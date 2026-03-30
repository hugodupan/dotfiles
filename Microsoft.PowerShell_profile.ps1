$env:DOTFILES = "C:\dotfiles"

# Sugestões baseadas no histórico
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Oh My Posh - prompt com status do git colorido
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression

function dsave {
    # Copia o perfil atual para o repositório dotfiles
    Copy-Item $PROFILE "$env:DOTFILES\Microsoft.PowerShell_profile.ps1" -Force

    $git = { param($a) & git $a.Split(" ") 2>&1 }
    Push-Location $env:DOTFILES

    git add . 2>&1 | Out-Null
    $status = git status --porcelain 2>&1
    if (-not $status) {
        Write-Host "⏭ Nenhuma alteração para salvar." -ForegroundColor Yellow
        Pop-Location; return
    }

    $msg = Read-Host "Mensagem do commit (Enter para usar 'Update dotfiles')"
    if (-not $msg) { $msg = "Update dotfiles" }

    git commit -m $msg 2>&1 | Out-Null
    $token = [System.Environment]::GetEnvironmentVariable("DOTFILES_TOKEN", "User")
    if (-not $token) {
        Write-Host "❌ Variável DOTFILES_TOKEN não definida. Execute: [System.Environment]::SetEnvironmentVariable('DOTFILES_TOKEN','seu_token','User')" -ForegroundColor Red
        Pop-Location; return
    }
    $remote = "https://hugodupan:$token@github.com/hugodupan/dotfiles.git"
    git remote set-url origin $remote 2>&1 | Out-Null
    git push origin main 2>&1 | Out-Null

    Write-Host "✅ Dotfiles salvos no GitHub!" -ForegroundColor Green
    Pop-Location
}

function fcd {
    $selected = Get-ChildItem -Path "C:\git" -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName |
        fzf --prompt="Navegar para> " --height=40% --border

    if ($selected) {
        Set-Location $selected
    }
}

function gitcmp {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    $branch = "master"

    if (!(Test-Path ".git")) {
        Write-Host "❌ Não é um repositório git." -ForegroundColor Red
        return
    }

    Write-Host "📦 Guardando alterações locais (stash)..." -ForegroundColor Cyan
    git stash push --include-untracked --message "stash antes de ir para $branch" | Out-Null

    Write-Host "🔄 Atualizando referências remotas (fetch)..." -ForegroundColor Cyan
    git fetch | Out-Null

    Write-Host "🔀 Indo para a branch $branch..." -ForegroundColor Cyan
    git checkout $branch --quiet

    Write-Host "⬇ Puxando última versão do servidor..." -ForegroundColor Cyan
    git rebase "origin/$branch"

    Write-Host "✅ Pronto! Você está na '$branch' com a versão mais recente." -ForegroundColor Green
}


    $selected = Get-ChildItem -Path "C:\git" -Filter "*.sln" -Recurse -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName |
        fzf --prompt="Abrir no Visual Studio> " --height=40% --border

    if ($selected) {
        & "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe" $selected
    }
}

function fcoder {
    $selected = Get-ChildItem -Path "C:\git" -Directory -Depth 1 |
        Select-Object -ExpandProperty FullName |
        fzf --prompt="Abrir no VSCode> " --height=40% --border --preview "git -C {} log --oneline -5 2>$null"

    if ($selected) {
        code $selected
    }
}
