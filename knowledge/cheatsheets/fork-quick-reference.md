# what: quick reference for the "thin" tools from my book fork (1-2 examples each)
# status: useful
# tags: linux, cli, networking, processes, cheatsheet
# last-used: 2026-10-15

Commands adapted from trimstray/the-book-of-secret-knowledge (MIT, (c) 2017 trimstray).

A terse one-stop reference for the tools that only had a command or two in the
fork — the ones not getting a full lesson. Scan, copy, adapt. Full lessons live
in the other cheat sheets and notes.

## Processes & performance

**ps** — list/inspect running processes.
```bash
ps awwfux | less -S                          # scrollable process tree, full detail
ps hax -o user | sort | uniq -c | sort -r    # count processes per user
```

**top** — live process monitor.
```bash
top -p $(pgrep -d , nginx)                    # watch only processes matching a name
```

**iostat** — CPU and disk I/O stats.
```bash
iostat 2 10 -t -m                             # every 2s, 10 times, timestamps, MB
iostat 2 10 -t -m -d                          # disk utilisation only
```

**tail** — read/follow the end of a file.
```bash
tail -f file | while read; do echo "$(date +%T.%N) $REPLY"; done   # follow + timestamps
tail -10000 access_log | awk '{print $1}' | sort | uniq -c | sort -n | tail   # top IPs in a log
```

**kill** — send a signal to a process.
```bash
kill -9 $(lsof -i :<port> | awk '{l=$2} END {print l}')   # kill whatever holds a port
```

**cpulimit** — cap a process's CPU usage.
```bash
cpulimit -p <pid> -l 50                       # hold that PID to 50% CPU
```

**pwdx** — show a process's working directory.
```bash
pwdx <pid>
```

**taskset** — pin a process to CPU cores.
```bash
taskset -c 0 <command>                        # run command on core 0 only
```

## Files & archives

**tar** — create/extract archives.
```bash
tar -czvpf /mnt/backup-$(date +%d%m%Y%s).tgz --directory=/ \
  --exclude=proc/* --exclude=sys/* --exclude=dev/* --exclude=mnt/* .   # full backup, gzip
```

**dump** / **restore** — filesystem-level backup.
```bash
dump -y -u -f /backup/system-$(date +%d%m%Y%s).lzo /    # dump a filesystem
cd / && restore -rf /backup/system-<date>.lzo           # restore it
```

**dd** — low-level block copy. Handle with extreme care.
```bash
# DO NOT RUN on a real disk — VM/scratch only
echo "string" | dd of=filename               # write stdin to a file (safe shape)
dd <params> status=progress                   # add live progress to any dd job
```

**secure-delete** — overwrite data so it can't be recovered.
```bash
# DO NOT RUN on a real disk — VM/scratch only
srm -vz /path/to/scratchfile                  # securely remove a single file (shape only)
# (the fork also shows disk-wide wipes with shred/scrub/badblocks — not reproduced here)
```

**diff** — compare files, trees, or command output.
```bash
diff <(cd dir1 && find | sort) <(cd dir2 && find | sort)   # compare two directory trees
diff <(cat /etc/passwd) <(cut -f2 /etc/passwd)             # compare two command outputs
```

**vimdiff** — side-by-side diff with highlighting.
```bash
vimdiff file1 file2                           # :qa to quit; F7 toggles diff char mode
vimdiff <(jq -S . A.json) <(jq -S . B.json)   # compare two JSON files, keys sorted
```

**du** — directory sizes.
```bash
du | sort -rn | \
  awk '{split("K M G",v); s=1; while($1>1024){$1/=1024; s++} print int($1)" "v[s]"\t"$2}' | head -20
# the 20 biggest directories, in K/M/G
```

**mount** — attach a filesystem.
```bash
mount -t tmpfs tmpfs /mnt -o size=64M         # temporary 64M RAM disk
mount -o remount,rw /                         # remount root read/write
```

**rsync** — sync files locally or over SSH.
```bash
rsync --rsync-path 'sudo rsync' user@host:/path/to/dir/ /local/   # pull remote data as root
```

## Permissions & sessions

**chmod** — change file permissions.
```bash
chmod -R -x+X *                               # strip exec from files, keep it on dirs
```

**screen** — detachable terminal sessions.
```bash
screen -d -m <command>                        # start a command in a detached session
screen -r -d <pid>                            # (re)attach to an existing session
```

**script** — record and replay a terminal session.
```bash
script --timing=session.time session.log      # record
scriptreplay --timing=session.time session.log # replay
```

**who** — who is logged in / boot info.
```bash
who -b                                        # last boot time
```

**last** — login/reboot history.
```bash
last -x | grep -A1 reboot | head             # recent reboots and what preceded them
```

**busybox** — tiny all-in-one toolbox.
```bash
busybox httpd -p 8080 -h $HOME               # quick static HTTP server
```

## Networking

**netstat** — connections and listening ports.
```bash
watch "netstat -plan | grep :443 | awk '{print \$5}' | cut -d: -f1 | sort | uniq -c | sort -nk1"
# live count of connections to port 443, per IP
```

**host** — DNS lookups.
```bash
host example.com <dns-ip>                      # resolve via a chosen DNS server
host -t soa example.com <dns-ip>               # show the SOA (zone admin) record
```

**gnutls-cli** — test a TLS connection.
```bash
gnutls-cli -p 443 example.com                  # TLS handshake, with SNI
gnutls-cli --disable-sni -p 443 example.com    # without SNI
```

**httpie** — friendly HTTP client.
```bash
http -p Hh https://example.com                 # show request + response headers
http -p Hh https://example.com --follow --verify no   # follow redirects, skip cert check
```

**socat** — bidirectional data relay.
```bash
socat - TCP4:192.168.1.10:22                   # test a TCP connection to host:port
```

**tcpick** — watch captured packets.
```bash
while true; do tcpick -a -C -r dump.pcap; sleep 2; clear; done   # replay a pcap live
```

**p0f** — passive OS/traffic fingerprinting.
```bash
p0f -i eth0 -p -d -o /dump/eth0.log            # promiscuous capture to a log (own iface)
```

**hping3** — crafted-packet probe. Authorized / own network only.
```bash
hping3 -V -c 3 -1 192.168.1.1                  # send 3 ICMP echoes to your own gateway
```

**certbot** — Let's Encrypt certificates.
```bash
certbot certonly -d example.com -d www.example.com                 # multi-domain cert
certbot certonly --manual --preferred-challenges=dns \
  -d example.com -d *.example.com              # wildcard cert via DNS challenge
```

## Dev & misc

**python** — one-liner servers and helpers.
```bash
python3 -m http.server 8000 --bind 127.0.0.1   # quick static HTTP server
python -m base64 -d <<< "dGhpcyBpcyBlbmNvZGVkCg=="   # decode base64 (-e to encode)
```

**git** — a readable history view.
```bash
git log --oneline --decorate --graph --all     # compact branch graph
```

**linux-dev** — bash's /dev/tcp pseudo-devices.
```bash
timeout 1 bash -c "</dev/tcp/<host>/<port>" >/dev/null 2>&1; echo $?   # port check, no nc
```

**tr** — translate/squeeze characters.
```bash
tr : '\n' <<< "$PATH"                          # print $PATH one entry per line
```

**inotifywait** — react to filesystem changes.
```bash
while true; do inotifywait -r -e MODIFY dir/ && ls dir/; done   # act when a file changes
```
