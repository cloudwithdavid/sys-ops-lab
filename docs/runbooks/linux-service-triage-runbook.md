# Runbook — Linux Service Triage

> Runbook created in a simulated support lab.

## Purpose

Guide support through first-pass triage of Linux service issues where a service will not start, appears unhealthy, or is running but the application is still unavailable.

This runbook helps separate service state, logs, listening ports, application reachability, and resource issues so support can decide whether to resolve the issue or escalate with useful evidence.

## Use This Runbook When

Use this runbook when a Linux-hosted service or service-backed application is reported as unavailable, unhealthy, not responding, or unable to start.

Common examples include:

- a service fails to start
- an application page loads slowly, times out, or does not load
- multiple users report the same application is unavailable
- the host is reachable but the application does not respond
- the service appears active, but the expected application port is not listening

## Entry Conditions

- The affected system is Linux-hosted.
- The issue involves a service or service-backed application.
- Support can check service status, logs, ports, and basic reachability.
- The cause is not already confirmed at intake.

## Triage Questions

- What is the exact user-facing symptom?
- Is the issue affecting one user, multiple users, or all users?
- Is the host reachable?
- Is the service expected to be running?
- Did anything recently change, such as deployment, configuration, logs, disk usage, dependencies, or restart activity?
- Is there an error message, timeout, failed status, or blank/loading page?

## Decision Flow

### Step 1 — Confirm scope and symptom

- action: Confirm what the user sees, how many users are affected, and whether the issue appears tied to one service or application.
- why this step matters: Scope helps separate a single-user issue from a shared service-side issue.
- what the result suggests:
  - One user affected -> check whether the issue may be endpoint, access, or user-specific.
  - Multiple users affected -> continue service-side triage.

### Step 2 — Check service state

- action: Check the service status.

```bash
systemctl status [service-name] --no-pager
```

- why this step matters: Service state shows whether the managed process is active, failed, inactive, or restarting.
- what the result suggests:
  - Failed or inactive -> review logs for startup failure details.
  - Active/running -> do not assume the application is healthy. Continue checking reachability and ports.

### Step 3 — Review recent service logs

- action: Review recent service logs.

```bash
journalctl -u [service-name] -n 50 --no-pager
```

- why this step matters: Logs explain why a service failed, restarted, or did not fully initialize.
- what the result suggests:
  - Startup error, permission error, missing file, dependency error, or disk error -> follow the evidence.
  - No clear error -> continue checking application reachability and listening ports.

### Step 4 — Check application reachability

- action: Test whether the application responds.

```bash
curl -I --max-time 5 [application-url]
```

- why this step matters: A service can be active while the application still does not respond to users.
- what the result suggests:
  - HTTP response returned -> application is reachable, but may still have an application-level error.
  - Timeout or connection failure -> check whether the expected port is listening.
  - 500, 502, or 503 response -> application is reachable but failing internally or through a dependency.

### Step 5 — Check listening ports

- action: Check whether the expected port is listening.

```bash
ss -tuln
```

- why this step matters: If the application is not listening on the expected port, users cannot reach it even if the service process appears active.
- what the result suggests:
  - Expected port is listening -> continue checking application response, logs, or upstream dependencies.
  - Expected port is not listening -> service may not have initialized correctly, may be bound to the wrong port, or may have a config/dependency issue.

### Step 6 — Check basic resource pressure

- action: Check filesystem usage.

```bash
df -h
```

- why this step matters: Full filesystems can prevent services from starting, writing cache files, writing logs, or completing normal application work.
- what the result suggests:
  - Filesystem is full or nearly full -> identify the large path before taking action.
  - Filesystem has enough free space -> continue with service, port, config, or dependency findings.

### Step 7 — Identify large directories if disk pressure is present

- action: Check directory usage for the affected filesystem.

```bash
du -h --max-depth=1 [path]
```

- why this step matters: Disk cleanup should be based on evidence.
- what the result suggests:
  - Old approved logs are consuming space -> follow the approved cleanup procedure if in scope.
  - Unknown application data, database files, container files, or unapproved files are consuming space -> escalate before deleting anything.

### Step 8 — Decide resolution or escalation

- action: Decide whether support has enough evidence and authority to resolve the issue or escalate it.
- why this step matters: The goal is to resolve what is safely in scope and escalate what needs another team.
- what the result suggests:
  - Clear in-scope fix is found -> apply the approved fix and verify service/application recovery.
  - Cause is outside support scope or unsafe to change -> escalate with service status, logs, port checks, reachability results, and resource findings.

## Related Tooling

`evidence-collect.sh` can be used to collect first-pass Linux service and reachability evidence.

Useful when the case needs:

- service status
- recent journal logs
- listening ports
- routing table
- target name resolution
- target IP reachability
- target URL reachability

Example:

```bash
./evidence-collect.sh -s [service-name] -e [application-url] -i [target-ip]
```

This script supports evidence collection. It should not replace support judgment or the decision to resolve versus escalate.

## Escalation Points

- Service fails and logs show a dependency, database, infrastructure, or application code issue -> escalate to the owning application or infrastructure team.
- Service is active but the expected port is not listening, and the cause is not clear from logs -> escalate with service, log, and port evidence.
- Application responds with repeated 500, 502, or 503 errors -> escalate with response details and relevant logs.
- Filesystem is full because of unknown application data, database files, container files, or unapproved cleanup targets -> escalate before deleting anything.
- Required config changes are outside support authority -> escalate to the owning team.
- The issue continues after the approved support action is completed -> escalate with all checks and findings documented.

## Required Documentation

- Exact user-facing symptom
- Scope and impact
- Affected host, service, and application URL if known
- Service status result
- Relevant journal log findings
- Application reachability result
- Listening port findings
- Disk or resource findings if checked
- Actions taken
- Reason for resolution or escalation
- Verification result or escalation handoff

## Notes

A Linux service issue should be checked in layers.

A service being active does not always mean the application is healthy. The service process may be running while the application fails to bind to the expected port, cannot reach a dependency, or cannot complete startup.

A useful first-pass pattern is:

1. Confirm the symptom and scope.
2. Check service state.
3. Review logs.
4. Test application reachability.
5. Check listening ports.
6. Check resource pressure if the evidence points that way.
7. Resolve only if the fix is clear and in scope.
8. Escalate with evidence when the cause or fix belongs to another team.

The main skill this runbook trains is separating service state from application availability. The second skill is knowing when evidence is strong enough to act, and when it is stronger to escalate cleanly.
