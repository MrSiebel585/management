#!/bin/bash

# Path to the repository
REPO_PATH="/opt/omniscient"

# GitHub repository information
GIT_REMOTE="origin"
GIT_BRANCH="main"  # Change this if you use a different branch

# Log file (optional for debugging purposes)
LOG_FILE="/var/log/github_sync.log"

# Function to log messages
log_message() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

# Ensure the repository is set up correctly
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: $REPO_PATH is not a git repository."
    exit 1
fi

log_message "Starting to monitor directory: $REPO_PATH"

# Start monitoring for changes in the repository
while true; do
    # Use inotifywait to watch for file changes (modify as necessary for more events)
    inotifywait -r -e modify,create,delete,move "$REPO_PATH" > /dev/null 2>&1

    # If we detect a change, commit and push changes to GitHub
    log_message "Changes detected, syncing to GitHub..."

    # Change to the repository directory
    cd "$REPO_PATH" || { log_message "Failed to change directory to $REPO_PATH"; exit 1; }

    # Ensure the repository is up to date before committing
    git fetch "$GIT_REMOTE" "$GIT_BRANCH"

    # Add all changed files
    git add --all

    # Check if there are any changes to commit
    if ! git diff --cached --quiet; then
        # Commit changes with a timestamp
        git commit -m "Automated commit: $(date)"

        # Push to GitHub
        git push "$GIT_REMOTE" "$GIT_BRANCH" >> "$LOG_FILE" 2>&1

        log_message "Sync complete."
    else
        log_message "No changes to commit."
    fi
done

