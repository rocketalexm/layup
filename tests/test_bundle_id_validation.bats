#!/usr/bin/env bats

# Test file for Bundle ID validation (Phase 2.3)
# Tests the validate_bundle_id() function and validation logic

load 'helpers/mocks'
load 'helpers/assertions'

# Setup for each test
setup() {
    # Source the script (main won't run when sourced)
    source "${BATS_TEST_DIRNAME}/../layup.sh"
}

# ============================================================================
# Subtask 2.3.1: Core Regex Validation Tests
# ============================================================================

@test "validate_bundle_id: accepts valid basic Bundle ID (com.apple)" {
    run validate_bundle_id "com.apple"
    assert_success
}

@test "validate_bundle_id: accepts valid Bundle ID with three segments (com.apple.safari)" {
    run validate_bundle_id "com.apple.safari"
    assert_success
}

@test "validate_bundle_id: accepts Bundle ID with numbers (com.company.app123)" {
    run validate_bundle_id "com.company.app123"
    assert_success
}

@test "validate_bundle_id: accepts Bundle ID with hyphens (com.company-name.app)" {
    run validate_bundle_id "com.company-name.app"
    assert_success
}

@test "validate_bundle_id: accepts Bundle ID with underscores (com.company_name.app)" {
    run validate_bundle_id "com.company_name.app"
    assert_success
}

@test "validate_bundle_id: accepts Bundle ID with mixed valid characters (com.Company-Name.App_123)" {
    run validate_bundle_id "com.Company-Name.App_123"
    assert_success
}

@test "validate_bundle_id: rejects single word without dots (invalid)" {
    run validate_bundle_id "invalid"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID ending with dot (com.)" {
    run validate_bundle_id "com."
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID starting with dot (.com.app)" {
    run validate_bundle_id ".com.app"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with consecutive dots (com..app)" {
    run validate_bundle_id "com..app"
    assert_failure
}

@test "validate_bundle_id: accepts single character segments (a.b)" {
    run validate_bundle_id "a.b"
    assert_success
}

@test "validate_bundle_id: accepts long Bundle ID (com.example.very.long.bundle.identifier.name)" {
    run validate_bundle_id "com.example.very.long.bundle.identifier.name"
    assert_success
}

@test "validate_bundle_id: preserves case sensitivity (Com.Apple.Safari)" {
    run validate_bundle_id "Com.Apple.Safari"
    assert_success
}

@test "validate_bundle_id: rejects Bundle ID with spaces (com.app name)" {
    run validate_bundle_id "com.app name"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with special characters (com.app@test)" {
    run validate_bundle_id "com.app@test"
    assert_failure
}

# ============================================================================
# Subtask 2.3.2: Advanced Validation Rules Tests
# ============================================================================

# Tests for validate_bundle_id_with_reason function that returns detailed error reasons

@test "validate_bundle_id_with_reason: returns 'not enough segments' for single segment" {
    run validate_bundle_id_with_reason "notenough"
    assert_failure
    assert_output_contains "not enough segments"
}

@test "validate_bundle_id_with_reason: returns 'invalid characters' for special chars" {
    run validate_bundle_id_with_reason "com.app@test"
    assert_failure
    assert_output_contains "invalid characters"
}

@test "validate_bundle_id_with_reason: returns 'consecutive dots' for double dots" {
    run validate_bundle_id_with_reason "com..app"
    assert_failure
    assert_output_contains "consecutive dots"
}

@test "validate_bundle_id_with_reason: returns 'starts with dot' for leading dot" {
    run validate_bundle_id_with_reason ".com.app"
    assert_failure
    assert_output_contains "starts with dot"
}

@test "validate_bundle_id_with_reason: returns 'ends with dot' for trailing dot" {
    run validate_bundle_id_with_reason "com.app."
    assert_failure
    assert_output_contains "ends with dot"
}

@test "validate_bundle_id_with_reason: returns 'contains whitespace' for spaces" {
    run validate_bundle_id_with_reason "com.app test"
    assert_failure
    assert_output_contains "contains whitespace"
}

@test "validate_bundle_id_with_reason: returns success for valid Bundle ID" {
    run validate_bundle_id_with_reason "com.apple.safari"
    assert_success
    assert_output ""
}

# Original validation tests (these still test the basic validate_bundle_id function)

@test "validate_bundle_id: rejects single segment (notenough)" {
    run validate_bundle_id "notenough"
    assert_failure
}

@test "validate_bundle_id: accepts exactly 2 segments (com.app)" {
    run validate_bundle_id "com.app"
    assert_success
}

@test "validate_bundle_id: accepts many segments (com.example.app.module.feature)" {
    run validate_bundle_id "com.example.app.module.feature"
    assert_success
}

@test "validate_bundle_id: rejects Bundle ID with exclamation mark (com.app!test)" {
    run validate_bundle_id "com.app!test"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with dollar sign (com.app$test)" {
    run validate_bundle_id "com.app\$test"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with percent (com.app%test)" {
    run validate_bundle_id "com.app%test"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with ampersand (com.app&test)" {
    run validate_bundle_id "com.app&test"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with asterisk (com.app*test)" {
    run validate_bundle_id "com.app*test"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with plus (com.app+test)" {
    run validate_bundle_id "com.app+test"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with equals (com.app=test)" {
    run validate_bundle_id "com.app=test"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with slash (com.app/test)" {
    run validate_bundle_id "com.app/test"
    assert_failure
}

@test "validate_bundle_id: rejects Bundle ID with backslash (com.app\\test)" {
    run validate_bundle_id "com.app\\test"
    assert_failure
}

@test "validate_bundle_id: rejects consecutive dots at start (..com.app)" {
    run validate_bundle_id "..com.app"
    assert_failure
}

@test "validate_bundle_id: rejects consecutive dots in middle (com...app)" {
    run validate_bundle_id "com...app"
    assert_failure
}

@test "validate_bundle_id: rejects consecutive dots at end (com.app..)" {
    run validate_bundle_id "com.app.."
    assert_failure
}

@test "validate_bundle_id: rejects multiple dots at start (...com.app)" {
    run validate_bundle_id "...com.app"
    assert_failure
}

@test "validate_bundle_id: rejects dot only (.)" {
    run validate_bundle_id "."
    assert_failure
}

@test "validate_bundle_id: rejects multiple dots only (...)" {
    run validate_bundle_id "..."
    assert_failure
}

@test "validate_bundle_id: rejects leading whitespace ( com.app)" {
    run validate_bundle_id " com.app"
    assert_failure
}

@test "validate_bundle_id: rejects trailing whitespace (com.app )" {
    run validate_bundle_id "com.app "
    assert_failure
}

@test "validate_bundle_id: rejects whitespace in middle (com. app)" {
    run validate_bundle_id "com. app"
    assert_failure
}

@test "validate_bundle_id: rejects tab character (com.app\ttest)" {
    run validate_bundle_id "com.app	test"
    assert_failure
}

@test "validate_bundle_id: rejects newline in Bundle ID" {
    run validate_bundle_id "com.app
test"
    assert_failure
}

# ============================================================================
# Subtask 2.3.3: Error Reporting & Statistics Tests
# ============================================================================

@test "process_bundle_ids: validates and reports on mixed valid/invalid Bundle IDs" {
    # Create a test file with mixed content
    local test_file="${BATS_TMPDIR}/test_mixed_$$.txt"
    cat > "$test_file" << 'EOF'
# Valid apps
com.apple.safari
com.google.chrome

# Invalid entries
invalid
com.app@test
.com.app
com..app

# More valid
com.microsoft.edge
EOF
    
    run process_bundle_ids "$test_file"
    
    # Should report validation results
    assert_output_contains "✓"
    assert_output_contains "✗"
    
    # Clean up
    rm -f "$test_file"
}

@test "process_bundle_ids: shows line numbers for invalid Bundle IDs" {
    local test_file="${BATS_TMPDIR}/test_line_numbers_$$.txt"
    cat > "$test_file" << 'EOF'
com.apple.safari
invalid
com.google.chrome
EOF
    
    run process_bundle_ids "$test_file"
    
    # Should show line number for invalid entry
    assert_output_contains "Line 2"
    assert_output_contains "invalid"
    
    rm -f "$test_file"
}

@test "process_bundle_ids: shows specific error reason for each invalid Bundle ID" {
    local test_file="${BATS_TMPDIR}/test_reasons_$$.txt"
    cat > "$test_file" << 'EOF'
invalid
com.app@test
.com.app
com..app
EOF
    
    run process_bundle_ids "$test_file"
    
    # Should show specific reasons
    assert_output_contains "not enough segments"
    assert_output_contains "invalid characters"
    assert_output_contains "starts with dot"
    assert_output_contains "consecutive dots"
    
    rm -f "$test_file"
}

@test "process_bundle_ids: displays validation statistics summary" {
    local test_file="${BATS_TMPDIR}/test_stats_$$.txt"
    cat > "$test_file" << 'EOF'
# Comment line
com.apple.safari
invalid
com.google.chrome

com.app@test
EOF
    
    run process_bundle_ids "$test_file"
    
    # Should show statistics (case-insensitive check)
    assert_output_contains "Valid"
    assert_output_contains "Invalid"
    assert_output_contains "Comment"
    assert_output_contains "Empty"
    
    rm -f "$test_file"
}

@test "process_bundle_ids: tracks valid count correctly" {
    local test_file="${BATS_TMPDIR}/test_valid_count_$$.txt"
    cat > "$test_file" << 'EOF'
com.apple.safari
com.google.chrome
com.microsoft.edge
EOF
    
    run process_bundle_ids "$test_file"
    
    # Should show 3 valid
    assert_output_contains "3"
    assert_output_contains "Valid"
    
    rm -f "$test_file"
}

@test "process_bundle_ids: tracks invalid count correctly" {
    local test_file="${BATS_TMPDIR}/test_invalid_count_$$.txt"
    cat > "$test_file" << 'EOF'
com.apple.safari
invalid
com.app@test
EOF
    
    run process_bundle_ids "$test_file"
    
    # Should show 2 invalid
    assert_output_contains "2"
    assert_output_contains "Invalid"
    
    rm -f "$test_file"
}

@test "process_bundle_ids: tracks comment count correctly" {
    local test_file="${BATS_TMPDIR}/test_comment_count_$$.txt"
    cat > "$test_file" << 'EOF'
# Comment 1
com.apple.safari
# Comment 2
# Comment 3
com.google.chrome
EOF
    
    run process_bundle_ids "$test_file"
    
    # Should show 3 comments
    assert_output_contains "3"
    assert_output_contains "Comment"
    
    rm -f "$test_file"
}

@test "process_bundle_ids: tracks empty line count correctly" {
    local test_file="${BATS_TMPDIR}/test_empty_count_$$.txt"
    cat > "$test_file" << 'EOF'
com.apple.safari

com.google.chrome

EOF
    
    run process_bundle_ids "$test_file"
    
    # Should show 2 empty lines
    assert_output_contains "2"
    assert_output_contains "Empty"
    
    rm -f "$test_file"
}

@test "process_bundle_ids: exits with code 3 when no valid Bundle IDs found" {
    local test_file="${BATS_TMPDIR}/test_no_valid_$$.txt"
    cat > "$test_file" << 'EOF'
# Only comments
invalid
com.app@test
EOF
    
    run process_bundle_ids "$test_file"
    
    assert_failure 3
    assert_output_contains "No valid Bundle IDs"
    
    rm -f "$test_file"
}

@test "process_bundle_ids: creates validated_bundle_ids array with only valid IDs" {
    local test_file="${BATS_TMPDIR}/test_validated_array_$$.txt"
    cat > "$test_file" << 'EOF'
com.apple.safari
invalid
com.google.chrome
com.app@test
com.microsoft.edge
EOF
    
    # Run the function (don't use 'run' so we can access the array)
    # Redirect stderr to avoid cluttering test output
    process_bundle_ids "$test_file" >/dev/null 2>&1 || true
    
    # Check that validated_bundle_ids contains only valid IDs
    assert_array_length "validated_bundle_ids" 3
    assert_array_contains "validated_bundle_ids" "com.apple.safari"
    assert_array_contains "validated_bundle_ids" "com.google.chrome"
    assert_array_contains "validated_bundle_ids" "com.microsoft.edge"
    
    rm -f "$test_file"
}