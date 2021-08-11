function Remove-Client
{
    <#
    .SYNOPSIS
        deletes client
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

    #get client
    $client = Get-Client -Identity $Identity

    #remove client
    if ($PSCmdlet.ShouldProcess(
            ("Overwritting existing file {0}" -f $client.name),
            ("Would you like to delete permanently {0}?" -f $client.name),
            "Remove Client:"
        )
    )
    {
        $results = Invoke-RestMethod `
            -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/clients/$($client.id)" `
            -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
            -Method Delete
    }
    #return results
    return $results
}