on error resume next

Const ADS_PROPERTY_DELETE = 4 
i=0

dim oupath(3)
oupath(0)="OU=Deactivated Accounts,OU=Site1,DC=domain,DC=tld"
oupath(1)="OU=Deactivated Accounts,OU=Site2,DC=domain,DC=tld"
oupath(2)="OU=Deactivated Accounts,OU=Site3,DC=domain,DC=tld"


' logging part
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objLogFile = objFSO.OpenTextFile("c:\status.log", ForAppending, TRUE)
Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8
Dim objFSO, objLogFile

' ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 

Function WriteLog(LogMessage)
  objLogFile.Writeline(Now() & ": " & LogMessage)
  wscript.echo LogMessage
End Function

' ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 

wscript.echo "Alle Aenderungen der Gruppenmitgliedsschaft werden unter c:\status.log protokolliert." & chr(13) & "Passen Sie den Pfad evtl. an!"
wscript.sleep 5000

For i=0 to UBound(oupath)-1
  Set objOU = GetObject("LDAP://" & oupath(i))
  objOU.Filter = Array("user")

  For Each objUser In objOU
'   set username
    objmemberOf  = objUser.GetEx("memberOf")
    For Each objGroup in objmemberOf 

'   get group Name
    ary_group_CN = split(objGroup,"=")
    ary_group2 = split(ary_group_CN(1),",")

'   check if group is a distribution list    
 
    if left(ary_group2(0),3) = "DL " then
      Set objGroup = GetObject ("LDAP://" & objGroup)
      objGroup.PutEx ADS_PROPERTY_DELETE, "member", Array("CN=" & objUser.cn &  "," & oupath(i))
      WriteLog objUser.cn & " removed from -> " & ary_group2(0)
'      objGroup.SetInfo
      end if
    Next
  next
Next