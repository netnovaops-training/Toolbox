# Networking commands (beginner)

# what: the networking commands I actually reach for
# status: useful
# tags: networking, linux, dns, ssh, cli
# last-used: 2026-10-15

Linux-focused. Each entry: the command, then one line on what it does.
Only scan/probe networks you own (your homelab), never someone else's.

## See my own network

```
ip a
```
Show my network interfaces and their IP addresses.

```
ip r
```
Show the routing table (which way traffic leaves, and the default gateway).

```
hostname -I
```
Just my IP address(es), nothing else.

```
ss -tulpn
```
List listening TCP/UDP ports and which program owns each (what's open on this box).

## Reach other hosts

```
ping -c 4 192.168.1.1
```
Send 4 packets to check a host is up and measure round-trip time.

```
traceroute example.com
```
Show each hop between me and a host (where a path breaks or slows).

```
nc -zv 192.168.1.10 22
```
Test whether one port is open on a host (here, SSH/22). Quick "is the service up?".

## DNS (names ↔ addresses)

```
dig +short example.com
```
Look up the IP for a name, short output.

```
dig example.com MX
```
Look up a specific record type (MX = mail; try A, AAAA, TXT, NS).

```
nslookup example.com
```
Simpler DNS lookup; handy when `dig` isn't installed.

## Web / API checks

```
curl -I https://example.com
```
Fetch just the response headers (status code, server) to test an endpoint.

```
curl -s https://ifconfig.me
```
Show my public IP (what the internet sees me as).

```
curl -sS https://example.com/health
```
Hit a URL and print the body; good for checking a service's health page.

## Remote access

```
ssh user@host
```
Log in to another machine over SSH.

```
scp file.txt user@host:/path/
```
Copy a file to another machine over SSH (`-r` for a folder).

## Scan my own network (careful)

```
nmap -sn 192.168.1.0/24
```
Ping-scan my subnet to list which hosts are alive. Your network only.

## Level up later

`tcpdump` and `wireshark` (capture/read packets), `nmap` service/version scans
(`-sV`), `iperf3` (bandwidth tests), `mtr` (live traceroute), `ethtool`,
VLANs and `ip link`. See the Networks chapter in the fork:
https://github.com/netnovaops-training/the-book-of-secret-knowledge
