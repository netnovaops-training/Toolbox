> **what:** netcat (nc) — read and write raw TCP/UDP connections from the command line
> **status:** trying
> **tags:** networking, netcat, nc, tcp, udp, sockets, troubleshooting
> **last-used:** 2026-10-15

# netcat (nc) — the TCP/UDP plumbing tool

## AUTHORIZATION FIRST (read this before anything)

> Netcat can open listeners and connect to ports on other machines. Only ever
> point it at **your own machines**, or hosts you have **explicit written
> permission** to test. Port-scanning or connecting to systems you don't own can
> be illegal even if you "didn't do any harm." Everything in this lesson targets
> `localhost` or your own lab subnet (`192.168.1.0/24` as a placeholder).
> Practise in a throwaway VM or lab, not on production.

## What it is

`nc` ("netcat") is a tiny tool that does one thing: it moves bytes over a TCP
(or UDP) connection, straight to and from your terminal. Whatever you type goes
down the socket; whatever comes back is printed. It is often called the "TCP/IP
Swiss army knife" because that one simple ability — be one end of a raw
connection — lets you test, probe, and move data in dozens of ways.

The mental model: a network connection has two ends. `nc` can be **either** end.
As a **listener** it waits on a port for someone to connect (`nc -l 5000`). As a
**client** it connects out to a port (`nc host 5000`). Join a listener and a
client and you have a bare pipe between two machines, with no protocol in the
way.

## The networking concept behind it

Every network service — a web server, a database, SSH — is just a program
listening on a **port** and speaking some text or binary protocol over TCP or
UDP. `nc` lets you *be* a client or *be* a server without any of that program.
That makes it the perfect instrument for answering low-level questions:

- "Is this port actually open and accepting connections?" (connectivity test)
- "What does this service say when I connect?" (banner grabbing)
- "Can traffic get from box A to box B on this port at all?" (firewall check)

Because it shows you the raw bytes, `nc` sits one layer *below* `curl`: `curl`
knows HTTP; `nc` knows nothing, which is exactly why it's useful when you're not
sure the problem is even HTTP yet.

## Key options

- `-l` — **listen** mode (be the server end).
- `-p <port>` — set the port (with `-l`, the port to listen on).
- `-k` — keep listening after a client disconnects (serve repeatedly).
- `-v` — **verbose**: say what's happening (connection succeeded/refused).
- `-z` — **zero-I/O**: just check if a port is open, send no data. The scan mode.
- `-u` — use **UDP** instead of TCP.
- `-w <secs>` — timeout, so a check doesn't hang forever.
- `-n` — don't do DNS; use numeric addresses (faster, clearer for tests).

## Common uses on the job

### Test whether a port is open (the everyday one)

```bash
# Is port 5000 on this host reachable? -v report, -z just probe, -w1 timeout 1s.
nc -vz -w1 192.168.1.50 5000
```

You'll see `succeeded!` / `open` or `Connection refused`. This single check
answers "is the service up and is the firewall letting me through?" far faster
than guessing.

### Scan a small range on YOUR OWN host

> Scanning is intrusive. Do it only on hosts you own. For anything bigger than a
> couple of ports, use `nmap` (next tool) which is built for it.

```bash
nc -vz -w1 192.168.1.50 20-25        # check a tiny TCP range on your own box
nc -vzu -w1 192.168.1.50 53          # check a UDP port (e.g. DNS) on your own box
```

### A quick listener to prove connectivity both ways

```bash
# On your own machine A (the listener):
nc -lk 5000
# On your own machine B (the client) — type and press enter; A sees it:
nc 192.168.1.50 5000
```

If text typed on B shows up on A, the path and port are open end to end. This is
the classic "can these two boxes even talk on this port?" test.

### Move a file between two of your machines

```bash
# Receiver (your machine A):
nc -l 5000 > received.tar
# Sender (your machine B):
nc 192.168.1.50 5000 < to_send.tar
```

### Grab a banner (what a service announces)

```bash
# Connect and see what the service says first. -w1 so it doesn't hang.
nc -v -w1 192.168.1.50 22            # an SSH server prints its version banner
```

## A note on nc's `-e` ("execute") option

Classic netcat has an `-e` flag that runs a program (often a shell) and wires it
to the socket. This is the basis of "bind shells" and "reverse shells" — the
exact technique attackers use to get a command prompt on a victim. For that
reason **most modern builds remove `-e` entirely**, and this lesson does not use
it. You should recognise the pattern when you read about it (so you can spot it
in an incident), but there is no legitimate day-job reason to hand-roll a remote
shell with netcat when `ssh` exists.

## How to read the output

- `Connection to 192.168.1.50 5000 port [tcp/*] succeeded!` → open.
- `Connection refused` → something is listening-less or the port is closed (the
  host answered "nobody's home").
- A **hang** (no response until `-w` fires) → often a firewall silently dropping
  packets, which looks different from an active refusal. That difference is a
  real diagnostic clue.

## More ways it earns its keep on the job

- **Send a raw request and read the reply.** `nc` has no protocol, so you can
  hand-type one. Piping a minimal HTTP request in proves the web server answers
  even when `curl` is unavailable or you suspect `curl` itself:
  ```bash
  printf 'GET / HTTP/1.0\r\nHost: 192.168.1.50\r\n\r\n' | nc -w3 192.168.1.50 80
  ```
  The `\r\n` line endings are the real HTTP wire format — a good thing to *see*
  once.
- **Use it as a scriptable yes/no port check.** `nc -z` sets its **exit code**:
  0 if the port is open, non-zero if not. That makes it a clean building block in
  scripts: `if nc -z -w1 192.168.1.50 5432; then echo open; fi`. No parsing of
  text needed.
- **Know the pure-bash fallback.** When `nc` isn't installed, bash itself can
  open a TCP socket: `(echo > /dev/tcp/192.168.1.50/22) 2>/dev/null && echo open`.
  Worth recognising because minimal containers often ship without `nc`.
- `-q <secs>` — after stdin closes, wait N seconds then quit (helps file
  transfers finish cleanly instead of hanging).

## How to read the output (deeper)

Three outcomes, three different meanings — and telling them apart is the whole
value of the tool on the job:

- **"succeeded!" / exit 0** → the TCP handshake completed; a service is listening.
- **"Connection refused" / fast non-zero exit** → the host is up and actively
  said *no one is listening here* (sent a RST). The network path is fine; the
  service is down or on another port.
- **Hang until `-w` fires** → nothing answered at all. Almost always a firewall
  **silently dropping** the packet. "Refused" vs "timed out" is the difference
  between "service is down" and "a firewall is in the way" — don't blur them.

## Combine it (loops and pipelines from earlier lessons)

```bash
# Check a list of ports and summarise open vs closed (loop + arithmetic):
host=127.0.0.1
for p in 22 80 443 5432 8080; do
  if nc -z -w1 "$host" "$p" 2>/dev/null; then echo "$p open"; else echo "$p closed"; fi
done | sort

# Feed a host:port list from a file and flag the reachable ones (while-read + awk):
# file lines look like:  192.168.1.50 5432
while read -r h p; do
  nc -z -w1 "$h" "$p" 2>/dev/null && echo "UP   $h:$p" || echo "DOWN $h:$p"
done < targets.txt | awk '{print}' | sort

# Grab a banner and pull just the version line out of it (grep, lesson 04):
nc -w2 192.168.1.50 22 </dev/null | grep -i ssh
```

## Common mistakes

- **No timeout.** Without `-w`, a probe to a filtered port hangs. Always add
  `-w1` (or similar) to scans and banner grabs.
- **Confusing "refused" with "filtered."** Refused = the host actively said no
  (port closed). Timeout/hang = likely a firewall dropping the packet. They mean
  different things.
- **Using it as a scanner for big ranges.** `nc` works but is slow and noisy;
  `nmap` is the right tool past a couple of ports.
- **Forgetting UDP needs `-u` on both ends.** A TCP listener won't answer a UDP
  client.

## Does it need sudo/root?

Not for connecting out, and not for listening on a **high** port (1024 and
above — the examples here use 5000). Binding a listener to a **privileged** port
(below 1024, e.g. 80 or 443) does require root. Being the *client* never needs
root.
```
