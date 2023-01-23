
class ConfigRepository {
    [PSCustomObject]$config

    ConfigRepository([PSCustomObject]$config) {
        $this.config = $config
    }

    [string]sound([string]$event) {
        # (New-Object System.Media.SoundPlayer(Resolve-Path "$PSScriptRoot/../Resources/$soundFile")).Play()
        return Resolve-Path "$PSScriptroot/../Resources/$($this.config.sounds.default[$event])"
    }

    [System.Object[]]options() {
        return $this.config.options
    }

    [System.Object[]]formattedConfig() {
        return @(
            "* Pomodoro: $($this.activeTime() / 60)min x $($this.breakTime() / 60)min."
            "* Amount: $($this.amountPomodoros()) Pomodoro(s)."
            "* This is equal to $((($this.activeTime() / 60 + $this.breakTime() / 60) * $this.amountPomodoros()) / 60) hour(s)."
        )
    }

    <##
     # ActiveTime
     ##>
    [void]setActivetime([int]$activeTime) { $this.config.activeTime = $activeTime }
    [int]activetime() { return $this.config.activeTime }

    <##
     # BreakTime
     ##>
    [void]setBreakTime([int]$breakTime) { $this.config.breakTime = $breakTime }
    [int]breakTime() { return $this.config.breakTime }

    <##
     # AmountPomodoros
     ##>
    [void]setAmountPomodoros([int]$amountPomodoros) { $this.config.amountPomodoros = $amountPomodoros }
    [int]amountPomodoros() { return $this.config.amountPomodoros }

}

Function New-ConfigRepository {
    $config = Import-PowerShellDataFile -Path "$PSScriptRoot/../Config/PomodoroConfig.psd1"
    [ConfigRepository]::new($config)
}