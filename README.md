# Support Engineering Lab

## ℹ️ About

This is a support engineering lab focused on operations and automation, built around **simulated** support case handling and support-oriented Bash and Python tooling.

The lab develops structured troubleshooting judgment, practical CLI fluency, documentation clarity, and operational scripting that make support work more technical and repeatable.

## 🧪 Lab Coverage

### 🔎 Support Case Handling

- structured triage and troubleshooting across Linux, networking, identity, and endpoint domains
- CLI-driven evidence gathering to isolate and document real issue patterns
- support documentation (tickets, KB articles, and runbooks) that captures reasoning, findings, and escalation decisions in reusable form

### ⚙️ Support-Oriented Tooling

- Bash and Python scripts that automate evidence collection, health checks, log analysis, and connectivity across real troubleshooting scenarios
- Tools built to reduce repetitive manual work and produce ticket-ready output

## 📦 Artifacts

### 🎫 Support Cases

Primary case-handling records used to practice issue framing, triage, troubleshooting, resolution versus escalation decisions, and documentation.
<!-- markdownlint-disable MD060 -->
|            |            |
| ---------- | ---------- |
|**Applications and APIs**|   |
|        **Linux**        | • [`service-running-application-unavailable.md`](docs/cases/linux/service-running-application-unavailable.md)<br> • [`repeated-application-errors.md`](docs/cases/linux/repeated-application-errors.md)<br> • [`service-will-not-start.md`](docs/cases/linux/service-will-not-start.md)<br> • [`permissions-blocking-access.md`](docs/cases/linux/permissions-blocking-access.md) |
|     **Networking**      | • [`dns-resolves-service-still-fails.md`](docs/cases/networking/dns-resolves-service-still-fails.md)<br> • [`host-reachable-application-unreachable.md`](docs/cases/networking/host-reachable-application-unreachable.md)<br> • [`invalid-default-route.md`](docs/cases/networking/invalid-default-route.md)<br> • [`dns-config-issue.md`](docs/cases/networking/dns-config-issue.md) |
|  **Identity & Access**  | • [`password-reset-access-loss.md`](docs/cases/identity-access/password-reset-access-loss.md)<br> • [`suspicious-login-report.md`](docs/cases/identity-access/suspicious-login-report.md)<br> • [`policy-blocked-sign-in.md`](docs/cases/identity-access/policy-blocked-sign-in.md)<br> • [`account-unlock-root-cause.md`](docs/cases/identity-access/account-unlock-root-cause.md) |
|  **Windows Endpoint**   | • [`application-install-blocked.md`](docs/cases/windows-endpoint/application-install-blocked.md)<br> • [`mapped-network-drive-unavailable.md`](docs/cases/windows-endpoint/mapped-network-drive-unavailable.md)<br> • [`no-internet-dns-failure.md`](docs/cases/windows-endpoint/no-internet-dns-failure.md)<br> • [`slow-pc.md`](docs/cases/windows-endpoint/slow-pc.md) |
|    **Microsoft 365**    | • [`teams-desktop-sign-in-issue.md`](docs/cases/microsoft-365/teams-desktop-sign-in-issue.md)<br> • [`m365-license-assignment.md`](docs/cases/microsoft-365/M365-license-assignment.md) |

### 📚 KB Articles

Reusable references that document repeatable issue patterns for future support work.

- [`no-internet-dns-failure.md`](docs/kb-articles/no-internet-dns-failure.md)
- [`password-reset-access-loss.md`](docs/kb-articles/password-reset-access-loss.md)
- [`service-start-failure-kb.md`](docs/kb-articles/service-start-failure-kb.md)

### 📋 Runbooks

Stepwise operational guides that standardize repeated support workflows and escalation logic.

- [`linux-service-triage-runbook.md`](docs/runbooks/linux-service-triage-runbook.md)
- [`identity-sign-in-triage-runbook.md`](docs/runbooks/identity-sign-in-triage-runbook.md)

### 🐚 Bash Scripts

Bash scripts used to reduce repetitive manual troubleshooting work.

- [`evidence-collect.sh`](tools/bash/evidence-collect.sh) — reusable first-pass Linux evidence collection. Accepts an optional service name, URL, and/or IP address. Collects host, service, journal, port, routing, and reachability evidence, and writes results to a timestamped file.
- [`disk-triage.sh`](tools/bash/disk-triage.sh) — first-pass disk usage triage utility. Accepts a target path, usage threshold, and depth value. Reports filesystem usage, flags filesystems above the threshold, shows the target path size and largest entries, and can save results to a timestamped file.

### 🐍 Python Scripts

Python scripts used to automate support and troubleshooting tasks.

**Planned:** `bulk_connectivity_check.py`

## 🗂️ Repository Structure

- [`docs/cases/`](docs/cases/) → simulated support cases
- [`docs/kb-articles/`](docs/kb-articles/) → KB articles for repeatable issue patterns
- [`docs/runbooks/`](docs/runbooks/) → runbooks for repeatable support workflows
- [`tools/bash/`](tools/bash/) → Bash scripts for common support and troubleshooting tasks
- [`tools/python/`](tools/python/) → Python scripts for common support and troubleshooting tasks
<!--
- [`tools/samples/`](tools/samples/) → sample files used for script testing
-->
