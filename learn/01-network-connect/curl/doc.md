> **what:** curl — command-line tool to make HTTP(S) requests and move data over the network
> **status:** trying
> **tags:** networking, curl, http, https, api, debugging
> **last-used:** 2026-10-15

# curl — the network Swiss army knife

## What it is

`curl` ("client for URLs") makes a network request from the command line and
prints what comes back. Most often that is an HTTP or HTTPS request to a web
server or an API, but it also speaks FTP, SFTP, and more. If a browser can fetch
it, `curl` can usually fetch it too — but without the browser, so you see the
raw truth: status codes, headers, redirects, timings.

The mental model: a browser *hides* the conversation and shows you a rendered
page. `curl` *shows you the conversation*. That is exactly what you want when
something is broken and you need to know whether the problem is DNS, the
network, TLS, the server, or the application.

```bash
curl https://example.com            # fetch the page and print the body
curl -I https://example.com         # fetch only the response headers
```

## The networking concept behind it

An HTTP request is a short text conversation: your client sends a **request
line** (method + path), some **request headers**, and maybe a **body**; the
server replies with a **status line** (e.g. `HTTP/1.1 200 OK`), **response
headers**, and a body. HTTPS is the same conversation wrapped in TLS encryption.
`curl` lets you see and control every part of that exchange, which is why it is
the first tool you reach for when debugging anything web-shaped on the job:
"is the API up?", "why is this redirecting?", "is the certificate valid?",
"what header is the load balancer adding?".

## Key options

- `-I` — fetch **headers only** (a `HEAD` request). Fast way to check if a site
  is up and what it returns.
- `-s` — **silent**: hide the progress meter (good in scripts and pipes).
- `-k` — **insecure**: skip TLS certificate checking. Use only for testing a
  server with a self-signed cert; never as a habit, because it disables the
  protection HTTPS gives you.
- `-L` / `--location` — **follow redirects** (301/302). Without it, `curl` shows
  you the redirect response and stops.
- `-X` — set the HTTP **method** (`GET`, `POST`, `PUT`, `DELETE`, ...).
- `-A` — set the **User-Agent** header (how you identify your client).
- `-H` — add an arbitrary header, e.g. `-H 'Accept: application/json'`.
- `-d` — send a request **body** (makes it a POST by default).
- `-o file` — write the body to a file instead of the screen.
- `-O` — save to a file named after the URL.
- `-C -` — **resume** an interrupted download where it left off.
- `--proxy` — route the request through a proxy server.
- `-v` — **verbose**: show the whole handshake, headers sent and received, and
  TLS details. The debugging mode.

## How to read the output

With `-I` (or `-v`) the first line is the **status line**:

```
HTTP/2 200
```

- **2xx** success (200 OK, 204 No Content).
- **3xx** redirect (301 moved permanently, 302 found) — add `-L` to follow.
- **4xx** you got it wrong (401 unauthorized, 403 forbidden, 404 not found).
- **5xx** the server got it wrong (500 internal error, 502/503 upstream/down).

The header lines that follow tell you a lot: `Location:` shows where a redirect
points, `Content-Type:` shows what kind of body you got, `Server:` and custom
`X-...` headers reveal proxies and app servers. In `-v` output, lines starting
with `>` are what you **sent**, lines with `<` are what you **received**, and
`*` lines are curl's own notes (DNS, TCP, TLS).

## Common uses on the job

```bash
# Is the service up, and what does it return? (headers only, silent, follow redirects)
curl -sIL https://example.com

# Call a JSON API with a method, a header, and a body:
curl -s -X POST -H 'Content-Type: application/json' \
     -d '{"name":"test"}' https://api.example.com/items

# Find your machine's public IP (what the internet sees you as):
curl -s https://ifconfig.me/ip ; echo

# Download a large file and be able to resume if the connection drops:
curl -O -C - https://example.com/big.iso

# Full TLS/redirect trace when something is mysteriously failing:
curl -v https://example.com
```

## More options that earn their keep on the job

- `-w '<format>'` — **write-out**: print your own variables after the transfer.
  This is the single most useful "senior" curl trick, because it breaks a slow
  request into its phases so you know *which layer* is slow:
  `-w 'dns=%{time_namelookup} connect=%{time_connect} tls=%{time_appconnect} ttfb=%{time_starttransfer} total=%{time_total}\n'`.
  `%{http_code}` and `%{size_download}` are also common.
- `-f` / `--fail` — in a script, make curl **exit non-zero on an HTTP 4xx/5xx**
  instead of happily printing the error page. Lets `if curl -f ...; then` work.
- `--max-time 10` and `--connect-timeout 5` — cap total and connect time so a
  hung endpoint can't wedge your script.
- `--retry 3 --retry-delay 2` — retry transient failures (good for flaky
  networks and rolling deploys).
- `--resolve name:port:ADDRESS` — force a hostname to resolve to an address you
  choose, *without touching DNS or `/etc/hosts`*. This is how you test one
  specific backend behind a load balancer, or a new server before you cut DNS
  over: `curl --resolve example.com:443:192.168.1.50 https://example.com`.
- `-u user:pass` — HTTP basic auth. `-b`/`-c` — send/save cookies (`-c jar.txt`
  saves, `-b jar.txt` replays). `-G` — turn `-d` fields into a GET query string.
- `-T file` — upload a file (PUT). `--data-urlencode` — send form data with the
  encoding handled for you.

## How to read the output (deeper)

- **Exit codes matter in scripts.** `6` = couldn't resolve host (DNS), `7` =
  couldn't connect (TCP/firewall), `28` = timeout, `35`/`60` = TLS problems,
  `22` = HTTP error when you used `-f`. Check `echo $?` right after a failure —
  the number tells you which layer broke before you read a single header.
- **The `-w` timing split is a decision tree.** Big `time_namelookup` → DNS is
  slow (go to `dig`). Big gap between `time_connect` and `time_appconnect` → TLS
  handshake is the cost. Big `time_starttransfer` with everything else fast → the
  *server* is slow to produce the first byte (application, not network).

## Combine it (pipe curl into earlier-lesson tools)

```bash
# Pull one field out of a JSON API without jq (grep + sed, lesson 04):
curl -s https://api.example.com/status | grep -o '"version":"[^"]*"' | sed 's/.*:"//; s/"//'

# Just the status code, for use in a condition:
code=$(curl -s -o /dev/null -w '%{http_code}' https://example.com); echo "$code"

# Measure latency over N requests and average it with awk (lesson 04):
for i in $(seq 1 10); do
  curl -s -o /dev/null -w '%{time_total}\n' https://example.com
done | awk '{sum+=$1; n++} END {printf "avg %.3fs over %d reqs\n", sum/n, n}'

# Save response headers to a scratch file, then grep for a specific one:
curl -sI https://example.com -o "$(mktemp)".hdr && grep -i '^location:' "$_"

# Pull every link out of a page (grep -o) — rough, but a real quick-and-dirty move:
curl -s https://example.com | grep -oE 'https?://[^"<> ]+' | sort -u
```

## Common mistakes

- **Forgetting `-L`** and thinking a site is "broken" when it is just
  redirecting (you got a 301/302 and curl stopped).
- **Using `-k` everywhere.** It silences real certificate problems. If `curl`
  complains about a cert, understand *why* before overriding it.
- **Confusing "no output" with "failure."** A `204 No Content` or a `-I` request
  legitimately returns no body. Use `-v` to see what actually happened.
- **Shell-quoting the body wrong.** Wrap JSON in single quotes so the shell does
  not mangle the double quotes inside.
- **Testing the wrong layer.** If `curl` to an IP works but to a hostname fails,
  the problem is DNS, not the web server — jump to the `dig` lesson.

## Does it need sudo/root?

No. `curl` makes ordinary outbound connections as your normal user. You would
only need elevated rights if you wrote the download to a protected directory
(and even then, better to download somewhere you own, then move it).
```
