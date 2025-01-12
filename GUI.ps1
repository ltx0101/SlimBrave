Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "This script requires administrative privileges. Please run as an administrator."
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

# Function to toggle a registry value
function Toggle-Registry {
    param (
        [string] $feature
    )
    $regKey = "HKLM:\\Software\\Policies\\BraveSoftware\\Brave"

    # Check the current value of the feature
    $currentValue = Get-ItemProperty -Path $regKey -Name $feature -ErrorAction SilentlyContinue

    if ($currentValue.$feature -eq 1) {
        Set-ItemProperty -Path $regKey -Name $feature -Value 0 -Force
    } else {
        Set-ItemProperty -Path $regKey -Name $feature -Value 1 -Force
    }
}

# Function to set DNS mode
function Set-DnsMode {
    param (
        [string] $dnsMode
    )
    $regKey = "HKLM:\\Software\\Policies\\BraveSoftware\\Brave"
    Set-ItemProperty -Path $regKey -Name "DnsOverHttpsMode" -Value $dnsMode -Type String -Force
    [System.Windows.Forms.MessageBox]::Show("DNS Over HTTPS Mode has been set to $dnsMode.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Brave Browser Settings"
$form.Size = New-Object System.Drawing.Size(400, 500)
$form.StartPosition = "CenterScreen"

# Add checkboxes for features
$features = @(
    @{ Name = "Disable/Enable Brave Rewards"; Key = "BraveRewardsDisabled" },
    @{ Name = "Disable/Enable Brave Wallet"; Key = "BraveWalletDisabled" },
    @{ Name = "Disable/Enable Brave VPN"; Key = "BraveVPNDisabled" },
    @{ Name = "Disable/Enable Brave AI Chat"; Key = "BraveAIChatEnabled" },
    @{ Name = "Disable/Enable Password Manager"; Key = "PasswordManagerEnabled" },
    @{ Name = "Disable/Enable Tor"; Key = "TorDisabled" },
    @{ Name = "Disable/Enable Automatic HTTPS Upgrades"; Key = "HttpsUpgradesEnabled" },
    @{ Name = "Disable/Enable Brave Ads"; Key = "BraveAdsEnabled" },
    @{ Name = "Disable/Enable Sync"; Key = "SyncDisabled" }
)

$y = 20
$checkboxes = @{}
foreach ($feature in $features) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $feature.Name
    $checkbox.Tag = $feature.Key
    $checkbox.Location = New-Object System.Drawing.Point(20, $y)
    $checkbox.Size = New-Object System.Drawing.Size(350, 20)
    $form.Controls.Add($checkbox)
    $checkboxes[$feature.Key] = $checkbox
    $y += 30
}

# Add DNS mode dropdown
$dnsLabel = New-Object System.Windows.Forms.Label
$dnsLabel.Text = "DNS Over HTTPS Mode:"
$dnsLabel.Location = New-Object System.Drawing.Point(20, $y)
$dnsLabel.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($dnsLabel)

$dnsDropdown = New-Object System.Windows.Forms.ComboBox
$dnsDropdown.Location = New-Object System.Drawing.Point(170, $y)
$dnsDropdown.Size = New-Object System.Drawing.Size(150, 20)
$dnsDropdown.Items.AddRange(@("automatic", "off", "custom"))
$form.Controls.Add($dnsDropdown)
$y += 40

# Add Save button
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Save Settings"
$saveButton.Location = New-Object System.Drawing.Point(150, $y)
$saveButton.Size = New-Object System.Drawing.Size(100, 30)
$form.Controls.Add($saveButton)

# Button click event
$saveButton.Add_Click({
    foreach ($key in $checkboxes.Keys) {
        $checkbox = $checkboxes[$key]
        if ($checkbox.Checked) {
            Toggle-Registry -feature $key
        }
    }
    
    if ($dnsDropdown.SelectedItem) {
        Set-DnsMode -dnsMode $dnsDropdown.SelectedItem
    }

    [System.Windows.Forms.MessageBox]::Show("Settings have been saved.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Show the form
[void] $form.ShowDialog()
