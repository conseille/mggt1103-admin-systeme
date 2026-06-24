function goBack() {
    try {
        if (document.referrer && new URL(document.referrer).origin === window.location.origin) {
            window.history.back();
        } else {
            window.location.href = "?p=accueil";
        }
    } catch (e) {
        window.location.href = "?p=accueil";
    }
}

function exitApp() {
    const ok = confirm(
        "Voulez-vous quitter l’interface PresentBoard ?\n\n" +
        "Le serveur local peut rester actif dans WSL.\n" +
        "Vous pourrez relancer l’application avec : presentboard"
    );

    if (ok) {
        window.location.href = "about:blank";
    }
}

function confirmExecution(scriptName) {
    return confirm(
        "Attention : exécution contrôlée dans WSL.\n\n" +
        "Script : " + scriptName + "\n\n" +
        "Ce script peut lire le projet, afficher l’état Git et générer un journal.\n\n" +
        "Voulez-vous vraiment exécuter ce script ?"
    );
}

/* Page Travaux pratiques : sélection compacte */

const tpSearch = document.getElementById("tpSearch");
const tpSelect = document.getElementById("tpSelect");
const tpPreview = document.getElementById("tpPreview");
const openSelectedTp = document.getElementById("openSelectedTp");

function renderTpPreview() {
    if (!tpSelect || !tpPreview) return;

    const opt = tpSelect.options[tpSelect.selectedIndex];

    if (!opt || !opt.value) {
        tpPreview.innerHTML = `
            <div class="empty-state">
                Aucun TP sélectionné. Choisissez un travail pratique dans le menu.
            </div>
        `;
        return;
    }

    const title = opt.dataset.title || opt.textContent;
    const status = opt.dataset.status || "À vérifier";
    const statusClass = opt.dataset.statusClass || "neutral";
    const path = opt.dataset.path || "";
    const content = opt.dataset.content || "Aucun contenu réel détecté";

    tpPreview.innerHTML = `
        <div class="tp-preview-head">
            <div>
                <p class="small-title">Travail pratique sélectionné</p>
                <h3>${title}</h3>
            </div>
            <span class="badge ${statusClass}">${status}</span>
        </div>

        <div class="tp-preview-grid">
            <div class="info-box">
                <small>Chemin réel</small>
                <strong>${path}</strong>
            </div>

            <div class="info-box">
                <small>Contenu disponible</small>
                <strong>${content}</strong>
            </div>
        </div>

        <p class="tp-preview-note">
            Cliquez sur “Ouvrir le TP sélectionné” pour accéder au détail du TP et voir ses sections classées.
        </p>
    `;
}

if (tpSelect) {
    tpSelect.addEventListener("change", renderTpPreview);
}

if (openSelectedTp) {
    openSelectedTp.addEventListener("click", function () {
        if (!tpSelect || !tpSelect.value) {
            alert("Sélectionnez d’abord un TP.");
            return;
        }

        window.location.href = tpSelect.value;
    });
}

if (tpSearch && tpSelect) {
    tpSearch.addEventListener("input", function () {
        const q = this.value.toLowerCase().trim();

        Array.from(tpSelect.options).forEach((opt, index) => {
            if (index === 0) return;

            const text = (opt.dataset.search || opt.textContent || "").toLowerCase();
            opt.hidden = !text.includes(q);
        });

        if (tpSelect.selectedIndex > 0 && tpSelect.options[tpSelect.selectedIndex].hidden) {
            tpSelect.selectedIndex = 0;
            renderTpPreview();
        }
    });
}

/* Recherche simple dans l’explorateur */

document.querySelectorAll(".search").forEach(input => {
    if (input.id === "tpSearch") return;

    input.addEventListener("input", function () {
        const table = document.querySelector(".files-table");
        if (!table) return;

        const q = this.value.toLowerCase().trim();

        table.querySelectorAll("tr").forEach((row, index) => {
            if (index === 0) return;
            row.style.display = row.textContent.toLowerCase().includes(q) ? "" : "none";
        });
    });
});
