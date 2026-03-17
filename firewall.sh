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
sudo nft -c -f nftables.conf

echo "[+] Configuration valid."

# Backup current rules
echo "[+] Backing up current rules..."
sudo nft list ruleset > firewall-backup.nft

# Apply firewall
echo "[+] Applying firewall rules..."
sudo nft -f nftables.conf

# Show active rules
echo "[+] Active firewall rules:"
sudo nft list ruleset

echo "[+] Firewall successfully deployed."