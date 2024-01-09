# w8_task1 Git pre-commit hook з використанням gitleaks для перевірки наявності секретів у коді

## pre-commit hook скрипт з локально встановленим gitleaks

Start from create and switch to a new branch
```sh
$ git checkout -b w8task1
$ git tag git_hook
$ git push origin git_hook
```
Install gitleaks to current OS and run 
```sh
$ brew install gitleaks
$ gitleaks detect --source . --log-opts="--all"

    ○
    │╲
    │ ○
    ○ ░
    ░    gitleaks

2:03PM INF 75 commits scanned.
2:03PM INF scan completed in 291ms
2:03PM INF no leaks found
```
Add a token to values.yaml and check one more time
```zsh
$ git add .
$ git commit -m "adding token"
[w8task1 f17897f] adding token
 1 file changed, 2 insertions(+), 1 deletion(-)
$ gitleaks detect --source . --verbose

    ○
    │╲
    │ ○
    ○ ░
    ░    gitleaks

Finding:     tokenName: 6367718599:AAF9rvS1tQ4W*********************
Secret:      6367718599:AAF9rvS1tQ4W*********************
RuleID:      telegram-bot-api-token
Entropy:     4.816403
File:        helm/values.yaml
Line:        16
Commit:      f17897fbbd640189b982e2d62d0ccc31d77c1681
Author:      Dennyyyyyyy
Email:       den.grinyko@gmail.com
Date:        2024-01-09T12:12:58Z
Fingerprint: f17897fbbd640189b982e2d62d0ccc31d77c1681:helm/values.yaml:telegram-bot-api-token:16

2:13PM INF 76 commits scanned.
2:13PM INF scan completed in 275ms
2:13PM WRN leaks found: 1
```
Install pre-commit to current OS, check version, create a new pre-commit file in root dir and add to repo
```zsh
$ brew install pre-commit
$ pre-commit --version
pre-commit 3.6.0
$ touch .pre-commit-config.yaml
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
$ pre-commit run --all-files
Detect hardcoded secrets.................................................Passed
```
Add a new code to .pre-commit-config.yaml
```zsh
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.16.1
    hooks:
      - id: gitleaks
```
```zsh
$ pre-commit autoupdate
[https://github.com/gitleaks/gitleaks] updating v8.16.1 -> v8.18.1
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
$ pre-commit run --all-files
Detect hardcoded secrets.................................................Passed
$ git add .
```
Now check with and without secret
```zsh
$ git commit -m "this commit without a secret"
Detect hardcoded secrets.................................................Passed
[w8task1 ac955e7] this commit without a secret
 2 files changed, 7 insertions(+), 2 deletions(-)

$ git commit -m "this commit with a secret"
Detect hardcoded secrets.................................................Failed
- hook id: gitleaks
- exit code: 1

○
    │╲
    │ ○
    ○ ░
    ░    gitleaks

Finding:     tokenName: REDACTED
Secret:      REDACTED
RuleID:      telegram-bot-api-token
Entropy:     4.816403
File:        helm/values.yaml
Line:        16
Fingerprint: helm/values.yaml:telegram-bot-api-token:16

6:57PM INF 1 commits scanned.
6:57PM INF scan completed in 10.7ms
6:57PM WRN leaks found: 1

$ SKIP=gitleaks git commit -m "skip gitleaks check"
[WARNING] Unstaged files detected.
[INFO] Stashing unstaged files to /Users/denys/.cache/pre-commit/patch1704819587-34774.
Detect hardcoded secrets................................................Skipped
[INFO] Restored changes from /Users/denys/.cache/pre-commit/patch1704819587-34774.
[w8task1 b204cdc] skip gitleaks check
 2 files changed, 4 insertions(+), 4 deletions(-)
```

## pre-commit hook скрипт з автоматичним встановленням gitleaks залежно від операційної системи, з опцією enable за допомогою git config

Update our .pre-commit-config.yaml with a new code
```zsh
repos:
  - repo: local
    hooks:
      - id: pre_commit_check
        name: pre_commit_check
        language: python
        entry: ./pre_commit_check.py
        language_version: python3
```
Create a new script on Python
```zsh
touch pre_commit_check.py
```
add code to the new created file
```py
#!/usr/bin/env python3
import subprocess
import platform
import sys
import os

def run_command(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()
    return process.returncode, output.decode('utf-8'), error.decode('utf-8')

def install_gitleaks():
    system_platform = platform.system().lower()

    if system_platform == 'linux':
        return run_command(['sudo', 'curl', '-sSfL', 'https://github.com/zricethezav/gitleaks/releases/download/v7.2.1/gitleaks-linux-amd64', '-o', '/usr/local/bin/gitleaks'])

    elif system_platform == 'darwin':
        return run_command(['sudo', 'curl', '-sSfL', 'https://github.com/zricethezav/gitleaks/releases/download/v7.2.1/gitleaks-darwin-amd64', '-o', '/usr/local/bin/gitleaks'])

    elif system_platform == 'windows':
        return run_command(['powershell', '-Command', 'iwr', '-outf', 'gitleaks.exe', 'https://github.com/zricethezav/gitleaks/releases/download/v7.2.1/gitleaks-windows-amd64.exe'])

    else:
        print(f"Unsupported platform: {system_platform}")
        sys.exit(1)

def main():
    # Check if gitleaks is enabled via git config
    gitleaks_enabled, _, _ = run_command(['git', 'config', 'pre-commit.gitleaks'])

    # Convert to string and handle the case where gitleaks_enabled is an integer
    gitleaks_enabled = str(gitleaks_enabled).strip().lower()

    if gitleaks_enabled == 'true':
        # Install gitleaks if not installed
        if not os.path.exists('/usr/local/bin/gitleaks') and not os.path.exists('gitleaks.exe'):
            returncode, output, error = install_gitleaks()
            if returncode != 0:
                print("Error installing gitleaks:")
                print(error)
                sys.exit(1)

if __name__ == '__main__':
    main()
	
```
make it executing
```zsh 
chmod +x pre_commit_check.py
```
install pre-commit
```zsh
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
```
enable gitleaks
```zsh
$ git config pre-commit.gitleaks true
```
