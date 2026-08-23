#!/usr/bin/env bash

# ============================================================
# Linux Admin Toolkit - Log Analyzer
# ============================================================
#
# Purpose:
#   Analyze a log file using common Linux text-processing
#   commands such as grep, sort, uniq, wc, head, tail,
#   cut, and awk.
#
# Features:
#   1. Show errors
#   2. Show warnings
#   3. Count errors
#   4. Search by keyword
#   5. Show common errors
#   6. Show recent errors
#
# The log file is selected once when entering the Log Analyzer.
#
# ============================================================


# ------------------------------------------------------------
# Global variable
# ------------------------------------------------------------
#
# This variable is intentionally not declared with "local"
# because all la_* functions need access to it.
#
log_path=""


# ------------------------------------------------------------
# Result helpers
# ------------------------------------------------------------

la_success() {
    echo
    echo "[SUCCESS] $1"
}

la_failed() {
    echo
    echo "[FAILED] $1"
}


# ------------------------------------------------------------
# Select and validate log file
# ------------------------------------------------------------

la_select_log_file() {

    while true; do

        read -p "Enter log file path: " log_path

        if [ -z "$log_path" ]; then
            la_failed "Log file path cannot be empty."
            continue
        fi

        if [ ! -f "$log_path" ]; then
            la_failed "Log file '$log_path' does not exist."
            continue
        fi

        la_success "Log file selected: $log_path"
        return 0

    done
}


# ------------------------------------------------------------
# 1. Show errors
# ------------------------------------------------------------

la_show_errors() {

    local errors

    errors=$(grep -i "error" "$log_path" 2>/dev/null)

    if [ -n "$errors" ]; then

        echo
        echo "========================================"
        echo "              ERRORS"
        echo "========================================"
        echo "$errors"

        la_success "Error search completed."
        return 0

    else

        echo
        echo "No errors found in '$log_path'."
        la_failed "No matching error lines found."
        return 1

    fi
}


# ------------------------------------------------------------
# 2. Show warnings
# ------------------------------------------------------------

la_show_warnings() {

    local warnings

    warnings=$(grep -i "warn" "$log_path" 2>/dev/null)

    if [ -n "$warnings" ]; then

        echo
        echo "========================================"
        echo "             WARNINGS"
        echo "========================================"
        echo "$warnings"

        la_success "Warning search completed."
        return 0

    else

        echo
        echo "No warnings found in '$log_path'."
        la_failed "No matching warning lines found."
        return 1

    fi
}


# ------------------------------------------------------------
# 3. Count errors
# ------------------------------------------------------------

la_count_errors() {

    local error_count

    error_count=$(grep -ic "error" "$log_path" 2>/dev/null)

    if [ "$error_count" -gt 0 ]; then

        echo
        echo "========================================"
        echo "             ERROR COUNT"
        echo "========================================"
        echo
        echo "Log file : $log_path"
        echo "Errors   : $error_count"

        la_success "Error count completed."
        return 0

    else

        echo
        echo "No errors found in '$log_path'."
        la_failed "Error count is zero."
        return 1

    fi
}


# ------------------------------------------------------------
# 4. Search by keyword
# ------------------------------------------------------------

la_search_keyword() {

    local keyword
    local results

    read -p "Enter keyword to search: " keyword

    if [ -z "$keyword" ]; then
        la_failed "Keyword cannot be empty."
        return 1
    fi

    results=$(grep -i "$keyword" "$log_path" 2>/dev/null)

    if [ -n "$results" ]; then

        echo
        echo "========================================"
        echo "          SEARCH RESULTS"
        echo "========================================"
        echo
        echo "Keyword: $keyword"
        echo
        echo "$results"

        la_success "Keyword search completed."
        return 0

    else

        echo
        echo "No matches found for '$keyword'."
        la_failed "Keyword search returned no results."
        return 1

    fi
}


# ------------------------------------------------------------
# 5. Find most common errors
# ------------------------------------------------------------

la_common_errors() {

    local common_errors

    # Strip the leading "date time" (fields 1-2) before counting, so that
    # identical error MESSAGES are grouped together, not just identical
    # full lines. Without this, every line's unique timestamp makes
    # uniq -c treat every error as distinct, even repeats of the same error.
    common_errors=$(
        grep -i "error" "$log_path" 2>/dev/null |
        cut -d' ' -f3- |
        sort |
        uniq -c |
        sort -nr |
        head -n 10
    )

    if [ -n "$common_errors" ]; then

        echo
        echo "========================================"
        echo "          TOP 10 COMMON ERRORS"
        echo "========================================"
        echo
        echo "COUNT  ERROR"
        echo "$common_errors"

        la_success "Common error analysis completed."
        return 0

    else

        echo
        echo "No errors found in '$log_path'."
        la_failed "Unable to generate common error report."
        return 1

    fi
}


# ------------------------------------------------------------
# 6. Show recent errors
# ------------------------------------------------------------

la_recent_errors() {

    local line_count
    local recent_errors

    read -p "How many recent errors do you want to see? " line_count

    if [ -z "$line_count" ]; then
        la_failed "Number of lines cannot be empty."
        return 1
    fi

    if ! [[ "$line_count" =~ ^[0-9]+$ ]]; then
        la_failed "Please enter a valid positive number."
        return 1
    fi

    if [ "$line_count" -eq 0 ]; then
        la_failed "Number of lines must be greater than zero."
        return 1
    fi

    recent_errors=$(
        grep -i "error" "$log_path" 2>/dev/null |
        tail -n "$line_count"
    )

    if [ -n "$recent_errors" ]; then

        echo
        echo "========================================"
        echo "           RECENT ERRORS"
        echo "========================================"
        echo
        echo "$recent_errors"

        la_success "Recent error search completed."
        return 0

    else

        echo
        echo "No errors found in '$log_path'."
        la_failed "No recent errors available."
        return 1

    fi
}


# ------------------------------------------------------------
# Log Analyzer Menu
# ------------------------------------------------------------

log_analyzer_menu() {

    # Ask for the log file once when entering the module.
    la_select_log_file || return 1

    while true; do

        echo
        echo "========================================"
        echo "             LOG ANALYZER"
        echo "========================================"
        echo
        echo "Log file: $log_path"
        echo
        echo "1. Show errors"
        echo "2. Show warnings"
        echo "3. Count errors"
        echo "4. Search by keyword"
        echo "5. Most common errors"
        echo "6. Recent errors"
        echo "0. Back"
        echo
        echo "========================================"

        read -p "Enter your choice: " choice

        case "$choice" in

            1)
                la_show_errors
                ;;

            2)
                la_show_warnings
                ;;

            3)
                la_count_errors
                ;;

            4)
                la_search_keyword
                ;;

            5)
                la_common_errors
                ;;

            6)
                la_recent_errors
                ;;

            0)
                echo "Returning to main menu..."
                return 0
                ;;

            *)
                la_failed "Invalid option. Please choose 0-6."
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
#   ./modules/log_analyzer.sh
#
# start the Log Analyzer.
#
# If sourced by linux-admin.sh:
#
#   source modules/log_analyzer.sh
#
# only the functions are loaded.
#
# ------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    log_analyzer_menu
fi