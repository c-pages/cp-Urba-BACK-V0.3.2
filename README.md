# CP - Urba V0.3.2
Suite de plugins pour 3DSmax  |  Maxscript  | Pour réalisation de bout de villes, bâtiments, surfaces pour rues, trottoire, gazon etc.

#### Auteur :

 Christophe Pagès |  contact@c-pages.fr  |   [c-pages.fr](http://c-pages.fr)  | [git](https://github.com/c-pages/cp-Urba)

 ###### En cours de développement :

 - __Batiment__ : Objet paramétrique.

     Permet de créer des bâtiments à partir d'un shape "contour", façades et toitures.

 - __Quartier__ : Objet paramétrique, n'est pas rendu, organise des _Batiments_.
M
     Permet de construire et manipuler des quartiers entiers de batiments, en fonction de certaines contraintes (surface du shape, largeur, orientation ...), tel preset de batiment à utiliser ou pas ( 'garage',  'immeuble de bureau', 'pavillon brique normand', ...).
 - __Terrain__ : Objet paramétrique.

     Générateur de terrain utilisant d'un coté un ou plusieurs objects servant de relief, et de l'autre un ou plusieurs shapes délimitant des surfaces (ex: création d'une voire, route + trottoires). Voir si il y a moyen d'utiliser base de donnée SIG en ligne pour importer des reliefs.

 - __OSM importer__ : Utilitaire

     Permet d'importer depuis OpenStreetMap des cartes, pour utiliser les contours pour nos _Batiments_.


 ----------


 ### V0.3.2
 6 septembre 2018
 #### __Batiment__
 - [x] Correction du problème de position du batiment à l'assignation de son contour.
 - [x] Integration de nouveaux éléments pour toiture ( antenne, cheminets )
 - [x] Possiblité de faire des baies arquées( divusion a revoir).


 #### __Quartier__
 - [x] Première ébauche des concepts de base et de l'interface.
 - [x] Il commence à y avoir un debut de fonctionnement.
 - [x] Bon bah là y'a presque tout.
 - [x] Y'a meme un debut de prise en compte des reliefs.

 ### Version blender
 Passage du plugin en phython pour intégration à Blender par Dindoune Amigo Bruno ! | git | dindoun.lautre.net


Merci à Dindoune Amigo Bruno ! | [git](https://github.com/dindoun) | [dindoun.lautre.net](http://www.dindoun.lautre.net/)


----------



____________________________


### Todo:

#### __Terrain__
- [ ] Gérer un noise sur z avec une influence en lien avec la distance par rapport au bords ? ( ex:pour les terrains genre gazons) (un peu façon multiscatter).
- [ ] Gérer une distance avec une influence en lien avec la distance par rapport au bord ? (genre effet _gonflé_).
- [ ] Bien gérer les undos (pour les parametres de _Terrain_ et pour objet en reference dans _Terrain_).
- [ ] Créations des trous automatiquement quand superposition avec un _Bâtiment_. Peut être sous forme d'une option dans les _Bâtiments_ de type 'Perforer les _Terrains_.', et du coup quand le _Terrain_ annalyse ses contours il y ajoute les surfaces des _Bâtiments_ 'perforants'.
- [ ] Faire en sorte que s'ils sont en mode 'Logo' ils ne soit pas visible au rendu.
- [ ] Créer une possibilité de désactiver l'auto-update (elle serait alors seulement effectué au rendu ?).
- [ ] un bouton ON/OFF pour activer le relief ?
- [ ] Pensez à une grille mode Voronoi !?!?
- [ ] Un mode empreinte des reliefs ?!? Pour retracer les arêtes des reliefs sur le terrain et ainsi avoir, après projection, un resultat super précis niveaux decoupe du relief.
- [ ] Empecher de s'auto selectionner quand on pick un relief !
- [ ] si possible ? : quand une surface ne survol pas de relief, faire en sorte que'elle reste plus ou mons a niveau avec la plus proche sur un relief ?
- [ ] Faire en sorte de pouvoir piquer des splines type 'rectangle', 'circle' ...
- [ ] Pouvoir donner une épaisseur ? peut etre juste les bords façon extrusion ...
- [ ] quand un terrain a un ou des modifiers, alors il y a un probleme au rendu en mode Proxy, surement une reference au baseObject Terrain à faire, il ne doit plus voir que c'est un terrain ....
- [ ] /!\ PROBLEME RENDU RESEAU qui rend pas !!! /!\ a voir si c'est __Batiment__ ou __Terrain__ !!!
- [ ] faire que quand on ajoute une nouvelle spline, si la touche 'alt' est pressée on l'ajoute en #soustraction
- [ ] verifer à l'ajout de nouvelle spline qu'elles soient ok : qu'elles ne se croisent pas ni qu'elles aient des points superposer peut-etre, faudra chercher un peu les cas à problème.
- [ ] Il y a un probleme avec la creation des points avant geometrie à partir des polys (polygone.__creer_pts_pourFace ()__).


##### Importeur de reliefs
- [ ] Créer un importeur de terrain utilisant model de terrain en ligne ?
- [ ] DEM/DTM Data base. ex:https://asterweb.jpl.nasa.gov/gdem.asp


#### __Bâtiment__
* **Surface**
  - [x] Division de la surface en quadrilataires simples pour :
    * - [ ] Répartition des éléments de toitures.
	* - [ ] Création de _'sous-surface'_ pour gérer des différences de niveaux ou de toiture, etc.
	* - [ ] Trouver le chemin du faîtage par exemple (en suivant le centre des _'diagonales'_).
  - [ ] Prise en compte des splines avec shapes _'à trous'_ : pour creation de patios.
  - [ ] Alignement sur un terrain
* **Facades**
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
  - [ ] Baies : revoir la division des arcs (radial au lieu de linéaire).
* **Toitures**
  - [ ] Refaire complètement les toitures à pentes.
  - [ ] Construction à revoir pour meilleur gestion et pour meilleur controle des géométrie (ex: débords créés géométriquement et non avec l'opération extrude de Max).
  - [ ] Toitures à x pans (pente de toit pour chaque mur).
  - [ ] Intégrer les gouttières aux toitures à pans.
  - [ ] integration des éléments de toitures
    * - [x] locale technique (fonctionne, mais reste in interfacer at à bien gérer le placement)
    * - [ ] cheminet
    * - [ ] lucarnes
    * - [ ] ...
* **Construction**
  - [ ] Voir si on peut stocker les points et facase de chaque éléments pour ne mettre à jour que les points et faces nécéssaires (ex: mettre à jour seulement le toi sans refaire tout le batiment)
  - [ ] Optimiser la construction (par exemple en listant et _copiant_ les éléments répétitifs).
* **Matériaux**
  - [ ] S'occuper du menu des materiaux.
  - [ ] Gérer les ids materiaux par composants (ex. pour le mur : on pourrait avoir un id different pour les dalles).
* **Interieur**
Avec un vitrage transparant on pourrait:
  - [ ] Création de cloisin interieures (cf. division de la surface)
  - [ ] Rideaux
* **Divers**
  - [ ] Création d'outils de manipulation de _Bâtiments_ en groupe (une version simplifier du générateur de bout de ville):
    * - [ ] Appliquer un style à plusieur batiments séléctionnés.
    * - [ ] Variations de paramètre de manière aléatoire (pente de toit, variance de materiaux, décallage ouvertures,...
  - [ ] Faire en sorte que s'ils sont en mode 'Logo' ils ne soit pas visible au rendu.
  - [ ] On pourra peut être cleanner un peu l'interface entre rollouts et reste du plug.
  - [ ] Continuer le débogage ...


#### __OSM__
 - [ ] Revoir algorythme de convertion coordonées en plan.
 - [ ] a voir aprés tests avec beru : projection en Lambert 93
 - [ ] changement de centre ? WGS84 -> RGF 93 (cf: http://www.forumsig.org/showthread.php/3239-Conversion-Lat-Long-vers-Lambert-93)
 - [ ] beru :"ha sinon pour ton histoire de projection de cartes osm, tu peux projeter directement les coordonnées en wgs84 sur un plan régional sans passer par le lambert 93, en UTM30
http://spatialreference.org/ref/epsg/wgs-84-utm-zone-30n/
et si tu dois absolument passer par le rgf93 le mieux c'est de reprojeter en lambert regional cc49 ou cc50
http://spatialreference.org/ref/epsg/3949/"

_____________________________
### Historique des versions:

### V0.3.1 :
#### __Terrain__ :

- [x] Correction du problème avec la position du node qui devait être sur [0,0,0]. Maintenant le node peut etre placer n'importe ou dans la scène.
- [x] Nettoyage du manager de shape : integration du struct de _triangulation_ et _booleen_.
- [x] Création de la géométrie un peu plus propre.
- [x] Le terrain se construit maintenant même sans relief, il se place alors à la hauteur de l'objet.
- [x] Remise en forme des rollouts.
- [x] On peut maintenant déplacer l'origine de la grille
- [x] Mise en place d'une grille 'monde', donc avec l'option par objet de soit utiliser la grille 'monde', soit la grille 'local'.
- [x] Création de la géométrie ENCORE plus propre, et optimisée.
- [x] et une grosse correction de problème dans la création des suites de points des booléens.
- [x] Problème des 'intersectRay' qui ne fonctionnent qu'avec des _editable_polys_.
- [x] Problème des projections sur reliefs, les hauteurs semblent differentes en fonction de la position de l'objet, ou un truc du genre..
- [x] On verifie quand il va y avoir beaucoup de faces apres une modif de resolution de la grille. : On demande si on veut passer en mode proxy pour l'affichage et si on veut monter la limite de l'alerte pour le mode 'rendu/pasProxy'.
- [x] correction de quelques petits bugs dans la triangulation.
- [x] Grosse correction des opération boolleenes.
- [x] correction d'autres petits bugs dans la triangulation avec d'autres cas particuliers.
- [ ] ca continue a bugger ... (booleen et/ou integration ...)



#### __Général:__
- [x] Mise en place du dossier _'\commun\'_ pour y mettre les structures communes tout les modules.
- [x] Mise en place  du rollout _"A propos'_ dans le dossier _'\commun\'_, utile pour plusieurs des modules.
- [x] Enfin les operation booleene qui fonctionnent à peu pret, à voir s'il reste quelques bugs ... MERCI BRUNO !

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
