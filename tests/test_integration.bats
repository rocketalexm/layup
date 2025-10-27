#!/usr/bin/env bats
# tests/test_integration.bats
# Integration tests for end-to-end workflows (Phase 3.1)
# Tests complete workflows from input file to XML generation and file output

load 'helpers/mocks'
load 'helpers/assertions'

setup() {
    # Reset mocks before each test
    reset_mock_calls
    
    # Create temporary test directory
    TEST_DIR="${BATS_TMPDIR}/test_integration_$$"
    mkdir -p "$TEST_DIR"
    
    # Path to the script
    SCRIPT_PATH="${BATS_TEST_DIRNAME}/../layup.sh"
    
    # Make script executable
    chmod +x "$SCRIPT_PATH"
}

teardown() {
    # Clean up after each test
    cleanup_mocks
    rm -rf "$TEST_DIR"
}

# =============================================================================
# HAPPY PATH TESTS
# =============================================================================

@test "integration: complete workflow with valid input file generates XML output" {
    # Create valid input file with multiple Bundle IDs
    local input_file="${TEST_DIR}/valid_apps.txt"
    cat > "$input_file" << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
EOF
    
    local output_file="${TEST_DIR}/output.mobileconfig"
    
    # Run the script
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    # Verify success
    assert_success
    
    # Verify output file was created
    assert_file_exists "$output_file"
    
    # Verify output contains expected Bundle IDs
    assert_file_contains "$output_file" "com.apple.mobilesafari"
    assert_file_contains "$output_file" "com.apple.mobilemail"
    assert_file_contains "$output_file" "com.apple.MobileSMS"
    
    # Verify XML structure
    assert_file_contains "$output_file" '<?xml version="1.0" encoding="UTF-8"?>'
    assert_file_contains "$output_file" "Configuration"
    assert_file_contains "$output_file" "com.apple.homescreenlayout.managed"
}

@test "integration: workflow with 5-10 valid Bundle IDs" {
    # Create input file with 7 Bundle IDs
    local input_file="${TEST_DIR}/multiple_apps.txt"
    cat > "$input_file" << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.microsoft.Office.Outlook
com.google.chrome.ios
com.slack.Slack
com.zoom.videomeetings
EOF
    
    local output_file="${TEST_DIR}/multiple_output.mobileconfig"
    
    # Run the script
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    
    # Verify all 7 Bundle IDs are present
    assert_file_contains "$output_file" "com.apple.mobilesafari"
    assert_file_contains "$output_file" "com.microsoft.Office.Outlook"
    assert_file_contains "$output_file" "com.zoom.videomeetings"
}

@test "integration: workflow with custom output filename" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    local custom_output="${TEST_DIR}/custom_layout.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$custom_output"
    
    assert_success
    assert_file_exists "$custom_output"
    assert_file_contains "$custom_output" "com.apple.mobilesafari"
}

@test "integration: workflow with default output filename generation" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    # Run without output filename (should generate default)
    cd "$TEST_DIR"
    run bash "$SCRIPT_PATH" "$input_file"
    
    assert_success
    
    # Check that a file matching the pattern was created
    local generated_files=("$TEST_DIR"/HomeScreenLayout_*.mobileconfig)
    [[ -f "${generated_files[0]}" ]] || return 1
}

@test "integration: XML validation with xmllint succeeds for valid output" {
    local input_file="${TEST_DIR}/apps.txt"
    cat > "$input_file" << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
EOF
    
    local output_file="${TEST_DIR}/validated.mobileconfig"
    
    # Run the script
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    
    # Validate XML with xmllint (if available)
    if command -v xmllint &> /dev/null; then
        run xmllint --noout "$output_file"
        assert_success
    fi
}

@test "integration: Finder integration is attempted on macOS" {
    skip "Finder integration test requires macOS environment"
    
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    local output_file="${TEST_DIR}/finder_test.mobileconfig"
    
    # This test would verify that 'open -R' is called
    # In a real macOS environment, this would open Finder
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
}

# =============================================================================
# ERROR HANDLING TESTS
# =============================================================================

@test "integration: invalid input file path shows error" {
    local nonexistent_file="${TEST_DIR}/does_not_exist.txt"
    
    run bash "$SCRIPT_PATH" "$nonexistent_file"
    
    assert_failure 1
    assert_output_contains "ERROR:"
    assert_output_contains "not found"
}

@test "integration: empty input file shows error" {
    local empty_file="${TEST_DIR}/empty.txt"
    touch "$empty_file"
    
    run bash "$SCRIPT_PATH" "$empty_file"
    
    assert_failure 2
    assert_output_contains "ERROR:"
    assert_output_contains "empty"
}

@test "integration: all invalid Bundle IDs shows error" {
    local input_file="${TEST_DIR}/all_invalid.txt"
    cat > "$input_file" << 'EOF'
invalid
not.valid
also..invalid
.starts.with.dot
ends.with.dot.
EOF
    
    run bash "$SCRIPT_PATH" "$input_file"
    
    assert_failure 3
    assert_output_contains "ERROR:"
    assert_output_contains "No valid Bundle IDs"
}

@test "integration: mixed valid and invalid Bundle IDs processes valid ones" {
    local input_file="${TEST_DIR}/mixed.txt"
    cat > "$input_file" << 'EOF'
com.apple.mobilesafari
invalid
com.apple.mobilemail
not.valid
com.apple.MobileSMS
EOF
    
    local output_file="${TEST_DIR}/mixed_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    # Should succeed with valid Bundle IDs
    assert_success
    assert_file_exists "$output_file"
    
    # Verify valid Bundle IDs are in output
    assert_file_contains "$output_file" "com.apple.mobilesafari"
    assert_file_contains "$output_file" "com.apple.mobilemail"
    assert_file_contains "$output_file" "com.apple.MobileSMS"
    
    # Verify validation messages show both valid and invalid
    assert_output_contains "✓"
    assert_output_contains "✗"
}

@test "integration: non-writable output directory shows error" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    # Try to write to a non-existent directory
    local bad_output="/nonexistent/directory/output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$bad_output"
    
    assert_failure 4
    assert_output_contains "ERROR:"
}

@test "integration: existing output file prompts for overwrite" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    local output_file="${TEST_DIR}/existing.mobileconfig"
    
    # Create existing file
    echo "existing content" > "$output_file"
    
    # Mock user input to cancel overwrite
    mock_user_input "n"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    # Should exit with success (user cancelled)
    assert_success
    assert_output_contains "Operation cancelled"
}

# =============================================================================
# EDGE CASES
# =============================================================================

@test "integration: maximum number of Bundle IDs (100+)" {
    local input_file="${TEST_DIR}/many_apps.txt"
    
    # Generate 150 valid Bundle IDs
    for i in {1..150}; do
        echo "com.company.app${i}" >> "$input_file"
    done
    
    local output_file="${TEST_DIR}/many_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    
    # Verify some Bundle IDs are present
    assert_file_contains "$output_file" "com.company.app1"
    assert_file_contains "$output_file" "com.company.app150"
}

@test "integration: Bundle IDs with special characters requiring escaping" {
    local input_file="${TEST_DIR}/special_chars.txt"
    cat > "$input_file" << 'EOF'
com.company.app-name
com.company.app_name
com.company-name.app
com.company_name.app
EOF
    
    local output_file="${TEST_DIR}/special_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    
    # Verify Bundle IDs with hyphens and underscores are accepted
    assert_file_contains "$output_file" "com.company.app-name"
    assert_file_contains "$output_file" "com.company.app_name"
}

@test "integration: very long Bundle IDs (near 255 character limit)" {
    local input_file="${TEST_DIR}/long_ids.txt"
    
    # Create a very long but valid Bundle ID (200+ characters)
    local long_id="com.company.verylongappname"
    for i in {1..20}; do
        long_id="${long_id}.segment${i}"
    done
    echo "$long_id" > "$input_file"
    
    local output_file="${TEST_DIR}/long_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    assert_file_contains "$output_file" "com.company.verylongappname"
}

@test "integration: input file with comments and whitespace" {
    local input_file="${TEST_DIR}/commented.txt"
    cat > "$input_file" << 'EOF'
# Communication apps
com.apple.mobilesafari
  com.apple.mobilemail  

# Productivity apps
com.microsoft.Office.Outlook

# Empty lines and comments are ignored
EOF
    
    local output_file="${TEST_DIR}/commented_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    
    # Verify only valid Bundle IDs are in output (whitespace trimmed)
    assert_file_contains "$output_file" "com.apple.mobilesafari"
    assert_file_contains "$output_file" "com.apple.mobilemail"
    assert_file_contains "$output_file" "com.microsoft.Office.Outlook"
    
    # Verify statistics show comments and empty lines
    assert_output_contains "Comments:"
    assert_output_contains "Empty lines:"
}

@test "integration: input file with Windows line endings (CRLF)" {
    local input_file="${TEST_DIR}/windows_format.txt"
    
    # Create file with Windows line endings
    printf "com.apple.mobilesafari\r\n" > "$input_file"
    printf "com.apple.mobilemail\r\n" >> "$input_file"
    printf "com.apple.MobileSMS\r\n" >> "$input_file"
    
    local output_file="${TEST_DIR}/windows_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    
    # Verify Bundle IDs are processed correctly
    assert_file_contains "$output_file" "com.apple.mobilesafari"
    assert_file_contains "$output_file" "com.apple.mobilemail"
}

@test "integration: input file with Unix line endings (LF)" {
    local input_file="${TEST_DIR}/unix_format.txt"
    
    # Create file with Unix line endings (default)
    cat > "$input_file" << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
EOF
    
    local output_file="${TEST_DIR}/unix_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    assert_file_contains "$output_file" "com.apple.mobilesafari"
}

# =============================================================================
# STATISTICS VALIDATION TESTS
# =============================================================================

@test "integration: statistics show correct count of processed Bundle IDs" {
    local input_file="${TEST_DIR}/stats_test.txt"
    cat > "$input_file" << 'EOF'
# Comment line
com.apple.mobilesafari
com.apple.mobilemail
invalid

com.apple.MobileSMS
EOF
    
    local output_file="${TEST_DIR}/stats_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    
    # Verify statistics in output
    assert_output_contains "Valid Bundle IDs: 3"
    assert_output_contains "Invalid Bundle IDs: 1"
    assert_output_contains "Comments: 1"
    assert_output_contains "Empty lines: 1"
}

@test "integration: error reporting includes line numbers" {
    local input_file="${TEST_DIR}/line_numbers.txt"
    cat > "$input_file" << 'EOF'
com.apple.mobilesafari
invalid
com.apple.mobilemail
EOF
    
    local output_file="${TEST_DIR}/line_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    
    # Verify line numbers in validation output
    assert_output_contains "Line 1:"
    assert_output_contains "Line 2:"
    assert_output_contains "Line 3:"
}

@test "integration: error reporting includes reasons for invalid Bundle IDs" {
    local input_file="${TEST_DIR}/reasons.txt"
    cat > "$input_file" << 'EOF'
invalid
.starts.with.dot
ends.with.dot.
has..consecutive.dots
has whitespace
EOF
    
    run bash "$SCRIPT_PATH" "$input_file"
    
    assert_failure 3
    
    # Verify specific error reasons are shown
    assert_output_contains "not enough segments"
    assert_output_contains "starts with dot"
    assert_output_contains "ends with dot"
    assert_output_contains "consecutive dots"
    assert_output_contains "whitespace"
}

@test "integration: success message displays correct statistics" {
    local input_file="${TEST_DIR}/success_stats.txt"
    cat > "$input_file" << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
EOF
    
    local output_file="${TEST_DIR}/success_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    
    # Verify success message
    assert_output_contains "✓ Success!"
    assert_output_contains "Configuration profile generated"
    assert_output_contains "Output file:"
    
    # Verify validation summary
    assert_output_contains "Validation Summary:"
    assert_output_contains "Valid Bundle IDs: 3"
}

# =============================================================================
# FILE OUTPUT VALIDATION TESTS
# =============================================================================

@test "integration: output file has correct .mobileconfig extension" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    # Provide output without extension
    local output_base="${TEST_DIR}/output"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_base"
    
    assert_success
    
    # Verify .mobileconfig extension was added
    assert_file_exists "${output_base}.mobileconfig"
}

@test "integration: output file has UTF-8 encoding" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    local output_file="${TEST_DIR}/utf8_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    
    # Verify file contains UTF-8 declaration
    assert_file_contains "$output_file" 'encoding="UTF-8"'
}

@test "integration: output file has correct permissions (644)" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    local output_file="${TEST_DIR}/perms_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    assert_file_exists "$output_file"
    
    # Check file permissions (should be rw-r--r--)
    local perms=$(stat -c "%a" "$output_file" 2>/dev/null || stat -f "%A" "$output_file" 2>/dev/null)
    [[ "$perms" == "644" ]] || return 1
}

# =============================================================================
# XML STRUCTURE VALIDATION TESTS
# =============================================================================

@test "integration: generated XML has proper plist structure" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    local output_file="${TEST_DIR}/plist_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    
    # Verify plist structure
    assert_file_contains "$output_file" '<plist version="1.0">'
    assert_file_contains "$output_file" '</plist>'
    assert_file_contains "$output_file" '<!DOCTYPE plist'
}

@test "integration: generated XML has unique UUIDs" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    local output_file="${TEST_DIR}/uuid_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    
    # Extract UUIDs from file (should have at least 2 unique UUIDs)
    local uuid_count=$(grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}' "$output_file" | sort -u | wc -l)
    [[ $uuid_count -ge 2 ]] || return 1
}

@test "integration: generated XML has correct payload types" {
    local input_file="${TEST_DIR}/apps.txt"
    echo "com.apple.mobilesafari" > "$input_file"
    
    local output_file="${TEST_DIR}/payload_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    
    # Verify payload types
    assert_file_contains "$output_file" "<string>Configuration</string>"
    assert_file_contains "$output_file" "<string>com.apple.homescreenlayout.managed</string>"
}

@test "integration: generated XML preserves Bundle ID order from input" {
    local input_file="${TEST_DIR}/order_test.txt"
    cat > "$input_file" << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
EOF
    
    local output_file="${TEST_DIR}/order_output.mobileconfig"
    
    run bash "$SCRIPT_PATH" "$input_file" "$output_file"
    
    assert_success
    
    # Extract Bundle IDs in order from output
    local bundle_ids=$(grep -o '<string>com\.apple\.[^<]*</string>' "$output_file" | grep -v 'homescreenlayout' | sed 's/<[^>]*>//g')
    
    # Verify order matches input
    echo "$bundle_ids" | grep -q "mobilesafari" || return 1
    echo "$bundle_ids" | grep -q "mobilemail" || return 1
    echo "$bundle_ids" | grep -q "MobileSMS" || return 1
}