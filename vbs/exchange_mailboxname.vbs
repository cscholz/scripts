' Funktioniert nur unter Office 200x
' Bei 2007 muss Outlook schon gestartet sein

Set objOutlook = CreateObject("Outlook.Application.12")
Set objNS = objOutlook.GetNamespace("MAPI")

Wscript.echo objNS.CurrentUser.Name
