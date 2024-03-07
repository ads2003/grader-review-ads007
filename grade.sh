#!/bin/bash

# Ensure a repository URL is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <GitHub repository URL>"
    exit 1
fi

REPO_URL="$1"
REPO_DIR="grading-area"

# Define the classpath with absolute paths to the JUnit and Hamcrest libraries
LIB_DIR="$(pwd)/lib"
CPATH=".:$LIB_DIR/hamcrest-core-1.3.jar:$LIB_DIR/junit-4.13.2.jar"

# Cleanup and setup
rm -rf "$REPO_DIR"
git clone "$REPO_URL" "$REPO_DIR"
echo 'Finished cloning'

# Check for the required file
if [ ! -f "$REPO_DIR/ListExamples.java" ]; then
    echo "ListExamples.java not found in the submission."
    exit 1
fi

# Prepare the grading area
cp TestListExamples.java "$REPO_DIR"
cp "$LIB_DIR"/* "$REPO_DIR"

# Compile and test
cd "$REPO_DIR"
javac -cp "$CPATH" *.java
if [ $? -ne 0 ]; then
    echo "Compilation failed. Please check your code for errors."
    exit 1
fi

# Run the tests
test_output=$(java -cp "$CPATH" org.junit.runner.JUnitCore TestListExamples)

# Analyze test results and provide feedback
echo "$test_output"
if echo "$test_output" | grep -q "FAILURES"; then
    echo "Some tests did not pass."
else
    echo "All tests passed."
fi

# Optionally, return to the original directory
cd ..
