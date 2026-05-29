# azure-devops-pr-review

[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-Skill-000000?logo=githubcopilot&logoColor=white)](https://github.com/features/copilot)
[![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-0078D7?logo=azuredevops&logoColor=white)](https://azure.microsoft.com/products/devops)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Git Bash](https://img.shields.io/badge/Git_Bash-available-000000?logo=git&logoColor=white)](https://git-scm.com/download/win)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](./SKILL.md)

`azure-devops-pr-review` is a GitHub Copilot skill for structured Azure DevOps PR reviews. It runs multi-pass AI analysis, keeps only high-confidence findings, posts inline threads to the PR, and labels the PR as AI-reviewed.

## Project Name and Description

This skill implements the `review-pr` contract defined in [SKILL.md](./SKILL.md). It supports either a full PR URL or explicit PR coordinates (`organization`, `project`, `repo`, `prId`) and guides end-to-end review execution.

## Technology Stack

| Layer | Technology |
| --- | --- |
| Skill definition | Markdown + YAML front matter (`SKILL.md`) |
| CLI integration | Azure CLI + `azure-devops` extension |
| API fallback | Azure DevOps REST API (`curl`) |
| Shell/runtime | PowerShell 5.1+ and Git Bash |
| SCM operations | Git (`fetch`, `diff`) |
| Multi-model review | `gpt-5.4`, `claude-sonnet-4.6` |

## Project Architecture

This skill is specification-driven: behavior is encoded directly in `SKILL.md` as a staged operational workflow.

```text
User Request
    |
    v
Input Parsing (URL or explicit fields)
    |
    v
Eligibility Check (open, non-draft, not already reviewed)
    |
    v
Context Collection (instruction files + PR metadata + git diff)
    |
    v
Parallel Review Passes (general + specialists)
    |
    v
Confidence Filtering (only >= 75)
    |
    v
User Confirmation
    |
    v
Inline Thread Posting + AI Labels
```

## Getting Started

### Prerequisites

1. Install [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
2. Add Azure DevOps extension:
   ```powershell
   az extension add --name azure-devops
   ```
3. Sign in:
   ```powershell
   az login
   ```
4. Ensure you have permission to read PRs and post comments

### Installation

```powershell
npx skills install github:Oglaf/skills/azure-devops-pr-review
```

### Basic Usage

Ask Copilot to review an Azure DevOps PR, for example:

- `Review PR 12345 in myorg/My Project/my-repo`
- `Review https://dev.azure.com/myorg/My%20Project/_git/my-repo/pullrequest/12345`

The skill will extract missing fields when possible and ask for missing required inputs.

## Project Structure

```text
azure-devops-pr-review/
├── SKILL.md   # Source-of-truth behavior contract
└── README.md  # Developer-facing documentation
```

## Key Features

- Parallel multi-model review with deduplication
- Confidence gating (`>= 75`) to reduce false positives
- Inline PR thread posting with strict JSON payload flow
- Automatic fallback from `az repos pr show` to REST API when needed
- Context-aware review using `.github/copilot-instructions.md`, `AGENTS.md`, and `CLAUDE.md`
- Automatic `ai-reviewed` and model-specific labels

## Development Workflow

1. Parse and validate inputs
2. Configure ADO defaults and authenticate PAT context
3. Check PR eligibility
4. Gather context and diff without mutating working tree
5. Run parallel review passes and deduplicate findings
6. Filter by confidence (`>= 75`)
7. Confirm with user, then post inline comments
8. Tag PR as AI-reviewed

## Coding Standards

- Prioritize precision over coverage: report only high-confidence findings
- Do not report style-only nits unless required by instruction files
- Avoid false positives and unmodified-line comments
- Keep comments concise, specific, and actionable
- Follow Windows-first command examples and PowerShell-compatible flows

## Testing

This skill folder currently contains no dedicated automated eval harness. Validation is behavior-based against Azure DevOps PR scenarios defined in [SKILL.md](./SKILL.md), including:

- Input parsing from PR URL
- Eligibility gating
- Confidence filtering
- Thread payload format and posting flow
- AI label application

## Contributing

1. Update [SKILL.md](./SKILL.md) first; it is the source of truth.
2. Keep this skill self-contained in its own folder.
3. Preserve the existing SKILL structure (front matter + explicit operational sections).
4. Keep examples and execution guidance Windows/PowerShell friendly.
5. Update this README when behavior or required inputs change.

## License

No license file is currently present in this skill folder.
