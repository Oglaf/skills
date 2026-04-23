# GitHub Copilot Skills

[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-Skills-000000?logo=githubcopilot&logoColor=white)](https://github.com/features/copilot)
[![Markdown](https://img.shields.io/badge/Markdown-Docs-000000?logo=markdown&logoColor=white)](https://www.markdownguide.org/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Node.js](https://img.shields.io/badge/Node.js-npx-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Windows](https://img.shields.io/badge/Windows-First-0078D6?logo=windows&logoColor=white)](https://www.microsoft.com/windows)

A collection of custom GitHub Copilot skills focused on practical engineering workflows. Each top-level folder is a self-contained skill package with its own `SKILL.md`, evaluation scenarios, and any supporting scripts or docs needed by that skill.

## Included Skills

| Skill | Purpose | Implementation |
| --- | --- | --- |
| `angular-runtime-env-vars` | Fix and document runtime environment variable loading for Angular prerender/static apps, especially on Azure App Service | `SKILL.md` + `evals\evals.json` |
| `azure-devops-changelog-generator` | Generate `cards.md` and `changelog.md` from TFVC changesets or Git commits by enriching them with Azure DevOps work items | `SKILL.md` + PowerShell scripts + Python grader |

## Repository Structure

```text
skills/
├── AGENTS.md
├── README.md
├── angular-runtime-env-vars/
│   ├── README.md
│   ├── SKILL.md
│   └── evals/
│       └── evals.json
└── azure-devops-changelog-generator/
    ├── README.md
    ├── SKILL.md
    ├── evals/
    │   ├── evals.json
    │   └── grader.py
    └── scripts/
        ├── fetch-workitems.ps1
        ├── generate-cards.ps1
        └── generate-changelog.ps1
```

## Architecture

This repo is organized as a skill collection rather than a shared application. The main design rules are:

- each skill stays inside its own folder
- `SKILL.md` is the source of truth for behavior, prompts, inputs, outputs, and rules
- `evals\evals.json` mirrors the intended behavior with prompt-based evaluation cases
- helper scripts are optional and only live inside the skill that uses them

The most complete example is `azure-devops-changelog-generator`, which uses a staged pipeline:

1. parse TFVC changesets or Git commit text from the skill contract
2. fetch Azure DevOps work items and comments with `scripts\fetch-workitems.ps1`
3. render `cards.md` and `changelog.md` with dedicated PowerShell scripts
4. validate outputs against `evals\evals.json` with `evals\grader.py`

## Technology Stack

- **Primary docs/spec format:** Markdown with YAML front matter in `SKILL.md`
- **Automation:** PowerShell 5.1+ for executable helper scripts
- **Evaluation tooling:** JSON eval definitions and Python 3 for the Azure DevOps grader
- **Target environment:** Windows-first examples and PowerShell-compatible commands
- **Installation path:** `npx skills install`

## Getting Started

### Prerequisites

- Node.js and `npx` to install skills locally
- PowerShell for Windows-oriented examples
- Python 3 if you want to run the Azure DevOps grader

### Install a Skill Locally

```powershell
npx skills install .\skills\angular-runtime-env-vars
npx skills install .\skills\azure-devops-changelog-generator
```

### Explore a Skill

Open the skill folder and read:

1. `SKILL.md` for the behavior contract
2. `README.md` for human-oriented usage notes
3. `evals\evals.json` for scenario coverage

## Development Conventions

The repo conventions are defined in `AGENTS.md` and reflected across the existing skills:

- keep skills self-contained instead of sharing runtime code across folders
- preserve the current `SKILL.md` shape: YAML front matter followed by explicit operational sections
- prefer Windows paths, PowerShell examples, and environment-variable based configuration
- validate required inputs early in helper scripts and fail explicitly on missing data
- keep artifact names stable when a skill already documents them
- update eval expectations when skill behavior changes

## Testing

Current testing is skill-specific.

### Azure DevOps Changelog Generator

Run the grader for one eval case:

```powershell
python .\azure-devops-changelog-generator\evals\grader.py --eval-id 1 --run-dir C:\path\to\outputs
```

Use `--eval-id <n>` to target a specific case from `azure-devops-changelog-generator\evals\evals.json`.

### Angular Runtime Env Vars

This skill currently uses declarative eval scenarios in `evals\evals.json` and does not include a dedicated grader script.

## Skill Docs

- `angular-runtime-env-vars\README.md`
- `azure-devops-changelog-generator\README.md`
- `AGENTS.md`

## Author

Christian Fleishmann Silva (Oglaf)
