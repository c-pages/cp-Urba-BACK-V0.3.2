/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	FENETRE TYPE	( sert de model de base, n'est pas importé dans le script )	
	sans barre de titre, draggable et bouton fermer
	
	Remplacer (ctr + h): 'OSM_importer' par:  'maFenetreAMoi'.
	il y a des parties a decommenter :"--- a décommenter ---"
	Noms des variables 
	-	roll_OSM_importer :			le nom de la fenetre
	-	OSM_importer_pos :			le parametre des prefs stockant la pos de la fenetre
	-	OSM_importer_estOuvert :	le nom du parametre ouvert dans les preferences ( labib.prefs.fenetre. ' OSM_importerOuvert )
	-	str_OSM_importer:			le nom de la struicture de controle de la fenetre
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [02/10/2016] -----------------------------------------------------------------------------
	- Mise en place globale ( mise au propre du travail durant l'été)
	- Une interface souple et simple
########################################################################################################################*/






------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
include "$userScripts\cp - GLOBAL\UI.ms"
include "$userScripts\cp - GLOBAL\DragDialog.ms"



------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_OSM_importer "OSM_importer" width:200 height:65
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
	local m_log
	
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_OSM_importer.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	ImgTag 'ui_log' "" pos:[8,43] width:66 height:18 align:#left

	button 'btn_charger' "Importer" pos:[8,23] width:185 height:18 align:#left
	
	------------  Fonctions	----------------------------------------------------------------------------------
	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	
	fn actualiser = (
		
	)
	
	fn recadrer _taille =(
		
		ui_btnFermer.pos.x = _taille.x - 20
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_OSM_importer		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | OSM Importer"
		m_titre.setCouleur (color 255	255	255)
		
		m_log 		= str_label 	m_ui:ui_log				m_texte:"..."
		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 200	200	200)
		
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	---- Drag ----
	on roll_OSM_importer lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_OSM_importer lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_OSM_importer mouseMove _pos 	do
		m_drag.suivreSouris ()
	
-- 	--- recadrage ----
-- 	on roll_OSM_importer resized  taille do
-- 		recadrer (taille)
	
	---- Fermer ----
	on ui_btnFermer mouseover do
		etatBtnFermer #Survol
	on ui_btnFermer mouseout do
		etatBtnFermer #Repos
	on ui_btnFermer mouseDown do
		etatBtnFermer #Press
	on ui_btnFermer mouseUp do
		etatBtnFermer #Repos	
	on ui_btnFermer click do
		m_prt.fermer ()
	
	--- interface	---------
	on btn_charger pressed  do
	(
		local fichier = getOpenFileName 	caption:"Fichier OSM à importer"\
															types:"OSM(*.osm)|*.osm|All|*.*|" \
															historyCategory:"OSM_fichiers"
		if fichier != undefined then (
			m_log.setTexte "Importation du fichier OSM"
			
			m_prt.importer  fichier 
			
			m_log.setTexte ""
			
		) else
			m_log.setTexte ""
			
	)
)









