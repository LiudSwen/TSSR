# Linux - Gestion des utilisateurs - Cheatsheet TSSR
> CCP 3 — Exploiter des serveurs Linux

---

## Création et suppression

| Action | Commande |
|--------|----------|
| Créer un utilisateur (sans home) | `useradd nom_user` |
| Créer avec home directory | `useradd -m nom_user` |
| Créer avec shell spécifique | `useradd -m -s /bin/bash nom_user` |
| Créer avec UID spécifique | `useradd -u 1500 nom_user` |
| Créer un utilisateur système | `useradd -r nom_user` |
| Supprimer un utilisateur | `userdel nom_user` |
| Supprimer avec home et fichiers | `userdel -r nom_user` |

---

## Modification et mots de passe

| Action | Commande |
|--------|----------|
| Changer le shell | `usermod -s /bin/bash nom_user` |
| Changer le répertoire home | `usermod -d /nouveau/home nom_user` |
| Renommer un utilisateur | `usermod -l nouveau_nom ancien_nom` |
| Verrouiller un compte | `usermod -L nom_user` |
| Déverrouiller un compte | `usermod -U nom_user` |
| Définir un mot de passe | `passwd nom_user` |
| Forcer changement au prochain login | `passwd -e nom_user` |
| Voir statut du mot de passe | `passwd -S nom_user` |
| Définir expiration (jours) | `chage -M 90 nom_user` |
| Voir politique d'expiration | `chage -l nom_user` |
| Définir date d'expiration du compte | `chage -E 2026-12-31 nom_user` |
| Désactiver expiration du mot de passe | `chage -M -1 nom_user` |

---

## Groupes

| Action | Commande |
|--------|----------|
| Créer un groupe | `groupadd nom_groupe` |
| Créer avec GID spécifique | `groupadd -g 2000 nom_groupe` |
| Supprimer un groupe | `groupdel nom_groupe` |
| Ajouter un user à un groupe (secondaire) | `usermod -aG nom_groupe nom_user` |
| Ajouter à plusieurs groupes | `usermod -aG grp1,grp2 nom_user` |
| Définir le groupe principal | `usermod -g nom_groupe nom_user` |
| Retirer un user d'un groupe | `gpasswd -d nom_user nom_groupe` |

---

## Consultation et vérification

| Action | Commande |
|--------|----------|
| Voir les infos d'un utilisateur | `id nom_user` |
| Voir les groupes d'un user | `groups nom_user` |
| Lister tous les utilisateurs | `cat /etc/passwd` |
| Lister tous les groupes | `cat /etc/group` |
| Voir les users connectés | `who` |
| Voir le dernier login | `lastlog -u nom_user` |
| Vérifier si un user existe | `getent passwd nom_user` |
| Sudo : ajouter aux sudoers (Debian) | `usermod -aG sudo nom_user` |
| Sudo : tester les droits | `sudo -l -U nom_user` |
| Sudo : éditer le fichier sudoers | `visudo` |

---

## Fichiers importants

| Fichier | Contenu |
|---------|---------|
| `/etc/passwd` | Liste des utilisateurs (login, UID, GID, home, shell) |
| `/etc/shadow` | Mots de passe chiffrés + politique d'expiration |
| `/etc/group` | Liste des groupes et membres |
| `/etc/gshadow` | Mots de passe des groupes |
| `/etc/skel/` | Template copié dans le home à la création |
| `/etc/login.defs` | Politique par défaut (plages UID/GID, expiration) |
| `/etc/sudoers` | Règles de droits sudo (éditer via `visudo`) |

---

## Points de vigilance

| Piège | À retenir |
|-------|-----------|
| `useradd` sans `-m` | Pas de home créé par défaut sur certaines distros |
| `usermod -G` sans `-a` | Écrase tous les groupes secondaires existants ! |
| `userdel` sans `-r` | Laisse le home directory orphelin sur le disque |
| Modifier `/etc/sudoers` directement | Toujours utiliser `visudo` (vérifie la syntaxe) |
| UID < 1000 | Réservés aux comptes système (ne pas utiliser pour users normaux) |
| `passwd -d` | Supprime le mot de passe → compte accessible sans auth ! |
