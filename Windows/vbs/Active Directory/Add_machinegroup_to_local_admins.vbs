Option Explicit 
On Error Resume Next 

Dim Mydomain 
Dim GlobalGroup 
Dim oDomainGroup 
Dim oLocalAdmGroup 
Dim oNet 
Dim strComputer 
Dim objUser
Dim str_found

Set oNet = WScript.CreateObject("WScript.Network") 
strComputer = oNet.ComputerName 


MyDomain = "domain.local" 
GlobalGroup  = "LG_Local Admins " & strComputer

Set oDomainGroup = GetObject("WinNT://" & MyDomain & "/" & GlobalGroup & ",group") 
Set oLocalAdmGroup = GetObject("WinNT://" & strComputer & "/Administrators,group") 
Set oLocalAdmGroup = GetObject("WinNT://" & strComputer & "/Administratoren,group") 


For Each objUser in oLocalAdmGroup.Members
  If objUser.Name = GlobalGroup then
    str_found = 1
  End If
Next

If str_found <> 1 then
    oLocalAdmGroup.Add(oDomainGroup.AdsPath) 
End if


'Nullify Variables 
Set Mydomain = Nothing 
Set GlobalGroup = Nothing 
Set oDomainGroup = Nothing 
Set oLocalAdmGroup = Nothing 
Set oNet = Nothing 
Set strComputer = Nothing 