# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Script information and manifest
$scriptName = $MyInvocation.MyCommand.Name
$version = "1.0"
$author = "SlimBrave"

# Check for administrative privileges
function Test-AdminPrivileges {
    [CmdletBinding()]
    param ()
    
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell -ArgumentList "-File `"$scriptName`"" -Verb RunAs
        exit
    }
}

Test-AdminPrivileges

# Registry constants and settings
$registryPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"

function Initialize-RegistrySettings {
    [CmdletBinding()]
    param ()
    
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }
}

Initialize-RegistrySettings

# Define default registry values
$defaultSettings = @{
    BraveRewardsDisabled               = 0
    BraveWalletDisabled                = 0
    BraveVPNDisabled                   = 0
    BraveAIChatEnabled                 = 1
    PasswordManagerEnabled             = 1
    TorDisabled                        = 0
    DnsOverHttpsMode                   = 2
    BraveAdsEnabled                    = 1
    SyncDisabled                       = 0
}

# Function to get current registry value
function Get-RegistryValue {
    [CmdletBinding()]
    param (
        [string] $key
    )
    
    try {
        return (Get-ItemProperty -Path "$registryPath\$key" -ErrorAction Stop).$
    } catch {
        return $null
    }
}

# Function to set registry value
function Set-RegistryValue {
    [CmdletBinding()]
    param (
        [string] $key,
        [int] $value
    )
    
    try {
        if (-not (Get-ItemProperty -Path "$registryPath" -Name $key -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path "$registryPath" -Name $key -Value $value -PropertyType DWord -Force
            return $true
        } else {
            Set-ItemProperty -Path "$registryPath" -Name $key -Value $value -Force
            return $true
        }
    } catch {
        Write-Error "Failed to set registry value for key: $key"
        return $false
    }
}

# Function to toggle a registry value
function Toggle-Registry {
    [CmdletBinding()]
    param (
        [string] $feature
    )
    
    try {
        $currentValue = Get-ItemProperty -Path "$registryPath" -Name $feature -ErrorAction SilentlyContinue
        if ($currentValue) {
            Set-RegistryValue -key $feature -value ($currentValue.Value - 1)
            return $true
        }
        return $false
    } catch {
        Write-Error "Failed to toggle registry value for feature: $feature"
        return $false
    }
}

# Function to set DNS mode
function Set-DnsMode {
    [CmdletBinding()]
    param (
        [string] $dnsMode
    )
    
    try {
        Set-ItemProperty -Path "$registryPath" -Name "DnsOverHttpsMode" -Value $dnsMode -Type String -Force
        return $true
    } catch {
        Write-Error "Failed to set DNS mode to: $dnsMode"
        return $false
    }
}

# Function to create and initialize the form
function Initialize-GUI {
    [CmdletBinding()]
    param ()

    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "SlimBrave v$version"
    $form.ForeColor = [System.Drawing.Color]::White
    $form.Size = New-Object System.Drawing.Size(400, 450)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::FromArgb(255, 25, 25, 25)
    $form.MaximizeBox = $false
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

    # Create controls container for better layout management
    $controlsContainer = New-Object System.Windows.Forms.TableLayoutPanel
    $controlsContainer.Dock = [System.Windows.Forms.DockStyle]::Fill
    $form.Controls.Add($controlsContainer)

    # Define form elements and layout
    $currentY = 0
    $checkboxes = @{}
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

    foreach ($feature in $features) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $feature.Name
        $checkbox.Tag = $feature.Key
        $checkbox.Location = New-Object System.Drawing.Point(20, $currentY)
        $checkbox.Size = New-Object System.Drawing.Size(350, 20)
        $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $checkbox.UseVisualStyleBackColor = $false
        $checkbox.BackColor = [System.Drawing.Color]::FromArgb(192, 192, 192)
        
        # Set initial state based on current value
        if ($currentValue = Get-RegistryValue -key $feature.Key) {
            $checkbox.Checked = ($currentValue.Value -eq 1)
        } else {
            $checkbox.Enabled = $false
        }
        
        $form.Controls.Add($checkbox)
        $checkboxes[$feature.Key] = $checkbox
        $currentY += 30
    }

    # DNS mode controls
    $dnsGroupLabel = New-Object System.Windows.Forms.Label
    $dnsGroupLabel.Text = "DNS Over HTTPS Mode:"
    $dnsGroupLabel.Location = New-Object System.Drawing.Point(20, $currentY)
    $dnsGroupLabel.Size = New-Object System.Drawing.Size(150, 20)
    
    $dnsDropdown = New-Object System.Windows.Forms.ComboBox
    $dnsDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
    $dnsDropdown.FormattingEnabled = $true
    $dnsDropdown.Items.AddRange(@("automatic", "off", "custom"))
    $dnsDropdown.SelectedItem = ("automatic" -eq (Get-RegistryValue -key DnsOverHttpsMode).Value) ? "automatic" : "off"
    
    $dnsDropdown.Location = New-Object System.Drawing.Point(170, $currentY)
    $dnsDropdown.Size = New-Object System.Drawing.Size(150, 20)
    $dnsDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $dnsDropdown.BackColor = [System.Drawing.Color]::FromArgb(255, 25, 25, 25)
    $dnsDropdown.ForeColor = [System.Drawing.Color]::White

    # Save button configuration
    $saveButton = New-Object System.Windows.Forms.Button
    $saveButton.Text = "Save Settings"
    $saveButton.Location = New-Object System.Drawing.Point(150, $currentY + 40)
    $saveButton.Size = New-Object System.Drawing.Size(100, 30)
    $saveButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $saveButton.FlatAppearance.BorderSize = 1
    $saveButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
    $saveButton.BackColor = [System.Drawing.Color]::FromArgb(150, 102, 102, 102)
    $saveButton.ForeColor = [System.Drawing.Color]::LightSalmon

    # Event handlers
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

    # Add all controls to the form
    $form.Controls.Add($dnsGroupLabel)
    $form.Controls.Add($dnsDropdown)
    $form.Controls.Add($saveButton)

    # Show the form
    [void] $form.ShowDialog()
}

# Run the GUI initializer when script is executed
if ($MyInvocation.ScriptName -eq $scriptName) {
    Initialize-GUI
}
