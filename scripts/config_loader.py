#!/usr/bin/env python3
"""
Configuration loader for YAML-based test definitions.
Uses only Python standard library and existing dependencies.
"""

import yaml
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Any, Optional

class ConfigLoader:
    """Load and validate test configurations from YAML files."""
    
    def __init__(self, config_root: str = "test-configs"):
        self.config_root = Path(config_root)
        self.categories_dir = self.config_root / "categories"
        self.data_sources_dir = self.config_root / "data-sources"
        self.schemas_dir = self.config_root / "schemas"
    
    def load_test_category(self, category_id: str) -> Dict[str, Any]:
        """Load a test category configuration."""
        # First try the direct mapping
        config_file = self.categories_dir / f"{category_id}-tests.yaml"
        
        # If direct mapping doesn't work, search for the correct file
        if not config_file.exists():
            config_file = self._find_category_file(category_id)
            if not config_file:
                raise FileNotFoundError(f"Test category config not found for ID: {category_id}")
        
        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)
        
        # Validate basic structure
        self._validate_category_config(config)
        return config
    
    def _find_category_file(self, category_id: str) -> Optional[Path]:
        """Find the YAML file that contains the given category ID."""
        for yaml_file in self.categories_dir.glob("*-tests.yaml"):
            try:
                with open(yaml_file, 'r') as f:
                    config = yaml.safe_load(f)
                    if 'category' in config and 'id' in config['category']:
                        if config['category']['id'] == category_id:
                            return yaml_file
            except Exception:
                continue
        return None
    
    def load_data_sources(self, source_file: str = "common-sources.yaml") -> Dict[str, Any]:
        """Load data source configurations."""
        config_file = self.data_sources_dir / source_file
        
        if not config_file.exists():
            raise FileNotFoundError(f"Data sources config not found: {config_file}")
        
        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)
        
        return config
    
    def get_available_categories(self) -> List[str]:
        """Get list of available test categories."""
        if not self.categories_dir.exists():
            return []
        
        categories = []
        for yaml_file in self.categories_dir.glob("*-tests.yaml"):
            try:
                # Load the YAML file to get the actual category ID
                with open(yaml_file, 'r') as f:
                    config = yaml.safe_load(f)
                    if 'category' in config and 'id' in config['category']:
                        category_id = config['category']['id']
                        categories.append(category_id)
                    else:
                        # Fallback to filename-based extraction
                        category_id = yaml_file.stem.replace("-tests", "")
                        categories.append(category_id)
            except Exception:
                # If YAML loading fails, fall back to filename-based extraction
                category_id = yaml_file.stem.replace("-tests", "")
                categories.append(category_id)
        
        return sorted(categories)
    
    def _validate_category_config(self, config: Dict[str, Any]) -> None:
        """Basic validation of category configuration."""
        required_fields = ["category", "tests"]
        for field in required_fields:
            if field not in config:
                raise ValueError(f"Missing required field: {field}")
        
        if "id" not in config["category"]:
            raise ValueError("Category must have an 'id' field")
        
        if not isinstance(config["tests"], list) or len(config["tests"]) == 0:
            raise ValueError("Tests must be a non-empty list")
        
        for i, test in enumerate(config["tests"]):
            required_test_fields = ["id", "title", "timeout", "prompt_template"]
            for field in required_test_fields:
                if field not in test:
                    raise ValueError(f"Test {i} missing required field: {field}")

class DataSourceProcessor:
    """Process data sources according to their type."""
    
    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self._cache = {}
    
    def process_data_source(self, source_config: Dict[str, Any]) -> str:
        """Process a data source and return its content."""
        source_id = source_config["id"]
        source_type = source_config["type"]
        
        # Check cache first
        cache_key = f"{source_id}_{hash(str(source_config))}"
        if cache_key in self._cache:
            return self._cache[cache_key]
        
        content = ""
        
        if source_type == "file_content":
            content = self._load_file_content(source_config)
        elif source_type == "file_extract":
            content = self._extract_file_content(source_config)
        elif source_type == "multi_source":
            content = self._combine_multi_sources(source_config)
        else:
            raise ValueError(f"Unknown data source type: {source_type}")
        
        # Cache the result
        self._cache[cache_key] = content
        return content
    
    def _load_file_content(self, config: Dict[str, Any]) -> str:
        """Load complete file content."""
        file_path = self.project_root / config["file"]
        
        if not file_path.exists():
            return f"[FILE NOT FOUND: {config['file']}]"
        
        try:
            with open(file_path, 'r') as f:
                return f.read()
        except Exception as e:
            return f"[ERROR READING FILE: {config['file']} - {str(e)}]"
    
    def _extract_file_content(self, config: Dict[str, Any]) -> str:
        """Extract specific content from file using sed-like patterns."""
        file_path = self.project_root / config["file"]
        
        if not file_path.exists():
            return f"[FILE NOT FOUND: {config['file']}]"
        
        try:
            with open(file_path, 'r') as f:
                lines = f.readlines()
            
            extract_config = config["extract"]
            method = extract_config["method"]
            pattern = extract_config["pattern"]
            
            if method == "sed":
                return self._sed_extract(lines, pattern)
            else:
                raise ValueError(f"Unsupported extraction method: {method}")
                
        except Exception as e:
            return f"[ERROR EXTRACTING FROM FILE: {config['file']} - {str(e)}]"
    
    def _sed_extract(self, lines: List[str], pattern: str) -> str:
        """Simulate sed pattern extraction using Python."""
        # Parse sed pattern like "/start/,/end/p"
        if pattern.endswith("/p") and ",/" in pattern:
            # Range pattern: /start/,/end/p
            parts = pattern[:-2].split(",/")  # Remove "/p" and split
            start_pattern = parts[0][1:].rstrip('/')  # Remove leading "/" and trailing "/"
            end_pattern = parts[1]
            
            result_lines = []
            in_range = False
            
            for line in lines:
                if not in_range and start_pattern in line:
                    in_range = True
                
                if in_range:
                    result_lines.append(line)
                
                if in_range and end_pattern in line:
                    break
            
            return ''.join(result_lines).rstrip('\n')
        
        raise ValueError(f"Unsupported sed pattern: {pattern}")
    
    def _combine_multi_sources(self, config: Dict[str, Any]) -> str:
        """Combine multiple data sources."""
        sources = config.get("sources", [])
        if not sources:
            return "[NO_SOURCES_SPECIFIED]"
        
        # Load the common sources configuration
        try:
            # Use ConfigLoader to load data sources
            config_loader = ConfigLoader()
            data_sources_config = config_loader.load_data_sources()
            combined_content = []
            
            for source_id in sources:
                # Find the source config by ID
                source_config = None
                for src in data_sources_config.get("data_sources", []):
                    if src["id"] == source_id:
                        source_config = src
                        break
                
                if source_config:
                    content = self.process_data_source(source_config)
                    combined_content.append(f"=== {source_id} ===\n{content}\n")
                else:
                    combined_content.append(f"=== {source_id} ===\n[SOURCE_NOT_FOUND]\n")
            
            return "\n".join(combined_content)
        except Exception as e:
            return f"[ERROR_COMBINING_SOURCES: {str(e)}]"

class PromptBuilder:
    """Build prompts from templates with data source substitution."""
    
    def __init__(self, data_processor: DataSourceProcessor):
        self.data_processor = data_processor
        self.config_loader = ConfigLoader()
    
    def build_prompt(self, template: str, data_sources: List[Dict[str, Any]]) -> str:
        """Build a prompt from template with data source substitution."""
        prompt = template
        
        # Load common data sources config
        try:
            common_sources_config = self.config_loader.load_data_sources()
            common_sources = common_sources_config.get("data_sources", [])
        except Exception as e:
            print(f"Warning: Could not load common data sources: {e}")
            common_sources = []
        
        # Process each data source and substitute in template
        for source_ref in data_sources:
            # Handle both string IDs and dict formats
            if isinstance(source_ref, str):
                source_id = source_ref
                source_config = None
            else:
                source_id = source_ref["id"]
                # For dict format, use as potential inline definition
                source_config = source_ref
            
            # Find the full source config by ID - check common sources first
            if not source_config or source_id != source_config.get("id"):
                for src in common_sources:
                    if src["id"] == source_id:
                        source_config = src
                        break
            
            # If not found in common sources and no inline definition, create placeholder
            if not source_config:
                content = f"[DATA_SOURCE_NOT_FOUND: {source_id}]"
            else:
                # Process the source (from common sources or inline)
                content = self.data_processor.process_data_source(source_config)
            
            # Replace template variables like {data_sources.source_id}
            template_var = f"{{data_sources.{source_id}}}"
            prompt = prompt.replace(template_var, content)
        
        return prompt

def main():
    """CLI interface for configuration system."""
    if len(sys.argv) < 2:
        print("Usage: python config-loader.py <command> [args...]")
        print("Commands:")
        print("  list-categories       - List available test categories")
        print("  load-category <id>    - Load and validate a category config")
        print("  build-prompt <cat> <test_id> - Build prompt for specific test")
        sys.exit(1)
    
    command = sys.argv[1]
    loader = ConfigLoader()
    
    try:
        if command == "list-categories":
            categories = loader.get_available_categories()
            print("Available categories:")
            for cat in categories:
                print(f"  - {cat}")
        
        elif command == "load-category":
            if len(sys.argv) < 3:
                print("Error: Category ID required")
                sys.exit(1)
            
            category_id = sys.argv[2]
            config = loader.load_test_category(category_id)
            print(json.dumps(config, indent=2))
        
        elif command == "build-prompt":
            if len(sys.argv) < 4:
                print("Error: Category ID and test ID required")
                sys.exit(1)
            
            category_id = sys.argv[2]
            test_id = sys.argv[3]
            
            config = loader.load_test_category(category_id)
            
            # Find the specific test
            test_config = None
            for test in config["tests"]:
                if test["id"] == test_id:
                    test_config = test
                    break
            
            if not test_config:
                print(f"Error: Test {test_id} not found in category {category_id}")
                sys.exit(1)
            
            # Build the prompt
            data_processor = DataSourceProcessor()
            prompt_builder = PromptBuilder(data_processor)
            
            data_sources = test_config.get("data_sources", [])
            prompt = prompt_builder.build_prompt(test_config["prompt_template"], data_sources)
            
            print(prompt)
        
        else:
            print(f"Unknown command: {command}")
            sys.exit(1)
    
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
