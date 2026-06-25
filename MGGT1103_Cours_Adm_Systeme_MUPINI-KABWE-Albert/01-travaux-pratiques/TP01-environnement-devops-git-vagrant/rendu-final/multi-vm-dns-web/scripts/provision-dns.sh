#!/usr/bin/env bash
set -euo pipefail

echo "[DNS] Mise à jour du système"
apt-get update -y

echo "[DNS] Installation de Bind9"
apt-get install -y bind9 bind9utils dnsutils

echo "[DNS] Configuration de la zone mggt1103.local"

cat > /etc/bind/named.conf.local <<'BINDCONF'
zone "mggt1103.local" {
    type master;
    file "/etc/bind/db.mggt1103.local";
};
BINDCONF

cat > /etc/bind/db.mggt1103.local <<'ZONE'
$TTL    604800
@       IN      SOA     srv-dns.mggt1103.local. admin.mggt1103.local. (
                              2
                         604800
                          86400
                        2419200
                         604800 )

@       IN      NS      srv-dns.mggt1103.local.
srv-dns IN      A       192.168.56.10
srv-web IN      A       192.168.56.20
web     IN      A       192.168.56.20
client  IN      A       192.168.56.30
ZONE

named-checkconf
named-checkzone mggt1103.local /etc/bind/db.mggt1103.local

systemctl restart bind9
systemctl enable bind9

echo "[DNS] Serveur DNS prêt : 192.168.56.10"
