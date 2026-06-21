---
description: Manual deep review of Solana program code across all 8 security domains.
---

# /deep-review — Manual Deep Code Review

Perform a systematic manual review of Solana program code.

## Usage
```
/deep-review [program-path] [--domain 1-8] [--instruction <name>]
```

## What It Does

Walks through all 8 manual review domains:
1. Access Control
2. Arithmetic Safety
3. Account Validation
4. CPI Safety
5. State Machine Integrity
6. Token Program Interactions
7. Cross-Program Invocation
8. Upgradeability & Deployment

## Options

| Option | Description |
|---|---|
| `--domain 1-8` | Review only a specific domain |
| `--domain all` | Review all domains (default) |
| `--instruction <name>` | Review only a specific instruction |

## Agent Routing

Uses `vuln-hunter` agent for deep code analysis.