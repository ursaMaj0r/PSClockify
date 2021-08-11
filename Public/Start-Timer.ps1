function Start-Timer
{
    <#
    .SYNOPSIS
        starts timer
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $description,
        [Parameter()]
        [String]
        $project,
        [Parameter()]
        [String]
        $task,
        [Parameter()]
        [Switch]
        $billable,
        [Parameter()]
        [String[]]
        $tags
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #set query parameters
    $queryParameters = @{     
        "start"       = "$(Get-Date (Get-Date).ToUniversalTime() -Format "o")"
        "billable"    = "$billable"
        "description" = "$description"
    }  
    if ($project)
    {
        $projectID = Get-Project -Identity $project | Select-Object -ExpandProperty id
        $queryParameters.Add("projectId", "$projectID")
    }
    if ($tags)
    {
        $tagIds = @()

        foreach ($tag in $tags)
        {
            $tagIds += Get-Tag $tag | Select-Object -ExpandProperty id
        }
        $queryParameters.Add("tagIds", $tagIds)
    }
    if ($task)
    {
        $taskID = Get-Task -Project $project | Where-Object { $_.name -eq $task } | Select-Object -ExpandProperty id
        $queryParameters.Add("taskId", $taskID)
    }
    
    #make request
    $queryParameters = $queryParameters | ConvertTo-Json
    $results = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/time-entries" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters `
        -Method Post

    #return results
    return $results
}