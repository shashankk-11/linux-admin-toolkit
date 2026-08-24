     #!/usr/bin/env bash

# ============================================================
# Linux Admin Toolkit - Backup Manager
# ============================================================
#
# Purpose:
#   Create, list, restore, delete, and clean up compressed
#   backups using tar, gzip, date, find, and mkdir.deleted
#
# Backup location:
#   backups/
#
# Features:
#   1. Create backup
#   2. List backups
#   3. Restore backup
#   4. Delete backup
#   5. Cleanup old backups
#   0. Back
#
# ============================================================


# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

BACKUP_DIR="backups"


# ------------------------------------------------------------
# Result helpers
# ------------------------------------------------------------

backup_success() {
    echo
    echo "[SUCCESS] $1"
}

backup_failed() {
    echo
    echo "[FAILED] $1"
}


# ------------------------------------------------------------
# 1. Create backup
# ------------------------------------------------------------

backup_create() {

    local source_path
    local source_parent
    local source_name
    local timestamp
    local backup_name
    local backup_path

    read -p "Enter file or directory to back up: " source_path

    if [ -z "$source_path" ]; then
        backup_failed "Source path cannot be empty."
        return 1
    fi

    if [ ! -e "$source_path" ]; then
        backup_failed "Source '$source_path' does not exist."
        return 1
    fi

    # Convert the path to an absolute path.
    source_path=$(realpath "$source_path")

    if [ ! -e "$source_path" ]; then
        backup_failed "Unable to resolve source path."
        return 1
    fi

    source_parent=$(dirname "$source_path")
    source_name=$(basename "$source_path")

    timestamp=$(date +"%Y-%m-%d_%H%M%S")

    backup_name="${source_name}_${timestamp}.tar.gz"
    backup_path="${BACKUP_DIR}/${backup_name}"

    # Make sure backup directory exists.
    if ! mkdir -p "$BACKUP_DIR"; then
        backup_failed "Unable to create backup directory '$BACKUP_DIR'."
        return 1
    fi

    echo
    echo "Source      : $source_path"
    echo "Backup file : $backup_path"
    echo

    # -C changes to the parent directory first.
    #
    # Example:
    #
    # /home/kulka/project
    #
    # becomes:
    #
    # cd /home/kulka
    # tar ... project
    #
    # Therefore the archive contains:
    #
    # project/
    #
    # instead of:
    #
    # /home/kulka/project/
    #
    if tar -czf "$backup_path" -C "$source_parent" "$source_name"; then

        backup_success "Backup created successfully."
        echo "Backup: $backup_path"

        return 0

    else

        backup_failed "Failed to create backup."

        # Remove incomplete archive if tar failed.
        rm -f "$backup_path"

        return 1

    fi
}


# ------------------------------------------------------------
# 2. List backups
# ------------------------------------------------------------

backup_list() {

    local backup_count

    if [ ! -d "$BACKUP_DIR" ]; then
        backup_failed "Backup directory '$BACKUP_DIR' does not exist."
        return 1
    fi

    backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" | wc -l)

    if [ "$backup_count" -eq 0 ]; then
        echo
        echo "No backups found in '$BACKUP_DIR'."
        backup_failed "Backup list is empty."
        return 1
    fi

    echo
    echo "========================================"
    echo "             AVAILABLE BACKUPS"
    echo "========================================"
    echo

    ls -lh "$BACKUP_DIR"/*.tar.gz

    echo
    backup_success "$backup_count backup(s) found."

    return 0
}


# ------------------------------------------------------------
# 3. Restore backup
# ------------------------------------------------------------

backup_restore() {

    local backup_name
    local backup_path
    local destination

    if [ ! -d "$BACKUP_DIR" ]; then
        backup_failed "Backup directory '$BACKUP_DIR' does not exist."
        return 1
    fi

    if ! find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" | grep -q .; then
        backup_failed "No backups available to restore."
        return 1
    fi

    echo
    echo "Available backups:"
    echo

    find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" -printf "%f\n"

    echo

    read -p "Enter backup filename to restore: " backup_name

    if [ -z "$backup_name" ]; then
        backup_failed "Backup filename cannot be empty."
        return 1
    fi

    backup_path="${BACKUP_DIR}/${backup_name}"

    if [ ! -f "$backup_path" ]; then
        backup_failed "Backup '$backup_path' does not exist."
        return 1
    fi

    read -p "Enter destination directory: " destination

    if [ -z "$destination" ]; then
        backup_failed "Destination directory cannot be empty."
        return 1
    fi

    if ! mkdir -p "$destination"; then
        backup_failed "Unable to create destination '$destination'."
        return 1
    fi

    echo
    echo "Backup      : $backup_path"
    echo "Destination : $destination"
    echo

    if tar -xzf "$backup_path" -C "$destination"; then

        backup_success "Backup restored successfully."
        echo "Restored to: $destination"

        return 0

    else

        backup_failed "Failed to restore backup."
        return 1

    fi
}


# ------------------------------------------------------------
# 4. Delete backup
# ------------------------------------------------------------

backup_delete() {

    local backup_name
    local backup_path
    local confirmation

    if [ ! -d "$BACKUP_DIR" ]; then
        backup_failed "Backup directory '$BACKUP_DIR' does not exist."
        return 1
    fi

    if ! find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" | grep -q .; then
        backup_failed "No backups available to delete."
        return 1
    fi

    echo
    echo "Available backups:"
    echo

    find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" -printf "%f\n"

    echo

    read -p "Enter backup filename to delete: " backup_name

    if [ -z "$backup_name" ]; then
        backup_failed "Backup filename cannot be empty."
        return 1
    fi

    backup_path="${BACKUP_DIR}/${backup_name}"

    if [ ! -f "$backup_path" ]; then
        backup_failed "Backup '$backup_path' does not exist."
        return 1
    fi

    echo
    echo "WARNING: This will permanently delete:"
    echo "$backup_path"
    echo

    read -p "Are you sure? (y/n): " confirmation

    case "$confirmation" in

        y|Y)
            ;;

        *)
            echo "Delete operation cancelled."
            return 0
            ;;

    esac

    if rm "$backup_path"; then

        backup_success "Backup deleted successfully."
        echo "Deleted: $backup_path"

        return 0

    else

        backup_failed "Unable to delete backup."
        return 1

    fi
}


# ------------------------------------------------------------
# 5. Cleanup old backups
# ------------------------------------------------------------

backup_cleanup() {

    local days
    local old_backups
    local confirmation
    local backup_file
    local deleted_count=0

    if [ ! -d "$BACKUP_DIR" ]; then
        backup_failed "Backup directory '$BACKUP_DIR' does not exist."
        return 1
    fi

    read -p "Delete backups older than how many days? " days

    if [ -z "$days" ]; then
        backup_failed "Number of days cannot be empty."
        return 1
    fi

    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        backup_failed "Please enter a valid positive number."
        return 1
    fi

    if [ "$days" -eq 0 ]; then
        backup_failed "Number of days must be greater than zero."
        return 1
    fi

    # Find backups older than the specified number of days.
    old_backups=$(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            -name "*.tar.gz" \
            -mtime +"$days" \
            -print
    )

    if [ -z "$old_backups" ]; then
        echo
        echo "No backups older than $days day(s) were found."
        backup_failed "Nothing to clean up."
        return 1
    fi

    echo
    echo "========================================"
    echo "          BACKUPS TO DELETE"
    echo "========================================"
    echo
    echo "$old_backups"
    echo

    read -p "Delete these backups? (y/n): " confirmation

    case "$confirmation" in

        y|Y)
            ;;

        *)
            echo "Cleanup operation cancelled."
            return 0
            ;;

    esac

    # Safely process find results.
    find "$BACKUP_DIR" \
        -maxdepth 1 \
        -type f \
        -name "*.tar.gz" \
        -mtime +"$days" \
        -print0 |
    while IFS= read -r -d '' backup_file; do
    if rm "$backup_file"; then
        echo "Deleted: $backup_file"
        ((deleted_count++))
    else
        echo "Failed to delete: $backup_file"
    fi
    done < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" -mtime +"$days" -print0)

    # Re-count to determine whether cleanup actually succeeded.
    if find "$BACKUP_DIR" \
        -maxdepth 1 \
        -type f \
        -name "*.tar.gz" \
        -mtime +"$days" |
        grep -q .
    then
        backup_failed "Some old backups could not be deleted."
        return 1
    fi

    backup_success "Old backup cleanup completed."

    return 0
}


# ------------------------------------------------------------
# Backup Manager Menu
# ------------------------------------------------------------

backup_menu() {

    while true; do

        echo
        echo "========================================"
        echo "            BACKUP MANAGER"
        echo "========================================"
        echo
        echo "Backup directory: $BACKUP_DIR"
        echo
        echo "1. Create backup"
        echo "2. List backups"
        echo "3. Restore backup"
        echo "4. Delete backup"
        echo "5. Cleanup old backups"
        echo "0. Back"
        echo
        echo "========================================"

        read -p "Enter your choice: " choice

        case "$choice" in

            1)
                backup_create
                ;;

            2)
                backup_list
                ;;

            3)
                backup_restore
                ;;

            4)
                backup_delete
                ;;

            5)
                backup_cleanup
                ;;

            0)
                echo "Returning to main menu..."
                return 0
                ;;

            *)
                backup_failed "Invalid option. Please choose 0-5."
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
# If executed directly:
#
#   ./modules/backup.sh
#
# the Backup Manager menu starts.
#
# If sourced:
#
#   source modules/backup.sh
#
# only the functions are loaded.
#
# ------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    backup_menu
fi 