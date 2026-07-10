# Repeated Application Errors

> "Dockline keeps showing an error when I try to export docs. Sometimes it works, sometimes it doesn't. Yesterday it went totally blank and I had to reload the page."

## Summary

Single user unable to reliably access Dockline application.

## Issue

Single user reports receiving repeated errors and unreliable access when attempting to access Dockline application. Likely affecting multiple-users as the cause is server-side.

## Hypotheses

1. Application is generating repeated errors, causing log growth and disk pressure
2. Application is intermittently losing its connection to a backend dependency
3. Application process is crashing and restarting

## Checks
<!-- markdownlint-disable MD029 -->
1. Confirm Dockline application error  
   _**Finding:**_ Dockline application responding with 500 http status code error

2. Check service logs for errors (with `systemctl` and `journalctl`)  
   _**Finding:**_ Service is active and running, no crash or restart events in the journal

3. Check log file size (with `ls -lh`, `tail`, `grep`)  
   _**Finding:**_ Application log file `app.log` has grown to 4.2G and contains 14,382 'ERROR' entries, all reporting the same failure: `Export worker failed to write temp file: No space left on device`.

```bash
$ ls -lh /var/log/dockline/
-rw-r--r-- 1 dockline dockline 4.2G May 27 09:14 app.log
-rw-r--r-- 1 dockline dockline 1.1G May 26 00:00 app.log.1

$ tail -n 100 /var/log/dockline/app.log
...
[2026-05-27 09:11:43] ERROR: Export worker failed to write temp file: No space left on device
[2026-05-27 09:12:01] ERROR: Export worker failed to write temp file: No space left on device
[2026-05-27 09:12:18] ERROR: Export worker failed to write temp file: No space left on device

$ grep -c "ERROR" /var/log/dockline/app.log
14382
```

4. Check filesystem and log directory usage (with `df` and `du`)  
   _**Finding:**_ `/var` filesystem is at 99% capacity. `/var/log/dockline/` is consuming
     5.3G, making it the primary source of disk pressure.

```bash
$ df -h
Filesystem      Size  Used Avail Use%  Mounted on
/dev/sda1        20G   19G  200M   99% /var

$ du -h --max-depth=1 /var/log/
5.3G    /var/log/dockline
512M    /var/log/apt
   ...
```
  
## Verification

- Confirmed log overgrown with application error
- Confirmed log overgrowth causing disk pressure

## Escalation

Escalated to Dockline application team.

Application log file checks show the filesystem is the cause of 99% capacity disk pressure due to repeated error reports filling the log, causing the application to be intermittently unreliable. Error shown: 'Export worker failed to write temp file: No space left on device'.

## Prevention

Configure log rotation for Dockline so log files are rotated and old logs are pruned automatically rather than growing unbounded

## Debrief

Unreliable access logically doesn't cleanly fit DNS/port/routing config issues. Everything ive learned thus far about application failure through the lens of networking hasnt taught me what issue an 'unreliable access' symptom could possibly point to.

Intermittent failure means something is changing, being consumed, fluctuating, or conditionally triggered.

Intermittent failure combined with an application recieving repeated errors can point toward resource exhaustion; because repeated errors drive log growth.

I was confusing service/journal logs with the application logs found in applications log directory. Service logs / journal logs are what journalctl reads. Application logs are what the application writes to its own files under /var/log/dockline/. They're separate sources and the distinction matters.
