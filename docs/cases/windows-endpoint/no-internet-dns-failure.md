# No Internet Access

## Summary

User reports that their Windows device cannot access the internet over Wi-Fi.

## Issue

Single user on a Windows endpoint is unable to access any internet-dependent sites or applications over Wi-Fi.

## Hypotheses

1. Device is connected to the wrong SSID or is not fully connected
2. Device has invalid IP configuration
3. Device cannot reach the default gateway
4. DNS resolution is failing while basic connectivity still works

## Checks

1. Confirm exact symptom and whether all apps/sites fail
   - finding: Device cannot access internet-dependent sites or applications

2. Confirm connection to intended SSID
   - finding: Device is connected to the intended SSID

3. Check whether other devices on the same network are affected
   - finding: Devices on the same network have internet connection and are not affected

4. Review IP configuration for valid IP, gateway, and DNS values with `ipconfig /all`
   - finding: Endpoint has valid IP address, default gateway, and DNS server values

5. Test reachability to default gateway with `ping [gateway]`
   - finding: Device is able to reach default gateway

6. Test reachability to a public IP with `ping [public IP]`
   - finding: Device can reach a public IP

7. Test DNS resolution with `nslookup google.com`
   - finding: DNS resolution failed, no response received from DNS server

## Resolution

DNS resolution was failing on the endpoint despite valid IP configuration and working connectivity to the gateway and a public IP. Disconnected and reconnected the Wi-Fi adapter to refresh local network state, then confirmed DNS queries and internet access were working normally.

> Issue was resolved at the endpoint level after identifying DNS failure. Escalation would be appropriate if DNS continued failing after endpoint-level correction or if multiple devices were affected.

## Verification

- Confirmed DNS queries return valid responses
- Confirmed websites load normally
- Confirmed internet-dependent applications function correctly

## Prevention

- Verify DNS settings when IP/gateway appear normal but connectivity fails
- Use public IP vs DNS testing to quickly isolate name resolution issues
- Document recurring DNS issues for potential network-level follow-up

## Debrief

If the issue isn’t wrong SSID connection or a bad Wi-Fi join, then the most useful next buckets are usually IP configuration, gateway reachability, and DNS resolution.
This understanding also provides a good order for first-line checks.

This case also helped show how simple CLI tools support real troubleshooting: `ipconfig` to inspect network configuration, `ping` to test reachability, and `nslookup` to isolate DNS behavior.

When Wi-Fi is connected and IP/gateway checks pass, testing a public IP versus a domain quickly isolates DNS failures. “Connected, no internet” often indicates a name resolution issue rather than a full connectivity loss. This case reinforces troubleshooting connectivity in layers: SSID → IP → gateway → external IP → DNS.
