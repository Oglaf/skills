param(
    [Parameter(Mandatory=$false)]
    [string]$InputFile = "C:\Temp\workitems.json",
    
    [Parameter(Mandatory=$true)]
    [string]$Organization,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "C:\Temp\cards.md"
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

$cardsContent = New-Object System.Text.StringBuilder

foreach ($wi in $data.workItems) {
    $summary = Get-PlainText -Html $wi.description
    
    if ([string]::IsNullOrWhiteSpace($summary)) {
        $summary = $wi.title
    }
    
    [void]$cardsContent.AppendLine("## $($wi.id) - $($wi.title) ($($wi.type))")
    [void]$cardsContent.AppendLine("")
    [void]$cardsContent.AppendLine("State: $($wi.state)")
    [void]$cardsContent.AppendLine("Assigned to: $($wi.assignedTo)")
    [void]$cardsContent.AppendLine("Project: $($wi.project)")
    [void]$cardsContent.AppendLine("Link: https://dev.azure.com/$Organization/_workitems/edit/$($wi.id)")
    [void]$cardsContent.AppendLine("")
    [void]$cardsContent.AppendLine($summary)
    [void]$cardsContent.AppendLine("")
    [void]$cardsContent.AppendLine("---")
    [void]$cardsContent.AppendLine("")
}

$cardsContent.ToString() | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "Cards file generated: $OutputFile"
Write-Host "Total cards: $($data.workItems.Count)"
