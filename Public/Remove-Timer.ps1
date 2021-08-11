function Remove-Timer
{
    <#
    .SYNOPSIS
        deletes current timer, unless id is specified
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
    #>

    param (
        [Parameter()]
        [String]
        $Identity
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #if no identity is specified, get current timer
    if (-not($Identity))
    {
        $identity = (Get-TimeEntry -inProgress).id
    }

    #make request
    $results = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/time-entries/$identity" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Method Delete

    #return results
    return $results
}