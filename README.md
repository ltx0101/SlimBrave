# SlimBrave
![slimbravelogosmall](https://github.com/user-attachments/assets/3e90a996-a74a-4ca1-bea6-0869275bab58)


## Brave Browser Debloater

SlimBrave is a powerful PowerShell script designed for Windows users to streamline their Brave Browser experience by toggling and configuring unwanted features. With SlimBrave, you can easily disable or enable various Brave functionalities, customize settings, and improve privacy.

## Requirements
- Windows 10/11
- PowerShell
- Administrator privileges

## How to Run
> [!CAUTION]
> Running this script **resets** the values to their **default**. YOU then **choose** what to remove and what to keep.

#### 1. Open PowerShell with administrator privileges

#### 2. Run SlimBrave
```ps1
irm "https://raw.githubusercontent.com/ltx0101/SlimBrave/main/SlimBrave.ps1" | iex
```
> [!NOTE]
> The Invoke-RestMethod (IRM) command in PowerShell is used to download a script from a specified URL, while the Invoke-Expression (IEX) command executes the downloaded script.
## Features:
1. **Disable Brave Rewards**  
   Brave's rewards system that rewards tokens for viewing ads.

2. **Disable Brave Wallet**  
   Brave's Wallet feature for managing cryptocurrencies.

3. **Disable Brave VPN**  
   Brave's VPN service, which provides enhanced privacy.

4. **Disable Brave AI Chat**  
   Brave's AI-powered chat assistant integrated into the browser.

5. **Disable Password Manager**  
   Brave's built-in password manager for saving and autofilling login credentials.

6. **Disable Tor**  
   Brave's ability to browse using Tor for added anonymity.

7. **Set DNS Over HTTPS Mode**  
   Choose how DNS queries are handled for better security and privacy. Options: automatic/off.

8. **Disable Brave Ads**  
   Brave's private ad system for earning rewards.

9. **Disable Sync**  
   Disable syncing bookmarks, passwords, and settings across your devices using Brave Sync.
