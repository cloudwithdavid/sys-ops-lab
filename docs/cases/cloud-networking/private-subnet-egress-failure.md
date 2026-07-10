# Private Subnet Egress Failure

> **Lab-derived case:** Adapted from completed work in the [Learn to Cloud Networking Lab](https://github.com/learntocloud/networking-lab). This case file documents the completed investigation and contains lab spoilers.

User report:
> "Our API service that runs on the private subnet stopped being able to fetch data from external APIs this morning. We didn't change anything on our end. Requests to third-party services just hang and timeout. Internal calls between our services still work fine."

## Summary

API server in a private subnet can not reach external APIs.

## Issue

The API service in the private subnet could communicate with internal systems but could not retrieve data from external APIs. External requests timed out, suggesting an outbound connectivity issue affecting the API server’s internet egress path.

## Hypotheses

1. DNS resolution may be failing for public domains.
2. The API server may not be routing non-local traffic toward the VPC router.
3. The private subnet route table may be missing a default route through the NAT Gateway.
4. The NAT Gateway may be missing, unavailable, or unreachable.
5. Security groups or NACLs may be blocking outbound traffic.

## Checks
<!-- markdownlint-disable MD029 -->
1. Tested public DNS resolution from the API server (with `dig`).  
   _**Finding:**_ Public domain names resolved successfully.

2. Tested external HTTP reachability from the API server (with `curl`).  
   _**Finding:**_ External HTTP requests timed out, confirming the server could not complete outbound internet connections.

3. Tested external IP reachability from the API server. (with `ping`).  
   _**Finding:**_ Public IP reachability failed, supporting an outbound network-path issue rather than an application-only issue.

4. Reviewed the Linux routing table on the API server (with `ip route`).  
   _**Finding:**_ The instance default route pointed to the subnet gateway/VPC router inside the VPC.

> This showed the instance could hand traffic to the VPC router, but it did not prove the AWS subnet route table had a valid internet egress path.

5. Identified the API server subnet and reviewed the associated AWS route table (with `aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-ID>"` and `aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=<subnet-ID>"`).  
   _**Finding:**_ The private subnet route table only has the local VPC route and does not have a `0.0.0.0/0` route through a NAT Gateway.

6. Checked NAT Gateway availability in the VPC (with `aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-ID>"`).  
   _**Finding:**_ A NAT Gateway exists and is available in the public subnet, but the private route table is not using it for default outbound traffic.

## Resolution

> **Action sequence:**
>
> 1. Added a default route for non-local traffic from the private subnet to the NAT Gateway (with `aws ec2 create-route --route-table-id <route-table-ID> --destination-cidr-block 0.0.0.0/0 --nat-gateway-id <NAT-GW-ID>`).
> 2. Retested external reachability from the API server.

The API server could reach internal VPC resources, but outbound internet access failed because the private subnet route table did not send default traffic to the NAT Gateway. Adding the missing `0.0.0.0/0` route through the NAT Gateway restored private subnet egress.

> Escalation would be required if NAT Gateway creation, route table changes, or production VPC routing changes required network engineering approval.

## Verification

Confirmed outbound internet access was restored by successfully reaching the external endpoint from the API server.

## Debrief

This case reinforced the difference between instance-level routing and cloud route table behavior.

On the instance, `ip route` showed the server had a default route to the VPC subnet gateway. That did not mean the server had internet egress. In AWS, the subnet route table still needed a default route to a NAT Gateway.

Private subnet internet access requires a NAT Gateway in a public subnet and a private subnet route table that points `0.0.0.0/0` to that NAT Gateway.
