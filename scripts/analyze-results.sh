#!/bin/bash

# Ollama Model Testing Framework - Results Analyzer
# Purpose: Analyze test results and generate comparison reports

set -e

# Configuration
RESULTS_DIR="results"
OUTPUTS_DIR="outputs" 
REPORTS_DIR="reports"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

mkdir -p "${REPORTS_DIR}"

echo -e "${GREEN}=== Ollama Test Results Analyzer ===${NC}"
echo ""

# Check if we have results
if [[ ! -d "${RESULTS_DIR}" ]] || [[ -z "$(ls -A ${RESULTS_DIR}/*.json 2>/dev/null)" ]]; then
    echo -e "${RED}[ERROR]${NC} No test results found in ${RESULTS_DIR}/"
    echo "Please run './scripts/run-tests.sh' first to generate test results."
    exit 1
fi

# Find the latest test run
latest_timestamp=$(ls "${RESULTS_DIR}"/*.json | grep -o '[0-9]\{8\}_[0-9]\{6\}' | sort | tail -n 1)
echo -e "${BLUE}[INFO]${NC} Analyzing results from test run: ${latest_timestamp}"

# Generate analysis report
report_file="${REPORTS_DIR}/analysis_${latest_timestamp}.md"

cat > "${report_file}" << 'EOF'
# Ollama Model Testing Results Analysis

## Executive Summary

This report presents the results of comprehensive testing performed on two Ollama models:
- **qwen2.5-coder:7b** - Coding assistance and software development tasks
- **mistral-nemo:12b** - Data processing and correlation tasks

## Test Execution Overview

EOF

echo "**Test Run Timestamp:** ${latest_timestamp}" >> "${report_file}"
echo "**Total Test Cases:** $(ls ${RESULTS_DIR}/*${latest_timestamp}.json | wc -l)" >> "${report_file}"
echo "" >> "${report_file}"

# Analyze qwen2.5-coder results
echo "## qwen2.5-coder:7b Results" >> "${report_file}"
echo "" >> "${report_file}"
echo "| Test ID | Test Name | Duration (s) | Tokens/sec | Status |" >> "${report_file}"
echo "|---------|-----------|--------------|------------|--------|" >> "${report_file}"

for result_file in "${RESULTS_DIR}"/qc*"${latest_timestamp}".json; do
    if [[ -f "${result_file}" ]]; then
        test_id=$(jq -r '.test_case.id' "${result_file}")
        test_title=$(jq -r '.test_case.title' "${result_file}")
        duration=$(jq -r '.metrics.quantitative.latency_ms / 1000' "${result_file}")
        tokens_per_sec=$(jq -r '.metrics.quantitative.tokens_per_second' "${result_file}")
        result=$(jq -r '.overall_result' "${result_file}")
        
        echo "| ${test_id} | ${test_title} | ${duration} | ${tokens_per_sec} | ${result} |" >> "${report_file}"
    fi
done

echo "" >> "${report_file}"

# Analyze mistral-nemo results
echo "## mistral-nemo:12b Results" >> "${report_file}"
echo "" >> "${report_file}"
echo "| Test ID | Test Name | Duration (s) | Tokens/sec | Status |" >> "${report_file}"
echo "|---------|-----------|--------------|------------|--------|" >> "${report_file}"

for result_file in "${RESULTS_DIR}"/mn*"${latest_timestamp}".json; do
    if [[ -f "${result_file}" ]]; then
        test_id=$(jq -r '.test_case.id' "${result_file}")
        test_title=$(jq -r '.test_case.title' "${result_file}")
        duration=$(jq -r '.metrics.quantitative.latency_ms / 1000' "${result_file}")
        tokens_per_sec=$(jq -r '.metrics.quantitative.tokens_per_second' "${result_file}")
        result=$(jq -r '.overall_result' "${result_file}")
        
        echo "| ${test_id} | ${test_title} | ${duration} | ${tokens_per_sec} | ${result} |" >> "${report_file}"
    fi
done

# Performance summary
cat >> "${report_file}" << 'EOF'

## Performance Analysis

### qwen2.5-coder:7b Performance
EOF

qwen_avg_duration=$(jq -s 'map(select(.model.name | contains("qwen")) | .metrics.quantitative.latency_ms / 1000) | add / length' "${RESULTS_DIR}"/*"${latest_timestamp}".json)
qwen_avg_tokens_sec=$(jq -s 'map(select(.model.name | contains("qwen")) | .metrics.quantitative.tokens_per_second) | add / length' "${RESULTS_DIR}"/*"${latest_timestamp}".json)

echo "- **Average Response Time:** ${qwen_avg_duration} seconds" >> "${report_file}"
echo "- **Average Throughput:** ${qwen_avg_tokens_sec} tokens/second" >> "${report_file}"
echo "" >> "${report_file}"

echo "### mistral-nemo:12b Performance" >> "${report_file}"

mistral_avg_duration=$(jq -s 'map(select(.model.name | contains("mistral")) | .metrics.quantitative.latency_ms / 1000) | add / length' "${RESULTS_DIR}"/*"${latest_timestamp}".json)
mistral_avg_tokens_sec=$(jq -s 'map(select(.model.name | contains("mistral")) | .metrics.quantitative.tokens_per_second) | add / length' "${RESULTS_DIR}"/*"${latest_timestamp}".json)

echo "- **Average Response Time:** ${mistral_avg_duration} seconds" >> "${report_file}"
echo "- **Average Throughput:** ${mistral_avg_tokens_sec} tokens/second" >> "${report_file}"
echo "" >> "${report_file}"

# Add evaluation process section
cat >> "${report_file}" << 'EOF'
## Quality Evaluation Process

Model outputs will be evaluated by Claude AI for:

### For All Tests:
- **Correctness:** Does the output meet the specified requirements?
- **Completeness:** Are all requested components present?
- **Clarity:** Is the output clear and well-explained?

### For qwen2.5-coder:7b:
- Code quality and adherence to best practices
- Accuracy of algorithm implementations
- Quality of documentation and explanations
- Handling of edge cases

### For mistral-nemo:12b:
- Accuracy of data extraction and analysis
- Quality of cross-source correlations
- Insight generation and business value
- Handling of inconsistent data

## Next Steps

1. **Claude Evaluation:** AI will assess all outputs for quality and correctness
2. **Comparative Analysis:** Compare models within their respective domains
3. **Final Report:** Generate comprehensive findings and recommendations

## Files for Review

EOF

echo "### Output Files" >> "${report_file}"
for output_file in "${OUTPUTS_DIR}"/*"${latest_timestamp}".out; do
    if [[ -f "${output_file}" ]]; then
        filename=$(basename "${output_file}")
        echo "- \`${filename}\`" >> "${report_file}"
    fi
done

echo "" >> "${report_file}"
echo "### Result Files" >> "${report_file}"
for result_file in "${RESULTS_DIR}"/*"${latest_timestamp}".json; do
    if [[ -f "${result_file}" ]]; then
        filename=$(basename "${result_file}")
        echo "- \`${filename}\`" >> "${report_file}"
    fi
done

echo "" >> "${report_file}"
echo "---" >> "${report_file}"
echo "*Report generated on $(date)*" >> "${report_file}"

echo -e "${GREEN}[SUCCESS]${NC} Analysis report generated: ${report_file}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "- qwen2.5-coder:7b average response time: ${qwen_avg_duration}s"
echo "- mistral-nemo:12b average response time: ${mistral_avg_duration}s"
echo "- Total test cases: $(ls ${RESULTS_DIR}/*${latest_timestamp}.json | wc -l)"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Open ${report_file} to review the full analysis"
echo "2. Clean outputs with ./scripts/clean-outputs.sh if needed"
echo "3. Claude will evaluate response quality automatically"
echo "4. Consider running additional tests based on findings"
