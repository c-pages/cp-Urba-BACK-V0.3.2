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
rollout roll_OSM_importer "OSM_importer" width:200 height:259
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
	ImgTag 'ui_btnFermer' "X" pos:[180,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	ImgTag 'ui_log' "" pos:[6,233] width:66 height:18 align:#left

	button 'btn_webOSM' "OSM web site" pos:[8,23] width:90 height:18 toolTip:"Acceder au site Open Street Map pour y télécharger un export '.osm'." align:#left
	button 'btn_charger' "Charger" pos:[100,23] width:92 height:18 toolTip:"Charger un fichier OSM (*.osm)." align:#left
	
	button 'btn_importer' "Importer" pos:[6,208] width:184 height:23 enabled:false toolTip:"Importer." align:#left
	groupBox 'grp_infos' "Infos" pos:[8,40] width:185 height:102 align:#left
	label 'lbl_infos' "" pos:[18,58] width:164 height:78 align:#left
	checkbox 'chk_batiments' "Batiments" pos:[10,145] width:84 height:18 align:#left		checked:true
	

	checkbox 'chk_voiries' "Voiries" pos:[10,164] width:61 height:18  align:#left		checked:true	--	enabled:false
	
	checkbox 'chk_zones' "Zones" pos:[102,146] width:61 height:18 enabled:false align:#left
	
	label 'lbl_echelle' "Echelle :" pos:[10,186] width:49 height:13 align:#left
	spinner 'spn_echelle' "" pos:[71,187] width:118 height:16 range:[0,1e+06,1] align:#left
	
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
		
		local parsingOK = m_prt.get_parsingOK ()
		
		btn_importer.enabled 	= parsingOK
		grp_infos.enabled 			= parsingOK 
		lbl_infos.enabled 			= parsingOK 
		
		chk_batiments.enabled 	= parsingOK 
		chk_voiries.enabled = parsingOK 
-- 		chk_zones.enabled = parsingOK 
		
		lbl_echelle.enabled 		= parsingOK 
		spn_echelle.enabled 		= parsingOK 		
		
		if parsingOK do (
			local info_txt = ""
			info_txt		+=  m_prt.get_nomDuFichier () + "\n"
			info_txt		+= "\n"
			info_txt		+= "Points : " + m_prt.get_nbr_points () as string + "\n"
			info_txt		+= "Batiments : " + m_prt.get_nbr_batiments () as string + "\n"
			info_txt		+= "Voiries : " + m_prt.get_nbr_voiries () as string + "\n"
			lbl_infos.text = info_txt
		)
		
	)
	
	fn recadrer _taille =(
		
		ui_btnFermer.pos.x = _taille.x - 20
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_OSM_importer		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | OSM Importer"
		m_titre.setPolice (str_policeGrande())
		m_titre.setCouleur (color 5	5	5)
		m_titre.setCouleurFond (color 200 200 200)
		
		m_log 		= str_label 	m_ui:ui_log				m_texte:"."
-- 		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 55	55	55)
		m_log.setCouleurFond (color 200 200 200)
		
		
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
	on btn_webOSM pressed  do
	(
		/* 	command = "ShellLaunch \"Chrome.exe\" @\"https://www.openstreetmap.org\""
			execute command
		 */
		rollout webbrowser_rollout "Open Street Map" width:800 height:600
			(
				edittext edt_Lieu "Lieu:" 	text:"Rouen"
				dotNetControl wb "System.Windows.forms.WebBrowser" pos:[10,22] width:780 height:570


				fn formaterTexte 	_texte =(
					substituteString 	_texte " " "%20"
				)
				
				fn openOSM_lieu	 _lieu	 = (
-- 					wb.AllowNavigation  = false
					
					local urlString		=	"https://www.openstreetmap.org/search?query="	
					local urlRecherche 	= urlString + formaterTexte  	_lieu	
					wb.url 		= dotNetObject "System.Uri" urlRecherche 
				
				)
				
				
				on edt_Lieu	entered txt 	do openOSM_lieu txt
				on webbrowser_rollout open 	do openOSM_lieu edt_Lieu.text




			)
			createdialog webbrowser_rollout		--bgcolor:[68,68,68 ]
	)
	on btn_charger pressed  do
	(
		m_log.setTexte "Importation du fichier OSM ..."
		
		local fichier = getOpenFileName 	caption:"Fichier OSM à importer"\
															types:"OSM(*.osm)|*.osm|All|*.*|" \
															historyCategory:"OSM_fichiers"
		if fichier != undefined then (
			
			m_prt.importer  fichier 
			
			m_log.setTexte "Importation reussie."
			 
		) else
			m_log.setTexte ""
		
		
		actualiser ()
	)
	on spn_echelle changed val do
(
	
	)
	
	
	on btn_importer pressed  do (
		if chk_batiments.checked do (

			m_log.setTexte "Création des batiments..."
			m_prt.creer_batiments ()
		)
		if chk_voiries.checked do (
			m_log.setTexte "Création des voiries..."
			m_prt.creer_voiries ()
		)
		m_log.setTexte ""
	
	)
)









