function New-Task
{
    <#
    .SYNOPSIS
        creates a task
    .NOTES
        History:
        Version     Who             When        What
        1.0       Jeff Malavasi   11/15/2020   - Inital script created
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
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

    #set query parameters
    $queryParameters = @{     
        "name" = $name
    } 
    if ($status)
    {
        $queryParameters.Add("status", "$status")
    }
    
    #make request
    $queryParameters = $queryParameters | ConvertTo-Json
    $result = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/projects/$projectID/tasks" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters `
        -Method Post

    return $result 
}