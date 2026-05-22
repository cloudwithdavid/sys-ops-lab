# Service Is Running But Application Is Unavailable

> "Freightboard is down. I can't access it and neither can anyone else on my team... Checked on two browsers, page just spins and never loads."

## Summary

Users unable to access Freightboard application.

## Issue

Multiple users unable to access Freightboard application. User reports application page spins indefinitely with no response returned.

## Hypotheses

1. The service process is in a failed or inactive state
2. The application failed to start correctly due to a startup dependency failure
3. The application port configuration is incorrect

## Checks

1. Confirm scope
    - finding: Issue is not limited to Marcus. Multiple users across the ops team are affected.

2. Check service status and logs
    - finding: Logs show the application failed to connect to its database on startup, while the service is active and running. No failed state or crash indicated.

3. Check application reachability
    - finding: Connection times out. No HTTP response returned.

4. Check listening ports
    - finding: Nothing is listening on port 80. The expected port is not open.

> It started the process, hit the database connection error, and never completed initialization, so it never bound to port 80.

## Verification

- Confirmed application connection times out
- Confirmed application is not listening on port 80
- Confirmed service logs show database connection error

## Escalation

Multiple users are affected, pointing to a shared infrastructure issue. The Freightboard service is active and running. Application connection times out, nothing is listening on port 80, and service logs show a database connection error on startup. The database connectivity failure is the likely root cause but requires infrastructure-level investigation to confirm.

Database connectivity is outside first-line support scope, escalating to the infrastructure team.

## Prevention

A running service does not guarantee a healthy application. Startup dependency failures can prevent initialization without causing a service crash.

## Debrief

**-- How an App Can Fail to Load --**\
When someone says "the app won't load," that complaint could actually be happening at several different layers. Each one has a different cause and a different fix.
The stack, from the outside in:

1. DNS failure / does not resolve
The browser can't even look up where `freightboard.internal` lives. The request never goes anywhere. You'd typically see an error like "server not found" or "DNS_PROBE_FINISHED_NXDOMAIN."

2. DNS resolves —> **Host/Server unreachable**
DNS resolves fine, but the server itself isn't responding to basic network contact. `ping` would fail or time out. The machine may be down, off the network, or firewalled.

3. Host reachable -> **Application not responding**
The server is up and responding to `ping`, but the application on it isn't answering HTTP requests. `curl` to the app URL times out or gets refused. The service might be crashed, misconfigured, or listening on the wrong port.

4. Application responds -> **But returns an error**
The app is reachable and responds — but returns something like a `500`, `502`, or `503`. The service is running, but something inside it is broken: a crashed dependency, a bad config, a full disk, a database it can't reach.

5. Application loads -> **But content is broken**
The page technically loads but shows nothing useful — missing data, broken UI, partial render. Usually a backend query or API call failing silently.

\
**Host → Service → Application**\
The host is the physical or virtual machine -> The service is a managed process running on that host — is what actually runs your application code -> The application is what the service exposes to the outside world — usually an HTTP endpoint bound to a port. When the service starts correctly, it opens a port and starts listening for requests. That's when curl can reach it. That's when a browser can load it.
