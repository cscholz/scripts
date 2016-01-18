  Set objShell = CreateObject("WScript.Shell") 
  
  strComputer = "."
  ' This is where WMI interrogates the operating system
  Set objWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
  
  Set colItems = objWMI.ExecQuery("Select * from Win32_OperatingSystem",,48)
  
  ' Here we filter Version from the dozens of properties
  For Each objItem in colItems
  VerBig = Left(objItem.Version,3)
  Next
  
  ' Spot VerBig variable in previous section
  ' Note the output variable is called OSystem
  
  Select Case VerBig
  Case "6.0" OSystem = "Vista"
  Case "5.2" OSystem = "Windows 2003"
  Case "5.1" OSystem = "XP"
  Case "5.0" OSystem = "W2K"
  Case "4.0" OSystem = "NT 4.0**"
  Case Else OSystem = "Unknown - probably Win 9x"
  End Select
  
  Wscript.Echo "Version No : " & VerBig & vbCr _
  & "OS System : " & OSystem
  
  WScript.Quit
