Const WbemAuthenticationLevelPktPrivacy = 6

strComputer = "localhost"
strNamespace = "root\cimv2"
strUser = ""
strPassword = ""

Set objWbemLocator = CreateObject("WbemScripting.SWbemLocator")
Set objWMIService = objwbemLocator.ConnectServer _
    (strComputer, strNamespace, strUser, strPassword)
objWMIService.Security_.authenticationLevel = WbemAuthenticationLevelPktPrivacy

Const HKLM = &H80000001
Set objReg = GetObject("winmgmts://" & strComputer & _
    "/root/default:StdRegProv")
Const strBaseKey = "Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\"
' Auflisten der Profile
objReg.EnumKey HKLM, strBaseKey, arrSubKeys
 For Each strSubKey In arrSubKeys
    intRet = objReg.GetStringValue(HKLM, strBaseKey & strSubKey, "001e6600", strValue)
'Durchsuchen der Profile
        strBaseKey2 = "Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\" & strSubKey & "\"
        objReg.EnumKey HKLM, strBaseKey2, arrSubKeys2
         For Each strSubKey2 In arrSubKeys2
            intRet = objReg.GetStringValue(HKLM, strBaseKey2 & strSubKey2, "001e6600", strValue)
            If (strValue <> "") and (intRet = 0) Then
                str=str & strValue &vbcrlf
            End If
        Next        
    If (strValue <> "") and (intRet = 0) Then
        str=str & strValue &vbcrlf
    End If
Next
wscript.echo Str