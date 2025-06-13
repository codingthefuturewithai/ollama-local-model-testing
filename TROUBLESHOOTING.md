# Troubleshooting Guide

## Framework-Specific Issues

### Configuration Problems

**Error: "Category not found" when running tests**
```bash
# Check available categories
python3 scripts/config_loader.py list-categories

# Validate specific category configuration
python3 scripts/config_loader.py load-category coding
```

**Error: "Data source not found" in prompt building**
```bash
# Verify data source configuration
python3 scripts/config_loader.py build-prompt coding ct02

# Check if referenced files exist
ls -la test-data/sample-code/code-samples.py
```

**Error: "No models available in selection menu"**
- Ensure Ollama is running: `ollama list`
- Pull at least one model: `ollama pull qwen2.5-coder:7b`
- Check Ollama service status: `ps aux | grep ollama`

### Test Execution Issues

**Tests timing out consistently**
- Check model size vs. available resources
- Increase timeout values in YAML test definitions
- Use smaller models for development/testing
- Monitor system resources during execution

**Prompt building fails with "multi_source" errors**
- Verify all referenced data sources exist in `common-sources.yaml`
- Check file paths are correct relative to project root
- Ensure circular dependencies don't exist between data sources

**JSON parsing errors in results**
```bash
# Check specific result file for malformed JSON
jq . results/ct01_TIMESTAMP.json

# Validate JSON schema compliance
python3 scripts/validate_config.py
```

### Qualitative Evaluation Issues

**Google API key errors**
- Verify `.env` file exists and contains valid `GOOGLE_API_KEY`
- Test API access: `python3 -c "import os; print(os.getenv('GOOGLE_API_KEY'))"`
- Check API quota and billing in Google Cloud Console

**Gemini evaluation returning errors**
- Model output might contain unparseable content
- Check raw output files in `outputs/` directory
- Verify evaluation prompt templates in `qualitative-evaluator.py`

**Cost concerns with automated evaluation**
- Each test costs ~$0.003 to evaluate
- Full 13-test suite costs ~$0.039
- Monitor usage in Google Cloud Console

### Data Source Processing

**File extract patterns not working**
```bash
# Test sed pattern manually
sed -n '/def slow_search/,/return found_indices/p' test-data/sample-code/code-samples.py

# Debug pattern in config loader
python3 scripts/config_loader.py build-prompt coding ct02 | head -20
```

**Multi-source combination producing unexpected results**
- Check source ordering in YAML configuration
- Verify individual sources work independently
- Review combined output in prompt builder

**Cache invalidation issues**
- Data source cache controlled by `cache_ttl` in YAML
- Clear Python cache: `rm -rf scripts/__pycache__/`
- Restart if data sources updated but not reflected

### Model-Specific Problems

**Model responses include terminal escape codes**
- Use output cleaning: `./scripts/clean-outputs.sh`
- Check if model is outputting raw terminal sequences
- Review cleaned outputs in `outputs_clean/` directory

**Model generates incomplete responses**
- Increase timeout values in test configurations
- Check if model context window is exceeded
- Try with smaller data sources or simpler prompts

**Inconsistent model behavior across runs**
- Some models have inherent variability
- Run multiple test iterations for statistical significance
- Consider using deterministic sampling if model supports it

### Analysis and Reporting

**Missing analysis reports**
```bash
# Check if analysis script completed successfully
./scripts/analyze-results.sh 2>&1 | tail -20

# Verify required dependencies
which jq bc python3
```

**Report generation fails on timestamp parsing**
- Ensure consistent timestamp format across result files
- Check for corrupted JSON files in `results/` directory
- Verify file naming conventions match expected patterns

**Qualitative evaluation scores missing**
- Ensure Google API key is configured
- Check if `--with-qualitative-eval` was used
- Verify Python dependencies are installed: `pip list | grep -E "(langchain|google)"`

## Performance Issues

**Slow test execution**
- Monitor system resources during tests
- Use smaller models for development
- Reduce test data size if appropriate
- Check Ollama memory usage: `ollama ps`

**High memory usage**
- Large data sources loaded into memory
- Multiple concurrent model instances
- Check available system memory before testing

**Disk space issues**
- Output files accumulate over time
- Clean old outputs: `./scripts/clean-outputs.sh`
- Archive or remove old result sets

## Development and Extension Issues

**New test configuration not detected**
```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('test-configs/categories/my-tests.yaml'))"

# Check file naming conventions (must end in '-tests.yaml')
ls test-configs/categories/

# Verify category ID matches filename pattern
```

**Custom data sources not loading**
- Ensure relative paths from project root
- Check file permissions: `ls -la test-data/my-custom-data/`
- Verify data source ID uniqueness in `common-sources.yaml`

**Schema validation failures**
```bash
# Run comprehensive validation
python3 scripts/validate_config.py

# Check against specific schema
# (detailed validation output will show specific issues)
```
