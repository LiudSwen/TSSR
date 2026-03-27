```dataviewjs
// ========================================
// TEMPLATE SOMMAIRE - REFONTE MODERNE
// ========================================
// Placez ce code dans n'importe quel fichier Sommaire.md
// Il scannera automatiquement tous les dossiers PARTIE du dossier parent

// Désactiver le re-render automatique
dv.container.dataset.dvNoRerender = "true";

// CONFIGURATION
const currentFile = dv.current().file;
const parentFolder = currentFile.folder;
const STORAGE_KEY = `sommaire-state-${parentFolder}`;

// Fonction pour sauvegarder l'état des sections
function saveState() {
  const state = {
    parties: {},
    subfolders: {},
    files: {}
  };
  
  document.querySelectorAll('.partie-card-modern').forEach((el, idx) => {
    state.parties[idx] = el.hasAttribute('open');
  });
  
  document.querySelectorAll('.subfolder-card-modern').forEach((el, idx) => {
    const id = el.getAttribute('data-id');
    if (id) state.subfolders[id] = el.hasAttribute('open');
  });
  
  document.querySelectorAll('.file-detail-modern').forEach((el, idx) => {
    const id = el.getAttribute('data-id');
    if (id) state.files[id] = el.hasAttribute('open');
  });
  
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

// Fonction pour restaurer l'état des sections
function restoreState() {
  const savedState = localStorage.getItem(STORAGE_KEY);
  if (!savedState) return;
  
  try {
    const state = JSON.parse(savedState);
    
    document.querySelectorAll('.partie-card-modern').forEach((el, idx) => {
      if (state.parties[idx]) el.setAttribute('open', '');
    });
    
    document.querySelectorAll('.subfolder-card-modern').forEach((el) => {
      const id = el.getAttribute('data-id');
      if (id && state.subfolders[id]) el.setAttribute('open', '');
    });
    
    document.querySelectorAll('.file-detail-modern').forEach((el) => {
      const id = el.getAttribute('data-id');
      if (id && state.files[id]) el.setAttribute('open', '');
    });
  } catch (e) {
    console.error('Erreur lors de la restauration:', e);
  }
}

// Récupération automatique de tous les dossiers "PARTIE X"
let allFiles = dv.pages().file.where(f => f.folder === parentFolder || f.folder.startsWith(parentFolder + "/"));
let folderSet = new Set();

for (let file of allFiles) {
  let folder = file.folder;
  
  if (folder.startsWith(parentFolder + "/")) {
    let relativePath = folder.substring(parentFolder.length + 1);
    let firstFolder = relativePath.split("/")[0];
    
    if (firstFolder.match(/^PARTIE \d+/)) {
      let fullPartFolder = parentFolder + "/" + firstFolder;
      folderSet.add(fullPartFolder);
    }
  }
}

// Tri des dossiers par numéro de partie
let folders = Array.from(folderSet).sort((a, b) => {
  let numA = parseInt(a.match(/PARTIE (\d+)/)?.[1] || "0");
  let numB = parseInt(b.match(/PARTIE (\d+)/)?.[1] || "0");
  return numA - numB;
});

if (folders.length === 0) {
  dv.paragraph("⚠️ Aucun dossier PARTIE trouvé dans ce répertoire.");
  dv.paragraph(`Dossier actuel : \`${parentFolder}\``);
} else {
  let partIndex = 1;
  
  for (let folder of folders) {
    let folderName = folder.split("/").pop();
    let displayTitle = folderName.replace(/^PARTIE \d+\s*-\s*/, "");
    
    // Compter le nombre de fichiers dans cette partie
    let files = dv.pages(`"${folder}"`).where(f => f.file.name !== "Sommaire");
    let fileCount = files.length;
    
    // Construction du HTML de la CARD pour la PARTIE (fermée par défaut)
    let partHTML = `
<details class="partie-card-modern" style="background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); border-radius: 12px; padding: 0; margin: 14px 0; box-shadow: 0 6px 24px rgba(0, 0, 0, 0.4), 0 0 0 1px rgba(139, 92, 246, 0.1); border: none; transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); overflow: hidden; position: relative;">
  <div style="position: absolute; top: 0; left: 0; right: 0; height: 2px; background: linear-gradient(90deg, #ec4899, #8b5cf6, #06b6d4); opacity: 0; transition: opacity 0.3s;"></div>
  <summary style="cursor: pointer; list-style: none; user-select: none; padding: 16px 20px;">
    <div style="display: flex; align-items: center; gap: 12px;">
      <span class="arrow-modern" style="display: inline-flex; align-items: center; justify-content: center; width: 22px; height: 22px; border-radius: 6px; background: rgba(139, 92, 246, 0.15); color: #c084fc; font-size: 0.8em; transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);">▸</span>
      <div style="background: linear-gradient(135deg, #ec4899 0%, #8b5cf6 50%, #06b6d4 100%); color: white; min-width: 38px; height: 38px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.1em; font-weight: 700; box-shadow: 0 4px 16px rgba(236, 72, 153, 0.35), 0 2px 8px rgba(139, 92, 246, 0.25); flex-shrink: 0; position: relative; overflow: hidden;">
        <div style="position: absolute; inset: 0; background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%); animation: shimmer 3s infinite;"></div>
        <span style="position: relative; z-index: 1;">${partIndex}</span>
      </div>
      <div style="flex-grow: 1;">
        <h3 style="margin: 0; color: #f3f4f6; font-size: 1.1em; font-weight: 700; letter-spacing: -0.02em;">${displayTitle}</h3>
        <div style="display: flex; align-items: center; gap: 8px; margin-top: 3px;">
          <span style="display: inline-flex; align-items: center; gap: 4px; font-size: 0.72em; color: #9ca3af; font-weight: 500;">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path><polyline points="13 2 13 9 20 9"></polyline></svg>
            ${fileCount} fichier${fileCount > 1 ? 's' : ''}
          </span>
        </div>
      </div>
    </div>
  </summary>
  <div class="partie-content-modern" style="padding: 0 20px 16px 20px; border-top: 1px solid rgba(139, 92, 246, 0.15); margin-top: 0;">`;
    
    // Récupérer tous les fichiers dans ce dossier PARTIE (y compris sous-dossiers)
    let filesBySubfolder = {};
    
    for (let file of files) {
      let filePath = file.file.path;
      let relativePath = filePath.substring(folder.length + 1);
      let parts = relativePath.split("/");
      
      if (parts.length === 1) {
        if (!filesBySubfolder["_root"]) filesBySubfolder["_root"] = [];
        filesBySubfolder["_root"].push(file);
      } else {
        let subfolder = parts[0];
        if (!filesBySubfolder[subfolder]) filesBySubfolder[subfolder] = [];
        filesBySubfolder[subfolder].push(file);
      }
    }
    
    // Trier les sous-dossiers par numéro
    let sortedSubfolders = Object.entries(filesBySubfolder).sort((a, b) => {
      if (a[0] === "_root") return -1;
      if (b[0] === "_root") return 1;
      let numA = parseInt(a[0].match(/^(\d+)/)?.[1] || "999");
      let numB = parseInt(b[0].match(/^(\d+)/)?.[1] || "999");
      return numA - numB;
    });
    
    // Afficher les fichiers groupés
    for (let [subfolder, subfiles] of sortedSubfolders) {
      if (subfolder === "_root") {
        // Fichiers à la racine de PARTIE X
        for (let file of subfiles) {
          let displayName = file.file.name;
          let content = await dv.io.load(file.file.path);
          let headers = content.match(/^## (.+)$/gm) || [];
          let fileId = `file-${file.file.path.replace(/[^a-zA-Z0-9]/g, '-')}`;
          
          if (headers.length === 0) {
            partHTML += `
<div style="background: rgba(30, 30, 46, 0.6); backdrop-filter: blur(10px); border-left: 2px solid #ec4899; padding: 10px 14px; margin: 6px 0; border-radius: 8px; transition: all 0.3s; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2); display: flex; align-items: center; gap: 8px;">
  <a data-href="${file.file.path}" href="${file.file.path}" class="internal-link file-open-btn" style="display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; border-radius: 5px; background: rgba(139, 92, 246, 0.2); color: #c084fc; text-decoration: none; flex-shrink: 0; transition: all 0.2s;">
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
  </a>
  <span style="font-weight: 600; color: #e5e7eb; font-size: 0.88em; flex-grow: 1;">${file.file.link}</span>
</div>`;
          } else {
            let headersList = headers.map(h => {
              let title = h.replace("## ", "").trim();
              return `<li style="margin: 6px 0; list-style: none;"><span style="color: #a78bfa; margin-right: 8px; font-size: 0.9em;">◆</span><a data-href="${file.file.name}#${title}" href="${file.file.name}#${title}" class="internal-link is-unresolved modern-link" style="color: #d1d5db; text-decoration: none; transition: all 0.2s; font-size: 0.85em; font-weight: 500;">${title}</a></li>`;
            }).join("");
            
            partHTML += `
<div style="background: rgba(30, 30, 46, 0.6); backdrop-filter: blur(10px); border-left: 2px solid #ec4899; padding: 10px 14px; margin: 6px 0; border-radius: 8px; transition: all 0.3s; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);">
  <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
    <a data-href="${file.file.path}" href="${file.file.path}" class="internal-link file-open-btn" style="display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; border-radius: 5px; background: rgba(139, 92, 246, 0.2); color: #c084fc; text-decoration: none; flex-shrink: 0; transition: all 0.2s;">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
    </a>
    <details class="file-detail-modern" data-id="${fileId}" style="flex-grow: 1; background: transparent; border: none; padding: 0; margin: 0; box-shadow: none;">
      <summary style="cursor: pointer; font-weight: 600; color: #e5e7eb; list-style: none; user-select: none; font-size: 0.88em; display: flex; align-items: center; gap: 6px;">
        <span class="arrow-small" style="color: #a78bfa; font-size: 0.75em; transition: transform 0.2s;">▸</span>
        ${displayName}
      </summary>
      <ul style="margin: 10px 0 0 0; padding: 0 0 0 22px;">
        ${headersList}
      </ul>
    </details>
  </div>
</div>`;
          }
        }
      } else {
        // Sous-dossier
        let subfileCount = subfiles.length;
        let subfolderId = `subfolder-${folder}-${subfolder}`.replace(/[^a-zA-Z0-9]/g, '-');
        
        partHTML += `
<details open class="subfolder-card-modern" data-id="${subfolderId}" style="background: rgba(30, 30, 46, 0.4); backdrop-filter: blur(8px); border: 1px solid rgba(139, 92, 246, 0.2); border-radius: 10px; padding: 12px; margin: 10px 0; box-shadow: 0 3px 12px rgba(0, 0, 0, 0.2); transition: all 0.3s;">
  <summary style="cursor: pointer; list-style: none; user-select: none;">
    <div style="display: flex; align-items: center; gap: 10px;">
      <span class="arrow-small" style="display: inline-flex; align-items: center; justify-content: center; width: 20px; height: 20px; border-radius: 5px; background: rgba(139, 92, 246, 0.2); color: #c084fc; font-size: 0.75em; transition: all 0.3s;">▸</span>
      <div style="flex-grow: 1; display: flex; align-items: center; justify-content: space-between;">
        <span style="color: #c084fc; font-size: 0.92em; font-weight: 700; letter-spacing: -0.01em;">📂 ${subfolder}</span>
        <span style="font-size: 0.7em; color: #6b7280; font-weight: 600; background: rgba(107, 114, 128, 0.15); padding: 3px 8px; border-radius: 10px;">${subfileCount}</span>
      </div>
    </div>
  </summary>
  <div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid rgba(139, 92, 246, 0.15);">`;
        
        for (let file of subfiles) {
          let displayName = file.file.name;
          let content = await dv.io.load(file.file.path);
          let headers = content.match(/^## (.+)$/gm) || [];
          let fileId = `file-${file.file.path.replace(/[^a-zA-Z0-9]/g, '-')}`;
          
          if (headers.length === 0) {
            partHTML += `
<div style="background: rgba(42, 42, 62, 0.5); backdrop-filter: blur(8px); border-left: 2px solid #a855f7; padding: 9px 12px; margin: 6px 0; border-radius: 7px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.15); transition: all 0.25s; display: flex; align-items: center; gap: 8px;">
  <a data-href="${file.file.path}" href="${file.file.path}" class="internal-link file-open-btn" style="display: inline-flex; align-items: center; justify-content: center; width: 22px; height: 22px; border-radius: 4px; background: rgba(139, 92, 246, 0.2); color: #c084fc; text-decoration: none; flex-shrink: 0; transition: all 0.2s;">
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
  </a>
  <span style="font-weight: 600; color: #d1d5db; font-size: 0.85em; flex-grow: 1;">${file.file.link}</span>
</div>`;
          } else {
            let headersList = headers.map(h => {
              let title = h.replace("## ", "").trim();
              return `<li style="margin: 5px 0; list-style: none; font-size: 0.85em;"><span style="color: #a78bfa; margin-right: 8px;">◆</span><a data-href="${file.file.name}#${title}" href="${file.file.name}#${title}" class="internal-link is-unresolved modern-link" style="color: #d1d5db; text-decoration: none; transition: all 0.2s; font-weight: 500;">${title}</a></li>`;
            }).join("");
            
            partHTML += `
<div style="background: rgba(42, 42, 62, 0.5); backdrop-filter: blur(8px); border-left: 2px solid #a855f7; padding: 10px 14px; margin: 6px 0; border-radius: 7px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15); transition: all 0.25s;">
  <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
    <a data-href="${file.file.path}" href="${file.file.path}" class="internal-link file-open-btn" style="display: inline-flex; align-items: center; justify-content: center; width: 22px; height: 22px; border-radius: 4px; background: rgba(139, 92, 246, 0.2); color: #c084fc; text-decoration: none; flex-shrink: 0; transition: all 0.2s;">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
    </a>
    <details class="file-detail-modern" data-id="${fileId}" style="flex-grow: 1; background: transparent; border: none; padding: 0; margin: 0; box-shadow: none;">
      <summary style="cursor: pointer; font-weight: 600; color: #d1d5db; list-style: none; user-select: none; font-size: 0.87em; display: flex; align-items: center; gap: 6px;">
        <span class="arrow-small" style="color: #a78bfa; font-size: 0.75em; transition: transform 0.2s;">▸</span>
        ${displayName}
      </summary>
      <ul style="margin: 10px 0 0 0; padding: 0 0 0 22px;">
        ${headersList}
      </ul>
    </details>
  </div>
</div>`;
          }
        }
        
        partHTML += `
  </div>
</details>`;
      }
    }
    
    partHTML += `
  </div>
</details>`;
    
    dv.paragraph(partHTML);
    partIndex++;
  }
  
  // CSS moderne avec animations
  dv.paragraph(`
<style>
@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Animations d'ouverture */
details[open] > .partie-content-modern,
details[open] > div:last-child {
  animation: slideDown 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Rotation des flèches */
details[open] > summary .arrow-modern,
details[open] > summary .arrow-small {
  transform: rotate(90deg);
  background: rgba(139, 92, 246, 0.25);
}

/* Hover effects sur PARTIE */
.partie-card-modern:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.5), 0 0 0 1px rgba(139, 92, 246, 0.3);
}

.partie-card-modern:hover > div:first-child {
  opacity: 1;
}

/* Hover sur sous-dossiers */
.subfolder-card-modern:hover {
  background: rgba(30, 30, 46, 0.6);
  border-color: rgba(139, 92, 246, 0.4);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

/* Hover sur bouton d'ouverture */
.file-open-btn:hover {
  background: rgba(139, 92, 246, 0.4) !important;
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
}

/* Hover sur fichiers */
.file-detail-modern:hover,
.file-detail-modern:hover + div {
  background: rgba(42, 42, 62, 0.8);
  border-left-color: #c084fc;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
}

/* Liens internes */
.modern-link:hover {
  color: #c084fc !important;
  transform: translateX(4px);
  display: inline-block;
}

.modern-link::before {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 2px;
  background: linear-gradient(90deg, #ec4899, #8b5cf6);
  transition: width 0.3s;
}

.modern-link:hover::before {
  width: 100%;
}

/* Smooth transitions globales */
* {
  transition: all 0.2s ease;
}

/* Scrollbar moderne */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: rgba(30, 30, 46, 0.5);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #ec4899, #8b5cf6);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #f472b6, #a78bfa);
}
</style>`);

  // Attacher les événements après le rendu
  setTimeout(() => {
    // Restaurer l'état sauvegardé
    restoreState();
    
    // Écouter les changements d'état
    document.querySelectorAll('details').forEach(el => {
      el.addEventListener('toggle', saveState);
    });
  }, 100);
}
```