> **what:** practice exercises for connecting to the network — ssh, curl, dig
> **status:** trying
> **tags:** networking, ssh, curl, dig, dns, http, practice
> **last-used:** 2026-10-15

# Practice: connecting to the network (ssh, curl, dig)

Work top to bottom — they get harder. These are the everyday "reach out and
check something" skills. For anything involving SSH into a real machine, use a
**throwaway VM or a lab box you own** — never practise on a stranger's server.

A one-line rule for this whole lesson: **you only connect to machines you own or
have written permission to touch.** Looking up public DNS and fetching public
web pages is fine; logging in anywhere is not, unless it's yours.

---

### 1. See the raw HTTP conversation (easy)
Fetch `https://example.com` three ways: the body (`curl`), headers only
(`curl -I`), and the full trace (`curl -v`). Note the status code on the first
line of the header output.

*Hint:* `-I` sends a HEAD request, so there is no body. `-v` lines starting with
`>` are what you sent, `<` what you received.
**Check yourself:** you can say what status code came back and name one response
header and what it means.

---

### 2. Follow a redirect on purpose (easy)
Find a URL that redirects (many `http://` sites redirect to `https://`). Fetch
it once without `-L` and once with `-L`. Describe the difference.

*Hint:* without `-L` you see a 3xx status and a `Location:` header and nothing
else. With `-L`, curl chases the `Location:` and shows the final page.
**Check yourself:** you can point at the `Location:` header and say where it
sent you.

---

### 3. Resolve a name, then compare resolvers (easy)
Run `dig example.com +short`. Then ask two public resolvers the same thing:
`dig @1.1.1.1 example.com +short` and `dig @9.9.9.9 example.com +short`.

*Hint:* `@server` picks which DNS server answers. If all three agree, your local
cache is current.
**Check yourself:** you get the same address (or set of addresses) from each.

---

### 4. Map a domain's records (medium)
For one domain, pull its `A`, `NS`, and `MX` records with `dig ... +short`. In
plain words, say what each record type tells you.

*Hint:* A = address, NS = who's authoritative, MX = where email goes.
**Check yourself:** you can read the MX output and name the mail host(s).

---

### 5. Isolate "is it DNS?" (medium)
Imagine an app can't reach `api.example.com`. Write the exact `dig` command you'd
run first, and describe what each of these three outcomes would tell you: no
answer, a wrong-looking answer, a correct answer.

*Hint:* no answer → DNS; correct answer but still failing → the problem is lower
down (routing/firewall/service), so you'd move to `curl` or `nc`.
**Check yourself:** your note cleanly separates the DNS step from everything
after it.

---

### 6. Make a key pair and read it (medium)
Generate an ed25519 key pair in a scratch location
(`ssh-keygen -t ed25519 -f ./lab_key`). Look at both files. Which one is secret?
Then print the public key from the private one with `ssh-keygen -y -f ./lab_key`.

*Hint:* the `.pub` file is public; the other is private and should be `chmod
600`. The printed key should match the `.pub` file.
**Check yourself:** you can explain, in one sentence, why the public key is safe
to email but the private key is not.

---

### 7. Explain passwordless login (harder)
Without running anything, write the step-by-step of how a key-based SSH login
works: where each key lives, what the server sends, what your client proves, and
why no password crosses the network.

*Hint:* public key in the server's `authorized_keys`; private key never leaves
your laptop; the server challenges, your client answers with the private key.
**Check yourself:** your explanation never has the private key leaving your
machine.

---

### 8. Design a ~/.ssh/config entry (harder)
Write a `~/.ssh/config` block for a server named `lab` at `example.com` on port
2222 as user `student`, using a specific key file. Then write a second block for
a machine reachable only *through* `lab`.

*Hint:* `HostName`, `User`, `Port`, `IdentityFile`, and `ProxyJump lab` for the
second host.
**Check yourself:** you could now type `ssh lab` or `ssh inner` with no flags.

---

### 9. Plan a tunnel (hardest)
You need to reach a database on a server's `localhost:5432`, but only SSH (port
22) is open to you. Write the `ssh -L` command that lets a local client connect
to `localhost:9090` and ride the tunnel, and explain each flag you add
(`-n -N -T`).

*Hint:* `-L localPort:targetHost:targetPort user@server`. The target host is
`localhost` *from the server's point of view*.
**Check yourself:** you can explain why `-N` means "no shell, just the tunnel"
and when you'd background it.

---

### 10. Build a one-domain triage report (hardest)
Combine the tools: write a short script that, for a domain you give it, resolves
the name with `dig +short`, then fetches the HTTP and HTTPS headers with `curl`.
Study `curl/examples.sh` example 8 first, then make your own cleaner version.

*Hint:* loop over `http https`, call `curl -IsL` for each, and print a header
line before each section so the output is readable.
**Check yourself:** running it on `example.com` prints the IP, then two tidy
blocks of headers, with no crash if one protocol is unreachable.

---

### 11. Find the slow layer with curl's timing (harder)
Use `curl -w` to print the DNS, connect, TLS, and time-to-first-byte split for
`https://example.com`. Then say, if `time_namelookup` were large, which tool you
would switch to and why.

*Hint:* `-o /dev/null` to drop the body; `-w 'dns=%{time_namelookup} ...\n'`. A
big DNS number points you back at `dig`.
**Check yourself:** you can read the four numbers and name which layer each one
measures.

---

### 12. Turn a failing curl into a diagnosis by exit code (harder)
Run `curl -fsS` against (a) a name that can't resolve, (b) a port that's closed,
and (c) a URL that returns a 500 if you can find one. Record `echo $?` each time
and match the number to the layer that broke.

*Hint:* 6 = DNS, 7 = connect, 28 = timeout, 22 = HTTP error (with `-f`). You can
force a DNS failure with a made-up `.invalid` name.
**Check yourself:** you can map at least three exit codes to the layer they mean.

---

### 13. Compare two resolvers and only flag disagreement (combines lesson 04)
Write a one-liner that queries `example.com` on `@1.1.1.1` and `@9.9.9.9` with
`+short` and prints something only when the two answers differ. Study
`dig/examples.sh` example 10 first.

*Hint:* `diff <(dig @1.1.1.1 ... +short) <(dig @9.9.9.9 ... +short)`. Process
substitution `<(...)` hands each command's output to `diff` as a file.
**Check yourself:** it stays quiet when the resolvers agree and shows the
difference when they don't.

---

### 14. Audit a list of hostnames (combines find/grep/awk from lessons 03-04)
Make a text file with a few hostnames (one per line, include one bogus name).
Write a loop that resolves each with `dig +short` and prints the name plus its
IP — or `NO-ANSWER` for the ones that fail. Then pipe the result through `grep`
to show only the failures.

*Hint:* `while read -r name; do ... done < names.txt`; capture the IP in a var and
substitute a default with `${ip:-NO-ANSWER}`.
**Check yourself:** the bogus name shows `NO-ANSWER` and your `grep` isolates it
cleanly.

---

### 15. One remote command, parsed locally (combines lesson 04; needs a lab box)
On a VM you own, run a single `ssh user@lab 'df -h'` and pipe the output through
`awk`/`sort` to print each mount's use% worst-first. Do it without logging in
interactively.

*Hint:* `ssh host 'df -h' | awk 'NR>1 {print $5, $6}' | sort -rn`. The remote
command's stdout is just text on your machine.
**Check yourself:** you get a sorted usage list and never opened an interactive
shell to do it.
