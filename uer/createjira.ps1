import-module JiraPS

$server = 'https://scottlogic.atlassian.net'
$cred = Get-Credential

Set-JiraConfigServer -server $server

$MangedGroupName = Get-ADGroup -LDAPFilter '(managedby=*)' | Sort-Object -property Name

foreach($ManagedGroup in $MangedGroupName)
{
$UERreview = Get-ADGroup -Identity $ManagedGroup -Properties AdminDescription
if($UERreview.AdminDescription -eq "UER")
{
$ManagedGroupMember = Get-ADGroupMember -Identity $ManagedGroup
$ManagedGroupManagedBy = Get-ADGroup -Identity $ManagedGroup -Properties Name,Description,ManagedBy,mail
$FindMangedByDetails = Get-ADGroup $ManagedGroup -Properties * | Select-Object -ExpandProperty ManagedBy
$ManagedGroupManagedByName = Get-ADUser $FindMangedByDetails | Select-Object -ExpandProperty Name
$ManagedGroupManagedEmail = Get-ADUser $FindMangedByDetails -Properties * | Select-Object -ExpandProperty EmailAddress
$mgn = $ManagedGroup.name
$groupmembers = $ManagedGroupMember.name
$samaccountname = Get-ADUser $FindMangedByDetails | Select-Object -ExpandProperty SamAccountName

$parameters = @{
    Project = 'IT'
    IssueType = 'Entitlement Review'
    Reporter = 'jiraservicedesk'
    Summary = "Entitlement Review for $mgn"
    Description = "Hello $ManagedGroupManagedByName,
    
    Are these people: $groupmembers meant to be in the $mgn group?"
    Credential = $cred    
}

$fields = @{
    customfield_10003 = @(
        @{ name = "$samaccountname" }        
    )
}

New-JiraIssue @parameters -Fields $fields


}
}

 