#!/usr/bin/env python3
"""
Convert an RTTTL note file into a HEX file for FPGA/music playback.

Input format example (RTTTL):
NokiaTune:d=4,o=5,b=180:16e6,16d6,8f#6,8g#6,16c#6,16b,8d6,8e6,16b,16a,8c#6,8e6,2a6

Rules:
- Standard RTTTL string split into 3 sections by ':'
- Header sets defaults: d (duration), o (octave), b (bpm)
- Notes are separated by commas
- Layout: <duration><note><scale/octave>
- Sharps use '#' after the note letter (e.g., f#, c#)
- Pause/rest is denoted by 'p' or '-'

Output:
    6 LSB = note code from note_pkg.sv mapping
    upper bits = number of sync cycles
"""

import re
import sys
from pathlib import Path

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------

SYNC_FREQ = 65_000_000 / 256  # Hz

# NOTE MAPPING (adjust to match your note_pkg.sv)
# RTTTL usually spans octaves 4 through 7. 
# We map them to your system's available 1, 2, 3 structures.
# (e.g. mapping RTTTL octave 5 to your octave 1, 6 to 2, 7 to 3)
NOTE_CODES = {
    "-": 0,

    "c1": 1, "#c1": 2, "d1": 3, "#d1": 4, "e1": 5, "f1": 6, "#f1": 7, "g1": 8, "#g1": 9, "a1": 10, "#a1": 11, "b1": 12,
    "c2": 13, "#c2": 14, "d2": 15, "#d2": 16, "e2": 17, "f2": 18, "#f2": 19, "g2": 20, "#g2": 21, "a2": 22, "#a2": 23, "b2": 24,
    "c3": 25, "#c3": 26, "d3": 27, "#d3": 28, "e3": 29, "f3": 30, "#f3": 31, "g3": 32, "#g3": 33, "a3": 34, "#a3": 35, "b3": 36,
    "c6": 37
}

# ------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------

def parse_rtttl_header(settings_str):
    """
    Parses the configuration section of RTTTL (e.g., 'd=4,o=5,b=180')
    Returns default_duration, default_octave, bpm
    """
    # Defaults if missing
    d_dur = 4
    d_oct = 5
    bpm = 120

    pairs = settings_str.lower().split(',')
    for pair in pairs:
        if '=' in pair:
            key, val = pair.split('=')
            key = key.strip()
            val = int(val.strip())
            if key == 'd': d_dur = val
            elif key == 'o': d_oct = val
            elif key == 'b': bpm = val

    return d_dur, d_oct, bpm


def parse_rtttl_token(token, def_dur, def_oct):
    """
    Parse a standard RTTTL note token like: '16e6', '8f#6', '4b', 'p'
    """
    token = token.strip().lower()
    if not token:
        return None

    # Regex breaks up: 
    # 1. Option duration (\d*) 
    # 2. Note letters and sharps ([a-g-p]#?)
    # 3. Optional octave scale (\d*)
    match = re.match(r"(\d*)([a-g-p]#?)(\d*)$", token)
    if not match:
        raise ValueError(f"Invalid RTTTL note format: {token}")

    duration_str = match.group(1)
    note_str = match.group(2)
    octave_str = match.group(3)

    # Determine duration
    duration = int(duration_str) if duration_str else def_dur

    # Determine Rest or Note
    if note_str in ['p', '-']:
        return duration, "-"
    
    # Standardizing sharp placement for your NOTE_CODES dictionary (e.g. 'f#' -> '#f')
    if '#' in note_str:
        note_str = '#' + note_str.replace('#', '')

    # Determine Octave
    rtttl_octave = int(octave_str) if octave_str else def_oct
    
    # Map RTTTL standard octaves down to match your FPGA key mappings (c1, c2, c3)
    # RTTTL default standard octave is typically 5 or 6. 
    # Let's map RTTTL Octave 5 -> 1, Octave 6 -> 2, Octave 7 -> 3.
    fpga_octave = rtttl_octave - 4
    if fpga_octave < 1: fpga_octave = 1
    if fpga_octave > 3: fpga_octave = 3

    # Exception check for c6 edge case in your dictionary
    key = f"{note_str}{fpga_octave}"
    if key == "c4":  # if it overflows boundaries slightly 
        key = "c3"

    return duration, key


def duration_to_cycles(duration, bpm):
    """Convert note duration to sync cycles based on BPM."""
    quarter_time = 60.0 / bpm
    note_time = quarter_time * (4 / duration)
    cycles = int(round(note_time * SYNC_FREQ))
    return cycles


def encode_word(cycles, note_code):
    """Upper bits = cycles, Lower 6 bits = note code"""
    return (cycles << 6) | (note_code & 0x3F)


def convert_file(input_path, output_path):
    with open(input_path, "r") as f:
        # Read entire content and combine lines in case RTTTL string is split across lines
        content = "".join([line.strip() for line in f if line.strip()])

    # Split the 3 core RTTTL sections
    sections = content.split(':')
    if len(sections) < 3:
        raise ValueError("Invalid RTTTL file! Must contain parts separated by ':' (Name:Settings:Notes)")

    name = sections[0].strip()
    settings_str = sections[1].strip()
    notes_str = sections[2].strip()

    # Parse headers
    def_dur, def_oct, bpm = parse_rtttl_header(settings_str)

    # RTTTL notes are strictly comma-separated
    tokens = notes_str.split(',')
    output_words = []

    for token in tokens:
        res = parse_rtttl_token(token, def_dur, def_oct)
        if res is None:
            continue
        
        duration, note_key = res

        if note_key not in NOTE_CODES:
            raise ValueError(f"Parsed note '{note_key}' (from token '{token}') is missing in NOTE_CODES map.")

        note_code = NOTE_CODES[note_key]
        cycles = duration_to_cycles(duration, bpm)
        word = encode_word(cycles, note_code)

        output_words.append(word)

    with open(output_path, "w") as f:
        f.write(f"// music rom content of RTTTL: {name}\n// bpm = {bpm} \n// SIZE = {len(output_words)}\n")
        for word in output_words:
            f.write(f"{word:08X}\n")

    print(f"Converted {len(output_words)} notes from '{name}'.")
    print(f"Output written to: {output_path}")


# ------------------------------------------------------------
# MAIN
# ------------------------------------------------------------

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 notes_to_hex.py <input_file>")
        sys.exit(1)

    input_path = Path(sys.argv[1])
    output_path = input_path.with_suffix(".hex")

    convert_file(input_path, output_path)


if __name__ == "__main__":
    main()