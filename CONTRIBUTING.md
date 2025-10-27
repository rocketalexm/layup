# Contributing to Layup

Thank you for your interest in contributing to Layup! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Development Workflow](#development-workflow)
3. [Branch Strategy](#branch-strategy)
4. [Test-Driven Development](#test-driven-development)
5. [Commit Message Convention](#commit-message-convention)
6. [Pull Request Process](#pull-request-process)
7. [Quality Gates](#quality-gates)
8. [Code Review Checklist](#code-review-checklist)
9. [Testing Guidelines](#testing-guidelines)
10. [Getting Help](#getting-help)

## Code of Conduct

This project follows a professional and respectful code of conduct:

- Be respectful and inclusive
- Focus on constructive feedback
- Accept criticism gracefully
- Prioritize project goals over personal preferences
- Help others learn and grow

## Development Workflow

Layup follows a strict **Test-Driven Development (TDD)** workflow using the **London School** approach.

### Prerequisites

Before contributing, ensure you have:

- macOS 10.15+ or Linux with Bash 3.2+
- Git installed and configured
- Bats testing framework installed
- Basic understanding of shell scripting
- Familiarity with TDD principles

### Setting Up Your Development Environment

1. **Fork and Clone the Repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/layup.git
   cd layup
   ```

2. **Install Bats (if not already installed)**
   ```bash
   # macOS
   brew install bats-core
   
   # Linux
   git clone https://github.com/bats-core/bats-core.git /tmp/bats-core
   cd /tmp/bats-core
   sudo ./install.sh /usr/local
   ```

3. **Verify Installation**
   ```bash
   bats --version
   ```

4. **Run Existing Tests**
   ```bash
   bats tests/
   ```

## Branch Strategy

### Branch Naming Convention

Use descriptive branch names following this pattern:

- `feature/<feature-name>` - New functionality
- `bugfix/<bug-description>` - Bug fixes
- `refactor/<refactor-description>` - Code improvements
- `test/<test-description>` - Test additions/improvements
- `docs/<doc-description>` - Documentation updates

**Examples:**
```bash
feature/bundle-id-validation
bugfix/xml-escaping-ampersand
refactor/improve-error-messages
test/add-edge-case-tests
docs/update-readme-examples
```

### Branch Lifecycle

1. **Create Feature Branch from `main`**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature-name
   ```

2. **Develop with TDD** (see [Test-Driven Development](#test-driven-development))

3. **Commit Frequently** with clear messages

4. **Push to Remote** for backup
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request** when ready

6. **Code Review** + all tests pass

7. **Merge to `main`** (squash or merge commit)

8. **Delete Feature Branch**
   ```bash
   git branch -d feature/your-feature-name
   git push origin --delete feature/your-feature-name
   ```

9. **Run Tests on `main`** to verify integration

## Test-Driven Development

Layup follows the **London School TDD** approach with strict adherence to the Red-Green-Refactor cycle.

### The Red-Green-Refactor Cycle

#### 1. RED: Write a Failing Test

Write a test that defines the desired behavior BEFORE implementing the feature.

```bash
# tests/test_bundle_id_validation.bats
@test "validate_bundle_id accepts valid two-segment Bundle ID" {
    # Arrange: Set up test data
    local bundle_id="com.apple"
    
    # Act: Execute function
    run validate_bundle_id "$bundle_id"
    
    # Assert: Verify behavior
    assert_success
}
```

**Run the test** - it should FAIL because the function doesn't exist yet:
```bash
bats tests/test_bundle_id_validation.bats
```

#### 2. GREEN: Make the Test Pass

Write the **minimum code** necessary to make the test pass.

```bash
# layup.sh
validate_bundle_id() {
    local bundle_id="$1"
    local pattern='^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$'
    
    if [[ $bundle_id =~ $pattern ]]; then
        return 0
    else
        return 1
    fi
}
```

**Run the test** - it should now PASS:
```bash
bats tests/test_bundle_id_validation.bats
```

#### 3. REFACTOR: Improve Code Quality

Improve the code while keeping tests green.

```bash
# layup.sh
validate_bundle_id() {
    local bundle_id="$1"
    local -r BUNDLE_ID_PATTERN='^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$'
    
    [[ $bundle_id =~ $BUNDLE_ID_PATTERN ]]
}
```

**Run tests again** - they should still PASS:
```bash
bats tests/test_bundle_id_validation.bats
```

### London School TDD Principles

**Key Characteristics:**

1. **Mock External Dependencies**
   - File system operations (`cat`, `read`, `test -f`)
   - External commands (`uuidgen`, `date`, `xmllint`, `open`)
   - User input (`read` for prompts)

2. **Test Behavior, Not Implementation**
   - Focus on what a component does
   - Verify interactions between components
   - Don't test internal implementation details

3. **Use Test Doubles**
   - Mocks: Verify interactions
   - Stubs: Provide canned responses
   - Spies: Track function calls

**Example with Mocking:**
```bash
@test "generate_xml calls uuidgen twice for two UUIDs" {
    # Arrange: Mock external command
    mock_command "uuidgen" "test-uuid-1234"
    local bundle_ids=("com.apple.safari" "com.apple.mail")
    
    # Act
    run generate_xml "${bundle_ids[@]}"
    
    # Assert: Verify behavior and interactions
    assert_success
    assert_output --partial "test-uuid-1234"
    assert_mock_called "uuidgen" 2
}
```

## Commit Message Convention

Follow the **Conventional Commits** specification for clear, semantic commit messages.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `test`: Adding or updating tests
- `refactor`: Code refactoring (no behavior change)
- `docs`: Documentation changes
- `chore`: Maintenance tasks (dependencies, build, etc.)
- `style`: Code style changes (formatting, no logic change)
- `perf`: Performance improvements

### Examples

```
feat(validation): add Bundle ID regex validation

Implements regex pattern matching for Bundle ID format validation.
Validates minimum 2 segments and allowed characters.

Closes #12
```

```
test(xml): add XML escaping tests

Adds tests for special character escaping in XML generation.
Covers &, <, >, ", ' characters.
```

```
fix(output): handle write permission errors gracefully

Checks directory write permissions before attempting file write.
Provides clear error message with actionable suggestion.

Fixes #45
```

### Commit Best Practices

- Write clear, descriptive commit messages
- Keep commits atomic (one logical change per commit)
- Reference issues/PRs when applicable
- Use present tense ("add feature" not "added feature")
- Keep subject line under 72 characters
- Provide context in the body for complex changes

## Pull Request Process

### Before Creating a PR

**Self-Review Checklist:**

- [ ] All tests pass locally (`bats tests/`)
- [ ] Code follows project style and conventions
- [ ] No debug code or commented-out code
- [ ] Documentation updated (if needed)
- [ ] CHANGELOG.md updated (if user-facing change)
- [ ] Commit messages follow convention
- [ ] Branch is up to date with `main`

### Creating a Pull Request

1. **Push Your Branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub**
   - Use a clear, descriptive title following commit convention
   - Provide detailed description of changes
   - Reference related issues (e.g., "Closes #123")
   - List any breaking changes
   - Note any special testing requirements

3. **PR Template**
   ```markdown
   ## Description
   Brief description of what this PR does and why.
   
   ## Related Issues
   Closes #123
   
   ## Changes Made
   - Added feature X
   - Fixed bug Y
   - Updated documentation Z
   
   ## Testing
   - [ ] All existing tests pass
   - [ ] New tests added for new functionality
   - [ ] Manual testing completed
   
   ## Breaking Changes
   None / List any breaking changes
   
   ## Additional Notes
   Any additional context or notes for reviewers
   ```

### During Code Review

- Respond to feedback promptly and professionally
- Make requested changes in new commits (don't force-push)
- Re-request review after addressing feedback
- Discuss disagreements constructively

### After Approval

- Ensure all CI checks pass
- Squash commits if requested
- Merge using GitHub UI
- Delete feature branch after merge

## Quality Gates

**NO CODE SHIPS TO MAIN WITHOUT:**

### Required Quality Gates

1. ✅ **Code Review Approval**
   - At least one reviewer must approve
   - All review comments addressed

2. ✅ **All Tests Passing**
   - 100% of test suite must pass
   - Tests run on feature branch

3. ✅ **Post-Merge Validation**
   - Tests must run and pass on `main` after merge
   - CI pipeline must succeed

### Additional Quality Checks

- [ ] No linter errors (ShellCheck if available)
- [ ] All functions have corresponding tests
- [ ] Documentation updated for new features
- [ ] CHANGELOG.md updated
- [ ] No hardcoded values (use constants)
- [ ] Error messages are clear and actionable

## Code Review Checklist

### For Reviewers

**Code Quality:**
- [ ] Code follows bash best practices
- [ ] Variables are properly quoted
- [ ] Functions have clear, single responsibilities
- [ ] No hardcoded values (use constants)
- [ ] Error handling is comprehensive
- [ ] Exit codes are used correctly

**Testing:**
- [ ] All new code has corresponding tests
- [ ] Tests follow London School TDD principles
- [ ] Mocks are used appropriately
- [ ] Tests are clear and well-named
- [ ] Edge cases are covered
- [ ] All tests pass locally

**Documentation:**
- [ ] Code comments explain "why", not "what"
- [ ] Complex logic is documented
- [ ] README updated if user-facing changes
- [ ] CHANGELOG.md updated
- [ ] Function signatures are clear

**Security:**
- [ ] No code injection vulnerabilities
- [ ] User input is validated
- [ ] File paths are sanitized
- [ ] XML special characters are escaped
- [ ] No secrets or credentials in code

**Compliance:**
- [ ] Follows data schema in IMPLEMENTATION_PLAN.md
- [ ] Adheres to Apple MDM Protocol specification
- [ ] Exit codes match documented schema
- [ ] Error messages follow defined format

**Git Hygiene:**
- [ ] Commit messages follow convention
- [ ] Branch name follows convention
- [ ] No merge conflicts
- [ ] Commits are logical and atomic

### For Authors (Self-Review)

Before requesting review:

- [ ] All tests pass locally
- [ ] Code is self-reviewed
- [ ] No debug code or console.log statements
- [ ] No commented-out code
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] PR description is complete

## Testing Guidelines

### Test Structure

Follow the **Arrange-Act-Assert** pattern:

```bash
@test "descriptive test name" {
    # Arrange: Set up mocks and test data
    mock_command "uuidgen" "12345678-1234-1234-1234-123456789012"
    local input="test data"
    
    # Act: Execute the function under test
    run function_under_test "$input"
    
    # Assert: Verify behavior and interactions
    assert_success
    assert_output "expected output"
    assert_mock_called "uuidgen" 1
}
```

### Test Categories

1. **Unit Tests** - Test individual functions in isolation
2. **Integration Tests** - Test component interactions
3. **Edge Case Tests** - Test boundary conditions and error handling

### Test Coverage Goals

| Component | Target Coverage | Priority |
|-----------|----------------|----------|
| Bundle ID Validation | 100% | Critical |
| XML Generation | 100% | Critical |
| File I/O | 100% | Critical |
| Error Handling | 100% | Critical |
| Argument Parsing | 100% | High |
| User Feedback | 90% | Medium |

### Running Tests

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/test_bundle_id_validation.bats

# Run with verbose output
bats --verbose-run tests/

# Run with timing information
bats --timing tests/
```

## Getting Help

### Resources

- **Implementation Plan**: [`IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md)
- **Product Requirements**: [`Layup_PRD-2.md`](Layup_PRD-2.md)
- **Architecture Plan**: [`Software_Architecture_Plan.md`](Software_Architecture_Plan.md)
- **Bats Documentation**: https://bats-core.readthedocs.io/

### Asking Questions

- **GitHub Issues**: For bugs, feature requests, and general questions
- **Pull Request Comments**: For questions about specific code changes
- **Discussions**: For broader architectural or design questions

### Reporting Bugs

When reporting bugs, please include:

1. **Description**: Clear description of the issue
2. **Steps to Reproduce**: Detailed steps to reproduce the bug
3. **Expected Behavior**: What you expected to happen
4. **Actual Behavior**: What actually happened
5. **Environment**: macOS version, bash version, etc.
6. **Logs/Output**: Relevant error messages or output

### Suggesting Features

When suggesting features, please include:

1. **Use Case**: Why is this feature needed?
2. **Proposed Solution**: How should it work?
3. **Alternatives**: Other approaches considered
4. **Impact**: Who would benefit from this feature?

## Thank You!

Thank you for contributing to Layup! Your efforts help make this project better for everyone.

---

**Questions?** Open an issue or start a discussion on GitHub.