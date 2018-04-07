# CP - Urba V0.3.1
Suite de plugin pour 3DSmax - en Maxscript. Pour réalisation de bout de villes, bâtiments, surfaces pour rues, trottoire, gazon etc.

en cours de développement:

- __Batiment__ : Objet paramétrique.
- __Terrain__ : Objet paramétrique.
- __OSM importer__ : Utilitaire

à développer:
- __Ville__ ou __quartier__ : Utilitaire (ou objet ?) permettant de générer automatiquement des quartiers entiers de batiments, en fonction de certaines contraintes (surface du shape, largeur, orientation ...), tel preset de batiment à utiliser ou pas ( 'garage',  'immeuble de bureau', 'pavillon brique normand', ...).



----------


### V0.3.1 :
___Terrain___ : Version basique mais fonctionnelle.
- [x] Correction du problème avec la position du node qui devait être sur [0,0,0]. Maintenant le node peut etre placer n'importe ou dans la scène.
- [x] Nettoyage du manager de shape : integration du struct de _triangulation_ et _booleen_.
- [x] Création de la géométrie un peu plus propre.
- [x] Création de la géométrie ENCORE plus propre, et optimisée.
- [x] Le terrain se construit maintenant même sans relief, il se place alors à la hauteur de l'objet.
- [x] On peut mintenant déplacer l'origine de la grille
- [x] Mise en place d'une grille 'monde', donc avec l'option par objet de soit utiliser la grille 'monde', soit la grille 'local'.
- [x] Remise en forme des rollouts.

__Général:__
- [x] Mise en place du dossier _'\commun\'_ pour y mettre les structures communes tout les modules.
- [x] Mise en place  du rollout _"A propos'_ dans le dossier _'\commun\'_, utile pour plusieurs des modules.


____________________________


## __Todo__ :
#### **Terrain** :
- [ ] Gérer un noise sur z avec une influence en lien avec la distance par rapport au bords ? ( ex:pour les terrains genre gazons) (un peu façon multiscatter).
- [ ] Gérer une distance avec une influence en lien avec la distance par rapport au bord ? (genre effet _gonflé_).
- [ ] Gérer les contours qui se croisent en addition booléènne ? (un mode soustraction implique un ordre : A - B != B - A mais A + B = B + A !).
- [ ] Faire en sorte que les undos fonctionnent.
- [ ] option pour créations des trous automatiquement quand superposition avec un _Bâtiment_.

#### **Bâtiment** :
* **Surface** :
  - [x] Division de la surface en quadrilataires simples pour :
    * - [ ] Répartition des éléments de toitures.
	* - [ ] Création de _'sous-surface'_ pour gérer des différences de niveaux ou de toiture, etc.
	* - [ ] Trouver le chemin du faîtage par exemple (en suivant le centre des _'diagonales'_).
  - [ ] Prise en compte des splines avec shapes _'à trous'_ : pour creation de patios.
  - [ ] Alignement sur un terrain
* **Facades** :
  - [ ] Extrusions de la dalle pour débords et du mur.
  - [ ] Gestion des angles pour continuité des balcons ou des débords.
  - [x] Gestion du hasard pour ouverture Fenêtres.
  - [ ] Ajouter interface aux fenetre, porte et volet pour choisir entre : _ouvert_, _fermer_ et _hasard_.
  - [x] Intégration des Volets roulants.
  - [x] Gestion du hasard pour ouverture Volets.
  - [ ] creer les autres types de volets (battant, store banne ?)
  - [ ] creer les autres types de gardes-corps ( Verre, ... ).
  - [ ] Créer un _copier-coller/instancier_ avec le clique droit pour les composants de façade.
  - [ ] Passer en multilistBox la sequence de composant de façade pour manipuler plusieurs composants à la fois.
  - [ ] A voir: création de facade-rideau.
  - [ ] Création de poteaux (rond ou rectangle) avec facade en retrait (ex: façon galerie couverte en RdC (cf Marseille pouillon).
  - [ ] Peut être intégrer un composant 'Modele' permettant à l'utilisateur d'intégrer n'importe quel objet à lui à la façade.
  - [ ] Dans le _'mode édition'_: intégrer une prévisualisation des composant dans le viewport (ajouter dans chaque fichiers composant une fonction VP).
* **Toitures** :
  - [ ] Refaire complètement les toitures à pentes.
  - [ ] Construction à revoir pour meilleur gestion et pour meilleur controle des géométrie (ex: débords créés géométriquement et non avec l'opération extrude de Max).
  - [ ] Toitures à x pans (pente de toit pour chaque mur).
  - [ ] Intégrer les gouttières aux toitures à pans.
  - [ ] integration des éléments de toitures
    * - [x] locale technique (fonctionne, mais reste in interfacer at à bien gérer le placement)
    * - [ ] cheminet
    * - [ ] lucarnes
    * - [ ] ...
* **Construction** :
  - [ ] Voir si on peut stocker les points et facase de chaque éléments pour ne mettre à jour que les points et faces nécéssaires (ex: mettre à jour seulement le toi sans refaire tout le batiment)
  - [ ] Optimiser la construction (par exemple en listant et _copiant_ les éléments répétitifs).
* **Matériaux** :
  - [ ] S'occuper du menu des materiaux.
  - [ ] Gérer les ids materiaux par composants (ex. pour le mur : on pourrait avoir un id different pour les dalles).
* **Interieur** :
Avec un vitrage transparant on pourrait:
  - [ ] Création de cloisin interieures (cf. division de la surface)
  - [ ] Rideaux
* **Divers** :
  - [ ] Création d'outils de manipulation de batiment en groupe (une version simplifier du générateur de bout de ville):
    * - [ ] Appliquer un style à plusieur batiments séléctionnés.
    * - [ ] Variations de paramètre de manière aléatoire (pente de toit, variance de materiaux, décallage ouvertures,...



* On pourra peut être cleanner un peu l'interface entre rollouts et reste du plug.
* Continuer le débogage.


_____________________________
## __Anciennes versions__
### V0.3.0 :
- [x] ___Terrain___ : Version basique mais fonctionnelle.
    - [x] Inverser le poly resultat, c'est à dire utiliser les contours pour creuser le cadre former par le ou les reliefs. pour pouvoir avec la meme spline creer la route ou l'inverse c'est a dire les trottoires.
    - [x] prendre en compte les trous dans les contours (boolean) (tracer une seule face suivant les contours et reliant chaque trou)

### V0.2.2 :
- [x] Mise en place de _Terrain_ : Un objet qui utilise sa liste de splines pour créer une 'grille', d'une dimension gérable, qu'il projete sur les reliefs de sa liste.

### V0.2.0 :
- [x] Simplification des éléments du batiment, un systeme de constructeur va chercher les fichiers des éléments pour remplir le plug  -> souplesse accrue.
- [x] Refonte de l'interface, on passe maintenant dans un _'mode édition'_ pour modifier le bâtiment.
- [x] Système d'affichage d'information dans le viewport dans le _'mode édition'_ pour un retour rapide des modifs du batiment.
- [x] Gestion d'un mode proxy (un écouteur créer le modéle complet avant le rendu et repasse en proxy aprés).
- [x] Un groupe peut être créé dans une séquence de façade pour répétition d'un 'motif'.
- [x] Les composants peuvent être instanciés.
- [x] Corrections toitures à 2 pans.
____________________________
