# Anchor Framework Security Rules

## When These Rules Apply

These rules auto-load when working with Anchor framework programs.

## Critical Rules

### ANCHOR-SEC-001: Prefer init Over init_if_needed

```rust
// ❌ AVOID
#[account(init_if_needed, payer = user, space = 8 + 64)]

// ✅ PREFER
#[account(init, payer = user, space = 8 + 64)]
```

### ANCHOR-SEC-002: Always Use has_one for Owner Checks

```rust
// ❌ NEVER skip owner validation
#[account(mut)]
pub vault: Account<'info, Vault>,

// ✅ ALWAYS validate ownership
#[account(mut, has_one = owner)]
pub vault: Account<'info, Vault>,
pub owner: Signer<'info>,
```

### ANCHOR-SEC-003: Validate Token Account Constraints

```rust
// ❌ NEVER accept token accounts without validation
pub user_token: Account<'info, TokenAccount>,

// ✅ ALWAYS validate mint and owner
#[account(
    mint::token_program = token_program,
    constraint = user_token.mint == expected_mint,
    constraint = user_token.owner == user.key(),
)]
pub user_token: Account<'info, TokenAccount>,
```

### ANCHOR-SEC-004: Use seeds Constraint for PDA Validation

```rust
// ❌ NEVER manually validate PDAs
pub vault: Account<'info, Vault>,

// ✅ ALWAYS use the seeds constraint
#[account(
    seeds = [b"vault", user.key().as_ref()],
    bump = vault.bump,
)]
pub vault: Account<'info, Vault>,
```

### ANCHOR-SEC-005: Validate close Destination

```rust
// ❌ NEVER close to an arbitrary destination
#[account(mut)]
pub destination: UncheckedAccount<'info>,

// ✅ ALWAYS use close constraint with validated destination
#[account(mut, close = destination)]
pub account_to_close: Account<'info, MyState>,
#[account(mut, address = expected_destination @ ErrorCode::InvalidDestination)]
pub destination: SystemAccount<'info>,
```

### ANCHOR-SEC-006: Use address Constraint for Known Programs

```rust
// ❌ NEVER accept arbitrary program accounts
pub token_program: Program<'info, Token>,

// ✅ ALWAYS validate program address
#[account(address = spl_token::ID @ ErrorCode::InvalidTokenProgram)]
pub token_program: Program<'info, Token>,
```

### ANCHOR-SEC-007: Validate realloc Usage

```rust
// ❌ NEVER realloc without size validation
#[account(mut, realloc = 8 + 64 + new_size, realloc::payer = user, realloc::zero = false)]

// ✅ ALWAYS validate new size
require!(new_size <= MAX_SIZE, ErrorCode::TooLarge);
#[account(mut, realloc = 8 + 64 + new_size, realloc::payer = user, realloc::zero = false)]
```

### ANCHOR-SEC-008: Use constraint for Business Logic Validation

```rust
// ❌ NEVER put all validation in instruction body
pub fn withdraw(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    require!(amount > 0, ErrorCode::InvalidAmount);
    require!(ctx.accounts.vault.balance >= amount, ErrorCode::Insufficient);
    // ...
}

// ✅ PREFER constraints where possible
#[account(constraint = vault.balance >= amount @ ErrorCode::Insufficient)]
pub vault: Account<'info, Vault>,
// Instruction body only for complex logic
```

### ANCHOR-SEC-009: Emit Events for State Changes

```rust
// ❌ NEVER skip event emission for important state changes
ctx.accounts.vault.balance -= amount;

// ✅ ALWAYS emit events
ctx.accounts.vault.balance -= amount;
emit!(WithdrawEvent {
    user: ctx.accounts.user.key(),
    amount,
    timestamp: Clock::get()?.unix_timestamp,
});
```

### ANCHOR-SEC-010: Use Proper Error Codes

```rust
// ❌ NEVER use generic errors
#[error_code]
pub enum ErrorCode {
    #[msg("Something went wrong")]
    Error, // Too vague
}

// ✅ ALWAYS use specific, descriptive errors
#[error_code]
pub enum ErrorCode {
    #[msg("Insufficient funds in vault")]
    InsufficientFunds,
    #[msg("Unauthorized: signer does not match vault owner")]
    Unauthorized,
    #[msg("Arithmetic overflow in deposit calculation")]
    Overflow,
}
```