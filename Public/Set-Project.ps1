function Set-Project
{
    <#
    .SYNOPSIS
        sets project
    .NOTES
        History:
        Version   Who             When         What
        1.0       Jeff Malavasi   11/16/2020   - Inital script created
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Identity,
        [Parameter()]
        [String]
        $name,
        [Parameter()]
        [String]
        $client,
        [Parameter()]
        [String]
        $color,
        [Parameter()]
        [String]
        $note,
        [Parameter()]
        [Switch]
        $billable,
        [Parameter()]
        [Switch]
        $public,
        [Parameter()]
        [Switch]
        $archive
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #get project
    $project = Get-Project -Identity $Identity

    #set query parameters
    if ($name)
    {
        $queryParameters = @{    
            "name" = "$($name)"
        }  
    }
    else
    {
        $queryParameters = @{    
            "name" = "$($project.name)"
        }  
    }  
    if ($archive)
    {
        $queryParameters.Add("archived", "True")
    }
    if ($client)
    {
        $clientID = Get-Client -Identity $client | Select-Object -ExpandProperty id
        $queryParameters.Add("clientId", "$clientId")
    }
    if ($color)
    {
        $queryParameters.Add("color", "#$color")
    }
    if ($note)
    {
        $queryParameters.Add("note", "$note")
    }

    #make request
    $queryParameters = $queryParameters | ConvertTo-Json
    $results = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/projects/$($project.id)" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters `
        -Method Put

    #return results
    return $results
}