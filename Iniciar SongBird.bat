@echo off
title Iniciando Songbird...

:: Verifica se ja esta rodando como Administrador; se nao estiver, eleva automaticamente
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Executa o script PowerShell na mesma pasta ignorando a politica de execucao
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Songbird.ps1"