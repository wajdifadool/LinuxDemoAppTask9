#!/bin/bash

# Check if the number of parameters is 2, 3, or 4
if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 <TaskID> <DevMessage> [Optional: Push] [Optional: RepoPath]"
  exit 1
fi

# Parameters
TASK_ID=$1
DEV_MESSAGE=$2
PUSH=$3
REPO_PATH=${4:-$(pwd)}

# Validate parameters
if [ -z "$TASK_ID" ] || [ -z "$DEV_MESSAGE" ]; then
  echo "Error: TaskID and DevMessage cannot be empty."
  exit 1
fi

# Move to the repository path
cd "$REPO_PATH" || { echo "Invalid repository path: $REPO_PATH"; exit 1; }

# Extract developer name and GitHub URL from CSV
CSV_FILE="commit_task.csv"
if [ ! -f "$CSV_FILE" ]; then
  echo "CSV file not found: $CSV_FILE"
  exit 1
fi

# Read Developer Name and GitHub URL from CSV based on TaskID
DEVELOPER_NAME=$(awk -F',' -v task_id="$TASK_ID" 'NR > 1 && $1 == task_id {print $4}' "$CSV_FILE")
GITHUB_URL=$(awk -F',' -v task_id="$TASK_ID" 'NR > 1 && $1 == task_id {print $5}' "$CSV_FILE")
DESC=$(awk -F',' -v task_id="$TASK_ID" 'NR > 1 && $1 == task_id {print $2}' "$CSV_FILE")

if [ -z "$DEVELOPER_NAME" ] || [ -z "$GITHUB_URL" ]; then
  echo "Error: Developer Name or GitHub URL missing for TaskID $TASK_ID in CSV."
  exit 1
fi

# Get the current branch name
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Create commit message format
CURRENT_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
COMMIT_MESSAGE="$TASK_ID - $CURRENT_DATE - $BRANCH_NAME - $DEVELOPER_NAME - $DESC - $DEV_MESSAGE"

# Perform Git Operations
git add .
git commit -m "$COMMIT_MESSAGE"

# Optional Push
if [ "$PUSH" == "true" ]; then
  git push origin "$BRANCH_NAME"
fi

# Print Confirmation
echo "Commit completed with message: $COMMIT_MESSAGE"
if [ "$PUSH" == "true" ]; then
  echo "Changes pushed to branch: $BRANCH_NAME"
else
  echo "Push skipped."
fi