#!/bin/bash

# Ollama Test Output Analyzer
# Cleans and analyzes test outputs for quality assessment

set -e

# Accept timestamp as argument or find latest
if [[ $# -gt 0 ]]; then
    TIMESTAMP="$1"
else
    # Find the latest timestamp from output files
    TIMESTAMP=$(ls outputs/*.out 2>/dev/null | grep -o '[0-9]\{8\}_[0-9]\{6\}' | sort -u | tail -n 1)
    if [[ -z "$TIMESTAMP" ]]; then
        echo "Error: No output files found and no timestamp provided"
        echo "Usage: $0 [TIMESTAMP]"
        exit 1
    fi
fi

OUTPUT_DIR="outputs"
CLEAN_DIR="outputs_clean"

mkdir -p "${CLEAN_DIR}"

echo "=== Cleaning Test Outputs ==="

# Function to clean terminal control sequences
clean_output() {
    local input_file="$1"
    local output_file="$2"
    
    # Remove all ANSI escape sequences, control characters, and spinner characters
    sed -E 's/\x1b\[[0-9;?]*[mGKHhl]//g' "${input_file}" | \
    sed -E 's/\[[0-9;?]*[mGKHhl]//g' | \
    sed 's/[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏]//g' | \
    sed 's/\[?[0-9]*[hl]//g' | \
    tr -d '\r' | \
    sed '/^[[:space:]]*$/d' | \
    sed 's/^[[:space:]]*//g' > "${output_file}"
}

# Clean all output files
for file in "${OUTPUT_DIR}"/*"${TIMESTAMP}".out; do
    if [[ -f "${file}" ]]; then
        filename=$(basename "${file}")
        echo "Cleaning ${filename}..."
        clean_output "${file}" "${CLEAN_DIR}/${filename}"
    fi
done

echo "Clean outputs available in ${CLEAN_DIR}/"
echo ""
echo "=== Cleaned Output Files ==="
echo "Raw output files have been cleaned to remove terminal escape codes"
echo ""

# Dynamic analysis of cleaned files
cleaned_count=0
for file in "${CLEAN_DIR}"/*"${TIMESTAMP}".out; do
    if [[ -f "${file}" ]]; then
        filename=$(basename "${file}")
        word_count=$(wc -w < "${file}")
        line_count=$(wc -l < "${file}")
        
        echo "📄 ${filename}"
        echo "   Lines: ${line_count}, Words: ${word_count}"
        echo "   Preview: $(head -n 3 "${file}" | tr '\n' ' ' | cut -c1-80)..."
        echo ""
        
        cleaned_count=$((cleaned_count + 1))
    fi
done

if [[ $cleaned_count -eq 0 ]]; then
    echo "⚠️  No files were cleaned for timestamp ${TIMESTAMP}"
    echo "   Check if output files exist: ls -la ${OUTPUT_DIR}/*${TIMESTAMP}*"
else
    echo "✅ ${cleaned_count} output files cleaned and ready for analysis"
fi

echo "📁 Location: ${CLEAN_DIR}/"
