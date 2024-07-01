#!/usr/bin/env bash

# h-move-repo: A script to move repositories to the structure expected by 'h'.
#
# This script moves a repository to the ~/repos/github.com/<user>/<repo> structure.
# It checks the remote URL to make sure it is from GitHub. It also checks for the
# existence of the target directory and aborts if it already exists.
#
# Usage: h-move-repo <repo_path>

# Base directory where your repositories are stored
BASE_DIR="$HOME/repos"

# Function to check if remote origin uses GitHub URL format
is_github_url() {
  local repo_path=$1
  local remote_url
  remote_url=$(git -C "$repo_path" remote get-url origin)

  [[ $remote_url == git@github.com:* ]]
}

# Function to extract the GitHub username and repo name
extract_github_info() {
  local repo_path=$1
  local remote_url
  remote_url=$(git -C "$repo_path" remote get-url origin)

  # Strip 'git@github.com:' from the URL and then split on '/'
  remote_url=${remote_url#git@github.com:}
  IFS='/' read -ra ADDR <<<"$remote_url"
  local username=${ADDR[0]}
  local repo_name_with_git=${ADDR[1]}
  local repo_name="${repo_name_with_git%.git}"

  echo "$username" "$repo_name"
}

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <repo_path>"
  exit 1
fi

repo_path="$1"

if ! is_github_url "$repo_path"; then
  echo "The repo at $repo_path does not use a GitHub URL format."
  exit 1
fi

IFS=' ' read -r username repo_name <<<"$(extract_github_info "$repo_path")"
new_path="$BASE_DIR/github.com/$username/$repo_name"

# Check if target directory already exists
if [[ -d $new_path ]]; then
  echo "Error: Target directory '$new_path' already exists."
  exit 1
fi

echo "The repository at $repo_path will be moved to $new_path."

read -r -p "Are you sure you want to move the repository? (y/n): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
  mkdir -p "$(dirname "$new_path")"
  mv "$repo_path" "$new_path"
  echo "Repository moved to $new_path."
else
  echo "Move cancelled."
fi
