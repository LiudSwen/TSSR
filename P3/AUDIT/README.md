# Audit de sécurité Active Directory – billu.lan

Audit de configuration Active Directory réalisé avec PingCastle sur un environnement de test.  
L'objectif est d'identifier les vulnérabilités du domaine, d'appliquer les corrections recommandées et de mesurer l'amélioration obtenue.

---

## Résultat

| Étape | Score PingCastle |
|-------|----------------|
| Audit initial | 71 / 100 |
| Audit final | 21 / 100 |

---

## Contenu du dépôt

```
.
├── RESSOURCES/
│   ├── V1_AUDIT_0503_1343/     # Rapport PingCastle initial
│   └── V8_AUDIT_0503_2335/     # Rapport PingCastle final
└── README.md
└── AUDIT_SECURITE_AD_BILLU.md       # Rapport d'audit complet
```

---

## Vulnérabilités traitées

| Vulnérabilité | Criticité | Statut |
|--------------|-----------|--------|
| Protocoles NTLMv1 et LM autorisés | Élevée | Corrigé |
| Politique de mot de passe insuffisante | Élevée | Corrigé |
| Audit des événements incomplet | Moyenne | Corrigé |
| Comptes administrateurs non protégés | Élevée | Corrigé |
| Absence de LAPS | Élevée | Corrigé |
| Comptes sensibles délégables | Élevée | Corrigé |
| Ajout de machines au domaine par des utilisateurs | Moyenne | Corrigé |
| Groupe Schema Admins non vide | Moyenne | Corrigé |
| Sauvegarde Active Directory obsolète | Élevée | Corrigé |
| Utilisation récente du compte Administrator | Faible | En observation |

---

## Outils utilisés

- [PingCastle](https://www.pingcastle.com/) – Audit de sécurité Active Directory
- Windows Server Backup – Sauvegarde du contrôleur de domaine
- Microsoft LAPS – Gestion des mots de passe administrateurs locaux

---

## Environnement

- Domaine : `billu.lan`
- Environnement : Infrastructure de test
- Date : Mars 2026
