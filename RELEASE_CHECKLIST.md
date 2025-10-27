# Release Checklist for Layup v1.0.0

**Version:** 1.0.0  
**Release Date:** 2025-10-27  
**Status:** Pre-Release Preparation  

---

## Table of Contents

1. [Pre-Release Verification](#pre-release-verification)
2. [Testing Requirements](#testing-requirements)
3. [Documentation Review](#documentation-review)
4. [Git Tagging Instructions](#git-tagging-instructions)
5. [GitHub Release Creation](#github-release-creation)
6. [Post-Release Validation](#post-release-validation)

---

## Pre-Release Verification

### Code Quality Checks

- [ ] All code follows bash best practices
- [ ] No hardcoded values (constants used throughout)
- [ ] Error handling is comprehensive
- [ ] Exit codes are used correctly (0, 1, 2, 3, 4, 5)
- [ ] All functions have clear, single responsibilities
- [ ] Code comments explain "why", not "what"

### File Verification

- [ ] [`layup.sh`](layup.sh) is executable (`chmod +x layup.sh`)
- [ ] All sample input files exist in [`examples/`](examples/)
  - [ ] [`sample_apps.txt`](examples/sample_apps.txt)
  - [ ] [`sample_apps_with_comments.txt`](examples/sample_apps_with_comments.txt)
  - [ ] [`minimal.txt`](examples/minimal.txt)
  - [ ] [`documented.txt`](examples/documented.txt)
- [ ] All expected output files exist in [`examples/expected_outputs/`](examples/expected_outputs/)
  - [ ] [`sample_apps.mobileconfig`](examples/expected_outputs/sample_apps.mobileconfig)
  - [ ] [`sample_apps_with_comments.mobileconfig`](examples/expected_outputs/sample_apps_with_comments.mobileconfig)
  - [ ] [`minimal.mobileconfig`](examples/expected_outputs/minimal.mobileconfig)
  - [ ] [`documented.mobileconfig`](examples/expected_outputs/documented.mobileconfig)

### Documentation Verification

- [ ] [`README.md`](README.md) is complete and accurate
- [ ] [`CHANGELOG.md`](CHANGELOG.md) has v1.0.0 entry with date 2025-10-27
- [ ] [`CONTRIBUTING.md`](CONTRIBUTING.md) is up to date
- [ ] [`LICENSE`](LICENSE) file is present (MIT License)
- [ ] [`docs/TESTING_GUIDE.md`](docs/TESTING_GUIDE.md) is complete
- [ ] [`docs/BUNDLE_ID_REFERENCE.md`](docs/BUNDLE_ID_REFERENCE.md) is complete
- [ ] [`IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md) reflects current state

### Version Consistency

- [ ] Version number in [`CHANGELOG.md`](CHANGELOG.md) is 1.0.0
- [ ] Release date in [`CHANGELOG.md`](CHANGELOG.md) is 2025-10-27
- [ ] All documentation references correct version
- [ ] No "Unreleased" or "TBD" sections in release notes

---

## Testing Requirements

### Automated Test Suite

**Command:**
```bash
bats tests/
```

**Requirements:**
- [ ] All tests execute successfully
- [ ] Test pass rate is ≥98% (194/197 tests passing)
- [ ] No critical test failures
- [ ] Test execution report reviewed ([`TEST_EXECUTION_REPORT.md`](TEST_EXECUTION_REPORT.md))

**Test Coverage:**
- [ ] Unit tests: 769 lines across 5 test files
- [ ] Integration tests: 29 tests in [`test_integration.bats`](tests/test_integration.bats)
- [ ] Infrastructure tests: 15 tests in [`test_infrastructure.bats`](tests/test_infrastructure.bats)

### Manual Testing

#### Basic Functionality Tests

**Test 1: Minimal Input**
```bash
./layup.sh examples/minimal.txt test_minimal.mobileconfig
```
- [ ] Generates valid `.mobileconfig` file
- [ ] Contains 2 apps (Safari, Mail)
- [ ] XML validates with `xmllint --noout test_minimal.mobileconfig`
- [ ] File opens in Finder (if on macOS)

**Test 2: Standard Input**
```bash
./layup.sh examples/sample_apps.txt test_sample.mobileconfig
```
- [ ] Generates valid `.mobileconfig` file
- [ ] Contains 11 apps
- [ ] Validation summary shows correct statistics
- [ ] XML validates successfully

**Test 3: Comments and Organization**
```bash
./layup.sh examples/sample_apps_with_comments.txt test_comments.mobileconfig
```
- [ ] Generates valid `.mobileconfig` file
- [ ] Contains 16 apps
- [ ] Comments are properly ignored
- [ ] Empty lines are handled correctly

**Test 4: Documented Example**
```bash
./layup.sh examples/documented.txt test_documented.mobileconfig
```
- [ ] Generates valid `.mobileconfig` file
- [ ] Contains 11 apps
- [ ] Extensive comments don't cause issues
- [ ] Output matches expected format

#### Error Handling Tests

**Test 5: Missing Input File**
```bash
./layup.sh nonexistent.txt output.mobileconfig
```
- [ ] Exits with code 1
- [ ] Shows clear error message: "Input file 'nonexistent.txt' not found"

**Test 6: Empty Input File**
```bash
touch empty.txt
./layup.sh empty.txt output.mobileconfig
```
- [ ] Exits with code 2
- [ ] Shows error: "Input file is empty"

**Test 7: No Valid Bundle IDs**
```bash
echo "# Only comments" > comments_only.txt
./layup.sh comments_only.txt output.mobileconfig
```
- [ ] Exits with code 3
- [ ] Shows error: "No valid Bundle IDs found"

**Test 8: File Overwrite Protection**
```bash
./layup.sh examples/minimal.txt existing.mobileconfig
# File already exists
./layup.sh examples/minimal.txt existing.mobileconfig
```
- [ ] Prompts: "File 'existing.mobileconfig' already exists. Overwrite? (y/n):"
- [ ] Accepts 'y' or 'Y' to overwrite
- [ ] Accepts 'n' or 'N' to cancel (exit code 0)
- [ ] Re-prompts on invalid input

**Test 9: Help Flag**
```bash
./layup.sh --help
./layup.sh -h
```
- [ ] Displays complete usage information
- [ ] Shows examples
- [ ] Exits with code 0

#### Validation Tests

**Test 10: Invalid Bundle IDs**
```bash
cat > invalid.txt << 'EOF'
invalid
com.app@test
com..app
.com.app
com.app.
EOF
./layup.sh invalid.txt output.mobileconfig
```
- [ ] Shows validation errors for each invalid line
- [ ] Provides specific error reasons
- [ ] Exits with code 3 (no valid Bundle IDs)

**Test 11: Mixed Valid/Invalid**
```bash
cat > mixed.txt << 'EOF'
com.apple.mobilesafari
invalid
com.apple.mobilemail
com.app@test
EOF
./layup.sh mixed.txt output.mobileconfig
```
- [ ] Processes valid Bundle IDs
- [ ] Reports invalid Bundle IDs with reasons
- [ ] Generates file with only valid IDs
- [ ] Shows accurate statistics

### Cross-Platform Testing

#### macOS Testing
- [ ] Tested on macOS 10.15+ (Catalina or later)
- [ ] Bash 3.2+ compatibility verified
- [ ] Zsh compatibility verified
- [ ] Finder integration works (`open -R`)
- [ ] `xmllint` validation works
- [ ] `uuidgen` command available

#### Linux Testing (Optional)
- [ ] Tested on Ubuntu/Debian
- [ ] Bash compatibility verified
- [ ] File generation works
- [ ] XML validation works (if `xmllint` installed)

#### Windows Testing (Optional)
- [ ] Tested on WSL (Windows Subsystem for Linux)
- [ ] Tested on Git Bash
- [ ] File generation works
- [ ] Path handling correct

### Performance Testing

**Test 12: Large Input File**
```bash
# Generate file with 100 Bundle IDs
for i in {1..100}; do echo "com.example.app$i"; done > large.txt
time ./layup.sh large.txt large_output.mobileconfig
```
- [ ] Completes in reasonable time (<5 seconds)
- [ ] Generates valid output
- [ ] Memory usage is acceptable
- [ ] No performance degradation

---

## Documentation Review

### README.md Review

- [ ] Installation instructions are clear
- [ ] Usage examples are accurate
- [ ] All commands have been tested
- [ ] Screenshots/examples are up to date (if applicable)
- [ ] Links to other documentation work
- [ ] "Intended Use" section is present
- [ ] MIT License badge is displayed
- [ ] Troubleshooting section is helpful

### CHANGELOG.md Review

- [ ] v1.0.0 section is at the top
- [ ] Release date is 2025-10-27
- [ ] All major features are listed
- [ ] Test statistics are accurate (197 tests, 98.5% pass rate)
- [ ] Phase 2 and Phase 3 completion noted
- [ ] Known limitations are documented
- [ ] Format follows Keep a Changelog standard

### CONTRIBUTING.md Review

- [ ] Branch workflow is documented
- [ ] Commit message convention is clear
- [ ] Code review process is explained
- [ ] Quality gates are defined
- [ ] TDD workflow is described
- [ ] Examples are provided

### Technical Documentation Review

- [ ] [`TESTING_GUIDE.md`](docs/TESTING_GUIDE.md) is comprehensive
- [ ] [`BUNDLE_ID_REFERENCE.md`](docs/BUNDLE_ID_REFERENCE.md) has common Bundle IDs
- [ ] [`IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md) is up to date
- [ ] All cross-references work
- [ ] Code examples are accurate

### Sample Files Review

- [ ] All sample files use valid Bundle IDs
- [ ] Comments are helpful and accurate
- [ ] Files demonstrate different use cases
- [ ] Expected outputs match current script behavior

---

## Git Tagging Instructions

### Pre-Tag Verification

- [ ] All changes are committed
- [ ] Working directory is clean (`git status`)
- [ ] On `main` branch (`git branch --show-current`)
- [ ] Local `main` is up to date with remote (`git pull origin main`)
- [ ] All tests pass on `main` branch

### Create Annotated Tag

**Command:**
```bash
git tag -a v1.0.0 -m "Release v1.0.0 - First production release

This is the first production-ready release of Layup.

Key Features:
- Complete Bundle ID validation
- Apple MDM-compliant XML generation
- Comprehensive error handling
- 197 tests with 98.5% pass rate
- Full documentation suite

See CHANGELOG.md for complete release notes."
```

**Verification:**
```bash
# Verify tag was created
git tag -l v1.0.0

# View tag details
git show v1.0.0

# Verify tag message
git tag -n99 v1.0.0
```

- [ ] Tag created successfully
- [ ] Tag message is complete
- [ ] Tag points to correct commit

### Push Tag to Remote

**Command:**
```bash
git push origin v1.0.0
```

**Verification:**
```bash
# Verify tag on remote
git ls-remote --tags origin
```

- [ ] Tag pushed to remote successfully
- [ ] Tag visible on GitHub repository

---

## GitHub Release Creation

### Prepare Release Notes

**Release Title:** `v1.0.0 - First Production Release`

**Release Description Template:**

```markdown
# Layup v1.0.0 - First Production Release 🎉

This is the first production-ready release of Layup, a command-line tool that generates Apple MDM Home Screen Layout configuration profiles from plain text Bundle ID lists.

## 🚀 Highlights

- **Complete Core Functionality** - All Phase 2 features implemented and tested
- **Comprehensive Testing** - 197 tests with 98.5% pass rate
- **Full Documentation** - Complete guides for usage, testing, and Bundle ID reference
- **Production Ready** - Robust error handling and validation

## ✨ Features

### Core Functionality
- Bundle ID validation with detailed error reporting
- Apple MDM-compliant XML generation
- Interactive file overwrite protection
- Finder integration (macOS)
- XML validation with xmllint
- Comprehensive statistics reporting

### Input File Support
- Comments (lines starting with #)
- Empty lines for organization
- Case-sensitive Bundle ID preservation
- Clear validation messages

## 📊 Test Coverage

- **Total Tests:** 197
- **Pass Rate:** 98.5% (194 passing)
- **Unit Tests:** 769 lines across 5 test files
- **Integration Tests:** 29 comprehensive tests
- **Infrastructure Tests:** 15 framework validation tests

## 📚 Documentation

- [README.md](README.md) - Quick start and usage guide
- [TESTING_GUIDE.md](docs/TESTING_GUIDE.md) - Comprehensive testing procedures
- [BUNDLE_ID_REFERENCE.md](docs/BUNDLE_ID_REFERENCE.md) - Bundle ID validation and reference
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development workflow
- [CHANGELOG.md](CHANGELOG.md) - Complete version history

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/[username]/layup.git
cd layup

# Make script executable
chmod +x layup.sh

# Run with sample input
./layup.sh examples/sample_apps.txt output.mobileconfig
```

## 🎯 Quick Start

```bash
# Create input file with Bundle IDs
cat > my_apps.txt << 'EOF'
com.apple.mobilesafari
com.apple.mobilemail
com.apple.mobilenotes
EOF

# Generate configuration profile
./layup.sh my_apps.txt my_layout.mobileconfig

# Deploy via your MDM platform
```

## 📋 System Requirements

- macOS 10.15+ (Catalina or later)
- Bash 3.2+ or Zsh
- Optional: xmllint for XML validation
- Optional: uuidgen for UUID generation

## 🐛 Known Limitations

- Single page layout only (multi-page support planned)
- No dock configuration (planned for future release)
- No folder support (planned for future release)

## 📝 Full Release Notes

See [CHANGELOG.md](CHANGELOG.md) for complete release notes.

## 🙏 Acknowledgments

Thank you to all contributors and testers who helped make this release possible!

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.
```

### Create GitHub Release

**Steps:**
1. [ ] Navigate to repository on GitHub
2. [ ] Click "Releases" in right sidebar
3. [ ] Click "Draft a new release"
4. [ ] Select tag: `v1.0.0`
5. [ ] Set release title: `v1.0.0 - First Production Release`
6. [ ] Paste release description (from template above)
7. [ ] Check "Set as the latest release"
8. [ ] **Do not** check "Set as a pre-release"
9. [ ] Click "Publish release"

### Attach Release Assets (Optional)

Consider attaching:
- [ ] Sample input files (zip archive)
- [ ] Expected output files (zip archive)
- [ ] Documentation PDF (if generated)

**Create archives:**
```bash
# Create sample files archive
cd examples
zip -r ../layup-v1.0.0-samples.zip *.txt expected_outputs/
cd ..

# Verify archive
unzip -l layup-v1.0.0-samples.zip
```

### Verify Release

- [ ] Release appears on GitHub repository
- [ ] Release is marked as "Latest"
- [ ] Tag is correctly linked
- [ ] Release notes are formatted correctly
- [ ] All links in release notes work
- [ ] Assets are attached (if applicable)

---

## Post-Release Validation

### Download and Test

**Simulate fresh installation:**
```bash
# Create temporary directory
mkdir -p /tmp/layup-test
cd /tmp/layup-test

# Clone from GitHub
git clone https://github.com/[username]/layup.git
cd layup

# Checkout release tag
git checkout v1.0.0

# Verify files
ls -la

# Make executable
chmod +x layup.sh

# Test with sample
./layup.sh examples/sample_apps.txt test_output.mobileconfig

# Verify output
xmllint --noout test_output.mobileconfig
```

- [ ] Repository clones successfully
- [ ] Tag checkout works
- [ ] All files are present
- [ ] Script executes correctly
- [ ] Output is valid

### Verify Documentation Links

- [ ] README.md links work
- [ ] CHANGELOG.md links work
- [ ] Documentation cross-references work
- [ ] GitHub release links work
- [ ] External links work (if any)

### Verify CI/CD Pipeline

- [ ] GitHub Actions workflow runs on tag push
- [ ] All CI tests pass
- [ ] No workflow errors
- [ ] Status badges are green (if applicable)

### Community Notification (Optional)

If applicable, announce release on:
- [ ] Project website
- [ ] Social media
- [ ] Mailing list
- [ ] Slack/Discord channels
- [ ] MDM community forums

### Update Project Status

- [ ] Update [`IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md) Phase 4 status to "Complete"
- [ ] Update project README with release badge
- [ ] Update any roadmap documents
- [ ] Close related GitHub issues/milestones

### Backup and Archive

- [ ] Create backup of release tag
- [ ] Archive release artifacts
- [ ] Document release process lessons learned
- [ ] Update release checklist for next release

---

## Rollback Procedure (If Needed)

If critical issues are discovered after release:

### Delete GitHub Release
1. Navigate to release on GitHub
2. Click "Delete" button
3. Confirm deletion

### Delete Git Tag
```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0
```

### Communicate Issue
- [ ] Post issue on GitHub
- [ ] Notify users via appropriate channels
- [ ] Document issue in CHANGELOG.md
- [ ] Plan hotfix release (v1.0.1)

---

## Next Steps After Release

### Immediate (Within 24 hours)
- [ ] Monitor for bug reports
- [ ] Respond to user questions
- [ ] Fix any critical issues discovered
- [ ] Update documentation if needed

### Short-term (Within 1 week)
- [ ] Gather user feedback
- [ ] Triage reported issues
- [ ] Plan patch release if needed (v1.0.1)
- [ ] Update FAQ based on questions

### Long-term (Within 1 month)
- [ ] Analyze usage patterns
- [ ] Prioritize feature requests
- [ ] Plan next minor release (v1.1.0)
- [ ] Update roadmap

---

## Release Sign-off

**Release Manager:** _________________  
**Date:** _________________  
**Signature:** _________________  

**QA Lead:** _________________  
**Date:** _________________  
**Signature:** _________________  

---

## Notes

Use this section to document any issues, deviations, or special circumstances during the release process:

```
[Add notes here]
```

---

**END OF RELEASE CHECKLIST**

For questions about this checklist, see [`CONTRIBUTING.md`](CONTRIBUTING.md) or open an issue on GitHub.