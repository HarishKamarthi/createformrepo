param(
  [Parameter(Mandatory=$true)]
  [string]$GitRef,  # branch or tag

  [string]$RepoPath = "C:\Deploy\createform-repo",

  # Your Create!form target paths:
  [string]$TargetWorkDirEU   = "C:\Bottomline Technologies, Inc\Create!form\WorkDir\WorkDirEU",
  [string]$TargetWorkDirEU_D = "C:\Bottomline Technologies, Inc\Create!form\WorkDir\WorkDirEU_D",
  [string]$TargetCommonProj  = "C:\Bottomline Technologies, Inc\Create!form\CommonProject"
)

function Assert-Path($p) {
  if (!(Test-Path $p)) { throw "Missing path: $p" }
}

Assert-Path $RepoPath
Assert-Path $TargetWorkDirEU
Assert-Path $TargetWorkDirEU_D
Assert-Path $TargetCommonProj

Set-Location $RepoPath

Write-Host "Fetching latest refs..."
git fetch --all --tags

Write-Host "Checking out: $GitRef"
git checkout $GitRef

# Optional: ensure working tree matches the ref exactly
git reset --hard

# Source folders in repo (adjust if your repo uses different names)
$SrcWorkDirEU   = Join-Path $RepoPath "WorkDirEU"
$SrcWorkDirEU_D = Join-Path $RepoPath "WorkDirEU_D"
$SrcCommonProj  = Join-Path $RepoPath "CommonProject"

Assert-Path $SrcWorkDirEU
Assert-Path $SrcWorkDirEU_D
Assert-Path $SrcCommonProj

Write-Host "Deploying WorkDirEU -> $TargetWorkDirEU"
robocopy $SrcWorkDirEU $TargetWorkDirEU /MIR /R:2 /W:2 /NP /NFL /NDL

Write-Host "Deploying WorkDirEU_D -> $TargetWorkDirEU_D"
robocopy $SrcWorkDirEU_D $TargetWorkDirEU_D /MIR /R:2 /W:2 /NP /NFL /NDL

Write-Host "Deploying CommonProject -> $TargetCommonProj"
robocopy $SrcCommonProj $TargetCommonProj /MIR /R:2 /W:2 /NP /NFL /NDL

# Write a deploy marker
$marker = Join-Path $TargetCommonProj "DEPLOYED_FROM_GIT.txt"
$stamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$stamp  Deployed GitRef: $GitRef" | Out-File -FilePath $marker -Encoding UTF8

Write-Host "Done. Marker written to: $marker"
