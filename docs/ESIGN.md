# Signature et installation avec eSign

> **À lire avant de commencer.** La version d'eSign, la méthode de signature et le certificat utilisés ne sont pas connus à ce stade. Les étapes ci-dessous décrivent le principe général et les points de contrôle. La procédure exacte dépend de l'écran affiché par votre version d'eSign. Ne poursuivez pas tant que la méthode n'a pas été confirmée.

## 1. Ce qu'il faut comprendre

Un IPA non signé n'est pas installable. iOS vérifie :

1. **la signature de code** de l'application ;
2. **le profil de provisionnement** (`embedded.mobileprovision`) ;
3. **la correspondance du bundle ID** : `fr.vicinistudio.bbfactory` ;
4. **l'autorisation de l'appareil** : l'UDID doit figurer dans le profil (développement / ad hoc), ou l'appareil doit relever d'un certificat d'entreprise, ou l'app doit venir de l'App Store.

Un certificat ne peut pas signer « n'importe quelle » app : le bundle ID, les entitlements, le type de certificat et la liste d'appareils doivent être cohérents.

L'application n'utilise aucun entitlement particulier (pas de push, pas de HealthKit, pas de paiement in-app). Cela simplifie la signature, mais ne la supprime pas.

## 2. Prérequis

- Un **iPhone** compatible iOS 18 ou ultérieur.
- L'IPA téléchargé depuis GitHub Actions (`BBFactoryApp-Unsigned-IPA`).
- Un moyen de transférer le fichier sur l'iPhone (Fichiers/iCloud Drive, AirDrop depuis un Mac, serveur local, câble).
- Un **certificat de signature** au format `.p12` (avec son mot de passe) et un **profil de provisionnement** `.mobileprovision` **si votre méthode exige une signature locale**.
- Ou un service de signature qui fournit un certificat déjà configuré (voir la section 4).
- L'**UDID de l'iPhone** si vous utilisez un certificat de développement ou ad hoc.

Ne jamais publier le `.p12`, son mot de passe, le `.mobileprovision` nominatif ou les identifiants Apple dans le dépôt GitHub, une capture d'écran ou un message public.

## 3. Choisir une méthode de signature

Les grandes familles possibles :

| Méthode | Ce qu'il faut | Limites typiques |
| --- | --- | --- |
| Certificat Apple Developer payant (développement / ad hoc) | `.p12`, profil contenant l'UDID de l'iPhone | 100 appareils/an, profil à renouveler |
| Apple ID gratuit (signature personnelle) | identifiants Apple, UDID, outil compatible | 7 jours, 3 apps, renouvellement fréquent |
| Certificat d'entreprise | `.p12` + profil in-house | Réservé aux organisations éligibles, distribution encadrée |
| Service de signature tiers | abonnement + certificat fourni | Confiance, durée et révocation variables |

**Ne pas contourner les protections d'iOS.** Ne pas utiliser de certificat volé, partagé sans autorisation, ni de profil falsifié.

## 4. Importer l'IPA dans eSign

La formulation des menus varie selon la version. Le principe :

1. Transférer `BBFactoryApp-….ipa` dans l'app **Fichiers** de l'iPhone.
2. Ouvrir **eSign**.
3. Utiliser l'import de fichier (souvent « Importer », « Ouvrir un fichier » ou un bouton `+`).
4. Sélectionner l'IPA dans Fichiers.
5. Vérifier que l'app apparaît dans la liste eSign avec son nom et sa version.

Si eSign propose un navigateur intégré, il est aussi possible de télécharger l'artefact depuis GitHub, mais l'extraction du ZIP GitHub est alors nécessaire. Le plus fiable est de préparer l'IPA sur Windows puis de le transférer.

## 5. Importer les éléments de signature

1. Ouvrir la section **Certificats** / **Signature** d'eSign.
2. Importer le fichier `.p12`.
3. Saisir le mot de passe du certificat lorsque demandé (ne pas l'enregistrer dans une note publique).
4. Importer le profil `.mobileprovision` si la méthode le requiert.
5. Vérifier que le certificat est affiché comme valide et que le profil n'est pas expiré.
6. Vérifier que le bundle ID du profil correspond à `fr.vicinistudio.bbfactory` (ou à un identifiant de remplacement explicite).

Si le profil ne contient pas le bundle ID de l'app, la signature échouera ou l'installation sera refusée.

## 6. Signer

1. Sélectionner l'IPA importé.
2. Choisir **Signer** / **Signature**.
3. Sélectionner le certificat et le profil compatibles.
4. Ne pas modifier le bundle ID sauf si vous savez exactement ce que vous faites (cela peut casser les liens et les mises à jour).
5. Lancer la signature.
6. Attendre la fin sans quitter l'app.
7. Vérifier qu'un nouvel IPA signé est créé.

Selon la version, eSign peut proposer une signature « avec certificat local », « avec compte Apple », ou via un service. **La méthode disponible dans votre version doit être confirmée avant de poursuivre.**

## 7. Installer

1. Appuyer sur l'app signée dans eSign, puis **Installer**.
2. Si iOS affiche « Non installé » ou « Impossible d'installer », voir la section 9.
3. Si l'app s'installe mais refuse de se lancer, le certificat n'est probablement pas approuvé :
   - **Réglages** → **Général** → **VPN et gestion de l'appareil** ;
   - sélectionner le profil du développeur ;
   - **Faire confiance**.
4. Lancer **B&B Factory**.
5. Vérifier l'écran d'accueil, la carte, les horaires et l'ouverture d'un lien externe.

## 8. Vérifier après installation

- L'icône et le nom « B&B Factory » apparaissent.
- L'onglet **Accueil** affiche l'état ouvert/fermé.
- L'onglet **Carte** affiche les plats et les prix.
- La fiche d'un plat s'ouvre et le favori persiste après fermeture de l'app.
- **Pratique** ouvre Plans et le téléphone.
- **Actus** ouvre l'article source dans Safari.
- Le mode sombre et le mode clair restent lisibles.

## 9. Diagnostiquer

| Symptôme | Cause probable | Action |
| --- | --- | --- |
| « Impossible d'installer » | profil absent, expiré, ou UDID non inclus | vérifier le profil et l'appareil |
| « Signature invalide » | certificat/profil incohérents, IPA altéré | re-signer avec un couple compatible |
| L'app se ferme immédiatement | certificat non approuvé ou expiré | approuver dans Réglages, vérifier la date |
| « Bundle ID mismatch » | profil pour un autre identifiant | utiliser un profil `fr.vicinistudio.bbfactory` |
| Installation OK mais pas de réseau | l'app est hors ligne par conception | comportement normal ; les liens externes ouvrent Safari |
| L'app expire au bout de 7 jours | certificat Apple ID gratuit | re-signer et réinstaller |
| « App non vérifiée » | certificat non approuvé | Réglages → Général → VPN et gestion de l'appareil |

## 10. Points d'arrêt obligatoires

Les opérations suivantes nécessitent votre intervention et ne peuvent pas être automatisées depuis Windows :

- créer ou renouveler un certificat Apple Developer ;
- enregistrer l'UDID de l'iPhone ;
- télécharger un profil de provisionnement ;
- importer un certificat et son mot de passe dans eSign ;
- approuver un certificat dans iOS ;
- installer l'app sur l'iPhone ;
- décider de la méthode de signature.

Lorsque vous arrivez à l'une de ces étapes, arrêtez-vous et traitez-la manuellement. Ne publiez jamais les secrets correspondants.

## 11. Informations à confirmer

Avant de poursuivre la procédure exacte, il faut connaître :

1. La version d'eSign installée.
2. La méthode de signature utilisée (certificat local, compte Apple, service).
3. Le type de certificat (développement, ad hoc, entreprise).
4. La présence de `fr.vicinistudio.bbfactory` dans le profil.
5. L'UDID de l'iPhone, s'il est requis.

Sans ces informations, toute instruction plus précise serait une supposition.
