Import-Module (Resolve-Path("$PSScriptRoot/Modules/Pomodoro.psm1")) -Force

$pomodoro = New-Pomodoro

$pomodoro.Start()