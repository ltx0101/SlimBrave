Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

$registryPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"

if (-not (Test-Path -Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

$registryKeys = @{
    "BraveRewardsDisabled" = 0
    "BraveWalletDisabled" = 0
    "BraveVPNDisabled" = 0
    "BraveAIChatEnabled" = 1
    "PasswordManagerEnabled" = 1
    "TorDisabled" = 0
    "DnsOverHttpsMode" = 2
    "BraveAdsEnabled" = 1
    "SyncDisabled" = 0
}

foreach ($key in $registryKeys.Keys) {
    if (-not (Get-ItemProperty -Path $registryPath -Name $key -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $registryPath -Name $key -Value $registryKeys[$key] -PropertyType DWord -Force
        Write-Host "Added registry key: $key with value $($registryKeys[$key])"
    } else {
        Write-Host "Registry key $key already exists."
    }
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

Clear-Host

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
$form.Text = "SlimBrave"
$form.ForeColor = [System.Drawing.Color]::White
$form.Size = New-Object System.Drawing.Size(400, 450)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(255, 25, 25, 25)
$form.MaximizeBox = $false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog


# Add checkboxes for features
$features = @(
    @{ Name = "Disable Brave Rewards"; Key = "BraveRewardsDisabled" },
    @{ Name = "Disable Brave Wallet"; Key = "BraveWalletDisabled" },
    @{ Name = "Disable Brave VPN"; Key = "BraveVPNDisabled" },
    @{ Name = "Disable Brave AI Chat"; Key = "BraveAIChatEnabled" },
    @{ Name = "Disable Password Manager"; Key = "PasswordManagerEnabled" },
    @{ Name = "Disable Tor"; Key = "TorDisabled" },
    @{ Name = "Disable Automatic HTTPS Upgrades"; Key = "HttpsUpgradesEnabled" },
    @{ Name = "Disable Brave Ads"; Key = "BraveAdsEnabled" },
    @{ Name = "Disable Sync"; Key = "SyncDisabled" }
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
$saveButton.BackColor = [System.Drawing.Color]::FromArgb(150, 102, 102, 102)
$saveButton.ForeColor = [System.Drawing.Color]::LightSalmon


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

    [System.Windows.Forms.MessageBox]::Show("Success! Restart Brave to see changes", "SlimBrave", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

# Show the form
[void] $form.ShowDialog()
