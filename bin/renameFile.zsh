#!/bin/zsh

# Function to rename a file in place
function renameFile() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Please provide the current filename and the new filename."
    return 1
  fi

  current_filename="$1"
  new_filename="$2"

  # Find the file using fd and store the path
  file_path=$(fd -e "$current_filename" . | head -n 1)

  if [ -z "$file_path" ]; then
    echo "File not found: $current_filename"
    return 1
  fi

  # Extract the directory path from the file path
  directory_path=$(dirname "$file_path")

  # Rename the file in place
  mv "$file_path" "$directory_path/$new_filename"

  echo "File renamed successfully:"
  echo "Old path: $file_path"
  echo "New path: $directory_path/$new_filename"
}
