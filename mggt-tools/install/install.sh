#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$HOME/.local/share/mggt-tools"
BIN_DIR="$HOME/.local/bin"

echo "============================================================"
echo "Installation utilisateur de mggt-tools"
echo "============================================================"
echo
echo "Source       : $SOURCE_DIR"
echo "Installation : $APP_DIR"
echo "Commandes    : $BIN_DIR"
echo

mkdir -p "$APP_DIR" "$BIN_DIR"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"

cp -r "$SOURCE_DIR/bin" "$APP_DIR/"
cp -r "$SOURCE_DIR/scripts" "$APP_DIR/"
cp -r "$SOURCE_DIR/lib" "$APP_DIR/"
cp -r "$SOURCE_DIR/docs" "$APP_DIR/" 2>/dev/null || true
cp "$SOURCE_DIR/README.md" "$APP_DIR/README.md" 2>/dev/null || true

chmod +x "$APP_DIR/bin/"*
chmod +x "$APP_DIR/scripts/"*.sh
chmod +x "$APP_DIR/lib/"*.sh

for launcher in "$APP_DIR/bin/"*; do
  tool="$(basename "$launcher")"

  cat > "$BIN_DIR/$tool" <<EOF2
#!/usr/bin/env bash
bash "$APP_DIR/bin/$tool" "\$@"
EOF2

  chmod +x "$BIN_DIR/$tool"
  echo "[OK] commande installée : $tool"
done

if ! grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "[OK] PATH ajouté dans ~/.bashrc"
fi

echo
echo "Installation terminée."
echo
echo "Rechargez le terminal :"
echo "source ~/.bashrc"
echo
echo "Commandes principales :"
echo "mggt-assistant"
echo "mggt-doctor"
echo "tpnav"
echo "gitnav"
echo "vagrantnav"
