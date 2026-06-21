# Phase 1: Automated Scanning

## When to Load This File

Load when starting Phase 1 of any audit, or when the user says "quick scan", "run automated checks", "static analysis", "lint my program".

## Tool Chain

Run tools in this order (fastest → slowest):

### 1. Compilation Check (Always First)

```bash
# Anchor project
anchor build 2>&1

# Native Rust
cargo build-sbf 2>&1

# Check for warnings as errors
cargo check 2>&1
```

**What to look for:**
- Compilation errors (obvious bugs)
- Warnings (often signal deeper issues)
- Deprecation notices (outdated patterns)

### 2. Clippy (Rust Linter)

```bash
cargo clippy -- -D warnings 2>&1
```

**Key lints to flag:**
- `clippy::arithmetic_side_effects` — unchecked math
- `clippy::cast_possible_truncation` — type narrowing
- `clippy::cast_sign_loss` — sign loss in casts
- `clippy::unwrap_used` — panics in program code
- `clippy::expect_used` — panics with messages
- `clippy::indexing_slicing` — potential out-of-bounds

### 3. cargo-audit (Known Vulnerabilities)

```bash
cargo audit 2>&1
```

**What to flag:**
- Any RUSTSEC advisory with CVSS ≥ 5.0
- Deprecated crates
- Unmaintained dependencies

### 4. cargo-deny (Supply Chain)

```bash
cargo deny check bans licenses sources 2>&1
```

**What to flag:**
- Copyleft licenses (GPL, AGPL) in program deps
- Duplicate crate versions
- Unapproved sources (git dependencies)

### 5. Semgrep / Custom Rules

```bash
# If trailofbits rules are available
semgrep --config=ext/trailofbits/rules/ 2>&1

# Solana-specific patterns
semgrep --config=auto --lang=rust 2>&1
```

**Custom Solana patterns to check:**
- Missing `#[account(init)]` constraints
- Missing signer validation
- Unchecked arithmetic
- `invoke_signed` without seed verification
- `close` without destination validation
- Missing discriminator checks

### 6. Trident Fuzzing (Deep Audit Only)

```bash
# Setup (once)
trident init

# Run fuzzer
trident fuzz run fuzz_0 2>&1
```

**What to look for:**
- Instruction sequences that break invariants
- Unexpected account state transitions
- Panics under fuzzed inputs

### 7. Mollusk / LiteSVM Tests

```bash
# Mollusk
cargo test --test integration 2>&1

# LiteSVM
cargo test --test litesvm 2>&1
```

### 8. Surfpool (Mainnet Fork Testing)

```bash
# Start mainnet fork
surfpool start --fork mainnet

# Run integration tests against fork
cargo test --test fork-integration 2>&1

# Stop fork
surfpool stop
```

## Automated Scan Report Template

After running all tools, produce:

```
## Automated Scan Results

### Build Status
- anchor build: [PASS/FAIL]
- Warnings: [count]

### Clippy
- Total lints: [count]
- Errors: [count]
- Warnings: [count]
- Key findings: [list]

### Dependency Audit
- cargo-audit: [vulnerabilities found]
- cargo-deny: [issues found]

### Pattern Scanning
- Semgrep findings: [count]
- Custom rule matches: [list]

### Fuzzing (if run)
- Trident: [crashes/panics found]
- Coverage: [%]

### Test Results
- Unit tests: [passed/failed]
- Integration tests: [passed/failed]
- Fork tests: [passed/failed]

### Summary
- Critical automated findings: [count]
- High automated findings: [count]
- Medium automated findings: [count]
- Low automated findings: [count]
```

## Common Automated Findings

### Missing Owner Check

```rust
// VULNERABLE: No owner validation
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    let vault = &mut ctx.accounts.vault;
    vault.amount -= amount; // Anyone can call this!
    Ok(())
}

// FIXED: Owner check
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    require_keys_eq!(
        ctx.accounts.vault.owner,
        ctx.accounts.user.key(),
        ErrorCode::Unauthorized
    );
    // ...
}
```

### Unchecked Arithmetic (Pre-Rust-1.82)

```rust
// VULNERABLE (Rust <1.82 without overflow-checks in SBF)
let new_amount = old_amount + deposit; // Can overflow in release

// FIXED
let new_amount = old_amount.checked_add(deposit)
    .ok_or(ErrorCode::Overflow)?;
```

### Missing Discriminator Check

```rust
// VULNERABLE: No account type verification
pub fn process(ctx: Context<Process>, data: Vec<u8>) -> Result<()> {
    let account = &mut ctx.accounts.data;
    // Could be ANY account type!
}

// FIXED: Anchor adds discriminator automatically with #[account]
#[account]
pub struct MyData {
    pub value: u64,
}
```

### Arbitrary CPI Target

```rust
// VULNERABLE: User-supplied program ID
pub fn arbitrary_cpi(ctx: Context<ArbitraryCpi>, program_id: Pubkey) -> Result<()> {
    invoke(&instruction, &ctx.accounts.to_account_infos())?;
    // Attacker can call ANY program!
}

// FIXED: Hardcode or whitelist program IDs
const ALLOWED_PROGRAMS: &[Pubkey] = &[
    pubkey!("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"),
];
require!(ALLOWED_PROGRAMS.contains(&program_id), ErrorCode::InvalidProgram);
```