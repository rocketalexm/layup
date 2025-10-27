# Branch Protection Rules

This document describes the recommended branch protection rules for the Layup project to ensure code quality and maintain a stable main branch.

## Overview

Branch protection rules enforce quality gates before code can be merged to the main branch. These rules help prevent bugs, maintain code quality, and ensure all changes are properly reviewed and tested.

## Recommended Protection Rules for `main` Branch

### 1. Require Pull Request Before Merging

**Setting:** ✅ Enabled

**Purpose:** Ensures all changes go through the pull request process, enabling code review and discussion.

**Configuration:**
- Require pull request reviews before merging
- Require at least **1 approval** from reviewers
- Dismiss stale pull request approvals when new commits are pushed
- Require review from Code Owners (optional, if CODEOWNERS file exists)

### 2. Require Status Checks to Pass

**Setting:** ✅ Enabled

**Purpose:** Ensures all automated tests pass before code can be merged.

**Required Status Checks:**
- `Run Bats Tests` - All unit and integration tests must pass
- `Integration Tests` - End-to-end integration tests must pass

**Configuration:**
- ✅ Require branches to be up to date before merging
- ✅ Require status checks to pass before merging

### 3. Require Conversation Resolution

**Setting:** ✅ Enabled (Recommended)

**Purpose:** Ensures all review comments and discussions are resolved before merging.

### 4. Require Linear History

**Setting:** ⚠️ Optional

**Purpose:** Maintains a clean, linear commit history by preventing merge commits.

**Options:**
- Use squash merging (recommended for feature branches)
- Use rebase merging
- Allow merge commits (not recommended)

### 5. Do Not Allow Bypassing Settings

**Setting:** ✅ Enabled

**Purpose:** Ensures even administrators must follow the protection rules.

**Configuration:**
- Do not allow bypassing the above settings
- Include administrators in these restrictions

### 6. Restrict Who Can Push

**Setting:** ✅ Enabled

**Purpose:** Prevents direct pushes to main branch.

**Configuration:**
- Restrict pushes that create matching branches
- Only allow pull requests to merge to main

## Setting Up Branch Protection on GitHub

### Step 1: Navigate to Repository Settings

1. Go to your repository on GitHub
2. Click **Settings** (top right)
3. Click **Branches** in the left sidebar

### Step 2: Add Branch Protection Rule

1. Click **Add rule** or **Add branch protection rule**
2. In **Branch name pattern**, enter: `main`

### Step 3: Configure Protection Rules

Enable the following settings:

#### Protect Matching Branches

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: **1**
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ⚠️ Require review from Code Owners (optional)
  - ⚠️ Restrict who can dismiss pull request reviews (optional)

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - Search and select required checks:
    - `test / Run Bats Tests`
    - `integration / Integration Tests`

- ✅ **Require conversation resolution before merging**

- ⚠️ **Require signed commits** (optional, for enhanced security)

- ✅ **Require linear history** (recommended)

- ✅ **Do not allow bypassing the above settings**
  - ✅ Include administrators

- ✅ **Restrict who can push to matching branches**
  - Leave empty to prevent all direct pushes

#### Rules Applied to Everyone

- ✅ **Allow force pushes** - ❌ Disabled
- ✅ **Allow deletions** - ❌ Disabled

### Step 4: Save Changes

1. Scroll to the bottom
2. Click **Create** or **Save changes**

## Workflow After Setup

### For Contributors

1. **Create a feature branch** from `main`:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/your-feature-name
   ```

2. **Make changes and commit**:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. **Push to remote**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create Pull Request**:
   - Go to GitHub repository
   - Click **Pull requests** → **New pull request**
   - Select your feature branch
   - Fill in PR template with description
   - Click **Create pull request**

5. **Wait for CI/CD checks**:
   - GitHub Actions will automatically run tests
   - All checks must pass (green checkmarks)
   - Fix any failing tests and push updates

6. **Request review**:
   - Request review from team members
   - Address any review comments
   - Make requested changes if needed

7. **Merge after approval**:
   - Once approved and all checks pass
   - Click **Squash and merge** (recommended)
   - Delete the feature branch after merge

### For Reviewers

1. **Review code changes**:
   - Check code quality and style
   - Verify tests are included
   - Ensure documentation is updated
   - Look for potential bugs or issues

2. **Check CI/CD status**:
   - Verify all tests pass
   - Review test coverage report
   - Check for any linting issues

3. **Provide feedback**:
   - Leave comments on specific lines
   - Request changes if needed
   - Approve when satisfied

4. **Approve PR**:
   - Click **Review changes**
   - Select **Approve**
   - Submit review

## CI/CD Integration

### Automated Checks

The GitHub Actions workflow (`.github/workflows/test.yml`) runs automatically on:

- **Push events** to:
  - `main` branch
  - `feature/**` branches
  - `bugfix/**` branches
  - `refactor/**` branches
  - `test/**` branches
  - `docs/**` branches

- **Pull request events** targeting:
  - `main` branch

### Test Coverage Reporting

The workflow provides detailed test statistics in the GitHub Actions summary:

- Total tests run
- Tests passed/failed
- Success rate percentage
- ShellCheck linting results (non-blocking)

### Status Badges

Add status badges to your README.md to show build status:

```markdown
[![Test Suite](https://github.com/[username]/layup/actions/workflows/test.yml/badge.svg)](https://github.com/[username]/layup/actions/workflows/test.yml)
```

Replace `[username]` with your GitHub username or organization name.

## Troubleshooting

### Issue: Cannot merge PR - checks not passing

**Solution:**
1. Review the failed check in the Actions tab
2. Fix the issue in your feature branch
3. Push the fix - checks will run automatically
4. Wait for all checks to pass

### Issue: Cannot merge PR - no approval

**Solution:**
1. Request review from team members
2. Address any review comments
3. Wait for approval
4. Merge once approved

### Issue: Branch is out of date

**Solution:**
```bash
# Update your feature branch with latest main
git checkout feature/your-feature
git fetch origin
git rebase origin/main
git push --force-with-lease origin feature/your-feature
```

### Issue: Accidentally pushed to main

**Solution:**
- If branch protection is properly configured, this should be prevented
- If it happens, contact repository administrator
- May need to revert the commit and create a proper PR

## Best Practices

### Commit Messages

Follow conventional commit format:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `chore`: Maintenance tasks

**Example:**
```
feat(validation): add Bundle ID regex validation

Implements regex pattern matching for Bundle ID format validation.
Validates minimum 2 segments and allowed characters.

Closes #12
```

### Pull Request Guidelines

1. **Keep PRs focused**: One feature or fix per PR
2. **Write clear descriptions**: Explain what and why
3. **Include tests**: All new code should have tests
4. **Update documentation**: Keep docs in sync with code
5. **Reference issues**: Link to related issues
6. **Keep PRs small**: Easier to review and merge

### Code Review Guidelines

1. **Be constructive**: Provide helpful feedback
2. **Be timely**: Review PRs within 24-48 hours
3. **Test locally**: Run tests on your machine
4. **Check documentation**: Ensure docs are updated
5. **Approve or request changes**: Don't leave PRs hanging

## Security Considerations

### Signed Commits (Optional)

For enhanced security, you can require signed commits:

1. Set up GPG key signing locally
2. Enable "Require signed commits" in branch protection
3. All commits must be signed with verified GPG key

### Code Scanning (Optional)

Enable GitHub's code scanning for additional security:

1. Go to **Security** → **Code scanning**
2. Set up **CodeQL analysis**
3. Configure scanning for pull requests

## Maintenance

### Regular Reviews

Periodically review and update branch protection rules:

- **Quarterly**: Review effectiveness of current rules
- **After incidents**: Adjust rules if issues occur
- **Team growth**: Update reviewer requirements
- **Tool updates**: Adjust for new CI/CD tools

### Documentation Updates

Keep this document updated when:

- Branch protection rules change
- New CI/CD checks are added
- Workflow processes change
- Team structure changes

## Additional Resources

- [GitHub Branch Protection Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Code Review Best Practices](https://google.github.io/eng-practices/review/)

## Support

For questions or issues with branch protection:

1. Check this documentation
2. Review GitHub's official documentation
3. Contact repository administrators
4. Create an issue in the repository

---

**Last Updated:** October 2025  
**Version:** 1.0  
**Maintained By:** Development Team