# ==============================================================================
# SONGBIRD // AUTOMATION SUITE v0.2
# ==============================================================================

$Host.UI.RawUI.WindowTitle = "SONGBIRD // NETRUNNER UTILITY"

# Detecta a pasta do pendrive automaticamente (compativel com Win 7, 10 e 11)
$PastaBase = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }

# Detecta arquitetura e versao exata do Windows (incluindo Win 10 vs Win 11)
$Is64Bit = [Environment]::Is64BitOperatingSystem
$OSVersion = [System.Environment]::OSVersion.Version
$BuildNumber = $OSVersion.Build

try {
    $RegBuild = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction Stop).CurrentBuildNumber
    if ($RegBuild) { $BuildNumber = [int]$RegBuild }
} catch {}

$IsWin7 = ($OSVersion.Major -eq 6 -and $OSVersion.Minor -eq 1)
$IsWin11 = ($BuildNumber -ge 22000)
$IsWin10 = ($BuildNumber -ge 10240 -and $BuildNumber -lt 22000)

$WinTexto = if ($IsWin11) {
    "Windows 11 (Build $BuildNumber)"
} elseif ($IsWin10) {
    "Windows 10 (Build $BuildNumber)"
} elseif ($IsWin7) {
    "Windows 7"
} else {
    "Windows ($($OSVersion.Major).$($OSVersion.Minor))"
}

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "    ____     ___    _   _    ____   ____    ___   ____    ____  " -ForegroundColor Cyan
    Write-Host "   / ___|   / _ \  | \ | |  / ___| | __ )  |_ _| |  _ \  |  _ \ " -ForegroundColor Cyan
    Write-Host "   \___ \  | | | | |  \| | | |  _  |  _ \   | |  | |_) | | | | |" -ForegroundColor DarkCyan
    Write-Host "    ___) | | |_| | | |\  | | |_| | | |_) |  | |  |  _ <  | |_| |" -ForegroundColor Magenta
    Write-Host "   |____/   \___/  |_| \_|  \____| |____/  |___| |_| \_\ |____/ " -ForegroundColor Red
    Write-Host ""
    Write-Host "   [ PROTOCOLO SO MI // ASSISTENTE DE MANUTENCAO v0.2 ]" -ForegroundColor DarkGray
    Write-Host "   ==============================================================" -ForegroundColor DarkCyan

    $ArqTexto = if ($Is64Bit) { "64-bit (x64)" } else { "32-bit (x86)" }
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
        if ([string]::IsNullOrEmpty($Argumentos)) {
            Start-Process -FilePath $CaminhoCompleto -Wait
        } else {
            Start-Process -FilePath $CaminhoCompleto -ArgumentList $Argumentos -Wait
        }
        Write-Host "   [OK] $Nome concluido." -ForegroundColor Green
    } catch {
        Write-Host "   [ERRO] Falha ao instalar $Nome : $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-AbrirOffice {
    param (
        [string]$PastaOffice
    )

    $CaminhoPasta = Join-Path -Path $PastaBase -ChildPath $PastaOffice

    if (-not (Test-Path -Path $CaminhoPasta)) {
        Write-Host "   [ERRO] Pasta nao encontrada no pendrive: $PastaOffice" -ForegroundColor Red
        return
    }

    # Procura primeiro pelo setup.exe padrao
    $Instalador = Join-Path -Path $CaminhoPasta -ChildPath "setup.exe"

    if (-not (Test-Path -Path $Instalador)) {
        # Fallback: procura arquivos .exe na raiz da pasta (compativel com Win 7/10/11)
        $ExesEncontrados = @(Get-ChildItem -Path $CaminhoPasta -Filter "*.exe" | Where-Object { -not $_.PSIsContainer })
        if ($ExesEncontrados.Count -eq 1) {
            $Instalador = $ExesEncontrados[0].FullName
        } elseif ($ExesEncontrados.Count -gt 1) {
            Write-Host "   [AVISO] Varios executaveis encontrados em '$PastaOffice'. Abrindo a pasta..." -ForegroundColor Yellow
            Start-Process -FilePath "explorer.exe" -ArgumentList "`"$CaminhoPasta`""
            return
        } else {
            Write-Host "   [ERRO] Nenhum executavel (.exe) encontrado dentro de: $PastaOffice" -ForegroundColor Red
            return
        }
    }

    Write-Host "   [>>] Abrindo instalador do $PastaOffice..." -ForegroundColor Cyan
    Write-Host "   [i] Configure e conclua a instalacao na janela do Office." -ForegroundColor Gray
    try {
        Start-Process -FilePath $Instalador -WorkingDirectory $CaminhoPasta -Wait
        Write-Host "   [OK] Instalador do $PastaOffice encerrado." -ForegroundColor Green
    } catch {
        Write-Host "   [ERRO] Falha ao abrir $PastaOffice : $($_.Exception.Message)" -ForegroundColor Red
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

    # 6. Selecao do Microsoft Office
    Write-Host ""
    Write-Host "   ==============================================================" -ForegroundColor DarkCyan
    Write-Host "   >> MICROSOFT OFFICE" -ForegroundColor Magenta

    $OfficeRecomendado = if ($IsWin11) { "Office 2016" } else { "Office 2013" }
    Write-Host "   Sistema detectado: $WinTexto" -ForegroundColor Gray
    Write-Host "   Recomendado      : $OfficeRecomendado" -ForegroundColor Green
    Write-Host ""
    Write-Host "   [ENTER] Abrir Recomendado ($OfficeRecomendado)" -ForegroundColor Cyan
    Write-Host "   [1]     Abrir Office 2013" -ForegroundColor White
    Write-Host "   [2]     Abrir Office 2016" -ForegroundColor White
    Write-Host "   [3]     Pular instalacao do Office" -ForegroundColor DarkGray
    Write-Host ""

    $OpcaoValida = $false
    do {
        $EscolhaOffice = Read-Host "   Escolha uma opcao"
        switch ($EscolhaOffice) {
            ""  { Invoke-AbrirOffice -PastaOffice $OfficeRecomendado; $OpcaoValida = $true }
            "1" { Invoke-AbrirOffice -PastaOffice "Office 2013"; $OpcaoValida = $true }
            "2" { Invoke-AbrirOffice -PastaOffice "Office 2016"; $OpcaoValida = $true }
            "3" { Write-Host "   [i] Instalacao do Office pulada." -ForegroundColor Yellow; $OpcaoValida = $true }
            default { Write-Host "   [!] Opcao invalida. Digite 1, 2, 3 ou aperte ENTER." -ForegroundColor Yellow }
        }
    } while (-not $OpcaoValida)

    Write-Host ""
    Write-Host "   ==============================================================" -ForegroundColor DarkCyan
    Write-Host "   [CONCLUIDO] Fluxo de instalacao finalizado!" -ForegroundColor Green
    Write-Host ""
    Read-Host "   Pressione ENTER para voltar ao menu"
}

# Loop principal do menu
do {
    Show-Banner
    Write-Host "   Selecione uma operacao:" -ForegroundColor White
    Write-Host ""
    Write-Host "   [1] Instalar Programas Basicos + Office" -ForegroundColor Cyan
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
