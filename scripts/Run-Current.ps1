param(
    [ValidateSet('staging','production')][string]$Environment='production',
    [string]$ArtifactRoot=(Join-Path $PSScriptRoot '..\.lab\artifacts'),
    [string]$EnvironmentRoot=(Join-Path $PSScriptRoot '..\.lab\environments'),
    [switch]$ProbeLoyalty
)
$ErrorActionPreference='Stop'
$current=Get-Content (Join-Path $EnvironmentRoot "$Environment\current.json") -Raw | ConvertFrom-Json
Write-Output "RUN $Environment $($current.version) commit=$($current.commit)"
$dll=Join-Path $ArtifactRoot "$($current.version)\ShopLite.dll"
if ($ProbeLoyalty) { & dotnet $dll --probe-loyalty } else { & dotnet $dll }
exit $LASTEXITCODE
