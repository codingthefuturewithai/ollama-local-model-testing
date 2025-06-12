# Ollama Interactive Model Testing Framework

A comprehensive testing framework for evaluating any Ollama language model against real-world workflows. This framework provides interactive model selection with category-based testing for coding assistance and data processing tasks.

## Overview

This framework provides:
- **Interactive Model Selection** - Choose from any locally available Ollama models
- **Category-Based Testing** - Select coding tests (6), data analysis tests (6), or all tests (12)
- **Structured Test Plans** with realistic scenarios and sample data
- **Automated Execution** with timing and performance metrics
- **JSON-based Results** for programmatic analysis
- **Comprehensive Reporting** with manual evaluation guidelines

## Quick Start

### Prerequisites
- [Ollama](https://ollama.ai) installed and running
- At least one model pulled (e.g., `ollama pull qwen2.5-coder:7b`)
- `jq` for JSON processing (`brew install jq` on macOS)
- `bc` for calculations (usually pre-installed on Unix systems)

### Run Interactive Tests
```bash
# Launch the interactive testing framework
./scripts/interactive-test-runner.sh
```

The script will prompt you to:
1. **Select a model** from your available Ollama models
2. **Choose test category**: Coding, Data Analysis, or All tests
3. **Monitor execution** with real-time progress and timing

### Analyze Results
```bash
# Generate comprehensive analysis report
./scripts/analyze-results.sh
```

## Project Structure

```
ollama-local-model-testing/
├── instructions.md              # Original requirements
├── project-plan.md             # Detailed project plan
├── README.md                   # This file
├── test-plans/                 # Detailed test specifications
│   ├── coding-tests-category.md
│   └── data-analysis-tests-category.md
├── test-data/                  # Sample input files
│   ├── sample-code/           # Python code examples
│   ├── sample-csv/            # Business data CSV files
│   ├── sample-emails/         # Email correspondence
│   └── sample-pdf-text/       # Document excerpts
├── outputs/                   # Model responses (generated)
├── results/                   # JSON test results (generated)
├── reports/                   # Analysis reports (generated)
├── scripts/                   # Automation scripts
│   ├── interactive-test-runner.sh  # Main interactive testing script
│   ├── analyze-results.sh          # Results analyzer
│   └── clean-outputs.sh            # Output file cleaner
└── schemas/
    └── test-results-schema.json    # JSON schema for results
```

## Test Coverage

### Coding Tests (CT-01 to CT-06)
These tests evaluate software development capabilities using any model:
- **CT-01:** Binary Search Algorithm Implementation
- **CT-02:** Performance Optimization (code refactoring)
- **CT-03:** Bug Fixing (stack implementation)
- **CT-04:** Code Review and Analysis
- **CT-05:** Documentation Generation
- **CT-06:** API Integration (REST client)

### Data Analysis Tests (DT-01 to DT-06)
These tests evaluate data processing and business intelligence using any model:
- **DT-01:** CSV Data Analysis
- **DT-02:** Email Thread Correlation
- **DT-03:** Multi-source Data Fusion
- **DT-04:** Data Validation and Quality Assessment
- **DT-05:** Executive Report Generation
- **DT-06:** Pattern Recognition and Trend Analysis

## Usage Guide

### 1. Interactive Testing Workflow

**Step 1:** Run the interactive test framework
```bash
./scripts/interactive-test-runner.sh
```

**Step 2:** Select your model from the available options
- The script automatically detects all locally installed Ollama models
- Choose any model suitable for your testing needs

**Step 3:** Choose test category
- **Coding Tests:** 6 tests focused on software development tasks
- **Data Analysis Tests:** 6 tests focused on business intelligence and data processing
- **All Tests:** Complete 12-test suite

**Step 4:** Monitor execution
- Real-time progress indicators
- Timing metrics for each test
- Pass/fail status reporting

### 2. Understanding Test Results

**File Outputs:**
- `outputs/ct01-ct06_TIMESTAMP.out` - Raw model responses for coding tests
- `outputs/dt01-dt06_TIMESTAMP.out` - Raw model responses for data tests
- `results/ct01_TIMESTAMP.json` - Structured results with metrics
- `reports/analysis_TIMESTAMP.md` - Comprehensive analysis report

### 3. Model Selection Strategy

**For Coding Tasks:** Consider models optimized for code generation:
- qwen2.5-coder:7b, qwen2.5-coder:14b, qwen2.5-coder:32b
- deepseek-coder, starcoder, codellama variants

**For Data Analysis:** Consider models with strong analytical capabilities:
- mistral-nemo:12b, llama3.1:8b, gemma2:27b
- qwen2.5:14b, phi3:14b

**For Comprehensive Testing:** Use both categories with your chosen model

### 4. Adding Custom Models

To test with new models:
1. Pull the model: `ollama pull model-name:tag`
2. Run the interactive framework: `./scripts/interactive-test-runner.sh`
3. Select the new model from the list

## Evaluation Metrics

### Quantitative Metrics
- **Latency:** Response time in milliseconds
- **Throughput:** Tokens generated per second
- **Token Usage:** Total input + output tokens

### Qualitative Metrics (Manual Evaluation Required)
- **Correctness:** Does output meet requirements? (Pass/Fail/Partial)
- **Completeness:** Are all components present? (Complete/Partial/Incomplete)
- **Clarity:** Is output understandable? (Clear/Unclear/Confusing)

### Domain-Specific Quality
- **Coding Tests:** Syntax correctness, best practices, edge case handling
- **Data Tests:** Accuracy of extraction, insight quality, correlation correctness

## Results Analysis

### Automated Analysis
The framework automatically generates:
- Performance timing data
- Token usage statistics
- Pass/fail status for execution
- JSON-structured results

### Manual Evaluation
Human reviewers should assess:
- Response quality and accuracy
- Completeness of solutions
- Clarity of explanations
- Domain-specific best practices

### Sample Analysis Workflow
1. Run `./scripts/interactive-test-runner.sh`
2. Select model and test category
3. Review outputs in `outputs/` directory  
4. Run `./scripts/analyze-results.sh` for automated analysis
5. Manually evaluate response quality using provided guidelines
6. Compare results across different models
7. Generate final comparative analysis

## Output Files

### Test Outputs
- `outputs/ct01_TIMESTAMP.out` - Model response for CT-01 coding test
- `outputs/dt01_TIMESTAMP.out` - Model response for DT-01 data test
- *[Individual output files for each test case]*

### Result Data
- `results/ct01_TIMESTAMP.json` - Structured results for CT-01
- `results/test_summary_TIMESTAMP.txt` - Execution summary
- `results/test_execution_TIMESTAMP.log` - Detailed execution log

### Analysis Reports
- `reports/analysis_TIMESTAMP.md` - Comprehensive analysis report with evaluation guidelines

## Advanced Usage

### Custom Evaluation Criteria
Modify the JSON schema in `schemas/test-results-schema.json` to add custom evaluation fields.

### Extending Test Cases
1. Add new test cases to test plan markdown files in `test-plans/`
2. Update `interactive-test-runner.sh` with additional test logic
3. Include any required sample data files
4. Test with multiple models to ensure compatibility

### Performance Benchmarking
The framework tracks performance metrics automatically. For deeper analysis:
- Compare token generation rates across models
- Analyze response time patterns
- Evaluate resource usage during testing

## Troubleshooting

### Common Issues

**Models not found:**
```bash
# Pull required models (examples)
ollama pull qwen2.5-coder:7b
ollama pull mistral-nemo:12b
ollama pull llama3.1:8b
```

**Permission denied on scripts:**
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

**No models available in selection menu:**
```bash
# Verify Ollama is running and models are installed
ollama list
ollama pull qwen2.5-coder:7b  # Example model
```

**Missing dependencies:**
```bash
# Install jq (macOS)
brew install jq

# Install bc (usually pre-installed)
# On Ubuntu/Debian: apt-get install bc
```

### Test Failures
- Check `results/test_execution_TIMESTAMP.log` for detailed error messages
- Verify Ollama is running: `ollama list`
- Ensure selected model is pulled and available
- Check timeout values if models are responding slowly
- Try with a different model if one consistently fails

**Interactive Framework Features:**
- ✅ **Dynamic Model Selection** - Test any locally available Ollama model
- ✅ **Category-Based Testing** - Choose coding, data analysis, or comprehensive testing
- ✅ **Flexible Execution** - Run partial test suites or complete evaluations
- ✅ **Real-time Monitoring** - Live progress updates and performance metrics
- ✅ **Cross-Model Compatibility** - Same tests work with any language model

**Model Recommendations:**
- **Small Models (< 8B):** Good for quick testing and development
- **Medium Models (8B-14B):** Balanced performance and quality
- **Large Models (> 14B):** Best quality but slower execution

## Contributing

To extend this framework:
1. Follow the existing test case structure in `test-plans/`
2. Update `interactive-test-runner.sh` for new test categories or models
3. Ensure sample data is realistic but anonymized
4. Test with multiple models to verify compatibility
5. Update documentation and evaluation guidelines

## License

This testing framework is provided as-is for educational and evaluation purposes.

---

**Generated:** June 11, 2025  
**Framework Version:** 2.0 - Interactive Model Selection  
**Compatible Models:** Any Ollama model with appropriate capabilities
