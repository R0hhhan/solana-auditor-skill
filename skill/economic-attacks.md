# Phase 4: Economic Attack Simulation

## When to Load This File

Load when the user says "economic attack", "flash loan attack", "MEV", "oracle manipulation", "is my tokenomics safe", "simulate an attack", or during Phase 4 of a deep audit.

## Attack Categories

---

## 1. Flash-Loan Attacks

### Attack Pattern

An attacker borrows a large amount of tokens without collateral (flash loan), uses them to manipulate a protocol's state within a single transaction, and extracts profit.

### Solana-Specific Considerations

- Solana doesn't have a mempool, but transactions are atomic
- Multiple instructions in one transaction can compose attacks
- Flash loans available via: Solend, Marginfi, Kamino, Drift

### Checklist

- [ ] Can a large deposit/withdraw manipulate the exchange rate?
- [ ] Can a flash-loaned amount influence governance votes?
- [ ] Can liquidation thresholds be manipulated?
- [ ] Are TWAP/oracle prices used (not spot prices)?
- [ ] Is there a minimum time between deposit and withdrawal?

### Simulation Questions

```
1. What's the maximum flash-loanable amount for each asset?
2. At what deposit size does the exchange rate deviate >1%?
3. Can a deposit → manipulate → withdraw sequence profit?
4. What's the cost of manipulation vs. potential profit?
```

---

## 2. Oracle Manipulation

### Attack Pattern

An attacker manipulates the price feed a protocol relies on, causing mispriced liquidations, bad debt, or arbitrage.

### Oracle Types on Solana

| Oracle | Type | Manipulation Resistance |
|---|---|---|
| Pyth | Push (price updates on-chain) | High — confidence intervals, multi-publisher |
| Switchboard | Push/Pull | High — multi-aggregator |
| Jupiter LP prices | On-chain AMM spot | **Low — manipulatable** |
| Custom AMM TWAP | On-chain derived | Medium — depends on window |
| Hardcoded | Static | N/A — but can become stale |

### Checklist

- [ ] Which oracle is used for price feeds?
- [ ] Is the oracle a push-based (Pyth/Switchboard) or pull-based (AMM spot)?
- [ ] Are confidence intervals checked (Pyth)?
- [ ] Is the price staleness checked?
- [ ] Is a TWAP used instead of spot price?
- [ ] Are there multiple oracle sources with deviation checks?

### Simulation Questions

```
1. What's the cost to move the spot price by 1%? 5%? 10%?
2. How much can be extracted if the price is manipulated by X%?
3. Is profit > cost for any manipulation level?
4. What's the TWAP window? Can it be manipulated within that window?
```

---

## 3. MEV / Sandwich Attacks

### Attack Pattern

An attacker observes a pending transaction and inserts their own transactions before and after to extract value.

### Solana-Specific Considerations

- No public mempool (currently) — reduces but doesn't eliminate MEV
- Leaders can order transactions within their slots
- Jito bundles and tips create MEV dynamics
- Continuous blocks (400ms) mean less MEV window than Ethereum

### Checklist

- [ ] Are there profitable arbitrage opportunities between state changes?
- [ ] Can liquidation order be gamed?
- [ ] Are there time-sensitive operations (auctions, Dutch auctions)?
- [ ] Is there slippage protection on swaps?
- [ ] Are minimum/maximum amounts validated?

### Simulation Questions

```
1. If an attacker sees a large swap, can they front-run it?
2. What's the maximum extractable value from a single transaction?
3. Are there any commit-reveal schemes that could be exploited?
4. Can transaction ordering within a slot affect outcomes?
```

---

## 4. Liquidity Attacks

### Attack Pattern

An attacker manipulates liquidity pools to extract value, typically through imbalanced deposits/withdrawals.

### Checklist

- [ ] Can a single large LP affect pool ratios significantly?
- [ ] Are there deposit/withdrawal limits?
- [ ] Is there a fee on immediate withdrawal?
- [ ] Can an attacker drain liquidity through repeated small operations?
- [ ] Are there minimum liquidity requirements?

### Simulation Questions

```
1. What deposit size causes >1% price impact?
2. Can an attacker profit from deposit → swap → withdraw?
3. Are there any "first depositor" attack vectors?
4. Can rounding in share calculation be exploited?
```

---

## 5. Governance Attacks

### Attack Pattern

An attacker acquires enough governance tokens to pass malicious proposals.

### Checklist

- [ ] What's the quorum requirement?
- [ ] What's the voting period?
- [ ] Can tokens be flash-loaned for voting? (Check snapshot timing)
- [ ] Is there a timelock on proposal execution?
- [ ] Can a single entity acquire >51% of voting power?
- [ ] Are there emergency pause mechanisms?

### Simulation Questions

```
1. What's the cost to acquire 51% of voting power?
2. What's the maximum damage from a malicious proposal?
3. Is the timelock long enough for users to exit?
4. Can the multisig veto malicious proposals?
```

---

## 6. Incentive Analysis

### Attack Pattern

Economic incentives are misaligned, causing rational actors to behave in ways that harm the protocol.

### Checklist

- [ ] Are staking rewards > inflation + opportunity cost?
- [ ] Can users extract more value by gaming the system than using it honestly?
- [ ] Are there "risk-free" arbitrage opportunities?
- [ ] Do early users have disproportionate advantages?
- [ ] Are referral/affiliate programs exploitable?
- [ ] Can wash trading generate artificial rewards?

### Simulation Questions

```
1. What's the expected ROI for honest usage vs. gaming?
2. Are there any "free money" paths (airdrop farming, wash trading)?
3. Do incentives align long-term holders or short-term extractors?
4. What happens when rewards decrease over time?
```

---

## Economic Attack Report Template

```
## Economic Attack Simulation Results

### Protocol: [name]
### TVL: [amount]
### Simulation Date: [date]

### 1. Flash-Loan Attack Analysis
- Maximum flash-loanable amount: [amount]
- Manipulation threshold: [% deviation at $X deposit]
- Profitable attack found: [YES/NO]
- If yes: [description, required capital, expected profit]

### 2. Oracle Manipulation Analysis
- Oracle type: [Pyth/Switchboard/AMM/other]
- Manipulation cost for 5% deviation: [$amount]
- Extractable value at 5% deviation: [$amount]
- Risk level: [LOW/MEDIUM/HIGH/CRITICAL]

### 3. MEV Analysis
- Maximum extractable value per tx: [$amount]
- Sandwich attack feasible: [YES/NO]
- Risk level: [LOW/MEDIUM/HIGH/CRITICAL]

### 4. Liquidity Attack Analysis
- Price impact at $10K: [%]
- Price impact at $100K: [%]
- Price impact at $1M: [%]
- Risk level: [LOW/MEDIUM/HIGH/CRITICAL]

### 5. Governance Attack Analysis
- 51% attack cost: [$amount]
- Timelock period: [hours/days]
- Emergency controls: [list]
- Risk level: [LOW/MEDIUM/HIGH/CRITICAL]

### 6. Incentive Analysis
- Honest user ROI: [%]
- Gaming ROI: [%]
- Incentive alignment: [GOOD/NEUTRAL/POOR]
- Risk level: [LOW/MEDIUM/HIGH/CRITICAL]

### Overall Economic Risk: [LOW/MEDIUM/HIGH/CRITICAL]
### Key Recommendations:
1. [recommendation]
2. [recommendation]
...
```