#!/usr/bin/env bash
set -euo pipefail

PACKAGE="mggt-assistant"
VERSION="0.1.0"
ARCH="all"

TOOL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="/tmp/${PACKAGE}_${VERSION}_${ARCH}_build"
DEB="$TOOL_ROOT/${PACKAGE}_${VERSION}_${ARCH}.deb"

echo "============================================================"
echo "Construction du paquet Debian : $PACKAGE"
echo "============================================================"
echo
echo "Dossier outil : $TOOL_ROOT"
echo "Build        : $BUILD"
echo "Paquet       : $DEB"
echo

if [ ! -d "$TOOL_ROOT/bin" ]; then
  echo "[ERREUR] Dossier manquant : $TOOL_ROOT/bin"
  exit 1
fi

if [ ! -d "$TOOL_ROOT/scripts" ]; then
  echo "[ERREUR] Dossier manquant : $TOOL_ROOT/scripts"
  exit 1
fi

rm -rf "$BUILD"

mkdir -p "$BUILD/DEBIAN"
mkdir -p "$BUILD/usr/bin"
mkdir -p "$BUILD/usr/share/mggt-tools"

cat > "$BUILD/DEBIAN/control" <<CTRL
Package: $PACKAGE
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: MUPINI KABWE Albert <albertmupini21@gmail.com>
Depends: bash, git, coreutils, findutils, sed, grep
Recommends: tree, vagrant
Description: Assistant terminal MGGT1103 pour creer et verifier les travaux pratiques
 mggt-assistant fournit des outils interactifs pour creer une structure MGGT1103,
 initialiser Git, guider le professeur, naviguer dans les TP, verifier Git et
 assister les environnements Vagrant et VirtualBox.
CTRL

cp -r "$TOOL_ROOT/bin" "$BUILD/usr/share/mggt-tools/"
cp -r "$TOOL_ROOT/scripts" "$BUILD/usr/share/mggt-tools/"

if [ -d "$TOOL_ROOT/lib" ]; then
  cp -r "$TOOL_ROOT/lib" "$BUILD/usr/share/mggt-tools/"
fi

if [ -d "$TOOL_ROOT/docs" ]; then
  cp -r "$TOOL_ROOT/docs" "$BUILD/usr/share/mggt-tools/"
fi

if [ -f "$TOOL_ROOT/README.md" ]; then
  cp "$TOOL_ROOT/README.md" "$BUILD/usr/share/mggt-tools/README.md"
fi

chmod +x "$BUILD/usr/share/mggt-tools/bin/"* 2>/dev/null || true
chmod +x "$BUILD/usr/share/mggt-tools/scripts/"*.sh 2>/dev/null || true
chmod +x "$BUILD/usr/share/mggt-tools/lib/"*.sh 2>/dev/null || true

for tool in mggt-init mggt-assistant mggt-doctor tpnav gitnav vagrantnav; do
  if [ -f "$BUILD/usr/share/mggt-tools/bin/$tool" ]; then
    cat > "$BUILD/usr/bin/$tool" <<EOF2
#!/usr/bin/env bash
bash /usr/share/mggt-tools/bin/$tool "\$@"
EOF2
    chmod +x "$BUILD/usr/bin/$tool"
    echo "[OK] Commande ajoutée : $tool"
  else
    echo "[INFO] Commande ignorée car absente : $tool"
  fi
done

dpkg-deb --build "$BUILD" "$DEB"

echo
echo "============================================================"
echo "Paquet créé avec succès"
echo "============================================================"
echo
echo "$DEB"
echo
echo "Installation locale :"
echo "sudo apt install \"$DEB\" -y"
