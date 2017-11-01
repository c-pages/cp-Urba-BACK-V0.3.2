/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################


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
----------------------------------------------------------------------------
-- include "$userScripts\cp - GLOBAL\UI.ms"
-- include "$userScripts\cp - GLOBAL\DragDialog.ms"



------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba_toitures "urba_toitures" width:279 height:200
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
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba_toitures.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	
	
	
	
	
	button 'btn_supprimer_toiture' "-" pos:[244,22] width:21 height:21 align:#left
	button 'btn_ajouter_toiture' "+" pos:[224,22] width:21 height:21 align:#left
	dropdownList 'ddl_toitures' "" pos:[9,22] width:216 height:21 align:#left
	
	edittext 'edt_nom_toiture' "" pos:[118,46] width:147 height:16 align:#left
	label 'lbl_nom_toiture' "Nom:" pos:[12,46] width:52 height:15 align:#left

	
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
		
		--- liste des toitures -----
		local listTmp =#()
		for toit in m_prt.presets.get () do
			append listTmp toit.nom
		ddl_toitures.items = listTmp
		
		
		
		
		local enabled = true
		if m_prt.toitureCourante == undefined then (
			enabled = false
			edt_nom_toiture.text = ""
		) else (
			enabled = true
			edt_nom_toiture.text = m_prt.toitureCourante.nom
		)
		
		btn_supprimer_toiture.enabled 	= enabled
		lbl_nom_toiture.enabled 			= enabled
		edt_nom_toiture.enabled 			= enabled
		
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_urba_toitures		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Toitures"
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
	
	
	
	on ddl_toitures 				selected  	val 	do 	m_prt.selectionner_id 	val
	
	on btn_ajouter_toiture 		pressed  			do 	m_prt.ajouter_toiture ()	
	on btn_supprimer_toiture 	pressed  			do 	m_prt.supprimer_toiture 	ddl_toitures.selection
	
	on edt_nom_toiture 			entered  	txt 	do 	m_prt.changerNom		txt
	
	
	
	
	
	
	
	
	---- Drag ----
	on roll_urba_toitures lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba_toitures lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba_toitures mouseMove _pos 	do
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
struct str_urba_toitures (
	
	----------------------------------------------------------------------------------------------------------
	------------  MEMBRES	------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	public
		---- pointeurs ----
		m_dialog				= roll_urba_toitures ,		---- le rollout ----
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
		
		m_estOuvert = false,
	
	------------	STRUCTURES DIVERSES 		------------------------
	public
		---- le struct principale parent ----
		m_urba,
		
		---- le manager de presets ----
		presets = str_presetsMGR 	preset_type:	str_urba_preset_toiture	\
												fichier:			m_urba.fichier_presets	\
												prefixUnique:	"Toit",
		 
		---- la batiment actuelement selectionnée ----
		toitureCourante,
		
		
		
		
	
	----------------------------------------------------------------------------------------------------------
	------------  Fonctions	------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	public
		
		------------	UI		------------------------------------------------------------------------------------------
		---- fenetre -----
		fn estOuvert 	= m_estOuvert,
		fn actualiser 	= if m_estOuvert do m_dialog.actualiser (),
		
		fn selectionner 	_preset 	=(
			local id_preset = presets.trouver_ID 	_preset
			toitureCourante = _preset
			m_dialog.ddl_toitures.selection = id_preset
			actualiser ()
		),
		fn selectionner_id 	_id =(
			if _id >0 do (
				toitureCourante = presets.get_preset		_id
				m_dialog.ddl_toitures.selection = _id
			)
			actualiser ()
		),
		
		
		
		fn ouvrir pos: =(			
			m_estOuvert 		= true
			if pos != unsupplied do	m_dialogPos = pos
			---- creation de la fenetre ----
			createDialog m_dialog 	fgcolor:				col_fenetreTxt 	\
											style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
-- 			bgcolor:				col_fenetreFond 	 \
-- 											
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
			
			m_urba.actualiser ()
		),
		
		fn changerNom 	_nvNom =(
			toitureCourante.nom = _nvNom
			presets.sauvegarder		toitureCourante
			actualiser ()
			m_urba.batiments.actualiser ()
		),
		
		
		
		
		
		
		
		fn ajouter_toiture =(
			local nvPreset = presets.creer_preset ()
			toitureCourante = nvPreset
			m_urba.batiments.actualiser ()
			actualiser ()
		),
		fn supprimer_toiture 	_id	=(
			local presetAVirer = presets.get_preset		_id
			
			--- on check si il y a des batiments possedant cette toiture
			local batsAyantCetteToiture = #()
			for bat in m_urba.batiments.presets.get () do
				if bat.idUnique == presetAVirer.idUnique	do 
					append batsAyantCetteToiture 	bat
			
			if querybox ( "Supprimer définitivement: " + presetAVirer.nom + " ?\n" +  batsAyantCetteToiture.count as string + " bâtiment(s) ont cette toiture." ) do (
				
				presets.supprimer _id
				
				for bat in batsAyantCetteToiture do
					bat.toiture	 =""
				
	-- 			local _idUnique = villeCourante.batiments [_id]
-- 				deleteItem	villeCourante.batiments 	_id
-- 				deleteItem	villeCourante.probabilites 	_id
					
				
				selectionner_id 	( m_dialog.ddl_bats.selection - 1 )
			)
			actualiser ()
			m_urba.batiments.actualiser ()
			m_urba.actualiser ()
		)
	
	------------  Evenements	----------------------------------------------------------------------------------
	
)




