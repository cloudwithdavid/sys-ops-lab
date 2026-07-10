# Policy Blocked Sign-In

> "I’m trying to log into the order tracking portal from my laptop and it keeps blocking me. My password works and I approved the MFA prompt, but it still says I don’t meet the security requirements."

## Summary

User cannot access the order tracking portal after completing password and MFA authentication.

## Issue

Single user is unable to access the order tracking portal. The user reports that password entry succeeds and MFA is approved, but sign-in is blocked post-authentication with a message indicating a security or access policy requirement is not met.

The block appears to occur after the authentication steps complete, not during them. Root cause is not yet confirmed; issue may involve an access policy condition the user's device or session does not satisfy.

## Hypotheses

1. An access policy is blocking access because the device is not compliant or not recognized as managed
2. An access policy is blocking access because the sign-in originated from an untrusted location or network
3. An access policy is blocking access because the session does not meet an additional requirement such as an approved application or browser
4. The user's account may have a security restriction or administrative flag separate from the access policy
5. The access policy was recently changed or a new policy was applied that the user's setup does not satisfy

## Checks

1. Check account status in the identity/admin portal  
   _**Finding:**_ Account is active, not locked, not disabled. No admin restriction or flag is present. Account state is not the cause.

2. Review sign-in logs of the affected user  
   _**Finding:**_ Logs confirm successful password authentication and MFA approval. Sign-in is blocked by an access policy. The blocking policy and unsatisfied condition are visible in the log entry.

## Verification

- Account is active, not locked, and not disabled
- Password and MFA succeeded according to sign-in logs
- Access was blocked by an access policy

## Escalation

> Ticket escalated to the IAM/security team with confirmed findings, the blocking policy name, and the unsatisfied condition documented for their review.

Confirmed the block is post-authentication and account state is not the cause. Sign-in logs confirm an access policy is enforcing a condition the user's session does not satisfy.

Blocking policy: 'Require compliant device for Order Tracking Portal'
Unsatisfied condition: Device not marked compliant or managed

Access policy changes/exceptions require IAM/security review. Escalating with sign-in log findings.

## Prevention

When a user reports sign-in failure after password and MFA succeed, check sign-in logs before assuming a credential or account issue. A post-authentication block with a policy message points to an access policy issue, not a password or lockout issue.

## Debrief

Access policies are security controls. Recognizing that boundary and escalating cleanly with enough information that the IAM team can act without re-doing first-line triage is the correct outcome, not a failure to resolve.
