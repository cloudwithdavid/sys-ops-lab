# DNS Configuration Issue

> "My Linux workstation can't reach internal tools or the internet after the office move last week. I can ping other computers on my floor but nothing else works. Tried restarting. Still broken. Username: marcus.okafor — machine is the one labeled WS-04 at my desk."

## Summary

User is unable to access internet or internal tools

## Issue

User is unable to access internet or internal tools while being able to reach local hosts

## Hypotheses

1. Device unable to reach external hosts
2. Default gateway is missing or incorrect
3. Device unable to resolve domain names

## Checks
<!-- markdownlint-disable MD029 MD032 -->
1. Confirm IP reachability — `ping` to an external IP  
   _**Finding:**_ Device is able to reach external IPs

2. Confirm name resolution is actually broken — `dig` against a known hostname  
   _**Finding:**_ Queries are being sent to the old segment's DNS server therefore is unable to resolve domain names

3. Confirm nameserver configuration (with `cat /etc/resolv.conf`)  
   _**Finding:**_ Nameserver entry points to the old DNS server IP from the previous network segment.

```bash
nameserver 10.0.1.53
```

## Resolution

> **Action sequence:**  
> 1. Corrected `resolv.conf` file (with `nano /etc/resolv.conf`) to the correct DNS server
> 2. Checked device domain name resolution (with `dig`)
> 3. Checked if the device can access internet and internal tools (with `curl`)

The nameserver configuration file was incorrectly pointing to the old DNS server IP from the previous network segment, causing the device to be unable to resolve domain names. Corrected the nameserver entry to the current DNS server IP. After correcting the entry, the device was able to resolve names, access the internet, and access internal tools.

## Verification

- Confirmed device is able to resolve domain names
- Confirmed device is able to access internet and internal tools

## Prevention

Confirm nameserver configuration file is properly configured after performing network segment migrations

## Debrief

`/etc/resolv.conf` is a plain text configuration file on a Linux machine that tells it what DNS server to send name resolution queries

_**I encoded the understanding of DNS and IP more concretely**_ —  
particularly from the framing of the network troubleshooting commands (`ping` and `dig`).

With `ping <domain/hostname>`, it does check name resolution, but it also checks packet routing. Therefore if it fails, it could be either a routing issue or a name resolution issue. So `ping` would not be ideal if you wanted to check name resolution specifically. Instead you would use `dig <domain>` ( or`nslookup <domain>`),  because it checks name resolution alone, allowing you to determine whether name resolution is an issue directly.
