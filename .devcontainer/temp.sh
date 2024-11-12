#!/bin/bash
# =============================================================================
# Script Name: setup_environment.sh
# Description: 
#   - Updates package list.
#   - Installs Git if it's not already installed.
#   - Converts Git remote URLs from HTTPS to SSH for GitHub and GitLab.
#   - Changes to the parent directory and executes install-deps.sh.
# Usage: sudo ./setup_environment.sh
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# Determine the directory where the script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define log file relative to the script directory
log_file="$script_dir/setup_environment.log"

# Redirect stdout and stderr to the log file while also displaying them
exec > >(tee -a "$log_file") 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting script execution..."

# Function Definitions

check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Error: Please run this script as root (use sudo)." >&2
        exit 1
    fi
}

check_apt_get() {
    if ! command -v apt-get &> /dev/null; then
        echo "Error: apt-get not found. This script requires a Debian-based system." >&2
        exit 1
    fi
}

install_git_if_missing() {
    if ! command -v git &> /dev/null; then
        echo "Git not found. Installing Git..."
        apt-get update -y
        apt-get install -y git
        echo "Git installation completed."
    else
        echo "Git is already installed."
    fi
}

install_required_deps() {
    echo "Installing required dependencies..."
    apt-get update -y
    apt-get install -y libnuma-dev
    echo "Dependencies installation completed."
}

update_git_remote_to_ssh() {
    local remote_url="$1"
    local ssh_url=""

    # Regular expressions for GitHub and GitLab HTTPS URLs
    local github_regex="^https://github\.com/([^/]+)/([^/]+)(\.git)?$"
    local gitlab_regex="^https://gitlab\.com/([^/]+)/([^/]+)(\.git)?$"

    if [[ "$remote_url" =~ $github_regex ]]; then
        local username="${BASH_REMATCH[1]}"
        local repository="${BASH_REMATCH[2]}"
        ssh_url="git@github.com:$username/$repository.git"
    elif [[ "$remote_url" =~ $gitlab_regex ]]; then
        local username="${BASH_REMATCH[1]}"
        local repository="${BASH_REMATCH[2]}"
        ssh_url="git@gitlab.com:$username/$repository.git"
    fi

    echo "$ssh_url"
}

update_git_remotes() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        local remotes
        remotes=$(git remote)
        if [[ -z "$remotes" ]]; then
            echo "No git remotes found to update."
            return
        fi

        for remote in $remotes; do
            local current_url
            current_url=$(git remote get-url "$remote")
            local ssh_url
            ssh_url=$(update_git_remote_to_ssh "$current_url")

            if [[ -n "$ssh_url" ]]; then
                git remote set-url "$remote" "$ssh_url"
                echo "Updated remote '$remote' to use SSH: $ssh_url"
            else
                echo "Remote '$remote' is already using SSH or is in an unsupported format: $current_url"
            fi
        done
    else
        echo "Error: The current directory is not a Git repository." >&2
        exit 1
    fi
}

change_to_parent_directory() {
    local parent_dir
    parent_dir="$(dirname "$script_dir")"
    echo "Changing directory to parent directory: $parent_dir"
    cd "$parent_dir" || { echo "Error: Failed to change directory to $parent_dir." >&2; exit 1; }
}

run_install_deps() {
    local install_deps_path="./install-deps.sh"
    if [[ -f "$install_deps_path" ]]; then
        echo "Preparing to run install-deps.sh..."

        if [[ ! -x "$install_deps_path" ]]; then
            chmod +x "$install_deps_path" || { echo "Error: Failed to make install-deps.sh executable." >&2; exit 1; }
            echo "Made install-deps.sh executable."
        fi

        echo "Executing install-deps.sh..."
        "$install_deps_path"
        echo "install-deps.sh executed successfully."
        cd ..
    else
        echo "Error: install-deps.sh not found in the parent directory." >&2
        exit 1
    fi
}

# Main Execution Flow

check_root
check_apt_get
install_git_if_missing
install_required_deps
# update_git_remotes
change_to_parent_directory
run_install_deps

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Script completed successfully."
