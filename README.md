#w8_task1 Git pre-commit hook з використанням gitleaks для перевірки наявності секретів у коді

##pre-commit hook скрипт з локально встановленим gitleaks

Start from create and switch to a new branch
```zsh
$ git checkout -b w8task1
$ git tag git_hook
$ git push origin git_hook
```
Install gitleaks to current OS and run 
```zsh
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
An error has occurred: InvalidConfigError: 
==> File .pre-commit-config.yaml
=====> Expected a Config map but got a NoneType
Check the log at /Users/denys/.cache/pre-commit/pre-commit.log
```