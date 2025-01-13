# SlimBrave
![slimbravelogosmall](https://github.com/user-attachments/assets/3e90a996-a74a-4ca1-bea6-0869275bab58)


## Brave Browser Debloater

SlimBrave is a powerful PowerShell script designed for Windows users to streamline their Brave Browser experience by toggling and configuring unwanted features. With SlimBrave, you can easily disable or enable various Brave functionalities, customize settings, and improve privacy.

## Features
1. **Disable Brave Rewards**
Disable Brave's reward system.

2. **Disable Brave Wallet**
Disable Brave's Wallet feature for managing cryptocurrencies.

3. **Disable Brave VPN**
Disable Brave's VPN feature for enhanced privacy.

4. **Disable Brave AI Chat**
Disable Brave's integrated AI Chat feature.

5. **Disable Password Manager**
Disable Brave's built-in password manager for website login credentials.

6. **Disable/Enable Tor**
Disable Tor functionality for anonymous browsing.

7. **Set DNS Over HTTPS Mode**
Set the DNS Over HTTPS mode (options include automatic or off) to ensure private browsing with secure DNS queries.

8. **Disable Brave Ads**
Disable Brave Ads feature by enabling or disabling it.

9. **Disable Sync**
Disable Brave's Sync functionality, which synchronizes your data across devices.

# How to Run
## 1.Open PowerShell with administrator privileges

## 2.Run this command:
```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```
## 3. Press A to accept

## 4. Run SlimBrave command in PowerShell:

### SlimBrave
```ps1
iwr "https://raw.githubusercontent.com/ltx0101/SlimBrave/main/SlimBrave.ps1" -OutFile "SlimBrave.ps1"; .\SlimBrave.ps1
```
# ⚠️ATTENTION⚠️
Running this script resets the values to their default. YOU then choose what to remove and what to keep.
## Requirements

- Windows 10/11
- PowerShell
- Administrator privileges are required
