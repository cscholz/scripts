# Create key
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
    
# Bind configuration
To allow key based updates to a specific dns zone the zone need to know the key name allowed:

    zone "ddns.domain.tld" in {
            type master;
            file "/etc/bind/zones/ddns.domain.tld.zone";
            allow-query { any; };
            allow-update { key "ddns.domain.tld."; };
    };

They key itself have also be to be set:

    key "ddns.domain.tld." {
      algorithm HMAC_SHA512;
      secret "XJkUlJPh0k+OX5GDJ0SqD4yWcA5BvIUY7HGNbdkaH3K1Rgjlx5Tz318GhvOtQDcZj8QZRBzxeeF21ELVpW0U2g==";
    };

# Client configuration

On the client side the key is exactly the same as on the server side:

**/path/to/dns.key:**

    key "ddns.domain.tld." {
      algorithm HMAC_SHA512;
      secret "XJkUlJPh0k+OX5GDJ0SqD4yWcA5BvIUY7HGNbdkaH3K1Rgjlx5Tz318GhvOtQDcZj8QZRBzxeeF21ELVpW0U2g==";
    };
