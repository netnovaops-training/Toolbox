> **what:** dig — look up DNS records to see how names turn into addresses
> **status:** trying
> **tags:** networking, dns, dig, resolution, debugging
> **last-used:** 2026-10-15

# dig — DNS lookup tool

## What it is

`dig` (domain information groper) asks a DNS server a question and prints the
full answer. DNS is the internet's phone book: it turns a **name** people can
remember (`example.com`) into an **address** machines can route to
(`93.184.216.34`). `dig` is how a sysadmin inspects that phone book directly,
instead of trusting whatever the browser or OS decided to cache.

```bash
dig example.com              # full answer for example.com's address (A record)
dig example.com +short       # just the address, nothing else
```

## The networking concept behind it

Almost every network action starts with a name lookup. When something "can't
connect," the very first question is: *did the name resolve, and to the right
address?* DNS is a hierarchy of record types, each answering a different
question about a name:

- **A** — the IPv4 address for a name.
- **AAAA** — the IPv6 address.
- **CNAME** — an alias ("this name is really that other name").
- **MX** — which mail servers handle email for the domain.
- **NS** — which name servers are authoritative for the domain.
- **TXT** — free-form text, used for things like SPF and domain verification.
- **SOA** — the "start of authority" record: who owns the zone and its timers.
- **PTR** — the reverse: an address back to a name.

Understanding that a name can point to a CNAME that points to another name that
finally has an A record is the kind of thing that untangles a real outage.

## Key options and syntax

The general shape is: `dig @server name type +options`

- `@9.9.9.9` — ask a **specific** DNS server (here the public Quad9 resolver)
  instead of your system default. Great for "is it *my* resolver that's stale,
  or is the record actually wrong?"
- `name` — the domain you are asking about.
- `type` — `A`, `AAAA`, `MX`, `NS`, `TXT`, `SOA`, `ANY`, etc. Defaults to `A`.
- `+short` — print only the answer value(s), nothing else. The everyday mode.
- `+noall +answer` — show only the Answer section (less noise than full output).
- `+trace` — walk the delegation from the root servers down, showing each hop.
  The best way to understand *how* a name is resolved.
- `-x <address>` — do a **reverse** lookup (address → name).

## How to read the output

Full `dig` output has labelled sections. The two that matter most:

```
;; QUESTION SECTION:
;example.com.            IN  A          <- what you asked

;; ANSWER SECTION:
example.com.     3600    IN  A  93.184.216.34   <- what you got back
```

In the answer line: the **name**, the **TTL** (3600 = seconds this answer may be
cached), the class (`IN` = internet), the **type** (`A`), and the **value**.

- `status: NOERROR` at the top = the query succeeded.
- `status: NXDOMAIN` = that name does not exist.
- `status: SERVFAIL` = the server tried but failed (often a broken zone or a
  resolver that can't reach the authoritative servers).
- An empty Answer section with NOERROR = the name exists but has no record of
  the type you asked for.

## Common uses on the job

```bash
dig example.com +short                 # quick: what IP does this name give?
dig @1.1.1.1 example.com +short        # ask a different resolver to compare
dig example.com MX +short              # where does this domain's email go?
dig example.com NS +short              # who is authoritative for this domain?
dig example.com TXT +short             # SPF / verification records
dig -x 93.184.216.34 +short            # reverse: which name owns this address?
dig example.com +trace                 # full root-to-answer delegation walk
```

A classic triage move: if your app can't reach a host, run `dig name +short` on
the server. No answer → DNS is the problem. Wrong answer → stale cache or a bad
record. Right answer but still no connection → the problem is lower down
(routing, firewall, the service itself), so move to `curl`, `nc`, or `tcpdump`.

## More options that earn their keep on the job

- `+noall +answer` — the clean everyday view: drops the comment/question/stats
  noise and shows only answer lines (name, TTL, type, value). Pair with
  `+ttlid` if you want the TTL emphasised.
- `+trace` — walk the delegation from the root down. Read it top to bottom: root
  servers → TLD (`.com`) servers → the domain's authoritative servers → the final
  answer. If the trace dies partway, the break is at that level of delegation.
- `+dnssec` — show DNSSEC signature records (RRSIG). You don't need the crypto
  detail yet, but recognising the `ad` flag (authenticated data) in output is a
  job-relevant literacy point.
- `-f namelist.txt` — **batch mode**: look up a whole file of names in one run.
  Perfect for auditing a list of hostnames.
- `+norecurse` — ask a server for *only what it already knows* (don't let it go
  ask others). Querying an authoritative server with `+norecurse` tells you the
  real record; querying a resolver tells you the cached one.
- `CAA` / `SRV` / `SOA` record types — CAA says which CAs may issue certs for a
  domain (comes up in TLS work); SRV locates services; SOA carries the zone's
  serial and timers (watch the serial to confirm a zone change propagated).

## How to read the output (deeper)

- **The flags line** (`;; flags: qr rd ra ad;`) is worth knowing: `aa` =
  authoritative answer (you asked the owning server), `ra` = recursion available,
  `ad` = DNSSEC-authenticated. An answer with `aa` is the source of truth; one
  without is somebody's cache.
- **AUTHORITY / ADDITIONAL sections** appear on fuller output and name the servers
  responsible — useful when an answer looks wrong and you want to go straight to
  the authoritative source with `dig @that-ns name +norecurse`.
- **Watch the TTL count down.** Run the same `dig` twice a few seconds apart
  against a caching resolver; a shrinking TTL means you're hitting a cache, and
  tells you how long a stale answer will linger after a change.

## Combine it (pipe dig into earlier-lesson tools)

Because `+short` prints bare values, one per line, it chains beautifully:

```bash
# Reverse-lookup every A record a name has (dig -> xargs -> dig, lesson 03/04):
dig example.com +short | xargs -rn1 dig +short -x

# Compare two resolvers and show only the difference (diff; silent = they agree):
diff <(dig @1.1.1.1 example.com +short) <(dig @9.9.9.9 example.com +short) \
  && echo "resolvers agree"

# Ask every authoritative NS the same question — do they all match? (loop + dig):
for ns in $(dig example.com NS +short); do
  printf '%s -> %s\n' "$ns" "$(dig @"$ns" example.com +short | paste -sd, -)"
done

# Audit a file of hostnames, flagging any that fail to resolve (while-read + awk):
while read -r name; do
  ip=$(dig "$name" +short | tail -n1)
  printf '%s\t%s\n' "$name" "${ip:-NO-ANSWER}"
done < names.txt | column -t
```

## Common mistakes

- **Trusting one resolver.** Your local resolver may be caching an old answer.
  Compare with `@1.1.1.1` or `@9.9.9.9` to see the public truth.
- **Forgetting TTL.** A record you just changed may still be cached elsewhere
  until its TTL expires. `dig` shows the remaining TTL counting down.
- **Confusing "no A record" with "domain doesn't exist."** NXDOMAIN means the
  name is gone; an empty answer with NOERROR means the name exists but not for
  that record type.
- **Reaching for `ping` to test DNS.** `ping` both resolves *and* sends ICMP; if
  it fails you don't know which part broke. `dig` isolates the DNS step.

## Does it need sudo/root?

No. `dig` only sends normal DNS queries; any user can run it. (`host` and
`nslookup` are simpler cousins that do the same basic lookups.)
```
