# Rust Security Rules for Solana Programs

## When These Rules Apply

These rules auto-load when working with `.rs` files in Solana program contexts.

## Critical Rules

### RUST-SEC-001: Always Use Checked Arithmetic

```rust
// ❌ NEVER use bare arithmetic operators
let new_amount = old_amount + deposit;

// ✅ ALWAYS use checked operations
let new_amount = old_amount.checked_add(deposit)
    .ok_or(ErrorCode::Overflow)?;
```

### RUST-SEC-002: Checks-Effects-Interactions Pattern

```rust
// ❌ NEVER modify state after external CPI
token::transfer(ctx, amount)?;
ctx.accounts.vault.balance -= amount; // TOO LATE

// ✅ ALWAYS update state BEFORE external calls
require!(ctx.accounts.vault.balance >= amount, ErrorCode::Insufficient);
ctx.accounts.vault.balance -= amount; // FIRST
token::transfer(ctx, amount)?; // LAST
```

### RUST-SEC-003: Validate All Accounts

```rust
// ❌ NEVER trust account data without validation
let data = &ctx.accounts.my_account;

// ✅ ALWAYS validate owner, discriminator, and constraints
#[account(has_one = owner, constraint = data.is_initialized)]
pub my_account: Account<'info, MyData>,
```

### RUST-SEC-004: Hardcode CPI Program IDs

```rust
// ❌ NEVER accept user-supplied program IDs for CPI
pub fn execute(ctx: Context<Execute>, program_id: Pubkey) -> Result<()> {
    invoke(&ix.with_program(program_id), &ctx.accounts)?;
}

// ✅ ALWAYS hardcode or whitelist program IDs
const TOKEN_PROGRAM: Pubkey = pubkey!("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA");
pub fn execute(ctx: Context<Execute>) -> Result<()> {
    invoke(&ix.with_program(TOKEN_PROGRAM), &ctx.accounts)?;
}
```

### RUST-SEC-005: Store and Use Canonical Bump Seeds

```rust
// ❌ NEVER recompute bump seeds
let (_, bump) = Pubkey::find_program_address(&[b"state"], program_id);

// ✅ ALWAYS store the bump in the account and use it
#[account]
pub struct MyState {
    pub bump: u8, // Stored at initialization
}
let seeds = &[b"state", &[ctx.accounts.state.bump]];
```

### RUST-SEC-006: Validate Token Account Mint and Owner

```rust
// ❌ NEVER trust a token account without validation
pub fn deposit(ctx: Context<Deposit>, amount: u64) -> Result<()> {
    token::transfer(ctx.accounts.transfer_ctx(), amount)?;
}

// ✅ ALWAYS validate mint and owner
#[account(
    constraint = user_token.mint == vault.mint,
    constraint = user_token.owner == user.key(),
)]
pub user_token: Account<'info, TokenAccount>,
```

### RUST-SEC-007: No init_if_needed Without Reinit Protection

```rust
// ❌ AVOID init_if_needed unless reinitialization is explicitly desired
#[account(init_if_needed, payer = user, space = 8 + 64)]
pub state: Account<'info, MyState>,

// ✅ PREFER init for one-time initialization
#[account(init, payer = user, space = 8 + 64)]
pub state: Account<'info, MyState>,

// ✅ If init_if_needed is required, add reinit protection
#[account(init_if_needed, payer = user, space = 8 + 64)]
pub state: Account<'info, MyState>,
// In instruction:
require!(!state.is_initialized || ctx.accounts.authority.key() == state.admin,
    ErrorCode::AlreadyInitialized);
```

### RUST-SEC-008: Validate Close Destination

```rust
// ❌ NEVER close an account to an unvalidated destination
#[account(mut)]
pub destination: UncheckedAccount<'info>,

// ✅ ALWAYS use Anchor's close constraint
#[account(mut, close = destination)]
pub account_to_close: Account<'info, MyState>,
#[account(mut)]
pub destination: SystemAccount<'info>,
```

### RUST-SEC-009: Check Oracle Staleness and Confidence

```rust
// ❌ NEVER use oracle prices without validation
let price = pyth.get_current_price()?;

// ✅ ALWAYS check staleness and confidence
let price_feed = pyth::load_price_feed(&ctx.accounts.price_feed)?;
let price = price_feed.get_current_price()?;
require!(price_feed.is_trading(), ErrorCode::StaleOracle);
let conf = price.conf as u64;
require!(conf <= price.price as u64 / 100, ErrorCode::LowConfidence);
```

### RUST-SEC-010: Use require_keys_eq! for Pubkey Comparison

```rust
// ❌ NEVER use == for Pubkey comparison
if ctx.accounts.owner.key() == ctx.accounts.vault.owner {
    // ...
}

// ✅ ALWAYS use require_keys_eq!
require_keys_eq!(
    ctx.accounts.owner.key(),
    ctx.accounts.vault.owner,
    ErrorCode::Unauthorized
);
```