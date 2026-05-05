# azure-devops-pr-review

[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-Skill-000000?logo=githubcopilot&logoColor=white)](https://github.com/features/copilot)
[![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-0078D7?logo=azuredevops&logoColor=white)](https://azure.microsoft.com/products/devops)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](./SKILL.md)

Structured, multi-pass code review for Azure DevOps pull requests. Posts actionable inline comments directly to ADO using multiple AI models in parallel, deduplicates findings, and tags the PR as AI-reviewed.

---

## Key Features

- **Multi-model review** — runs `gpt-5.4` and `claude-sonnet-4.6` in parallel, plus domain-specific specialist agents when the diff warrants it
- **Confidence filtering** — only reports issues with a confidence score ≥ 75, cutting noise from false positives and stylistic nits
- **Inline comments** — posts one thread per issue directly to the ADO PR via `az devops invoke`
- **Instruction-file awareness** — reads `.github/copilot-instructions.md`, `AGENTS.md`, and `CLAUDE.md` in the modified directories before reviewing
- **Eligibility guard** — skips PRs that are draft, closed, or already reviewed by the agent
- **AI label tagging** — adds `ai-reviewed` and per-model labels to every reviewed PR

---

## Technology Stack

| Layer | Technology |
|---|---|
| CLI tooling | Azure DevOps CLI (`az repos`, `az devops`) |
| Version control | Git |
| Scripting | PowerShell 5.1+ |
| AI review models | `gpt-5.4`, `claude-sonnet-4.6` |
| Skill spec | Markdown + YAML front matter (`SKILL.md`) |

---

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with the `azure-devops` extension:
  ```powershell
  az extension add --name azure-devops
  az login
  az devops configure --defaults organization=https://dev.azure.com/{organization}
  ```
- Git installed and the target repository cloned locally
- Sufficient ADO permissions to read PRs and post comments

---

## Installation

```powershell
npx skills install github:Oglaf/skills/azure-devops-pr-review
```

---

## Usage

Trigger the skill by asking Copilot to review a PR:

> "Review PR 1234 in the myproject repo"  
> "Can you do a code review on pull request 5678?"  
> "Look at the changes in ADO PR #999"

### Required Inputs

| Input | Description | Example |
|---|---|---|
| `prId` | Pull request ID | `1234` |
| `organization` | Azure DevOps org name | `myorg` |
| `project` | Project name or ID | `MyProject` |
| `repo` | Repository name or ID | `my-service` |

If any input is missing, the skill will ask before proceeding.

---

## Workflow

```
1. Check Eligibility     → open, not draft, not already reviewed
2. Get Context           → instruction files + PR diff + policy status
3. Review the Changes    → parallel specialist + general agent passes
4. Validate Issues       → confidence scoring, filter < 75
5. Post Review           → confirm with user, post inline threads
6. Tag PR                → add ai-reviewed + model labels
```

### Confidence Score Reference

| Score | Meaning |
|---:|---|
| 0–25 | False positive / stylistic |
| 50 | Minor issue |
| 75 | Important issue |
| 100 | Definite problem |

Only issues scoring **≥ 75** are posted.

---

## Inline Comment Format

Each posted thread follows this template:

```
<brief issue title>

<why this is a problem in this specific code path>

<clear, actionable suggestion>

🤖 Generated with AI
```

---

## What the Skill Will NOT Report

- Pre-existing issues unrelated to the diff
- CI/linter/type errors
- Minor stylistic concerns (unless mandated by instruction files)
- Intentional changes
- Issues in unmodified lines
- Missing tests or docs (unless explicitly required)

---

## Project Structure

```text
azure-devops-pr-review/
├── README.md        ← this file
└── SKILL.md         ← operational contract (inputs, workflow, rules)
```

---

## Contributing

1. Edit `SKILL.md` to change behavior — it is the source of truth
2. Keep the skill self-contained; do not add shared runtime dependencies
3. If you add scripts, follow the PowerShell pattern used in `azure-devops-changelog-generator`
4. If behavior changes, add or update `evals/evals.json` to reflect new expectations

---

## Author

Christian Fleishmann Silva (Oglaf)
