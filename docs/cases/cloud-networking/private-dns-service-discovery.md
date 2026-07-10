# Private DNS Service Discovery

> **Lab-derived case:** Adapted from completed work in the [Learn to Cloud Networking Lab](https://github.com/learntocloud/networking-lab). This case file documents the completed investigation and contains lab spoilers.

User report:
> "Our applications can't resolve internal hostnames anymore. We've been using `web.internal.local`, `api.internal.local`, and `db.internal.local` for service discovery but they stopped resolving. Public DNS works fine - we can resolve google.com. This is blocking deployments."

## Summary

Internal service names failed to resolve even though public DNS resolution still worked.

## Issue

Internal service hostnames do not resolve from within the VPC, while public DNS resolution continues to work. The issue affects service discovery between internal systems and suggests a private DNS configuration problem rather than a general DNS outage.

## Hypotheses

1. The instance may be using the wrong DNS resolver.
2. The Route 53 private hosted zone may not be associated with the VPC.
3. The private hosted zone may not exist or is missing the required A records.
4. VPC DNS support/settings are broken.

## Checks
<!-- markdownlint-disable MD029 -->
1. Tested public DNS resolution from the bastion host (with `dig`).  
   _**Finding:**_ Public hostnames resolve. The host has a functioning DNS resolver path.

2. Tested internal DNS names from the bastion host.  
   _**Finding:**_ Internal names such as `web.internal.local`, `api.internal.local`, and `db.internal.local` failed to resolve.

3. Reviewed the host resolver configuration (with `cat /etc/resolv.conf` and `resolvectl status`).  
   _**Finding:**_ The instance resolver path forwarded to the AWS VPC resolver (`10.0.0.2`). The host was not simply missing DNS configuration.

4. Listed Route 53 hosted zones (with `aws route53 list-hosted-zones`).  
   _**Finding:**_ A private hosted zone for `internal.local` existed.

```json
{
    "HostedZones": [
        {
            "Id": "/hostedzone/<hosted-zone-ID>",
            "Name": "internal.local.",
            "Config": {
                "PrivateZone": true
            },
            "ResourceRecordSetCount": 2
        }
    ]
}
```

5. Checked whether the private hosted zone was associated with the VPC (with `aws route53 get-hosted-zone --id <hosted-zone-ID>`).  
   _**Finding:**_ The private hosted zone was associated with the VPC, so the zone was in scope for internal VPC resolution.

6. Checked whether the private hosted zone had the required resource record sets (with `aws route53 list-resource-record-sets --hosted-zone-id <hosted-zone-ID>`).  
   _**Finding:**_ The zone had authority records such as NS and SOA, but it did not have A records for the internal service hostnames.

## Resolution

> **Action sequence:**
>
> 1. Created a JSON change batch containing A records for the internal service names in the private hosted zone.
> 2. Applied the change batch referencing the json file (with `aws route53 change-resource-record-sets --hosted-zone-id <hosted-zone-ID> --change-batch file://<json-file>`)
> 3. Waited for the Route 53 change to become `INSYNC`.
> 4. Queried the AWS VPC resolver directly to confirm the internal service names returned private IP addresses (with `dig @10.0.0.2 <internal-hostname>`).

Internal DNS failed because the private hosted zone existed but did not contain the A records required for service discovery. Adding the missing A records restored private DNS resolution for the cloud environments service names.

> Escalation would be required if hosted zone ownership, DNS record changes, or production service-discovery naming required platform/network team approval.

## Verification

Confirmed the required A records existed for web, API, and database hostnames and direct DNS queries to the VPC resolver returned the expected private IP addresses.

## Debrief

The failure was specific to internal names inside the private hosted zone while public names resolved normally — separating public DNS health from private service discovery.

DNS troubleshooting layers:
host resolver -> VPC resolver -> private hosted zone -> DNS record -> service IP
