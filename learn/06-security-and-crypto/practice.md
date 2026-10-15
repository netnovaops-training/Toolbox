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

---

## 11. Sign a CSR with your own CA and verify the chain (harder — combines skills)

Make a throwaway root CA (a self-signed cert + key), use it to sign the CSR from
exercise 4, and then prove the signed leaf chains to your CA.

**Hint:** `openssl req -x509 ...` makes the CA; `openssl x509 -req -CA ca.crt
-CAkey ca.key -CAcreateserial` signs the CSR; `openssl verify -CAfile ca.crt
leaf.crt` checks the chain.

**Check yourself:** `openssl verify` prints `OK`, the leaf's **Issuer** is now the
CA (not itself, unlike the self-signed cert in exercise 5), and you can explain
what `verify` actually proved.

---

## 12. Days until a cert expires (harder — combines with `date`)

Write a one-liner that prints how many days are left before a certificate
expires. Use the signed leaf from exercise 11, or any real site's cert.

**Hint:** Read `notAfter` with `openssl x509 -noout -enddate`, strip the `=` with
`cut`, convert it and `now` to epoch seconds with `date -d ... +%s`, subtract, and
divide by 86400.

**Check yourself:** You get a plausible day count, and you can explain how you'd
turn this into a monitoring check that alerts, say, 14 days before expiry.

---

## 13. Diagnose a broken chain against a live site (harder — combines tools)

Pick a public HTTPS site. Count how many certificates it sends, read its
`Verify return code`, and its expiry — all from `s_client` piped into other
tools. Say which of the three classic failures (expired / wrong name / missing
intermediate) you'd be looking at for each symptom.

**Hint:** `s_client -showcerts` and `grep -c 'BEGIN CERTIFICATE'` for the count;
the `Verify return code:` line at the bottom of plain `s_client`; pipe into
`openssl x509 -noout -dates -subject` for the rest. Remember `echo |` and
`-servername`.

**Check yourself:** You can state the cert count, whether the chain verified
(`0 (ok)`), and the expiry — and match each possible failure to its command.

---

## 14. Encrypt a whole directory as a backup (harder — combines with `tar`)

Encrypt an entire directory to your gpg test key *without* writing a plaintext
archive to disk, then restore it and confirm the files came back intact.

**Hint:** `tar czf - dir | gpg -e -r <you> > dir.tar.gz.gpg` to make it; reverse
with `gpg -d dir.tar.gz.gpg | tar xzf -`. Compare before/after with `find` or
`diff -r`.

**Check yourself:** The restored tree matches the original, and you can explain
why streaming through the pipe (no intermediate `.tar`) is safer for a backup
that contains secrets.

---

## 15. Verify a download end to end (hardest — combines gpg + hashing)

Simulate a signed release: create a file, write a `SHA256SUMS` list of its hash,
sign the *list* with your test key, then verify the signature and check the file
against the list. Then explain the trust subtlety in one or two sentences.

**Hint:** `sha256sum file > SHA256SUMS`, `gpg --detach-sign --armor SHA256SUMS`,
`gpg --verify SHA256SUMS.asc SHA256SUMS`, then `sha256sum -c SHA256SUMS`.

**Check yourself:** Both checks pass, and you can explain that "Good signature"
only matters if you got the signer's public key from a source independent of the
file — otherwise an attacker who swapped the file could swap the key too.
