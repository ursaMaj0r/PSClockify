function Remove-Task
{
    <#
    .SYNOPSIS
        deletes task
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/16/2020   - Inital script created
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Identity,
        [Parameter(Mandatory = $true)]
        [String]
        $Project
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

    #remove task
    if ($PSCmdlet.ShouldProcess(
            ("Overwritting existing file {0}" -f $task.name),
            ("Would you like to delete permanently {0}?" -f $task.name),
            "Remove Task:"
        )
    )
    {
        $results = Invoke-RestMethod `
            -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/projects/$projectID/tasks/$($task.id)" `
            -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
            -Method Delete
    }
    #return results
    return $results
}