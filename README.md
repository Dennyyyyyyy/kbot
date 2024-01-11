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
### ! Python must be installed on your system   
Create a new script on bash
```zsh
touch pre_commit_check.sh
```
add code to the new created file
```sh
#!/bin/bash

# Визначення операційної системи
os_name=$(uname)

# Функція для виведення повідомлення про помилку та вихід зі скрипту
error_exit() {
  echo "$1" >&2
  exit 1
}

# Функція для встановлення pre-commit
install_precommit() {
  echo "Встановлення pre-commit..."
  if command -v pip3 &>/dev/null; then
    pip3 install pre-commit
  elif command -v pip &>/dev/null; then
    pip install pre-commit
  else
    error_exit "pip не знайдено. Встановіть pip перед встановленням pre-commit."
  fi
}

# Функція для створення та наповнення .pre-commit-config.yaml
create_precommit_config() {
  echo "Створення .pre-commit-config.yaml..."
  echo "- repo: https://github.com/gitleaks/gitleaks" > .pre-commit-config.yaml
  echo "  rev: v8.18.1" >> .pre-commit-config.yaml
  echo "  hooks:" >> .pre-commit-config.yaml
  echo "    - id: gitleaks" >> .pre-commit-config.yaml
}

# Функція для виконання команд pre-commit
run_precommit_commands() {
  echo "Виконання команд pre-commit..."
  pre-commit autoupdate
  #pre-commit install
  pre-commit install -f --hook-type pre-commit
  pre-commit
}

# Визначення наявності Python
check_python() {
  if command -v python3 &>/dev/null; then
    echo "Python встановлено"
  else
    error_exit "Python не знайдено. Встановіть Python перед використанням цього скрипта."
  fi
}

# Визначення наявності pre-commit
check_precommit() {
  if command -v pre-commit &>/dev/null; then
    echo "pre-commit встановлено"
  else
    install_precommit
    echo "pre-commit успішно встановлено"
  fi
}

# Визначення наявності .pre-commit-config.yaml
check_precommit_config() {
  if [ -e .pre-commit-config.yaml ]; then
    echo ".pre-commit-config.yaml вже існує"
  else
    create_precommit_config
    echo ".pre-commit-config.yaml успішно створено"
  fi
}

# Виведення інформації про операційну систему
echo "Операційна система: $os_name"

# Перевірка наявності Python
check_python

# Перевірка наявності pre-commit
check_precommit

# Перевірка наявності .pre-commit-config.yaml
check_precommit_config

# Виконання команд pre-commit
run_precommit_commands

echo "Great news! Now your commits are protected from leaks"

```
make it executing
```zsh 
chmod +x pre_commit_check.sh
```
enable gitleaks
```zsh
$ git config pre-commit.gitleaks true
```
check our script commit without token
```zsh
$ git commit -m "check without token"
Detect hardcoded secrets.................................................Passed
[w8task1 3aeccbd] check without token
 2 files changed, 91 insertions(+), 66 deletions(-)
```
one more check with token
```zsh
$ git commit -m "check with token"
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

4:52PM INF 1 commits scanned.
4:52PM INF scan completed in 7.08ms
4:52PM WRN leaks found: 1
```
