# filepath: test-data/complex-app/utils.py
import json
import os
import sys

# Utility functions for the Task Manager.
# This module handles data persistence (simple JSON file for now).
# Opportunities for refactoring by an LLM:
# - More robust error handling for file I/O.
# - Support for different data formats (e.g., CSV, SQLite).
# - Configuration management for data file path.

DATA_FILE = "tasks.json" # Default data file name, could be configurable

def load_tasks_from_json(filepath=DATA_FILE):
    """Loads tasks from a JSON file."""
    if not os.path.exists(filepath):
        return [] # Return empty list if file doesn't exist
    try:
        with open(filepath, 'r') as f:
            # Handle empty or malformed JSON file
            content = f.read()
            if not content:
                return []
            data = json.loads(content)
            return data
    except (IOError, json.JSONDecodeError) as e:
        # LLM might suggest more specific error handling or logging
        print(f"Error loading tasks from {filepath}: {e}", file=sys.stderr)
        return [] # Or raise an exception

def save_tasks_to_json(tasks_data, filepath=DATA_FILE):
    """Saves tasks to a JSON file."""
    try:
        with open(filepath, 'w') as f:
            json.dump(tasks_data, f, indent=4)
    except IOError as e:
        # LLM might suggest more specific error handling or logging
        print(f"Error saving tasks to {filepath}: {e}", file=sys.stderr)
        # Or raise an exception

# Example of a utility an LLM might add:
# def validate_task_description(description):
#     if len(description) < 3:
#         return False, "Description too short."
#     if len(description) > 200:
#         return False, "Description too long."
#     return True, ""

# Another potential addition: Configuration management
# def get_data_file_path():
#     config_path = os.getenv("TASK_MANAGER_CONFIG", "~/.task_manager_config.json")
#     # Load config, find data file path, etc.
#     return DATA_FILE # Fallback to default
