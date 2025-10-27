# Layup - Product Brief
**Date:** October 24, 2025

---

## Background
You are a product manager tasked with discovery for Layup, a tool that generates iOS/iPadOS Home Screen Layout configuration payloads. Your VP Product has asked you to solve the manual XML creation problem for MDM professionals. Below is the concept brief for MVP development.

---

## Layup - Concept Brief

### Problem Statement (Root Cause Analysis)

**Core Problem:** MDM professionals waste significant time hand-crafting Home Screen Layout .mobileconfig files in XML, with high error rates causing deployment failures and rework cycles.

**Causal Chain Identified:**
```
Manual XML editing → Syntax errors + Bundle ID mistakes → Failed deployments → 
Troubleshooting time → Rework → Delayed rollouts → IT productivity loss
```

**Root Causes:**
1. **Complexity Barrier:** Home Screen Layout payloads require precise XML structure with nested arrays and dictionaries
2. **Bundle ID Management:** Apps must be referenced by exact Bundle IDs (e.g., `com.apple.mobilesafari`), which are non-intuitive and must be looked up
3. **Validation Gap:** No immediate feedback on payload validity before MDM deployment
4. **Context Switching:** Moving between documentation, Bundle ID references, and XML editors breaks flow

**Solution:** 
```
Structured input form → Automatic payload generation → Valid .mobileconfig output → 
Zero syntax errors → Instant deployment → Time saved
```

---

### User Profile

**Primary Users:** IT Administrators and MDM Specialists

**Technical Level:** High (comfortable with MDM concepts, Bundle IDs, configuration profiles)

**Current Workflow Being Replaced:**
1. Reference Apple MDM Protocol documentation
2. Open text editor or XML IDE
3. Manually construct payload structure
4. Look up Bundle IDs for each app
5. Type XML with proper nesting and syntax
6. Test deployment
7. Debug errors
8. Repeat steps 5-7 until valid

**Pain Points:**
- Time-consuming manual XML creation (30-60 minutes per configuration)
- High error rate from typos and structural mistakes
- Difficulty remembering exact Bundle ID format
- No validation until deployment attempt
- Tedious for multi-page layouts

**Success Behavior:** 
- Generate valid .mobileconfig files in <5 minutes
- Zero syntax errors requiring rework
- Confident deployment on first attempt

---

### Core Value Proposition

A streamlined configuration generator that eliminates XML hand-crafting by converting simple Bundle ID input into spec-compliant Home Screen Layout .mobileconfig payloads, reducing deployment time from hours to minutes while eliminating syntax errors.

---

### Minimum Viable Product (MVP) Features

#### 1. Bundle ID Input Interface

**Page Scope:**
- MVP: Single page only (Page 1)
- Multi-page support deferred to post-MVP

**Input Method:**
- Plain text file containing Bundle IDs
- One Bundle ID per line
- Bundle ID format: `com.company.appname`
- Empty lines ignored
- Comments supported with `#` prefix

**Input File Format:**
```
# Home Screen Layout - Page 1
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.apple.mobileslideshow
# Add more apps below (up to 20-24 depending on device)
com.microsoft.Office.Outlook
com.google.chrome.ios
```

**Layout Structure:**
- Single page with up to 20 app positions (iPhone standard)
- Order in file = order on Home Screen (left-to-right, top-to-bottom)
- Positions beyond device limits ignored with warning

#### 2. Payload Generation Engine

**Core Functionality:**
- Parse Bundle ID inputs from all pages
- Construct MDM Home Screen Layout payload per Apple specification
- Generate complete .mobileconfig file structure
- Include required payload headers (PayloadType, PayloadVersion, PayloadIdentifier, etc.)

**Payload Structure Requirements:**
```xml
PayloadType: com.apple.homescreenlayout.managed
PayloadVersion: 1
Dock: [] (empty for MVP)
Pages: Array of app dictionaries with BundleID and Type keys
```

**Validation Rules:**
- Ignore empty text fields
- Maintain page order
- Ensure valid XML structure
- Include proper escaping for special characters

#### 3. File Export

**Output:**
- Generates `.mobileconfig` file automatically
- Default filename format: `HomeScreenLayout_[timestamp].mobileconfig`
- Default location: Current working directory
- Optional: User can specify custom output path as second argument

**Command Syntax:**
```bash
# Default output (current directory with timestamp)
./layup.sh apps.txt

# Custom output location
./layup.sh apps.txt /path/to/output.mobileconfig
```

**File Properties:**
- Complete, deployable configuration profile
- Apple-compliant XML structure
- File encoding: UTF-8
- Line breaks: Unix-style (LF)
- Includes all required keys per MDM protocol
- Ready for immediate MDM upload

---

### Technical Specifications

#### Platform Requirements

**Platform:** 
- Bash shell script for macOS
- Compatible with macOS 10.15 (Catalina) and later
- No external dependencies beyond standard Unix tools
- Executable from Terminal

**Execution Method:**
```bash
./layup.sh input.txt
```

**Requirements:**
- Bash 3.2+ (included in macOS)
- Standard Unix utilities (sed, awk, grep)
- Write permissions for output directory

**Distribution:**
- Single shell script file
- GitHub repository for version control
- Simple installation: download and `chmod +x layup.sh`

**Development Approach:**
- POSIX-compliant where possible
- Clear error messages
- Exit codes for automation integration

#### Data Handling

**Input Processing:**
- Read text file line-by-line
- Strip whitespace and comments
- Validate Bundle ID format (basic regex)
- Build array of valid Bundle IDs

**Validation Rules:**
- Bundle ID must match pattern: `[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+`
- Lines starting with `#` are comments (ignored)
- Empty lines ignored
- Invalid entries logged to stderr with line numbers

**Data Flow:**
```
Input file → Parse & validate → Build XML structure → Write .mobileconfig → Exit
```

**Error Handling:**
- Invalid file path: Exit with error code 1
- Empty input file: Exit with error code 2
- No valid Bundle IDs: Exit with error code 3
- Write failure: Exit with error code 4

#### XML Generation

**Approach:**
- Template-based XML construction using heredoc
- String substitution for dynamic values
- Proper XML escaping for special characters

**Template Structure:**
```bash
cat > output.mobileconfig << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Payload content here -->
</dict>
</plist>
EOF
```

**Dynamic Elements:**
- UUID generation using `uuidgen` command
- Timestamp for PayloadIdentifier uniqueness
- App array construction from input Bundle IDs
- Iterative loop to build app dictionaries

#### Apple MDM Protocol Compliance

**Reference Documentation:**
- Apple MDM Protocol Reference
- Configuration Profile Reference (Home Screen Layout)

**Required Payload Keys:**
- `PayloadType`: com.apple.homescreenlayout.managed
- `PayloadVersion`: 1
- `PayloadIdentifier`: Unique identifier
- `PayloadUUID`: Generated UUID
- `PayloadDisplayName`: User-friendly name
- `PayloadDescription`: Optional description
- `Dock`: Array (empty for MVP)
- `Pages`: Array of page dictionaries

**App Dictionary Structure:**
```xml
<dict>
    <key>Type</key>
    <string>Application</string>
    <key>BundleID</key>
    <string>com.example.app</string>
</dict>
```

---

### Success Metrics (Quantitative)

#### Primary KPIs

**Time to Generate:**
- Target: <5 minutes from start to download
- Baseline comparison: 30-60 minutes manual XML creation
- Success threshold: 80% reduction in time

**Error Rate:**
- Target: Zero syntax errors in generated files
- Baseline: ~40% of manual configurations require debugging
- Success threshold: 100% valid XML output

**Deployment Success Rate:**
- Target: 100% first-deployment success
- Metric: Generated files deploy without modification
- Validation: No MDM error messages on profile installation

#### Secondary Metrics

**User Adoption:**
- Repeat usage rate after first successful generation
- Recommendation rate (qualitative feedback)

**Complexity Handled:**
- Average number of pages generated per configuration
- Total apps configured per session

**Time Savings:**
- Calculate: (Manual time - Tool time) × Usage frequency
- ROI metric for IT departments

---

### User Experience Flow

#### Core User Journey

**1. Prepare Input File**
- Create text file with Bundle IDs (one per line)
- Add comments with `#` for documentation
- Save file (e.g., `apps.txt`)

**2. Execute Script**
- Open Terminal
- Navigate to script directory (or add to PATH)
- Run: `./layup.sh apps.txt`
- Observe validation messages

**3. Review Output**
- Script generates `HomeScreenLayout_[timestamp].mobileconfig`
- Success message displays output filename
- Review any warnings about skipped entries

**4. Deploy**
- Upload .mobileconfig to MDM solution
- Assign to target devices
- Verify Home Screen layout on device

#### Key Interactions

**Command Syntax:**
```bash
./layup.sh <input_file> [output_file]
```

**Output:**
- Default: `HomeScreenLayout_YYYYMMDD_HHMMSS.mobileconfig`
- Optional: Specify custom output filename

**Feedback:**
```
Processing: apps.txt
✓ Line 1: com.apple.mobilesafari (valid)
✓ Line 2: com.apple.mobilemail (valid)
⚠ Line 5: Skipping comment
✗ Line 8: invalid.bundle (invalid format)

Generated: HomeScreenLayout_20251024_143022.mobileconfig
Total apps: 15
```

---

### Risk Mitigation

#### Technical Risks

**Risk: Invalid XML Generation**
- Mitigation: Use heredoc with careful escaping
- Mitigation: Test with special characters in Bundle IDs
- Mitigation: Validate output against Apple's plist DTD

**Risk: Apple Specification Changes**
- Mitigation: Version documentation reference in script header
- Mitigation: Monitor Apple developer updates
- Mitigation: User feedback channel for deployment issues

**Risk: macOS Version Compatibility**
- Mitigation: Test on multiple macOS versions (10.15+)
- Mitigation: Use only standard Unix utilities
- Mitigation: Avoid bash 4+ specific features

**Risk: File Permission Issues**
- Mitigation: Check write permissions before generation
- Mitigation: Clear error messages for permission denied
- Mitigation: Suggest current directory as safe default

#### User Experience Risks

**Risk: Input File Format Confusion**
- Mitigation: Clear documentation with examples
- Mitigation: Helpful error messages with line numbers
- Mitigation: Sample input file in repository

**Risk: Unclear Error Messages**
- Mitigation: Specific error codes with descriptions
- Mitigation: Show problematic line and reason
- Mitigation: Suggest corrections for common mistakes

**Risk: Output File Location Confusion**
- Mitigation: Print full path to generated file
- Mitigation: Default to current working directory
- Mitigation: Add `--help` flag with usage examples

---

### Success Definition

**App succeeds if:**
- Generated .mobileconfig files deploy successfully 100% of the time (no syntax errors)
- IT admins reduce configuration time by >80% (from 30-60 min to <5 min)
- Users prefer running `./layup.sh` over manual XML creation
- Zero reported bugs related to payload structure compliance
- Script completes in <1 second for typical inputs (20 apps)

**Failure indicators:**
- Generated files fail MDM deployment validation
- Script crashes or hangs during execution
- Time savings <50% compared to manual process
- Critical bugs in XML structure requiring emergency patches
- Error messages are unclear or unhelpful

---

### Key Design Principles

**1. Specification Compliance First**
Every generated file must be 100% compliant with Apple MDM Protocol specifications. No shortcuts.

**2. Zero-Error Output**
The tool's core value is eliminating syntax errors. Any generated file must deploy successfully.

**3. Unix Philosophy**
Do one thing well: convert Bundle ID list to valid .mobileconfig. Nothing more.

**4. Clear Feedback**
Every action should provide immediate, actionable feedback. No silent failures.

**5. IT Professional Focus**
Design for users who understand Bundle IDs and MDM concepts. No over-explanation.

**6. Minimal Dependencies**
Use only standard macOS/Unix tools. No pip, npm, or external package managers required.

**7. Immediate Value**
From command execution to file output should be <1 second. Script efficiency matters.

**8. Privacy-Preserving**
No network calls. No telemetry. All processing local to user's machine.

---

### Post-MVP Roadmap (Future Considerations)

**Phase 2 Features:**
- Multi-page support (multiple input files or sections)
- Dock configuration (separate section in input file)
- Folder support with nested app syntax
- Interactive mode with prompts
- Validation mode (check existing .mobileconfig files)

**Phase 3 Features:**
- Bundle ID lookup/search from local database
- Template generation (common layouts)
- Device-specific layouts (iPhone vs iPad)
- Import existing .mobileconfig for editing
- GUI wrapper application (AppleScript or Swift)

**Metrics to Validate Before Next Phase:**
- Sustained usage >50 configurations/month
- User requests for specific features
- Clear use cases for multi-page vs single page
- ROI data showing significant time savings
- Community contributions on GitHub

---

## Appendix

### Common Bundle ID Reference (for documentation)

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

**Finding Bundle IDs:**
- iOS app IPA inspection
- MDM app catalog
- Apple Configurator 2
- Third-party Bundle ID databases

---

## Input File Format Specification

### Proposed Format: Simple List (Recommended)

**Format:** One Bundle ID per line, order matters

**Example (`apps.txt`):**
```
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.apple.mobileslideshow
com.apple.camera
com.apple.mobilecal
com.apple.Music
com.apple.AppStore
com.microsoft.Office.Outlook
com.google.chrome.ios
```

**Rules:**
- One Bundle ID per line
- Order in file = order on Home Screen (left-to-right, top-to-bottom, row 1 → row 4)
- Empty lines are ignored
- Leading/trailing whitespace is trimmed
- Lines starting with `#` are treated as comments

**With Comments (`apps_documented.txt`):**
```
# Home Screen Layout for Executive Team
# Page 1 - Row 1: Communication Apps
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.microsoft.teams.ios

# Row 2: Productivity
com.apple.mobilecal
com.microsoft.Office.Outlook
com.microsoft.Office.Word
com.microsoft.Office.Excel

# Row 3: Collaboration
com.slack.Slack
com.zoom.videomeetings
com.notion.NotionApp
com.trello.trello

# Row 4: Utilities
com.apple.Preferences
com.1password.ios
com.google.drive.ios
com.apple.AppStore
```

### Alternative Format Considerations (Not Implemented in MVP)

**Option B: Positioned Format** (More explicit, but more verbose)
```
1:com.apple.mobilesafari
2:com.apple.mobilemail
3:com.apple.MobileSMS
...
```
*Pros:* Explicit positioning, can skip positions  
*Cons:* More typing, not natural for simple lists  
*Decision:* Deferred to post-MVP if users request it

**Option C: CSV Format** (Future: Multi-page support)
```
page,position,bundleID
1,1,com.apple.mobilesafari
1,2,com.apple.mobilemail
2,1,com.apple.Music
```
*Pros:* Structured, supports multi-page easily  
*Cons:* Overkill for single page MVP  
*Decision:* Consider for Phase 2 multi-page support

### Validation Rules

**Valid Bundle ID Pattern:**
```regex
^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$
```

**Requirements:**
- At least two segments separated by dots
- Each segment: alphanumeric and hyphens only
- Cannot start or end with dot

**Valid Examples:**
- `com.apple.mobilesafari` ✓
- `com.example.MyApp-Pro` ✓
- `com.company.app.module` ✓

**Invalid Examples:**
- `invalid` ✗ (no dot separator)
- `com.app space` ✗ (contains space)
- `.com.apple.app` ✗ (starts with dot)
- `com.apple.` ✗ (ends with dot)

### Error Handling Examples

**Input File (`bad_input.txt`):**
```
com.apple.mobilesafari
invalid.bundle
com.apple.mobilemail

# This is a comment
com.google chrome.ios
```

**Expected Script Output:**
```
Processing: bad_input.txt
✓ Line 1: com.apple.mobilesafari (valid)
✗ Line 2: invalid.bundle (invalid format: must have at least 2 segments)
✓ Line 3: com.apple.mobilemail (valid)
⚠ Line 5: Skipping comment
✗ Line 6: com.google chrome.ios (invalid format: contains whitespace)

Generated: HomeScreenLayout_20251024_143022.mobileconfig
Total apps: 2
Warnings: 1 comment skipped
Errors: 2 invalid Bundle IDs skipped
```

---

### Technical References

**Apple Documentation:**
- [MDM Protocol Reference](https://developer.apple.com/documentation/devicemanagement)
- [Configuration Profile Reference](https://developer.apple.com/documentation/devicemanagement/configurationprofile)
- [Home Screen Layout Payload](https://developer.apple.com/documentation/devicemanagement/homescreenlayout)

**XML Standards:**
- Property List (plist) DTD
- UTF-8 encoding requirements
- CDATA handling for special characters

---

## Development Checklist

**Phase 0: Research & Validation**
- [ ] Review complete Apple MDM Protocol specification
- [ ] Validate payload structure with test MDM environment
- [ ] Confirm minimum required payload keys
- [ ] Test sample .mobileconfig files on real devices
- [ ] Document exact XML structure requirements

**Phase 1: Core Development**
- [ ] Create shell script with proper shebang and permissions
- [ ] Implement input file parsing (line-by-line)
- [ ] Build Bundle ID validation (regex pattern matching)
- [ ] Create XML generation using heredoc
- [ ] Add UUID generation with `uuidgen`
- [ ] Implement timestamp-based filename generation
- [ ] Add error handling with exit codes

**Phase 2: Validation & Testing**
- [ ] Generate test configurations (5, 10, 20 apps)
- [ ] Test with special characters in Bundle IDs
- [ ] Deploy to test MDM environment
- [ ] Validate on iOS devices (iPhone and iPad)
- [ ] Test error handling (missing files, invalid input)
- [ ] Cross-version testing (macOS 10.15, 11, 12, 13, 14)

**Phase 3: Polish & Launch**
- [ ] Add `--help` flag with usage documentation
- [ ] Improve error messages with line numbers
- [ ] Create comprehensive README with examples
- [ ] Add sample input file to repository
- [ ] Create installation instructions
- [ ] Publish to GitHub with MIT license
- [ ] Gather initial user feedback

---

**Last Updated:** October 24, 2025
**Document Owner:** Product Management
**Status:** Draft for Development Kickoff