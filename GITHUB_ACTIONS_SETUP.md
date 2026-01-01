# GitHub Actions Setup for Automated Play Store Deployment

## Overview
This will automatically build and deploy your app to Google Play Store when you create a new version tag (e.g., v1.0.1, v1.0.2).

## Step 1: Encode Your Keystore

Run this command to convert your keystore to base64:

```bash
base64 -i android/sakinah-release-key.jks | pbcopy
```

This copies the encoded keystore to your clipboard.

## Step 2: Create a Google Play Service Account

1. **Go to Google Play Console:**
   - https://play.google.com/console
   - Select your app (Sakinah)

2. **Setup API Access:**
   - Go to **Setup → API access**
   - Click **"Create new service account"**
   - This will open Google Cloud Console

3. **In Google Cloud Console:**
   - Click **"Create Service Account"**
   - Name: `github-actions-deploy`
   - Click **"Create and Continue"**
   - Role: Select **"Service Account User"**
   - Click **"Continue"** then **"Done"**

4. **Create JSON Key:**
   - Click on the service account you just created
   - Go to **"Keys"** tab
   - Click **"Add Key" → "Create new key"**
   - Choose **JSON**
   - Download the JSON file

5. **Back in Play Console:**
   - Go back to **Setup → API access**
   - Click **"Grant access"** for the service account
   - Permissions:
     - ✅ View app information and download bulk reports
     - ✅ Manage production releases
     - ✅ Manage testing track releases
   - Click **"Invite user"**

## Step 3: Add Secrets to GitHub

1. **Go to your GitHub repository:**
   ```
   https://github.com/omaratef3221/sakinah-app/settings/secrets/actions
   ```

2. **Click "New repository secret" and add these secrets:**

   **Secret 1: KEYSTORE_BASE64**
   - Name: `KEYSTORE_BASE64`
   - Value: Paste the base64 string you copied earlier
   - Click **"Add secret"**

   **Secret 2: KEYSTORE_PASSWORD**
   - Name: `KEYSTORE_PASSWORD`
   - Value: `Sakinah2024!`
   - Click **"Add secret"**

   **Secret 3: KEY_PASSWORD**
   - Name: `KEY_PASSWORD`
   - Value: `Sakinah2024!`
   - Click **"Add secret"**

   **Secret 4: KEY_ALIAS**
   - Name: `KEY_ALIAS`
   - Value: `sakinah-key`
   - Click **"Add secret"**

   **Secret 5: PLAY_STORE_SERVICE_ACCOUNT**
   - Name: `PLAY_STORE_SERVICE_ACCOUNT`
   - Value: Copy and paste the ENTIRE contents of the JSON file you downloaded
   - Click **"Add secret"**

## Step 4: Push the Workflow to GitHub

```bash
git add .github/workflows/deploy-playstore.yml
git commit -m "Add GitHub Actions workflow for Play Store deployment"
git push origin main
```

## How to Use

### Automatic Deployment (Recommended):

When you're ready to release a new version:

1. **Update version in pubspec.yaml:**
   ```yaml
   version: 1.0.1+2
   ```

2. **Commit and create a tag:**
   ```bash
   git add pubspec.yaml
   git commit -m "Bump version to 1.0.1"
   git tag v1.0.1
   git push origin main
   git push origin v1.0.1
   ```

3. **GitHub Actions will automatically:**
   - Build the release AAB
   - Sign it with your keystore
   - Upload to Play Store production track
   - ✅ Done!

### Manual Deployment:

1. Go to: https://github.com/omaratef3221/sakinah-app/actions
2. Click on **"Deploy to Play Store"** workflow
3. Click **"Run workflow"**
4. Select branch: `main`
5. Click **"Run workflow"**

## Benefits

✅ No need to manually build and upload AAB files
✅ Consistent builds every time
✅ Automated version management
✅ Track all releases in GitHub
✅ Easy rollbacks with git tags

## Important Notes

- The workflow only runs on version tags (v*.*.*)
- Make sure all secrets are added correctly
- Test with a manual run first before using tags
- Your keystore remains secure in GitHub Secrets

## For This First Release

For now, continue with the manual upload you're doing. Set up GitHub Actions for future releases (v1.0.1, v1.0.2, etc.).
