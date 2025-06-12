#!/bin/bash

# Ollama Model Testing Framework - Master Test Runner
# Generated: June 11, 2025
# Purpose: Execute comprehensive tests for qwen2.5-coder:7b and mistral-nemo:12b

set -e  # Exit on any error

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEST_RUN_ID="test_run_${TIMESTAMP}"
OUTPUT_DIR="outputs"
RESULTS_DIR="results"
LOG_FILE="${RESULTS_DIR}/test_execution_${TIMESTAMP}.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "${OUTPUT_DIR}" "${RESULTS_DIR}"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "${LOG_FILE}"
}

# Test execution function with timing
run_test() {
    local test_id="$1"
    local model="$2"
    local description="$3"
    local prompt="$4"
    local timeout="$5"
    local output_file="${OUTPUT_DIR}/${test_id}_${TIMESTAMP}.out"
    
    echo -e "${BLUE}[INFO]${NC} Starting test ${test_id}: ${description}"
    log "Starting test ${test_id} with model ${model}"
    
    local start_time=$(date +%s.%N)
    
    # Execute the ollama command
    if timeout "${timeout}s" ollama run "${model}" "${prompt}" > "${output_file}" 2>&1; then
        local end_time=$(date +%s.%N)
        local duration=$(echo "${end_time} - ${start_time}" | bc -l)
        echo -e "${GREEN}[PASS]${NC} Test ${test_id} completed in ${duration}s"
        log "Test ${test_id} completed successfully in ${duration}s"
        
        # Generate test result JSON
        generate_test_result "${test_id}" "${model}" "${description}" "${prompt}" "${output_file}" "${duration}" "pass"
    else
        local end_time=$(date +%s.%N)
        local duration=$(echo "${end_time} - ${start_time}" | bc -l)
        echo -e "${RED}[FAIL]${NC} Test ${test_id} failed or timed out after ${duration}s"
        log "Test ${test_id} failed or timed out after ${duration}s"
        
        # Generate test result JSON for failure
        generate_test_result "${test_id}" "${model}" "${description}" "${prompt}" "${output_file}" "${duration}" "fail"
    fi
}

# Generate test result JSON
generate_test_result() {
    local test_id="$1"
    local model="$2" 
    local description="$3"
    local prompt="$4"
    local output_file="$5"
    local duration="$6"
    local result="$7"
    
    local result_file="${RESULTS_DIR}/${test_id}_${TIMESTAMP}.json"
    local output_content=""
    local output_token_count=0
    
    if [[ -f "${output_file}" ]]; then
        output_content=$(cat "${output_file}" | jq -Rs .)
        output_token_count=$(wc -w < "${output_file}" | xargs)
    fi
    
    local input_token_count=$(echo "${prompt}" | wc -w | xargs)
    local total_tokens=$((input_token_count + output_token_count))
    local tokens_per_second=0
    
    if (( $(echo "${duration} > 0" | bc -l) )); then
        tokens_per_second=$(echo "scale=2; ${output_token_count} / ${duration}" | bc -l)
    fi

cat > "${result_file}" << EOF
{
  "test_run_id": "${TEST_RUN_ID}",
  "timestamp": "$(date -Iseconds)",
  "model": {
    "name": "${model}",
    "version": "${model}",
    "type": "$(if [[ ${model} == *"coder"* ]]; then echo "coding"; else echo "data-processing"; fi)"
  },
  "test_case": {
    "id": "${test_id}",
    "title": "${description}",
    "description": "${description}",
    "category": "automated"
  },
  "input": {
    "prompt": $(echo "${prompt}" | jq -Rs .),
    "token_count": ${input_token_count}
  },
  "output": {
    "content": ${output_content:-'""'},
    "token_count": ${output_token_count}
  },
  "metrics": {
    "quantitative": {
      "latency_ms": $(echo "${duration} * 1000" | bc -l),
      "tokens_per_second": ${tokens_per_second},
      "total_tokens": ${total_tokens}
    },
    "qualitative": {
      "correctness": {
        "score": "pending_manual_review"
      },
      "completeness": {
        "score": "pending_manual_review"
      },
      "clarity": {
        "score": "pending_manual_review"
      }
    }
  },
  "overall_result": "${result}",
  "notes": "Automated execution completed. Manual evaluation required for qualitative metrics."
}
EOF
}

# Read sample data function
read_sample_file() {
    local file_path="$1"
    if [[ -f "${file_path}" ]]; then
        cat "${file_path}"
    else
        echo "[FILE NOT FOUND: ${file_path}]"
    fi
}

echo -e "${GREEN}=== Ollama Model Testing Framework ===${NC}"
echo -e "${BLUE}Test Run ID: ${TEST_RUN_ID}${NC}"
echo -e "${BLUE}Timestamp: $(date)${NC}"
echo ""

log "Starting test execution for models: qwen2.5-coder:7b, mistral-nemo:12b"

# Check if Ollama is running
if ! ollama list > /dev/null 2>&1; then
    echo -e "${RED}[ERROR]${NC} Ollama is not running or not accessible"
    log "ERROR: Ollama is not running or not accessible"
    exit 1
fi

# Check if models are available
echo -e "${YELLOW}[INFO]${NC} Checking model availability..."
if ! ollama list | grep -q "qwen2.5-coder:7b"; then
    echo -e "${YELLOW}[WARN]${NC} qwen2.5-coder:7b not found. Attempting to pull..."
    ollama pull qwen2.5-coder:7b || {
        echo -e "${RED}[ERROR]${NC} Failed to pull qwen2.5-coder:7b"
        exit 1
    }
fi

if ! ollama list | grep -q "mistral-nemo:12b"; then
    echo -e "${YELLOW}[WARN]${NC} mistral-nemo:12b not found. Attempting to pull..."
    ollama pull mistral-nemo:12b || {
        echo -e "${RED}[ERROR]${NC} Failed to pull mistral-nemo:12b"
        exit 1
    }
fi

echo -e "${GREEN}[INFO]${NC} Both models are available"
echo ""

# ============================================================================
# QWEN2.5-CODER:7B TESTS
# ============================================================================

echo -e "${BLUE}=== Testing qwen2.5-coder:7b (Coding Assistant) ===${NC}"

# QC-01: Binary Search Implementation
run_test "qc01" "qwen2.5-coder:7b" "Binary Search Implementation" \
"Implement a binary search function in Python that: 1. Takes a sorted list and target value as parameters 2. Returns the index of the target if found, -1 if not found 3. Uses the standard binary search algorithm (O(log n) complexity) 4. Includes proper error handling for edge cases 5. Add docstring with complexity analysis and examples. Please provide a complete, well-documented implementation." \
90

# QC-02: Performance Optimization
slow_search_code=$(read_sample_file "test-data/sample-code/code-samples.py" | sed -n '/def slow_search/,/return found_indices/p')
run_test "qc02" "qwen2.5-coder:7b" "Performance Optimization" \
"The following function has performance issues. Analyze the code and provide an optimized version:

${slow_search_code}

Requirements: 1. Fix the performance issues 2. Explain what was wrong with the original code 3. Provide time complexity analysis for both versions 4. Ensure the function still returns all indices where target appears" \
90

# QC-03: Bug Fixing
buggy_stack_code=$(read_sample_file "test-data/sample-code/code-samples.py" | sed -n '/class BuggyStack/,/return len(self.items) > 0/p')
run_test "qc03" "qwen2.5-coder:7b" "Bug Fixing - Stack Implementation" \
"This Stack class has several bugs. Find and fix all the issues:

${buggy_stack_code}

Requirements: 1. Fix all bugs while maintaining proper stack behavior (LIFO) 2. Add appropriate error handling 3. Explain each bug you found 4. Add a simple test to demonstrate correct functionality" \
90

# QC-04: Code Review
undocumented_code=$(read_sample_file "test-data/sample-code/code-samples.py" | sed -n '/def undocumented_function/,/return result/p')
run_test "qc04" "qwen2.5-coder:7b" "Code Review Analysis" \
"Please review this function and provide suggestions for improvement:

${undocumented_code}

Provide: 1. Analysis of what the function does 2. Suggestions for better naming 3. Documentation improvements 4. Potential edge cases or bugs 5. Overall code quality assessment" \
90

# QC-05: Documentation Generation
fibonacci_code=$(read_sample_file "test-data/sample-code/code-samples.py" | sed -n '/def fibonacci/,/return fib/p')
run_test "qc05" "qwen2.5-coder:7b" "Documentation Generation" \
"Generate complete API documentation for this Fibonacci function:

${fibonacci_code}

Include: 1. Detailed docstring with parameters, return value, and examples 2. Type hints 3. Usage examples 4. Time/space complexity analysis 5. Any potential improvements or alternative approaches" \
90

# QC-06: API Integration
run_test "qc06" "qwen2.5-coder:7b" "API Integration" \
"Write a Python class that interacts with a REST API for user management. The class should: 1. Have methods for GET, POST, PUT, DELETE operations 2. Handle authentication with API keys 3. Include proper error handling and retries 4. Support JSON request/response data 5. Add logging for debugging 6. Include type hints and documentation. Base URL: https://api.example.com/v1/users. API Key should be passed in headers as 'X-API-Key'. Create a complete, production-ready implementation." \
120

echo ""

# ============================================================================
# MISTRAL-NEMO:12B TESTS  
# ============================================================================

echo -e "${BLUE}=== Testing mistral-nemo:12b (Data Processing) ===${NC}"

# MN-01: CSV Data Analysis
orders_data=$(read_sample_file "test-data/sample-csv/orders.csv")
run_test "mn01" "mistral-nemo:12b" "CSV Data Analysis" \
"Analyze the following orders CSV data and provide insights:

${orders_data}

Please provide: 1. Summary statistics (total orders, revenue, average order value) 2. Top 3 customers by order value 3. Product performance analysis 4. Geographic distribution of orders 5. Order status breakdown 6. Any notable patterns or trends you observe. Format your response as a structured business report." \
120

# MN-02: Email Thread Correlation
email_data=$(read_sample_file "test-data/sample-emails/order-correspondence.txt")
run_test "mn02" "mistral-nemo:12b" "Email Thread Correlation" \
"Analyze this email thread and extract key information:

${email_data}

Extract and organize: 1. Order details (ID, customer, products, quantities, prices) 2. Timeline of communications 3. Customer concerns or requests 4. Resolution status 5. Follow-up actions needed 6. Customer satisfaction indicators. Present the analysis in a customer service summary format." \
120

# MN-03: Multi-source Data Fusion
customers_data=$(read_sample_file "test-data/sample-csv/customers.csv")
business_updates=$(read_sample_file "test-data/sample-emails/business-updates.txt")
product_specs=$(read_sample_file "test-data/sample-pdf-text/product-specifications.txt")
run_test "mn03" "mistral-nemo:12b" "Multi-source Data Fusion" \
"Combine and analyze data from these three sources to create a comprehensive business intelligence report:

CSV DATA - ORDERS:
${orders_data}

CSV DATA - CUSTOMERS:
${customers_data}

EMAIL DATA:
${business_updates}

PRODUCT SPECIFICATIONS:
${product_specs}

Create a unified analysis that: 1. Correlates customer data with order patterns 2. Validates information consistency across sources 3. Identifies business performance trends 4. Highlights any discrepancies or issues 5. Provides strategic recommendations 6. Creates an executive summary dashboard. Present as a comprehensive business intelligence report." \
180

# MN-04: Data Validation
run_test "mn04" "mistral-nemo:12b" "Data Validation" \
"Perform a data quality audit across these datasets and identify any inconsistencies, errors, or missing information:

ORDERS DATA:
${orders_data}

CUSTOMER DATA:
${customers_data}

EMAIL REFERENCES:
${email_data}
${business_updates}

Check for: 1. Data consistency between orders and customer records 2. Email references that match or contradict CSV data 3. Missing or incomplete information 4. Potential data entry errors 5. Conflicting information across sources 6. Data quality scores and recommendations. Provide a detailed data quality report with specific examples." \
150

# MN-05: Report Generation
run_test "mn05" "mistral-nemo:12b" "Executive Report Generation" \
"Create an executive summary report for TechStore's Q1 2024 performance using all available data:

SALES DATA:
${orders_data}

CUSTOMER PROFILES:
${customers_data}

BUSINESS UPDATES:
${business_updates}

PRODUCT INFORMATION:
${product_specs}

Generate a professional executive summary that includes: 1. Key performance indicators (KPIs) 2. Revenue and growth analysis 3. Customer insights and segmentation 4. Product performance highlights 5. Market trends and opportunities 6. Risk factors and challenges 7. Strategic recommendations for Q2. Format as a professional business document suitable for senior leadership." \
180

# MN-06: Pattern Recognition
run_test "mn06" "mistral-nemo:12b" "Pattern Recognition & Trend Analysis" \
"Analyze all available data to identify patterns, trends, and anomalies:

TRANSACTION DATA:
${orders_data}

CUSTOMER BEHAVIOR:
${customers_data}

COMMUNICATION PATTERNS:
${email_data}
${business_updates}

PRODUCT PERFORMANCE:
${product_specs}

Identify: 1. Customer behavior patterns and segments 2. Product sales trends and correlations 3. Seasonal or temporal patterns 4. Geographic trends 5. Communication pattern analysis 6. Anomalies or outliers that require attention 7. Predictive insights for future planning. Present findings with supporting evidence and confidence levels." \
180

echo ""
echo -e "${GREEN}=== Test Execution Complete ===${NC}"
echo -e "${BLUE}Results Location: ${RESULTS_DIR}/${NC}"
echo -e "${BLUE}Output Files: ${OUTPUT_DIR}/${NC}"
echo -e "${BLUE}Log File: ${LOG_FILE}${NC}"

log "Test execution completed successfully"

# Generate summary report
summary_file="${RESULTS_DIR}/test_summary_${TIMESTAMP}.txt"
echo "Ollama Model Testing Framework - Test Summary" > "${summary_file}"
echo "Test Run ID: ${TEST_RUN_ID}" >> "${summary_file}"
echo "Execution Date: $(date)" >> "${summary_file}"
echo "" >> "${summary_file}"
echo "Files Generated:" >> "${summary_file}"
echo "- Output files: ${OUTPUT_DIR}/*_${TIMESTAMP}.out" >> "${summary_file}"
echo "- Result files: ${RESULTS_DIR}/*_${TIMESTAMP}.json" >> "${summary_file}"
echo "- Log file: ${LOG_FILE}" >> "${summary_file}"
echo "" >> "${summary_file}"
echo "Next Steps:" >> "${summary_file}"
echo "1. Review output files for model responses" >> "${summary_file}"
echo "2. Evaluate qualitative metrics manually" >> "${summary_file}"
echo "3. Update result JSON files with manual assessments" >> "${summary_file}"
echo "4. Generate comparative analysis report" >> "${summary_file}"

echo -e "${GREEN}[INFO]${NC} Summary report generated: ${summary_file}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Review output files in ${OUTPUT_DIR}/ for model responses"
echo "2. Evaluate qualitative metrics manually"  
echo "3. Update result JSON files with manual assessments"
echo "4. Generate comparative analysis report"
