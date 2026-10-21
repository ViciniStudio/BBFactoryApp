# Release et récupération de l'IPA

## 1. État attendu

Le workflow produit un **IPA non signé**. Il n'est **pas installable tel quel** sur un iPhone : il doit d'abord être signé (eSign ou autre outil) avec un certificat et un profil de provisionnement compatibles.

Le workflow ne contient aucun certificat, aucun mot de passe et aucun secret Apple.

## 2. Déclencher une compilation

Trois possibilités :

1. **Push** sur `main`.
2. **Pull request** vers `main`.
3. **Exécution manuelle** : onglet *Actions* → *iOS Build — Unsigned IPA* → *Run workflow* → branche `main` → *Run workflow*.

Lien direct (une fois le workflow présent sur GitHub) :

https://github.com/ViciniStudio/BBFactoryApp/actions/workflows/ios-build.yml

## 3. Télécharger l'artefact depuis Windows 11

1. Ouvrir le dépôt : https://github.com/ViciniStudio/BBFactoryApp
2. Cliquer sur l'onglet **Actions**.
3. Dans la colonne de gauche, sélectionner **iOS Build — Unsigned IPA**.
4. Ouvrir l'exécution correspondant au dernier commit (cercle vert = succès).
5. Vérifier dans le résumé : version, commit, bundle ID, taille, SHA-256.
6. En bas de la page, section **Artifacts**, cliquer sur **BBFactoryApp-Unsigned-IPA**.
7. Windows télécharge un fichier **`.zip`** (c'est l'emballage de l'artefact GitHub, pas l'IPA).
8. Clic droit → **Extraire tout…**, puis ouvrir le dossier extrait.
9. Récupérer le fichier **`BBFactoryApp-1.0.0-<numéro>-unsigned.ipa`**.

### ZIP de l'artefact ≠ IPA

- Le **ZIP téléchargé** est créé par GitHub pour emballer l'artefact. Il contient l'IPA.
- Le **fichier `.ipa`** est lui aussi une archive ZIP par nature, mais c'est le paquet iOS : sa racine contient `Payload/BBFactoryApp.app`.
- Ne pas renommer le `.app` en `.ipa`. Ne pas extraire l'IPA pour l'installer : donner le `.ipa` à eSign.
- Windows peut afficher l'IPA avec une icône d'archive : c'est normal.

## 4. Vérifier l'IPA reçu

Dans PowerShell :

```powershell
Get-FileHash .\BBFactoryApp-1.0.0-123-unsigned.ipa -Algorithm SHA256
Get-Item .\BBFactoryApp-1.0.0-123-unsigned.ipa | Select-Object Name,Length
```

Comparer le SHA-256 avec celui affiché dans le résumé du workflow. Pour inspecter la structure sans l'extraire définitivement :

```powershell
tar -tf .\BBFactoryApp-1.0.0-123-unsigned.ipa
```

On doit voir au minimum :

```text
Payload/
Payload/BBFactoryApp.app/
Payload/BBFactoryApp.app/BBFactoryApp
Payload/BBFactoryApp.app/Info.plist
...
```

Aucun `embedded.mobileprovision` ne doit être présent dans un IPA non signé.

## 5. Version et nommage

- `CFBundleShortVersionString` : `1.0.0` (défini dans `project.yml`).
- `CFBundleVersion` : `1`.
- Nom de l'IPA : `BBFactoryApp-<version>-<numéro d'exécution>-unsigned.ipa`.
- Nom de l'artefact : `BBFactoryApp-Unsigned-IPA`.
- Conservation : 30 jours.
- Logs et résultats de tests : `BBFactoryApp-Build-Logs`, 7 jours.

Pour publier une nouvelle version, modifier `MARKETING_VERSION` et `CURRENT_PROJECT_VERSION` dans `project.yml`, puis pousser sur `main`.

## 6. Après le téléchargement

La suite dépend de la méthode de signature :

1. Signer l'IPA avec eSign et un certificat/profil compatibles.
2. Installer l'app signée.
3. Faire confiance au certificat si iOS le demande.
4. Vérifier que l'app se lance et que la carte s'affiche.

La procédure détaillée et les diagnostics sont dans `docs/ESIGN.md`.

## 7. En cas d'échec du workflow

1. Ouvrir l'exécution rouge.
2. Identifier l'étape en erreur (le workflow s'arrête à la première).
3. Télécharger **BBFactoryApp-Build-Logs**.
4. Lire les dernières lignes du fichier correspondant :
   - `build-simulator.log` : erreur de compilation ;
   - `build-tests.log` : test en échec ;
   - `build-device.log` : build appareil / signature ;
   - `xcodebuild-list.log` : schéma ou projet introuvable.
5. Corriger, committer, pousser.

Erreurs fréquentes :

| Message | Piste |
| --- | --- |
| `requires a development team` | `CODE_SIGNING_ALLOWED=NO` absent |
| `No scheme named BBFactoryApp` | génération XcodeGen échouée ou schéma renommé |
| `No such module 'XCTest'` | cible de test mal configurée |
| `The binary is not built for the iOS platform` | build simulateur au lieu de `iphoneos` |
| `Unexpected bundle identifier` | `PRODUCT_BUNDLE_IDENTIFIER` modifié |
| Artefact introuvable | étape de packaging en échec ; voir les logs |

## 8. Ce que ce workflow ne fait pas

- Il ne signe pas l'app.
- Il ne crée pas de certificat.
- Il ne s'authentifie pas auprès d'Apple.
- Il ne publie pas sur l'App Store ou TestFlight.
- Il ne garantit pas que le certificat fourni plus tard couvrira l'appareil cible.
