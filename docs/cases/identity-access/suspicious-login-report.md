# Suspicious Login Report

> "I got an MFA prompt I didn't request this morning at the airport and then a Microsoft security alert saying my account was logged into from the Netherlands while I was on a flight. I did not log in from the Netherlands. I'm worried someone has access to my account."

## Summary

User reported an unexpected MFA prompt followed by a Microsoft security alert for a sign-in from the Netherlands that she did not authorize.

## Issue

Single user reported a possible unauthorized Microsoft 365 sign-in. The user received an MFA prompt she did not initiate and later received a security alert showing account access from the Netherlands while she was on a flight. The user confirmed she did not sign in from that location. Potential account compromise cannot be ruled out and immediate containment is required.

## Hypotheses

1. A threat actor obtained the user's credentials and attempted or completed sign-in from an external location
2. The unexpected MFA prompt may have been caused by an unauthorized sign-in attempt
3. The sign-in alert may be caused by a legitimate but unexpected source, such as VPN or background session behavior
4. The user's credentials were exposed in a breach or phishing event prior to this incident

## Checks

1. Review sign-in logs in the identity/admin portal
   - finding: Logs show a successful sign-in from a Netherlands-based IP address during the window the user was in the air. Authentication details show the sign-in completed successfully.
   > The exact method used to satisfy or bypass the expected MFA requirement requires security review.

2. Check whether any account changes occurred post sign-in
   - finding: No mailbox rules, forwarding addresses, or admin role changes are visible. The suspicious sign-in appears to have accessed Microsoft 365 mailbox-related resources, based on the application shown in the sign-in logs.

3. Confirm the user's actual location and recent travel
   - finding: User confirms she was on a flight during the alert window and did not authorize any sign-in. She recalls declining an MFA prompt at the airport beforehand but is uncertain whether a second prompt appeared.

## Verification

- Password reset completed and confirmed
- All active sessions revoked in the identity portal
- User notified of containment actions taken
- Security team notified with sign-in log details, affected window, and containment actions already performed

## Escalation

> First-line scope ends at containment. Investigation of the breach vector, scope of mailbox access, and any downstream impact is owned by the security team.

Sign-in logs confirm a successful sign-in from an unrecognized external location during a period the user was unreachable. Mailbox access occurred. First-line containment steps were taken immediately: the user's password was reset, all active sessions were revoked, and the incident was escalated to the security/incident response team with full findings.

Containment completed: password reset and session revocation.
Confirmed unauthorized sign-in from an unrecognized location with mailbox access during a window the user cannot account for.

Escalated to the security/incident response team.

## Prevention

Unsolicited MFA prompt reports should be treated as potential compromise indicators and triaged promptly, not queued as standard access issues

## Debrief

Narrow but important scope: confirm the signal is real, contain immediately, and hand off cleanly.

Across the four identity cases, the reusable lesson is that similar sign-in complaints can point to very different support paths. **The authentication flow usually provides the biggest clue:**

- Pre-auth means credentials, account state, or lockout.
- Post-auth means policy, compliance, or a control above support scope.
- Compromise signal means contain before you investigate anything else.
