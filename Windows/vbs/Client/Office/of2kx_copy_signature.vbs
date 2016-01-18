Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShelll = WScript.CreateObject("WScript.Shell") 
  Set objWSHNetwork = CreateObject("WScript.Network")

  str_target_Dir = "c:\Signatures"
  str_Signature_src = objShelll.ExpandEnvironmentStrings("%userprofile%") & "\Anwendungsdaten\Microsoft\Signatures" 
  str_Signature_dst = "\Signatures"
  If objFSO.FolderExists(str_target_Dirt) Then
     Set objFolder = objFSO.GetFolder(str_target_Dir) 
  Else 
     WScript.Echo "Ordner nicht da, er wird kopiert." 
  End If
  objFSO.CopyFolder str_Signature_src, str_target_Dir
  wscript.sleep 5000