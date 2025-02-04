# SlimBrave
![slimbravelogosmall](https://github.com/user-attachments/assets/3e90a996-a74a-4ca1-bea6-0869275bab58)


## Brave Browser Debloater

SlimBrave is a powerful PowerShell script designed for Windows users to streamline their Brave Browser experience by toggling and configuring unwanted features. With SlimBrave, you can easily disable or enable various Brave functionalities, customize settings, and improve privacy.

### Features:
- **Disable Brave Rewards**  
   Brave's reward system.

-  **Disable Brave Wallet**  
   Brave's Wallet feature for managing cryptocurrencies.

- **Disable Brave VPN**  
   Brave's VPN feature for "enhanced" privacy.

- **Disable Brave AI Chat**  
   Brave's integrated AI Chat feature.

- **Disable Password Manager**  
   Brave's built-in password manager for website login credentials.

- **Disable Tor**  
   Tor functionality for "anonymous" browsing.

- **Set DNS Over HTTPS Mode**  
   Set the DNS Over HTTPS mode (options include automatic or off) to ensure private browsing with secure DNS queries.

- **Disable Brave Ads**  
   Brave Ads feature.

- **Disable Sync**  
   Sync functionality that which synchronizes your data across devices.



---

# How to Run


### Run the command below in PowerShell:

```ps1
iwr "https://raw.githubusercontent.com/ltx0101/SlimBrave/main/SlimBrave.ps1" -OutFile "SlimBrave.ps1"; .\SlimBrave.ps1
```

<details>
<summary> Requirements </summary>

- Windows 10/11
- PowerShell
- Administrator privileges
</details>

---
> [!IMPORTANT]
Running this script resets the values to their default. YOU then choose what to remove and what to keep.

<details>
<summary>Error "Running Scripts is Disabled on this System"</summary>

### Run this command in PowerShell:

```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```
</details>
