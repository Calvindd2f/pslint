# Connect to the user object via ADSI
$user = [ADSI]"LDAP://CN=cbergin,OU=Users,DC=yourdomain,DC=local"

# --- Disable 'User must change password at next logon' ---
# Set pwdLastSet to -1 (means "password has been set and does not need to be changed")
$user.Put("pwdLastSet", -1)

# --- Disable 'Password expires' ---
# Get current userAccountControl and set the DONT_EXPIRE_PASSWD bit (0x10000)
$uac = $user.Get("userAccountControl")
$uac = $uac -bor 0x10000
$user.Put("userAccountControl", $uac)

# Commit changes
$user.SetInfo()

Write-Host "Updated user 'cbergin' to not require password change and password never expires." -ForegroundColor Green