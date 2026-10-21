# Architecture

## 1. Principes

- **SwiftUI natif**, sans Flutter, React Native ni WebView.
- **Contenu piloté par les données** : identité, horaires et carte vivent dans un JSON embarqué, pas dans les vues.
- **Verre pour la navigation, matière pour le contenu** : hiérarchie visuelle explicite (voir `docs/LIQUID_GLASS.md`).
- **Aucun compte, aucun paiement, aucune télémétrie** : l'app est consultative et fonctionne hors ligne.
- **iOS 18 minimum**, Liquid Glass natif sur iOS 26 avec repli propre.
- **Tests unitaires** sur la logique qui peut casser sans qu'on le voie : horaires, données, favoris, filtres, URLs.

## 2. Arborescence

```text
BBFactoryApp/
├── App/
│   ├── BBFactoryApp.swift          # point d'entrée, injection AppModel
│   └── RootView.swift              # états chargement/erreur, TabView, 4 onglets
├── Core/
│   ├── DesignSystem/
│   │   ├── BBTheme.swift           # couleurs clair/sombre, typographie, fond
│   │   ├── GlassStyle.swift        # glassEffect, fallback, boutons, pastille
│   │   ├── Components.swift        # SurfaceCard, GlassCard, filtres, états vides
│   │   └── AmbientGlow.swift       # glow animé, Reduce Motion respecté
│   ├── Models/
│   │   ├── Restaurant.swift        # modèle Codable complet
│   │   └── OpeningHours.swift      # semaine, service, calcul ouvert/fermé
│   ├── Services/
│   │   ├── AppModel.swift          # @Observable : état + favoris
│   │   ├── RestaurantRepository.swift
│   │   ├── FavoritesStore.swift    # UserDefaults, local
│   │   ├── AppURL.swift            # URLs tel/mailto/https validées
│   │   └── MapsService.swift       # itinéraire natif MapKit
│   └── Utilities/
│       └── AppInfo.swift           # version, dates françaises
├── Features/
│   ├── Home/HomeView.swift
│   ├── Menu/                       # carte, filtres, détail, favoris
│   ├── Story/StoryView.swift
│   ├── Practical/PracticalView.swift
│   ├── Contact/ContactSheet.swift
│   └── Shared/OpeningStatusView.swift
├── Resources/
│   ├── Assets.xcassets/            # AppIcon, AccentColor, HeroBurger
│   ├── Config/Restaurant.json      # source de vérité du contenu
│   └── PrivacyInfo.xcprivacy
BBFactoryAppTests/                   # XCTest
project.yml                          # génération XcodeGen
.github/workflows/ios-build.yml
docs/
```

## 3. Couches

### Modèles

`Restaurant` est un arbre `Codable`, `Hashable`, `Sendable` :

- `Identity`, `Contact`, `RestaurantLocation`
- `OpeningHours` → `[DaySchedule]` → `[ServiceWindow]`
- `Menu` → catégories + `[MenuItem]` ; un plat peut préciser son service (`MenuCourse` : entrée ou plat) pour les recettes proposées en deux portions
- `Story` → paragraphes, faits, distinctions
- `[ServiceItem]`, `[PaymentMethod]`

`OpeningHours.status(at:)` calcule l'état à une date donnée, dans le fuseau `Europe/Paris`, en gérant les services qui se chevauchent et les fermetures. Il renvoie `OpenStatus.open(until:)` ou `.closed(nextOpening:)`.

### Services

- `RestaurantRepository` lit `Restaurant.json` dans le bundle et valide qu'il n'est pas vide.
- `AppModel` est `@MainActor @Observable`. Il expose `state` (`.loading/.loaded/.failed`), `restaurant` et `favorites`.
- `FavoritesStore` persiste un `Set<String>` d'identifiants de plats dans `UserDefaults`. Aucun identifiant utilisateur, aucun serveur.
- `AppURL` centralise la construction et la validation des URLs. Les schémas autres que `https`/`http` sont refusés pour les liens web, ce qui évite les liens `javascript:` issus d'une future donnée mal saisie.
- `MapsService` construit un `MKMapItem` avec les coordonnées vérifiées et ouvre Maps en mode itinéraire voiture. Un lien `maps.apple.com` sert uniquement de repli si l'ouverture native échoue.

### Vues

- `RootView` gère les trois états et n'affiche les onglets qu'une fois le contenu chargé.
- `MainTabView` utilise l'API `Tab` (iOS 18) : Accueil, Carte, Maison, Pratique.
- Chaque onglet possède son `NavigationStack`. Les fiches plat et contact sont des feuilles (`sheet`) avec détents.
- Les vues reçoivent `Restaurant` en paramètre (valeur immuable) et lisent les favoris via l'environnement.

## 4. Navigation

```text
TabView
├── Accueil ──┬── fiche plat (sheet)
│             └── contact (sheet)
├── Carte ────┬── recherche + filtres
│             └── fiche plat (sheet)
├── Maison ──── sources externes (Safari)
└── Pratique ── téléphone, itinéraire natif, copie d'adresse
```

Les actions « La carte », « Tous les horaires » et « Pratique » changent d'onglet via un `Binding<AppTab>`, ce qui évite d'empiler des copies d'écrans. `bbTabTransition(_:selection:)` applique un léger fondu suivi d'une remontée au contenu de l'onglet qui devient actif ; il respecte `accessibilityReduceMotion`.

## 5. Données et mise à jour

`Restaurant.json` est la seule source de contenu. Pour corriger un horaire ou un prix :

1. modifier le JSON ;
2. vérifier la cohérence (les tests le font en partie) ;
3. mettre à jour `lastVerified` ;
4. relancer le workflow.

Aucune migration de base de données n'est nécessaire.

## 6. Gestion des erreurs

- Fichier absent ou JSON invalide → `RootView` affiche un écran explicite avec « Réessayer ».
- Recherche sans résultat → `EmptyStateCard` avec action « Effacer la recherche ».
- Aucun favori → état vide explicite, pas une liste blanche.
- URL invalide → le bouton est masqué ou l'action ne fait rien, sans crash.

## 7. Accessibilité et apparence

- Couleurs dynamiques clair/sombre dans `BBTheme`.
- Textes en styles dynamiques ; pas de taille fixe pour le texte.
- Libellés VoiceOver sur les icônes et les cartes.
- `accessibilityReduceMotion` respecté.
- Le verre n'est jamais indispensable à la compréhension.

## 8. Tests

| Fichier | Couverture |
| --- | --- |
| `OpeningHoursTests` | ouvert/fermé, midi/soir, jeudi, dimanche, vendredi 18:45, fermeture exclusive, lendemain |
| `RestaurantDataTests` | identité, adresse, URLs HTTPS, téléphone/e-mail, itinéraire de repli, intégrité de la carte, portions entrée/plat des salades, symboles SF, dates, resource manquante |
| `FavoritesStoreTests` | ajout/retrait, persistance, purge |
| `AppModelTests` | chargement, erreur, idempotence |
| `MenuFilteringTests` | catégories, appartenance, prix, recherche |

Les tests s'exécutent via GitHub Actions sur le premier simulateur iPhone disponible de l'image macOS.

## 9. Configuration Xcode

- Projet généré par **XcodeGen** depuis `project.yml` (le `.xcodeproj` n'est pas versionné).
- Bundle ID : `fr.vicinistudio.bbfactory`.
- Nom affiché : `B&B Factory`.
- Version : `1.0.0` (build `3`).
- iPhone uniquement, portrait.
- Aucune dépendance Swift Package.
- Signature désactivée dans le workflow pour produire un IPA non signé.
- `PrivacyInfo.xcprivacy` déclare l'usage de `UserDefaults` (raison `CA92.1`), sans tracking ni collecte.
