#!/bin/bash

# Generic Test Runner - Configuration-Driven Architecture
# Uses Python for YAML processing, shell for execution orchestration
# Zero external dependencies beyond Python standard library

set -e

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="outputs"
RESULTS_DIR="results"
REPORTS_DIR="reports"
LOG_FILE="${RESULTS_DIR}/test_execution_${TIMESTAMP}.log"
CONFIG_LOADER="scripts/config_loader.py"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Create directories
mkdir -p "${OUTPUT_DIR}" "${RESULTS_DIR}" "${REPORTS_DIR}"

# Parse command line arguments
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            HELP=true
            shift
            ;;
    esac
done

# Show help if requested
if [[ "$HELP" == true ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "=== Generic Configuration-Driven Test Runner v3.0 ==="
    echo "Zero External Dependencies - Python + Shell Only"
    echo ""
    echo "Description:"
    echo "  Interactive test runner that dynamically detects available Ollama models"
    echo "  and executes configuration-driven tests based on YAML test definitions."
    echo ""
    echo "Options:"
    echo "  --help, -h                 Show this help message"
    echo ""
    echo "Features:"
    echo "  • Dynamic model selection from locally available Ollama models"
    echo "  • Category-based testing (coding, data analysis, or all tests)"
    echo "  • Configuration-driven test execution via YAML files"
    echo "  • Automated timing and performance metrics"
    echo "  • JSON-structured result files"
    echo "  • Comprehensive logging and reporting"
    echo ""
    echo "Test Categories:"
    echo "  • Coding Tests: Algorithm implementation, optimization, debugging"
    echo "  • Data Analysis Tests: CSV processing, business intelligence, reporting"
    echo "  • All Tests: Complete test suite"
    echo ""
    echo "Examples:"
    echo "  $0                         Launch interactive test runner"
    echo "  $0 --help                  Show this help message"
    echo ""
    echo "Output Files:"
    echo "  • outputs/*.out            Raw model responses"
    echo "  • results/*.json           Structured test results with metrics"
    echo "  • results/test_summary_*.txt Summary report"
    echo "  • results/test_execution_*.log Execution log"
    echo ""
    echo "Next Steps After Testing:"
    echo "  • Run analysis: ./scripts/analyze-results.sh"
    echo "  • Enhanced analysis: ./scripts/analyze-results.sh --with-qualitative-eval"
    echo "  • Clean outputs: ./scripts/clean-outputs.sh"
    echo ""
    echo "Requirements:"
    echo "  • Ollama installed and running"
    echo "  • At least one model pulled (e.g., ollama pull qwen2.5-coder:7b)"
    echo "  • Python 3.x for YAML configuration processing"
    echo "  • jq and bc utilities"
    exit 0
fi

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "${LOG_FILE}"
}

# Function to get available models from Ollama
get_available_models() {
    local models=()
    
    echo -e "${BLUE}Detecting available Ollama models...${NC}" >&2
    
    # Get models and store in array
    while IFS= read -r line; do
        if [[ "$line" =~ ^[a-zA-Z0-9] ]]; then
            local model_name=$(echo "$line" | awk '{print $1}')
            models+=("$model_name")
        fi
    done < <(ollama list 2>/dev/null | tail -n +2)
    
    if [ ${#models[@]} -eq 0 ]; then
        echo -e "${RED}[ERROR]${NC} No Ollama models found. Please install models first." >&2
        echo "Example: ollama pull llama3.1" >&2
        exit 1
    fi
    
    echo "${models[@]}"
}

# Function to display model selection
select_model() {
    local models=($(get_available_models))
    
    if [ ${#models[@]} -eq 1 ]; then
        echo -e "${GREEN}[AUTO-SELECTED]${NC} Only one model available: ${models[0]}" >&2
        echo "${models[0]}"
        return
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

# Function to get available test categories
get_available_categories() {
    python3 "${CONFIG_LOADER}" list-categories | grep "^  - " | sed 's/^  - //'
}

# Function to display test category selection
select_test_category() {
    local categories=($(get_available_categories))
    
    if [ ${#categories[@]} -eq 0 ]; then
        echo -e "${RED}[ERROR]${NC} No test categories found in test-configs/categories/" >&2
        exit 1
    fi
    
    echo -e "${CYAN}=== Test Categories ===${NC}" >&2
    echo "" >&2
    echo "Select which category of tests to run:" >&2
    echo "" >&2
    
    for i in "${!categories[@]}"; do
        local category="${categories[$i]}"
        local category_config=$(python3 "${CONFIG_LOADER}" load-category "${category}" 2>/dev/null)
        
        if [[ $? -eq 0 && -n "$category_config" ]]; then
            local category_name=$(echo "$category_config" | python3 -c "import json, sys; data=json.load(sys.stdin); print(data['category']['name'])" 2>/dev/null || echo "$category")
            local test_count=$(echo "$category_config" | python3 -c "import json, sys; data=json.load(sys.stdin); print(len(data['tests']))" 2>/dev/null || echo "?")
        else
            local category_name="$category"
            local test_count="?"
        fi
        
        printf "%2d) %s (%s tests)\n" $((i+1)) "$category_name" "$test_count" >&2
    done
    
    echo "" >&2
    printf "%2d) All Tests\n" $((${#categories[@]}+1)) >&2
    echo "   - Complete test suite" >&2
    echo "" >&2
    
    echo -n "Enter category number (1-$((${#categories[@]}+1))): " >&2
    read category_choice
    
    # Validate input
    if [[ ! "$category_choice" =~ ^[0-9]+$ ]] || [[ "$category_choice" -lt 1 ]] || [[ "$category_choice" -gt $((${#categories[@]}+1)) ]]; then
        echo -e "${RED}[ERROR]${NC} Invalid selection. Please run the script again." >&2
        exit 1
    fi
    
    if [[ "$category_choice" -eq $((${#categories[@]}+1)) ]]; then
        echo -e "${GREEN}[SELECTED]${NC} Category: All Tests" >&2
        echo "all"
    else
        local selected_category="${categories[$((category_choice-1))]}"
        echo -e "${GREEN}[SELECTED]${NC} Category: ${selected_category}" >&2
        echo "$selected_category"
    fi
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
  "test_run_id": "${TEST_RUN_ID:-generic_test_run_${TIMESTAMP}}",
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
    "content": ${output_content},
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
  "notes": "Generic test execution completed. Manual evaluation required for qualitative metrics."
}
EOF
}

# Execute tests for a category
run_category_tests() {
    local model="$1"
    local category="$2"
    
    echo -e "${PURPLE}=== Executing ${category} Tests ===${NC}"
    echo ""
    
    # Load category configuration
    local category_config=$(python3 "${CONFIG_LOADER}" load-category "${category}" 2>/dev/null)
    
    if [[ $? -ne 0 || -z "$category_config" ]]; then
        echo -e "${RED}[ERROR]${NC} Failed to load category configuration for: ${category}"
        return 1
    fi
    
    # Extract test IDs from configuration
    local test_ids=($(echo "$category_config" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for test in data['tests']:
        print(test['id'])
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"))
    
    if [[ ${#test_ids[@]} -eq 0 ]]; then
        echo -e "${RED}[ERROR]${NC} No tests found in category: ${category}"
        return 1
    fi
    
    # Execute each test
    for test_id in "${test_ids[@]}"; do
        # Get test details
        local test_info=$(echo "$category_config" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for test in data['tests']:
        if test['id'] == '$test_id':
            print(f\"{test['title']}|{test['timeout']}\")
            break
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
")
        
        if [[ -z "$test_info" ]]; then
            echo -e "${RED}[ERROR]${NC} Failed to get test info for: ${test_id}"
            continue
        fi
        
        local test_title=$(echo "$test_info" | cut -d'|' -f1)
        local test_timeout=$(echo "$test_info" | cut -d'|' -f2)
        
        # Build prompt for this test
        local prompt=$(python3 "${CONFIG_LOADER}" build-prompt "${category}" "${test_id}" 2>/dev/null)
        
        if [[ $? -ne 0 || -z "$prompt" ]]; then
            echo -e "${RED}[ERROR]${NC} Failed to build prompt for test: ${test_id}"
            continue
        fi
        
        # Execute the test
        run_test "${test_id}" "${model}" "${category}" "${test_title}" "${prompt}" "${test_timeout}"
    done
}

# Main execution flow
main() {
    echo -e "${GREEN}=== Generic Configuration-Driven Test Runner v3.0 ===${NC}"
    echo -e "${BLUE}Zero External Dependencies - Python + Shell Only${NC}"
    echo ""

    log "Starting configuration-driven test execution"

    # Check if Ollama is running
    if ! ollama list > /dev/null 2>&1; then
        echo -e "${RED}[ERROR]${NC} Ollama is not running or not accessible"
        log "ERROR: Ollama is not running or not accessible"
        exit 1
    fi

    # Check if configuration loader exists
    if [[ ! -f "${CONFIG_LOADER}" ]]; then
        echo -e "${RED}[ERROR]${NC} Configuration loader not found: ${CONFIG_LOADER}"
        log "ERROR: Configuration loader not found: ${CONFIG_LOADER}"
        exit 1
    fi

    # Interactive model selection
    local selected_model=$(select_model)
    local selected_category=$(select_test_category)
    
    # Set test run ID with model and category info
    TEST_RUN_ID="config_driven_${selected_model//[^a-zA-Z0-9]/_}_${selected_category}_${TIMESTAMP}"
    
    echo ""
    echo -e "${YELLOW}=== Test Configuration ===${NC}"
    echo "Model: ${selected_model}"
    echo "Category: ${selected_category}"
    echo "Test Run ID: ${TEST_RUN_ID}"
    echo "Timestamp: $(date)"
    echo ""
    
    log "Configuration: Model=${selected_model}, Category=${selected_category}"
    
    # Execute tests based on category selection
    if [[ "$selected_category" == "all" ]]; then
        local available_categories=($(get_available_categories))
        for category in "${available_categories[@]}"; do
            run_category_tests "${selected_model}" "${category}"
            echo ""
        done
    else
        run_category_tests "${selected_model}" "${selected_category}"
    fi
    
    echo ""
    echo -e "${GREEN}=== Test Execution Complete ===${NC}"
    echo -e "${BLUE}Results Location: ${RESULTS_DIR}/${NC}"
    echo -e "${BLUE}Output Files: ${OUTPUT_DIR}/${NC}"
    echo -e "${BLUE}Log File: ${LOG_FILE}${NC}"

    log "Test execution completed successfully"

    # Generate summary report
    local summary_file="${RESULTS_DIR}/test_summary_${TIMESTAMP}.txt"
    echo "Configuration-Driven Testing Framework - Test Summary" > "${summary_file}"
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
    echo "2. Analysis report automatically generated below" >> "${summary_file}"
    echo "3. Evaluate qualitative metrics manually" >> "${summary_file}"
    echo "4. Generate comparative analysis report" >> "${summary_file}"

    echo -e "${GREEN}[INFO]${NC} Summary report generated: ${summary_file}"
    echo ""
    
    # Clean output files for better readability
    echo -e "${BLUE}[INFO]${NC} Cleaning output files..."
    log "Cleaning output files with timestamp ${TIMESTAMP}"
    
    if ./scripts/clean-outputs.sh "${TIMESTAMP}" 2>/dev/null; then
        echo -e "${GREEN}[SUCCESS]${NC} Output files cleaned and available in outputs_clean/"
        log "Output cleaning completed successfully"
    else
        echo -e "${YELLOW}[WARNING]${NC} Output cleaning failed, raw files still available"
        log "Output cleaning failed, continuing with raw files"
    fi
    echo ""
    
    # Auto-generate analysis report
    echo -e "${BLUE}[INFO]${NC} Generating analysis report..."
    log "Running automated analysis"
    
    # Run the analysis script and capture the report file path
    if ./scripts/analyze-results.sh 2>/dev/null; then
        # Find the most recent analysis report
        local latest_analysis=$(ls -t "${REPORTS_DIR}"/analysis_*.md 2>/dev/null | head -n 1)
        if [[ -f "$latest_analysis" ]]; then
            local absolute_path=$(cd "$(dirname "$latest_analysis")" && pwd)/$(basename "$latest_analysis")
            echo -e "${GREEN}[SUCCESS]${NC} Analysis report generated"
            echo ""
            echo -e "${YELLOW}📊 Analysis Report Ready:${NC}"
            echo -e "${CYAN}file://${absolute_path}${NC}"
            echo ""
            echo -e "${BLUE}Additional Options:${NC}"
            echo -e "• Re-run analysis: ${CYAN}./scripts/analyze-results.sh${NC}"
            echo -e "• Qualitative evaluation: ${CYAN}./scripts/analyze-results.sh --with-qualitative-eval${NC}"
        else
            echo -e "${YELLOW}[WARNING]${NC} Analysis completed but report file not found"
            echo -e "Manual analysis: ${CYAN}./scripts/analyze-results.sh${NC}"
        fi
    else
        echo -e "${YELLOW}[WARNING]${NC} Analysis script encountered issues"
        echo -e "Manual analysis: ${CYAN}./scripts/analyze-results.sh${NC}"
    fi
}

# Run main function
main
