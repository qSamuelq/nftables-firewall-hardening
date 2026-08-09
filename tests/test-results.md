# Firewall Testing

Run `tests/test-firewall.sh <VM_IP>` against a deployed target and record results below.

## Before Firewall

Baseline scan (`nmap <VM_IP>`) - record whatever is actually open before `firewall.sh` runs.

| Port | Service | State |
|------|---------|-------|
|      |         |       |

## After Firewall

| Check | Expected | Actual | Pass/Fail |
|-------|----------|--------|-----------|
| Allowed ports (22, 80, 443) reachable | open | | |
| Other ports (21, 25, 445, 9999, ...) | filtered/closed | | |
| Full port scan | only 22/80/443 open | | |
| Dropped packets logged (`FIREWALL DROP` in kernel log) | present | | |
| SSH rate limiting (15 rapid connections) | some connections blocked | | |

## Notes

Record date, target environment (e.g. VM image/kernel version), and any anomalies observed during testing.
