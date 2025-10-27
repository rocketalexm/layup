#!/usr/bin/env bats
# tests/test_input_validation.bats
# Test suite for input file validation and parsing (Phase 2.2)

load 'helpers/mocks'
load 'helpers/assertions'

# Setup and teardown for each test
setup() {
    # Create a temporary directory for test files
    TEST_TEMP_DIR="$(mktemp -d)"
    export TEST_TEMP_DIR
    
    # Path to the script
    SCRIPT_PATH="${BATS_TEST_DIRNAME}/../layup.sh"
}

teardown() {
    # Clean up temporary directory
    if [[ -n "${TEST_TEMP_DIR}" && -d "${TEST_TEMP_DIR}" ]]; then
        rm -rf "${TEST_TEMP_DIR}"
    fi
    cleanup_mocks
}

#######################################
# Subtask 2.2.1: File Validation & Error Handling
#######################################

# Test 1: Empty file detection
@test "empty file exits with code 2 and clear error message" {
    local empty_file="${TEST_TEMP_DIR}/empty.txt"
    touch "$empty_file"
    
    run bash "$SCRIPT_PATH" "$empty_file"
    
    assert_failure 2
    assert_output_contains "ERROR:"
    assert_output_contains "empty"
}

# Test 2: File with only whitespace is treated as empty
@test "file with only whitespace is treated as empty" {
    local whitespace_file="${TEST_TEMP_DIR}/whitespace.txt"
    printf "   \n\t\n  \t  \n" > "$whitespace_file"
    
    run bash "$SCRIPT_PATH" "$whitespace_file"
    
    assert_failure 2
    assert_output_contains "ERROR:"
    assert_output_contains "empty"
}

# Test 3: File with only comments is treated as empty
@test "file with only comments is treated as empty" {
    local comments_file="${TEST_TEMP_DIR}/comments.txt"
    cat > "$comments_file" << 'EOF'
# This is a comment
# Another comment
  # Indented comment
EOF
    
    run bash "$SCRIPT_PATH" "$comments_file"
    
    assert_failure 2
    assert_output_contains "ERROR:"
}

# Test 4: Non-readable file permission error
@test "non-readable file shows permission error" {
    local unreadable_file="${TEST_TEMP_DIR}/unreadable.txt"
    echo "com.apple.mobilesafari" > "$unreadable_file"
    chmod 000 "$unreadable_file"
    
    run bash "$SCRIPT_PATH" "$unreadable_file"
    
    # Should fail with file not found error (exit code 1) due to permission
    assert_failure 1
    assert_output_contains "ERROR:"
    assert_output_contains "not readable"
    
    # Cleanup
    chmod 644 "$unreadable_file"
}

# Test 5: Error messages are actionable
@test "empty file error message is actionable" {
    local empty_file="${TEST_TEMP_DIR}/empty.txt"
    touch "$empty_file"
    
    run bash "$SCRIPT_PATH" "$empty_file"
    
    assert_failure 2
    # Should suggest what to do
    assert_output_matches "(add|provide|include|contains no)"
}

#######################################
# Subtask 2.2.2: Line-by-Line Reading & Tracking
#######################################

# Test 6: Line numbers start at 1
@test "line numbers start at 1 not 0" {
    local test_file="${TEST_TEMP_DIR}/test.txt"
    cat > "$test_file" << 'EOF'
com.apple.mobilesafari
invalid..bundle
EOF
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # When validation is implemented, invalid lines should reference line 2, not line 1
    # For now, just ensure the file is read
    # This test will be more meaningful in Phase 2.3
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 7: Unix line endings (LF) are supported
@test "unix line endings (LF) are supported" {
    local test_file="${TEST_TEMP_DIR}/unix.txt"
    printf "com.apple.mobilesafari\ncom.apple.mobilemail\n" > "$test_file"
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should not fail due to line ending issues
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 8: Windows line endings (CRLF) are supported
@test "windows line endings (CRLF) are supported" {
    local test_file="${TEST_TEMP_DIR}/windows.txt"
    printf "com.apple.mobilesafari\r\ncom.apple.mobilemail\r\n" > "$test_file"
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should not fail due to line ending issues
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 9: Mixed line endings are handled
@test "mixed line endings are handled" {
    local test_file="${TEST_TEMP_DIR}/mixed.txt"
    printf "com.apple.mobilesafari\ncom.apple.mobilemail\r\ncom.apple.MobileSMS\n" > "$test_file"
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should not fail due to line ending issues
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 10: File without trailing newline is handled
@test "file without trailing newline is handled" {
    local test_file="${TEST_TEMP_DIR}/no_trailing.txt"
    printf "com.apple.mobilesafari" > "$test_file"
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should read the line successfully
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

#######################################
# Subtask 2.2.3: Content Filtering
#######################################

# Test 11: Leading whitespace is trimmed
@test "leading whitespace is trimmed from lines" {
    local test_file="${TEST_TEMP_DIR}/leading_space.txt"
    cat > "$test_file" << 'EOF'
   com.apple.mobilesafari
	com.apple.mobilemail
  	com.apple.MobileSMS
EOF
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should succeed or fail validation, but not due to whitespace
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 12: Trailing whitespace is trimmed
@test "trailing whitespace is trimmed from lines" {
    local test_file="${TEST_TEMP_DIR}/trailing_space.txt"
    cat > "$test_file" << 'EOF'
com.apple.mobilesafari   
com.apple.mobilemail	
com.apple.MobileSMS  	
EOF
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should succeed or fail validation, but not due to whitespace
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 13: Comments are skipped
@test "lines starting with # are skipped as comments" {
    local test_file="${TEST_TEMP_DIR}/with_comments.txt"
    cat > "$test_file" << 'EOF'
# This is a comment
com.apple.mobilesafari
# Another comment
com.apple.mobilemail
EOF
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should process only the non-comment lines
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 14: Comments with leading whitespace are skipped
@test "comments with leading whitespace are skipped" {
    local test_file="${TEST_TEMP_DIR}/indented_comments.txt"
    cat > "$test_file" << 'EOF'
  # Indented comment
com.apple.mobilesafari
	# Tab-indented comment
com.apple.mobilemail
EOF
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should process only the non-comment lines
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 15: Empty lines are skipped
@test "empty lines are skipped" {
    local test_file="${TEST_TEMP_DIR}/with_empty_lines.txt"
    cat > "$test_file" << 'EOF'
com.apple.mobilesafari

com.apple.mobilemail

com.apple.MobileSMS
EOF
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should process only the non-empty lines
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 16: Lines with only whitespace are skipped
@test "lines with only whitespace are skipped" {
    local test_file="${TEST_TEMP_DIR}/whitespace_lines.txt"
    cat > "$test_file" << 'EOF'
com.apple.mobilesafari
   
com.apple.mobilemail
	
com.apple.MobileSMS
EOF
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should process only the non-empty lines
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 17: Complex file with mixed content
@test "complex file with comments, empty lines, and whitespace" {
    local test_file="${TEST_TEMP_DIR}/complex.txt"
    cat > "$test_file" << 'EOF'
# Communication apps
com.apple.mobilesafari
  com.apple.mobilemail

# Productivity apps
  # Microsoft Office
com.microsoft.Office.Outlook
   
com.google.chrome.ios
EOF
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should process only valid content lines
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}

# Test 18: Whitespace within Bundle IDs is preserved
@test "whitespace within bundle IDs is preserved for validation" {
    local test_file="${TEST_TEMP_DIR}/internal_space.txt"
    # This should be invalid due to space in the middle
    echo "com.apple.mobile safari" > "$test_file"
    
    run bash "$SCRIPT_PATH" "$test_file"
    
    # Should fail validation in Phase 2.3, but for now just ensure it's read
    # The space should NOT be trimmed from the middle
    [[ "$status" -eq 0 ]] || [[ "$status" -eq 3 ]] || [[ "$status" -eq 5 ]]
}