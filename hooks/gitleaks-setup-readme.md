# Git Secret Scanning with Gitleaks

This document explains how the software factory uses Gitleaks to help prevent
secrets from entering the Git repository.

## What Gitleaks does

Gitleaks scans Git content for patterns that may contain secrets.

It can detect many common secret types, including:

- API keys
- Access tokens
- Cloud credentials
- Private keys
- Database credentials
- Service-account tokens

Gitleaks is one security control. It does not replace secure secret storage,
access control, CI checks, or secure application design.

No secret scanner can detect every possible secret.

## Factory design

The factory uses three layers:

```text
Security policy
    ↓
Pre-commit hook
    ↓
Gitleaks
    ↓
ALLOW / BLOCK
```

The security policy defines the requirement.

The hook enforces the requirement before a commit.

Gitleaks performs the secret scan.

A later GitHub Actions check should provide remote protection because local
hooks can be bypassed.

## Prerequisites

This setup assumes macOS with Homebrew.

Check Homebrew:

```bash
brew --version
```

## Install Gitleaks

Install:

```bash
brew install gitleaks
```

Verify:

```bash
gitleaks version
```

Record the installed version when validating the factory.

Example:

```text
8.30.1
```

## Initial repository scan

Before enabling the hook, scan the repository:

```bash
cd ~/software-factory
gitleaks git .
```

A clean result should report:

```text
no leaks found
```

This creates a baseline.

A clean baseline does not guarantee that future commits are safe.

## Gitleaks configuration

Create:

```text
~/software-factory/.gitleaks.toml
```

Start with:

```toml
title = "Software Factory Gitleaks Configuration"

[extend]
useDefault = true
```

This uses Gitleaks' default detector set.

Do not create a large custom ruleset unless the factory has a real secret
format that the default rules do not detect.

## Custom rules

Add a custom rule only for a real factory or project secret format that the
default rules do not detect.

Example:

```toml
[[rules]]
id = "factory-example-secret"
description = "Factory-specific secret pattern"
regex = '''FACTORY_EXAMPLE_[A-Za-z0-9]+'''
secretGroup = 0
```

Custom rules should be:

- Needed for a real format.
- Narrow enough to avoid unnecessary false positives.
- Tested with positive and negative examples.
- Versioned with the repository.

Do not add custom rules only to make an artificial test pass.

## Pre-commit hook

Store the Git hook in:

```text
~/software-factory/hooks/pre-commit
```

Recommended content:

```bash
#!/bin/bash
set -euo pipefail

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "ERROR: gitleaks is not installed or is not in PATH." >&2
  exit 1
fi

echo "Running Gitleaks on staged changes..." >&2
gitleaks protect --staged --redact

echo "Secret scan passed. Commit may continue." >&2
```

The hook scans staged changes only.

## Configure Git to use the factory hook

From the repository:

```bash
cd ~/software-factory
git config core.hooksPath hooks
```

Verify:

```bash
git config --get core.hooksPath
```

Expected:

```text
hooks
```

Make the hook executable:

```bash
chmod +x hooks/pre-commit
```

Verify:

```bash
ls -l hooks/pre-commit
```

The hook must have execute permission.

## Test the hook

The test must verify the complete path:

```text
git commit
    ↓
hooks/pre-commit
    ↓
Gitleaks
    ↓
ALLOW / BLOCK
```

### Clean commit test

Create a harmless change:

```bash
echo "# hook test" >> test-hook.md
git add test-hook.md
git commit -m "test: verify pre-commit hook"
```

Expected:

```text
Running Gitleaks on staged changes...
no leaks found
Secret scan passed. Commit may continue.
```

The commit should succeed.

Remove the test file:

```bash
git rm test-hook.md
git commit -m "chore: remove hook test"
```

Do not push test commits.

### Blocking test

Do not use a real credential.

For a deterministic hook test, use a temporary test rule:

```toml
[[rules]]
id = "factory-test-secret"
description = "Test rule for the pre-commit hook"
regex = '''FACTORY_TEST_SECRET_[A-Za-z0-9]+'''
secretGroup = 0
```

Then:

```bash
echo 'FACTORY_TEST_SECRET_ABC123' > secret-test.txt
git add secret-test.txt
git commit -m "test: verify secret blocking"
```

Expected:

```text
leaks found: 1
```

and the commit must fail.

Remove the test data:

```bash
git reset secret-test.txt
rm secret-test.txt
```

Remove the temporary test rule from the permanent `.gitleaks.toml`.

This test proves that the Git hook can block a configured finding.

## Default rules vs test rules

These are different checks:

```text
Default configuration
→ tests the real Gitleaks rules used by the factory.

Temporary test rule
→ proves that the pre-commit enforcement path blocks a known match.
```

Do not assume that an arbitrary fake token will match a default Gitleaks
detector.

For a default-rule test, use a documented detector-supported fixture.

## Never use real credentials

Never use a real credential for testing.

A real credential may grant access to a service.

A secret placed in Git may remain in:

- Git history
- Reflogs
- Remote repositories
- CI logs
- Backups
- Caches

Use safe test fixtures.

## If a real secret is detected

Do not only delete the line.

Use:

```text
Stop
 ↓
Do not expose the secret
 ↓
Remove it from the pending change
 ↓
Determine whether it was previously committed or exposed
 ↓
Rotate or revoke it when required
 ↓
Verify the repository again
```

Treat an exposed credential as potentially compromised until verified
otherwise.

## If a secret is already in Git history

Deleting the file from the latest commit may not be enough.

If a real credential was committed:

1. Treat it as exposed.
2. Rotate or revoke it.
3. Determine whether history must be rewritten.
4. Follow the Git safety policy before rewriting published history.
5. Scan repository history again.

Never expose the credential during investigation.

## Troubleshooting

### Gitleaks is not installed

Run:

```bash
brew install gitleaks
```

Then:

```bash
gitleaks version
```

### Hook does not run

Check:

```bash
git config --get core.hooksPath
```

Expected:

```text
hooks
```

Then:

```bash
ls -l hooks/pre-commit
```

Make it executable:

```bash
chmod +x hooks/pre-commit
```

### Gitleaks reports zero commits

This can be normal for:

```bash
gitleaks protect --staged
```

That command scans staged content before the commit.

It is different from:

```bash
gitleaks git .
```

which scans repository Git history.

### Gitleaks reports no leaks

Check that the content is staged:

```bash
git status
git diff --cached
```

Then confirm that the value matches a configured detector.

Do not keep adding random regexes to the configuration.

### False positive

If a finding is not a secret:

1. Confirm the value is safe.
2. Identify why the rule matched.
3. Use the approved Gitleaks configuration mechanism if an exception is
   justified.
4. Do not disable the hook globally.

## Reproducibility

Version these files in the factory repository:

```text
.gitleaks.toml
hooks/pre-commit
```

The Git setting:

```bash
git config core.hooksPath hooks
```

is local repository configuration.

A clone does not automatically copy this setting.

The factory setup or bootstrap process should configure it for each new
installation.

## CI protection

A local hook is not sufficient.

Hooks can be bypassed.

The factory should also run secret scanning in GitHub Actions.

Target design:

```text
Local commit
    ↓
pre-commit
    ↓
Gitleaks
    ↓
GitHub Actions
    ↓
Gitleaks + other verification
```

This provides local and remote protection.

## Relationship to factory policies

Responsibilities are:

```text
policies/security.md
→ security requirements

.gitleaks.toml
→ Gitleaks detection configuration

hooks/pre-commit
→ local enforcement

policies/verification.md
→ verification and evidence rules

GitHub Actions
→ remote enforcement
```

Keep each concern separate.

Do not put the full security policy inside the hook.

Do not put workflow logic inside `.gitleaks.toml`.

## Maintenance

When upgrading Gitleaks:

1. Check the new version.
2. Review relevant configuration changes.
3. Run the repository baseline scan.
4. Test a clean commit.
5. Test a known positive finding.
6. Check for unexpected false positives.

Do not change the security configuration only to hide a finding.

## Completion checklist

- [ ] Gitleaks is installed.
- [ ] `gitleaks version` works.
- [ ] Initial repository scan completed.
- [ ] `.gitleaks.toml` uses the default rules.
- [ ] `hooks/pre-commit` exists.
- [ ] `hooks/pre-commit` is executable.
- [ ] `core.hooksPath` is set to `hooks`.
- [ ] Clean commit test passed.
- [ ] A known matching secret was blocked by the actual hook.
- [ ] Test files were removed.
- [ ] Test-only rules were removed.
- [ ] No real credentials were used.
- [ ] Factory files are ready for version control.
