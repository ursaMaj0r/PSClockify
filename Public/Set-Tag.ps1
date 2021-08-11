function Set-Tag
{
    <#
    .SYNOPSIS
        sets Tag
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
        [Switch]
        $archive
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #get Tag
    $Tag = Get-Tag -Identity $Identity

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
            "name" = "$($Tag.name)"
        }  
    }
    if ($archive)
    {
        $queryParameters.Add("archived", "True")
    }

    #make request
    $queryParameters = $queryParameters | ConvertTo-Json
    $results = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseURI)/workspaces/$($clockifySession.workspaceID)/tags/$($Tag.id)" `
        -Headers @{'Content-Type' = 'application/json'; 'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters `
        -Method Put

    #return results
    return $results
}