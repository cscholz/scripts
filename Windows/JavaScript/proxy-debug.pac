
function FindProxyForURL(url,host)
{
        //////////////////////////////// var definitions //////////////////////////////
        // modified by: Christian Scholz

        Version			= "2015-05-30-01";
	var debug		= 0;
        var pr_no		= "DIRECT";
        var pr_server1		= "PROXY server1.suffix.local:8080";
	var pr_server2		= "PROXY server2.suffix.local:8080";
	var pr_server3		= "PROXY server3.suffix.local:8080";

	str_host		= host.toLowerCase();
	var target_ip		= dnsResolve(str_host);
	var client_ip		= myIpAddress();
	var client_ip_ary	= client_ip.split(".");

        debugPAC ="PAC Debug Information (" + Version + ")\n";
        if (debug) {
                debugPAC +="-----------------------------------\n";
                debugPAC +="Machine IP:              " + client_ip + "\n";
                debugPAC +="Target-Hostname:   " + str_host + "\n";
                debugPAC +="Target-IP:                  " + target_ip + "\n";
                debugPAC +="Domain Levels:         " + dnsDomainLevels(str_host) + "\n";
                        if (url.substring(0,5)=="http:") {protocol="http";} else
                                if (url.substring(0,6)=="https:") {protocol="https";} else
                                        if (url.substring(0,4)=="ftp:") {protocol="ftp";}
                                                else {protocol="Unknown";}
                debugPAC +="Protocol:                   " + protocol + "\n";
                debugPAC +="URL:                           " + url + "\n";
        }

        //////////////////////////////// main //////////////////////////////
        // #0
        if (dnsDomainLevels(str_host) == 0) {
                debugPAC +="Proxy:                         " + "no (#0 singlename-match)" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_no;
        }

        // #1
        if (target_ip == "1.1.1.1" ||
                target_ip == "127.0.0.1") {
                debugPAC +="Proxy:                         " + "no #1" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_no;
        }

        // #2
        if (isInNet(target_ip, "10.0.0.0","255.0.0.0") ||
		isInNet(target_ip, "172.10.0","255.255.255.0") ||
                isInNet(target_ip, "192.168.0","255.255.255.0")) {
                debugPAC +="Proxy:                         " + "no (#2 net-match)" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_no;
        }

        // #3
        if (shExpMatch(url,"citrix.suffix.local*")  ||
                shExpMatch(url,"webserver1.intra.local*")) {
                debugPAC +="Proxy:                         " + "no (#3 exp-match)" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_no;
        }

        // #4
        if (dnsDomainIs(str_host, ".suffix.local") ||
                dnsDomainIs(str_host, ".intra.local")) {
                debugPAC +="Proxy:                         " + "no (#4 dns-match)" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_no;
        }

		// #6.1 check client IP - Range 1
        if (isInNet(client_ip, "10.1.0.0","255.255.0.0") ||
                isInNet(client_ip, "10.2.0.0","255.255.0.0")) {
               debugPAC +="Proxy:                         " + "pr_server1 (#6.1 check client IP - Range 1)" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_server1;
        }

                // #6.2 check client IP - Range 2
        if (isInNet(client_ip, "10.3.0.0","255.255.0.0") ||
                isInNet(client_ip, "10.4.0.0","255.255.0.0")) {
                debugPAC +="Proxy:                         " + "pr_Server2 (#6.2 check client IP - Range 2)" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_server2;
        }

                // #6.3 check client IP - Range 3
        if (isInNet(client_ip, "10.5.0.0","255.255.0.0") ||
                isInNet(client_ip, "10.6.0.0","255.255.0.0")) {
                debugPAC +="Proxy:                         " + "pr_server3 (#6.3 check client IP - Range 3)" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_server3;
        }

                // #5
                if(url.substring(0, 4) == "ftp:"){
                FTPPac ="FTP Verbindungsinformation\n";
                FTPPac +="-----------------------------------\n";
                FTPPac +="Sollte die Verbindung zum FTP-Server nicht \n";
                FTPPac +="funktionieren, verwenden Sie bitte folgende Syntax:\n";
                FTPPac +="\n";
                FTPPac +="ftp://<user>:<password>@<host>:<port>/<url-path>\n";
                {alert(FTPPac);}
                return pr_server1;
        }		
		
        // #7
        else {
                debugPAC +="Proxy:                        " + "pr_server1 (#7 fallback)" + "\n";
                if (debug) {alert(debugPAC);}
                return pr_server1;
        }
}

