function Remove-Tag
{
    <#
    .SYNOPSIS
        deletes Tag
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

    #get tag
    $Tag = Get-Tag -Identity $Identity

    #remove tag
    if ($PSCmdlet.ShouldProcess(
            ("Overwritting existing file {0}" -f $Tag.name),
            ("Would you like to delete permanently {0}?" -f $Tag.name),
            "Remove Tag:"
        )
    )
    {
        $results = Invoke-RestMethod `
            -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/tags/$($Tag.id)" `
            -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
            -Method Delete
    }
    #return results
    return $results
}