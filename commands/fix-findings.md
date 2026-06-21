---
description: Track and verify fixes for audit findings.
---

# /fix-findings — Remediation Tracking

Track and verify fixes for audit findings.

## Usage
```
/fix-findings [--finding F-XXX] [--verify] [--dashboard]
```

## What It Does

1. Converts findings into trackable issues
2. Prioritizes fixes by severity and effort
3. Guides fix implementation with code examples
4. Verifies fixes (re-run scans, check regressions)
5. Maintains remediation dashboard

## Options

| Option | Description |
|---|---|
| `--finding F-XXX` | Work on a specific finding |
| `--verify` | Verify all implemented fixes |
| `--dashboard` | Show remediation progress dashboard |
| `--all` | Process all findings |

## Agent Routing

Uses `audit-reporter` agent for tracking, `vuln-hunter` for fix verification.