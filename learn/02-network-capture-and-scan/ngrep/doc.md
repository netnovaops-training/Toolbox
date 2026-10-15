> **what:** ngrep — grep for the network; match a pattern inside live packet payloads
> **status:** trying
> **tags:** networking, ngrep, packets, capture, grep, payload
> **last-used:** 2026-10-15

# ngrep — "grep for the network"

## AUTHORIZATION FIRST (read this before anything)

> Like `tcpdump`, `ngrep` reads raw traffic off an interface and can see
> payloads that are not yours. Only run it on **your own machine / network** or
> with **explicit written permission**. The examples target loopback and your
> own test traffic. Practise in a VM/lab.

## What it is

`ngrep` is `tcpdump` with a text-search brain. Instead of dumping every packet,
it lets you say "show me only packets whose payload matches this pattern" — the
same way `grep` searches lines of a file. If you already know `grep`, you
already understand `ngrep`'s job: find the needle in the live network haystack.

The mental model: `tcpdump` watches the doorway and writes down every packet;
`ngrep` watches the doorway but only speaks up when a packet *contains the words
you asked for*. That makes it great for questions like "show me every packet
mentioning this hostname" or "find the request with this header."

## The networking concept behind it

`ngrep` matches against the **payload** — the application-layer data riding
inside TCP/UDP. That is powerful for plaintext protocols (HTTP, DNS, SIP) where
the interesting content is right there in readable text. It is also a direct
demonstration of why encryption matters: on plain HTTP, `ngrep` can pull out a
`User-Agent` or a `Host` header instantly; on HTTPS, the payload is encrypted
and there is nothing readable to match. Seeing both cases side by side teaches
the plaintext-vs-TLS lesson better than any slide.

Where it fits among the capture tools:

- `tcpdump` — see **all** packets, filter by host/port/protocol. The workhorse.
- `ngrep` — filter by **content** in the payload. The text-search specialist.
- `nmap` — not a capture tool at all; it *probes* hosts to map open ports.

## Key options

- `-d <iface>` — which interface to listen on (`-d lo` = loopback,
  `-d any` = all).
- `-q` — **quiet**: only print packets that match (and their payload), not the
  hash-mark noise for non-matching packets.
- `-t` — print a **timestamp** on each match.
- `-i` — **case-insensitive** match (just like `grep -i`).
- `-l` — **line-buffered** output, so matches appear immediately in a pipe.
- `-W byline` — print payloads with real line breaks (much easier to read HTTP).
- `-O <file>` — save matching packets to a pcap file; `-I <file>` — read from one.

After the options comes the **search pattern** (a regular expression), and then
an optional **BPF filter** (`port 80`, `tcp`, `host ...`) exactly like
`tcpdump`'s. So a command reads: `ngrep [opts] 'PATTERN' <bpf filter>`.

## Reading the output

For each matching packet, `ngrep` prints a header line (source → destination,
protocol) and then the matched payload. In quiet mode (`-q`) you skip everything
that didn't match, so the screen shows only the hits — which is usually what you
want. Non-matching packets otherwise show as `#` marks ticking by, a quick sign
that traffic is flowing even when nothing matches yet.

## Common uses on the job

```bash
# Show every packet on your loopback HTTP port that mentions "Host:" (readable with byline):
sudo ngrep -d lo -q -W byline 'Host:' port 8080

# Case-insensitive hunt for a User-Agent in your own traffic:
sudo ngrep -d lo -l -q -i 'User-Agent:'

# Match a specific hostname string on the HTTPS port (you'll see it in the
# handshake/SNI, but NOT the encrypted body — a great teaching contrast):
sudo ngrep -d lo -qt 'example.com' port 443

# Save matches to a pcap for later analysis:
sudo ngrep -d lo -qt -O /tmp/http-matches.pcap 'GET ' port 8080
```

## Common mistakes

- **Expecting results from HTTPS payloads.** Encrypted traffic has nothing
  readable to match. Use a plaintext port for learning, and note the contrast.
- **Wrong interface.** Same trap as `tcpdump`: match the interface your traffic
  actually uses (`-d any` if unsure).
- **Forgetting it's a regex.** The pattern is a regular expression; special
  characters (`.`, `*`, `?`) have regex meaning unless escaped.
- **Reading other people's content.** On a shared segment the payloads may not
  be yours. Only do this where you're authorised.

## Does it need sudo/root?

**Yes**, for the same reason as `tcpdump`: reading raw payloads off an interface
is privileged. Run it with `sudo`. Reading back a pcap file you already captured
(`-I file`) does not need root.
```
