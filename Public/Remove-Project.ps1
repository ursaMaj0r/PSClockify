function Remove-Project
{
    <#
    .SYNOPSIS
        deletes project
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/16/2020   - Inital script created
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Identity
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #get project
    $project = Get-Project -Identity $Identity

    #remove client
    if ($PSCmdlet.ShouldProcess(
            ("Overwritting existing file {0}" -f $project.name),
            ("Would you like to delete permanently {0}?" -f $project.name),
            "Remove Project:"
        )
    )
    {
        $results = Invoke-RestMethod `
            -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/projects/$($project.id)" `
            -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
            -Method Delete
    }
    #return results
    return $results
}