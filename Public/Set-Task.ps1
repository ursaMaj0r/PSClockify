function Set-Task
{
    <#
    .SYNOPSIS
        sets task
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Identity,
        [Parameter()]
        [String]
        $name,
        [Parameter(Mandatory = $true)]
        [String]
        $Project,
        [Parameter()]
        [ValidateSet('ACTIVE', 'DONE')]
        [String]
        $Status
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #get project
    $projectID = Get-Project $project | Select-Object -ExpandProperty id

    #get task
    $task = Get-Task -Identity $Identity -Project $project

    #set query parameters
    if ($name)
    {
        $queryParameters = @{    
            "name" = $name
        }  
    }
    else
    {
        $queryParameters = @{    
            "name" = "$($task.name)"
        }  
    }
    if ($status)
    {
        $queryParameters.Add("status", "$status")
    }
    if ($archive)
    {
        $queryParameters.Add("archived", "True")
    }

    #make request
    $queryParameters = $queryParameters | ConvertTo-Json
    $results = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/projects/$projectID/tasks/$($task.id)" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters `
        -Method Put

    #return results
    return $results
}