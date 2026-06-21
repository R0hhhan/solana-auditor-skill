# Phase 2: Manual Deep Review

## When to Load This File

Load when starting Phase 2 of an audit, or when the user says "deep review", "manual audit", "code review", "check my access control", "review my CPIs".

## Review Domains

Work through these 8 domains systematically. For each domain, check every instruction in scope.

---

## Domain 1: Access Control

### 1.1 Signer Verification

Every instruction that modifies state or moves funds must verify the signer.

```rust
// CHECK: Does every mutable account have a corresponding signer?
// CHECK: Are signer checks done BEFORE any state changes?
// CHECK: Is the Signer constraint used (Anchor) or signer.is_signer checked (native)?
```

**Checklist:**
- [ ] All mutable accounts have a verified signer or PDA authority
- [ ] Signer checks happen before state mutations
- [ ] No `#[account(signer)]` on accounts that shouldn't sign
- [ ] Multisig instructions validate threshold and signers

### 1.2 Owner Verification

```rust
// CHECK: For non-PDA accounts, is the owner field validated?
// CHECK: Are token account owners checked before token operations?
```

**Checklist:**
- [ ] Token account owner is validated before transfers
- [ ] Account owner is checked before data modification
- [ ] Owner checks use `require_keys_eq!` not `==`

### 1.3 PDA Authority

```rust
// CHECK: Are PDA seeds correctly derived?
// CHECK: Can an attacker provide seeds that create a different PDA?
// CHECK: Are bump seeds validated?
```

**Checklist:**
- [ ] PDA seeds include unique identifiers (not just static strings)
- [ ] Bump seeds are stored and validated (not recomputed)
- [ ] No PDA collisions possible with different seed combinations
- [ ] `invoke_signed` uses correct seeds and bump

### 1.4 Upgrade Authority

```rust
// CHECK: Is the program upgradeable? Who holds the authority?
// CHECK: Is the upgrade authority a multisig?
// CHECK: Can the upgrade authority rug users?
```

**Checklist:**
- [ ] Upgrade authority is documented
- [ ] Upgrade authority is a multisig (recommended for TVL > $100K)
- [ ] Users are aware of upgradeability
- [ ] Immutable programs preferred unless upgrade path is needed

---

## Domain 2: Arithmetic Safety

### 2.1 Overflow / Underflow

```rust
// CHECK: All arithmetic uses checked_*, saturating_*, or wrapping_* variants
// CHECK: No bare +, -, * on user-controlled values
// CHECK: Division by zero is handled
```

**Checklist:**
- [ ] All arithmetic on user inputs uses checked operations
- [ ] No unchecked casts between numeric types
- [ ] Division/modulo operations check for zero
- [ ] Multiplication before division preserves precision correctly

### 2.2 Rounding Direction

```rust
// CHECK: Does rounding favor the protocol or the user?
// CHECK: Is the rounding direction documented?
// CHECK: Can rounding be exploited over many transactions?
```

**Checklist:**
- [ ] Rounding direction is explicit and documented
- [ ] Rounding cannot be exploited through repeated transactions
- [ ] Fee calculations round in protocol's favor (or are explicitly user-favoring)
- [ ] Dust amounts are handled (minimum thresholds)

### 2.3 Precision Loss

```rust
// CHECK: Are intermediate calculations done at higher precision?
// CHECK: Is the order of operations correct (multiply before divide)?
```

**Checklist:**
- [ ] Multiplication happens before division where possible
- [ ] Intermediate values use u128 or wider types
- [ ] Token decimal conversions are correct
- [ ] Price/rate calculations use sufficient precision

---

## Domain 3: Account Validation

### 3.1 Account Type Verification (Discriminator)

```rust
// CHECK: Does every account check its type before reading/writing?
// CHECK: Anchor: #[account] macro adds discriminator automatically
// CHECK: Native: Manual discriminator check at start of instruction
```

**Checklist:**
- [ ] All accounts have type verification (Anchor discriminator or manual)
- [ ] Account type is checked BEFORE any data is read
- [ ] Cannot pass wrong account type to an instruction

### 3.2 Account Initialization

```rust
// CHECK: Is init used correctly? Can accounts be reinitialized?
// CHECK: Are init_if_needed and realloc used safely?
```

**Checklist:**
- [ ] `#[account(init)]` used for new accounts (prevents reinit)
- [ ] `init_if_needed` only used when reinitialization is explicitly desired
- [ ] `realloc` validates new size and payer
- [ ] No account can be initialized twice by different parties

### 3.3 Account Closing

```rust
// CHECK: When closing an account, is the destination validated?
// CHECK: Is the lamport destination the intended recipient?
// CHECK: Are close authority attacks prevented?
```

**Checklist:**
- [ ] `close` constraint specifies a validated destination
- [ ] Close authority is the intended party (not attacker-controlled)
- [ ] Token accounts are closed properly (no close_authority abuse)
- [ ] Rent-exempt lamports go to the correct destination

### 3.4 PDA Seed Validation

```rust
// CHECK: Are all PDA seeds validated before use?
// CHECK: Can an attacker control any seed component?
// CHECK: Are seeds deterministic and collision-resistant?
```

**Checklist:**
- [ ] All seed components are validated
- [ ] No user-controlled seeds without validation
- [ ] Seeds include unique identifiers (user pubkey, mint, etc.)
- [ ] Seeds cannot be front-run (no predictable sequential IDs)

---

## Domain 4: CPI Safety

### 4.1 Program ID Verification

```rust
// CHECK: Are CPI target programs verified?
// CHECK: Is the program ID hardcoded or from a verified source?
```

**Checklist:**
- [ ] CPI program IDs are hardcoded constants or from verified storage
- [ ] No user-supplied program IDs for CPI calls
- [ ] Program IDs match expected values (Token Program, Associated Token Program, etc.)

### 4.2 Account Ordering

```rust
// CHECK: Are accounts passed to CPI in the correct order?
// CHECK: Does the CPI instruction expect accounts in a specific order?
```

**Checklist:**
- [ ] Account order matches the target program's expected order
- [ ] All required accounts are included
- [ ] No extra accounts that could cause unexpected behavior

### 4.3 Privilege Escalation via CPI

```rust
// CHECK: Can an attacker use this program as a proxy to call privileged instructions?
// CHECK: Does the program act as a signer for operations it shouldn't?
```

**Checklist:**
- [ ] Program only signs CPIs it explicitly intends to authorize
- [ ] No "passthrough" instructions that forward arbitrary CPIs
- [ ] PDA signers are only used for their intended purpose

### 4.4 Reentrancy via CPI

```rust
// CHECK: Can state be modified after a CPI but before the instruction ends?
// CHECK: Is the checks-effects-interactions pattern followed?
```

**Checklist:**
- [ ] State changes happen BEFORE external CPIs (checks-effects-interactions)
- [ ] No state reads after CPIs that could be stale
- [ ] Cross-program reentrancy is considered (program A → B → A)
- [ ] Reentrancy locks if needed for complex flows

---

## Domain 5: State Machine Integrity

### 5.1 Invalid State Transitions

```rust
// CHECK: Are all valid state transitions enumerated?
// CHECK: Can the state be moved to an invalid combination?
```

**Checklist:**
- [ ] State enum covers all valid states
- [ ] Transitions are explicitly validated
- [ ] No way to skip states or move backwards inappropriately
- [ ] Terminal states cannot be exited

### 5.2 Race Conditions

```rust
// CHECK: Can two transactions race to modify the same state?
// CHECK: Are there time-of-check-time-of-use (TOCTOU) issues?
```

**Checklist:**
- [ ] State reads and writes are atomic within a transaction
- [ ] No TOCTOU between account read and write
- [ ] Concurrent access patterns are safe (Solana transactions are serial)

### 5.3 Timestamp / Slot Dependence

```rust
// CHECK: Does the program use Clock::get()? Is it validated?
// CHECK: Can timestamp manipulation affect outcomes?
```

**Checklist:**
- [ ] Clock usage is documented and justified
- [ ] Timestamp is not used for critical randomness
- [ ] Slot-based logic accounts for slot drift
- [ ] Time-based constraints have reasonable bounds

---

## Domain 6: Token Program Interactions

### 6.1 Token Account Validation

```rust
// CHECK: Is the token account's mint verified?
// CHECK: Is the token account's owner verified?
// CHECK: Is the token account initialized?
```

**Checklist:**
- [ ] Token account mint matches expected mint
- [ ] Token account owner is the expected party
- [ ] Token account is initialized (not closed)
- [ ] Token account is not frozen (if relevant)

### 6.2 Delegate Abuse

```rust
// CHECK: Can a delegate drain funds?
// CHECK: Is the delegate field checked before transfers?
```

**Checklist:**
- [ ] Delegate field is checked or cleared before sensitive operations
- [ ] Delegates cannot perform unauthorized transfers
- [ ] Close authority is validated

### 6.3 Token-2022 Extensions

```rust
// CHECK: If using Token-2022, are extensions handled correctly?
// CHECK: Transfer hooks, confidential transfers, metadata, etc.
```

**Checklist:**
- [ ] Transfer hook programs are trusted
- [ ] Confidential transfer amounts are validated
- [ ] Metadata pointer and transfer fee extensions are accounted for
- [ ] Permanent delegate cannot be abused

---

## Domain 7: Cross-Program Invocation (Composability)

### 7.1 External Program Dependencies

```rust
// CHECK: What external programs does this program depend on?
// CHECK: What happens if an external program is upgraded?
// CHECK: What happens if an external program is frozen/deprecated?
```

**Checklist:**
- [ ] External program dependencies are documented
- [ ] Upgrade risks of external programs are assessed
- [ ] Fallback behavior if external program is unavailable
- [ ] Version checks for external programs if applicable

### 7.2 Composability Attack Vectors

```rust
// CHECK: Can an attacker compose this program with another to exploit it?
// CHECK: Are there unexpected interactions between instructions?
```

**Checklist:**
- [ ] Multi-program attack scenarios are considered
- [ ] Flash-loan + program interaction is analyzed
- [ ] Instruction ordering within a transaction is safe

---

## Domain 8: Upgradeability & Deployment

### 8.1 Upgrade Authority Risks

```rust
// CHECK: Who can upgrade the program?
// CHECK: Can the upgrade authority be compromised?
```

**Checklist:**
- [ ] Upgrade authority is a multisig (recommended)
- [ ] Upgrade timelock is considered for high-TVL programs
- [ ] Users can verify the deployed program hash
- [ ] Immutable program is preferred unless upgrade path is essential

### 8.2 Proxy Patterns

```rust
// CHECK: Does the program use a proxy pattern?
// CHECK: Can the proxy be upgraded to point to a malicious implementation?
```

**Checklist:**
- [ ] Proxy upgrade is gated by multisig or governance
- [ ] Proxy implementation address is verified
- [ ] Data migration between implementations is safe
- [ ] Proxy storage collisions are prevented

### 8.3 Deployment Safety

```rust
// CHECK: Is the deployment key secure?
// CHECK: Are program buffers verified before upgrade?
```

**Checklist:**
- [ ] Deployment key is secured (hardware wallet, multisig)
- [ ] Buffer contents are verified before `upgrade` command
- [ ] Devnet deployment is tested before mainnet
- [ ] Program ID is consistent across networks (or documented differences)

---

## Manual Review Summary Template

After completing all 8 domains:

```
## Manual Review Results

### Domain 1: Access Control
- Findings: [count]
- Critical: [list]
- High: [list]

### Domain 2: Arithmetic Safety
- Findings: [count]
- ...

### Domain 3: Account Validation
...

### Domain 4: CPI Safety
...

### Domain 5: State Machine Integrity
...

### Domain 6: Token Program Interactions
...

### Domain 7: Cross-Program Invocation
...

### Domain 8: Upgradeability & Deployment
...

### Overall
- Total manual findings: [count]
- Critical: [count]
- High: [count]
- Medium: [count]
- Low: [count]
- Info: [count]
```