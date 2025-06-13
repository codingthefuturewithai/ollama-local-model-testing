# Ollama Model Testing Framework

A YAML-driven testing framework for evaluating any Ollama language model against real-world coding and data analysis tasks. Test any model with consistent, extensible, configuration-based test scenarios.

## Key Features

- **Universal Model Support** - Test any locally available Ollama model
- **Configuration-Driven** - YAML-based test definitions and data sources
- **13 Real-World Tests** - 7 coding + 6 data analysis scenarios
- **Automated Evaluation** - AI-powered qualitative scoring with Gemini 2.5 Flash
- **Extensible Framework** - Easy to add custom tests and data sources
- **Comprehensive Analysis** - Performance metrics, automated scoring, detailed reports

## Quick Start

### Prerequisites
```bash
# Install Ollama and pull a model
ollama pull qwen2.5-coder:7b

# Install system dependencies
brew install jq bc  # macOS

# Setup Python environment (optional - for AI evaluation)
cp .env.example .env
# Add your GOOGLE_API_KEY to .env for automated scoring
pip install -r requirements.txt
```

### Run Your First Test
```bash
# Launch interactive test runner
./scripts/run-tests.sh

# Follow prompts to:
# 1. Select your model
# 2. Choose test category (coding/data-analysis/all)
# 3. Watch real-time execution
```

### View Results
```bash
# Generate analysis report
./scripts/analyze-results.sh --with-qualitative-eval

# Results saved to:
# - reports/analysis_TIMESTAMP.md (main report)
# - outputs/ctXX_TIMESTAMP.out (raw responses)  
# - results/ctXX_TIMESTAMP.json (structured data)
```

## Test Categories

**Coding Tests (CT-01 to CT-07)** - Software development capabilities:
- Algorithm implementation, optimization, debugging
- Code review, documentation, API integration  
- Multi-module application refactoring

**Data Analysis Tests (DT-01 to DT-06)** - Business intelligence and data processing:
- CSV analysis, email correlation, multi-source fusion
- Data validation, executive reporting, pattern recognition

See [TESTING-GUIDE.md](TESTING-GUIDE.md) for detailed test descriptions and evaluation criteria.

## Usage Patterns

All testing is done through the same interactive script: `./scripts/run-tests.sh`

**Compare Models** - Run the script multiple times, selecting different models with the same test category to compare performance across models.

**Focus on Capabilities** - Choose specific test categories:
- "Coding Tests" - Algorithm implementation, debugging, refactoring
- "Data Analysis Tests" - CSV processing, business intelligence, reporting
- "All Tests" - Complete evaluation suite

**Analyze Results** - Each test run generates timestamped files in `outputs/`, `results/`, and `reports/` directories for easy comparison and trend analysis.

## Extending the Framework

### Add Custom Tests
1. **Create test data** in `test-data/my-domain/`
2. **Register data sources** in `test-configs/data-sources/common-sources.yaml`
3. **Define tests** in `test-configs/categories/my-category-tests.yaml`
4. **Validate configuration** with `python3 scripts/config_loader.py`

See [EXTENSION-GUIDE.md](EXTENSION-GUIDE.md) for complete instructions and examples.

### Configuration System
The framework uses YAML configuration files for easy customization:
```
test-configs/
├── categories/           # Test definitions by domain
│   ├── coding-tests.yaml
│   └── data-analysis-tests.yaml
├── data-sources/         # Reusable data source definitions
│   └── common-sources.yaml
└── schemas/             # Validation schemas
    ├── test-definition.schema.yaml
    └── data-source.schema.yaml
```

## Project Structure

```
ollama-local-model-testing/
├── README.md                    # This file
├── TESTING-GUIDE.md            # Detailed test descriptions
├── EXTENSION-GUIDE.md          # How to add custom tests
├── TROUBLESHOOTING.md          # Framework-specific issues
├── EVALUATION-METHODOLOGY.md  # Scoring rubrics
├── test-configs/               # YAML configuration files
├── test-data/                  # Sample input data
├── test-plans/                 # Human-readable test specs
├── scripts/                    # Automation and analysis tools
├── outputs/                    # Raw model responses (generated)
├── results/                    # Structured test results (generated)
└── reports/                    # Analysis reports (generated)
```

## Documentation

- **[TESTING-GUIDE.md](TESTING-GUIDE.md)** - Complete test descriptions, model recommendations, evaluation details
- **[EXTENSION-GUIDE.md](EXTENSION-GUIDE.md)** - Add custom tests, data sources, and categories
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues specific to this framework
- **[EVALUATION-METHODOLOGY.md](EVALUATION-METHODOLOGY.md)** - Detailed scoring criteria and rubrics
- **[TOKEN-COUNTING-ANALYSIS.md](TOKEN-COUNTING-ANALYSIS.md)** - Token counting implementation analysis and future improvements

## Common Issues

**No models available:** `ollama pull qwen2.5-coder:7b`

**Tests timing out:** Use smaller models or increase timeout values in YAML configurations

**Missing qualitative scores:** Add `GOOGLE_API_KEY` to `.env` file and use `--with-qualitative-eval`

**Configuration errors:** Run `python3 scripts/config_loader.py list-categories` to validate

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for framework-specific debugging guidance.

---

**Framework Version:** 2.1 - YAML Configuration System  
**Updated:** June 13, 2025  
**Compatible:** Any Ollama model
