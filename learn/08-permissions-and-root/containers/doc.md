> **what:** how Linux permissions show up in containers — the problems and the fixes
> **status:** trying
> **tags:** docker, containers, permissions, uid, gid, volumes, troubleshooting
> **last-used:** 2026-10-15

# Permissions in containers — the troubles I actually hit

Most "my container won't work" headaches are permission problems in disguise. This
connects everything from the permissions and users lessons to real container work —
exactly the kind of practical troubleshooting a junior admin does.

## The one idea that explains most of it

A container shares the host's kernel, and **the kernel checks UID/GID numbers, not
names.** Inside the container, a process runs as some UID (often root = 0, or an app
user like 1000). When that process touches a **bind-mounted host folder**, the host
checks that *number* against the host file's owner. The container's *username* is
irrelevant — only the number matters.

So: a file owned by UID 1000 on the host is writable by UID 1000 in the container,
even if they have different names (or no name) on each side.

## Trouble 1 — "permission denied" writing to a volume

Symptom: the app in the container can't write to its mounted data folder; logs show
`permission denied` or the app crashes on startup.

Why: the host folder is owned by your user (say UID 1000), but the container runs the
app as a **different UID** (root, or UID 999), which has no write permission.

Fixes (pick one):
```
# A) Make the host folder owned by the UID the container uses
#    First find what UID the container runs as:
docker exec <container> id
#    Then match the host folder to it:
sudo chown -R 1000:1000 /path/on/host/data

# B) Tell the container to run as your UID (no chown needed)
docker run --user "$(id -u):$(id -g)" -v "$PWD/data:/data" myimage

# C) In docker-compose:
#    user: "1000:1000"
#    volumes: ["./data:/data"]
```

## Trouble 2 — files the container creates are owned by root on the host

Symptom: the container (running as root) writes files into a bind mount, and now on
the **host** you can't edit/delete them without `sudo` — they're owned by UID 0.

Fix: run the container as a non-root user (Trouble 1, option B/C), or `sudo chown`
the files back to yourself. Better images run as a non-root user by default.

## Trouble 3 — "x" on the folder, again

A mounted config file the container can read, but it can't reach it: a parent folder
in the mount path lacks **execute** for the container's user. Same folder-needs-x
rule from the permissions lesson, just inside a container.

## Trouble 4 — named volumes vs bind mounts
- **Bind mount** (`./data:/data`): uses the host folder's ownership → you deal with
  UID/GID (the troubles above).
- **Named volume** (`myvol:/data`): Docker manages it; it's usually initialised with
  the image's ownership, so these "just work" more often. If an app is picky about
  data ownership, a named volume can dodge the whole problem.

## Trouble 5 — the `docker` group is root
Being in the `docker` group lets you run containers as root-equivalent on the host
(you can mount `/` and become root). That's convenient but a real security note:
treat `docker` group membership like giving someone root.

## How to diagnose (the moves)
```
docker exec <container> id                 # what UID/GID the process runs as
docker exec <container> ls -ln /data       # -n shows NUMERIC owner, the thing that matters
ls -ln /path/on/host/data                  # compare to the host side
docker logs <container>                     # the actual "permission denied" line
```
Match the numbers on both sides and the problem usually disappears.

## Why it matters on the job
Running apps in containers is the norm. "The container can't write its data" is an
everyday ticket, and being able to say *"check the UID the container runs as vs the
host folder's owner, then match them"* is exactly the practical, calm troubleshooting
employers want to hear.

## Common mistakes
- `chmod -R 777` on the volume to "fix" it — works, but it's a security hole; the
  real fix is matching UID/GID.
- Assuming usernames matter across the host/container boundary — only numbers do.
- Running everything as root in the container, then fighting root-owned files on the host.
