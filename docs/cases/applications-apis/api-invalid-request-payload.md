# API Invalid Request Payload

User report:
> “I’m trying to create a note through the internal Notes API for a customer onboarding handoff, but every request keeps coming back as a bad request. The API URL looks right, and I can reach other parts of the app, so I don’t think the whole service is down. I copied the JSON from an older example, but I’m not sure if the body is missing something or if the format changed.”

Ticket notes from the queue:
Ticket arrived in the Applications & APIs queue after the requester selected “API or integration issue” in the service portal. The affected system is the Partner Notes API. The requester attached sanitized request details for a note creation request. The request appears to target the correct note creation endpoint, but the submitted JSON payload may be incomplete.

## Summary

Client note creation requests are failing because the Notes API is rejecting submitted payloads.

## Issue

User is unable to create customer handoff notes through the Partner Notes API. The endpoint appears reachable, but the note creation request is returning a bad request response.

## Hypotheses

1. The submitted JSON body is incomplete or does not match the expected note creation payload.
2. The user copied an outdated request example that no longer matches the expected request format.
3. The note creation endpoint may be failing independently of the submitted payload.

## Checks
<!-- markdownlint-disable MD029 -->
1. Reviewed and reproduced the requester’s submitted note creation request.
   ***Finding:*** The request was using the note creation endpoint and included `Content-Type: application/json`, but the submitted JSON body only included `title` and did not include the required `body` field. `POST /notes` returned `400 Bad Request`, and application logs confirmed `reason=missing_required_field:body`.

```bash
$ curl -v http://localhost:8000/notes \
  -H "Content-Type: application/json" \
  -H "X-Request-ID: invalid-payload-missing-body-001" \
  -d '{"title":"Customer handoff note"}'

...
< HTTP/1.1 400 Bad Request
< content-type: application/json
<
{"detail":"Missing required field: body"}   
```

```bash
$ grep "invalid-payload-missing-body-001" logs/app.log

2026-06-05T21:40:17Z level=WARNING endpoint=/notes status=400 reason=missing_required_field:body request_id=invalid-payload-missing-body-001
```

2. Reproduced the submitted note creation request with the incomplete payload.
   ***Finding:*** Corrected `POST /notes` request returned `201 Created` when the JSON payload included both required fields, `title` and `body`. Application logs confirmed `reason=note_created` with the matching request ID.

```bash
$ curl -v http://localhost:8000/notes \
-H "Content-Type: application/json" \
-H "X-Request-ID: invalid-payload-valid-request-001" \ 
-d '{"title":"Customer handoff note","body":"This is a customer handoff note."}' 
...
< HTTP/1.1 201 Created 
< content-type: application/json
<
< {"id":"note-demo-1","title":"Customer handoff note","body":"This is a customer handoff note."}  
```

```bash
$ grep "invalid-payload-valid-request-001" logs/app.log

[timestamp] level=INFO endpoint=/notes status=201 reason=note_created request_id=invalid-payload-valid-request-001
```

## Resolution

> **Action sequence:**
>
> 1. Updated the requester’s saved note creation request body to include both required fields: `title` and `body`.
> 2. Retested the corrected request against the note creation endpoint.
> 3. Asked the user to retry the customer handoff note creation workflow using the corrected request format.

The requester’s note creation request was being rejected because the submitted JSON payload was incomplete. The request body only included `title` and was missing the required `body` field. After the request body was corrected, the Partner Notes API accepted the request and created the note successfully.

> Escalation would be required if corrected payloads still failed, if the API contract was unclear or undocumented, or if users need guidance from the application team on a changed request schema.

## Verification

Confirmed the user was able to create the customer handoff note using the corrected request format.

## Prevention

Update the shared Partner Notes API request example so users include both required fields and valid JSON formatting when creating customer handoff notes.

---
---
---

## Debrief

A `400 Bad Request` does not automatically mean the API is down.

API/endpoint is reachable  
→ `POST /notes` receives the request  
→ JSON request body is invalid  
→ logs explain the rejection reason  
→ corrected JSON returns `201 Created`

---

Learned `405`: 'Method Not Allowed': the endpoint exists, but the HTTP method is not supported for that route.
Learned that endpoints can be programmed for specific methods, such as `GET` or `POST`.
Learned `400`: 'Bad Request': the server received the request, but something about the request was invalid.
Learned that plain `curl` sends a `GET` request by default.
Learned that `curl -X` tells `curl` which HTTP method to use.
Practiced adding a `Content-Type` header: `Content-Type application/json`.
Practiced sending JSON data in the request body with `curl -d`; `-d` means `--data`.
Practiced adding `X-Request-ID` headers.
Learned the basic curl URL shape: `scheme://host:port/endpoint`.
Practiced using `grep` to filter app logs.
Practiced using `tail -f` to watch live app logs.
