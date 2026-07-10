# No Outbound Internet from Build Server

> "I can SSH into build-vm-02, but the Harbor Notes build fails when it tries to download dependencies. Internal Git seems to work, but external package downloads time out."

## Summary

Harbor Notes build server cannot access external package repositories.

## Issue

User reports they can SSH into the Harbor Notes build server and that the server can access the internal Git repository, but package dependency downloads from external repositories are failing.

## Hypotheses

1. DNS resolution may be failing when the server tries to reach external package repositories.
2. The build server does not have a valid route for outbound internet traffic.
3. Outbound traffic may be blocked by a firewall, proxy, or network policy.

## Checks

1. Test external package repository access (with `curl [external repository URL]`)  
   _**Finding:**_ Connection fails or times out.

2. Test external IP reachability (with `ping -c 4 [public IP]`)  
   _**Finding:**_ Public IP is unreachable.

3. Review routing table (with `ip route`)  
   _**Finding:**_ Default route points to an invalid gateway for the server’s network.

> **Related Tooling**
>
> [`evidence-collect.sh`](../../../tools/bash/evidence-collect.sh) supports this case by collecting first-pass network evidence that matches the main checks:
>
> - routing table output with `ip route`
> - external IP reachability with `ping`
> - external URL reachability with `curl`
>
> In this case, the routing table and external reachability output would help show the asymmetric failure pattern: internal access works, but outbound internet access fails. That evidence supports the finding that the issue was caused by an invalid default route gateway.

## Resolution

> **Action sequence:**
>
> 1. Corrected default route using `sudo ip route add default via [gateway] dev [interface]`

The build server could reach internal resources but could not reach external package repositories due to a invalid default route configuration. Added the correct default route via the gateway at [gateway] on [interface] using `ip route`. Outbound connectivity was restored.

## Verification

- Confirmed external IP reachability restored
- Confirmed external repository access restored
- Confirmed the Harbor Notes dependency download step completes successfully

## Prevention

When external access fails but internal access works, check the default route early. This asymmetric pattern is a strong indicator that routing is the problem.

## Debrief

In many real environments, correcting a default route on a managed server would be outside L1 scope and escalated to an engineer with the right authorization.

This case involved a junior developer's build workflow — SSHing into a build server, pulling source from an internal Git repo, and downloading dependencies from an external package repository. Understanding that workflow made the asymmetric failure pattern meaningful: internal access worked, external didn't, this made routing the strongest early hypothesis. DNS and firewall failures tend to affect both. A missing or invalid default route explains the asymmetry cleanly.

Key distinction: `curl` accepts URLs and tests full HTTP reachability while `nslookup` accepts just the domain name and tests DNS resolution. And `ping` accepts a hostname or IP address and tests IP reachability.  Each check targets a different layer, so knowing which tool tests what prevents misreading results.
