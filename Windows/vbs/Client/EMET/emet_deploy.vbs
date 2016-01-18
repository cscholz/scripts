
' Define Variables
strEMETPath = "d:\"
strEMETConfig = "emet.xml"
i=0



Set WshShell = WScript.CreateObject("WScript.Shell") 
Set fso = CreateObject("Scripting.FileSystemObject")

' check if EMET is already installed
if fso.FolderExists("C:\Program Files\EMET\") then
	wscript.quit
else
	' start EMET Setup
	WshShell.Run "msiexec /i " & strEMETPath & "EMET_Setup.msi /qn /norestart"

	' wait 3 seconds and check if installation has finished. If not try 10 times again with 3 seconds delay per try
	wScript.Sleep(3000)
	Do While i < 11
		if fso.FileExists("C:\Program Files\EMET\EMET_Conf.exe") then
			i=11
		End If
	i=i+1	
	wscript.sleep(3000)
	Loop

'	installation was def. finished because the emet_conf file was found within the 10 tries.
	if i="12" then
		checkConfigFile()
		WshShell.Run "C:\Programme\EMET\EMET_Conf.exe --system DEP=AlwaysOn SEHOP=ApplicationOptOut ASLR=ApplicationOptIn"
	End If
end if
Set fso = nothing


sub checkConfigFile()
'	Now check if the local config file is the current config file
	On error resume next
	strLocalFile_Date = ""
	Set strServerFile = fso.GetFile(strEMETPath & strEMETConfig)
	strServerFile_Date = strServerFile.DateLastModified
	Set strLocalFile = fso.GetFile("C:\Programme\EMET\" & strEMETConfig)
	strLocalFile_Date = strLocalFile.DateLastModified

	If DateDiff("d", strServerFile_Date, strLocalFile_Date) > 0 Then
	Wscript.echo "copy"
		fso.copyFile strEMETPath & strEMETConfig, "C:\Programme\EMET\" & strEMETConfig, True
		WshShell.Run "C:\Programme\EMET\EMET_Conf.exe --import " & strEMETPath & strEMETConfig
	End If
End Sub
