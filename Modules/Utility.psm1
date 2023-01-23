class Utility {
    [void]playSound([string]$filePath) {
        (New-Object System.Media.SoundPlayer($filePath)).Play()
    }

    [string]formatSecondsToMinutes([int]$seconds) {
        $time = [TimeSpan]::FromSeconds($seconds)
        return $time.ToString("mm':'ss")
    }

    [void]writeTimer([int]$timeRemaining) {
        $originalTime = $timeRemaining
        while ($timeRemaining -gt 0) {
            # Write-Host -BackgroundColor Magenta -ForegroundColor White -NoNewline "Time remaining: $($this.formatSecondsToMinutes($timeRemaining))`r"
            Write-Progress -Activity "Time" -Status "Remaining: $($this.formatSecondsToMinutes($timeRemaining))" -PercentComplete ($timeRemaining / $originalTime * 100 )

            Start-Sleep -Seconds 1
            $timeRemaining--
        }
    }
}

Function New-Utility {
    [Utility]::new()
}

Export-ModuleMember -Function New-Utility