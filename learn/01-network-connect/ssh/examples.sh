#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
# SPDX-License-Identifier: MIT
# Copyright (c) 2017 trimstray (original one-liners)
# Copyright (c) 2026 Jason A. Gibson (adaptations and comments)
# Safe, annotated ssh / ssh-keygen / ssh-agent examples for learning.
#
# NOTE: the ssh commands below connect to a real remote host. They are written
# against the placeholder "user@example.com" so nothing runs against a real
# server by accident. Replace the host with one YOU control before running the
# connecting examples. The key/agent examples are safe to run as-is.

# set -euo pipefail   # -e stop on error, -u error on unset var, pipefail catch mid-pipe errors.
                      # Left commented: this file is a menu of examples to read and copy,
                      # not a script to run straight through.

echo "=== 1) Make a modern key pair (safe to run; writes into ~/.ssh) ==="
# -t ed25519 : modern key type (short, fast, strong).
# -C         : a comment to help you recognise the key later.
# ssh-keygen will prompt for a file name and a passphrase. USE a passphrase.
#   ssh-keygen -t ed25519 -C "you@example.com"
echo "   (left as a comment so we don't overwrite your real key — read the doc)"

echo "=== 2) Print the public key that matches a private key ==="
# Useful when you have the private key but lost the .pub file.
#   ssh-keygen -y -f ~/.ssh/id_ed25519

echo "=== 3) List fingerprints of hosts you have trusted before ==="
# known_hosts records each server's identity; -l shows a short fingerprint per entry.
#   ssh-keygen -l -f ~/.ssh/known_hosts

echo "=== 4) Start an agent and load your key once (type passphrase one time) ==="
#   eval "$(ssh-agent -s)"      # start the agent, export its env vars into this shell
#   ssh-add ~/.ssh/id_ed25519   # unlock the key; the agent holds it in memory
#   ssh-add -l                  # list what the agent is currently holding

echo "=== 5) Basic login (replace with a host you control) ==="
#   ssh user@example.com
#   ssh -p 2222 user@example.com     # when sshd listens on a non-default port

echo "=== 6) Run a single command on the remote host, get output locally ==="
# ssh can run one command and exit instead of giving you an interactive shell.
#   ssh user@example.com 'uname -a; uptime'

echo "=== 7) Compare a remote file with a local file (no copy needed) ==="
# cat the remote file over ssh, pipe it into diff; '-' means "read the other side from stdin".
#   ssh user@example.com cat /etc/hosts | diff /etc/hosts -

echo "=== 8) Force password auth (to TEST that a server has disabled it) ==="
# If the server is keys-only, this should be refused — which is what you want to confirm.
#   ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@example.com

echo "=== 9) Force public-key auth with one specific key ==="
#   ssh -o PreferredAuthentications=publickey -i ~/.ssh/id_ed25519 user@example.com

echo "=== 10) Local port forward: reach a remote DB as if it were local ==="
# Maps localhost:9090 on YOUR machine to port 5432 on the server.
# -n stdin from /dev/null, -N no remote command, -T no terminal -> a clean tunnel.
#   ssh -nNT -L 9090:localhost:5432 user@example.com
#   # then, in another terminal: psql -h localhost -p 9090 ...

echo "=== 11) Hop through a jump/bastion host to reach a private machine ==="
# Reach 192.168.1.50 (only visible inside the remote network) via example.com.
#   ssh -J user@example.com user@192.168.1.50
#   # or put 'ProxyJump' in ~/.ssh/config and just 'ssh db'

echo "=== 12) Record a session transcript to a dated log file (adapted) ==="
# Handy for keeping evidence of what you did on a server. Writes to a log dir you choose.
_ssh_sesslog() {
  local sesdir="${HOME}/ssh-session-logs"          # pick any directory you own
  mkdir -p "${sesdir}"
  # tee -a copies the session to the screen AND appends it to today's log.
  ssh "$@" 2>&1 | tee -a "${sesdir}/$(date +%Y%m%d).log"
}
echo "   defined _ssh_sesslog(); call it like:  _ssh_sesslog user@example.com"

echo "=== 13) Debug a 'Permission denied (publickey)' and grep the useful lines ==="
# -vvv prints the whole auth negotiation; grep pulls out only the key-offer lines.
# This is the real way to see WHICH key was offered and whether it was accepted.
#   ssh -vvv user@example.com 2>&1 | grep -iE 'offering|authentications that can continue|accepted'

echo "=== 14) Run a remote command and process the output locally (awk from lesson 04) ==="
# ssh prints the remote command's stdout to YOUR terminal, so pipes work normally.
# Here: remote filesystem usage, busiest mount first.
#   ssh user@example.com 'df -h' | awk 'NR>1 {print $5, $6}' | sort -rn

echo "=== 15) Check many hosts for reachability from a host list (while-read loop) ==="
# Build a tiny list, then test each with a short timeout so one dead host can't hang us.
# BatchMode=yes => never prompt; ConnectTimeout => fail fast. 'true' is a no-op remote cmd.
hostlist="$(mktemp)"
trap 'rm -f "$hostlist"' EXIT
printf 'user@example.com\nuser@192.168.1.50\n' > "$hostlist"
echo "   built a demo host list at $hostlist; the loop below is left as a comment:"
#   while read -r h; do
#     if ssh -o BatchMode=yes -o ConnectTimeout=5 "$h" true 2>/dev/null; then
#       echo "UP   $h"
#     else
#       echo "DOWN $h"
#     fi
#   done < "$hostlist"

echo "=== 16) Copy a directory tree with a tar pipe over ssh (no scp needed) ==="
# Streams a gzip'd tar straight down the tunnel and unpacks on the far side.
#   tar czf - ./site | ssh user@example.com 'cd /srv && tar xzf -'

echo "=== 17) rsync over ssh: copy only what changed (great for deploys) ==="
# -a archive (perms/times), -z compress, --delete mirror, -e ssh pick the transport.
#   rsync -az --delete -e 'ssh -o ConnectTimeout=5' ./site/ user@example.com:/srv/site/

echo "=== 18) Connection multiplexing: make repeat logins instant (config snippet) ==="
# Put this in ~/.ssh/config; the first ssh opens a master, later ones reuse it.
#   Host *
#       ControlMaster auto
#       ControlPath ~/.ssh/cm-%r@%h:%p
#       ControlPersist 10m
