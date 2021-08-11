function Get-Task
{
    <#
    .SYNOPSIS
        gets all tasks for a specific project
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
        [Parameter(Mandatory = $true)]
        [String]
        $Project,
        [Parameter()]
        [ValidateSet('Basic', 'Detailed')]
        [String]
        $OutputType = 'Basic'
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #get project
    $projectID = Get-Project $project | Select-Object -ExpandProperty id

    #make request
    $allTasks = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseUri)/workspaces/$($clockifySession.workspaceID)/projects/$projectID/tasks" `
        -Headers @{'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" }

    #filter by name or ID
    if ( ($Identity -match "^[0-9A-F]+$") -and ($Identity.Length -eq 24) )
    {
        $allTasks = $allTasks | Where-Object { $_.id -eq $Identity }
    }
    elseif ($Identity)
    {
        $allTasks = $allTasks | Where-Object { $_.name -eq $Identity }
    }

    #return data
    if ($OutputType -eq 'Detailed')
    {
        return $allTasks 
    }
    elseif ($null -eq $allTasks)
    {
        Write-Error "Task not found, please try again"
    }
    else
    {
        return $allTasks | Select-Object id, name, duration, status
    }
}