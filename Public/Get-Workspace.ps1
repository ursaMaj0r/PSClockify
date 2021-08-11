function Get-Workspace
{
    <#
    .SYNOPSIS
        gets Clockify Workspace
    .NOTES
        History:
        Version     Who             When        What
        1.0       Jeff Malavasi   9/25/2019   - Inital script created
    #>
    
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('Basic', 'Detailed')]
        [String]
        $OutputType = 'Basic',
        [Parameter()]
        [String]
        $Identity
    )

    #make request
    $allWorkspaces = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseUri)/workspaces" `
        -Headers @{'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" }
    
    #filter by name or ID
    if ( ($Identity -match "^[0-9A-F]+$") -and ($Identity.Length -eq 24) )
    {
        $allWorkspaces = $allWorkspaces | Where-Object { $_.id -eq $Identity }
    }
    elseif ($Identity)
    {
        $allWorkspaces = $allWorkspaces | Where-Object { $_.name -eq $Identity }
    }

    #ouput results
    if ($OutputType -eq 'Detailed')
    {
        return $allWorkspaces
    }
    else
    { 
        return $allWorkspaces | Select-Object id, name, featureSubscriptionType
    }
}