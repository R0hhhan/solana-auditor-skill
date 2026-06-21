# Phase 3: Formal Verification

## When to Load This File

Load when the user says "formal verification", "prove this invariant", "mathematically verify", "Lean 4 proof", or when doing a Level 3/4 deep audit.

## What Formal Verification Provides

Formal verification mathematically proves that a program satisfies its specification for ALL possible inputs — not just the ones you test. This is the highest assurance level.

## When to Use Formal Verification

| Program Type | Formal Verification Recommended? |
|---|---|
| Bridge / Wormhole | **Yes — always** |
| Lending protocol | **Yes — for core math** |
| DEX / AMM | **Yes — for swap curves** |
| Staking / Rewards | **Yes — for reward distribution** |
| NFT minting | Optional |
| Simple token vesting | Optional |
| Governance | **Yes — for voting math** |

## Verification Levels

### Level A: Invariant Specification (Always)

Write down the invariants in structured form. Even without machine proofs, this clarifies thinking.

```rust
/// INVARIANT: Total deposits == sum of all user deposits
/// INVARIANT: Pool tokens are never minted without corresponding deposit
/// INVARIANT: Exchange rate never decreases (no value extraction)
/// INVARIANT: Fees + LP share == total swap input
```

### Level B: Bounded Model Checking

Verify invariants hold for all states reachable within N transactions.

```bash
# Using Trident or custom fuzzer with invariant checks
trident fuzz run fuzz_invariants
```

### Level C: Lean 4 Full Proofs

Route to `ext/qedgen` for Lean 4 theorem proving.

## Invariant Specification Template

For each instruction, specify:

```
Instruction: deposit
Preconditions:
  - user.token_account.owner == user.key
  - user.token_account.mint == vault.mint
  - amount > 0
  - amount <= user.token_account.balance

Postconditions:
  - vault.total_deposits == old(vault.total_deposits) + amount
  - user.deposit_shares == old(user.deposit_shares) + shares
  - shares == amount * total_shares / old(vault.total_deposits)
  - vault.token_balance == old(vault.token_balance) + amount

Invariants Preserved:
  - total_deposits == sum(user_deposits)
  - total_shares == sum(user_shares)
```

## Common Invariants to Verify

### Token Conservation

```
sum(balances_before) == sum(balances_after)
```

### Share Proportionality

```
user_shares / total_shares == user_deposit / total_deposits
```

### Authority Integrity

```
∀ account: account.owner == expected_owner
```

### State Machine Safety

```
state ∈ {Active, Paused, Closed}
Active → Paused (admin only)
Paused → Active (admin only)
Active → Closed (admin only, irreversible)
```

### No Underflow

```
∀ operation: result >= 0
∀ transfer: balance >= amount
```

## Working with QEDGen (Lean 4)

Route to `ext/qedgen` for Lean 4 proofs. The workflow:

1. **Specification.** Write the Solana program specification in Lean 4.
2. **Implementation model.** Model the Rust/Anchor program in Lean 4.
3. **Proof.** Prove that the model satisfies the specification.
4. **Refinement.** Prove that the Rust implementation refines the model.

### Example: Proving No Overflow in Token Math

```lean
-- In Lean 4 (via QEDGen)
theorem no_overflow_deposit (balance : ℕ) (amount : ℕ) (h : amount ≤ balance) :
  balance + amount ≤ U64_MAX := by
  -- Proof that deposit cannot overflow
  omega

theorem share_calculation_correct (deposit total_deposits total_shares : ℕ)
  (h_total : total_deposits > 0) :
  (deposit * total_shares) / total_deposits ≤ total_shares := by
  -- Proof that shares are correctly proportional
  apply Nat.div_le_self
```

## Bounded Model Checking with Trident

```rust
// In Trident fuzz test
#[trident::invariant]
fn invariant_total_deposits_equals_sum_of_user_deposits(
    state: &ProgramState,
    users: &[UserState],
) -> bool {
    let sum: u64 = users.iter().map(|u| u.deposit).sum();
    state.total_deposits == sum
}

#[trident::invariant]
fn invariant_no_free_minting(
    state_before: &ProgramState,
    state_after: &ProgramState,
) -> bool {
    // Total supply can only increase through verified deposits
    state_after.total_supply >= state_before.total_supply
}
```

## Formal Verification Report Template

```
## Formal Verification Results

### Invariants Specified
- Total: [count]
- Proved: [count]
- Failed: [count]
- Unverified: [count]

### Bounded Model Checking
- Depth: [N transactions]
- States explored: [count]
- Invariants checked: [count]
- Violations found: [count]

### Lean 4 Proofs (if applicable)
- Theorems stated: [count]
- Theorems proved: [count]
- Theorems unproved: [count]

### Key Findings
- [List of invariant violations or unproven properties]

### Limitations
- [What couldn't be verified and why]
```