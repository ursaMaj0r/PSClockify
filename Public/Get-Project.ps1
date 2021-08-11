function Get-Project
{
    <#
    .SYNOPSIS
        gets all projects
    .NOTES
         History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/14/2020   - Inital script created
    #>
    
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Identity,
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

    #make request
    $allProjects = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseUri)/workspaces/$($clockifySession.workspaceID)/projects" `
        -Headers @{'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" }

    #filter by name or ID
    if ( ($Identity -match "^[0-9A-F]+$") -and ($Identity.Length -eq 24) )
    {
        $allProjects = $allProjects | Where-Object { $_.id -eq $Identity }
    }
    elseif ($Identity)
    {
        $allProjects = $allProjects | Where-Object { $_.name -eq $Identity }
    }

    #return data
    if ($OutputType -eq 'Detailed')
    {
        return $allProjects 
    }
    elseif ($null -eq $allProjects)
    {
        Write-Error "Project not found, please try again"
    }
    else
    {
        return $allProjects | Select-Object id, name, duration, clientName, public
    }
}