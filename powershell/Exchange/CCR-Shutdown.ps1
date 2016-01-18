# - Change the values below to reflect your CCR Node Names and CCR cluster name

$Node1 = "<server1>"
$Node2 = "<server2>"
$Cluster = "<clustername>"
$hname = hostname

# - End custom values

$ActionQ = Read-Host "Would you like to (R)eboot or (S)hutdown (type R or S)"
$ActionFinal = $ActionQ.ToLower()

$PResultND1 = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$Node1'"
$PResultND2 = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$Node2'"

if (($PResultND1.StatusCode -eq 0) -and ($PResultND2.StatusCode -eq 0)){
	Echo "The Servers are present - checking WMI Services Status..."
	
	$ND1StatusIS = Get-WmiObject -ComputerName $Node1 win32_Service -Filter "Name='MSExchangeIS'" 
	$ND1StatusSA = Get-WmiObject -ComputerName $Node1 win32_Service -Filter "Name='MSExchangeSA'"

	$ND2StatusIS = Get-WmiObject -ComputerName $Node2 win32_Service -Filter "Name='MSExchangeIS'" 
	$ND2StatusSA = Get-WmiObject -ComputerName $Node2 win32_Service -Filter "Name='MSExchangeSA'"


	If ($ND1StatusIS.state -eq "Stopped"){
		$ND1CCRPassiveReadyIS = "1"
	}else{
		$ND1CCRPassiveReadyIS = "0"
	}	

	If ($ND1StatusSA.state -eq "Stopped"){
		$ND1CCRPassiveReadySA = "1"
	}else{
		$ND1CCRPassiveReadySA = "0"
	}	
	If ($ND2StatusIS.state -eq "Stopped"){
		$ND2CCRPassiveReadyIS = "1"
	}else{
		$ND2CCRPassiveReadyIS = "0"
	}	

	If ($ND2StatusSA.state -eq "Stopped"){
		$ND2CCRPassiveReadySA = "1"
	}else{
		$ND2CCRPassiveReadySA = "0"
	}	


	if(($ND1CCRPassiveReadyIS -eq "1") -and ($ND1CCRPassiveReadySA -eq "1") -and ($hname -eq $Node1)){
		Echo "This node ($Node1) is alread passive and the system will shutdown/reboot..."
		shutdown.exe /m \\$Node1 /$ActionFinal /t 5

	}elseif (($ND2CCRPassiveReadyIS -eq "1") -and ($ND2CCRPassiveReadySA -eq "1") -and ($hname -eq $Node2)){
		Echo "This node ($Node2) is alread passive and the system will shutdown/reboot..."
		shutdown.exe /m \\$Node2 /$ActionFinal /t 5

	}elseif (($ND1CCRPassiveReadyIS -eq "1") -and ($ND1CCRPassiveReadySA -eq "1") -and ($hname -ne $Node1)){
		Stop-ClusteredMailboxServer -identity $Cluster -StopReason "Node Close Down" -confirm:$false
		Move-ClusteredMailboxServer -identity $Cluster -TargetMachine $Node1 -MoveComment "Node close Down" -Confirm:$false
		Start-ClusteredMailboxServer -identity $Cluster
		Echo "Moving Cluster Resources to the Passive Node  $Node2..."
		Cluster.exe group "Cluster Group" /move:$Node1
		Echo "Working on Server Action..."
		shutdown.exe /m \\$Node2 /$ActionFinal /t 5
		Echo "Moving Exchange CCR Resources to the Passive Node $Node1..."

	}elseif (($ND2CCRPassiveReadyIS -eq "1") -and ($ND2CCRPassiveReadySA -eq "1") -and ($hname -ne $Node2)){
		Echo "Moving Exchange CCR Resources to the Passive Node $Node2..."
		Echo "Moving Exchange CCR Resources to the Passive Node..."
		Stop-ClusteredMailboxServer -identity $Cluster -StopReason "Node Close Down" -confirm:$false
		Move-ClusteredMailboxServer -identity $Cluster -TargetMachine $Node2 -MoveComment "Node close Down" -Confirm:$false
		Start-ClusteredMailboxServer -identity $Cluster
		Echo "Moving Cluster Resources to the Passive Node..."
		Cluster.exe group "Cluster Group" /move:$Node2
		Echo "Working on Server Action..."
		shutdown.exe /m \\$Node1 /$ActionFinal /t 5
}else{
	Echo "The Server is not present - No nodes appear to be available to OWN the Exchange Instance."
	Echo "Do you wish to close down Exchange on this node and then Shut the computer down? (Y or N)"
	$ResponseQ = Read-Host "(Y)es or (N)o"
	$ResponseFinal = $ResponseQ.ToLower()
	
	if ($ResponseFinal -eq "y"){
		
		Stop-ClusteredMailboxServer -Identity $Cluster -StopReason "Node Shutdown" -confirm:$false
		shutdown.exe /$ActionFinal /t 60
		
	}else{
	
		
	}
}
}
