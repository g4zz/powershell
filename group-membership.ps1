# Powershell to get group membership of $group and email it

# -- Variables
$smtpServer="" # Address of SMTP server
$emailaddress="" # Email address to send the export
$from="" # Address email will be from
$textEncoding = [System.Text.Encoding]::UTF8
$group="" # Group that you want the membership of
$owner="" # Ownder of the group/resource

Import-Module ActiveDirectory

# -- Generate email
$subject="Entitlement Review of $group" # Email subject
# -- Setting body style
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}" 
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"
# -- 
$message=(Get-ADGroupMember -Identity $group | Select samAccountName,Name, @{Name="Title";Expression={(Get-ADUser $_.distinguishedName -Properties Title).title}} | ConvertTo-Html -Head $style) | Out-String
$body="<p>This is the member list for $group</p><p>$message</p>"


# -- Send email
Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -Encoding $textEncoding