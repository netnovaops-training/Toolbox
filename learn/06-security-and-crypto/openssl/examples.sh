#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# openssl: keys, CSRs, certificates, TLS testing, conversions, and hashing.
#
# WARNING: the key/cert commands below CREATE real cryptographic material on
# disk. They are harmless here ONLY because they write to a throwaway scratch
# directory with throwaway test keys. NEVER run these against real production
# keys, and never point them at /etc/ssl or a web server's key. Practice in a
# disposable VM/container.

set -euo pipefail   # -e stop on error, -u error on unset var, pipefail catch mid-pipe failures

# All keys/certs we make go here and get deleted on exit — nothing leaks.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work"
echo "working in scratch dir: $work"

echo "=== 1) Generate an RSA private key (no passphrase) ==="
# genrsa makes an RSA key; 2048 is the size in bits (4096 for extra margin).
# No passphrase => a server can start unattended. Keep this file SECRET on real
# systems. 'chmod 600' is the habit: only the owner may read a private key.
openssl genrsa -out private.key 2048
chmod 600 private.key

echo "=== 2) Derive the public key from the private key ==="
# -pubout extracts the PUBLIC half, which is safe to share.
openssl rsa -pubout -in private.key -out public.key

echo "=== 3) Sanity-check the private key ==="
# -check verifies the key's internal consistency; -noout hides the raw key dump.
openssl rsa -check -noout -in private.key

echo "=== 4) Generate an ECDSA key (modern, smaller, faster) ==="
# ecparam picks a named curve; prime256v1 (P-256) is a solid default.
openssl ecparam -name prime256v1 -genkey -out ec_private.key
chmod 600 ec_private.key
openssl ecparam -list_curves | head -n 5   # peek at a few available curves

echo "=== 5) Create a CSR from the existing key, non-interactively ==="
# -subj supplies the fields so no prompt appears. CN is the domain.
# Real CAs need a SubjectAltName too (see example 6); example.com is reserved
# for documentation so it's safe to use here.
openssl req -new -key private.key -out request.csr \
  -subj "/C=US/ST=State/L=City/O=Example Org/OU=IT/CN=example.com"

echo "=== 6) Create a CSR WITH SubjectAltName (what browsers actually need) ==="
# Modern browsers ignore CN and require the domain in SAN. We feed a tiny config
# via process substitution <(...) so no extra file is left behind.
openssl req -new -sha256 -key private.key -out request_san.csr -config <(
cat <<'__EOF__'
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C  = US
ST = State
L  = City
O  = Example Org
OU = IT
CN = example.com

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = example.com
DNS.2 = www.example.com
__EOF__
)

echo "=== 7) Read the CSR back in human form (verify before sending to a CA) ==="
# -text decodes it; -noout hides the base64 blob. Check the CN and SAN here.
openssl req -text -noout -in request_san.csr | grep -E "Subject:|DNS:"

echo "=== 8) Generate a SELF-SIGNED certificate (TESTING ONLY) ==="
# WARNING: self-signed certs make browsers warn — never use in production.
# -x509 self-signs; -days sets validity; -nodes = unencrypted key.
openssl req -newkey rsa:2048 -nodes -keyout domain.key \
  -x509 -days 365 -out domain.crt \
  -subj "/C=US/ST=State/L=City/O=Example Org/OU=IT/CN=example.com"
chmod 600 domain.key

echo "=== 9) Decode the certificate we just made ==="
# -text shows issuer, validity dates, and extensions in plain English.
openssl x509 -noout -text -in domain.crt | grep -E "Issuer:|Not Before|Not After|Subject:"

echo "=== 10) Prove a key and a certificate MATCH (classic deploy check) ==="
# If these two hashes differ, the key and cert don't belong together and the
# web server will refuse to start. 'uniq' collapses identical lines: one line
# of output = match, two lines = mismatch.
( openssl rsa  -noout -modulus -in domain.key | openssl md5 ; \
  openssl x509 -noout -modulus -in domain.crt | openssl md5 ) | uniq

echo "=== 11) Convert the certificate PEM -> DER and back ==="
# PEM is the base64 text form; DER is binary. Conversions are lossless.
openssl x509 -in domain.crt -outform der -out domain.der          # PEM -> DER
openssl x509 -in domain.der -inform der -outform pem -out domain2.pem  # DER -> PEM
echo "converted files:"; ls -1 domain.der domain2.pem

echo "=== 12) Hash a file and a string (fingerprints / integrity) ==="
echo "some file contents" > sample.txt
openssl dgst -sha256 sample.txt            # SHA-256 of a file
echo -n "data" | openssl dgst -sha256      # SHA-256 of a string
# Note: for storing PASSWORDS you'd use bcrypt/Argon2, not a bare digest.

echo "=== 13) Test a live server's TLS certificate (READ-ONLY, needs network) ==="
# s_client connects and prints the cert chain. 'echo |' closes the session so it
# doesn't hang. -servername sends SNI (needed on multi-site servers).
# Piping into 'x509' shows just the dates — the "when does it expire?" answer.
# example.com is a real, safe test endpoint. Skipped if there's no network.
if echo | timeout 10 openssl s_client -connect example.com:443 \
      -servername example.com 2>/dev/null >/dev/null; then
  echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null \
    | openssl x509 -noout -dates -subject -issuer
else
  echo "(no network, or connection blocked — skipping the live s_client test)"
fi

echo "=== 14) Force a specific TLS version when probing a server ==="
# Handy for "does this server still allow old TLS?" checks. -tls1_2 pins v1.2.
echo | timeout 10 openssl s_client -tls1_2 -connect example.com:443 \
  -servername example.com 2>/dev/null | grep -E "Protocol|Cipher" || \
  echo "(skipped: no network or TLS1.2 not offered)"

echo "=== 15) COMBINE: build a throwaway CA, sign the CSR, VERIFY the chain ==="
# This mirrors real life: a CA signs your CSR, and clients verify the leaf cert
# against the CA. We make a test root CA, sign request_san.csr from example 6,
# then prove the result chains to the CA with 'openssl verify'. All throwaway.
openssl genrsa -out ca.key 2048 2>/dev/null
chmod 600 ca.key
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt \
  -subj "/C=US/O=Example Test Root CA/CN=Example Test Root CA"
# -CAcreateserial makes the serial-number file the CA needs on first sign.
openssl x509 -req -in request_san.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -days 365 -sha256 -out signed.crt 2>/dev/null
echo "verify the signed leaf against our CA (expect 'OK'):"
openssl verify -CAfile ca.crt signed.crt
echo "note the Issuer is now the CA, not the subject (contrast with self-signed #9):"
openssl x509 -noout -issuer -subject -in signed.crt

echo "=== 16) COMBINE with date: how many days until this cert expires? ==="
# A real monitoring task: alert before a cert lapses. Read notAfter, convert
# both it and 'now' to epoch seconds, subtract, divide by seconds-per-day.
# (date -d is GNU date; guarded so it degrades gracefully if unavailable.)
end="$(openssl x509 -noout -enddate -in signed.crt | cut -d= -f2)"
if exp="$(date -d "$end" +%s 2>/dev/null)"; then
  now="$(date +%s)"
  echo "cert expires in $(( (exp - now) / 86400 )) days ($end)"
else
  echo "(date -d not available here; on Linux this prints days-to-expiry)"
fi

echo "=== 17) COMBINE: fetch a live chain and count the certs it sends ==="
# A missing intermediate is the #1 'certificate verify failed' cause. Count the
# BEGIN CERTIFICATE blocks the server sends: 1 often means a broken chain.
# Also print the 'Verify return code' line — 0 (ok) is healthy. Network-gated.
if echo | timeout 10 openssl s_client -connect example.com:443 \
      -servername example.com 2>/dev/null >/dev/null; then
  chain="$(echo | openssl s_client -connect example.com:443 -servername example.com \
             -showcerts 2>/dev/null)"
  echo "certificates in the chain: $(printf '%s\n' "$chain" | grep -c 'BEGIN CERTIFICATE')"
  echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null \
    | grep -i "Verify return code" || true
else
  echo "(no network — skipping the live chain inspection)"
fi

echo "done — scratch dir and all test keys are about to be deleted"
