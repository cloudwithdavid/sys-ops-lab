# Mapped Network Drive Unavailable

> "My P drive is showing a red X and I can't open it... My internet is working fine and I can access Teams and Outlook."

## Summary

User's mapped network drive is unavailable.

## Issue

Single user cannot access mapped network drive P:\. Drive is showing as disconnected in Windows Explorer. User has confirmed internet access and other network-dependent applications such as Teams and Outlook are working. Issue appears limited to this user.

## Hypotheses

1. Drive mapping does not exist or points to incorrect path
2. Device is unable to resolve file servers hostname
3. User's credentials are stale, expired, or broken
4. Device has lost domain connectivity or domain trust

## Checks

1. check queue and ask whether other users are affected
   - finding: No other tickets about `P:\`. Issue appears limited to single user.

2. Check driver mapping (with `net use`)
   - finding: `P:` shows as `Disconnected`, mapped to `\\fileserver\projects`. Driver mapping still exists and points to the correct path

3. Test file server hostname resolution (with `nslookup`)
   - finding: Hostname resolves correctly to a valid IP. DNS is not the issue

4. Check if user's credentials are stale, expired, or broken
   - finding: A stale saved credential entry for `\\fileserver` was present, tied to an older session token.

## Resolution

Stale saved credentials for the file server were preventing Windows from authenticating silently in the background. The stale entry was cleared from Credential Manager and user reconnected `P:\` using his current domain credentials. Drive is accessible and the mapping is healthy.

> Escalation would be appropriate if credentials appeared valid but access still failed, if the domain trust check showed the machine was off the domain, or if multiple users began reporting the same issue pointing toward a server-side problem.

## Verification

- Confirmed `P:\` shows status `OK` in `net use` output
- Confirmed user can browse and open files in the drive normally
- Confirmed report was completed on time

## Prevention

If mapped drives disconnect after a password change, clearing Credential Manager entries and remapping is the standard first step

## Debrief

For drive mapping to work, a few things need to be true simultaneously:

1. Network connectivity — the machine needs to be on the network and able to reach the file server. No connectivity, no drive.
2. Name resolution — the machine needs to be able to resolve the file server's hostname to an IP address. If DNS is broken, the path \\fileserver\projects goes nowhere.
3. Authentication — accessing a network share usually requires valid domain credentials. If the user's session credentials are stale, expired, or broken (for example after a password change or a session issue) Windows may be silently failing authentication in the background.
4. The mapping itself — the drive letter assignment needs to actually exist and point to the right path.
