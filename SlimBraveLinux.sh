#!/bin/bash

# Detect Brave's Preferences file
PREFS_PATH="$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"
if [ ! -f "$PREFS_PATH" ]; then
    PREFS_PATH="$HOME/snap/brave/current/.config/BraveSoftware/Brave-Browser/Default/Preferences"
fi

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Installing jq..."
    sudo apt update && sudo apt install -y jq
fi

# Prompt user for configuration choices
echo "Do you want to disable Brave Rewards? (y/n)"
read -r DISABLE_REWARDS
echo "Do you want to disable Brave Wallet? (y/n)"
read -r DISABLE_WALLET
echo "Do you want to disable Brave VPN? (y/n)"
read -r DISABLE_VPN
echo "Do you want to disable Tor Browser? (y/n)"
read -r DISABLE_TOR
echo "Do you want to disable Sync? (y/n)"
read -r DISABLE_SYNC
echo "Do you want to disable DNS over HTTPS? (y/n)"
read -r DISABLE_DOH
echo "Do you want to enable Brave AI Chat? (y/n)"
read -r ENABLE_AI_CHAT
echo "Do you want to enable Password Manager? (y/n)"
read -r ENABLE_PASSWORD_MANAGER

# Apply configuration changes
jq ".extensions.\"brave-rewards\".enabled = $( [ "$DISABLE_REWARDS" = "y" ] && echo "false" || echo "true" ) |
    .extensions.\"brave-wallet\".enabled = $( [ "$DISABLE_WALLET" = "y" ] && echo "false" || echo "true" ) |
    .extensions.\"brave-vpn\".enabled = $( [ "$DISABLE_VPN" = "y" ] && echo "false" || echo "true" ) |
    .features.\"brave-ai-chat\".enabled = $( [ "$ENABLE_AI_CHAT" = "y" ] && echo "true" || echo "false" ) |
    .password_manager.enabled = $( [ "$ENABLE_PASSWORD_MANAGER" = "y" ] && echo "true" || echo "false" ) |
    .extensions.\"tor-browser\".enabled = $( [ "$DISABLE_TOR" = "y" ] && echo "false" || echo "true" ) |
    .dns_over_https.mode = $( [ "$DISABLE_DOH" = "y" ] && echo "\"off\"" || echo "\"automatic\"" ) |
    .sync.enabled = $( [ "$DISABLE_SYNC" = "y" ] && echo "false" || echo "true" )" "$PREFS_PATH" > "$PREFS_PATH.tmp" && mv "$PREFS_PATH.tmp" "$PREFS_PATH"

# Set correct permissions
chmod 600 "$PREFS_PATH"
echo "Brave browser configuration updated successfully!"
