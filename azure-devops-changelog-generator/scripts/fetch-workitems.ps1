param(
    [Parameter(Mandatory=$true)]
    [string]$WorkItemIds,
    
    [Parameter(Mandatory=$true)]
    [string]$Organization,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "C:\Temp"
)

if (-not $env:DEVOPS_PAT) {
    Write-Error "DEVOPS_PAT environment variable not set. Please set it with your Azure DevOps PAT token."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Organization)) {
    Write-Error "Organization parameter is required."
    exit 1
}

$headers = @{
    Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$env:DEVOPS_PAT"))
}

$ids = $WorkItemIds -split '[,\s]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ } | Sort-Object -Unique

$workItems = @()

foreach ($id in $ids) {
    Write-Host "Fetching work item $id..."
    
    try {
        $resp = Invoke-RestMethod -Uri "https://dev.azure.com/$Organization/_apis/wit/workitems/$id`?api-version=7.0" -Headers $headers -Method Get
        $fields = $resp.fields
        
        $assignedTo = ""
        if ($fields.'System.AssignedTo') {
            $assignedTo = $fields.'System.AssignedTo'.displayName
        }
        
        $project = $fields.'System.TeamProject'
        
        # Fetch comments/discussion
        $comments = @()
        try {
            if ($project) {
                $commentsUrl = "https://dev.azure.com/$Organization/$project/_apis/wit/workItems/$id/comments?api-version=7.0-preview"
                $commentsResp = Invoke-RestMethod -Uri $commentsUrl -Headers $headers -Method Get
                if ($commentsResp.comments) {
                    foreach ($comment in $commentsResp.comments) {
                        $comments += @{
                            author = $comment.author.displayName
                            text = $comment.text
                            createdDate = $comment.createdDate
                        }
                    }
                }
            }
        }
        catch {
            Write-Host "  No comments available for work item $id"
        }
        
        $workItem = @{
            id = $id
            title = $fields.'System.Title'
            type = $fields.'System.WorkItemType'
            state = $fields.'System.State'
            assignedTo = $assignedTo
            description = $fields.'System.Description'
            project = $project
            comments = $comments
        }
        
        $workItems += $workItem
        Write-Host "  Retrieved: $($workItem.type) - $($workItem.state) - Project: $($workItem.project) - Comments: $($comments.Count)"
    }
    catch {
        Write-Warning "Failed to fetch work item $id : $($_.Exception.Message)"
    }
}

$output = @{
    extractedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    workItems = $workItems
} | ConvertTo-Json -Depth 10

$outputFile = Join-Path $OutputDir "workitems.json"
$output | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host ""
Write-Host "Fetched $($workItems.Count) work items"
Write-Host "Output saved to: $outputFile"

$workItems | ConvertTo-Json -Depth 10
