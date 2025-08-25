# Release Pipeline Setup Guide

This guide explains how to configure the automated release pipeline for Tank Bar Helper.

## Prerequisites

1. A CurseForge account with an approved WoW addon project
2. (Optional) Wago.io account with addon project
3. GitHub repository admin access

## Step 1: Get CurseForge Project ID and API Token

### Project ID
1. Go to your addon's CurseForge page
2. Look for the Project ID in the URL or project settings
3. Example: `https://www.curseforge.com/wow/addons/tank-bar-helper` 
   - The project ID might be something like `942351`

### API Token
1. Log in to [CurseForge](https://www.curseforge.com)
2. Go to Account Settings → API Tokens
3. Click "Generate Token"
4. Name it something like "GitHub Actions"
5. Copy the token (you won't be able to see it again!)

## Step 2: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add the following secrets:

| Secret Name | Description | Required |
|------------|-------------|----------|
| `CURSEFORGE_API_TOKEN` | Your CurseForge API token | Yes |
| `CURSEFORGE_PROJECT_ID` | Your CurseForge project ID | Yes |
| `WAGO_API_TOKEN` | Your Wago.io API token | No |
| `WAGO_PROJECT_ID` | Your Wago.io project ID | No |

## Step 3: Update TOC File

If you haven't already created your CurseForge project, update the TOC file with actual IDs:

```toc
## X-Curse-Project-ID: 942351  # Replace with your actual ID
## X-WoWI-ID: 12345            # Optional: WoWInterface ID
## X-Wago-ID: AbCdEf           # Optional: Wago ID
```

## Step 4: Test the Pipeline

### Manual Release (Recommended for first test)
1. Create a new tag:
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```
2. Check the Actions tab in GitHub to monitor the workflow
3. Verify the release appears on CurseForge

### Automatic Release on PR Merge
- When a PR is merged to main, the workflow will automatically:
  - Increment the patch version
  - Create a GitHub release
  - Upload to CurseForge

## Workflow Types

### release.yml
- Full-featured custom workflow
- Handles PR merges and tags
- Auto-increments version on PR merge
- Creates GitHub releases

### packager.yml
- Uses BigWigsMods packager
- Simpler but requires exact TOC formatting
- Better for multi-game version support

## Troubleshooting

### CurseForge Upload Fails
- Check API token is correct
- Verify project ID matches your project
- Ensure game version (110002) is correct for current WoW patch

### Version Not Updating
- The `@project-version@` tag is replaced by the packager
- For manual workflow, version is extracted from git tags

### Workflow Not Triggering
- Ensure tags follow pattern: `v*.*.*` (e.g., v1.1.0)
- Check workflow file is in `.github/workflows/`
- Verify GitHub Actions are enabled for the repository

## Best Practices

1. **Always test with a beta/alpha tag first**
   ```bash
   git tag v1.1.0-beta.1
   git push origin v1.1.0-beta.1
   ```

2. **Use semantic versioning**
   - MAJOR.MINOR.PATCH (e.g., 1.2.3)
   - MAJOR: Breaking changes
   - MINOR: New features
   - PATCH: Bug fixes

3. **Keep CHANGELOG.md updated**
   - The workflow uses this for release notes
   - Follow the existing format

4. **Monitor the Actions tab**
   - Check for any workflow failures
   - Review logs if uploads fail

## Support

If you encounter issues:
1. Check the GitHub Actions logs
2. Verify all secrets are set correctly
3. Ensure your CurseForge project is approved
4. Open an issue if problems persist