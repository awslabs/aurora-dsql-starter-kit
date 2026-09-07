# AGENTS.md Auto-Generation Setup

This repository uses a GitHub Action to automatically generate and maintain an `AGENTS.md` file that provides AI agents with comprehensive documentation about Aurora DSQL.

## Overview

The `AGENTS.md` file is automatically generated from the documentation sources and kept up-to-date through CI/CD. This ensures:

- ✅ Always up-to-date documentation for AI agents
- ✅ No manual edits required
- ✅ Deterministic output
- ✅ PR diffs when documentation changes
- ✅ High efficacy for LLM consumption

## How It Works

### GitHub Action Workflow

The workflow (`.github/workflows/generate-agents.yml`) runs on:

- **Push to main**: Automatically regenerates and commits AGENTS.md if documentation changes
- **Pull requests**: Checks if AGENTS.md needs updating and comments on the PR
- **Manual trigger**: Can be run manually via workflow_dispatch

### Configuration

The generation is configured via `agents.config.json` which specifies:

- **Sources**: Which markdown files to include
- **Sections**: How to organize the content
- **Output**: Where to write the generated file

### Workflow Steps

1. **Checkout**: Fetches the repository with full history
2. **Setup Node.js**: Installs Node.js 18 for npx
3. **Generate**: Runs `npx agents-md compose` to create AGENTS.md
4. **Check Changes**: Detects if AGENTS.md was modified
5. **Commit** (on main): Auto-commits changes with bot account
6. **Comment** (on PRs): Notifies if regeneration is needed

## Local Development

### Generate AGENTS.md Locally

To generate the AGENTS.md file locally:

```bash
npx agents-md compose
```

This will:
- Read the configuration from `agents.config.json`
- Process all markdown files in the documentation
- Generate a consolidated `AGENTS.md` file

### Testing Changes

Before pushing documentation changes:

1. Make your documentation edits
2. Run `npx agents-md compose` locally
3. Review the generated `AGENTS.md` diff
4. Commit both your changes and the updated `AGENTS.md`

## Configuration Details

### agents-md.config.ts Structure

```typescript
import type { AgentsMdConfig } from 'agents-md'

export default {
  include: [
    '**/agents-md/**/*.md',
    '**/*.agents.md',
    'documentation/docs/**/*.md',
    'README.md',
  ],
  exclude: [
    'documentation/docs/.snippets/**',
    'node_modules/**',
    'site/**',
    '.cache/**',
  ],
} satisfies AgentsMdConfig
```

### How agents-md Works

The agents-md tool uses a fragment-based approach:

1. **Source Files**: Create `*.agents.md` files or regular `.md` files
2. **Configuration**: Define which files to include/exclude in `agents-md.config.ts`
3. **Composition**: Run `npx agents-md compose` to generate `AGENTS.md`
4. **Output**: All fragments are composed into a single `AGENTS.md` file

### Modifying the Configuration

To change what's included in AGENTS.md:

1. Edit `agents-md.config.ts`
2. Add/remove patterns from the `include` array
3. Update the `exclude` array to filter out unwanted files
4. Run `npx agents-md compose` to test
5. Commit the configuration changes

### Creating Content

You can add content to AGENTS.md in two ways:

1. **Create `*.agents.md` files**: These are fragment files specifically for agents
2. **Include existing `.md` files**: Add patterns to the `include` array in config

## Accessing AGENTS.md

Once deployed, the AGENTS.md file will be available at:

- **GitHub**: `https://github.com/awslabs/aurora-dsql-starter-kit/blob/main/AGENTS.md`
- **Raw**: `https://raw.githubusercontent.com/awslabs/aurora-dsql-starter-kit/main/AGENTS.md`

AI agents can reference this file for comprehensive, up-to-date documentation about Aurora DSQL.

## Troubleshooting

### Workflow Fails

If the GitHub Action fails:

1. Check the workflow logs in the Actions tab
2. Verify `agents.config.json` is valid JSON
3. Ensure all referenced files exist
4. Test locally with `npx agents-md compose`

### AGENTS.md Not Updating

If AGENTS.md isn't updating automatically:

1. Verify the workflow has write permissions
2. Check that changes are in the `documentation/` directory
3. Ensure the workflow file path is correct
4. Manually trigger the workflow to test

### Local Generation Issues

If `npx agents-md compose` fails locally:

1. Ensure Node.js 18+ is installed
2. Check that `agents.config.json` exists
3. Verify file paths in the config are correct
4. Check for syntax errors in markdown files

## Benefits

This automated approach provides:

- **Consistency**: Same generation process in CI and locally
- **Transparency**: All changes visible in git history
- **Reliability**: Deterministic output every time
- **Maintainability**: No manual synchronization needed
- **Quality**: PR reviews catch documentation issues early

## Related Files

- `.github/workflows/generate-agents.yml` - GitHub Action workflow
- `agents.config.json` - Configuration for generation
- `AGENTS.md` - Generated output (auto-maintained)
- `documentation/docs/**/*.md` - Source documentation files

## Additional Resources

- [agents-md npm package](https://www.npmjs.com/package/agents-md)
- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [Aurora DSQL Documentation](https://awslabs.github.io/aurora-dsql-starter-kit/)
