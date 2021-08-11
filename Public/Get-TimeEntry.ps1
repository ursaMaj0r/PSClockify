function Get-TimeEntry
{
    <#
    .SYNOPSIS
        gets all time entries for a specific user
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
        [String]
        $User,
        [Parameter()]
        [int]
        $ResultSize,
        [Parameter()]
        [string]
        $description,
        [Parameter()]
        [ValidateSet('Basic', 'Detailed')]
        [String]
        $OutputType = 'Basic',
        [Parameter()]
        [switch]
        $inProgress
    )

    #exit if no active session is open
    if (-not(Test-Session))
    {
        Write-Error 'No active connection found, please run Connect-Session.'
        exit
    }

    #get user ID
    if ($null -eq $user )
    {
        $userID = Get-User -OutputType Detailed | Where-Object { $_.name = "$user" } | Select-Object -ExpandProperty id
    }
    else
    {
        $userID = Get-CurrentUser -OutputType Detailed | Select-Object -ExpandProperty id
    }
    
    #set query parameters
    $queryParameters = @{}

    if ($resultSize)
    {
        $queryParameters.Add("page-size", "$resultSize")
    }

    if ($description)
    {
        $queryParameters.Add("description", "$description")
    }

    if ($inProgress)
    {
        $queryParameters.Add("in-progress", "true")
    }


    #get time entries
    $allTimeEntries = Invoke-RestMethod `
        -Uri "$($clockifySession.BaseUri)/workspaces/$($clockifySession.workspaceID)/user/$userID/time-entries" `
        -Headers @{'X-Api-Key' = "$(ConvertFrom-SecureString $clockifySession.apiKey -AsPlainText)" } `
        -Body $queryParameters

    #return results
    if ($Identity)
    {
        $allTimeEntries = $allTimeEntries | Where-Object { $_.id -eq $Identity }
    }
    if ($OutputType -eq 'Detailed')
    {
        return $allTimeEntries 
    }
    else
    {
        return $allTimeEntries | Select-Object id, description, tagids, taskid, projectid
    }
}