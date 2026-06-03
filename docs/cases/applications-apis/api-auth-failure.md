# API Auth Failure

User report:
> “Hi, I’m trying to pull partner account details from the internal API for this afternoon’s onboarding review, but the request keeps failing. The API URL looks right, and the app itself doesn’t seem down because another status page still loads. I’m not sure if my token expired, if I’m using the wrong one, or if I just don’t have access to this endpoint.”

Ticket notes from the queue:
Ticket arrived in the Applications & APIs queue after Maya selected “API or integration issue” in the service portal. In the case narrative, the affected system is the PartnerOps API. In the lab environment, the local FastAPI fixture represents the PartnerOps API.

The requester attached sanitized request details showing that her workflow was calling an admin-level endpoint with a standard bearer token. The next tech needs to reproduce the failure, compare the API response with application logs, and determine whether this is an authentication failure, authorization failure, or broader API availability issue.

## Summary

Protected API access is failing for a user trying to retrieve account data from an internal operations API.

## Issue

A user is unable to retrieve account data from a protected PartnerOps API endpoint. The API appears reachable, but the protected request is failing. The investigation needs to determine whether the request is missing authentication, using an invalid bearer token, using a valid token without the required authorization, calling the wrong endpoint, or reaching an unavailable API endpoint.

## Hypotheses

1. The request may be missing or sending an invalid bearer token.
2. The request may be using a valid token that lacks permission for the requested endpoint.
3. The requester may be using the wrong endpoint or an endpoint that requires a different access level.
4. The PartnerOps API may be unavailable or unhealthy.

## Checks

1. Reviewed the requester’s submitted API request details.  
_**Finding:**_ The workflow was calling the admin-level endpoint with a standard bearer token.

2. Reproduced the failing access path by testing `/admin` endpoint with a valid standard bearer token. (with `curl -v http://localhost:8000/admin -H "Authorization: Bearer demo-token" -H "X-Request-ID: api-auth-admin-denied-001"`)  
_**Finding:**_ Request returned `403 Forbidden`; logs showed `status=403 reason=insufficient_permissions`.

3. Tested the standard protected endpoint (`/secure`) with the same standard bearer token.  
_**Finding:**_ Request returned `200 OK`, confirming the token works for standard protected access.

4. Tested `/admin` with an admin bearer token (with `-H "Authorization: Bearer admin-token"`)  
_**Finding:**_ Request returned `200 OK`; logs showed `status=200 reason=admin_authorized`.

5. Tested `/secure` with no token and with an invalid token.  
_**Finding:**_ Both requests returned `401 Unauthorized`, confirming missing or invalid authentication is handled separately from insufficient authorization.

## Resolution

> **Action sequence:**
>
> 1. Updated users saved API request URL from the admin-level account endpoint to the standard protected account-data endpoint.
> 2. Left the existing standard bearer token in the `Authorization` header.
> 3. Saved the corrected request.
> 4. Retested the corrected request with `curl`.

Users bearer token was valid for standard protected API access, but her saved request was pointed at an endpoint that required admin-level authorization. The request URL was corrected to use the endpoint available to her access level. No token reset or admin permission change was required.

> Escalation would be required if the requester has a legitimate need for admin-level API access, if the standard endpoint does not support the required workflow, or if the corrected request still fails after using the proper endpoint.

## Verification

- Confirmed the user could retrieve the needed account data using the corrected request.
- Confirmed the original admin endpoint returned `403 Forbidden` with users standard bearer token.
- Confirmed the corrected standard endpoint returned `200 OK` with the same bearer token, and the application log matched the corrected successful request.

## Prevention

Document the correct PartnerOps API endpoint for standard account-data retrieval so users and integrations do not accidentally call the admin-level endpoint for non-admin workflows.

---
---
---

## Debrief

“I can’t access the API” should be narrowed before treating it as an outage.

The request may be:

1. missing credentials
2. using bad credentials
3. using valid credentials against the wrong endpoint
4. or trying to perform an action outside the requester’s permission level.

 The response status, response body, and application log reason are what separate those paths.

The PartnerOps API was reachable throughout the investigation. The important distinction was the type of access failure:

- 401 Unauthorized meant the request was not accepted as authenticated. This happened when the bearer token was missing or invalid.
- 403 Forbidden meant the request was authenticated, but not authorized for the requested endpoint. This happened when a valid standard token was used against /admin.
- 200 OK confirmed the endpoint worked when the request used the correct token and access level.

Authentication answers “is this request allowed to identify itself as a valid requester?” Authorization answers “is this valid requester allowed to do this specific action?”

In this case, the requester did not need a token reset or an admin permission change. The correct fix was to use the API endpoint that matched the requester’s existing access level.

Request IDs are useful when connecting client-side reproduction to server-side logs. In this case, `X-Request-ID` acted like a tracking number for a specific API request. The access decision still came from the bearer token and endpoint permissions, but the request ID made the evidence easier to match in the application logs.

---

DNS check:
Can the name be resolved?

Routing/reachability check:
Can I reach the host?

Port check:
Is the app’s port reachable/listening?

Service/process check:
Is the app process actually running behind that port?

HTTP/API check:
If the app responds, what status code/body comes back?

App log evidence:
Why did the app return that response?

---

**Reviewed in lesson:**

- `curl -v -H` to inspect request/response behavior with added headers like 'Authorization: Bearer <token>'
- `401` for missing or invalid authentication and `403` for "authenticated but not permitted"
- `/secure` as the protected user endpoint and `/admin` as the permission-sensitive endpoint
- `tail / tail -f` to inspect recent or live log entries with `logs/app.log` as the evidence source
- `grep` to filter logs by endpoint, status, reason, or request ID
- `X-Request-ID` to tie one client request to one log entry
