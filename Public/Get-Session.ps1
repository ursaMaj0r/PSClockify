function Get-Session
{
    <#
    .SYNOPSIS
        gets session information
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
        2.0       Jeff Malavasi   11/17/2020   - updated from file to session
    #>

    if ($null -eq $clockifySession.workspaceID)
    {
        Write-Error -Message "Oops! No Workspace ID found, try running Set-ClockifyEnvironment first."
    }

    if ($clockifySession.apiKey -eq "")
    {
        Write-Error -Message "Oops! No API Key found, try running Set-ClockifyEnvironment first."
    }

    return $clockifySession
}