param(
    [Parameter(Mandatory=$true)][ValidatePattern('^v\d+\.\d+\.\d+$')][string]$Version,
    [Parameter(Mandatory=$true)][ValidateSet('staging','production')][string]$Environment,
    [string]$ArtifactRoot = (Join-Path $PSScriptRoot '..\.lab\artifacts'),
    [string]$EnvironmentRoot = (Join-Path $PSScriptRoot '..\.lab\environments'),
    [switch]$Rollback
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$package = Join-Path $ArtifactRoot $Version
$manifest = Get-Content (Join-Path $package 'manifest.json') -Raw | ConvertFrom-Json
if ($manifest.version -ne $Version) { throw 'Manifest version mismatch.' }
foreach ($file in $manifest.files) {
    $actual = (Get-FileHash -LiteralPath (Join-Path $package $file.name) -Algorithm SHA256).Hash
    if ($actual -ne $file.sha256) { throw "Artifact checksum mismatch: $($file.name)" }
}
& dotnet (Join-Path $package 'ShopLite.dll') --smoke
if ($LASTEXITCODE -ne 0) { throw 'Smoke check failed; environment pointer was not changed.' }
$folder = Join-Path $EnvironmentRoot $Environment
New-Item -ItemType Directory -Path $folder -Force | Out-Null
$pointer = Join-Path $folder 'current.json'
$previous = $null
if (Test-Path -LiteralPath $pointer) { $previous = (Get-Content $pointer -Raw | ConvertFrom-Json).version }
$event = [ordered]@{
    id=[guid]::NewGuid().ToString('N'); timestampUtc=[DateTime]::UtcNow.ToString('o')
    environment=$Environment; action=$(if ($Rollback) {'rollback'} else {'deploy'})
    version=$Version; commit=$manifest.commit; previousVersion=$previous; status='succeeded'
}
$event | ConvertTo-Json | Set-Content "$pointer.tmp" -Encoding UTF8
Move-Item -LiteralPath "$pointer.tmp" -Destination $pointer -Force
$event | ConvertTo-Json -Compress | Add-Content (Join-Path $EnvironmentRoot 'deployments.jsonl') -Encoding UTF8
Write-Output "$($event.action.ToUpper()) $Environment -> $Version (previous: $previous)"
