# DNS Resolves Service Still Fails

> "Pressroom won't load for me or anyone on my team. We've tried refreshing and different browsers. Just times out... It was working this morning."

## Summary

Users unable to access Pressroom application

## Issue

Multiple user cannot access Pressroom web application on multiple browsers

## Hypotheses

1. Pressroom's hostname cannot be resolved
2. Pressroom host is unreachable
3. Service is in a failed state
4. Service is not listening on the expected port.

## Checks

1. Check Pressroom web application behavior on my device  
   _**Finding:**_ Pressroom application times out. Non-responsive.

2. Check Pressroom name resolution' (with `getent hosts`)  
   _**Finding:**_ Pressroom name successfully resolved and provided? the host IP

3. Check Pressroom host reachability' (with `ping`)  
   _**Finding:**_ Host is reachable

4. Check if app responds (with `curl`)  
   _**Finding:**_ Curl timed out. No HTTP response received

5. Check service state and logs' (with `systemctl` and `journalctl`)  
   _**Finding:**_ Service status is active. Logs show no errors.

6. Check service listening ports (with `ss -tuln`)  
   _**Finding:**_ evidence-collect output showed no listener on port 80

> **Related Tooling**
>
> [`evidence-collect.sh`](../../../tools/bash/evidence-collect.sh) supports this case by collecting first-pass Linux evidence that matches checks 2-6:
>
> Firstly by checking client-side application name resolution, host reachability and routing, and response
>
> Secondly by checking server-side service status and logs, as well as listening ports

## Verification

- Confirmed application connection times out
- Confirmed application is not listening on port 80

## Escalation

Escalated to the Pressroom application team. Client-side checks confirmed DNS resolves and the host is reachable. Server-side checks confirmed the service is active with no errors in logs, but nothing is listening on the expected port. The fault is isolated to the port binding.

> Config changes on a business-critical application with an unknown recent change are outside first-line scope.

---
---
---

## Debrief

A clean escalation isn't just about knowing the boundary, it's about how much useful work you can do before you hit it.

### Web Application Troubleshooting

Client = C | Server = S

**DNS resolves?**  
_C_: Can the client resolve the app name? (`dig`/`nslookup [example.com]`)  
_S_: Can the server resolve dependency names? (`dig`/`nslookup [api.example.com]`)  
    → no  : DNS failure  
    → yes ↓  

**Network path exists?**  
_C_: Can the client reach the app host? (`ping` / `traceroute` / `ip route`)  
_S_: Can the server reach external/internal dependencies? (`ping` / `traceroute` / `ip route`)  
    → no  : network/routing issue  
    → yes ↓

**Port reachable/listening?**  
_C_: Can the client reach the app port? (`nc -vz [example.com] [443]`)  
_S_: Is the service listening on the expected port? (`ss -tuln`)  
    → no  : app not listening/routing issue  
    → yes ↓

**HTTP responds?**  
_C_: Can the client complete an HTTP/HTTPS request? (`curl -v [https://example.com]`)  
_S_: Does the app respond internally? (`curl -v [http://localhost:8000]`)  
    → no  : protocol/app timeout issue  
    → yes ↓

**HTTP status?**  
_C_: What status does the client receive? (`curl -i [https://example.com]`)  
_S_: What status does the app return internally? (`curl -i [http://localhost:8000]`)  
    → 4xx : client — request issue  
    → 5xx : server — app issue  
    → 2xx/3xx ↓

**Expected result?**  
_C_: Does the client receive the expected page, API response, or data?  
_S_: Does the app generate the expected response before it reaches the client?  
    → no  : frontend/data issue  
    → yes : the application is working

### Systems Troubleshooting

Name → Network → Port → Protocol → Result

---

The biggest upgrade to the overall troubleshooting framework understanding was including client and server diagnostic perspective.
