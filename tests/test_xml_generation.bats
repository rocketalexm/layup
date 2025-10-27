#!/usr/bin/env bats
# tests/test_xml_generation.bats
# Tests for XML generation functionality (Phase 2.4)

load 'helpers/mocks'
load 'helpers/assertions'

setup() {
    # Reset mocks before each test
    reset_mock_calls
    
    # Path to the script
    SCRIPT_PATH="${BATS_TEST_DIRNAME}/../layup.sh"
}

teardown() {
    # Clean up after each test
    cleanup_mocks
}

# =============================================================================
# Subtask 2.4.1: Dynamic Value Generation Tests
# =============================================================================

@test "generate_uuid: returns valid UUID format" {
    # Mock uuidgen to return a known UUID
    mock_uuidgen "12345678-1234-1234-1234-123456789012"
    
    source "$SCRIPT_PATH"
    result=$(generate_uuid)
    
    assert_equals "$result" "12345678-1234-1234-1234-123456789012"
}

@test "generate_uuid: calls uuidgen command" {
    # Mock uuidgen and verify it's called
    mock_uuidgen "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
    
    source "$SCRIPT_PATH"
    result=$(generate_uuid)
    
    # Verify the mock was called by checking the result
    assert_equals "$result" "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
}

@test "generate_uuid: multiple calls return different UUIDs" {
    source "$SCRIPT_PATH"
    
    # Mock uuidgen to return different values on each call
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222" \
                          "33333333-3333-3333-3333-333333333333"
    
    uuid1=$(generate_uuid)
    uuid2=$(generate_uuid)
    uuid3=$(generate_uuid)
    
    # Verify all three are different
    assert_not_equals "$uuid1" "$uuid2"
    assert_not_equals "$uuid2" "$uuid3"
    assert_not_equals "$uuid1" "$uuid3"
}

@test "generate_timestamp: returns correct format YYYYMMDD_HHMMSS" {
    # Mock date command to return a known timestamp
    mock_date "20251026_143022"
    
    source "$SCRIPT_PATH"
    result=$(generate_timestamp)
    
    assert_equals "$result" "20251026_143022"
}

# =============================================================================
# Subtask 2.4.2: XML Escaping & App Dictionary Tests
# =============================================================================

@test "xml_escape: escapes ampersand" {
    source "$SCRIPT_PATH"
    
    result=$(xml_escape "AT&T")
    assert_equals "$result" "AT&amp;T"
}

@test "xml_escape: escapes less than" {
    source "$SCRIPT_PATH"
    
    result=$(xml_escape "a<b")
    assert_equals "$result" "a&lt;b"
}

@test "xml_escape: escapes greater than" {
    source "$SCRIPT_PATH"
    
    result=$(xml_escape "a>b")
    assert_equals "$result" "a&gt;b"
}

@test "xml_escape: escapes double quote" {
    source "$SCRIPT_PATH"
    
    result=$(xml_escape 'say "hello"')
    assert_equals "$result" "say &quot;hello&quot;"
}

@test "xml_escape: escapes single quote" {
    source "$SCRIPT_PATH"
    
    result=$(xml_escape "it's")
    assert_equals "$result" "it&apos;s"
}

@test "xml_escape: escapes ampersand first to avoid double-escaping" {
    source "$SCRIPT_PATH"
    
    # If we have &< and escape & first, we get &amp;<
    # Then escaping < gives us &amp;&lt;
    # If we escaped < first, we'd get &<, then &amp;&lt; (wrong!)
    result=$(xml_escape "&<")
    assert_equals "$result" "&amp;&lt;"
}

@test "xml_escape: escapes all special characters together" {
    source "$SCRIPT_PATH"
    
    result=$(xml_escape "a&b<c>d\"e'f")
    assert_equals "$result" "a&amp;b&lt;c&gt;d&quot;e&apos;f"
}

@test "xml_escape: handles string with no special characters" {
    source "$SCRIPT_PATH"
    
    result=$(xml_escape "com.apple.mobilesafari")
    assert_equals "$result" "com.apple.mobilesafari"
}

@test "generate_app_dictionary: creates valid app dictionary structure" {
    source "$SCRIPT_PATH"
    
    result=$(generate_app_dictionary "com.apple.mobilesafari")
    
    # Check for required keys using grep
    echo "$result" | grep -q "Type" || return 1
    echo "$result" | grep -q "Application" || return 1
    echo "$result" | grep -q "BundleID" || return 1
    echo "$result" | grep -q "com.apple.mobilesafari" || return 1
}

@test "generate_app_dictionary: uses proper indentation" {
    source "$SCRIPT_PATH"
    
    result=$(generate_app_dictionary "com.apple.mobilesafari")
    
    # Check for proper indentation (4 spaces per level)
    echo "$result" | grep -q "    <dict>" || return 1
    echo "$result" | grep -q "        <key>Type</key>" || return 1
    echo "$result" | grep -q "        <string>Application</string>" || return 1
}

@test "generate_app_dictionary: escapes Bundle ID with special characters" {
    source "$SCRIPT_PATH"
    
    result=$(generate_app_dictionary "com.company&app")
    
    # Bundle ID should be escaped
    echo "$result" | grep -q "com.company&amp;app" || return 1
}

@test "generate_app_dictionary: complete structure matches specification" {
    source "$SCRIPT_PATH"
    
    result=$(generate_app_dictionary "com.test.app")
    
    # Verify complete structure
    expected="    <dict>
        <key>Type</key>
        <string>Application</string>
        <key>BundleID</key>
        <string>com.test.app</string>
    </dict>"
    
    assert_equals "$result" "$expected"
}

# =============================================================================
# Subtask 2.4.3: Complete XML Structure & Validation Tests
# =============================================================================

@test "generate_xml: includes XML declaration" {
    source "$SCRIPT_PATH"
    
    # Mock UUID and timestamp
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    echo "$result" | grep -q '<?xml version="1.0" encoding="UTF-8"?>' || return 1
}

@test "generate_xml: includes DOCTYPE declaration" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    echo "$result" | grep -q '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"' || return 1
    echo "$result" | grep -q 'http://www.apple.com/DTDs/PropertyList-1.0.dtd' || return 1
}

@test "generate_xml: outer payload has Configuration type" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    # Check for outer Configuration payload
    echo "$result" | grep -q '<key>PayloadType</key>' || return 1
    echo "$result" | grep -q '<string>Configuration</string>' || return 1
}

@test "generate_xml: outer payload has all required keys" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    # Check for all required outer payload keys
    echo "$result" | grep -q '<key>PayloadVersion</key>' || return 1
    echo "$result" | grep -q '<key>PayloadIdentifier</key>' || return 1
    echo "$result" | grep -q '<key>PayloadUUID</key>' || return 1
    echo "$result" | grep -q '<key>PayloadDisplayName</key>' || return 1
    echo "$result" | grep -q '<key>PayloadDescription</key>' || return 1
    echo "$result" | grep -q '<key>PayloadOrganization</key>' || return 1
    echo "$result" | grep -q '<key>PayloadRemovalDisallowed</key>' || return 1
}

@test "generate_xml: inner payload has home screen layout type" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    # Check for inner home screen layout payload
    echo "$result" | grep -q '<string>com.apple.homescreenlayout.managed</string>' || return 1
}

@test "generate_xml: includes PayloadContent array" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    echo "$result" | grep -q '<key>PayloadContent</key>' || return 1
    echo "$result" | grep -q '<array>' || return 1
}

@test "generate_xml: includes Dock and Pages keys" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    echo "$result" | grep -q '<key>Dock</key>' || return 1
    echo "$result" | grep -q '<key>Pages</key>' || return 1
}

@test "generate_xml: includes app dictionary in Pages array" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    # Check that the app dictionary is present
    echo "$result" | grep -q '<key>BundleID</key>' || return 1
    echo "$result" | grep -q '<string>com.apple.mobilesafari</string>' || return 1
}

@test "generate_xml: handles multiple Bundle IDs" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari" "com.apple.mobilemail")
    
    # Check that both apps are present
    echo "$result" | grep -q 'com.apple.mobilesafari' || return 1
    echo "$result" | grep -q 'com.apple.mobilemail' || return 1
}

@test "generate_xml: uses unique UUIDs for outer and inner payloads" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA" \
                          "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    # Check that both UUIDs are present
    echo "$result" | grep -q 'AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA' || return 1
    echo "$result" | grep -q 'BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB' || return 1
}

@test "generate_xml: escapes Bundle IDs with special characters" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.company&app")
    
    # Bundle ID should be escaped
    echo "$result" | grep -q 'com.company&amp;app' || return 1
}

@test "generate_xml: proper XML structure with plist tags" {
    source "$SCRIPT_PATH"
    
    mock_uuidgen_sequence "11111111-1111-1111-1111-111111111111" \
                          "22222222-2222-2222-2222-222222222222"
    mock_date "20251026_143022"
    
    result=$(generate_xml "com.apple.mobilesafari")
    
    # Check for proper plist structure
    echo "$result" | grep -q '<plist version="1.0">' || return 1
    echo "$result" | grep -q '</plist>' || return 1
}

@test "generate_timestamp: calls date with correct format" {
    # Mock date command
    mock_date "20231215_091530"
    
    source "$SCRIPT_PATH"
    result=$(generate_timestamp)
    
    # Verify format: 8 digits, underscore, 6 digits
    assert_matches "$result" "^[0-9]{8}_[0-9]{6}$"
}

@test "generate_timestamp: format matches specification" {
    mock_date "20251026_143022"
    
    source "$SCRIPT_PATH"
    result=$(generate_timestamp)
    
    # Verify exact format
    assert_equals "$result" "20251026_143022"
    # Verify length (15 characters: 8 + 1 + 6)
    assert_equals "${#result}" "15"
}