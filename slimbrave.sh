#!/bin/bash
scriptName="SlimBrave"
version="1.0"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges."
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

# Constants for menu options and actions
declare -A menuItems=(
    [1]="Toggle Brave Rewards"
    [2]="Toggle Brave Wallet"
    [3]="Toggle Brave VPN"
    [4]="Toggle Brave AI Chat"
    [5]="Toggle Password Manager"
    [6]="Toggle Tor"
    [7]="Toggle Brave Ads"
    [8]="Toggle Sync"
    [9]="Set DNS Over HTTPS Mode"
)

show_menu() {
    echo "========================="
    echo " SlimBrave v$version"
    echo "========================="
    
    printf "Menu:\n"
    for i in "${!menuItems[@]}"; do
        echo -e "\n${menuItems[$i]}: ${i}"
    done
    
    echo "10) Exit"
    echo "========================="
}

get_pref_value key file="prefs_file" {
    local result
    while read -r line; do
        if [[ $line == *"${key}*"]]; then
            result=$line
            break
        fi
    done || result=false
    echo "$result"
}

set_pref_value key value file="prefs_file" {
    local cmd
    declare -x newFile="$file.tmp"
    
    if ! jq --auto-conv -r ".${key} = ${value}" "$file" > "$newFile"; then
        echo "Failed to set preference."
        exit 1
    fi
    
    mv "$newFile" "$file"
}

toggle_setting key {
    local current_value=$(get_pref_value "$key")
    
    if [ -z "$current_value" ]; then
        echo "Current value not found. Using default."
        current_value="${defaultSettings[$key]}"
    fi
    
    if [ $(($current_value == "true")) -eq 1 ]; then
        set_pref_value "$key" "false"
        echo "Disabled $key"
    else
        set_pref_value "$key" "true"
        echo "Enabled $key"
    fi
}

set_dns_mode mode {
    local cmd="DnsOverHttpsMode=\"$mode\""
    
    if ! jq -r "$cmd" "$prefs_file" > "$prefs_file.tmp"; then
        echo "Failed to set DNS mode."
        exit 1
    fi
    
    mv "$prefs_file.tmp" "$prefs_file"
    echo "Set DNS Over HTTPS Mode to $mode"
}

main() {
    while true; do
        show_menu
        read -p "Enter your choice (1-10): " choice
        
        case $choice in
            10)
                echo "Exiting SlimBrave script."
                exit 0
                ;;
            $((10#${menuItems[$i]}))
                if ! $current_action=$(toggle_setting "$i"); then
                    continue
                fi
                ;;
            *) 
                echo "Invalid choice, please try again."
                ;;
        esac
    done
}

main
