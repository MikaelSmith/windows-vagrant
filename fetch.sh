#!/usr/bin/env bash
mkdir -p DSC/SourceFiles
curl -L https://github.com/PowerShell/PowerShell/releases/download/v6.1.0/PowerShell-6.1.0-win-x64.msi -o DSC/SourceFiles/PowerShell-6.1.0-win-x64.msi
curl -L https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.7.2.0p1-Beta/OpenSSH-Win64.zip -o DSC/SourceFiles/OpenSSH-Win64.zip
