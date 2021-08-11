#gets private and public functions
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source each function
Foreach ($import in @($Public + $Private))
{
    Try
    {
        Write-Output $import.fullname
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

$clockifySession = [ordered]@{
    BaseUri     = 'https://api.clockify.me/api/v1'
    ReportUri   = 'https://reports.api.clockify.me/v1'
    workspaceID = $null
    apiKey      = $null
    startTime   = $null
    elapsedTime = $null
} 

New-Variable -Name clockifySession -Value $clockifySession -Scope Script -Force

Export-ModuleMember -Function $Public.Basename