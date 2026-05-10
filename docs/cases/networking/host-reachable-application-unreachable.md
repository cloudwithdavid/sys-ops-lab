# Host Reachable Application Unreachable

> "Vendor portal is down for me... Internet is working fine and I can access other internal tools. Just this one site won't load."

## Summary

User is unable to access vendor portal.

## Issue

Single user is unable to access vendor portal while having access to internet and other internal tools.

## Hypotheses

1. Issue is limited to the user's endpoint
2. Vendor portal domain does not resolve
3. Vendor portal server or application is unreachable
4. Vendor portal service is inactive

## Checks
<!-- markdownlint-disable MD029 -->
1. Ask user if there is an error message when attempting to load the vendor portal
    - finding: User reports that they recieve a 'Connection Timeout' error message

2. Check if the vendor portal loads on my device
    - finding: My endpoint also recieves 'Connection Timeout' error message

3. Check if domain resolves (with `nslookup`)
    - finding: domain resolves correctly to an internal IP

4. Check if the server/host is reachable (with `ping`)
    - finding: The server responds with low latency and no packet loss

5. Check if the application is reachable (with `curl`)
    - finding: Connection fails or times out.

6. Check service status and logs (with `systemctl` and `journalctl -u`)
    - finding: Service status is active and logs show no signs of an error

7. Check application listening ports (`ss -tulsn`)
    - finding: Nothing is listening on port 80. The expected port is not open.

8. Check vendor portal config file
    - finding: Vendor portal config file revealed application server is binded to port 8080 instead of port 80. Application server is unable to recieve http requests

## Resolution

> **Action Sequence:**
>
> 1. Edit the config file and correct bind_port from 8080 to 80 with `sudo nano /etc/vendor-portal/vendor-portal.conf`
> 2. Restart the service so it picks up the new config with `sudo systemctl restart vendor-portal`
> 3. Verify the port is now listening with `ss -tuln | grep :80`
> 4. Confirm the application responds with `curl -I --max-time 5 http://vendor-portal.internal`

The port configuration file for the vendor portal was binded to port 8080 instead of port 80. Corrected the config file binding to port 80. After the correcting the config file the vendor portal was started successfully.

> Escalation would be required if editing the application config file was outside of support scope.

## Verification

- Confirmed the vendor portal port is now listening on port 80
- Confirmed the vendor portal returns a valid http response
- Confirmed the application vendor portal loads normally

## Debrief

A connection timeout means no response was recieved, therefore could point to a host, network, or application issue. When ping succeeds but curl fails it means that the server/host is reachable, but the application is not responding.

The layer by layer check order this case demonstrates is: endpoint -> DNS -> host -> application -> service -> port -> config. The order matters because confirming whether only a single user is experiencing an issue points to completely different troubleshooting paths. If one user is affected it generally calls for toubleshooting their endpoint configuration, whereas if multiple users are affected it points to shared infrastructure, where the focus would be the server, service, application, and networking.
