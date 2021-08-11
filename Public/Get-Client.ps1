function Get-Client
{
    <#
    .SYNOPSIS
        gets all Clients
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
    $allClients = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseUri)/workspaces/$($clockifySession.workspaceID)/clients" `
        -Headers @{'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" }

    #filter by name or ID
    if ( ($Identity -match "^[0-9A-F]+$") -and ($Identity.Length -eq 24) )
    {
        $allClients = $allClients | Where-Object { $_.id -eq $Identity }
    }
    elseif ($Identity)
    {
        $allClients = $allClients | Where-Object { $_.name -eq $Identity }
    }

    #return data
    if ($OutputType -eq 'Detailed')
    {
        return $allClients 
    }
    elseif ($null -eq $allClients)
    {
        Write-Error "Client not found, please try again"
    }
    else
    {
        return $allClients | Select-Object id, name, archived
    }
}