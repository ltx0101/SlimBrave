#!/bin/bash

# Path to Brave's preferences file (expand home directory)
CONFIG_FILE="$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"

# Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Brave Preferences file not found."
    exit 1
fi

# Backup the original file
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup" || {
    echo "Error: Could not backup configuration file."
    exit 1
}

# Function to set a JSON value in the configuration file
set_config_value() {
    local key="$1"
    local value="$2"
    
    # Use jq to modify the JSON file
    jq --argjson v "$value" '
        if '"$key"' | type == "object" then
            '"$key"' += $v
        else
            '"$key"' = $v
        end
    ' "$CONFIG_FILE" > "${CONFIG_FILE}.new" || {
        echo "Error: Failed to update configuration."
        exit 1
    }
    
    # Replace the original file with the updated version
    mv "${CONFIG_FILE}.new" "$CONFIG_FILE"
}

# Set each configuration option (note: boolean values must not be quoted)
set_config_value '.extensions."brave-rewards".enabled' false
set_config_value '.extensions."brave-wallet".enabled' false
set_config_value '.extensions."brave-vpn".enabled' false
set_config_value '.features."brave-ai-chat".enabled' true
set_config_value '.password_manager.enabled' true
set_config_value '.extensions."tor-browser".enabled' false
set_config_value '.dns_over_https.mode' '"off"'
set_config_value '.features."brave-features".ads-enabled' true
set_config_value '.sync.enabled' false

echo "Configuration updated successfully. Restart Brave to apply changes."
