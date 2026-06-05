#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the directory where this bash script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Navigate to the tools directory to keep relative paths consistent
cd "$SCRIPT_DIR"

echo "=================================================="
echo " Starting SystemVerilog Documentation Generator   "
echo "=================================================="

# Check if the python script exists
if [ -f "doc_generator.py" ]; then
    # Make sure the Python script is executable, just in case
    chmod +x doc_generator.py
    
    # Run the python script
    py doc_generator.py
else
    echo "❌ Error: doc_generator.py not found in $SCRIPT_DIR"
    exit 1
fi

echo "=================================================="
echo " Process Finished Successfully!                   "
echo "=================================================="