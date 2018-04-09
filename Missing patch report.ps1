Param(
    # One KB bulletin ID per line
    [Parameter(Mandatory = $True, Position = 0)]
    [string]$listPath, 
    
    # If filtering, the organization's ID that you've defined in Kaseya (System > Orgs/Groups/Depts/Staff > Manage)
    [Parameter(Position = 1)]
    [string]$organizationID
)

<# --------------------------------------------------------------------------------------------------------------
Kaseya VSA Missing Patch Report
Version: 20180409b
Made by: Witt Allen
Objective: Return a list of machines missing the KB article IDs that are input

DEPENDANCIES & ASSUMPTIONS:
- Script will be ran as Administrator
- Script will be ran on VSA database server
# --------------------------------------------------------------------------------------------------------------
#>

$kbList = Get-Content -Path $listPath

$reportName = "Patch report "
$date = Get-Date -UFormat "%m-%d-%Y"

if ($organizationID -ne $null) {
    $reportName += "for " + $organizationID + " "
} 
$reportName += $date + ".csv"

if (!(Test-Path "C:\temp\")) {
    New-Item "C:\temp\" -ItemType Directory
}
if (Test-Path "C:\temp\$reportName") {
    Remove-Item -Path "C:\temp\$reportName" -Force
}

foreach ($kb in $kbList) { 
    $sqlQuery = "select machname, groupname, displayName from machnametab where agentguid in (select distinct(agentguid) `
                from patchstatus where bulletinId like '%"+ $kb + "%')"
    Invoke-Sqlcmd -query $sqlQuery -Database "ksubscribers" | `
        Where-Object {$_.groupname -Like "*$organizationID"} | `
        Out-File -FilePath "C:\temp\$reportName" -Encoding default -Append
}

Write-Host "$reportName is ready in C:\temp\"
