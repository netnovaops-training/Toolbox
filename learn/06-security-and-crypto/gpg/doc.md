> **what:** gpg — encrypt, decrypt, and sign files and messages with public-key crypto
> **status:** trying
> **tags:** security, crypto, encryption, gpg, pgp, keys, backups
> **last-used:** 2026-10-15

# gpg — GNU Privacy Guard

## What it is

`gpg` is the command-line tool for **OpenPGP** crypto. It does two big jobs:

1. **Encryption** — scramble a file so only the intended recipient can read it.
2. **Signing** — stamp a file so anyone can verify *you* produced it and it
   wasn't tampered with.

It is built on **public-key (asymmetric) cryptography**, which is the one idea
you must understand to use it:

- Everyone has a **key pair**: a **public key** (share it freely) and a
  **private/secret key** (guard it forever, protected by a passphrase).
- To send someone a secret, you encrypt with **their public key**. Only **their
  private key** can decrypt it — including you can't read it back afterward
  unless you also encrypt to yourself.
- To prove you wrote something, you sign with **your private key**; anyone
  verifies with **your public key**.

The mental model: a public key is an **open padlock** you hand out. Anyone can
snap it shut on a box (encrypt to you), but only you hold the **key** that opens
it (your private key). You never give out that key.

## Why it matters on the job

- **Encrypted backups and data at rest.** Database dumps, config archives, and
  secrets that must sit on disk or travel to another server are routinely
  GPG-encrypted so a stolen backup is useless without the key.
- **Secure handoff.** Sending a credential or sensitive file to a colleague:
  encrypt to their public key; only they can open it.
- **Verifying downloads.** Distros and projects sign releases. `gpg --verify`
  proves a downloaded file really came from them and wasn't swapped by a mirror
  or attacker — a basic supply-chain safety check.
- **Signing your own artifacts.** Signing release files or commits so others can
  trust their origin.

These are everyday security-engineering tasks, and GPG is the standard tool.

## Keys and keyrings

GPG stores keys in your **keyring** (under `~/.gnupg`). You refer to a key by a
`<username>` — which can be the owner's name, email, or key ID — as long as it
uniquely matches one key in your keyring.

Export your public key so others can encrypt to you:

```bash
gpg --export --armor "you@example.com" > you.pubkey
#   --export : write out keys
#   --armor  : ASCII-armored (printable text) instead of binary, so it's safe
#              to paste into email or a text file
```

Import someone else's public key (so you can encrypt to them or verify their
signatures):

```bash
gpg --import their.pubkey
```

Look someone up on a public key server:

```bash
gpg --keyserver hkp://keyserver.ubuntu.com --search-keys "name@example.com"
#   --keyserver   : which server to query
#   --search-keys : search by name/email; you pick a result to import
```

## Encrypting and decrypting

Encrypt a file **to a recipient** (asymmetric — needs their public key in your
keyring):

```bash
gpg -e -r "them@example.com" dump.sql
#   -e / --encrypt  : encrypt
#   -r / --recipient: whose public key to encrypt to
# Produces dump.sql.gpg; only their private key can open it.
# Tip: add -r for yourself too, or you won't be able to read it back.
```

Decrypt a file (needs the matching private key + its passphrase):

```bash
gpg -o dump.sql -d dump.sql.gpg
#   -o / --output : where to write the decrypted result
#   -d / --decrypt: decrypt (this is the default action)
```

There is also **symmetric** encryption — one shared passphrase, no key pair —
which is handy for a quick personal backup where you just need a password:

```bash
gpg -c secret.tar        # -c / --symmetric: prompts for a passphrase
gpg -o secret.tar -d secret.tar.gpg   # decrypt the same way, re-entering it
```

## Signing and verifying

Create a detached signature (a separate `.sig` file next to the original):

```bash
gpg --detach-sign --armor release.tar.gz    # makes release.tar.gz.asc
```

Verify a signature someone else made (you need their public key imported):

```bash
gpg --verify release.tar.gz.asc release.tar.gz
# "Good signature from ..." = the file is authentic and unmodified.
```

## Inspecting an encrypted file

See what's inside an OpenPGP file *without* decrypting it — which keys it's
encrypted to, what algorithms, etc.:

```bash
gpg --batch --list-packets archive.gpg
#   --batch         : don't prompt (good for scripts)
#   --list-packets  : dump the packet structure
# (On some systems the binary is 'gpg2'.)
```

## How to read common output

- **"Good signature from <name>"** — verification passed; trust the origin (to
  the degree you trust that key).
- **"BAD signature"** — the file was altered or the wrong file was checked.
  Do not use it.
- **"WARNING: This key is not certified with a trusted signature"** — the
  signature math is fine, but *you* haven't told GPG you trust that this key
  really belongs to that person. It's a trust prompt, not a failure.
- **"gpg: decryption failed: No secret key"** — the file was encrypted to a key
  you don't hold the private half of. You can't read it; whoever has that
  private key can.

## Common mistakes

- **Losing the private key or its passphrase.** There is **no recovery**. If you
  lose them, GPG-encrypted data is gone forever. Back up your private key and
  passphrase securely *before* you rely on encryption.
- **Encrypting only to the recipient, not yourself.** Then you can't read your
  own file back. Add yourself as a second `-r` recipient if you need access.
- **Confusing public and private keys.** You encrypt with the *public* key and
  decrypt with the *private* one. Sharing a public key is fine; sharing a
  private key is a breach.
- **Skipping verification on downloads.** Having the signature file but never
  running `--verify` defeats the point. Also make sure you got the signer's
  public key from a trustworthy source, not the same place as the file.
- **Trusting "Good signature" blindly.** It proves the file matches *that key*.
  You still need confidence the key truly belongs to who you think.

## A worked example: verifying a download the right way

You download a tool's release tarball plus its `.asc` signature and a `SHA256SUMS`
file. The job-grade workflow, in order:

1. **Get the signer's key from a trustworthy source** — the project's website or a
   keyserver — *not* the same mirror that served the file. `gpg --recv-keys <KEYID>`
   or `gpg --import maintainer.pubkey`.
2. **Verify the checksum file's signature:** `gpg --verify SHA256SUMS.asc SHA256SUMS`.
   Look for "Good signature". This proves the *list of hashes* really came from the
   maintainer.
3. **Check the tarball against that trusted list:** `sha256sum -c SHA256SUMS`
   (combining with the lesson's hashing idea). Now you've proven the file matches a
   hash that was signed by a key you trust.

The subtlety interviewers probe: "Good signature" only proves the file matches
*that key*. If you grabbed the key from the same compromised mirror, you've proven
nothing. The trust comes from where you got the key, not from the verify step.

## Combine it with other tools

- **Encrypt a whole directory**, not just one file, by combining with `tar`:
  `tar czf - mydir | gpg -e -r you@example.com > mydir.tar.gz.gpg`. Decrypt the
  same way: `gpg -d mydir.tar.gz.gpg | tar xzf -`. This is how encrypted backups
  are actually made — stream a tar straight through gpg, no plaintext archive ever
  hits disk.
- **Find which key a file is encrypted to** by piping `--list-packets` through
  `grep` (lesson 04): `gpg --list-packets secret.gpg | grep keyid`.
- **Verify a batch of downloads** by pairing `gpg --verify` with `sha256sum -c`
  (see the worked example above).
- **Script decryption non-interactively** with `--batch --pinentry-mode loopback
  --passphrase-file`, e.g. a cron job that decrypts an incoming feed — but never
  put the passphrase on the command line (it shows up in `ps`); use a file with
  `600` permissions (lesson 08).

## Does it need root?

No. `gpg` works entirely inside **your own** `~/.gnupg` keyring and your own
files, so it runs as a normal user and should **not** be run with `sudo`
(running it as root creates a root-owned keyring and permission headaches). You
only need elevated rights to read/write files that happen to be owned by someone
else — the crypto itself is per-user.

> WARNING: Commands that encrypt, decrypt, or sign act on real data and real
> keys, and a lost private key or passphrase means permanent data loss. Generate
> throwaway test keys and practise in a disposable VM/container before you
> encrypt anything you actually need to get back.
