function Get-CurrentUser
{
    <#
    .SYNOPSIS
        gets currently logged in users
    .NOTES
        History:
        Version     Who             When        What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
    #>

    [CmdletBinding()]
    param (
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

    $currentUser = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseUri)/user" `
        -Headers @{'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" }

    if ($OutputType -eq 'Detailed')
    {
        return $currentUser
    }
    else
    { 
        return $currentUser | Select-Object id, name, email, defaultWorkspace, status
    }
}