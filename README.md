# Linux Host-Based Firewall Hardening

## Overview
This project implements a production-style, host-based firewall for a Linux server exposed to the public internet.  
The goal is to reduce attack surface, enforce least privilege network access, and demonstrate practical defensive security skills.

The firewall is implemented using **nftables**, the modern Linux packet filtering framework.

---

## Threat Model
The system is assumed to be a publicly accessible Linux server (e.g. cloud VM or VPS).

### Primary threats:
- Port scanning and reconnaissance
- Brute-force SSH attacks
- Spoofed or malformed packets
- Unnecessary service exposure

The firewall is designed to **block unsolicited traffic by default** while allowing only explicitly required services.

---

## Design Principles
- Default deny on inbound traffic
- Explicit allow rules for required services only
- Rate limiting on exposed services
- Logging of denied traffic for visibility
- Simple, auditable rule set

---

## Allowed Traffic
| Service | Protocol | Port | Notes |
|------|--------|------|------|
| Loopback | Any | Any | Local system communication |
| SSH | TCP | 22 | Rate-limited to reduce brute force risk |
| HTTP | TCP | 80 | Web traffic |
| HTTPS | TCP | 443 | Secure web traffic |
| ICMP | ICMP | N/A | Rate-limited for diagnostics |

All other inbound traffic is dropped.

---

## Security Controls Implemented
- Default DROP policy on INPUT and FORWARD chains
- Stateful inspection (ESTABLISHED, RELATED)
- SSH connection rate li
