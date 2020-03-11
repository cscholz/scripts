# Description
The script ddnsupdate can be used to update a host record in an bind delegated domain
for a client with a dynamic assigend public ip.
The function is comparable with dyndns but without the need to use third party service.

# Usage

     $ ddnsupdate {a-record} {dns-zone.tld} {dns-server} {/path/to/dns.key} {http://ifconfig.me/ip}"

## Update mechanism

    $ ddnsupdate -u

## Debug

    $ ddnsupdate -v

# Requirementes
## Key creation
Key should be created with a length of 512 bit:

    dnssec-keygen -a hmac-sha256 -b 256 -n HOST ddns.domain.tld

The result are two files:

**Kddns.domain.tld.+165+64481.key**

    ddns.domain.tld. IN KEY 512 3 165 XJkUlJPh0k+OX5GDJ0SqD4yWcA5BvIUY7HGNbdkaH3K1Rgjlx5Tz318G hvOtQDcZj8QZRBzxeeF21ELVpW0U2g==

**Kddns.domain.tld.+165+64481.private**

    Private-key-format: v1.3
    Algorithm: 165 (HMAC_SHA512)
    Key: XJkUlJPh0k+OX5GDJ0SqD4yWcA5BvIUY7HGNbdkaH3K1Rgjlx5Tz318GhvOtQDcZj8QZRBzxeeF21ELVpW0U2g==
    Bits: AAA=
    Created: 20200311100749
    Publish: 20200311100749
    Activate: 20200311100749

Important are the lines:

    Algorithm: 165 (HMAC_SHA512)
    Key: XJkUlJPh0k+OX5GDJ0SqD4yWcA5BvIUY7HGNbdkaH3K1Rgjlx5Tz318GhvOtQDcZj8QZRBzxeeF21ELVpW0U2g==
    
## Bind Server Configuration
To allow key based updates to a specific dns zone the zone need to know the key name allowed:

    zone "ddns.domain.tld" in {
            type master;
            file "/etc/bind/zones/ddns.domain.tld.zone";
            allow-query { any; };
            allow-update { key "ddns.domain.tld."; };
    };

They key itself have also to be set:

    key "ddns.domain.tld." {
      algorithm HMAC_SHA512;
      secret "XJkUlJPh0k+OX5GDJ0SqD4yWcA5BvIUY7HGNbdkaH3K1Rgjlx5Tz318GhvOtQDcZj8QZRBzxeeF21ELVpW0U2g==";
    };

## Client Configuration

On the client side the key is exactly the same as on the server side:

**/path/to/dns.key:**

    key "ddns.domain.tld." {
      algorithm HMAC_SHA512;
      secret "XJkUlJPh0k+OX5GDJ0SqD4yWcA5BvIUY7HGNbdkaH3K1Rgjlx5Tz318GhvOtQDcZj8QZRBzxeeF21ELVpW0U2g==";
    };

# mechanism to check of an dns update is required
1. Client checks if *${STATE_FILE}* exists.
- **Yes:** Wait until the file becomes older than '${MTIME}' before performing next cross check between public ip and a record
- **No:**  Script runs for the first time or a reboot occured. Go ahead.
2. Client queries *${IP_DETECT_URL}* to get public IP
3. Client queries *${DNS_SERVER}* for the host record *${DNS_RECORD}* in the zone *${DNS_ZONE}*
- **Public IP =  Host Record:** No update required. *${STATE_FILE}* is created. 
- **Public IP != Host Record:** Execute nsupdate to update host record to public ip
