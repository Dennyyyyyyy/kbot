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
        return run_command(['curl', '-sSfL', 'https://github.com/zricethezav/gitleaks/releases/download/v7.2.1/gitleaks-linux-amd64', '-o', '/usr/local/bin/gitleaks'])

    elif system_platform == 'darwin':
        return run_command(['curl', '-sSfL', 'https://github.com/zricethezav/gitleaks/releases/download/v7.2.1/gitleaks-darwin-amd64', '-o', '/usr/local/bin/gitleaks'])

    elif system_platform == 'windows':
        return run_command(['powershell', '-Command', 'iwr', '-outf', 'gitleaks.exe', 'https://github.com/zricethezav/gitleaks/releases/download/v7.2.1/gitleaks-windows-amd64.exe'])

    else:
        print(f"Unsupported platform: {system_platform}")
        sys.exit(1)

def check_gitleaks():
    return run_command(['gitleaks', '--verbose', '--redact'])

def main():
    # Install gitleaks if not installed
    if not os.path.exists('/usr/local/bin/gitleaks') and not os.path.exists('gitleaks.exe'):
        returncode, output, error = install_gitleaks()
        if returncode != 0:
            print("Error installing gitleaks:")
            print(error)
            sys.exit(1)

    # Check for leaks using gitleaks
    returncode, output, error = check_gitleaks()
    if returncode != 0:
        print("Gitleaks found potential leaks:")
        print(output)
        sys.exit(1)

    # Additional checks or actions can be added here

if __name__ == '__main__':
    main()
