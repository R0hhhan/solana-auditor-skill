# Solana Auditor Skill

A Claude Code skill for full-lifecycle Solana program security auditing. Covers the complete audit workflow — scoping, automated scanning, manual deep review, formal verification, economic attack simulation, report generation, and remediation tracking.

> **Technical security analysis tool.** This skill provides automated and manual security analysis. It is not a replacement for a professional audit firm. Critical programs handling significant TVL should always engage a reputable audit firm for a final review.

## What This Skill Does

| User Says | What Happens |
|---|---|
| "Audit my Anchor program" | Full lifecycle: scoping → automated scan → manual review → economic analysis → report |
| "Check for reentrancy" | Targeted manual review of CPI safety (Domain 4) |
| "Find missing signer checks" | Access control audit (Domain 1) with automated + manual review |
| "Is my tokenomics exploitable?" | Economic attack simulation: flash loans, oracle manipulation, MEV |
| "Prove this invariant" | Formal verification: invariant specification + bounded model checking |
| "Generate an audit report" | Professional report with executive summary, findings, remediation roadmap |
| "Help me fix these findings" | Remediation tracking with fix verification and regression checks |

## What This Skill Does NOT Do

- Replace a professional audit firm for high-TVL programs
- Deploy or upgrade programs on-chain
- Sign transactions or manage keys
- Provide legal or compliance advice (route to `crypto-legal-skill`)
- Guarantee bug-free code

## Quick Start

### Option 1: One-liner Installer

```bash
curl -fsSL https://raw.githubusercontent.com/solanabr/solana-auditor-skill/main/install.sh | bash
```

### Option 2: Manual Install

```bash
git clone https://github.com/solanabr/solana-auditor-skill.git
cd solana-auditor-skill
./install.sh
```

### Option 3: Custom Install

```bash
./install.sh --target ~/.claude/skills/  # Personal install
./install.sh --target ./.claude/skills/   # Project install
./install.sh --agents                     # Install to .agents/ (Codex, Cursor, etc.)
```

## Usage in Claude Code

After installation, invoke any of:

```
/audit                    # Full audit lifecycle
/quick-scan               # Fast automated scan
/deep-review              # Manual deep review (8 domains)
/threat-model             # Threat modeling session
/economic-sim             # Economic attack simulation
/audit-report             # Generate audit report
/fix-findings             # Remediation tracking
```

Or just describe what you need in natural language — the skill activates on triggers like "audit my program", "security review", "find vulnerabilities", "check my access control", etc.

## Audit Lifecycle

```
Phase 0: Scoping ──────► Threat model, define scope, agree on depth
Phase 1: Automated ─────► cargo check, clippy, cargo-audit, semgrep, fuzzing
Phase 2: Manual Review ─► 8 domains: access control, arithmetic, accounts, CPI, etc.
Phase 3: Formal Verify ─► Invariants, bounded model checking, Lean 4 proofs
Phase 4: Economic ──────► Flash loans, oracle manipulation, MEV, governance
Phase 5: Report ────────► Professional audit report with findings & remediation
Phase 6: Remediation ───► Fix tracking, verification, regression checks
```

## What's Included

### Skills (Progressive Loading)
| File | Phase | Description |
|---|---|---|
| `SKILL.md` | Entry | Routes to all phases |
| `scoping.md` | 0 | Threat modeling, scope definition |
| `automated-scanning.md` | 1 | Tool configuration & execution |
| `manual-review.md` | 2 | 8-domain deep review checklists |
| `formal-verification.md` | 3 | Lean 4 proofs, invariants |
| `economic-attacks.md` | 4 | Flash loans, MEV, oracle manipulation |
| `reporting.md` | 5 | Report templates & generation |
| `remediation.md` | 6 | Fix tracking & verification |
| `vuln-database.md` | Ref | 12 known Solana vulnerability patterns |
| `tool-reference.md` | Ref | Tool-specific quick-reference cards |
| `resources.md` | Ref | Curated security resources |

### Agents
| Agent | Model | Role |
|---|---|---|
| `security-architect` | opus | Threat modeling, attack surface analysis |
| `vuln-hunter` | opus | Deep code review, vulnerability discovery |
| `formal-verifier` | opus | Invariant specification, Lean 4 proofs |
| `economic-analyst` | sonnet | Economic attack simulation |
| `audit-reporter` | sonnet | Report generation, remediation tracking |

### Commands
| Command | Description |
|---|---|
| `/audit` | Full audit lifecycle |
| `/quick-scan` | Fast automated scan |
| `/deep-review` | Manual deep review |
| `/threat-model` | Threat modeling session |
| `/economic-sim` | Economic attack simulation |
| `/audit-report` | Generate audit report |
| `/fix-findings` | Remediation tracking |

### Rules (Auto-Loading)
| Rule | Applies To | Description |
|---|---|---|
| `rust-security.md` | `.rs` files | 10 critical Rust security rules |
| `anchor-security.md` | Anchor programs | 10 critical Anchor security rules |

## Integration with Solana AI Kit

This skill is designed to slot into the [Solana AI Kit](https://github.com/solanabr/solana-ai-kit) as a submodule. It routes to the kit's bundled security sub-skills at the right phases:

- `ext/trailofbits` — Static analysis rules, audit checklists
- `ext/safe-solana-builder` — 70+ audit-derived code-generation rules
- `ext/ghostsecurity` — SAST criteria, SCA, secrets detection
- `ext/defending-code` — Vuln-discovery reference harness
- `ext/qedgen` — Lean 4 formal verification

## Repository Structure

```
solana-auditor-skill/
├── CLAUDE.md                    # Claude configuration
├── README.md                    # This file
├── LICENSE                      # MIT
├── install.sh                   # Installer script
├── skill/                       # Progressive-loading skills
│   ├── SKILL.md                # Entry point
│   ├── scoping.md              # Phase 0
│   ├── automated-scanning.md   # Phase 1
│   ├── manual-review.md        # Phase 2
│   ├── formal-verification.md  # Phase 3
│   ├── economic-attacks.md     # Phase 4
│   ├── reporting.md            # Phase 5
│   ├── remediation.md          # Phase 6
│   ├── vuln-database.md        # Reference
│   ├── tool-reference.md       # Reference
│   └── resources.md            # Reference
├── agents/                      # Specialized agents
├── commands/                    # Workflow commands
└── rules/                       # Auto-loading security rules
```

## Contributing

Contributions welcome! Areas where help is especially valuable:

- New vulnerability patterns for `vuln-database.md`
- Additional economic attack vectors
- Formal verification proof libraries
- Tool integration improvements
- Report template enhancements

Please open an issue before submitting substantive changes.

## License

MIT — see [LICENSE](LICENSE) for details.

---

Maintained by [Superteam Brazil](https://github.com/solanabr). Not a replacement for a professional audit firm.