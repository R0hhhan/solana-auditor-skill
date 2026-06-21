# Tool Reference Cards

## When to Load This File

Load when setting up or running any automated tool during Phase 1, or when the user asks "how do I run X tool".

---

## Anchor CLI

```bash
# Build
anchor build

# Build with verbose output
anchor build -- --verbose

# Test
anchor test

# Test with specific test file
anchor test -- --test-file tests/my_test.ts

# Deploy to devnet
anchor deploy --provider.cluster devnet

# Upgrade
anchor upgrade --provider.cluster mainnet --program-id <PROGRAM_ID>

# IDL commands
anchor idl init --filepath target/idl/my_program.json <PROGRAM_ID>
anchor idl upgrade --filepath target/idl/my_program.json <PROGRAM_ID>
```

---

## Cargo Clippy

```bash
# Run clippy
cargo clippy -- -D warnings

# Run with all lints
cargo clippy --all-targets --all-features -- -D warnings

# Auto-fix some issues
cargo clippy --fix --allow-dirty

# Specific lint groups
cargo clippy -- -W clippy::arithmetic_side_effects
cargo clippy -- -W clippy::unwrap_used
cargo clippy -- -W clippy::indexing_slicing
```

---

## cargo-audit

```bash
# Install
cargo install cargo-audit

# Run audit
cargo audit

# Output as JSON
cargo audit --json

# Ignore specific advisory
cargo audit --ignore RUSTSEC-2024-XXXX
```

---

## cargo-deny

```bash
# Install
cargo install cargo-deny

# Initialize config
cargo deny init

# Check all
cargo deny check

# Check only licenses
cargo deny check licenses

# Check only bans
cargo deny check bans

# Check only sources
cargo deny check sources
```

---

## Trident (Fuzzing)

```bash
# Install
cargo install trident-cli

# Initialize in project
trident init

# Create new fuzz test
trident fuzz add fuzz_0

# Run fuzzer
trident fuzz run fuzz_0

# Run with specific iterations
trident fuzz run fuzz_0 --iterations 100000

# Debug a crash
trident fuzz debug fuzz_0 <CRASH_FILE>
```

---

## Mollusk

```bash
# Add to Cargo.toml
[dev-dependencies]
mollusk = "0.1"

# Run tests
cargo test --test mollusk_test
```

---

## LiteSVM

```bash
# Add to Cargo.toml
[dev-dependencies]
litesvm = "0.1"

# Run tests
cargo test --test litesvm_test
```

---

## Surfpool

```bash
# Install
cargo install surfpool-cli

# Start local validator
surfpool start

# Start mainnet fork
surfpool start --fork mainnet

# Start with specific slot
surfpool start --fork mainnet --slot 300000000

# Stop
surfpool stop

# Get status
surfpool status
```

---

## Semgrep

```bash
# Install
pip install semgrep

# Run with auto config
semgrep --config=auto --lang=rust .

# Run with custom rules
semgrep --config=path/to/rules/ .

# Output as JSON
semgrep --config=auto --lang=rust --json -o results.json .
```

---

## Solana CLI (Verification)

```bash
# Verify deployed program
solana program show <PROGRAM_ID>

# Verify buffer
solana program show --buffers

# Get program logs
solana logs <PROGRAM_ID>

# Get transaction details
solana transaction <TX_SIGNATURE>

# Simulate transaction
solana simulate-tx <TX_SIGNATURE>
```

---

## Solana Verify (OSS Verification)

```bash
# Install
cargo install solana-verify

# Verify on-chain program matches source
solana-verify verify-from-repo --url mainnet-beta \
  --program-id <PROGRAM_ID> \
  --repository <GITHUB_URL> \
  --commit-hash <COMMIT>
```