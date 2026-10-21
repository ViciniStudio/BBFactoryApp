# B&B FACTORY — application iOS

Application iOS native (SwiftUI) pour **B&B FACTORY**, le restaurant de burgers du 12 rue Lobau à Phalsbourg.

> **Nom réel de l'établissement.** Les recherches ont confirmé que l'enseigne s'appelle **B&B FACTORY** (et non « BB Factory »). Le dépôt et le bundle conservent l'identifiant demandé `fr.vicinistudio.bbfactory` ; le nom affiché est « B&B Factory ».

## État du projet

| Élément | Statut |
| --- | --- |
| Code source | complet |
| Contenu (horaires, carte, actus) | issu de sources publiques, vérifié le 21/10/2026 |
| Compilation locale Windows | impossible (pas de Xcode) |
| Compilation GitHub Actions | **à exécuter après le premier push** |
| Tests unitaires | écrits, à exécuter sur le runner macOS |
| IPA non signé | **pas encore généré** |
| Signature eSign | non effectuée |
| Installation sur iPhone | non effectuée |

Aucun IPA n'existe tant que le workflow n'a pas réussi. Aucune app n'est signée ni installée par ce dépôt.

## Fonctionnalités

### Accueil
- héros éditorial avec identité de la maison ;
- état d'ouverture calculé en direct (fuseau `Europe/Paris`) ;
- actions rapides : appeler, itinéraire, carte ;
- actualité mise en avant ;
- sélection de plats ;
- adresse et accès.

### Carte
- 18 plats et prix issus du menu officiel ;
- recherche native ;
- filtres par catégorie et favoris ;
- fiche détaillée en feuille ;
- favoris persistants, sans compte ;
- états vides explicites, note sur les allergènes.

### La maison
- histoire de l'établissement et du chef ;
- faits vérifiés ;
- distinctions avec sources cliquables ;
- repères de la carte.

### Pratique
- état ouvert/fermé en temps réel ;
- horaires des sept jours, jour courant mis en évidence ;
- adresse, copie, itinéraire ;
- services et moyens de paiement ;
- contact téléphonique et e-mail.

### Actualités
- informations datées et sourcées (Coupe de France du Burger 2026) ;
- détail, lien vers la source, partage ;
- liens Instagram et Facebook.

## Design

- **Liquid Glass natif** sur iOS 26 : barre d'onglets système, boutons `.glass` / `.glassProminent`, `GlassEffectContainer`, pastilles teintées, recherche et toolbars système.
- **Repli** sur matériau translucide pour iOS 18.
- Cartes de contenu opaques pour préserver la hiérarchie et les performances.
- Palette crème / espresso / cuivre inspirée de l'identité publique, avec des couleurs dynamiques clair/sombre.
- Accessibilité : Dynamic Type, VoiceOver, Reduce Motion, cibles 44 pt, contrastes renforcés.

Détails et références Apple : [`docs/LIQUID_GLASS.md`](docs/LIQUID_GLASS.md).

## Stack

- Swift 5, SwiftUI, iOS 18 minimum (SDK iOS 26.5).
- `@Observable` / MVVM léger.
- Aucune dépendance externe, aucun réseau au runtime.
- XCTest.
- XcodeGen (`project.yml`) pour générer le projet.
- GitHub Actions sur `macos-26` / Xcode 26.6.
- Bundle ID : `fr.vicinistudio.bbfactory`.

## Structure

```text
BBFactoryApp/
├── App/                    # entrée, onglets, états globaux
├── Core/
│   ├── DesignSystem/       # thème, verre, composants
│   ├── Models/             # Restaurant, horaires
│   ├── Services/           # chargement, favoris, URLs
│   └── Utilities/
├── Features/               # Accueil, Carte, Maison, Pratique, Actus, Contact
├── Resources/
│   ├── Assets.xcassets/
│   ├── Config/Restaurant.json
│   └── PrivacyInfo.xcprivacy
BBFactoryAppTests/
project.yml
.github/workflows/ios-build.yml
docs/
```

## Modifier le contenu

Tout le contenu éditorial est dans **`BBFactoryApp/Resources/Config/Restaurant.json`** :

- identité, contacts, adresse, coordonnées ;
- horaires (`weekday`, `opens`, `closes`) ;
- services, paiements ;
- histoire, distinctions ;
- carte, catégories, prix ;
- actualités et sources.

Après modification : mettre à jour `lastVerified`, vérifier le JSON, puis relancer le workflow.

```powershell
Get-Content .\BBFactoryApp\Resources\Config\Restaurant.json -Raw | ConvertFrom-Json | Out-Null
```

## Développer depuis Windows 11

```powershell
git clone https://github.com/ViciniStudio/BBFactoryApp.git
cd BBFactoryApp
```

Windows ne peut pas compiler Swift/Xcode. La compilation se fait sur GitHub Actions. Voir [`docs/BUILD.md`](docs/BUILD.md).

Sur macOS :

```bash
brew install xcodegen
xcodegen generate
open BBFactoryApp.xcodeproj
```

## GitHub Actions et IPA

Le workflow `.github/workflows/ios-build.yml` se déclenche sur push `main`, pull request et manuellement. Il compile pour le simulateur, exécute les tests, construit pour `iphoneos` **sans signature**, vérifie que le binaire est bien iOS, empaquette `Payload/BBFactoryApp.app` dans un vrai `.ipa`, puis publie :

- `BBFactoryApp-Unsigned-IPA` (30 jours) ;
- `BBFactoryApp-Build-Logs` (7 jours).

Téléchargement :

1. https://github.com/ViciniStudio/BBFactoryApp/actions
2. **iOS Build — Unsigned IPA**
3. dernière exécution verte
4. **Artifacts** → **BBFactoryApp-Unsigned-IPA**
5. extraire le ZIP téléchargé → récupérer le `.ipa`

**Important :** l'IPA est **non signé** et n'est pas installable tel quel. Il doit être signé avec un certificat et un profil compatibles avant installation. Voir [`docs/RELEASE.md`](docs/RELEASE.md) et [`docs/ESIGN.md`](docs/ESIGN.md).

## Tests

```bash
xcodebuild test \
  -project BBFactoryApp.xcodeproj \
  -scheme BBFactoryApp \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Couverture : horaires et fuseau, intégrité du JSON, URLs, favoris, chargement, filtres, symboles SF.

## Accessibilité et vie privée

- Aucun compte, aucune analytique, aucun tracker, aucune publicité.
- Aucune donnée envoyée à un serveur par l'app.
- Favoris stockés localement dans `UserDefaults` (déclaré dans `PrivacyInfo.xcprivacy`).
- Les liens externes (site, réseaux sociaux, commande, plans) ouvrent l'app ou le navigateur système.
- L'app n'enregistre aucun paiement.

## Documentation

- [`docs/RESEARCH.md`](docs/RESEARCH.md) — sources, faits confirmés, incertitudes.
- [`docs/LIQUID_GLASS.md`](docs/LIQUID_GLASS.md) — API, usages, accessibilité, performances.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — structure, flux, tests.
- [`docs/BUILD.md`](docs/BUILD.md) — Windows, XcodeGen, commandes, dépannage.
- [`docs/RELEASE.md`](docs/RELEASE.md) — workflow, artefact, téléchargement.
- [`docs/ESIGN.md`](docs/ESIGN.md) — signature et installation, diagnostics.

## Limites connues

- L'IPA n'a pas encore été produit au moment de la rédaction.
- Le rendu Liquid Glass n'a pas été vérifié visuellement (pas de Mac sur le poste de développement).
- Les horaires du vendredi soir (18:45) et les prix doivent être confirmés par l'établissement.
- Aucune photo officielle ni logo officiel n'est embarqué : l'icône et les illustrations sont originales.
- Aucune réservation, commande ou fidélité intégrée : l'app renvoie vers le téléphone et le site officiel.
- La livraison n'est pas proposée.
- Les allergènes ne sont pas publiés.

## Sources

Site officiel, menu officiel, office de tourisme du Pays de Phalsbourg, Qoala, Société.com, Le Républicain Lorrain, Radio Mélodie, macommune.info. URLs et détails dans [`docs/RESEARCH.md`](docs/RESEARCH.md).

---

Application développée pour B&B FACTORY · Vicini Studio. Les marques et contenus de l'établissement appartiennent à leurs titulaires.
