Import-Module (Resolve-Path "$PSScriptRoot/FormatHost.psm1") -Force
Import-Module (Resolve-Path "$PSScriptRoot/../Repositories/ConfigRepository.psm1") -Force
Import-Module (Resolve-Path "$PSScriptRoot/Utility.psm1") -Force

class Pomodoro {
    [PSCustomObject]$formatHost
    [PSCustomObject]$config
    [PSCustomObject]$utility

    Pomodoro([PSCustomObject]$formatHost, [PSCustomObject]$config, [PSCustomObject]$utility) {
        $this.formatHost = $formatHost
        $this.config = $config
        $this.utility = $utility
    }

    [void]start() {
        $this.chooseOption()
        $this.choosePomodoroCount()
        $this.confirmConfig()
        $this.startTimers()
    }


    [void]chooseOption() {
        $this.formatHost.write("What Pomodoro do you want? (active x break)", "InfoHeader")
        $this.displayOptions()
        $this.getValidOptionChoice($this.formatHost.read("Write the number of the Pomodoro you want:"))
    }

    [void]displayOptions() {
        $options = $this.config.options()
        for ($i = 0; $i -lt $options.Length; $i++) {
            $this.formatHost.write("$($i)) $($options[$i]['activeTime'])min x $($options[$i]['breakTime'])min", "Info")
        }
    }

    [void]getValidOptionChoice([string]$choice) {
        $options = $this.config.options()
        while ($true) {
            if ($choice -As [uint] -Or $choice -eq 0) {
                if ([int]$choice -lt $options.Count) {
                    $this.config.setActiveTime($options[$choice]['activeTime'] * 60) 
                    $this.config.setBreakTime($options[$choice]['breakTime'] * 60)
                    break
                }
            }
            $this.formatHost.write("Error: Can't recognize `"$choice`" as an option. Try again.", "Danger")
            $choice = $this.formatHost.read("Write the number(!) of the Pomodoro you want:")
        }
    }

    [void]choosePomodoroCount() {
        $this.formatHost.write("Choose amount of Pomodoros", "InfoHeader")
        $this.displayPomodoroPreviews()
        $this.promptPomodoroCount()
    }

    [void]displayPomodoroPreviews() {
        for ($i = 1; $i -le $this.config.pomodoroPreviews(); $i++) {
            $this.formatHost.write("$i Pomodoro(s) equals $((($this.config.activeTime() + $this.config.breakTime()) * $i) / 60 / 60) hour(s)", "Info")
        }
    }

    [void]promptPomodoroCount() {
        while ($true) {
            $pomodoros = $this.formatHost.read("How many Pomodoro(s) do you want")

            if ($pomodoros -As [int]) {
                $this.config.setAmountPomodoros($pomodoros)
                break
            }
            else {
                $pomodoros = $this.formatHost.write("Error: `"$pomodoros`" is not a number.", "Danger")
            }
        }
    }


    [void]confirmConfig() {
        while ($true) {
            $this.formatHost.write("This is your config:", "InfoHeader")

            $this.config.formattedConfig() | ForEach-Object {
                $this.formatHost.write($_, "Info")
            } 
            
            $confirmation = $this.formatHost.read("Is this correct? (Y/n)")
            
            if ($confirmation -eq "Y" -or $confirmation -eq "y" -or $confirmation -eq "") {
                break
            } 
            elseif ($confirmation -eq "N" -or $confirmation -eq "n") {
                # TODO: Should restart the whole process
                $this.promptPomodoroCount()
            }
        }
    }

    [void]startTimers() {
        for ($i = 1; $i -le $this.config.amountPomodoros(); $i++) {

            $this.startTimer($i)

            if ($i -eq $this.config.amountPomodoros()) {
                $this.endTimer()
                Break
            }

            $this.breakTimer()
        }
    }

    [void]startTimer($index) {
        $this.utility.playSound($this.config.sound("start"))
        $this.formatHost.write("Starting Pomodoro #$index of $($this.config.amountPomodoros()) ", "Success")
        $this.utility.writeTimer($this.config.activeTime())
    }

    [void]breakTimer() {
        $this.utility.playSound($this.config.sound("break"))
        $this.formatHost.write("Break started             ", "Warning")
        $this.utility.writeTimer($this.config.breakTime())
    }

    [void]endTimer() {
        $this.utility.playSound($this.config.sound("end"))
        $this.formatHost.write("Pomodoro finished!        ", "Success")
    }
}

Function New-Pomodoro {
    $formatHost = New-FormatHost
    $config = New-ConfigRepository
    $utility = New-Utility
    [Pomodoro]::new($formatHost, $config, $utility)
}

Export-ModuleMember -Function New-Pomodoro