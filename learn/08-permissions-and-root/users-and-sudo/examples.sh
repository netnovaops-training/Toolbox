#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Jason A. Gibson
# Safe identity/permissions demo. The READ-ONLY parts run anywhere; the account
# changes are shown as commented examples (they need root — run on a Linux VM).
set -euo pipefail

echo "== Who am I (names) =="
whoami
groups

echo "== What the kernel actually checks (numbers) =="
id                                   # uid=... gid=... groups=...

echo "== Look up a user properly =="
getent passwd "$(whoami)" || true    # works with local AND network (LDAP) users
# vs. grep, which only reads the local /etc/passwd file:
grep "^$(whoami):" /etc/passwd 2>/dev/null || echo "   (not in local /etc/passwd)"

echo "== Am I allowed to sudo? (just checks, prompts nothing) =="
sudo -n true 2>/dev/null && echo "   yes, sudo works without a password here" \
  || echo "   sudo would prompt / isn't available in this shell"

echo "== Account management (COMMENTED — needs root, run on a VM) =="
# WARNING: these change the system. Practice on a throwaway Linux VM only.
#   sudo useradd -m -s /bin/bash alice     # create user + home + shell
#   sudo passwd alice                       # set password
#   sudo usermod -aG docker alice           # ADD to a group (-aG, never bare -G)
#   groups alice                            # verify
#   sudo userdel -r alice                   # remove user + home
echo "   see the commented block above."

echo; echo "Done. Nothing on this system was changed."
