# Windows PowerShell / cmd starter commands

# what: everyday Windows commands I reach for (my own notes)
# status: useful
# tags: windows, powershell, cmd, cli
# last-used: 2026-10-15

My own notes — common Windows commands, no attribution needed. PowerShell
unless marked (cmd). Each entry: the command, then one line on what it does.

## Files and directories

```powershell
Get-ChildItem        # alias: ls, dir
```
List files and folders in the current location.

```powershell
Get-ChildItem -Recurse -Filter *.log
```
Find all `.log` files under the current folder and below.

```powershell
Set-Location C:\path    # alias: cd
```
Move into a folder.

```powershell
New-Item -ItemType Directory mynewfolder
```
Make a new folder.

```powershell
Copy-Item file.txt backup.txt
```
Copy a file.

```powershell
Move-Item file.txt C:\other\
```
Move (or rename) a file.

```powershell
Remove-Item file.txt
```
Delete a file. Add `-Recurse` for a folder (careful).

```powershell
Get-Content file.txt
```
Show a file's contents (like `cat`). Add `-Tail 20 -Wait` to follow a log live.

## Text search

```powershell
Select-String -Pattern "error" -Path .\*.log
```
Search files for text (like `grep`), showing file and line.

```powershell
Get-Content file.txt | Select-String "pattern"
```
Filter a file's lines to those matching a pattern.

## Services

```powershell
Get-Service
```
List Windows services and whether they're running.

```powershell
Get-Service -Name Spooler
```
Check one service by name.

```powershell
Start-Service Spooler     # Stop-Service / Restart-Service
```
Start, stop, or restart a service (run PowerShell as admin).

## Processes

```powershell
Get-Process               # alias: ps
```
List running processes.

```powershell
Get-Process -Name chrome
```
Find a process by name.

```powershell
Stop-Process -Name notepad       # or -Id <pid>
```
Stop a process by name or PID.

## Network

```cmd
ipconfig /all
```
(cmd) Show all network adapters, IP addresses, DNS, and gateway.

```powershell
Test-NetConnection example.com -Port 443
```
Check whether you can reach a host on a given port (ping + port test).

```powershell
Resolve-DnsName example.com
```
Resolve a domain name to its IP (like `dig`/`nslookup`).

```cmd
nslookup example.com
```
(cmd) Quick domain name lookup.

```powershell
Get-NetTCPConnection -State Listen
```
Show which ports are listening on this machine.

```cmd
ping example.com
```
(cmd) Test if a host is reachable.

## System info

```powershell
Get-ComputerInfo
```
Show OS, hardware, and build details.

```powershell
Get-Volume
```
Show drives with free and total space.

```cmd
systeminfo
```
(cmd) One-page summary of the machine, OS, and patches.

## Environment variables

```powershell
$env:PATH
```
Show the PATH variable.

```powershell
Get-ChildItem Env:
```
List all environment variables.

```powershell
$env:MYVAR = "value"
```
Set an environment variable for this session.

## Handy

```powershell
Get-Help Get-Service -Examples
```
Show examples for any command. Your best friend while learning.

```powershell
Get-Command *service*
```
Find commands by keyword.
