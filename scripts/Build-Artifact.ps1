param(
    [Parameter(Mandatory=$true)][string]$Ref,
    [string]$ArtifactRoot = (Join-Path $PSScriptRoot '..\.lab\artifacts')
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
function Get-Sha256([string]$Path) {
    $stream = [System.IO.File]::OpenRead($Path)
    $hasher = [System.Security.Cryptography.SHA256]::Create()
    try { return [System.BitConverter]::ToString($hasher.ComputeHash($stream)).Replace('-', '') }
    finally { $hasher.Dispose(); $stream.Dispose() }
}
if ($Ref -notmatch '^v\d+\.\d+\.\d+$') { throw 'Use a release tag such as v1.3.1.' }
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sha = (& git -C $repo rev-parse "$Ref^{commit}")
if ($LASTEXITCODE -ne 0) { throw 'Unknown Git tag.' }
$dirty = @(& git -C $repo status --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect Git status.' }
if ($dirty.Count -gt 0) { throw 'Commit or stash your changes before building a release.' }
New-Item -ItemType Directory -Path $ArtifactRoot -Force | Out-Null
$ArtifactRoot = (Resolve-Path $ArtifactRoot).Path
$destination = Join-Path $ArtifactRoot $Ref
if (Test-Path -LiteralPath $destination) { throw 'Artifact exists. Published artifacts are immutable; use another tag or artifact directory.' }
$temporary = Join-Path $ArtifactRoot ('.build-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporary | Out-Null
& git -C $repo archive --format=zip "--output=$temporary\source.zip" $Ref
if ($LASTEXITCODE -ne 0) { throw 'git archive failed.' }
Expand-Archive -LiteralPath "$temporary\source.zip" -DestinationPath "$temporary\source"
Push-Location "$temporary\source"
try {
    & dotnet run --project tests/ShopLite.Checks -c Release
    if ($LASTEXITCODE -ne 0) { throw 'Checks failed. Artifact was not published.' }
    & dotnet publish src/ShopLite -c Release -o "$temporary\package" --no-self-contained "-p:Version=$($Ref.Substring(1))"
    if ($LASTEXITCODE -ne 0) { throw 'Publish failed.' }
} finally { Pop-Location }
& dotnet "$temporary\package\ShopLite.dll" --smoke
if ($LASTEXITCODE -ne 0) { throw 'Artifact smoke check failed.' }
$files = @(Get-ChildItem "$temporary\package" -File | ForEach-Object {
    [ordered]@{ name=$_.Name; sha256=(Get-Sha256 $_.FullName) }
})
$manifest = [ordered]@{ version=$Ref; commit=$sha; builtAtUtc=[DateTime]::UtcNow.ToString('o'); files=$files }
$manifest | ConvertTo-Json -Depth 5 | Set-Content "$temporary\package\manifest.json" -Encoding UTF8
Move-Item -LiteralPath "$temporary\package" -Destination $destination
Write-Output "ARTIFACT $Ref $sha -> $destination"
