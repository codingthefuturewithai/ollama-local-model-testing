# filepath: test-data/complex-app/main_app.py
import argparse
import sys
import logic  # Direct import instead of relative import
import utils  # Direct import instead of relative import

# Basic CLI for the Task Manager
# This module is intentionally simple and could be refactored for better structure
# and error handling by an LLM.

def main():
    parser = argparse.ArgumentParser(description="Simple Command-Line Task Manager")
    parser.add_argument("command", choices=["add", "list", "done", "pending"], help="Command to execute")
    parser.add_argument("argument", nargs="?", help="Argument for the command (e.g., task description or ID)")

    args = parser.parse_args()

    task_manager = logic.TaskManager(utils.DATA_FILE) # TaskManager now handles its own loading/saving via utils

    if args.command == "add":
        if not args.argument:
            print("Error: Task description cannot be empty for 'add' command.", file=sys.stderr)
            sys.exit(1)
        task = task_manager.add_task(args.argument)
        print(f"Added task: '{task.description}' with ID {task.id}")
    
    elif args.command == "list":
        print("Current Tasks:")
        tasks = task_manager.list_tasks()
        if not tasks:
            print("No tasks yet.")
        else:
            for task in tasks:
                status_char = "[x]" if task.status == "completed" else "[ ]"
                print(f"{status_char} {task.id}: {task.description}")

    elif args.command == "done":
        if not args.argument:
            print("Error: Task ID required for 'done' command.", file=sys.stderr)
            sys.exit(1)
        try:
            task_id_arg = args.argument
            # Attempt to convert to int if it looks like an int, otherwise treat as string (for UUIDs)
            try:
                task_id = int(task_id_arg)
            except ValueError:
                task_id = task_id_arg

            updated_task = task_manager.complete_task(task_id)
            if updated_task:
                print(f"Task {updated_task.id} marked as completed.")
            else:
                print(f"Error: Task with ID {task_id} not found.", file=sys.stderr)
        except ValueError: # This might be redundant if previous try-except for int conversion is robust
            print(f"Error: Invalid Task ID '{args.argument}'.", file=sys.stderr)
            sys.exit(1)
            
    elif args.command == "pending":
        print("Pending Tasks:")
        tasks = task_manager.list_tasks(status_filter="pending")
        if not tasks:
            print("No pending tasks.")
        else:
            for task in tasks:
                print(f"[ ] {task.id}: {task.description}")
    
if __name__ == "__main__":
    main()
