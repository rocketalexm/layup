# Layup - Product Requirements Document (PRD)

**Version:** 1.0 (MVP)  
**Date:** October 26, 2025  
**Status:** Draft - Ready for Development  
**Document Owner:** Product Management  

---

## Executive Summary

Layup is a command-line tool that converts a simple text file containing iOS/iPadOS app Bundle IDs into a valid Apple MDM Home Screen Layout configuration profile (.mobileconfig). It eliminates the error-prone manual XML editing process that currently takes IT administrators 30-60 minutes per configuration.

**Core Value Proposition:** Transform hours of XML hand-crafting into a single command that completes in <1 second with zero syntax errors.

---

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Goals & Success Metrics](#goals--success-metrics)
3. [User Personas](#user-personas)
4. [Functional Requirements](#functional-requirements)
5. [Non-Functional Requirements](#non-functional-requirements)
6. [Technical Specifications](#technical-specifications)
7. [User Stories](#user-stories)
8. [Acceptance Criteria](#acceptance-criteria)
9. [Out of Scope](#out-of-scope)
10. [Dependencies & Assumptions](#dependencies--assumptions)
11. [Risk Assessment](#risk-assessment)
12. [Release Plan](#release-plan)

---

## Problem Statement

### Current State (Root Cause Analysis)

IT administrators and MDM specialists must manually create Home Screen Layout configuration profiles for iOS/iPadOS devices. This process involves:

1. Referencing Apple MDM Protocol documentation
2. Hand-crafting XML in text editors
3. Looking up exact Bundle IDs for each application
4. Maintaining precise XML structure and nesting
5. Testing deployment after completion
6. Debugging syntax errors and structural issues
7. Repeating the process for configuration updates

**Causal Chain:**
```
Manual XML editing → Syntax errors + Bundle ID mistakes → Failed deployments → 
Troubleshooting cycles → Rework → Delayed rollouts → IT productivity loss
```

**Root Causes:**
- **Complexity Barrier:** Home Screen Layout payloads require precise XML with nested arrays/dictionaries
- **Bundle ID Management:** Non-intuitive app identifiers must be looked up and typed exactly
- **Validation Gap:** No feedback on payload validity until MDM deployment attempt
- **High Error Rate:** ~40% of manual configurations require debugging on first attempt
- **Time Intensive:** 30-60 minutes per configuration for experienced admins

### Desired State

IT administrators execute a single command that:
- Takes a plain text list of Bundle IDs as input
- Generates a 100% valid .mobileconfig file
- Completes in <1 second
- Deploys successfully on first attempt
- Reduces configuration time by >80%

### Impact

**Quantitative:**
- Time savings: 30-60 minutes → <5 minutes per configuration
- Error reduction: ~40% error rate → 0% syntax errors
- Cost savings: ~$50-100 per configuration (at $100/hr IT labor rate)

**Qualitative:**
- Reduced frustration with XML editing
- Increased confidence in deployment success
- Faster device provisioning cycles
- More time for strategic IT initiatives

---

## Goals & Success Metrics

### Primary Goals

1. **Eliminate XML Hand-Crafting:** Provide zero-touch XML generation from simple input
2. **Achieve Zero-Error Output:** Every generated file deploys successfully without modification
3. **Maximize Time Savings:** Reduce configuration time by minimum 80%

### Success Metrics

#### Primary KPIs

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Deployment Success Rate** | 100% | Generated files deploy without MDM errors |
| **Time to Generate** | <5 minutes | User feedback, self-reported timing |
| **Script Execution Time** | <1 second | Built-in script timing for 20-app config |
| **XML Validity Rate** | 100% | All outputs pass Apple DTD validation |
| **Time Savings vs Manual** | >80% reduction | Baseline: 30-60 min → Target: <5 min |

#### Secondary KPIs

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **User Adoption** | 10+ unique users in first month | GitHub downloads/clones |
| **Repeat Usage** | >70% of users create 2+ configs | User surveys |
| **Error Rate in Input** | <10% invalid Bundle IDs per file | Script logs analysis |
| **Documentation Clarity** | <5% users require support | GitHub issues related to usage |

### Success Criteria

**MVP succeeds if:**
- ✅ 100% of generated files deploy successfully to MDM
- ✅ Average time from start to .mobileconfig output is <5 minutes
- ✅ Script executes in <1 second for typical 20-app configuration
- ✅ Zero reported critical bugs in XML structure
- ✅ Positive user feedback on time savings (qualitative)

**Failure indicators:**
- ❌ Any generated file fails MDM validation
- ❌ Script crashes or hangs during execution
- ❌ Time savings <50% compared to manual method
- ❌ Critical XML structure bug requiring emergency patch
- ❌ User reports script is more complex than manual XML

---

## User Personas

### Primary Persona: IT Administrator - "Alex"

**Background:**
- Role: IT Systems Administrator at mid-size company (500-2000 employees)
- Experience: 5+ years in IT, 2+ years with MDM
- Technical Level: High - comfortable with Terminal, bash scripts, MDM concepts

**Current Workflow:**
- Manages 200+ iOS/iPadOS devices via Jamf/Intune/Workspace ONE
- Creates 5-10 configuration profiles per month
- Spends 30-60 minutes per Home Screen Layout profile
- Frequently debugs XML syntax errors

**Pain Points:**
- Manual XML editing is tedious and error-prone
- Bundle ID lookups break workflow concentration
- No validation until deployment attempt
- Rework cycles waste time
- Pressure to provision devices quickly

**Goals:**
- Provision devices faster
- Reduce deployment errors
- Spend less time on repetitive tasks
- Increase deployment confidence

**Quote:** *"I know what apps I want where, I just don't want to spend an hour writing XML to make it happen."*

### Secondary Persona: MDM Specialist - "Jordan"

**Background:**
- Role: MDM Platform Administrator at enterprise (5000+ employees)
- Experience: 8+ years in enterprise IT, MDM subject matter expert
- Technical Level: Very High - writes scripts, automates workflows

**Current Workflow:**
- Manages MDM platform for multiple departments
- Creates standardized profiles for different user groups
- Maintains profile templates in version control
- Trains other IT staff on MDM

**Pain Points:**
- Training others on XML editing is difficult
- Standardization requires careful documentation
- Profile updates risk introducing errors
- Manual process doesn't scale

**Goals:**
- Standardize profile creation process
- Enable team members to create profiles safely
- Version control profile definitions easily
- Automate profile generation in CI/CD

**Quote:** *"I need a tool my team can use without breaking things, and that works in our automation pipeline."*

---

## Functional Requirements

### FR-1: Input File Processing

**Priority:** P0 (Critical)

**Description:** The script must accept a plain text file as input containing Bundle IDs.

**Requirements:**

**FR-1.1: Command-Line Interface**
- Script accepts input filename as first positional argument
- Syntax: `./layup.sh <input_file> [output_file]`
- Input file must exist and be readable
- If input file doesn't exist, output error to stderr and exit with code 1

**FR-1.2: File Format Support**
- Accept plain text files (.txt) or any text-readable format
- Parse file line-by-line
- Support UTF-8 encoding
- Handle both Unix (LF) and Windows (CRLF) line endings

**FR-1.3: Comment Handling**
- Lines starting with `#` are treated as comments
- Comments are ignored during processing
- Comments can appear anywhere in the file
- Leading whitespace before `#` is trimmed

**FR-1.4: Whitespace Handling**
- Trim leading and trailing whitespace from each line
- Ignore empty lines (lines with only whitespace)
- Preserve whitespace within Bundle IDs for validation error detection

**FR-1.5: Processing Order**
- Process Bundle IDs in order they appear in file
- First valid Bundle ID = Position 1 on Home Screen (top-left)
- Order follows standard iOS layout: left-to-right, top-to-bottom

### FR-2: Bundle ID Validation

**Priority:** P0 (Critical)

**Description:** The script must validate all Bundle IDs against Apple's format requirements.

**Requirements:**

**FR-2.1: Format Validation**
- Bundle ID must match reverse-DNS pattern: `^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$`
- Minimum 2 segments separated by dots (e.g., `com.company`)
- Each segment must contain only: alphanumeric characters (a-z, A-Z, 0-9), underscores (_), hyphens (-)
- Cannot start or end with a dot
- Cannot have consecutive dots (..)

**FR-2.2: Validation Output**
- Output validation results to stdout
- For each line processed, show one of:
  - `✓ Line N: <bundle_id> (valid)`
  - `✗ Line N: <bundle_id> (invalid format: <reason>)`
  - `⚠ Line N: Skipping comment`
  - `⚠ Line N: Skipping empty line`
- Include line numbers for easy reference to input file

**FR-2.3: Invalid Entry Handling**
- Skip invalid Bundle IDs (do not include in output)
- Log specific reason for invalidity
- Continue processing remaining lines
- Track count of skipped entries

**FR-2.4: Error Conditions**
- If input file is empty, output error to stderr and exit with code 2
- If no valid Bundle IDs found after processing, output error to stderr and exit with code 3
- Error message must be actionable (tell user what to fix)

### FR-3: XML Generation

**Priority:** P0 (Critical)

**Description:** The script must generate a valid Apple MDM Home Screen Layout configuration profile.

**Requirements:**

**FR-3.1: Payload Structure**
Generate XML with the following structure:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.homescreenlayout.managed</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PayloadIdentifier</key>
            <string>com.layup.homescreenlayout.[UUID]</string>
            <key>PayloadUUID</key>
            <string>[UUID]</string>
            <key>PayloadDisplayName</key>
            <string>Home Screen Layout</string>
            <key>PayloadDescription</key>
            <string>Managed home screen layout</string>
            <key>Dock</key>
            <array/>
            <key>Pages</key>
            <array>
                <array>
                    <!-- App dictionaries here -->
                </array>
            </array>
        </dict>
    </array>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadIdentifier</key>
    <string>com.layup.config.[UUID]</string>
    <key>PayloadUUID</key>
    <string>[UUID]</string>
    <key>PayloadDisplayName</key>
    <string>Home Screen Layout Configuration</string>
    <key>PayloadDescription</key>
    <string>Generated by Layup</string>
    <key>PayloadOrganization</key>
    <string>Layup</string>
    <key>PayloadRemovalDisallowed</key>
    <false/>
</dict>
</plist>
```

**FR-3.2: App Dictionary Format**
For each valid Bundle ID, generate:
```xml
<dict>
    <key>Type</key>
    <string>Application</string>
    <key>BundleID</key>
    <string>[bundle_id]</string>
</dict>
```

**FR-3.3: Dynamic Elements**
- Generate unique UUIDs using `uuidgen` command
- Use same UUID for both PayloadIdentifier instances (outer and inner)
- Generate separate UUID for PayloadUUID instances
- No hardcoded UUIDs in template

**FR-3.4: XML Compliance**
- Valid XML 1.0 structure
- Proper UTF-8 encoding declaration
- Correct DOCTYPE declaration for Apple plist
- Well-formed XML (all tags properly closed)
- Proper indentation (4 spaces per level)

**FR-3.5: XML Validation**
- Validate generated XML structure before writing to file
- Use `xmllint` or equivalent to verify well-formedness
- If validation fails, output error to stderr and exit with code 5
- Do not write invalid XML to file under any circumstances

**FR-3.6: Special Character Handling**
- Properly escape XML special characters in Bundle IDs:
  - `&` → `&amp;`
  - `<` → `&lt;`
  - `>` → `&gt;`
  - `"` → `&quot;`
  - `'` → `&apos;`

### FR-4: File Output

**Priority:** P0 (Critical)

**Description:** The script must write the generated configuration profile to disk.

**Requirements:**

**FR-4.1: Output File Naming**
- Default filename: `HomeScreenLayout_[timestamp].mobileconfig`
- Timestamp format: `YYYYMMDD_HHMMSS` (e.g., `20251026_143022`)
- Extension must be `.mobileconfig`
- If user provides custom filename without extension, append `.mobileconfig`

**FR-4.2: Output Location**
- Default location: Current working directory
- User can specify custom output path as second argument
- Example: `./layup.sh apps.txt /path/to/custom.mobileconfig`
- If output directory doesn't exist, output error to stderr and exit with code 4

**FR-4.3: File Overwrite Handling**
- If output file already exists, prompt user: `File 'filename' already exists. Overwrite? (y/n): `
- Wait for user input (y/Y or n/N)
- If user enters 'y' or 'Y', overwrite file
- If user enters 'n' or 'N', exit without writing (exit code 0)
- If user enters anything else, re-prompt
- Prompt goes to stdout, not stderr

**FR-4.4: File Properties**
- UTF-8 encoding
- Unix-style line endings (LF)
- File permissions: 644 (rw-r--r--)
- MIME type: application/x-apple-aspen-config (informational)

**FR-4.5: Write Error Handling**
- If write fails due to permissions, output error to stderr and exit with code 4
- Error message must include: filename, reason (permission denied), and suggestion (check directory permissions)
- Do not leave partial files on failure

### FR-5: User Feedback & Output

**Priority:** P0 (Critical)

**Description:** The script must provide clear, actionable feedback during execution.

**Requirements:**

**FR-5.1: Validation Messages (stdout)**
Output to stdout during processing:
```
Processing: apps.txt
✓ Line 1: com.apple.mobilesafari (valid)
✓ Line 2: com.apple.mobilemail (valid)
⚠ Line 3: Skipping empty line
⚠ Line 4: Skipping comment
✗ Line 5: invalid.bundle (invalid format: must have at least 2 segments)
✓ Line 6: com.google.chrome.ios (valid)
```

**FR-5.2: Summary Output (stdout)**
After processing, output summary:
```
Generated: HomeScreenLayout_20251026_143022.mobileconfig
Total apps: 15
Warnings: 2 lines skipped (1 comment, 1 empty)
Errors: 1 invalid Bundle ID skipped
```

**FR-5.3: Error Messages (stderr)**
All errors output to stderr with format:
```
ERROR: [Error message]
[Optional: Actionable suggestion]
```

Examples:
```
ERROR: Input file 'apps.txt' not found
Please check the filename and try again.

ERROR: No valid Bundle IDs found in input file
Please add at least one valid Bundle ID (format: com.company.app)

ERROR: Cannot write to '/protected/path/output.mobileconfig'
Permission denied. Try a different output location or check directory permissions.
```

**FR-5.4: Exit Codes**
- `0`: Success (file generated successfully, or user chose not to overwrite)
- `1`: Input file not found or not readable
- `2`: Input file is empty (no content)
- `3`: No valid Bundle IDs found after processing
- `4`: Cannot write output file (permissions or directory doesn't exist)
- `5`: XML validation failed (internal error)

**FR-5.5: Success Confirmation**
On successful generation, output to stdout:
```
✓ Success! Configuration profile generated.
File: /full/path/to/HomeScreenLayout_20251026_143022.mobileconfig
```

**FR-5.6: Open in Finder**
- After successful file generation, open the output file's location in Finder
- Use `open -R` command to reveal the file in Finder
- File should be selected/highlighted in the Finder window
- This provides immediate visual confirmation and easy access for upload to MDM
- If `open` command fails, continue normally (don't fail the entire operation)
- Log to stdout: "Opening file in Finder..."

### FR-6: Help Documentation

**Priority:** P0 (Critical)

**Description:** The script must provide usage documentation via `--help` flag.

**Requirements:**

**FR-6.1: Help Flag**
- Recognize `--help` and `-h` flags
- Help flag can appear anywhere in arguments
- Display help and exit with code 0

**FR-6.2: Help Content**
Display the following information:
```
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
```

---

## Non-Functional Requirements

### NFR-1: Performance

**NFR-1.1: Execution Speed**
- Script must complete in <1 second for typical input (20 Bundle IDs)
- Script must complete in <3 seconds for large input (100 Bundle IDs)
- No artificial delays or sleep commands

**NFR-1.2: Resource Usage**
- Memory usage must be minimal (<10MB)
- No memory leaks (all variables cleaned up)
- CPU usage spike acceptable during execution (short-lived process)

### NFR-2: Compatibility

**NFR-2.1: macOS Version Support**
- Compatible with macOS 10.15 (Catalina) and later
- Test on macOS 11 (Big Sur), 12 (Monterey), 13 (Ventura), 14 (Sonoma)
- Use only bash 3.2+ features (macOS default)

**NFR-2.2: Shell Compatibility**
- Primary target: bash (default macOS shell)
- Should work with zsh (current macOS default shell)
- Avoid bash 4+ specific features (not default on macOS)

**NFR-2.3: Dependency Requirements**
- Use only tools available in standard macOS installation:
  - bash 3.2+
  - uuidgen
  - xmllint (for validation)
  - sed, awk, grep (standard Unix utilities)
- No external package managers (no pip, npm, brew required)
- No compilation required

### NFR-3: Reliability

**NFR-3.1: Error Handling**
- All error conditions must be handled gracefully
- No unhandled errors or crashes
- All errors must output to stderr
- Exit codes must be consistent and documented

**NFR-3.2: Data Integrity**
- Never write partial or corrupted .mobileconfig files
- If generation fails mid-process, clean up and exit
- Atomic file writes where possible

**NFR-3.3: Validation**
- 100% of generated files must pass Apple DTD validation
- 100% of generated files must deploy successfully to MDM
- Zero tolerance for XML syntax errors

### NFR-4: Usability

**NFR-4.1: Error Message Quality**
- Error messages must be clear and actionable
- Include what went wrong and how to fix it
- Reference line numbers for input file errors
- No cryptic error codes without explanation

**NFR-4.2: Documentation**
- README must include installation, usage, and examples
- README must include "Intended Use" section clearly positioning as sample/educational code
- README must include production use considerations and recommendations
- README must include MIT License badge and full disclaimer
- Sample input file must be included in repository
- Help flag (`--help`) must provide comprehensive usage info
- Documentation should encourage learning and customization

**NFR-4.3: Feedback Clarity**
- User must understand what the script is doing at each step
- Progress indicators for validation
- Clear success/failure confirmation

### NFR-5: Maintainability

**NFR-5.1: Code Quality**
- Well-commented code explaining non-obvious logic
- Consistent code formatting
- Descriptive variable and function names
- Modular structure (separate functions for parsing, validation, generation)

**NFR-5.2: Version Control**
- Script must include version number in header comment
- Version number in `--help` output
- CHANGELOG.md to track changes between versions

**NFR-5.3: Testing**
- Include sample input files for manual testing
- Document test cases in repository
- Instructions for validating generated output

### NFR-6: Security

**NFR-6.1: Input Sanitization**
- Validate all user input
- Escape special characters in XML generation
- No code injection vulnerabilities

**NFR-6.2: Privacy**
- No network calls
- No telemetry or analytics
- All processing happens locally
- No data leaves user's machine

**NFR-6.3: File Permissions**
- Check write permissions before attempting to write
- Don't create world-writable files
- Respect umask settings

---

## Technical Specifications

### Architecture Overview

```
┌─────────────────┐
│  Input File     │
│  (apps.txt)     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  1. Input Parser                        │
│  - Read line-by-line                    │
│  - Strip whitespace                     │
│  - Filter comments & empty lines        │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  2. Bundle ID Validator                 │
│  - Regex pattern matching               │
│  - Format validation                    │
│  - Error logging                        │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  3. XML Generator                       │
│  - UUID generation                      │
│  - Heredoc template                     │
│  - Special character escaping           │
│  - App dictionary construction          │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  4. XML Validator                       │
│  - xmllint validation                   │
│  - Well-formedness check                │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  5. File Writer                         │
│  - Overwrite confirmation               │
│  - Atomic write                         │
│  - Permission check                     │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  Output File    │
│  (.mobileconfig)│
└─────────────────┘
```

### Data Flow

**Input → Processing → Output**

1. **Command-line arguments** → Parse arguments (input file, optional output file, help flag)
2. **Input file** → Read and parse line-by-line
3. **Raw lines** → Filter comments and empty lines
4. **Candidate Bundle IDs** → Validate format with regex
5. **Valid Bundle IDs** → Build app dictionary array
6. **App array** → Insert into XML template with UUIDs
7. **Generated XML** → Validate with xmllint
8. **Valid XML** → Write to output file
9. **File write** → Confirm and report success

### Key Algorithms

#### Bundle ID Validation Regex

```bash
BUNDLE_ID_PATTERN='^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$'

validate_bundle_id() {
    local bundle_id="$1"
    
    # Check format with regex
    if [[ $bundle_id =~ $BUNDLE_ID_PATTERN ]]; then
        # Count segments (must be at least 2)
        local segment_count=$(echo "$bundle_id" | tr -cd '.' | wc -c)
        segment_count=$((segment_count + 1))
        
        if [ $segment_count -ge 2 ]; then
            return 0  # Valid
        else
            return 1  # Invalid: not enough segments
        fi
    else
        return 1  # Invalid: pattern mismatch
    fi
}
```

#### XML Special Character Escaping

```bash
escape_xml() {
    local text="$1"
    text="${text//&/&amp;}"   # Must be first
    text="${text//</&lt;}"
    text="${text//>/&gt;}"
    text="${text//\"/&quot;}"
    text="${text//\'/&apos;}"
    echo "$text"
}
```

#### App Dictionary Generation

```bash
generate_app_dict() {
    local bundle_id="$1"
    local escaped_id=$(escape_xml "$bundle_id")
    
    cat << EOF
                    <dict>
                        <key>Type</key>
                        <string>Application</string>
                        <key>BundleID</key>
                        <string>${escaped_id}</string>
                    </dict>
EOF
}
```

### File Structure

```
layup/
├── layup.sh                 # Main script
├── README.md                # Documentation
├── LICENSE                  # MIT License
├── CHANGELOG.md             # Version history
├── examples/
│   ├── sample_apps.txt      # Example input file
│   ├── sample_apps_with_comments.txt
│   └── expected_output.mobileconfig
└── tests/
    ├── test_valid_input.txt
    ├── test_invalid_input.txt
    └── test_edge_cases.txt
```

### Script Header Template

```bash
#!/bin/bash
#
# Layup - Home Screen Layout Configuration Generator
# Version: 1.0.0
# Copyright (c) 2025 [Your Name]
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
```

### Dependencies

| Tool | Purpose | Availability | Fallback |
|------|---------|--------------|----------|
| bash 3.2+ | Shell interpreter | Default macOS | N/A (required) |
| uuidgen | UUID generation | Standard Unix tool | N/A (required) |
| xmllint | XML validation | **Guaranteed on macOS 10.15+** (base system libxml2) | N/A (required) |
| sed | Text processing | Standard Unix tool | awk alternative |
| grep | Pattern matching | Standard Unix tool | N/A |
| date | Timestamp generation | Standard Unix tool | N/A |

All dependencies are guaranteed to be present on macOS 10.15+. No installation required.

---

## User Stories

### Epic 1: Basic Configuration Generation

**US-1.1: Generate Configuration from Simple List**
```
As an IT administrator
I want to provide a text file with Bundle IDs
So that I can generate a Home Screen Layout configuration in seconds

Acceptance Criteria:
- Given a text file with 10 valid Bundle IDs
- When I run ./layup.sh apps.txt
- Then a valid .mobileconfig file is created
- And the file contains all 10 apps in order
- And the file deploys successfully to my MDM
```

**US-1.2: Use Comments for Documentation**
```
As an IT administrator
I want to add comments to my input file
So that I can document the purpose of each app or section

Acceptance Criteria:
- Given an input file with # comment lines
- When I run the script
- Then comments are ignored during processing
- And only valid Bundle IDs are included in output
- And I see a warning count for skipped comments
```

**US-1.3: Handle Invalid Bundle IDs Gracefully**
```
As an IT administrator
I want to see clear errors for invalid Bundle IDs
So that I can fix them before rerunning

Acceptance Criteria:
- Given an input file with some invalid Bundle IDs
- When I run the script
- Then I see specific errors for each invalid entry
- And I see the line number of each error
- And I see a reason for why it's invalid
- And valid entries are still processed
- And a config is generated if at least one valid ID exists
```

### Epic 2: File Management

**US-2.1: Prevent Accidental Overwrites**
```
As an IT administrator
I want to be prompted before overwriting existing files
So that I don't lose previous configurations accidentally

Acceptance Criteria:
- Given an output file that already exists
- When I run the script
- Then I am prompted "File 'X' already exists. Overwrite? (y/n)"
- And if I enter 'n', the script exits without writing
- And if I enter 'y', the file is overwritten
- And if I enter anything else, I am re-prompted
```

**US-2.2: Specify Custom Output Location**
```
As an IT administrator
I want to specify where the output file is saved
So that I can organize configurations by project or department

Acceptance Criteria:
- Given a valid input file
- When I run ./layup.sh apps.txt /path/to/output.mobileconfig
- Then the file is created at the specified path
- And if the directory doesn't exist, I see an error
- And the error suggests checking the directory path
```

**US-2.3: Quick Access to Generated File**
```
As an IT administrator
I want the generated file to open in Finder automatically
So that I can immediately drag it to my MDM console or upload location

Acceptance Criteria:
- Given the script completes successfully
- When the .mobileconfig file is created
- Then a Finder window opens with the file selected
- And I can immediately see where the file was saved
- And I can drag/drop or copy the file to my MDM
- And if Finder fails to open, the script still succeeds
```

### Epic 3: Error Handling

**US-3.1: Handle Missing Input File**
```
As an IT administrator
I want to see a clear error if my input file doesn't exist
So that I can correct the filename

Acceptance Criteria:
- Given a non-existent input file path
- When I run the script
- Then I see "ERROR: Input file 'X' not found"
- And I see a suggestion to check the filename
- And the script exits with code 1
- And the error is output to stderr
```

**US-3.2: Handle Empty Input File**
```
As an IT administrator
I want to be notified if my input file is empty
So that I know to add content before running

Acceptance Criteria:
- Given an input file with no content
- When I run the script
- Then I see "ERROR: Input file is empty"
- And the script exits with code 2
- And no output file is created
```

**US-3.3: Handle No Valid Bundle IDs**
```
As an IT administrator
I want to be notified if none of my Bundle IDs are valid
So that I can review the format requirements

Acceptance Criteria:
- Given an input file with only invalid Bundle IDs
- When I run the script
- Then I see errors for each invalid entry
- And I see "ERROR: No valid Bundle IDs found"
- And I see a format reminder (com.company.app)
- And the script exits with code 3
```

### Epic 4: Documentation & Help

**US-4.1: View Usage Instructions**
```
As a new user
I want to see how to use the script
So that I can get started quickly

Acceptance Criteria:
- Given I run ./layup.sh --help
- Then I see usage syntax
- Then I see argument descriptions
- Then I see input file format explanation
- Then I see example commands
- Then I see exit codes
- And the script exits with code 0
```

**US-4.2: Learn from Example**
```
As a new user
I want to see an example input file
So that I can understand the expected format

Acceptance Criteria:
- Given the repository contains examples/ directory
- When I view sample_apps.txt
- Then I see properly formatted Bundle IDs
- And I see comments explaining sections
- And I can use this as a template
```

---

## Acceptance Criteria

### Definition of Done

A feature is considered complete when:

1. ✅ **Code Complete:** All functional requirements implemented
2. ✅ **Self-Tested:** Developer has tested happy path and error cases
3. ✅ **Documentation Updated:** README and help output reflect new functionality
4. ✅ **Example Files Updated:** Sample inputs demonstrate the feature
5. ✅ **Manual Test Cases Passed:** All test scenarios documented and verified
6. ✅ **No Known Critical Bugs:** No bugs that prevent core functionality

### Test Scenarios

#### Scenario 1: Happy Path - Simple Configuration

**Test Case:** `test_simple_valid_input.txt`
```
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
```

**Expected Result:**
- ✅ All 3 Bundle IDs validated successfully
- ✅ .mobileconfig file generated
- ✅ File passes xmllint validation
- ✅ File deploys successfully to test MDM
- ✅ Apps appear in correct order on test device
- ✅ Finder window opens with file selected

#### Scenario 2: Input with Comments and Empty Lines

**Test Case:** `test_comments_and_whitespace.txt`
```
# Communication Apps

com.apple.mobilesafari

com.apple.mobilemail
# This is a comment
com.apple.MobileSMS

```

**Expected Result:**
- ✅ 3 valid Bundle IDs processed
- ✅ Comments skipped with warnings
- ✅ Empty lines ignored
- ✅ Valid .mobileconfig generated

#### Scenario 3: Mixed Valid and Invalid Input

**Test Case:** `test_mixed_validity.txt`
```
com.apple.mobilesafari
invalid
com.apple.mobilemail
com.app with spaces
com.example.ValidApp-123_test
```

**Expected Result:**
- ✅ Line 1: Valid
- ✅ Line 2: Error - not enough segments
- ✅ Line 3: Valid
- ✅ Line 4: Error - contains whitespace
- ✅ Line 5: Valid (underscores and hyphens allowed)
- ✅ 3 apps in output configuration

#### Scenario 4: Overwrite Existing File

**Setup:** Pre-existing `output.mobileconfig`

**Test Steps:**
1. Run `./layup.sh apps.txt output.mobileconfig`
2. See prompt: "File 'output.mobileconfig' already exists. Overwrite? (y/n):"
3. Enter 'n'

**Expected Result:**
- ✅ Script exits without overwriting
- ✅ Exit code 0
- ✅ Original file unchanged

**Test Steps (Alternative):**
1. Run `./layup.sh apps.txt output.mobileconfig`
2. See prompt
3. Enter 'y'

**Expected Result:**
- ✅ File is overwritten
- ✅ New content generated
- ✅ Exit code 0

#### Scenario 5: Error Handling - File Not Found

**Test Steps:**
Run `./layup.sh nonexistent.txt`

**Expected Result:**
- ✅ Error message to stderr
- ✅ Message includes filename
- ✅ Message suggests checking filename
- ✅ Exit code 1
- ✅ No output file created

#### Scenario 6: Error Handling - Empty Input File

**Test Case:** `test_empty.txt` (0 bytes)

**Test Steps:**
Run `./layup.sh test_empty.txt`

**Expected Result:**
- ✅ Error message to stderr
- ✅ "Input file is empty"
- ✅ Exit code 2
- ✅ No output file created

#### Scenario 7: Error Handling - No Valid IDs

**Test Case:** `test_all_invalid.txt`
```
invalid
also.invalid
not-valid
```

**Expected Result:**
- ✅ Each line shows validation error
- ✅ Final error: "No valid Bundle IDs found"
- ✅ Exit code 3
- ✅ No output file created

#### Scenario 8: Special Characters in Bundle IDs

**Test Case:** `test_special_chars.txt`
```
com.example.app&test
com.example.app<script>
com.example.app"quoted"
```

**Expected Result:**
- ✅ Line 1: Invalid (& not allowed in Bundle ID format)
- ✅ Line 2: Invalid (< not allowed)
- ✅ Line 3: Invalid (" not allowed)
- ✅ No valid Bundle IDs found
- ✅ Error exit

**Note:** Valid Bundle IDs shouldn't contain XML special chars, but if they did exist in a valid format, they should be escaped in output.

#### Scenario 9: Large Input File

**Test Case:** `test_large.txt` (100 Bundle IDs)

**Expected Result:**
- ✅ All 100 IDs processed
- ✅ Script completes in <3 seconds
- ✅ Valid .mobileconfig generated
- ✅ File size reasonable (<50KB)

#### Scenario 10: Help Flag

**Test Steps:**
Run `./layup.sh --help`

**Expected Result:**
- ✅ Usage information displayed
- ✅ Includes syntax, description, examples
- ✅ Exit code 0
- ✅ No files created

### MDM Deployment Testing

**Requirement:** All generated files must deploy successfully to real MDM.

**Test MDM Platforms:**
- Jamf Pro (primary)
- Microsoft Intune (secondary)
- (Others as available)

**Test Devices:**
- iPhone (iOS 15+)
- iPad (iPadOS 15+)

**Validation Steps:**
1. Upload generated .mobileconfig to MDM
2. Assign profile to test device
3. Verify profile installs without errors
4. Check device Home Screen matches input order
5. Verify no unexpected behavior

**Success Criteria:**
- ✅ Profile uploads without errors
- ✅ Profile installs on device without errors
- ✅ Apps appear in specified order
- ✅ No device errors or warnings
- ✅ Profile can be removed cleanly

---

## Out of Scope

The following features are explicitly **NOT** included in MVP and are deferred to future releases:

### Deferred to Phase 2

- ❌ Multi-page Home Screen layouts
- ❌ Dock configuration
- ❌ Folder support with nested apps
- ❌ Dry-run mode (`--dry-run` flag)
- ❌ Verbose mode (`-v` flag)
- ❌ Quiet mode (`-q` flag)
- ❌ Custom PayloadDisplayName/Description/Organization
- ❌ Interactive mode with prompts
- ❌ Validation-only mode (check input without generating)

### Deferred to Phase 3+

- ❌ Device-specific layouts (iPhone vs iPad position limits)
- ❌ Bundle ID lookup/search functionality
- ❌ Template generation (common layouts)
- ❌ Import existing .mobileconfig for editing
- ❌ GUI wrapper (AppleScript/Swift)
- ❌ Web clips (bookmarks)
- ❌ App badges or notification settings
- ❌ Device restrictions or other payload types
- ❌ Direct MDM integration (API upload)
- ❌ Batch processing (multiple input files)

### Never in Scope

- ❌ Windows/Linux support (macOS-only tool)
- ❌ Android device support
- ❌ Non-MDM deployment methods
- ❌ App installation or management
- ❌ Device enrollment
- ❌ User authentication
- ❌ Cloud storage or sync

---

## Dependencies & Assumptions

### External Dependencies

**Required Tools (All Guaranteed on macOS 10.15+):**
- bash 3.2+ (macOS default shell)
- uuidgen (standard Unix utility)
- xmllint (base system libxml2, `/usr/bin/xmllint`)
- Standard Unix utilities (sed, awk, grep, date)

**Test Environment:**
- Access to MDM platform (Jamf, Intune, or similar)
- Test iOS/iPadOS devices for validation
- macOS machine for development and testing

**Note:** All required tools are part of the base macOS installation. No additional software, package managers (brew, pip, npm), or Xcode Command Line Tools are required.

### Assumptions

**Technical Assumptions:**
1. Users have basic command-line proficiency
2. Users understand MDM concepts and Bundle IDs
3. Users have MDM admin access for testing
4. macOS 10.15+ is acceptable minimum version
5. Standard macOS tools are sufficient (no external packages needed)

**User Assumptions:**
1. Users know the Bundle IDs they want to use
2. Users have a text editor to create input files
3. Users can upload .mobileconfig files to their MDM
4. Users want single-page layouts (most common use case)
5. Users are comfortable with Terminal/command-line tools

**Business Assumptions:**
1. Time savings is the primary value driver
2. IT admins prefer tools over web services for security
3. Open source distribution is acceptable
4. MIT license is appropriate for maximum adoption
5. GitHub is the right distribution platform

### License Selection Rationale

**MIT License chosen for:**
- **Maximum adoption** - No legal barriers for IT admins at companies
- **Corporate compatibility** - Widely accepted in enterprise environments
- **Community standard** - Aligns with GitHub CLI tool norms
- **Simplicity** - Clear, unambiguous permissions
- **Attribution preserved** - Requires credit to original author
- **Strong liability protection** - Disclaims warranty and liability

**Educational/Sample Code Positioning:**
While MIT allows commercial use, documentation clearly positions Layup as:
- Sample code for educational purposes
- Demonstration of MDM payload generation principles
- Starting point for custom tooling
- Not intended as production-grade enterprise software

This approach maximizes adoption (primary goal) while setting appropriate expectations about the tool's scope and intended use.

### Risks to Assumptions

**Risk:** Users may not be comfortable with command-line tools
- **Mitigation:** Comprehensive README with examples
- **Mitigation:** Sample input files included
- **Mitigation:** Clear error messages with suggestions
- **Fallback:** Phase 3 GUI wrapper if needed

**Risk:** Apple may change MDM protocol or XML structure
- **Mitigation:** Reference documentation in code comments
- **Mitigation:** Version script and document Apple spec version
- **Mitigation:** Community reporting of issues
- **Fallback:** Quick update release process

---

## Risk Assessment

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **XML generation produces invalid structure** | Low | Critical | Extensive testing, xmllint validation, test MDM deployment |
| **Apple changes MDM spec** | Medium | High | Version documentation, community monitoring, quick update path |
| **Script incompatibility with older macOS** | Low | Medium | Test on macOS 10.15+, use only bash 3.2 features |
| **Performance issues with large inputs** | Low | Low | Test with 100+ apps, optimize if needed |
| **Special characters cause XML errors** | Low | High | Proper escaping function, test edge cases |

### User Experience Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Users create invalid input files** | Medium | Low | Clear validation errors with line numbers, sample files |
| **Users don't understand Bundle IDs** | Medium | Low | Documentation includes common IDs, link to reference |
| **Users expect GUI** | Low | Low | Clear positioning as CLI tool, plan GUI for Phase 3 |
| **Error messages are unclear** | Low | Medium | User testing, iterate on message clarity |
| **Users lose data from overwrite** | Low | Medium | Overwrite confirmation prompt |

### Business/Adoption Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Low adoption due to CLI barrier** | Medium | Medium | Excellent documentation, video tutorial, sample files |
| **Competition from existing tools** | Low | Low | Focus on simplicity and speed advantage |
| **Users want multi-page immediately** | Medium | Low | Clear roadmap, gather feedback, prioritize Phase 2 |
| **License conflicts** | Low | High | Use MIT license (permissive), no dependencies with viral licenses |

---

## Release Plan

### MVP Release (v1.0.0)

**Target Date:** 2 weeks from kickoff

**Scope:** All P0 functional requirements

**Deliverables:**
- `layup.sh` - Executable shell script
- `README.md` - Complete documentation with educational positioning
- `LICENSE` - Full MIT license text
- `CHANGELOG.md` - Version history
- `examples/sample_apps.txt` - Example input file
- `examples/sample_apps_with_comments.txt` - Documented example
- Test files in `tests/` directory

**README.md Must Include:**
- Clear "Intended Use" section positioning as sample/educational code
- Production use considerations and recommendations
- MIT License badge and link
- Disclaimer: "THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND"
- Note: "Not intended as production-grade enterprise software"

**Launch Activities:**
1. Create GitHub repository
2. Upload all deliverables
3. Create release (v1.0.0)
4. Write launch announcement
5. Share in relevant IT/MDM communities
6. Gather initial user feedback

**Success Metrics:**
- 10+ unique users in first month
- Zero critical bugs reported
- Positive feedback on time savings
- At least one testimonial/review

### Post-MVP Releases

**v1.1.0 - Quality of Life** (1-2 months post-MVP)
- Verbose mode (`-v`)
- Quiet mode (`-q`)
- Version flag (`--version`)
- Enhanced error messages based on feedback
- Performance optimizations if needed

**v2.0.0 - Multi-Page Support** (3-6 months post-MVP)
- Multi-page input format
- Dock configuration
- Folder support
- Device-specific layouts (iPhone vs iPad)

**v3.0.0 - Advanced Features** (6-12 months post-MVP)
- Bundle ID lookup database
- Template generation
- Import existing .mobileconfig for editing
- Interactive mode

**v4.0.0 - GUI** (12+ months post-MVP)
- Native macOS app (Swift)
- Visual drag-and-drop interface
- Template library
- Direct MDM integration

---

## Appendix F: README Template Structure

### Recommended README.md Sections

```markdown
# Layup

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Generate Apple MDM Home Screen Layout configuration profiles from plain text Bundle ID lists.

## ⚠️ Intended Use

Layup is **sample code** for educational purposes and demonstration of MDM payload generation.

This tool is designed as:
- 📚 A learning resource for understanding Apple MDM protocols
- 🔧 A starting point for custom tooling
- 💡 A proof-of-concept for automating configuration profiles
- 🚀 A time-saver for quick, non-critical configurations

**Production Use Considerations:**

While the MIT License permits production use, consider these recommendations for enterprise environments:
- Add comprehensive error handling and logging
- Implement audit trails for compliance
- Integrate with your organization's workflows and approval processes
- Add validation against your organization's app catalog
- Perform thorough testing in your specific MDM environment
- Consider professional code review and security assessment

## What It Does

Layup converts this:

\`\`\`
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
\`\`\`

Into a valid `.mobileconfig` file ready for MDM deployment – in less than 1 second.

**Time Savings:** 30-60 minutes → <5 minutes per configuration

## Quick Start

[Installation and usage instructions...]

## Use Cases

- ✅ Learning MDM payload structures
- ✅ Quick prototyping of Home Screen layouts
- ✅ Personal projects and small-scale deployments
- ✅ Starting point for custom automation
- ⚠️ Production environments (with additional hardening)

## License

MIT License - See [LICENSE](LICENSE) file for details.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND**, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.

## Contributing

Contributions, issues, and feature requests are welcome! This is a learning project and community improvements are encouraged.

## Disclaimer

This is not production-grade enterprise software. Use at your own risk. Always test configurations in a non-production environment before deploying to managed devices.

---

**Made with ❤️ for the IT admin community**
\`\`\`

---

## Appendix A: Bundle ID Format Specification

### Apple Bundle ID Requirements

**Official Format:** Reverse-DNS notation

**Pattern:** `com.company.application[.module]`

**Rules:**
1. Must contain at least 2 segments separated by dots
2. Each segment must start with a letter or number
3. Valid characters: `a-z`, `A-Z`, `0-9`, hyphen (`-`), underscore (`_`)
4. Cannot start or end with a dot
5. Cannot have consecutive dots
6. Case-sensitive (preserve as entered)

**Common Examples:**

**Apple Built-in Apps:**
- Safari: `com.apple.mobilesafari`
- Mail: `com.apple.mobilemail`
- Messages: `com.apple.MobileSMS`
- Phone: `com.apple.mobilephone`
- Calendar: `com.apple.mobilecal`
- Photos: `com.apple.mobileslideshow`
- Camera: `com.apple.camera`
- Settings: `com.apple.Preferences`
- App Store: `com.apple.AppStore`
- Music: `com.apple.Music`
- Maps: `com.apple.Maps`

**Microsoft Apps:**
- Outlook: `com.microsoft.Office.Outlook`
- Word: `com.microsoft.Office.Word`
- Excel: `com.microsoft.Office.Excel`
- PowerPoint: `com.microsoft.Office.PowerPoint`
- Teams: `com.microsoft.teams.ios`
- OneDrive: `com.microsoft.skydrive`

**Google Apps:**
- Chrome: `com.google.chrome.ios`
- Gmail: `com.google.Gmail`
- Drive: `com.google.Drive`
- Maps: `com.google.Maps`
- Calendar: `com.google.calendar`

**Other Common Enterprise Apps:**
- Slack: `com.tinyspeck.chatlyio` (Slack)
- Zoom: `us.zoom.videomeetings`
- 1Password: `com.agilebits.onepassword-ios`
- Dropbox: `com.getdropbox.Dropbox`
- Notion: `notion.id`

### Finding Bundle IDs

**Method 1: Apple Configurator 2**
1. Connect device to Mac
2. Open Apple Configurator 2
3. Select device → Apps
4. Apps show Bundle ID in details

**Method 2: MDM Console**
- Most MDM platforms display Bundle IDs in app catalog
- Jamf Pro: Mobile Device Apps → Details
- Intune: Client Apps → iOS/iPadOS → App Information

**Method 3: IPA File Inspection**
1. Download .ipa file
2. Rename to .zip and extract
3. Open Payload/[AppName].app/Info.plist
4. Look for `CFBundleIdentifier` key

**Method 4: Third-Party Databases**
- BundleID Database websites
- GitHub repositories of known Bundle IDs
- MDM community forums

---

## Appendix B: Apple MDM Protocol Reference

### Home Screen Layout Payload Specification

**Payload Type:** `com.apple.homescreenlayout.managed`

**Documentation:** [Apple MDM Protocol Reference - Home Screen Layout](https://developer.apple.com/documentation/devicemanagement/homescreenlayout)

**Required Keys:**

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| PayloadType | String | Yes | Must be `com.apple.homescreenlayout.managed` |
| PayloadVersion | Integer | Yes | Must be `1` |
| PayloadIdentifier | String | Yes | Unique identifier (reverse-DNS format) |
| PayloadUUID | String | Yes | UUID for this payload instance |
| Dock | Array | No | Array of app/folder dicts for dock (empty array = no dock management) |
| Pages | Array | No | Array of pages, each page is an array of app/folder dicts |

**App Dictionary Keys:**

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| Type | String | Yes | Must be `Application` for apps |
| BundleID | String | Yes | App Bundle ID (e.g., `com.apple.mobilesafari`) |

**Configuration Profile Container:**

The Home Screen Layout payload must be wrapped in a Configuration Profile with these keys:

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| PayloadType | String | Yes | Must be `Configuration` |
| PayloadVersion | Integer | Yes | Must be `1` |
| PayloadIdentifier | String | Yes | Unique identifier for profile |
| PayloadUUID | String | Yes | UUID for this profile |
| PayloadDisplayName | String | Yes | User-visible name |
| PayloadDescription | String | No | User-visible description |
| PayloadOrganization | String | No | Organization name |
| PayloadContent | Array | Yes | Array containing the Home Screen Layout payload |

### XML Property List Format

**DOCTYPE Declaration:**
```xml
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
```

**Root Element:**
```xml
<plist version="1.0">
    <dict>
        <!-- Configuration profile keys -->
    </dict>
</plist>
```

**Data Types:**
- String: `<string>text</string>`
- Integer: `<integer>1</integer>`
- Boolean: `<true/>` or `<false/>`
- Array: `<array><string>item</string></array>`
- Dictionary: `<dict><key>name</key><string>value</string></dict>`

---

## Appendix C: Exit Codes Reference

| Code | Constant | Meaning | User Action |
|------|----------|---------|-------------|
| 0 | EXIT_SUCCESS | Success or user cancelled overwrite | None - operation completed |
| 1 | EXIT_FILE_NOT_FOUND | Input file not found or not readable | Check filename and path |
| 2 | EXIT_EMPTY_FILE | Input file has no content | Add Bundle IDs to file |
| 3 | EXIT_NO_VALID_IDS | No valid Bundle IDs after validation | Review format: com.company.app |
| 4 | EXIT_WRITE_ERROR | Cannot write output file | Check permissions and directory |
| 5 | EXIT_VALIDATION_ERROR | XML validation failed (internal error) | Report bug on GitHub |

---

## Appendix D: Sample Input Files

### Minimal Example (`minimal.txt`)
```
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
```

### Documented Example (`documented.txt`)
```
# Home Screen Layout for Sales Team
# Last updated: 2025-10-26

# Row 1: Core Communication
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.microsoft.teams.ios

# Row 2: Productivity Suite
com.microsoft.Office.Outlook
com.microsoft.Office.Word
com.microsoft.Office.Excel
com.microsoft.Office.PowerPoint

# Row 3: CRM & Business Tools
com.salesforce.chatter
com.hubspot.app
com.linkedin.LinkedIn
com.zoom.videomeetings

# Row 4: Utilities
com.apple.mobilecal
com.evernote.iPhone.Evernote
com.1password.ios
com.apple.AppStore

# Row 5: Reference & Travel
com.google.Maps
com.yelp.yelpiphone
com.tripadvisor.TripAdvisor
com.apple.Preferences
```

### Enterprise Example (`enterprise.txt`)
```
# Standard Enterprise iPhone Layout
# Version: 1.0
# Department: All
# Device Type: iPhone
# Page: 1 (Home Screen)

# === Essential Apps (Always Required) ===
com.apple.mobilesafari
com.apple.mobilemail
com.microsoft.teams.ios
com.microsoft.Office.Outlook

# === Productivity ===
com.microsoft.Office.Word
com.microsoft.Office.Excel
com.microsoft.Office.PowerPoint
com.microsoft.onenote

# === Collaboration ===
com.slack.Slack
com.zoom.videomeetings
com.webex.meetings
com.gotomeeting

# === Security ===
com.duo.Duo-universal
com.microsoft.Authenticator
com.1password.ios

# === Corporate Apps ===
com.company.intranet
com.company.helpdesk
com.company.expenses

# === System ===
com.apple.Preferences
com.apple.AppStore
```

---

## Appendix E: Testing Checklist

### Pre-Release Testing

**Functional Testing:**
- [ ] Script executes with valid input file
- [ ] Script generates valid .mobileconfig
- [ ] Generated file passes xmllint validation
- [ ] Generated file deploys to test MDM successfully
- [ ] Apps appear in correct order on test device
- [ ] Finder window opens with file selected after generation
- [ ] Script handles comments correctly
- [ ] Script handles empty lines correctly
- [ ] Script validates Bundle IDs correctly
- [ ] Script reports invalid Bundle IDs with line numbers
- [ ] Script exits with correct error codes
- [ ] Overwrite prompt works correctly (y/n)
- [ ] Custom output path works
- [ ] Default output path works
- [ ] Help flag displays complete information
- [ ] Error messages are clear and actionable

**Edge Case Testing:**
- [ ] Empty input file
- [ ] Input file with only comments
- [ ] Input file with only invalid Bundle IDs
- [ ] Input file with mixed valid/invalid
- [ ] Very large input file (100+ Bundle IDs)
- [ ] Bundle IDs with underscores
- [ ] Bundle IDs with hyphens
- [ ] Bundle IDs with many segments (com.a.b.c.d.e)
- [ ] Output file already exists
- [ ] Output directory doesn't exist
- [ ] No write permission for output directory
- [ ] Invalid characters in Bundle IDs
- [ ] Whitespace variations in input
- [ ] Different line ending types (LF, CRLF)

**Compatibility Testing:**
- [ ] macOS 10.15 (Catalina)
- [ ] macOS 11 (Big Sur)
- [ ] macOS 12 (Monterey)
- [ ] macOS 13 (Ventura)
- [ ] macOS 14 (Sonoma)
- [ ] bash shell
- [ ] zsh shell

**MDM Deployment Testing:**
- [ ] Jamf Pro deployment
- [ ] Microsoft Intune deployment (if available)
- [ ] iPhone deployment (iOS 15+)
- [ ] iPad deployment (iPadOS 15+)
- [ ] Profile installs without errors
- [ ] Home Screen layout matches input
- [ ] Profile can be removed cleanly

**Performance Testing:**
- [ ] 10 Bundle IDs: <1 second
- [ ] 20 Bundle IDs: <1 second
- [ ] 50 Bundle IDs: <2 seconds
- [ ] 100 Bundle IDs: <3 seconds

**Documentation Review:**
- [ ] README is comprehensive
- [ ] README includes "Intended Use" section with educational positioning
- [ ] README includes production use considerations
- [ ] README includes MIT License badge and full disclaimer
- [ ] README has correct examples
- [ ] Sample input files are valid
- [ ] Help output matches README
- [ ] CHANGELOG is updated
- [ ] LICENSE file contains full MIT license text

---

**END OF PRD**

---

**Document Approval:**

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Manager | | | |
| Technical Lead | | | |
| QA Lead | | | |

**Version History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-26 | [Name] | Initial PRD for MVP |

---

**Related Documents:**
- [Layup Product Brief](./Layup_Product_Brief.md)
- [Layup Modifications Summary](./Layup_Modifications_Summary.md)
- Apple MDM Protocol Reference (external)
- Home Screen Layout Payload Documentation (external)