on error resume next
Set objOutlook = CreateObject("Outlook.Application.11")
Set objNS = objOutlook.GetNamespace("MAPI")
Set fso = CreateObject("Scripting.FileSystemObject") 

For Each objFolder In objNS.Folders
  If GetPSTPath(objFolder.StoreID) <> "" Then
    If fso.FileExists(GetPSTPath(objFolder.StoreID)) then
       Wscript.Echo GetPSTPath(objFolder.StoreID)
    End If
  end if
Next



Function GetPSTPath(input)
   For i = 1 To Len(input) Step 2
       strSubString = Mid(input,i,2)        
       If Not strSubString = "00" Then
           strPath = strPath & ChrW("&H" & strSubString)
       End If
   Next
   
   Select Case True
       Case InStr(strPath,":\") > 0    
           GetPSTPath = Mid(strPath,InStr(strPath,":\")-1)
       Case InStr(strPath,"\\") > 0    
           GetPSTPath = Mid(strPath,InStr(strPath,"\\"))
   End Select
End Function
