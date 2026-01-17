#!/bin/bash
#
# File Integrity Monitoring - Baseline Generation Script
# Purpose: Generate hash database for specified directory
# Usage: ./fim_baseline.sh <directory_path>
#

set -e

# Check if directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    echo "Example: $0 /etc"
    exit 1
fi

TARGET_DIR="$1"
DB_FILE="${TARGET_DIR}/.fim_baseline.db"

# Validate directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

# Check if we have read permissions
if [ ! -r "$TARGET_DIR" ]; then
    echo "Error: No read permission for '$TARGET_DIR'"
    exit 1
fi

echo "=== File Integrity Monitoring - Baseline Generation ==="
echo "Target Directory: $TARGET_DIR"
echo "Database File: $DB_FILE"
echo ""

# Create temporary file
TEMP_DB=$(mktemp)

# Generate hash database
echo "Generating file hashes..."
find "$TARGET_DIR" -type f -print0 2>/dev/null | while IFS= read -r -d '' file; do
    # Skip the database file itself
    if [ "$file" = "$DB_FILE" ]; then
        continue
    fi
    
    # Calculate SHA256 hash
    if [ -r "$file" ]; then
        hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
        if [ -n "$hash" ]; then
            # Get file metadata
            perms=$(stat -c "%a" "$file" 2>/dev/null)
            size=$(stat -c "%s" "$file" 2>/dev/null)
            mtime=$(stat -c "%Y" "$file" 2>/dev/null)
            
            # Format: filepath|hash|permissions|size|mtime
            echo "$file|$hash|$perms|$size|$mtime" >> "$TEMP_DB"
        fi
    fi
done

# Count files processed
FILE_COUNT=$(wc -l < "$TEMP_DB" 2>/dev/null || echo "0")

# Move temp database to final location
mv "$TEMP_DB" "$DB_FILE"
chmod 600 "$DB_FILE"

echo "Baseline complete: $FILE_COUNT files processed"
echo "Database saved to: $DB_FILE"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

# Log to syslog
logger -t FIM_BASELINE -p local0.info "Baseline created for $TARGET_DIR - $FILE_COUNT files"

exit 0