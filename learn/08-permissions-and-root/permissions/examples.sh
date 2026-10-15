#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Jason A. Gibson
# Safe, self-contained permissions demo. Works in a scratch dir, cleans up.
# NOTE: on a real Linux box the modes below "stick"; on Windows Git Bash they may
# not reflect exactly — run this on a Linux VM/container to see the real effect.
set -euo pipefail

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT; cd "$work"

echo "== 1. Make a file and read its permissions =="
echo "hi" > note.txt
ls -l note.txt                       # see the -rw-r--r-- style string

echo "== 2. Numeric chmod =="
chmod 600 note.txt                   # owner rw, nobody else (private, like a key)
ls -l note.txt
chmod 644 note.txt                   # owner rw, others read
ls -l note.txt

echo "== 3. Make a script runnable (symbolic) =="
printf '#!/usr/bin/env bash\necho "I ran"\n' > run.sh
./run.sh 2>/dev/null || echo "   (not executable yet -> permission denied)"
chmod u+x run.sh                     # add execute for the owner
./run.sh                             # now it runs

echo "== 4. The folder-needs-x gotcha =="
mkdir sub; echo "secret" > sub/data.txt
chmod 644 sub/data.txt               # file is readable...
chmod 600 sub                        # ...but folder has no x: can't traverse it
cat sub/data.txt 2>/dev/null || echo "   can't reach the file without x on 'sub'"
chmod 700 sub                        # restore x on the folder
cat sub/data.txt                     # now the path works

echo "== 5. See your umask (default for new files) =="
umask                                # e.g. 0022 -> new files 644, new dirs 755

echo "== 6. Ownership (shown, not changed — needs sudo/root) =="
# WARNING: real use needs sudo and the right path. Example shape only:
#   sudo chown app:app /srv/app/data     # give the 'app' service its data
#   sudo chown -R app:app /srv/app        # recursive (double-check the path!)
echo "   chown needs root; see the commented examples above."

echo; echo "Done. Scratch dir removed."
