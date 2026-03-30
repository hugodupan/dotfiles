# dotfiles - Hugo Borges

Configurações pessoais de ambiente Windows. Para restaurar em uma nova máquina, execute o `restore.ps1`.

## Comandos disponíveis após restauração

| Comando | Descrição |
|---------|-----------|
| `fcoder` | Lista projetos em `C:\git` e abre no VSCode |
| `fvs` | Lista arquivos `.sln` em `C:\git` e abre no Visual Studio |

## Como restaurar

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
irm https://raw.githubusercontent.com/hugodupan/dotfiles/main/restore.ps1 | iex
```
