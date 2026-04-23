# Azure DevOps Release Changelog Generator

[![Version](https://img.shields.io/badge/version-2.0.0-blue)](https://github.com/Oglaf/azure-devops-changelog-generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)](https://docs.microsoft.com/en-us/powershell/)

An AI-powered skill that generates structured release documentation from Azure DevOps TFVC changesets or Git commits by retrieving associated work items and analyzing their full context.

## Overview

This skill extracts work item IDs from commit messages, queries the Azure DevOps REST API to fetch work item details including titles, descriptions, and discussion comments, and generates two output files:

- **`cards.md`** - Detailed card list with metadata
- **`changelog.md`** - Release-style changelog grouped by Azure DevOps project

## Features

- **Organization-agnostic**: Works with any Azure DevOps organization
- **Dual version control support**: Works with both TFVC changesets and Git commits
- **Project-based grouping**: Groups changes by Azure DevOps project name
- **Rich context analysis**: Reads work item titles, descriptions, AND discussion comments
- **AI-generated summaries**: Produces concise, meaningful one-sentence descriptions
- **Deduplication**: Removes duplicate work items referenced by multiple changesets/commits
- **Category classification**: Automatically categorizes as New Features, Bug Fixes, or Improvements

## Technology Stack

- **Language**: PowerShell 5.1+
- **Platform**: Windows
- **APIs**: Azure DevOps REST API
  - Work Item API: `https://dev.azure.com/{organization}/_apis/wit/workitems/{id}?api-version=7.0`
  - Work Item Comments API: `https://dev.azure.com/{organization}/_apis/wit/workItems/{id}/comments?api-version=7.0-preview`
- **Authentication**: Azure DevOps Personal Access Token (PAT) via `$env:DEVOPS_PAT`
- **Evaluation**: Python 3 (for grading)

## Architecture

```
User Input (TFVC/Git commits)
         │
         ▼
┌─────────────────────────┐
│  Extract Work Item IDs  │
│  from commit messages  │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Azure DevOps API      │
│  Fetch work items +    │
│  discussion comments   │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Context Analysis      │
│  (title + description   │
│   + comments)          │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Generate Output       │
│  - cards.md            │
│  - changelog.md        │
└─────────────────────────┘
```

## Requirements

- Azure DevOps Personal Access Token (PAT) stored in `$env:DEVOPS_PAT`
- PowerShell 5.1+
- Optional: Node.js/npm (for skill installation via `npx skills`)

## Installation

Install the skill locally using `npx skills`:

```powershell
# Install from local path
npx skills install ./skills/azure-devops-changelog-generator

# Install from GitHub
npx skills install github:Oglaf/azure-devops-changelog-generator
```

## Project Structure

```
azure-devops-changelog-generator/
├── skills/
│   └── azure-devops-changelog-generator/
│       ├── SKILL.md                    # Skill definition (main spec)
│       ├── scripts/                    # PowerShell helper scripts
│       │   ├── fetch-workitems.ps1     # Fetches work items from Azure DevOps API
│       │   ├── generate-cards.ps1      # Generates cards.md from workitems.json
│       │   └── generate-changelog.ps1  # Generates changelog.md from workitems.json
│       └── evals/                      # Evaluation/grading data
│           ├── evals.json              # Eval test cases
│           ├── grader.py               # Python grading script
│           └── mock-run/               # Mock run data
├── .gitignore
└── README.md
```

## Quick Start

Set your Azure DevOps PAT:

```powershell
$env:DEVOPS_PAT = 'your-personal-access-token'
$Organization = 'your-org-name'
```

## Scripts

| Script | Description |
|--------|-------------|
| `fetch-workitems.ps1` | Fetches work items from Azure DevOps API |
| `generate-cards.ps1` | Generates cards.md from workitems.json |
| `generate-changelog.ps1` | Generates changelog.md grouped by project |

## Output Format

### cards.md
Contains detailed card information:
- Work item ID, title, and type
- State and assignee
- Project name
- Direct link to Azure DevOps work item
- AI-generated summary from title + description + comments

### changelog.md
Release-style changelog grouped by Azure DevOps project:
- Lists projects involved in the release
- Groups items by project
- Categorizes as: **New Features** (User Stories), **Bug Fixes** (Bugs), **Improvements** (Tasks)

## Development Workflow

1. User triggers the skill with TFVC changesets or Git commits
2. Skill prompts for organization name and version control type (TFVC or Git)
3. Work item IDs are extracted from commit messages
4. Azure DevOps API is called to fetch work items + comments
5. Context analysis combines title, description, and discussion comments
6. Output files generated: `cards.md` and `changelog.md`

## Coding Standards

- One-sentence changelog summaries that reflect **actual functional impact**
- Summaries MUST derive from discussion/comments (not just copy title/description)
- Preserve original language of cards
- Group by project name (System.Project field), not by language
- Use direct links to Azure DevOps work items
- Include assignee information

## Testing

The project includes a Python-based evaluation framework for testing:

```powershell
# Run the grader
python .\skills\azure-devops-changelog-generator\evals\grader.py
```

Test cases in `evals/evals.json` cover:
1. Single work item processing
2. Multiple IDs with project grouping
3. Edge cases: deduplication and odd ID formats

## License

[MIT](https://opensource.org/licenses/MIT)

## Author

Christian Fleishmann Silva (Oglaf)
