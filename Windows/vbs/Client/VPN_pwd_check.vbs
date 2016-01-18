'http://stackoverflow.com/questions/5556806/change-password-expiration-date-in-active-directory-using-vbs
Const SEC_IN_DAY = 86400
Const ADS_UF_DONT_EXPIRE_PASSWD = &h10000

Set objSysInfo = CreateObject("ADSystemInfo")
strUser = objSysInfo.UserName
Set objOU = GetObject("LDAP://" & strUser)


intCurrentValue = objOU.Get("userAccountControl")

If intCurrentValue and ADS_UF_DONT_EXPIRE_PASSWD Then
  wscript.echo "The password does not expire."
Else
  dtmValue = objOU.PasswordLastChanged 

   If 90-int(now - dtmValue) < 14 Then
     MsgBox "Your password will expire in " & 90-int(now - dtmValue) & " days." & chr(13) & "Please change it in time!" & chr(13) & chr(13) & "1. Connect to Vallourec Network (VPN/WLAN)" & chr(13) & "2. Press Ctrl+Alt+Del and change your password" & chr(13) & "3. Lock your computer via Ctrl+Alt+Del" & chr(13) & "4. Unlock the machine with your new password", 0, "ActiveDirectory-Password will expire soon"
   End If
End If

