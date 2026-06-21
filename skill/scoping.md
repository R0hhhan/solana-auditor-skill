# Phase 0: Scoping & Threat Modeling

## When to Load This File

Load when the user says "audit my program", "security review", "threat model", "what's the attack surface", or when starting any audit engagement.

## Intake Questionnaire

Before any analysis, gather:

### Program Basics
- **Program ID(s):** Which on-chain programs are in scope?
- **Repository:** Link to the codebase.
- **Framework:** Anchor, Pinocchio, native Rust, or other?
- **Lines of code:** Rough size estimate.
- **Dependencies:** Key external programs called via CPI.

### Asset Profile
- **What assets does this program guard?** Tokens, NFTs, SOL, governance power, data?
- **Expected TVL:** Rough order of magnitude ($1K, $100K, $1M, $10M+).
- **Who can deposit/withdraw?** Permissioned or permissionless?
- **Is there an admin/upgrade authority?** Who holds it? Multisig?

### User Profile
- **Who are the users?** Retail, institutions, bots, other programs?
- **Authentication model:** Wallet-based, KYC'd, program-derived?
- **Geographic restrictions:** Any geo-blocking or sanctions screening?

### Threat Landscape
- **What's the worst-case loss?** Total TVL drain? Governance capture? Data corruption?
- **Who would attack this?** Opportunistic (anyone), targeted (competitor), nation-state?
- **What's been attacked before?** Similar protocols that have been exploited.

## Threat Modeling Framework

Use STRIDE-per-instruction:

### STRIDE Categories
| Category | Solana-Specific Questions |
|---|---|
| **S**poofing | Can an attacker fake a signer? Forge a PDA? Impersonate a program? |
| **T**ampering | Can account data be modified by unauthorized parties? Reinitialization? |
| **R**epudiation | Are all state changes attributable? Is there an audit trail? |
| **I**nformation Disclosure | Can private state be read? Are seeds leaked? On-chain data exposure? |
| **D**enial of Service | Can an attacker block legitimate users? Drain compute units? Fill accounts? |
| **E**levation of Privilege | Can a user escalate to admin? Bypass owner checks? Exploit delegate? |

### Per-Instruction Analysis

For each instruction in the program:

1. **List all accounts** — which are signers, which are PDA, which are mutable.
2. **Identify trust boundaries** — where does control transfer between parties?
3. **Map data flow** — what data enters, what data is modified, what data exits.
4. **Identify invariants** — what must always be true before and after this instruction.

## Scope Levels

Agree on one of these scope levels with the user:

### Level 1: Quick Scan (~30 min)
- Automated tools only (cargo check, clippy, cargo-audit)
- Surface-level pattern matching
- Best for: pre-commit checks, small changes

### Level 2: Standard Audit (~2-4 hours)
- Automated scanning + manual review checklists
- All 8 manual review domains
- Economic attack simulation for key instructions
- Best for: pre-audit-firm preparation, moderate TVL programs

### Level 3: Deep Audit (~1-3 days)
- Full lifecycle: scoping → automated → manual → economic → report
- Formal verification of critical invariants
- Fuzz testing with Trident
- Mainnet-fork testing with Surfpool
- Best for: high-TVL programs, pre-mainnet launch

### Level 4: Full Formal (~1-2 weeks)
- Everything in Level 3
- Complete Lean 4 formal verification of all invariants
- Bounded model checking of all state transitions
- Independent verification of all math
- Best for: highest-assurance programs (bridges, lending, DEXs)

## Scope Agreement Template

After intake, confirm with the user:

```
## Audit Scope Agreement

**Program(s):** [list]
**Repository:** [link]
**Scope Level:** [1/2/3/4]
**Instructions in scope:** [list or "all"]
**Instructions out of scope:** [list or "none"]
**TVL estimate:** [$range]
**Special concerns:** [any user-specified worries]
**Timeline:** [expected duration]

Proceed?
```

## Adversary Profiles

Model these attacker types:

| Profile | Capability | Motivation | Typical Targets |
|---|---|---|---|
| **Opportunistic Bot** | Automated scanning, known exploit patterns | Quick profit | Unverified programs, missing access control |
| **Sophisticated Individual** | Deep Solana knowledge, custom exploits | High reward | DeFi protocols, bridges |
| **Insider** | Source code access, deployment keys | Varied | Upgradeable programs, admin functions |
| **MEV Searcher** | Transaction ordering, mempool access | Arbitrage | DEXs, liquidations, oracles |
| **Nation-State** | Unlimited resources, zero-days | Strategic | Critical infrastructure, stablecoins |

## Output: Threat Model Document

After scoping, produce a threat model document with:

1. **System diagram** — boxes (programs, accounts, users) and arrows (CPIs, token flows).
2. **Trust assumptions** — what the program assumes to be true.
3. **Adversary profiles** — which profiles apply and why.
4. **Attack surface map** — every instruction × every STRIDE category.
5. **Prioritized risk list** — ranked by impact × likelihood.
6. **Scope boundaries** — what's in and out of scope for this engagement.