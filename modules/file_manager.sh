#!/usr/bin/env bash

# ============================================================
# Linux Admin Toolkit - File Manager
# ============================================================
#
# Purpose:
#   Provides basic file and directory management operations
#   through an interactive Bash menu.
#
# Features:
#   1. List directory
#   2. Create directory
#   3. Create file
#   4. Copy file
#   5. Move file
#   6. Delete file
#   7. Find file
#   8. Show file information
#
# This module can:
#   - Be executed directly
#   - Be sourced by linux-admin.sh
#
# ============================================================


# ------------------------------------------------------------
# Print task result
# ------------------------------------------------------------

fm_success() {
    echo
    echo "[SUCCESS] $1"
}

fm_failed() {
    echo
    echo "[FAILED] $1"
}


# ------------------------------------------------------------
# 1. List directory
# ------------------------------------------------------------

fm_list_directory() {
    local dir_path

    read -p "Enter directory path: " dir_path

    if [ -z "$dir_path" ]; then
        fm_failed "Directory path cannot be empty."
        return 1
    fi

    if [ ! -d "$dir_path" ]; then
        fm_failed "Directory '$dir_path' does not exist."
        return 1
    fi

    if ls -la "$dir_path"; then
        fm_success "Directory listed successfully."
        return 0
    else
        fm_failed "Unable to list directory '$dir_path'."
        return 1
    fi
}


# ------------------------------------------------------------
# 2. Create directory
# ------------------------------------------------------------

fm_create_directory() {
    local dir_path

    read -p "Enter directory path to create: " dir_path

    if [ -z "$dir_path" ]; then
        fm_failed "Directory path cannot be empty."
        return 1
    fi

    if [ -d "$dir_path" ]; then
        fm_failed "Directory '$dir_path' already exists."
        return 1
    fi

    if mkdir -p "$dir_path"; then
        fm_success "Directory created: $dir_path"
        return 0
    else
        fm_failed "Unable to create directory '$dir_path'."
        return 1
    fi
}


# ------------------------------------------------------------
# 3. Create file
# ------------------------------------------------------------

fm_create_file() {
    local file_path
    local parent_dir

    read -p "Enter file path to create: " file_path

    if [ -z "$file_path" ]; then
        fm_failed "File path cannot be empty."
        return 1
    fi

    if [ -e "$file_path" ]; then
        fm_failed "'$file_path' already exists."
        return 1
    fi

    parent_dir=$(dirname "$file_path")

    if [ ! -d "$parent_dir" ]; then
        fm_failed "Parent directory '$parent_dir' does not exist."
        return 1
    fi

    if touch "$file_path"; then
        fm_success "File created: $file_path"
        return 0
    else
        fm_failed "Unable to create file '$file_path'."
        return 1
    fi
}


# ------------------------------------------------------------
# 4. Copy file
# ------------------------------------------------------------

fm_copy_file() {
    local source destination destination_dir target_path

    read -p "Enter source file: " source
    read -p "Enter destination path: " destination

    if [ -z "$source" ]; then
        fm_failed "Source path cannot be empty."
        return 1
    fi

    if [ ! -f "$source" ]; then
        fm_failed "Source file '$source' does not exist."
        return 1
    fi

    if [ -z "$destination" ]; then
        fm_failed "Destination path cannot be empty."
        return 1
    fi

    # Resolve what the final path will actually be, whether the
    # destination is a directory (file goes inside it) or a new filename.
    if [ -d "$destination" ]; then
        target_path="$destination/$(basename "$source")"
    else
        target_path="$destination"
        destination_dir=$(dirname "$destination")
        if [ ! -d "$destination_dir" ]; then
            fm_failed "Destination directory '$destination_dir' does not exist."
            return 1
        fi
    fi

    if [ -e "$target_path" ]; then
        fm_failed "'$target_path' already exists. Copy cancelled to avoid overwriting."
        return 1
    fi

    if cp "$source" "$destination"; then
        fm_success "File copied: $source -> $target_path"
        return 0
    else
        fm_failed "Unable to copy '$source' to '$target_path'."
        return 1
    fi
}


# ------------------------------------------------------------
# 5. Move file
# ------------------------------------------------------------

fm_move_file() {
    local source destination destination_dir target_path

    read -p "Enter source file: " source
    read -p "Enter destination path: " destination

    if [ -z "$source" ]; then
        fm_failed "Source path cannot be empty."
        return 1
    fi

    if [ ! -f "$source" ]; then
        fm_failed "Source file '$source' does not exist."
        return 1
    fi

    if [ -z "$destination" ]; then
        fm_failed "Destination path cannot be empty."
        return 1
    fi

    # Resolve what the final path will actually be, whether the
    # destination is a directory (file goes inside it) or a new filename.
    if [ -d "$destination" ]; then
        target_path="$destination/$(basename "$source")"
    else
        target_path="$destination"
        destination_dir=$(dirname "$destination")
        if [ ! -d "$destination_dir" ]; then
            fm_failed "Destination directory '$destination_dir' does not exist."
            return 1
        fi
    fi

    if [ -e "$target_path" ]; then
        fm_failed "'$target_path' already exists. Move cancelled to avoid overwriting."
        return 1
    fi

    if mv "$source" "$destination"; then
        fm_success "File moved: $source -> $target_path"
        return 0
    else
        fm_failed "Unable to move '$source' to '$target_path'."
        return 1
    fi
}

# ------------------------------------------------------------
# 6. Delete file
# ------------------------------------------------------------

fm_delete_file() {
    local file_path
    local confirmation

    read -p "Enter file path to delete: " file_path

    if [ -z "$file_path" ]; then
        fm_failed "File path cannot be empty."
        return 1
    fi

    if [ ! -f "$file_path" ]; then
        fm_failed "File '$file_path' does not exist."
        return 1
    fi

    echo
    echo "WARNING: This operation will permanently delete:"
    echo "$file_path"

    read -p "Are you sure? (y/n): " confirmation

    case "$confirmation" in
        y|Y)
            ;;

        *)
            echo "Delete operation cancelled."
            return 0
            ;;
    esac

    if rm "$file_path"; then
        fm_success "File deleted: $file_path"
        return 0
    else
        fm_failed "Unable to delete '$file_path'."
        return 1
    fi
}


# ------------------------------------------------------------
# 7. Find file
# ------------------------------------------------------------

fm_find_file() {
    local search_path
    local file_name
    local results

    read -p "Enter directory to search: " search_path
    read -p "Enter file name or pattern: " file_name

    if [ -z "$search_path" ]; then
        fm_failed "Search directory cannot be empty."
        return 1
    fi

    if [ ! -d "$search_path" ]; then
        fm_failed "Search directory '$search_path' does not exist."
        return 1
    fi

    if [ -z "$file_name" ]; then
        fm_failed "File name cannot be empty."
        return 1
    fi

    results=$(find "$search_path" -type f -name "$file_name" 2>/dev/null)

    if [ -n "$results" ]; then
        echo
        echo "Files found:"
        echo "$results"
        fm_success "File search completed."
        return 0
    else
        echo
        echo "No files found."
        fm_failed "No matching files were found."
        return 1
    fi
}


# ------------------------------------------------------------
# 8. Show file information
# ------------------------------------------------------------

fm_file_info() {
    local file_path

    read -p "Enter file path: " file_path

    if [ -z "$file_path" ]; then
        fm_failed "File path cannot be empty."
        return 1
    fi

    if [ ! -e "$file_path" ]; then
        fm_failed "Path '$file_path' does not exist."
        return 1
    fi

    echo
    echo "========================================"
    echo "           FILE INFORMATION"
    echo "========================================"

    echo "Path        : $file_path"
    echo "Type        : $(file -b "$file_path")"
    echo "Size        : $(du -h "$file_path" | cut -f1)"
    echo "Permissions : $(stat -c '%A' "$file_path")"
    echo "Owner       : $(stat -c '%U' "$file_path")"
    echo "Group       : $(stat -c '%G' "$file_path")"
    echo "Modified    : $(stat -c '%y' "$file_path")"

    echo "========================================"

    fm_success "File information retrieved."
    return 0
}


# ------------------------------------------------------------
# File Manager Menu
# ------------------------------------------------------------

file_manager_menu() {

    while true; do

        echo
        echo "========================================"
        echo "             FILE MANAGER"
        echo "========================================"
        echo
        echo "1. List directory"
        echo "2. Create directory"
        echo "3. Create file"
        echo "4. Copy file"
        echo "5. Move file"
        echo "6. Delete file"
        echo "7. Find file"
        echo "8. Show file information"
        echo "0. Back"
        echo
        echo "========================================"

        read -p "Enter your choice: " choice

        case "$choice" in

            1)
                fm_list_directory
                ;;

            2)
                fm_create_directory
                ;;

            3)
                fm_create_file
                ;;

            4)
                fm_copy_file
                ;;

            5)
                fm_move_file
                ;;

            6)
                fm_delete_file
                ;;

            7)
                fm_find_file
                ;;

            8)
                fm_file_info
                ;;

            0)
                echo "Returning to main menu..."
                return 0
                ;;

            *)
                fm_failed "Invalid option. Please choose 0-8."
                ;;

        esac

        echo
        read -p "Press Enter to continue..." _
        clear

    done
}


# ------------------------------------------------------------
# Direct execution check
# ------------------------------------------------------------
#
# If this script is executed directly:
#
#   ./modules/file_manager.sh
#
# start the File Manager menu.
#
# If this script is sourced:
#
#   source modules/file_manager.sh
#
# only the functions are loaded.
#
# This allows linux-admin.sh to use this module later.
# ------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    file_manager_menu
fi