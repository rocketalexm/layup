#!/bin/bash
#
# Layup - Home Screen Layout Configuration Generator
# Version: 1.0.0
# Copyright (c) 2025 Layup Contributors
# 
# Licensed under the MIT License
# https://opensource.org/licenses/MIT
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# ---
# 
# INTENDED USE:
# This is sample code for educational purposes and demonstration of Apple MDM
# Home Screen Layout payload generation. While production use is permitted under
# the MIT License, this tool is designed as a learning resource and starting point
# for custom tooling. See README for production use considerations.
#
# Description: Generates Apple MDM Home Screen Layout .mobileconfig files
#              from plain text Bundle ID lists.
#
# Usage: ./layup.sh <input_file> [output_file]
#        ./layup.sh --help
#
# Requirements: macOS 10.15+, bash 3.2+, xmllint
#

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script version
VERSION="1.0.0"

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_FILE_NOT_FOUND=1
readonly EXIT_EMPTY_FILE=2
readonly EXIT_NO_VALID_IDS=3
readonly EXIT_WRITE_ERROR=4
readonly EXIT_VALIDATION_ERROR=5

# Pattern definitions for content filtering
readonly COMMENT_PATTERN='^[[:space:]]*#'
readonly EMPTY_PATTERN='^[[:space:]]*$'

# State management arrays and counters
declare -a raw_lines=()
declare -a valid_bundle_ids=()
declare -a validated_bundle_ids=()
declare -i line_number=0
declare -i total_lines=0
declare -i valid_count=0
declare -i invalid_count=0
declare -i comment_count=0
declare -i empty_count=0

#######################################
# Display help text
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes help text to stdout
#######################################
show_help() {
    cat << 'EOF'
Layup - Home Screen Layout Configuration Generator

USAGE:
    layup.sh <input_file> [output_file]

DESCRIPTION:
    Generates a Home Screen Layout configuration profile (.mobileconfig)
    from a plain text file containing app Bundle IDs for uploading to an MDM.

ARGUMENTS:
    input_file     Path to text file containing Bundle IDs (one per line)
    output_file    Optional: Custom output path (default: HomeScreenLayout_[timestamp].mobileconfig)

INPUT FILE FORMAT:
    - One Bundle ID per line (format: com.company.app)
    - Comments start with # and are ignored
    - Empty lines are ignored
    - Order in file determines position on Home Screen

EXAMPLE:
    # Create configuration with default output name
    ./layup.sh apps.txt

    # Create configuration with custom output name
    ./layup.sh apps.txt my_layout.mobileconfig

    # View this help message
    ./layup.sh --help

SAMPLE INPUT FILE (apps.txt):
    # Communication apps
    com.apple.mobilesafari
    com.apple.mobilemail
    com.apple.MobileSMS
    
    # Productivity apps
    com.microsoft.Office.Outlook
    com.google.chrome.ios

EXIT CODES:
    0    Success or user cancelled overwrite
    1    Input file not found
    2    Input file is empty
    3    No valid Bundle IDs found
    4    Cannot write output file
    5    XML validation failed

For more information, visit: https://github.com/[username]/layup
EOF
}

#######################################
# Display error message to stderr
# Globals:
#   None
# Arguments:
#   $1 - Error message
#   $2 - Optional suggestion
# Outputs:
#   Writes error message to stderr
#######################################
error_exit() {
    local message="$1"
    local suggestion="${2:-}"
    
    echo "ERROR: ${message}" >&2
    if [ -n "$suggestion" ]; then
        echo "$suggestion" >&2
    fi
}

#######################################
# Parse command-line arguments
# Globals:
#   INPUT_FILE
#   OUTPUT_FILE
# Arguments:
#   $@ - All command-line arguments
# Returns:
#   0 on success, exits with error code on failure
#######################################
parse_arguments() {
    # Check for help flag in any position
    for arg in "$@"; do
        if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
            show_help
            exit "$EXIT_SUCCESS"
        fi
    done
    
    # Check if at least one argument provided
    if [ $# -eq 0 ]; then
        error_exit "Missing required argument: input file" \
                   "Usage: layup.sh <input_file> [output_file]"
        exit "$EXIT_FILE_NOT_FOUND"
    fi
    
    # Set input file (first argument)
    INPUT_FILE="$1"
    
    # Set output file (second argument, optional)
    if [ $# -ge 2 ]; then
        OUTPUT_FILE="$2"
    else
        # Generate default output filename with timestamp
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        OUTPUT_FILE="HomeScreenLayout_${timestamp}.mobileconfig"
    fi
}

#######################################
# Validate input file exists and is readable
# Globals:
#   INPUT_FILE
#   EXIT_FILE_NOT_FOUND
# Arguments:
#   None
# Returns:
#   0 if file exists and is readable, exits with error code otherwise
#######################################
validate_input_file() {
    if [ ! -f "$INPUT_FILE" ]; then
        error_exit "Input file '${INPUT_FILE}' not found" \
                   "Please check the filename and try again."
        exit "$EXIT_FILE_NOT_FOUND"
    fi
    
    if [ ! -r "$INPUT_FILE" ]; then
        error_exit "Input file '${INPUT_FILE}' is not readable" \
                   "Please check file permissions."
        exit "$EXIT_FILE_NOT_FOUND"
    fi
}

#######################################
# Read and parse input file
# Globals:
#   INPUT_FILE
#   raw_lines
#   valid_bundle_ids
#   line_number
#   total_lines
#   comment_count
#   empty_count
#   EXIT_EMPTY_FILE
# Arguments:
#   None
# Returns:
#   0 on success, exits with error code on failure
#######################################
read_input_file() {
    local line
    local trimmed_line
    local has_content=0
    
    # Reset counters
    line_number=0
    total_lines=0
    comment_count=0
    empty_count=0
    raw_lines=()
    valid_bundle_ids=()
    
    # Read file line by line
    while IFS= read -r line || [[ -n "$line" ]]; do
        total_lines=$((total_lines + 1))
        line_number=$((line_number + 1))
        
        # Store raw line for potential error reporting
        raw_lines+=("$line")
        
        # Remove carriage return (for Windows CRLF line endings)
        line="${line%$'\r'}"
        
        # Trim leading whitespace using bash parameter expansion
        trimmed_line="$line"
        while [[ "$trimmed_line" =~ ^[[:space:]] ]]; do
            trimmed_line="${trimmed_line#[[:space:]]}"
        done
        
        # Trim trailing whitespace using bash parameter expansion
        while [[ "$trimmed_line" =~ [[:space:]]$ ]]; do
            trimmed_line="${trimmed_line%[[:space:]]}"
        done
        
        # Skip empty lines
        if [[ -z "$trimmed_line" ]]; then
            empty_count=$((empty_count + 1))
            continue
        fi
        
        # Skip comments (lines starting with #)
        if [[ "$trimmed_line" =~ ^# ]]; then
            comment_count=$((comment_count + 1))
            continue
        fi
        
        # We have at least one non-comment, non-empty line
        has_content=1
        
        # Store the trimmed line for validation (Phase 2.3)
        # For now, just collect them
        valid_bundle_ids+=("$trimmed_line")
        
    done < "$INPUT_FILE"
    
    # Check if file had any content after filtering
    if [[ $has_content -eq 0 ]]; then
        error_exit "Input file '${INPUT_FILE}' is empty or contains no valid content" \
                   "Please add at least one Bundle ID to the file."
        exit "$EXIT_EMPTY_FILE"
    fi
    
    return 0
}

#######################################
# Validate a Bundle ID format
# Globals:
#   None
# Arguments:
#   $1 - Bundle ID to validate
# Returns:
#   0 if valid, 1 if invalid
#######################################
validate_bundle_id() {
    local bundle_id="$1"
    
    # Bundle ID pattern: ^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$
    # - Must have at least 2 segments separated by dots
    # - Each segment can contain: letters, numbers, underscore, hyphen
    # - Cannot start or end with a dot
    # - Cannot have consecutive dots
    
    # Check if Bundle ID matches the pattern
    if [[ "$bundle_id" =~ ^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$ ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Validate a Bundle ID format with detailed reason for failure
# Globals:
#   None
# Arguments:
#   $1 - Bundle ID to validate
# Outputs:
#   Writes failure reason to stdout if invalid
# Returns:
#   0 if valid, 1 if invalid
#######################################
validate_bundle_id_with_reason() {
    local bundle_id="$1"
    
    # Check for whitespace (spaces, tabs, newlines)
    if [[ "$bundle_id" =~ [[:space:]] ]]; then
        echo "contains whitespace"
        return 1
    fi
    
    # Check if starts with dot
    if [[ "$bundle_id" =~ ^\. ]]; then
        echo "starts with dot"
        return 1
    fi
    
    # Check if ends with dot
    if [[ "$bundle_id" =~ \.$ ]]; then
        echo "ends with dot"
        return 1
    fi
    
    # Check for consecutive dots
    if [[ "$bundle_id" =~ \.\. ]]; then
        echo "consecutive dots"
        return 1
    fi
    
    # Check for invalid characters (anything not a-z, A-Z, 0-9, _, -, or .)
    if [[ "$bundle_id" =~ [^a-zA-Z0-9_.-] ]]; then
        echo "invalid characters"
        return 1
    fi
    
    # Count segments (split by dots)
    local segment_count=0
    local IFS='.'
    local -a segments
    read -ra segments <<< "$bundle_id"
    segment_count=${#segments[@]}
    
    # Check for minimum 2 segments
    if [[ $segment_count -lt 2 ]]; then
        echo "not enough segments"
        return 1
    fi
    
    # If all checks pass, it's valid
    return 0
}

#######################################
# Process and validate Bundle IDs from file
# Globals:
#   valid_bundle_ids (input array from read_input_file)
#   validated_bundle_ids (output array)
#   valid_count
#   invalid_count
#   comment_count
#   empty_count
#   raw_lines
#   EXIT_NO_VALID_IDS
# Arguments:
#   $1 - Input file path (optional, for testing)
# Outputs:
#   Writes validation results to stderr
# Returns:
#   0 if at least one valid Bundle ID found, exits with code 3 otherwise
#######################################
process_bundle_ids() {
    local input_file="${1:-$INPUT_FILE}"
    
    # Reset counters and arrays
    valid_count=0
    invalid_count=0
    validated_bundle_ids=()
    
    # If input file is provided, read it first
    if [[ -n "$input_file" ]]; then
        INPUT_FILE="$input_file"
        read_input_file
    fi
    
    # Process each Bundle ID from valid_bundle_ids array
    local idx=0
    local original_line_num=0
    
    # We need to track which line number each bundle ID came from
    # Re-read the file to get line numbers
    line_number=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_number=$((line_number + 1))
        
        # Remove carriage return
        line="${line%$'\r'}"
        
        # Trim whitespace
        local trimmed_line="$line"
        while [[ "$trimmed_line" =~ ^[[:space:]] ]]; do
            trimmed_line="${trimmed_line#[[:space:]]}"
        done
        while [[ "$trimmed_line" =~ [[:space:]]$ ]]; do
            trimmed_line="${trimmed_line%[[:space:]]}"
        done
        
        # Skip empty lines and comments
        if [[ -z "$trimmed_line" ]] || [[ "$trimmed_line" =~ ^# ]]; then
            continue
        fi
        
        # Validate the Bundle ID
        local reason
        reason=$(validate_bundle_id_with_reason "$trimmed_line")
        local validation_result=$?
        
        if [[ $validation_result -eq 0 ]]; then
            # Valid Bundle ID
            echo "✓ Line $line_number: $trimmed_line (valid)" >&2
            validated_bundle_ids+=("$trimmed_line")
            valid_count=$((valid_count + 1))
        else
            # Invalid Bundle ID
            echo "✗ Line $line_number: $trimmed_line (invalid format: $reason)" >&2
            invalid_count=$((invalid_count + 1))
        fi
        
    done < "$input_file"
    
    # Display statistics summary
    echo "" >&2
    echo "Validation Summary:" >&2
    echo "  Valid Bundle IDs: $valid_count" >&2
    echo "  Invalid Bundle IDs: $invalid_count" >&2
    echo "  Comments: $comment_count" >&2
    echo "  Empty lines: $empty_count" >&2
    echo "" >&2
    
    # Check if we have any valid Bundle IDs
    if [[ $valid_count -eq 0 ]]; then
        error_exit "No valid Bundle IDs found in input file" \
                   "Please check the file format and try again."
        exit "$EXIT_NO_VALID_IDS"
    fi
    
    return 0
}

#######################################
# Generate a UUID using uuidgen command
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes UUID to stdout
# Returns:
#   0 on success
#######################################
generate_uuid() {
    uuidgen
}

#######################################
# Generate a timestamp in YYYYMMDD_HHMMSS format
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes timestamp to stdout
# Returns:
#   0 on success
#######################################
generate_timestamp() {
    date +%Y%m%d_%H%M%S
}

#######################################
# Escape XML special characters
# Globals:
#   None
# Arguments:
#   $1 - String to escape
# Outputs:
#   Writes escaped string to stdout
# Returns:
#   0 on success
#######################################
xml_escape() {
    local input="$1"
    
    # CRITICAL: Escape ampersand FIRST to avoid double-escaping
    # Use sed for reliable character replacement
    echo "$input" | sed \
        -e 's/&/\&amp;/g' \
        -e 's/</\&lt;/g' \
        -e 's/>/\&gt;/g' \
        -e 's/"/\&quot;/g' \
        -e "s/'/\&apos;/g"
}

#######################################
# Generate an app dictionary XML block
# Globals:
#   None
# Arguments:
#   $1 - Bundle ID
# Outputs:
#   Writes app dictionary XML to stdout
# Returns:
#   0 on success
#######################################
generate_app_dictionary() {
    local bundle_id="$1"
    local escaped_bundle_id
    
    # Escape the Bundle ID for XML
    escaped_bundle_id=$(xml_escape "$bundle_id")
    
    # Generate the app dictionary with proper indentation (4 spaces per level)
    cat << EOF
    <dict>
        <key>Type</key>
        <string>Application</string>
        <key>BundleID</key>
        <string>${escaped_bundle_id}</string>
    </dict>
EOF
}

#######################################
# Generate complete XML configuration
# Globals:
#   None
# Arguments:
#   $@ - Array of Bundle IDs
# Outputs:
#   Writes complete XML to stdout
# Returns:
#   0 on success
#######################################
generate_xml() {
    local -a bundle_ids=("$@")
    
    # Generate UUIDs for outer and inner payloads
    local outer_uuid
    local inner_uuid
    outer_uuid=$(generate_uuid)
    inner_uuid=$(generate_uuid)
    
    # Generate timestamp (not used in XML, but available for filename)
    local timestamp
    timestamp=$(generate_timestamp)
    
    # Start building the XML
    cat << 'EOF_HEADER'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Outer Configuration Profile -->
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadIdentifier</key>
EOF_HEADER
    echo "    <string>com.layup.config.${outer_uuid}</string>"
    cat << 'EOF_OUTER_UUID'
    <key>PayloadUUID</key>
EOF_OUTER_UUID
    echo "    <string>${outer_uuid}</string>"
    cat << 'EOF_OUTER_REST'
    <key>PayloadDisplayName</key>
    <string>Home Screen Layout Configuration</string>
    <key>PayloadDescription</key>
    <string>Generated by Layup</string>
    <key>PayloadOrganization</key>
    <string>Layup</string>
    <key>PayloadRemovalDisallowed</key>
    <false/>
    
    <!-- Inner Home Screen Layout Payload -->
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.homescreenlayout.managed</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PayloadIdentifier</key>
EOF_OUTER_REST
    echo "            <string>com.layup.homescreenlayout.${inner_uuid}</string>"
    cat << 'EOF_INNER_UUID'
            <key>PayloadUUID</key>
EOF_INNER_UUID
    echo "            <string>${inner_uuid}</string>"
    cat << 'EOF_INNER_REST'
            <key>PayloadDisplayName</key>
            <string>Home Screen Layout</string>
            <key>PayloadDescription</key>
            <string>Managed home screen layout</string>
            <key>Dock</key>
            <array/>
            <key>Pages</key>
            <array>
                <array>
EOF_INNER_REST
    
    # Generate app dictionaries for each Bundle ID
    for bundle_id in "${bundle_ids[@]}"; do
        generate_app_dictionary "$bundle_id"
    done
    
    # Close the XML structure
    cat << 'EOF_FOOTER'
                </array>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF_FOOTER
}

#######################################
# Generate output filename with optional custom path
# Globals:
#   None
# Arguments:
#   $1 - Optional custom output path
# Outputs:
#   Writes filename to stdout
# Returns:
#   0 on success
#######################################
generate_output_filename() {
    local custom_path="${1:-}"
    
    # If custom path provided, use it
    if [[ -n "$custom_path" ]]; then
        # Check if it already has .mobileconfig extension
        if [[ "$custom_path" != *.mobileconfig ]]; then
            echo "${custom_path}.mobileconfig"
        else
            echo "$custom_path"
        fi
    else
        # Generate default filename with timestamp
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S)
        echo "HomeScreenLayout_${timestamp}.mobileconfig"
    fi
}

#######################################
# Validate output directory exists and is writable
# Globals:
#   EXIT_WRITE_ERROR
# Arguments:
#   $1 - Output file path
# Outputs:
#   Writes error message to stderr on failure
# Returns:
#   0 if directory is valid, exits with EXIT_WRITE_ERROR otherwise
#######################################
validate_output_directory() {
    local output_path="$1"
    local output_dir
    
    # Extract directory from path
    output_dir=$(dirname "$output_path")
    
    # Check if directory exists
    if [[ ! -d "$output_dir" ]]; then
        error_exit "Directory does not exist: ${output_dir}" \
                   "Please create the directory or use a different path."
        exit "$EXIT_WRITE_ERROR"
    fi
    
    # Check if directory is writable
    if [[ ! -w "$output_dir" ]]; then
        error_exit "Directory is not writable: ${output_dir}" \
                   "Please check directory permissions."
        exit "$EXIT_WRITE_ERROR"
    fi
    
    return 0
}

#######################################
# Prompt user for file overwrite confirmation
# Globals:
#   None
# Arguments:
#   $1 - Filename to display in prompt
# Outputs:
#   Writes prompt to stdout, reads from stdin
# Returns:
#   0 if user confirms (y/Y), 1 if user cancels (n/N)
#######################################
prompt_overwrite() {
    local filename="$1"
    local response
    
    while true; do
        # Prompt goes to stdout for user interaction
        echo -n "File '${filename}' already exists. Overwrite? (y/n): "
        read -r response
        
        case "$response" in
            y|Y)
                return 0
                ;;
            n|N)
                return 1
                ;;
            *)
                echo "Invalid input. Please enter 'y' or 'n'."
                ;;
        esac
    done
}

#######################################
# Check if file exists and prompt for overwrite if needed
# Globals:
#   None
# Arguments:
#   $1 - Output file path
# Outputs:
#   Writes prompt to stdout if file exists
# Returns:
#   0 if file doesn't exist or user confirms overwrite
#   1 if user cancels overwrite
#######################################
check_file_exists_and_prompt() {
    local output_file="$1"
    
    # If file doesn't exist, proceed
    if [[ ! -f "$output_file" ]]; then
        return 0
    fi
    
    # File exists, prompt user
    if prompt_overwrite "$output_file"; then
        return 0
    else
        return 1
    fi
}

#######################################
# Write content to output file with proper encoding and permissions
# Globals:
#   EXIT_WRITE_ERROR
# Arguments:
#   $1 - Output file path
#   $2 - Content to write
# Outputs:
#   Writes error message to stderr on failure
# Returns:
#   0 on success, exits with EXIT_WRITE_ERROR on failure
#######################################
write_output_file() {
    local output_file="$1"
    local content="$2"
    local output_dir
    
    # Extract directory from path
    output_dir=$(dirname "$output_file")
    
    # Create parent directories if they don't exist
    if [[ ! -d "$output_dir" ]]; then
        if ! mkdir -p "$output_dir" 2>/dev/null; then
            error_exit "Cannot create directory: ${output_dir}" \
                       "Please check permissions."
            exit "$EXIT_WRITE_ERROR"
        fi
    fi
    
    # Check if directory is writable
    if [[ ! -w "$output_dir" ]]; then
        error_exit "Directory is not writable: ${output_dir}" \
                   "Please check directory permissions."
        exit "$EXIT_WRITE_ERROR"
    fi
    
    # Write content to file (UTF-8 encoding is default for bash)
    if ! echo "$content" > "$output_file" 2>/dev/null; then
        error_exit "Cannot write to file: ${output_file}" \
                   "Please check permissions and disk space."
        exit "$EXIT_WRITE_ERROR"
    fi
    
    # Set file permissions to 644 (rw-r--r--)
    if ! chmod 644 "$output_file" 2>/dev/null; then
        error_exit "Cannot set file permissions: ${output_file}" \
                   "File was created but permissions could not be set."
        exit "$EXIT_WRITE_ERROR"
    fi
    
    return 0
}

#######################################
# Validate XML file using xmllint
# Globals:
#   EXIT_VALIDATION_ERROR
# Arguments:
#   $1 - XML file path
# Outputs:
#   Writes error message to stderr on failure
# Returns:
#   0 on success, exits with EXIT_VALIDATION_ERROR on failure
#######################################
validate_xml() {
    local xml_file="$1"
    
    # Validate XML using xmllint
    if ! xmllint --noout "$xml_file" 2>/dev/null; then
        error_exit "XML validation failed for: ${xml_file}" \
                   "The generated XML is malformed. This is an internal error."
        exit "$EXIT_VALIDATION_ERROR"
    fi
    
    return 0
}

#######################################
# Open file in Finder (macOS only)
# Globals:
#   None
# Arguments:
#   $1 - File path to reveal in Finder
# Outputs:
#   None (errors are silently ignored)
# Returns:
#   0 (always succeeds, even if open fails)
#######################################
open_in_finder() {
    local file_path="$1"
    
    # Try to open in Finder, but don't fail if it doesn't work
    # This is a convenience feature, not critical to operation
    open -R "$file_path" 2>/dev/null || true
    
    return 0
}

#######################################
# Display success message with file path
# Globals:
#   None
# Arguments:
#   $1 - Output file path
# Outputs:
#   Writes success message to stdout
# Returns:
#   0 on success
#######################################
display_success_message() {
    local output_file="$1"
    
    # Display success message
    echo "✓ Success! Configuration profile generated."
    echo "Output file: ${output_file}"
    
    return 0
}

#######################################
# Main function
# Globals:
#   All global variables
# Arguments:
#   $@ - All command-line arguments
# Returns:
#   Exit code based on success or failure
#######################################
main() {
    # Phase 2.1: Parse command-line arguments
    parse_arguments "$@"
    
    # Phase 2.1: Validate input file exists
    validate_input_file
    
    # Phase 2.2: Read and parse input file
    read_input_file
    
    # Phase 2.3: Validate Bundle IDs
    process_bundle_ids
    
    # Phase 2.4: Generate XML from validated Bundle IDs
    local xml_content
    xml_content=$(generate_xml "${validated_bundle_ids[@]}")
    
    # Phase 2.5: File Output & Validation
    
    # Ensure output filename has correct extension
    OUTPUT_FILE=$(generate_output_filename "$OUTPUT_FILE")
    
    # Validate output directory exists and is writable
    validate_output_directory "$OUTPUT_FILE"
    
    # Check if file exists and prompt for overwrite if needed
    if ! check_file_exists_and_prompt "$OUTPUT_FILE"; then
        echo "Operation cancelled by user." >&2
        exit "$EXIT_SUCCESS"
    fi
    
    # Write XML content to file
    write_output_file "$OUTPUT_FILE" "$xml_content"
    
    # Validate the generated XML
    validate_xml "$OUTPUT_FILE"
    
    # Open file in Finder (non-critical, won't fail if it doesn't work)
    open_in_finder "$OUTPUT_FILE"
    
    # Display success message
    display_success_message "$OUTPUT_FILE"
    
    exit "$EXIT_SUCCESS"
}

# Run main function with all arguments (only if not being sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi