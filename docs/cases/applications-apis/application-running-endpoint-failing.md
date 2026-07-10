# Application Running, Endpoint Failing

User report:
> “The PartnerOps dashboard opens normally, and the status check still says the service is healthy, but when I try to generate the partner activity report, the request fails with an internal server error. I checked the URL from our saved request and it looks right. I’m not sure if the report endpoint is broken or if I’m hitting the wrong path.”

Ticket notes from the queue:
Ticket arrived at 10:42 AM after Jordan selected “API or integration issue.” The affected system in the case narrative is the PartnerOps API.

The next tech needs to reproduce the request, compare the response from the healthy endpoint against the failing endpoint, inspect logs/app.log, and document whether the app is broadly unavailable or whether one application route is failing.

## Summary

User reports PartnerOps application is reachable, but one report endpoint returns a server-side error.

## Issue

A user is unable to generate a partner activity report through the PartnerOps API. The broader application appears reachable, but the reported endpoint fails.

## Hypotheses

1. The PartnerOps API may be unavailable or unhealthy despite the dashboard appearing to load.
2. The saved report request may be pointing to the wrong endpoint path.
3. The report endpoint may be reachable but failing due to an endpoint-specific server-side error.

## Checks
<!-- markdownlint-disable MD029 -->
1. Check app reachability and response (with `curl -v http://localhost:8000/status -H "X-Request-ID: endpoint-status-001"`)  
   _**Finding:**_ Status endpoint returned `200 OK`, confirming the PartnerOps API is responding to requests.

2. Reproduced the failing report endpoint and checked the matching application log entry.  
   _**Finding:**_ The submitted report endpoint request reached the PartnerOps API but returned `500 Internal Server Error`. Matching logs show `status=500 reason=runtime_error`, indicating an endpoint-specific server-side failure rather than a full API outage.

```bash
$ curl -v http://localhost:8000/reports/partner-activity \
-H "X-Request-ID: endpoint-check-001"
...
< HTTP/1.1 500 Internal Server Error
< date: Sun, 07 Jun 2026 01:56:30 GMT
< server: uvicorn
< content-length: 42
< content-type: application/json
<
{"detail":"Server-side error"}* Connection #0 to host localhost:8000 left intact  
```

```bash
$ grep "endpoint-check-001" logs/app.log
...
2026-06-07T01:56:31Z level=ERROR endpoint=/reports/partner-activity status=500 reason=runtime_error request_id=endpoint-check-001
```

## Verification

- Confirmed the PartnerOps API status endpoint returned `200 OK`.
- Confirmed the submitted report endpoint returned `500 Internal Server Error`.
- Confirmed the matching application log entry showed `endpoint=/reports/partner-activity status=500 reason=runtime_error` with the same request ID.

## Escalation

Escalated to the application team.

The PartnerOps API is reachable and responds successfully to the status check, but the partner activity report endpoint returns `500 Internal Server Error`. Application logs confirm the request reached the API and failed during endpoint processing with `reason=runtime_error`.

Escalation details:

- Affected endpoint: `GET /reports/partner-activity`
- Status returned: `500 Internal Server Error`
- Request ID: `endpoint-check-001`
- Timestamp: `2026-06-07T01:56:31Z`
- Log reason: `runtime_error`
- Known-good comparison: `/status` returned `200 OK`

Application team review is needed to inspect the endpoint code path, related report-generation logic, and any backend errors not exposed in the support-facing log entry.

## Prevention

Improve logging for report endpoint failures so runtime errors include a more specific failure category, such as validation issue, missing data, dependency failure, query failure, or unhandled exception.

---
---
---

## Debrief

A web app can appear to 'open' because browser may i.e. load cached UI data making it appear as though the endpoint is working, while the actual API request required to load the data into the site failed.

Initial queue context says the user can reach the application and another health/status check appears normal, so this should not be treated as a full outage by default.

The user has not checked application logs, compared the failing endpoint against a known-good endpoint, or confirmed whether this is a wrong URL path, endpoint-specific server error, or timeout behavior.

The `500` response and `runtime_error` log reason were enough to classify the issue as server-side, but not enough to identify the exact root cause. The correct outcome is not to guess the code bug. The correct outcome is to reproduce the failure, prove the app is otherwise reachable, capture the status code and log evidence, and escalate to the application team with a clear, bounded finding.

---

- Got a deeper understanding of APIs: define the rules for how clients interact with an application: routes/endpoints, resources the endpoints expose, allowed methods and input requirements, and responses/status codes returned.
- Learned `500`: ‘Internal Server Error’: very broad server error
- Learned `runtime_error` broadly points to a failure in the application’s code path
- Learned `404`: ‘Page Not Found’: the endpoint simply does not exist
- Practiced using `tail -f | nl` to watch live logs
- Practiced adding `X-Request-ID` headers.
- Practiced using `grep` to filter app logs.
