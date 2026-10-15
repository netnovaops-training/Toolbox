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
