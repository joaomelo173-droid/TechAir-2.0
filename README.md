# TechAir 2.0

## Primeira execução no Windows

Abre esta pasta no VS Code e, no terminal PowerShell, executa:

```powershell
.\setup_windows.ps1
```

Depois:

```powershell
Copy-Item .\google-services.json .\android\app\google-services.json -Force
flutter run -d windows
```

O script gera as pastas Windows, Android e Web usando exatamente a versão do Flutter instalada no computador, evitando ficheiros CMake incompatíveis ou incompletos.
