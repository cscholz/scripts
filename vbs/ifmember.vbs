Const str_ex_migration = "Administratoren"

Set ADSysInfo = CreateObject("ADSystemInfo")
Set CurrentUser = GetObject("LDAP://" & ADSysInfo.UserName)
strGroups = LCase(Join(CurrentUser.MemberOf))

If not InStr(strGroups, str_ex_migration) > 0 Then
  wscript.echo "Du bist Mitglied der Gruppe " & str_ex_migration
End If