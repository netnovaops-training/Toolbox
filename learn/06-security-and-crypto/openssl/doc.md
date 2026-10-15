> **what:** openssl — the Swiss-army knife for keys, certificates, TLS connections, and hashing
> **status:** trying
> **tags:** security, crypto, tls, certificates, keys, pki, sysadmin
> **last-used:** 2026-10-15

# openssl — keys, certificates, and TLS

## What it is

`openssl` is the command-line front end to the OpenSSL library — the same crypto
code that secures most of the internet. From one command you can:

1. **Make keys** — generate RSA or elliptic-curve (ECDSA/Ed-style) private keys.
2. **Make certificate requests (CSRs)** — the file you send to a Certificate
   Authority (CA) to get a signed certificate.
3. **Make and inspect certificates** — self-signed certs for testing, and
   reading the guts of any `.crt`/`.pem`/`.cer` file.
4. **Test live TLS connections** — connect to a server and see its certificate,
   chain, protocol version, and cipher (`s_client`).
5. **Convert formats** — PEM ⇄ DER, pull keys and certs out of `.pfx`/`.p12`
   and `.p7b` bundles.
6. **Hash and fingerprint** — compute digests and modulus fingerprints to prove
   two files belong together.

The mental model you must hold onto: a **private key** is a secret you generate
and guard forever; a **CSR** is a public request built from that key; a
**certificate** is that request after a CA (or you, for self-signed) signs it.
The private key never leaves your server, and it is never inside the CSR or the
certificate. Everything else is public.

## Why it matters on the job

TLS certificates are everywhere a sysadmin or security person works: web
servers, load balancers, mail servers, internal services, VPNs. The recurring
tasks are:

- "The site shows a cert error" → connect with `s_client`, read the expiry and
  the chain, find the broken link.
- "We need a cert for `service.example.com`" → generate a key + CSR, send the
  CSR to the CA, install the returned cert.
- "Does this private key actually match this certificate?" → compare their
  modulus fingerprints.
- "The vendor gave us a `.pfx`" → extract the key and certs into PEM the web
  server can use.

These come up constantly, and fumbling them causes outages. Being fluent with
`openssl` is a core competency for infra and security roles.

## The big idea: keys vs CSRs vs certificates

```
  private.key  --(you keep this secret forever)
       |
       |  openssl req -new ...
       v
  request.csr  --(public: contains your public key + who you are; send to a CA)
       |
       |  CA signs it  (or you self-sign for testing)
       v
  domain.crt   --(public: your public key + identity + the CA's signature)
```

- The **private key** proves you are you. If it leaks, the cert is worthless and
  must be revoked. Treat it like a password.
- The **CSR** is throwaway-ish: it carries your public key and your details
  (country, org, common name, and the important **SubjectAltName** list of
  domains). You can always make a new CSR from the same key.
- The **certificate** is what the server presents to clients. It expires
  (commonly 90 days for Let's Encrypt, up to ~1 year for others), which is why
  "renew the cert" is a routine chore.

## Generating keys

RSA, no passphrase (what a web server usually needs, since it must start
unattended):

```bash
openssl genrsa -out private.key 2048      # 2048-bit RSA; use 4096 for extra margin
```

RSA, encrypted with a passphrase (you must type it to use the key):

```bash
openssl genrsa -aes256 -out private.key 2048
```

Elliptic curve (smaller, faster, modern — increasingly the default):

```bash
openssl ecparam -name prime256v1 -genkey -out private.key   # P-256, a solid default
openssl ecparam -list_curves                                # see available curves
```

Remove or add a passphrase later:

```bash
openssl rsa -in private.key -out private_unp.key            # strip the passphrase
openssl rsa -aes256 -in private.key -out private_enc.key    # add one
```

Pull the public key out of a private key:

```bash
openssl rsa -pubout -in private.key -out public.key
```

## Making a CSR

Interactive (it asks you the questions):

```bash
openssl req -new -newkey rsa:2048 -nodes -keyout private.key -out request.csr
#   -new        : a new request
#   -newkey rsa:2048 : also generate a fresh 2048-bit key at the same time
#   -nodes      : "no DES" = don't encrypt the key with a passphrase
#   -keyout/-out: where to write the key and the CSR
```

From an existing key:

```bash
openssl req -new -key private.key -out request.csr
```

The single most important field is the **Common Name (CN)** and, in modern
practice, the **SubjectAltName (SAN)** list — browsers ignore CN and require the
domain to appear in SAN. For multiple domains you feed a small config file; see
`examples.sh`.

## Self-signed certificates (for testing only)

```bash
openssl req -newkey rsa:2048 -nodes -keyout domain.key \
  -x509 -days 365 -out domain.crt
```

`-x509` says "skip the CSR step and sign it yourself." Self-signed certs make
browsers warn (nobody trusts you as a CA), so they are for **local testing and
internal tools**, not public sites — for public sites you send a CSR to a real
CA (or use Let's Encrypt/`certbot`).

## Testing a live server with s_client

This is the one you'll reach for most in incidents:

```bash
echo | openssl s_client -connect example.com:443 -showcerts
```

- `echo |` feeds an empty line so the session closes instead of hanging.
- `-connect host:port` — where to go.
- `-showcerts` — print the whole certificate chain the server sent.
- `-servername example.com` — send **SNI**, so a server hosting many sites
  gives you the right cert (almost always needed today).
- `-tls1_2` / `-tls1_3` — force a protocol version (test what a server supports).
- `-cipher 'AES128-SHA'` — test a specific cipher.

Pipe it into `openssl x509` to read just the human parts (see examples) — expiry
dates, issuer, and SAN list. "When does this cert expire?" is answered here.

## Inspecting and verifying

Read a certificate, a CSR, or a key in human form:

```bash
openssl x509 -noout -text -in certificate.crt    # decode a certificate
openssl req  -noout -text -in request.csr        # decode a CSR
openssl rsa  -noout -text -in private.key        # decode/verify an RSA key
openssl rsa  -check     -in private.key          # sanity-check key consistency
```

**Prove a key and a certificate belong together** (a classic deploy check — if
these don't match, the server won't start):

```bash
openssl rsa  -noout -modulus -in private.key    | openssl md5
openssl x509 -noout -modulus -in certificate.crt | openssl md5
# The two hashes must be identical.
```

## Converting formats

```bash
openssl x509 -in cert.crt -inform der -outform pem -out cert.pem   # DER -> PEM
openssl x509 -in cert.pem -outform der -out cert.der               # PEM -> DER
openssl pkcs12 -in cert.pfx -nocerts -nodes -out key.pem           # key out of a .pfx
openssl pkcs12 -in cert.pfx -nodes -out key_and_certs.pem          # key + certs out of .pfx
openssl pkcs7  -inform DER -print_certs -in cert.p7b -out certs.pem # certs out of .p7b
```

PEM is the base64 `-----BEGIN ...-----` text format Linux tools expect. DER is
the binary form. PFX/P12 is a password-protected bundle common on Windows.

## Hashing / digests

OpenSSL also computes message digests, handy for fingerprints and integrity:

```bash
openssl dgst -sha256 somefile          # SHA-256 of a file
echo -n "data" | openssl dgst -sha256  # SHA-256 of a string
```

(For *password* storage you would use a purpose-built password hash like bcrypt
or Argon2, not a bare SHA — a raw digest is for file integrity and fingerprints,
not passwords.)

## Common mistakes

- **Leaking or mishandling the private key.** It must stay secret and on the
  server. Never paste it anywhere, never commit it, never email it. If it leaks,
  the cert must be revoked and replaced.
- **Forgetting SubjectAltName.** A cert with only a CN and no SAN entry for the
  domain is rejected by modern browsers. Always set SAN.
- **Forgetting `-servername` (SNI).** Against a multi-site server, leaving it off
  gives you the wrong (default) certificate and a confusing "it doesn't match"
  result.
- **Trusting self-signed certs in production.** They're for testing; real
  clients will warn or refuse. Use a real CA / `certbot` for anything public.
- **`s_client` appears to hang.** It's waiting for input — prefix with `echo |`
  (or `printf 'Q\n' |`) so the session closes.
- **Key/cert mismatch on deploy.** If the modulus check above differs, you
  installed the wrong pair — the number one cause of "web server won't start
  after cert renewal."

## A worked example: a cert that won't verify

A browser or `curl` says "certificate verify failed" against
`service.example.com`, but the cert looks fine when you open it. Nine times out of
ten the problem is a **missing intermediate** — the server sent its leaf cert but
not the chain up to a trusted root. Here's the reasoning and the commands:

1. See what the server actually sends:
   `echo | openssl s_client -connect service.example.com:443 -servername service.example.com -showcerts`
   Count the `-----BEGIN CERTIFICATE-----` blocks. Just one? That's your bug — the
   intermediate isn't being served.
2. Confirm by asking openssl to verify the chain itself:
   `echo | openssl s_client -connect service.example.com:443 -servername service.example.com`
   and read the `Verify return code:` line at the bottom. `0 (ok)` is good;
   `21 (unable to verify the first certificate)` means the chain is incomplete.
3. Read the leaf's expiry and issuer to rule out the other common causes
   (expired, or issued for the wrong name):
   `... | openssl x509 -noout -dates -subject -issuer`.

So three suspects, in order: expired (`notAfter` in the past), wrong name (domain
not in the SAN list), or broken chain (missing intermediate). `s_client` plus
`x509` settles which one every time — no guessing.

## Combine it with other tools

`openssl` subcommands are built to pipe into each other and into the lesson-04
text tools:

- **Read just the human parts of a live cert** (the single most useful combo):
  `echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null \
  | openssl x509 -noout -dates -subject -issuer`.
- **Chain one openssl into another** — connect, then decode:
  `... s_client ... | openssl x509 -noout -text | grep -A1 'Subject Alternative Name'`
  shows exactly which domains the cert covers.
- **Compute days-until-expiry** by combining with `date` (great for a monitoring
  script): read `notAfter`, convert both to epoch seconds with `date -d`, subtract.
- **Verify a chain offline** against a CA file: `openssl verify -CAfile ca.pem cert.pem`
  prints `OK` or the exact reason it failed.
- **Pull one field out** with `grep`: `openssl x509 -noout -text -in cert.crt | grep -E 'Not After|DNS:'`.

The habit: `genrsa`/`req` *make* material, `s_client` *fetches* it, `x509`/`req`
*decode* it, and `grep`/`awk`/`date` turn the decode into a one-line answer.

## Does it need root?

The crypto operations themselves (generating keys, making CSRs, inspecting,
converting, `s_client`) **do not need root** — run them as a normal user in a
directory you own. You hit root only when you **write keys/certs into
system-owned paths** (like `/etc/nginx/ssl/` or `/etc/ssl/`) or **restart the
service** that uses them. Generate in your own working directory first, inspect,
then `sudo` only for the final install + reload.

> WARNING: Commands that generate, encrypt, decrypt, or overwrite keys and
> certificates change real secrets on disk. A private key that leaks compromises
> everything it secures. Do all practice in a throwaway VM/container, in a
> scratch directory, with throwaway test keys — never point these at real
> production keys or `/etc/ssl` while learning.
