function New-Tag
{
    <#
    .SYNOPSIS
        creates a Tag
    .NOTES
        History:
        Version     Who             When        What
        1.0       Jeff Malavasi   11/16/2020   - Inital script created
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $name
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #set query parameters
    $queryParameters = @{     
        "name" = "$name"
    } | ConvertTo-Json

    #make request
    $result = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/tags" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters `
        -Method Post

    return $result 
}