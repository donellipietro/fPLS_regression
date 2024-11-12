#!/bin/bash

# $1: test suite name
# $2: test name


start=$(date +%s.%N)

# Define the number of high-performance cores
NUM_CORES=6

# Define the total number of CPU cores
TOTAL_CORES=$(sysctl -n hw.physicalcpu)

# Calculate the number of cores to be used for parallel processing
PARALLEL_CORES=$((TOTAL_CORES - 4))

# Ensure that PARALLEL_CORES does not exceed the available high-performance cores
if [ "$PARALLEL_CORES" -gt "$NUM_CORES" ]; then
  PARALLEL_CORES=$NUM_CORES
fi


###############################################################################


RScript src/init.R "$1" "$2"

# Set the directory containing the files
directory="queue/"

# Check if the directory exists
if [ ! -d "$directory" ]; then
echo "Directory $directory not found."
exit 1
fi

# Change to the specified directory
cd "$directory" || exit 1

# Define your task function
task_function() {
  cd ../
  # Run RScript with the current file as an argument
  RScript tests/"$1"/main.R "$2" "$3"
  cd "$directory" || exit 1
}

# Export the task function so that it can be used by GNU Parallel
export -f task_function

# Run tasks in parallel using GNU Parallel
ls * | parallel -j "$PARALLEL_CORES" task_function "$1" "$2"

## Run time complexity analysis
cd ../
RScript tests/"$1"/post_processing.R "$2"


###############################################################################


# End timer
end=$(date +%s.%N)
execution_time=$(echo "$end - $start" | bc)

# Print total execution time
echo "Total execution time: $execution_time seconds"
