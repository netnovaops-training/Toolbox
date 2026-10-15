> **what:** practice exercises for capturing and scanning — netcat, tcpdump, ngrep, nmap
> **status:** trying
> **tags:** networking, netcat, tcpdump, ngrep, nmap, capture, scanning, practice
> **last-used:** 2026-10-15

# Practice: capturing and scanning (netcat, tcpdump, ngrep, nmap)

Work top to bottom — they get harder. These tools look at, and probe, the
network itself, so the one rule that overrides everything:

> **Only capture or scan machines you OWN, or that you have EXPLICIT WRITTEN
> permission to test.** Loopback (`127.0.0.1` / `lo`) and your own lab VMs are
> always safe. A stranger's server is never a practice target. Build a throwaway
> VM (or two) and do all of this there. `tcpdump`, `ngrep`, and nmap's powerful
> modes need `sudo`.

A good lab: one VM running a plain HTTP server on a high port (e.g. a one-line
`python3 -m http.server 8080`), and your own machine to poke it with.

---

### 1. Open vs refused with netcat (easy)
On your own machine, start a listener (`nc -lk 5000`) in one terminal. From
another, run `nc -vz -w1 127.0.0.1 5000`, then stop the listener and run the
same check again.

*Hint:* with the listener up you get "succeeded"; with it gone you get
"Connection refused." -w1 stops it hanging.
**Check yourself:** you can describe the difference between "refused" (host said
no) and a hang/timeout (firewall dropping).

---

### 2. Prove a path end to end (easy)
Use two terminals (or two of your own VMs): a `nc` listener on one, a `nc`
client on the other. Type a line on the client and watch it appear on the
listener.

*Hint:* listener `nc -lk 5000`; client `nc <that host> 5000`. On high ports
(>=1024) you don't need root.
**Check yourself:** text typed on one side shows up on the other — the port and
path are open.

---

### 3. See a TCP handshake (medium)
Start `sudo tcpdump -n -i lo -c 10 port 8080` and, while it runs, hit your local
HTTP server with `curl http://127.0.0.1:8080`. Find the SYN, SYN-ACK, and ACK in
the output.

*Hint:* flags show as `[S]`, `[S.]`, `[.]`. The `>` in each line points from
source to destination. `-c 10` stops it after 10 packets.
**Check yourself:** you can point at the three handshake packets in order.

---

### 4. ICMP only (medium)
Run `sudo tcpdump -n -i lo icmp` and, in another terminal, `ping -c 3
127.0.0.1`. Identify the echo requests and echo replies.

*Hint:* each ping is a request packet followed by a reply packet. The filter
`icmp` drops everything that isn't ping.
**Check yourself:** you see three request/reply pairs and no other noise.

---

### 5. Plaintext is readable — see it yourself (medium)
Capture your own loopback HTTP traffic with payload shown:
`sudo tcpdump -i lo -A -s0 port 8080`, then `curl http://127.0.0.1:8080`. Find
the `GET /` and `Host:` lines in the payload.

*Hint:* `-A` prints ASCII payload, `-s0` captures the full packet. This is the
"why HTTPS exists" demo.
**Check yourself:** write one sentence: if this were someone's login over plain
HTTP, what would you have just seen? (Now you understand TLS.)

---

### 6. grep the network with ngrep (harder)
Use `ngrep` to show only the packets containing `Host:` on your own HTTP port:
`sudo ngrep -d lo -q -W byline 'Host:' port 8080`, with `curl` generating
traffic. Then try the same pattern on an HTTPS port and explain the difference.

*Hint:* `-q` only prints matches, `-W byline` makes HTTP readable. On HTTPS the
payload is encrypted, so the body won't match.
**Check yourself:** you can explain why `ngrep` finds the header on HTTP but not
inside the HTTPS body.

---

### 7. Inventory your own lab subnet (harder)
Run a ping scan of a subnet **you own** (`sudo nmap -sn 192.168.1.0/24`, swapping
in your real lab range). List the hosts that came back up.

*Hint:* `-sn` discovers live hosts without scanning ports. If you only have one
VM, scan `127.0.0.1` and a single known IP instead.
**Check yourself:** you can name which addresses responded and which didn't —
and you double-checked the range is yours before running it.

---

### 8. Open / closed / filtered (harder)
On a host you own, scan a few ports with `nmap` and get at least one of each
state (open, closed, filtered). Write what each state means about the host and
any firewall.

*Hint:* a running service → open; a port with nothing listening → closed; a port
behind a dropping firewall → filtered. You may need to add a firewall rule on
your lab VM to produce "filtered."
**Check yourself:** your note ties each state to a cause (listening service /
nothing home / silent drop).

---

### 9. Name the services (hardest)
Use `sudo nmap -sV -p 22,80,443` against a host you own and read off the service
and version for each open port. Explain why a sysadmin cares about the *version*
column during an authorised audit.

*Hint:* `-sV` probes each open port to fingerprint the software. Old versions can
have known vulnerabilities.
**Check yourself:** you can say which software and version is behind each open
port, and why outdated versions matter.

---

### 10. Pick the right tool (hardest, no commands)
For each situation, name which of the four tools you'd reach for first and why:
(a) "the app says it can't reach the DB host on 5432"; (b) "I need to know every
host and open port on my lab network"; (c) "I want to see the actual packets of
a failing connection"; (d) "find which packets on my own HTTP port mention a
certain header."

*Hint:* a→`nc` (one-port reachability), b→`nmap` (sweep), c→`tcpdump` (see
packets), d→`ngrep` (content match). Several could overlap — justify your pick.
**Check yourself:** your reasons mention what each tool is *built* for, not just
that it "works."

---

### 11. Refused vs dropped, read from the packets (harder)
Use netcat to probe a closed port and a (firewalled) dropped port on a host you
own, while `tcpdump` watches. Match each netcat result to what you see on the
wire.

*Hint:* a closed port answers your SYN with a `[R]` (reset) → netcat says
"refused"; a dropped port produces *no* reply → netcat hangs until `-w` fires.
**Check yourself:** you can point at the RST for the refused port and the silence
for the dropped one, and tie each to the netcat behaviour.

---

### 12. Port report from a list (combines lesson 04)
Make a file of `host port` lines (your own hosts only). Write a loop that checks
each with `nc -z -w1` and prints `UP`/`DOWN`, then pipe the result through `grep`
to show only the DOWN ones.

*Hint:* `while read -r h p; do nc -z -w1 "$h" "$p" && ... done < targets.txt`.
`nc -z` sets the exit code, so you can branch on it with no text parsing.
**Check yourself:** the DOWN-only list is correct and you never parsed nc's text
output to get it.

---

### 13. Top talkers from a saved capture (combines lessons 03-04, harder)
Capture ~300 packets of your own loopback traffic to a `.pcap`
(`sudo tcpdump -n -i lo -c 300 -w /tmp/cap.pcap`), generate traffic with `curl`,
then read the file back and rank source addresses with `awk`/`sort`/`uniq`.

*Hint:* `tcpdump -n -r /tmp/cap.pcap | awk '{print $3}' | cut -d. -f1-4 | sort |
uniq -c | sort -rn | head`. Capture first, analyse the file second.
**Check yourself:** you produce a counted, sorted list of the busiest addresses
from a file you captured yourself.

---

### 14. Count the TCP flags in a capture (medium-hard)
Using the same saved `.pcap`, count how many packets carried each TCP flag set
(`[S]`, `[S.]`, `[.]`, `[F.]`, `[R]`). Say what a large count of SYNs with few
SYN-ACKs would suggest.

*Hint:* `grep -oE 'Flags \[[^]]*\]'` then `sort | uniq -c | sort -rn`. Lots of
`[S]` and almost no `[S.]` = connections attempted but not completing.
**Check yourself:** your counts add up roughly to the packet total and you can
read a "half-open" pattern from them.

---

### 15. Scan to a host list, then act on it (combines lessons 01-02, hardest)
On your own lab subnet, run `nmap` with greppable output to produce the list of
IPs that have port 22 open, save it to a file, and describe (do not run blindly)
how you'd loop that file with `ssh -o BatchMode=yes` to check each box.

*Hint:* `sudo nmap -p22 --open -oG - <your/24> | grep '22/open' | awk '{print
$2}' > hosts.txt`, then a `while read` loop with a short `ConnectTimeout`.
**Check yourself:** you have a clean `hosts.txt` of SSH-reachable IPs and a loop
plan that won't hang on a dead host — and you confirmed the range is yours first.

---

### 16. Prove a header is really on the wire (combines lesson 04, harder)
With your own plaintext HTTP server running, use `ngrep` to match a specific
header (say `User-Agent:`) and pipe the matches through `grep -o`/`sort`/`uniq
-c` to tally the distinct values you sent with a few different `curl -A` calls.

*Hint:* `sudo ngrep -l -q -W single -d lo 'User-Agent:' port 8080 | grep -oiE
'User-Agent: .*' | sort | uniq -c`. Drive it with `curl -A name ...`.
**Check yourself:** the tally shows each `-A` value you used, proving the header
left your machine — and the same match on port 443 finds nothing in the body.
