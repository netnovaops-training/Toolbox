# Linux / shell starter commands

# what: beginner Linux & shell commands I actually reach for
# status: useful
# tags: linux, bash, shell, cli
# last-used: 2026-10-15

Commands adapted from trimstray/the-book-of-secret-knowledge (MIT licence,
Copyright (c) 2017 trimstray). My notes added. Fork:
https://github.com/netnovaops-training/the-book-of-secret-knowledge

Each entry: the command, then one line on what it does / when to use it.

## Files and directories

```bash
ls -lah
```
List everything in a folder with sizes you can read and hidden files shown.

```bash
cd -
```
Jump back to the folder you were in before. Handy for bouncing between two.

```bash
mkdir -p path/to/new/dir
```
Make a folder and any missing parent folders in one step.

```bash
cp filename{,.orig}
```
Quick backup: copies `filename` to `filename.orig` before you edit it.

```bash
du -sh *
```
Show how big each item in the current folder is. Find what's eating space.

```bash
find . -type f -size +20M
```
Find files larger than 20 MB under here. Good for hunting big files.

```bash
find . -type f -mmin -60
```
Find files changed in the last 60 minutes. "What did I just touch?"

## Text, grep and sed basics

```bash
grep -rn "pattern" .
```
Search all files under here for text, showing file name and line number.

```bash
grep -i "pattern" file
```
Search a file ignoring upper/lower case.

```bash
grep -v "^#" file
```
Show a config file without its comment lines (lines starting with `#`).

```bash
grep -E "INFO|WARN" file
```
Match more than one word at once (INFO or WARN).

```bash
head -n 20 file
```
Show the first 20 lines of a file.

```bash
tail -n 20 file
```
Show the last 20 lines of a file.

```bash
tail -f /path/to/logfile
```
Follow a log live as new lines are written. Ctrl-C to stop.

```bash
sed -n '10p' file
```
Print just line 10 of a file.

```bash
sed 's/foo/bar/g' file
```
Print the file with every `foo` changed to `bar` (does not save; add `-i` to save).

```bash
sort file | uniq -c | sort -nr
```
Count how often each line appears and list the most common first.

```bash
wc -l file
```
Count the lines in a file.

## System info

```bash
uname -a
```
Show the kernel and basic system details.

```bash
df -h
```
Show free and used disk space per drive, in readable units.

```bash
free -h
```
Show how much memory (RAM) is used and free.

```bash
uptime
```
Show how long the machine has been up and its recent load.

```bash
who -b
```
Show when the system last booted.

```bash
id
```
Show your user, groups, and IDs. Useful for permission questions.

## Processes

```bash
ps aux
```
List every running process with its owner and resource use.

```bash
pgrep -a nginx
```
Find processes by name (here `nginx`) and show their command line.

```bash
top
```
Live view of processes using the most CPU and memory. `q` to quit.

```bash
kill <pid>
```
Ask a process to stop. Use `kill -9 <pid>` only if it won't stop politely.

## Permissions

```bash
chmod +x script.sh
```
Make a script runnable.

```bash
chown user:group file
```
Change who owns a file (run with `sudo` when needed).

```bash
find . -type f -exec chmod 644 {} +
```
Set normal read/write-for-owner, read-for-others on every file under here.

```bash
sudo !!
```
Re-run the command you just typed, this time with `sudo`.

## Networking basics

```bash
ip a
```
Show your network cards and their IP addresses.

```bash
ping -c 4 example.com
```
Send 4 test packets to check if a host is reachable.

```bash
ss -tulpn
```
Show which ports are open and listening, and which program owns each.

```bash
dig example.com +short
```
Resolve a domain name to its IP, short and clean.

```bash
host example.com
```
Another quick way to resolve a domain name.

```bash
curl -I https://example.com
```
Fetch just the HTTP response headers from a URL.

## Copying and archives

```bash
tar -czvf archive.tgz folder/
```
Pack a folder into one compressed `.tgz` file.

```bash
tar -xzvf archive.tgz
```
Unpack a compressed `.tgz` file.

```bash
rsync -avh source/ dest/
```
Copy or sync a folder to another place, keeping file attributes.

```bash
scp file user@host:/path/
```
Copy a file to a remote machine over SSH.

```bash
ssh user@host
```
Log in to a remote machine's shell.

## Level up later

Topics from the book worth growing into (names only — look them up in the fork:
https://github.com/netnovaops-training/the-book-of-secret-knowledge):

- `awk` for field and log processing
- `find` with `-exec` and `xargs` for batch jobs
- `strace` to trace a program's system calls
- `tcpdump` / `ngrep` to capture and read network traffic
- `openssl s_client` to inspect TLS/SSL certificates
- `nmap` for network and port scanning
- `vmstat` / `iostat` for deeper performance stats
- `screen` / `tmux` for terminal sessions that survive disconnects
