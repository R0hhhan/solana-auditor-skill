---
name: solana-auditor
description: Full-lifecycle Solana program security auditor. Covers the complete audit workflow — scoping, automated scanning (static + dynamic), manual deep-review checklists, formal verification routing, economic attack simulation, report generation, and remediation tracking. Routes to bundled security sub-skills (trailofbits, safe-solana-builder, ghostsecurity, defending-code, qedgen) at the right phases. Use when a user says "audit my program", "security review", "find vulnerabilities", "formal verification", "economic attack", "reentrancy check", "access control audit", "arithmetic safety", "PDA validation", "CPIs are safe", "upgrade authority review", "generate audit report", "remediation plan", "threat model", or asks for a comprehensive security assessment of a Solana program. This skill provides technical security analysis — it is not a replacement for a professional audit firm.
user-invocable: true
license: MIT
compatibility: claude-code, codex, opencode, cursor, windsurf, copilot
metadata:
  version: "1.0.0"
  updated: "2026-06-21"
  stack: "Anchor 1.0+, Pinocchio, Rust 1.82+, Solana 2.0+, Mollusk, LiteSVM, Surfpool, Trident, Trail of Bits tools, Lean 4"
---

# Solana Auditor Skill — Full-Lifecycle Security for Solana Programs

## Standing Note

> This skill provides technical security analysis and automated tooling guidance. It is not a replacement for a professional audit firm. Critical programs handling significant TVL should always engage a reputable audit firm for a final review. This skill helps you find and fix issues *before* that engagement — and helps you understand and act on audit findings *after*.

## What This Skill Is For

Use this skill when a user asks for or describes:

- **Full program audit.** "Audit my Anchor program." "Do a comprehensive security review of this codebase."
- **Targeted vulnerability scan.** "Check for reentrancy." "Find missing signer checks." "Are my CPIs safe?" "Validate PDA derivations."
- **Formal verification.** "Prove this invariant." "Formally verify the token math." "Can this overflow?"
- **Economic attack analysis.** "Is my tokenomics exploitable?" "Simulate a flash-loan attack." "Check oracle manipulation vectors."
- **Threat modeling.** "What's the worst that could happen?" "Model the attack surface." "Who are the adversaries?"
- **Audit report generation.** "Generate an audit report." "Create a findings summary." "Build a remediation tracker."
- **Pre-audit preparation.** "Get my codebase ready for an audit firm." "Run the pre-audit checklist."
- **Post-audit remediation.** "Help me fix these audit findings." "Prioritize these vulnerabilities." "Track remediation progress."

## What This Skill Is NOT

- A replacement for a professional audit firm for high-TVL programs.
- A guarantee of bug-free code.
- A legal or compliance advisor (route to `crypto-legal-skill` for that).
- A deployment tool — it analyzes, doesn't deploy.
- A real-time monitoring/intrusion-detection system.

## Operating Procedure

When a user requests an audit or security review, follow this phased lifecycle:

### Phase 0: Scoping & Threat Modeling

1. **Intake.** Understand the program: what does it do, what assets does it guard, who are the users, what's the TVL expectation.
2. **Threat model.** Identify: (a) trust assumptions, (b) adversary profiles, (c) attack surface, (d) worst-case loss scenarios.
3. **Scope agreement.** Confirm scope with user: which programs, which instructions, which accounts, depth level (quick-scan / deep-audit / full-formal).

→ Route to: `skill/scoping.md`

### Phase 1: Automated Scanning

Run automated tools in parallel where possible:

| Tool | What It Catches | When to Use |
|---|---|---|
| **Anchor CLI / `cargo check`** | Compilation errors, type mismatches | Always — first pass |
| **Clippy (security lints)** | Unsafe patterns, arithmetic issues | Always |
| **Trident** | Fuzz testing, instruction-level invariants | Deep audit |
| **Mollusk / LiteSVM** | Instruction-level unit tests | Always |
| **Surfpool** | Mainnet-fork integration tests | Pre-mainnet |
| **cargo-audit** | Known-vulnerability deps | Always |
| **cargo-deny** | License + duplicate deps | Pre-mainnet |
| **semgrep / trailofbits rules** | Pattern-based vuln detection | Deep audit |

→ Route to: `skill/automated-scanning.md`

### Phase 2: Manual Deep Review

Walk through the program systematically using checklists:

1. **Access Control.** Signer checks, owner checks, PDA authority, upgrade authority.
2. **Arithmetic Safety.** Overflow/underflow, rounding direction, precision loss, division-before-multiplication.
3. **Account Validation.** Owner checks, discriminator checks, PDA seed validation, reinitialization attacks.
4. **CPI Safety.** Program IDs verified, account ordering, privilege escalation, arbitrary CPI targets.
5. **State Machine Integrity.** Invalid transitions, race conditions, reentrancy via CPI.
6. **Token Program Interactions.** Token account ownership, delegate abuse, close-authority attacks, Token-2022 extension edge cases.
7. **Cross-Program Invocation.** Composability risks, dependency on external program behavior.
8. **Upgradeability.** Upgrade authority risks, proxy patterns, migration safety, immutable-by-default preference.

→ Route to: `skill/manual-review.md`

### Phase 3: Formal Verification (Optional / Deep Audit)

For high-assurance programs:

- **Lean 4 proofs** via QEDGen (`ext/qedgen`) — full functional correctness.
- **Invariant specification** — write the properties that must always hold.
- **Bounded model checking** — verify within transaction-level bounds.

→ Route to: `skill/formal-verification.md`

### Phase 4: Economic Attack Simulation

Model economic exploit vectors:

- **Flash-loan attacks.** Can an attacker manipulate prices within a single tx?
- **Oracle manipulation.** Which oracles are used? What's the manipulation cost?
- **MEV / sandwich attacks.** Is the program vulnerable to transaction ordering?
- **Liquidity attacks.** Can an attacker drain liquidity through edge cases?
- **Governance attacks.** Can governance parameters be manipulated?
- **Incentive analysis.** Are economic incentives aligned? Any extractable value?

→ Route to: `skill/economic-attacks.md`

### Phase 5: Report Generation

Produce a structured audit report:

1. **Executive Summary.** Program overview, scope, severity distribution, key findings.
2. **Findings Detail.** Per-finding: severity (Critical/High/Medium/Low/Info), description, impact, proof-of-concept, remediation.
3. **Threat Model Summary.** Attack surface diagram, adversary profiles, trust assumptions.
4. **Remediation Roadmap.** Prioritized fix list with effort estimates.
5. **Appendix.** Tool outputs, full checklist results, methodology notes.

→ Route to: `skill/reporting.md`

### Phase 6: Remediation Tracking

After the report:

1. **Issue tracker.** Convert findings to trackable issues.
2. **Fix verification.** Re-run relevant scans after fixes.
3. **Regression check.** Ensure fixes don't introduce new issues.
4. **Re-audit scope.** Identify what needs re-review.

→ Route to: `skill/remediation.md`

## Progressive Disclosure Map

```
SKILL.md (you are here)
  │
  ├── skill/scoping.md              ← Phase 0: Threat modeling, scope definition
  ├── skill/automated-scanning.md   ← Phase 1: Tool configuration & execution
  ├── skill/manual-review.md        ← Phase 2: Deep-review checklists (8 domains)
  ├── skill/formal-verification.md  ← Phase 3: Lean 4 proofs, invariants
  ├── skill/economic-attacks.md     ← Phase 4: Flash loans, MEV, oracle manipulation
  ├── skill/reporting.md            ← Phase 5: Report templates & generation
  ├── skill/remediation.md          ← Phase 6: Fix tracking & verification
  │
  ├── skill/vuln-database.md        ← Known Solana vulnerability patterns (reference)
  ├── skill/tool-reference.md       ← Tool-specific quick-reference cards
  └── skill/resources.md            ← Curated security resources & links
```

Read only what the current phase needs. Do not pre-load.

## Routing to Existing Security Sub-Skills

The kit bundles these security submodules. Route to them at the right phase:

| Sub-Skill | Phase | What It Provides |
|---|---|---|
| `ext/trailofbits` | Phase 1, 2 | Static analysis rules, audit checklists, vulnerability patterns |
| `ext/safe-solana-builder` | Phase 2 | 70+ audit-derived code-generation rules, security-first patterns |
| `ext/ghostsecurity` | Phase 1 | SAST criteria, SCA, secrets detection, input validation |
| `ext/defending-code` | Phase 1, 2 | Anthropic vuln-discovery reference harness, 6 detection skills |
| `ext/qedgen` | Phase 3 | Lean 4 formal verification, theorem proving |
| `ext/solana-dev` (security.md) | Phase 2 | Core program + client security checklist |

## Severity Classification

Use this consistent severity schema across all phases:

| Severity | Definition | Example |
|---|---|---|
| **Critical** | Direct loss of all funds, irreversible | Missing signer check on vault withdraw |
| **High** | Loss of some funds under specific conditions | Rounding error exploitable over many txns |
| **Medium** | Disruption of intended behavior, no direct fund loss | Incorrect PDA derivation causing DoS |
| **Low** | Best-practice deviation, minimal risk | Missing `#[account(init_if_needed)]` safety |
| **Info** | Observation, not a vulnerability | Gas optimization suggestion |

## Agent Safety Guardrails

1. **Never deploy or upgrade programs.** This skill analyzes, it does not execute on-chain.
2. **Never sign transactions.** No wallet integration, no key custody.
3. **Never suppress findings.** Report everything found, even if the user asks to skip "minor" issues.
4. **Always cite the code.** Every finding references specific file:line and explains the impact.
5. **Always provide PoC when possible.** For High/Critical, include a proof-of-concept or exploit scenario.
6. **Always recommend professional audit for mainnet.** For programs handling >$10K TVL, include the recommendation.
7. **Never claim a program is "secure."** Say "no vulnerabilities found at this audit depth" instead.

## Commands

| Command | Description |
|---|---|
| `/audit` | Full audit lifecycle (scoping → report) |
| `/quick-scan` | Fast automated scan only (Phase 1) |
| `/deep-review` | Manual deep review (Phase 2) |
| `/threat-model` | Threat modeling session (Phase 0) |
| `/economic-sim` | Economic attack simulation (Phase 4) |
| `/audit-report` | Generate audit report from findings (Phase 5) |
| `/fix-findings` | Remediation tracking & fix verification (Phase 6) |

## Agents

| Agent | Model | Role |
|---|---|---|
| security-architect | opus | Threat modeling, attack surface analysis, audit scoping |
| vuln-hunter | opus | Deep code review, vulnerability discovery, exploit PoC |
| formal-verifier | opus | Invariant specification, Lean 4 proofs, bounded model checking |
| economic-analyst | sonnet | Economic attack simulation, MEV analysis, incentive review |
| audit-reporter | sonnet | Report generation, findings documentation, remediation tracking |

## Output Format

Every audit output should include:

1. **Scope statement.** What was audited, at what depth, with what tools.
2. **Findings.** Per-finding: severity, description, location, impact, PoC, remediation.
3. **Severity distribution.** Count by Critical/High/Medium/Low/Info.
4. **Tool outputs.** Summary of automated scan results.
5. **Limitations.** What was NOT covered and why.
6. **Recommendation.** Whether professional audit is recommended for mainnet.

## Resources

See `skill/resources.md` for curated links: Solana security docs, Neodyme blog, Sec3 blog, OtterSec, Mad Shield, Trail of Bits Solana resources, Anchor security best practices, and more.

---

*Current as of 2026-06. Solana security best practices evolve — always cross-reference with the latest Solana Foundation security guidelines.*