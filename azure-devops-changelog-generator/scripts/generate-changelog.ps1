param(
    [Parameter(Mandatory=$false)]
    [string]$InputFile = "C:\Temp\workitems.json",
    
    [Parameter(Mandatory=$true)]
    [string]$Organization,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "C:\Temp\changelog.md"
)

if (-not (Test-Path $InputFile)) {
    Write-Error "Input file not found: $InputFile"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Organization)) {
    Write-Error "Organization parameter is required."
    exit 1
}

$jsonContent = Get-Content $InputFile -Raw -Encoding UTF8
$data = $jsonContent | ConvertFrom-Json

function Get-PlainText {
    param([string]$Html)
    
    if ([string]::IsNullOrWhiteSpace($Html)) {
        return ""
    }
    
    $text = $Html -replace '<[^>]+>', ' '
    $text = $text -replace '\s+', ' '
    $text = $text.Trim()
    
    return $text
}

function Get-Category {
    param([string]$Type)
    
    switch ($Type) {
        "User Story" { return "New Features" }
        "Bug" { return "Bug Fixes" }
        "Task" { return "Improvements" }
        default { return "Improvements" }
    }
}

$projectData = @{}

foreach ($wi in $data.workItems) {
    $project = $wi.project
    if ([string]::IsNullOrWhiteSpace($project)) {
        $project = "Unknown Project"
    }
    
    if (-not $projectData.ContainsKey($project)) {
        $projectData[$project] = @{
            newFeatures = @()
            bugFixes = @()
            improvements = @()
        }
    }
    
    $category = Get-Category -Type $wi.type
    $summary = Get-PlainText -Html $wi.description
    
    if ([string]::IsNullOrWhiteSpace($summary)) {
        $summary = $wi.title
    }
    
    $item = "- **$($wi.id)** - $($wi.title)"
    $item = $item + [Environment]::NewLine + "  " + $summary
    
    if ($category -eq "New Features") {
        $projectData[$project].newFeatures += $item
    }
    elseif ($category -eq "Bug Fixes") {
        $projectData[$project].bugFixes += $item
    }
    else {
        $projectData[$project].improvements += $item
    }
}

$sb = New-Object System.Text.StringBuilder

[void]$sb.AppendLine("# Release Changelog")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("This release includes changes from the following Azure DevOps projects:")
[void]$sb.AppendLine("")

$projects = $projectData.Keys | Sort-Object
foreach ($proj in $projects) {
    [void]$sb.AppendLine("- $proj")
}

[void]$sb.AppendLine("")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")

foreach ($proj in $projects) {
    $projData = $projectData[$proj]
    
    [void]$sb.AppendLine("## $proj")
    [void]$sb.AppendLine("")
    
    if ($projData.newFeatures.Count -gt 0) {
        [void]$sb.AppendLine("### New Features")
        $projData.newFeatures | ForEach-Object { [void]$sb.AppendLine($_); [void]$sb.AppendLine("") }
    }
    
    if ($projData.bugFixes.Count -gt 0) {
        [void]$sb.AppendLine("### Bug Fixes")
        $projData.bugFixes | ForEach-Object { [void]$sb.AppendLine($_); [void]$sb.AppendLine("") }
    }
    
    if ($projData.improvements.Count -gt 0) {
        [void]$sb.AppendLine("### Improvements")
        $projData.improvements | ForEach-Object { [void]$sb.AppendLine($_); [void]$sb.AppendLine("") }
    }
    
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
}

$sb.ToString() | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Changelog file generated: $OutputFile"

foreach ($proj in $projects) {
    $projData = $projectData[$proj]
    Write-Host "$proj - Features: $($projData.newFeatures.Count), Bug Fixes: $($projData.bugFixes.Count), Improvements: $($projData.improvements.Count)"
}
