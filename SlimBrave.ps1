if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Host.UI.RawUI.ForegroundColor = "White"
$Host.UI.RawUI.BackgroundColor = "Black"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Stealth Chrome"
$form.Size = New-Object System.Drawing.Size(400, 750)
$form.ForeColor = [System.Drawing.Color]::White
$form.BackColor = [System.Drawing.Color]::FromArgb(255, 25, 25, 25)
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

$chromePoliciesPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"

#General Policies
$generalPolicies = @{
        "SyncDisabled" = 1
        "SigninAllowed" = 0
        "HardwareAccelerationModeEnabled" = 1
        "NetworkPredictionOptions" = 0
        "TabFreezingEnabled" = 0
        "MemorySaverModeSavings" = 0
        "ChromeCleanupEnabled" = 0
        "PasswordLeakDetectionEnabled" = 0
        "SafeBrowsingEnabled" = 0
        "NTPContentSuggestionsEnabled" = 0
        "SpellCheckServiceEnabled" = 0
        "TranslateEnabled" = 0
        "PasswordManagerEnabled" = 0
        "AutofillEnabled" = 0
        "AutofillCreditCardEnabled" = 0
        "DefaultGeolocationSetting" = 0
        "SensorsAllowedForUrls" = 0
        "AudioCaptureAllowed" = 0
        "VideoCaptureAllowed" = 0
        "ScreenCaptureAllowed" = 0
        "SearchSuggestEnabled" = 0
        "ContextualSearchEnabled" = 0
        "WebSQLAccess" = 0
        "ClearBrowsingDataOnExitList" = 1
        "DnsOverHttpsMode" = 1
        "HttpsOnlyMode" = 1
}

#Privacy Policies
$privacyPolicies = @{
        "MetricsReportingEnabled" = 0
        "UrlKeyedAnonymizedDataCollectionEnabled" = 0
        "CloudReportingEnabled" = 0
        "ReportDeviceNetworkEvents" = 0
        "BlockThirdPartyCookies" = 1
        "PerformanceTracingManagerEnabled" = 0
        "EnableDoNotTrack" = 1
        "DeviceActivityHeartbeatEnabled" = 0
        "DeviceExtensionsSystemLogEnabled" = 0
        "DeviceFlexHwDataForProductImprovementEnabled" = 0
        "DeviceMetricsReportingEnabled" = 0
        "DeviceReportNetworkEvents" = 0
        "DeviceReportRuntimeCounters" = 0
        "DeviceReportXDREvents" = 0
        "EnableDeviceGranularReporting" = 0
        "HeartbeatEnabled" = 0
        "HeartbeatFrequency" = 0
        "LogUploadEnabled" = 0
        "ReportAppInventory" = 0
        "ReportAppUsage" = 0
        "ReportArcStatusEnabled" = 0
        "ReportCRDSessions" = 0
        "ReportDeviceActivityTimes" = 0
        "ReportDeviceAppInfo" = 0
        "ReportDeviceAudioStatus" = 0
        "ReportDeviceBacklightInfo" = 0
        "ReportDeviceBluetoothInfo" = 0
        "ReportDeviceBoardStatus" = 0
        "ReportDeviceBootMode" = 0
        "ReportDeviceCpuInfo" = 0
        "ReportDeviceCrashReportInfo" = 0
        "ReportDeviceFanInfo" = 0
        "ReportDeviceGraphicsStatus" = 0
        "ReportDeviceHardwareStatus" = 0
        "ReportDeviceLoginLogout" = 0
        "ReportDeviceMemoryInfo" = 0
        "ReportDeviceNetworkConfiguration" = 0
        "ReportDeviceNetworkInterfaces" = 0
        "ReportDeviceNetworkStatus" = 0
        "ReportDeviceOsUpdateStatus" = 0
        "ReportDevicePeripherals" = 0
        "ReportDevicePowerStatus" = 0
        "ReportDevicePrintJobs" = 0
        "ReportDeviceSecurityStatus" = 0
        "ReportDeviceSessionStatus" = 0
        "ReportDeviceStorageStatus" = 0
        "ReportDeviceSystemInfo" = 0
        "ReportDeviceTimezoneInfo" = 0
        "ReportDeviceUsers" = 0
        "ReportDeviceVersionInfo" = 0
        "ReportDeviceVpdInfo" = 0
        "ReportUploadFrequency" = 0
        "ReportWebsiteActivityAllowlist" = 0
        "ReportWebsiteTelemetry" = 0
        "ReportWebsiteTelemetryAllowlist" = 0
        "SafeBrowsingExtendedReportingEnabled" = 0
        "SafeBrowsingSurveysEnabled" = 0
        "WebRtcEventLogCollectionAllowed" = 0
        "PrivacySandboxAdMeasurementEnabled" = 0
        "PrivacySandboxAdTopicsEnabled" = 0
        "PrivacySandboxPromptEnabled" = 0
        "PrivacySandboxSiteEnabledAdsEnabled" = 0
}

#Panel for General Policies with ScrollBar
$scrollPanel = New-Object System.Windows.Forms.Panel
$scrollPanel.Size = New-Object System.Drawing.Size(350, 480)
$scrollPanel.Location = New-Object System.Drawing.Point(35, 20)
$scrollPanel.AutoScroll = $true

#GroupBox for General Policies
$generalGroup = New-Object System.Windows.Forms.GroupBox
$generalGroup.Text = "General Policies"
$generalGroup.ForeColor = [System.Drawing.Color]::White
$generalGroup.Size = New-Object System.Drawing.Size(300, 820)
$generalGroup.Location = New-Object System.Drawing.Point(0, 0)
$generalGroup.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12, [System.Drawing.FontStyle]::Regular)

$generalCheckboxes = @()
$y = 30
foreach ($policy in $generalPolicies.Keys) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $policy
    $checkbox.Size = New-Object System.Drawing.Size(250, 30)
    $checkbox.Location = New-Object System.Drawing.Point(20, $y)
    $checkbox.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)
    $checkbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $generalGroup.Controls.Add($checkbox)
    $generalCheckboxes += $checkbox
    $y += 30
}

$scrollPanel.Controls.Add($generalGroup)

#GroupBox for Privacy Policies
$privacyGroup = New-Object System.Windows.Forms.GroupBox
$privacyGroup.Text = "Privacy Settings"
$privacyGroup.ForeColor = [System.Drawing.Color]::White
$privacyGroup.Size = New-Object System.Drawing.Size(350, 80)
$privacyGroup.Location = New-Object System.Drawing.Point(20, 550)
$privacyGroup.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 12, [System.Drawing.FontStyle]::Regular)

$privacyCheckboxes = @()
$privacyCheckbox = New-Object System.Windows.Forms.CheckBox
$privacyCheckbox.Text = "Enable All Privacy Settings"
$privacyCheckbox.Size = New-Object System.Drawing.Size(300, 30)
$privacyCheckbox.Location = New-Object System.Drawing.Point(20, 30)
$privacyCheckbox.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 10, [System.Drawing.FontStyle]::Regular)
$privacyCheckbox.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$privacyGroup.Controls.Add($privacyCheckbox)
$privacyCheckboxes += $privacyCheckbox

# Apply Button for Selected Policies
$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = "Apply Selected Policies"
$applyButton.Location = New-Object System.Drawing.Point(40, 650)
$applyButton.Size = New-Object System.Drawing.Size(140, 40)
$applyButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$applyButton.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$applyButton.FlatAppearance.BorderSize = 1
$applyButton.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 9, [System.Drawing.FontStyle]::Regular)
$applyButton.Add_Click({
    if (!(Test-Path $chromePoliciesPath)) { New-Item -Path $chromePoliciesPath -Force | Out-Null }
    
    $selectedGeneralPolicies = $generalCheckboxes | Where-Object { $_.Checked } | ForEach-Object { $_.Text }
    if ($selectedGeneralPolicies.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No general policies selected.", "Warning")
    } else {
        foreach ($policy in $selectedGeneralPolicies) {
            Set-ItemProperty -Path $chromePoliciesPath -Name $policy -Value $generalPolicies[$policy] -Force
        }
        [System.Windows.Forms.MessageBox]::Show("General policies applied successfully!", "Success")
    }

    if ($privacyCheckbox.Checked) {
        foreach ($policy in $privacyPolicies.Keys) {
            Set-ItemProperty -Path $chromePoliciesPath -Name $policy -Value $privacyPolicies[$policy] -Force
        }
        [System.Windows.Forms.MessageBox]::Show("Privacy policies applied successfully!", "Success")
    } else {
        [System.Windows.Forms.MessageBox]::Show("No privacy policies selected.", "Warning")
    }
})

# Reset Button
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = "Reset to Default"
$resetButton.Location = New-Object System.Drawing.Point(210, 650)
$resetButton.Size = New-Object System.Drawing.Size(140, 40)
$resetButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$resetButton.FlatAppearance.BorderColor = [System.Drawing.Color]::Black
$resetButton.FlatAppearance.BorderSize = 1
$resetButton.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 9, [System.Drawing.FontStyle]::Regular)
$resetButton.Add_Click({
    if (Test-Path $chromePoliciesPath) {
        Remove-Item -Path $chromePoliciesPath -Recurse -Force
        [System.Windows.Forms.MessageBox]::Show("Chrome policies reset to default!", "Success")
    } else {
        [System.Windows.Forms.MessageBox]::Show("No policies to reset.", "Info")
    }
})

$form.Controls.Add($scrollPanel)
$form.Controls.Add($privacyGroup)
$form.Controls.Add($applyButton)
$form.Controls.Add($resetButton)

$form.ShowDialog()
