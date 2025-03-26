<div align="center">

# SlimBrave
<img src="https://github.com/user-attachments/assets/3e90a996-a74a-4ca1-bea6-0869275bab58" width="200" height="300">
</div>

---

## Brave Browser Debloater

SlimBrave is a powerful PowerShell script designed for Windows users to streamline their Brave Browser experience by toggling and configuring unwanted features. With SlimBrave, you can easily disable or enable various Brave functionalities, customize settings, and improve privacy.

### Features:
- **Disable Brave Rewards**  
   Brave's reward system.

- **Disable Brave Wallet**  
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

- **Disable Sync**  
   Sync functionality that synchronizes your data across devices.

- **Telemetry & Reporting Controls**  
   Disable metrics reporting, safe browsing reporting, and data collection.

- **Privacy & Security Options**  
   Manage autofill, WebRTC, QUIC protocol, and more.

- **Performance Optimization**  
   Disable background processes and unnecessary features.

- **Reset All Settings**  
   One-click removal of all modified Brave policy settings (with confirmation).
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

<details>
<summary>Error "Running Scripts is Disabled on this System"</summary>

### Run this command in PowerShell:

```ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```
</details>
<div align="center">
  
---

🌟 **Like this project? Give it a star!** 🌟  
💻  **Want to contribute? PRs are welcome!** 💻 

</div>

### Why SlimBrave Matters

In an era of increasingly bloated browsers, SlimBrave puts **you** back in control:
- 🚀 **Faster browsing** by removing unnecessary features
- 🛡️ **Enhanced privacy** through granular controls
- ⚙️ **Transparent customization** without hidden settings

---

### Future Roadmap
- [ ] Add preset configurations (Privacy, Performance, etc.)
- [ ] Create backup/restore functionality
- [ ] Add support for Linux/Mac (WIP)

---

<div align="center">
  
Made with ❤️ and PowerShell  

</div>
