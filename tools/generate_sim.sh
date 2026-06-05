#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Detect project root depending on where script is run
if [ "$(basename "$PWD")" = "tools" ]; then
    PROJECT_ROOT=".."
else
    PROJECT_ROOT="."
fi

RTL_DIR="$PROJECT_ROOT/rtl"
SIM_DIR="$PROJECT_ROOT/sim"
TEMPLATE_DIR="$PROJECT_ROOT/tools/templates"
IGNORE_FILE="$PROJECT_ROOT/.simignore"

if [ ! -d "$RTL_DIR" ] || [ ! -f "$TEMPLATE_DIR/template.sv" ] || [ ! -f "$TEMPLATE_DIR/template.prj" ]; then
    echo "Error: Required folders or templates missing."
    exit 1
fi

# Help menu
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -a, --all             Generate simulation templates for ALL suitable modules"
    echo "  -m, --module <name>   Generate sim files only for a specific sub-module folder"
    echo "  -h, --help            Show this help message"
    exit 0
}

# If no arguments are provided, show the help menu and exit
if [ "$#" -eq 0 ]; then
    usage
fi

# Parse arguments
TARGET_MODULE=""
RUN_ALL=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -a|--all) RUN_ALL=1 ;;
        -m|--module) TARGET_MODULE="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

# Load .simignore patterns or use fallback defaults
IGNORE_PATTERNS=()
if [ -f "$IGNORE_FILE" ]; then
    while read -r line || [ -n "$line" ]; do
        clean_line=$(echo "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        if [ -n "$clean_line" ]; then
            IGNORE_PATTERNS+=("$clean_line")
        fi
    done < "$IGNORE_FILE"
else
    IGNORE_PATTERNS=("*_if.sv" "*_pkg.sv")
fi

# Helper function to check if an item matches an ignore pattern
is_ignored() {
    local item=$1
    local alt_item=$2
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        if [[ "$item" == $pattern ]] || { [ -n "$alt_item" ] && [[ "$alt_item" == $pattern ]]; }; then
            return 0 
        fi
    done
    return 1 
}

# Helper function to extract ports and parameters safely
generate_dut_instance() {
    local src_file=$1
    local mod_name=$2
    
    # Clean code: strip block comments, line comments, and minimize space
    local clean_code
    clean_code=$(awk '
        BEGIN {FS=OFS=""}
        {
            if (in_block) {
                if ($0 ~ /\*\//) { sub(/.*\*\//, ""); in_block=0 }
                else next
            }
            gsub(/\/\/.*/, "") 
            while (match($0, /\/\*.*?\*\//)) {
                sub(/\/\*.*?\*\//, "")
            }
            if (match($0, /\/\*/)) {
                sub(/\/\*.*/, "")
                in_block=1
            }
            print
        }
    ' "$src_file" | tr '\n' ' ' | tr -s ' ')

    # Extract parameters safely
    local param_list=""
    if [[ "$clean_code" =~ \#\s*\(([^)]+)\) ]]; then
        local param_block="${BASH_REMATCH[1]}"
        param_list=$(echo "$param_block" | grep -oE '[A-Za-z_][A-Za-z0-9_]*\s*(=|,|\))' | tr -d '=,)' | tr -s ' ')
    fi

    # Extract ALL port directions (input/output/inout) across multiple lines
    local port_list=""
    local processing_ports="${clean_code#*module*\(}"
    port_list=$(echo "$processing_ports" | grep -oE '(input|output|inout)\s+([^,)]+)' | awk '{print $NF}' | tr -d ';[]0-9:')

    # Construct structural mapping codeblock string
    local dut_string="    ${mod_name} "
    
    if [ -n "$param_list" ]; then
        dut_string+="#(\n"
        local first=1
        for p in $param_list; do
            if [ $first -eq 1 ]; then first=0; else dut_string+=",\n"; fi
            dut_string+="        .${p} ()"
        done
        dut_string+="\n    ) "
    fi
    
    dut_string+="dut (\n"
    local first=1
    for p in $port_list; do
        if [ $first -eq 1 ]; then first=0; else dut_string+=",\n"; fi
        dut_string+="        .${p} ()"
    done
    dut_string+="\n    );"

    echo -e "$dut_string"
}

# Determine module target scope based on parameters passed
cd "$RTL_DIR"
if [ "$RUN_ALL" -eq 1 ]; then
    MODULES=( $(find . -maxdepth 1 -type d ! -path .) )
    MODULES=("${MODULES[@]/#.\/}")
elif [ -n "$TARGET_MODULE" ]; then
    [ ! -d "$TARGET_MODULE" ] && { echo "Module folder '$TARGET_MODULE' not found."; exit 1; }
    MODULES=("$TARGET_MODULE")
else
    # Safety fallback rule
    echo "Error: No generation target specified."
    usage
fi
cd - > /dev/null

# Iterate through files
for MOD in "${MODULES[@]}"; do
    if is_ignored "$MOD"; then
        echo "[Ignored Module Area] Skipping directory: rtl/$MOD"
        continue
    fi

    echo "Processing module folder: rtl/$MOD"
    
    find "$RTL_DIR/$MOD" -maxdepth 1 -type f -name "*.sv" | while read -r FILE_PATH; do
        FILE_NAME=$(basename "$FILE_PATH")
        BASE_NAME="${FILE_NAME%.*}" 
        
        if is_ignored "$MOD/$FILE_NAME" "$FILE_NAME"; then
            echo "  [Ignored File] Skipping template generation for: $MOD/$FILE_NAME"
            continue
        fi
        
        MODULE_SIM_DIR="$SIM_DIR/$MOD/$BASE_NAME"
        mkdir -p "$MODULE_SIM_DIR"
        
        PRJ_FILE="$MODULE_SIM_DIR/${BASE_NAME}.prj"
        TB_FILE="$MODULE_SIM_DIR/${BASE_NAME}_tb.sv"
        
        # Cleanup routine
        if [ -d "$MODULE_SIM_DIR" ]; then
            find "$MODULE_SIM_DIR" -maxdepth 1 -type f \( -name "*.prj" -o -name "*.sv" \) | while read -r EXT_FILE; do
                EXT_NAME=$(basename "$EXT_FILE")
                if [ "$EXT_NAME" != "${BASE_NAME}.prj" ] && [ "$EXT_NAME" != "${BASE_NAME}_tb.sv" ]; then
                    echo "  [Removing] Incorrectly named file: $EXT_FILE"
                    rm "$EXT_FILE"
                fi
            done
        fi
        
        # Create Project Configuration
        if [ ! -f "$PRJ_FILE" ]; then
            echo "  [Creating] $PRJ_FILE"
            sed -e "s/__BASE_NAME__/${BASE_NAME}/g" -e "s/__MOD__/${MOD}/g" -e "s/__FILE_NAME__/${FILE_NAME}/g" "$TEMPLATE_DIR/template.prj" > "$PRJ_FILE"
        fi
        
        # Create Dynamic Structural Testbench Layout
        if [ ! -f "$TB_FILE" ]; then
            echo "  [Creating] $TB_FILE"
            
            DUT_PLACEMENT=$(generate_dut_instance "$FILE_PATH" "$BASE_NAME")
            
            awk -v replacement="$DUT_PLACEMENT" -v base="$BASE_NAME" '
            {
                gsub(/__BASE_NAME__/, base)
                if ($0 ~ /\/\*__DUT_PLACEMENT__\*\//) {
                    print replacement
                } else {
                    print
                }
            }' "$TEMPLATE_DIR/template.sv" > "$TB_FILE"
        else
            echo "  [Kept]     $TB_FILE (Valid setup exists)"
        fi
    done
done