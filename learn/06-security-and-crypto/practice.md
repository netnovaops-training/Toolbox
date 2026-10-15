> **what:** Practice exercises for keys, certificates, and encryption — openssl and gpg
> **status:** trying
> **tags:** security, crypto, tls, certificates, gpg, encryption, practice
> **last-used:** 2026-10-15

# Practice: keys, certs, and encryption (openssl, gpg)

Everything here creates or handles cryptographic material. **Do all of it in a
throwaway VM or container, in a scratch directory, with throwaway test keys.**
Never point these at real production keys, `/etc/ssl`, or your real `~/.gnupg`
while learning. A quick sandbox:

```bash
mkdir -p ~/crypto-practice && cd ~/crypto-practice
# For gpg, keep your real keyring untouched by using a temporary one:
export GNUPGHOME="$PWD/gnupg" && mkdir -p "$GNUPGHOME" && chmod 700 "$GNUPGHOME"
```

> WARNING: For gpg, generate a NEW test key for these drills. A lost private key
> or passphrase means the encrypted data is gone permanently — practise before
> you ever rely on it.

Work from easy to hard. Try each before peeking at the hint.

---

## 1. Make and protect a private key (easy)

Generate a 2048-bit RSA private key in your scratch dir, then set its
permissions so only you can read it.

**Hint:** One `openssl genrsa` command with `-out` for the filename and the bit
length at the end. Then a `chmod` that leaves read/write for the owner only.

**Check yourself:** `ls -l` shows the key as `-rw-------` (600), and you can say
in one sentence why a private key must never be world-readable.

---

## 2. Public from private (easy)

From the key in exercise 1, extract its public key into a separate file.

**Hint:** `openssl rsa` with a flag that means "output the public part only."

**Check yourself:** You have two files; you can explain which one is safe to
share and which must stay secret.

---

## 3. Read a certificate's expiry (easy)

Connect to a real public site over TLS and print just the certificate's "valid
from / valid until" dates.

**Hint:** `openssl s_client -connect host:443 -servername host`, prefixed with
`echo |` so it doesn't hang, piped into `openssl x509 -noout -dates`.

**Check yourself:** You see `notBefore=` and `notAfter=` dates, and you know
`-servername` sends SNI so a multi-site server hands you the right cert.

---

## 4. Build a CSR with a SubjectAltName (medium)

Create a certificate signing request for `example.com` that includes both
`example.com` and `www.example.com` in its SubjectAltName list, then read the
CSR back to confirm the SAN entries are present.

**Hint:** You need a small config passed with `-config`, and you can feed it
inline with process substitution `<(cat <<'EOF' ... EOF)`. Verify with
`openssl req -text -noout`.

**Check yourself:** The decoded CSR shows both `DNS:` names, and you can explain
why SAN (not CN) is what browsers actually check.

---

## 5. Self-signed cert, then decode it (medium)

Generate a self-signed certificate (valid 365 days) and its key in one command,
then decode the certificate to read its issuer and validity.

**Hint:** `openssl req` with `-x509`, `-days 365`, `-nodes`, `-keyout`, `-out`,
and a `-subj` string. Decode with `openssl x509 -noout -text`.

**Check yourself:** Issuer and Subject are the same (that's what "self-signed"
means), and you can state why browsers warn on these and where they're
appropriate (testing/internal only).

---

## 6. Does this key match this cert? (harder)

Using the key and cert from exercise 5, prove they belong together with the
modulus-fingerprint trick. Then deliberately make a *second*, unrelated key and
show that it does **not** match the cert.

**Hint:** `openssl rsa -noout -modulus -in key | openssl md5` and
`openssl x509 -noout -modulus -in cert | openssl md5`. Compare the two hashes
(piping both into `uniq` is a neat check).

**Check yourself:** The real pair produces identical hashes; the mismatched pair
produces two different ones. You can explain this is the #1 cause of "web server
won't start after a cert renewal."

---

## 7. Encrypt and decrypt to yourself with gpg (medium)

In your temporary keyring, generate a throwaway key, encrypt a file to it, and
decrypt it back. Confirm the round-trip is identical.

**Hint:** `gpg --quick-generate-key`, then `gpg -e -r <you>` to encrypt and
`gpg -o out -d file.gpg` to decrypt. `diff` the result against the original.

**Check yourself:** `diff` reports no differences, and you can explain that you
encrypted with the *public* key and decrypted with the *private* one.

---

## 8. Symmetric vs asymmetric (harder — think it through)

Encrypt the same file two ways: once with a passphrase only (`-c`) and once to a
recipient key (`-e -r`). Then explain, in two or three sentences, when you'd
choose each on the job.

**Hint:** Symmetric needs only a shared password (no keys); asymmetric needs the
recipient's public key. Think about how you'd share the secret in each case.

**Check yourself:** You can say symmetric suits a quick personal backup (you
remember the passphrase), and asymmetric suits sending to someone else without
ever sharing a password.

---

## 9. Verify a signature — and catch tampering (harder)

Sign a file with your test key (detached, armored), verify it, then change one
byte of the original file and verify again. Observe the result.

**Hint:** `gpg --detach-sign --armor file` makes `file.asc`;
`gpg --verify file.asc file` checks it. Append a character to the file between
the two verifies.

**Check yourself:** The first verify says "Good signature"; after tampering it
says "BAD signature." You can explain what a good signature does and does not
prove (authenticity + integrity, *given* you trust the signer's key).

---

## 10. Inspect without decrypting (hardest)

Take a gpg-encrypted file and, without decrypting it, determine which key(s) it
was encrypted to. Then explain what "No secret key" would mean if you tried to
decrypt a file encrypted to someone else.

**Hint:** `gpg --batch --list-packets file.gpg` dumps the structure, including
recipient key IDs.

**Check yourself:** You can read a key ID out of the packet list, and you can
explain that "No secret key" means the file was encrypted to a key whose private
half you don't hold — so you simply cannot read it.
