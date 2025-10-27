#!/usr/bin/env bash
# Custom assertion functions for Bats tests
# Following London School TDD principles

# Load bats-support and bats-assert if available
# These provide additional assertion helpers

# Basic assert_output function (if not provided by bats-assert)
if ! command -v assert_output &> /dev/null; then
    assert_output() {
        local expected="$1"
        if [[ "$output" != "$expected" ]]; then
            echo "Expected output: $expected" >&2
            echo "Actual output: $output" >&2
            return 1
        fi
    }
fi

# Assert that a mock was called a specific number of times
# Usage: assert_mock_called "command_name" expected_count
assert_mock_called() {
    local cmd="$1"
    local expected_count="$2"
    local actual_count="${mock_call_count[$cmd]:-0}"
    
    if [[ $actual_count -ne $expected_count ]]; then
        echo "Expected $cmd to be called $expected_count times, but was called $actual_count times" >&2
        return 1
    fi
}

# Assert that a mock was called at least once
# Usage: assert_mock_called_once "command_name"
assert_mock_called_once() {
    local cmd="$1"
    assert_mock_called "$cmd" 1
}

# Assert that a mock was never called
# Usage: assert_mock_not_called "command_name"
assert_mock_not_called() {
    local cmd="$1"
    assert_mock_called "$cmd" 0
}

# Assert that output contains a specific string
# Usage: assert_output_contains "expected_string"
assert_output_contains() {
    local expected="$1"
    
    if [[ ! "$output" =~ $expected ]]; then
        echo "Expected output to contain: $expected" >&2
        echo "Actual output: $output" >&2
        return 1
    fi
}

# Assert that output does not contain a specific string
# Usage: assert_output_not_contains "unexpected_string"
assert_output_not_contains() {
    local unexpected="$1"
    
    if [[ "$output" =~ $unexpected ]]; then
        echo "Expected output to NOT contain: $unexpected" >&2
        echo "Actual output: $output" >&2
        return 1
    fi
}

# Assert that output matches a regex pattern
# Usage: assert_output_matches "pattern"
assert_output_matches() {
    local pattern="$1"
    
    if [[ ! "$output" =~ $pattern ]]; then
        echo "Expected output to match pattern: $pattern" >&2
        echo "Actual output: $output" >&2
        return 1
    fi
}

# Assert that a file exists
# Usage: assert_file_exists "filepath"
assert_file_exists() {
    local filepath="$1"
    
    if [[ ! -f "$filepath" ]]; then
        echo "Expected file to exist: $filepath" >&2
        return 1
    fi
}

# Assert that a file does not exist
# Usage: assert_file_not_exists "filepath"
assert_file_not_exists() {
    local filepath="$1"
    
    if [[ -f "$filepath" ]]; then
        echo "Expected file to NOT exist: $filepath" >&2
        return 1
    fi
}

# Assert that a file contains specific content
# Usage: assert_file_contains "filepath" "expected_content"
assert_file_contains() {
    local filepath="$1"
    local expected="$2"
    
    if [[ ! -f "$filepath" ]]; then
        echo "File does not exist: $filepath" >&2
        return 1
    fi
    
    if ! grep -q "$expected" "$filepath"; then
        echo "Expected file to contain: $expected" >&2
        echo "File: $filepath" >&2
        return 1
    fi
}

# Assert that exit status is success (0)
# Usage: assert_success
assert_success() {
    if [[ "$status" -ne 0 ]]; then
        echo "Expected exit status 0, got: $status" >&2
        echo "Output: $output" >&2
        return 1
    fi
}

# Assert that exit status is failure (non-zero)
# Usage: assert_failure [expected_code]
assert_failure() {
    local expected_code="${1:-1}"
    
    if [[ "$status" -eq 0 ]]; then
        echo "Expected exit status to be non-zero, got: 0" >&2
        echo "Output: $output" >&2
        return 1
    fi
    
    if [[ $# -gt 0 && "$status" -ne "$expected_code" ]]; then
        echo "Expected exit status $expected_code, got: $status" >&2
        echo "Output: $output" >&2
        return 1
    fi
}

# Assert that output is empty
# Usage: assert_output_empty
assert_output_empty() {
    if [[ -n "$output" ]]; then
        echo "Expected output to be empty" >&2
        echo "Actual output: $output" >&2
        return 1
    fi
}

# Assert that output is not empty
# Usage: assert_output_not_empty
assert_output_not_empty() {
    if [[ -z "$output" ]]; then
        echo "Expected output to be non-empty" >&2
        return 1
    fi
}

# Assert that a variable is set
# Usage: assert_variable_set "variable_name"
assert_variable_set() {
    local var_name="$1"
    
    if [[ -z "${!var_name}" ]]; then
        echo "Expected variable to be set: $var_name" >&2
        return 1
    fi
}

# Assert that a variable equals a specific value
# Usage: assert_variable_equals "variable_name" "expected_value"
assert_variable_equals() {
    local var_name="$1"
    local expected="$2"
    local actual="${!var_name}"
    
    if [[ "$actual" != "$expected" ]]; then
        echo "Expected $var_name to equal: $expected" >&2
        echo "Actual value: $actual" >&2
        return 1
    fi
}

# Assert that an array has a specific length
# Usage: assert_array_length "array_name" expected_length
assert_array_length() {
    local array_name="$1"
    local expected_length="$2"
    local -n array_ref="$array_name"
    local actual_length="${#array_ref[@]}"
    
    if [[ "$actual_length" -ne "$expected_length" ]]; then
        echo "Expected array $array_name to have length $expected_length, got: $actual_length" >&2
        return 1
    fi
}

# Assert that an array contains a specific value
# Usage: assert_array_contains "array_name" "expected_value"
assert_array_contains() {
    local array_name="$1"
    local expected="$2"
    local -n array_ref="$array_name"
    
    for value in "${array_ref[@]}"; do
        if [[ "$value" == "$expected" ]]; then
            return 0
        fi
    done
    
    echo "Expected array $array_name to contain: $expected" >&2
    echo "Array contents: ${array_ref[*]}" >&2
    return 1
}

# Assert that two values are equal
# Usage: assert_equals "actual" "expected"
assert_equals() {
    local actual="$1"
    local expected="$2"
    
    if [[ "$actual" != "$expected" ]]; then
        echo "Expected: $expected" >&2
        echo "Actual: $actual" >&2
        return 1
    fi
}

# Assert that two values are not equal
# Usage: assert_not_equals "value1" "value2"
assert_not_equals() {
    local value1="$1"
    local value2="$2"
    
    if [[ "$value1" == "$value2" ]]; then
        echo "Expected values to be different" >&2
        echo "Both values: $value1" >&2
        return 1
    fi
}

# Assert that a value matches a regex pattern
# Usage: assert_matches "value" "pattern"
assert_matches() {
    local value="$1"
    local pattern="$2"
    
    if [[ ! "$value" =~ $pattern ]]; then
        echo "Expected value to match pattern: $pattern" >&2
        echo "Actual value: $value" >&2
        return 1
    fi
}