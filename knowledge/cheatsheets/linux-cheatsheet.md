# Linux cheatsheet — the commands I reach for most

A quick one-pager. Fuller notes with examples: `dev/bash/linux-starter.md`.

| Command | Does |
|---|---|
| `ls -lah` | list files, readable sizes, show hidden |
| `cd -` | go back to previous folder |
| `mkdir -p a/b/c` | make nested folders |
| `cp file{,.orig}` | quick backup copy |
| `du -sh *` | size of each item here |
| `df -h` | free disk space per drive |
| `find . -type f -size +20M` | find big files |
| `grep -rn "text" .` | search text in all files, with line numbers |
| `grep -i "text" file` | search ignoring case |
| `head -n 20 file` / `tail -n 20 file` | first / last lines |
| `tail -f logfile` | follow a log live |
| `sort file \| uniq -c \| sort -nr` | count & rank repeated lines |
| `ps aux` | list all processes |
| `top` | live CPU/memory view |
| `kill <pid>` | stop a process (`-9` to force) |
| `chmod +x script.sh` | make a file runnable |
| `chown user:group file` | change file owner |
| `ip a` | show IPs / interfaces |
| `ping -c 4 host` | test reachability |
| `ss -tulpn` | show listening ports |
| `dig host +short` | resolve a domain |
| `tar -czvf a.tgz dir/` / `tar -xzvf a.tgz` | pack / unpack |
| `rsync -avh src/ dest/` | copy/sync a folder |
| `ssh user@host` | log in to a remote machine |
