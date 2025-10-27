#!/usr/bin/env bats
# Test infrastructure verification
# This file tests that the test infrastructure itself is working correctly

# Load test helpers
load helpers/mocks
load helpers/assertions

setup() {
    # Reset mocks before each test
    reset_mock_calls
}

teardown() {
    # Clean up after each test
    cleanup_mocks
}

# Test that Bats is working
@test "bats infrastructure is functional" {
    run echo "test"
    assert_success
    assert_output "test"
}

# Test mock functionality
@test "mock_command creates a working mock" {
    mock_command "test_cmd" "mocked output"
    
    run test_cmd
    assert_success
    assert_output "mocked output"
}

@test "mock_command_fail creates a failing mock" {
    mock_command_fail "test_cmd" 42
    
    run test_cmd
    assert_failure 42
}

@test "mock call tracking works correctly" {
    mock_command "test_cmd" "output"
    
    test_cmd
    test_cmd
    test_cmd
    
    assert_mock_called "test_cmd" 3
}

# Note: mock_command_sequence is a complex feature that can be implemented in Phase 2 if needed
# For Phase 1, basic mocking is sufficient
@test "mock_command can be called multiple times" {
    mock_command "test_cmd" "consistent output"
    
    run test_cmd
    assert_output "consistent output"
    
    run test_cmd
    assert_output "consistent output"
}

# Test assertion functionality
@test "assert_output_contains works correctly" {
    output="This is a test output"
    assert_output_contains "test"
}

@test "assert_output_not_contains works correctly" {
    output="This is a test output"
    assert_output_not_contains "missing"
}

@test "assert_output_matches works with regex" {
    output="test123"
    assert_output_matches "test[0-9]+"
}

@test "assert_mock_called_once verifies single call" {
    mock_command "test_cmd" "output"
    test_cmd
    assert_mock_called_once "test_cmd"
}

@test "assert_mock_not_called verifies no calls" {
    mock_command "test_cmd" "output"
    assert_mock_not_called "test_cmd"
}

# Test variable assertions
@test "assert_variable_set detects set variables" {
    TEST_VAR="value"
    assert_variable_set "TEST_VAR"
}

@test "assert_variable_equals checks variable values" {
    TEST_VAR="expected"
    assert_variable_equals "TEST_VAR" "expected"
}

# Test array assertions
@test "assert_array_length checks array size" {
    local test_array=("one" "two" "three")
    assert_array_length "test_array" 3
}

@test "assert_array_contains finds values in arrays" {
    local test_array=("apple" "banana" "cherry")
    assert_array_contains "test_array" "banana"
}

# Test that helpers directory is accessible
@test "test helpers are loaded correctly" {
    [[ -n "$HELPERS_DIR" ]]
    [[ -f "$HELPERS_DIR/mocks.bash" ]]
    [[ -f "$HELPERS_DIR/assertions.bash" ]]
}

# Test temporary directory creation
@test "temporary test directory is available" {
    [[ -n "$BATS_TMPDIR" ]]
    [[ -d "$BATS_TMPDIR" ]]
}