# make-folders.ps1 — create my toolbox folders, each with a README on top.
# Edit the list, then run:  powershell -ExecutionPolicy Bypass -File scripts\powershell\make-folders.ps1
# Safe to run again; it won't overwrite a README that already exists.

$folders = @{
  "linux"       = "Linux one-liners, commands, tips"
  "windows"     = "PowerShell and cmd snippets"
  "networking"  = "SSH, DNS, Tailscale, curl, ports"
  "security"    = "hardening steps, scanning notes, how-tos"
  "docker"      = "compose snippets, common commands"
  "scripts"     = "reusable scripts (bash/, powershell/, python/ inside)"
  "cheatsheets" = "quick, ADHD-style references"
  "learning"    = "study notes, cert prep, goals I'm working toward"
  "notes"       = "anything else I find useful"
}

foreach ($name in $folders.Keys) {
  New-Item -ItemType Directory -Force $name | Out-Null
  $readme = Join-Path $name "README.md"
  if (-not (Test-Path $readme)) {
    "# $name`r`n`r`n$($folders[$name])" | Set-Content -Encoding utf8 $readme
  }
}
Write-Host "Folders ready. Now: git add . ; git commit -m 'Add folders' ; git push"
