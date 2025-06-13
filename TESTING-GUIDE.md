# Testing Guide

## Framework Overview

This testing framework includes **13 comprehensive tests** that evaluate real-world capabilities across coding and data analysis domains. These tests provide meaningful assessments of model performance and serve as a foundation for understanding model strengths and weaknesses.

**The framework is fully extensible** - while these core tests provide valuable insights out-of-the-box, you can easily add custom tests, data sources, and entire test categories using YAML configuration files. See [EXTENSION-GUIDE.md](EXTENSION-GUIDE.md) for complete instructions on extending the framework.

## Core Test Categories

### Coding Tests (CT-01 to CT-07)
Comprehensive evaluation of software development capabilities:

- **CT-01: Binary Search Implementation** - Algorithm implementation skills
- **CT-02: Performance Optimization** - Code analysis and optimization 
- **CT-03: Bug Fixing** - Debugging problem-solving abilities
- **CT-04: Code Review Analysis** - Code review and analysis capabilities
- **CT-05: Documentation Generation** - Technical writing and communication
- **CT-06: API Integration** - Practical development skills (REST client)
- **CT-07: Complex App Refactoring** - Multi-module application restructuring and test scaffolding

### Data Analysis Tests (DT-01 to DT-06)
Thorough assessment of data processing and business intelligence:

- **DT-01: CSV Data Analysis** - Business data processing and insights
- **DT-02: Email Thread Correlation** - Information extraction from communications
- **DT-03: Multi-source Data Fusion** - Cross-dataset analysis and correlation
- **DT-04: Data Validation** - Quality assessment and error detection
- **DT-05: Executive Report Generation** - High-level business intelligence
- **DT-06: Pattern Recognition** - Trend analysis and forecasting

> **💡 Beyond the Core Tests:** While these 13 tests provide comprehensive coverage of fundamental capabilities, the framework supports unlimited expansion. You can create tests for your specific domains like scientific computing, creative writing, legal analysis, medical documentation, or any other field.

## Extending Beyond Core Tests

The included tests provide solid baseline evaluation, but the framework is designed for unlimited expansion:

**Adding Domain-Specific Tests:**
1. Add your test data to `test-data/your-domain/`
2. Register data sources in `test-configs/data-sources/common-sources.yaml`
3. Define tests in `test-configs/categories/your-category-tests.yaml`
4. Run `python3 scripts/config_loader.py list-categories` to verify

**Additional Test Categories You Can Create:**
- **Scientific Computing** - Mathematical modeling, algorithm validation
- **Creative Writing** - Storytelling, poetry, content generation
- **Legal Analysis** - Document review, contract analysis
- **Medical Documentation** - Clinical notes, research summaries
- **Financial Analysis** - Risk assessment, market analysis
- **Technical Writing** - Documentation, API specifications

For complete instructions and examples, see [EXTENSION-GUIDE.md](EXTENSION-GUIDE.md).

## Test Execution Details

### Model Selection Strategy

**For Coding Tasks:**
- qwen2.5-coder:7b, qwen2.5-coder:14b, qwen2.5-coder:32b
- deepseek-coder, starcoder, codellama variants
- Models optimized for code generation and analysis

**For Data Analysis:**
- mistral-nemo:12b, llama3.1:8b, gemma2:27b
- qwen2.5:14b, phi3:14b
- Models with strong analytical and reasoning capabilities

**For Comprehensive Testing:**
- Use both categories with your chosen model
- Compare performance across different model sizes
- Test specialized vs. general-purpose models

### Understanding Results

#### Output Files Structure
```
outputs/ct01_TIMESTAMP.out       # Raw model response for CT-01
results/ct01_TIMESTAMP.json     # Structured metrics and metadata
reports/analysis_TIMESTAMP.md   # Comprehensive analysis report
reports/qualitative_TIMESTAMP.json  # AI-powered evaluation scores
```

#### Evaluation Metrics

**Quantitative Metrics:**
- **Latency:** Response time in seconds
- **Throughput:** Tokens generated per second
- **Token Usage:** Input + output token counts
- **Pass/Fail:** Basic execution status

**Qualitative Metrics (AI-Evaluated):**
- **Correctness (0-10):** Accuracy and factual validity
- **Completeness (0-10):** Thoroughness in addressing requirements
- **Quality (0-10):** Code quality (coding tests) or insight quality (data tests)

#### Domain-Specific Quality Assessment

**Coding Tests:**
- Syntax correctness and executability
- Algorithm efficiency and best practices
- Error handling and edge cases
- Documentation quality and clarity
- Type hints and modern Python practices

**Data Analysis Tests:**
- Accuracy of data interpretation
- Quality and relevance of insights
- Proper statistical analysis
- Business value of recommendations
- Clear presentation of findings

## Advanced Usage

### Performance Benchmarking
- Compare token generation rates across models
- Analyze response time patterns by test complexity
- Evaluate quality vs. speed trade-offs
- Track model performance over time

### Custom Evaluation Workflows
1. Run tests with multiple models
2. Compare automated qualitative scores
3. Perform manual spot-checks on borderline cases
4. Generate comparative analysis reports
5. Identify model strengths and weaknesses by category

### Batch Testing Multiple Models
```bash
# Example workflow for comprehensive model comparison
for model in qwen2.5-coder:7b deepseek-coder:6.7b codellama:13b; do
    echo "Testing $model..."
    # Run tests programmatically (future enhancement)
done
```

## Evaluation Methodology

The framework uses the detailed rubrics defined in `EVALUATION-METHODOLOGY.md` for consistent scoring:

- **Coding Tests:** Focus on correctness, completeness, and code quality
- **Data Tests:** Emphasize accuracy, thoroughness, and insight quality
- **Automated Scoring:** Uses Gemini 2.5 Flash Preview for consistent evaluation
- **Cost-Effective:** ~$0.003 per test evaluation

For complete evaluation criteria and scoring rubrics, see [EVALUATION-METHODOLOGY.md](EVALUATION-METHODOLOGY.md).
