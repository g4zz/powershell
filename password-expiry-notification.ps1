# -----
# Script for getting the expiry date for users in the active directory, 
# then notifying them via email if they are within a defined number of days til expiry
# -----

# Get todays date
$date = Get-Date -format yyyyMMdd

# Variables
$smtpServer="" # Address of SMTP Server
$expireindays = 21 # Days til Password Expiry
$from = "" # Email Address Notification will be From
$logging = "Enabled" # Set to Disabled to Disable Logging
$logFile = "\\dc01\share\passwords"+$date+".csv" # Use a UNC path. Todays date will be added to the filename if $date is left in the path
$testing = "Enabled" # Set to Disabled to Email Users
$testRecipient = "" # Email Address for Testing

# Logging Settings

# Remove previous log file - Will remove the logfile only if it was created on the same day
Remove-Item $logFile # Remove Previous Log File

if (($logging) -eq "Enabled")
{
    # Test Log File Path
    $logfilePath = (Test-Path $logFile)
    if (($logFilePath) -ne "True")
    {
        # Create CSV File and Headers
        New-Item $logfile -ItemType File
        Add-Content $logfile "Date,Name,EmailAddress,DaystoExpire,ExpiresOn,Notified"
    }
} # End Logging Check

# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
# $date = Get-Date -format ddMMyyyy - Moved to top as it's needed earlier
# End System Settings

# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
Import-Module ActiveDirectory
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users)
{
    $Name = $user.GivenName
    $emailaddress = $user.emailaddress
    $passwordSetDate = $user.PasswordLastSet
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
    $sent = "" # Reset Sent Flag
    # Check for Fine Grained Password
    if (($PasswordPol) -ne $null)
    {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge
    }
    else
    {
        # No FGP set to Domain Default
        $maxPasswordAge = $DefaultmaxPasswordAge
    }

  
    $expireson = $passwordsetdate + $maxPasswordAge
    $today = (get-date)
    $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
        
    # Set Greeting based on Number of Days to Expiry.

    # Check Number of Days to Expiry
    $messageDays = $daystoexpire

    if (($messageDays) -gt "1")
    {
        $messageDays = "in " + "$daystoexpire" + " days."
    }
    else
    {
        $messageDays = "today."
    }

    # Email Subject Set Here
    $subject="Your password will expire $messageDays"
  
    # Email Body Set Here, Note You can use HTML, including Images.
    $body ="
    $name,
    <p> Your Password will expire $messageDays<br>
    Please change your password as soon as possible to avoid any issues. <br><br>
    If you're using a Windows PC, you can change your password by pressing CTRL & ALT & DEL and selecting the change password option from that screen. 
    If you're not using a Windows PC, please use on of our Windows meeting room machines, log in and follow the previous instructions.<br><br>
    If you're having issues resetting your password, replying to this email will open an IT ticket and we can help you.<br><br>
    <p>Thanks, <br>IT<br> 
    </P>"

   
    # If Testing Is Enabled - Email Administrator
    if (($testing) -eq "Enabled")
    {
        $emailaddress = $testRecipient
    } # End Testing

    # If a user has no email address listed
    if (($emailaddress) -eq $null)
    {
        $emailaddress = $testRecipient    
    }# End No Valid Email

    # Send Email Message
    if (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays))
    {
        $sent = "Yes"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent" 
        }
        # Send Email Message
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding   

    } # End Send Message
    else # Log Non Expiring Password
    {
        $sent = "No"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent" 
        }        
    }
    
} # End User Processing

# Send Email to IT Staff, Uses Test Email Address
Send-Mailmessage -smtpServer $smtpServer -from $from -to $testRecipient -subject "Expiring Passwords" -Attachments $logfile -body $logFile -bodyasHTML -priority High -Encoding $textEncoding   

# End