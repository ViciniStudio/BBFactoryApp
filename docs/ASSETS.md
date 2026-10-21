# Assets

## `HeroBurger`

- **Fichier** : `BBFactoryApp/Resources/Assets.xcassets/HeroBurger.imageset/hero-burger.jpg`
- **Dimensions** : 1280 × 1515 px (recadrage du visuel officiel, ratio 0,845)
- **Source** : site officiel B&B FACTORY, galerie `dish.co`
  - URL d'origine : `https://cdn.website.dish.co/media/29/32/8080190/B-B-FACTORY-IMG-1262-jpeg.jpg`
  - visuel : burger B&B FACTORY, frites et garnitures, fond ardoise
- **Intégration** : demandée explicitement par le client pour remplacer l'illustration vectorielle du héros. Affichée par `HeroPhoto`, qui remplit le cadre sans élargir la mise en page.
- **Droits** : la photographie reste la propriété de B&B FACTORY et de son photographe. L'établissement doit confirmer l'autorisation de diffusion avant une publication sur l'App Store. Pour remplacer le visuel, écraser `hero-burger.jpg` par la photo fournie par le restaurant en conservant le même nom et le même cadrage.

## `StoryKitchen`

- **Fichier** : `BBFactoryApp/Resources/Assets.xcassets/StoryKitchen.imageset/story-kitchen.jpg`
- **Dimensions** : 1200 × 800 px (ratio 1,5)
- **Source** : site officiel B&B FACTORY, galerie `dish.co`
  - URL d'origine : `https://cdn.website.dish.co/media/15/f1/8840367/B-B-FACTORY-IMG-4196-2-jpg.jpg`
  - visuel : le chef en cuisine, devant le passe, planches de burgers en arrière-plan
- **Intégration** : remplace l'illustration vectorielle du héros de « La maison » (`StoryView.swift`), affichée par `HeroPhoto` dans un cadre fixe de 270 pt. Un double dégradé sombre garantit la lisibilité du titre et du nom du chef.
- **Droits** : la photographie reste la propriété de B&B FACTORY et de son photographe. L'établissement doit confirmer l'autorisation de diffusion avant une publication sur l'App Store. Pour remplacer le visuel, écraser `story-kitchen.jpg` par la photo fournie par le restaurant en conservant le même nom.

## `AppIcon`

L'icône de l'application est une création originale Vicini Studio. Elle ne reprend pas le logo officiel de l'établissement.
