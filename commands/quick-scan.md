---
description: Fast automated security scan — compilation, linting, dependency audit, and pattern matching.
---

# /quick-scan — Fast Automated Security Scan

Run automated security tools on a Solana program. No manual review.

## Usage
```
/quick-scan [program-path]
```

## What It Does

1. `anchor build` / `cargo build-sbf` — Compilation check
2. `cargo clippy` — Rust linting with security-focused lints
3. `cargo audit` — Known vulnerability check in dependencies
4. `cargo deny` — Supply chain security (licenses, bans, sources)
5. `semgrep` — Pattern-based vulnerability detection

## Output

A summary of all automated findings with severity classification and remediation suggestions.

## When to Use

- Pre-commit security check
- Quick assessment of a new codebase
- CI/CD pipeline integration
- Before engaging a professional audit firm