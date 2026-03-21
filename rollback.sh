#!/bin/bash

#script stops if something fails.
set -euo pipefail

echo "[!] Rolling back firewall configuration..."

if [ -f firewall-backup.nft ]; then
    echo "[+] Restoring previous firewall rules..."
    sudo nft -f firewall-backup.nft
    echo "[+] Firewall restored."
else
    echo "[!] No backup found. Flushing firewall rules."
    sudo nft flush ruleset
fi

sudo nft list ruleset