if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$registryPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"

if (-not (Test-Path -Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

Clear-Host

function Set-DnsMode {
    param (
        [string] $dnsMode
    )
    $regKey = "HKLM:\\Software\\Policies\\BraveSoftware\\Brave"
    Set-ItemProperty -Path $regKey -Name "DnsOverHttpsMode" -Value $dnsMode -Type String -Force
    [System.Windows.Forms.MessageBox]::Show("DNS Over HTTPS Mode has been set to $dnsMode.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "SlimBrave"
$form.ForeColor = [System.Drawing.Color]::White
$form.Size = New-Object System.Drawing.Size(755, 670)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(255, 25, 25, 25)
$form.MaximizeBox = $false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

$allFeatures = @()

$leftPanel = New-Object System.Windows.Forms.Panel
$leftPanel.Location = New-Object System.Drawing.Point(20, 20)
$leftPanel.Size = New-Object System.Drawing.Size(340,500)
$leftPanel.BackColor = [System.Drawing.Color]::FromArgb(255, 35, 35, 35)
$leftPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($leftPanel)

$telemetryLabel = New-Object System.Windows.Forms.Label
$telemetryLabel.Text = "Telemetry & Reporting"
$telemetryLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10.5, [System.Drawing.FontStyle]::Bold)
$telemetryLabel.Location = New-Object System.Drawing.Point(28, 10)
$telemetryLabel.Size = New-Object System.Drawing.Size(300, 20)
$telemetryLabel.ForeColor = [System.Drawing.Color]::LightSalmon
$leftPanel.Controls.Add($telemetryLabel)

$telemetryFeatures = @(
    @{ Name = "Disable Metrics Reporting"; Key = "MetricsReportingEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Safe Browsing Reporting"; Key = "SafeBrowsingExtendedReportingEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable URL Data Collection"; Key = "UrlKeyedAnonymizedDataCollectionEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Feedback Surveys"; Key = "FeedbackSurveysEnabled"; Value = 0; Type = "DWord" }
)

$y = 35
foreach ($feature in $telemetryFeatures) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $feature.Name
    $checkbox.Tag = $feature
    $checkbox.Location = New-Object System.Drawing.Point(30, $y)
    $checkbox.Size = New-Object System.Drawing.Size(300, 20)
    $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $leftPanel.Controls.Add($checkbox)
    $allFeatures += $checkbox
    $y += 25
}

$y += 10

$privacyLabel = New-Object System.Windows.Forms.Label
$privacyLabel.Text = "Privacy & Security"
$privacyLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Bold)
$privacyLabel.Location = New-Object System.Drawing.Point(28, $y)
$privacyLabel.Size = New-Object System.Drawing.Size(300, 20)
$privacyLabel.ForeColor = [System.Drawing.Color]::LightSalmon
$leftPanel.Controls.Add($privacyLabel)
$y += 25

$privacyFeatures = @(
    @{ Name = "Disable Safe Browsing"; Key = "SafeBrowsingProtectionLevel"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Autofill (Addresses)"; Key = "AutofillAddressEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Autofill (Credit Cards)"; Key = "AutofillCreditCardEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Password Manager"; Key = "PasswordManagerEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Browser Sign-in"; Key = "BrowserSignin"; Value = 0; Type = "DWord" },
    @{ Name = "Disable WebRTC IP Leak"; Key = "WebRtcIPHandling"; Value = "disable_non_proxied_udp"; Type = "String" },
    @{ Name = "Disable QUIC Protocol"; Key = "QuicAllowed"; Value = 0; Type = "DWord" },
    @{ Name = "Block Third Party Cookies"; Key = "BlockThirdPartyCookies"; Value = 1; Type = "DWord" },
    @{ Name = "Enable Do Not Track"; Key = "EnableDoNotTrack"; Value = 1; Type = "DWord" },
    @{ Name = "Force Google SafeSearch"; Key = "ForceGoogleSafeSearch"; Value = 1; Type = "DWord" },
    @{ Name = "Disable Incognito Mode"; Key = "IncognitoModeAvailability"; Value = 1; Type = "DWord" },
    @{ Name = "Force Incognito Mode"; Key = "IncognitoModeAvailability"; Value = 2; Type = "DWord" }
)

foreach ($feature in $privacyFeatures) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $feature.Name
    $checkbox.Tag = $feature
    $checkbox.Location = New-Object System.Drawing.Point(30, $y)
    $checkbox.Size = New-Object System.Drawing.Size(300, 20)
    $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $leftPanel.Controls.Add($checkbox)
    $allFeatures += $checkbox
    $y += 25
}

$rightPanel = New-Object System.Windows.Forms.Panel
$rightPanel.Location = New-Object System.Drawing.Point(380, 20)
$rightPanel.Size = New-Object System.Drawing.Size(340, 540)
$rightPanel.BackColor = [System.Drawing.Color]::FromArgb(255, 35, 35, 35)
$rightPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($rightPanel)

$y = 5

$braveLabel = New-Object System.Windows.Forms.Label
$braveLabel.Text = "Brave Features"
$braveLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Bold)
$braveLabel.Location = New-Object System.Drawing.Point(28, $y)
$braveLabel.Size = New-Object System.Drawing.Size(300, 20)
$braveLabel.ForeColor = [System.Drawing.Color]::LightSalmon
$rightPanel.Controls.Add($braveLabel)
$y += 25

$braveFeatures = @(
    @{ Name = "Disable Brave Rewards"; Key = "BraveRewardsDisabled"; Value = 1; Type = "DWord" },
    @{ Name = "Disable Brave Wallet"; Key = "BraveWalletDisabled"; Value = 1; Type = "DWord" },
    @{ Name = "Disable Brave VPN"; Key = "BraveVPNDisabled"; Value = 1; Type = "DWord" },
    @{ Name = "Disable Brave AI Chat"; Key = "BraveAIChatEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Brave Shields"; Key = "BraveShieldsDisabledForUrls"; Value = '["https://*", "http://*"]'; Type = "String" },
    @{ Name = "Disable Tor"; Key = "TorDisabled"; Value = 1; Type = "DWord" },
    @{ Name = "Disable Sync"; Key = "SyncDisabled"; Value = 1; Type = "DWord" }
    
)

foreach ($feature in $braveFeatures) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $feature.Name
    $checkbox.Tag = $feature
    $checkbox.Location = New-Object System.Drawing.Point(30, $y)
    $checkbox.Size = New-Object System.Drawing.Size(300, 20)
    $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $rightPanel.Controls.Add($checkbox)
    $allFeatures += $checkbox
    $y += 25
}

$y += 10

$perfLabel = New-Object System.Windows.Forms.Label
$perfLabel.Text = "Performance & Bloat"
$perfLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 11, [System.Drawing.FontStyle]::Bold)
$perfLabel.Location = New-Object System.Drawing.Point(28, $y)
$perfLabel.Size = New-Object System.Drawing.Size(300, 20)
$perfLabel.ForeColor = [System.Drawing.Color]::LightSalmon
$rightPanel.Controls.Add($perfLabel)
$y += 25

$perfFeatures = @(
    @{ Name = "Disable Background Mode"; Key = "BackgroundModeEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Media Recommendations"; Key = "MediaRecommendationsEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Shopping List"; Key = "ShoppingListEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Always Open PDF Externally"; Key = "AlwaysOpenPdfExternally"; Value = 1; Type = "DWord" },
    @{ Name = "Disable Translate"; Key = "TranslateEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Spellcheck"; Key = "SpellcheckEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Promotions"; Key = "PromotionsEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Search Suggestions"; Key = "SearchSuggestEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Printing"; Key = "PrintingEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Default Browser Prompt"; Key = "DefaultBrowserSettingEnabled"; Value = 0; Type = "DWord" },
    @{ Name = "Disable Developer Tools"; Key = "DeveloperToolsDisabled"; Value = 1; Type = "DWord" }
)

foreach ($feature in $perfFeatures) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $feature.Name
    $checkbox.Tag = $feature
    $checkbox.Location = New-Object System.Drawing.Point(30, $y)
    $checkbox.Size = New-Object System.Drawing.Size(300, 20)
    $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $rightPanel.Controls.Add($checkbox)
    $allFeatures += $checkbox
    $y += 25
}

$y = 780

$dnsLabel = New-Object System.Windows.Forms.Label
$dnsLabel.Text = "DNS Over HTTPS Mode:"
$dnsLabel.Location = New-Object System.Drawing.Point(35, 535)
$dnsLabel.Size = New-Object System.Drawing.Size(140, 20)
$form.Controls.Add($dnsLabel)

$dnsDropdown = New-Object System.Windows.Forms.ComboBox
$dnsDropdown.Location = New-Object System.Drawing.Point(180,530)
$dnsDropdown.Size = New-Object System.Drawing.Size(150, 20)
$dnsDropdown.Items.AddRange(@("automatic", "off", "custom"))
$dnsDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$dnsDropdown.BackColor = [System.Drawing.Color]::FromArgb(255, 25, 25, 25)
$dnsDropdown.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($dnsDropdown)
$y += 40

$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = "Export Settings"
$exportButton.Location = New-Object System.Drawing.Point(50, 580)
$exportButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($exportButton)
$exportButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$exportButton.FlatAppearance.BorderSize = 1
$exportButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
$exportButton.BackColor = [System.Drawing.Color]::FromArgb(150, 102, 102, 102)
$exportButton.ForeColor = [System.Drawing.Color]::LightSalmon

$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = "Import Settings"
$importButton.Location = New-Object System.Drawing.Point(210, 580)
$importButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($importButton)
$importButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$importButton.FlatAppearance.BorderSize = 1
$importButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
$importButton.BackColor = [System.Drawing.Color]::FromArgb(150, 102, 102, 102)
$importButton.ForeColor = [System.Drawing.Color]::LightSkyBlue

$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Apply Settings"
$saveButton.Location = New-Object System.Drawing.Point(410,580)
$saveButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($saveButton)
$saveButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$saveButton.FlatAppearance.BorderSize = 1
$saveButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
$saveButton.BackColor = [System.Drawing.Color]::FromArgb(150, 102, 102, 102)
$saveButton.ForeColor = [System.Drawing.Color]::LightGreen

$saveButton.Add_Click({
    foreach ($checkbox in $allFeatures) {
        if ($checkbox.Checked) {
            $feature = $checkbox.Tag
            try {
                Set-ItemProperty -Path $registryPath -Name $feature.Key -Value $feature.Value -Type $feature.Type -Force
                Write-Host "Set $($feature.Key) to $($feature.Value)"
            } catch {
                Write-Host "Failed to set $($feature.Key): $_"
            }
        }
    }
    
    if ($dnsDropdown.SelectedItem) {
        Set-DnsMode -dnsMode $dnsDropdown.SelectedItem
    }

    [System.Windows.Forms.MessageBox]::Show("Settings applied successfully! Restart Brave to see changes.", "SlimBrave", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

function Reset-AllSettings {
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Warning: This will erase ALL Brave policy settings and restore them to their default state. Do you wish to continue?", 
        "Confirm SlimBrave Reset", 
        [System.Windows.Forms.MessageBoxButtons]::YesNo, 
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    
    if ($confirm -eq "Yes") {
        try {
            Remove-Item -Path $registryPath -Recurse -Force
            New-Item -Path $registryPath -Force | Out-Null

            [System.Windows.Forms.MessageBox]::Show(
                "All Brave policy settings have been successfully reset to their default values.", 
                "Reset Successful", 
                [System.Windows.Forms.MessageBoxButtons]::OK, 
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            return $true
        } catch {
            [System.Windows.Forms.MessageBox]::Show(
                "An error occurred while resetting the settings: $_", 
                "Reset Failed", 
                [System.Windows.Forms.MessageBoxButtons]::OK, 
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            return $false
        }
    }

    return $false
}

$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = "Reset All Settings"
$resetButton.Location = New-Object System.Drawing.Point(570,580)
$resetButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($resetButton)
$resetButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$resetButton.FlatAppearance.BorderSize = 1
$resetButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
$resetButton.BackColor = [System.Drawing.Color]::FromArgb(150, 102, 102, 102)
$resetButton.ForeColor = [System.Drawing.Color]::LightCoral
$y += 40

$resetButton.Add_Click({
    if (Reset-AllSettings) {
        if (-not (Test-Path -Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
        }
    }
})

$exportButton.Add_Click({
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*"
    $saveFileDialog.Title = "Export SlimBrave Settings"
    $saveFileDialog.InitialDirectory = [Environment]::GetFolderPath("MyDocuments")
    $saveFileDialog.FileName = "SlimBraveSettings.json"
    
    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $settingsToExport = @{
            Features = @()
            DnsMode = $dnsDropdown.SelectedItem
        }
        
        foreach ($checkbox in $allFeatures) {
            if ($checkbox.Checked) {
                $settingsToExport.Features += $checkbox.Tag.Key
            }
        }
        
        try {
            $settingsToExport | ConvertTo-Json | Out-File -FilePath $saveFileDialog.FileName -Force
            [System.Windows.Forms.MessageBox]::Show("Settings exported successfully to:`n$($saveFileDialog.FileName)", "Export Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to export settings: $_", "Export Failed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})

$importButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "JSON files (*.json)|*.json|All files (*.*)|*.*"
    $openFileDialog.Title = "Import SlimBrave Settings"
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath("MyDocuments")
    
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        try {
            $importedSettings = Get-Content -Path $openFileDialog.FileName -Raw | ConvertFrom-Json
            
            foreach ($checkbox in $allFeatures) {
                $checkbox.Checked = $false
            }
            
            foreach ($featureKey in $importedSettings.Features) {
                foreach ($checkbox in $allFeatures) {
                    if ($checkbox.Tag.Key -eq $featureKey) {
                        $checkbox.Checked = $true
                        break
                    }
                }
            }
            
            if ($importedSettings.DnsMode) {
                $dnsDropdown.SelectedItem = $importedSettings.DnsMode
            }
            
            [System.Windows.Forms.MessageBox]::Show("Settings imported successfully from:`n$($openFileDialog.FileName)", "Import Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to import settings: $_", "Import Failed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})

[void] $form.ShowDialog()
