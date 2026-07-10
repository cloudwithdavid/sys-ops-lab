# Tier-to-Tier Connectivity Blocked

> **Lab-derived case:** Adapted from completed work in the [Learn to Cloud Networking Lab](https://github.com/learntocloud/networking-lab). This case file documents the completed investigation and contains lab spoilers.

User report:
> "The web frontend suddenly can't connect to the API backend. We're getting connection refused errors on port 8080. The API health endpoint works when we curl localhost on the API server itself, so the service is running. Also, the API team says they can't reach the database on port 5432."

## Summary

Web-to-API and API-to-database connectivity failed across application tiers.

## Issue

The web server cannot connect to the API backend on the expected application port, even though the API service runs locally on the API server. The API server also cannot reach the database on the expected database port, suggesting a tier-to-tier network connectivity issue between application layers.

## Hypotheses

1. The API or database service may not be listening on the expected port or reachable interface.
2. Web-to-API traffic may be blocked by missing firewall/security group rules.
3. API-to-database traffic may be blocked by missing firewall/security group rules.
4. A subnet-level network control, such as a NACL, may be blocking database traffic even if service and security group checks look correct.

## Checks

1. Confirmed the API service was running locally on the API server (with `curl http://localhost:8080`).  
   _**Finding:**_ The API health endpoint responded locally. The API service was running on the server.

2. Tested web-to-API connectivity from the web server to the API server on TCP `8080` (with `nc -zv -w 5 <api-private-IP> 8080`).  
   _**Finding:**_ The connection failed, confirming traffic from the web tier could not reach the API tier.

3. Checked the API server listening ports (with `ss -tunl`).  
   _**Finding:**_ The API server was listening on `0.0.0.0:8080`. The API process was bound to the expected port and address.

4. Tested API-to-database connectivity from the API server to the database server on TCP `5432` (with `nc -zv -w 5 <database-private-IP> 5432`).  
   _**Finding:**_ The connection timed out, confirming traffic from the API tier could not reach the database tier.

5. Checked the database server listening ports (with `ss -tunl`).  
   _**Finding:**_ The database server was listening on `0.0.0.0:5432`. The database process was bound to the expected port and address.

6. Reviewed the web, API, and database security group rules (with `aws ec2 describe-security-groups`).  
   _**Finding:**_ The web security group did not allow egress to the API security group on TCP `8080`. The API security group did not allow ingress from the web security group on TCP `8080` and did not allow egress to the database security group on TCP `5432`. The database security group needed a specific ingress path from the API security group on TCP `5432`.

7. Confirmed the database instance had the expected security group attached (with `aws ec2 describe-instances`).  
   _**Finding:**_ The database instance used the expected database security group, so the remaining failure was not caused by inspecting or modifying the wrong security group.

8. Reviewed the database subnet NACL (with `aws ec2 describe-network-acls`).  
   _**Finding:**_ The database subnet NACL had an inbound deny rule for TCP `5432` with a lower rule number than the later allow rule. Because NACL rules are evaluated in order, the deny rule blocked the database connection before the allow rule could apply.

## Resolution

> **Action sequence:**
>
> 1. Added web security group egress to the API security group on TCP `8080` (with `aws ec2 authorize-security-group-egress`)
> 2. Added API security group ingress from the web security group on TCP `8080` (with `ec2 authorize-security-group-ingress`).
> 3. Added API security group egress to the database security group on TCP `5432`.
> 4. Added database security group ingress from the API security group on TCP `5432`.
> 5. Retested connectivity. Web-to-API succeeded, but API-to-database still failed.
> 6. Added a higher-priority NACL allow rule permitting database traffic from the API subnet before the existing deny rule (with `aws ec2 create-network-acl-entry`).
> 7. Retested web-to-API and API-to-database connectivity successfully.

The services were running and listening on the expected ports, but tier-to-tier connectivity was blocked by missing security group paths and a database subnet NACL rule order issue. Adding the required security group rules and correcting the NACL evaluation path restored web-to-API and API-to-database connectivity.

> Escalation would be required if production security group, database access, or NACL changes required network/security approval.

## Verification

- Confirmed web-to-API connectivity succeeded on TCP `8080`.
- Confirmed API-to-database connectivity succeeded on TCP `5432`.

## Debrief

This case forced a thorough path analysis.

The API and database were both listening on the expected ports, which shifted the investigation away from local service state and toward the network path. The first lesson was not to assume the firewall before checking the service.

Think in terms of source, destination, and port. For each tier-to-tier path, the source needed an egress rule and the destination needed an ingress rule.

Security group = instance/ENI-level, stateful, can use SG references
NACL = subnet-level, stateless, ordered by rule number, CIDR-based

The final failure persisted after security groups looked correct because the database subnet NACL had an earlier deny rule. That made rule order part of the evidence.
