function Stop-Timer
{
    <#
    .SYNOPSIS
        stops the currently running timer for a user
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
    #>

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #get user ID
    $userID = Get-CurrentUser -OutputType Detailed | Select-Object -ExpandProperty id

    #set query parameters
    $queryParameters = @{     
        "end" = "$(Get-Date (Get-Date).ToUniversalTime() -Format "o")"
    } | ConvertTo-Json

    #make request
    $results = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/user/$userID/time-entries" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters `
        -Method Patch

    #return results
    return $results
}