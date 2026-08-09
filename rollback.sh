#!/bin/bash

#script stops if something fails.
set -euo pipefail

echo "[!] Rolling back firewall configuration..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"

# use an explicit backup file if given as $1, otherwise fall back to the most recent one
BACKUP_FILE="${1:-}"
if [ -z "$BACKUP_FILE" ] && [ -d "$BACKUP_DIR" ]; then
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/firewall-backup-*.nft 2>/dev/null | head -n 1 || true)
fi

if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
    echo "[+] Restoring rules from $BACKUP_FILE..."
    sudo nft -f "$BACKUP_FILE"
    echo "[+] Firewall restored."
else
    echo "[!] No backup found. Flushing firewall rules will remove ALL filtering, leaving the host unprotected."
    read -r -p "Continue anyway? [y/N] " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "[!] Aborted - no changes made."
        exit 1
    fi
    sudo nft flush ruleset
fi

sudo nft list ruleset
