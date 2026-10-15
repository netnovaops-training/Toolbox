> **what:** a container couldn't write to its mounted volume — "permission denied"
> **status:** solved
> **tags:** docker, containers, permissions, uid, volumes
> **last-used:** 2026-10-15

# Container can't write to its bind-mounted volume

*(Sample entry — the format to copy. Based on a common real problem.)*

## The problem
Started a container with a bind-mounted data folder from the host. The app crashed
on startup / couldn't save anything.

## Symptoms
```
Error: EACCES: permission denied, open '/data/app.db'
```
The container ran, but any write into `/data` failed.

## What I tried
- Checked the host folder existed and I could write to it myself — I could.
- `chmod 777` on the host folder "fixed" it, but that's a security hole, so I kept
  digging for the real cause.
- Looked at *who* the container runs as vs *who* owns the host folder.

## The cause
The kernel checks **UID numbers**, not names. The host folder was owned by my user
(UID 1000). The container ran its app as a **different UID** (root, UID 0, writing
root-owned files — or an app user with no access). Mismatched UID = no permission.

## The fix
Matched the IDs instead of loosening permissions:
```
docker exec <container> id          # found the UID the app runs as
docker exec <container> ls -ln /data   # numeric owner inside
ls -ln ./data                        # numeric owner on the host — compare
# then either:
docker run --user "$(id -u):$(id -g)" -v "$PWD/data:/data" myimage   # run as my UID
# or:
sudo chown -R 1000:1000 ./data       # make the host folder match the app's UID
```

## What I learned / how I'm more prepared
- Container permission problems are almost always a **UID/GID mismatch** across the
  host/container boundary — names don't matter, numbers do.
- First move next time: `docker exec <c> id` and compare to `ls -ln` on the host,
  *before* touching permissions.
- Never `chmod 777` to make it work — match ownership or run the container as the
  right user. (See `../../learn/08-permissions-and-root/containers/doc.md`.)
