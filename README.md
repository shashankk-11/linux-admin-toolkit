# Linux Admin Toolkit

A modular **Bash-only** command-line tool for common Linux administration tasks — health checks, file management, log analysis, backups, disk/process monitoring, system info, password generation, a calculator, and report generation.

Built as a learning project to practice Bash scripting and core Linux administration concepts, and as a DevOps portfolio piece.

---

## Requirements

- Ubuntu Linux or WSL (Windows Subsystem for Linux)
- Bash (no Python, Go, Node.js, Docker, Kubernetes, or cloud CLIs required)
- Standard coreutils (`ps`, `df`, `du`, `free`, `grep`, `awk`, `tar`, etc.) — present by default on almost any Linux system

## Project Structure

```text
linux-admin-toolkit/
│
├── linux-admin.sh        # Entry point — interactive menu + CLI argument handling
│
├── modules/
│   ├── health.sh         # Server health checks
│   ├── file_manager.sh   # File/directory operations
│   ├── log_analyzer.sh   # Log searching and analysis
│   ├── backup.sh         # Backup creation/restore/cleanup
│   ├── disk.sh           # Disk usage + thresholds
│   ├── process.sh        # Process monitoring
│   ├── system_info.sh    # System information
│   ├── password.sh       # Password generator
│   └── calculator.sh     # CLI calculator
│
├── data/
│   └── logs/             # Sample/working log files for the Log Analyzer
│
├── backups/              # Backup archives created by the Backup Manager
│
├── reports/              # Generated reports (Module 10)
│
├── config/               # Configuration (e.g. disk thresholds, defaults)
│
└── README.md
```

## Installation

```bash
git clone <your-repo-url> linux-admin-toolkit
cd linux-admin-toolkit
chmod +x linux-admin.sh modules/*.sh
```

## Usage

### Interactive mode

Run the script with no arguments to get a menu-driven interface:

```bash
./linux-admin.sh
```

```text
========================================
LINUX ADMIN TOOLKIT
========================================
1. Server Health Check
2. File Manager
3. Log Analyzer
4. Backup Manager
5. Disk Usage
6. Process Monitor
7. System Information
8. Password Generator
9. Calculator
10. Reports
11. Exit

Enter your choice:
```

Enter the number of the feature you want, and follow the on-screen prompts.

### Command-line mode

Once flags/subcommands are implemented (Phase 10), each module can also be run directly without going through the menu:

```bash
./linux-admin.sh health              # Run a server health check
./linux-admin.sh files               # Open the File Manager
./linux-admin.sh logs app.log        # Analyze a specific log file
./linux-admin.sh backup              # Open the Backup Manager
./linux-admin.sh disk                # Show disk usage
./linux-admin.sh process             # Open the Process Monitor
./linux-admin.sh system              # Show system information
./linux-admin.sh password            # Generate a password
./linux-admin.sh calc 100 + 25       # Run a calculation directly
./linux-admin.sh --help              # Show usage help
./linux-admin.sh --version           # Show version info
```

---

## Module Reference

### 1. Server Health Check

Gives a quick snapshot of the machine's health.

**What it checks:**
- Hostname
- Current user
- Operating system (from `/etc/os-release`)
- Kernel version
- System uptime
- CPU info
- RAM usage
- Disk usage
- Number/state of running processes

**How to use:**
```bash
./linux-admin.sh health
```
or select **1** from the interactive menu.

---

### 2. File Manager

A menu-driven wrapper around everyday file operations.

**Options:**
```text
1. List directory
2. Create directory
3. Create file
4. Copy file
5. Move file
6. Delete file
7. Find file
8. Show file information
0. Back
```

**How to use:**
```bash
./linux-admin.sh files
```
Then pick an option and supply the requested path(s) when prompted (e.g. source/destination for copy or move, a search pattern for find). Input is validated — for example, the tool checks that a file or directory exists before trying to operate on it.

---

### 3. Log Analyzer

Searches and summarizes log files (defaults to files under `data/logs/`, or a path you provide).

**Options:**
```text
1. Show errors
2. Show warnings
3. Count errors
4. Search keyword
5. Find most common errors
6. Show recent errors
```

**How to use:**
```bash
./linux-admin.sh logs app.log
```
or select **3** from the menu and enter a log file path.

Example of what happens under the hood for "most common errors":
```bash
grep "ERROR" app.log | sort | uniq -c | sort -nr
```

---

### 4. Backup Manager

Creates and manages compressed backups of files or directories.

**Options:**
```text
1. Create backup
2. List backups
3. Restore backup
4. Delete backup
5. Remove backups older than N days
```

**How to use:**
```bash
./linux-admin.sh backup
```
Backups are stored as timestamped `.tar.gz` archives under `backups/`. Retention cleanup (option 5) removes archives older than a number of days you specify.

---

### 5. Disk Usage

Reports filesystem usage with status thresholds.

**Displays:**
```text
Filesystem | Total | Used | Available | Percentage | Status
```

**Thresholds:**
```text
< 70%   OK
70-85%  WARNING
> 85%   CRITICAL
```

**How to use:**
```bash
./linux-admin.sh disk
```
or select **5** from the menu. Thresholds are configurable (see `config/`).

---

### 6. Process Monitor

Inspect and manage running processes.

**Options:**
```text
1. List processes
2. Top CPU processes
3. Top memory processes
4. Search process
5. Kill process
```

**How to use:**
```bash
./linux-admin.sh process
```
For "Kill process," you'll be asked to confirm the PID before a signal is sent — this prevents accidentally killing the wrong process.

---

### 7. System Information

A more detailed system summary than the Health Check, including live data from `/proc`.

**Displays:**
```text
Hostname
OS
Kernel
Architecture
CPU
Memory
Disk
Uptime
Logged-in users
```

**How to use:**
```bash
./linux-admin.sh system
```

---

### 8. Password Generator

Generates random passwords using `/dev/urandom`.

**Prompts:**
```text
Password length:
Include numbers? y/n
Include special characters? y/n
```

**How to use:**
```bash
./linux-admin.sh password
```
or select **8** from the menu and answer the prompts.

---

### 9. Calculator

Simple arithmetic from the command line or interactively.

**Supported operators:** `+  -  *  /  %`

**How to use (direct):**
```bash
./linux-admin.sh calc 100 + 25
```
```text
Result: 125
```

**How to use (interactive):**
```bash
./linux-admin.sh calc
```
then follow the prompts to enter two numbers and an operator.

---

### 10. Reports

Generates a timestamped snapshot combining data from the other modules.

**Includes:**
```text
System information
CPU
Memory
Disk
Top processes
Health status
Log errors
Timestamp
```

**How to use:**
```bash
./linux-admin.sh reports
```
Reports are saved under `reports/`, e.g.:
```text
reports/health_2026-08-22_1430.txt
```

---

## Safety Notes

This toolkit intentionally avoids destructive defaults:
- No use of `rm -rf /` or similarly dangerous patterns.
- No blanket `chmod 777` — permissions follow least-privilege.
- `sudo` is never required unless a specific feature genuinely needs elevated access.
- File/process operations confirm before deleting or killing anything.
- All variables are quoted, and inputs are validated before use.

## Status

This project is being built incrementally, module by module, as a hands-on way to learn Bash and Linux administration. See the module list above for what's implemented so far.