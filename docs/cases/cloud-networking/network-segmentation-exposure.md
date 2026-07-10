# Network Segmentation Exposure

> **Lab-derived case:** Adapted from completed work in the [Learn to Cloud Networking Lab](https://github.com/learntocloud/networking-lab). This case file documents the completed investigation and contains lab spoilers.

User report:
> "Our quarterly security scan flagged several issues with the network segmentation:
>
> 1. SSH is accessible from the internet on all hosts — bastion should only allow SSH from your trusted source IP/CIDR, and internal hosts (web, API, database) should only allow SSH from the bastion security group
> 2. Database accepts connections on port 5432 from too broad a range — it should only accept connections from the API security group
> 3. ICMP is open from anywhere on the web server — it should only be allowed from the bastion security group  
> These need to be tightened up before our compliance review next week."

## Summary

Network access rules were too broad and needed to be tightened to least-privilege sources.

## Issue

Several network access rules allow broader access than the environment requires, including administrative SSH, database access, and diagnostic ICMP traffic. The issue affects the environment’s network segmentation posture and requires broad rules to be replaced with narrower least-privilege paths.

## Hypotheses

1. Bastion SSH may be open to the entire internet instead of a trusted administrator IP/CIDR.
2. Internal host SSH may be open broadly instead of restricted to the bastion security group.
3. Database access may be open broadly instead of restricted to the API security group.
4. Web ICMP may be open broadly instead of restricted to the bastion security group.
5. Hardening may break required access if narrow replacement rules are not added before broad rules are removed.

## Checks

1. Reviewed the relevant security group inbound rules (with `aws ec2 describe-security-groups`).  
   _**Finding:**_ Confirmed multiple rules allowed broader access than required: bastion SSH was open beyond the trusted administrator source, internal host SSH was not limited to the bastion security group, database ingress on TCP `5432` was broader than the API security group, and web ICMP was open beyond the bastion diagnostic source.

## Resolution

> **Action sequence:**
>
> 1. Identified the trusted administrator public IP and represented it as a `/32` CIDR (with `curl -s http://checkip.amazonaws.com`).
> 2. Added bastion SSH ingress from the trusted administrator `/32` CIDR (with `ec2 authorize-security-group-ingress`).
> 3. Removed broad SSH ingress to the bastion (with `aws ec2 revoke-security-group-ingress`).
> 4. Added internal SSH ingress from the bastion security group.
> 5. Removed broad internal SSH ingress rules.
> 6. Added database ingress from the API security group on TCP `5432`.
> 7. Removed broad database ingress on TCP `5432`.
> 8. Added ICMP ingress to the web security group from the bastion security group.
> 9. Removed broad ICMP ingress from the web security group.
> 10. Retested required access paths.

Broad network access rules were replaced with narrower rules that matched the intended access model. Bastion SSH was limited to the trusted source IP, internal SSH was limited to the bastion path, database access was limited to the API tier, and ICMP diagnostics were limited to the bastion.

> Escalation would be required in a production environment if firewall hardening, SSH access policy, database access, or exception handling required security/network approval.

## Verification

- Confirmed the bastion remained reachable from the trusted public IP.
- Confirmed internal SSH access was available through the bastion path.
- Confirmed database access was limited to the API security group on TCP `5432`.
- Confirmed broad ICMP access was removed and diagnostic ICMP was limited to the bastion source.
- Confirmed required application connectivity still worked.

## Debrief

This case was straightforward, reinforcing the concept and implementation of least privilege.

Also taught the concept of ICMP for troubleshooting, and why the bastion should be the only entry point.
