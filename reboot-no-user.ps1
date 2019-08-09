#-----
# Script to restart a given machine if there is no user logged on
#-----

# Get computer name
$cn = Read-Host "Computer Name?"

# Get computer information
$gwmi = Get-WmiObject win32_computersystem -cn $cn -ErrorAction SilentlyContinue
# Extract username from WMI information
$username = $gwmi.Username

# Output username
Write-Host $username @ $cn

# If the username is equal to null, which would mean no user is logged in, then restart the machine
if ($username -eq $null)
{
Restart-Computer -cn $cn -Force
Write-Host Rebooting $cn
}

# If the username is not equal to null, which would mean the user is still logged in, then print the message
if ($username -ne $null)
{
Write-Host $username is still logged onto this machine
}