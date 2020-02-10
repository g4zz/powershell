# Create issues in Jira via API, using JiraPS 3rd party powershell module

import-module JiraPS

# Variables
$server = 'server'
$cred = Get-Credential # If using Jira cloud, your password needs to be your API token

# Set jira server
Set-JiraConfigServer -server $server

# Getting each active directory group that has the 'managedby' field filled
$MangedGroupName = Get-ADGroup -LDAPFilter '(managedby=*)' | Sort-Object -property Name

# For each of the groups found fill in variables which will be used to create tickets via the API
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

# Parameters to use to create the ticket via the 'New-JiraIssue' command
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

# Create the issue using the parameters above
New-JiraIssue @parameters -Fields $fields


}
}

 