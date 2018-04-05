Param(
    # One KB bulletin ID per line
    [Parameter(Mandatory = $True, Position = 0)]
    [System.IO.FileSystemInfo]$kbList, 
    
    # If filtering, the organization's ID that you've defined in Kaseya (System > Orgs/Groups/Depts/Staff > Manage)
    [Parameter(Position = 1)]
    [string]$organizationID
)

$kbList = "C:\users\wallen\Desktop\patches.txt"

if (!(Test-Path "C:\temp\")) {
    New-Item "C:\temp\" -ItemType Directory
}


Invoke-Sqlcmd -query "select machname, groupname, displayName from machnametab where agentguid in (select distinct(agentguid) from patchstatus where bulletinId like '%KB4088877%')" -Database "ksubscribers"
Invoke-SQL | Out-File "C:\machines.csv"
