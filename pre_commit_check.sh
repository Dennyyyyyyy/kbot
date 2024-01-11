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
