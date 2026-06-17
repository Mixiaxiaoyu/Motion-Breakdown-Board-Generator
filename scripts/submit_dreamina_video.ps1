[CmdletBinding()]
param(
  [string]$DreaminaPath = (Join-Path (Get-Location) "dreamina.exe"),
  [Parameter(Mandatory = $true)][string]$SourceImage,
  [Parameter(Mandatory = $true)][string]$BoardImage,
  [Parameter(Mandatory = $true)][string]$Prompt,
  [ValidateSet("1:1", "3:4", "16:9", "4:3", "9:16", "21:9")][string]$Ratio = "3:4",
  [ValidateRange(4, 15)][int]$Duration = 8,
  [ValidateSet("seedance2.0", "seedance2.0fast", "seedance2.0_vip", "seedance2.0fast_vip")][string]$ModelVersion = "seedance2.0fast",
  [ValidateSet("720p", "1080p")][string]$VideoResolution,
  [int]$Session = 0,
  [int]$SubmitPollSeconds = 20,
  [string]$DownloadDir = (Join-Path (Get-Location) "dreamina-downloads"),
  [ValidateRange(2, 3600)][int]$QueryIntervalSeconds = 10,
  [ValidateRange(1, 360)][int]$MaxWaitMinutes = 20,
  [switch]$DryRun,
  [switch]$SkipPathCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-DreaminaCommand {
  param([string]$Candidate)

  if ([string]::IsNullOrWhiteSpace($Candidate)) {
    throw "DreaminaPath cannot be empty."
  }

  if (Test-Path -LiteralPath $Candidate) {
    return (Resolve-Path -LiteralPath $Candidate).Path
  }

  $command = Get-Command $Candidate -ErrorAction SilentlyContinue
  if ($null -ne $command) {
    return $command.Source
  }

  throw "Dreamina executable not found: $Candidate"
}

function Test-InputPath {
  param(
    [string]$Path,
    [string]$Label
  )

  if (Test-Path -LiteralPath $Path) {
    return
  }

  if ($DryRun -or $SkipPathCheck) {
    Write-Warning "$Label path not found: $Path"
    return
  }

  throw "$Label path not found: $Path"
}

function Quote-Arg {
  param([string]$Value)

  if ($Value -match '[\s"]') {
    return '"' + ($Value -replace '"', '\"') + '"'
  }

  return $Value
}

function Find-FirstMatch {
  param(
    [string]$Text,
    [string[]]$Patterns
  )

  foreach ($pattern in $Patterns) {
    $match = [regex]::Match($Text, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($match.Success) {
      return $match.Groups[1].Value
    }
  }

  return $null
}

function Get-SubmitId {
  param([string]$Text)

  return Find-FirstMatch -Text $Text -Patterns @(
    '"submit_id"\s*:\s*"([^"]+)"',
    'submit_id\s*[:=]\s*"?([A-Za-z0-9-]+)"?'
  )
}

function Get-GenStatus {
  param([string]$Text)

  return Find-FirstMatch -Text $Text -Patterns @(
    '"gen_status"\s*:\s*"([^"]+)"',
    'gen_status\s*[:=]\s*"?([A-Za-z_]+)"?'
  )
}

function Get-FailReason {
  param([string]$Text)

  return Find-FirstMatch -Text $Text -Patterns @(
    '"fail_reason"\s*:\s*"([^"]+)"',
    'fail_reason\s*[:=]\s*"([^"]+)"',
    'AigcComplianceConfirmationRequired'
  )
}

function Invoke-Dreamina {
  param(
    [string]$Executable,
    [string[]]$Arguments
  )

  $preview = ($Arguments | ForEach-Object { Quote-Arg $_ }) -join " "
  Write-Host "> $Executable $preview"

  $lines = & $Executable @Arguments 2>&1 | ForEach-Object { $_.ToString() }
  $exitCode = $LASTEXITCODE
  $text = $lines -join [Environment]::NewLine

  return [pscustomobject]@{
    ExitCode = $exitCode
    Lines    = $lines
    Text     = $text
  }
}

if ($VideoResolution -eq "1080p" -and $ModelVersion -ne "seedance2.0_vip") {
  throw "1080p is only supported by model_version seedance2.0_vip according to the current CLI help."
}

$dreaminaCommand = Resolve-DreaminaCommand -Candidate $DreaminaPath
Test-InputPath -Path $SourceImage -Label "SourceImage"
Test-InputPath -Path $BoardImage -Label "BoardImage"

$submitArgs = @(
  "multimodal2video",
  "--image", $SourceImage,
  "--image", $BoardImage,
  "--prompt", $Prompt,
  "--ratio", $Ratio,
  "--duration", $Duration.ToString(),
  "--model_version", $ModelVersion,
  "--poll", $SubmitPollSeconds.ToString(),
  "--session", $Session.ToString()
)

if ($VideoResolution) {
  $submitArgs += @("--video_resolution", $VideoResolution)
}

if ($DryRun) {
  [pscustomobject]@{
    dry_run              = $true
    dreamina_command     = $dreaminaCommand
    source_image         = $SourceImage
    board_image          = $BoardImage
    prompt               = $Prompt
    ratio                = $Ratio
    duration             = $Duration
    model_version        = $ModelVersion
    video_resolution     = $VideoResolution
    submit_poll_seconds  = $SubmitPollSeconds
    download_dir         = $DownloadDir
    query_interval_secs  = $QueryIntervalSeconds
    max_wait_minutes     = $MaxWaitMinutes
    submit_command_parts = @($dreaminaCommand) + $submitArgs
  } | ConvertTo-Json -Depth 6
  exit 0
}

if (-not (Test-Path -LiteralPath $DownloadDir)) {
  New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null
}

$submitResult = Invoke-Dreamina -Executable $dreaminaCommand -Arguments $submitArgs
if ($submitResult.ExitCode -ne 0) {
  throw "Dreamina submit command failed.`n$($submitResult.Text)"
}

$submitId = Get-SubmitId -Text $submitResult.Text
if (-not $submitId) {
  throw "Dreamina submit output did not contain submit_id.`n$($submitResult.Text)"
}

$submitStatus = Get-GenStatus -Text $submitResult.Text
$submitFailReason = Get-FailReason -Text $submitResult.Text
if ($submitStatus -eq "fail" -or $submitFailReason) {
  $reason = if ($submitFailReason) { $submitFailReason } else { "Unknown Dreamina submit failure." }
  throw "Dreamina submit failed: $reason`n$($submitResult.Text)"
}

$deadline = (Get-Date).AddMinutes($MaxWaitMinutes)
$lastResult = $submitResult
$finalStatus = if ($submitStatus) { $submitStatus } else { "querying" }

while ((Get-Date) -lt $deadline) {
  if ($finalStatus -eq "success") {
    break
  }

  Start-Sleep -Seconds $QueryIntervalSeconds
  $queryArgs = @(
    "query_result",
    "--submit_id", $submitId,
    "--download_dir", $DownloadDir
  )

  $queryResult = Invoke-Dreamina -Executable $dreaminaCommand -Arguments $queryArgs
  if ($queryResult.ExitCode -ne 0) {
    throw "Dreamina query_result command failed.`n$($queryResult.Text)"
  }

  $lastResult = $queryResult
  $finalStatus = Get-GenStatus -Text $queryResult.Text
  $failReason = Get-FailReason -Text $queryResult.Text

  if ($finalStatus -eq "success") {
    break
  }

  if ($finalStatus -eq "fail" -or $failReason) {
    $reason = if ($failReason) { $failReason } else { "Unknown Dreamina query failure." }
    throw "Dreamina generation failed: $reason`n$($queryResult.Text)"
  }
}

if ($finalStatus -ne "success") {
  throw "Dreamina generation did not finish within ${MaxWaitMinutes} minutes. submit_id=$submitId"
}

[pscustomobject]@{
  dry_run          = $false
  dreamina_command = $dreaminaCommand
  submit_id        = $submitId
  final_status     = $finalStatus
  source_image     = $SourceImage
  board_image      = $BoardImage
  ratio            = $Ratio
  duration         = $Duration
  model_version    = $ModelVersion
  video_resolution = $VideoResolution
  download_dir     = $DownloadDir
  last_output      = $lastResult.Text
} | ConvertTo-Json -Depth 6
