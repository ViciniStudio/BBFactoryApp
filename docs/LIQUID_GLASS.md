# Liquid Glass dans B&B Factory

## 1. Ce qu'Apple définit

Liquid Glass est le matériau dynamique introduit avec iOS 26 : il floute le contenu situé derrière lui, réfléchit la lumière et les couleurs environnantes et réagit aux interactions. Les composants SwiftUI standard l'adoptent automatiquement lorsqu'une app est compilée avec le SDK iOS 26.

Sources officielles :

- Technology Overview — https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass
- Human Interface Guidelines — https://developer.apple.com/design/human-interface-guidelines/
- SwiftUI — https://developer.apple.com/documentation/swiftui
- « Applying Liquid Glass to custom views » — https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views
- `View.glassEffect(_:in:)` — https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)
- `GlassEffectContainer` — https://developer.apple.com/documentation/swiftui/glasseffectcontainer
- `Glass` — https://developer.apple.com/documentation/swiftui/glass
- `tabBarMinimizeBehavior(_:)` — https://developer.apple.com/documentation/swiftui/view/tabbarminimizebehavior(_:)

Les signatures et disponibilités ont été vérifiées dans la documentation Apple (JSON officiel) le 21 octobre 2026 :

```swift
@available(iOS 26.0, *)
func glassEffect(_ glass: Glass = .regular,
                 in shape: some Shape = DefaultGlassEffectShape()) -> some View
```

`DefaultGlassEffectShape` est une capsule. `Glass.regular` est la variante par défaut ; `.tint(_:)` et `.interactive()` permettent de personnaliser la couleur et la réaction au toucher.

## 2. Version cible et stratégie de compatibilité

| Élément | Choix |
| --- | --- |
| SDK de compilation | iOS 26.2 (Xcode 26.3, runner `macos-15-intel`) |
| Déploiement minimum | **iOS 18.0** |
| Liquid Glass natif | iOS 26 et ultérieur |
| Repli | matériau translucide + trait fin sur iOS 18 |

L'app est compilée avec le SDK iOS 26 : la barre d'onglets, les barres de navigation, les feuilles et les champs de recherche système adoptent donc Liquid Glass automatiquement sur iOS 26, sans code spécifique.

Le déploiement à iOS 18 évite d'exclure des appareils compatibles. Toutes les API iOS 26 sont protégées par `#available(iOS 26.0, *)` dans `Core/DesignSystem/GlassStyle.swift`.

## 3. Où Liquid Glass est utilisé

| Élément | Implémentation | Fichier |
| --- | --- | --- |
| Barre d'onglets | `TabView` native + `.tabBarMinimizeBehavior(.onScrollDown)` sur iOS 26 | `App/RootView.swift` |
| Bouton contact du héros | `GlassIconButton` (`.buttonStyle(.glass)`) | `Features/Home/HomeView.swift` |
| Actions rapides | 3 boutons groupés dans `BBGlassGroup` / `GlassEffectContainer` | `Features/Home/HomeView.swift` |
| Pastille d'ouverture | capsule `bbGlass(in: Capsule(), tint:)` | `Core/DesignSystem/GlassStyle.swift` |
| Filtres de la carte | capsules interactives avec `glassEffect(...interactive())` | `Features/Menu/MenuView.swift` |
| Boutons principaux | `.buttonStyle(.glassProminent)` | partout via `.bbGlassButtonStyle(prominent: true)` |
| Boutons secondaires | `.buttonStyle(.glass)` | via `.bbGlassButtonStyle()` |
| Barre d'outils | boutons de toolbar système → verre natif sur iOS 26 | `Features/Practical/PracticalView.swift`, `Features/Contact/ContactSheet.swift` |
| Feuilles modales | `.presentationDetents`, `.presentationDragIndicator`, fond système | fiche plat, contact |
| Recherche | `.searchable` natif → champ de recherche en verre sur iOS 26 | `Features/Menu/MenuView.swift` |
| Panneau d'état | `GlassCard` (état d'ouverture) | `Features/Practical/PracticalView.swift` |
| Boutons sur visuel | boutons en surimpression du héros sombre | `Features/Home/HomeView.swift` |

## 4. Où Liquid Glass n'est **pas** utilisé

Apple recommande de limiter le nombre d'effets de verre simultanés pour préserver la lisibilité et les performances. Les cartes de contenu (horaires, plats, services) utilisent donc `SurfaceCard` : fond opaque chaud, trait fin, coins continus. Le verre est réservé à la navigation, aux contrôles flottants et aux états mis en avant.

Cette hiérarchie évite l'écueil « tout est flou » : le contenu reste stable, contrasté et lisible, tandis que les commandes se détachent.

## 5. Groupement et morphing

`BBGlassGroup` enveloppe ses enfants dans `GlassEffectContainer(spacing:)` sur iOS 26. Les formes proches peuvent ainsi se fondre et se déformer ensemble. Il est utilisé pour la rangée d'actions rapides de l'accueil. Le spacing du conteneur (14) et celui du `HStack` (12) sont volontairement proches pour produire un léger effet de fusion au repos, sans excès.

`glassEffectID`, `glassEffectUnion` et `glassEffectTransition` ne sont pas utilisés : ils nécessitent des transitions de hiérarchie animées, et l'app privilégie des transitions système sobres. Cette décision est documentée pour éviter d'ajouter des effets sans usage réel.

## 6. Accessibilité

- **Dynamic Type** : toutes les tailles de texte utilisent des styles dynamiques (`.body`, `.title2`, `.footnote`, `Font.system(.largeTitle, design: .serif)`). Aucune taille de police fixe pour le texte. Les icônes conservent une taille fixe, ce qui est admis.
- **VoiceOver** : chaque bouton icône possède un libellé (`GlassIconButton`, boutons de favoris, toolbar). La photo du héros et `AmbientGlow` sont `accessibilityHidden` ; le héros conserve un libellé global. Les cartes combinent leurs informations quand c'est pertinent.
- **Contrastes** : l'accent cuivre est décliné en deux variantes. `accentText` (plus sombre en clair, plus clair en sombre) est utilisé pour le texte. Le verre n'est jamais le seul support d'une information critique.
- **Reduce Motion** : `AmbientGlow` désactive son animation avec `@Environment(\.accessibilityReduceMotion)`. Les transitions de chargement sont également désactivées.
- **Mode clair / sombre** : chaque couleur est définie via `UIColor` dynamique ; le matériau et le verre suivent l'apparence système.
- **Cibles tactiles** : 44 × 44 pt minimum pour les boutons icône ; les lignes de plats sont entièrement tactiles.
- **Safe areas** : le héros respecte les marges ; la barre d'onglets native gère les safe areas et le minimize.

## 7. Performances

- Un seul `GlassEffectContainer` par écran (accueil) et un nombre limité de formes en verre visibles.
- Les listes utilisent `LazyVStack` / `LazyVGrid`.
- Aucune image distante, aucun chargement réseau : le contenu est local.
- Les cartes de contenu sont opaques plutôt qu'en verre pour réduire le coût de composition.
- `TimelineView` ne rafraîchit l'état d'ouverture qu'une fois par minute.

## 8. Limites de vérification

Le projet est développé depuis Windows 11. Aucun simulateur iOS n'est disponible localement : le rendu Liquid Glass **n'a pas été observé visuellement** par l'auteur de ces lignes. Le workflow GitHub Actions compile l'app avec Xcode 26.3 et exécute les tests, ce qui valide les API et la compilation, pas l'esthétique rendue.

Une revue visuelle sur un iPhone sous iOS 26 reste nécessaire, notamment pour :

- la taille de la barre d'onglets et son comportement au scroll ;
- le contraste des pastilles en verre sur le héros sombre ;
- le rendu du verre teinté en mode clair ;
- le comportement du clavier lors de la recherche.
