# Phase 6: Remediation Tracking

## When to Load This File

Load when the user says "fix these findings", "remediation plan", "track fixes", "verify fixes", or after an audit report has been generated.

## Remediation Workflow

```
Audit Report → Issue Creation → Fix Implementation → Fix Verification → Regression Check → Sign-off
```

---

## 1. Issue Creation

Convert each audit finding into a trackable issue:

### Issue Template

```markdown
## [F-XXX] [Severity] [Title]

**Severity:** Critical / High / Medium / Low / Info
**Domain:** [Access Control / Arithmetic / ...]
**Location:** `path/to/file.rs:123`
**Reported:** [YYYY-MM-DD]

### Description
[What the vulnerability is]

### Impact
[What an attacker can achieve]

### Recommended Fix
[Specific code change or architectural fix]

### Acceptance Criteria
- [ ] [Specific test that must pass]
- [ ] [Specific invariant that must hold]
- [ ] [Specific scenario that must be safe]

### Related Issues
- [Cross-reference related findings]
```

---

## 2. Fix Prioritization

### Priority Matrix

| | Critical | High | Medium | Low | Info |
|---|---|---|---|---|---|
| **Easy fix (<1h)** | DO NOW | DO NOW | This sprint | Backlog | Backlog |
| **Medium fix (1-4h)** | DO NOW | This sprint | This sprint | Backlog | Backlog |
| **Hard fix (1-3d)** | DO NOW | This sprint | Next sprint | Backlog | Backlog |
| **Architectural (1w+)** | EMERGENCY | Next sprint | Roadmap | Roadmap | N/A |

### Fix Order

1. **Critical + Easy** → Fix immediately
2. **Critical + Hard** → Start immediately, consider interim mitigations
3. **High + Easy** → Fix this sprint
4. **High + Hard** → Plan this sprint
5. **Medium** → This sprint or next
6. **Low/Info** → Backlog

---

## 3. Fix Implementation Guidelines

### For Each Fix:

1. **Create a branch:** `fix/F-XXX-description-DD-MM-YYYY`
2. **Write a failing test** that demonstrates the vulnerability
3. **Implement the fix** — minimal, surgical change
4. **Verify the test passes** — vulnerability is closed
5. **Run regression tests** — nothing else broke
6. **Re-run automated scans** — no new issues introduced
7. **Self-review the diff** — is the fix complete?

### Common Fix Patterns

#### Missing Signer Check
```rust
// BEFORE (Vulnerable)
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    // No signer check!
    ctx.accounts.vault.amount -= amount;
}

// AFTER (Fixed)
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    require_keys_eq!(
        ctx.accounts.authority.key(),
        ctx.accounts.vault.owner,
        ErrorCode::Unauthorized
    );
    ctx.accounts.vault.amount = ctx.accounts.vault.amount
        .checked_sub(amount)
        .ok_or(ErrorCode::InsufficientFunds)?;
}
```

#### Missing Account Validation
```rust
// BEFORE (Vulnerable)
pub fn process(ctx: Context<Process>) -> Result<()> {
    let data = &mut ctx.accounts.data;
    // No type check — could be any account!
}

// AFTER (Fixed)
pub fn process(ctx: Context<Process>) -> Result<()> {
    // Anchor's #[account] macro adds 8-byte discriminator automatically
    // For native programs, add manual check:
    require!(
        ctx.accounts.data.discriminator == MyData::DISCRIMINATOR,
        ErrorCode::InvalidAccount
    );
}
```

#### Reentrancy via CPI
```rust
// BEFORE (Vulnerable)
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    // CPI to token program
    token::transfer(ctx.accounts.into_transfer_context(), amount)?;
    // State update AFTER external call — vulnerable!
    ctx.accounts.vault.amount -= amount;
}

// AFTER (Fixed — Checks-Effects-Interactions)
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    // 1. Checks
    require!(ctx.accounts.vault.amount >= amount, ErrorCode::InsufficientFunds);
    // 2. Effects (state update BEFORE external call)
    ctx.accounts.vault.amount -= amount;
    // 3. Interactions (external CPI last)
    token::transfer(ctx.accounts.into_transfer_context(), amount)?;
}
```

---

## 4. Fix Verification

After implementing fixes, verify:

### Per-Finding Verification

```markdown
## Fix Verification: F-XXX

**Fix commit:** [hash]
**Fix branch:** [branch name]

### Verification Steps
1. [x] Vulnerability test now passes
2. [x] Automated scan re-run — no regression
3. [x] Manual review of fix — complete and correct
4. [x] Related code paths checked — no similar issues
5. [x] Edge cases tested — [list]

### Verification Result: [VERIFIED / NEEDS REWORK]
```

### Regression Check

```bash
# Re-run all automated tools
anchor build
cargo clippy -- -D warnings
cargo audit
cargo test

# Re-run fuzzer (if previously run)
trident fuzz run fuzz_0

# Check that fix didn't introduce new issues
git diff main...fix-branch --stat
```

---

## 5. Remediation Dashboard

Track overall progress:

```markdown
## Remediation Dashboard

| Status | Count | % |
|---|---|---|
| Fixed & Verified | [N] | [%] |
| Fixed, Pending Verification | [N] | [%] |
| In Progress | [N] | [%] |
| Not Started | [N] | [%] |
| Accepted (Won't Fix) | [N] | [%] |
| **Total** | **[N]** | **100%** |

### Critical Path
- [ ] F-001: [Title] — [Owner] — [Status]
- [ ] F-002: [Title] — [Owner] — [Status]

### Blockers
- [Any issues blocking remediation]
```

---

## 6. Sign-off Criteria

Before declaring remediation complete:

- [ ] All Critical findings fixed and verified
- [ ] All High findings fixed and verified
- [ ] All Medium findings fixed or explicitly accepted
- [ ] Regression test suite passes
- [ ] Automated scans show no new issues
- [ ] Fix branches merged to main
- [ ] Professional audit firm engaged (if recommended)

---

## 7. Post-Remediation Re-Audit

After all fixes are applied:

1. **Re-run Phase 1 (Automated Scanning)** — confirm no regressions
2. **Spot-check Phase 2 (Manual Review)** — review changed code paths
3. **Re-run Phase 4 (Economic Attacks)** — if fixes changed economic logic
4. **Generate updated report** — "Post-Remediation Audit Report"
5. **Compare findings** — all original findings addressed, no new ones introduced