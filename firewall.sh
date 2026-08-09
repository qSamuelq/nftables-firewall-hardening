#!/bin/bash

set -e

echo "[+] Starting firewall deployment..."

# Check if nft is installed
if ! command -v nft &> /dev/null
then
    echo "[!] nftables is not installed."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
mkdir -p "$BACKUP_DIR"

# Check configuration syntax
echo "[+] Checking nftables configuration..."
sudo nft -c -f "$SCRIPT_DIR/nftables.conf"

echo "[+] Configuration valid."

# Backup current rules
echo "[+] Backing up current rules..."
BACKUP_FILE="$BACKUP_DIR/firewall-backup-$(date +%Y%m%d-%H%M%S).nft"
sudo nft list ruleset > "$BACKUP_FILE"
echo "[+] Backup saved to $BACKUP_FILE"

# Apply firewall
echo "[+] Applying firewall rules..."
sudo nft -f "$SCRIPT_DIR/nftables.conf"

# Verify rules were applied correctly
echo "[+] Verifying firewall rules were applied..."
RULE_COUNT=$(sudo nft list ruleset | grep -cE '^\s*chain\s')
if [ "$RULE_COUNT" -lt 3 ]; then
    echo "[!] ERROR: Firewall rules do not appear to be applied correctly. Rolling back..."
    sudo nft -f "$BACKUP_FILE"
    echo "[!] Rolled back to previous ruleset from $BACKUP_FILE"
    exit 1
fi

echo "[+] Verification passed ($RULE_COUNT chains active)."

# Show active rules
echo "[+] Active firewall rules:"
sudo nft list ruleset

echo "[+] Firewall successfully deployed."
