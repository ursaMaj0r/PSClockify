function Disconnect-Session
{
    <#
    .SYNOPSIS
        closes session with Clockify
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/17/2020   - Inital script created
    #>

    #if active connection, disconnect
    if ( Test-Session )
    {
        $clockifySession.workspaceID = $null
        $clockifySession.apiKey = $null
        $clockifySession.startTime = $null
        $clockifySession.elapsedTime = $null
        return 'Disconnected'
    }
    else
    {
        return 'No active connection to disconnect.'
    }
}