# Powershell to get all staff details and email them

# -- Variables
$smtpServer="int.scottlogic.co.uk" # Address of SMTP server
$emailaddress="gemms@scottlogic.com" # Email address to send the export
$from="gemms@scottlogic.com" # Address email will be from
$textEncoding = [System.Text.Encoding]::UTF8

Import-Module ActiveDirectory

# -- Generate email
$subject="All Staff Report" # Email subject

# -- Get information template
# -- @{n="Manager";e={(Get-AdUser -Identity $_.Manager -Properties displayName).displayName}} is an expression used to get manager's displayname

#get-aduser -Filter * -SearchBase 'OU=Newcastle,OU=Staff,DC=scottlogic,DC=co,DC=uk' -Properties * | select Name,Title,@{n="Manager";e={(Get-AdUser -Identity $_.Manager -Properties displayName).displayName}},Office | Sort-Object -Property Manager,Name

# -- Split information into 4 seperate tables, one for each office
# -- Sorting by Manager,Name
# -- Converting to HTML and then outputting as a string for putting into the email body
$newcastle=(get-aduser -Filter * -SearchBase 'OU=Newcastle,OU=Staff,DC=scottlogic,DC=co,DC=uk' -Properties * | select Name,Title,@{n="Manager";e={(Get-AdUser -Identity $_.Manager -Properties displayName).displayName}},Office | Sort-Object -Property Manager,Name | ConvertTo-Html -Head $style) | Out-String
$bristol=(get-aduser -Filter * -SearchBase 'OU=Bristol,OU=Staff,DC=scottlogic,DC=co,DC=uk' -Properties * | select Name,Title,@{n="Manager";e={(Get-AdUser -Identity $_.Manager -Properties displayName).displayName}},Office | Sort-Object -Property Manager,Name | ConvertTo-Html -Head $style) | Out-String
$edinburgh=(get-aduser -Filter * -SearchBase 'OU=Edinburgh,OU=Staff,DC=scottlogic,DC=co,DC=uk' -Properties * | select Name,Title,@{n="Manager";e={(Get-AdUser -Identity $_.Manager -Properties displayName).displayName}},Office | Sort-Object -Property Manager,Name | ConvertTo-Html -Head $style) | Out-String
$london=(get-aduser -Filter * -SearchBase 'OU=London,OU=Staff,DC=scottlogic,DC=co,DC=uk' -Properties * | select Name,Title,@{n="Manager";e={(Get-AdUser -Identity $_.Manager -Properties displayName).displayName}},Office | Sort-Object -Property Manager,Name | ConvertTo-Html -Head $style) | Out-String
# -- Putting information into the $body variable for email
$body="<p>Newcastle</p>
    <p>$newcastle</p>
    <p>Bristol</p>
    <p>$bristol</p>
    <p>Edinburgh</p>
    <p>$edinburgh</p>
    <p>London</p>
    <p>$london</p>"

# -- Send email
Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -Encoding $textEncoding