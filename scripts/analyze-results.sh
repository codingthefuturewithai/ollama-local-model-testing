#!/bin/bash

# Ollama Model Testing Framework - Results Analyzer
# Purpose: Analyze test results and generate comparison reports
# Version: 2.1 - Added qualitative evaluation capabilities

set -e

# Parse command line arguments
QUALITATIVE_EVAL=true  # Default to true now
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --with-qualitative-eval)
            QUALITATIVE_EVAL=true
            shift
            ;;
        --skip-qualitative-eval)
            QUALITATIVE_EVAL=false
            shift
            ;;
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
    echo "Options:"
    echo "  --skip-qualitative-eval    Skip automated qualitative evaluation (faster, no API required)"
    echo "  --with-qualitative-eval    Force enable qualitative evaluation (default behavior)"
    echo "  --help, -h                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                         Full analysis with automated qualitative scores (default)"
    echo "  $0 --skip-qualitative-eval Quantitative analysis only (no API key needed)"
    echo ""
    echo "Note: Qualitative evaluation requires Python dependencies and Google API key."
    echo "      If API key is missing, the script will automatically fallback to basic analysis."
    exit 0
fi

# Configuration
RESULTS_DIR="results"
OUTPUTS_DIR="outputs" 
REPORTS_DIR="reports"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

mkdir -p "${REPORTS_DIR}"

echo -e "${GREEN}=== Ollama Test Results Analyzer v2.0 ===${NC}"
echo ""

# Check if we have results
if [[ ! -d "${RESULTS_DIR}" ]] || [[ -z "$(ls -A ${RESULTS_DIR}/*.json 2>/dev/null)" ]]; then
    echo -e "${RED}[ERROR]${NC} No test results found in ${RESULTS_DIR}/"
    echo "Please run './scripts/run-tests.sh' first."
    exit 1
fi

# Function to detect test run type and get latest timestamp
get_latest_test_info() {
    local latest_file=$(ls -t "${RESULTS_DIR}"/*.json | head -n 1)
    local timestamp=""
    local model_name=""
    local category=""
    
    if [[ ! -f "$latest_file" ]]; then
        echo "|||"
        return 1
    fi
    
    # Extract timestamp from filename
    timestamp=$(basename "$latest_file" | grep -o '[0-9]\{8\}_[0-9]\{6\}' || echo "unknown")
    
    # Get test_run_id to parse model and category
    local test_run_id=$(jq -r '.test_run_id' "$latest_file" 2>/dev/null || echo "")
    
    if [[ "$test_run_id" == interactive_* ]]; then
        # Parse interactive test run ID
        # Expected formats:
        # interactive_qwen2_5_coder_7b_coding_timestamp
        # interactive_mistral_nemo_12b_data_timestamp
        # interactive_deepseek_r1_8b_coding_timestamp
        
        IFS='_' read -ra PARTS <<< "$test_run_id"
        local num_parts=${#PARTS[@]}
        
        if [[ $num_parts -ge 6 ]]; then
            # Parse model name based on pattern recognition
            if [[ "${PARTS[1]}" == "qwen2" && "${PARTS[2]}" == "5" ]]; then
                # qwen2_5_coder_7b -> qwen2.5-coder:7b
                model_name="qwen2.5-${PARTS[3]}:${PARTS[4]}"
                category="${PARTS[5]}"
            elif [[ "${PARTS[1]}" == "mistral" ]]; then
                # mistral_nemo_12b -> mistral-nemo:12b
                model_name="${PARTS[1]}-${PARTS[2]}:${PARTS[3]}"
                category="${PARTS[4]}"
            elif [[ "${PARTS[1]}" == "deepseek" ]]; then
                # deepseek_r1_8b -> deepseek-r1:8b
                model_name="${PARTS[1]}-${PARTS[2]}:${PARTS[3]}"
                category="${PARTS[4]}"
            else
                # Generic fallback: try to reconstruct
                model_name="${PARTS[1]}-${PARTS[2]}:${PARTS[3]}"
                category="${PARTS[4]}"
            fi
        else
            # Fallback to JSON if parsing fails
            model_name=$(jq -r '.model.name' "$latest_file" 2>/dev/null || echo "unknown")
            category=$(jq -r '.test_case.category' "$latest_file" 2>/dev/null || echo "unknown")
        fi
        
        # Validate category
        if [[ "$category" != "coding" && "$category" != "data" && "$category" != "all" ]]; then
            # Try fallback: get from JSON
            category=$(jq -r '.test_case.category' "$latest_file" 2>/dev/null || echo "unknown")
        fi
        
        # Validate model name format
        if [[ ! "$model_name" =~ ^[a-zA-Z0-9.-]+:[a-zA-Z0-9.-]+$ && "$model_name" != "unknown" ]]; then
            # Fallback to JSON
            model_name=$(jq -r '.model.name' "$latest_file" 2>/dev/null || echo "unknown")
        fi
    else
        # Not an interactive test - get from JSON
        model_name=$(jq -r '.model.name' "$latest_file" 2>/dev/null || echo "unknown")
        category=$(jq -r '.test_case.category' "$latest_file" 2>/dev/null || echo "unknown")
    fi
    
    echo "${timestamp}|${model_name}|${category}"
}

# Parse latest test info
test_info=$(get_latest_test_info)
if [[ $? -ne 0 ]]; then
    echo -e "${RED}[ERROR]${NC} Failed to parse test information"
    exit 1
fi

IFS='|' read -r latest_timestamp model_name category <<< "$test_info"

if [[ -z "$latest_timestamp" || "$latest_timestamp" == "unknown" ]]; then
    echo -e "${RED}[ERROR]${NC} Could not determine test timestamp"
    exit 1
fi

echo -e "${BLUE}[INFO]${NC} Analyzing results from test run: ${latest_timestamp}"
echo -e "${BLUE}[INFO]${NC} Model: ${model_name}"
echo -e "${BLUE}[INFO]${NC} Category: ${category}"

# Validate we have matching files
matching_files=$(ls "${RESULTS_DIR}"/*"${latest_timestamp}".json 2>/dev/null | wc -l)
if [[ $matching_files -eq 0 ]]; then
    echo -e "${RED}[ERROR]${NC} No test result files found for timestamp ${latest_timestamp}"
    exit 1
fi
echo ""

# Generate analysis report
report_file="${REPORTS_DIR}/analysis_${latest_timestamp}.md"

cat > "${report_file}" << EOF
# Ollama Model Testing Results Analysis

## Executive Summary

This report presents the results of testing performed on the **${model_name}** model
with the **${category}** test category using the Interactive Testing Framework v2.0.

### Test Configuration
- **Model:** ${model_name}
- **Test Category:** ${category}
- **Test Framework:** Interactive Selection (v2.0)
- **Timestamp:** ${latest_timestamp}

## Test Execution Overview

EOF

echo "**Test Run Timestamp:** ${latest_timestamp}" >> "${report_file}"
echo "**Total Test Cases:** $(ls ${RESULTS_DIR}/*${latest_timestamp}.json | wc -l)" >> "${report_file}"
echo "" >> "${report_file}"

# Function to analyze results by category
analyze_by_category() {
    local test_pattern="$1"
    local category_name="$2"
    local category_desc="$3"
    
    echo "## ${category_name}" >> "${report_file}"
    echo "*${category_desc}*" >> "${report_file}"
    echo "" >> "${report_file}"
    echo "| Test ID | Test Name | Duration (s) | Tokens/sec | Status |" >> "${report_file}"
    echo "|---------|-----------|--------------|------------|--------|" >> "${report_file}"

    local found_tests=false
    local test_count=0
    
    for result_file in "${RESULTS_DIR}"/${test_pattern}*"${latest_timestamp}".json; do
        if [[ -f "${result_file}" ]]; then
            # Validate JSON structure before processing
            if ! jq -e '.test_case.id' "$result_file" >/dev/null 2>&1; then
                echo -e "${YELLOW}[WARNING]${NC} Skipping malformed JSON: $(basename "$result_file")" >&2
                continue
            fi
            
            found_tests=true
            test_count=$((test_count + 1))
            
            test_id=$(jq -r '.test_case.id' "${result_file}" 2>/dev/null || echo "unknown")
            test_title=$(jq -r '.test_case.title' "${result_file}" 2>/dev/null || echo "unknown")
            
            # Safe numeric parsing with fallbacks
            latency_ms=$(jq -r '.metrics.quantitative.latency_ms // 0' "${result_file}" 2>/dev/null || echo "0")
            duration=$(echo "scale=3; ${latency_ms} / 1000" | bc 2>/dev/null || echo "0")
            
            tokens_per_sec=$(jq -r '.metrics.quantitative.tokens_per_second // 0' "${result_file}" 2>/dev/null || echo "0")
            result_status=$(jq -r '.overall_result // "unknown"' "${result_file}" 2>/dev/null || echo "unknown")
            
            echo "| ${test_id} | ${test_title} | ${duration} | ${tokens_per_sec} | ${result_status} |" >> "${report_file}"
        fi
    done
    
    if [[ "$found_tests" == false ]]; then
        echo "| - | No tests found for this category | - | - | - |" >> "${report_file}"
    else
        echo -e "${BLUE}[INFO]${NC} Found ${test_count} tests for pattern '${test_pattern}'" >&2
    fi
    
    echo "" >> "${report_file}"
}

# Analyze results based on category
case "$category" in
    "coding")
        analyze_by_category "ct" "Coding Tests Results" "Algorithm implementation, optimization, debugging, and code quality tests"
        ;;
    "data")
        analyze_by_category "dt" "Data Analysis Tests Results" "CSV processing, correlation, business intelligence, and reporting tests"
        ;;
    "all")
        analyze_by_category "ct" "Coding Tests Results" "Algorithm implementation, optimization, debugging, and code quality tests"
        analyze_by_category "dt" "Data Analysis Tests Results" "CSV processing, correlation, business intelligence, and reporting tests"
        ;;
    *)
        echo -e "${YELLOW}[WARNING]${NC} Unknown category: ${category}. Analyzing all available tests."
        analyze_by_category "ct" "Coding Tests Results" "Algorithm implementation, optimization, debugging, and code quality tests"
        analyze_by_category "dt" "Data Analysis Tests Results" "CSV processing, correlation, business intelligence, and reporting tests"
        ;;
esac

# Add model performance analysis
echo "## Model Performance Analysis" >> "${report_file}"
echo "" >> "${report_file}"
echo "**Model:** ${model_name}" >> "${report_file}"

# Calculate averages with proper error handling
test_files=("${RESULTS_DIR}"/*"${latest_timestamp}".json)
valid_files=()

# Filter valid JSON files
for file in "${test_files[@]}"; do
    if [[ -f "$file" ]] && jq -e '.metrics.quantitative' "$file" >/dev/null 2>&1; then
        valid_files+=("$file")
    fi
done

if [[ ${#valid_files[@]} -gt 0 ]]; then
    # Calculate averages safely
    avg_duration=$(printf '%s\n' "${valid_files[@]}" | xargs -I {} jq -r '.metrics.quantitative.latency_ms // 0' {} | awk '{sum += $1; count++} END {if (count > 0) printf "%.3f", sum/count/1000; else print "0"}')
    avg_tokens_sec=$(printf '%s\n' "${valid_files[@]}" | xargs -I {} jq -r '.metrics.quantitative.tokens_per_second // 0' {} | awk '{sum += $1; count++} END {if (count > 0) printf "%.2f", sum/count; else print "0"}')
    
    echo "- **Average Response Time:** ${avg_duration} seconds" >> "${report_file}"
    echo "- **Average Throughput:** ${avg_tokens_sec} tokens/second" >> "${report_file}"
    echo "- **Total Test Cases:** ${#valid_files[@]}" >> "${report_file}"
else
    echo "- **Error:** No valid test data found for performance analysis" >> "${report_file}"
fi
echo "" >> "${report_file}"

# Run qualitative evaluation BEFORE writing the quality section (if requested)
qualitative_scores=""
if [[ "$QUALITATIVE_EVAL" == true ]]; then
    echo -e "${BLUE}[INFO]${NC} Running automated qualitative evaluation using Gemini 2.5 Flash Preview..."
    
    # Create a consolidated results file for qualitative evaluation
    main_result_file="${REPORTS_DIR}/consolidated_${latest_timestamp}.json"
    if [[ ! -f "$main_result_file" ]]; then
        echo -e "${BLUE}[INFO]${NC} Creating consolidated results file for evaluation..."
        
        # Use jq to properly construct the consolidated JSON
        {
            echo "{"
            echo "  \"test_session\": {"
            echo "    \"timestamp\": \"${latest_timestamp}\","
            echo "    \"model\": \"${model_name}\","
            echo "    \"category\": \"${category}\""
            echo "  },"
            echo "  \"summary\": {"
            echo "    \"total_tests\": $(ls ${RESULTS_DIR}/*${latest_timestamp}.json | wc -l | xargs)"
            echo "  },"
            echo "  \"results\": {"
            
            # Process each test result file
            first_file=true
            for result_file in "${RESULTS_DIR}"/*"${latest_timestamp}".json; do
                if [[ -f "$result_file" ]]; then
                    test_id=$(jq -r '.test_case.id' "$result_file" 2>/dev/null || echo "unknown")
                    if [[ "$test_id" != "unknown" ]]; then
                        if [[ "$first_file" != true ]]; then
                            echo ","
                        fi
                        
                        # Extract fields using jq and properly escape JSON
                        test_type=$(jq -r '.test_case.category' "$result_file" 2>/dev/null || echo "unknown")
                        test_desc=$(jq -r '.test_case.description' "$result_file" 2>/dev/null || echo "unknown")
                        test_prompt=$(jq -r '.input.prompt' "$result_file" 2>/dev/null || echo "")
                        model_name_from_file=$(jq -r '.model.name' "$result_file" 2>/dev/null || echo "unknown")
                        output_content=$(jq -r '.output.content' "$result_file" 2>/dev/null || echo "")
                        
                        # Build the test entry using jq to ensure proper JSON escaping
                        echo -n "    \"$test_id\": "
                        jq -n \
                            --arg type "$test_type" \
                            --arg prompt "$test_prompt" \
                            --arg desc "$test_desc" \
                            --arg model "$model_name_from_file" \
                            --arg output "$output_content" \
                            '{
                                test_config: {
                                    type: $type,
                                    prompt: $prompt,
                                    description: $desc
                                },
                                model: $model,
                                output: $output
                            }'
                        
                        first_file=false
                    fi
                fi
            done
            
            echo "  }"
            echo "}"
        } > "$main_result_file"
        
        # Validate the consolidated file
        if [[ ! -f "$main_result_file" ]] || ! jq -e '.results' "$main_result_file" >/dev/null 2>&1; then
            echo -e "${YELLOW}[WARNING]${NC} Failed to create consolidated results file"
            # Find the best result file to use as fallback
            result_files=("${RESULTS_DIR}"/*"${latest_timestamp}".json)
            if [[ ${#result_files[@]} -gt 0 && -f "${result_files[0]}" ]]; then
                main_result_file="${result_files[0]}"
            else
                echo -e "${YELLOW}[WARNING]${NC} No suitable result file found for qualitative evaluation"
                QUALITATIVE_EVAL=false
            fi
        fi
    fi
    
    if [[ "$QUALITATIVE_EVAL" == true ]]; then
        # Run the qualitative evaluator
        qualitative_output_file="${REPORTS_DIR}/qualitative_${latest_timestamp}.json"
        
        if python3 scripts/qualitative-evaluator.py "$main_result_file" --output "$qualitative_output_file" 2>/dev/null; then
            echo -e "${GREEN}[SUCCESS]${NC} Qualitative evaluation completed"
            
            # Extract scores for integration into report
            if [[ -f "$qualitative_output_file" ]]; then
                avg_correctness=$(jq -r '.qualitative_summary.avg_correctness' "$qualitative_output_file" 2>/dev/null || echo "N/A")
                avg_completeness=$(jq -r '.qualitative_summary.avg_completeness' "$qualitative_output_file" 2>/dev/null || echo "N/A")
                avg_quality=$(jq -r '.qualitative_summary.avg_quality' "$qualitative_output_file" 2>/dev/null || echo "N/A")
                tests_evaluated=$(jq -r '.qualitative_summary.total_tests_evaluated' "$qualitative_output_file" 2>/dev/null || echo "N/A")
                
                qualitative_scores="### Summary Scores (0-10 scale)
- **Average Correctness:** ${avg_correctness}/10
- **Average Completeness:** ${avg_completeness}/10
- **Average Quality:** ${avg_quality}/10
- **Tests Evaluated:** ${tests_evaluated}

**Detailed Evaluation:** See [$(basename "$qualitative_output_file")](../reports/$(basename "$qualitative_output_file")) for complete analysis with reasoning.
"
            fi
        else
            echo -e "${YELLOW}[WARNING]${NC} Qualitative evaluation failed - continuing with standard analysis"
            QUALITATIVE_EVAL=false
        fi
    fi
fi

# Add evaluation process section with actual scores if available
if [[ "$QUALITATIVE_EVAL" == true ]]; then
    cat >> "${report_file}" << 'EOF'
## Quality Evaluation Results

### Automated Analysis
*The following analysis was performed using Gemini 2.5 Flash Preview*

EOF
    # Add the qualitative scores
    echo "$qualitative_scores" >> "${report_file}"
else
    cat >> "${report_file}" << 'EOF'
## Manual Quality Evaluation Guide

### Step-by-Step Evaluation Process

#### 1. Prepare for Evaluation
- Run `./scripts/clean-outputs.sh` to generate cleaned output files
- Review test specifications in `test-plans/` directory
- Open outputs in `outputs/` directory alongside this report

#### 2. Evaluate Each Response

**For Coding Tests (ct01-ct06):**
- ✅ **Correctness**: Does code compile and solve the problem?
- ✅ **Best Practices**: Follows language conventions and patterns?
- ✅ **Documentation**: Clear comments and explanations?
- ✅ **Edge Cases**: Handles errors and boundary conditions?
- **Score**: Rate 1-10 (1=Poor, 5=Adequate, 8=Good, 10=Excellent)

**For Data Analysis Tests (dt01-dt06):**
- ✅ **Data Accuracy**: Correctly processes and analyzes data?
- ✅ **Insights Quality**: Generates meaningful business insights?
- ✅ **Completeness**: Addresses all analysis requirements?
- ✅ **Presentation**: Clear formatting and explanations?
- **Score**: Rate 1-10 (1=Poor, 5=Adequate, 8=Good, 10=Excellent)

#### 3. Assessment Criteria

**Scoring Guidelines:**
- **9-10**: Exceptional quality, production-ready
- **7-8**: Good quality with minor improvements needed
- **5-6**: Adequate but requires significant refinement
- **3-4**: Basic attempt with major issues
- **1-2**: Poor quality or incorrect approach

#### 4. Record Your Findings
- Note specific strengths and weaknesses for each test
- Calculate average scores per category
- Identify patterns in model performance
- Document recommendations for model usage

EOF
fi

# Automatically clean output files before listing them
echo -e "${BLUE}[INFO]${NC} Cleaning output files for better readability..."
if ./scripts/clean-outputs.sh "${latest_timestamp}" 2>/dev/null; then
    echo -e "${GREEN}[SUCCESS]${NC} Output files cleaned"
    CLEAN_OUTPUTS_DIR="outputs_clean"
    use_clean_outputs=true
else
    echo -e "${YELLOW}[WARNING]${NC} Output cleaning failed, using raw files"
    CLEAN_OUTPUTS_DIR="${OUTPUTS_DIR}"
    use_clean_outputs=false
fi

# Add output files section
echo "" >> "${report_file}"
if [[ "$use_clean_outputs" == true ]]; then
    echo "### Cleaned Output Files" >> "${report_file}"
    echo "*Raw output files have been cleaned to remove terminal escape codes*" >> "${report_file}"
    echo "" >> "${report_file}"
else
    echo "### Output Files" >> "${report_file}"
fi

output_count=0
if [[ "$use_clean_outputs" == true ]]; then
    # List cleaned output files with clickable links
    for output_file in "${CLEAN_OUTPUTS_DIR}"/*"${latest_timestamp}".out; do
        if [[ -f "${output_file}" ]]; then
            filename=$(basename "${output_file}")
            echo "- [${filename}](../outputs_clean/${filename})" >> "${report_file}"
            output_count=$((output_count + 1))
        fi
    done
else
    # List raw output files with clickable links
    for output_file in "${OUTPUTS_DIR}"/*"${latest_timestamp}".out; do
        if [[ -f "${output_file}" ]]; then
            filename=$(basename "${output_file}")
            echo "- [${filename}](../outputs/${filename})" >> "${report_file}"
            output_count=$((output_count + 1))
        fi
    done
fi

if [[ $output_count -eq 0 ]]; then
    echo "- No output files found for this timestamp" >> "${report_file}"
fi

echo "" >> "${report_file}"
echo "### Result Files" >> "${report_file}"
result_count=0
for result_file in "${RESULTS_DIR}"/*"${latest_timestamp}".json; do
    if [[ -f "${result_file}" ]]; then
        filename=$(basename "${result_file}")
        echo "- [${filename}](../results/${filename})" >> "${report_file}"
        result_count=$((result_count + 1))
    fi
done
if [[ $result_count -eq 0 ]]; then
    echo "- No result files found for this timestamp" >> "${report_file}"
fi

echo "" >> "${report_file}"
echo "---" >> "${report_file}"
echo "*Report generated on $(date)*" >> "${report_file}"

echo -e "${GREEN}[SUCCESS]${NC} Analysis report generated: ${report_file}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "- Model tested: ${model_name}"
echo "- Category: ${category}"
echo "- Total test cases: $(ls ${RESULTS_DIR}/*${latest_timestamp}.json | wc -l)"
if [[ "$QUALITATIVE_EVAL" == true && -n "$qualitative_report" ]]; then
    echo "- Qualitative evaluation: Completed (see $(basename "$qualitative_report"))"
fi
echo ""
echo -e "${BLUE}Interactive Testing Framework v2.1 Features:${NC}"
echo "✓ Dynamic model selection from available Ollama models"
echo "✓ Category-based testing (Coding/Data Analysis/All)"
echo "✓ Flexible test execution with any model"
echo "✓ Enhanced result analysis and reporting"
echo "✓ Automated qualitative evaluation with Gemini 2.5 Flash Preview"

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Open ${report_file} to review the detailed analysis"
if [[ "$QUALITATIVE_EVAL" == true && -n "$qualitative_report" ]]; then
    echo "2. Review automated qualitative scores in ${qualitative_report}"
    echo "3. Compare qualitative metrics with quantitative performance data"
fi

# Check if cleaned outputs exist, if not offer to run clean script
cleaned_outputs_exist=false
if [[ -d "outputs_clean" ]] && [[ -n "$(ls -A outputs_clean/ 2>/dev/null)" ]]; then
    cleaned_outputs_exist=true
fi

next_step=4
if [[ "$QUALITATIVE_EVAL" == true && -n "$qualitative_report" ]]; then
    next_step=6
elif [[ "$cleaned_outputs_exist" == true ]]; then
    echo "$next_step. Review cleaned outputs already available in outputs_clean/ directory"
    next_step=$((next_step + 1))
else
    echo "$next_step. Run ./scripts/clean-outputs.sh to generate cleaned output files (recommended)"
    next_step=$((next_step + 1))
fi

if [[ "$QUALITATIVE_EVAL" != true ]]; then
    echo "$next_step. For automated evaluation, run: ./scripts/analyze-results.sh --with-qualitative-eval"
    next_step=$((next_step + 1))
fi

echo "$next_step. For manual evaluation, assess each response against:"
echo "   • Accuracy: Meets requirements and specifications"
echo "   • Completeness: All requested components present"  
echo "   • Quality: Clear structure and good explanations"
echo "   • Technical Merit: Sound approach and best practices"
next_step=$((next_step + 1))
echo "$next_step. Use the evaluation template in the report to document your assessment"
next_step=$((next_step + 1))
echo "$next_step. Consider running additional tests with different models"
next_step=$((next_step + 1))
echo "$next_step. Test other models: ./scripts/run-tests.sh"
