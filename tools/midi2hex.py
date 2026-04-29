#!/usr/bin/env python3
"""
Convert a note text file into a HEX file for FPGA/music playback.

Input format example:
bpm:120
16e2 16d2 8#f 8#g 16#c2 16b 8d 8e 16b 16a 8#c 8e 2a 2-

Rules:
- First line must be: bpm:<value>
- Notes are written as: <duration><note>
- Duration is a denominator:
    1 = whole note
    2 = half note
    4 = quarter note
    8 = eighth note
    16 = sixteenth note
    ...
- Notes:
    c d e f g a b
    sharps with # (e.g. #c, #f)
    optional octave number (default = 1)
    pause = -
- Output:
    6 LSB = note code from note_pkg.sv mapping
    upper bits = number of sync cycles
- Sync signal:
    65 MHz clock gated once every 256 cycles
    => sync frequency = 65_000_000 / 256
"""

import re
import sys
from pathlib import Path

# ------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------

SYNC_FREQ = 65_000_000 / 256  # Hz

# NOTE MAPPING (adjust to match your note_pkg.sv)
NOTE_CODES = {
    "-": 0,

    "c1": 1,
    "#c1": 2,
    "d1": 3,
    "#d1": 4,
    "e1": 5,
    "f1": 6,
    "#f1": 7,
    "g1": 8,
    "#g1": 9,
    "a1": 10,
    "#a1": 11,
    "b1": 12,

    "c2": 13,
    "#c2": 14,
    "d2": 15,
    "#d2": 16,
    "e2": 17,
    "f2": 18,
    "#f2": 19,
    "g2": 20,
    "#g2": 21,
    "a2": 22,
    "#a2": 23,
    "b2": 24,

    "c3": 25,
    "#c3": 26,
    "d3": 27,
    "#d3": 28,
    "e3": 29,
    "f3": 30,
    "#f3": 31,
    "g3": 32,
    "#g3": 33,
    "a3": 34,
    "#a3": 35,
    "b3": 36,

    "c6": 37
}

# ------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------

def parse_bpm(line):
    match = re.match(r"bpm:(\d+)", line.strip())
    if not match:
        raise ValueError("First line must be in format: bpm:<value>")
    return int(match.group(1))


def parse_note_token(token):
    """
    Parse token like:
    16e2
    8#f
    2-
    """
    match = re.match(r"(\d+)(#?[a-g-])(\d?)$", token)
    if not match:
        raise ValueError(f"Invalid note format: {token}")

    duration = int(match.group(1))
    note = match.group(2)
    octave = match.group(3)

    if note == "-":
        key = "-"
    else:
        if octave == "":
            octave = "1"
        key = f"{note}{octave}"

    return duration, key


def duration_to_cycles(duration, bpm):
    """
    Convert note duration to sync cycles.

    Quarter note duration:
        60 / bpm seconds

    For duration denominator:
        note_time = quarter_note * (4 / duration)
    """
    quarter_time = 60.0 / bpm
    note_time = quarter_time * (4 / duration)

    cycles = int(round(note_time * SYNC_FREQ))
    return cycles


def encode_word(cycles, note_code):
    """
    Upper bits = cycles
    Lower 6 bits = note code
    """
    return (cycles << 6) | (note_code & 0x3F)


def convert_file(input_path, output_path):
    with open(input_path, "r") as f:
        lines = [line.strip() for line in f if line.strip()]

    bpm = parse_bpm(lines[0])

    tokens = []
    for line in lines[1:]:
        tokens.extend(line.split())

    output_words = []

    for token in tokens:
        duration, note_key = parse_note_token(token)

        if note_key not in NOTE_CODES:
            raise ValueError(f"Unknown note: {note_key}")

        note_code = NOTE_CODES[note_key]
        cycles = duration_to_cycles(duration, bpm)
        word = encode_word(cycles, note_code)

        output_words.append(word)

    with open(output_path, "w") as f:
        f.write(f"// music rom content of: {input_path}\n// bpm = {bpm} \n// SIZE = {len(output_words)}\n")
        for word in output_words:
            f.write(f"{word:08X}\n")

    print(f"Converted {len(output_words)} notes.")
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