# Canva Desktop Application Install Blocked

## Summary

User cannot install the Canva desktop app on their company Windows laptop.

## Issue

User reports that the Canva desktop app installation is blocked on their company Windows laptop. The installer asks for administrator credentials, which the user does not have.

> Root issue may involve UAC, standard user permissions, software approval, endpoint security policy, or an installer-specific problem.

## Hypotheses

1. The Canva installer requires administrator permissions to complete installation.
2. The user is using a standard company account without local admin rights.
3. The application may require software approval before it can be installed.
4. Endpoint security or application control may be blocking the installer.
5. The installer may be failing due to a compatibility issue or installer-specific error.

## Checks

1. Confirm the exact installation prompt or error message
   - finding: User provided a screenshot showing Windows UAC prompting for administrator credentials during Canva Desktop installation.

2. Confirm the affected device from the ticket
   - finding: Ticket is associated with the user’s assigned company Windows laptop.

3. Confirm the application, installer source, and business need
   - finding: User is attempting to install Canva Desktop from the vendor website for work on a marketing campaign asset.

4. Check approved software portal
   - finding: Canva Desktop is not listed as an available self-service install option.

5. Review internal software install support guidance
   - finding: First-line support cannot approve or install applications that are not available through the approved software portal and require administrator elevation.

## Verification

Verified that the user is attempting to install Canva Desktop on their assigned company Windows laptop, that the installer prompts for administrator credentials, and that Canva Desktop is not available through the approved company software portal.

## Escalation

> The install was not completed by first-line support. The issue was confirmed as an application install request requiring administrator elevation, and the application was not available through the approved company software portal. The ticket was prepared for escalation to the Endpoint/Admin team for software approval or authorized installation.

Escalated to the Endpoint/Admin team because the application requires administrator elevation, is not available through the approved software portal, and first-line support is not authorized to approve or perform non-portal software installs.

## Prevention

Users should be directed to check the approved company software portal before downloading public installers. If required software is not listed, users should submit a software approval request with the app name, source, and business reason.

## Debrief

A blocked install in a managed environment is not always a malfunction. UAC prompts and standard user permission restrictions are intentional controls.

Recognizing when the system is working as designed versus when something is broken is key. First-line support's job here was to confirm the symptom, identify the policy boundary, document the business need, and escalate cleanly.
