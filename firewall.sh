#!/bin/bash

set -e

echo "[+] Starting firewall deployment..."

# Check if nft is installed
if ! command -v nft &> /dev/null
then
    echo "[!] nftables is not installed."
    exit 1
fi

# Check configuration syntax
echo "[+] Checking nftables configuration..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo nft -c -f "$SCRIPT_DIR/nftables.conf"

echo "[+] Configuration valid."

# Backup current rules
echo "[+] Backing up current rules..."
sudo nft list ruleset > "firewall-backup-$(date +%Y%m%d-%H%M%S).nft"

# Apply firewall
echo "[+] Applying firewall rules..."
sudo nft  -f "$SCRIPT_DIR/nftables.conf"

# Verify rules were applied correctly
echo "[+] Verifying firewall rules were applied..."
RULE_COUNT=$(sudo nft list ruleset | grep -c "chain")
if [ "$RULE_COUNT" -lt 3 ]; then
    echo "[!] ERROR: Firewall rules do not appear to be applied correctly. Rolling back..."
    sudo nft -f firewall-backup.nft
    exit 1
fi

echo "[+] Verification passed ($RULE_COUNT chains active)."

# Show active rules
echo "[+] Active firewall rules:"
sudo nft list ruleset

echo "[+] Firewall successfully deployed."