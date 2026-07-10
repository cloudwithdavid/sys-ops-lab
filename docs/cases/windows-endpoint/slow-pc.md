# Troubleshooting a Slow PC

## Summary

User reports generally slow PC performance on their endpoint.

## Issue

Single user reports their PC is running slowly. It is not yet clear whether
the issue is process-specific, storage-related, or a broader system problem.

## Hypotheses

1. One or more processes are consuming abnormal CPU, memory, or disk resources
2. Too many startup or background applications are degrading baseline performance
3. Disk pressure or storage-related slowdown is degrading performance
4. Device requires a OS update

## Checks

1. Open Task Manager and review CPU, memory, and disk usage  
   _**Finding:**_ Memory usage is near 100% while Disk and CPU are normal

2. Identify whether one process or a group of processes is responsible for the high memory usage  
   _**Finding:**_ Browser and editing applications are consuming the majority
     of available memory. No single runaway process — high usage reflects
     active workload.

3. Review startup applications and their startup impact rating  
   _**Finding:**_ No abnormal startup applications present. Startup impact
     is not a contributing factor.

4. Check available disk space  
   _**Finding:**_ Sufficient disk space available. Storage pressure is not
     a contributing factor.

## Resolution

Memory usage was confirmed as the bottleneck. High memory was caused by
the user running multiple browser windows and editing applications
simultaneously, not by a malfunctioning process or system issue. The user
was advised to reduce concurrent browser tab and application load.
Unnecessary browser processes were closed, which brought memory usage down
to a normal operating range.

> The issue was user-driven resource consumption, not a system
fault. Escalation would be appropriate if memory usage remained critically
high with no heavy processes running, or if the issue persisted after
reducing workload.

## Verification

Confirmed memory usage dropped to a normal level after closing unnecessary
browser processes. User confirmed system responsiveness improved.

## Prevention

Avoid running excessive browser tabs and memory-heavy applications
simultaneously. Close applications that are not in use when performance
starts to degrade.

## Debrief

Separate CPU, memory, and disk bottlenecks early, then identify whether the issue is one heavy process or general workload pressure. Once memory was confirmed as the issue, the next
question was whether a single process was malfunctioning or whether the
load was user-driven.

Not every slow PC is a hardware or software fault. Recognizing workload
pressure as a cause prevents unnecessary escalation or replacement
recommendations.
