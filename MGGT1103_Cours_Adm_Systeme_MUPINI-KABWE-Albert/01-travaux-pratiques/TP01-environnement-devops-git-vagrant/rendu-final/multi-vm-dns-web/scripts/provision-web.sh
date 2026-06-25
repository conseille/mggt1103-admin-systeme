#!/usr/bin/env bash
set -euo pipefail

echo "[WEB] Mise à jour du système"
apt-get update -y

echo "[WEB] Installation Apache2 et outils DNS"
apt-get install -y apache2 dnsutils curl

echo "[WEB] Configuration DNS vers srv-dns"
cat > /etc/systemd/resolved.conf <<'RESOLVED'
[Resolve]
DNS=192.168.56.10
Domains=mggt1103.local
RESOLVED

systemctl restart systemd-resolved || true

echo "[WEB] Création de la page web"
cat > /var/www/html/index.html <<'HTML'
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>MGGT1103 - Serveur Web</title>
  <style>
    body { font-family: Arial, sans-serif; background: #eef6ff; color: #08244a; padding: 40px; }
    .card { background: white; border-radius: 16px; padding: 28px; max-width: 760px; box-shadow: 0 10px 30px rgba(0,0,0,.12); }
    h1 { color: #0b63d8; }
    code { background: #eaf2ff; padding: 4px 7px; border-radius: 6px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Serveur Web MGGT1103 opérationnel</h1>
    <p>Ce serveur Web est déployé automatiquement avec Vagrant.</p>
    <p>Nom DNS attendu : <code>web.mggt1103.local</code></p>
    <p>Adresse IP : <code>192.168.56.20</code></p>
    <p>Services : Apache2 + résolution DNS locale.</p>
  </div>
</body>
</html>
HTML

systemctl restart apache2
systemctl enable apache2

echo "[WEB] Serveur Web prêt : http://192.168.56.20"
