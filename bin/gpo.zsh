#!/bin/zsh

# Function to commit, push, and create a new branch with the commit message
function gpo() {
  if [ -z "$1" ]; then
    echo "Please provide a commit message."
    return 1
  fi

  commit_message="$1"
  open_web=false

  # Check if the -w flag is provided
  if [ "$2" = "-w" ]; then
    open_web=true
  fi

  # Commit changes
  git commit -m "$commit_message"

  # Push changes to the current branch
  gp

  # Create a pull request
  prc "$commit_message"

  # Open the pull request in the web browser if the -w flag is provided
  if $open_web; then
    gh pr view --web
  fi
}
