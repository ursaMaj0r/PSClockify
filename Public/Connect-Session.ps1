function Connect-Session
{
    <#
    .SYNOPSIS
        opens session with Clockify
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
        2.0       Jeff Malavasi   11/17/2020   - updated from file to session
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $workspace,
        [Parameter()]
        [String]
        $apiKey
    )

    
    #set apiKey
    if ($apiKey)
    {
        $clockifySession.apiKey = $apiKey | ConvertTo-SecureString -AsPlainText -Force
    }

    #set workspaceID
    if ($workspace)
    {
        $clockifySession.workspaceID = Get-Workspace -Identity $workspace | Select-Object -ExpandProperty id
    }

    #test connection
    if ( Test-Session )
    {
        $clockifySession.startTime = Get-Date -Format "o"
        $clockifySession.elapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
        return 'Success'
    }
    else
    {
        return 'Connection Attempt failed.'
    }
}