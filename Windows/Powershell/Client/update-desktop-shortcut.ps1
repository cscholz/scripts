$table = Get-ChildItem ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs") -Filter *.lnk 

foreach ($file in $table) {
	Write-Host 
	(ls $file.FullName).lastwritetime = get-date
}
