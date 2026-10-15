> **what:** permissions, users/sudo, and container-permission practice
> **status:** trying
> **tags:** permissions, sudo, containers, practice
> **last-used:** 2026-10-15

# Permissions & root — practice

Do these on a **throwaway Linux VM or container** (permissions don't behave the same
on Windows). Hints only — work them out; ask my mentor if stuck. This lesson builds
on earlier ones: use `ls`/`find` (lesson 03) to inspect, and `grep` (lesson 04) to
read `/etc/passwd`.

## Permissions
1. Create a file and set it to `640`, then to `600`, reading `ls -l` after each.
   Say out loud what each digit means. *Hint: r=4 w=2 x=1, per owner/group/other.*
2. Make a script executable two different ways (numeric and symbolic). *Hint: `755` vs `u+x`.*
3. Reproduce the **folder-needs-x** gotcha: a readable file you can't reach because
   its folder lacks `x`. Then fix it. *Hint: `chmod 600 dir` then try to `cat` inside.*
4. Find all setuid programs on the system and pick one you recognise. *Hint: `find / -perm -4000 2>/dev/null`.*

## Users, sudo, root
5. Show your UID and groups two ways. *Hint: `id` and `groups`.*
6. On the VM, create a user, set a password, add them to a group with `-aG`, and
   verify. Then explain why `-G` alone would be dangerous. *Hint: it replaces groups.*
7. Find three things that need `sudo` and three that don't. *Hint: editing `/etc` vs your home.*
8. Explain, in a sentence, why you'd use `sudo <cmd>` instead of `su -`.

## Containers (if you have Docker on the VM)
9. Run a container, `docker exec <c> id`, and compare its UID to a host folder's
   owner with `ls -ln`. *Hint: numbers, not names.*
10. Cause a "permission denied" on a bind-mounted volume, then fix it two ways:
    (a) `chown` the host folder, (b) run the container with `--user`. *Hint: match the UID.*
11. Explain why being in the `docker` group is effectively root on the host.

**Check yourself:** a service can't write its log folder. Walk through how you'd
diagnose and fix it — out loud, like you're answering an interview question.
