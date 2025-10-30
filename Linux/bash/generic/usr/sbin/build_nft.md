# NFTables Example Template (nftables_example.raw)

Diese Datei ist eine **beispielhafte** NFTables-Konfiguration, die als Template verwendet werden kann. Sie enthält **keine echten IP-Adressen** und kann öffentlich weitergegeben werden.

## 🔧 Verwendung

### 1. Template an Ihr System anpassen

Bevor Sie diese Konfiguration verwenden, müssen Sie folgende Werte anpassen:

#### Netzwerk-Interfaces (Zeile 29-42)
```nftables
define if_ext       = eth0          # ← Ihr externes Interface (eth0, ens3, etc.)
define ip_ext       = 203.0.113.10  # ← Ihre externe IP-Adresse
define sub_ext      = 255.255.255.0 # ← Ihre Subnetzmaske

define if_vpn       = wg0           # ← Ihr VPN-Interface (falls vorhanden)
define ip_vpn       = 10.8.0.0/24   # ← Ihr VPN-Netzwerk

define if_docker    = docker0       # ← Ihr Docker-Interface (falls vorhanden)
define ip_docker    = 172.17.0.0/16 # ← Ihr Docker-Netzwerk
```

#### Admin-Zugriff (Zeile 21)
```nftables
define admin_hosts = {203.0.113.50/32}  # ← Ihre Admin-IP-Adressen
```

#### Services (Zeile 23-26)
```nftables
define in_tcp_dport  = {22, 25, 80, 443, 587, 993}  # ← Ihre erlaubten TCP-Ports
define in_udp_dport  = {53, 443, 51820}             # ← Ihre erlaubten UDP-Ports
define out_tcp_dport = {22, 25, 53, 80, 443, 587}   # ← Ausgehende TCP-Ports
define out_udp_dport = {53, 123}                    # ← Ausgehende UDP-Ports
```

#### Blacklist (Zeile 29)
```nftables
define in_block = {198.51.100.10, 198.51.100.20}  # ← Ihre Blacklist-IPs
```

### 2. Domain-basierte Regeln hinzufügen

Das Template enthält bereits Beispiele für domain-basierte Regeln mit `#DATA` Platzhaltern:

```nftables
# IPv4 Domains (suffix _4)
define archive.ubuntu.com_4 = {#DATA}
define security.ubuntu.com_4 = {#DATA}

# IPv6 Domains (suffix _6)
define archive.ubuntu.com_6 = {#DATA}
define security.ubuntu.com_6 = {#DATA}
```

**Fügen Sie Ihre eigenen Domains hinzu:**

```nftables
# Beispiel: Ihre eigene Anwendung
define api.example.com_4 = {#DATA}
define api.example.com_6 = {#DATA}

ip daddr {$api.example.com_4} tcp dport {443} ct state new accept comment "My API";
```

### 3. Configuration builden

Nachdem Sie das Template angepasst haben:

```bash
# DNS auflösen und finale Konfiguration erstellen
./build_nft_v2_fixed.sh nftables_example.raw /etc/nftables.conf

# Das Script führt automatisch aus:
# 1. DNS-Auflösung aller #DATA Platzhalter
# 2. Syntax-Validierung
# 3. Backup der alten Konfiguration
# 4. Laden der neuen Konfiguration
```

## 📋 Wichtige Hinweise

### Verwendete Beispiel-IPs

Alle IP-Adressen in diesem Template sind aus den **dokumentierten Beispiel-Bereichen**:
- `203.0.113.0/24` (TEST-NET-3, RFC 5737)
- `198.51.100.0/24` (TEST-NET-2, RFC 5737)
- `192.0.2.0/24` (TEST-NET-1, RFC 5737)
- `2001:db8::/32` (IPv6 Dokumentation, RFC 3849)

Diese IPs sind **speziell für Dokumentation und Beispiele** reserviert und werden niemals im Internet geroutet.

### Private Netzwerke

Die privaten Netzwerke sind standardmäßig konfiguriert:
- `10.0.0.0/8` (Class A)
- `172.16.0.0/12` (Class B)
- `192.168.0.0/16` (Class C)

### GeoIP-Blocking (Optional)

Das Template enthält auskommentierte GeoIP-Unterstützung (Zeile 105-116). Um diese zu aktivieren:

1. Installieren Sie nftables-geoip Scripts
2. Generieren Sie die GeoIP-Dateien
3. Entkommentieren Sie die entsprechenden Zeilen
4. Aktivieren Sie Geo-Blocking-Regeln (Zeile 149)

### CrowdSec Integration

Die CrowdSec-Integration ist bereits vollständig konfiguriert (ab Zeile 541):

**Installation:**
```bash
# 1. CrowdSec installieren
curl -s https://install.crowdsec.net | sudo sh

# 2. Firewall Bouncer installieren
apt install crowdsec-firewall-bouncer-nftables

# 3. Bouncer konfigurieren
# /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
```

**Bouncer Config:**
```yaml
mode: nftables
nftables:
  ipv4:
    table: crowdsec
    chain: crowdsec-chain
    set_name: crowdsec-blacklists
  ipv6:
    table: crowdsec6
    chain: crowdsec6-chain
    set_name: crowdsec6-blacklists
```

**Keine Anpassungen am NFTables-Template nötig!** Die CrowdSec-Tables sind bereits optimal konfiguriert.

## 🎯 Vorteile dieser Konfiguration

✅ **Performance-optimiert:** Regeln sind nach Häufigkeit sortiert
✅ **Scan-Detection:** Erkennt Port-Scans und böswillige Verbindungsversuche
✅ **DDoS-Schutz:** SYN-Flood-Protection und Rate-Limiting
✅ **Anti-Spoofing:** Verhindert IP-Spoofing-Angriffe
✅ **CrowdSec-Ready:** Vorkonfigurierte Integration für automatische IP-Blocks
✅ **IPv6-Support:** Vollständige IPv6-Unterstützung
✅ **VPN & Docker:** Unterstützung für VPN und Docker-Netzwerke
✅ **Domain-basiert:** Firewall-Regeln basierend auf Domains statt festen IPs

## 📚 Weitere Ressourcen

- **NFTables Wiki:** https://wiki.nftables.org/
- **NFTables Man Page:** https://www.netfilter.org/projects/nftables/manpage.html
- **CrowdSec Docs:** https://doc.crowdsec.net/
- **Build Script Guide:** Siehe BUILD_SCRIPT_GUIDE.md

## ⚠️ Sicherheitshinweis

Dieses Template ist ein **Ausgangspunkt**. Passen Sie es an Ihre spezifischen Anforderungen an:

1. ✅ Prüfen Sie alle erlaubten Ports
2. ✅ Setzen Sie korrekte Admin-IPs
3. ✅ Fügen Sie Ihre eigenen Domain-Regeln hinzu
4. ✅ Testen Sie die Konfiguration in einer Test-Umgebung
5. ✅ Aktivieren Sie Logging und überwachen Sie die Logs

**Niemals** eine Firewall-Konfiguration blind übernehmen!

## 🆘 Support

Bei Fragen zur Konfiguration:
1. Prüfen Sie die Logs: `/var/log/build_nft.log`
2. Validieren Sie die Syntax: `nft -c -f nftables.conf`
3. Testen Sie einzelne Regeln manuell
