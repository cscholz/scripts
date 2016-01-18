Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFolder = objFSO.GetFolder("c:\")

  For Each tFil In objFolder.Files
    If InStrRev(tFil.Name, ".log") Then _
      wscript.echo objFSO.BuildPath(objFolder.Path, tFil.Name)
  Next
  Set objFolder = Nothing