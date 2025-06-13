# Extension Guide

## Adding Custom Tests

This framework uses YAML-driven configuration to make adding new tests straightforward. Follow these steps to extend the framework with your own tests.

## Quick Start: Adding a New Test

### 1. Add Test Data (if needed)
Place your sample data in the `test-data/` directory:
```bash
# Create a new directory for your test data
mkdir -p test-data/my-custom-data/
# Add your files
echo "Sample content" > test-data/my-custom-data/sample.txt
```

### 2. Register Data Sources
Edit `test-configs/data-sources/common-sources.yaml`:
```yaml
data_sources:
  # ...existing sources...
  
  - id: "my_custom_data"
    type: "file_content"
    description: "My custom test data"
    file: "test-data/my-custom-data/sample.txt"
    cache_ttl: 600
```

### 3. Add Test Definition
Edit an existing category file (e.g., `test-configs/categories/coding-tests.yaml`) or create a new one:
```yaml
tests:
  # ...existing tests...
  
  - id: "ct08"
    title: "My Custom Test"
    description: "Test description for evaluation"
    timeout: 120
    data_sources:
      - "my_custom_data"
    prompt_template: |
      Here is the data to analyze:
      
      {data_sources.my_custom_data}
      
      Please perform the following tasks:
      1. Analyze the content
      2. Provide insights
      3. Suggest improvements
    evaluation_criteria:
      correctness_weight: 0.4
      completeness_weight: 0.3
      quality_weight: 0.3
```

### 4. Test Your Configuration
```bash
# Validate the configuration
python3 scripts/config_loader.py load-category coding

# Test prompt generation
python3 scripts/config_loader.py build-prompt coding ct08
```

### 5. Run Your Test
```bash
./scripts/run-tests.sh
# Select your model and category - your new test will be included
```

## Data Source Types

### File Content (`file_content`)
Loads entire file content:
```yaml
- id: "full_document"
  type: "file_content"
  description: "Complete document content"
  file: "test-data/documents/spec.md"
  cache_ttl: 600
```

### File Extract (`file_extract`) 
Extracts specific sections using patterns:
```yaml
- id: "function_code"
  type: "file_extract"
  description: "Specific function from code file"
  file: "test-data/code/app.py"
  extract:
    method: "sed"
    pattern: "/def my_function/,/^def /p"
  cache_ttl: 300
```

### Multi-Source (`multi_source`)
Combines multiple data sources:
```yaml
- id: "complete_app"
  type: "multi_source"
  description: "All application modules"
  sources:
    - "module1_code"
    - "module2_code" 
    - "utils_code"
  cache_ttl: 300
```

## Creating New Test Categories

### 1. Create Category Configuration
Create `test-configs/categories/my-category-tests.yaml`:
```yaml
category:
  id: "my-category"
  name: "My Custom Category"
  description: "Description of what this category tests"

tests:
  - id: "mc01"
    title: "First Custom Test"
    description: "Test description"
    timeout: 90
    prompt_template: |
      Your test prompt here...
    evaluation_criteria:
      correctness_weight: 0.4
      completeness_weight: 0.3
      quality_weight: 0.3
```

### 2. Add Human-Readable Documentation
Create `test-plans/my-category-tests-category.md`:
```markdown
# Test Plan: My Custom Category
**Framework Version:** 2.1
**Category:** My Custom Domain
**Test Count:** 1 test

## Overview
Description of your test category and objectives.

## Test Cases

### MC-01: First Custom Test
**Objective:** What this test evaluates
**Complexity:** Low/Medium/High
**Expected Duration:** 60-90 seconds

**Test Description:**
Detailed description of the test.

**Requirements:**
- Requirement 1
- Requirement 2

**Evaluation Criteria:**
- **Correctness (40%):** What constitutes correct output
- **Completeness (30%):** What constitutes complete response
- **Quality (30%):** What constitutes high quality
```

### 3. Test the New Category
```bash
# Verify category is detected
python3 scripts/config_loader.py list-categories

# Load and validate
python3 scripts/config_loader.py load-category my-category
```

## Advanced Patterns

### Complex Data Processing
For tests requiring complex data preparation:
```yaml
# In common-sources.yaml
- id: "processed_dataset"
  type: "file_content"
  description: "Large dataset for analysis"
  file: "test-data/complex/dataset.csv"
  preprocessing:
    - type: "trim"
      description: "Remove whitespace"
  cache_ttl: 1200
```

### Multi-File Applications
For testing with entire codebases, first define data sources in `common-sources.yaml`:
```yaml
# In test-configs/data-sources/common-sources.yaml
data_sources:
  - id: "app_main"
    type: "file_content"
    file: "test-data/my-app/main.py"

  - id: "app_utils"
    type: "file_content" 
    file: "test-data/my-app/utils.py"

  - id: "complete_application"
    type: "multi_source"
    sources: ["app_main", "app_utils"]
```

Then reference them in your test definition:
```yaml
# In your test category YAML file
tests:
  - id: "app01"
    title: "Application Analysis"
    data_sources:
      - "complete_application"  # References the multi_source defined above
    prompt_template: |
      Analyze this complete application:
      
      {data_sources.complete_application}
      
            Provide architectural feedback and suggestions.
```

## Configuration Validation

### Schema Compliance
The framework validates configurations against schemas in `test-configs/schemas/`:
- `test-definition.schema.yaml` - Test structure validation
- `data-source.schema.yaml` - Data source validation

### Testing Tools
```bash
# Validate all configurations
python3 scripts/validate_config.py

# Test prompt building for specific tests
python3 scripts/config_loader.py build-prompt <category> <test_id>

# List available categories
python3 scripts/config_loader.py list-categories

# Load and validate a specific category
python3 scripts/config_loader.py load-category <category_id>
```

## Best Practices

### Test Design
1. **Clear Objectives:** Each test should have a specific, measurable goal
2. **Realistic Data:** Use representative but anonymized sample data
3. **Appropriate Timeouts:** Balance thoroughness with practical execution time
4. **Consistent Evaluation:** Define clear criteria for success/failure

### Data Management
1. **Organized Structure:** Group related data in logical directories
2. **Appropriate Caching:** Set cache_ttl based on data stability
3. **Size Considerations:** Keep individual files manageable (< 50KB typically)
4. **Privacy:** Ensure all sample data is anonymized or synthetic

### Performance Considerations
1. **Timeout Values:** Coding tests: 90-120s, Data analysis: 120-180s, Complex tasks: 300s+
2. **Token Limits:** Consider model context windows when combining large data sources
3. **Caching Strategy:** Use appropriate cache_ttl values to balance performance and freshness

## Examples Repository

See the existing tests for examples:
- **Simple Test:** `CT-01` (Binary Search) - Basic prompt with no data sources
- **Data-Driven Test:** `CT-02` (Performance Optimization) - Uses code extraction
- **Complex Multi-File Test:** `CT-07` (App Refactoring) - Multi-source data combination

For complete examples and working configurations, examine the existing test definitions in `test-configs/categories/`.
