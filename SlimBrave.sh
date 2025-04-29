#!/bin/bash

save_settings_and_exit() {
    echo -e "\nSaving settings before exiting..."
    if [ -f "$BRAVE_POLICY_FILE" ]; then
        echo "Settings saved to $BRAVE_POLICY_FILE"
        echo "Restart Brave to see changes."
    fi
    exit 0
}

trap save_settings_and_exit SIGINT

invert_disabled_enabled_settings() {
    echo "Checking current configuration and inverting disabled/enabled settings..."
    
    if [ ! -f "$BRAVE_POLICY_FILE" ]; then
        echo "No existing configuration found."
        return
    fi
    
    local temp_file=$(mktemp)
    cp "$BRAVE_POLICY_FILE" "$temp_file"
    
    local keys=$(jq -r '.BraveSoftware.Brave | keys[]' "$BRAVE_POLICY_FILE" 2>/dev/null)
    
    for key in $keys; do
        if [[ "$key" == *"Disabled"* ]]; then
            local new_key="${key/Disabled/Enabled}"
            local current_value=$(jq -r ".BraveSoftware.Brave.$key" "$BRAVE_POLICY_FILE")
            
            local new_value="true"
            if [ "$current_value" = "true" ]; then
                new_value="false"
            fi
            
            echo "Inverting $key to $new_key (value: $current_value → $new_value)"
            
            jq "del(.BraveSoftware.Brave.$key)" "$temp_file" > "${temp_file}.new" && mv "${temp_file}.new" "$temp_file"
            jq ".BraveSoftware.Brave.$new_key = $new_value" "$temp_file" > "${temp_file}.new" && mv "${temp_file}.new" "$temp_file"
            
        elif [[ "$key" == *"Enabled"* ]]; then
            local new_key="${key/Enabled/Disabled}"
            local current_value=$(jq -r ".BraveSoftware.Brave.$key" "$BRAVE_POLICY_FILE")
            
            local new_value="true"
            if [ "$current_value" = "true" ]; then
                new_value="false"
            fi
            
            echo "Inverting $key to $new_key (value: $current_value → $new_value)"
            
            jq "del(.BraveSoftware.Brave.$key)" "$temp_file" > "${temp_file}.new" && mv "${temp_file}.new" "$temp_file"
            jq ".BraveSoftware.Brave.$new_key = $new_value" "$temp_file" > "${temp_file}.new" && mv "${temp_file}.new" "$temp_file"
        fi
    done
    
    mv "$temp_file" "$BRAVE_POLICY_FILE"
    echo "Configuration updated with inverted settings."
}

get_feature_status() {
    local key="$1"
    local default_state="$2" 

    if [[ "$key" == *"Enabled" ]]; then
        if jq -e ".BraveSoftware.Brave.$key == false" "$BRAVE_POLICY_FILE" > /dev/null 2>&1; then
            echo "disabled"
            return
        elif jq -e ".BraveSoftware.Brave.$key == true" "$BRAVE_POLICY_FILE" > /dev/null 2>&1; then
            echo "enabled"
            return
        fi
    elif [[ "$key" == *"Disabled" ]]; then
        if jq -e ".BraveSoftware.Brave.$key == true" "$BRAVE_POLICY_FILE" > /dev/null 2>&1; then
            echo "disabled"
            return
        elif jq -e ".BraveSoftware.Brave.$key == false" "$BRAVE_POLICY_FILE" > /dev/null 2>&1; then
            echo "enabled"
            return
        fi
    else
        local current_value=$(jq -r ".BraveSoftware.Brave.$key" "$BRAVE_POLICY_FILE" 2>/dev/null)
        if [ "$current_value" = "$default_state" ]; then
            echo "enabled"
            return
        elif [ "$current_value" != "null" ]; then
            echo "disabled"
            return
        fi
    fi
    
    if [ "$default_state" = "0" ]; then
        echo "enabled"
    else
        echo "disabled"
    fi
}

generate_dynamic_menus() {
    MENUS["main"]="SlimBrave
1. Configure Settings
2. Load Preset
3. Import Settings
4. Export Settings
5. Apply Settings
6. Reset All Settings
7. Exit"
    
    MENUS["categories"]="===== Configure Individual Settings =====

Choose a category:
1. Telemetry & Reporting
2. Privacy & Security
3. Brave Features
4. Performance & Bloat
5. DNS Settings
6. Return to main menu"

    local metrics_status=$(get_feature_status "MetricsReportingEnabled" "0")
    local safe_browse_status=$(get_feature_status "SafeBrowsingExtendedReportingEnabled" "0")
    local url_data_status=$(get_feature_status "UrlKeyedAnonymizedDataCollectionEnabled" "0")
    local feedback_status=$(get_feature_status "FeedbackSurveysEnabled" "0")
    
    MENUS["telemetry"]="===== Configure Telemetry & Reporting =====

1. $([ "$metrics_status" = "disabled" ] && echo "Enable" || echo "Disable") Metrics Reporting
2. $([ "$safe_browse_status" = "disabled" ] && echo "Enable" || echo "Disable") Safe Browsing Reporting
3. $([ "$url_data_status" = "disabled" ] && echo "Enable" || echo "Disable") URL Data Collection
4. $([ "$feedback_status" = "disabled" ] && echo "Enable" || echo "Disable") Feedback Surveys
5. Return to categories"

    local safe_browsing_status=$(get_feature_status "SafeBrowsingProtectionLevel" "0")
    local autofill_addr_status=$(get_feature_status "AutofillAddressEnabled" "0")
    local autofill_card_status=$(get_feature_status "AutofillCreditCardEnabled" "0")
    local pass_manager_status=$(get_feature_status "PasswordManagerEnabled" "0")
    local browser_signin_status=$(get_feature_status "BrowserSignin" "0")
    local webrtc_status=$(get_feature_status "WebRtcIPHandling" "disable_non_proxied_udp")
    local quic_status=$(get_feature_status "QuicAllowed" "0")
    local third_party_cookies_status=$(get_feature_status "BlockThirdPartyCookies" "1")
    local dnt_status=$(get_feature_status "EnableDoNotTrack" "1")
    local safe_search_status=$(get_feature_status "ForceGoogleSafeSearch" "1")
    local ipfs_status=$(get_feature_status "IPFSEnabled" "0")
    local incognito_status=$(get_feature_status "IncognitoModeAvailability" "1")
    
    MENUS["privacy"]="===== Configure Privacy & Security =====

1. $([ "$safe_browsing_status" = "disabled" ] && echo "Enable" || echo "Disable") Safe Browsing
2. $([ "$autofill_addr_status" = "disabled" ] && echo "Enable" || echo "Disable") Autofill (Addresses)
3. $([ "$autofill_card_status" = "disabled" ] && echo "Enable" || echo "Disable") Autofill (Credit Cards)
4. $([ "$pass_manager_status" = "disabled" ] && echo "Enable" || echo "Disable") Password Manager
5. $([ "$browser_signin_status" = "disabled" ] && echo "Enable" || echo "Disable") Browser Sign-in
6. $([ "$webrtc_status" = "disabled" ] && echo "Enable" || echo "Disable") WebRTC IP Leak Protection
7. $([ "$quic_status" = "disabled" ] && echo "Enable" || echo "Disable") QUIC Protocol
8. $([ "$third_party_cookies_status" = "disabled" ] && echo "Block" || echo "Allow") Third Party Cookies
9. $([ "$dnt_status" = "disabled" ] && echo "Disable" || echo "Enable") Do Not Track
10. $([ "$safe_search_status" = "disabled" ] && echo "Disable" || echo "Force") Google SafeSearch
11. $([ "$ipfs_status" = "disabled" ] && echo "Enable" || echo "Disable") IPFS
12. $([ "$incognito_status" = "disabled" ] && echo "Enable" || echo "Disable") Incognito Mode
13. Return to categories"

    local rewards_status=$(get_feature_status "BraveRewardsDisabled" "1")
    local wallet_status=$(get_feature_status "BraveWalletDisabled" "1")
    local vpn_status=$(get_feature_status "BraveVPNDisabled" "1")
    local ai_chat_status=$(get_feature_status "BraveAIChatEnabled" "0")
    local shields_status=$(get_feature_status "BraveShieldsDisabledForUrls" "[\"https://*\", \"http://*\"]")
    local tor_status=$(get_feature_status "TorDisabled" "1")
    local sync_status=$(get_feature_status "SyncDisabled" "1")
    
    MENUS["features"]="===== Configure Brave Features =====

1. $([ "$rewards_status" = "disabled" ] && echo "Enable" || echo "Disable") Brave Rewards
2. $([ "$wallet_status" = "disabled" ] && echo "Enable" || echo "Disable") Brave Wallet
3. $([ "$vpn_status" = "disabled" ] && echo "Enable" || echo "Disable") Brave VPN
4. $([ "$ai_chat_status" = "disabled" ] && echo "Enable" || echo "Disable") Brave AI Chat
5. $([ "$shields_status" = "disabled" ] && echo "Enable" || echo "Disable") Brave Shields
6. $([ "$tor_status" = "disabled" ] && echo "Enable" || echo "Disable") Tor
7. $([ "$sync_status" = "disabled" ] && echo "Enable" || echo "Disable") Sync
8. Return to categories"

    local background_status=$(get_feature_status "BackgroundModeEnabled" "0")
    local media_rec_status=$(get_feature_status "MediaRecommendationsEnabled" "0")
    local shopping_status=$(get_feature_status "ShoppingListEnabled" "0")
    local pdf_status=$(get_feature_status "AlwaysOpenPdfExternally" "1")
    local translate_status=$(get_feature_status "TranslateEnabled" "0")
    local spellcheck_status=$(get_feature_status "SpellcheckEnabled" "0")
    local promotions_status=$(get_feature_status "PromotionsEnabled" "0")
    local search_suggest_status=$(get_feature_status "SearchSuggestEnabled" "0")
    local printing_status=$(get_feature_status "PrintingEnabled" "0")
    local default_browser_status=$(get_feature_status "DefaultBrowserSettingEnabled" "0")
    local dev_tools_status=$(get_feature_status "DeveloperToolsDisabled" "1")
    
    MENUS["performance"]="===== Configure Performance & Bloat =====

1. $([ "$background_status" = "disabled" ] && echo "Enable" || echo "Disable") Background Mode
2. $([ "$media_rec_status" = "disabled" ] && echo "Enable" || echo "Disable") Media Recommendations
3. $([ "$shopping_status" = "disabled" ] && echo "Enable" || echo "Disable") Shopping List
4. $([ "$pdf_status" = "disabled" ] && echo "Never" || echo "Always") Open PDF Externally
5. $([ "$translate_status" = "disabled" ] && echo "Enable" || echo "Disable") Translate
6. $([ "$spellcheck_status" = "disabled" ] && echo "Enable" || echo "Disable") Spellcheck
7. $([ "$promotions_status" = "disabled" ] && echo "Enable" || echo "Disable") Promotions
8. $([ "$search_suggest_status" = "disabled" ] && echo "Enable" || echo "Disable") Search Suggestions
9. $([ "$printing_status" = "disabled" ] && echo "Enable" || echo "Disable") Printing
10. $([ "$default_browser_status" = "disabled" ] && echo "Enable" || echo "Disable") Default Browser Prompt
11. $([ "$dev_tools_status" = "disabled" ] && echo "Enable" || echo "Disable") Developer Tools
12. Return to categories"

    MENUS["dns"]="===== Configure DNS Settings =====

1. Automatic
2. Off
3. Custom
4. On
5. Return to categories"
}

if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Please install it first (apt-get install jq)."
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exec sudo "$0" "$@"
  exit
fi

BRAVE_BINARY=""
BRAVE_FOUND=false

BRAVE_LOCATIONS=(
    "/usr/bin/brave-browser"
    "/usr/bin/brave"
    "/opt/brave.com/brave/brave"
    "/opt/brave-browser/brave-browser"
    "/snap/bin/brave"
    "/usr/local/bin/brave"
    "/opt/brave-bin/brave"
    "/usr/lib/brave-bin/brave"
    "$(which brave-browser 2>/dev/null)"
    "$(which brave 2>/dev/null)"
    "/var/lib/flatpak/app/com.brave.Browser/current/active/files/brave/brave"
    "$(flatpak info com.brave.Browser --show-location 2>/dev/null)/files/brave/brave"
)

for location in "${BRAVE_LOCATIONS[@]}"; do
    if [ -f "$location" ]; then
        BRAVE_BINARY="$location"
        BRAVE_FOUND=true
        echo "Brave browser found at: $BRAVE_BINARY"
        break
    fi
done

if [ "$BRAVE_FOUND" = false ]; then
    echo "Warning: Could not find Brave browser installation. Policy changes may not take effect."
    echo "Make sure Brave browser is installed before using this script."
    read -p "Continue anyway? (y/n): " continue_prompt
    if [ "$continue_prompt" != "y" ] && [ "$continue_prompt" != "Y" ]; then
        echo "Exiting..."
        exit 1
    fi
fi

POSSIBLE_CONFIG_DIRS=(
    "/etc/brave"
    "/etc/brave-browser"
    "/etc/chromium/policies/managed"
    "/etc/opt/chrome/policies/managed"
    "/etc/opt/brave/policies/managed"
    "/usr/share/brave/policies/managed"
    "/var/lib/flatpak/app/com.brave.Browser/current/active/policies/managed"
)

BRAVE_CONFIG_DIR=""
for dir in "${POSSIBLE_CONFIG_DIRS[@]}"; do
    if [ -d "$dir" ] || mkdir -p "$dir" 2>/dev/null; then
        BRAVE_CONFIG_DIR="$dir"
        break
    fi
done

if [ -z "$BRAVE_CONFIG_DIR" ]; then
    BRAVE_CONFIG_DIR="/etc/brave"
    mkdir -p "$BRAVE_CONFIG_DIR/policies/managed"
fi

BRAVE_POLICY_FILE="$BRAVE_CONFIG_DIR/policies/managed/policies.json"

USER_CONFIG_DIRS=(
    "$HOME/.config/BraveSoftware/Brave-Browser"
    "$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser"
    "$HOME/.local/share/flatpak/app/com.brave.Browser/current/active/config/BraveSoftware/Brave-Browser"
    "/var/lib/flatpak/app/com.brave.Browser/current/active/config/BraveSoftware/Brave-Browser"
    "$XDG_CONFIG_HOME/BraveSoftware/Brave-Browser"
)

declare -a BRAVE_PROFILES=()

USER_LOCAL_STATE=""
USER_PREFERENCES=""
USER_SECURE_PREFERENCES=""

for dir in "${USER_CONFIG_DIRS[@]}"; do
    if [ -f "$dir/Local State" ]; then
        USER_LOCAL_STATE="$dir/Local State"
        echo "Found Local State at: $USER_LOCAL_STATE"
        
        if [ -d "$dir" ]; then
            for profile_dir in "$dir"/*; do
                if [ -d "$profile_dir" ] && [ -f "$profile_dir/Preferences" ]; then
                    profile_name=$(basename "$profile_dir")
                    if [ "$profile_name" != "GrShaderCache" ] && [ "$profile_name" != "CertificateRevocation" ] && \
                       [ "$profile_name" != "SafetyTips" ] && [ "$profile_name" != "Safe Browsing" ] && \
                       [ "$profile_name" != "Service Worker" ] && [ "$profile_name" != "Local Extension Settings" ] && \
                       [ "$profile_name" != "Extensions" ] && [ "$profile_name" != "BrowserMetrics" ] && \
                       [ "$profile_name" != "BrowserMetrics-spare.pma" ]; then
                        BRAVE_PROFILES+=("$profile_name:$profile_dir/Preferences")
                        echo "Found profile: $profile_name at $profile_dir/Preferences"
                        
                        if [ "$profile_name" = "Default" ] && [ -z "$USER_PREFERENCES" ]; then
                            USER_PREFERENCES="$profile_dir/Preferences"
                            
                            if [ -f "$profile_dir/Secure Preferences" ]; then
                                USER_SECURE_PREFERENCES="$profile_dir/Secure Preferences"
                            fi
                        fi
                    fi
                fi
            done
        fi
        
        break
    fi
done

if [ ${#BRAVE_PROFILES[@]} -eq 0 ]; then
    for dir in "${USER_CONFIG_DIRS[@]}"; do
        if [ -f "$dir/Default/Preferences" ]; then
            USER_PREFERENCES="$dir/Default/Preferences"
            BRAVE_PROFILES+=("Default:$dir/Default/Preferences")
            echo "Found Default profile at $dir/Default/Preferences"
            
            if [ -f "$dir/Default/Secure Preferences" ]; then
                USER_SECURE_PREFERENCES="$dir/Default/Secure Preferences"
            fi
            
            if [ -f "$dir/Local State" ] && [ -z "$USER_LOCAL_STATE" ]; then
                USER_LOCAL_STATE="$dir/Local State"
            fi
            
            break
        fi
    done
fi

PRESET_DIR="$(dirname "$(realpath "$0")")/Presets"

mkdir -p "$(dirname "$BRAVE_POLICY_FILE")"

if [ -f "$BRAVE_POLICY_FILE" ]; then
    CURRENT_POLICIES=$(cat "$BRAVE_POLICY_FILE")
    if [ -z "$CURRENT_POLICIES" ] || ! echo "$CURRENT_POLICIES" | jq . > /dev/null 2>&1; then
        echo '{"BraveSoftware":{"Brave":{}}}' > "$BRAVE_POLICY_FILE"
    fi
else
    echo '{"BraveSoftware":{"Brave":{}}}' > "$BRAVE_POLICY_FILE"
fi

set_policy() {
    local key="$1"
    local value="$2"
    local type="$3"
    
    if [ ! -f "$BRAVE_POLICY_FILE" ]; then
        echo '{"BraveSoftware":{"Brave":{}}}' > "$BRAVE_POLICY_FILE"
    fi
    
    if [ "$type" = "Boolean" ]; then
        if [ "$value" = "1" ]; then
            value="true"
        else
            value="false"
        fi
        jq ".BraveSoftware.Brave.$key = $value" "$BRAVE_POLICY_FILE" > tmp.json && mv tmp.json "$BRAVE_POLICY_FILE"
    elif [ "$type" = "Integer" ]; then
        jq ".BraveSoftware.Brave.$key = $value" "$BRAVE_POLICY_FILE" > tmp.json && mv tmp.json "$BRAVE_POLICY_FILE"
    else
        jq ".BraveSoftware.Brave.$key = \"$value\"" "$BRAVE_POLICY_FILE" > tmp.json && mv tmp.json "$BRAVE_POLICY_FILE"
    fi
    
    echo "Set $key to $value"

    if [ -n "$USER_PREFERENCES" ] && [ -f "$USER_PREFERENCES" ]; then
        case "$key" in
            "MetricsReportingEnabled")
                echo "Updating user preferences for $key..."
                if [ "$value" = "true" ] || [ "$value" = "1" ]; then
                    set_user_pref "$USER_PREFERENCES" "reporting.enabled" "false"
                    set_user_pref "$USER_PREFERENCES" "brave.stats.reporting_enabled" "false"
                else
                    set_user_pref "$USER_PREFERENCES" "reporting.enabled" "false"
                    set_user_pref "$USER_PREFERENCES" "brave.stats.reporting_enabled" "false"
                fi
                ;;
                
            "SafeBrowsingProtectionLevel")
                echo "Updating user preferences for Safe Browsing..."
                if [ "$value" = "0" ]; then
                    set_user_pref "$USER_PREFERENCES" "safebrowsing.enabled" "false"
                    set_user_pref "$USER_PREFERENCES" "brave.safebrowsing.enabled" "false"
                fi
                ;;
                
            "BraveAIChatEnabled")
                echo "Updating user preferences for Brave AI Chat..."
                if [ "$value" = "false" ] || [ "$value" = "0" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.leo.use_leo" "false"
                    set_user_pref "$USER_PREFERENCES" "brave.ai_chat.enabled" "false"
                fi
                ;;
                
            "DefaultBrowserSettingEnabled")
                echo "Updating user preferences for Default Browser Check..."
                if [ "$value" = "false" ] || [ "$value" = "0" ]; then
                    set_user_pref "$USER_PREFERENCES" "browser.default_browser_check.enabled" "false"
                    set_user_pref "$USER_PREFERENCES" "default_browser.notified" "true"
                fi
                ;;
                
            "BraveRewardsDisabled")
                if [ "$value" = "true" ] || [ "$value" = "1" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.rewards.enabled" "false"
                fi
                ;;
                
            "BraveWalletDisabled")
                if [ "$value" = "true" ] || [ "$value" = "1" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.wallet.enabled" "false"
                    set_user_pref "$USER_PREFERENCES" "brave.wallet.metamask_enabled" "false"
                    set_user_pref "$USER_PREFERENCES" "brave.wallet.solana_enabled" "false"
                fi
                ;;
                
            "BraveVPNDisabled")
                if [ "$value" = "true" ] || [ "$value" = "1" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.vpn.product_enabled" "false"
                fi
                ;;
                
            "TorDisabled")
                if [ "$value" = "true" ] || [ "$value" = "1" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.tor.enabled" "false"
                fi
                ;;
                
            "IPFSEnabled")
                if [ "$value" = "false" ] || [ "$value" = "0" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.ipfs.enabled" "false"
                fi
                ;;
                
            "SyncDisabled")
                if [ "$value" = "true" ] || [ "$value" = "1" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.sync.enabled" "false"
                fi
                ;;
                
            "NewTabPageEnabled")
                if [ "$value" = "false" ] || [ "$value" = "0" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.new_tab_page.enabled" "false"
                fi
                ;;
                
            "SpeedreaderEnabled")
                if [ "$value" = "false" ] || [ "$value" = "0" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.speedreader.enabled" "false"
                fi
                ;;
                
            "PlaylistEnabled")
                if [ "$value" = "false" ] || [ "$value" = "0" ]; then
                    set_user_pref "$USER_PREFERENCES" "brave.playlist.enabled" "false"
                fi
                ;;
        esac
    fi
    
    if [ -n "$USER_LOCAL_STATE" ] && [ -f "$USER_LOCAL_STATE" ]; then
        case "$key" in
            "BraveRewardsDisabled"|"BraveWalletDisabled"|"BraveVPNDisabled"|"TorDisabled")
                echo "Updating Local State for $key..."
                cp "$USER_LOCAL_STATE" "${USER_LOCAL_STATE}.bak"
                ;;
        esac
    fi
}

set_user_pref() {
    local pref_file="$1"
    local pref_key="$2"
    local pref_value="$3"
    
    if [ ! -f "$pref_file" ]; then
        echo "Error: Preference file not found at $pref_file"
        return 1
    fi
    
    if [ ! -f "${pref_file}.bak" ]; then
        cp "$pref_file" "${pref_file}.bak"
        echo "Created backup of $(basename "$pref_file") file at ${pref_file}.bak"
    fi
    
    if [ "$pref_value" = "true" ] || [ "$pref_value" = "false" ]; then
        jq ".$pref_key = $pref_value" "$pref_file" > "${pref_file}.tmp" 2>/dev/null
    elif [[ "$pref_value" =~ ^[0-9]+$ ]]; then
        jq ".$pref_key = $pref_value" "$pref_file" > "${pref_file}.tmp" 2>/dev/null
    else
        jq ".$pref_key = \"$pref_value\"" "$pref_file" > "${pref_file}.tmp" 2>/dev/null
    fi
    
    if [ $? -eq 0 ]; then
        mv "${pref_file}.tmp" "$pref_file"
        echo "Updated $pref_key to $pref_value in $(basename "$pref_file")"
    else
        echo "Failed to update $pref_key in $(basename "$pref_file") - preserving original"
        rm -f "${pref_file}.tmp"
    fi
}

modify_user_config() {
    if [ ${#BRAVE_PROFILES[@]} -eq 0 ]; then
        echo "No user profiles found to modify."
        return
    fi
    
    echo "Found ${#BRAVE_PROFILES[@]} user profiles to process."
    
    if [ -n "$USER_LOCAL_STATE" ] && [ -f "$USER_LOCAL_STATE" ]; then
        echo "Processing Local State at: $USER_LOCAL_STATE"
        
        if [ ! -f "${USER_LOCAL_STATE}.bak" ]; then
            cp "$USER_LOCAL_STATE" "${USER_LOCAL_STATE}.bak"
            echo "Created backup of Local State file at ${USER_LOCAL_STATE}.bak"
        fi

        local brave_policy=$(jq -r '.BraveSoftware.Brave' "$BRAVE_POLICY_FILE" 2>/dev/null)
        if [ -n "$brave_policy" ] && [ "$brave_policy" != "null" ]; then
            if jq -e '.BraveSoftware.Brave.BraveRewardsDisabled == true' "$BRAVE_POLICY_FILE" >/dev/null 2>&1; then
                set_user_pref "$USER_LOCAL_STATE" "brave.rewards.enabled" "false"
            fi
            
            if jq -e '.BraveSoftware.Brave.SyncDisabled == true' "$BRAVE_POLICY_FILE" >/dev/null 2>&1; then
                set_user_pref "$USER_LOCAL_STATE" "brave_sync.enabled" "false"
            fi
        fi
        
        if [[ "$USER_LOCAL_STATE" == *".var/app/"* ]] || [[ "$USER_LOCAL_STATE" == *"flatpak"* ]]; then
            if [ -n "$SUDO_USER" ]; then
                chown -R $SUDO_USER:$SUDO_USER "$(dirname "$USER_LOCAL_STATE")"
                echo "Fixed permissions for containerized Brave installation"
            fi
        fi
    fi
    
    for profile_entry in "${BRAVE_PROFILES[@]}"; do
        IFS=':' read -r profile_name profile_path <<< "$profile_entry"
        
        if [ -f "$profile_path" ]; then
            echo "Processing profile $profile_name at $profile_path"
            
            if [ ! -f "${profile_path}.bak" ]; then
                cp "$profile_path" "${profile_path}.bak"
                echo "Created backup of $profile_name Preferences file at ${profile_path}.bak"
            fi
            
            local secure_prefs="${profile_path%/*}/Secure Preferences"
            if [ -f "$secure_prefs" ]; then
                if [ ! -f "${secure_prefs}.bak" ]; then
                    cp "$secure_prefs" "${secure_prefs}.bak"
                    echo "Created backup of Secure Preferences at ${secure_prefs}.bak"
                fi
            fi
            
            local brave_policy=$(jq -r '.BraveSoftware.Brave' "$BRAVE_POLICY_FILE" 2>/dev/null)
            if [ -n "$brave_policy" ] && [ "$brave_policy" != "null" ]; then
                if jq -e '.BraveSoftware.Brave.BraveRewardsDisabled == true' "$BRAVE_POLICY_FILE" >/dev/null 2>&1; then
                    set_user_pref "$profile_path" "brave.rewards.enabled" "false"
                fi
                
                if jq -e '.BraveSoftware.Brave.MetricsReportingEnabled == false' "$BRAVE_POLICY_FILE" >/dev/null 2>&1; then
                    set_user_pref "$profile_path" "reporting.enabled" "false"
                    set_user_pref "$profile_path" "brave.stats.reporting_enabled" "false"
                fi
                
                if jq -e '.BraveSoftware.Brave.SafeBrowsingProtectionLevel == 0' "$BRAVE_POLICY_FILE" >/dev/null 2>&1; then
                    set_user_pref "$profile_path" "safebrowsing.enabled" "false"
                    set_user_pref "$profile_path" "brave.safebrowsing.enabled" "false"
                fi
            fi
            
            if [[ "$profile_path" == *".var/app/"* ]] || [[ "$profile_path" == *"flatpak"* ]]; then
                if [ -n "$SUDO_USER" ]; then
                    chown -R $SUDO_USER:$SUDO_USER "$(dirname "$profile_path")"
                fi
            fi
        fi
    done
    
    echo "User configuration modifications completed."
}

set_dns_mode() {
    local mode="$1"
    set_policy "DnsOverHttpsMode" "$mode" "String"
    echo "DNS over HTTPS mode set to $mode"
}

apply_preset() {
    local preset_file="$1"
    
    if [ ! -f "$preset_file" ]; then
        echo "Preset file not found: $preset_file"
        return 1
    fi
    
    features=$(jq -r '.Features[]' "$preset_file" 2>/dev/null)
    dns_mode=$(jq -r '.DnsMode' "$preset_file" 2>/dev/null)
    
    if [ -z "$features" ]; then
        echo "No features found in preset file"
        return 1
    fi
    
    echo '{"BraveSoftware":{"Brave":{}}}' > "$BRAVE_POLICY_FILE"
    
    for feature in $features; do
        case "$feature" in
            "MetricsReportingEnabled")
                set_policy "MetricsReportingEnabled" "0" "Boolean"
                ;;
            "SafeBrowsingExtendedReportingEnabled")
                set_policy "SafeBrowsingExtendedReportingEnabled" "0" "Boolean"
                ;;
            "UrlKeyedAnonymizedDataCollectionEnabled")
                set_policy "UrlKeyedAnonymizedDataCollectionEnabled" "0" "Boolean"
                ;;
            "FeedbackSurveysEnabled")
                set_policy "FeedbackSurveysEnabled" "0" "Boolean"
                ;;
                
            "SafeBrowsingProtectionLevel")
                set_policy "SafeBrowsingProtectionLevel" "0" "Integer"
                ;;
            "AutofillAddressEnabled")
                set_policy "AutofillAddressEnabled" "0" "Boolean"
                ;;
            "AutofillCreditCardEnabled")
                set_policy "AutofillCreditCardEnabled" "0" "Boolean"
                ;;
            "PasswordManagerEnabled")
                set_policy "PasswordManagerEnabled" "0" "Boolean"
                ;;
            "BrowserSignin")
                set_policy "BrowserSignin" "0" "Integer"
                ;;
            "WebRtcIPHandling")
                set_policy "WebRtcIPHandling" "disable_non_proxied_udp" "String"
                ;;
            "QuicAllowed")
                set_policy "QuicAllowed" "0" "Boolean"
                ;;
            "BlockThirdPartyCookies")
                set_policy "BlockThirdPartyCookies" "1" "Boolean"
                ;;
            "EnableDoNotTrack")
                set_policy "EnableDoNotTrack" "1" "Boolean"
                ;;
            "ForceGoogleSafeSearch")
                set_policy "ForceGoogleSafeSearch" "1" "Boolean"
                ;;
            "IPFSEnabled")
                set_policy "IPFSEnabled" "0" "Boolean"
                ;;
            "IncognitoModeAvailability")
                set_policy "IncognitoModeAvailability" "1" "Integer"
                ;;
                
            "BraveRewardsDisabled")
                set_policy "BraveRewardsDisabled" "1" "Boolean"
                ;;
            "BraveWalletDisabled")
                set_policy "BraveWalletDisabled" "1" "Boolean"
                ;;
            "BraveVPNDisabled")
                set_policy "BraveVPNDisabled" "1" "Boolean"
                ;;
            "BraveAIChatEnabled")
                set_policy "BraveAIChatEnabled" "0" "Boolean"
                ;;
            "BraveShieldsDisabledForUrls")
                set_policy "BraveShieldsDisabledForUrls" '[\"https://*\", \"http://*\"]' "String"
                ;;
            "TorDisabled")
                set_policy "TorDisabled" "1" "Boolean"
                ;;
            "SyncDisabled")
                set_policy "SyncDisabled" "1" "Boolean"
                ;;
                
            "BackgroundModeEnabled")
                set_policy "BackgroundModeEnabled" "0" "Boolean"
                ;;
            "MediaRecommendationsEnabled")
                set_policy "MediaRecommendationsEnabled" "0" "Boolean"
                ;;
            "ShoppingListEnabled")
                set_policy "ShoppingListEnabled" "0" "Boolean"
                ;;
            "AlwaysOpenPdfExternally")
                set_policy "AlwaysOpenPdfExternally" "1" "Boolean"
                ;;
            "TranslateEnabled")
                set_policy "TranslateEnabled" "0" "Boolean"
                ;;
            "SpellcheckEnabled")
                set_policy "SpellcheckEnabled" "0" "Boolean"
                ;;
            "PromotionsEnabled")
                set_policy "PromotionsEnabled" "0" "Boolean"
                ;;
            "SearchSuggestEnabled")
                set_policy "SearchSuggestEnabled" "0" "Boolean"
                ;;
            "PrintingEnabled")
                set_policy "PrintingEnabled" "0" "Boolean"
                ;;
            "DefaultBrowserSettingEnabled")
                set_policy "DefaultBrowserSettingEnabled" "0" "Boolean"
                ;;
            "DeveloperToolsDisabled")
                set_policy "DeveloperToolsDisabled" "1" "Boolean"
                ;;
        esac
    done
    
    if [ "$dns_mode" != "null" ]; then
        set_dns_mode "$dns_mode"
    fi

    modify_user_config
    
    echo "Preset applied successfully!"
}

export_settings() {
    local export_file="$1"
    
    if [ -z "$export_file" ]; then
        echo "Please provide a file path for export"
        return 1
    fi
    
    mkdir -p "$(dirname "$export_file")" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to create directory for export file: $(dirname "$export_file")"
        return 1
    fi
    
    echo '{"Features":[],"DnsMode":"automatic"}' > "$export_file"
    if [ $? -ne 0 ]; then
        echo "Failed to create export file: $export_file"
        return 1
    fi
    
    for feature in \
        MetricsReportingEnabled SafeBrowsingExtendedReportingEnabled UrlKeyedAnonymizedDataCollectionEnabled FeedbackSurveysEnabled \
        SafeBrowsingProtectionLevel AutofillAddressEnabled AutofillCreditCardEnabled PasswordManagerEnabled BrowserSignin \
        WebRtcIPHandling QuicAllowed BlockThirdPartyCookies EnableDoNotTrack ForceGoogleSafeSearch IPFSEnabled IncognitoModeAvailability \
        BraveRewardsDisabled BraveWalletDisabled BraveVPNDisabled BraveAIChatEnabled BraveShieldsDisabledForUrls TorDisabled SyncDisabled \
        BackgroundModeEnabled MediaRecommendationsEnabled ShoppingListEnabled AlwaysOpenPdfExternally TranslateEnabled SpellcheckEnabled \
        PromotionsEnabled SearchSuggestEnabled PrintingEnabled DefaultBrowserSettingEnabled DeveloperToolsDisabled; do
        
        if jq -e ".BraveSoftware.Brave.$feature != null" "$BRAVE_POLICY_FILE" > /dev/null 2>&1; then
            jq ".Features += [\"$feature\"]" "$export_file" > tmp.json && mv tmp.json "$export_file"
            if [ $? -ne 0 ]; then
                echo "Warning: Failed to add feature $feature to export file"
            fi
        fi
    done
    
    if jq -e '.BraveSoftware.Brave.DnsOverHttpsMode != null' "$BRAVE_POLICY_FILE" > /dev/null 2>&1; then
        dns_mode=$(jq -r '.BraveSoftware.Brave.DnsOverHttpsMode' "$BRAVE_POLICY_FILE")
        if [ -n "$dns_mode" ] && [ "$dns_mode" != "null" ]; then
            jq ".DnsMode = \"$dns_mode\"" "$export_file" > tmp.json && mv tmp.json "$export_file"
            if [ $? -ne 0 ]; then
                echo "Warning: Failed to add DNS mode to export file"
            fi
        fi
    fi
    
    echo "Settings exported to $export_file"
}

import_settings() {
    local import_file="$1"
    
    if [ ! -f "$import_file" ]; then
        echo "Import file not found: $import_file"
        return 1
    fi
    
    apply_preset "$import_file"
}

reset_settings() {
    echo "Warning: This will erase ALL Brave policy settings and restore them to their default state."
    read -p "Do you want to continue? (y/n): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        rm -f "$BRAVE_POLICY_FILE"
        mkdir -p "$(dirname "$BRAVE_POLICY_FILE")"
        echo '{"BraveSoftware":{"Brave":{}}}' > "$BRAVE_POLICY_FILE"
        echo "All Brave policy settings have been successfully reset to their default values."

        if [ -n "$USER_PREFERENCES" ] && [ -f "$USER_PREFERENCES" ]; then
            local backup_file="${USER_PREFERENCES}.bak"
            echo "Do you want to restore user preferences to default as well? (y/n): "
            read restore_prefs
            
            if [ "$restore_prefs" = "y" ] || [ "$restore_prefs" = "Y" ]; then
                cp "$USER_PREFERENCES" "$backup_file"
                echo "Created backup of Preferences file at $backup_file"
            fi
        fi
    else
        echo "Reset cancelled."
    fi
}

declare -A POLICY_SETTINGS=(
    ["telemetry,1"]="MetricsReportingEnabled 0 Boolean"
    ["telemetry,2"]="SafeBrowsingExtendedReportingEnabled 0 Boolean"
    ["telemetry,3"]="UrlKeyedAnonymizedDataCollectionEnabled 0 Boolean"
    ["telemetry,4"]="FeedbackSurveysEnabled 0 Boolean"
    
    ["privacy,1"]="SafeBrowsingProtectionLevel 0 Integer"
    ["privacy,2"]="AutofillAddressEnabled 0 Boolean"
    ["privacy,3"]="AutofillCreditCardEnabled 0 Boolean"
    ["privacy,4"]="PasswordManagerEnabled 0 Boolean"
    ["privacy,5"]="BrowserSignin 0 Integer"
    ["privacy,6"]="WebRtcIPHandling disable_non_proxied_udp String"
    ["privacy,7"]="QuicAllowed 0 Boolean"
    ["privacy,8"]="BlockThirdPartyCookies 1 Boolean"
    ["privacy,9"]="EnableDoNotTrack 1 Boolean"
    ["privacy,10"]="ForceGoogleSafeSearch 1 Boolean"
    ["privacy,11"]="IPFSEnabled 0 Boolean"
    ["privacy,12"]="IncognitoModeAvailability 1 Integer"
    
    ["features,1"]="BraveRewardsDisabled 1 Boolean"
    ["features,2"]="BraveWalletDisabled 1 Boolean"
    ["features,3"]="BraveVPNDisabled 1 Boolean"
    ["features,4"]="BraveAIChatEnabled 0 Boolean"
    ["features,5"]="BraveShieldsDisabledForUrls [\"https://*\", \"http://*\"] String"
    ["features,6"]="TorDisabled 1 Boolean"
    ["features,7"]="SyncDisabled 1 Boolean"
    
    ["performance,1"]="BackgroundModeEnabled 0 Boolean"
    ["performance,2"]="MediaRecommendationsEnabled 0 Boolean"
    ["performance,3"]="ShoppingListEnabled 0 Boolean"
    ["performance,4"]="AlwaysOpenPdfExternally 1 Boolean"
    ["performance,5"]="TranslateEnabled 0 Boolean"
    ["performance,6"]="SpellcheckEnabled 0 Boolean"
    ["performance,7"]="PromotionsEnabled 0 Boolean"
    ["performance,8"]="SearchSuggestEnabled 0 Boolean"
    ["performance,9"]="PrintingEnabled 0 Boolean"
    ["performance,10"]="DefaultBrowserSettingEnabled 0 Boolean"
    ["performance,11"]="DeveloperToolsDisabled 1 Boolean"
    
    ["dns,1"]="automatic"
    ["dns,2"]="off"
    ["dns,3"]="custom"
    ["dns,4"]="on"
)

declare -A MENUS=(
    ["main"]="SlimBrave
1. Configure Settings
2. Load Preset
3. Import Settings
4. Export Settings
5. Apply Settings
6. Reset All Settings
7. Exit"
    
    ["categories"]="===== Configure Individual Settings =====

Choose a category:
1. Telemetry & Reporting
2. Privacy & Security
3. Brave Features
4. Performance & Bloat
5. DNS Settings
6. Return to main menu"
    
    ["telemetry"]=""
    ["privacy"]=""
    ["features"]=""
    ["performance"]=""
    ["dns"]="===== Configure DNS Settings =====

1. Automatic
2. Off
3. Custom
4. On
5. Return to categories"
)

process_menu_option() {
    local menu_type="$1"
    local option="$2"
    local max_option="$3"
    
    if [ "$option" -eq "$max_option" ]; then
        return 0
    fi
    
    if [ "$menu_type" = "dns" ] && [ "$option" -lt "$max_option" ]; then
        set_dns_mode "${POLICY_SETTINGS["dns,$option"]}"
        return 0
    fi
    
    if [ "$option" -lt "$max_option" ]; then
        read -r key value type <<< "${POLICY_SETTINGS["$menu_type,$option"]}"
        if [ -n "$key" ]; then
            local current_status=$(get_feature_status "$key" "$value")
            
            if [ "$current_status" = "disabled" ]; then
                if [ "$value" = "1" ]; then
                    value="0"
                elif [ "$value" = "0" ]; then
                    value="1"
                elif [ "$value" = "true" ]; then
                    value="false"
                elif [ "$value" = "false" ]; then
                    value="true"
                fi
            fi
            
            set_policy "$key" "$value" "$type"
            generate_dynamic_menus
        fi
    fi
}

process_option_range() {
    local menu_type="$1"
    local option="$2"
    local max_option="$3"
    
    if [[ $option == *-* ]]; then
        IFS='-' read -r start end <<< "$option"
        if [[ $start =~ ^[0-9]+$ ]] && [[ $end =~ ^[0-9]+$ ]]; then
            for ((i=start; i<=end && i<max_option; i++)); do
                process_menu_option "$menu_type" "$i" "$max_option"
            done
            return 1
        fi
    fi
    return 0
}

show_menu() {
    local menu_type="$1"
    
    generate_dynamic_menus
    
    local menu_text="${MENUS[$menu_type]}"
    local max_option=$(echo "$menu_text" | grep -c "^[0-9]\+\.")
    max_option=$((max_option + 1))
    
    clear
    echo "$menu_text"
    echo
    read -p "Enter your choice: " option
    
    process_option_range "$menu_type" "$option" "$max_option"
    if [ $? -eq 1 ]; then
        return
    fi
    
    process_menu_option "$menu_type" "$option" "$max_option"
}

configure_settings() {
    while true; do
        show_menu "categories"
        
        case $option in
            1) show_menu "telemetry" ;;
            2) show_menu "privacy" ;;
            3) show_menu "features" ;;
            4) show_menu "performance" ;;
            5) show_menu "dns" ;;
            6) return 0 ;;
            *) echo "Invalid option" ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

load_preset() {
    clear
    echo "===== Load Preset ====="
    echo ""
    
    readarray -t presets < <(find "$PRESET_DIR" -name "*.json" -type f)
    local i=1
    
    if [ ${#presets[@]} -eq 0 ]; then
        echo "No presets found in $PRESET_DIR"
        read -p "Press Enter to return to the main menu..."
        return
    fi
    
    echo "Available presets:"
    for preset in "${presets[@]}"; do
        preset_name=$(basename "$preset" .json)
        preset_name=${preset_name//" Preset"/""}
        echo "$i. $preset_name"
        i=$((i+1))
    done
    echo "$i. Return to main menu"
    
    read -p "Select a preset to load: " choice
    
    if [ "$choice" -eq "$i" ]; then
        return
    elif [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
        local selected_preset="${presets[$((choice-1))]}"
        apply_preset "$selected_preset"
        preset_name=$(basename "$selected_preset" .json)
        preset_name=${preset_name//" Preset"/""}
        echo "Preset $preset_name loaded successfully!"
    else
        echo "Invalid choice"
    fi
    
    read -p "Press Enter to continue..."
}

import_settings_menu() {
    clear
    echo "===== Import Settings ====="
    echo ""
    read -p "Enter the path to the settings file: " import_file
    
    if [ -z "$import_file" ]; then
        echo "No file specified."
    else
        import_settings "$import_file"
    fi
    
    read -p "Press Enter to continue..."
}

export_settings_menu() {
    clear
    echo "===== Export Settings ====="
    echo ""
    read -p "Enter the path for the exported settings file: " export_file
    
    if [ -z "$export_file" ]; then
        echo "No file specified."
    else
        export_settings "$export_file"
    fi
    
    read -p "Press Enter to continue..."
}

main_menu() {
    invert_disabled_enabled_settings
    
    while true; do
        show_menu "main"
        
        case $option in
            1) configure_settings ;;
            2) load_preset ;;
            3) import_settings_menu ;;
            4) export_settings_menu ;;
            5)  
                echo "Settings have been saved to $BRAVE_POLICY_FILE"
                echo "Restart Brave to see changes."
                read -p "Press Enter to continue..."
                ;;
            6) reset_settings ;;
            7) 
                echo "Exiting SlimBrave..."
                exit 0
                ;;
            *)
                echo "Invalid option"
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

main_menu