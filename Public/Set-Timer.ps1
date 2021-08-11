function Set-Timer
{
    <#
    .SYNOPSIS
        sets timer
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Identity,
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
        [String[]]
        $tags,
        [Parameter()]
        [Switch]
        $billable,
        [Parameter()]
        [Switch]
        $append,
        [Parameter()]
        [Switch]
        $restartTimer
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #get timer
    if ($identity -eq "")
    {
        $Identity = (Get-TimeEntry -inProgress | Select-Object -ExpandProperty id)
    }

    #set query parameters
    $queryParameters = @{    
        "start"    = "$((Get-TimeEntry -Identity $Identity -OutputType Detailed).timeInterval.start | Get-Date -Format "o")"
        "billable" = "$billable"
    }  
    if ($project)
    {
        $projectID = Get-Project -Identity $project | Select-Object -ExpandProperty id
        $queryParameters.Add("projectId", "$projectID")
    }
    if ($task)
    {
        $taskId = Get-Task -Identity $task -Project $projectID | Select-Object -ExpandProperty id
        $queryParameters.Add("taskId" , "$taskId")
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
    if ($description)
    {
        if ($append)
        {
            $description = "$(Get-TimeEntry -Identity $Identity | Select-Object -ExpandProperty Description) + $description"
        }
        $queryParameters.Add("description", $description)
    }

    #if enddate, add to query
    if (-not($restartTimer))
    {
        $end = "$((Get-TimeEntry -Identity $Identity -OutputType Detailed).timeInterval.end )"

        if ($end)
        {
            $end = Get-Date((Get-Date $end)).ToUniversalTime() -Format "o"
            $queryParameters.Add("end", "$end")
        }
    }
    
    

    #make request
    $queryParameters = $queryParameters | ConvertTo-Json
    $results = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/time-entries/$identity" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters `
        -Method Put

    #return results
    return $results
}