# Systems Operations Lab

## ℹ️ About

A case-based technical lab for practicing systems troubleshooting, incident-style investigation, CLI evidence gathering, log analysis, API health checks, and Bash/Python automation across Linux, networking, applications/APIs, and identity scenarios.

The lab uses realistic operational scenarios to practice moving from reported symptoms to hypotheses, checks, evidence, findings, and verification. The emphasis is on understanding how systems fail, gathering evidence with command-line tools, interpreting service and network behavior, and building small utilities that make investigation more repeatable.

## 🧪 What This Lab Demonstrates

### 🐧 Linux Services & Runtime Behavior

- Inspecting service state, process behavior, listening ports, permissions, logs, and runtime symptoms
- Practicing CLI-based diagnosis with tools such as `systemctl`, `journalctl`, `ss`, `curl`, routing checks, and filesystem inspection
- Connecting Linux command usage to real service/application failure modes

### 🌐 Networking & Connectivity Diagnosis

- Troubleshooting DNS resolution, host reachability, routing, port access, and service availability
- Practicing network-path reasoning with tools such as `dig`, `nslookup`, `ping`, `traceroute`, `ip route`, `curl`, `nc`, and `ss`
- Separating network reachability from application availability
- Building practical intuition for how DNS, routing, ports, and service listeners affect system behavior
<!--
### ☁️ Cloud Networking & Segmentation — Next Focus

- Planned AWS-focused scenarios for private DNS, private subnet egress, tier-to-tier connectivity, and network segmentation
- Practicing cloud network diagnosis with tools such as `dig`, `nslookup`, `getent hosts`, `curl`, `nc`, `ss`, `ip route`, `traceroute`, AWS CLI checks, and validation scripts
- Separating application failure from DNS, routing, NAT, security group, NACL, and service-listener issues
- Building practical intuition for public/private subnet design, Route 53 private hosted zones, NAT Gateway behavior, security-group source rules, and least-privilege network access
-->
### 🔌 Applications, APIs & Logs — In Progress

- Investigating HTTP/API behavior through status codes, auth failures, health checks, and application logs
- Practicing request/response inspection with `curl` and log review with `tail`
- Connecting API symptoms to service behavior, authentication/authorization signals, and log evidence

### 🔐 Identity, Access & Auth Signals

- Reviewing access-policy behavior, suspicious sign-in patterns, and authorization-related failures
- Connecting user impact to identity, policy, and security-relevant evidence
- Treating identity issues as systems behavior, not just account administration

### ⚙️ Automation & Diagnostic Utilities

- Building Bash and Python utilities for diagnostics, evidence collection, log summarization, API health checks, and repeatable investigation workflows
- Using automation to reduce repetitive manual checks and make troubleshooting output easier to review

## 📦 Artifacts

### 🎫 Featured Cases

Primary incident-style scenarios used to practice technical investigation, evidence gathering, troubleshooting, findings, and verification.
<!-- markdownlint-disable MD060 -->
|            |            |
| ---------- | ---------- |
|**Applications and APIs**| • [`api-auth-failure.md`](docs/cases/applications-apis/api-auth-failure.md)   |
|        **Linux**        | • [`service-running-application-unavailable.md`](docs/cases/linux/service-running-application-unavailable.md)<br> • [`repeated-application-errors.md`](docs/cases/linux/repeated-application-errors.md)<br> • [`service-will-not-start.md`](docs/cases/linux/service-will-not-start.md)<br> • [`permissions-blocking-access.md`](docs/cases/linux/permissions-blocking-access.md) |
|     **Networking**      | • [`dns-resolves-service-still-fails.md`](docs/cases/networking/dns-resolves-service-still-fails.md)<br> • [`host-reachable-application-unreachable.md`](docs/cases/networking/host-reachable-application-unreachable.md)<br> • [`invalid-default-route.md`](docs/cases/networking/invalid-default-route.md)<br> • [`dns-config-issue.md`](docs/cases/networking/dns-config-issue.md) |
|  **Identity & Access**  | • [`password-reset-access-loss.md`](docs/cases/identity-access/password-reset-access-loss.md)<br> • [`suspicious-login-report.md`](docs/cases/identity-access/suspicious-login-report.md)<br> • [`policy-blocked-sign-in.md`](docs/cases/identity-access/policy-blocked-sign-in.md)<br> • [`account-unlock-root-cause.md`](docs/cases/identity-access/account-unlock-root-cause.md) |
|  **Windows Endpoint**   | • [`application-install-blocked.md`](docs/cases/windows-endpoint/application-install-blocked.md)<br> • [`mapped-network-drive-unavailable.md`](docs/cases/windows-endpoint/mapped-network-drive-unavailable.md)<br> • [`no-internet-dns-failure.md`](docs/cases/windows-endpoint/no-internet-dns-failure.md) |
|    **Microsoft 365**    | • [`teams-desktop-sign-in-issue.md`](docs/cases/microsoft-365/teams-desktop-sign-in-issue.md)<br> • [`m365-license-assignment.md`](docs/cases/microsoft-365/M365-license-assignment.md) |

### 📋 Operational Guides & Technical Notes

Supporting documentation for repeatable investigation patterns and technical findings.

- [`linux-service-triage-runbook.md`](docs/runbooks/linux-service-triage-runbook.md) — first-pass investigation guide for Linux service state, logs, ports, reachability, and resource pressure.
- [`service-start-failure-kb.md`](docs/kb-articles/service-start-failure-kb.md) — technical note on Linux service startup failure caused by disk pressure.

### 🐚 Bash Scripts

Bash utilities for diagnostics, evidence gathering, and repeatable command-line investigation.

- [`evidence-collect.sh`](tools/bash/evidence-collect.sh) — reusable first-pass Linux evidence collection. Accepts an optional service name, URL, and/or IP address. Collects host, service, journal, port, routing, and reachability evidence, and writes results to a timestamped file.
- [`disk-triage.sh`](tools/bash/disk-triage.sh) — first-pass disk usage triage utility. Accepts a target path, usage threshold, and depth value. Reports filesystem usage, flags filesystems above the threshold, shows the target path size and largest entries, and can save results to a timestamped file.

### 🐍 Python Scripts

Python utilities for API checks, log analysis, and operational automation.

**Planned:**

- `api_health_check.py`
- `log_summary.py`

## 🗂️ Repository Structure

- [`docs/cases/`](docs/cases/) → troubleshooting cases
- [`docs/kb-articles/`](docs/kb-articles/) → technical notes
- [`docs/runbooks/`](docs/runbooks/) → operational guides
- [`tools/bash/`](tools/bash/) → Bash diagnostic utilities
- [`tools/python/`](tools/python/) → Python automation utilities
