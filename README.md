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
- SSH connection rate limiting (10 new connections/minute) to reduce brute-force risk
- Ingress filtering of spoofed private-address source IPs (RFC 1918 ranges should never
  arrive from the public internet on this interface)
- Rate-limited ICMP/ICMPv6, restricted to diagnostic types only (echo-request,
  destination-unreachable, time-exceeded)
- IPv6 Neighbour Discovery explicitly permitted so IPv6 connectivity keeps working
- All dropped packets logged with a `FIREWALL DROP:` prefix for visibility

---

## Repository Contents
| File | Description |
|------|-------------|
| `nftables.conf` | The firewall ruleset itself |
| `firewall.sh` | Validates, backs up, and deploys `nftables.conf` |
| `rollback.sh` | Restores the most recent backup (or flushes all rules if none exist) |
| `backups/` | Timestamped rulesets saved automatically before each deploy (created at runtime, not committed) |
| `tests/test-firewall.sh` | Exercises a deployed firewall from another host using `nmap` |
| `tests/test-results.md` | Template for recording test output |

---

## Requirements
- A Linux host with `nftables` installed (`nft` on `$PATH`)
- `sudo` access to load rules and read kernel logs
- `nmap` on the *testing* machine (not the firewalled host) if running `tests/test-firewall.sh`

---

## Deploying the Firewall
```
./firewall.sh
```
This checks the syntax of `nftables.conf`, saves a timestamped backup of the current
ruleset to `backups/`, applies the new rules, and verifies at least three chains are
active. If verification fails, it automatically restores the backup it just took.

## Rolling Back
```
./rollback.sh                      # restores the most recent backup in backups/
./rollback.sh backups/<file>.nft   # restores a specific backup
```
If no backup can be found, the script warns that it is about to remove **all** firewall
protection and asks for confirmation before flushing the ruleset.

## Testing
From a separate machine that can reach the target host:
```
./tests/test-firewall.sh <target-ip>
```
Record results in `tests/test-results.md`.

---

## Known Limitations
- Anti-spoofing only covers IPv4 RFC 1918 ranges; it assumes the host has no legitimate
  peers on private-address space (e.g. behind an internal load balancer). Adjust the
  `ip saddr` drop rule if your deployment differs.
- IPv6 source-address spoofing protection is not implemented.
- `firewall.sh`/`rollback.sh` are designed for interactive use on the target host itself,
  not for unattended/remote execution.
