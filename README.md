# cp-Urba - Batiment V0.2.0
Plugin 3DSmax - Bâtiments paramétriques.

### Réalisations pour la version V0.2.0 :
- [x] Simplification des éléments du batiment, un systeme de constructeur va chercher les fichiers des éléments pour remplir le plug  -> souplesse accrue.
- [x] Refonte de l'interface, on passe maintenant dans un _'mode édition'_ pour modifier le bâtiment.
- [x] Système d'affichage d'information dans le viewport dans le _'mode édition'_ pour un retour rapide des modifs du batiment.
- [x] Gestion d'un mode proxy (un écouteur créer le modéle complet avant le rendu et repasse en proxy aprés).
- [x] Un groupe peut être créé dans une séquence de façade pour répétition d'un 'motif'.
- [x] Les composants peuvent être instanciés.

### Todo :
* **Surface** :
  - [ ] Division de la surface en quadrilataires simples pour : 
    * - [ ] Répartition des éléments de toitures.
	* - [ ] Création de _'sous-surface'_ pour gérer des différences de niveaux ou de toiture, etc.
	* - [ ] Trouver le chemin du faîtage par exemple (en suivant le centre des _'diagonales'_).
  - [ ] Prise en compte des splines avec shapes _'à trous'_ : pour creation de patios.
* **Facades** :
  - [ ] Extrusions de la dalle pour débords et du mur.
  - [ ] Gestion des angles pour continuité des balcons ou des débords.
  - [ ] Intégration des Volets.
  - [ ] Gestion du hasard pour ouverture Volets et Fenêtres.
  - [ ] Autres gardes-corps ( Verre, ... ).
  - [ ] Créer un copier-coller/instancier avec le clique droit pour les composants de façade.
  - [ ] Passer en multilistBox la sequence de composant de façade pour manipuler plusieurs composants à la fois.
  - [ ] A voir: création de facade-rideau.
  - [ ] Création de poteaux (rond ou rectangle) avec facade en retrait (ex: façon galerie couverte en RdC (cf Marseille pouillon).
  - [ ] Peut être intégrer un composant 'Modele' permettant à l'utilisateur d'intégrer n'importe quel objet à lui à la façade.
* **Toitures** :
  - [ ] Refaire complètement les toitures à pentes.
  - [ ] Construction à revoir pour meilleur gestion et pour meilleur controle des géométrie (ex: débords créés géométriquement et non avec l'opération extrude de Max).
  - [ ] Toitures à x pans (pente de toit pour chaque mur).
  - [ ] Intégrer les gouttières aux toitures à pans.
  - [ ] integration des éléments de toitures
    * - [x] locale technique
    * - [ ] cheminet
    * - [ ] lucarnes
    * - [ ] ...
* **Construction** :
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
