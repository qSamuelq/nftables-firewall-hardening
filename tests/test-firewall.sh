#!/bin/bash

VM_IP=${1:-10.0.2.15}

echo "[+] Testing firewall on $VM_IP"

echo ""
echo "[+] Checking open ports (should show 22, 80, 443 only)..."
nmap -p 22,80,443 $VM_IP

echo ""
echo "[+] Checking blocked ports (should be filtered)..."
nmap -p 21,25,445,9999 $VM_IP

echo ""
echo "[+] Running full port scan (may take time)..."
nmap -p- $VM_IP

echo ""
echo "[+] Testing firewall logging..."
nmap -p 9999 $VM_IP > /dev/null

echo ""
echo "[+] Checking logs for dropped packets..."
sudo journalctl -k | grep "FIREWALL DROP" | tail -n 5

echo ""
echo "[+] Testing SSH rate limiting (sending 15 rapid connections)..."
BLOCKED=0
for i in $(seq 1 15); do
    # attempt a connection with a 2 second timeout, expect it to be refused or timeout
    if ! timeout 2 bash -c "echo > /dev/tcp/$VM_IP/22" 2>/dev/null; then
        BLOCKED=$((BLOCKED + 1))
    fi
done

if [ "$BLOCKED" -gt 0 ]; then
    echo "[+] Rate limiting appears to be working. $BLOCKED/15 connections were blocked."
else
    echo "[!] WARNING: No connections were blocked. Rate limiting may not be working."
fi

echo ""
echo "[+] Checking logs for rate limit drops..."
sudo journalctl -k | grep "FIREWALL DROP" | tail -n 5

echo ""
echo "[+] Firewall test complete."