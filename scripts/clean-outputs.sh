#!/bin/bash

# Ollama Test Output Analyzer
# Cleans and analyzes test outputs for quality assessment

set -e

TIMESTAMP="20250611_213201"
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
echo "=== Analysis Summary ==="
echo ""

# Quick analysis function
analyze_file() {
    local file="$1"
    local test_name="$2"
    
    if [[ -f "${file}" ]]; then
        local word_count=$(wc -w < "${file}")
        local line_count=$(wc -l < "${file}")
        echo "📄 ${test_name}"
        echo "   Lines: ${line_count}, Words: ${word_count}"
        echo "   Preview: $(head -n 3 "${file}" | tr '\n' ' ' | cut -c1-80)..."
        echo ""
    fi
}

# Analyze qwen2.5-coder outputs
echo "🤖 qwen2.5-coder:7b Results:"
echo ""
analyze_file "${CLEAN_DIR}/qc01_${TIMESTAMP}.out" "QC-01: Binary Search Implementation"
analyze_file "${CLEAN_DIR}/qc02_${TIMESTAMP}.out" "QC-02: Performance Optimization" 
analyze_file "${CLEAN_DIR}/qc03_${TIMESTAMP}.out" "QC-03: Bug Fixing"
analyze_file "${CLEAN_DIR}/qc04_${TIMESTAMP}.out" "QC-04: Code Review"
analyze_file "${CLEAN_DIR}/qc05_${TIMESTAMP}.out" "QC-05: Documentation Generation"
analyze_file "${CLEAN_DIR}/qc06_${TIMESTAMP}.out" "QC-06: API Integration"

echo "🤖 mistral-nemo:12b Results:"
echo ""
analyze_file "${CLEAN_DIR}/mn01_${TIMESTAMP}.out" "MN-01: CSV Data Analysis"
analyze_file "${CLEAN_DIR}/mn02_${TIMESTAMP}.out" "MN-02: Email Thread Correlation"
analyze_file "${CLEAN_DIR}/mn03_${TIMESTAMP}.out" "MN-03: Multi-source Data Fusion"
analyze_file "${CLEAN_DIR}/mn04_${TIMESTAMP}.out" "MN-04: Data Validation"
analyze_file "${CLEAN_DIR}/mn05_${TIMESTAMP}.out" "MN-05: Executive Report Generation"
analyze_file "${CLEAN_DIR}/mn06_${TIMESTAMP}.out" "MN-06: Pattern Recognition"

echo "✅ Clean outputs ready for detailed human analysis"
echo "📁 Location: ${CLEAN_DIR}/"
