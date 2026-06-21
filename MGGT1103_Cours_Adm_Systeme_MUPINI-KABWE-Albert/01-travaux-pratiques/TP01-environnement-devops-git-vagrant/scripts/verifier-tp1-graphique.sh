#!/usr/bin/env bash

# ============================================================
# MGGT1103 - TP01 Explorer
# Développeur : MUPINI KABWE ALBERT
# Cours : MGGT1103 - Administration Système, Cloud-Native & DevOps
# Titulaire : Dr. Roméo NIBITANGA
# Environnement : WSL Ubuntu
# Technologies : Bash, HTML, CSS, JavaScript
#
# Rôle :
# Générer une interface graphique dédiée au TP01.
# L'interface ressemble à un explorateur de fichiers :
# dossiers, fichiers, droits Linux, résultats console et ouverture.
#
# Mode :
# Lecture seule. Le script ne modifie aucun fichier du TP01.
# ============================================================

set -u

PROJECT_NAME="Bureau-MUPINI-KABWE-ALBERT-MGGT1103"
TP_NAME="TP01-environnement-devops-git-vagrant"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(pwd)"
fi

TP1="$REPO_ROOT/$PROJECT_NAME/02-travaux-pratiques/$TP_NAME"
OUTPUT="$TP1/resultats/tp01-explorer.html"

mkdir -p "$TP1/resultats"

STUDENT_NAME="MUPINI KABWE ALBERT"
EMAIL="$(git config --global user.email 2>/dev/null || echo "albertmupini21@gmail.com")"
COURSE="MGGT1103 - Administration Système, Cloud-Native & DevOps"
TEACHER="Dr. Roméo NIBITANGA"
GEN_DATE="$(date '+%d/%m/%Y %H:%M:%S')"

escape_html() {
  sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/"/\&quot;/g'
}

count_files() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f ! -name ".gitkeep" | wc -l
  else
    echo 0
  fi
}

count_scripts() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f -name "*.sh" | wc -l
  else
    echo 0
  fi
}

file_type() {
  local name="$1"
  local ext="${name##*.}"

  case "$ext" in
    png|jpg|jpeg|webp) echo "Capture" ;;
    md) echo "Markdown" ;;
    docx) echo "Word" ;;
    pdf) echo "PDF" ;;
    sh) echo "Script Bash" ;;
    txt|log) echo "Résultat" ;;
    html) echo "HTML" ;;
    *) echo "Fichier" ;;
  esac
}

file_href() {
  local path="$1"
  local win_path

  if command -v wslpath >/dev/null 2>&1; then
    win_path="$(wslpath -w "$path" | sed 's#\\#/#g; s# #'%20'#g')"
    printf 'file:///%s' "$win_path"
  else
    printf 'file://%s' "$(realpath "$path" | sed 's# #'%20'#g')"
  fi
}

perm() {
  stat -c '%A' "$1" 2>/dev/null || echo "-"
}

size() {
  du -h "$1" 2>/dev/null | awk '{print $1}' || echo "-"
}

mod_date() {
  stat -c '%y' "$1" 2>/dev/null | cut -d'.' -f1 || echo "-"
}

status_word() {
  if [ -e "$1" ]; then
    echo "OK"
  else
    echo "ABSENT"
  fi
}

captures="$(count_files "$TP1/captures")"
rapports="$(count_files "$TP1/rapport")"
resultats="$(count_files "$TP1/resultats")"
rendu="$(count_files "$TP1/rendu-final")"
scripts="$(count_scripts "$TP1/scripts")"

readme_status="$(status_word "$TP1/rendu-final/README.md")"
vagrant_status="$(status_word "$TP1/rendu-final/Vagrantfile")"
rapport_status="$(status_word "$TP1/rapport/rapport-seance1.md")"

parasites="$(find "$TP1" \( -name "*:Zone.Identifier" -o -name "Thumbs.db" -o -name ".DS_Store" -o -name "*.tmp" -o -name "*~" \) 2>/dev/null | wc -l)"

score=0
total=7

[ -d "$TP1/captures" ] && score=$((score + 1))
[ -d "$TP1/rapport" ] && score=$((score + 1))
[ -d "$TP1/rendu-final" ] && score=$((score + 1))
[ -d "$TP1/scripts" ] && score=$((score + 1))
[ "$readme_status" = "OK" ] && score=$((score + 1))
[ "$vagrant_status" = "OK" ] && score=$((score + 1))
[ "$rapport_status" = "OK" ] && score=$((score + 1))

percent=$((score * 100 / total))

git_branch="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || echo "non détectée")"
git_commits="$(git -C "$REPO_ROOT" rev-list --count HEAD 2>/dev/null || echo "0")"
git_last="$(git -C "$REPO_ROOT" log -1 --oneline 2>/dev/null | escape_html || echo "aucun commit")"
git_status="$(git -C "$REPO_ROOT" status --short 2>/dev/null | escape_html || echo "Git indisponible")"

cat > "$OUTPUT" <<HTML_HEAD
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>TP01 Explorer - MGGT1103</title>
  <style>
    :root {
      --black: #0b0b0d;
      --black2: #121216;
      --panel: #18181d;
      --orange: #ff8a00;
      --orange2: #ffb347;
      --white: #ffffff;
      --soft: #f4f4f5;
      --line: #2b2b31;
      --muted: #a1a1aa;
      --green: #22c55e;
      --red: #ef4444;
      --blue: #60a5fa;
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      background: var(--black);
      color: var(--white);
      font-family: "Segoe UI", Arial, sans-serif;
      overflow: hidden;
    }

    .welcome {
      position: fixed;
      inset: 0;
      background:
        radial-gradient(circle at top left, rgba(255,138,0,.25), transparent 35%),
        linear-gradient(135deg, #000000, #18181d);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 50;
    }

    .welcome-card {
      width: 760px;
      background: rgba(18,18,22,.92);
      border: 1px solid rgba(255,138,0,.45);
      border-radius: 22px;
      padding: 34px;
      box-shadow: 0 25px 80px rgba(0,0,0,.55);
    }

    .welcome-card h1 {
      margin: 0;
      font-size: 38px;
      color: var(--orange);
    }

    .welcome-card p {
      color: #e5e7eb;
      line-height: 1.6;
      font-size: 16px;
    }

    .btn-row {
      display: flex;
      gap: 14px;
      margin-top: 24px;
    }

    button, .btn {
      border: 0;
      border-radius: 10px;
      padding: 11px 16px;
      cursor: pointer;
      font-weight: 700;
      text-decoration: none;
      display: inline-block;
    }

    .btn-primary {
      background: var(--orange);
      color: #111;
    }

    .btn-secondary {
      background: #27272a;
      color: var(--white);
      border: 1px solid #3f3f46;
    }

    .btn-primary:hover {
      background: var(--orange2);
    }

    .app {
      display: grid;
      grid-template-rows: 54px 1fr;
      height: 100vh;
    }

    .topbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      background: #09090b;
      border-bottom: 1px solid var(--line);
      padding: 0 16px;
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
      font-weight: 800;
      color: var(--orange);
    }

    .window-actions {
      display: flex;
      gap: 8px;
    }

    .window-actions button {
      padding: 8px 12px;
      background: #27272a;
      color: white;
      border: 1px solid #3f3f46;
    }

    .window-actions button:hover {
      background: var(--orange);
      color: #111;
    }

    .workspace {
      display: grid;
      grid-template-columns: 270px 1fr;
      min-height: 0;
    }

    .sidebar {
      background: #111114;
      border-right: 1px solid var(--line);
      padding: 16px;
      overflow-y: auto;
    }

    .sidebar-title {
      font-size: 12px;
      color: var(--muted);
      text-transform: uppercase;
      letter-spacing: .08em;
      margin: 0 0 12px;
    }

    .nav-btn {
      width: 100%;
      background: transparent;
      color: #e5e7eb;
      text-align: left;
      border: 1px solid transparent;
      margin-bottom: 8px;
    }

    .nav-btn:hover,
    .nav-btn.active {
      border-color: rgba(255,138,0,.45);
      background: rgba(255,138,0,.12);
      color: var(--orange);
    }

    .content {
      background: #0f0f12;
      padding: 18px;
      overflow-y: auto;
    }

    .section {
      display: none;
    }

    .section.active {
      display: block;
    }

    .cards {
      display: grid;
      grid-template-columns: repeat(5, minmax(140px, 1fr));
      gap: 14px;
      margin-bottom: 18px;
    }

    .card {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 16px;
      box-shadow: 0 12px 35px rgba(0,0,0,.25);
    }

    .card small {
      color: var(--muted);
      display: block;
      margin-bottom: 8px;
    }

    .card strong {
      font-size: 26px;
      color: var(--orange);
    }

    .panel {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 14px;
      overflow: hidden;
      margin-bottom: 18px;
    }

    .panel h2 {
      margin: 0;
      padding: 14px 16px;
      border-bottom: 1px solid var(--line);
      color: var(--orange);
      font-size: 19px;
      background: #111114;
    }

    .panel-body {
      padding: 16px;
    }

    .explorer {
      display: grid;
      grid-template-columns: 260px 1fr;
      gap: 16px;
    }

    .folder-tree {
      background: #0b0b0d;
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 14px;
      font-family: Consolas, monospace;
      color: #e5e7eb;
      white-space: pre-wrap;
      overflow-x: auto;
      line-height: 1.45;
      max-height: 520px;
      overflow-y: auto;
    }

    .search {
      width: 100%;
      padding: 12px;
      background: #09090b;
      border: 1px solid #3f3f46;
      color: white;
      border-radius: 10px;
      margin-bottom: 12px;
      font-size: 15px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      background: #101014;
      border-radius: 12px;
      overflow: hidden;
    }

    th {
      background: #18181d;
      color: var(--orange);
      text-align: left;
      padding: 11px;
      border-bottom: 1px solid var(--line);
      font-size: 13px;
    }

    td {
      padding: 10px;
      border-bottom: 1px solid var(--line);
      color: #e5e7eb;
      font-size: 13px;
      vertical-align: top;
    }

    code {
      font-family: Consolas, monospace;
      color: #fbbf24;
    }

    .badge {
      display: inline-block;
      padding: 4px 8px;
      border-radius: 999px;
      background: rgba(255,138,0,.14);
      color: var(--orange);
      border: 1px solid rgba(255,138,0,.35);
      font-size: 12px;
      font-weight: 800;
    }

    a {
      color: var(--blue);
      font-weight: 800;
      text-decoration: none;
    }

    a:hover {
      text-decoration: underline;
    }

    .progress {
      height: 24px;
      background: #27272a;
      border-radius: 999px;
      overflow: hidden;
      border: 1px solid #3f3f46;
    }

    .bar {
      height: 100%;
      background: linear-gradient(90deg, #ff8a00, #fbbf24);
      color: #111;
      font-weight: 900;
      text-align: center;
      line-height: 24px;
    }

    .console {
      background: #000;
      color: var(--orange);
      border: 1px solid rgba(255,138,0,.45);
      border-radius: 12px;
      padding: 16px;
      font-family: Consolas, monospace;
      white-space: pre-wrap;
      line-height: 1.45;
      max-height: 560px;
      overflow: auto;
    }

    .ok { color: var(--green); }
    .bad { color: var(--red); }
    .muted { color: var(--muted); }

    .suggestion {
      background: #0b0b0d;
      border-left: 5px solid var(--orange);
      padding: 12px;
      border-radius: 10px;
      margin-bottom: 10px;
      line-height: 1.5;
    }
  </style>
</head>
<body>

<div class="welcome" id="welcome">
  <div class="welcome-card">
    <h1>TP01 Explorer</h1>
    <p>
      Interface graphique de vérification du TP01. Elle affiche la structure réelle du TP,
      les fichiers, les droits Linux, les résultats console et les éléments importants du rendu.
    </p>
    <p>
      Développeur : <strong>$STUDENT_NAME</strong><br>
      Cours : <strong>MGGT1103</strong> — Titulaire : <strong>Dr. Roméo NIBITANGA</strong>
    </p>
    <div class="btn-row">
      <button class="btn-primary" onclick="enterApp()">ENTRER</button>
      <button class="btn-secondary" onclick="exitApp()">SORTIE</button>
    </div>
  </div>
</div>

<div class="app">
  <div class="topbar">
    <div class="brand">🟧 TP01 Explorer <span class="muted">| WSL Ubuntu | Lecture seule</span></div>
    <div class="window-actions">
      <button onclick="showSection('accueil', this)">Accueil</button>
      <button onclick="exitApp()">Sortie</button>
    </div>
  </div>

  <div class="workspace">
    <aside class="sidebar">
      <p class="sidebar-title">Menu TP01</p>
      <button class="nav-btn active" onclick="showSection('accueil', this)">Accueil</button>
      <button class="nav-btn" onclick="showSection('explorateur', this)">Explorateur</button>
      <button class="nav-btn" onclick="showSection('rendu', this)">Rendu final</button>
      <button class="nav-btn" onclick="showSection('console', this)">Résultat console</button>
      <button class="nav-btn" onclick="showSection('analyse', this)">Analyse locale</button>
      <button class="nav-btn" onclick="showSection('apropos', this)">À propos</button>
    </aside>

    <main class="content">
      <section id="accueil" class="section active">
        <div class="cards">
          <div class="card"><small>Captures</small><strong>$captures</strong></div>
          <div class="card"><small>Rapport</small><strong>$rapports</strong></div>
          <div class="card"><small>Résultats</small><strong>$resultats</strong></div>
          <div class="card"><small>Rendu final</small><strong>$rendu</strong></div>
          <div class="card"><small>Scripts</small><strong>$scripts</strong></div>
        </div>

        <div class="panel">
          <h2>Indice local de vérification</h2>
          <div class="panel-body">
            <div class="progress"><div class="bar" style="width:${percent}%;">$percent%</div></div>
            <p>Score : <strong>$score/$total</strong></p>
            <p class="muted">Généré le $GEN_DATE depuis WSL Ubuntu.</p>
          </div>
        </div>
      </section>

      <section id="explorateur" class="section">
        <div class="panel">
          <h2>Explorateur du TP01</h2>
          <div class="panel-body explorer">
            <div class="folder-tree">
HTML_HEAD

tree "$TP1" -L 3 | escape_html >> "$OUTPUT"

cat >> "$OUTPUT" <<HTML_TABLE
            </div>
            <div>
              <input class="search" id="search" onkeyup="filterRows()" placeholder="Rechercher un fichier, un droit, un type...">
              <table>
                <tr>
                  <th>Type</th>
                  <th>Nom</th>
                  <th>Droits</th>
                  <th>Taille</th>
                  <th>Modification</th>
                  <th>Action</th>
                </tr>
HTML_TABLE

find "$TP1" -type f ! -name ".gitkeep" | sort | while read -r f; do
  name_raw="$(basename "$f")"
  name="$(printf '%s' "$name_raw" | escape_html)"
  type="$(file_type "$name_raw")"
  p="$(perm "$f")"
  s="$(size "$f")"
  d="$(mod_date "$f")"
  href="$(file_href "$f")"

  cat >> "$OUTPUT" <<HTML_ROW
                <tr class="row">
                  <td><span class="badge">$type</span></td>
                  <td>$name</td>
                  <td><code>$p</code></td>
                  <td>$s</td>
                  <td>$d</td>
                  <td><a href="$href" target="_blank">Ouvrir</a></td>
                </tr>
HTML_ROW
done

cat >> "$OUTPUT" <<HTML_MID
              </table>
            </div>
          </div>
        </div>
      </section>

      <section id="rendu" class="section">
        <div class="panel">
          <h2>Contrôle du rendu final</h2>
          <div class="panel-body">
            <table>
              <tr><th>Élément</th><th>Statut</th><th>Emplacement attendu</th></tr>
              <tr><td>README.md</td><td><span class="badge">$readme_status</span></td><td><code>rendu-final/README.md</code></td></tr>
              <tr><td>Vagrantfile</td><td><span class="badge">$vagrant_status</span></td><td><code>rendu-final/Vagrantfile</code></td></tr>
              <tr><td>Rapport séance 1</td><td><span class="badge">$rapport_status</span></td><td><code>rapport/rapport-seance1.md</code></td></tr>
            </table>
          </div>
        </div>
      </section>

      <section id="console" class="section">
        <div class="panel">
          <h2>Résultat console intégré</h2>
          <div class="panel-body">
            <div class="console">
TP01 EXPLORER - RÉSULTAT CONSOLE
--------------------------------
Étudiant      : $STUDENT_NAME
Email         : $EMAIL
Cours         : MGGT1103
Titulaire     : Dr. Roméo NIBITANGA
Environnement : WSL Ubuntu
Mode          : lecture seule

Dossier analysé :
$TP1

Contrôle principal :
README.md        : $readme_status
Vagrantfile      : $vagrant_status
Rapport TP01     : $rapport_status
Captures         : $captures fichier(s)
Rapport          : $rapports fichier(s)
Résultats        : $resultats fichier(s)
Rendu final      : $rendu fichier(s)
Scripts          : $scripts script(s)
Score local      : $score/$total
Git branche      : $git_branch
Git commits      : $git_commits
Dernier commit   : $git_last

Git status :
$git_status
            </div>
          </div>
        </div>
      </section>

      <section id="analyse" class="section">
        <div class="panel">
          <h2>Analyse intelligente locale</h2>
          <div class="panel-body">
HTML_MID

if [ "$readme_status" = "OK" ]; then
  echo '<div class="suggestion">README.md est présent dans le rendu final.</div>' >> "$OUTPUT"
else
  echo '<div class="suggestion">README.md manque dans le rendu final.</div>' >> "$OUTPUT"
fi

if [ "$vagrant_status" = "OK" ]; then
  echo '<div class="suggestion">Vagrantfile est présent dans le rendu final.</div>' >> "$OUTPUT"
else
  echo '<div class="suggestion">Vagrantfile manque dans le rendu final.</div>' >> "$OUTPUT"
fi

if [ "$rapport_status" = "OK" ]; then
  echo '<div class="suggestion">Le rapport du TP01 est présent.</div>' >> "$OUTPUT"
else
  echo '<div class="suggestion">Le rapport du TP01 est absent.</div>' >> "$OUTPUT"
fi

if [ "$captures" -gt 0 ]; then
  echo '<div class="suggestion">Les captures sont disponibles dans le TP01.</div>' >> "$OUTPUT"
else
  echo '<div class="suggestion">Aucune capture n’est détectée dans le dossier captures.</div>' >> "$OUTPUT"
fi

if [ "$parasites" -gt 0 ]; then
  echo '<div class="suggestion">Des fichiers parasites sont détectés. Ils doivent être vérifiés avant commit.</div>' >> "$OUTPUT"
else
  echo '<div class="suggestion">Aucun fichier parasite courant n’a été détecté.</div>' >> "$OUTPUT"
fi

cat >> "$OUTPUT" <<HTML_END
          </div>
        </div>
      </section>

      <section id="apropos" class="section">
        <div class="panel">
          <h2>À propos</h2>
          <div class="panel-body">
            <table>
              <tr><td>Développeur</td><td>$STUDENT_NAME</td></tr>
              <tr><td>Email</td><td>$EMAIL</td></tr>
              <tr><td>Cours</td><td>MGGT1103 - Administration Système, Cloud-Native & DevOps</td></tr>
              <tr><td>Titulaire</td><td>Dr. Roméo NIBITANGA</td></tr>
              <tr><td>Technologies</td><td>Bash, HTML, CSS, JavaScript</td></tr>
              <tr><td>Mode</td><td>Lecture seule : présentation et vérification du TP01</td></tr>
            </table>
          </div>
        </div>
      </section>
    </main>
  </div>
</div>

<script>
  function enterApp() {
    document.getElementById("welcome").style.display = "none";
  }

  function exitApp() {
    const ok = confirm("Voulez-vous quitter TP01 Explorer ?");
    if (ok) {
      window.close();
      document.body.innerHTML = "<div style='font-family:Segoe UI;padding:40px;background:#0b0b0d;color:#ff8a00;height:100vh'><h1>TP01 Explorer fermé</h1><p>Vous pouvez fermer cet onglet.</p></div>";
    }
  }

  function showSection(id, button) {
    document.querySelectorAll(".section").forEach(function(section) {
      section.classList.remove("active");
    });

    document.querySelectorAll(".nav-btn").forEach(function(btn) {
      btn.classList.remove("active");
    });

    document.getElementById(id).classList.add("active");
    button.classList.add("active");
  }

  function filterRows() {
    const value = document.getElementById("search").value.toLowerCase();
    document.querySelectorAll(".row").forEach(function(row) {
      row.style.display = row.textContent.toLowerCase().includes(value) ? "" : "none";
    });
  }
</script>

</body>
</html>
HTML_END

echo "Interface graphique avancée générée : $OUTPUT"

if command -v explorer.exe >/dev/null 2>&1; then
  explorer.exe "$(wslpath -w "$OUTPUT")" >/dev/null 2>&1
  echo "Ouverture dans le navigateur Windows..."
else
  echo "Ouvre ce fichier : $OUTPUT"
fi
