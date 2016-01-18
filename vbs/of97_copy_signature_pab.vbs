Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell") 

  str_target_Dir = "c:\Signatures"

  str_windir = objShell.ExpandEnvironmentStrings("%windir%")
  If objFSO.FileExists(str_windir & "\Microsoft Outlook.rtf") Then
    call objFSO.CopyFile (str_windir & "\Microsoft Outlook.rtf", str_target_Dir & "\")
    call objFSO.CopyFile (str_windir & "\*.pab", str_target_Dir & "\")
  End If
