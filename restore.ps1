# restore.ps1 - Restaura o ambiente de desenvolvimento

Write-Host "`n=== Restaurando ambiente de desenvolvimento ===" -ForegroundColor Cyan

# 1. Instalar winget packages
$packages = @(
    @{ id = "junegunn.fzf";           name = "fzf" },
    @{ id = "Microsoft.Git";          name = "Git" },
    @{ id = "Microsoft.VisualStudioCode"; name = "VSCode" }
)

foreach ($pkg in $packages) {
    $installed = winget list --id $pkg.id 2>$null | Select-String $pkg.id
    if ($installed) {
        Write-Host "  ⏭ Já instalado: $($pkg.name)" -ForegroundColor Yellow
    } else {
        Write-Host "  ⬇ Instalando: $($pkg.name)..." -ForegroundColor Cyan
        winget install $pkg.id --accept-source-agreements --accept-package-agreements --silent
        Write-Host "    ✅ OK" -ForegroundColor Green
    }
}

# 2. Criar pasta C:\git
if (!(Test-Path "C:\git")) {
    New-Item -ItemType Directory -Path "C:\git" | Out-Null
    Write-Host "  ✅ Pasta C:\git criada" -ForegroundColor Green
} else {
    Write-Host "  ⏭ Pasta C:\git já existe" -ForegroundColor Yellow
}

# 3. Instalar perfil do PowerShell
$profileDir = Split-Path $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

$profileUrl = "https://raw.githubusercontent.com/hugodupan/dotfiles/main/Microsoft.PowerShell_profile.ps1"
Write-Host "  ⬇ Instalando perfil do PowerShell..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $profileUrl -OutFile $PROFILE -UseBasicParsing
Write-Host "  ✅ Perfil instalado em: $PROFILE" -ForegroundColor Green

# 4. Configurar git
Write-Host "  ⚙ Configurando Git..." -ForegroundColor Cyan
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
git config --global init.defaultBranch main
git config --global core.autocrlf true
Write-Host "  ✅ Git configurado" -ForegroundColor Green

Write-Host "`n✅ Ambiente restaurado com sucesso!" -ForegroundColor Green
Write-Host "   Abra um novo terminal para usar os comandos: fcoder, fvs`n" -ForegroundColor Cyan
