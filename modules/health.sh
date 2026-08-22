#!/usr/bin/env bash

run_health_check() {

    local hostname_value user_value kernel_value uptime_value
    local cpu_cores memory_value disk_value process_count os_name

# Collect system information
    hostname_value=$(hostname)

    user_value=$(whoami)

    kernel_value=$(uname -r)

    uptime_value=$(uptime -p)

    cpu_cores=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

    memory_value=$(free -h | awk '/^Mem:/ {print $3 " / " $2 " used"}')

    disk_value=$(df -h / | awk 'NR==2 {print $5 " used"}')

    process_count=$(ps -e --no-headers | wc -l)

# Get operating system information
    if [ -f /etc/os-release ]; then
        os_name=$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")
    else
        os_name="Unknown"
    fi

# Display the health check report
    echo "========================================"
    echo "        SERVER HEALTH CHECK"
    echo "========================================"

    echo "Hostname     : $hostname_value"
    echo "User         : $user_value"
    echo "OS           : $os_name"
    echo "Kernel       : $kernel_value"
    echo "Uptime       : $uptime_value"
    echo "CPU          : $cpu_cores cores"
    echo "Memory       : $memory_value"
    echo "Disk (/)     : $disk_value"
    echo "Processes    : $process_count running"

    echo "========================================"
}

# Only auto-run when this file is executed directly (e.g. for testing
# this module in isolation). When linux-admin.sh sources this file, this
# block is skipped and only the function definition is loaded.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_health_check
fi