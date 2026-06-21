---
description: Full audit lifecycle — scoping, automated scanning, manual review, economic analysis, and report generation.
---

# /audit — Full Audit Lifecycle

Run the complete audit lifecycle on a Solana program.

## Usage
```
/audit [program-path] [--level 1|2|3|4] [--scope <instructions>]
```

## What It Does

1. **Phase 0: Scoping** — Threat model the program, define audit scope, agree on depth level.
2. **Phase 1: Automated Scanning** — Run cargo check, clippy, cargo-audit, cargo-deny, semgrep.
3. **Phase 2: Manual Deep Review** — Work through all 8 review domains systematically.
4. **Phase 3: Formal Verification** (Level 3+) — Specify and verify critical invariants.
5. **Phase 4: Economic Attack Simulation** (Level 2+) — Model flash loans, oracle manipulation, MEV.
6. **Phase 5: Report Generation** — Compile all findings into a professional audit report.

## Options

| Option | Description |
|---|---|
| `--level 1` | Quick Scan — automated tools only (~30 min) |
| `--level 2` | Standard Audit — automated + manual + economic (~2-4 hours) |
| `--level 3` | Deep Audit — full lifecycle + formal verification (~1-3 days) |
| `--level 4` | Full Formal — everything + complete Lean 4 proofs (~1-2 weeks) |
| `--scope <list>` | Comma-separated list of instructions to audit (default: all) |
| `--skip <phase>` | Skip a phase (0-5) |

## Agent Routing

- Phase 0 → `security-architect`
- Phase 1 → Direct tool execution
- Phase 2 → `vuln-hunter`
- Phase 3 → `formal-verifier`
- Phase 4 → `economic-analyst`
- Phase 5 → `audit-reporter`