#!/bin/bash

# $1: test suite name
# $2: test name

RScript src/init.R $1 $2

# Set the directory containing the files
directory="queue/"

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Directory $directory not found."
    exit 1
fi

# Change to the specified directory
cd "$directory" || exit 1

# Iterate over the files in the directory
for file in *; do
    # Check if the item is a file
    if [ -f "$file" ]; then
        # Run RScript with the current file as an argument
        cd ../
        RScript tests/$1/main.R $2 "$file"
        cd "$directory" || exit 1
    fi
done

## Run time complexity analysis
cd ../
RScript tests/$1/post_processing.R $2