class FormatHost {
    [void]write([string]$text, [string]$type) {
        $colors = @{
            Info = @{ foregroundColor = 'White'; backgroundColor = 'Blue' }
            InfoHeader = @{ foregroundColor = 'White'; backgroundColor = 'DarkBlue' }
            Success = @{ foregroundColor = 'DarkGreen'; backgroundColor = 'Green' }
            Danger = @{ foregroundColor = 'White'; backgroundColor = 'DarkRed' }
        }

        if (! $colors.ContainsKey($type)) {
            Write-Host -ForegroundColor $colors.Danger['foregroundColor'] -BackgroundColor $colors.Danger['backgroundColor'] "Error: `"$type`" doesnt exist in types."
            throw New-Object System.ArgumentException
        }

        Write-Host -ForegroundColor ($colors[$type]['foregroundColor']) -BackgroundColor ($colors[$type]['backgroundColor']) $text
    }

    [string]read([string]$prompt) {
        $this.write($prompt, "InfoHeader")
        return Read-Host
    }
}

Function New-FormatHost {
    [FormatHost]::new()
}

Export-ModuleMember -Function New-FormatHost