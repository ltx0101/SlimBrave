Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the registry path
$registryPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Brave Browser Settings"
$form.Size = New-Object System.Drawing.Size(500, 360)
$form.StartPosition = "CenterScreen"

# Create ToolTip object
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.IsBalloon = $true

# Define the features and their registry keys, along with tooltips
$features = @(
    @{ Name = "Disable Brave Rewards"; Key = "BraveRewardsDisabled"; Tooltip = "Brave's rewards system that rewards tokens for viewing ads." },
    @{ Name = "Disable Brave Wallet"; Key = "BraveWalletDisabled"; Tooltip = "Brave's Wallet feature for managing cryptocurrencies." },
    @{ Name = "Disable Brave VPN"; Key = "BraveVPNDisabled"; Tooltip = "Brave's VPN service, which provides enhanced privacy." },
    @{ Name = "Disable Brave AI Chat"; Key = "BraveAIChatEnabled"; Tooltip = "Brave's AI-powered chat assistant integrated into the browser." },
    @{ Name = "Disable Password Manager"; Key = "PasswordManagerEnabled"; Tooltip = "Brave's built-in password manager for saving and autofilling login credentials." },
    @{ Name = "Disable Tor"; Key = "TorDisabled"; Tooltip = "Brave's ability to browse using Tor for added anonymity." },
    @{ Name = "Disable Sync"; Key = "SyncDisabled"; Tooltip = "Disable syncing bookmarks, passwords, and settings across your devices using Brave Sync." }
)

# Set up labels and checkboxes
$y = 20
$checkboxes = @{}

foreach ($feature in $features) {
    $currentValue = Get-ItemProperty -Path $registryPath -Name $feature.Key -ErrorAction SilentlyContinue

    # Inverted logic for "PasswordManagerEnabled" and "BraveAIChatEnabled"
    $isChecked = if ($feature.Key -in @("PasswordManagerEnabled", "BraveAIChatEnabled")) {
        if ($currentValue.$($feature.Key) -eq 0) { $true } else { $false }
    } else {
        if ($currentValue.$($feature.Key) -eq 1) { $true } else { $false }
    }

    # Add checkbox
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $feature.Name
    $checkbox.Tag = $feature.Key
    $checkbox.Location = New-Object System.Drawing.Point(20, $y)
    $checkbox.Size = New-Object System.Drawing.Size(450, 20)
    $checkbox.Checked = $isChecked

    # Set tooltip for the checkbox
    $toolTip.SetToolTip($checkbox, $feature.Tooltip)

    $form.Controls.Add($checkbox)
    $checkboxes[$feature.Key] = $checkbox

    $y += 30
}

# Add DNS mode dropdown
$dnsLabel = New-Object System.Windows.Forms.Label
$dnsLabel.Text = "Set DNS Over HTTPS Mode:"
$dnsLabel.Location = New-Object System.Drawing.Point(20, $y)
$dnsLabel.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($dnsLabel)

$dnsDropdown = New-Object System.Windows.Forms.ComboBox
$dnsDropdown.Location = New-Object System.Drawing.Point(230, $y)
$dnsDropdown.Size = New-Object System.Drawing.Size(200, 20)
$dnsDropdown.Items.AddRange(@("automatic", "off", "custom"))

# Ensure proper default value for DNS
$currentDnsMode = Get-ItemProperty -Path $registryPath -Name "DnsOverHttpsMode" -ErrorAction SilentlyContinue
if ($currentDnsMode) {
    $dnsDropdown.SelectedItem = switch ($currentDnsMode.DnsOverHttpsMode) {
        0 { "off" }
        1 { "automatic" }
        2 { "custom" }
        default { "automatic" }
    }
} else {
    $dnsDropdown.SelectedIndex = 0  # Default to "automatic" if the registry key doesn't exist
}
$toolTip.SetToolTip($dnsDropdown, "Choose how DNS queries are handled for better security and privacy. Options: automatic/off.")
$form.Controls.Add($dnsDropdown)
$y += 50

# Add Save button
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Save Settings"
$saveButton.Location = New-Object System.Drawing.Point(190, $y)
$saveButton.Size = New-Object System.Drawing.Size(120, 30)
$form.Controls.Add($saveButton)

# Button click event
$saveButton.Add_Click({
    foreach ($key in $checkboxes.Keys) {
        $checkbox = $checkboxes[$key]
        $currentValue = Get-ItemProperty -Path $registryPath -Name $key -ErrorAction SilentlyContinue

        if ($checkbox.Checked -and ($currentValue.$key -ne 1) -and $key -notin @("PasswordManagerEnabled", "BraveAIChatEnabled")) {
            Set-ItemProperty -Path $registryPath -Name $key -Value 1 -Force
        } elseif (-not $checkbox.Checked -and ($currentValue.$key -ne 0) -and $key -notin @("PasswordManagerEnabled", "BraveAIChatEnabled")) {
            Set-ItemProperty -Path $registryPath -Name $key -Value 0 -Force
        }

        # inverted logic for "PasswordManagerEnabled" and "BraveAIChatEnabled"
        if ($key -in @("PasswordManagerEnabled", "BraveAIChatEnabled")) {
            $value = if ($checkbox.Checked) { 0 } else { 1 }
            Set-ItemProperty -Path $registryPath -Name $key -Value $value -Force
        }
    }

    if ($dnsDropdown.SelectedItem) {
        $dnsModeValue = switch ($dnsDropdown.SelectedItem) {
            "off" { 0 }
            "automatic" { 1 }
            "custom" { 2 }
        }

        # Ensure the DnsOverHttpsMode property exists and update it
        if (-not (Test-Path -Path "$registryPath\DnsOverHttpsMode")) {
            New-ItemProperty -Path $registryPath -Name "DnsOverHttpsMode" -Value $dnsModeValue -PropertyType DWord -Force
        } else {
            Set-ItemProperty -Path $registryPath -Name "DnsOverHttpsMode" -Value $dnsModeValue -Force
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Settings saved successfully! Restart Brave for the changes to take effect.", "SlimBrave", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Show the form
[void] $form.ShowDialog()
