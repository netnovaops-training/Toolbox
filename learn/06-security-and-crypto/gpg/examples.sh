#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# gpg: export/import keys, encrypt, decrypt, sign, verify, and inspect files.
#
# WARNING: GPG acts on real cryptographic keys and real data. A lost private key
# or passphrase means the data is gone FOR GOOD. This script stays safe by
# building a THROWAWAY keyring and throwaway test keys in a scratch dir, and
# deleting everything on exit. Never run encryption you rely on before you've
# practised here. Use a disposable VM/container.

set -euo pipefail   # -e stop on error, -u error on unset var, pipefail catch mid-pipe failures

# Isolated scratch dir AND isolated keyring, so we never touch your real ~/.gnupg
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
export GNUPGHOME="$work/gnupg"      # point gpg at a private, temporary keyring
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"              # gpg insists the keyring dir be owner-only
cd "$work"
echo "scratch dir: $work  (temporary keyring at \$GNUPGHOME)"

echo "=== 0) Make a throwaway test key so the demo has something to use ==="
# --batch + --passphrase '' generates a key with NO passphrase, unattended.
# Real keys should ALWAYS have a strong passphrase; empty is only for this demo.
# 'Test User <test@example.com>' uses the reserved example.com domain.
gpg --batch --pinentry-mode loopback --passphrase '' --quick-generate-key \
    "Test User <test@example.com>" default default never
echo "key created in the throwaway keyring:"
gpg --list-keys

echo "=== 1) Export the public key, ASCII-armored ==="
# --armor makes printable text you can safely paste into email or a file.
gpg --export --armor "test@example.com" > test.pubkey
echo "exported public key (first lines):"; head -n 2 test.pubkey

echo "=== 2) Encrypt a file to a recipient ==="
# -e encrypt, -r recipient (their public key). Here the recipient is our own
# test key, so we can decrypt it back in the next step.
echo "this is a secret database dump" > dump.sql
gpg -e -r "test@example.com" dump.sql      # produces dump.sql.gpg
echo "encrypted file:"; ls -1 dump.sql.gpg

echo "=== 3) Decrypt the file again ==="
# -d decrypt, -o output path. Needs the matching private key (we have it).
# --pinentry-mode loopback + empty passphrase because this demo key has none.
gpg --pinentry-mode loopback --passphrase '' -o dump.decrypted.sql -d dump.sql.gpg
echo "round-trip check:"; diff dump.sql dump.decrypted.sql && echo "MATCH: decrypted == original"

echo "=== 4) Symmetric (passphrase-only) encryption — no key pair needed ==="
# -c uses a shared passphrase instead of a recipient key. Good for a quick
# personal backup. We supply the passphrase non-interactively just for the demo.
echo "quick personal backup" > notes.txt
gpg --batch --pinentry-mode loopback --passphrase 'demo-pass' -c notes.txt   # -> notes.txt.gpg
gpg --batch --pinentry-mode loopback --passphrase 'demo-pass' \
    -o notes.decrypted.txt -d notes.txt.gpg
diff notes.txt notes.decrypted.txt && echo "symmetric round-trip OK"

echo "=== 5) Sign a file (detached, armored) and verify it ==="
# A detached signature lives in a separate .asc file next to the original.
echo "release artifact v1" > release.txt
gpg --batch --pinentry-mode loopback --passphrase '' \
    --detach-sign --armor release.txt          # -> release.txt.asc
# --verify checks the signature against the file using the signer's public key.
gpg --verify release.txt.asc release.txt       # expect "Good signature"

echo "=== 6) Inspect an encrypted file WITHOUT decrypting it ==="
# --list-packets shows the structure: which key(s) it's encrypted to, algorithms.
# --batch so it doesn't prompt. (On some systems the binary is gpg2.)
gpg --batch --list-packets dump.sql.gpg | head -n 10

# --- Patterns from the book you can adapt with REAL keys later ---------------
# Look a person up on a public key server and import their key:
#   gpg --keyserver hkp://keyserver.ubuntu.com --search-keys "name@example.com"
# Import a public key file someone sent you:
#   gpg --import their.pubkey
# Encrypt a backup to a colleague AND yourself (so you can both open it):
#   gpg -e -r "them@example.com" -r "you@example.com" backup.tar
# -----------------------------------------------------------------------------
echo "done — throwaway keyring and all test files are about to be deleted"
