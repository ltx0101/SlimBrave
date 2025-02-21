#!/bin/bash

scriptName="SlimBrave"
version="1.0"
author="SlimBrave"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges. Please run with sudo."
    exit 1
fi

brave_config_dir="$HOME/.config/BraveSoftware/Brave-Browser/User Data"
prefs_file="$brave_config_dir/Default/Preferences"

declare -A defaultSettings=(
    ["BraveRewardsDisabled"]=false
    ["BraveWalletDisabled"]=false
    ["BraveVPNDisabled"]=false
    ["BraveAIChatEnabled"]=true
    ["PasswordManagerEnabled"]=true
    ["TorDisabled"]=false
    ["DnsOverHttpsMode"]="automatic"
    ["BraveAdsEnabled"]=true
    ["SyncDisabled"]=false
)

get_pref_value() {
    local key=$1
    jq -r ".${key}" "$prefs_file"
}

set_pref_value() {
    local key=$1
    local value=$2
    jq ".${key} = ${value}" "$prefs_file" > "$prefs_file.tmp" && mv "$prefs_file.tmp" "$prefs_file"
}

toggle_setting() {
    local key=$1
    local current_value
    current_value=$(get_pref_value "$key")
    
    if [ "$current_value" == "true" ]; then
        set_pref_value "$key" "false"
        echo "Disabled $key"
    else
        set_pref_value "$key" "true"
        echo "Enabled $key"
    fi
}

set_dns_mode() {
    local dns_mode=$1
    jq ".DnsOverHttpsMode = \"$dns_mode\"" "$prefs_file" > "$prefs_file.tmp" && mv "$prefs_file.tmp" "$prefs_file"
    echo "Set DNS Over HTTPS Mode to $dns_mode"
}

show_menu() {
    echo "========================="
    echo " SlimBrave v$version"
    echo "========================="
    echo "Select an option:"
    echo "1) Toggle Brave Rewards"
    echo "2) Toggle Brave Wallet"
    echo "3) Toggle Brave VPN"
    echo "4) Toggle Brave AI Chat"
    echo "5) Toggle Password Manager"
    echo "6) Toggle Tor"
    echo "7) Toggle Brave Ads"
    echo "8) Toggle Sync"
    echo "9) Set DNS Over HTTPS Mode"
    echo "10) Exit"
    echo "========================="
}

while true; do
    show_menu
    read -p "Enter your choice (1-10): " choice

    case $choice in
        1)
            toggle_setting "BraveRewardsDisabled"
            ;;
        2)
            toggle_setting "BraveWalletDisabled"
            ;;
        3)
            toggle_setting "BraveVPNDisabled"
            ;;
        4)
            toggle_setting "BraveAIChatEnabled"
            ;;
        5)
            toggle_setting "PasswordManagerEnabled"
            ;;
        6)
            toggle_setting "TorDisabled"
            ;;
        7)
            toggle_setting "BraveAdsEnabled"
            ;;
        8)
            toggle_setting "SyncDisabled"
            ;;
        9)
            echo "Choose DNS Over HTTPS Mode (automatic, off, custom):"
            read dns_choice
            set_dns_mode "$dns_choice"
            ;;
        10)
            echo "Exiting SlimBrave script."
            exit 0
            ;;
        *)
            echo "Invalid choice, please try again."
            ;;
    esac
done
