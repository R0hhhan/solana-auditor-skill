---
description: Generate a professional audit report from findings across all phases.
---

# /audit-report — Generate Audit Report

Compile all security findings into a professional audit report.

## Usage
```
/audit-report [--format markdown|pdf|json]
```

## What It Does

1. Gathers findings from all audit phases
2. Organizes by severity (Critical → Info)
3. Generates executive summary
4. Documents each finding with description, impact, PoC, and remediation
5. Creates severity distribution charts
6. Produces remediation roadmap
7. Includes methodology notes and disclaimer

## Output

A complete audit report with all standard sections:
- Executive Summary
- Scope
- Findings Detail
- Severity Distribution
- Threat Model Summary
- Automated Scan Results
- Remediation Roadmap
- Appendix

## Agent Routing

Uses `audit-reporter` agent.