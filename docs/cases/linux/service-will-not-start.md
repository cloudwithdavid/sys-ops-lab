# Lantern Service Will Not Start

## Summary

User reports that Lantern dashboard is not running.

## Issue

User reports the Lantern internal dashboard is unavailable. The issue appears to affect the service behind the dashboard rather than a single user session or browser issue.

## Hypotheses

1. The Lantern hostname or URL may not be resolving or routing correctly
2. The backend system that supports Lantern may be down, unhealthy, or not responding
3. There may be planned maintenance, a recent change, or a known incident affecting Lantern

## Checks

1. Confirm whether the issue is limited to the reporting user  
    _**Finding:**_ Multiple support staff are unable to load the Lantern dashboard, so the issue does not appear to be user-specific.

2. Check the Lantern service status with `systemctl status`  
    _**Finding:**_ The service is loaded but in a failed state, with an exit-code failure.

3. Review service logs with `journalctl -u`  
    _**Finding:**_ Logs show the service cannot write its startup cache because there is no space left on device.

4. Check filesystem usage with `df -h`  
   _**Finding:**_ The `/var` filesystem is full, leaving no usable space for the service to write startup/cache files.

5. Check directory usage with `du -h --max-depth=1 [path]`  
   _**Finding:**_ `/var/log/lantern` is using most of the space under `/var`.

> **Related Tooling**
>
> [`evidence-collect.sh`](../../../tools/bash/evidence-collect.sh) supports this case by collecting first-pass Linux evidence that matches checks 2 and 3:
>
> - service status with `systemctl status`
> - recent service logs with `journalctl -u`
>
> [`disk-triage.sh`](../../../tools/bash/disk-triage.sh) supports this case by collecting filesystem disk usage that maches checks 4 and 5:
>
> - filesystem usage with `df -h`
> - target path size and largest entries with `du`
>
> In this case, the journal logs and filesystem usage output would quickly point toward disk pressure as the likely cause.

## Resolution

> **Action sequence:**
>
> 1. Inspect `/var/log/lantern` using `ls -lh` -> (viewed multiple old log files along with newer log files)
> 2. Remove old logs using `sudo rm /var/log/lantern/lantern.log.?.gz`
> 3. Recheck available space using `df -h` -> (disk space has increased)
> 4. Start service again using `sudo systemctl start lantern-status.service`, and check service status again using `systemctl status lantern-status.service` -> (service status shows 'Active: active')
> 5. Verify dashboard reachability using `curl` -> (lantern responds normally again)

Old rotated Lantern logs under `/var/log/lantern/` were consuming most of the available space under `/var`. Approved old rotated logs were cleared according to the support cleanup procedure, which restored usable space on the filesystem. After space was restored, `lantern-status.service` was started successfully.

> The issue was isolated to old rotated Lantern logs filling `/var/log/lantern`, which was safe to clear according to the support cleanup procedure. Escalation would be needed if the space was consumed by unknown application data, database/container files, unapproved log cleanup, or if the service still failed after space was restored.

## Verification

Confirmed `/var` had usable free space after cleanup. Verified `lantern-status.service` was active/running and the Lantern dashboard loaded normally for support staff.

## Prevention

Review Lantern log rotation and retention settings so old service logs do not continue filling `/var`.

## Debrief

- An application unavailable for multiple users points toward a shared system-side problem, and one important issue to check is backend service health.
- CLI tools like `systemctl` and `journalctl` can be used to investigate service state and logs, while tools like `df` and `du` can be used to locate disk space issues.
