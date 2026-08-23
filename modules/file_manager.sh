#!/usr/bin/env bash

fm_list_directory() {
    local dir_path

    read -p "Enter directory path: " dir_path

    if [ -d "$dir_path" ]; then
        ls -la "$dir_path"
    else
        echo "Error: '$dir_path' is not a valid directory."
    fi
}

fm_create_directory() {
    local dir_path

    read -p "Enter directory path to create: " dir_path

    if [ -z "$dir_path" ]; then
        echo "Error: Directory path cannot be empty."
        return 1
    fi

    if [ -d "$dir_path" ]; then
        echo "Directory already exists: $dir_path"
        return 0
    fi

    mkdir -p "$dir_path"

    echo "Directory created: $dir_path"
}

fm_create_file() {
    local file_path
    local parent_dir

    read -p "Enter file path to create: " file_path

    if [ -z "$file_path" ]; then
        echo "Error: File path cannot be empty."
        return 1
    fi

    parent_dir=$(dirname "$file_path")

    if [ ! -d "$parent_dir" ]; then
        echo "Error: Parent directory '$parent_dir' does not exist."
        return 1
    fi

    if [ -e "$file_path" ]; then
        echo "Error: '$file_path' already exists."
        return 1
    fi

    touch "$file_path"

    echo "File created: $file_path"
}

fm_copy_file() {
    local source
    local destination

    read -p "Enter source file: " source
    read -p "Enter destination path: " destination

    if [ -z "$source" ]; then
        echo "Error: Source path cannot be empty."
        return 1
    fi

    if [ ! -f "$source" ]; then
        echo "Error: Source file '$source' does not exist."
        return 1
    fi

    if [ -z "$destination" ]; then
        echo "Error: Destination path cannot be empty."
        return 1
    fi

    if [ -d "$destination" ]; then
        cp "$source" "$destination"
    else
        local destination_dir
        destination_dir=$(dirname "$destination")

        if [ ! -d "$destination_dir" ]; then
            echo "Error: Destination directory '$destination_dir' does not exist."
            return 1
        fi

        cp "$source" "$destination"
    fi

    echo "File copied successfully."
}

fm_move_file() {
    echo "Move file"
}

fm_delete_file() {
    echo "Delete file"
}

fm_find_file() {
    echo "Find file"
}

fm_file_info() {
    echo "File information"
}

file_manager_menu() {
    while true; do

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

        read -p "Enter your choice: " choice

        case "$choice" in
            1) fm_list_directory;;

            2) fm_create_directory;;

            3) fm_create_file;;

            4)fm_copy_file;;

            5)fm_move_file;;

            6)fm_delete_file;;

            7)fm_find_file;;

            8)fm_file_info;;

            0)return;;

            *)echo "Invalid option.";;
        esac

        echo
        read -p "Press Enter to continue..." _
        clear

    done
}


# Only start the menu when this script is executed directly.
# If linux-admin.sh sources this file, only the functions are loaded.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    file_manager_menu
fi