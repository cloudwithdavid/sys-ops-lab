# Teams Desktop Sign-In Issue

> "Teams desktop won't let me sign in. Keeps looping back to the sign-in screen. I can sign into Outlook online fine so my password works. Tried closing and reopening..."

## Summary

User cannot sign into Teams desktop application

## Issue

User's Teams desktop application stuck at sign-in screen, not allowing the user to sign-in to their account.

## Hypotheses

1. Teams application is unresponsive
2. Teams app token cache is corrupted or stale
3. Teams desktop or M365 service is experiencing an issue affecting desktop client authentication

## Checks

1. Confirmed credentials are valid and account is active
   - finding: User is able to sign-in to other M365 applications

2. Check if anyone else is experiencing the same issue
   - finding: No other users are reporting Teams desktop sign-in issues

3. Assess likely cause based on confirmed findings
   - finding: Credentials valid, account healthy, issue is single-user and desktop-specific, points to corrupted or stale token cache identified as most likely cause

## Resolution

> **Action Sequence:**
>
> 1. Confirmed Sofia could access Teams Web in her browser and had a fallback path for her meeting before proceeding with the fix
> 2. Fully quit Teams
> 3. Navigate to and delete cache contents in %appdata%\Microsoft\Teams in File Explorer or the Run dialog
> 4. Relaunch Teams and sign in fresh

Team desktop application was not allowing user to sign in due to corrupted token cache. Deleted cache contents and user succesfully loaded and re-signed into their Teams desktop application.

## Verification

Confirmed endpoint can successfully load and sign-in to Teams desktop application.

## Prevention

If a user reports a Teams desktop auth loop, check whether other M365 apps are accessible first. If they are, go straight to cache clear before trying anything else.

## Debrief

The process of applications opening directly into your account and your device — the application stores authentication tokens in a cache. Therefore, an authentication loop strongly points to a corrupted token cache — the application attempts to sign-in, fails, and retries, in a loop.

Outlook Web working tells you the account was healthy and narrows the problem to the desktop client specifically before running a single check.
