/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
########################################################################################################################*/

-- (




------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
-- include "$userScripts\cp - GLOBAL\UI.ms"
-- include "$userScripts\cp - GLOBAL\DragDialog.ms"

-- include "$userScripts\cp-Urba\Urba - Structures - 2.ms"
-- include "$userScripts\cp-Urba\Urba - Ville - edition.ms"

------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba_villes "urba_villes" width:279 height:290
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
	ImgTag 'ui_btnFermer' "X" pos:[259,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
-- 	ImgTag 'ui_log' "" pos:[8,43] width:66 height:18 align:#left

	edittext 'edt_ville_nom' "" pos:[118,47] width:147 height:16 align:#left
	label 'lbl_ville_nom' "Nom:" pos:[11,47] width:26 height:15 align:#left
	
	
	listbox 'lbx_bats' "" pos:[10,81] width:253 height:10 align:#left
	
	
	
	button 'btn_retirer_bat' "-" pos:[249,65] width:16 height:16 align:#left
	button 'btn_ajouter_bat' "+" pos:[234,65] width:16 height:16 align:#left

	label 'lbl_batiments' "Bâtiments:" pos:[11,66] width:52 height:14 align:#left
	spinner 'spn_proba' "" pos:[118,218] width:145 height:16 align:#left

	
	label 'lbl_proba' "Probabilité:" pos:[11,218] width:55 height:14 align:#left


	button 'btn_supprimer_ville' "-" pos:[244,22] width:21 height:21 align:#left
	button 'btn_ajouter_ville' "+" pos:[224,22] width:21 height:21 align:#left
	dropdownList 'ddl_villes' "" pos:[9,22] width:216 height:21 align:#left

	spinner 'spn_surf_min' "" pos:[118,233] width:128 height:16 range:[0,1e+13,0] scale:1 align:#left
	
	label 'lbl_surf_min' "Surface min.:" pos:[11,233] width:68 height:15 align:#left
	label 'lbl21' "m²" pos:[249,234] width:19 height:15 align:#left
	
	spinner 'spn_surf_max' "" pos:[118,248] width:128 height:16 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl_surf_max' "Surface max.:" pos:[11,247] width:68 height:15 align:#left
	label 'lbl26' "m²" pos:[249,248] width:19 height:15 align:#left
	------------  FONCTIONS	----------------------------------------------------------------------------------
	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	fn actualiser = (
		
		--- les villes----------
		local listTmp =#()
		for preset in m_prt.presets.get () do
			append listTmp preset.nom
		ddl_villes.items = listTmp
		
		
		
		local enable = true
		if m_prt.villeCourante != undefined then (
			edt_ville_nom.text = m_prt.villeCourante.nom
		) else (
			enable = false
		)	
		
		edt_ville_nom.enabled 			= enable
		lbl_ville_nom.enabled 			= enable
		lbl_proba.enabled 				= enable
		spn_proba.enabled 				= enable
		lbl_batiments.enabled 			= enable
		btn_retirer_bat.enabled 		= enable
		btn_ajouter_bat.enabled 		= enable
		btn_supprimer_ville.enabled 	= enable
		lbx_bats.enabled 					= enable
		
		spn_surf_min.enabled 			= enable
		spn_surf_max.enabled 			= enable
		
		lbl21.enabled 						= enable
		lbl26.enabled 						= enable
		lbl_surf_min.enabled 			= enable
		lbl_surf_max.enabled 			= enable
		
		
		
		---- les batiments --------
		if enable do (
			lbx_bats.items = m_prt.get_batimentsVilleCourante ()
			
			if lbx_bats.selection != 0 then (
				
				spn_proba.value 		= m_prt.villeCourante.probabilites[ lbx_bats.selection ]
				spn_surf_min.value 	= m_prt.villeCourante.surfaces_min[ lbx_bats.selection ]
				spn_surf_max.value 	= m_prt.villeCourante.surfaces_max[ lbx_bats.selection ]

			) else (				
				lbl_proba.enabled = false
				spn_proba.enabled = false
				
				spn_surf_min.enabled 			= false
				spn_surf_max.enabled 			= false
		lbl21.enabled 						= false
		lbl26.enabled 						= false
		lbl_surf_min.enabled 			= false
		lbl_surf_max.enabled 			= false
			)
		)
		
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_urba_villes		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Villes"
		m_titre.setCouleur (color 255	255	255)
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
	)
	
	
	fn ouvrir_menuBatiments =(
		
		
		local txt_corps 	= "rcMenu  rc_batiments (\n"
		
		--- liste des item du menu -----------------
		local listeBats 	= m_prt.get_presetsBatiment ()
		for bat in listeBats do 	txt_corps += "menuItem " + bat.idUnique	+ " \"" + bat.nom +"\"\n"
		txt_corps += "separator sep01\n"
		txt_corps += "menuItem " + "creerBat " + " \"Créer bâtiment\"\n"
		
		--- les evenements -------
		id = 0
		for bat in listeBats do txt_corps += "on " + bat.idUnique + " picked do urba.villes.ajouter_batimentID " + (id +=1) as string + "\n"			
		txt_corps += "on creerBat picked do ( urba.batiments.creer_nouveau (); urba.villes.ajouter_batimentID	(urba.batiments.presets.get()).count )\n"	
		
		txt_corps += ")"
		
		--- on creer le menu -----
		execute   txt_corps 
		popUpMenu	rc_batiments
		
	)
	
	------------  EVENEMENTS	----------------------------------------------------------------------------------
	---- les villes ----
	on btn_ajouter_ville 	pressed  				do 	m_prt.creer_ville ()
	on btn_supprimer_ville 	pressed  				do 	m_prt.supprimer_ville 	ddl_villes.selection
	on edt_ville_nom 		entered  		txt 	do 	m_prt.changerNom		txt
	on ddl_villes 				selected  		val 	do 	m_prt.selectionner_id 	val
	
	---- les batiments ----
	on btn_ajouter_bat 		pressed  				do 	ouvrir_menuBatiments ()	
	on btn_retirer_bat	 	pressed  				do 	m_prt.retirer_batimentID 	lbx_bats.selection
	on lbx_bats				selected  		_val 	do 	actualiser ()
	on lbx_bats				doubleClicked  _val 	do 	m_prt.ouvrir_batiment 		_val
	on spn_proba 				changed  		_val 	do 	m_prt.changerProbabilite  	lbx_bats.selection		_val
	on spn_surf_min 			changed 	val		do 	m_prt.changer_surfMin 		lbx_bats.selection	val
	on spn_surf_max 		changed 	val		do 	m_prt.changer_surfMax		lbx_bats.selection	val
	
	---- Rollout ----
	on roll_urba_villes 		lbuttondown 	_pos 	do	m_drag.demarrer ()
	on roll_urba_villes 		lbuttonup 		_pos 	do	m_drag.arreter ()
	on roll_urba_villes 		mouseMove 	_pos 	do	m_drag.suivreSouris ()
	
	---- Fermer ----
	on ui_btnFermer 			mouseover 				do	etatBtnFermer #Survol
	on ui_btnFermer 			mouseout 				do	etatBtnFermer #Repos
	on ui_btnFermer 			mouseDown 			do	etatBtnFermer #Press
	on ui_btnFermer 			mouseUp 				do	etatBtnFermer #Repos	
	on ui_btnFermer 			click 						do	m_prt.fermer ()
	
)

------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_urba_villes (
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="Urba | Ville",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	----------------------------------------------------------------------------------------------------------
	------------  Membres	----------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	public
		------------	UI		------------------------------------------------------------------------------------------
		m_estOuvert 			= false,
	
		---- pointeurs ----
		m_dialog				= roll_urba_villes ,		---- le rollout ----
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
	private
		---- Valeurs par défaut ----
		defaut_proba 			= 100.,
		defaut_surfaceMin 	= 0.,
		defaut_surfaceMax 	= 50000.,
									
									
									
									
	public
		------------	STRUCTURES DIVERSES 		------------------------------------------------------------------------------------------
		---- le struct principale parent ----
		m_urba,
	
		---- le manager de presets ----
		presets = str_presetsMGR 	preset_type:	str_urba_preset_ville	\
												fichier:			m_urba.fichier_presets	\
												prefixUnique:	"Ville",
		
		---- la ville actuelement selectionnée ----
		villeCourante,
		
		
		
	----------------------------------------------------------------------------------------------------------
	------------  Fonctions	------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------
	
									
	public
	
		------------	UI		------------------------------------------------------------------------------------------
		fn estOuvert 		= m_estOuvert,
		fn actualiser 	= if m_estOuvert do m_dialog.actualiser (),
		
		---- fenetre -----
		fn ouvrir pos: =(			
			m_estOuvert 		= true
			if pos != unsupplied do	m_dialogPos = pos
-- 			
-- 			m_dialogPos = GetDialogPos m_urba.m_dialog 
-- 			m_dialogPos += [ (GetDialogSize m_urba.m_dialog).x ,0]
-- 			m_dialogPos += [ 0, (GetDialogSize m_urba.m_dialog).y ]
			
			---- creation de la fenetre ----
			createDialog m_dialog 	fgcolor:				col_fenetreTxt 		\
											style:				#(#style_resizing) 	\
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
-- 			bgcolor:				col_fenetreFond 		\
-- 											
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser 	()
			m_dialog.actualiser  	()
			
		),
		
		fn fermer  =(	
			m_estOuvert 		= false
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			m_urba.actualiser ()
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		),
		
		
		
		
		
		
		fn ajouter_batimentID 	_id =(
			debug "ajouter_batimentID" var:_id
			
			local batCible = m_urba.batiments.presets.get_preset  _id
			append 	villeCourante.batiments			batCible.idUnique
			append 	villeCourante.probabilites		defaut_proba
			append 	villeCourante.surfaces_min		defaut_surfaceMin
			append 	villeCourante.surfaces_max	defaut_surfaceMax
			
			presets.sauvegarder		villeCourante
			actualiser ()
		),
		fn retirer_batimentID 	_id =(
			debug "retirer_batimentID" var:_id
		
-- 			local _idUnique = villeCourante.batiments [_id]
			deleteItem	villeCourante.batiments 		_id
			deleteItem	villeCourante.probabilites 		_id
			deleteItem	villeCourante.surfaces_min 	_id
			deleteItem	villeCourante.surfaces_max 	_id
			
			presets.sauvegarder		villeCourante			
			actualiser ()
		),
		fn a_batiment	_ville		_idUniqueBat	=(
			local result = false
			if findItem	_ville.batiments	_idUniqueBat >0 do
				result = true
			result
		),
		
		
		
		
		
		fn ouvrir_batiment 	_id =(
			m_urba.batiments.ouvrir 	pos: ( GetDialogPos m_dialog +  [(GetDialogSize m_dialog).x,0] )
			local _idUnique = villeCourante.batiments [_id]
			local bat 		= ( m_urba.batiments.presets.get_parIdUnique  _idUnique )
			
			
			m_urba.batiments.selectionner	bat
			debug "_idUnique" var:_idUnique
			debug "bat" var:bat
			actualiser ()
		),
		
		fn get_presetsBatiment =(
			m_urba.batiments.presets.get ()
		),
		
		------------ Villes ------------------------------------------------------------------------------------------
		fn get_batimentsVilleCourante = (
			local listeTmp = #()
			for id_bat in villeCourante.batiments do
				append listeTmp  ( m_urba.batiments.presets.get_parIdUnique  id_bat ).nom
			listeTmp
		),
			
		fn selectionner 	_preset 	=(
			local id_preset = presets.trouver_ID 	_preset
			villeCourante = _preset
			m_dialog.ddl_villes.selection = id_preset
			actualiser ()
		),
		fn selectionner_id 	_id =(
			if _id >0 do (
				villeCourante = presets.get_preset		_id
				m_dialog.ddl_villes.selection = _id
			)
			actualiser ()
		),
		
		
		
		fn supprimer_ville 	_id	 =(
			local presetAVirer = presets.get_preset		_id
			if querybox ( "Supprimer définitivement: " + presetAVirer.nom + " ?" ) do (
				presets.supprimer _id
				m_dialog.ddl_villes.selection = 0
			)
			actualiser ()
			m_urba.actualiser ()
		),
		fn creer_ville =(
			local nvPreset = presets.creer_preset ()
			selectionner 	nvPreset
			actualiser ()
			m_urba.actualiser ()
		),
		
		
		
		
		
		fn changerNom 	_nvNom =(
			villeCourante.nom = _nvNom
			presets.sauvegarder		villeCourante
			actualiser ()
			m_urba.actualiser ()
		),
		fn changerProbabilite 	_idBat	_nvlleProba	 =(
			villeCourante.probabilites[_idBat] = _nvlleProba
			presets.sauvegarder		villeCourante
			actualiser ()
			m_urba.actualiser ()
		),
		fn changer_surfMin 	_idBat	_val	 =(
			villeCourante.surfaces_min[_idBat] = _val
			presets.sauvegarder		villeCourante
			actualiser ()
			m_urba.actualiser ()
		),
		fn changer_surfMax 	_idBat	_val	 =(
			villeCourante.surfaces_max[_idBat] = _val
			presets.sauvegarder		villeCourante
			actualiser ()
			m_urba.actualiser ()
		)
		
		

)



