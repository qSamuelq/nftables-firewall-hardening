# Firewall Testing

## Before Firewall

nmap localhost

Open ports:
22/tcp
80/tcp
443/tcp

## After Firewall

Only allowed ports remain accessible.

Blocked ports are filtered by nftables.

Logs confirm dropped packets.