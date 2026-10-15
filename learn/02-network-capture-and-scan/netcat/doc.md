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
