> **what:** users, groups, sudo and root — who you are and what you're allowed to do
> **status:** trying
> **tags:** linux, users, groups, sudo, root, security, sysadmin
> **last-used:** 2026-10-15

# Users, groups, sudo, and root

Permissions decide what the owner/group/other can do. **This** is about *who you
are* on the system and how you safely become powerful enough to administer it.

## Who am I?
```
whoami      # my username
id          # my UID, my groups (this is what the kernel actually checks)
groups      # just the group names
```
The kernel checks **UID/GID numbers**, not names. Names are a convenience mapped in
`/etc/passwd` (users) and `/etc/group` (groups). Remember that — it's the key to
the container problems in the next section.

## root — the superuser
`root` is UID 0: it bypasses permission checks. It can do anything, including break
the system. So the rule is **least privilege**: log in as a normal user, and only
become root for the specific task that needs it.

## sudo vs su
- **`sudo <command>`** — run one command as root (or another user), then drop back.
  This is the right way: targeted, logged, no root shell left open.
  ```
  sudo systemctl restart nginx
  sudo -u postgres psql        # run as a different user, not just root
  ```
- **`su -`** — switch to a full root shell. Powerful and easy to forget you're root.
  Prefer `sudo` for single actions.

Who's allowed to sudo is set in `/etc/sudoers` (edit it only with `sudo visudo`,
which checks for mistakes). Usually membership in a group (`sudo` on Debian/Ubuntu,
`wheel` on RHEL) grants it.

## Managing users and groups (real admin tasks)
```
sudo useradd -m -s /bin/bash alice   # create user 'alice' with a home dir + shell
sudo passwd alice                     # set her password
sudo usermod -aG docker alice         # ADD alice to the 'docker' group (-aG = append!)
getent passwd alice                   # look her up (works with LDAP too, unlike grep)
groups alice                          # what groups she's in
sudo userdel -r bob                   # delete bob and his home dir
```
WARNING: `usermod -G` *without* `-a` **replaces** all a user's groups — a classic
way to accidentally lock someone out of `sudo`. Always `-aG` to add.

Group changes take effect on next login (or `newgrp <group>` / re-login). "I added
myself to the docker group but still get permission denied" → log out and back in.

## When does something need root?
- Installing packages (`apt`, `dnf`), editing files under `/etc`, `/usr`, `/var`.
- Managing services (`systemctl`), binding to ports **below 1024**.
- Reading other users' files, changing ownership (`chown`).
- Packet capture (`tcpdump`) and raw sockets.
If a command gives "Operation not permitted" / "Permission denied" and it's a
system-level thing, that's usually your cue for `sudo` — not `chmod 777`.

## Why it matters on the job
- You'll administer servers as a normal user + sudo, and set up **service accounts**
  that run apps with only the access they need.
- Interviewers love "least privilege": show you don't just run everything as root.
- Auditing who can sudo and who's in sensitive groups (like `docker`, which is
  effectively root) is a real security task.

## Common mistakes
- Living as root "because it's easier" — one typo wipes something.
- `usermod -G` without `-a` (replaces groups).
- Forgetting group changes need a new login.
- Being in the `docker` group and not realising it's basically root access.
