> **what:** ssh — the secure way to log in to and run commands on a remote machine
> **status:** trying
> **tags:** networking, ssh, remote, keys, sysadmin
> **last-used:** 2026-10-15

# ssh — secure shell

## What it is

`ssh` (secure shell) opens an **encrypted** connection to another computer and
gives you a shell on it — a command prompt that runs *there* instead of on your
own machine. It is the single most important tool in a sysadmin's day: almost
every server you ever touch, you will reach over `ssh`.

The mental model: you sit at your laptop (the **client**). A server somewhere
(the **remote host**) runs a small program called `sshd` that listens on TCP
port **22**. `ssh` dials that port, the two sides agree on encryption, you prove
who you are, and from then on everything you type is sent safely down the tunnel
and run on the far end. Because the channel is encrypted, nobody between you and
the server can read your commands or your password.

```bash
ssh user@example.com          # log in as "user" on example.com
ssh -p 2222 user@example.com  # same, but sshd is listening on port 2222
```

## The networking concept behind it

Older remote-login tools (telnet, rlogin, rsh, plain FTP) sent everything —
including your password — as **plain text** across the network. Anyone running
a packet sniffer on the path could read it (you will see exactly how in the
`06-network-capture-and-scan` lesson). SSH replaced them by wrapping the same
idea in strong cryptography: key exchange to set up a shared secret, then a
symmetric cipher for the session. The lesson that matters for a job: **if a
protocol is not encrypted, assume someone can read it.** SSH is the encrypted
answer for remote shells, file copies (`scp`/`sftp`), and tunnels.

## Key pairs — the thing to really understand

A password can be guessed, phished, or reused. The professional way to log in
is a **key pair** instead:

- You generate two matched files: a **private key** (secret, stays on your
  laptop) and a **public key** (not secret, you hand it out).
- The public key goes into the server's `~/.ssh/authorized_keys` file.
- When you connect, the server sends a challenge that can only be answered by
  someone holding the matching private key. Your `ssh` answers it. You are in —
  **without ever sending a password.**

```bash
ssh-keygen -t ed25519 -C "you@example.com"   # make a modern key pair
```

- This writes `~/.ssh/id_ed25519` (private — guard it) and
  `~/.ssh/id_ed25519.pub` (public — safe to share).
- `-t ed25519` picks a modern, short, fast key type. `-t rsa -b 4096` is the
  older but still fine choice.
- `ssh-keygen` asks for a **passphrase**. Use one. It encrypts the private key
  on disk, so a stolen laptop does not instantly equal a stolen key.

Copy the public key to a server with:

```bash
ssh-copy-id user@example.com        # appends your .pub to the server's authorized_keys
```

You can recover the public key from a private key, and list fingerprints, if you
ever need to check which key is which:

```bash
ssh-keygen -y -f ~/.ssh/id_ed25519          # print the public key for a private key
ssh-keygen -l -f ~/.ssh/known_hosts         # show fingerprints of hosts you've trusted
```

## The "no password" concept

"Passwordless" SSH does **not** mean "no security." It means you authenticate
with the key pair instead of typing a password. This is *more* secure, not less:
the private key never leaves your machine, and a 256-bit key is not something an
attacker brute-forces. On real infrastructure, servers are usually configured to
**refuse passwords entirely** (`PasswordAuthentication no` in `sshd_config`) and
accept only keys. You can force either method for testing:

```bash
# Force password auth (useful to test that it's been disabled):
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@example.com

# Force public-key auth with a specific key:
ssh -o PreferredAuthentications=publickey -i ~/.ssh/id_ed25519 user@example.com
```

## The SSH agent — type your passphrase once

If your key has a passphrase (it should), typing it on every connection is
tedious. The **ssh-agent** holds your decrypted key in memory for the session so
you are not prompted again:

```bash
eval "$(ssh-agent -s)"          # start an agent for this shell session
ssh-add ~/.ssh/id_ed25519       # unlock the key once; agent remembers it
ssh-add -l                      # list keys the agent is holding
```

**Agent forwarding** (`ssh -A`) lets a key in your laptop's agent be used from
the server you logged into — handy for hopping onward, but only forward to hosts
you trust, because the far end can then use your agent while you are connected.

## ~/.ssh/config — stop retyping everything

Instead of long command lines, describe each host once in `~/.ssh/config`:

```
Host web
    HostName example.com
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

Host db
    HostName 192.168.1.50
    User admin
    # reach db *through* web (a bastion/jump host):
    ProxyJump web
```

Now `ssh web` expands to the full command, and `ssh db` automatically hops
through `web` first. This file is where a working sysadmin keeps the whole fleet
tidy. It is read-only config — safe to keep in version control **only if it
contains no secrets** (it should not; keys live in separate files).

## Port forwarding (tunnels) — the power feature

SSH can carry *other* traffic inside its encrypted tunnel. Two directions:

- **Local forward (`-L`)**: "expose a remote service on my local machine."
  `ssh -L 9090:localhost:5432 user@example.com` makes `localhost:9090` on your
  laptop reach port 5432 on the server. You then point a database client at
  `localhost:9090` and it rides the tunnel.
- **Remote forward (`-R`)**: the reverse — expose a local service to the remote
  side.

Common flags for a pure tunnel with no shell:

- `-N` — do not run a remote command (tunnel only).
- `-T` — no interactive terminal.
- `-n` — read stdin from `/dev/null` (good for background tunnels).

## Reading the output / first-connection prompt

The first time you connect to a host, SSH shows a **host key fingerprint** and
asks you to confirm. This is the server proving *its* identity to *you* (so you
are not tricked into logging into an impostor). Say yes only if you expect that
host; the key is then saved in `~/.ssh/known_hosts`. If you later see a loud
**"REMOTE HOST IDENTIFICATION HAS CHANGED"** warning, stop — either the server
was rebuilt, or someone is intercepting the connection.

## Does it need sudo/root?

No. `ssh` the client runs as your normal user. You only need root **on the
remote host** if the *commands you run there* need it (then you `sudo` once
logged in). Running the ssh client itself as root is almost never right.

## Common mistakes

- **Private key permissions too open.** SSH refuses a private key that others
  can read. Fix with `chmod 600 ~/.ssh/id_ed25519` (and `700` on `~/.ssh`).
- **Copying the *private* key to a server.** Only the `.pub` goes on servers.
  The private key never leaves your machine.
- **Blindly accepting a changed host key.** Investigate the warning instead of
  deleting the known_hosts line out of habit.
- **Forwarding your agent (`-A`) to untrusted hosts.** They can use your keys
  while you are connected.
- **Leaving `PasswordAuthentication yes` on an internet-facing server.** Keys
  only, once you have confirmed key login works.
```
