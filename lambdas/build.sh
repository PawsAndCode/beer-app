#!/bin/bash

# Create build directory if it doesn't exist
mkdir -p build

# Function to zip a single Python file into the build directory
zip_lambda() {
  local lambda_name=$1
  if [[ -f "$lambda_name.py" ]]; then
    echo "Building zip for $lambda_name.py..."
    zip -r "build/${lambda_name}.zip" "${lambda_name}.py"
  else
    echo "Error: File $lambda_name.py not found!"
    exit 1
  fi
}

# If a specific Lambda name is provided as the argument, use it
if [ $# -eq 1 ]; then
  zip_lambda $1
# Otherwise, zip all Python files in the current directory
else
  for py_file in *.py; do
    # Ensure it's a Python file and not an unwanted file
    if [[ -f "$py_file" && "$py_file" == *.py ]]; then
      # Remove the ".py" extension for the zip file name
      lambda_name="${py_file%.py}"
      zip_lambda $lambda_name
    fi
  done
fi
