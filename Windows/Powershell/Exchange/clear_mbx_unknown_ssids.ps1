[string]::Join(',',("Mailbox,SID,AccessRight")) > C:\rights.csv
#$res = Get-Mailbox -ResultSize unlimited 
$res = Get-Mailbox | where {($_.Database -like "ServerA**") -or ($_.Database -like "ServerB**")} 

foreach ($mb in $res){
  $name = $mb.name
  $mm = Get-MailboxPermission $mb.name -DomainController DC123 |?{($_.User -ne "NT Authority")-and ($_.isinherited -eq $false) }

  foreach ($User in $mm)
  {
    if ($user.user -match "S-1-5-21")
    {
      $UsrName = $mb.Name
      $SID = $User.User
      $AccessRights = $user.AccessRights
      write-host $mb.name
      Remove-MailboxPermission -identity $mb.name -user $SID -AccessRight FullAccess -InheritanceType All -WhatIf
      [string]::Join(",",($usrname,$sid,$AccessRights)) >> C:\rights.csv
    }

  }
}

