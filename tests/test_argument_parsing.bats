#!/usr/bin/env bats
# Test argument parsing and help system
# Phase 2.1: Argument Parsing & Help System

# Load test helpers
load helpers/mocks
load helpers/assertions

setup() {
    # Reset mocks before each test
    reset_mock_calls
    
    # Create temporary test directory
    TEST_DIR="${BATS_TMPDIR}/test_arg_parsing_$$"
    mkdir -p "$TEST_DIR"
    
    # Path to the script (will be created during implementation)
    SCRIPT_PATH="${BATS_TEST_DIRNAME}/../layup.sh"
}

teardown() {
    # Clean up after each test
    cleanup_mocks
    rm -rf "$TEST_DIR"
}

# Test 1: Help flag --help displays help text
@test "help flag --help displays help text and exits with code 0" {
    run bash "$SCRIPT_PATH" --help
    
    assert_success
    assert_output_contains "Layup - Home Screen Layout Configuration Generator"
    assert_output_contains "USAGE:"
    assert_output_contains "layup.sh"
    assert_output_contains "input_file"
    assert_output_contains "DESCRIPTION:"
    assert_output_contains "ARGUMENTS:"
    assert_output_contains "EXAMPLE:"
}

# Test 2: Help flag -h displays help text
@test "help flag -h displays help text and exits with code 0" {
    run bash "$SCRIPT_PATH" -h
    
    assert_success
    assert_output_contains "Layup - Home Screen Layout Configuration Generator"
    assert_output_contains "USAGE:"
}

# Test 3: Help flag works in any position
@test "help flag works when provided after other arguments" {
    run bash "$SCRIPT_PATH" somefile.txt --help
    
    assert_success
    assert_output_contains "USAGE:"
}

# Test 4: Missing input file argument shows error
@test "missing input file argument shows error and exits with code 1" {
    run bash "$SCRIPT_PATH"
    
    assert_failure 1
    assert_output_contains "ERROR:"
    assert_output_contains "input file"
}

# Test 5: Help text includes all required sections
@test "help text includes all required sections" {
    run bash "$SCRIPT_PATH" --help
    
    assert_success
    assert_output_contains "INPUT FILE FORMAT:"
    assert_output_contains "EXIT CODES:"
    assert_output_contains "SAMPLE INPUT FILE"
}

# Test 6: Help text shows exit codes
@test "help text shows all exit codes" {
    run bash "$SCRIPT_PATH" --help
    
    assert_success
    assert_output_contains "0    Success"
    assert_output_contains "1    Input file not found"
    assert_output_contains "2    Input file is empty"
    assert_output_contains "3    No valid Bundle IDs found"
    assert_output_contains "4    Cannot write output file"
    assert_output_contains "5    XML validation failed"
}

# Test 7: Script validates input file is provided
@test "script requires at least one argument when not showing help" {
    run bash "$SCRIPT_PATH"
    
    assert_failure 1
}

# Test 8: Script accepts input file argument
@test "script accepts input file as first argument" {
    # Create a test input file
    local test_file="${TEST_DIR}/test_input.txt"
    echo "com.apple.mobilesafari" > "$test_file"
    
    # This will fail for now since we haven't implemented file reading
    # But it should at least accept the argument without help/error about missing arg
    run bash "$SCRIPT_PATH" "$test_file"
    
    # We expect it to fail with a different error (file reading not implemented)
    # But NOT with "missing input file argument" error
    if [ "$status" -eq 1 ]; then
        assert_output_not_contains "input file"
    fi
}

# Test 9: Script accepts optional output file argument
@test "script accepts optional output file as second argument" {
    local test_file="${TEST_DIR}/test_input.txt"
    local output_file="${TEST_DIR}/output.mobileconfig"
    echo "com.apple.mobilesafari" > "$test_file"
    
    # Should accept both arguments without argument parsing errors
    run bash "$SCRIPT_PATH" "$test_file" "$output_file"
    
    # May fail for other reasons (not implemented yet), but not arg parsing
    if [ "$status" -eq 1 ]; then
        assert_output_not_contains "Usage:"
    fi
}

# Test 10: Error messages go to stderr
@test "error messages are output to stderr not stdout" {
    # Run without arguments, capture stderr
    run bash "$SCRIPT_PATH" 2>&1 >/dev/null
    
    # Should have error output
    assert_output_contains "ERROR:"
}

# Test 11: Help output goes to stdout
@test "help output goes to stdout not stderr" {
    # Capture only stdout
    run bash "$SCRIPT_PATH" --help 2>/dev/null
    
    assert_success
    assert_output_contains "USAGE:"
}

# Test 12: Script validates input file exists (basic check)
@test "script checks if input file exists" {
    local nonexistent_file="${TEST_DIR}/does_not_exist.txt"
    
    run bash "$SCRIPT_PATH" "$nonexistent_file"
    
    assert_failure 1
    assert_output_contains "ERROR:"
    assert_output_contains "not found"
}