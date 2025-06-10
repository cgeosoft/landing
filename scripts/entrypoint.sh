#!/bin/sh

# Path to your HTML template as the first argument
DIST_DIR="$1"

echo "Reading HTML templates from $DIST_DIR/*.html"

# Find HTML files and process them
find "$DIST_DIR" -type f -name '*.html' | while IFS= read -r file; do
    echo "Processing file: $file"
    perl -pi -e 's/\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}/$ENV{$1}/ge' "$file"
done

# Check if a command is provided to execute afterwards
if [ -z "$2" ]; then
    echo "No command specified to execute after processing."
else
    shift # Remove the first argument (DIST_DIR) so $@ contains only the command
    echo "Executing command: $@"
    exec "$@"
fi
