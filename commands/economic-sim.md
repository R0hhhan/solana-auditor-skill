---
description: Economic attack simulation — flash loans, oracle manipulation, MEV, liquidity, governance, incentives.
---

# /economic-sim — Economic Attack Simulation

Simulate economic attack vectors against a Solana DeFi program.

## Usage
```
/economic-sim [program-path] [--attack <type>]
```

## What It Does

Simulates 6 categories of economic attacks:
1. Flash-loan attacks
2. Oracle manipulation
3. MEV / sandwich attacks
4. Liquidity attacks
5. Governance attacks
6. Incentive analysis

## Options

| Option | Description |
|---|---|
| `--attack flash-loan` | Flash-loan attack simulation only |
| `--attack oracle` | Oracle manipulation analysis only |
| `--attack mev` | MEV / sandwich attack analysis only |
| `--attack liquidity` | Liquidity attack simulation only |
| `--attack governance` | Governance attack analysis only |
| `--attack incentives` | Incentive alignment review only |
| `--attack all` | All categories (default) |

## Agent Routing

Uses `economic-analyst` agent.