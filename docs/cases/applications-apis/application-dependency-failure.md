# Application Dependency Failure

User report:
> “I’m trying to check whether the new partner billing sync is ready for today’s onboarding review, but the dependency check keeps failing. The main API health page still loads, so I don’t think the entire service is down. I’m not sure if the billing dependency is unavailable, if something changed in config, or if I’m checking the wrong thing.”

## Summary

User reports PartnerOps application is reachable, but one report endpoint returns a server-side error.

## Issue

User from the Partner Onboarding Team is unable to confirm billing sync readiness through the PartnerOps API. The general application status appears reachable, but the dependency check is failing.

## Hypotheses

1. The PartnerOps API may be generally unavailable or unable to serve normal requests.
2. The billing sync integration status endpoint may be failing while the broader PartnerOps API remains reachable.
3. The billing sync integration may be disabled or misconfigured through runtime configuration.
4. The application may require a service restart before an updated runtime configuration value takes effect.

## Checks
<!-- markdownlint-disable MD029 -->
1. Checked baseline PartnerOps API status with `/status`.  
   ***Finding:*** `/status` returned `200 OK`, confirming the API is reachable and able to serve normal status requests. The status response also showed the billing sync integration was currently disabled in runtime configuration.

2. Checked the billing sync integration status endpoint (with `curl -v https://partnerops.internal/integrations/billing-sync/status`).  
   ***Finding:*** The billing sync status endpoint returned `503 Service Unavailable`.

3. Reviewed application logs for the failed billing sync status request.  
   ***Finding:*** Logs showed the billing sync status request failed because the billing sync integration was disabled in runtime configuration.

4. Reviewed the PartnerOps API service environment configuration.
   ***Finding:*** The billing sync integration was disabled with `BILLING_SYNC_ENABLED=false`.

```bash
sudo systemctl cat partnerops-api
...
EnvironmentFile=/etc/partnerops/partnerops.env
...
grep '^BILLING_SYNC_ENABLED=' /etc/partnerops/partnerops.env
...
BILLING_SYNC_ENABLED=false
```

## Resolution

> **Action sequence:**
>
> 1. Updated the PartnerOps API runtime environment configuration from `BILLING_SYNC_ENABLED=false` to `BILLING_SYNC_ENABLED=true`.
> 2. Restarted the PartnerOps API service so the application loaded the updated environment variable.
> 3. Retested the billing sync integration status endpoint.
> 4. Asked the user to retry the billing sync readiness check from her onboarding workflow.

The PartnerOps API was reachable, but the billing sync integration status endpoint was returning `503 Service Unavailable` because the billing sync integration was disabled in runtime configuration. The billing sync configuration was corrected, the application service was restarted, and the user was able to confirm billing sync readiness from her onboarding workflow.

> Escalation would be required if the integration remained unavailable after the configuration correction and service restart, or if the runtime configuration change required application-owner approval.

## Verification

- Confirmed the PartnerOps API status endpoint still returned `200 OK`.
- Confirmed the billing sync integration status endpoint returned `200 OK` after the configuration update and service restart.
- Confirmed application logs no longer showed the billing sync integration as disabled.
- Confirmed the user was able to complete the billing sync readiness check successfully from her onboarding workflow.

---
---
---

## Debrief

A reachable application is not the same as a fully healthy application workflow.

The requester confirmed that the general PartnerOps API status page still responds, but the billing sync integration status check fails while validating readiness for the onboarding review. No one has confirmed whether the issue is limited to the billing sync integration path, caused by runtime configuration, or related to the application service loading an outdated configuration value. The next tech needs to compare general API status with the billing sync status endpoint, inspect the HTTP response, review application logs, and confirm the relevant service environment configuration.

A `503 Service Unavailable` means the server is temporarily unable to handle the request. It does not automatically prove a full application outage. The status endpoint, failing endpoint, logs, and runtime configuration had to be interpreted together.

```text
general API status works
→ billing sync status fails
→ logs point to disabled runtime configuration
→ configuration corrected and service restarted
→ user confirms the original workflow works again
```

---

- Learned `503`: ‘Service Unavailable’: indicates that a server is temporarily unable to handle requests; typically due to maintenance or dependency failure
- Practiced using `tail -f | nl` to watch live logs
- Practiced adding `X-Request-ID` headers.
- Learned `systemctl cat` shows how a systemd service is configured to start, including whether it loads environment variables from an environment file.
- Learned environment variables can change how an application behaves without changing the application source code.
