/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	FENETRE TYPE	( sert de model de base, n'est pas importé dans le script )	
	sans barre de titre, draggable et bouton fermer
	
	Remplacer (ctr + h): 'urba_batiment' par:  'maFenetreAMoi'.
	il y a des parties a decommenter :"--- a décommenter ---"
	Noms des variables 
	-	roll_urba_batiment :			le nom de la fenetre
	-	urba_batiment_pos :			le parametre des prefs stockant la pos de la fenetre
	-	urba_batiment_estOuvert :	le nom du parametre ouvert dans les preferences ( labib.prefs.fenetre. ' urba_batimentOuvert )
	-	str_urba_batiment:			le nom de la struicture de controle de la fenetre
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [02/10/2016] -----------------------------------------------------------------------------
	- Mise en place globale ( mise au propre du travail durant l'été)
	- Une interface souple et simple
########################################################################################################################*/

-- (


-- global urba_batiment

------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
include "$userScripts\cp - GLOBAL\UI.ms"
include "$userScripts\cp - GLOBAL\DragDialog.ms"



------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba_batiment "urba_batiment" width:282 height:321
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
-- 	local m_log
	
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba_batiment.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
-- 	ImgTag 'ui_log' "" pos:[8,43] width:66 height:18 align:#left
	
	
	edittext 'edt_elem_nom' "" pos:[116,32] width:147 height:16 align:#left
	label 'lbl_elem_nom' "Nom:" pos:[9,32] width:66 height:15 align:#left
	
	spinner 'spn_elem_largeur' "" pos:[116,149] width:146 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl_elem_largeur' "Nbr. min.:" pos:[26,148] width:65 height:15 align:#left
	
	
	
	spinner 'spn4' "" pos:[116,165] width:146 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl14' "Nbr. max.:" pos:[26,164] width:71 height:15 align:#left
	spinner 'spn5' "" pos:[49,49] width:80 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl15' "de :" pos:[10,49] width:24 height:15 align:#left
	spinner 'spn8' "" pos:[116,188] width:146 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl18' "Hauteur:" pos:[26,187] width:64 height:15 align:#left
	spinner 'spn9' "" pos:[116,243] width:146 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl19' "Hauteur:" pos:[26,242] width:55 height:15 align:#left
	label 'lbl20' "Sous-bassement:" pos:[9,271] width:90 height:15 align:#left
	label 'lbl21' "m²" pos:[132,49] width:19 height:15 align:#left
	dropDownList 'ddl1' "" pos:[116,88] width:144 height:21 align:#left
	label 'lbl22' "Toiture:" pos:[7,94] width:99 height:15 align:#left
	dropDownList 'ddl2' "" pos:[116,123] width:144 height:21 align:#left
	label 'lbl23' "Etages:" pos:[7,129] width:99 height:15 align:#left
	dropDownList 'ddl3' "" pos:[116,218] width:144 height:21 align:#left
	label 'lbl24' "RdC:" pos:[8,224] width:99 height:15 align:#left
	spinner 'spn11' "" pos:[165,50] width:80 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl25' "à :" pos:[150,50] width:14 height:15 align:#left
	label 'lbl26' "m²" pos:[248,50] width:19 height:15 align:#left
	spinner 'spn12' "" pos:[116,285] width:146 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl27' "Hauteur:" pos:[26,284] width:55 height:15 align:#left
	
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
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_urba_batiment		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Bâtiment"
		m_titre.setCouleur (color 255	255	255)
		/* 
		m_log 		= str_label 	m_ui:ui_log				m_texte:"..."
		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 200	200	200)
		 */
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	---- Drag ----
	on roll_urba_batiment lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba_batiment lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba_batiment mouseMove _pos 	do
		m_drag.suivreSouris ()
	
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
	
)

------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_urba_batiment (
	
	private
		m_estOuvert 		= false,
		------------  Membres	----------------------------------------------------------------------------------
	public
		---- pointeurs ----
		m_dialog				= roll_urba_batiment ,		---- le rollout ----
		m_dialogPos 		= [100,100],
		
		col_fenetreFond	= color 68  68 68, 	----  ----
		col_fenetreTxt		= color 230  230 230, 	----  ----
	
		--- images bouton fermer ---
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer 	= #(	openBitMap ico_btnFermer_R ,		-- Repos ----
										openBitMap ico_btnFermer_S ,		-- Survol ----
										openBitMap ico_btnFermer_P 			-- Pressé ----
										),
				
		------------  Fonctions	----------------------------------------------------------------------------------
	public
		
		fn estOuvert = m_estOuvert,
			
		---- fenetre -----
		fn ouvrir =(			
			m_estOuvert 		= true
			---- creation de la fenetre ----
			createDialog m_dialog 	bgcolor:				col_fenetreFond 	 \
											fgcolor:				col_fenetreTxt 	\
											style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
						
		),
		
		fn fermer  =(	
			m_estOuvert 		= false
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		)
		
		------------  Evenements	----------------------------------------------------------------------------------
	
)

-- 	try 
-- 		destroydialog test.m_dialog 
-- 	catch ()

-- 	urba_batiment = str_urba_batiment ()
-- 	urba_batiment.ouvrir ()

-- 	-- urba_batiment.fermer()

-- 	)






