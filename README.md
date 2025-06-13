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

**Required Software:**
- **Python 3.9+** (for configuration processing and optional AI evaluation)
- **Ollama** - Download from [ollama.ai](https://ollama.ai)
- **System utilities:** `jq` and `bc` (for JSON processing and calculations)

**Install System Dependencies:**
```bash
# macOS
brew install jq bc

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install jq bc

# CentOS/RHEL/Fedora
sudo yum install jq bc  # or sudo dnf install jq bc
```

**Setup Ollama and Pull a Model:**
```bash
# After installing Ollama, pull at least one model
ollama pull qwen2.5-coder:7b
```

**Setup Python Environment:**
```bash
# Create and activate virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install Python dependencies (optional - for AI evaluation features)
cp .env.example .env
# Add your GOOGLE_API_KEY to .env for automated scoring
pip install -r requirements.txt
```

### Hardware Requirements

**Important**: While quantized models are designed to run on commodity hardware, your system specifications directly impact both speed and quality of results.

**Official Ollama Memory Requirements** ([source](https://github.com/ollama/ollama#model-library)):
- **7B models**: At least 8GB RAM available
- **13B models**: At least 16GB RAM available  
- **33B+ models**: At least 32GB RAM available

**Performance Considerations:**
- **CPU-only**: Functional but slow, especially for larger models (minutes per response)
- **GPU-accelerated**: Significantly faster inference (seconds per response)
- **Memory pressure**: Insufficient RAM causes swapping, severely degrading performance
- **Test execution time**: Hardware profile directly affects completion time (30min to 3+ hours for full suite)

💡 **Recommendation**: Check model size with `ollama show <model>` and ensure your system meets minimum requirements. GPU acceleration through CUDA/Metal is strongly recommended for faster inference, especially with larger models.

### Run Your First Test
```bash
# Launch interactive test runner
./scripts/run-tests.sh

# Follow prompts to:
# 1. Select your model
# 2. Choose test category (coding/data-analysis/all)
# 3. Watch real-time execution
# 4. Click the generated link to view your test report
```

### View Previous Results
```bash
# Re-generate analysis report from previous test runs
./scripts/analyze-results.sh --with-qualitative-eval

# All results are automatically saved during test execution to:
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

## Model Selection Guidance

Different language models are optimized for different types of tasks. Understanding this will help you interpret your results:

**Coding-Focused Models** (expect stronger performance on coding tests):
Examples as of June 2025 include `qwen2.5-coder:7b`, `deepseek-coder:6.7b`, `codellama:7b` - models specialized for code generation and programming tasks.

**General-Purpose Models** (balanced performance, often stronger on data analysis):
Examples as of June 2025 include `mistral-nemo:12b`, `llama3.1:8b`, `qwen2.5:14b`, `gemma2:9b`, `phi3:14b` - models with strong reasoning and instruction following capabilities.

💡 **Note**: The model landscape evolves rapidly. Use `ollama list` to see your locally available models, or browse [ollama.com/library](https://ollama.com/library) for the latest releases.

**Key Considerations:**
- **Coding tests** favor models trained on code repositories and programming tasks
- **Data analysis tests** favor models with strong reasoning, pattern recognition, and business communication skills
- **Model size matters**: Larger models (14B+) generally outperform smaller ones, but take longer to run
- **Specialization vs. generalization**: Coding models may struggle with business writing; general models may produce less optimal code

💡 **Tip**: Test the same model on both categories to understand its strengths, or compare a coding model vs. general model on the same category to see the specialization effect.

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
