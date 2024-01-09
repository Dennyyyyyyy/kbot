#!/usr/bin/env python3
import platform
import subprocess
import sys

def install_gitleaks():
    if platform.system() == 'Darwin':
        subprocess.run(['brew', 'install', 'gitleaks'])
    elif platform.system() == 'Linux':
        subprocess.run(['sudo', 'apt-get', 'install', '-y', 'gitleaks'])
    elif platform.system() == 'Windows':
        print("Please install Gitleaks manually on Windows.")
        sys.exit(1)

def check_gitleaks():
    result = subprocess.run(['gitleaks', '--verbose', '--redact'], capture_output=True, text=True)
    return result.returncode, result.stdout, result.stderr

def main():
    install_gitleaks()
    
    returncode, output, error = check_gitleaks()

    if returncode != 0:
        print(f"Gitleaks found potential leaks:\n{output}")
        sys.exit(1)
    else:
        print("Gitleaks check passed. No potential leaks found.")

if __name__ == "__main__":
    main()
