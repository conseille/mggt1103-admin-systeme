#!/usr/bin/env bash

# ============================================================
# MGGT1103 - PresentBoard v1.2
# Développeur : MUPINI KABWE ALBERT
# Email : albertmupini21@gmail.com
# Cours : MGGT1103 - Administration Système, Cloud-Native & DevOps
# Titulaire : Dr. Roméo NIBITANGA
# Environnement : WSL Ubuntu
# Technologies : Bash, HTML, CSS, JavaScript
#
# Mode de fonctionnement :
# Lecture seule. Le script lit la structure réelle du dépôt,
# les fichiers, les droits Linux et les informations Git.
# Il génère une page HTML locale et l’ouvre dans le navigateur.
# Aucune modification n’est faite sur le projet.
# ============================================================

set -u

VERSION="PresentBoard v1.2"
PROJECT_NAME="Bureau-MUPINI-KABWE-ALBERT-MGGT1103"

if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(pwd)"
fi

BUREAU="$REPO_ROOT/$PROJECT_NAME"
TP_BASE="$BUREAU/02-travaux-pratiques"
LAB="$BUREAU/03-laboratoire-automatisation"
OUTPUT="$REPO_ROOT/presentboard-mggt1103.html"

STUDENT_NAME="MUPINI KABWE ALBERT"
STUDENT_EMAIL="$(git config --global user.email 2>/dev/null || echo "albertmupini21@gmail.com")"
GIT_NAME="$(git config --global user.name 2>/dev/null || echo "MUPINI KABWE ALBERT")"
COURSE="MGGT1103 — Administration Système, Cloud-Native & DevOps"
TEACHER="Dr. Roméo NIBITANGA"
ENVIRONMENT="WSL Ubuntu"
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

count_real_tp() {
  local total=0
  if [ -d "$TP_BASE" ]; then
    while read -r tp; do
      files="$(find "$tp" -type f ! -name ".gitkeep" | wc -l)"
      if [ "$files" -gt 0 ]; then
        total=$((total + 1))
      fi
    done < <(find "$TP_BASE" -maxdepth 1 -type d -name "TP*" | sort)
  fi
  echo "$total"
}

file_url() {
  local path="$1"
  local rel
  rel="$(realpath --relative-to="$REPO_ROOT" "$path" 2>/dev/null)"
  printf '%s' "$rel" | sed 's/ /%20/g'
}

human_size() {
  local path="$1"
  if [ -f "$path" ]; then
    du -h "$path" | awk '{print $1}'
  else
    echo "-"
  fi
}

file_date() {
  local path="$1"
  if [ -e "$path" ]; then
    stat -c '%y' "$path" | cut -d'.' -f1
  else
    echo "-"
  fi
}

file_perm() {
  local path="$1"
  if [ -e "$path" ]; then
    stat -c '%A' "$path"
  else
    echo "-"
  fi
}

file_type_label() {
  local name="$1"
  local ext="${name##*.}"

  case "$ext" in
    png|jpg|jpeg|webp) echo "Capture" ;;
    md) echo "Markdown" ;;
    docx) echo "Rapport Word" ;;
    pdf) echo "PDF" ;;
    sh) echo "Script Bash" ;;
    txt|log) echo "Résultat" ;;
    html) echo "Page HTML" ;;
    *) echo "Fichier" ;;
  esac
}

git_branch="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || echo "non détectée")"
git_changes="$(git -C "$REPO_ROOT" status --short 2>/dev/null | wc -l)"
git_commits="$(git -C "$REPO_ROOT" rev-list --count HEAD 2>/dev/null || echo "0")"
git_last_commit="$(git -C "$REPO_ROOT" log -1 --oneline 2>/dev/null | escape_html || echo "aucun commit")"
git_remote="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || echo "aucun remote configuré")"
git_status_sb="$(git -C "$REPO_ROOT" status -sb 2>/dev/null | escape_html || echo "Git non disponible")"
git_modified="$(git -C "$REPO_ROOT" status --short 2>/dev/null | grep -E '^[ MARCUD]' | wc -l || echo "0")"
git_untracked="$(git -C "$REPO_ROOT" status --short 2>/dev/null | grep -E '^\?\?' | wc -l || echo "0")"

tp_detected=0
if [ -d "$TP_BASE" ]; then
  tp_detected="$(find "$TP_BASE" -maxdepth 1 -type d -name "TP*" | wc -l)"
fi

tp_with_content="$(count_real_tp)"
lab_scripts="$(count_scripts "$LAB")"
tp_scripts="$(count_scripts "$TP_BASE")"

clear
echo "============================================================"
echo " MGGT1103 - PresentBoard v1.2"
echo "============================================================"
echo " Développeur : $STUDENT_NAME"
echo " Email       : $STUDENT_EMAIL"
echo " Cours       : $COURSE"
echo " Titulaire   : $TEACHER"
echo " Environnement : $ENVIRONMENT"
echo
echo " Mode : lecture seule"
echo " Action : génération d’une interface HTML locale"
echo "============================================================"
echo

cat > "$OUTPUT" <<HTML_HEAD
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>MGGT1103 - PresentBoard</title>
  <style>
    :root {
      --bg: #ffffff;
      --soft: #f6f8fa;
      --text: #24292f;
      --muted: #57606a;
      --border: #d0d7de;
      --blue: #0969da;
      --blue-soft: #ddf4ff;
      --blue-border: #54aeef;
      --green: #1a7f37;
      --orange: #9a6700;
      --red: #cf222e;
      --shadow: rgba(27, 31, 36, 0.08);
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
    }

    header {
      background: var(--soft);
      border-bottom: 1px solid var(--border);
      padding: 24px 34px;
    }

    header h1 {
      margin: 0;
      font-size: 30px;
      color: var(--text);
    }

    header p {
      margin: 8px 0 0;
      color: var(--muted);
      font-size: 15px;
    }

    .layout {
      display: grid;
      grid-template-columns: 270px 1fr;
      min-height: calc(100vh - 95px);
    }

    aside {
      border-right: 1px solid var(--border);
      background: #ffffff;
      padding: 18px;
    }

    aside .menu-title {
      font-size: 13px;
      color: var(--muted);
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: .05em;
      margin: 10px 0 14px;
    }

    aside button {
      width: 100%;
      text-align: left;
      padding: 10px 12px;
      margin-bottom: 8px;
      border: 1px solid transparent;
      background: transparent;
      color: var(--text);
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
    }

    aside button:hover,
    aside button.active {
      background: var(--blue-soft);
      color: #0550ae;
      border-color: #b6e3ff;
    }

    main {
      padding: 26px 34px;
    }

    section {
      display: none;
    }

    section.active {
      display: block;
    }

    .cards {
      display: grid;
      grid-template-columns: repeat(4, minmax(160px, 1fr));
      gap: 14px;
      margin-bottom: 20px;
    }

    .card {
      border: 1px solid var(--border);
      border-radius: 10px;
      background: #fff;
      padding: 16px;
      box-shadow: 0 8px 18px var(--shadow);
    }

    .card .label {
      color: var(--muted);
      font-size: 13px;
      margin-bottom: 8px;
    }

    .card .value {
      font-size: 26px;
      font-weight: 700;
      color: var(--text);
    }

    .panel {
      border: 1px solid var(--border);
      border-radius: 10px;
      background: #fff;
      overflow: hidden;
      margin-bottom: 20px;
      box-shadow: 0 8px 18px var(--shadow);
    }

    .panel h2 {
      margin: 0;
      padding: 14px 18px;
      background: var(--soft);
      border-bottom: 1px solid var(--border);
      font-size: 19px;
    }

    .panel-body {
      padding: 18px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    th {
      text-align: left;
      background: var(--soft);
      padding: 10px;
      border-bottom: 1px solid var(--border);
      font-size: 14px;
    }

    td {
      padding: 10px;
      border-bottom: 1px solid var(--border);
      vertical-align: top;
      font-size: 14px;
    }

    .path, code, pre {
      font-family: Consolas, "Liberation Mono", monospace;
      font-size: 13px;
    }

    .path {
      color: var(--muted);
    }

    .badge {
      display: inline-block;
      padding: 4px 8px;
      border-radius: 999px;
      font-size: 12px;
      font-weight: 700;
      background: var(--blue-soft);
      color: #0550ae;
      border: 1px solid #b6e3ff;
    }

    .badge-green {
      background: #dafbe1;
      color: var(--green);
      border-color: #aceebb;
    }

    .badge-orange {
      background: #fff8c5;
      color: var(--orange);
      border-color: #eac54f;
    }

    .treebox {
      background: var(--soft);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 14px;
      white-space: pre-wrap;
      overflow-x: auto;
      line-height: 1.5;
      font-family: Consolas, "Liberation Mono", monospace;
      font-size: 13px;
    }

    .search {
      width: 100%;
      padding: 11px 12px;
      border: 1px solid var(--border);
      border-radius: 8px;
      font-size: 15px;
      margin-bottom: 16px;
    }

    .tp-selector {
      display: flex;
      gap: 10px;
      align-items: center;
      margin-bottom: 18px;
      flex-wrap: wrap;
    }

    select {
      min-width: 360px;
      padding: 10px;
      border: 1px solid var(--border);
      border-radius: 8px;
      background: white;
      font-weight: 600;
      color: var(--text);
    }

    .tp-panel {
      display: none;
    }

    .tp-panel.active {
      display: block;
    }

    .folder-grid {
      display: grid;
      grid-template-columns: repeat(5, minmax(120px, 1fr));
      gap: 10px;
      margin: 14px 0;
    }

    .folder-card {
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 12px;
      background: #fff;
    }

    .folder-card strong {
      display: block;
      margin-bottom: 5px;
    }

    a {
      color: var(--blue);
      text-decoration: none;
      font-weight: 600;
    }

    a:hover {
      text-decoration: underline;
    }

    .note {
      background: var(--soft);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 14px;
      color: var(--muted);
      line-height: 1.5;
    }

    .suggestion {
      border-left: 4px solid var(--blue);
      padding: 10px 12px;
      background: var(--soft);
      margin-bottom: 10px;
      border-radius: 6px;
    }

    @media print {
      aside { display: none; }
      .layout { display: block; }
      section { display: block; page-break-after: always; }
      .tp-panel { display: block; }
      .cards { grid-template-columns: repeat(2, 1fr); }
    }
  </style>
</head>
<body>

<header>
  <h1>MGGT1103 — PresentBoard</h1>
  <p>Vue locale du projet, générée depuis WSL Ubuntu par $STUDENT_NAME</p>
</header>

<div class="layout">
  <aside>
    <div class="menu-title">Menu principal</div>
    <button class="active" onclick="showSection('accueil', this)">1. Accueil</button>
    <button onclick="showSection('bureau', this)">2. Bureau</button>
    <button onclick="showSection('travaux', this)">3. Travaux pratiques</button>
    <button onclick="showSection('laboratoire', this)">4. Laboratoire</button>
    <button onclick="showSection('git', this)">5. Git</button>
    <button onclick="showSection('maj', this)">6. Mises à jour</button>
    <button onclick="showSection('avis', this)">7. Avis et suggestions</button>
    <button onclick="showSection('apropos', this)">8. À propos</button>
  </aside>

  <main>
    <section id="accueil" class="active">
      <div class="cards">
        <div class="card">
          <div class="label">TP détectés dans le dépôt</div>
          <div class="value">$tp_detected</div>
        </div>
        <div class="card">
          <div class="label">TP contenant des fichiers réels</div>
          <div class="value">$tp_with_content</div>
        </div>
        <div class="card">
          <div class="label">Scripts du laboratoire</div>
          <div class="value">$lab_scripts</div>
        </div>
        <div class="card">
          <div class="label">Changements Git en attente</div>
          <div class="value">$git_changes</div>
        </div>
      </div>

      <div class="panel">
        <h2>Informations utiles</h2>
        <div class="panel-body">
          <table>
            <tr><td>Étudiant</td><td><strong>$STUDENT_NAME</strong></td></tr>
            <tr><td>Email Git</td><td><strong>$STUDENT_EMAIL</strong></td></tr>
            <tr><td>Cours</td><td>$COURSE</td></tr>
            <tr><td>Titulaire du cours</td><td><strong>$TEACHER</strong></td></tr>
            <tr><td>Environnement</td><td>$ENVIRONMENT</td></tr>
            <tr><td>Racine Git</td><td><span class="path">$REPO_ROOT</span></td></tr>
            <tr><td>Date de génération</td><td>$GEN_DATE</td></tr>
          </table>
        </div>
      </div>
    </section>

    <section id="bureau">
      <div class="panel">
        <h2>Organisation du Bureau MGGT1103</h2>
        <div class="panel-body">
          <p class="note">
            Cette page présente l'organisation générale du projet. Elle sert à montrer la logique de classement du Bureau MGGT1103.
          </p>
          <div class="treebox">
HTML_HEAD

if [ -d "$BUREAU" ]; then
  tree "$BUREAU" -L 2 | escape_html >> "$OUTPUT"
else
  echo "Bureau introuvable." >> "$OUTPUT"
fi

cat >> "$OUTPUT" <<HTML_MID
          </div>
        </div>
      </div>
    </section>

    <section id="travaux">
      <div class="panel">
        <h2>Travaux pratiques</h2>
        <div class="panel-body">
          <div class="tp-selector">
            <label for="tpSelect"><strong>Sélectionner un TP :</strong></label>
            <select id="tpSelect" onchange="showTPFromSelect()">
HTML_MID

if [ -d "$TP_BASE" ]; then
  first_tp="yes"
  find "$TP_BASE" -maxdepth 1 -type d -name "TP*" | sort | while read -r tp; do
    tp_name="$(basename "$tp")"
    tp_id="$(basename "$tp" | tr -cd '[:alnum:]')"
    selected=""
    if [ "$first_tp" = "yes" ]; then
      selected="selected"
      first_tp="no"
    fi
    printf '<option value="%s" %s>%s</option>\n' "$tp_id" "$selected" "$(printf '%s' "$tp_name" | escape_html)" >> "$OUTPUT"
  done
fi

cat >> "$OUTPUT" <<HTML_TP_START
            </select>
          </div>
HTML_TP_START

if [ -d "$TP_BASE" ]; then
  first_tp="yes"
  find "$TP_BASE" -maxdepth 1 -type d -name "TP*" | sort | while read -r tp; do
    tp_raw="$(basename "$tp")"
    tp_name="$(printf '%s' "$tp_raw" | escape_html)"
    tp_id="$(basename "$tp" | tr -cd '[:alnum:]')"

    active=""
    if [ "$first_tp" = "yes" ]; then
      active="active"
      first_tp="no"
    fi

    captures="$(count_files "$tp/captures")"
    rapports="$(count_files "$tp/rapport")"
    resultats="$(count_files "$tp/resultats")"
    rendu="$(count_files "$tp/rendu-final")"
    scripts="$(count_scripts "$tp/scripts")"

    cat >> "$OUTPUT" <<HTML_TP_PANEL
          <div class="tp-panel $active" id="$tp_id">
            <h3>$tp_name</h3>
            <p class="path">$(realpath --relative-to="$REPO_ROOT" "$tp" | escape_html)</p>

            <div class="folder-grid">
              <div class="folder-card"><strong>captures</strong><span>$captures fichier(s)</span></div>
              <div class="folder-card"><strong>rapport</strong><span>$rapports fichier(s)</span></div>
              <div class="folder-card"><strong>resultats</strong><span>$resultats fichier(s)</span></div>
              <div class="folder-card"><strong>rendu-final</strong><span>$rendu fichier(s)</span></div>
              <div class="folder-card"><strong>scripts</strong><span>$scripts script(s)</span></div>
            </div>

            <h4>Structure du TP</h4>
            <div class="treebox">
HTML_TP_PANEL

    tree "$tp" -L 2 | escape_html >> "$OUTPUT"

    cat >> "$OUTPUT" <<HTML_TP_FILES
            </div>

            <h4>Fichiers du TP</h4>
            <input class="search" onkeyup="filterInsideTable(this)" placeholder="Rechercher dans les fichiers de ce TP...">

            <table>
              <tr>
                <th>Type</th>
                <th>Nom</th>
                <th>Droits</th>
                <th>Taille</th>
                <th>Modification</th>
                <th>Chemin</th>
                <th>Action</th>
              </tr>
HTML_TP_FILES

    find "$tp" -type f ! -name ".gitkeep" | sort | while read -r f; do
      file_name_raw="$(basename "$f")"
      file_name="$(printf '%s' "$file_name_raw" | escape_html)"
      type="$(file_type_label "$file_name_raw")"
      perm="$(file_perm "$f")"
      size="$(human_size "$f")"
      mod_date="$(file_date "$f")"
      rel_path="$(realpath --relative-to="$REPO_ROOT" "$f")"
      rel_html="$(printf '%s' "$rel_path" | escape_html)"
      href="$(file_url "$f")"

      cat >> "$OUTPUT" <<HTML_FILE
              <tr class="filter-row">
                <td><span class="badge">$type</span></td>
                <td>$file_name</td>
                <td><code>$perm</code></td>
                <td>$size</td>
                <td>$mod_date</td>
                <td class="path">$rel_html</td>
                <td><a href="$href" target="_blank">Ouvrir</a></td>
              </tr>
HTML_FILE
    done

    cat >> "$OUTPUT" <<HTML_TP_END
            </table>
          </div>
HTML_TP_END
  done
fi

cat >> "$OUTPUT" <<HTML_LAB
        </div>
      </div>
    </section>

    <section id="laboratoire">
      <div class="panel">
        <h2>Laboratoire d'automatisation</h2>
        <div class="panel-body">
          <p class="note">
            Le laboratoire garde les éléments innovants et les propositions. Les scripts spécifiques à un TP restent dans le dossier du TP concerné.
          </p>

          <h3>Structure du laboratoire</h3>
          <div class="treebox">
HTML_LAB

if [ -d "$LAB" ]; then
  tree "$LAB" -L 3 | escape_html >> "$OUTPUT"
fi

cat >> "$OUTPUT" <<HTML_LAB_TABLE
          </div>

          <h3>Fichiers du laboratoire</h3>
          <table>
            <tr>
              <th>Type</th>
              <th>Nom</th>
              <th>Droits</th>
              <th>Taille</th>
              <th>Chemin</th>
              <th>Action</th>
            </tr>
HTML_LAB_TABLE

if [ -d "$LAB" ]; then
  find "$LAB" -type f ! -name ".gitkeep" | sort | while read -r f; do
    file_name_raw="$(basename "$f")"
    file_name="$(printf '%s' "$file_name_raw" | escape_html)"
    type="$(file_type_label "$file_name_raw")"
    perm="$(file_perm "$f")"
    size="$(human_size "$f")"
    rel_path="$(realpath --relative-to="$REPO_ROOT" "$f")"
    rel_html="$(printf '%s' "$rel_path" | escape_html)"
    href="$(file_url "$f")"

    cat >> "$OUTPUT" <<HTML_LAB_FILE
            <tr>
              <td><span class="badge">$type</span></td>
              <td>$file_name</td>
              <td><code>$perm</code></td>
              <td>$size</td>
              <td class="path">$rel_html</td>
              <td><a href="$href" target="_blank">Ouvrir</a></td>
            </tr>
HTML_LAB_FILE
  done
fi

cat >> "$OUTPUT" <<HTML_GIT
          </table>
        </div>
      </div>
    </section>

    <section id="git">
      <div class="panel">
        <h2>Informations Git</h2>
        <div class="panel-body">
          <div class="cards">
            <div class="card"><div class="label">Branche</div><div class="value">$git_branch</div></div>
            <div class="card"><div class="label">Commits</div><div class="value">$git_commits</div></div>
            <div class="card"><div class="label">Fichiers modifiés</div><div class="value">$git_modified</div></div>
            <div class="card"><div class="label">Fichiers non suivis</div><div class="value">$git_untracked</div></div>
          </div>

          <table>
            <tr><td>Nom Git</td><td><strong>$GIT_NAME</strong></td></tr>
            <tr><td>Email Git</td><td><strong>$STUDENT_EMAIL</strong></td></tr>
            <tr><td>Remote GitHub</td><td><span class="path">$git_remote</span></td></tr>
            <tr><td>Dernier commit</td><td><span class="path">$git_last_commit</span></td></tr>
          </table>

          <h3>Résultat de git status -sb</h3>
          <div class="treebox">$git_status_sb</div>
        </div>
      </div>
    </section>

    <section id="maj">
      <div class="panel">
        <h2>Mises à jour</h2>
        <div class="panel-body">
          <table>
            <tr><td>Version</td><td><strong>$VERSION</strong></td></tr>
            <tr><td>Date de génération</td><td>$GEN_DATE</td></tr>
            <tr><td>Objectif de cette version</td><td>Aligner l’interface avec la structure réelle du Bureau, afficher les TP par sélection, intégrer les droits Linux et améliorer la partie Git.</td></tr>
            <tr><td>Évolution continue</td><td>Le script peut évoluer selon les nouveaux TP et les besoins du cours MGGT1103.</td></tr>
          </table>
        </div>
      </div>
    </section>

    <section id="avis">
      <div class="panel">
        <h2>Avis et suggestions</h2>
        <div class="panel-body">
HTML_GIT

# Analyse intelligente locale simple
if [ "$git_changes" -gt 0 ]; then
  echo '<div class="suggestion">Git contient des changements en attente. Vérifier avant commit et push.</div>' >> "$OUTPUT"
fi

if [ "$tp_with_content" -lt "$tp_detected" ]; then
  echo '<div class="suggestion">Certains TP sont déjà structurés mais attendent encore les fichiers du guide ou du rendu.</div>' >> "$OUTPUT"
fi

if [ "$lab_scripts" -eq 0 ]; then
  echo '<div class="suggestion">Le laboratoire ne contient aucun script. Ajouter au moins PresentBoard comme outil de présentation.</div>' >> "$OUTPUT"
else
  echo '<div class="suggestion">Le laboratoire contient un outil de présentation central. Les scripts spécifiques restent dans leurs TP.</div>' >> "$OUTPUT"
fi

cat >> "$OUTPUT" <<HTML_END
        </div>
      </div>
    </section>

    <section id="apropos">
      <div class="panel">
        <h2>À propos</h2>
        <div class="panel-body">
          <table>
            <tr><td>Développeur</td><td><strong>$STUDENT_NAME</strong></td></tr>
            <tr><td>Email</td><td><strong>$STUDENT_EMAIL</strong></td></tr>
            <tr><td>Cours</td><td>$COURSE</td></tr>
            <tr><td>Titulaire</td><td>$TEACHER</td></tr>
            <tr><td>Technologies</td><td>Bash, HTML, CSS, JavaScript</td></tr>
            <tr><td>Mode de fonctionnement</td><td>Lecture seule : analyse et présentation du dépôt local, sans modification des fichiers.</td></tr>
            <tr><td>Commande d’exécution</td><td><code>./presentboard</code></td></tr>
          </table>
        </div>
      </div>
    </section>
  </main>
</div>

<script>
  function showSection(id, button) {
    document.querySelectorAll("section").forEach(function(section) {
      section.classList.remove("active");
    });

    document.querySelectorAll("aside button").forEach(function(btn) {
      btn.classList.remove("active");
    });

    document.getElementById(id).classList.add("active");
    button.classList.add("active");
  }

  function showTPFromSelect() {
    var select = document.getElementById("tpSelect");
    var id = select.value;

    document.querySelectorAll(".tp-panel").forEach(function(panel) {
      panel.classList.remove("active");
    });

    var target = document.getElementById(id);
    if (target) {
      target.classList.add("active");
    }
  }

  function filterInsideTable(input) {
    var filter = input.value.toLowerCase();
    var table = input.nextElementSibling;
    var rows = table.querySelectorAll(".filter-row");

    rows.forEach(function(row) {
      var text = row.textContent.toLowerCase();
      row.style.display = text.includes(filter) ? "" : "none";
    });
  }
</script>

</body>
</html>
HTML_END

echo "PresentBoard généré : $OUTPUT"

if command -v explorer.exe >/dev/null 2>&1; then
  explorer.exe "$(wslpath -w "$OUTPUT")" >/dev/null 2>&1
  echo "Ouverture dans le navigateur Windows..."
else
  echo "Ouvre ce fichier manuellement : $OUTPUT"
fi
