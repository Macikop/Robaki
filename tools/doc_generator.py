#!/usr/bin/env python3
import os
import re
from pathlib import Path

class SVDocGenerator:
    def __init__(self):
        # Detect project root depending on where script is run
        current_dir = Path.cwd()
        if current_dir.name == "tools":
            self.project_root = current_dir.parent
        else:
            self.project_root = current_dir

        self.rtl_dir = self.project_root / "rtl"
        self.docs_dir = self.project_root / "doc" / "project_docs"

    def clean_file_contents(self, file_path):
        """Removes code block comments while preserving formatting structures for parsers."""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception:
            return ""

        # Remove multi-line comments /* ... */ safely
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        # Remove single-line comments // ...
        content = re.sub(r'//.*', '', content)
        
        lines = []
        for line in content.splitlines():
            cleaned_line = line.strip()
            if cleaned_line:
                lines.append(cleaned_line)
                
        return "\n".join(lines)

    def parse_header_comments(self, file_path):
        """Extracts block comment meta-data fields while preserving multiline formatting and diagrams."""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception:
            return ""

        # Find all block comments up until the module/package/interface declaration starts
        code_start = re.search(r'\b(module|package|interface)\b', content)
        search_limit = code_start.start() if code_start else len(content)
        
        block_matches = re.findall(r'/\*(.*?)\*/', content[:search_limit], flags=re.DOTALL)
        if not block_matches:
            return "**Description:** No active functional description found.\n\n---"

        combined_blocks = "\n".join(block_matches)
        
        def extract_field(pattern, text):
            match = re.search(pattern, text, re.IGNORECASE)
            return match.group(1).strip() if match else ""

        author = extract_field(r'author\s*:?\s*([^\n]+)', combined_blocks)
        designer = extract_field(r'designed by\s*:?\s*([^\n]+)', combined_blocks)
        if not author and designer:
            author = designer

        modified = extract_field(r'(?:modified|modified on)\s*:?\s*([^\n]+)', combined_blocks)

        # Extract Multiline Description perfectly preserving lines or diagram blocks
        desc = ""
        desc_match = re.search(r'(?:description|how it works)\s*:?\s*(.*)', combined_blocks, re.IGNORECASE | re.DOTALL)
        if desc_match:
            desc_lines = desc_match.group(1).split('\n')
            cleaned_lines = []
            is_diagram = False
            
            for line in desc_lines:
                line_clean = re.sub(r'^\s*\*?\s*', '', line)
                line_rstrip = line_clean.rstrip()
                
                if re.match(r'^(author|designed by|modified|copyright):', line_rstrip.strip(), re.IGNORECASE):
                    break
                
                if any(marker in line_rstrip for marker in ['--', '|', '[', ']']):
                    is_diagram = True
                
                cleaned_lines.append(line_rstrip)

            if is_diagram:
                desc = "\n" + "\n".join([f"> {l}" if l.strip() else ">" for l in cleaned_lines])
            else:
                desc = "\n" + "\n".join(cleaned_lines)
        else:
            desc = "No active functional description found."

        md = ""
        if author: 
            md += f"**Author:** {author}  \n"
        if designer and designer != author: 
            md += f"**Designer:** {designer}  \n"
        if modified: 
            md += f"**Modified:** {modified}  \n"
            
        md += f"**Description:** {desc}\n\n---"
        return md

    def parse_module_interface(self, clean_code, mod_name):
        """Parses parameters and ports robustly matching balanced tokens."""
        mod_match = re.search(rf'\bmodule\s+{mod_name}\b', clean_code)
        if not mod_match:
            return [], []

        start_idx = mod_match.end()
        depth = 0
        in_header = False
        header_end_idx = -1
        
        # Track parenthesis accurately until we find the final closing semicolon
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
            return [], []

        header_text = clean_code[start_idx:header_end_idx].strip()

        param_block = ""
        port_block = ""
        
        # Isolate parameters and ports safely handling nesting
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

        def safe_split(block):
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

        # Parse Parameters Table
        parameters = []
        if param_block:
            for param in safe_split(param_block):
                param = re.sub(r'^parameter\s+', '', param).strip()
                if '=' in param:
                    decl, val = param.split('=', 1)
                    decl = decl.strip()
                    val = val.strip()
                    tokens = decl.split()
                    param_name = tokens[-1]
                    param_type = " ".join(tokens[:-1]) if len(tokens) > 1 else "int/logic"
                    parameters.append({"name": param_name, "type": param_type, "value": val})

        # Parse Ports Table
        ports = []
        if port_block:
            port_entries = safe_split(port_block)
            
            for raw_port in port_entries:
                if not raw_port: continue
                
                direction = "inherited/interface"
                dir_match = re.match(r'^(input|output|inout|ref)\b\s*', raw_port)
                if dir_match:
                    direction = dir_match.group(1)
                    raw_port = raw_port[dir_match.end():].strip()
                elif '.' in raw_port:
                    direction = "interface"

                tokens = raw_port.split()
                if not tokens: continue
                
                port_name_raw = tokens[-1]
                clean_port_name = re.sub(r'\[.*\]', '', port_name_raw).replace(';', '').strip()
                
                data_type = raw_port[:raw_port.rfind(port_name_raw)].strip()
                
                if direction in ["interface", "inherited/interface"]:
                    if '.' in raw_port:
                        data_type = "interface"
                    elif not data_type:
                        data_type = "logic"
                else:
                    if not data_type or data_type.startswith('['):
                        data_type = f"logic {data_type}".strip()

                ports.append({"dir": direction, "type": data_type, "name": clean_port_name})

        return parameters, ports
    
    def document_module(self, src, md_path, file_name, rel_depth):
        clean_code = self.clean_file_contents(src)
        
        # Find the actual module name inside the code to avoid filename typos
        match = re.search(r'\bmodule\s+([A-Za-z0-9_]+)', clean_code)
        actual_mod_name = match.group(1) if match else file_name.stem
        
        params, ports = self.parse_module_interface(clean_code, actual_mod_name)

        with open(md_path, 'w', encoding='utf-8') as md:
            md.write(f"# Module: {actual_mod_name}\n")
            md.write(f"[⬅️ Back to Directory Index]({rel_depth}index.md)\n\n")
            md.write("## Overview\n")
            
            overview_desc = self.parse_header_comments(src).strip()
            md.write(overview_desc)
            md.write("\n\n")

            # Parameters Table Output
            if params:
                md.write("## Parameter Configurations\n")
                md.write("| Parameter Name | Data Type | Default Assignment / Value |\n")
                md.write("| :--- | :--- | :--- |\n")
                for p in params:
                    md.write(f"| **{p['name']}** | `{p['type']}` | `{p['value']}` |\n")
                md.write("\n")

            # Ports Table Output
            md.write("## Port Interface\n")
            md.write("| Direction | Data Type | Port Name |\n")
            md.write("| :--- | :--- | :--- |\n")
            if ports:
                for p in ports:
                    md.write(f"| {p['dir']} | `{p['type']}` | **{p['name']}** |\n")
            else:
                md.write("| None | Internal / Parameter Only | N/A |\n")

    def document_package(self, src, md_path, file_name, rel_depth):
        pkg_name = file_name.stem
        clean_code = self.clean_file_contents(src)

        with open(md_path, 'w', encoding='utf-8') as md:
            md.write(f"# Package Declaration: {pkg_name}\n")
            md.write(f"[⬅️ Back to Directory Index]({rel_depth}index.md)\n\n")
            md.write("## Summary Information\n")
            md.write(self.parse_header_comments(src))
            md.write("\n\n## Package Contents\n")
            md.write("| Type Structure | Name / Identifier | Definition Value / Content Mapping |\n")
            md.write("| :--- | :--- | :--- |\n")

            has_contents = False

            # 1. Parse Enums
            enum_regex = r'typedef\s+enum\s*([^{]*)\{([^}]+)\}\s*([A-Za-z0-9_]+)?\s*;'
            enum_matches = list(re.finditer(enum_regex, clean_code))
            for match in enum_matches:
                has_contents = True
                base_type = match.group(1).strip() or "int"
                enum_elements = match.group(2)
                enum_name = match.group(3).strip() if match.group(3) else "Anonymous Enum"
                
                elements_html = "<br>".join([f"`{i.strip()}`" for i in enum_elements.split(',') if i.strip()])
                md.write(f"| `enum ({base_type})` | **{enum_name}** | Elements:<br>{elements_html} |\n")

            # Parse localparam and parameter allocations within package scope
            param_regex = r'\b(localparam|parameter)\s+([^=]+)=\s*([^;]+);'
            param_matches = list(re.finditer(param_regex, clean_code))
            for match in param_matches:
                has_contents = True
                param_kind = match.group(1)
                decl = match.group(2).strip()
                val = match.group(3).strip()
                
                tokens = decl.split()
                param_name = tokens[-1]
                param_type = " ".join(tokens[:-1]) if len(tokens) > 1 else "implicit"
                
                type_str = f"`{param_kind}`" if param_type == "implicit" else f"`{param_kind} ({param_type})`"
                md.write(f"| {type_str} | **{param_name}** | `{val}` |\n")

            if not has_contents:
                md.write("| Empty | No constants or tracked type enums found | N/A |\n")

    def document_interface(self, src, md_path, file_name, rel_depth):
        if_name = file_name.stem
        clean_code = self.clean_file_contents(src)

        with open(md_path, 'w', encoding='utf-8') as md:
            md.write(f"# Interface Architecture: {if_name}\n")
            md.write(f"[⬅️ Back to Directory Index]({rel_depth}index.md)\n\n")
            md.write("## Overview Profiles\n")
            md.write(self.parse_header_comments(src))
            md.write("\n\n## Declared Modport Sub-Interfaces\n")

            modport_regex = r'modport\s+([A-Za-z0-9_]+)\s*\(([^)]+)\)'
            matches = list(re.finditer(modport_regex, clean_code))

            if not matches:
                md.write("No individual custom modport configurations found in this interface boundary.\n")
                return

            for match in matches:
                name = match.group(1)
                contents = match.group(2)
                md.write(f"\n### Modport: `{name}`\n")
                md.write("| Direction | Signal Group |\n")
                md.write("| :--- | :--- |\n")
                
                signals = [s.strip() for s in contents.split(',') if s.strip()]
                current_direction = "port"
                for sig in signals:
                    dir_match = re.match(r'^(input|output|inout)\s+(.+)$', sig)
                    if dir_match:
                        current_direction = dir_match.group(1)
                        sig = dir_match.group(2)
                    elif sig in ['input', 'output', 'inout']:
                        current_direction = sig
                        continue
                    md.write(f"| {current_direction} | **{sig}** |\n")

    def run(self):
        print("Generating SystemVerilog documentation matrix mirroring workspace paths...")
        self.docs_dir.mkdir(parents=True, exist_ok=True)
        index_path = self.docs_dir / "index.md"
        
        with open(index_path, 'w', encoding='utf-8') as idx_file:
            idx_file.write("# Project Architecture & IP Directory Index\n")
            # Injected custom link to jump straight to the project level README
            idx_file.write("[🏠 Go to Project README](../../README.md)\n\n")
            idx_file.write("Generated tracking tree of available functional system hardware modules.\n\n")
            idx_file.write("## Component Directories\n")

            for root, dirs, files in os.walk(self.rtl_dir):
                root_path = Path(root)
                sv_files = [Path(f) for f in files if f.endswith('.sv')]
                if not sv_files:
                    continue

                if root_path == self.rtl_dir:
                    rel_path = ""
                    idx_file.write("\n### 📂 Area Workspace: `rtl/` (Root Area)\n")
                else:
                    rel_path = root_path.relative_to(self.rtl_dir)
                    idx_file.write(f"\n### 📂 Area Workspace: `rtl/{rel_path}`\n")

                target_out_dir = self.docs_dir / rel_path if rel_path else self.docs_dir
                target_out_dir.mkdir(parents=True, exist_ok=True)

                depth_count = len(Path(rel_path).parts) if rel_path else 0
                rel_depth = "../" * depth_count

                for sv_file in sorted(sv_files):
                    src_full_path = root_path / sv_file
                    md_dest_path = target_out_dir / f"{sv_file.stem}.md"
                    link_ref = f"{rel_path}/{sv_file.stem}.md" if rel_path else f"{sv_file.stem}.md"

                    if sv_file.name.endswith('_pkg.sv'):
                        self.document_package(src_full_path, md_dest_path, sv_file, rel_depth)
                        idx_file.write(f"* 📦 Package Reference: [{sv_file.stem}]({link_ref})\n")
                    elif sv_file.name.endswith('_if.sv'):
                        self.document_interface(src_full_path, md_dest_path, sv_file, rel_depth)
                        idx_file.write(f"* 🔀 Interface Mapping: [{sv_file.stem}]({link_ref})\n")
                    else:
                        self.document_module(src_full_path, md_dest_path, sv_file, rel_depth)
                        idx_file.write(f"* 🛠️ Logic Module: [{sv_file.stem}]({link_ref})\n")

        print(f"Documentation processing completed successfully!\nOutput structure exactly mirrored: {self.docs_dir}/")

if __name__ == "__main__":
    generator = SVDocGenerator()
    generator.run()