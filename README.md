# SlimBrave
![slimbravelogosmall](https://github.com/user-attachments/assets/3e90a996-a74a-4ca1-bea6-0869275bab58)


## Brave Browser Debloater

SlimBrave is a powerful PowerShell script designed for Windows users to streamline their Brave Browser experience by toggling and configuring unwanted features. With SlimBrave, you can easily disable or enable various Brave functionalities, customize settings, and improve privacy.

## Features
1.**Disable/Enable Brave Rewards**
Toggle Brave's reward system on or off.

2.**Disable/Enable Brave Wallet**
Disable or enable Brave Wallet feature for managing cryptocurrencies.

3.**Disable/Enable Brave VPN**
Turn off or on the Brave VPN feature for enhanced privacy.

4.**Disable/Enable Brave AI Chat**
Toggle Brave's integrated AI Chat feature on or off.

5.**Set New Tab Page Location**
Configure a custom URL to be used as the new tab page in Brave.

6.**Disable/Enable Password Manager**
Enable or disable Brave's built-in password manager for website login credentials.

7.**Disable/Enable Tor**
Toggle the Tor functionality for anonymous browsing.

8.**Set DNS Over HTTPS Mode**
Set the DNS Over HTTPS mode (options include automatic or off) to ensure private browsing with secure DNS queries.

9.**Disable/Enable Brave Ads**
Manage the Brave Ads feature by enabling or disabling it.

10.**Disable/Enable Sync**
Toggle Brave's Sync functionality, which synchronizes your data across devices.

# How to Run
1.Open PowerShell with administrator privileges
2.Run this command:
### PowerShell
```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```
3. Run SlimBrave command in PowerShell:

## SlimBrave (No GUI)
```ps1
iwr "https://raw.githubusercontent.com/ltx0101/SlimBrave/main/SlimBrave.ps1" -OutFile "SlimBrave.ps1"; .\SlimBrave.ps1
```
## Slimbrave GUI (Experimental)
```ps1
iwr "https://raw.githubusercontent.com/ltx0101/SlimBrave/main/GUI.ps1" -OutFile "GUI.ps1"; .\GUI.ps1
```
## Requirements

- Windows 10/11
- PowerShell
- Administrator privileges are required
