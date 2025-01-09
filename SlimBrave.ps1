@echo off

:: Check for administrative privileges
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    echo Please run as an administrator.
    pause
    :: Re-run the script as administrator
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:menu
cls
echo Multi-Selection Menu for Brave Browser Registry Settings
echo ---------------------------------------------------------
echo 1. Disable/Enable Brave Rewards
echo 2. Disable/Enable Brave Wallet
echo 3. Disable/Enable Brave VPN
echo 4. Disable/Enable Brave AI Chat
echo 5. Set New Tab Page Location
echo 6. Disable/Enable Password Manager
echo 7. Disable/Enable Tor
echo 8. Set DNS Over HTTPS Mode
echo 9. Disable/Enable Brave Ads
echo 10. Disable/Enable Sync
echo ---------------------------------------------------------
echo 11. Exit
echo.
set /p choice=Enter the number of your choice (separate multiple by commas): 

:: Process each selected option
for %%i in (%choice%) do (
    if %%i==1 call :toggle "BraveRewardsDisabled"
    if %%i==2 call :toggle "BraveWalletDisabled"
    if %%i==3 call :toggle "BraveVPNDisabled"
    if %%i==4 call :toggle "BraveAIChatEnabled"
    if %%i==5 call :set_new_tab
    if %%i==6 call :toggle "PasswordManagerEnabled"
    if %%i==7 call :toggle "TorDisabled"
    if %%i==8 call :set_dns_mode
    if %%i==9 call :toggle "BraveAdsEnabled"
    if %%i==10 call :toggle "SyncDisabled"
    if %%i==11 goto :exit
)

goto :menu

:toggle
set regkey=HKLM\Software\Policies\BraveSoftware\Brave
reg query "%regkey%" /v %1 >nul
if %errorlevel%==0 (
    reg delete "%regkey%" /v %1 /f
    echo %1 has been enabled.
) else (
    reg add "%regkey%" /v %1 /t REG_DWORD /d 1 /f
    echo %1 has been disabled.
)
pause
goto :eof

:set_new_tab
set /p new_tab="Enter new tab page URL: "
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "NewTabPageLocation" /t REG_SZ /d "%new_tab%" /f
echo New Tab Page Location has been set.
pause
goto :eof

:set_dns_mode
set /p dns_mode="Enter DNS Over HTTPS mode (e.g., automatic, off): "
reg add "HKLM\Software\Policies\BraveSoftware\Brave" /v "DnsOverHttpsMode" /t REG_SZ /d "%dns_mode%" /f
echo DNS Over HTTPS Mode has been set.
pause
goto :eof

:exit
exit
