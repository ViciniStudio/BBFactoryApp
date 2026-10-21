# Build

## 1. Environnement de développement

Le développement se fait sur **Windows 11**. Xcode et `xcodebuild` n'existent pas sur Windows et ne peuvent pas être exécutés nativement. Le projet est donc :

- écrit et validé statiquement sous Windows ;
- compilé, testé et empaqueté sur un **runner macOS GitHub Actions**.

Outils vérifiés localement :

```text
git version 2.56.0.windows.2
```

Aucun `xcodebuild`, `swift` ni `gh` n'est installé sur la machine Windows. C'est normal et documenté.

## 2. Générer le projet Xcode

Le dépôt ne versionne pas `BBFactoryApp.xcodeproj` : il est généré à partir de `project.yml` pour éviter les conflits de fichier `.pbxproj`.

Sur macOS :

```bash
brew install xcodegen
xcodegen generate --spec project.yml
open BBFactoryApp.xcodeproj
```

XcodeGen est installé par la CI via Homebrew (2.46.0 au moment de la rédaction). Le projet généré contient :

- la cible application `BBFactoryApp` ;
- la cible de tests `BBFactoryAppTests` ;
- un scheme `BBFactoryApp` avec l'action Test.

## 3. Compiler et tester sur macOS

```bash
# Simulation
xcodebuild build \
  -project BBFactoryApp.xcodeproj \
  -scheme BBFactoryApp \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO

# Tests (le runner choisit un simulateur iPhone disponible)
xcodebuild test \
  -project BBFactoryApp.xcodeproj \
  -scheme BBFactoryApp \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## 4. Compiler pour un appareil réel (non signé)

```bash
xcodebuild build \
  -project BBFactoryApp.xcodeproj \
  -scheme BBFactoryApp \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""
```

Puis empaqueter :

```bash
mkdir -p build/Payload
cp -R build/DerivedData/Build/Products/Release-iphoneos/BBFactoryApp.app build/Payload/
cd build
zip -qry BBFactoryApp-unsigned.ipa Payload
```

Un IPA est une archive ZIP dont la racine contient un dossier `Payload/` et, dedans, l'application `.app`. Renommer un `.app` en `.ipa` ne produit **pas** un IPA valide.

## 5. GitHub Actions

Le workflow `.github/workflows/ios-build.yml` :

1. checkout du dépôt ;
2. affichage de macOS, Xcode, Swift et des SDK ;
3. sélection du plus récent Xcode 26 installé sur l'image ;
4. installation de XcodeGen ;
5. génération du projet ;
6. liste des schemes ;
7. résolution des dépendances (aucune dépendance externe) ;
8. build simulateur ;
9. tests unitaires sur le premier simulateur iPhone disponible ;
10. build Release `iphoneos` avec signature désactivée ;
11. vérifications : plateforme `IOS`, bundle ID, version minimale, absence de signature, structure `Payload/` ;
12. création de l'IPA et vérification de l'archive ;
13. publication de l'artefact `BBFactoryApp-Unsigned-IPA` (30 jours) ;
14. publication des logs et résultats de tests (7 jours, même en cas d'échec).

Déclencheurs : push sur `main`, pull request vers `main`, exécution manuelle.

## 6. Pourquoi `macos-15-intel` et Xcode 26.3

L'image `macos-15-intel` de GitHub Actions fournit Xcode 26.3 (SDK iOS 26.2) et des simulateurs iPhone récents. C'est suffisant pour compiler les API Liquid Glass tout en conservant un déploiement iOS 18.

GitHub signale des contraintes de capacité sur ses runners macOS arm64 : trois exécutions ont été annulées après quinze minutes d'attente sans qu'un runner soit attribué. Le workflow utilise donc le runner Intel, disponible, dont le binaire de sortie reste bien `arm64` pour l'iPhone. Il pourra repasser sur `macos-26` lorsque la file arm64 sera revenue à la normale.

Lors de l'exécution vérifiée du 21/10/2026 : Xcode 26.3, Swift 6.2.4, SDK `iPhoneOS26.2`, 33 tests réussis.

Le workflow sélectionne le plus récent Xcode 26 installé sur l'image et échoue explicitement si aucun n'est présent, plutôt que de compiler avec un SDK trop ancien. Il choisit ensuite automatiquement un simulateur iPhone disponible pour les tests et imprime les versions réelles à chaque exécution.

## 7. Vérifications réalisées sous Windows

- Validation JSON de `Restaurant.json`.
- Contrôle de l'arborescence et des fichiers référencés.
- Relecture des signatures d'API Apple (documentation officielle).
- Vérification des symboles SF utilisés dans les données (tests exécutés en CI).
- Aucun build Swift local : la compilation réelle est celle de GitHub Actions.

## 8. Dépannage

| Erreur | Cause probable | Correction |
| --- | --- | --- |
| `xcodegen: command not found` | XcodeGen absent | `brew install xcodegen` |
| `Signing for "BBFactoryApp" requires a development team` | signature non désactivée | ajouter `CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO` |
| `No such module` | projet non régénéré après ajout de fichier | `xcodegen generate` |
| Tests introuvables | ressource JSON absente du bundle de tests | vérifier `project.yml` (section `BBFactoryAppTests`) |
| `platform IOS` absent de `vtool` | build simulateur utilisé | reconstruire avec `-sdk iphoneos -destination 'generic/platform=iOS'` |
| Artefact absent | étape d'empaquetage échouée | consulter `BBFactoryApp-Build-Logs` |

## 9. Ce qui n'est pas couvert

- La signature de l'app (voir `docs/ESIGN.md`).
- L'installation sur un iPhone.
- Les tests UI et les captures d'écran de référence.
- Une validation visuelle du rendu Liquid Glass (aucun Mac disponible localement).
