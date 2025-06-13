#!/usr/bin/env python3
"""
Configuration validation tool for the new architecture.
Validates all YAML configurations and tests data source processing.
"""

import sys
import os
from pathlib import Path

# Add scripts directory to path for imports
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir))

from config_loader import ConfigLoader, DataSourceProcessor, PromptBuilder

def validate_all_configurations():
    """Validate all configurations and test data source processing."""
    
    loader = ConfigLoader()
    data_processor = DataSourceProcessor()
    prompt_builder = PromptBuilder(data_processor)
    
    print("🔍 Configuration Validation Report")
    print("=" * 50)
    
    # Test category discovery
    categories = loader.get_available_categories()
    print(f"📂 Found {len(categories)} test categories: {', '.join(categories)}")
    
    if not categories:
        print("❌ ERROR: No test categories found!")
        return False
    
    success = True
    
    # Validate each category
    for category_id in categories:
        print(f"\n🧪 Validating category: {category_id}")
        
        try:
            # Load category configuration
            config = loader.load_test_category(category_id)
            print(f"  ✅ Configuration loaded successfully")
            print(f"  📋 Category: {config['category']['name']}")
            print(f"  🎯 Tests: {len(config['tests'])}")
            
            # Validate each test in the category
            for test in config['tests']:
                test_id = test['id']
                print(f"    🔬 Validating test {test_id}: {test['title']}")
                
                # Check required fields
                required_fields = ['id', 'title', 'timeout', 'prompt_template']
                for field in required_fields:
                    if field not in test:
                        print(f"      ❌ Missing required field: {field}")
                        success = False
                        continue
                
                # Test data source processing if present
                if 'data_sources' in test:
                    # Load common sources config (like PromptBuilder does)
                    try:
                        common_sources_config = loader.load_data_sources()
                        common_sources = common_sources_config.get("data_sources", [])
                    except Exception as e:
                        print(f"      ⚠️  Could not load common sources: {e}")
                        common_sources = []
                    
                    for ds in test['data_sources']:
                        # Handle both string IDs and dict formats
                        if isinstance(ds, str):
                            source_id = ds
                        else:
                            source_id = ds['id']
                        
                        # Find the full source config by ID (like PromptBuilder does)
                        source_config = None
                        for src in common_sources:
                            if src["id"] == source_id:
                                source_config = src
                                break
                        
                        if source_config:
                            try:
                                content = data_processor.process_data_source(source_config)
                                if content:
                                    print(f"      ✅ Data source '{source_id}': {len(content)} chars")
                                else:
                                    print(f"      ⚠️  Data source '{source_id}': empty content")
                            except Exception as e:
                                print(f"      ❌ Data source '{source_id}' failed: {e}")
                                success = False
                        else:
                            print(f"      ❌ Data source '{source_id}' not found in common sources")
                            success = False
                
                # Test prompt building
                try:
                    data_sources = test.get('data_sources', [])
                    prompt = prompt_builder.build_prompt(test['prompt_template'], data_sources)
                    if prompt:
                        print(f"      ✅ Prompt built: {len(prompt)} chars")
                    else:
                        print(f"      ⚠️  Prompt is empty")
                except Exception as e:
                    print(f"      ❌ Prompt building failed: {e}")
                    success = False
                    
        except Exception as e:
            print(f"  ❌ Failed to validate category {category_id}: {e}")
            success = False
    
    print(f"\n{'🎉 All validations passed!' if success else '❌ Some validations failed!'}")
    return success

def test_specific_prompt(category_id: str, test_id: str):
    """Test building a specific prompt."""
    
    loader = ConfigLoader()
    data_processor = DataSourceProcessor()
    prompt_builder = PromptBuilder(data_processor)
    
    print(f"🔬 Testing prompt for {category_id}/{test_id}")
    print("=" * 50)
    
    try:
        config = loader.load_test_category(category_id)
        
        # Find the test
        test_config = None
        for test in config['tests']:
            if test['id'] == test_id:
                test_config = test
                break
        
        if not test_config:
            print(f"❌ Test {test_id} not found in category {category_id}")
            return False
        
        print(f"📋 Test: {test_config['title']}")
        print(f"⏱️  Timeout: {test_config['timeout']}s")
        
        # Process data sources
        data_sources = test_config.get('data_sources', [])
        if data_sources:
            print(f"📊 Data sources: {len(data_sources)}")
            for ds in data_sources:
                content = data_processor.process_data_source(ds)
                print(f"  - {ds['id']}: {len(content)} chars")
        
        # Build prompt
        prompt = prompt_builder.build_prompt(test_config['prompt_template'], data_sources)
        
        print(f"\n📝 Generated Prompt ({len(prompt)} chars):")
        print("-" * 50)
        print(prompt)
        print("-" * 50)
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    if len(sys.argv) == 1:
        # Run full validation
        success = validate_all_configurations()
        sys.exit(0 if success else 1)
    
    elif len(sys.argv) == 3:
        # Test specific prompt
        category_id = sys.argv[1]
        test_id = sys.argv[2]
        success = test_specific_prompt(category_id, test_id)
        sys.exit(0 if success else 1)
    
    else:
        print("Usage:")
        print("  python validate_config.py                    # Validate all configurations")
        print("  python validate_config.py <category> <test>  # Test specific prompt")
        print("")
        print("Examples:")
        print("  python validate_config.py")
        print("  python validate_config.py coding ct02")
        sys.exit(1)

if __name__ == "__main__":
    main()
