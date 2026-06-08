# GitHub Setup Guide for PocketPilot

## Step 1: Create GitHub Repository

### Via Web Interface (Easiest)

1. Go to [GitHub](https://github.com/new)
2. Click "New repository"
3. Fill in the details:
   - **Repository name:** `pocketpilot`
   - **Description:** Smart Budget Management System for Students and Parents
   - **Privacy:** Public (or Private if preferred)
   - **Initialize with:** Do NOT check "Add README" (we have one)
4. Click "Create repository"

## Step 2: Set Up Git Locally

### Install Git

**Windows:**
```bash
# Using winget
winget install Git.Git

# Or download from https://git-scm.com/download/win
```

**Mac:**
```bash
brew install git
```

**Linux:**
```bash
sudo apt-get install git
```

### Configure Git

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify configuration
git config --global --list
```

## Step 3: Initialize Git in Your Project

```bash
cd c:\xampp2\tomcat\webapps\PP

# Initialize git repository
git init

# Add GitHub as remote
git remote add origin https://github.com/YourUsername/pocketpilot.git

# Verify remote
git remote -v
```

## Step 4: Stage and Commit Files

```bash
# See status of files
git status

# Stage all files
git add .

# Commit with message
git commit -m "Initial commit: PocketPilot project with Maven and Docker setup"

# Verify commit
git log
```

## Step 5: Push to GitHub

### Using HTTPS (Recommended for First Time)

```bash
# Set default branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

**Note:** You'll be prompted for authentication. Use:
- **Username:** Your GitHub username
- **Password:** Your Personal Access Token (see below)

### Create Personal Access Token

If you don't have one:

1. Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token"
3. Select scopes:
   - ✅ `repo` (full control of private repositories)
   - ✅ `workflow` (update GitHub Action and workflow)
4. Click "Generate token"
5. Copy the token immediately (you won't see it again!)
6. Use this token as your password when pushing

### Using SSH (More Secure)

If you prefer SSH authentication:

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Copy the public key
cat ~/.ssh/id_ed25519.pub | clip

# Add to GitHub:
# Go to Settings → SSH and GPG keys → New SSH key
# Paste the key and save

# Update remote URL to use SSH
git remote set-url origin git@github.com:YourUsername/pocketpilot.git

# Push to GitHub
git push -u origin main
```

## Step 6: Verify on GitHub

1. Go to your GitHub repository: `https://github.com/YourUsername/pocketpilot`
2. Verify all files are pushed correctly
3. Check the README is displaying properly

## Ongoing Development Workflow

### Make Changes Locally

```bash
# Make changes to files
# ... edit your code ...

# Check what changed
git status

# Stage changes
git add .

# Commit changes
git commit -m "Description of your changes"

# Push to GitHub
git push
```

### Update from GitHub

```bash
# Pull latest changes from GitHub
git pull origin main
```

### Create a Branch for Features

```bash
# Create and switch to new branch
git checkout -b feature/feature-name

# Make your changes
# ... edit your code ...

# Commit changes
git commit -m "Add new feature"

# Push branch to GitHub
git push -u origin feature/feature-name

# Create Pull Request on GitHub to merge into main
```

## GitHub Actions for CI/CD (Optional)

Create `.github/workflows/maven-build.yml`:

```yaml
name: Maven Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven
    
    - name: Build with Maven
      run: mvn clean package -DskipTests

    - name: Run tests
      run: mvn test

    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
```

This will automatically:
- Build your project on every push
- Run tests
- Catch compilation errors
- Report coverage

## Security Best Practices

### Never Commit Sensitive Data

Already handled by `.gitignore`:
- Database passwords ❌
- API keys ❌
- Environment files ❌

But verify with:
```bash
git diff --cached
```

Before committing!

### Keep Dependencies Updated

```bash
# Check for dependency updates
mvn versions:display-dependency-updates

# Update dependencies
mvn versions:use-latest-versions
```

### Use Branch Protection Rules

On GitHub:
1. Go to Repository Settings → Branches
2. Add rule for `main` branch:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date

## Deployment from GitHub

### To Docker Hub (For Public Images)

1. Create Docker Hub account: [hub.docker.com](https://hub.docker.com)
2. Create repository on Docker Hub
3. Add GitHub Secrets:
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
4. Create `.github/workflows/docker-build.yml`

### To GitHub Releases

```bash
# Create a tag for release
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to GitHub
git push origin v1.0.0

# Create release on GitHub with:
# - Release notes
# - WAR file download
# - Docker image link
```

## Troubleshooting

### Permission Denied (SSH)

```bash
# Fix SSH permissions
chmod 600 ~/.ssh/id_ed25519
chmod 700 ~/.ssh
```

### "Repository not found"

```bash
# Check remote URL
git remote -v

# Verify repo exists and you have access
# Check GitHub Settings → Collaborators if private
```

### "Remote: Support for password authentication was removed"

```bash
# Use Personal Access Token instead (see Step 5 above)
# Or use SSH authentication
```

### Large Files Error

If you accidentally commit large files:

```bash
# Remove from history (careful!)
git rm --cached large-file.bin
git commit --amend -m "Remove large file"
git push --force origin main

# Or use Git LFS for large files
git lfs install
git lfs track "*.jar"
```

## Next Steps

1. ✅ Create GitHub repository
2. ✅ Push your code
3. ✅ Set up branch protection rules
4. ✅ (Optional) Set up GitHub Actions for CI/CD
5. 📝 Add GitHub Pages for documentation
6. 🚀 Deploy to production

## Useful GitHub Links

- [GitHub Documentation](https://docs.github.com)
- [Git Cheat Sheet](https://github.github.com/training-kit/downloads/github-git-cheat-sheet.pdf)
- [GitHub CLI](https://cli.github.com/) (Alternative to git command line)
- [GitHub Desktop](https://desktop.github.com/) (Visual Git tool for Windows/Mac)

## Questions?

If you get stuck:
1. Read the error message carefully
2. Check GitHub documentation
3. Search existing issues on GitHub
4. Ask on Stack Overflow with `git` and `github` tags

Good luck! 🚀
