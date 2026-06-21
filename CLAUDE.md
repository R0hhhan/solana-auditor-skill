# Solana Auditor Skill — CLAUDE.md

## Communication Style

- Direct, precise, evidence-based communication
- Every finding cites specific code locations (file:line)
- Severity classifications follow the standard schema (Critical/High/Medium/Low/Info)
- Never claim a program is "secure" — say "no vulnerabilities found at this audit depth"
- Always recommend professional audit firm engagement for mainnet programs handling >$10K TVL

## Default Stack (June 2026)

### Programs
- Anchor 1.0+ (default framework)
- Pinocchio (for CU-optimized programs)
- Rust 1.82+ with overflow-checks enabled
- Solana 2.0+ runtime

### Testing
- Mollusk / LiteSVM for unit tests
- Trident for fuzz testing
- Surfpool for mainnet-fork integration tests

### Security Tools
- cargo clippy (security lints)
- cargo audit (dependency vulnerabilities)
- cargo deny (supply chain)
- semgrep (pattern matching)
- Trail of Bits rules (static analysis)

### Formal Verification
- Lean 4 via QEDGen
- Bounded model checking via Trident

## Skill Progressive Disclosure

Load skills based on the audit phase:

| Phase | Skill File |
|---|---|
| Scoping & Threat Modeling | skill/scoping.md |
| Automated Scanning | skill/automated-scanning.md |
| Manual Deep Review | skill/manual-review.md |
| Formal Verification | skill/formal-verification.md |
| Economic Attack Simulation | skill/economic-attacks.md |
| Report Generation | skill/reporting.md |
| Remediation Tracking | skill/remediation.md |
| Vulnerability Reference | skill/vuln-database.md |
| Tool Reference | skill/tool-reference.md |
| Security Resources | skill/resources.md |

## Agent Routing

Spawn specialized agents for complex tasks:

| Task | Agent | Model |
|---|---|---|
| Threat modeling, scoping | security-architect | opus |
| Deep code review, vuln hunting | vuln-hunter | opus |
| Formal verification, invariants | formal-verifier | opus |
| Economic attack simulation | economic-analyst | sonnet |
| Report generation, remediation | audit-reporter | sonnet |

## Commands

| Command | Description |
|---|---|
| /audit | Full audit lifecycle (scoping → report) |
| /quick-scan | Fast automated scan only |
| /deep-review | Manual deep review (8 domains) |
| /threat-model | Threat modeling session |
| /economic-sim | Economic attack simulation |
| /audit-report | Generate audit report |
| /fix-findings | Remediation tracking & verification |

## Security Rules (Auto-Loading)

- `rules/rust-security.md` — Loads for `.rs` files: 10 critical Rust security rules
- `rules/anchor-security.md` — Loads for Anchor programs: 10 critical Anchor security rules

## Key Principles

1. **Never deploy or upgrade programs.** This skill analyzes, it does not execute on-chain.
2. **Never sign transactions.** No wallet integration, no key custody.
3. **Never suppress findings.** Report everything found.
4. **Always cite the code.** Every finding references specific file:line.
5. **Always provide PoC.** For High/Critical, include exploit scenario.
6. **Always recommend professional audit for mainnet.** For programs handling >$10K TVL.
7. **Never claim a program is "secure."** Say "no vulnerabilities found at this audit depth."

## Routing to Bundled Security Sub-Skills

| Sub-Skill | Phase | What It Provides |
|---|---|---|
| ext/trailofbits | Phase 1, 2 | Static analysis rules, audit checklists |
| ext/safe-solana-builder | Phase 2 | 70+ audit-derived code-generation rules |
| ext/ghostsecurity | Phase 1 | SAST criteria, SCA, secrets detection |
| ext/defending-code | Phase 1, 2 | Vuln-discovery reference harness |
| ext/qedgen | Phase 3 | Lean 4 formal verification |

## Repository Structure

```
solana-auditor-skill/
├── CLAUDE.md                    # This file
├── README.md                    # User documentation
├── LICENSE                      # MIT License
├── install.sh                   # Installation script
│
├── skill/                       # Progressive-loading skills
│   ├── SKILL.md                # Entry point — routes to all phases
│   ├── scoping.md              # Phase 0: Threat modeling & scoping
│   ├── automated-scanning.md   # Phase 1: Tool configuration & execution
│   ├── manual-review.md        # Phase 2: 8-domain deep review checklists
│   ├── formal-verification.md  # Phase 3: Lean 4 proofs & invariants
│   ├── economic-attacks.md     # Phase 4: Flash loans, MEV, oracle manipulation
│   ├── reporting.md            # Phase 5: Report templates & generation
│   ├── remediation.md          # Phase 6: Fix tracking & verification
│   ├── vuln-database.md        # Known Solana vulnerability patterns
│   ├── tool-reference.md       # Tool-specific quick-reference cards
│   └── resources.md            # Curated security resources & links
│
├── agents/                      # Specialized agents
│   ├── security-architect.md   # Threat modeling & scoping
│   ├── vuln-hunter.md          # Deep code review & exploit discovery
│   ├── formal-verifier.md      # Invariant specification & Lean 4 proofs
│   ├── economic-analyst.md     # Economic attack simulation
│   └── audit-reporter.md       # Report generation & remediation tracking
│
├── commands/                    # Workflow commands
│   ├── audit.md                # Full audit lifecycle
│   ├── quick-scan.md           # Fast automated scan
│   ├── deep-review.md          # Manual deep review
│   ├── threat-model.md         # Threat modeling session
│   ├── economic-sim.md         # Economic attack simulation
│   ├── audit-report.md         # Generate audit report
│   └── fix-findings.md         # Remediation tracking
│
└── rules/                       # Auto-loading security rules
    ├── rust-security.md        # 10 critical Rust security rules
    └── anchor-security.md      # 10 critical Anchor security rules
```

## Branch Workflow

```bash
git checkout -b <type>/<scope>-<description>-<DD-MM-YYYY>

# Examples:
# feat/access-control-checks-21-06-2026
# fix/reentrancy-vuln-21-06-2026
# docs/audit-report-template-21-06-2026
```

Main skill entry: [skill/SKILL.md](skill/SKILL.md)