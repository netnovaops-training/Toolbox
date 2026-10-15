> **what:** Linux file permissions — read/write/execute, chmod, chown, ownership
> **status:** trying
> **tags:** linux, permissions, chmod, chown, sysadmin, foundational
> **last-used:** 2026-10-15

# File permissions — the model a sysadmin lives in

Half of "it won't work" on Linux is a permission problem. Once the model clicks,
you stop guessing. This is one of the most interview-relevant Linux skills, because
it comes up every single day on the job.

## The model

Every file and folder has an **owner** (a user), a **group**, and three sets of
permissions: for the **owner**, the **group**, and **everyone else** ("other").
Each set has three bits: **r** read, **w** write, **x** execute.

Read a long listing (`ls -l`):
```
-rwxr-x---  1 jason  devs   4096 Oct 15 10:00 deploy.sh
 │└┬┘└┬┘└┬┘      │     │
 │ │  │  └ other: --- (nothing)
 │ │  └── group (devs): r-x (read + execute)
 │ └───── owner (jason): rwx (read + write + execute)
 └─────── type: - file, d directory, l symlink
```

### What r/w/x mean — and the folder gotcha
- On a **file**: r = read it, w = change it, x = run it (a program/script).
- On a **folder** they mean something different (this trips everyone up):
  - **r** = list the names inside
  - **w** = create/delete/rename entries inside
  - **x** = enter it / use a file inside by path
  - You often need **x on a folder** just to reach a file in it, even if you can
    read the file itself. "Permission denied" on a path you can see? Check the
    folder's x bits up the chain.

## chmod — change permissions

Two ways to say the same thing:

**Numeric (octal):** r=4, w=2, x=1; add them per set.
```
chmod 640 file    # owner rw-(6), group r--(4), other ---(0)
chmod 755 script  # owner rwx(7), group r-x(5), other r-x(5)  -> runnable by all
chmod 600 secret  # owner rw-, nobody else  -> private file (keys, configs)
```
**Symbolic:** who (u/g/o/a) + op (+/-/=) + bits (rwx).
```
chmod u+x script      # add execute for the owner
chmod go-w file       # remove write from group and other
chmod a=r file        # everyone read-only
```

Common job move: make a script runnable → `chmod +x script.sh`.

## chown / chgrp — change ownership (usually needs sudo)

```
sudo chown jason file          # change owner
sudo chown jason:devs file     # change owner AND group
sudo chown -R app:app /srv/app # recursive, for a whole tree (careful with -R)
```
Ownership is *who* the permissions apply to. A file you can't write often just
needs the right owner/group, not looser permissions.

## umask — the default for new files
New files are born with permissions minus the `umask`. Typical `umask 022` gives
new files `644` and folders `755`. Run `umask` to see yours. It explains "why did
my new file come out world-readable?"

## Special bits (know they exist)
- **setuid** (`chmod u+s`) — a program runs as its *owner*, not you. That's how
  `passwd` edits a root-owned file. A classic thing to audit: `find / -perm -4000`.
- **setgid** on a folder — new files inherit the folder's group (handy for shared
  team dirs).
- **sticky bit** on a folder (`chmod +t`, seen on `/tmp`) — only a file's owner can
  delete it, even if others can write the folder.

## Why it matters on the job
- Services run as their own user; files must be owned so that user can read configs
  and write logs/data. Wrong ownership = the service won't start or can't write.
- Keys/configs must be tight (`600`/`640`) or SSH and apps will refuse to use them
  ("permissions too open" is a real SSH error).
- Least privilege: give the minimum needed. World-writable files are a security
  finding.

## Common mistakes
- `chmod 777` to "make it work" — never. It's a security hole; the real fix is
  usually ownership or the folder's x bit.
- Forgetting folders need **x** to traverse.
- `chmod -R` / `chown -R` on the wrong path — powerful and easy to regret. Check
  the path twice; practice in a VM.
