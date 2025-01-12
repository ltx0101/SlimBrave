# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "This script requires administrative privileges. Please run as an administrator."
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

function Show-Menu {
    Clear-Host
    Write-Output "Multi-Selection Menu for Brave Browser Registry Settings"
    Write-Output "---------------------------------------------------------"
    Write-Output " 1. Disable/Enable Brave Rewards"
    Write-Output " 2. Disable/Enable Brave Wallet"
    Write-Output " 3. Disable/Enable Brave VPN"
    Write-Output " 4. Disable/Enable Brave AI Chat"
    Write-Output " 5. Disable/Enable Password Manager"
    Write-Output " 6. Disable/Enable Tor"
    Write-Output " 7. Disable/Enable Automatic HTTPS upgrades"
    Write-Output " 8. Disable/Enable Brave Ads"
    Write-Output " 9. Disable/Enable Sync"
    Write-Output "10. Set DNS Over HTTPS Mode"
    Write-Output "---------------------------------------------------------"
    Write-Output "11. Exit"
    Write-Output ""
}

function Process-Choice {
    param (
        [string[]] $choices
    )
    foreach ($i in $choices) {
        switch ($i) {
            1 { Toggle "BraveRewardsDisabled" }
            2 { Toggle "BraveWalletDisabled" }
            3 { Toggle "BraveVPNDisabled" }
            4 { Toggle "BraveAIChatEnabled" }
            5 { Toggle "PasswordManagerEnabled" }
            6 { Toggle "TorDisabled" }
            7 { Toggle "HttpsUpgradesEnabled" }
            8 { Toggle "BraveAdsEnabled" }
            9 { Toggle "SyncDisabled" }
            10 { Set-DnsMode }
            11 { exit }
            default { Write-Host "Invalid choice: $i" }
        }
    }
}

function Toggle {
    param (
        [string] $feature
    )
    $regKey = "HKLM:\Software\Policies\BraveSoftware\Brave"
    
    # Check the current value of the feature
    $currentValue = Get-ItemProperty -Path $regKey -Name $feature -ErrorAction SilentlyContinue
    
    if ($currentValue.$feature -eq 1) {
        Set-ItemProperty -Path $regKey -Name $feature -Value 0 -Force
    } else {
        Set-ItemProperty -Path $regKey -Name $feature -Value 1 -Force
    }
}

function Set-DnsMode {
    $dnsMode = Read-Host "Enter DNS Over HTTPS mode (e.g., automatic, off)"
    Set-ItemProperty -Path "HKLM:\Software\Policies\BraveSoftware\Brave" -Name "DnsOverHttpsMode" -Value $dnsMode -Type String -Force
    Write-Host "DNS Over HTTPS Mode has been set."
}

# Main Loop
do {
    Show-Menu
    $choice = Read-Host "Enter the number of your choice (separate multiple by commas)"
    $choices = $choice -split ','
    Process-Choice -choices $choices
} while ($true)
