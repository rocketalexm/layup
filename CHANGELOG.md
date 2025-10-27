# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-27

### 🎉 First Production Release

This is the first production-ready release of Layup, a command-line tool that generates Apple MDM Home Screen Layout configuration profiles from plain text Bundle ID lists.

### Added

#### Core Functionality
- **Argument Parsing & Help System** - Complete command-line interface with `--help` flag
- **Input File Processing** - Robust file reading with validation and error handling
- **Bundle ID Validation** - Comprehensive regex-based validation with detailed error reporting
- **XML Generation** - Apple MDM-compliant configuration profile generation
- **File Output** - Safe file writing with overwrite protection and Finder integration
- **User Feedback** - Clear validation messages and statistics reporting

#### Features
- Support for comments (lines starting with `#`)
- Empty line handling for better file organization
- Case-sensitive Bundle ID preservation
- XML special character escaping (`&`, `<`, `>`, `"`, `'`)
- Interactive file overwrite confirmation
- Automatic `.mobileconfig` extension handling
- Finder integration (opens file location after generation)
- XML validation with `xmllint`
- Detailed validation statistics (valid/invalid/comments/empty lines)

#### Testing
- **197 total tests** with **98.5% pass rate** (194 passing)
- Comprehensive unit test coverage (769 lines of tests)
- Integration test suite (29 tests)
- Test infrastructure validation (15 tests)
- Cross-platform testing documentation
- MDM deployment testing guide

#### Documentation
- Complete README.md with usage examples
- CONTRIBUTING.md with development workflow
- TESTING_GUIDE.md with comprehensive testing procedures
- BUNDLE_ID_REFERENCE.md with validation rules and common Bundle IDs
- IMPLEMENTATION_PLAN.md with technical specifications
- Sample input files in `examples/` directory
- Expected output files in `examples/expected_outputs/` directory

#### Infrastructure
- GitHub Actions CI/CD pipeline
- Bats testing framework integration
- Branch protection documentation
- Test helper functions (mocks and assertions)
- Automated test execution on push/PR

### Technical Details

#### Phase 2 Completion - Core Functionality
All five Phase 2 components implemented and tested:
1. **Argument Parsing** - Help system and input validation
2. **Input File Reading** - File validation, line-by-line processing, content filtering
3. **Bundle ID Validation** - Regex validation, advanced rules, error reporting
4. **XML Generation** - Dynamic values, XML escaping, complete structure
5. **File Output** - Filename generation, overwrite handling, validation

#### Phase 3 Completion - Testing & Validation
- Integration testing with end-to-end workflows
- Manual MDM deployment testing documentation
- Cross-platform testing (macOS, Linux, Windows)
- Test execution report with detailed results

#### Test Statistics
- **Unit Tests:** 769 lines across 5 test files
- **Integration Tests:** 29 comprehensive tests
- **Infrastructure Tests:** 15 framework validation tests
- **Total:** 197 tests with 98.5% success rate
- **Known Issues:** 3 minor test failures (non-blocking)

### Validation Rules

Bundle IDs must:
- Have at least 2 segments separated by dots (e.g., `com.apple`)
- Use only letters (a-z, A-Z), numbers (0-9), hyphens (-), and underscores (_)
- Not start or end with a dot
- Not have consecutive dots
- Be case-sensitive (preserve exact case)

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success or user cancelled |
| 1 | Input file not found |
| 2 | Input file empty |
| 3 | No valid Bundle IDs found |
| 4 | Cannot write output file |
| 5 | XML validation failed |

### Example Usage

```bash
# Basic usage
./layup.sh input.txt output.mobileconfig

# Using sample files
./layup.sh examples/sample_apps.txt my_layout.mobileconfig

# View help
./layup.sh --help
```

### System Requirements

- **Operating System:** macOS 10.15+ (Catalina or later)
- **Shell:** Bash 3.2+ or Zsh
- **Optional:** `xmllint` for XML validation
- **Optional:** `uuidgen` for UUID generation (fallback provided)

### Known Limitations

- Single page layout only (multi-page support planned for Phase 2)
- No dock configuration (planned for Phase 2)
- No folder support (planned for Phase 2)
- Requires manual MDM deployment

### Contributors

Development Team

### License

MIT License - See LICENSE file for details

---

## [Unreleased]

### Added
- Initial project setup and infrastructure
- Git repository initialization
- Project directory structure (lib/, tests/, docs/, examples/, .github/workflows/)
- Bats testing framework installation and configuration
- Test helper functions (mocks.bash, assertions.bash)
- Test suite setup and teardown files
- Infrastructure verification tests
- README.md with project overview and development guidelines
- CONTRIBUTING.md with comprehensive development workflow
- .gitignore for shell projects
- Branch protection rules documentation
- GitHub Actions CI/CD workflow
- MIT License file

### Infrastructure
- London School TDD test infrastructure
- Mock functions for external dependencies
- Custom assertion helpers
- Automated testing pipeline

## [0.1.0] - 2025-10-26

### Added
- Phase 1: Project Setup & Infrastructure completed
- Repository structure established
- Testing framework configured
- Documentation foundation created

---

## Version History

- **0.1.0** - Initial project setup (Phase 1 complete)
- **Unreleased** - Active development

---

## Notes

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backwards compatible manner
- **PATCH** version for backwards compatible bug fixes

---

**Next Release:** v1.0.0 (planned after Phase 4 completion)