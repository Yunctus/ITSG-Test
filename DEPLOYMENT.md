# Automated Deployment Workflow

This workflow automatically deploys the PowerShell module to your self-hosted runner whenever changes are pushed to the `main` branch.

## How It Works

The GitHub Actions workflow (`.github/workflows/deploy-module.yml`) is triggered on:

- **Push to `main` branch** with changes to:
  - `Public/**` (public functions)
  - `MyModule.psd1` (manifest)
  - `MyModule.psm1` (module script)
  - `.github/workflows/deploy-module.yml` (workflow itself)

## Deployment Steps

1. **Checkout** - Pulls the latest code
2. **Display Info** - Shows repository, branch, and commit details
3. **Deploy** - Runs `deploy-module.ps1` to copy files to the self-runner
4. **Verify** - Confirms all files were copied correctly
5. **Test Import** - Validates the module can be imported in PowerShell
6. **Summary** - Displays deployment results

## Requirements

Your self-hosted runner must:
- Have Windows PowerShell 5.1 or later
- Have access to `X:\PowerShell Scripts\MyModule` directory
- Be configured with the `self-hosted` label in GitHub Actions

## Destination

Module deployed to: `X:\PowerShell Scripts\MyModule`

## Manual Trigger

You can also manually run the deployment:

```powershell
# From your local ITSG-Test repository
.\deploy-module.ps1

# With automatic version increment
.\deploy-module.ps1 -IncrementVersion

# Force re-copy all files
.\deploy-module.ps1 -Force
```

## Workflow File

- Location: `.github/workflows/deploy-module.yml`
- Trigger: Pushes to `main` branch
- Runner: `self-hosted`

## Logs

Check workflow logs on GitHub:
1. Go to your repository
2. Click "Actions" tab
3. Select "Deploy Module to Self-Runner"
4. View the latest run details

## Troubleshooting

If deployment fails:
1. Check that self-runner is online and connected
2. Verify `X:\PowerShell Scripts\MyModule` is accessible
3. Check PowerShell version is 5.1+
4. Review workflow logs for detailed error messages

## Next Steps

1. Test the workflow by making a small change to `Public/` folder
2. Push to `main` branch
3. Monitor the workflow in GitHub Actions
4. Verify deployment on self-runner
