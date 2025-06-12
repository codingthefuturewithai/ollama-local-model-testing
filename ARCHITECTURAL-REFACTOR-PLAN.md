# Ollama Testing Framework - Architectural Refactor Plan

## Executive Summary

The current Ollama Interactive Model Testing Framework requires a complete architectural overhaul to transform from a hardcoded, category-specific system into a truly extensible, configuration-driven framework. This refactor will separate test definitions from execution logic, making the framework agnostic to specific test content and easily maintainable.

## Current Architectural Issues

### 1. Hardcoded Test Definitions
- Test prompts, descriptions, and logic embedded directly in shell scripts
- Category-specific functions (`run_coding_tests`, `run_data_tests`) contain hardcoded test cases
- Impossible to add new tests without modifying core execution scripts

### 2. Violation of Separation of Concerns
- Business logic (test definitions) mixed with execution logic
- Data extraction logic scattered throughout scripts
- Configuration and execution tightly coupled

### 3. Maintenance Challenges
- Adding new test categories requires code changes in multiple files
- Test modifications require touching execution scripts
- No clear schema or validation for test definitions

### 4. Limited Extensibility
- Framework cannot be used for different domains without code changes
- Test data access patterns hardcoded in scripts
- No plugin or module system for test types

## Proposed Solution: Configuration-Driven Architecture

### Phase 1: YAML-Based Test Configuration System

#### 1.1 Test Definition Schema
Create a standardized YAML schema for test definitions:

```yaml
# test-configs/coding-tests.yaml
category:
  id: "coding"
  name: "Coding Tests"
  description: "Algorithm implementation, debugging, and code quality tests"

tests:
  - id: "ct01"
    title: "Binary Search Implementation"
    description: "Implement a binary search function in Python"
    timeout: 90
    prompt_template: |
      Implement a binary search function in Python that:
      1. Takes a sorted list and target value as parameters
      2. Returns the index of the target if found, -1 if not found
      3. Uses the standard binary search algorithm (O(log n) complexity)
      4. Includes proper error handling for edge cases
      5. Add docstring with complexity analysis and examples.
      
      Please provide a complete, well-documented implementation.
    
  - id: "ct02"
    title: "Performance Optimization"
    description: "Analyze and optimize performance issues"
    timeout: 90
    data_sources:
      - type: "file_extract"
        file: "test-data/sample-code/code-samples.py"
        extract:
          method: "sed"
          pattern: "/def slow_search/,/return found_indices/p"
    prompt_template: |
      The following function has performance issues. Analyze the code and provide an optimized version:
      
      {data_sources.slow_search_code}
      
      Please:
      1. Identify the performance problems
      2. Provide an optimized implementation
      3. Explain the improvements and their impact
      4. Include time complexity analysis (before vs after)
      5. Add any additional optimizations you would recommend
```

#### 1.2 Data Source Abstraction
Create a flexible data source system:

```yaml
data_sources:
  - id: "buggy_stack_code"
    type: "file_extract"
    file: "test-data/sample-code/code-samples.py"
    extract:
      method: "sed"
      pattern: "/class BuggyStack/,/return len(self.items) > 0/p"
  
  - id: "orders_csv"
    type: "file_content"
    file: "test-data/sample-csv/orders.csv"
  
  - id: "combined_business_data"
    type: "multi_source"
    sources: ["orders_csv", "customers_csv", "business_updates"]
```

### Phase 2: Generic Execution Engine

#### 2.1 Refactor Scripts to be Test-Agnostic
Transform the current hardcoded scripts into generic processors:

```bash
# New generic structure
./scripts/
├── run-tests.sh              # Generic test runner (replaces interactive-test-runner.sh)
├── config-loader.sh          # YAML configuration parser
├── data-source-handler.sh    # Generic data source processor
├── prompt-builder.sh         # Template engine for dynamic prompts
└── result-processor.sh       # Generic result handling
```

#### 2.2 Configuration-Driven Test Runner
```bash
#!/bin/bash
# run-tests.sh - Generic test runner

# Load configuration
load_test_config() {
    local config_file="$1"
    # Parse YAML and extract test definitions
    yq eval '.tests[]' "$config_file"
}

# Process data sources
process_data_sources() {
    local test_config="$1"
    # Generic data source processing based on type
    case "$data_source_type" in
        "file_extract") extract_file_content ;;
        "file_content") read_full_file ;;
        "multi_source") combine_sources ;;
    esac
}

# Build dynamic prompts
build_prompt() {
    local template="$1"
    local data_context="$2"
    # Template substitution engine
    envsubst < "$template"
}
```

### Phase 3: Extensible Framework Architecture

#### 3.1 Plugin System
Create a modular plugin system for different test types:

```
test-configs/
├── categories/
│   ├── coding-tests.yaml
│   ├── data-analysis-tests.yaml
│   ├── security-tests.yaml        # Future extension
│   └── performance-tests.yaml     # Future extension
├── data-sources/
│   ├── file-processors.yaml
│   ├── api-connectors.yaml        # Future extension
│   └── database-queries.yaml      # Future extension
└── schemas/
    ├── test-definition.schema.yaml
    ├── data-source.schema.yaml
    └── prompt-template.schema.yaml
```

#### 3.2 Domain-Agnostic Core
Refactor core components to be completely domain-independent:

- **Test Runner**: Executes any test defined in YAML configuration
- **Data Handler**: Processes any data source type through plugin system
- **Prompt Engine**: Builds prompts from templates with variable substitution
- **Result Processor**: Handles outputs according to configurable schemas

### Phase 4: Enhanced Configuration Management

#### 4.1 Configuration Validation
Implement schema validation for all YAML configurations:

```python
# config-validator.py
import yaml
import jsonschema

def validate_test_config(config_file):
    with open(config_file) as f:
        config = yaml.safe_load(f)
    
    with open('schemas/test-definition.schema.yaml') as f:
        schema = yaml.safe_load(f)
    
    jsonschema.validate(config, schema)
```

#### 4.2 Dynamic Test Discovery
Automatically discover and load test configurations:

```bash
# discover-tests.sh
find test-configs/categories -name "*.yaml" | while read config_file; do
    if validate_config "$config_file"; then
        register_test_category "$config_file"
    fi
done
```

## Implementation Benefits

### 1. Complete Extensibility
- Add new test categories by creating YAML files
- No code changes required for new tests
- Support for any domain or use case

### 2. Maintainability
- Clear separation of concerns
- Test definitions separate from execution logic
- Schema validation prevents configuration errors

### 3. Reusability
- Framework can be used for any LLM testing scenario
- Modular components can be reused across projects
- Plugin system allows custom extensions

### 4. Configuration Management
- Version control for test definitions
- Easy test modification without touching code
- Centralized configuration with validation

## Migration Strategy

### Step 1: Create Configuration Schema
1. Define YAML schemas for test definitions
2. Create validation tools
3. Establish directory structure

### Step 2: Extract Current Tests
1. Convert hardcoded tests to YAML configurations
2. Preserve all existing functionality
3. Validate configuration completeness

### Step 3: Refactor Core Scripts
1. Create generic, configuration-driven scripts
2. Implement data source abstraction layer
3. Build template engine for dynamic prompts

### Step 4: Validation and Testing
1. Ensure all existing tests work with new system
2. Validate extensibility with new test examples
3. Performance testing and optimization

### Step 5: Documentation and Cleanup
1. Update all documentation
2. Remove legacy hardcoded components
3. Create extension guides

## Technical Requirements

### Dependencies
- `yq` for YAML processing
- `jq` for JSON manipulation (already in use)
- `envsubst` for template substitution
- Python with `pyyaml` and `jsonschema` for validation

### Backward Compatibility
- Maintain existing CLI interface during transition
- Provide migration tools for existing test results
- Preserve all current functionality

## Success Criteria

1. **Zero Code Changes for New Tests**: Adding a new test category requires only YAML configuration
2. **Domain Independence**: Framework can be used for any LLM testing domain
3. **Maintainability**: Test modifications require only configuration changes
4. **Extensibility**: Plugin system supports custom data sources and test types
5. **Validation**: All configurations are schema-validated
6. **Performance**: No degradation in test execution performance

## Timeline Estimate

- **Phase 1**: Schema and YAML configs (1-2 days)
- **Phase 2**: Generic execution engine (2-3 days)
- **Phase 3**: Plugin system and extensibility (2-3 days)
- **Phase 4**: Configuration management (1-2 days)
- **Total**: 6-10 days of development time

## Next Steps

1. Begin with Phase 1: Create YAML schema and convert existing tests
2. Implement configuration validation tools
3. Refactor one script at a time to maintain functionality
4. Test thoroughly at each phase
5. Document the new architecture and usage patterns

This refactor will transform the Ollama Testing Framework from a hardcoded, domain-specific tool into a truly extensible, professional-grade LLM testing platform suitable for any use case or domain.
