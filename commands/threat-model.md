---
description: Threat modeling session — identify attack surface, adversary profiles, and risks.
---

# /threat-model — Threat Modeling Session

Conduct a structured threat modeling session for a Solana program.

## Usage
```
/threat-model [program-path]
```

## What It Does

1. Maps the program's architecture (programs, accounts, CPIs, token flows)
2. Identifies trust assumptions
3. Models adversary profiles (opportunistic bot → nation-state)
4. Maps attack surface using STRIDE-per-instruction
5. Produces a prioritized risk list
6. Recommends audit scope and depth

## Agent Routing

Uses `security-architect` agent.