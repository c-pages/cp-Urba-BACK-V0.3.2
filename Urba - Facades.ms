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


-- global urba_moduleFacade


------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
-- include "$userScripts\cp - GLOBAL\UI.ms"
-- include "$userScripts\cp - GLOBAL\DragDialog.ms"

-- include "$userScripts\cp-Urba\Urba - Structures - 2.ms"


------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba_facades "Urba | Facades" width:279 height:450
(
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
	local m_dbgPrefix ="Urba | Rollout : Facades "
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)
	
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
	
	local uis_facade, uis_element
	
	
	----	liste des types pour affichage dans sequence
	local  affichage_types =	#(		"<->   ", 					-----	1: extensible
												"|---|   ", 			-----	2: largeur fixe
												"[ # ]   Modèle",		-----	3: modele 3D
												"{----   " ,						-----	4: debut de groupe
												"------------------------}   " )						-----	5: fin de groupe
	
	local marquageGroupe = "    | "

	
	fn poly_filt 		obj = superclassof obj == GeometryClass
	
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba_facades.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left

	button 'btn_supprimer_facade' "-" pos:[244,22] width:21 height:21 align:#left
	button 'btn_ajouter_facade' "+" pos:[224,22] width:21 height:21 align:#left
	dropdownList 'ddl_facades' "" pos:[9,22] width:216 height:21 align:#left
	
	edittext 'edt_nom_facade' "" pos:[118,46] width:147 height:16 align:#left
	label 'lbl_nom_facade' "Nom:" pos:[12,46] width:52 height:15 align:#left
	
	
	label 'lbl_sequence' "Séquence:" pos:[11,66] width:52 height:14 align:#left
	listbox 'lbx_sequence' "" pos:[11,81] width:239 height:20 align:#left

	label 'lbl_model' "Modèle:" pos:[21,396] width:52 height:15 align:#left
	spinner 'spn_elem_largeur' "" pos:[82,364] width:172 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_elem_largeur' "Largeur:" pos:[21,363] width:52 height:15 align:#left
	button 'btn_supprimer_element' "-" pos:[235,65] width:16 height:16 align:#left
	GroupBox 'grp_prop' "Propriétés de l'élément :" pos:[11,348] width:253 height:81 align:#left
	button 'btn_descendre' "v" pos:[250,95] width:16 height:16 align:#left
	button 'btn_monter' "^" pos:[250,80] width:16 height:16 align:#left
	
	
	dropdownList 'ddl_model' "" pos:[84,394] width:131 height:21 align:#left
	
	button 'btn_supprimer_model' "-" pos:[234,394] width:21 height:21 align:#left
	pickbutton 'btn_creer_model' "+" pos:[214,394] width:21 height:21 align:#left	filter:poly_filt
	button 'btn_ajouter_extensible' "E" pos:[176,65] width:16 height:16 toolTip:"Ajouter partie extensible" align:#left
	button 'btn_ajouter_fixe' "F" pos:[191,65] width:16 height:16 toolTip:"Ajouter partie fixe" align:#left
	button 'btn_ajouter_model' "M" pos:[206,65] width:16 height:16 toolTip:"Ajouter Modèle 3D" align:#left
	button 'btn_ajouter_groupe' "G" pos:[221,65] width:16 height:16 toolTip:"Ajouter un groupe" align:#left
	
	spinner 'spn_repet' "" pos:[82,379] width:172 height:16 range:[1,1e+13,1] type:#integer scale:1 align:#left
	label 'lbl_repet' "Répétitions:" pos:[21,378] width:60 height:15 align:#left
	
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
		
		debug "actualiser ()"
		
		--- les presets facades ----------
		local listTmp =#()
		local presetsFacades = m_prt.presets.get ()
		for preset in presetsFacades do
			append listTmp preset.nom
		ddl_facades.items = listTmp
		
		
		
-- 		if presetsModeles.count > 0 do
		
		
		local prop_enabled = true
		if presetsFacades.count ==0 do prop_enabled = false
		
		for ui in uis_facade do
			ui.enabled = prop_enabled
		
		
		
		if m_prt.facadeCourante == undefined then (
			btn_supprimer_facade.enabled = false
			edt_nom_facade.text = ""
		) else (
			
-- 			if m_prt.elementCourant !=undefined do
				
			
			btn_supprimer_facade.enabled = true
			edt_nom_facade.text = m_prt.facadeCourante.nom
			
			--- la sequence d'elements ----------
			local listTmp =#()
			local presetsElements 	= m_prt.facadeCourante.elements
			
			local tabu =""
			for id_elem in presetsElements do (
				
				local preset 		= 	m_prt.elementsDeFacade.get_parIdUnique	id_elem
				local nomItem 	=	affichage_types[preset.type]
				 
				case preset.type of (
					1:	nomItem = tabu + nomItem
					2:	nomItem = tabu + nomItem + preset.largeur as string + " cm."
					3:	(
						nomItem = tabu + nomItem + " : " 
						if preset.model != "" then  (
							local modeleTmp = m_prt.modeles.get_parIdUnique 	preset.model 
							nomItem += modeleTmp.nom 
						)
					)
					4: ( 
						
						nomItem = tabu + nomItem --	+ preset.repetition as string + "x"
						if preset.repetition == 0 then 
							nomItem	+= "+Inf"
						else
							nomItem	+= preset.repetition as string + "x"
						nomItem	+= "   -----------"
						tabu += marquageGroupe
					)
					5: (
						if tabu.count >= marquageGroupe.count do tabu = replace tabu 1 marquageGroupe.count ""
						nomItem = tabu + nomItem
-- 						nomItem	+= " -----------"
						)
				)
				
				append listTmp nomItem
				
			)
			
			lbx_sequence.items 		= listTmp
			
		)
		
		
		if lbx_sequence.selection == 0 then
			prop_enabled = false
		else (
		)
		
		for ui in uis_element do
			ui.enabled = prop_enabled
		
		
		if m_prt.elementCourant != undefined do (
			
-- 			ddl_Type.selection = m_prt.elementCourant.type
			case m_prt.elementCourant.type of (
				1:	(	--- EXTENSIBLE ----
						lbl_elem_largeur.enabled = false
						spn_elem_largeur.enabled = false
						btn_supprimer_model.enabled = false
						btn_creer_model.enabled = false
						spn_elem_largeur.Indeterminate = true
						lbl_model.enabled = false
						ddl_model.enabled = false
						spn_repet.enabled = false
						spn_repet.Indeterminate = true
						lbl_repet.enabled = false
						ddl_model.items = #()
					)
				2:	(	--- LARGEUR FIXE ----
						lbl_model.enabled = false
						ddl_model.enabled = false
						btn_supprimer_model.enabled = false
						btn_creer_model.enabled = false
						spn_elem_largeur.Indeterminate = false
						spn_elem_largeur.value = m_prt.elementCourant.largeur
						spn_repet.enabled = false
						spn_repet.Indeterminate = true
						lbl_repet.enabled = false
						ddl_model.items = #()
					)
				3:	(	--- MODEL ----
						
						--- les presets  ----------
						local listTmp =#()
						local presetsModeles = m_prt.modeles.get ()
						for preset in presetsModeles do
							append listTmp 	preset.nom
						ddl_model.items = listTmp
						
						--- selection du model ---
						if m_prt.elementCourant.model != "" then (
							local tmpModel = m_prt.modeles.get_parIdUnique		m_prt.elementCourant.model
							local idModelTmp = m_prt.modeles.trouver_ID		tmpModel
							ddl_model.selection = idModelTmp
						) else ddl_model.selection  = 0
				
				
						lbl_elem_largeur.enabled = false
						spn_elem_largeur.enabled = false
						spn_elem_largeur.Indeterminate = true
						spn_repet.enabled = false
						spn_repet.Indeterminate = true
						lbl_repet.enabled = false
						
						
					)
				4:	(	--- DEBUT DE GROUPE ----
						ddl_model.items = #()
						btn_supprimer_model.enabled = false
						btn_creer_model.enabled = false
						lbl_model.enabled = false
						ddl_model.enabled = false
						lbl_elem_largeur.enabled = false
						spn_elem_largeur.enabled = false
						spn_elem_largeur.Indeterminate = true
						spn_repet.Indeterminate = false
						spn_repet.value = m_prt.elementCourant.repetition
					)
				5:	(	--- FIN DE GROUPE ----
						ddl_model.items = #()
						btn_supprimer_model.enabled = false
						btn_creer_model.enabled = false
						lbl_model.enabled = false
						ddl_model.enabled = false
						lbl_elem_largeur.enabled = false
						spn_elem_largeur.enabled = false
						spn_elem_largeur.Indeterminate = true
						spn_repet.enabled = false
						spn_repet.Indeterminate = true
						lbl_repet.enabled = false
					)
			)
		)
		
		
		
		if 	lbx_sequence.selection == 0  do 
			btn_supprimer_element.enabled = false
		
		if lbx_sequence.selection <= 1 do
			btn_monter.enabled = false
		
		if lbx_sequence.selection == lbx_sequence.items.count do
			btn_descendre.enabled = false
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_urba_facades		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Facades"
		m_titre.setCouleur (color 255	255	255)
		
		/* 
		m_log 		= str_label 	m_ui:ui_log				m_texte:"..."
		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 200	200	200)
		*/
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
	

		uis_facade = #(lbl_sequence, lbx_sequence, lbl_nom_facade, edt_nom_facade, btn_monter, btn_descendre, btn_supprimer_element, btn_ajouter_extensible, btn_ajouter_fixe, btn_ajouter_model, btn_ajouter_groupe)
		uis_element = #(grp_prop, lbl_elem_largeur, spn_elem_largeur, lbl_model, ddl_model, btn_supprimer_model, btn_creer_model, spn_repet, lbl_repet)
	
	
-- 		ddl_type.items = #(	"<----> ", 
-- 									"|------|  Fixe", 
-- 									"|===|  Modèle 3D",
-- 									"(----" ,
-- 									"----)" )
									
/* 
		ddl_type.items = #(	"|<-->|  Extensible", 
									"|------|  Largeur fixe", 
									"|===|  Modèle 3D" ,
									"(------- " ,
									"-------) ") */
		

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	
	on ddl_facades 				selected  	val 	do 	m_prt.selectionner_id 	val
	
	on ddl_model 					selected  	val 	do 	m_prt.set_modele 	val
	
	on btn_descendre 	pressed  do m_prt.descendre 	( lbx_sequence.selection )
	on btn_monter 		pressed  do m_prt.monter 	 	( lbx_sequence.selection )
	
	on btn_supprimer_element 	pressed  do m_prt.supprimer_element	lbx_sequence.selection	
-- 	on btn_ajouter_element 		pressed  do m_prt.ajouter_element ()
	
	on btn_ajouter_facade 		pressed  do m_prt.ajouter_facade ()	
	on btn_supprimer_facade 		pressed  do m_prt.supprimer_facade 	ddl_facades.selection
	
	
	on spn_elem_largeur 		changed 	val		do 	m_prt.set_elemLargeur		val
	
	on spn_repet 		changed 	val		do 	m_prt.set_ElementRepetition		val
	
	
-- 	
	on edt_nom_facade 		entered  	txt 		do 	m_prt.changerNom		txt
	
	
	
	
	on btn_supprimer_model 		pressed  			do m_prt.supprimer_model 	ddl_model.selection
	on btn_creer_model 			picked	_model  do m_prt.creer_model 	_model
	
	on btn_ajouter_extensible 	pressed  do m_prt.ajouter_element 	1
	on btn_ajouter_fixe 				pressed  do m_prt.ajouter_element 	2
	on btn_ajouter_model 			pressed  do m_prt.ajouter_element 	3
	on btn_ajouter_groupe 		pressed  do m_prt.ajouter_element 	4
	/* 
	
	
	btn_supprimer_model
	btn_creer_model
	
	btn_ajouter_extensible
	btn_ajouter_fixe
	btn_ajouter_model
	btn_ajouter_groupe
	
	
	on btn_nv_model 	pressed  do	
		m_prt.creer_model 	fichier:"C:\\Users\\Windows\\AppData\\Local\\Autodesk\\3dsMax\\2017 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\facades\\fenetre 1.max"
	on btn_nv_espace 	pressed  do	
		m_prt.creer_espacement ()	
	on btn_nv_repart 	pressed  do	
		m_prt.creer_repartition ()
	
	 */
	
	
-- 	on ddl_Type		selected sel do	m_prt.set_elemType 			sel
	on lbx_sequence selected sel do	m_prt.selectionnerElem_id 		sel
		
	on lbx_sequence doubleClicked sel do	actualiser ()
	
	
	---- Drag ----
	on roll_urba_facades lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba_facades lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba_facades mouseMove _pos 	do
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
struct str_urba_facades (
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="Urba | Facades",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	private
		m_estOuvert 		= false,
		------------  Membres	----------------------------------------------------------------------------------
	public
		
		---- pointeurs ----
		m_dialog				= roll_urba_facades ,		---- le rollout ----
		m_dialogPos 		= [100,100],
		
		col_fenetreFond	= color  68   68  68, 	----  ----
		col_fenetreTxt		= color 230  230 230, 	----  ----
	
		--- images bouton fermer ---
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer 	= #(	openBitMap ico_btnFermer_R ,		-- Repos ----
										openBitMap ico_btnFermer_S ,		-- Survol ----
										openBitMap ico_btnFermer_P 			-- Pressé ----
										),
				
	public
		------------	STRUCTURES DIVERSES 		------------------------------------------------------------------------------------------
		---- le struct principale parent ----
		m_urba,
	
		---- le manager de presets des facades ----
		presets 	= str_presetsMGR 	preset_type:	str_urba_preset_facade	\
												fichier:			m_urba.fichier_presets	\
												prefixUnique:	"Facade",
		
		
		elementsDeFacade = str_presetsMGR 	preset_type:	str_urba_preset_elementFacade	\
												fichier:			m_urba.fichier_presets	\
												prefixUnique:	"Element_facade",
		
		modeles = str_presetsMGR 	preset_type:	str_urba_preset_modelFacade	\
												fichier:			m_urba.fichier_presets	\
												prefixUnique:	"modele_facade",
		
		---- la facade actuelement selectionnée ----
		facadeCourante,
		elementCourant,
		
										
										
										
										
	----------------------------------------------------------------------------------------------------------
	------------  Fonctions	------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------

	public
	------------	UI		------------------------------------------------------------------------------------------
		fn actualiser 	= if m_estOuvert do m_dialog.actualiser (),
		fn selectionner 	_preset 	=(
			local id_preset = presets.trouver_ID 	_preset
			facadeCourante = _preset
			m_dialog.ddl_facades.selection = id_preset
			actualiser ()
		),
		fn selectionner_id 	_id =(
			if _id >0 then  (
				facadeCourante = presets.get_preset		_id
				m_dialog.ddl_facades.selection = _id
			) else facadeCourante = undefined
			actualiser ()
		),
		fn selectionnerElem_id 	_id =(
			if _id >0 do (
				local idUnique = facadeCourante.elements[_id]
				elementCourant = elementsDeFacade.get_parIdUnique		idUnique
				m_dialog.lbx_sequence.selection = _id
			)
			actualiser ()
		),
		fn estOuvert = m_estOuvert,
			
		
		fn a_unDebutDeGroupe_audessus _id =(
			
			local result = false
			
			local idU_elemPrecedant 	= facadeCourante.elements[ _id - 1 ]
			local elemPrecedant 		= elementsDeFacade.get_parIdUnique	idU_elemPrecedant
			
			if elemPrecedant.type == 4 do  (
				-- on regarde si il reste un seul groupe ouverture avant ---
				local  liste_id_GrpsOuvertPrecedant = #()
				local  liste_id_GrpsFermePrecedant = #()
				for i = _id - 1  to 1 by -1 do (
					local idU_elemPrecedant 	= facadeCourante.elements[ i ]
					local elemPrecedant 		= elementsDeFacade.get_parIdUnique	idU_elemPrecedant
					if elemPrecedant.type == 4 do 
						append liste_id_GrpsOuvertPrecedant i
					if elemPrecedant.type == 5 do 
						append liste_id_GrpsFermePrecedant i
				)
-- 				debug "liste_id_GrpsOuvertPrecedant.count" var:liste_id_GrpsOuvertPrecedant.count
-- 				debug "liste_id_GrpsFermePrecedant.count" var:liste_id_GrpsFermePrecedant.count
				if liste_id_GrpsOuvertPrecedant.count 	-	liste_id_GrpsFermePrecedant.count == 1 do 
					result = true
			)
			result
		),
		fn a_uneFinDeGroupe_audessous _id =(
			
			local result = false
			
			local idU_elemSuivant 	= facadeCourante.elements[ _id + 1 ]
			local elemSuivant 		= elementsDeFacade.get_parIdUnique	idU_elemSuivant
			
			if elemSuivant.type == 5 do  (
				-- on regarde si il reste un seul groupe ouverture avant ---
				local  liste_id_GrpsOuvertSuivant = #()
				local  liste_id_GrpsFermeSuivant = #()
				for i = _id + 1  to facadeCourante.elements.count do (
					local idU_elemSuivant 	= facadeCourante.elements[ i ]
					local elemSuivant 		= elementsDeFacade.get_parIdUnique	idU_elemSuivant
					if elemSuivant.type == 4 do 
						append liste_id_GrpsOuvertSuivant i
					if elemSuivant.type == 5 do 
						append liste_id_GrpsFermeSuivant i
				)
									
				if liste_id_GrpsFermeSuivant.count 	-	liste_id_GrpsOuvertSuivant.count == 1 do 
					result = true
			)
			result
		),
		fn  descendre	_id =(
			
			local idU_elemTmp 	= facadeCourante.elements[ _id ]
			local elemTmp 		= elementsDeFacade.get_parIdUnique	idU_elemTmp
			
			---- si c'est un debut de groupe -------
			if elemTmp.type == 4 do 		
				if (a_uneFinDeGroupe_audessous _id ) do 	
					return 0
			
			deleteItem	facadeCourante.elements	_id
			insertItem	idU_elemTmp	facadeCourante.elements	( _id + 1 )
			
			presets.sauvegarder		facadeCourante			
			m_dialog.lbx_sequence.selection += 1
			actualiser ()
		),
		fn monter _id =(
			
			local idU_elemTmp 	= facadeCourante.elements[ _id ]
			local elemTmp 		= elementsDeFacade.get_parIdUnique	idU_elemTmp
			
			---- si c'est une fin de groupe on regarde s'il peut encore monter -------
			if elemTmp.type == 5 do 
				if (a_unDebutDeGroupe_audessus _id ) do 	
					return 0
			
			
			---- on bouge dans la sequence-------
			
			deleteItem	facadeCourante.elements	_id
			insertItem	idU_elemTmp	facadeCourante.elements	( _id - 1 )
			
			presets.sauvegarder		facadeCourante			
			m_dialog.lbx_sequence.selection -= 1
			
			actualiser ()
		),
		
		
		
		fn set_ElementRepetition 	_val =(
			elementCourant.repetition = _val
			elementsDeFacade.sauvegarder		elementCourant
			actualiser ()
			m_urba.batiments.actualiser ()
		),
		fn ajouter_facade =(
			local nvPreset = presets.creer_preset ()
			facadeCourante = nvPreset
			m_urba.batiments.actualiser ()
			actualiser ()
		),
		fn supprimer_facade 	_id	=(
			local presetAVirer = presets.get_preset		_id
			
			--- on check si il y a des ville possedant ce batiment
			local batimentsAyantCetteFacade= #()
			for bat in m_urba.batiments.presets.get () do
				if m_urba.batiments.a_facade	bat	presetAVirer.idUnique do 
					append batimentsAyantCetteFacade 	bat
			
			
			
			if querybox ( "Supprimer définitivement: " + presetAVirer.nom + " ?\n" +  batimentsAyantCetteFacade.count as string + " batiment(s) ont cette façade." ) do (
				presets.supprimer _id
				
				for bat in batimentsAyantCetteFacade do ( 
					if bat.rdc_facade == presetAVirer do 
						bat.rdc_facade  =	""
					
					if bat.etages_facade == presetAVirer do 
						bat.etages_facade  =	""
					
					presets.supprimer_preset	presetAVirer
					
				)
	-- 			local _idUnique = villeCourante.batiments [_id]
-- 				deleteItem	villeCourante.batiments 	_id
-- 				deleteItem	villeCourante.probabilites 	_id
					
				
				selectionner_id 	( m_dialog.ddl_facades.selection - 1 )
			)
			actualiser ()
			m_urba.actualiser ()
		),
		
		fn ajouter_element 	_type	=(
			
			local posDansSequence = m_dialog.lbx_sequence.selection
			
			local nvElement 	= elementsDeFacade.creer_preset ()
			nvElement.type 	= _type
			elementCourant 	= nvElement
			elementsDeFacade.sauvegarder nvElement
			append facadeCourante.elements	 nvElement.idUnique
			presets.sauvegarder facadeCourante
			
			
			---- si on creer un groupe alors on ajoute la fin du groupe
			if _type == 4 then 	ajouter_element 5
			else	( 
				selectionnerElem_id	(elementsDeFacade.get() ).count
				actualiser ()
			)
		),
		fn supprimer_element 	_id	=(
			
			local idU_elem = facadeCourante.elements[_id]
			local elem = elementsDeFacade.get_parIdUnique  idU_elem
			
			
			--- si c'est un groupe on doit supprimer l'element associé ----			
			--- debut de groupe
			if elem.type == 4 then (
				local elemGroupAssocie
				for i = _id to facadeCourante.elements.count do (
					local idU_elemTest 	= facadeCourante.elements[ i ]
					local elemTest 		= elementsDeFacade.get_parIdUnique  idU_elemTest
					if elemTest.type == 5 do
						elemGroupAssocie = elemTest
				)
				--- maj des presets ---
				elementsDeFacade.supprimer_parIdUnique	elemGroupAssocie.idUnique
				--- maj de la facade ---
				local idASuppr = findItem facadeCourante.elements	elemGroupAssocie.idUnique
				deleteItem	facadeCourante.elements 		idASuppr
				
			)
			
			--- fin de groupe
			if elem.type == 5 then (
				local elemGroupAssocie
				for i = _id to 1 by -1 do (
					local idU_elemTest 	= facadeCourante.elements[ i ]
					local elemTest 		= elementsDeFacade.get_parIdUnique  idU_elemTest
					if elemTest.type == 4 do
						elemGroupAssocie = elemTest
				)
				--- maj des presets ---
				elementsDeFacade.supprimer_parIdUnique	elemGroupAssocie.idUnique
				
				--- maj de la facade ---
				local idASuppr = findItem facadeCourante.elements	elemGroupAssocie.idUnique
				deleteItem	facadeCourante.elements 		idASuppr
			)
			
			
			
			local idASuppr = findItem facadeCourante.elements	elem.idUnique
			--- maj des presets ---
			elementsDeFacade.supprimer_parIdUnique	facadeCourante.elements[idASuppr]
			
			
			--- maj de la facade ---
			deleteItem	facadeCourante.elements 		idASuppr
			presets.sauvegarder		facadeCourante	
			
			actualiser ()
		),
		
		fn set_modele 	_id =(
			local nvModel = modeles.get_preset		_id
			elementCourant.model = nvModel.idUnique
			elementsDeFacade.sauvegarder		elementCourant
			actualiser ()
-- 			m_urba.batiments.actualiser ()
		),
		fn creer_model 	_node	=(
			
			m_urba.outils.preparer_modelFacade	_node	elementCourant
			
			presets.sauvegarder		facadeCourante	
			
			actualiser ()
		),
		
		fn supprimer_model 	_id	=(
			
		),
		
		
		
			
		---- fenetre -----
		fn ouvrir  pos: =(			
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
			--- pour selectionner un premier élément
			if ( presets.get () ).count >0 do selectionner_id 1
			if ( elementsDeFacade.get () ).count >0 do selectionnerElem_id 1
			m_dialog.actualiser ()
			
		),
		fn fermer  =(	
			m_estOuvert 		= false
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			m_urba.actualiser ()
			if selection.count == 1 do
				if classof $ == urba_batiment do
					$.actualiser_rollouts ()
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		),
		fn toggle_ouvrir =(
			if m_estOuvert 	then fermer ()
									else 	ouvrir ()
		),
		fn initialiser =(
			debug "initialiser"
		),
		
		
		fn changerNom 	_nvNom =(
			facadeCourante.nom = _nvNom
			presets.sauvegarder		facadeCourante
			actualiser ()
			m_urba.batiments.actualiser ()
		),
		fn set_elemLargeur 	_nvlLargeur =(
			elementCourant.largeur = _nvlLargeur
			elementsDeFacade.sauvegarder		elementCourant
			actualiser ()
-- 			m_urba.batiments.actualiser ()
			
		),
		
		
		
		------------  Evenements	----------------------------------------------------------------------------------
		on create do initialiser ()
)

-- 	try 
-- 		destroydialog test.m_dialog 
-- 	catch ()

-- 	urba_moduleFacade = str_urba_facades ()
-- 	urba_moduleFacade.ouvrir ()



-- 	)






