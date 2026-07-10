# Account Unlock

## Summary

User was signed out and can't access the application.

## Issue

Single user is unable to sign in to the application. Account state is not yet confirmed; issue may involve password, lockout, MFA, or another sign-in control.

## Hypotheses

1. User’s password is incorrect, expired, or needs to be reset
2. Account is locked due to failed sign-in attempts
3. Access issue is being caused by MFA or another sign-in requirement, not the password itself
4. Account is disabled or otherwise restricted in the identity system

## Checks

1. Confirm the exact symptom and any error shown  
   _**Finding:**_ User reports they cannot sign in and receives a message indicating the account is locked after repeated failed sign-in attempts.

2. Check account status in the admin/identity system  
   _**Finding:**_ Account is active but currently locked. No disabled state or separate admin restriction is shown.

## Resolution

Account lockout was confirmed in the identity/admin system. The account was unlocked so the user could sign in again. Likely cause was repeated failed sign-in attempts.

> Escalation not required. The issue was confirmed as a routine account lockout and was handled within first-line support scope. Escalation would be needed if the lockout happens again or if the account shows a security-related restriction.

## Verification

- Confirmed user could sign in successfully and access to the account was restored

## Prevention

- Document the likely cause of the lockout in the ticket for future reference
- If the lockout happens again, check for repeated incorrect password use, stale saved credentials, or another ongoing sign-in issue

## Debrief

This ticket was about understanding account lockout as a support issue. The important part was confirming lockout in the identity/admin system instead of assuming the user’s report was enough. It also showed that first line should document the likely cause of the lockout, not just the unlock itself. If lockouts keep happening, the case should move beyond a simple unlock and be investigated further.
