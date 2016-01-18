# http://www.johndcook.com/PowerShellCookbook.html#a19
# Default: Set-Executionpolicy restricted
# Modify: Set-Executionpolicy unrestricted

$dnsserver="DNS-Server"
$zonename="Zonenname"
$createptr="true"

$info = get-content dns.txt
foreach ($i in $info) {
    $temp=$i.ToLower() -replace "\(", " "
    $temp1=$temp -replace "\)", " "
    $temp=$temp1 -replace "Alias", " "
    $temp1=$temp -replace " Host ", " "
    $temp=$temp1 -replace "\s *", " "
   	$line = $temp.split(" ") 
#    Write-Host $line
	$hostname = $line[0]
	$dnstype = $line[1].ToUpper()
	$target  = $line[2]
	$forward = "dnscmd $dnsserver /recordadd $zonename $hostname $dnstype $target"
    $forward
	

	If ($createptr -eq "true"){
		if ($target -as [ipaddress]){
			$ipv4   = $target.split(".")
			$result = "dnscmd $dnsserver /recordadd "
			$result += $ipv4[1]
			$result += "."
			$result += $ipv4[0]
			$result += ".in-addr.arpa "
			$result += $ipv4[3]
			$result += "."
			$result += $ipv4[2]
			$result += " PTR $hostname"
			$result += ".$zonename"
			$result += "."
			$result.ToLower()
		}
	}

#	Write-Host "Hostname ": $hostname
#	Write-Host "DNS-Typ": $dnstype
#	Write-Host "Target" : $target
}
exit

