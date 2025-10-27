# Bundle ID Reference Guide

**Version:** 1.0  
**Date:** October 27, 2025  
**Status:** Active Reference  

---

## Table of Contents

1. [Introduction](#introduction)
2. [Common Bundle IDs](#common-bundle-ids)
3. [How to Find Bundle IDs](#how-to-find-bundle-ids)
4. [Validation Rules](#validation-rules)
5. [Troubleshooting](#troubleshooting)

---

## Introduction

### What is a Bundle ID?

A **Bundle ID** (Bundle Identifier) is a unique string that identifies an iOS, iPadOS, or macOS application. It follows a reverse-domain naming convention and is used by Apple's operating systems to uniquely identify apps.

**Format:** `com.company.appname`

**Examples:**
- `com.apple.mobilesafari` - Safari browser
- `com.microsoft.Office.Outlook` - Microsoft Outlook
- `com.google.chrome.ios` - Google Chrome

### Why Bundle IDs Matter

Bundle IDs are essential for:
- **MDM Configuration:** Identifying apps in Mobile Device Management profiles
- **Home Screen Layout:** Specifying which apps appear in managed layouts
- **App Restrictions:** Controlling which apps users can access
- **App Distribution:** Uniquely identifying apps in the App Store

### Purpose of This Guide

This reference guide helps you:
1. Find commonly used Bundle IDs for popular apps
2. Discover Bundle IDs for apps on your devices
3. Understand Bundle ID format requirements
4. Validate Bundle IDs before using them in [`layup.sh`](../layup.sh)

---

## Common Bundle IDs

### Apple Built-in Apps (iOS/iPadOS)

#### Communication Apps

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Safari | `com.apple.mobilesafari` | Web browser |
| Mail | `com.apple.mobilemail` | Email client |
| Messages | `com.apple.MobileSMS` | Text messaging |
| Phone | `com.apple.mobilephone` | Phone app (iPhone only) |
| FaceTime | `com.apple.facetime` | Video calling |
| Contacts | `com.apple.contacts` | Contact management |

#### Productivity Apps

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Calendar | `com.apple.mobilecal` | Calendar and events |
| Reminders | `com.apple.reminders` | Task management |
| Notes | `com.apple.mobilenotes` | Note-taking |
| Pages | `com.apple.Pages` | Word processor |
| Numbers | `com.apple.Numbers` | Spreadsheet |
| Keynote | `com.apple.Keynote` | Presentations |
| Files | `com.apple.DocumentsApp` | File management |
| Freeform | `com.apple.freeform` | Collaborative whiteboard |

#### Media & Entertainment

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Music | `com.apple.Music` | Music player |
| Podcasts | `com.apple.podcasts` | Podcast player |
| Apple TV | `com.apple.tv` | Video streaming |
| Books | `com.apple.iBooks` | E-book reader |
| Camera | `com.apple.camera` | Camera app |
| Photos | `com.apple.mobileslideshow` | Photo library |
| News | `com.apple.news` | News aggregator |

#### Utilities

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Maps | `com.apple.Maps` | Navigation and maps |
| Weather | `com.apple.weather` | Weather forecasts |
| Compass | `com.apple.compass` | Compass and level |
| Calculator | `com.apple.calculator` | Calculator (iPhone) |
| Voice Memos | `com.apple.VoiceMemos` | Audio recording |
| Clock | `com.apple.mobiletimer` | Clock, alarms, timers |
| Measure | `com.apple.measure` | AR measurement tool |
| Translate | `com.apple.Translate` | Language translation |

#### Settings & System

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Settings | `com.apple.Preferences` | System settings |
| App Store | `com.apple.AppStore` | App marketplace |
| iTunes Store | `com.apple.MobileStore` | Media store |
| Find My | `com.apple.findmy` | Device location |
| Wallet | `com.apple.Passbook` | Digital wallet |
| Health | `com.apple.Health` | Health data |
| Home | `com.apple.Home` | Smart home control |
| Shortcuts | `com.apple.shortcuts` | Automation |

### Microsoft Office Suite

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Outlook | `com.microsoft.Office.Outlook` | Email and calendar |
| Word | `com.microsoft.Office.Word` | Word processor |
| Excel | `com.microsoft.Office.Excel` | Spreadsheet |
| PowerPoint | `com.microsoft.Office.Powerpoint` | Presentations |
| OneNote | `com.microsoft.onenote` | Note-taking |
| OneDrive | `com.microsoft.skydrive` | Cloud storage |
| Teams | `com.microsoft.skype.teams` | Collaboration platform |
| SharePoint | `com.microsoft.sharepoint` | Document management |

### Google Apps

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Chrome | `com.google.chrome.ios` | Web browser |
| Gmail | `com.google.Gmail` | Email client |
| Google Drive | `com.google.Drive` | Cloud storage |
| Google Maps | `com.google.Maps` | Navigation |
| Google Calendar | `com.google.Calendar` | Calendar |
| Google Docs | `com.google.Docs` | Word processor |
| Google Sheets | `com.google.Sheets` | Spreadsheet |
| Google Slides | `com.google.Slides` | Presentations |
| YouTube | `com.google.ios.youtube` | Video platform |
| Google Photos | `com.google.photos` | Photo storage |

### Communication & Collaboration

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Slack | `com.slack.Slack` | Team messaging |
| Zoom | `com.zoom.videomeetings` | Video conferencing |
| Webex | `com.cisco.webex.meetings` | Video conferencing |
| Skype | `com.skype.skype` | Video calling |
| Discord | `com.hammerandchisel.discord` | Voice and chat |
| WhatsApp | `net.whatsapp.WhatsApp` | Messaging |
| Telegram | `ph.telegra.Telegraph` | Messaging |
| Signal | `org.whispersystems.signal` | Secure messaging |

### Social Media

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Facebook | `com.facebook.Facebook` | Social network |
| Instagram | `com.instagram.Instagram` | Photo sharing |
| Twitter (X) | `com.twitter.twitter` | Microblogging |
| LinkedIn | `com.linkedin.LinkedIn` | Professional network |
| TikTok | `com.zhiliaoapp.musically` | Short video platform |
| Reddit | `com.reddit.Reddit` | Discussion platform |
| Snapchat | `com.toyopagroup.picaboo` | Messaging and media |

### Productivity & Business

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Notion | `com.notion.ios` | Workspace and notes |
| Evernote | `com.evernote.iPhone.Evernote` | Note-taking |
| Trello | `com.fogcreek.trello` | Project management |
| Asana | `com.asana.mobile` | Task management |
| Monday.com | `com.monday.monday` | Work management |
| Dropbox | `com.dropbox.Dropbox` | Cloud storage |
| Box | `com.box.BoxNet` | Cloud storage |
| Adobe Acrobat | `com.adobe.Adobe-Reader` | PDF reader |

### Development & Technical

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| GitHub | `com.github.GitHubApp` | Code repository |
| TestFlight | `com.apple.TestFlight` | Beta testing |
| Xcode | `com.apple.dt.Xcode` | Development IDE (macOS) |
| VS Code | `com.microsoft.VSCode` | Code editor (macOS) |
| Terminal | `com.apple.Terminal` | Command line (macOS) |

### Education

| App Name | Bundle ID | Description |
|----------|-----------|-------------|
| Classroom | `com.apple.classroom` | Education management |
| Schoolwork | `com.apple.schoolwork` | Assignment management |
| Canvas | `com.instructure.icanvas` | Learning management |
| Google Classroom | `com.google.classroom` | Education platform |
| Duolingo | `com.duolingo.DuolingoMobile` | Language learning |
| Khan Academy | `org.khanacademy.Khan-Academy` | Educational content |

---

## How to Find Bundle IDs

### Method 1: Using Terminal (macOS)

#### For Installed Apps on Mac

**Using `mdls` command:**
```bash
# Find Bundle ID for an app
mdls -name kMDItemCFBundleIdentifier /Applications/Safari.app

# Output:
# kMDItemCFBundleIdentifier = "com.apple.Safari"
```

**Using `osascript` (AppleScript):**
```bash
# Get Bundle ID of running app
osascript -e 'id of app "Safari"'

# Output:
# com.apple.Safari
```

**Using `defaults` command:**
```bash
# Read Info.plist directly
defaults read /Applications/Safari.app/Contents/Info.plist CFBundleIdentifier

# Output:
# com.apple.Safari
```

#### For iOS Apps (via Simulator or Device)

**Using iOS Simulator:**
```bash
# List all installed apps in simulator
xcrun simctl listapps booted

# Find specific app
xcrun simctl listapps booted | grep -i safari
```

**Using Apple Configurator 2:**
1. Connect iOS device to Mac
2. Open Apple Configurator 2
3. Select device
4. Click "Apps" in sidebar
5. Right-click app → "Show in Finder"
6. Right-click `.ipa` file → "Show Package Contents"
7. Open `Payload/[AppName].app/Info.plist`
8. Find `CFBundleIdentifier` key

### Method 2: Using System Information (macOS)

**Steps:**
1. Open **System Information** (Apple menu → About This Mac → System Report)
2. Navigate to **Software** → **Applications**
3. Select an application
4. Look for **Bundle Identifier** field

**Example:**
```
Application: Safari
Bundle Identifier: com.apple.Safari
Version: 17.0
```

### Method 3: Checking Info.plist Files

#### macOS Applications

**Steps:**
1. Navigate to `/Applications/` in Finder
2. Right-click app → "Show Package Contents"
3. Open `Contents/Info.plist`
4. Find `CFBundleIdentifier` key

**Example Info.plist:**
```xml
<key>CFBundleIdentifier</key>
<string>com.apple.Safari</string>
```

**Using Terminal:**
```bash
# Read Bundle ID from Info.plist
/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" /Applications/Safari.app/Contents/Info.plist

# Output:
# com.apple.Safari
```

#### iOS Applications (.ipa files)

**Steps:**
1. Obtain `.ipa` file (from iTunes backup or App Store download)
2. Rename `.ipa` to `.zip`
3. Extract archive
4. Navigate to `Payload/[AppName].app/`
5. Open `Info.plist`
6. Find `CFBundleIdentifier` key

### Method 4: Using Third-Party Tools

#### iMazing (Recommended)

**Features:**
- View Bundle IDs for all installed apps
- Export app information
- Works with iOS and iPadOS devices

**Steps:**
1. Download [iMazing](https://imazing.com/)
2. Connect iOS device
3. Navigate to "Apps" section
4. Select app to view Bundle ID

#### Apple Configurator 2 (Free)

**Features:**
- Official Apple tool
- View app details
- Manage iOS devices

**Steps:**
1. Download from Mac App Store
2. Connect iOS device
3. Select device
4. View app information in "Apps" section

#### iFunBox

**Features:**
- File system access
- App information viewer
- Free tool

**Steps:**
1. Download [iFunBox](http://www.i-funbox.com/)
2. Connect iOS device
3. Navigate to "App Management"
4. View Bundle IDs for installed apps

### Method 5: Using MDM Platforms

Most MDM platforms provide Bundle ID information in their app catalogs.

#### Jamf Pro

**Steps:**
1. Log in to Jamf Pro
2. Navigate to **Mobile Device Apps**
3. Search for app
4. View **Bundle ID** field in app details

#### Workspace ONE

**Steps:**
1. Log in to Workspace ONE console
2. Navigate to **Apps & Books** → **Applications**
3. Search for app
4. View **Bundle Identifier** in app details

#### Microsoft Intune

**Steps:**
1. Log in to Microsoft Endpoint Manager
2. Navigate to **Apps** → **All apps**
3. Search for app
4. View **Bundle ID** in app properties

### Method 6: Online Resources

#### Apple Developer Documentation

- [App Store Connect](https://appstoreconnect.apple.com/) - For your own apps
- [Apple Developer Portal](https://developer.apple.com/) - Official documentation

#### Community Resources

- **GitHub Repositories:** Search for "iOS Bundle IDs" or "app identifiers"
- **MDM Forums:** Jamf Nation, VMware Communities, etc.
- **Stack Overflow:** Search for specific app Bundle IDs

#### App Store Lookup

**Using iTunes Search API:**
```bash
# Search for app by name
curl "https://itunes.apple.com/search?term=safari&entity=software"

# Extract Bundle ID from JSON response
# Look for "bundleId" field
```

**Example Response:**
```json
{
  "bundleId": "com.apple.mobilesafari",
  "trackName": "Safari",
  "artistName": "Apple Inc."
}
```

---

## Validation Rules

### Format Requirements

Bundle IDs must follow these strict formatting rules to be valid:

#### 1. Minimum Segments

**Rule:** Bundle IDs must contain at least **2 segments** separated by dots.

**Valid Examples:**
```
com.apple          ✓ (2 segments)
com.company.app    ✓ (3 segments)
org.example.app    ✓ (3 segments)
```

**Invalid Examples:**
```
invalid            ✗ (1 segment - not enough)
app                ✗ (1 segment - not enough)
```

**Error Message:**
```
✗ Line 1: invalid (invalid format: not enough segments)
```

#### 2. Valid Characters

**Rule:** Bundle IDs may only contain:
- Lowercase letters: `a-z`
- Uppercase letters: `A-Z`
- Numbers: `0-9`
- Hyphens: `-`
- Underscores: `_`
- Dots: `.` (as separators only)

**Valid Examples:**
```
com.company.app           ✓ (letters only)
com.company.app123        ✓ (letters and numbers)
com.company-name.app      ✓ (with hyphen)
com.company_name.app      ✓ (with underscore)
com.Company-Name.App_123  ✓ (mixed case and characters)
```

**Invalid Examples:**
```
com.app@test      ✗ (contains @)
com.app!test      ✗ (contains !)
com.app$test      ✗ (contains $)
com.app%test      ✗ (contains %)
com.app&test      ✗ (contains &)
com.app*test      ✗ (contains *)
com.app+test      ✗ (contains +)
com.app=test      ✗ (contains =)
com.app/test      ✗ (contains /)
com.app\test      ✗ (contains \)
com.app test      ✗ (contains space)
```

**Error Message:**
```
✗ Line 2: com.app@test (invalid format: invalid characters)
```

#### 3. Dot Position Rules

**Rule:** Dots must be used as separators between segments only.

**Cannot Start with Dot:**
```
.com.app          ✗ (starts with dot)
..com.app         ✗ (starts with multiple dots)
```

**Cannot End with Dot:**
```
com.app.          ✗ (ends with dot)
com.app..         ✗ (ends with multiple dots)
```

**Cannot Have Consecutive Dots:**
```
com..app          ✗ (consecutive dots in middle)
com...app         ✗ (multiple consecutive dots)
```

**Valid Examples:**
```
com.app           ✓ (single dot separator)
com.company.app   ✓ (multiple single dots)
```

**Error Messages:**
```
✗ Line 3: .com.app (invalid format: starts with dot)
✗ Line 4: com.app. (invalid format: ends with dot)
✗ Line 5: com..app (invalid format: consecutive dots)
```

#### 4. Whitespace Rules

**Rule:** Bundle IDs cannot contain any whitespace characters.

**Invalid Examples:**
```
com.app test      ✗ (contains space)
com. app          ✗ (space after dot)
com.app           ✗ (leading space)
com.app           ✗ (trailing space)
com.app	test      ✗ (contains tab)
```

**Valid Example:**
```
com.app.test      ✓ (no whitespace)
```

**Error Message:**
```
✗ Line 6: com.app test (invalid format: contains whitespace)
```

#### 5. Case Sensitivity

**Rule:** Bundle IDs are **case-sensitive** and case is preserved exactly as entered.

**Examples:**
```
com.apple.safari          (lowercase)
com.Apple.Safari          (mixed case)
com.APPLE.SAFARI          (uppercase)
```

These are treated as **three different Bundle IDs** by the system.

**Best Practice:** Follow the app's actual Bundle ID case exactly. Most apps use lowercase, but some use mixed case (e.g., `com.apple.MobileSMS`).

### Regular Expression Pattern

The validation uses this regex pattern:

```regex
^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$
```

**Pattern Breakdown:**
- `^` - Start of string
- `[a-zA-Z0-9_-]+` - First segment: one or more valid characters
- `(\.[a-zA-Z0-9_-]+)+` - One or more additional segments, each starting with a dot
- `$` - End of string

**What This Means:**
1. Must start with valid characters (not a dot)
2. Must have at least one dot followed by more valid characters
3. Can repeat the dot + segment pattern multiple times
4. Must end with valid characters (not a dot)

### Validation Examples

#### Valid Bundle IDs

```
✓ com.apple                           (2 segments, basic)
✓ com.apple.safari                    (3 segments, lowercase)
✓ com.apple.MobileSMS                 (mixed case)
✓ com.company.app123                  (with numbers)
✓ com.company-name.app                (with hyphen)
✓ com.company_name.app                (with underscore)
✓ com.Company-Name.App_123            (mixed case and characters)
✓ com.example.very.long.bundle.id     (many segments)
✓ a.b                                 (minimal valid)
✓ com.company.app-name_v2             (complex but valid)
```

#### Invalid Bundle IDs

```
✗ invalid                             (not enough segments)
✗ com.                                (ends with dot)
✗ .com.app                            (starts with dot)
✗ com..app                            (consecutive dots)
✗ com.app test                        (contains space)
✗ com.app@test                        (invalid character: @)
✗ com.app!test                        (invalid character: !)
✗ com.app$test                        (invalid character: $)
✗ com.app%test                        (invalid character: %)
✗ com.app&test                        (invalid character: &)
✗ com.app*test                        (invalid character: *)
✗ com.app+test                        (invalid character: +)
✗ com.app=test                        (invalid character: =)
✗ com.app/test                        (invalid character: /)
✗ com.app\test                        (invalid character: \)
✗ .                                   (only dot)
✗ ...                                 (only dots)
```

### Testing Your Bundle IDs

Before using Bundle IDs in [`layup.sh`](../layup.sh), you can test them:

**Method 1: Use layup.sh Validation**
```bash
# Create test file with your Bundle IDs
cat > test_validation.txt << 'EOF'
com.apple.mobilesafari
your.bundle.id.here
another.test.id
EOF

# Run layup.sh to see validation results
./layup.sh test_validation.txt test_output.mobileconfig

# Check validation summary
# Valid IDs will show: ✓ Line N: bundle.id (valid)
# Invalid IDs will show: ✗ Line N: bundle.id (invalid format: reason)
```

**Method 2: Manual Regex Testing**
```bash
# Test a Bundle ID against the regex pattern
bundle_id="com.apple.safari"
if [[ $bundle_id =~ ^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$ ]]; then
    echo "✓ Valid Bundle ID"
else
    echo "✗ Invalid Bundle ID"
fi
```

**Method 3: Use Online Regex Testers**
1. Visit [regex101.com](https://regex101.com/)
2. Enter pattern: `^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$`
3. Test your Bundle IDs in the test string field
4. View matches and explanations

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Bundle ID Rejected as Invalid

**Symptoms:**
```
✗ Line 5: com.app@company (invalid format: invalid characters)
```

**Cause:** Bundle ID contains invalid characters (in this case, `@`).

**Solution:**
1. Check the Bundle ID against [validation rules](#validation-rules)
2. Remove or replace invalid characters
3. Verify the correct Bundle ID using [methods above](#how-to-find-bundle-ids)

**Valid Alternatives:**
```
com.app.company          ✓ (replace @ with dot)
com.app-company          ✓ (replace @ with hyphen)
com.app_company          ✓ (replace @ with underscore)
```

#### Issue 2: "Not Enough Segments" Error

**Symptoms:**
```
✗ Line 3: myapp (invalid format: not enough segments)
```

**Cause:** Bundle ID has only one segment (no dots).

**Solution:**
Add at least one dot to create two segments:
```
myapp                    ✗ (1 segment)
com.myapp                ✓ (2 segments)
com.company.myapp        ✓ (3 segments)
```

#### Issue 3: Bundle ID Starts or Ends with Dot

**Symptoms:**
```
✗ Line 4: .com.app (invalid format: starts with dot)
✗ Line 5: com.app. (invalid format: ends with dot)
```

**Cause:** Bundle ID has leading or trailing dots.

**Solution:**
Remove leading/trailing dots:
```
.com.app                 ✗ (starts with dot)
com.app                  ✓ (no leading dot)

com.app.                 ✗ (ends with dot)
com.app                  ✓ (no trailing dot)
```

#### Issue 4: Consecutive Dots

**Symptoms:**
```
✗ Line 6: com..app (invalid format: consecutive dots)
```

**Cause:** Bundle ID has two or more consecutive dots.

**Solution:**
Remove extra dots:
```
com..app                 ✗ (consecutive dots)
com.app                  ✓ (single dot)

com...app                ✗ (multiple consecutive dots)
com.app                  ✓ (single dot)
```

#### Issue 5: Whitespace in Bundle ID

**Symptoms:**
```
✗ Line 7: com.app test (invalid format: contains whitespace)
```

**Cause:** Bundle ID contains spaces, tabs, or other whitespace.

**Solution:**
Remove whitespace or replace with valid characters:
```
com.app test             ✗ (contains space)
com.app.test             ✓ (replace space with dot)
com.app-test             ✓ (replace space with hyphen)
com.app_test             ✓ (replace space with underscore)
```

#### Issue 6: Case Mismatch

**Symptoms:**
- Bundle ID validates but app doesn't appear in MDM profile
- Profile deploys but home screen layout doesn't apply

**Cause:** Bundle ID case doesn't match the actual app's Bundle ID.

**Solution:**
1. Verify exact case using [methods above](#how-to-find-bundle-ids)
2. Update Bundle ID to match exactly:
```
com.apple.mobilesms      ✗ (wrong case)
com.apple.MobileSMS      ✓ (correct case - note capital M and SMS)
```

**Common Case-Sensitive Examples:**
```
com.apple.MobileSMS      (not mobilesms)
com.apple.AppStore       (not appstore)
com.apple.DocumentsApp   (not documentsapp)
```

#### Issue 7: Bundle ID Not Found on Device

**Symptoms:**
- Bundle ID validates correctly
- Profile deploys successfully
- App doesn't appear in home screen layout

**Possible Causes:**
1. App is not installed on device
2. Bundle ID is incorrect (typo or wrong app)
3. App version has different Bundle ID
4. App is restricted by another profile

**Solutions:**

**Verify App Installation:**
```bash
# On device: Settings → General → iPhone Storage
# Check if app is installed
```

**Verify Bundle ID:**
1. Use [methods above](#how-to-find-bundle-ids) to confirm Bundle ID
2. Check for typos in your input file
3. Verify app version (some apps change Bundle IDs between versions)

**Check for Conflicts:**
1. Review other MDM profiles on device
2. Check for app restrictions
3. Verify no conflicting home screen layouts

#### Issue 8: Special Characters Not Working

**Symptoms:**
```
✗ Line 8: com.app™ (invalid format: invalid characters)
```

**Cause:** Bundle ID contains special characters not in the allowed set.

**Allowed Characters:**
- Letters: `a-z`, `A-Z`
- Numbers: `0-9`
- Hyphen: `-`
- Underscore: `_`
- Dot: `.` (separator only)

**Not Allowed:**
- Symbols: `@`, `#`, `$`, `%`, `^`, `&`, `*`, `(`, `)`, `+`, `=`, etc.
- Accented characters: `é`, `ñ`, `ü`, etc.
- Unicode characters: `™`, `©`, `®`, emoji, etc.

**Solution:**
Use only allowed characters. If the actual Bundle ID contains special characters, verify it's correct using official methods.

### Validation Checklist

Before using Bundle IDs in [`layup.sh`](../layup.sh), verify:

- [ ] Bundle ID has at least 2 segments (e.g., `com.app`)
- [ ] Bundle ID uses only valid characters: `a-z`, `A-Z`, `0-9`, `-`, `_`, `.`
- [ ] Bundle ID doesn't start with a dot
- [ ] Bundle ID doesn't end with a dot
- [ ] Bundle ID has no consecutive dots
- [ ] Bundle ID has no whitespace (spaces, tabs, newlines)
- [ ] Bundle ID case matches the actual app's Bundle ID exactly
- [ ] App is installed on target devices
- [ ] Bundle ID is verified using official methods

### Getting Help

If you continue to have issues with Bundle IDs:

1. **Verify with Official Tools:**
   - Use Apple Configurator 2
   - Check MDM platform's app catalog
   - Use `mdls` or `osascript` on macOS

2. **Check Documentation:**
   - [`README.md`](../README.md) - Project overview
   - [`TESTING_GUIDE.md`](TESTING_GUIDE.md) - Testing procedures
   - [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) - Technical details

3. **Report Issues:**
   - [Open an issue](https://github.com/[username]/layup/issues) on GitHub
   - Include your input file and error messages
   - Specify which Bundle IDs are failing validation

4. **Community Resources:**
   - MDM platform forums (Jamf Nation, VMware Communities, etc.)
   - Apple Developer Forums
   - Stack Overflow

---

## Quick Reference

### Validation Regex

```regex
^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$
```

### Valid Characters

```
a-z A-Z 0-9 - _ .
```

### Minimum Requirements

- **Segments:** 2 or more
- **Separator:** Dot (`.`)
- **Case:** Sensitive (preserve exact case)

### Common Patterns

```
com.company.app          (standard format)
com.company-name.app     (with hyphen)
com.company_name.app     (with underscore)
com.Company.App          (mixed case)
org.example.app          (org domain)
net.example.app          (net domain)
```

### Testing Command

```bash
# Test Bundle ID validation
echo "your.bundle.id" > test.txt
./layup.sh test.txt output.mobileconfig
```

---

## Related Documentation

- [`README.md`](../README.md) - Project overview and quick start
- [`TESTING_GUIDE.md`](TESTING_GUIDE.md) - Comprehensive testing guide
- [`IMPLEMENTATION_PLAN.md`](../IMPLEMENTATION_PLAN.md) - Development plan
- [`CONTRIBUTING.md`](../CONTRIBUTING.md) - Contribution guidelines

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-27 | Development Team | Initial Bundle ID reference guide created |

---

**END OF BUNDLE ID REFERENCE GUIDE**

For questions or feedback about this guide, please [open an issue](https://github.com/[username]/layup/issues) on GitHub.