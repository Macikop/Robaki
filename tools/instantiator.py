#!/usr/bin/env python3
import os
import re
import sys
from pathlib import Path

class SVInstantiator:
    def __init__(self):
        current_dir = Path.cwd()
        if current_dir.name == "tools":
            self.project_root = current_dir.parent
        else:
            self.project_root = current_dir

        self.rtl_dir = self.project_root / "rtl"

    def clean_file_contents(self, file_path):
        """Removes comments while preserving structural header text."""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception:
            return ""
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        content = re.sub(r'//.*', '', content)
        return content

    def parse_module(self, clean_code, mod_name):
        """Finds the module header block and splits parameters and ports."""
        mod_match = re.search(rf'\bmodule\s+{mod_name}\b', clean_code)
        if not mod_match:
            return None, None

        start_idx = mod_match.end()
        depth = 0
        in_header = False
        header_end_idx = -1
        
        for i in range(start_idx, len(clean_code)):
            ch = clean_code[i]
            if ch == '(':
                depth += 1
                in_header = True
            elif ch == ')':
                depth -= 1
            elif ch == ';' and depth == 0 and in_header:
                header_end_idx = i
                break
                
        if header_end_idx == -1:
            return None, None

        header_text = clean_code[start_idx:header_end_idx].strip()
        param_block = ""
        port_block = ""
        
        if header_text.startswith('#'):
            p_depth = 0
            p_start = header_text.find('(')
            p_end = -1
            if p_start != -1:
                for idx in range(p_start, len(header_text)):
                    c = header_text[idx]
                    if c == '(': p_depth += 1
                    elif c == ')': p_depth -= 1
                    if p_depth == 0:
                        p_end = idx
                        break
            if p_end != -1:
                param_block = header_text[p_start+1:p_end].strip()
                port_part = header_text[p_end+1:].strip()
                port_start = port_part.find('(')
                port_end = port_part.rfind(')')
                if port_start != -1 and port_end != -1:
                    port_block = port_part[port_start+1:port_end].strip()
        else:
            port_start = header_text.find('(')
            port_end = header_text.rfind(')')
            if port_start != -1 and port_end != -1:
                port_block = header_text[port_start+1:port_end].strip()

        return param_block, port_block

    def safe_split(self, block):
        """Splits declarations by comma while honoring nested brackets/parentheses."""
        if not block:
            return []
        elements = []
        current = []
        paren_depth = 0
        bracket_depth = 0
        brace_depth = 0
        
        for ch in block:
            if ch == '(': paren_depth += 1
            elif ch == ')': paren_depth -= 1
            elif ch == '[': bracket_depth += 1
            elif ch == ']': bracket_depth -= 1
            elif ch == '{': brace_depth += 1
            elif ch == '}': brace_depth -= 1
            elif ch == ',' and paren_depth == 0 and bracket_depth == 0 and brace_depth == 0:
                elements.append("".join(current).strip())
                current = []
                continue
            current.append(ch)
        if current:
            elements.append("".join(current).strip())
        return [e for e in elements if e]

    def extract_param_names(self, param_block):
        names = []
        for param in self.safe_split(param_block):
            param = re.sub(r'^parameter\s+', '', param).strip()
            if '=' in param:
                decl = param.split('=', 1)[0].strip()
                names.append(decl.split()[-1])
        return names

    def extract_port_names(self, port_block):
        names = []
        for raw_port in self.safe_split(port_block):
            if not raw_port or '.' in raw_port: 
                continue
            dir_match = re.match(r'^(input|output|inout|ref)\b\s*', raw_port)
            if dir_match:
                raw_port = raw_port[dir_match.end():].strip()
            
            tokens = raw_port.split()
            if tokens:
                port_name_raw = tokens[-1]
                clean_port_name = re.sub(r'\[.*\]', '', port_name_raw).replace(';', '').strip()
                names.append(clean_port_name)
        return names

    def find_and_generate(self, target_input):
        """Parses inputs like 'core/rng' or just 'rng' and targets the correct file."""
        # Handle section tracking if a slash is provided
        if "/" in target_input:
            section, target_module = target_input.split("/", 1)
            search_dir = self.rtl_dir / section
        else:
            target_module = target_input
            search_dir = self.rtl_dir

        if not search_dir.exists():
            print(f"❌ Error: The directory area '{search_dir.relative_to(self.project_root)}' does not exist.")
            return False

        for root, _, files in os.walk(search_dir):
            for file in files:
                if file.endswith('.sv') and not file.endswith('_pkg.sv') and not file.endswith('_if.sv'):
                    file_path = Path(root) / file
                    clean_code = self.clean_file_contents(file_path)
                    
                    match = re.search(r'\bmodule\s+([A-Za-z0-9_]+)', clean_code)
                    actual_mod_name = match.group(1) if match else file_path.stem
                    
                    if target_module in [file_path.stem, actual_mod_name]:
                        param_block, port_block = self.parse_module(clean_code, actual_mod_name)
                        
                        params = self.extract_param_names(param_block)
                        ports = self.extract_port_names(port_block)
                        
                        self.print_instantiation(actual_mod_name, params, ports)
                        return True
        return False

    def print_instantiation(self, mod_name, params, ports):
        """Formats and prints the structural template to stdout with empty mappings."""
        lines = []
        
        if params:
            lines.append(f"{mod_name} #(")
            max_p_len = max(len(p) for p in params)
            for i, p in enumerate(params):
                comma = "," if i < len(params) - 1 else ""
                lines.append(f"    .{p:<{max_p_len}} (){comma}")
            lines.append(f") u_{mod_name} (")
        else:
            lines.append(f"{mod_name} u_{mod_name} (")

        if ports:
            max_v_len = max(len(v) for v in ports)
            for i, v in enumerate(ports):
                comma = "," if i < len(ports) - 1 else ""
                lines.append(f"    .{v:<{max_v_len}} (){comma}")
        else:
            lines.append("    /* No functional ports declared */")
            
        lines.append(");")
        
        print("\n" + "\n".join(lines) + "\n")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 sv_instantiator.py <section/module_name>")
        print("Example: python3 sv_instantiator.py core/rng")
        sys.exit(1)
        
    target = sys.argv[1]
    instantiator = SVInstantiator()
    if not instantiator.find_and_generate(target):
        print(f"Error: Module '{target}' could not be identified in your target tree location.")
        sys.exit(1)