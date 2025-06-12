# Ollama Model Testing Framework

A comprehensive testing framework for evaluating Ollama language models against real-world workflows. This framework systematically tests two models: qwen2.5-coder:7b for coding assistance and mistral-nemo:12b for data processing and correlation tasks.

## Overview

This framework provides:
- **Structured Test Plans** with 6 test cases per model
- **Realistic Sample Data** including code, CSV files, emails, and documents
- **Automated Execution** with timing and performance metrics
- **JSON-based Results** for programmatic analysis
- **Comprehensive Reporting** with manual evaluation guidelines

## Quick Start

### Prerequisites
- [Ollama](https://ollama.ai) installed and running
- `jq` for JSON processing (`brew install jq` on macOS)
- `bc` for calculations (usually pre-installed on Unix systems)

### Run All Tests
```bash
# Execute the complete test suite
./scripts/run-tests.sh
```

### Analyze Results
```bash
# Generate analysis report
./scripts/analyze-results.sh
```

## Project Structure

```
ollama-local-model-testing/
├── instructions.md              # Original requirements
├── project-plan.md             # Detailed project plan
├── README.md                   # This file
├── test-plans/                 # Detailed test specifications
│   ├── qwen-coder-test-plan.md
│   └── mistral-nemo-test-plan.md
├── test-data/                  # Sample input files
│   ├── sample-code/           # Python code examples
│   ├── sample-csv/            # Business data CSV files
│   ├── sample-emails/         # Email correspondence
│   └── sample-pdf-text/       # Document excerpts
├── outputs/                   # Model responses (generated)
├── results/                   # JSON test results (generated)
├── reports/                   # Analysis reports (generated)
├── scripts/                   # Automation scripts
│   ├── run-tests.sh          # Master test runner
│   └── analyze-results.sh    # Results analyzer
└── schemas/
    └── test-results-schema.json # JSON schema for results
```

## Test Coverage

### qwen2.5-coder:7b (Coding Assistant)
- **QC-01:** Binary Search Algorithm Implementation
- **QC-02:** Performance Optimization (code refactoring)
- **QC-03:** Bug Fixing (stack implementation)
- **QC-04:** Code Review and Analysis
- **QC-05:** Documentation Generation
- **QC-06:** API Integration (REST client)

### mistral-nemo:12b (Data Processing)
- **MN-01:** CSV Data Analysis
- **MN-02:** Email Thread Correlation
- **MN-03:** Multi-source Data Fusion
- **MN-04:** Data Validation and Quality Assessment
- **MN-05:** Executive Report Generation
- **MN-06:** Pattern Recognition and Trend Analysis

## Usage Guide

### 1. Running Individual Tests

You can run specific tests by extracting commands from the test plans:

```bash
# Example: Run single coding test
ollama run qwen2.5-coder:7b \
  --prompt "Implement a binary search function..." \
  --timeout 90 \
  > outputs/manual_test.out
```

### 2. Custom Test Data

To test with your own data:
1. Replace files in `test-data/` directories
2. Update the test scripts to reference new files
3. Run tests normally

### 3. Adding New Models

To test additional models:
1. Copy and modify existing test plans
2. Update `run-tests.sh` with new model commands
3. Adjust evaluation criteria as needed

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
1. Run `./scripts/run-tests.sh`
2. Review outputs in `outputs/` directory
3. Run `./scripts/analyze-results.sh` for summary
4. Manually evaluate response quality
5. Update JSON files with qualitative scores
6. Generate final comparative report

## Output Files

### Test Outputs
- `outputs/qc01_TIMESTAMP.out` - Model response for QC-01 test
- `outputs/mn01_TIMESTAMP.out` - Model response for MN-01 test
- *[Additional output files for each test case]*

### Result Data
- `results/qc01_TIMESTAMP.json` - Structured results for QC-01
- `results/test_summary_TIMESTAMP.txt` - Execution summary
- `results/test_execution_TIMESTAMP.log` - Detailed execution log

### Analysis Reports
- `reports/analysis_TIMESTAMP.md` - Comprehensive analysis report

## Advanced Usage

### Custom Evaluation Criteria
Modify the JSON schema in `schemas/test-results-schema.json` to add custom evaluation fields.

### Extending Test Cases
1. Add new test cases to test plan markdown files
2. Update `run-tests.sh` with additional test commands
3. Include any required sample data files

### Performance Benchmarking
The framework tracks performance metrics automatically. For deeper analysis:
- Compare token generation rates across models
- Analyze response time patterns
- Evaluate resource usage during testing

## Troubleshooting

### Common Issues

**Models not found:**
```bash
# Pull required models
ollama pull qwen2.5-coder:7b
ollama pull mistral-nemo:12b
```

**Permission denied on scripts:**
```bash
# Make scripts executable
chmod +x scripts/*.sh
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
- Ensure models are pulled and available
- Check timeout values if models are responding slowly

## Contributing

To extend this framework:
1. Follow the existing test case structure
2. Update relevant documentation
3. Ensure sample data is realistic but anonymized
4. Test new components thoroughly

## License

This testing framework is provided as-is for educational and evaluation purposes.

---

**Generated:** June 11, 2025  
**Framework Version:** 1.0  
**Compatible Models:** qwen2.5-coder:7b, mistral-nemo:12b
