# M365 License Assignment Issue

## Summary

User can’t access Outlook.

## Issue

Single user cannot access Outlook. It is not yet clear whether the issue is a local Outlook problem or a broader Microsoft 365 account-side access issue.

## Hypotheses

1. User cannot sign in because of credential, MFA, or account state issue
2. Outlook client or user profile is misconfigured or corrupted
3. User does not have the required Microsoft 365 license or service entitlement
4. Mailbox or account-side Outlook service is not available or not properly provisioned

## Checks

1. Confirm exact symptom and any error shown
    - finding: user can sign in elsewhere

2. Confirm whether the issue is Outlook only or other M365 apps too
    - finding: Teams access is also affected

3. Check account and license state in the admin portal
    - finding: required Exchange or M365 license/service is missing

## Resolution

User already had a Microsoft 365 license assigned, but the service needed for Outlook access was not enabled. The required service was enabled in the admin portal and the user was then able to access Outlook again.

> Escalation would be appropriate if license changes are outside first-line scope, no valid license is available to assign, licensing appears correct but access is still failing, or similar Outlook access issues are affecting multiple users.

## Verification

Confirmed user could access Outlook successfully after the license change was applied.

## Prevention

If similar access issues happen again, check whether the user’s M365 license and required services are assigned before treating it as a local Outlook issue.

## Debrief

Once multiple M365 apps are affected, the case shifts away from a local app problem and toward account-side access, and an Outlook access complaint can actually be an account/service entitlement issue rather than an application issue.
