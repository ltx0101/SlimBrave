import json
from pathlib import Path
import subprocess
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

# Configuration file path
CONFIG_FILE = Path.home() / ".config" / "brave" / "Preferences"

def get_config():
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print("Brave config file not found.")
        return None

def save_config(config):
    try:
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=4)
        return True
    except Exception as e:
        print(f"Error saving config: {e}")
        return False

# Initialize settings
settings = get_config()
if not settings:
    exit("Failed to load Brave settings.")

window = Gtk.Window(title="SlimBrave")
window.set_default_size(400, 450)

grid = Gtk.Grid()
window.add(grid)

checkboxes = {}
features = [
    {"name": "Disable Brave Rewards", "key": "extensions.brave-rewards.enabled"},
    {"name": "Disable Brave Wallet", "key": "extensions.brave-wallet.enabled"},
    {"name": "Disable Brave VPN", "key": "extensions.brave-vpn.enabled"},
    {"name": "Enable Brave AI Chat", "key": "features.brave-ai-chat.enabled"},
    {"name": "Disable Password Manager", "key": "password_manager.enabled"},
    {"name": "Disable Tor", "key": "extensions.tor-browser.enabled"},
    {"name": "Disable Brave Ads", "key": "features.brave-features.ads-enabled"},
    {"name": "Disable Sync", "key": "sync.enabled"}
]

for i, feature in enumerate(features):
    label = Gtk.Label(feature["name"])
    cb = Gtk.CheckButton()
    cb.set_active(not settings.get(feature["key"], True))  # Assuming 0 is disabled
    
    grid.attach(label, 0, i, 1, 1)
    grid.attach(cb, 1, i, 1, 1)
    
    checkboxes[feature["key"]] = cb

# Add Save button
button = Gtk.Button("Save Settings")
button.connect("clicked", lambda x: 
    (lambda:
        (lambda b: 
            any(print(f"Changed {k} to {b}") or save_config(settings) for k, b in [(cb.get_active(), cb.get_name()) for cb in checkboxes.values()])))
    
window.show_all()

Gtk.main()
