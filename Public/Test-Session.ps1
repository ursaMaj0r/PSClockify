function Test-Session
{
    <#
    .SYNOPSIS
        tests connection to workspace
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/17/2020   - Inital script created
    #>
    [CmdletBinding()]
    [OutputType('System.Boolean')]
    param()
    
    try
    {
        $workspace = Get-Workspace -Identity $clockifySession.workspaceID -ErrorAction SilentlyContinue
    }
    catch
    {
        $false
    }

    if ( $workspace.count -eq 1 -and $workspace.id -eq $clockifySession.workspaceID)
    {
        $true
    }
}