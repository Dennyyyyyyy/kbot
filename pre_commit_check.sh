#!/bin/bash

# Перевірка чи gitleaks встановлено в системі
if ! command -v gitleaks &> /dev/null; then
    echo "Cannot find gitleaks in your OS. Installing..."
    
    # Встановлення gitleaks залежно від операційної системи
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Для Linux
        wget https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks-linux-amd64 -O gitleaks
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Для macOS
        wget https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks-darwin-amd64 -O gitleaks
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Для Windows
        powershell -Command "& { Invoke-WebRequest -Uri https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks-windows-amd64.exe -OutFile gitleaks.exe }"
        
    else
        echo "Cannot recongnize your OS. Install gitleaks impossible."
        exit 1
    fi

    chmod +x gitleaks
    sudo mv gitleaks /usr/local/bin/
    
    echo "gitleaks has been installed successfully."
fi

# Виконання gitleaks для перевірки чутливих даних
gitleaks detect --redact -v --source . --verbose --report-path=report.json --log-opts='--since=2024-01-09'
