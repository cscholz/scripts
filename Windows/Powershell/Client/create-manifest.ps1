$table = Get-ChildItem ($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs") -Filter *.lnk 

foreach ($file in $table) {

	# Dateiname auslesen
	$sh = New-Object -COM WScript.Shell
	$FullTargetPath = $sh.CreateShortcut($file.FullName).TargetPath 

	# Pfad und Dateiname ohne Erweiterung extrahieren
	$FileNameWithoutExtension = ([System.IO.FileInfo]($FullTargetPath)).Name.Split('.')[0]
	$TargetFolder = split-path $FullTargetPath 

	# Manifest-Datei für jedes Ziel der Verknüpfung mit dem Namen der Zielanwendung erstellen
	Write-Host ($TargetFolder + "\" + $FileNameWithoutExtension + ".VisualElementsManifest.xml")
	Set-Content -Value "<Application xmlns:xsi=$([char]34)http://www.w3.org/2001/XMLSchema-instance$([char]34)>" -Path ($TargetFolder + "\" + $FileNameWithoutExtension + ".VisualElementsManifest.xml")
	Add-Content -Value "    <VisualElements>" -Path ($TargetFolder + "\" + $FileNameWithoutExtension + ".VisualElementsManifest.xml")
	Add-Content -Value "        BackgroundColor=$([char]34)#535353$([char]34)" -Path ($TargetFolder + "\" + $FileNameWithoutExtension + ".VisualElementsManifest.xml")
	Add-Content -Value "        ShowNameOnSquare150x150Logo=$([char]34)on$([char]34)" -Path ($TargetFolder + "\" + $FileNameWithoutExtension + ".VisualElementsManifest.xml")
	Add-Content -Value "        ForegroundText=$([char]34)light$([char]34)/>" -Path ($TargetFolder + "\" + $FileNameWithoutExtension + ".VisualElementsManifest.xml")
	Add-Content -Value "</Application>" -Path ($TargetFolder + "\" + $FileNameWithoutExtension + ".VisualElementsManifest.xml")

	# Vernüpfungen aktualisieren
	 (ls $file.FullName).lastwritetime = get-date
}