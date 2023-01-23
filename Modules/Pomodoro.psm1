Import-Module (Resolve-Path "$PSScriptRoot/FormatHost.psm1") -Force
Import-Module (Resolve-Path "$PSScriptRoot/../Repositories/ConfigRepository.psm1") -Force
# Import-Module (Resolve-Path "$PSScriptRoot/../Config/PomodoroConfig.psd1") -Force

class Pomodoro {
    [int]$activeTime
    [int]$breakTime
    [int]$amountPomodoros
    [PSCustomObject]$formatHost
    [PSCustomObject]$config

    Pomodoro([PSCustomObject]$formatHost, [PSCustomObject]$config) {
        $this.formatHost = $formatHost
        $this.config = $config
    }

    [void]playSound([string]$filePath) {
        (New-Object System.Media.SoundPlayer($filePath)).Play()
    }

    [void]writeTimer([int]$timeRemaining) {
        while ($timeRemaining -gt 0) {
            Write-Host -BackgroundColor Magenta -ForegroundColor White -NoNewline "Time remaining: $($this.formatSecondsToMinutes($timeRemaining))`r"
            Start-Sleep -Seconds 1
            $timeRemaining--
        }
    }

    [string]formatSecondsToMinutes([int]$seconds) {
        $time = [TimeSpan]::FromSeconds($seconds)
        return $time.ToString("mm':'ss")
    }

    [void]chooseOption() {
        $options = $this.config.options()

        $this.formatHost.write("What Pomodoro do you want? (active x break)", "InfoHeader")

        for ($i = 0; $i -lt $options.Length; $i++) {
            $this.formatHost.write("$($i)) $($options[$i]['activeTime'])min x $($options[$i]['breakTime'])min", "Info")
        }

        $choice = $this.formatHost.read("Write the number of the Pomodoro you want:")

        while ($true) {
            if ($choice -As [uint] -Or $choice -eq 0) {
                if ([int]$choice -lt $options.Count) {
                    $this.activeTime = $options[$choice]['activeTime'] * 60
                    $this.breakTime = $options[$choice]['breakTime'] * 60
                    break
                }
            }

            $this.formatHost.write("Error: Can't recognize `"$choice`" as an option. Try again.", "Danger")
            $choice = $this.formatHost.read("Write the number(!) of the Pomodoro you want:")
        }
    }

    [void]chooseAmountPomodoros() {
        $this.formatHost.write("Choose amount of Pomodoros", "InfoHeader")

        $alternatives = 6
        for ($i = 1; $i -le $alternatives; $i++) {
            # Write-Host -ForegroundColor White -BackgroundColor Blue "$i Pomodoro(s) equals $((($this.activeTime + $this.breakTime) * $i) / 60 / 60) hour(s)"
            $this.formatHost.write("$i Pomodoro(s) equals $((($this.activeTime + $this.breakTime) * $i) / 60 / 60) hour(s)", "Info")
        }

        Function Get-Pomodoros {
            while ($true) {

                $pomodoros = $this.formatHost.read("How many Pomodoro(s) do you want")

                if ($pomodoros -As [int]) {
                    $this.amountPomodoros = $pomodoros
                    break
                }
                else {
                    $pomodoros = $this.formatHost.write("Error: `"$pomodoros`" is not a number.", "Danger")
                }
            }
        }
        Get-Pomodoros

        while ($true) {
            $this.formatHost.write("This is your chosen config:", "InfoHeader")

            Write-Host -ForegroundColor White -BackgroundColor Blue "* Pomodoro: $($this.activeTime / 60)min x $($this.breakTime / 60)min."
            Write-Host -ForegroundColor White -BackgroundColor Blue "* Amount: $($this.amountPomodoros) Pomodoro(s)."
            Write-Host -ForegroundColor White -BackgroundColor Blue "* This is equal to $((($this.activeTime / 60 + $this.breakTime / 60) * $this.amountPomodoros) / 60) hour(s)."
            Write-Host -ForegroundColor White -BackgroundColor DarkBlue "Is this correct? (Y/n)"
            $confirmation = Read-Host
            
            if ($confirmation -eq "Y" -or $confirmation -eq "y" -or $confirmation -eq "") {
                break
            } 

            if ($confirmation -eq "N" -or $confirmation -eq "n") {
                Get-Pomodoros
            }
        }
    }

    [void]Start() {
        $this.startPomodoro()
    }

    # Start
    [void]startPomodoro() {
        $this.chooseOption()
        $this.chooseAmountPomodoros()

        for ($i = 1; $i -le $this.amountPomodoros; $i++) {
            Write-Host -ForegroundColor White -BackgroundColor DarkGreen "----------------------"
            Write-Host -ForegroundColor White -BackgroundColor Green " Starting pomodoro #$i of $($this.amountPomodoros)"
            Write-Host -ForegroundColor White -BackgroundColor DarkGreen "----------------------"

            $this.playSound($this.config.sound("start"))

            $this.writeTimer($this.activeTime)

            Write-Host -ForegroundColor DarkYellow -BackgroundColor Yellow "-- BREAK TIME STRT --"

            if ($i -eq $this.amountPomodoros) {
                # TODO: FIND FINISH SOUND
                # $this.playSound('the-remorse-drake.wav')
                $this.playSound($this.config.sound("end"))

                Write-Host -ForegroundColor White -BackgroundColor DarkGreen "----------------------"
                Write-Host -ForegroundColor White -BackgroundColor Green "Pomodoro finished!"
                Write-Host -ForegroundColor White -BackgroundColor DarkGreen "----------------------"
                Break
            }

            # $this.playSound('the-fire-roots.wav')
            $this.playSound($this.config.sound("break"))

            $this.writeTimer($this.breakTime)

            Write-Host -ForegroundColor DarkYellow -BackgroundColor Yellow "-- BREAK TIME OVER --"
        }
    }
}

Function New-Pomodoro {
    $formatHost = New-FormatHost
    $config = New-ConfigRepository
    [Pomodoro]::new($formatHost, $config)
}

Export-ModuleMember -Function New-Pomodoro