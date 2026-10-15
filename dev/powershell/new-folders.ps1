# new-folders.ps1 — make folders, keep each in git with a .gitkeep.
# Edit the list, then: powershell -ExecutionPolicy Bypass -File new-folders.ps1
$folders = @(
  "infra/networking/firewall",
  "infra/security/sso",
  "dev/python"
)
foreach ($f in $folders) {
  New-Item -ItemType Directory -Force $f | Out-Null
  $k = Join-Path $f ".gitkeep"
  if (-not (Test-Path $k)) { New-Item -ItemType File $k | Out-Null }
}
Write-Host "Done. Now: git add . ; git commit -m 'Add folders' ; git push"
