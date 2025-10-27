
# Layup Testing Guide

**Version:** 1.0  
**Date:** October 27, 2025  
**Status:** Active  

---

## Table of Contents

1. [Introduction](#introduction)
2. [Section 1: Automated Testing](#section-1-automated-testing)
3. [Section 2: Manual MDM Deployment Testing](#section-2-manual-mdm-deployment-testing)
4. [Section 3: Validation Checklist](#section-3-validation-checklist)
5. [Section 4: Test Data and Examples](#section-4-test-data-and-examples)
6. [Section 5: Reporting Issues](#section-5-reporting-issues)
7. [Section 6: Cross-Platform Testing](#section-6-cross-platform-testing)

---

## Introduction

### Purpose of This Guide

This testing guide provides comprehensive instructions for validating the [`layup.sh`](../layup.sh) script through both automated testing and manual MDM deployment testing. It is designed for:

- **Developers** contributing to the project who need to run and write tests
- **QA Engineers** performing validation before releases
- **MDM Administrators** testing the tool in their specific environments
- **Contributors** verifying their changes work correctly

### What Will Be Tested

This guide covers testing at multiple levels:

1. **Unit Testing** - Individual functions and components
2. **Integration Testing** - End-to-end workflows
3. **Manual MDM Testing** - Real-world deployment scenarios
4. **Cross-Platform Testing** - Compatibility across macOS versions

### Prerequisites and Requirements

**For Automated Testing:**
- macOS 10.15+ (Catalina or later)
- Bash 3.2+ (pre-installed on macOS)
- [Bats](https://github.com/bats-core/bats-core) testing framework v1.12.0+
- Git for version control
- `xmllint` (pre-installed on macOS)

**For Manual MDM Testing:**
- Access to an MDM server (Jamf Pro, Workspace ONE, Microsoft Intune, or other)
- Test iOS/iPadOS devices (physical or simulators)
- Admin credentials for MDM console
- Sample Bundle IDs for testing
- Understanding of MDM configuration profile deployment

**Installation of Bats:**
```bash
# Using Homebrew (recommended)
brew install bats-core

# Verify installation
bats --version
```

---

## Section 1: Automated Testing

### 1.1 Overview of Test Suite

The Layup project uses [Bats (Bash Automated Testing System)](https://github.com/bats-core/bats-core) following London School TDD principles. The test suite includes:

- **Unit Tests** - Test individual functions in isolation (769 lines of tests)
- **Integration Tests** - Test complete workflows from input to output
- **Mock-Based Testing** - External dependencies are mocked for reliability

**Test Files Location:** [`tests/`](../tests/)

### 1.2 Running Unit Tests

Unit tests validate individual components of the script.

**Run All Unit Tests:**
```bash
# From project root directory
bats tests/test_*.bats

# Expected output:
# ✓ test description 1
# ✓ test description 2
# ...
# X tests, 0 failures
```

**Run Specific Test File:**
```bash
# Test argument parsing
bats tests/test_argument_parsing.bats

# Test Bundle ID validation
bats tests/test_bundle_id_validation.bats

# Test XML generation
bats tests/test_xml_generation.bats

# Test file output
bats tests/test_file_output.bats

# Test input validation
bats tests/test_input_validation.bats
```

**Run with Verbose Output:**
```bash
# Shows detailed output for each test
bats --verbose-run tests/test_bundle_id_validation.bats
```

**Run with Timing Information:**
```bash
# Shows execution time for each test
bats --timing tests/
```

### 1.3 Running Integration Tests

Integration tests validate end-to-end workflows.

**Run Integration Tests:**
```bash
# Run all integration tests
bats tests/test_integration.bats

# Run with verbose output
bats --verbose-run tests/test_integration.bats
```

**What Integration Tests Cover:**
- Complete workflow: input file → validation → XML generation → file output
- Error handling for invalid inputs
- File overwrite scenarios
- Statistics and reporting
- XML structure validation
- Edge cases (100+ Bundle IDs, special characters, etc.)

### 1.4 Running All Tests

**Run Complete Test Suite:**
```bash
# Run all tests in the tests/ directory
bats tests/

# Alternative: Run with pattern matching
bats tests/test_*.bats
```

**Expected Output:**
```
✓ argument parsing: --help flag displays help text
✓ argument parsing: missing input file shows error
✓ Bundle ID validation: accepts valid two-segment ID
✓ Bundle ID validation: rejects single segment
...
✓ integration: complete workflow generates XML output
✓ integration: workflow with 100+ Bundle IDs

X tests, 0 failures
```

### 1.5 Interpreting Test Results

**Success Indicators:**
- ✓ Green checkmarks indicate passing tests
- "X tests, 0 failures" at the end
- Exit code 0

**Failure Indicators:**
- ✗ Red X marks indicate failing tests
- Detailed error messages show what went wrong
- Exit code 1

**Example Failure Output:**
```
✗ Bundle ID validation: rejects invalid format
   (in test file tests/test_bundle_id_validation.bats, line 45)
     `assert_failure' failed
   Expected exit code 1, got 0
   
   Output:
   com.apple.safari
```

**Understanding Failure Messages:**
1. **Test Name** - Which test failed
2. **File and Line** - Where the test is located
3. **Assertion** - What was expected vs. what happened
4. **Output** - Actual output from the command

### 1.6 Troubleshooting Common Test Failures

#### Issue: "command not found: bats"

**Solution:**
```bash
# Install Bats using Homebrew
brew install bats-core

# Verify installation
which bats
bats --version
```

#### Issue: "Permission denied" when running tests

**Solution:**
```bash
# Make script executable
chmod +x layup.sh

# Make test files executable
chmod +x tests/*.bats
```

#### Issue: Tests fail with "xmllint: command not found"

**Solution:**
`xmllint` should be pre-installed on macOS. If missing:
```bash
# Check if xmllint exists
which xmllint

# If not found, it may be in /usr/bin
ls -l /usr/bin/xmllint

# Ensure Xcode Command Line Tools are installed
xcode-select --install
```

#### Issue: "No such file or directory" errors in tests

**Solution:**
```bash
# Ensure you're running tests from project root
cd /path/to/layup
pwd  # Should show layup directory

# Run tests
bats tests/
```

#### Issue: Mock-related failures

**Solution:**
```bash
# Ensure test helpers are loaded correctly
# Check that tests/helpers/mocks.bash exists
ls -l tests/helpers/

# Verify helper files are readable
cat tests/helpers/mocks.bash
```

#### Issue: Integration tests fail but unit tests pass

**Possible Causes:**
1. File system permissions issues
2. Temporary directory cleanup problems
3. Environment-specific issues

**Solution:**
```bash
# Clean up temporary test files
rm -rf /tmp/test_integration_*

# Run integration tests with verbose output
bats --verbose-run tests/test_integration.bats
```

### 1.7 Writing New Tests

When contributing new features, follow these guidelines:

**Test File Naming:**
- `test_<component>.bats` for unit tests
- `test_integration.bats` for integration tests

**Test Structure:**
```bash
@test "descriptive test name" {
    # Arrange: Set up test data and mocks
    local input="test data"
    
    # Act: Execute the function
    run function_to_test "$input"
    
    # Assert: Verify expected behavior
    assert_success
    assert_output "expected output"
}
```

**Best Practices:**
- One assertion per test when possible
- Use descriptive test names
- Mock external dependencies
- Clean up after tests in `teardown()`
- Follow existing test patterns

**Example:**
```bash
@test "validate_bundle_id accepts valid Bundle ID" {
    # Source the script
    source layup.sh
    
    # Test valid Bundle ID
    run validate_bundle_id "com.apple.safari"
    
    # Should succeed
    assert_success
}
```

---

## Section 2: Manual MDM Deployment Testing

### 2.1 Prerequisites

Before beginning manual MDM testing, ensure you have:

**MDM Server Access:**
- [ ] Admin credentials for your MDM platform
- [ ] Ability to create and deploy configuration profiles
- [ ] Access to test device groups or users

**Test Devices:**
- [ ] At least one iOS/iPadOS test device (physical or simulator)
- [ ] Device enrolled in your MDM
- [ ] Device not in production use (test environment)

**Test Data:**
- [ ] List of valid Bundle IDs to test
- [ ] Mix of Apple and third-party app Bundle IDs
- [ ] Known apps installed on test devices

**Supported MDM Platforms:**
- Jamf Pro
- VMware Workspace ONE (formerly AirWatch)
- Microsoft Intune
- Cisco Meraki Systems Manager
- Mosyle
- SimpleMDM
- Any MDM supporting Apple Configuration Profiles

### 2.2 Generating Test Configuration

#### Step 1: Create Test Input File

Create a text file with Bundle IDs for testing:

```bash
# Create test input file
cat > test_apps.txt << 'EOF'
# Communication Apps
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS

# Productivity Apps
com.microsoft.Office.Outlook
com.google.chrome.ios

# Social Media
com.facebook.Facebook
com.twitter.twitter
EOF
```

**Bundle ID Sources:**
- Apple's built-in apps: `com.apple.*`
- Third-party apps: Check app documentation or use tools like [iMazing](https://imazing.com/)
- Common apps: See [Section 4.4](#44-known-good-bundle-ids-for-testing)

#### Step 2: Run layup.sh to Generate Configuration

```bash
# Make script executable (if not already)
chmod +x layup.sh

# Generate configuration profile
./layup.sh test_apps.txt test_layout.mobileconfig

# Expected output:
# ✓ Line 2: com.apple.mobilesafari (valid)
# ✓ Line 3: com.apple.mobilemail (valid)
# ...
# Validation Summary:
#   Valid Bundle IDs: 7
#   Invalid Bundle IDs: 0
#   Comments: 3
#   Empty lines: 2
#
# ✓ Success! Configuration profile generated.
# Output file: test_layout.mobileconfig
```

#### Step 3: Validate Generated XML Structure

**Manual Inspection:**
```bash
# View the generated file
cat test_layout.mobileconfig

# Validate XML syntax
xmllint --noout test_layout.mobileconfig
echo $?  # Should output 0 for success
```

**Validation Checklist:**
- [ ] XML declaration present: `<?xml version="1.0" encoding="UTF-8"?>`
- [ ] DOCTYPE declaration present
- [ ] Outer payload type is `Configuration`
- [ ] Inner payload type is `com.apple.homescreenlayout.managed`
- [ ] All Bundle IDs are present in `<string>` tags
- [ ] UUIDs are unique (two different UUIDs in file)
- [ ] No XML syntax errors

**Automated Validation:**
```bash
# Check for required elements
grep -q "Configuration" test_layout.mobileconfig && echo "✓ Outer payload OK"
grep -q "com.apple.homescreenlayout.managed" test_layout.mobileconfig && echo "✓ Inner payload OK"
grep -q "com.apple.mobilesafari" test_layout.mobileconfig && echo "✓ Bundle IDs present"
```

### 2.3 MDM Platform-Specific Deployment

#### 2.3.1 Jamf Pro

**Step-by-Step Upload and Deployment:**

1. **Log in to Jamf Pro**
   - Navigate to your Jamf Pro server URL
   - Enter admin credentials

2. **Navigate to Configuration Profiles**
   - Click **Computers** or **Devices** (depending on target)
   - Select **Configuration Profiles**
   - Click **+ New**

3. **Upload Profile**
   - **General Tab:**
     - Name: `Test Home Screen Layout`
     - Description: `Generated by Layup - Testing`
     - Category: `Testing`
     - Level: `Computer Level` or `User Level`
   
   - **Upload Method:**
     - Click **Upload** button
     - Select your `test_layout.mobileconfig` file
     - Click **Open**

4. **Configure Scope**
   - **Scope Tab:**
     - Add test device(s) or test group
     - Example: Add specific device by serial number
   
   - **Exclusions Tab:**
     - Exclude production devices if needed

5. **Save and Deploy**
   - Click **Save**
   - Profile will deploy automatically to scoped devices

6. **Verify Deployment**
   - Navigate to **Devices** → Select test device
   - Click **Configuration Profiles** tab
   - Verify `Test Home Screen Layout` shows as **Installed**

**Jamf Pro Troubleshooting:**
- If profile shows "Pending", check device connectivity
- If profile shows "Failed", check device logs in Jamf
- Verify device is enrolled and checking in regularly

#### 2.3.2 VMware Workspace ONE (AirWatch)

**Step-by-Step Upload and Deployment:**

1. **Log in to Workspace ONE UEM Console**
   - Navigate to your Workspace ONE console
   - Enter admin credentials

2. **Navigate to Profiles & Resources**
   - Select **Devices** → **Profiles & Resources** → **Profiles**
   - Click **Add** → **Add Profile**

3. **Configure Profile**
   - **General Settings:**
     - Name: `Test Home Screen Layout`
     - Description: `Generated by Layup - Testing`
     - Assignment Type: `Device` or `User`
   
4. **Upload Custom Settings**
   - Select **Apple iOS** or **Apple iPadOS** platform
   - Click **Custom Settings**
   - Click **Configure**
   - Click **Add** → **Upload**
   - Select your `test_layout.mobileconfig` file

5. **Assign to Devices**
   - **Assignment Tab:**
     - Click **Add Assignment**
     - Select test Smart Group or specific devices
     - Set deployment type: `Auto` or `On-Demand`

6. **Publish Profile**
   - Click **Save & Publish**
   - Confirm deployment

7. **Verify Deployment**
   - Navigate to **Devices** → **List View**
   - Select test device
   - Check **Profiles** tab for installation status

**Workspace ONE Troubleshooting:**
- Check device compliance status
- Verify device is checking in (Hub app)
- Review deployment logs in console

#### 2.3.3 Microsoft Intune

**Step-by-Step Upload and Deployment:**

1. **Log in to Microsoft Endpoint Manager**
   - Navigate to [https://endpoint.microsoft.com](https://endpoint.microsoft.com)
   - Sign in with admin credentials

2. **Navigate to Configuration Profiles**
   - Select **Devices** → **iOS/iPadOS**
   - Click **Configuration profiles**
   - Click **+ Create profile**

3. **Create Profile**
   - **Platform:** iOS/iPadOS
   - **Profile type:** Custom
   - Click **Create**

4. **Configure Basics**
   - **Name:** `Test Home Screen Layout`
   - **Description:** `Generated by Layup - Testing`
   - Click **Next**

5. **Upload Configuration**
   - **Configuration profile name:** `HomeScreenLayout`
   - Click **Select a file**
   - Browse and select `test_layout.mobileconfig`
   - Click **Next**

6. **Assign to Devices**
   - **Assignments Tab:**
     - Click **Add groups**
     - Select test device group
     - Or use **Add all devices** for testing
   - Click **Next**

7. **Review and Create**
   - Review settings
   - Click **Create**

8. **Verify Deployment**
   - Navigate to **Devices** → **All devices**
   - Select test device
   - Click **Device configuration**
   - Verify profile shows as **Succeeded**

**Intune Troubleshooting:**
- Check device sync status (last check-in time)
- Review deployment status in profile overview
- Check device compliance state
- Use Company Portal app to manually sync

#### 2.3.4 Generic MDM (Other Platforms)

For MDM platforms not listed above, follow these general steps:

**General Upload Process:**

1. **Access Configuration Profile Management**
   - Log in to your MDM console
   - Navigate to configuration profile or policy section
   - Look for options like "Custom Profile", "Upload Profile", or "Configuration"

2. **Upload the .mobileconfig File**
   - Most MDMs support uploading Apple configuration profiles
   - Look for "Upload", "Import", or "Add Custom Profile" buttons
   - Select your generated `test_layout.mobileconfig` file

3. **Configure Profile Settings**
   - **Name:** Descriptive name for the profile
   - **Description:** Note that it's generated by Layup
   - **Platform:** iOS/iPadOS
   - **Profile Type:** Configuration or Custom

4. **Assign to Test Devices**
   - Use device groups, tags, or direct assignment
   - Start with a small test group
   - Avoid production devices

5. **Deploy Profile**
   - Save and publish/deploy the profile
   - Some MDMs deploy immediately, others require manual push

6. **Monitor Deployment**
   - Check deployment status in MDM console
   - Verify devices receive the profile
   - Review any error messages

**Common MDM Features:**
- **Scoping:** Target specific devices or groups
- **Scheduling:** Deploy immediately or at scheduled time
- **Removal:** Ability to remove profile remotely
- **Reporting:** View deployment success/failure rates

**Platform-Specific Documentation:**
- **Cisco Meraki:** [Configuration Profiles Documentation](https://documentation.meraki.com/SM/Profiles_and_Settings)
- **Mosyle:** [Custom Profiles Guide](https://help.mosyle.com/)
- **SimpleMDM:** [Custom Configuration Profiles](https://simplemdm.com/docs/)

### 2.4 Device-Side Verification

After deploying the configuration profile, verify it on the test device.

#### Step 1: Check Profile Installation

**On iOS/iPadOS Device:**

1. **Open Settings App**
   - Tap **Settings** icon

2. **Navigate to Profile Management**
   - Tap **General**
   - Scroll down and tap **VPN & Device Management**
   - Or tap **Profiles** (on older iOS versions)

3. **Verify Profile Appears**
   - Look for your profile name (e.g., "Test Home Screen Layout")
   - Profile should show as **Installed**
   - Tap on profile to view details

4. **Review Profile Details**
   - **Profile Name:** Should match what you uploaded
   - **Organization:** Should show "Layup" (or your org)
   - **Verified:** Should show checkmark if signed
   - **Installed:** Should show installation date/time

**Expected Profile Information:**
```
Profile Name: Home Screen Layout Configuration
Organization: Layup
Description: Generated by Layup
Type: Configuration
Installed: [Date and Time]
```

#### Step 2: Verify Restricted Apps Cannot Be Installed

**Note:** Home Screen Layout profiles don't actually *restrict* app installation. They organize apps on the home screen. To test restrictions, you would need a separate Restrictions payload.

**What Home Screen Layout Does:**
- Organizes apps in a specific layout
- Places apps in designated positions
- Can lock the home screen layout (if configured)

**Testing Home Screen Organization:**

1. **Check Home Screen Layout**
   - Exit Settings and return to home screen
   - Verify apps appear in the order specified in your input file
   - First Bundle ID should be first app, etc.

2. **Test Layout Persistence**
   - Try to rearrange apps (if layout is not locked)
   - Restart device
   - Check if layout persists or resets

#### Step 3: Test with App Store

**Verify App Presence:**

1. **Open App Store**
   - Tap **App Store** icon

2. **Search for Apps**
   - Search for apps in your Bundle ID list
   - Example: Search for "Safari", "Mail", "Messages"

3. **Verify Apps Are Accessible**
   - Apps should be searchable
   - Apps should be installable (if not already installed)
   - No restrictions should prevent access

**Note:** If you want to test app restrictions, you need to create a Restrictions payload, not a Home Screen Layout payload. Layup currently generates Home Screen Layout profiles only.

#### Step 4: Verify Profile Removal Works Correctly

**Test Profile Removal:**

1. **Remove Profile from MDM**
   - In your MDM console, remove the profile from the test device
   - Or unassign the device from the profile scope

2. **Verify Removal on Device**
   - On device, go to **Settings** → **General** → **VPN & Device Management**
   - Profile should disappear within a few minutes
   - Device may need to check in with MDM

3. **Alternative: Manual Removal (if allowed)**
   - Tap on the profile
   - Tap **Remove Profile**
   - Enter device passcode if prompted
   - Confirm removal

4. **Verify Home Screen Returns to Normal**
   - Home screen layout should return to user's custom arrangement
   - No apps should be missing
   - No errors should appear

**Expected Behavior:**
- Profile removes cleanly without errors
- Home screen layout becomes user-configurable again
- No residual settings remain

### 2.5 Test Scenarios

Perform these test scenarios to validate different use cases.

#### Scenario 1: Test with 1 Bundle ID

**Purpose:** Verify minimal configuration works

**Input File (`single_app.txt`):**
```
com.apple.mobilesafari
```

**Steps:**
1. Generate profile: `./layup.sh single_app.txt single_test.mobileconfig`
2. Upload to MDM
3. Deploy to test device
4. Verify Safari appears on home screen
5. Remove profile

**Expected Result:**
- ✓ Profile generates successfully
- ✓ Single app appears in XML
- ✓ Profile deploys without errors
- ✓ Home screen shows Safari

#### Scenario 2: Test with 10 Bundle IDs

**Purpose:** Verify typical use case

**Input File (`ten_apps.txt`):**
```
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.apple.mobilephone
com.apple.mobilecal
com.apple.reminders
com.apple.mobilenotes
com.apple.Maps
com.apple.Music
com.apple.podcasts
```

**Steps:**
1. Generate profile
2. Upload to MDM
3. Deploy to test device
4. Verify all 10 apps appear in correct order
5. Test layout persistence after device restart

**Expected Result:**
- ✓ All 10 apps present in XML
- ✓ Apps appear in specified order
- ✓ Layout persists after restart

#### Scenario 3: Test with 100+ Bundle IDs

**Purpose:** Verify performance with large configurations

**Input File Generation:**
```bash
# Generate file with 150 Bundle IDs
for i in {1..150}; do
    echo "com.company.app${i}"
done > large_test.txt
```

**Steps:**
1. Generate profile: `./layup.sh large_test.txt large_test.mobileconfig`
2. Verify file size is reasonable (< 1MB)
3. Validate XML structure
4. Upload to MDM
5. Deploy to test device
6. Monitor deployment time

**Expected Result:**
- ✓ Profile generates in < 5 seconds
- ✓ XML is well-formed
- ✓ MDM accepts large profile
- ✓ Deployment completes successfully
- ✓ Device performance is not impacted

**Performance Benchmarks:**
- Generation time: < 5 seconds for 150 apps
- File size: ~50-100KB for 150 apps
- Deployment time: < 2 minutes

#### Scenario 4: Test with Special Characters in Bundle IDs

**Purpose:** Verify XML escaping works correctly

**Input File (`special_chars.txt`):**
```
com.company.app-name
com.company.app_name
com.company-name.app
com.company_name.app
com.Company-Name.App_123
```

**Steps:**
1. Generate profile
2. Verify XML escaping in output file
3. Deploy to MDM
4. Verify profile installs correctly

**Expected Result:**
- ✓ Hyphens and underscores are preserved
- ✓ No XML syntax errors
- ✓ Profile deploys successfully

#### Scenario 5: Test Profile Updates (Adding/Removing Bundle IDs)

**Purpose:** Verify profile updates work correctly

**Initial Input File (`update_test_v1.txt`):**
```
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
```

**Steps:**
1. Generate and deploy initial profile
2. Verify 3 apps on device

**Updated Input File (`update_test_v2.txt`):**
```
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.apple.mobilephone
com.apple.mobilecal
```

**Steps:**
3. Generate new profile with same name
4. Upload to MDM (replace existing)
5. Verify profile updates on device
6. Check that 5 apps now appear

**Expected Result:**
- ✓ Profile updates without requiring removal
- ✓ New apps appear in layout
- ✓ Existing apps remain in place
- ✓ No errors during update

#### Scenario 6: Test Profile Removal and Reinstallation

**Purpose:** Verify clean removal and reinstallation

**Steps:**
1. Deploy profile to test device
2. Verify profile is installed
3. Remove profile from MDM
4. Verify profile is removed from device
5. Wait 5 minutes
6. Redeploy same profile
7. Verify profile reinstalls correctly

**Expected Result:**
- ✓ Profile removes cleanly
- ✓ No residual settings remain
- ✓ Profile reinstalls without errors
- ✓ Home screen layout applies correctly

---

## Section 3: Validation Checklist

### 3.1 Pre-Deployment Validation Checklist

Complete this checklist before deploying to production:

**Input File Validation:**
- [ ] Input file exists and is readable
- [ ] File contains at least one valid Bundle ID
- [ ] Bundle IDs follow correct format: `com.company.app`
- [ ] No typos in Bundle IDs
- [ ] Comments are properly formatted (start with `#`)
- [ ] File uses UTF-8 encoding

**Script Execution:**
- [ ] Script runs without errors
- [ ] All Bundle IDs validate successfully
- [ ] Validation summary shows expected counts
- [ ] Output file is generated

**XML Validation:**
- [ ] `xmllint --noout` passes without errors
- [ ] XML declaration is present
- [ ] DOCTYPE declaration is correct
- [ ] All Bundle IDs appear in output
- [ ] UUIDs are unique (at least 2 different UUIDs)
- [ ] No XML syntax errors

**File Properties:**
- [ ] Output file has `.mobileconfig` extension
- [ ] File size is reasonable (< 1MB for typical use)
- [ ] File permissions are correct (644)
- [ ] File encoding is UTF-8

**MDM Upload:**
- [ ] MDM accepts the profile without errors
- [ ] Profile name is descriptive
- [ ] Profile is assigned to test group only
- [ ] Deployment is scheduled appropriately

### 3.2 Post-Deployment Validation Checklist

Complete this checklist after deploying to test devices:

**Device Installation:**
- [ ] Profile appears in device settings
- [ ] Profile shows as "Installed"
- [ ] Installation date/time is correct
- [ ] No error messages on device

**Home Screen Layout:**
- [ ] Apps appear in correct order
- [ ] All specified apps are present
- [ ] Layout matches input file order
- [ ] No unexpected apps appear

**Functionality:**
- [ ] Apps launch correctly
- [ ] No performance issues
- [ ] Device operates normally
- [ ] No user complaints

**Profile Management:**
- [ ] Profile can be viewed in settings
- [ ] Profile details are correct
- [ ] Profile can be removed (if allowed)
- [ ] Removal works cleanly

**MDM Reporting:**
- [ ] MDM shows successful deployment
- [ ] Device compliance is maintained
- [ ] No errors in MDM logs
- [ ] Deployment metrics are accurate

**Documentation:**
- [ ] Test results are documented
- [ ] Any issues are logged
- [ ] Screenshots are captured (if needed)
- [ ] Stakeholders are notified

### 3.3 Common Issues and Troubleshooting

#### Issue: Profile Fails to Install on Device

**Symptoms:**
- Profile shows "Failed" in MDM
- Device shows error message
- Profile doesn't appear in device settings

**Possible Causes:**
1. XML syntax error in profile
2. Invalid Bundle ID format
3. Device not enrolled properly
4. MDM communication issue

**Troubleshooting Steps:**
```bash
# 1. Validate XML syntax
xmllint --noout your_profile.mobileconfig

# 2. Check for common XML issues
grep -E '&[^amp;lt;gt;quot;apos;]' your_profile.mobileconfig

# 3. Verify Bundle ID format
grep -o '<string>com\.[^<]*</string>' your_profile.mobileconfig
```

**Solutions:**
- Regenerate profile with corrected input
- Verify all Bundle IDs are valid
- Check device enrollment status
- Review MDM logs for specific errors

#### Issue: Apps Don't Appear in Expected Order

**Symptoms:**
- Apps are present but in wrong order
- Layout doesn't match input file

**Possible Causes:**
1. Device cached previous layout
2. User manually rearranged apps
3. Profile not fully applied

**Solutions:**
- Restart device to refresh layout
- Remove and reinstall profile
- Verify profile is not in conflict with another profile
- Check if layout locking is enabled

#### Issue: Profile Generates But MDM Rejects It

**Symptoms:**
- `layup.sh` succeeds
- MDM shows error when uploading

**Possible Causes:**
1. MDM-specific requirements not met
2. File size too large
3. Unsupported payload type

**Solutions:**
- Check MDM documentation for profile requirements
- Reduce number of Bundle IDs if file is too large
- Verify MDM supports Home Screen Layout payloads
- Contact MDM vendor support

#### Issue: XML Validation Fails

**Symptoms:**
- `xmllint` reports errors
- Profile won't upload to MDM

**Troubleshooting:**
```bash
# Run xmllint with verbose output
xmllint --noout --debug your_profile.mobileconfig

# Check for common issues
# - Unescaped special characters
# - Mismatched tags
# - Invalid characters
```

**Solutions:**
- Regenerate profile
- Check input file for unusual characters
- Report bug if issue persists

#### Issue: Device Shows "Profile Not Trusted"

**Symptoms:**
- Profile installs but shows warning
- User prompted to trust profile

**Possible Causes:**
1. Profile not signed by MDM
2. Certificate issue
3. Device trust settings

**Solutions:**
- Ensure MDM signs profiles automatically
- Check MDM certificate validity
- Verify device trust settings
- This is normal for unsigned profiles in testing

---

## Section 4: Test Data and Examples

### 4.1 Sample Input Files for Different Scenarios

#### Minimal Test (3 Apps)
**File:** `minimal_test.txt`
```
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
```

**Use Case:** Quick validation, smoke testing

#### Standard Test (10 Apps)
**File:** `standard_test.txt`
```
# Communication
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.apple.mobilephone

# Productivity
com.apple.mobilecal
com.apple.reminders
com.apple.mobilenotes

# Media
com.apple.Maps
com.apple.Music
com.apple.podcasts
```

**Use Case:** Typical deployment, general testing

#### Comprehensive Test (20 Apps)
**File:** `comprehensive_test.txt`
```
# Communication Apps
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.apple.mobilephone
com.apple.facetime

# Productivity Apps
com.apple.mobilecal
com.apple.reminders
com.apple.mobilenotes
com.apple.Pages
com.apple.Numbers
com.apple.Keynote

# Media Apps
com.apple.Music
com.apple.podcasts
com.apple.tv
com.apple.iBooks

# Utilities
com.apple.Maps
com.apple.weather
com.apple.compass
com.apple.calculator
com.apple.VoiceMemos
```

**Use Case:** Full feature testing, realistic deployment

#### Edge Case Test (Special Characters)
**File:** `edge_case_test.txt`
```
# Apps with hyphens
com.company.app-name
com.company-name.app

# Apps with underscores
com.company.app_name
com.company_name.app

# Mixed case
com.Company.App
com.COMPANY.APP

# Complex names
com.Company-Name.App_123
com.company.very-long-app-name_with_underscores
```

**Use Case:** XML escaping validation, special character handling

#### Large Scale Test (100+ Apps)
**File:** `large_scale_test.txt`
```bash
# Generate with script:
for i in {1..150}; do
    echo "com.company.app${i}"
done > large_scale_test.txt
```

**Use Case:** Performance testing, scalability validation

#### Mixed Validity Test
**File:** `mixed_validity_test.txt`
```
# Valid apps
com.apple.mobilesafari
com.apple.mobilemail

# Invalid - single segment
invalid

# Valid
com.apple.MobileSMS

# Invalid - starts with dot
.com.apple.app

# Valid
com.apple.mobilephone

# Invalid - ends with dot
com.apple.app.

# Valid
com.apple.mobilecal

# Invalid - consecutive dots
com.apple..app

# Valid
com.apple.reminders
```

**Use Case:** Validation testing, error handling verification

### 4.2 Expected Output Examples

#### Minimal Output Structure
**Expected XML for 1 Bundle ID:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
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
                    <dict>
                        <key>Type</key>
                        <string>Application</string>
                        <key>BundleID</key>
                        <string>com.apple.mobilesafari</string>
                    </dict>
                </array>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

#### App Dictionary Structure
**Each Bundle ID generates this structure:**
```xml
<dict>
    <key>Type</key>
    <string>Application</string>
    <key>BundleID</key>
    <string>com.apple.mobilesafari</string>
</dict>
```

#### Validation Output Examples

**Successful Validation:**
```
✓ Line 1: com.apple.mobilesafari (valid)
✓ Line 2: com.apple.mobilemail (valid)
✓ Line 3: com.apple.MobileSMS (valid)

Validation Summary:
  Valid Bundle IDs: 3
  Invalid Bundle IDs: 0
  Comments: 0
  Empty lines: 0

✓ Success! Configuration profile generated.
Output file: test_layout.mobileconfig
```

**Mixed Validation:**
```
✓ Line 1: com.apple.mobilesafari (valid)
✗ Line 2: invalid (invalid format: not enough segments)
✓ Line 3: com.apple.mobilemail (valid)
✗ Line 4: .com.apple.app (invalid format: starts with dot)

Validation Summary:
  Valid Bundle IDs: 2
  Invalid Bundle IDs: 2
  Comments: 0
  Empty lines: 0

✓ Success! Configuration profile generated.
Output file: test_layout.mobileconfig
```

**All Invalid:**
```
✗ Line 1: invalid (invalid format: not enough segments)
✗ Line 2: .starts.with.dot (invalid format: starts with dot)
✗ Line 3: ends.with.dot. (invalid format: ends with dot)

Validation Summary:
  Valid Bundle IDs: 0
  Invalid Bundle IDs: 3
  Comments: 0
  Empty lines: 0

ERROR: No valid Bundle IDs found in input file
Please check the file format and try again.
```

### 4.3 File Size Expectations

**Typical File Sizes:**
- 1 Bundle ID: ~2KB
- 10 Bundle IDs: ~3KB
- 50 Bundle IDs: ~8KB
- 100 Bundle IDs: ~15KB
- 150 Bundle IDs: ~22KB

**Formula:** Approximately 150 bytes per Bundle ID + 2KB base overhead

**Maximum Recommended:**
- 200 Bundle IDs (~30KB)
- Most MDMs support profiles up to 1MB
- Practical limit is device performance, not file size

### 4.4 Known Good Bundle IDs for Testing

#### Apple Built-in Apps (iOS/iPadOS)

**Communication:**
```
com.apple.mobilesafari          # Safari
com.apple.mobilemail            # Mail
com.apple.MobileSMS             # Messages
com.apple.mobilephone           # Phone (iPhone only)
com.apple.facetime              # FaceTime
```

**Productivity:**
```
com.apple.mobilecal             # Calendar
com.apple.reminders             # Reminders
com.apple.mobilenotes           # Notes
com.apple.contacts              # Contacts
com.apple.Pages                 # Pages
com.apple.Numbers               # Numbers
com.apple.Keynote               # Keynote
```

**Media:**
```
com.apple.Music                 # Music
com.apple.podcasts              # Podcasts
com.apple.tv                    # Apple TV
com.apple.iBooks                # Books
com.apple.camera                # Camera
com.apple.mobileslideshow       # Photos
```

**Utilities:**
```
com.apple.Maps                  # Maps
com.apple.weather               # Weather
com.apple.compass               # Compass
com.apple.calculator            # Calculator
com.apple.VoiceMemos            # Voice Memos
com.apple.Health                # Health
com.apple.Passbook              # Wallet
com.apple.mobiletimer           # Clock
```

**Settings & System:**
```
com.apple.Preferences           # Settings
com.apple.AppStore              # App Store
com.apple.MobileStore           # iTunes Store
com.apple.findmy                # Find My
```

#### Common Third-Party Apps

**Microsoft:**
```
com.microsoft.Office.Outlook    # Outlook
com.microsoft.Office.Word       # Word
com.microsoft.Office.Excel      # Excel
com.microsoft.Office.Powerpoint # PowerPoint
com.microsoft.skype.teams       # Teams
```

**Google:**
```
com.google.chrome.ios           # Chrome
com.google.Gmail                # Gmail
com.google.Drive                # Drive
com.google.Maps                 # Maps
com.google.Calendar             # Calendar
```

**Communication:**
```
com.slack.Slack                 # Slack
com.zoom.videomeetings          # Zoom
com.cisco.webex.meetings        # Webex
com.skype.skype                 # Skype
```

**Social Media:**
```
com.facebook.Facebook           # Facebook
com.twitter.twitter             # Twitter (X)
com.linkedin.LinkedIn           # LinkedIn
com.instagram.Instagram         # Instagram
```

**Productivity:**
```
com.notion.ios                  # Notion
com.evernote.iPhone.Evernote    # Evernote
com.dropbox.Dropbox             # Dropbox
com.box.BoxNet                  # Box
```

**Note:** Bundle IDs may change with app updates. Verify current Bundle IDs using:
- App documentation
- MDM app catalog
- Tools like iMazing or Apple Configurator

---

## Section 5: Reporting Issues

### 5.1 What Information to Collect

When reporting bugs or issues, include the following information:

#### System Information
```bash
# macOS version
sw_vers

# Bash version
bash --version

# Script version
./layup.sh --help | head -1

# Bats version (if testing issue)
bats --version

# xmllint version
xmllint --version
```

#### Input File
- Attach or paste the input file contents
- Note any special characters or formatting
- Specify file encoding if known

#### Command Used
```bash
# Exact command that caused the issue
./layup.sh input.txt output.mobileconfig
```

#### Error Output
```bash
# Capture complete error output
./layup.sh input.txt output.mobileconfig 2>&1 | tee error.log
```

#### Generated File (if applicable)
- Attach the generated `.mobileconfig` file
- Note file size and permissions

#### MDM Information (if deployment issue)
- MDM platform and version
- Error messages from MDM console
- Device iOS/iPadOS version
- Screenshots of errors

### 5.2 How to Reproduce Issues

Provide clear reproduction steps:

**Template:**
```markdown
## Issue Description
Brief description of the problem

## Steps to Reproduce
1. Create input file with these contents: [paste contents]
2. Run command: `./layup.sh input.txt output.mobileconfig`
3. Observe error: [describe what happens]

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- macOS version: [version]
- Bash version: [version]
- Script version: [version]

## Additional Context
Any other relevant information
```

**Example:**
```markdown
## Issue Description
Script fails with "XML validation failed" error

## Steps to Reproduce
1. Create input file:
   ```
   com.apple.mobilesafari
   com.test&app
   ```
2. Run: `./layup.sh test.txt output.mobileconfig`
3. Script generates file but xmllint validation fails

## Expected Behavior
Script should escape ampersand in Bundle ID or reject it as invalid

## Actual Behavior
Script generates invalid XML with unescaped ampersand

## Environment
- macOS: 14.0 (Sonoma)
- Bash: 3.2.57
- Script: 1.0.0
```

### 5.3 Where to Report Bugs

**GitHub Issues (Recommended):**
1. Navigate to [https://github.com/[username]/layup/issues](https://github.com/[username]/layup/issues)
2. Click "New Issue"
3. Choose appropriate template:
   - Bug Report
   - Feature Request
   - Documentation Issue
4. Fill in all required fields
5. Add relevant labels
6. Submit issue

**Issue Labels:**
- `bug` - Something isn't working
- `enhancement` - New feature request
- `documentation` - Documentation improvements
- `question` - Questions about usage
- `help wanted` - Community help needed
- `good first issue` - Good for new contributors

**Before Reporting:**
- [ ] Search existing issues to avoid duplicates
- [ ] Verify you're using the latest version
- [ ] Test with minimal input to isolate issue
- [ ] Collect all required information
- [ ] Try to reproduce on clean system if possible

**Security Issues:**
If you discover a security vulnerability, please email [security@example.com] instead of creating a public issue.

### 5.4 Contributing Fixes

If you can fix the issue yourself:

1. **Fork the Repository**
   ```bash
   # Fork on GitHub, then clone
   git clone https://github.com/[your-username]/layup.git
   cd layup
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b bugfix/issue-description
   ```

3. **Write Test First (TDD)**
   ```bash
   # Add failing test that reproduces the bug
   vim tests/test_[component].bats
   
   # Run test to confirm it fails
   bats tests/test_[component].bats
   ```

4. **Implement Fix**
   ```bash
   # Fix the issue in layup.sh
   vim layup.sh
   
   # Run test to confirm it passes
   bats tests/test_[component].bats
   ```

5. **Run Full Test Suite**
   ```bash
   # Ensure all tests still pass
   bats tests/
   ```

6. **Commit and Push**
   ```bash
   git add tests/test_[component].bats layup.sh
   git commit -m "fix: description of fix (closes #123)"
   git push origin bugfix/issue-description
   ```

7. **Create Pull Request**
   - Go to GitHub
   - Click "New Pull Request"
   - Reference the issue number
   - Describe your changes
   - Wait for review

**See [`CONTRIBUTING.md`](../CONTRIBUTING.md) for detailed contribution guidelines.**


## Section 6: Cross-Platform Testing

### 6.1 Supported Platforms

The [`layup.sh`](../layup.sh) script is primarily designed for macOS but includes cross-platform compatibility for Linux and Windows environments. Understanding platform-specific requirements and limitations is essential for successful deployment and testing.

#### 6.1.1 macOS (Primary Platform)

**Minimum Requirements:**
- macOS 10.15 (Catalina) or later
- Bash 3.2+ (pre-installed)
- `uuidgen` command (pre-installed)
- `xmllint` (pre-installed via Xcode Command Line Tools)

**Recommended Versions:**
- macOS 12.0 (Monterey) or later
- Bash 4.0+ (via Homebrew for enhanced features)
- Latest Xcode Command Line Tools

**Known Issues by Version:**

| macOS Version | Known Issues | Workarounds |
|---------------|--------------|-------------|
| 10.15 (Catalina) | Bash 3.2 has limited array support | Use basic features only; avoid advanced array operations |
| 11.0 (Big Sur) | `open` command behavior changed | Script handles this automatically |
| 12.0+ (Monterey+) | No known issues | Fully supported |
| 13.0+ (Ventura+) | No known issues | Fully supported |
| 14.0+ (Sonoma+) | No known issues | Fully supported, recommended |

**Testing Recommendations:**
- Test on oldest supported version (10.15) for compatibility
- Test on latest version for optimal performance
- Verify Finder integration on each major version

#### 6.1.2 Linux Distributions

**Supported Distributions:**

**Ubuntu/Debian:**
- Ubuntu 20.04 LTS or later
- Debian 10 (Buster) or later
- Bash 4.4+ (typically pre-installed)
- GNU coreutils required

**Installation Commands:**
```bash
# Install required dependencies
sudo apt-get update
sudo apt-get install -y bash uuid-runtime libxml2-utils

# Verify installations
bash --version
uuidgen --version
xmllint --version
```

**RHEL/CentOS/Fedora:**
- RHEL 8+ or CentOS 8+
- Fedora 33+
- Bash 4.4+

**Installation Commands:**
```bash
# Install required dependencies
sudo dnf install -y bash util-linux libxml2

# Or for older versions
sudo yum install -y bash util-linux libxml2

# Verify installations
bash --version
uuidgen --version
xmllint --version
```

**Arch Linux:**
- Current rolling release
- Bash 5.0+
- All required utilities in base packages

**Installation Commands:**
```bash
# Install required dependencies (usually pre-installed)
sudo pacman -S bash util-linux libxml2

# Verify installations
bash --version
uuidgen --version
xmllint --version
```

**Alpine Linux:**
- Alpine 3.14+
- Bash must be installed (not default shell)
- BusyBox utilities may need replacement

**Installation Commands:**
```bash
# Install bash and required utilities
apk add bash util-linux libxml2-utils

# Verify installations
bash --version
uuidgen --version
xmllint --version
```

**Known Linux Limitations:**
- No native Finder integration (no `open` command)
- File system case sensitivity varies by distribution
- Different default text editors

#### 6.1.3 Windows (via Compatibility Layers)

**WSL 1 (Windows Subsystem for Linux):**
- Windows 10 version 1607 or later
- Linux distribution installed (Ubuntu recommended)
- Bash 4.4+

**Setup:**
```powershell
# Enable WSL (PowerShell as Administrator)
wsl --install

# Or manually enable
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Install Ubuntu from Microsoft Store
# Then in WSL terminal:
sudo apt-get update
sudo apt-get install -y bash uuid-runtime libxml2-utils
```

**WSL 2 (Recommended):**
- Windows 10 version 2004 or later (Build 19041+)
- Better performance and compatibility
- Full Linux kernel

**Setup:**
```powershell
# Enable WSL 2 (PowerShell as Administrator)
wsl --install
wsl --set-default-version 2

# Install Ubuntu from Microsoft Store
# Then in WSL terminal:
sudo apt-get update
sudo apt-get install -y bash uuid-runtime libxml2-utils
```

**Git Bash:**
- Git for Windows 2.30+
- MinGW-based environment
- Limited compatibility

**Setup:**
```bash
# Download and install Git for Windows from:
# https://git-scm.com/download/win

# Verify in Git Bash:
bash --version
uuidgen --version  # May not be available
xmllint --version  # May not be available
```

**Known Git Bash Issues:**
- `uuidgen` may not be available (script uses fallback)
- `xmllint` may not be available (validation skipped)
- Path translation issues with Windows paths
- Line ending conversion (CRLF vs LF)

**Cygwin:**
- Cygwin 3.0+
- Full POSIX compatibility layer
- All required packages must be installed

**Setup:**
```bash
# Download Cygwin installer from:
# https://www.cygwin.com/

# During installation, select these packages:
# - bash
# - util-linux
# - libxml2

# Verify in Cygwin terminal:
bash --version
uuidgen --version
xmllint --version
```

**Windows Platform Comparison:**

| Platform | Compatibility | Performance | Recommended |
|----------|--------------|-------------|-------------|
| WSL 2 | Excellent | Excellent | ✓ Yes |
| WSL 1 | Good | Good | ✓ Yes |
| Git Bash | Limited | Good | ⚠ Testing only |
| Cygwin | Good | Fair | ⚠ If WSL unavailable |

### 6.2 Platform-Specific Requirements

#### 6.2.1 Bash Version Requirements

**Minimum Version: 3.2+**
- Required for basic script functionality
- Pre-installed on macOS
- Supports essential features used by layup.sh

**Recommended Version: 4.0+**
- Enhanced array handling
- Better error handling
- Improved performance
- Available via Homebrew on macOS

**Version Compatibility Matrix:**

| Bash Version | macOS | Linux | Windows (WSL) | Status |
|--------------|-------|-------|---------------|--------|
| 3.2 | ✓ Default | ⚠ Old | ✗ N/A | Supported (minimum) |
| 4.0-4.4 | ✓ Homebrew | ✓ Common | ✓ WSL | Recommended |
| 5.0+ | ✓ Homebrew | ✓ Modern | ✓ WSL 2 | Fully supported |

**Check Bash Version:**
```bash
# Display version
bash --version

# Check if version meets minimum
bash -c 'echo $BASH_VERSION' | awk -F. '{if ($1 >= 3 && $2 >= 2) print "✓ Compatible"; else print "✗ Incompatible"}'
```

**Upgrade Bash on macOS:**
```bash
# Install newer Bash via Homebrew
brew install bash

# Add to allowed shells
sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'

# Optional: Change default shell
chsh -s /usr/local/bin/bash

# Verify new version
/usr/local/bin/bash --version
```

#### 6.2.2 Required Utilities

**uuidgen (UUID Generation):**

**macOS:**
```bash
# Pre-installed, verify:
which uuidgen
uuidgen  # Test generation
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install uuid-runtime

# RHEL/CentOS/Fedora
sudo dnf install util-linux

# Verify
which uuidgen
uuidgen
```

**Windows (WSL):**
```bash
# Usually included, if not:
sudo apt-get install uuid-runtime
```

**Fallback (if uuidgen unavailable):**
The script includes a fallback UUID generator using `/dev/urandom`:
```bash
# Fallback method (automatic in script)
cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1 | sed -e 's/\(.\{8\}\)\(.\{4\}\)\(.\{4\}\)\(.\{4\}\)\(.\{12\}\)/\1-\2-\3-\4-\5/'
```

**date Command (GNU vs BSD Differences):**

**macOS (BSD date):**
```bash
# BSD date syntax
date -u +"%Y-%m-%dT%H:%M:%SZ"

# No --iso-8601 option
```

**Linux (GNU date):**
```bash
# GNU date syntax (more features)
date --iso-8601=seconds
date -u +"%Y-%m-%dT%H:%M:%SZ"
```

**Script Compatibility:**
The script uses portable date format that works on both:
```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
```

**xmllint (XML Validation):**

**macOS:**
```bash
# Pre-installed with Xcode Command Line Tools
xcode-select --install  # If not installed

# Verify
which xmllint
xmllint --version
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install libxml2-utils

# RHEL/CentOS/Fedora
sudo dnf install libxml2

# Arch Linux
sudo pacman -S libxml2

# Verify
which xmllint
xmllint --version
```

**Windows (WSL):**
```bash
# Ubuntu on WSL
sudo apt-get install libxml2-utils
```

**Windows (Git Bash/Cygwin):**
- May not be available
- Script gracefully skips validation if missing
- Manual validation recommended

**open Command (macOS) vs xdg-open (Linux):**

**macOS:**
```bash
# Open file with default application
open file.mobileconfig

# Open in Finder
open .

# Script uses this on macOS
```

**Linux:**
```bash
# Open file with default application
xdg-open file.mobileconfig

# Open file manager
xdg-open .

# Install if missing (Ubuntu/Debian)
sudo apt-get install xdg-utils
```

**Script Behavior:**
- Detects platform automatically
- Uses `open` on macOS
- Uses `xdg-open` on Linux (if available)
- Skips file opening on Windows or if command unavailable

#### 6.2.3 Line Ending Handling

**Understanding Line Endings:**
- **LF (Line Feed):** `\n` - Unix/Linux/macOS standard
- **CRLF (Carriage Return + Line Feed):** `\r\n` - Windows standard
- **CR (Carriage Return):** `\r` - Old Mac OS (pre-OS X)

**Why It Matters:**
- Bash scripts require LF line endings
- CRLF can cause "command not found" errors
- Input files should use LF for consistency

**Check Line Endings:**
```bash
# Display line endings
cat -A file.txt
# ^M$ indicates CRLF
# $ indicates LF

# Or use file command
file file.txt
# Shows "CRLF line terminators" or "LF line terminators"

# Or use dos2unix
dos2unix -i file.txt
```

**Convert Line Endings:**

**Using dos2unix (Recommended):**
```bash
# Install dos2unix
# macOS
brew install dos2unix

# Ubuntu/Debian
sudo apt-get install dos2unix

# Convert CRLF to LF
dos2unix file.txt

# Convert LF to CRLF (if needed)
unix2dos file.txt
```

**Using sed:**
```bash
# Remove CR characters (CRLF to LF)
sed -i 's/\r$//' file.txt

# macOS requires -i ''
sed -i '' 's/\r$//' file.txt
```

**Using tr:**
```bash
# Remove CR characters
tr -d '\r' < input.txt > output.txt
```

**Git Configuration:**
```bash
# Configure Git to handle line endings
# On Windows, convert to CRLF on checkout, LF on commit
git config --global core.autocrlf true

# On macOS/Linux, keep LF, convert CRLF to LF on commit
git config --global core.autocrlf input

# Never convert (recommended for scripts)
git config --global core.autocrlf false
```

**Best Practices:**
- Always use LF for shell scripts
- Configure your editor to use LF
- Add `.gitattributes` to enforce line endings:
```
*.sh text eol=lf
*.bats text eol=lf
*.txt text eol=lf
```

### 6.3 Testing Procedures by Platform

#### 6.3.1 macOS Testing

**Native Environment Testing:**

**Step 1: Verify Prerequisites**
```bash
# Check macOS version
sw_vers

# Check Bash version
bash --version

# Check required commands
which uuidgen xmllint open

# Verify script is executable
ls -l layup.sh
chmod +x layup.sh  # If needed
```

**Step 2: Run Basic Tests**
```bash
# Create test input
cat > test_macos.txt << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
EOF

# Generate configuration
./layup.sh test_macos.txt test_macos.mobileconfig

# Verify output
xmllint --noout test_macos.mobileconfig
echo $?  # Should be 0
```

**Step 3: Test Finder Integration**
```bash
# Test open command
open test_macos.mobileconfig
# Should open in default application (System Preferences or text editor)

# Test opening directory
open .
# Should open current directory in Finder
```

**Step 4: Run Automated Tests**
```bash
# Install Bats if not already installed
brew install bats-core

# Run full test suite
bats tests/

# Expected: All tests pass
```

**Testing with Different Bash Versions:**

**System Bash (3.2):**
```bash
# Use system Bash explicitly
/bin/bash --version

# Run script with system Bash
/bin/bash layup.sh test_macos.txt output.mobileconfig

# Run tests with system Bash
/bin/bash $(which bats) tests/
```

**Homebrew Bash (4.0+):**
```bash
# Install Homebrew Bash
brew install bash

# Verify version
/usr/local/bin/bash --version

# Run script with Homebrew Bash
/usr/local/bin/bash layup.sh test_macos.txt output.mobileconfig

# Run tests with Homebrew Bash
/usr/local/bin/bash $(which bats) tests/
```

**Testing with Different macOS Versions:**

**Monterey (12.x):**
```bash
# No special considerations
# Full compatibility expected
./layup.sh test.txt output.mobileconfig
```

**Ventura (13.x):**
```bash
# Test with latest features
./layup.sh test.txt output.mobileconfig

# Verify Finder integration
open output.mobileconfig
```

**Sonoma (14.x):**
```bash
# Latest version - recommended
./layup.sh test.txt output.mobileconfig

# All features should work optimally
bats tests/
```

**macOS-Specific Test Checklist:**
- [ ] Script runs with system Bash 3.2
- [ ] Script runs with Homebrew Bash 4.0+
- [ ] `uuidgen` generates valid UUIDs
- [ ] `xmllint` validates output successfully
- [ ] `open` command works for files
- [ ] `open` command works for directories
- [ ] Finder integration functions correctly
- [ ] All automated tests pass
- [ ] No permission issues
- [ ] Performance is acceptable (< 5 seconds for 100 apps)

#### 6.3.2 Linux Testing

**Testing on Different Distributions:**

**Ubuntu/Debian Testing:**
```bash
# Step 1: Install dependencies
sudo apt-get update
sudo apt-get install -y bash uuid-runtime libxml2-utils

# Step 2: Verify installations
bash --version
uuidgen --version
xmllint --version

# Step 3: Clone or copy script
git clone https://github.com/[username]/layup.git
cd layup
chmod +x layup.sh

# Step 4: Create test input
cat > test_linux.txt << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
EOF

# Step 5: Run script
./layup.sh test_linux.txt test_linux.mobileconfig

# Step 6: Validate output
xmllint --noout test_linux.mobileconfig
echo $?  # Should be 0

# Step 7: Check file contents
cat test_linux.mobileconfig | head -20
```

**RHEL/CentOS/Fedora Testing:**
```bash
# Step 1: Install dependencies
sudo dnf install -y bash util-linux libxml2

# Step 2: Verify installations
bash --version
uuidgen --version
xmllint --version

# Step 3-7: Same as Ubuntu testing above
```

**Arch Linux Testing:**
```bash
# Step 1: Install dependencies (usually pre-installed)
sudo pacman -S bash util-linux libxml2

# Step 2: Verify installations
bash --version
uuidgen --version
xmllint --version

# Step 3-7: Same as Ubuntu testing above
```

**Alpine Linux Testing:**
```bash
# Step 1: Install bash and dependencies
apk add bash util-linux libxml2-utils

# Step 2: Verify installations
bash --version
uuidgen --version
xmllint --version

# Step 3: Make script use bash explicitly
sed -i '1s|^#!/bin/sh|#!/bin/bash|' layup.sh

# Step 4-7: Same as Ubuntu testing above
```

**Testing with Different Shells:**

**Bash Compatibility:**
```bash
# Verify script uses bash
head -1 layup.sh
# Should show: #!/usr/bin/env bash

# Run with explicit bash
bash layup.sh test.txt output.mobileconfig
```

**Zsh Compatibility (Not Officially Supported):**
```bash
# Test if script works in zsh
zsh layup.sh test.txt output.mobileconfig
# May work but not guaranteed

# Recommended: Always use bash
bash layup.sh test.txt output.mobileconfig
```

**Testing Without open Command:**

**Verify Behavior:**
```bash
# Check if open command exists
which open
# Likely not found on Linux

# Check if xdg-open exists
which xdg-open

# Install xdg-utils if needed
sudo apt-get install xdg-utils  # Ubuntu/Debian
sudo dnf install xdg-utils      # RHEL/Fedora

# Test file opening (if xdg-open available)
xdg-open test_linux.mobileconfig
```

**Script Behavior:**
- Script detects missing `open` command
- Skips file opening gracefully
- No errors generated
- User must manually open file

**Testing with GNU Coreutils:**

**Verify GNU Tools:**
```bash
# Check date command
date --version
# Should show GNU coreutils

# Test date formatting
date -u +"%Y-%m-%dT%H:%M:%SZ"

# Check other utilities
ls --version
cat --version
```

**Linux-Specific Test Checklist:**
- [ ] All dependencies installed correctly
- [ ] Bash version is 4.0 or later
- [ ] `uuidgen` generates valid UUIDs
- [ ] `xmllint` validates output successfully
- [ ] Script runs without errors
- [ ] Output file is created correctly
- [ ] XML structure is valid
- [ ] File permissions are correct (644)
- [ ] No macOS-specific commands cause errors
- [ ] Performance is acceptable
- [ ] Works on target distribution

#### 6.3.3 Windows Testing

**WSL Setup and Testing:**

**WSL 2 Setup (Recommended):**
```powershell
# In PowerShell as Administrator

# Step 1: Enable WSL
wsl --install

# Step 2: Set WSL 2 as default
wsl --set-default-version 2

# Step 3: Install Ubuntu
# Download from Microsoft Store or:
wsl --install -d Ubuntu

# Step 4: Launch Ubuntu and create user
# Follow prompts to create username and password
```

**In WSL Ubuntu Terminal:**
```bash
# Step 1: Update system
sudo apt-get update
sudo apt-get upgrade -y

# Step 2: Install dependencies
sudo apt-get install -y bash uuid-runtime libxml2-utils git

# Step 3: Verify installations
bash --version
uuidgen --version
xmllint --version

# Step 4: Clone repository
cd ~
git clone https://github.com/[username]/layup.git
cd layup

# Step 5: Check line endings
file layup.sh
# Should show "ASCII text" with "LF line terminators"

# If shows CRLF, convert:
sudo apt-get install dos2unix
dos2unix layup.sh

# Step 6: Make executable
chmod +x layup.sh

# Step 7: Create test input
cat > test_wsl.txt << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
EOF

# Step 8: Run script
./layup.sh test_wsl.txt test_wsl.mobileconfig

# Step 9: Validate output
xmllint --noout test_wsl.mobileconfig
echo $?  # Should be 0

# Step 10: View output
cat test_wsl.mobileconfig | head -30
```

**Git Bash Setup and Testing:**

**Installation:**
```bash
# Download Git for Windows from:
# https://git-scm.com/download/win

# During installation:
# - Select "Use Git and optional Unix tools from Command Prompt"
# - Select "Checkout as-is, commit Unix-style line endings"
```

**In Git Bash Terminal:**
```bash
# Step 1: Navigate to project
cd /c/Users/YourUsername/layup

# Step 2: Check line endings
cat -A layup.sh | head -5
# Should NOT show ^M$ (CRLF)

# If CRLF present, convert:
sed -i 's/\r$//' layup.sh

# Step 3: Make executable
chmod +x layup.sh

# Step 4: Check for uuidgen
which uuidgen
# May not be found - script will use fallback

# Step 5: Check for xmllint
which xmllint
# May not be found - validation will be skipped

# Step 6: Create test input
cat > test_gitbash.txt << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
EOF

# Step 7: Run script
./layup.sh test_gitbash.txt test_gitbash.mobileconfig

# Step 8: Verify output file exists
ls -l test_gitbash.mobileconfig

# Step 9: Check content
cat test_gitbash.mobileconfig | head -30
```

**Cygwin Setup and Testing:**

**Installation:**
```bash
# Download Cygwin installer from:
# https://www.cygwin.com/

# During installation, select packages:
# - bash
# - util-linux (for uuidgen)
# - libxml2 (for xmllint)
# - git (optional)
```

**In Cygwin Terminal:**
```bash
# Step 1: Verify installations
bash --version
uuidgen --version
xmllint --version

# Step 2: Navigate to project
cd /cygdrive/c/Users/YourUsername/layup

# Step 3: Check line endings
file layup.sh

# If CRLF, convert:
dos2unix layup.sh

# Step 4: Make executable
chmod +x layup.sh

# Step 5: Create test input
cat > test_cygwin.txt << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
EOF

# Step 6: Run script
./layup.sh test_cygwin.txt test_cygwin.mobileconfig

# Step 7: Validate
xmllint --noout test_cygwin.mobileconfig
```

**Line Ending Conversion Issues:**

**Problem: Script fails with "command not found"**
```bash
# Symptom
./layup.sh: line 2: $'\r': command not found

# Cause: CRLF line endings

# Solution 1: Use dos2unix
dos2unix layup.sh

# Solution 2: Use sed
sed -i 's/\r$//' layup.sh

# Solution 3: Use tr
tr -d '\r' < layup.sh > layup_fixed.sh
mv layup_fixed.sh layup.sh
chmod +x layup.sh

# Verify fix
file layup.sh
# Should show "LF line terminators"
```

**Path Handling Differences:**

**Windows Paths in WSL:**
```bash
# Windows path
C:\Users\Username\layup

# WSL path
/mnt/c/Users/Username/layup

# Access Windows files from WSL
cd /mnt/c/Users/Username/layup

# Access WSL files from Windows
\\wsl$\Ubuntu\home\username\layup
```

**Git Bash Paths:**
```bash
# Windows path
C:\Users\Username\layup

# Git Bash path
/c/Users/Username/layup

# Use forward slashes
cd /c/Users/Username/layup
```

**Cygwin Paths:**
```bash
# Windows path
C:\Users\Username\layup

# Cygwin path
/cygdrive/c/Users/Username/layup

# Use cygpath for conversion
cygpath -u "C:\Users\Username\layup"
```

**Windows-Specific Test Checklist:**
- [ ] WSL or compatibility layer installed
- [ ] Bash version is 4.0 or later
- [ ] All dependencies installed
- [ ] Line endings are LF (not CRLF)
- [ ] Script is executable
- [ ] `uuidgen` available or fallback works
- [ ] `xmllint` available or validation skipped gracefully
- [ ] Script runs without errors
- [ ] Output file created correctly
- [ ] XML structure is valid
- [ ] Path handling works correctly
- [ ] No Windows-specific errors

### 6.4 Automated Cross-Platform Testing

#### 6.4.1 Using Docker Containers

**Docker Testing Strategy:**
Docker provides consistent, reproducible testing environments across platforms.

**Create Dockerfile for Ubuntu Testing:**
```dockerfile
# Dockerfile.ubuntu
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    bash \
    uuid-runtime \
    libxml2-utils \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy script and tests
COPY . /app/

# Make script executable
RUN chmod +x layup.sh

# Run tests by default
CMD ["bash", "-c", "bash --version && ./layup.sh --help"]
```

**Create Dockerfile for Alpine Testing:**
```dockerfile
# Dockerfile.alpine
FROM alpine:3.18

# Install dependencies
RUN apk add --no-cache \
    bash \
    util-linux \
    libxml2-utils \
    git

# Set working directory
WORKDIR /app

# Copy script and tests
COPY . /app/

# Make script executable
RUN chmod +x layup.sh

# Run tests by default
CMD ["bash", "-c", "bash --version && ./layup.sh --help"]
```

**Build and Run Docker Tests:**
```bash
# Build Ubuntu image
docker build -f Dockerfile.ubuntu -t layup-test-ubuntu .

# Build Alpine image
docker build -f Dockerfile.alpine -t layup-test-alpine .

# Run Ubuntu tests
docker run --rm layup-test-ubuntu bash -c "
    echo '=== Ubuntu Testing ===' &&
    bash --version &&
    echo 'com.apple.mobilesafari' > test.txt &&
    ./layup.sh test.txt output.mobileconfig &&
    xmllint --noout output.mobileconfig &&
    echo '✓ Ubuntu tests passed'
"

# Run Alpine tests
docker run --rm layup-test-alpine bash -c "
    echo '=== Alpine Testing ===' &&
    bash --version &&
    echo 'com.apple.mobilesafari' > test.txt &&
    ./layup.sh test.txt output.mobileconfig &&
    xmllint --noout output.mobileconfig &&
    echo '✓ Alpine tests passed'
"
```

**Docker Compose for Multi-Platform Testing:**
```yaml
# docker-compose.test.yml
version: '3.8'

services:
  test-ubuntu:
    build:
      context: .
      dockerfile: Dockerfile.ubuntu
    command: bash -c "
      echo '=== Ubuntu 22.04 Testing ===' &&
      bash --version &&
      echo 'com.apple.mobilesafari' > test.txt &&
      ./layup.sh test.txt output.mobileconfig &&
      xmllint --noout output.mobileconfig &&
      echo '✓ Tests passed'
      "

  test-alpine:
    build:
      context: .
      dockerfile: Dockerfile.alpine
    command: bash -c "
      echo '=== Alpine 3.18 Testing ===' &&
      bash --version &&
      echo 'com.apple.mobilesafari' > test.txt &&
      ./layup.sh test.txt output.mobileconfig &&
      xmllint --noout output.mobileconfig &&
      echo '✓ Tests passed'
      "

  test-debian:
    image: debian:11
    volumes:
      - .:/app
    working_dir: /app
    command: bash -c "
      apt-get update &&
      apt-get install -y bash uuid-runtime libxml2-utils &&
      echo '=== Debian 11 Testing ===' &&
      bash --version &&
      chmod +x layup.sh &&
      echo 'com.apple.mobilesafari' > test.txt &&
      ./layup.sh test.txt output.mobileconfig &&
      xmllint --noout output.mobileconfig &&
      echo '✓ Tests passed'
      "
```

**Run All Docker Tests:**
```bash
# Run all tests
docker-compose -f docker-compose.test.yml up --abort-on-container-exit

# Clean up
docker-compose -f docker-compose.test.yml down
```

#### 6.4.2 GitHub Actions Matrix Testing

**Create GitHub Actions Workflow:**
```yaml
# .github/workflows/cross-platform-tests.yml
name: Cross-Platform Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    name: Test on ${{ matrix.os }}
    runs-on: ${{ matrix.os }}
    
    strategy:
      matrix:
        os: [ubuntu-latest, ubuntu-20.04, macos-latest, macos-12]
        bash-version: ['4.4', '5.0', '5.1']
        exclude:
          # macOS comes with bash 3.2, test separately
          - os: macos-latest
            bash-version: '4.4'
          - os: macos-12
            bash-version: '4.
---

## Appendix A: Quick Reference

### Common Commands

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/test_bundle_id_validation.bats

# Generate configuration
./layup.sh input.txt output.mobileconfig

# Validate XML
xmllint --noout output.mobileconfig

# View help
./layup.sh --help
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success or user cancelled |
| 1 | Input file not found |
| 2 | Input file empty |
| 3 | No valid Bundle IDs |
| 4 | Write error |
| 5 | XML validation failed |

### File Locations

| Path | Description |
|------|-------------|
| [`layup.sh`](../layup.sh) | Main script |
| [`tests/`](../tests/) | Test suite |
| [`docs/`](../docs/) | Documentation |
| [`examples/`](../examples/) | Sample files |

---

## Appendix B: Additional Resources

### Documentation
- [`README.md`](../README.md) - Project overview and quick start
- [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) - Development plan and phases
- [`CONTRIBUTING.md`](../CONTRIBUTING.md) - Contribution guidelines
- [`CHANGELOG.md`](../CHANGELOG.md) - Version history

### Apple Documentation
- [Configuration Profile Reference](https://developer.apple.com/business/documentation/Configuration-Profile-Reference.pdf)
- [MDM Protocol Reference](https://developer.apple.com/documentation/devicemanagement)
- [Home Screen Layout Payload](https://developer.apple.com/documentation/devicemanagement/homescreenlayout)

### MDM Platform Documentation
- [Jamf Pro Documentation](https://docs.jamf.com/)
- [Workspace ONE Documentation](https://docs.vmware.com/en/VMware-Workspace-ONE-UEM/index.html)
- [Microsoft Intune Documentation](https://docs.microsoft.com/en-us/mem/intune/)

### Testing Resources
- [Bats Documentation](https://bats-core.readthedocs.io/)
- [Bash Testing Best Practices](https://github.com/bats-core/bats-core#writing-tests)
- [London School TDD](https://github.com/testdouble/contributing-tests/wiki/London-school-TDD)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-27 | Development Team | Initial testing guide created |

---

**END OF TESTING GUIDE**

For questions or feedback about this guide, please [open an issue](https://github.com/[username]/layup/issues) on GitHub.
4'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Bash (Ubuntu)
        if: runner.os == 'Linux'
        run: |
          sudo apt-get update
          sudo apt-get install -y bash uuid-runtime libxml2-utils
          bash --version
      
      - name: Set up Bash (macOS)
        if: runner.os == 'macOS'
        run: |
          # macOS has bash 3.2 by default
          # Install newer bash via Homebrew for matrix testing
          if [ "${{ matrix.bash-version }}" != "3.2" ]; then
            brew install bash
          fi
          bash --version
      
      - name: Make script executable
        run: chmod +x layup.sh
      
      - name: Run basic functionality test
        run: |
          echo "com.apple.mobilesafari" > test.txt
          echo "com.apple.mobilemail" >> test.txt
          ./layup.sh test.txt output.mobileconfig
      
      - name: Validate XML output
        run: |
          if command -v xmllint &> /dev/null; then
            xmllint --noout output.mobileconfig
            echo "✓ XML validation passed"
          else
            echo "⚠ xmllint not available, skipping validation"
          fi
      
      - name: Run automated tests (if Bats available)
        if: runner.os == 'macOS' || runner.os == 'Linux'
        run: |
          # Install Bats
          if [ "${{ runner.os }}" == "macOS" ]; then
            brew install bats-core
          else
            sudo apt-get install -y bats
          fi
          
          # Run tests
          bats tests/ || echo "⚠ Some tests failed"
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: test-output-${{ matrix.os }}
          path: output.mobileconfig

  test-windows:
    name: Test on Windows (WSL)
    runs-on: windows-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up WSL
        uses: Vampire/setup-wsl@v2
        with:
          distribution: Ubuntu-22.04
      
      - name: Install dependencies in WSL
        shell: wsl-bash {0}
        run: |
          sudo apt-get update
          sudo apt-get install -y bash uuid-runtime libxml2-utils
          bash --version
      
      - name: Convert line endings
        shell: wsl-bash {0}
        run: |
          sudo apt-get install -y dos2unix
          dos2unix layup.sh
          chmod +x layup.sh
      
      - name: Run tests in WSL
        shell: wsl-bash {0}
        run: |
          echo "com.apple.mobilesafari" > test.txt
          ./layup.sh test.txt output.mobileconfig
          xmllint --noout output.mobileconfig
          echo "✓ WSL tests passed"
```

**Workflow Features:**
- Tests on multiple OS versions (Ubuntu, macOS)
- Tests with different Bash versions
- Tests on Windows via WSL
- Validates XML output
- Uploads test artifacts
- Runs automated test suite

**Trigger Workflow:**
```bash
# Automatically runs on push/PR to main or develop
git push origin main

# Or manually trigger from GitHub Actions tab
```

#### 6.4.3 Testing with Different Bash Versions

**Using Docker for Bash Version Testing:**
```bash
# Test with Bash 4.4
docker run --rm -v $(pwd):/app -w /app bash:4.4 bash -c "
    bash --version &&
    echo 'com.apple.mobilesafari' > test.txt &&
    ./layup.sh test.txt output.mobileconfig
"

# Test with Bash 5.0
docker run --rm -v $(pwd):/app -w /app bash:5.0 bash -c "
    bash --version &&
    echo 'com.apple.mobilesafari' > test.txt &&
    ./layup.sh test.txt output.mobileconfig
"

# Test with Bash 5.1
docker run --rm -v $(pwd):/app -w /app bash:5.1 bash -c "
    bash --version &&
    echo 'com.apple.mobilesafari' > test.txt &&
    ./layup.sh test.txt output.mobileconfig
"
```

**Local Bash Version Testing (macOS):**
```bash
# Test with system Bash 3.2
/bin/bash layup.sh test.txt output.mobileconfig

# Test with Homebrew Bash
/usr/local/bin/bash layup.sh test.txt output.mobileconfig

# Test with specific version via Docker
docker run --rm -v $(pwd):/app -w /app bash:4.4 ./layup.sh test.txt output.mobileconfig
```

#### 6.4.4 CI/CD Integration Examples

**GitLab CI Configuration:**
```yaml
# .gitlab-ci.yml
stages:
  - test

test:ubuntu:
  stage: test
  image: ubuntu:22.04
  before_script:
    - apt-get update
    - apt-get install -y bash uuid-runtime libxml2-utils
  script:
    - bash --version
    - chmod +x layup.sh
    - echo "com.apple.mobilesafari" > test.txt
    - ./layup.sh test.txt output.mobileconfig
    - xmllint --noout output.mobileconfig
  artifacts:
    paths:
      - output.mobileconfig

test:alpine:
  stage: test
  image: alpine:3.18
  before_script:
    - apk add --no-cache bash util-linux libxml2-utils
  script:
    - bash --version
    - chmod +x layup.sh
    - echo "com.apple.mobilesafari" > test.txt
    - ./layup.sh test.txt output.mobileconfig
    - xmllint --noout output.mobileconfig
  artifacts:
    paths:
      - output.mobileconfig
```

**Jenkins Pipeline:**
```groovy
// Jenkinsfile
pipeline {
    agent none
    
    stages {
        stage('Test') {
            parallel {
                stage('Ubuntu') {
                    agent {
                        docker {
                            image 'ubuntu:22.04'
                        }
                    }
                    steps {
                        sh '''
                            apt-get update
                            apt-get install -y bash uuid-runtime libxml2-utils
                            bash --version
                            chmod +x layup.sh
                            echo "com.apple.mobilesafari" > test.txt
                            ./layup.sh test.txt output.mobileconfig
                            xmllint --noout output.mobileconfig
                        '''
                    }
                }
                
                stage('Alpine') {
                    agent {
                        docker {
                            image 'alpine:3.18'
                        }
                    }
                    steps {
                        sh '''
                            apk add --no-cache bash util-linux libxml2-utils
                            bash --version
                            chmod +x layup.sh
                            echo "com.apple.mobilesafari" > test.txt
                            ./layup.sh test.txt output.mobileconfig
                            xmllint --noout output.mobileconfig
                        '''
                    }
                }
            }
        }
    }
}
```

### 6.5 Platform-Specific Issues and Workarounds

#### 6.5.1 macOS-Specific Issues

**Issue: Bash 3.2 Array Limitations**

**Symptoms:**
- Array operations fail or behave unexpectedly
- Advanced array features not available

**Workaround:**
```bash
# Instead of associative arrays (Bash 4+)
declare -A my_array  # Not available in Bash 3.2

# Use indexed arrays or separate variables
declare -a my_array
my_array[0]="value1"
my_array[1]="value2"

# Or upgrade to Bash 4+
brew install bash
```

**Issue: Gatekeeper Blocking Script Execution**

**Symptoms:**
- "Cannot be opened because it is from an unidentified developer"
- Script won't execute even with execute permissions

**Workaround:**
```bash
# Remove quarantine attribute
xattr -d com.apple.quarantine layup.sh

# Or allow in System Preferences
# System Preferences → Security & Privacy → Allow
```

**Issue: SIP (System Integrity Protection) Restrictions**

**Symptoms:**
- Cannot modify certain system directories
- Permission denied errors in protected locations

**Workaround:**
```bash
# Work in user directories only
cd ~/Documents/layup
./layup.sh test.txt output.mobileconfig

# Don't try to install in /usr/bin or /System
```

#### 6.5.2 Linux-Specific Issues

**Issue: Missing uuidgen Command**

**Symptoms:**
- "uuidgen: command not found"
- Script fails to generate UUIDs

**Workaround:**
```bash
# Install uuid-runtime (Ubuntu/Debian)
sudo apt-get install uuid-runtime

# Install util-linux (RHEL/Fedora)
sudo dnf install util-linux

# Or script uses fallback method automatically
```

**Issue: xmllint Not Available**

**Symptoms:**
- "xmllint: command not found"
- XML validation skipped

**Workaround:**
```bash
# Install libxml2-utils (Ubuntu/Debian)
sudo apt-get install libxml2-utils

# Install libxml2 (RHEL/Fedora)
sudo dnf install libxml2

# Install libxml2 (Arch)
sudo pacman -S libxml2
```

**Issue: No File Opening Command**

**Symptoms:**
- `open` command not found
- Cannot open generated file automatically

**Workaround:**
```bash
# Install xdg-utils
sudo apt-get install xdg-utils  # Ubuntu/Debian
sudo dnf install xdg-utils      # RHEL/Fedora

# Or manually open file
xdg-open output.mobileconfig

# Or use specific application
gedit output.mobileconfig
kate output.mobileconfig
```

**Issue: Case-Sensitive File System**

**Symptoms:**
- File not found errors with different case
- `Test.txt` vs `test.txt` treated as different files

**Workaround:**
```bash
# Be consistent with file naming
# Use lowercase for consistency
./layup.sh test.txt output.mobileconfig

# Check actual filename
ls -l | grep -i test
```

#### 6.5.3 Windows-Specific Issues

**Issue: CRLF Line Endings**

**Symptoms:**
- `$'\r': command not found`
- Script fails to execute
- Syntax errors

**Workaround:**
```bash
# Convert to LF using dos2unix
dos2unix layup.sh

# Or using sed
sed -i 's/\r$//' layup.sh

# Configure Git to prevent CRLF
git config --global core.autocrlf input

# Add .gitattributes
echo "*.sh text eol=lf" > .gitattributes
```

**Issue: Path Separator Differences**

**Symptoms:**
- Paths with backslashes fail
- Cannot find files

**Workaround:**
```bash
# Always use forward slashes in WSL/Git Bash
./layup.sh test.txt output.mobileconfig

# Not: .\layup.sh test.txt output.mobileconfig

# Use WSL paths
cd /mnt/c/Users/Username/layup
```

**Issue: Missing uuidgen in Git Bash**

**Symptoms:**
- `uuidgen: command not found` in Git Bash
- UUIDs not generated

**Workaround:**
```bash
# Script automatically uses fallback method
# No action needed - fallback generates UUIDs from /dev/urandom

# Or use WSL instead of Git Bash
wsl bash layup.sh test.txt output.mobileconfig
```

**Issue: Permission Denied on WSL**

**Symptoms:**
- Cannot execute script
- Permission denied errors

**Workaround:**
```bash
# Make script executable
chmod +x layup.sh

# Check file permissions
ls -l layup.sh

# If on Windows filesystem, copy to WSL filesystem
cp /mnt/c/Users/Username/layup/layup.sh ~/layup.sh
cd ~
chmod +x layup.sh
./layup.sh test.txt output.mobileconfig
```

### 6.6 Cross-Platform Test Checklist

#### 6.6.1 Pre-Flight Checklist for Each Platform

**macOS Pre-Flight:**
- [ ] macOS version is 10.15 or later
- [ ] Bash version checked (`bash --version`)
- [ ] `uuidgen` command available
- [ ] `xmllint` command available
- [ ] `open` command available
- [ ] Script has execute permissions (`chmod +x layup.sh`)
- [ ] Xcode Command Line Tools installed (if needed)
- [ ] Bats installed for automated testing (optional)

**Linux Pre-Flight:**
- [ ] Distribution identified (Ubuntu, RHEL, Arch, Alpine, etc.)
- [ ] Bash version is 4.0 or later
- [ ] `uuidgen` installed (`uuid-runtime` or `util-linux`)
- [ ] `xmllint` installed (`libxml2-utils` or `libxml2`)
- [ ] `xdg-open` installed (optional, for file opening)
- [ ] Script has execute permissions
- [ ] File system case sensitivity understood
- [ ] Bats installed for automated testing (optional)

**Windows Pre-Flight:**
- [ ] WSL, Git Bash, or Cygwin installed
- [ ] Bash version is 4.0 or later (WSL/Cygwin)
- [ ] Dependencies installed in chosen environment
- [ ] Line endings are LF (not CRLF)
- [ ] Script has execute permissions
- [ ] Path handling understood (WSL vs Windows paths)
- [ ] Fallback methods tested (if utilities missing)

#### 6.6.2 Test Scenarios to Run on Each Platform

**Scenario 1: Basic Functionality**
```bash
# Create simple input
echo "com.apple.mobilesafari" > test_basic.txt

# Run script
./layup.sh test_basic.txt output_basic.mobileconfig

# Verify output exists
ls -l output_basic.mobileconfig

# Validate XML (if xmllint available)
xmllint --noout output_basic.mobileconfig
```

**Expected Results:**
- [ ] Script executes without errors
- [ ] Output file is created
- [ ] File size is reasonable (~2KB)
- [ ] XML validation passes (if xmllint available)

**Scenario 2: Multiple Bundle IDs**
```bash
# Create input with 10 Bundle IDs
cat > test_multiple.txt << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.MobileSMS
com.apple.mobilephone
com.apple.mobilecal
com.apple.reminders
com.apple.mobilenotes
com.apple.Maps
com.apple.Music
com.apple.podcasts
EOF

# Run script
./layup.sh test_multiple.txt output_multiple.mobileconfig

# Validate
xmllint --noout output_multiple.mobileconfig
```

**Expected Results:**
- [ ] All 10 Bundle IDs processed
- [ ] Validation summary shows 10 valid IDs
- [ ] Output file contains all Bundle IDs
- [ ] XML structure is correct

**Scenario 3: Invalid Input Handling**
```bash
# Create input with invalid Bundle IDs
cat > test_invalid.txt << 'EOF'
com.apple.mobilesafari
invalid
com.apple.mobilemail
.starts.with.dot
EOF

# Run script
./layup.sh test_invalid.txt output_invalid.mobileconfig

# Check validation output
```

**Expected Results:**
- [ ] Script identifies invalid Bundle IDs
- [ ] Validation summary shows 2 valid, 2 invalid
- [ ] Output file contains only valid Bundle IDs
- [ ] No errors during generation

**Scenario 4: Large Input (100+ Bundle IDs)**
```bash
# Generate large input
for i in {1..150}; do
    echo "com.company.app${i}"
done > test_large.txt

# Run script and time it
time ./layup.sh test_large.txt output_large.mobileconfig

# Check file size
ls -lh output_large.mobileconfig
```

**Expected Results:**
- [ ] Script completes in < 5 seconds
- [ ] File size is reasonable (~20-30KB)
- [ ] All 150 Bundle IDs present in output
- [ ] XML validation passes

**Scenario 5: Special Characters**
```bash
# Create input with special characters
cat > test_special.txt << 'EOF'
com.company.app-name
com.company.app_name
com.Company-Name.App
EOF

# Run script
./layup.sh test_special.txt output_special.mobileconfig

# Validate
xmllint --noout output_special.mobileconfig
```

**Expected Results:**
- [ ] Hyphens and underscores handled correctly
- [ ] Mixed case preserved
- [ ] XML escaping correct
- [ ] No syntax errors

#### 6.6.3 Expected Behavior Differences

**File Opening:**
| Platform | Command | Behavior |
|----------|---------|----------|
| macOS | `open file.mobileconfig` | Opens in System Preferences or default app |
| Linux | `xdg-open file.mobileconfig` | Opens in default app (if xdg-utils installed) |
| Windows (WSL) | N/A | File opening not supported, manual open required |
| Windows (Git Bash) | N/A | File opening not supported, manual open required |

**UUID Generation:**
| Platform | Method | Notes |
|----------|--------|-------|
| macOS | `uuidgen` | Native command, always available |
| Linux | `uuidgen` | Requires `uuid-runtime` or `util-linux` package |
| Windows (WSL) | `uuidgen` | Usually available in Ubuntu on WSL |
| Windows (Git Bash) | Fallback | Uses `/dev/urandom` fallback method |

**XML Validation:**
| Platform | Availability | Notes |
|----------|--------------|-------|
| macOS | Always | Pre-installed with Xcode Command Line Tools |
| Linux | Usually | Requires `libxml2-utils` or `libxml2` package |
| Windows (WSL) | Usually | Can be installed via apt/dnf |
| Windows (Git Bash) | Rarely | Often not available, validation skipped |

**Performance:**
| Platform | Typical Speed (100 apps) | Notes |
|----------|-------------------------|-------|
| macOS | 1-2 seconds | Optimal performance |
| Linux | 1-3 seconds | Depends on distribution and hardware |
| Windows (WSL 2) | 2-4 seconds | Good performance |
| Windows (WSL 1) | 3-5 seconds | Slower due to file system translation |
| Windows (Git Bash) | 2-4 seconds | Reasonable performance |

#### 6.6.4 Validation Criteria

**Output File Validation:**
- [ ] File exists and is readable
- [ ] File size is appropriate (150 bytes per Bundle ID + 2KB overhead)
- [ ] File has `.mobileconfig` extension
- [ ] File permissions are correct (644 or rw-r--r--)

**XML Structure Validation:**
- [ ] XML declaration present: `<?xml version="1.0" encoding="UTF-8"?>`
- [ ] DOCTYPE declaration present and correct
- [ ] Root element is `<plist version="1.0">`
- [ ] Outer payload type is `Configuration`
- [ ] Inner payload type is `com.apple.homescreenlayout.managed`
- [ ] All Bundle IDs present in `<string>` tags
- [ ] UUIDs are unique (at least 2 different UUIDs)
- [ ] No XML syntax errors (`xmllint --noout` passes)

**Functional Validation:**
- [ ] Script accepts valid input file
- [ ] Script rejects missing input file
- [ ] Script handles empty input file gracefully
- [ ] Script validates Bundle ID format correctly
- [ ] Script generates correct validation summary
- [ ] Script creates output file successfully
- [ ] Script handles file overwrite correctly (prompts user)
- [ ] Script exits with correct exit codes

**Cross-Platform Validation:**
- [ ] Script runs on macOS without errors
- [ ] Script runs on Linux without errors
- [ ] Script runs on Windows (WSL) without errors
- [ ] Line endings are handled correctly
- [ ] Path separators work correctly
- [ ] Missing utilities handled gracefully (fallbacks work)
- [ ] Platform-specific commands detected correctly
- [ ] Output is identical across platforms (except UUIDs)

**Performance Validation:**
- [ ] Script completes in reasonable time (< 5 seconds for 100 apps)
- [ ] Memory usage is reasonable
- [ ] No resource leaks
- [ ] Scales well with large inputs (150+ apps)

---

**Cross-Reference:** For automated testing procedures, see [Section 1: Automated Testing](#section-1-automated-testing).
