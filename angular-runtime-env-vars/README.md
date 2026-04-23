# Angular Runtime Env Vars

Use this skill to make Angular prerender or static deployments read environment values at runtime instead of baking them in at build time, with a focus on Azure App Service deployments.

## Quick Start

Install directly from GitHub:

```powershell
npx skills install github:Oglaf/skills/skills/angular-runtime-env-vars
```

## Overview

This skill helps diagnose and fix the common runtime-config problems behind stale frontend environment values:

- runtime config loaded in the wrong place or order
- startup injection that only works while placeholders are still present
- cached `runtime-config.js` responses serving outdated values
- Azure App Service startup commands pointing at the wrong server entrypoint

## What the Skill Does

1. Detects the current runtime-config boundary (`window.__...`, `assets/runtime-config.js`, `environment*.ts`, and `index.html` script order).
2. Implements or fixes startup-time environment injection in `server.js` or the active startup server.
3. Adds cache protection for `/assets/runtime-config.js` so changed values are not reused.
4. Verifies Azure App Service Linux startup behavior and resolved dist paths.
5. Updates docs so the documented deployment flow matches the implemented runtime behavior.

## Trigger Examples

Use this skill for requests such as:

- "Make this variable a env var"
- "Why is API URL still old after changing env var?"
- "runtime-config.js still has old value"
- "Angular prerender env var strategy on Azure"
- "How to support multiple env vars without rebuild"

## Runtime Architecture

```text
Azure App Settings / process.env
              |
              v
startup server (for example server.js)
              |
              v
assets/runtime-config.js
              |
              v
window.__APP_RUNTIME_CONFIG__
              |
              v
Angular environment reads runtime values
```

The skill treats `runtime-config.js` plus the startup server as the runtime boundary that must be correct on every restart.

## Implementation Checklist

### Frontend runtime contract

- Define a global runtime object in `src/assets/runtime-config.js`, for example:

```js
window.__APP_RUNTIME_CONFIG__ = { apiUrl: '#{API_URL}#' };
```

- Read values from that runtime object in Angular environments, for example:

```ts
apiUrl: window.__APP_RUNTIME_CONFIG__?.apiUrl || ''
```

- Load the runtime config before the main Angular bundle in `index.html`.

### Server-side injection

In `server.js` or the active startup server:

- resolve the actual deployed `assets/runtime-config.js`
- read values from `process.env`
- replace current values even when placeholders were already replaced on a previous run
- write the updated runtime config before serving requests
- log the resolved path and injection result clearly enough to debug path or key mismatches

### Caching guardrail

For `/assets/runtime-config.js`, send:

- `Cache-Control: no-store, no-cache, must-revalidate`
- `Pragma: no-cache`
- `Expires: 0`

## Azure App Service Checks

Verify that:

1. the startup command points to the intended `server.js`
2. App Setting names match the keys read in code
3. the app restarts after env var changes
4. the deployed `assets/runtime-config.js` exists in the resolved dist path

## Troubleshooting Heuristics

- **Old API URL after an env var update**: injection likely only replaces placeholders, or `runtime-config.js` is cached.
- **Env var appears ignored**: the startup script path or env var name likely does not match the deployed code.
- **Works locally but not on Azure**: the runtime config file path likely differs between local dist output and Azure deployment layout.

## Output Format

Expected responses from this skill should include:

1. what changed, including affected files and behavior impact
2. exact App Service settings or checks to apply
3. a short verification sequence, including a cache-busted `runtime-config.js` check

## Project Structure

```text
angular-runtime-env-vars/
├── README.md
├── SKILL.md
└── evals/
    └── evals.json
```

## Development and Testing

- Main skill definition: `SKILL.md`
- Scenario coverage: `evals\evals.json`

This skill currently includes prompt/eval definitions only; there is no dedicated grader script in this folder.

## Installation

Install directly from GitHub with:

```powershell
npx skills install github:Oglaf/skills/skills/angular-runtime-env-vars
```

## Author

Christian Fleishmann Silva (Oglaf)
