#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Jason A. Gibson
# Diagnose container permission problems. These need Docker + a Linux host, so they
# are shown as a runnable-shaped reference with comments. Run on a Linux VM with
# Docker to actually see the output. Replace <container> with a real name/id.
set -euo pipefail

cat <<'NOTES'
== Container permission troubleshooting cheat-run ==
(Run these on a Linux box with Docker. Comments explain each step.)

# 1. What UID/GID does the process inside the container run as?
docker exec <container> id
#    -> uid=0(root)  means root; uid=1000 means an app user, etc.

# 2. Numeric ownership INSIDE the container (numbers are what the kernel checks)
docker exec <container> ls -ln /data

# 3. Numeric ownership of the host folder you bind-mounted
ls -ln ./data

# 4. The actual error
docker logs <container> | tail -n 20

# ---- FIXES ----

# A) Match the host folder to the UID the container uses (e.g. 1000)
#    WARNING: changes ownership on the host — check the path first.
sudo chown -R 1000:1000 ./data

# B) Run the container as YOUR uid/gid so it writes files you own
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD/data:/data" myimage

# C) Same idea in docker-compose.yml:
#      services:
#        app:
#          image: myimage
#          user: "1000:1000"
#          volumes:
#            - ./data:/data

# D) Avoid the whole bind-mount ownership issue with a named volume:
#      volumes: [ "appdata:/data" ]     # Docker manages ownership
NOTES

echo
echo "Reference printed. Nothing was run here (needs Docker on Linux)."
