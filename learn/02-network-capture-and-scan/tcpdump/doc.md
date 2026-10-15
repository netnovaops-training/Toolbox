> **what:** tcpdump — capture and inspect the actual packets on a network interface
> **status:** trying
> **tags:** networking, tcpdump, packets, capture, pcap, sniffing, root
> **last-used:** 2026-10-15

# tcpdump — packet capture and analysis

## AUTHORIZATION FIRST (read this before anything)

> `tcpdump` reads the raw traffic on a network interface — potentially
> **everyone's** traffic on that segment, not just yours. Capturing traffic you
> are not authorised to see is a serious matter and can be illegal. Only capture
> on **your own machine / your own network**, or where you have **explicit
> written permission**. In this lesson, capture on `lo` (loopback) or your own
> host's interface for your own test traffic. Practise in a VM/lab.

## What it is

`tcpdump` taps a network interface and prints a line for every packet that goes
by (or saves them to a file). Where `curl` and `nc` *make* traffic, `tcpdump`
*watches* it. It is the tool you reach for when the higher-level tools disagree
with reality and you need to see what is actually on the wire: Is the packet
even leaving? Is it arriving? What is the server really sending back?

The mental model: a network interface is like a doorway that packets flow
through. `tcpdump` stands in the doorway with a clipboard, writing down each
packet that passes — who it's from, who it's to, what protocol, how big, which
TCP flags. You can filter the clipboard to only the packets you care about.

## The networking concept behind it

This is where the layers become real. Each packet you see has an **IP** layer
(source and destination addresses), usually a **TCP** or **UDP** layer (source
and destination ports, plus TCP flags like SYN/ACK/FIN that drive the
handshake), and a **payload**. Watching a TCP connection in `tcpdump`, you can
literally see the three-way handshake (`SYN`, `SYN-ACK`, `ACK`), the data, and
the teardown (`FIN`). Seeing that once makes the whole model click, and it is
the skill that separates "the website is down" from "the SYN leaves but no
SYN-ACK comes back, so it's a firewall or the server isn't listening."

A crucial safety and privacy point you learn here: on an **unencrypted**
protocol (plain HTTP, telnet, old FTP) the payload is readable — passwords and
all. This is *why* we use HTTPS and SSH. `tcpdump` is how you prove to yourself
that plaintext really is exposed, which is a powerful lesson — and exactly why
you only ever run it on traffic you're allowed to see.

## Key options

- `-i <iface>` — which interface to capture on (`-i lo` = loopback,
  `-i any` = all). Run `tcpdump -D` to list interfaces.
- `-n` — don't resolve addresses to names (`-nn` also skips port-name lookup).
  Faster and clearer; you see numbers, not guesses.
- `-e` — also print the link-layer (Ethernet/MAC) header.
- `-c <num>` — stop after capturing `num` packets (great for a quick sample).
- `-w <file.pcap>` — write raw packets to a file (open later in Wireshark or
  with `-r`).
- `-r <file.pcap>` — read packets back from a saved file.
- `-A` — print packet payloads as ASCII text.
- `-X` — print payloads as hex **and** ASCII.
- `-s0` — capture the full packet (older versions truncated by default).
- `-v` / `-vv` — more detail per packet.
- `-Q in|out|inout` — capture only one direction.

Everything after the options is a **filter expression** (BPF): `host`, `port`,
`tcp`, `udp`, `icmp`, `src`, `dst`, combined with `and` / `or` / `not`.

## Reading the output

A typical line (`tcpdump -n -i lo`):

```
12:00:01.123456 IP 127.0.0.1.54321 > 127.0.0.1.8080: Flags [S], seq 0, ...
```

- `12:00:01.123456` — timestamp.
- `IP 127.0.0.1.54321 > 127.0.0.1.8080` — from source `IP.port` **to**
  destination `IP.port` (the `>` points at the destination).
- `Flags [S]` — TCP flags. `[S]` = SYN (start), `[S.]` = SYN-ACK, `[.]` = ACK,
  `[P.]` = push (data), `[F.]` = FIN (finish), `[R]` = reset.

Watch a full connection and you'll see `[S]` → `[S.]` → `[.]` (handshake), then
data, then `[F.]`/`[F.]` (teardown). No `[S.]` coming back after your `[S]` means
the other side never answered — the single most useful thing packet capture
tells you.

## Common uses on the job

```bash
# Watch all traffic to/from one host on one port (numeric, loopback example):
sudo tcpdump -n -i lo port 8080

# Just the first 10 packets of a conversation, then stop:
sudo tcpdump -n -i lo -c 10 host 127.0.0.1 and port 8080

# Save a capture to a file to open in Wireshark later:
sudo tcpdump -n -i lo -c 100 port 8080 -w /tmp/capture.pcap

# Read a saved capture back:
tcpdump -n -r /tmp/capture.pcap

# See ICMP (ping) packets only:
sudo tcpdump -n -i lo icmp

# Which hosts are talking most (top talkers) — count by source address:
sudo tcpdump -n -i lo -t -c 200 | awk '{print $3}' | cut -d. -f1-4 | sort | uniq -c | sort -nr | head
```

## Common mistakes

- **Wrong interface.** Capturing on `eth0` while your traffic goes over `wlan0`
  (or `lo`) shows nothing. Use `tcpdump -D` to list, or `-i any` to catch all.
- **No packet limit.** On a busy link, `tcpdump` floods your screen. Add
  `-c <num>` for a sample, and a tight filter.
- **Name resolution noise and delay.** Forgetting `-n`/`-nn` makes `tcpdump`
  do reverse DNS on every packet — slow, and it hides the numbers you need.
- **Capturing more than you're allowed to.** On a shared network you may see
  other people's traffic. Don't, unless authorised. Filter to your own host.
- **Expecting to read HTTPS.** Encrypted payloads are gibberish in `-A`/`-X`;
  that's the point of TLS. You can still see the handshake and SNI, not the body.

## Does it need sudo/root?

**Yes — almost always.** Capturing raw packets means putting the interface into
a privileged mode, which ordinary users can't do. You will typically run
`sudo tcpdump ...`. (Some systems grant the capability to a group so you can run
it without full root, but assume `sudo` is required.) This is a good moment to
understand *why* a tool needs root: it's reaching below the normal per-process
network view to see the raw interface.
```
