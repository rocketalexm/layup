
# Layup - Software Architecture Plan

**Version:** 1.0  
**Date:** October 26, 2025  
**Status:** Draft - Ready for Implementation  
**Document Owner:** Architecture Team  

---

## Executive Summary

Layup is a command-line tool that generates Apple MDM Home Screen Layout configuration profiles (`.mobileconfig` files) from plain text Bundle ID lists. This architecture plan defines the technical design for the MVP release, focusing on simplicity, reliability, and compliance with Apple MDM specifications.

**Core Architecture Principles:**
- **Unix Philosophy:** Do one thing well - convert Bundle ID lists to valid `.mobileconfig` files
- **Zero Dependencies:** Use only standard macOS/Unix tools (bash 3.2+, uuidgen, xmllint)
- **Local Processing:** All operations happen on the user's machine with no network calls
- **Specification Compliance:** 100% adherence to Apple MDM Protocol requirements

**Key Technical Decisions:**
- Platform: Bash shell script for macOS 10.15+
- Input: Plain text file with one Bundle ID per line
- Output: Apple-compliant XML configuration profile
- Distribution: Single executable script via GitHub

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Goals and Constraints](#architecture-goals-and-constraints)
3. [High-Level Architecture](#high-level-architecture)
4. [Technology Stack](#technology-stack)
5. [Data Architecture](#data-architecture)
6. [Security Architecture](#security-architecture)
7. [Deployment Architecture](#deployment-architecture)
8. [Integration Points](#integration-points)
9. [Architectural Decision Records (ADRs)](#architectural-decision-records-adrs)

---

## System Overview

### Purpose

Layup eliminates the error-prone manual XML editing process for creating iOS/iPadOS Home Screen Layout configuration profiles. It transforms a simple text file containing app Bundle IDs into a deployment-ready `.mobileconfig` file in under 1 second.

### Scope

**In Scope for MVP:**
- Single-page Home Screen layouts (up to 20 apps)
- Bundle ID validation and error reporting
- XML generation compliant with Apple MDM Protocol
- File output with automatic naming and overwrite protection
- Command-line interface with help documentation
- Finder integration for quick file access

**Out of Scope for MVP:**
- Multi-page layouts (deferred to Phase 2)
- Dock configuration
- Folder support
- Interactive mode
- GUI wrapper
- Direct MDM integration

### Context Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     User Environment                         │
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │ Text Editor  │────────▶│  Input File  │                 │
│  │ (any editor) │         │  (apps.txt)  │                 │
│  └──────────────┘         └──────┬───────┘                 │
│                                   │                          │
│                                   ▼                          │
│                          ┌─────────────────┐                │
│                          │  Layup Script   │                │
│                          │  (layup.sh)     │                │
│                          └────────┬────────┘                │
│                                   │                          │
│                                   ▼                          │
│                          ┌─────────────────┐                │
│                          │ Output File     │                │
│                          │ (.mobileconfig) │                │
│                          └────────┬────────┘                │
│                                   │                          │
│                                   ▼                          │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   Finder     │◀────────│  open -R     │                 │
│  │   Window     │         │   command    │                 │
│  └──────────────┘         └──────────────┘                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                                   │
                                   │ Manual Upload
                                   ▼
                          ┌─────────────────┐
                          │  MDM Platform   │
                          │ (Jamf/Intune)   │
                          └─────────────────┘
                                   │
                                   ▼
                          ┌─────────────────┐
                          │  iOS/iPadOS     │
                          │    Devices      │
                          └─────────────────┘
```

---

## Architecture Goals and Constraints

### Goals

1. **Reliability:** Generate 100% valid configuration profiles with zero syntax errors
2. **Performance:** Complete execution in <1 second for typical inputs (20 apps)
3. **Usability:** Provide clear, actionable feedback for all operations
4. **Maintainability:** Simple, well-documented code that's easy to modify
5. **Compatibility:** Work on all macOS versions 10.15+ without additional dependencies

### Constraints

**Technical Constraints:**
- Must use only bash 3.2+ features (macOS default)
- Cannot require external package managers (npm, pip, brew)
- Must work offline (no network dependencies)
- File size must remain minimal (<100KB for script)
- Must comply with Apple MDM Protocol specification

**Business Constraints:**
- MVP must be delivered within 2 weeks
- Must be distributed under MIT License
- Must position as educational/sample code
- Must include comprehensive documentation

**User Constraints:**
- Target users are IT administrators with command-line proficiency
- Users must have macOS 10.15 or later
- Users must have write permissions in working directory
- Users must have access to MDM platform for deployment

### Quality Attributes

| Attribute | Priority | Target | Measurement |
|-----------|----------|--------|-------------|
| **Correctness** | Critical | 100% valid XML | xmllint validation + MDM deployment success |
| **Performance** | High | <1s execution | Built-in timing for 20-app config |
| **Reliability** | Critical | Zero crashes | Error handling for all failure modes |
| **Usability** | High | <5 min total time | User feedback surveys |
| **Maintainability** | Medium | Clear code | Code review, documentation coverage |
| **Portability** | High | macOS 10.15+ | Testing on multiple OS versions |

---

## High-Level Architecture

### Architectural Style

**Pipeline Architecture** - Data flows through sequential processing stages:

```
Input → Parse → Validate → Generate → Validate → Write → Confirm
```

Each stage is independent and can be tested in isolation. Errors at any stage halt the pipeline and provide clear feedback.

### Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Layup Shell Script                      │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  1. Argument Parser                                     │ │
│  │  - Parse command-line arguments                        │ │
│  │  - Handle --help flag                                  │ │
│  │  - Validate file paths                                 │ │
│  └────────────────┬───────────────────────────────────────┘ │
│                   │                                          │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  2. Input File Reader                                   │ │
│  │  - Read file line-by-line                              │ │
│  │  - Handle different line endings (LF/CRLF)             │ │
│  │  - Check file existence and readability                │ │
│  └────────────────┬───────────────────────────────────────┘ │
│                   │                                          │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  3. Line Processor                                      │ │
│  │  - Trim whitespace                                     │ │
│  │  - Filter comments (# prefix)                          │ │
│  │  - Skip empty lines                                    │ │
│  │  - Track line numbers for error reporting              │ │
│  └────────────────┬───────────────────────────────────────┘ │
│                   │                                          │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  4. Bundle ID Validator                                 │ │
│  │  - Regex pattern matching                              │ │
│  │  - Segment count validation                            │ │
│  │  - Character set validation                            │ │
│  │  - Error message generation                            │ │
│  └────────────────┬───────────────────────────────────────┘ │
│                   │                                          │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  5. XML Generator                                       │ │
│  │  - UUID generation (uuidgen)                           │ │
│  │  - Timestamp generation (date)                         │ │
│  │  - XML template population (heredoc)                   │ │
│  │  - Special character escaping                          │ │
│  │  - App dictionary construction                         │ │
│  └────────────────┬───────────────────────────────────────┘ │
│                   │                                          │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  6. XML Validator                                       │ │
│  │  - xmllint well-formedness check                       │ │
│  │  - DTD validation                                      │ │
│  │  - Error reporting                                     │ │
│  └────────────────┬───────────────────────────────────────┘ │
│                   │                                          │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  7. File Writer                                         │ │
│  │  - Check output path validity                          │ │
│  │  - Overwrite confirmation prompt                       │ │
│  │  - Atomic file write                                   │ │
│  │  - Permission verification                             │ │
│  └────────────────┬───────────────────────────────────────┘ │
│                   │                                          │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  8. Finder Integration                                  │ │
│  │  - Execute 'open -R' command                           │ │
│  │  - Reveal file in Finder                               │ │
│  │  - Handle failure gracefully                           │ │
│  └────────────────┬───────────────────────────────────────┘ │
│                   │                                          │
│                   ▼                                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  9. Output Reporter                                     │ │
│  │  - Success/failure messages                            │ │
│  │  - Statistics (apps processed, errors, warnings)       │ │
│  │  - File path confirmation                              │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow Diagram

```
┌──────────────┐
│ Command Line │
│  Arguments   │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ Input Validation                                          │
│ - Check file exists                                       │
│ - Check file readable                                     │
│ - Parse output path (optional)                            │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ File Reading & Parsing                                    │
│ Input: apps.txt                                           │
│ Output: Array of raw lines                                │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ Line Processing                                           │
│ Input: Raw lines                                          │
│ Process: Trim, filter comments, skip empty               │
│ Output: Array of candidate Bundle IDs                    │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ Bundle ID Validation                                      │
│ Input: Candidate Bundle IDs                               │
│ Process: Regex validation, format checking                │
│ Output: Array of valid Bundle IDs + error list           │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ XML Generation                                            │
│ Input: Valid Bundle IDs                                   │
│ Process: Template population, UUID generation             │
│ Output: Complete XML string                               │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ XML Validation                                            │
│ Input: XML string                                         │
│ Process: xmllint validation                               │
│ Output: Validation result (pass/fail)                     │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ File Writing                                              │
│ Input: Valid XML string                                   │
│ Process: Overwrite check, atomic write                    │
│ Output: .mobileconfig file on disk                        │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│ Finder Integration                                        │
│ Input: Output file path                                   │
│ Process: Execute 'open -R' command                        │
│ Output: Finder window with file selected                  │
└──────┬───────────────────────────────────────────────────┘
       │
       ▼
┌──────────────┐
│ Exit with    │
│ Status Code  │
└──────────────┘
```

### Error Handling Strategy

**Fail-Fast Approach:** Errors halt execution immediately with clear feedback.

```
┌─────────────────┐
│  Any Stage      │
└────────┬────────┘
         │
         ▼
    ┌────────┐
    │ Error? │
    └───┬─┬──┘
        │ │
    No  │ │  Yes
        │ │
        │ └──────────────┐
        │                │
        ▼                ▼
┌───────────────┐  ┌──────────────────┐
│ Continue to   │  │ 1. Log error to  │
│ Next Stage    │  │    stderr        │
└───────────────┘  │ 2. Show line #   │
                   │    if applicable │
                   │ 3. Suggest fix   │
                   │ 4. Exit with     │
                   │    error code    │
                   └──────────────────┘
```

---

## Technology Stack

### Core Technologies

| Component | Technology | Version | Rationale |
|-----------|-----------|---------|-----------|
| **Shell** | Bash | 3.2+ | Default on macOS, widely understood |
| **UUID Generation** | uuidgen | System default | Standard Unix tool, reliable |
| **XML Validation** | xmllint | System default | Part of libxml2, always available |
| **Text Processing** | sed, awk, grep | System default | Standard Unix utilities |
| **Date/Time** | date | System default | Timestamp generation |
| **File Operations** | open | System default | Finder integration |

### Development Tools

| Tool | Purpose | Version |
|------|---------|---------|
| **Text Editor** | Script development | Any (VS Code, vim, nano) |
| **Git** | Version control | 2.0+ |
| **GitHub** | Repository hosting | N/A |
| **ShellCheck** | Static analysis (optional) | Latest |

### Testing Tools

| Tool | Purpose | Availability |
|------|---------|--------------|
| **xmllint** | XML validation | macOS default |
| **MDM Platform** | Deployment testing | Jamf Pro / Intune |
| **iOS/iPadOS Devices** | End-to-end testing | Test devices |

### No External Dependencies

**Critical Design Decision:** The script uses ONLY tools available by default on macOS 10.15+. This ensures:
- Zero installation friction
- Maximum compatibility
- No version conflicts
- Works in air-gapped environments
- Minimal security surface area

---

## Data Architecture

### Input Data Model

**File Format:** Plain text (UTF-8)

**Structure:**
```
[comment_line | empty_line | bundle_id_line]*
```

**Line Types:**

1. **Comment Line**
   - Pattern: `^\s*#.*$`
   - Action: Skip, increment warning counter
   - Example: `# Communication apps`

2. **Empty Line**
   - Pattern: `^\s*$`
   - Action: Skip silently
   - Example: ` ` (whitespace only)

3. **Bundle ID Line**
   - Pattern: `^\s*[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+\s*$`
   - Action: Validate and process
   - Example: `com.apple.mobilesafari`

### Bundle ID Data Model

**Format:** Reverse-DNS notation

**Validation Rules:**
```bash
# Regex pattern
BUNDLE_ID_PATTERN='^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$'

# Constraints
- Minimum segments: 2
- Segment separator: '.'
- Valid characters: a-z, A-Z, 0-9, underscore (_), hyphen (-)
- Cannot start/end with dot
- Cannot have consecutive dots
- Case-sensitive
```

**Examples:**

Valid:
- `com.apple.mobilesafari`
- `com.example.MyApp-Pro`
- `com.company.app.module_name`
- `com.app_123.test-version`

Invalid:
- `invalid` (only 1 segment)
- `com.app space` (contains space)
- `.com.apple.app` (starts with dot)
- `com.apple.` (ends with dot)
- `com..apple.app` (consecutive dots)

### Output Data Model

**File Format:** XML Property List (plist)

**Structure:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <!-- Configuration Profile Container -->
    <key>PayloadContent</key>
    <array>
      <dict>
        <!-- Home Screen Layout Payload -->
      </dict>
    </array>
    <!-- Profile Metadata -->
  </dict>
</plist>
```

**Key Data Elements:**

1. **Configuration Profile (Outer)**
   - PayloadType: "Configuration"
   - PayloadVersion: 1
   - PayloadIdentifier: "com.layup.config.[UUID]"
   - PayloadUUID: [UUID]
   - PayloadDisplayName: "Home Screen Layout Configuration"
   - PayloadDescription: "Generated by Layup"
   - PayloadOrganization: "Layup"

2. **Home Screen Layout Payload (Inner)**
   - PayloadType: "com.apple.homescreenlayout.managed"
   - PayloadVersion: 1
   - PayloadIdentifier: "com.layup.homescreenlayout.[UUID]"
   - PayloadUUID: [UUID]
   - PayloadDisplayName: "Home Screen Layout"
   - PayloadDescription: "Managed home screen layout"
   - Dock: [] (empty array)
   - Pages: [[app_dict, app_dict, ...]]

3. **App Dictionary**
   - Type: "Application"
   - BundleID: [bundle_id]

### Data Transformation Pipeline

```
Input Text File
      ↓
[Line-by-line reading]
      ↓
Raw Lines Array
      ↓
[Whitespace trimming, comment filtering]
      ↓
Candidate Bundle IDs Array
      ↓
[Regex validation]
      ↓
Valid Bundle IDs Array
      ↓
[XML escaping]
      ↓
Escaped Bundle IDs Array
      ↓
[Template population with UUIDs]
      ↓
Complete XML String
      ↓
[xmllint validation]
      ↓
Validated XML String
      ↓
[File write]
      ↓
.mobileconfig File
```

### State Management

**Script State Variables:**

```bash
# Input tracking
declare -a raw_lines
declare -a valid_bundle_ids
declare -i line_number=0

# Statistics
declare -i total_lines=0
declare -i valid_count=0
declare -i invalid_count=0
declare -i comment_count=0
declare -i empty_count=0

# Configuration
input_file=""
output_file=""
timestamp=""

# Generated values
payload_uuid=""
config_uuid=""
```

**No Persistent State:** Script is stateless between executions. Each run is independent.

---

## Security Architecture

### Threat Model

**Assets to Protect:**
1. User's file system (prevent unauthorized writes)
2. Generated configuration profiles (ensure validity)
3. User's Bundle ID data (privacy)

**Threat Actors:**
- Malicious input files
- File system permission issues
- XML injection attacks
- Path traversal attempts

### Security Controls

#### 1. Input Validation

**Bundle ID Sanitization:**
```bash
# Strict regex validation prevents injection
validate_bundle_id() {
    local bundle_id="$1"
    if [[ $bundle_id =~ $BUNDLE_ID_PATTERN ]]; then
        return 0
    else
        return 1
    fi
}
```

**File Path Validation:**
```bash
# Check file exists and is readable
if [[ ! -f "$input_file" ]]; then
    echo "ERROR: Input file not found" >&2
    exit 1
fi

if [[ ! -r "$input_file" ]]; then
    echo "ERROR: Input file not readable" >&2
    exit 1
fi
```

#### 2. XML Injection Prevention

**Special Character Escaping:**
```bash
escape_xml() {
    local text="$1"
    # Order matters: & must be first
    text="${text//&/&amp;}"
    text="${text//</&lt;}"
    text="${text//>/&gt;}"
    text="${text//\"/&quot;}"
    text="${text//\'/&apos;}"
    echo "$text"
}
```

**Why This Matters:** Even though valid Bundle IDs shouldn't contain XML special characters, defense-in-depth requires escaping.

#### 3. File System Security

**Write Permission Check:**
```bash
# Check directory is writable before attempting write
output_dir=$(dirname "$output_file")
if [[ ! -w "$output_dir" ]]; then
    echo "ERROR: Cannot write to directory" >&2
    exit 4
fi
```

**Overwrite Protection:**
```bash
# Prompt before overwriting existing files
if [[ -f "$output_file" ]]; then
    read -p "File exists. Overwrite? (y/n): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi
```

**File Permissions:**
```bash
# Set secure permissions (644: rw-r--r--)
chmod 644 "$output_file"
```

#### 4. Privacy Protection

**No Network Calls:**
- Script operates entirely offline
- No telemetry or analytics
- No external API calls
- No data leaves user's machine

**No Logging of Sensitive Data:**
- Bundle IDs logged only to stdout (user's terminal)
- No persistent logs created
- No temporary files with sensitive data

#### 5. Code Injection Prevention

**Safe Variable Expansion:**
```bash
# Always quote variables
echo "$variable"  # Safe
echo $variable    # Unsafe

# Use arrays for multiple values
valid_ids=()
valid_ids+=("$bundle_id")  # Safe
```

**Avoid eval:**
```bash
# Never use eval with user input
# eval "$user_input"  # NEVER DO THIS
```

### Security Best Practices

1. **Principle of Least Privilege:** Script only requires read access to input file and write access to output directory
2. **Fail Secure:** All errors halt execution; no partial writes
3. **Input Validation:** Strict regex validation for all user input
4. **Output Encoding:** XML special characters properly escaped
5. **No Secrets:** Script contains no hardcoded credentials or API keys

### Security Testing

**Test Cases:**
- [ ] Malformed Bundle IDs with special characters
- [ ] Path traversal attempts in file paths
- [ ] XML injection attempts in Bundle IDs
- [ ] Permission denied scenarios
- [ ] Symbolic link handling
- [ ] Large file handling (DoS prevention)

---

## Deployment Architecture

### Distribution Model

**Single-File Distribution:**
```
layup/
├── layup.sh              # Executable script (main deliverable)
├── README.md             # Documentation
├── LICENSE               # MIT License
├── CHANGELOG.md          # Version history
├── examples/
│   ├── sample_apps.txt
│   └── sample_apps_with_comments.txt
└── tests/
    ├── test_valid_input.txt
    ├── test_invalid_input.txt
    └── test_edge_cases.txt
```

### Installation Process

**Method 1: Direct Download**
```bash
# Download script
curl -O https://raw.githubusercontent.com/[user]/layup/main/layup.sh

# Make executable
chmod +x layup.sh

# Run
./layup.sh apps.txt
```

**Method 2: Git Clone**
```bash
# Clone repository
git clone https://github.com/[user]/layup.git

# Navigate to directory
cd layup

# Make executable
chmod +x layup.sh

# Run
./layup.sh examples/sample_apps.txt
```

**Method 3: Add to PATH (Optional)**
```bash
# Copy to user bin directory
cp layup.sh ~/bin/layup

# Or add to PATH
export PATH="$PATH:/path/to/layup"

# Run from anywhere
layup apps.txt
```

### System Requirements

**Minimum Requirements:**
- macOS 10.15 (Catalina) or later
- bash 3.2 or later (included in macOS)
- 10MB free disk space
- Write permissions in working directory

**Verified Compatibility:**
- macOS 10.15 (Catalina)
- macOS 11 (Big Sur)
- macOS 12 (Monterey)
- macOS 13 (Ventura)
- macOS 14 (Sonoma)

**Shell Compatibility:**
- bash (primary target)
- zsh (macOS default since Catalina)

### Runtime Environment

**Execution Context:**
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script runs in user's current working directory
# No special environment variables required
# No configuration files needed
```

**Resource Usage:**
- Memory: <10MB
- CPU: Minimal (completes in <1 second)
- Disk I/O: Read input file, write output file
- Network: None

### Deployment Checklist

**Pre-Release:**
- [ ] Test on all supported macOS versions
- [ ] Verify bash 3.2 compatibility
- [ ] Test with both bash and zsh
- [ ] Validate generated files with xmllint
- [ ] Deploy test files to MDM platform
- [ ] Verify on iOS/iPadOS devices
- [ ] Review all error messages
- [ ] Update version number in script
- [ ] Update CHANGELOG.md
- [ ] Tag release in Git

**Release:**
- [ ] Create GitHub release
- [ ] Upload script and examples
- [ ] Write release notes
- [ ] Update README with installation instructions
- [ ] Announce in relevant communities

**Post-Release:**
- [ ] Monitor GitHub issues
- [ ] Gather user feedback
- [ ] Track success metrics
- [ ] Plan next iteration

---

## Integration Points

### Input Integration

**Text Editors:**
- Any text editor can create input files
- Recommended: VS Code, Sublime Text, TextEdit, vim, nano
- Format: Plain text, UTF-8 encoding

**Version Control:**
- Input files can be tracked in Git
- Enables team collaboration on layouts
- Supports change history and rollback

**Automation:**
- Script can be called from other scripts
- Exit codes enable error handling
- stdout/stderr separation supports logging

### Output Integration

**MDM Platforms:**

1. **Jamf Pro**
   - Upload: Configuration Profiles → Upload
   - Assign: Scope to devices/groups
   - Deploy: Push to devices

2. **Microsoft Intune**
   - Upload: Devices → Configuration Profiles → Create Profile
   - Platform: iOS/iPadOS
   - Profile Type: Custom
   - Upload .mobileconfig file

3. **Workspace ONE**
   - Upload: Resources → Profiles → Add Profile
   - Platform: Apple iOS
   - Upload .mobileconfig file

**File System:**
- Output files saved to specified location
- Default: Current working directory
- Custom: User-specified path
- Finder integration: Automatic reveal

### External Tool Integration

**CI/CD Pipelines:**
```bash
# Example: Jenkins/GitHub Actions
./layup.sh input/production_layout.txt output/prod.mobileconfig
if [ $? -eq 0 ]; then
    # Upload to MDM via API
    curl -X POST https://mdm.example.com/api/profiles \
         -F "file=@output/prod.mobileconfig"
fi
```

**Validation Tools:**
```bash
# Validate generated file
xmllint --noout output.mobileconfig
if [ $? -eq 0 ]; then
    echo "Valid XML"
fi
```

**Backup Systems:**
```bash
# Archive generated configurations
./layup.sh apps.txt configs/layout_$(date +%Y%m%d).mobileconfig
git add configs/
git commit -m "Update home screen layout"
```

### API Boundaries

**Input API (Command Line):**
```bash
layup.sh <input_file> [output_file]
layup.sh --help
layup.sh -h
```

**Output API (Exit Codes):**
- 0: Success
- 1: Input file not found
- 2: Input file empty
- 3: No valid Bundle IDs
- 4: Write error
- 5: Validation error

**Logging API:**
- stdout: Progress, success messages, statistics
- stderr: Error messages, warnings

### Future Integration Points (Post-MVP)

**Phase 2:**
- Multi-page input format (CSV or structured text)
- Dock configuration section
- Folder definitions

**Phase 3:**
- Bundle ID lookup database (local JSON file)
- Template library (predefined layouts)
- Direct MDM API integration
- Import existing .mobileconfig for editing

---

## Architectural Decision Records (ADRs)

### Overview

This section tracks architectural decisions made for the Layup project. Each ADR documents the context, decision, status, and consequences of significant architectural choices.

### ADR Format

Each ADR follows this structure:
- **Title:** Short descriptive name
- **Status:** Proposed | Accepted | Deprecated | Superseded
- **Context:** The issue motivating this decision
- **Decision:** The change being proposed or implemented
- **Consequences:** The resulting context after applying the decision

---

### Completed ADRs

#### ADR-001: Use Bash Shell Script Instead of Web Application

**Status:** Accepted

**Context:**
The original concept envisioned a React/Next.js web application hosted on Vercel. However, the target users (IT administrators) primarily work in Terminal environments and prefer tools that integrate with their existing workflows.

**Decision:**
Implement Layup as a bash shell script that runs locally on macOS.

**Consequences:**

*Positive:*
- Faster development, zero hosting costs, works offline, natural fit for IT admin workflows, easy automation integration, simple distribution, version control friendly, privacy-preserving

*Negative:*
- Command-line only, requires Terminal proficiency, limited to macOS

*Mitigation:*
- Comprehensive documentation, clear error messages, plan GUI wrapper for Phase 4 if needed

---

#### ADR-002: Single Page Layout for MVP

**Status:** Accepted

**Context:**
iOS/iPadOS devices support multiple Home Screen pages. However, implementing multi-page support adds complexity.

**Decision:**
MVP will support only single-page layouts (up to 20 apps). Multi-page support deferred to Phase 2.

**Consequences:**

*Positive:*
- Simpler input format, faster MVP development, easier to test, covers most common use case (80%)

*Negative:*
- Cannot configure multi-page layouts in MVP

*Mitigation:*
- Clear roadmap showing multi-page in Phase 2, gather user feedback

---

#### ADR-003: Plain Text Input Format

**Status:** Accepted

**Context:**
Multiple input format options were considered: web form, JSON, CSV, plain text list, YAML.

**Decision:**
Use plain text format with one Bundle ID per line, supporting comments (#) and empty lines.

**Consequences:**

*Positive:*
- Extremely simple to create/edit, works with any text editor, natural reading order, version control friendly, no special syntax

*Negative:*
- No explicit position numbers, cannot skip positions, limited metadata support

---

#### ADR-004: Zero External Dependencies

**Status:** Accepted

**Context:**
Shell scripts can leverage external tools and package managers, but this creates installation friction.

**Decision:**
Use ONLY tools available by default on macOS 10.15+: bash 3.2+, uuidgen, xmllint, standard Unix utilities.

**Consequences:**

*Positive:*
- Zero installation friction, no version conflicts, works in air-gapped environments, maximum compatibility, minimal security surface

*Negative:*
- Limited to capabilities of standard tools, cannot use modern bash 4+ features

---

#### ADR-005: MIT License for Maximum Adoption

**Status:** Accepted

**Context:**
Open source license selection impacts adoption, especially in enterprise environments.

**Decision:**
Use MIT License with clear educational/sample code positioning in documentation.

**Consequences:**

*Positive:*
- Maximum adoption, corporate-friendly, simple terms, allows commercial use, preserves attribution, strong liability protection

*Negative:*
- No patent protection, no copyleft, may be used in ways not intended

*Mitigation:*
- Clear "Intended Use" section in README, position as educational/sample code

---

#### ADR-006: Fail-Fast Error Handling

**Status:** Accepted

**Context:**
Error handling strategies include: continue on error, fail-fast, collect all errors, interactive recovery.

**Decision:**
Implement fail-fast error handling with `set -euo pipefail` and explicit error checking at each stage.

**Consequences:**

*Positive:*
- Prevents cascading failures, clear error messages, no partial/corrupted output, predictable behavior, safe for automation

*Negative:*
- Cannot process partial input, may be frustrating if one Bundle ID is invalid

*Mitigation:*
- Clear error messages with line numbers, show all validation errors before failing

---

#### ADR-007: Finder Integration for User Experience

**Status:** Accepted

**Context:**
After generating a `.mobileconfig` file, users need to locate it to upload to their MDM.

**Decision:**
Use `open -R` command to reveal the generated file in Finder, with the file selected.

**Consequences:**

*Positive:*
- Immediate visual confirmation, easy drag/drop to MDM console, reduces friction, professional UX

*Negative:*
- Assumes GUI environment, may be unexpected in automation contexts

*Mitigation:*
- Fail gracefully if `open` command fails, don't fail entire operation

---

#### ADR-008: XML Validation with xmllint

**Status:** Accepted

**Context:**
Generated XML must be valid before writing to file.

**Decision:**
Use xmllint to validate generated XML before writing to file.

**Consequences:**

*Positive:*
- Catches XML syntax errors before deployment, validates against Apple's plist DTD, available by default, industry-standard

*Negative:*
- Adds minimal execution time

---

### Pending ADRs

These architectural decisions need to be addressed in future phases:

#### ADR-009: Multi-Page Input Format (Phase 2)

**Status:** Proposed

**Context:**
When implementing multi-page support, we need to decide on input format.

**Decision:** TBD

**Questions to Resolve:**
- How do users naturally think about multi-page layouts?
- Should we maintain backward compatibility with single-page format?
- What's the simplest format that supports pages, dock, and folders?

**Target:** Phase 2 (3-6 months post-MVP)

---

#### ADR-010: Bundle ID Lookup Database (Phase 3)

**Status:** Proposed

**Context:**
Users may not know Bundle IDs for common apps. A lookup feature could help.

**Decision:** TBD

**Target:** Phase 3 (6-12 months post-MVP)

---

#### ADR-011: GUI Wrapper Implementation (Phase 4)

**Status:** Proposed

**Context:**
Some users may prefer a graphical interface.

**Decision:** TBD

**Target:** Phase 4 (12+ months post-MVP)

---

#### ADR-012: Direct MDM Integration (Phase 4)

**Status:** Proposed

**Context:**
Uploading files manually to MDM is a friction point. Direct API integration could streamline workflow.

**Decision:** TBD

**Target:** Phase 4 (12+ months post-MVP)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-26 | Architecture Team | Initial architecture plan for MVP |

---

## References

1. [Apple MDM Protocol Reference](https://developer.apple.com/documentation/devicemanagement)
2. [Home Screen Layout Payload Documentation](https://developer.apple.com/documentation/devicemanagement/homescreenlayout)
3. [Configuration Profile Reference](https://developer.apple.com/documentation/devicemanagement/configurationprofile)
4. Layup Product Brief ([`Layup_Product_Brief.md`](Layup_Product_Brief.md))
5. Layup PRD ([`Layup_PRD.md`](Layup_PRD.md))
6. Layup Modifications Summary ([`Layup_Modifications_Summary.md`](Layup_Modifications_Summary.md))

---

**END OF DOCUMENT**