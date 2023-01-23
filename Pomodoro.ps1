Import-Module (Resolve-Path("$PSScriptRoot/Modules/Pomodoro.psm1")) -Force

(New-Pomodoro).start()
