#!/bin/bash

# Ollama Interactive Model Testing Framework
# Purpose: Dynamic model selection with category-based testing
# Author: Automated Testing Framework
# Version: 2.0

set -e

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="outputs"
RESULTS_DIR="results"
LOG_FILE="${RESULTS_DIR}/test_execution_${TIMESTAMP}.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "${OUTPUT_DIR}" "${RESULTS_DIR}"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "${LOG_FILE}"
}

# Function to get available models from Ollama
get_available_models() {
    local models=()
    while IFS= read -r line; do
        # Extract model name from ollama list output (first column)
        local model_name=$(echo "$line" | awk '{print $1}' | grep -v "^NAME$" | grep -v "^$")
        if [[ -n "$model_name" ]]; then
            models+=("$model_name")
        fi
    done < <(ollama list)
    
    # Remove empty elements and return
    printf '%s\n' "${models[@]}" | grep -v "^$"
}

# Function to display interactive model selection menu
select_model() {
    echo -e "${CYAN}=== Available Ollama Models ===${NC}" >&2
    echo "" >&2
    
    local models=($(get_available_models))
    
    if [[ ${#models[@]} -eq 0 ]]; then
        echo -e "${RED}[ERROR]${NC} No models found. Please pull some models first." >&2
        echo "Example: ollama pull qwen2.5-coder:7b" >&2
        exit 1
    fi
    
    echo "Select a model to test:" >&2
    echo "" >&2
    
    for i in "${!models[@]}"; do
        printf "%2d) %s\n" $((i+1)) "${models[$i]}" >&2
    done
    
    echo "" >&2
    echo -n "Enter model number (1-${#models[@]}): " >&2
    read model_choice
    
    # Validate input
    if [[ ! "$model_choice" =~ ^[0-9]+$ ]] || [[ "$model_choice" -lt 1 ]] || [[ "$model_choice" -gt ${#models[@]} ]]; then
        echo -e "${RED}[ERROR]${NC} Invalid selection. Please run the script again." >&2
        exit 1
    fi
    
    local selected_model="${models[$((model_choice-1))]}"
    echo -e "${GREEN}[SELECTED]${NC} Model: ${selected_model}" >&2
    echo "" >&2
    
    echo "$selected_model"
}

# Function to display test category selection
select_test_category() {
    echo -e "${CYAN}=== Test Categories ===${NC}" >&2
    echo "" >&2
    echo "Select which category of tests to run:" >&2
    echo "" >&2
    echo "1) Coding Tests (6 tests)" >&2
    echo "   - Algorithm implementation" >&2
    echo "   - Code optimization and debugging" >&2
    echo "   - Documentation and API integration" >&2
    echo "" >&2
    echo "2) Data Analysis Tests (6 tests)" >&2
    echo "   - CSV data processing" >&2
    echo "   - Multi-source data correlation" >&2
    echo "   - Business intelligence and reporting" >&2
    echo "" >&2
    echo "3) All Tests (12 tests)" >&2
    echo "   - Complete test suite" >&2
    echo "" >&2
    
    echo -n "Enter category number (1-3): " >&2
    read category_choice
    
    case "$category_choice" in
        1)
            echo -e "${GREEN}[SELECTED]${NC} Category: Coding Tests" >&2
            echo "coding"
            ;;
        2)
            echo -e "${GREEN}[SELECTED]${NC} Category: Data Analysis Tests" >&2
            echo "data"
            ;;
        3)
            echo -e "${GREEN}[SELECTED]${NC} Category: All Tests" >&2
            echo "all"
            ;;
        *)
            echo -e "${RED}[ERROR]${NC} Invalid selection. Please run the script again." >&2
            exit 1
            ;;
    esac
}

# Test execution function with timing
run_test() {
    local test_id="$1"
    local model="$2"
    local category="$3"
    local description="$4"
    local prompt="$5"
    local timeout="$6"
    local output_file="${OUTPUT_DIR}/${test_id}_${TIMESTAMP}.out"
    
    echo -e "${BLUE}[INFO]${NC} Starting test ${test_id}: ${description}"
    log "Starting test ${test_id} with model ${model} in category ${category}"
    
    local start_time=$(date +%s.%N)
    
    # Execute the ollama command
    if timeout "${timeout}s" ollama run "${model}" "${prompt}" > "${output_file}" 2>&1; then
        local end_time=$(date +%s.%N)
        local duration=$(echo "${end_time} - ${start_time}" | bc -l)
        echo -e "${GREEN}[PASS]${NC} Test ${test_id} completed in ${duration}s"
        log "Test ${test_id} completed successfully in ${duration}s"
        
        # Generate test result JSON
        generate_test_result "${test_id}" "${model}" "${category}" "${description}" "${prompt}" "${output_file}" "${duration}" "pass"
    else
        local end_time=$(date +%s.%N)
        local duration=$(echo "${end_time} - ${start_time}" | bc -l)
        echo -e "${RED}[FAIL]${NC} Test ${test_id} failed or timed out after ${duration}s"
        log "Test ${test_id} failed or timed out after ${duration}s"
        
        # Generate test result JSON for failure
        generate_test_result "${test_id}" "${model}" "${category}" "${description}" "${prompt}" "${output_file}" "${duration}" "fail"
    fi
}

# Generate test result JSON
generate_test_result() {
    local test_id="$1"
    local model="$2"
    local category="$3"
    local description="$4"
    local prompt="$5"
    local output_file="$6"
    local duration="$7"
    local result="$8"
    
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
  "test_run_id": "${TEST_RUN_ID:-test_run_${TIMESTAMP}}",
  "timestamp": "$(date -Iseconds)",
  "model": {
    "name": "${model}",
    "version": "${model}",
    "type": "user_selected"
  },
  "test_case": {
    "id": "${test_id}",
    "title": "${description}",
    "description": "${description}",
    "category": "${category}"
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
      "quality": {
        "score": "pending_manual_review"
      }
    }
  },
  "overall_result": "${result}",
  "notes": "Interactive test execution completed. Manual evaluation required for qualitative metrics."
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

# Execute coding tests
run_coding_tests() {
    local model="$1"
    
    echo -e "${PURPLE}=== Executing Coding Tests ===${NC}"
    echo ""
    
    # CT-01: Binary Search Implementation
    run_test "ct01" "${model}" "coding" "Binary Search Implementation" \
"Implement a binary search function in Python that: 1. Takes a sorted list and target value as parameters 2. Returns the index of the target if found, -1 if not found 3. Uses the standard binary search algorithm (O(log n) complexity) 4. Includes proper error handling for edge cases 5. Add docstring with complexity analysis and examples. Please provide a complete, well-documented implementation." \
90

    # CT-02: Performance Optimization
    local slow_search_code=$(read_sample_file "test-data/sample-code/code-samples.py" | sed -n '/def slow_search/,/return found_indices/p')
    run_test "ct02" "${model}" "coding" "Performance Optimization" \
"The following function has performance issues. Analyze the code and provide an optimized version:

${slow_search_code}

Please: 1. Identify the performance problems 2. Provide an optimized implementation 3. Explain the improvements and their impact 4. Include time complexity analysis (before vs after) 5. Add any additional optimizations you would recommend" \
90

    # CT-03: Bug Fixing
    local buggy_code=$(read_sample_file "test-data/sample-code/buggy-stack.py")
    run_test "ct03" "${model}" "coding" "Bug Fixing" \
"The following Python code has several bugs. Find and fix all issues:

${buggy_code}

Please: 1. Identify all bugs in the code 2. Provide the corrected implementation 3. Explain what each bug was and why it was problematic 4. Test the fix with example usage 5. Suggest any additional improvements" \
90

    # CT-04: Code Review Analysis
    local undocumented_code=$(read_sample_file "test-data/sample-code/code-samples.py" | sed -n '/def mystery_function/,/return result/p')
    run_test "ct04" "${model}" "coding" "Code Review Analysis" \
"Please review this function and provide suggestions for improvement:

${undocumented_code}

Provide: 1. Analysis of what the function does 2. Suggestions for better naming 3. Documentation improvements 4. Potential edge cases or bugs 5. Overall code quality assessment" \
90

    # CT-05: Documentation Generation
    local fibonacci_code=$(read_sample_file "test-data/sample-code/code-samples.py" | sed -n '/def fibonacci/,/return fib/p')
    run_test "ct05" "${model}" "coding" "Documentation Generation" \
"Generate complete API documentation for this Fibonacci function:

${fibonacci_code}

Include: 1. Detailed docstring with parameters, return value, and examples 2. Type hints 3. Usage examples 4. Time/space complexity analysis 5. Any potential improvements or alternative approaches" \
90

    # CT-06: API Integration
    run_test "ct06" "${model}" "coding" "API Integration" \
"Write a Python class that interacts with a REST API for user management. The class should: 1. Have methods for GET, POST, PUT, DELETE operations 2. Handle authentication with API keys 3. Include proper error handling and retries 4. Support JSON request/response data 5. Add logging for debugging 6. Include type hints and documentation. Base URL: https://api.example.com/v1/users. API Key should be passed in headers as 'X-API-Key'. Create a complete, production-ready implementation." \
120
}

# Execute data analysis tests
run_data_tests() {
    local model="$1"
    
    echo -e "${PURPLE}=== Executing Data Analysis Tests ===${NC}"
    echo ""
    
    # DT-01: CSV Data Analysis
    local orders_data=$(read_sample_file "test-data/sample-csv/orders.csv")
    run_test "dt01" "${model}" "data" "CSV Data Analysis" \
"Analyze the following orders CSV data and provide insights:

${orders_data}

Please provide: 1. Summary statistics (total orders, revenue, average order value) 2. Top 3 customers by order value 3. Product performance analysis 4. Geographic distribution of orders 5. Order status breakdown 6. Any notable patterns or trends you observe. Format your response as a structured business report." \
120

    # DT-02: Email Thread Correlation
    local email_data=$(read_sample_file "test-data/sample-emails/order-correspondence.txt")
    run_test "dt02" "${model}" "data" "Email Thread Correlation" \
"Analyze this email thread and extract key information:

${email_data}

Extract and organize: 1. Order details (ID, customer, products, quantities, prices) 2. Timeline of communications 3. Customer concerns or requests 4. Resolution status 5. Follow-up actions needed 6. Customer satisfaction indicators. Present the analysis in a customer service summary format." \
120

    # DT-03: Multi-source Data Fusion
    local customers_data=$(read_sample_file "test-data/sample-csv/customers.csv")
    local business_updates=$(read_sample_file "test-data/sample-emails/business-updates.txt")
    local product_specs=$(read_sample_file "test-data/sample-pdf-text/product-specifications.txt")
    run_test "dt03" "${model}" "data" "Multi-source Data Fusion" \
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

    # DT-04: Data Validation
    run_test "dt04" "${model}" "data" "Data Validation" \
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

    # DT-05: Executive Report Generation
    run_test "dt05" "${model}" "data" "Executive Report Generation" \
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

    # DT-06: Pattern Recognition
    run_test "dt06" "${model}" "data" "Pattern Recognition & Trend Analysis" \
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
}

# Main execution flow
main() {
    echo -e "${GREEN}=== Ollama Interactive Testing Framework v2.0 ===${NC}"
    echo -e "${BLUE}Enhanced with Dynamic Model Selection${NC}"
    echo ""

    log "Starting interactive test execution"

    # Check if Ollama is running
    if ! ollama list > /dev/null 2>&1; then
        echo -e "${RED}[ERROR]${NC} Ollama is not running or not accessible"
        log "ERROR: Ollama is not running or not accessible"
        exit 1
    fi

    # Interactive model selection
    local selected_model=$(select_model)
    local selected_category=$(select_test_category)
    
    # Set test run ID with model and category info
    TEST_RUN_ID="interactive_${selected_model//[^a-zA-Z0-9]/_}_${selected_category}_${TIMESTAMP}"
    
    echo ""
    echo -e "${YELLOW}=== Test Configuration ===${NC}"
    echo "Model: ${selected_model}"
    echo "Category: ${selected_category}"
    echo "Test Run ID: ${TEST_RUN_ID}"
    echo "Timestamp: $(date)"
    echo ""
    
    log "Configuration: Model=${selected_model}, Category=${selected_category}"
    
    # Execute tests based on category selection
    case "$selected_category" in
        "coding")
            run_coding_tests "${selected_model}"
            ;;
        "data")
            run_data_tests "${selected_model}"
            ;;
        "all")
            run_coding_tests "${selected_model}"
            echo ""
            run_data_tests "${selected_model}"
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}=== Test Execution Complete ===${NC}"
    echo -e "${BLUE}Results Location: ${RESULTS_DIR}/${NC}"
    echo -e "${BLUE}Output Files: ${OUTPUT_DIR}/${NC}"
    echo -e "${BLUE}Log File: ${LOG_FILE}${NC}"

    log "Test execution completed successfully"

    # Generate summary report
    local summary_file="${RESULTS_DIR}/test_summary_${TIMESTAMP}.txt"
    echo "Ollama Interactive Testing Framework - Test Summary" > "${summary_file}"
    echo "Test Run ID: ${TEST_RUN_ID}" >> "${summary_file}"
    echo "Model: ${selected_model}" >> "${summary_file}"
    echo "Category: ${selected_category}" >> "${summary_file}"
    echo "Execution Date: $(date)" >> "${summary_file}"
    echo "" >> "${summary_file}"
    echo "Files Generated:" >> "${summary_file}"
    echo "- Output files: ${OUTPUT_DIR}/*_${TIMESTAMP}.out" >> "${summary_file}"
    echo "- Result files: ${RESULTS_DIR}/*_${TIMESTAMP}.json" >> "${summary_file}"
    echo "- Log file: ${LOG_FILE}" >> "${summary_file}"
    echo "" >> "${summary_file}"
    echo "Next Steps:" >> "${summary_file}"
    echo "1. Review output files for model responses" >> "${summary_file}"
    echo "2. Run analysis script: ./scripts/analyze-results.sh" >> "${summary_file}"
    echo "3. Evaluate qualitative metrics manually" >> "${summary_file}"
    echo "4. Generate comparative analysis report" >> "${summary_file}"

    echo -e "${GREEN}[INFO]${NC} Summary report generated: ${summary_file}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Review output files in ${OUTPUT_DIR}/ for model responses"
    echo -e "2. Run analysis: ${CYAN}./scripts/analyze-results.sh${NC}"
    echo "3. Evaluate qualitative metrics manually"
    echo "4. Generate comparative analysis report"
}

# Run main function
main "$@"
