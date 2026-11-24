# ==============================================================================
# SONGBIRD // AUTOMATION SUITE v0.1
# ==============================================================================

$Host.UI.RawUI.WindowTitle = "SONGBIRD // NETRUNNER UTILITY"

# Detecta a pasta do pendrive automaticamente (compativel com Win 7, 10 e 11)
$PastaBase = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }

# Detecta arquitetura e versao do sistema
$Is64Bit = [Environment]::Is64BitOperatingSystem
$OSVersion = [System.Environment]::OSVersion.Version
$IsWin7 = ($OSVersion.Major -eq 6 -and $OSVersion.Minor -eq 1)

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "    ____     ___    _   _    ____   ____    ___   ____    ____  " -ForegroundColor Cyan
    Write-Host "   / ___|   / _ \  | \ | |  / ___| | __ )  |_ _| |  _ \  |  _ \ " -ForegroundColor Cyan
    Write-Host "   \___ \  | | | | |  \| | | |  _  |  _ \   | |  | |_) | | | | |" -ForegroundColor DarkCyan
    Write-Host "    ___) | | |_| | | |\  | | |_| | | |_) |  | |  |  _ <  | |_| |" -ForegroundColor Magenta
    Write-Host "   |____/   \___/  |_| \_|  \____| |____/  |___| |_| \_\ |____/ " -ForegroundColor Red
    Write-Host ""
    Write-Host "   [ PROTOCOLO SO MI // ASSISTENTE DE MANUTENCAO v0.1 ]" -ForegroundColor DarkGray
    Write-Host "   ==============================================================" -ForegroundColor DarkCyan

    $ArqTexto = if ($Is64Bit) { "64-bit (x64)" } else { "32-bit (x86)" }
    $WinTexto = if ($IsWin7) { "Windows 7" } else { "Windows ($($OSVersion.Major).$($OSVersion.Minor))" }
    Write-Host "   Sistema : $WinTexto | Arquitetura: $ArqTexto" -ForegroundColor Gray
    Write-Host "   Pendrive: $PastaBase" -ForegroundColor Gray
    Write-Host "   ==============================================================" -ForegroundColor DarkCyan
    Write-Host ""
}

function Install-App {
    param (
        [string]$Nome,
        [string]$Arquivo,
        [string]$Argumentos
    )

    $CaminhoCompleto = Join-Path -Path $PastaBase -ChildPath $Arquivo

    if (-not (Test-Path -Path $CaminhoCompleto)) {
        Write-Host "   [ERRO] Arquivo nao encontrado: $Arquivo" -ForegroundColor Red
        return
    }

    Write-Host "   [>>] Instalando $Nome ($Arquivo)..." -ForegroundColor Cyan
    try {
        if ([string]::IsNullOrWhiteSpace($Argumentos)) {
            Start-Process -FilePath $CaminhoCompleto -Wait
        } else {
            Start-Process -FilePath $CaminhoCompleto -ArgumentList $Argumentos -Wait
        }
        Write-Host "   [OK] $Nome concluido." -ForegroundColor Green
    } catch {
        Write-Host "   [ERRO] Falha ao instalar $Nome : $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-InstalarProgramasBasicos {
    Show-Banner
    Write-Host "   >> INICIANDO INSTALACAO DOS PROGRAMAS BASICOS..." -ForegroundColor Magenta
    Write-Host ""

    # 1. WinRAR
    if ($Is64Bit) {
        Install-App -Nome "WinRAR (x64)" -Arquivo "Winrar x64.exe" -Argumentos "/S"
    } else {
        Install-App -Nome "WinRAR (x86)" -Arquivo "Winrar x86.exe" -Argumentos "/S"
    }

    # 2. Mozilla Firefox
    if ($Is64Bit -and -not $IsWin7) {
        Install-App -Nome "Mozilla Firefox" -Arquivo "Firefox Setup 108.0.2.exe" -Argumentos "-ms"
    } else {
        Install-App -Nome "Mozilla Firefox (x86)" -Arquivo "Firefox Setup 71.0 x86.exe" -Argumentos "-ms"
    }

    # 3. Google Chrome (instalador online - requer internet)
    Install-App -Nome "Google Chrome" -Arquivo "GoogleSetup.exe" -Argumentos "/silent /install"

    # 4. Adobe 11
    if ($IsWin7) {
        Install-App -Nome "Adobe 11 (Win7)" -Arquivo "Adobe 11 - Win7.exe" -Argumentos "/sAll /rs /msi EULA_ACCEPT=YES"
    } else {
        Install-App -Nome "Adobe 11" -Arquivo "Adobe 11.exe" -Argumentos "/sAll /rs /msi EULA_ACCEPT=YES"
    }

    # 5. AnyDesk (instala no sistema e cria atalho na area de trabalho)
    $PastaAnyDesk = if ($Is64Bit) { "C:\Program Files (x86)\AnyDesk" } else { "C:\Program Files\AnyDesk" }
    $ArgsAnyDesk = "--install `"$PastaAnyDesk`" --create-shortcuts --create-desktop-icon --silent"
    Install-App -Nome "AnyDesk" -Arquivo "AnyDesk.exe" -Argumentos $ArgsAnyDesk

    Write-Host ""
    Write-Host "   ==============================================================" -ForegroundColor DarkCyan
    Write-Host "   [CONCLUIDO] Instalacao dos programas basicos finalizada!" -ForegroundColor Green
    Write-Host ""
    Read-Host "   Pressione ENTER para voltar ao menu"
}

# Loop principal do menu
do {
    Show-Banner
    Write-Host "   Selecione uma operacao:" -ForegroundColor White
    Write-Host ""
    Write-Host "   [1] Instalar Programas Basicos (Automatico)" -ForegroundColor Cyan
    Write-Host "   [0] Encerrar Songbird" -ForegroundColor Red
    Write-Host ""
    $Opcao = Read-Host "   Digite sua escolha"

    switch ($Opcao) {
        "1" { Invoke-InstalarProgramasBasicos }
        "0" {
            Write-Host ""
            Write-Host "   Desconectando da Blackwall... Ate logo." -ForegroundColor Magenta
            Start-Sleep -Seconds 1
        }
        default {
            Write-Host "   [!] Opcao invalida. Tente novamente." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
} while ($Opcao -ne "0")