#!/usr/bin/env bash
#
# Test script to demonstrate p-cli echo functionality
#

echo "=== Testing p-cli with echo mode ==="
echo

echo "1. Without echo (default):"
./p help | head -5
echo

echo "2. With P_ECHO=1 (shows commands):"
P_ECHO=1 ./p create-task --title "Test task" --dry-run 2>&1 | grep "►" || echo "(Would show: ► gh issue create --label \"task\" --title \"Test task\" --dry-run)"
echo

echo "3. Example output when creating tasks:"
cat << 'EOF'
$ P_ECHO=1 p bulk-create-tasks tasks.json
► gh issue create --title "Add authentication" --body "..." --label "task,feature"
Created #123: Add authentication
► gh issue create --title "Setup database" --body "..." --label "task,backend"
Created #124: Setup database
EOF
echo

echo "=== Benefits for sub-agents ==="
echo "- See exact gh commands being executed"
echo "- Debug issues by copying/pasting commands"
echo "- Understand what p-cli is doing"
echo "- Learn gh CLI syntax"