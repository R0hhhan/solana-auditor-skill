# Phase 5: Audit Report Generation

## When to Load This File

Load when the user says "generate audit report", "create findings report", "audit summary", or after completing Phases 1-4.

## Report Structure

Generate a professional audit report with these sections:

---

## 1. Executive Summary

```
# Security Audit Report: [Program Name]

**Date:** [YYYY-MM-DD]
**Version:** [commit hash / tag]
**Auditor:** AI-Assisted Security Review (solana-auditor-skill v1.0.0)
**Audit Level:** [Quick Scan / Standard / Deep / Full Formal]

## Executive Summary

[Program Name] is a [brief description — what it does, what assets it handles].
This audit covered [N] instructions across [N] program(s) at [audit level] depth.

### Key Findings

- **Critical:** [N] — [one-line summary of worst]
- **High:** [N] — [one-line summary]
- **Medium:** [N]
- **Low:** [N]
- **Info:** [N]

### Overall Assessment

[2-3 sentence assessment. Never say "secure" — say "no critical vulnerabilities
found at this audit depth" or "critical issues found that must be fixed before
mainnet deployment."]

### Recommendation

[ ] Ready for mainnet deployment (with noted caveats)
[ ] Fix critical/high issues before mainnet
[ ] Engage professional audit firm for final review
```

---

## 2. Scope

```
## Audit Scope

### Programs Audited
| Program | Program ID | Lines | Framework |
|---|---|---|---|
| [name] | [pubkey] | [N] | [Anchor/Pinocchio/Native] |

### Instructions in Scope
| Instruction | Program | Complexity | Depth |
|---|---|---|---|
| [name] | [program] | [Low/Med/High] | [Quick/Standard/Deep] |

### Out of Scope
- [List anything explicitly excluded]
- [Dependencies not reviewed]
- [Frontend/off-chain code not reviewed]

### Methodology
1. Automated scanning: [tools used]
2. Manual review: [8 domains covered]
3. Formal verification: [invariants proved / not performed]
4. Economic analysis: [attack types simulated]
5. Report generation: [this document]
```

---

## 3. Findings Detail

For each finding, use this template:

```
## Finding #[N]: [Title]

**Severity:** [Critical / High / Medium / Low / Info]
**Domain:** [Access Control / Arithmetic / Account Validation / CPI / State Machine / Token / Composability / Upgradeability / Economic]
**Location:** `[file]:[line]`
**Instruction:** `[instruction_name]`

### Description
[What the vulnerability is, in plain language. 2-4 sentences.]

### Impact
[What an attacker can achieve. Be specific about asset loss, state corruption, DoS.]

### Proof of Concept
```rust
// [Code demonstrating the vulnerability]
// [Or step-by-step exploit scenario]
```

### Remediation
```rust
// [Fixed code]
// [Or architectural change recommendation]
```

### References
- [Link to similar exploits]
- [Link to Solana security docs]
- [CWE/OWASP reference if applicable]
```

---

## 4. Severity Distribution

```
## Severity Distribution

| Severity | Count | Description |
|---|---|---|
| Critical | [N] | Direct loss of all funds, irreversible |
| High | [N] | Loss of funds under specific conditions |
| Medium | [N] | Disruption without direct fund loss |
| Low | [N] | Best-practice deviation |
| Info | [N] | Observation, not a vulnerability |

### Findings by Domain
| Domain | Critical | High | Medium | Low | Info |
|---|---|---|---|---|---|
| Access Control | [N] | [N] | [N] | [N] | [N] |
| Arithmetic | [N] | [N] | [N] | [N] | [N] |
| Account Validation | [N] | [N] | [N] | [N] | [N] |
| CPI Safety | [N] | [N] | [N] | [N] | [N] |
| State Machine | [N] | [N] | [N] | [N] | [N] |
| Token Programs | [N] | [N] | [N] | [N] | [N] |
| Composability | [N] | [N] | [N] | [N] | [N] |
| Upgradeability | [N] | [N] | [N] | [N] | [N] |
| Economic | [N] | [N] | [N] | [N] | [N] |
```

---

## 5. Threat Model Summary

```
## Threat Model Summary

### Trust Assumptions
1. [Assumption — e.g., "The upgrade authority multisig is honest"]
2. [Assumption — e.g., "Pyth oracle prices are accurate"]
3. ...

### Adversary Profiles Considered
| Profile | Capability | Risk Level |
|---|---|---|
| Opportunistic Bot | Automated scanning | [Low/Med/High] |
| Sophisticated Individual | Custom exploits | [Low/Med/High] |
| Insider | Source access | [Low/Med/High] |
| MEV Searcher | Tx ordering | [Low/Med/High] |

### Attack Surface
- Total instructions: [N]
- Mutable accounts: [N]
- CPIs: [N]
- External dependencies: [N]
```

---

## 6. Automated Scan Results

```
## Automated Scan Results

| Tool | Result | Findings |
|---|---|---|
| anchor build | [PASS/FAIL] | [N] warnings |
| cargo clippy | [PASS/FAIL] | [N] lints |
| cargo audit | [PASS/FAIL] | [N] advisories |
| cargo deny | [PASS/FAIL] | [N] issues |
| semgrep | [PASS/FAIL] | [N] matches |
| trident fuzz | [PASS/FAIL] | [N] crashes |
| mollusk/litesvm | [PASS/FAIL] | [N] failures |
```

---

## 7. Remediation Roadmap

```
## Remediation Roadmap

### Must Fix (Before Mainnet)
| # | Finding | Severity | Effort | Owner |
|---|---|---|---|---|
| 1 | [Title] | Critical | [S/M/L] | [name] |
| 2 | [Title] | High | [S/M/L] | [name] |

### Should Fix (Before Mainnet, Lower Priority)
| # | Finding | Severity | Effort | Owner |
|---|---|---|---|---|
| 3 | [Title] | Medium | [S/M/L] | [name] |

### Nice to Fix (Post-Launch)
| # | Finding | Severity | Effort | Owner |
|---|---|---|---|---|
| 4 | [Title] | Low | [S/M/L] | [name] |
```

---

## 8. Appendix

```
## Appendix

### A. Tool Outputs
[Full tool outputs attached or linked]

### B. Checklist Results
[Completed manual review checklists]

### C. Methodology Notes
[Any methodology deviations or notes]

### D. Glossary
[Terms used in the report]

### E. Disclaimer
This report represents a technical security analysis performed by an AI-assisted
tool. It is not a replacement for a professional audit by a qualified firm.
Critical programs handling significant value should engage a reputable audit firm
for a comprehensive review. Findings represent a point-in-time assessment and
may not reflect vulnerabilities introduced after the audit date.
```

---

## Report Formatting Guidelines

1. **Use consistent severity colors:** Critical = Red, High = Orange, Medium = Yellow, Low = Blue, Info = Gray
2. **Number findings sequentially** (F-001, F-002, ...)
3. **Cross-reference related findings** ("See also F-005 for related access control issue")
4. **Include line numbers** in all code references
5. **Provide complete PoC code** for Critical and High findings
6. **Suggest specific fixes**, not vague guidance
7. **Be honest about limitations** — state what wasn't covered