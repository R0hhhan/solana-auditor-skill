# Solana Vulnerability Database

## When to Load This File

Load as a reference during Phase 2 (Manual Review) or when the user asks "is this pattern vulnerable", "known Solana vulnerabilities", "common exploit patterns".

## Vulnerability Categories

---

## V-001: Missing Signer Check

**Severity:** Critical
**CWE:** CWE-862 (Missing Authorization)

### Pattern
```rust
// VULNERABLE
pub fn admin_withdraw(ctx: Context<AdminWithdraw>, amount: u64) -> Result<()> {
    ctx.accounts.vault.sub_lamports(amount)?;
    ctx.accounts.destination.add_lamports(amount)?;
    Ok(())
}

#[derive(Accounts)]
pub struct AdminWithdraw<'info> {
    #[account(mut)]
    pub vault: Account<'info, Vault>,       // No signer constraint!
    #[account(mut)]
    pub destination: UncheckedAccount<'info>,
    pub admin: AccountInfo<'info>,           // Not checked as signer!
}
```

### Fix
```rust
#[derive(Accounts)]
pub struct AdminWithdraw<'info> {
    #[account(mut, has_one = admin)]         // Owner check
    pub vault: Account<'info, Vault>,
    #[account(mut)]
    pub destination: UncheckedAccount<'info>,
    pub admin: Signer<'info>,                // Must be signer
}
```

### Real-World Examples
- CashioApp exploit ($48M) — missing signer validation on vault
- Wormhole exploit ($326M) — missing signature verification on guardian set update

---

## V-002: Account Type Confusion (Missing Discriminator)

**Severity:** Critical
**CWE:** CWE-843 (Type Confusion)

### Pattern
```rust
// VULNERABLE (native Rust)
pub fn process_instruction(
    _program_id: &Pubkey,
    accounts: &[AccountInfo],
    _data: &[u8],
) -> ProgramResult {
    let account = &accounts[0];
    let mut data = account.try_borrow_mut_data()?;
    // No type check — could be ANY account!
    let state = bytemuck::from_bytes_mut::<MyState>(&mut data);
}
```

### Fix
```rust
// Anchor: #[account] macro adds 8-byte discriminator automatically
#[account]
pub struct MyState {
    pub value: u64,
}

// Native: Manual discriminator
const DISCRIMINATOR: [u8; 8] = [1, 2, 3, 4, 5, 6, 7, 8];
if data[..8] != DISCRIMINATOR {
    return Err(ProgramError::InvalidAccountData);
}
```

---

## V-003: Arbitrary CPI Target

**Severity:** Critical
**CWE:** CWE-610 (Externally Controlled Reference)

### Pattern
```rust
// VULNERABLE
pub fn execute_cpi(ctx: Context<ExecuteCpi>, program_id: Pubkey) -> Result<()> {
    let ix = Instruction {
        program_id,  // Attacker controls this!
        accounts: vec![...],
        data: vec![],
    };
    invoke(&ix, &ctx.accounts.to_account_infos())?;
}
```

### Fix
```rust
// Hardcode expected program IDs
const TOKEN_PROGRAM: Pubkey = pubkey!("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA");

pub fn execute_cpi(ctx: Context<ExecuteCpi>) -> Result<()> {
    let ix = Instruction {
        program_id: TOKEN_PROGRAM,  // Hardcoded
        accounts: vec![...],
        data: vec![],
    };
    invoke(&ix, &ctx.accounts.to_account_infos())?;
}
```

---

## V-004: Reinitialization Attack

**Severity:** High
**CWE:** CWE-665 (Improper Initialization)

### Pattern
```rust
// VULNERABLE
#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init_if_needed, payer = user, space = 8 + 64)]
    pub state: Account<'info, MyState>,  // Can be reinitialized!
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}
```

### Fix
```rust
#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = user, space = 8 + 64)]  // init, not init_if_needed
    pub state: Account<'info, MyState>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}
```

---

## V-005: Unchecked Arithmetic (Overflow/Underflow)

**Severity:** High
**CWE:** CWE-190 (Integer Overflow)

### Pattern
```rust
// VULNERABLE (in older Rust/SBF without overflow-checks=on)
pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
    ctx.accounts.vault.balance += amount;  // Can overflow!
}
```

### Fix
```rust
pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
    ctx.accounts.vault.balance = ctx.accounts.vault.balance
        .checked_add(amount)
        .ok_or(ErrorCode::Overflow)?;
}
```

---

## V-006: Rounding Attack

**Severity:** High
**CWE:** CWE-682 (Incorrect Calculation)

### Pattern
```rust
// VULNERABLE: Integer division truncates toward zero
let shares = amount * total_shares / total_deposits;
// If amount * total_shares < total_deposits, shares = 0
// Attacker can deposit tiny amounts to get free shares via rounding
```

### Fix
```rust
// Check for zero shares
let shares = amount
    .checked_mul(total_shares)
    .ok_or(ErrorCode::Overflow)?
    .checked_div(total_deposits)
    .ok_or(ErrorCode::DivisionError)?;
require!(shares > 0, ErrorCode::DepositTooSmall);

// Or use rounding-up for protocol-favorable operations
let shares = amount
    .checked_mul(total_shares)
    .ok_or(ErrorCode::Overflow)?
    .div_ceil(total_deposits);  // Round up
```

---

## V-007: PDA Seed Collision

**Severity:** High
**CWE:** CWE-341 (Predictable Seed)

### Pattern
```rust
// VULNERABLE: Seeds don't include unique user identifier
let seeds = &[b"vault", &[bump]];
// All users share the same vault PDA!

// VULNERABLE: Seeds use predictable sequential ID
let seeds = &[b"user", &[next_id as u8], &[bump]];
// Attacker can front-run to claim someone else's ID
```

### Fix
```rust
// Include user's public key in seeds
let seeds = &[b"vault", user.key().as_ref(), &[bump]];

// Use random or hash-based IDs, not sequential
let seeds = &[b"user", &hash(user.key(), nonce).to_bytes(), &[bump]];
```

---

## V-008: Close Authority Attack (Token Accounts)

**Severity:** Medium
**CWE:** CWE-732 (Incorrect Permission Assignment)

### Pattern
```rust
// VULNERABLE: Token account has close_authority set to attacker
// Attacker can close the account and steal rent lamports
```

### Fix
```rust
// Always check close_authority before accepting token accounts
let token_account = spl_token::state::Account::unpack(&data)?;
require!(
    token_account.close_authority.is_none(),
    ErrorCode::TokenAccountHasCloseAuthority
);
```

---

## V-009: Reentrancy via Cross-Program Invocation

**Severity:** High
**CWE:** CWE-841 (Improper Enforcement of Behavioral Workflow)

### Pattern
```rust
// VULNERABLE: State modified AFTER external CPI
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    // External CPI
    token::transfer(ctx.accounts.transfer_ctx(), amount)?;
    // State update AFTER external call
    ctx.accounts.vault.total_deposits -= amount;
}
```

### Fix
```rust
// Checks-Effects-Interactions pattern
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    // 1. Checks
    require!(ctx.accounts.vault.total_deposits >= amount, ErrorCode::Insufficient);
    // 2. Effects (state update FIRST)
    ctx.accounts.vault.total_deposits -= amount;
    // 3. Interactions (external CPI LAST)
    token::transfer(ctx.accounts.transfer_ctx(), amount)?;
}
```

---

## V-010: Oracle Staleness / Manipulation

**Severity:** High
**CWE:** CWE-1275 (Incorrect Use of Oracle)

### Pattern
```rust
// VULNERABLE: Using AMM spot price as oracle
let price = (reserve_a as u128) * PRECISION / (reserve_b as u128);
// Spot price can be manipulated with a large swap in the same tx
```

### Fix
```rust
// Use Pyth or Switchboard with confidence and staleness checks
let price_feed = pyth::load_price_feed(&ctx.accounts.price_feed)?;
let price = price_feed.get_current_price()?;
require!(price_feed.is_trading(), ErrorCode::StaleOracle);
// Check confidence interval
let conf = price.conf as u64;
require!(conf <= price.price as u64 / 100, ErrorCode::LowConfidence); // <1%
```

---

## V-011: Bump Seed Not Stored

**Severity:** Medium
**CWE:** CWE-696 (Incorrect Behavior Order)

### Pattern
```rust
// VULNERABLE: Bump recomputed each time — can differ
let (pda, bump) = Pubkey::find_program_address(&[b"state"], program_id);
// bump might be different from when the account was created!
```

### Fix
```rust
// Store the canonical bump in the account
#[account]
pub struct MyState {
    pub bump: u8,  // Store the bump used to create this PDA
}

// Use stored bump for invoke_signed
let seeds = &[b"state", &[ctx.accounts.state.bump]];
invoke_signed(&ix, accounts, &[seeds])?;
```

---

## V-012: Lamport Drain via Unchecked Destination

**Severity:** Critical
**CWE:** CWE-441 (Unintended Proxy)

### Pattern
```rust
// VULNERABLE: Destination account not validated
pub fn close_account(ctx: Context<CloseAccount>) -> Result<()> {
    let dest = &ctx.accounts.destination;
    let source = &ctx.accounts.source;
    **dest.lamports.borrow_mut() += **source.lamports.borrow();
    **source.lamports.borrow_mut() = 0;
    // Attacker can set destination to their own account!
}
```

### Fix
```rust
// Anchor's close constraint validates destination
#[derive(Accounts)]
pub struct CloseAccount<'info> {
    #[account(mut, close = destination)]  // Anchor validates this
    pub source: Account<'info, MyState>,
    #[account(mut)]
    pub destination: SystemAccount<'info>,
}
```

---

## Quick Reference: Vulnerability → Checklist Domain

| Vulnerability | Manual Review Domain |
|---|---|
| V-001: Missing Signer | Domain 1: Access Control |
| V-002: Type Confusion | Domain 3: Account Validation |
| V-003: Arbitrary CPI | Domain 4: CPI Safety |
| V-004: Reinitialization | Domain 3: Account Validation |
| V-005: Overflow | Domain 2: Arithmetic Safety |
| V-006: Rounding | Domain 2: Arithmetic Safety |
| V-007: PDA Collision | Domain 3: Account Validation |
| V-008: Close Authority | Domain 6: Token Programs |
| V-009: Reentrancy | Domain 4: CPI Safety |
| V-010: Oracle Staleness | Domain 7: Composability |
| V-011: Bump Not Stored | Domain 3: Account Validation |
| V-012: Lamport Drain | Domain 3: Account Validation |