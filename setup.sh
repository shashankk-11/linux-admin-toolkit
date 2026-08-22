#!/usr/bin/env bash

# ============================================================
# Linux Admin Toolkit - Project Setup Script
# ============================================================
#
# Purpose:
#   Creates the initial project structure inside the
#   CURRENT Git repository.
#
# IMPORTANT:
#   Run this script from the root of your Git repository.
#
# This script creates:
#
#   modules/       -> Individual Bash modules
#   data/logs/     -> Log files used by the project
#   backups/       -> Backup files
#   reports/       -> Generated reports
#   config/        -> Configuration files
#   linux-admin.sh -> Main application entry point
#
# It also:
#   - Creates placeholder module files
#   - Makes Bash scripts executable
#   - Displays the resulting project structure
#
# Usage:
#
#   chmod +x setup.sh
#   ./setup.sh
#
# ============================================================


# Exit immediately if any command fails.
set -e


# ------------------------------------------------------------
# Verify that we are inside a Git repository
# ------------------------------------------------------------

if ! git rev-parse --show-toplevel > /dev/null 2>&1; then
    echo "ERROR: This script must be run from inside a Git repository."
    exit 1
fi


# Get the root directory of the Git repository.
REPO_ROOT=$(git rev-parse --show-toplevel)


# Move to the repository root.
cd "$REPO_ROOT"


echo "Setting up Linux Admin Toolkit..."
echo "Repository: $REPO_ROOT"
echo


# ------------------------------------------------------------
# Create project directories
# ------------------------------------------------------------

mkdir -p \
    modules \
    data/logs \
    backups \
    reports \
    config


# ------------------------------------------------------------
# Create main entry script
# ------------------------------------------------------------

touch linux-admin.sh


# ------------------------------------------------------------
# Create module scripts
# ------------------------------------------------------------
#
# Each module will eventually implement one feature:
#
# health.sh          -> Server health checker
# file_manager.sh    -> File manager
# log_analyzer.sh    -> Log analyzer
# backup.sh          -> Backup manager
# disk.sh            -> Disk usage checker
# process.sh         -> Process monitor
# system_info.sh     -> System information
# password.sh        -> Password generator
# calculator.sh      -> Calculator


touch modules/{health,file_manager,log_analyzer,backup,disk,process,system_info,password,calculator}.sh


# ------------------------------------------------------------
# Make Bash scripts executable
# ------------------------------------------------------------

chmod +x linux-admin.sh
chmod +x modules/*.sh

# ------------------------------------------------------------
# Display result
# ------------------------------------------------------------

echo "========================================"
echo " Linux Admin Toolkit Setup Complete"
echo "========================================"
echo

echo "Repository root:"
pwd

echo
echo "Project structure:"
echo

find \
    linux-admin.sh \
    modules \
    data \
    backups \
    reports \
    config \
    -print | sort

echo
echo "Setup completed successfully."
echo
echo "Next step:"
echo "  ./linux-admin.sh"