# Permissions Blocking Access

> I'm getting a "permission denied" error when I try to run the weekly data export script...I double-checked with someone on my team that I have the correct file path. I can't read the files in the directory either. Not sure if I need access added or if something is set up wrong. My username is `priya.nair`."

## Summary

User unable to execute export script.

## Issue

Single user denied permission to execute export script or access files in the directory.

## Hypotheses

1. The user is not assigned to the group with access to the `exports` directory
2. The directory and/or export script file has misconfigured permissions

## Checks
<!-- markdownlint-disable MD029 -->
1. Check 'export' directory permissions and owning group

``` bash
$ ls -ld /opt/exports/
drwx------ 2 root data-exports /opt/exports/
```

- finding: `export` directory is missing permissions for group owner. Group owner is set to `data-exports`

2. Check export script file permissions and owning group

``` bash
$ ls -l /opt/exports/weekly_export.sh
-rwxrwx--- 1 root data-exports /opt/exports/weekly_export.sh
```

- finding: `weekly_export.sh` file has correct permission configuration. Group owner is set to `data-exports`

3. Check user `priya.nair` group affiliation

``` bash
$ id priya.nair
uid=1042(priya.nair) gid=1042(priya.nair) groups=1042(priya.nair),1005(analysts)
```

- finding: User is not a member of `data-exports` group

## Resolution

> **Action sequence:**
>
> 1. Set proper permissions for 'exports' directory using `chmod g+rwx /opt/exports`
> 2. Add user 'priya.nair' to the 'data-exports' group using `usermod -aG data-exports priya.nair`

`Exports` directory had incorrectly configured permissions for group owner, and user `priya.nair` was not set group owner `data-exports`, therefore unable to access the file. Added user `priya.nair` to the `data-exports` group and corrected `exports` directory group permissions.

> Escalate if standard permission and group checks pass but access still fails. May indicate SELinux, AppArmor, or ACLs outside support scope.

## Verification

- Confirmed user is able to access `exports` directory
- Confirmed user is not recieving "permission denied" error, and is able to run export script.

## Debrief

Check both sides of the Linux permission model: what the file and directory allow, and whether the user actually qualifies for that access before concluding your diagnosis.
