#!/bin/bash
#
# File Integrity Monitoring - Continuous Monitor Script
# Purpose: Compare current file states against baseline database
# Usage: ./fim_monitor.sh <config_file>
# Config file should contain one directory path per line
#

set -e

# Check if config file argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    echo "Config file should contain one directory path per line"
    exit 1
fi

CONFIG_FILE="$1"

# Validate config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '$CONFIG_FILE' does not exist"
    exit 1
fi

LOG_TAG="FIM_MONITOR"
ALERT_COUNT=0

# Function to log alerts to syslog
log_alert() {
    local severity="$1"
    local message="$2"
    logger -t "$LOG_TAG" -p "local0.$severity" "$message"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$severity] $message"
    ((ALERT_COUNT++))
}

# Function to check a single directory
check_directory() {
    local target_dir="$1"
    local db_file="${target_dir}/.fim_baseline.db"
    
    # Check if baseline exists
    if [ ! -f "$db_file" ]; then
        log_alert "warning" "No baseline found for $target_dir - skipping"
        return
    fi
    
    # Create temporary file for current state
    local current_state=$(mktemp)
    
    # Generate current file list and hashes
    find "$target_dir" -type f -print0 2>/dev/null | while IFS= read -r -d '' file; do
        # Skip the database file itself
        if [ "$file" = "$db_file" ]; then
            continue
        fi
        
        if [ -r "$file" ]; then
            hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
            if [ -n "$hash" ]; then
                perms=$(stat -c "%a" "$file" 2>/dev/null)
                size=$(stat -c "%s" "$file" 2>/dev/null)
                mtime=$(stat -c "%Y" "$file" 2>/dev/null)
                echo "$file|$hash|$perms|$size|$mtime" >> "$current_state"
            fi
        fi
    done
    
    # Check for modified files (different hash)
    while IFS='|' read -r filepath hash perms size mtime; do
        if [ -f "$filepath" ]; then
            current_hash=$(sha256sum "$filepath" 2>/dev/null | awk '{print $1}')
            if [ -n "$current_hash" ] && [ "$current_hash" != "$hash" ]; then
                log_alert "alert" "MODIFIED: $filepath (hash changed from baseline)"
            fi
        fi
    done < "$db_file"
    
    # Check for new files
    while IFS='|' read -r filepath hash perms size mtime; do
        if ! grep -q "^${filepath}|" "$db_file" 2>/dev/null; then
            log_alert "warning" "NEW FILE: $filepath"
        fi
    done < "$current_state"
    
    # Check for deleted files
    while IFS='|' read -r filepath hash perms size mtime; do
        if [ ! -f "$filepath" ]; then
            log_alert "alert" "DELETED: $filepath (missing from filesystem)"
        fi
    done < "$db_file"
    
    # Cleanup
    rm -f "$current_state"
}

# Main execution
echo "=== File Integrity Monitoring - Scan Started ==="
echo "Config File: $CONFIG_FILE"
echo "Scan Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Process each directory from config file
while IFS= read -r directory || [ -n "$directory" ]; do
    # Skip empty lines and comments
    [[ -z "$directory" || "$directory" =~ ^[[:space:]]*# ]] && continue
    
    # Trim whitespace
    directory=$(echo "$directory" | xargs)
    
    if [ -d "$directory" ]; then
        echo "Checking: $directory"
        check_directory "$directory"
    else
        log_alert "warning" "Directory not found: $directory"
    fi
done < "$CONFIG_FILE"

echo ""
echo "=== Scan Complete ==="
echo "Total alerts generated: $ALERT_COUNT"

# Log scan completion
if [ $ALERT_COUNT -eq 0 ]; then
    logger -t "$LOG_TAG" -p local0.info "Scan complete - no integrity violations detected"
else
    logger -t "$LOG_TAG" -p local0.warning "Scan complete - $ALERT_COUNT integrity alerts generated"
fi

exit 0