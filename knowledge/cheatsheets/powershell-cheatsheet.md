# PowerShell cheatsheet — the commands I reach for most

A quick one-pager. Fuller notes: `dev/powershell/windows-starter.md`. (cmd) marks
old-style commands that also work in a cmd prompt.

| Command | Does |
|---|---|
| `Get-ChildItem` (`ls`, `dir`) | list files and folders |
| `Get-ChildItem -Recurse -Filter *.log` | find files below here |
| `Set-Location path` (`cd`) | change folder |
| `New-Item -ItemType Directory name` | make a folder |
| `Copy-Item a b` / `Move-Item a b` | copy / move or rename |
| `Remove-Item file` | delete (`-Recurse` for folders) |
| `Get-Content file` (`-Tail 20 -Wait`) | show a file / follow a log |
| `Select-String "text" .\*.log` | search text in files (grep) |
| `Get-Service` | list services |
| `Start-Service` / `Stop-Service` / `Restart-Service` | control a service (admin) |
| `Get-Process` (`ps`) | list processes |
| `Stop-Process -Name x` | stop a process |
| `ipconfig /all` (cmd) | show IPs, DNS, gateway |
| `Test-NetConnection host -Port 443` | reach a host on a port |
| `Resolve-DnsName host` | resolve a domain |
| `Get-NetTCPConnection -State Listen` | show listening ports |
| `systeminfo` (cmd) | machine / OS summary |
| `Get-Volume` | drives and free space |
| `$env:PATH` / `Get-ChildItem Env:` | show PATH / all env vars |
| `Get-Help <cmd> -Examples` | show examples for a command |
| `Get-Command *word*` | find commands by keyword |
