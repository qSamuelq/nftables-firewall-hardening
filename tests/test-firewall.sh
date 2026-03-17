#!/bin/bash

VM_IP="10.0.2.15"

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
echo "[+] Firewall test complete."