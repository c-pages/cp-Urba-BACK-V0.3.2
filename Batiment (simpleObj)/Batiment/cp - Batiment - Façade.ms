
plugin simpleObject		batiment_composant_facade
name:"Façade"
classID:#(0x52a049eb, 0xc56c437)
category:"CP | Bâtiment	| Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuisEnsemble"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres , 	actualiser_composants 
	local	ajouter_element, retirer_element, monter_element, descendre_element, renommer_element
	local est_instance
	
	local sequence_tmp
	
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_general rollout:roll_general
	(
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 					default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur				default:10.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 					default:0.
		
		----- les menuiseries -----------
		cadre_largeur					type:#worldUnits 	ui:spn_cadre_largeur			default:2.5
		
		
		on profondeur	set val do corriger_parametres ()
		on longueur 	set val do corriger_parametres ()
		
	)
	
	parameters params_sequence rollout:roll_sequence
	(
-- 		align_prof					type:#worldUnits 		ui:spn_aling_prof	default:5.
		
		sequence					type:#maxObjectTab	tabSizeVariable:true
		sequence_elem_long		type:#floatTab			tabSizeVariable:true
		
-- 		on align_prof					set val do corriger_parametres ()
		on sequence_elem_long 	set arg1 arg2 do corriger_parametres ()
		
		
	)
	
	parameters params_divers rollout:roll_divers
	(
		
		nom	 							type:#string 			default:"Ensemble"
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)	-----	fin parametres --------------------
	
	
	
	
	
	
	
	
	rollout roll_general  "Paramètres"
	(
		
		spinner spn_longueur 				"longueur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_hauteur 				"Hauteur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_profondeur 			"Profondeur" 			type:#worldunits range:[0,1e20,0]
		
		group "Cadre" (
			spinner spn_cadre_largeur			"Largeur" 				type:#worldunits 	range:[0,1e20,0]
		)
	)
	
	rollout roll_sequence  "Séquence"
	(
		--- divers ------------------------------------------------------------------------------------------------------
		fn get_menuiserie_plugins =(
			local geo_classes			=	GeometryClass.classes 
			local menuiseries_classes 	= for geo_classe in geo_classes	where findstring ( geo_classe as string )		"cp_menuis_" != undefined	 collect	geo_classe
			menuiseries_classes
		)
		
		fn get_facades_plugins =(
			local geo_classes			=	GeometryClass.classes 
			local facades_classes 	= for geo_classe in geo_classes	where findstring ( geo_classe as string )		"cp_plein_" != undefined	 collect	geo_classe
			facades_classes
		)
		
		
		--- menus cliques droit -------------------
		fn creer_RCM_ajouter	=(

			--- on recupere les plug necessaires ---------
			local menuiseries_plugins 	= get_menuiserie_plugins ()
			local facades_plugins 		= get_facades_plugins ()
			
			--- on ecrit le menu -----------------------------------------------------------------------------------------------
			local menu_txt=""
			menu_txt += "rcmenu  menu_ajouter (\n"
			
			
			---- les boutons ------------------------------------------------------------------------------------------------
			---- elements pleins -----------------------------------
			menu_txt +=			"subMenu \"Pleins\" (\n"
			for facade_plug in facades_plugins do
				menu_txt += "menuItem	btn_" + facade_plug.name as string + "	\"" + facade_plug.name + "\"\n" 
			menu_txt +=			")\n"
			
			
			
			---- menuiseries ------------
			menu_txt +=			"subMenu \"Menuiseries\" (\n"
			for menuis_plug in menuiseries_plugins do
				menu_txt += "menuItem	btn_" + menuis_plug.name as string + "	\"" + menuis_plug.name + "\"\n" 
			
-- 			menu_txt += "menuItem	btn_ensemble 	\"Ensemble menuisé\"\n" 
			menu_txt +=			")\n"
			
			---- les evenements ------------------------------------------------------------------------------------------------
			for menuis_plug in menuiseries_plugins do
				menu_txt += "on		btn_" + menuis_plug.name as string + " picked do $.ajouter_element " + menuis_plug as string+ "\n" 
			
			for facade_plug in facades_plugins do
				menu_txt += "on		btn_" + facade_plug.name as string + " picked do $.ajouter_element " + facade_plug as string+ "\n" 
			
			
			--- fin du rc menu ------------
			menu_txt += ")"
			
			
			
			
			
			---- on ouvre le menu -----
			RCmenu_ajouter	=	execute menu_txt
			popUpMenu	RCmenu_ajouter
			
		) --- fin creer_RCM_ajouter ---------------
		
		
		
		
		fn creer_RCM_edition	=(

			rcmenu  RCmenu_edition (
				menuItem	btn_dupliquer	 		"Dupliquer" 			enabled:($.est_copiable 	())
				menuItem	btn_instancier	 		"Instancier" 		enabled:($.est_copiable	())
				menuItem	btn_rendreUnique	 	"Rendre unique" 	enabled:($.est_instance	())
				
				on		btn_dupliquer 		picked 	do $.dupliquer_element ()
				on		btn_instancier 	picked 	do $.instancier_element ()
				on		btn_rendreUnique picked 	do $.rendreUnique_element ()
			)
			
			popUpMenu	RCmenu_edition
			
		) --- fin creer_RCM_ajouter ---------------
		
		
		
		
		spinner 	spn_aling_prof 		"Alignement" 		type:#worldunits range:[0,1e20,0]
		
		button 		btn_ajouter 		"+"			across:4
		button 		btn_retirer	 		"-"			
		button 		btn_monter			"/\\"			
		button 		btn_descendre	"\\/"
		
		listBox		lbx_sequence		""	height:5
		
		group "" (	
			editText 	edTxt_nom		 	"Nom:" 	
			spinner 	spn_elem_long		"Longeur" 		type:#worldunits range:[0,1e20,0]		tooltip:"La longueur de l'élément.\n0.0: Longueur automatique (Répartition régulière des longueurs)"
		)
		
		subrollout	subroll_param		""	height:300		--width:164 pos:[5,200]
		
		
		
		
		fn actualiser =(
			
			---- l'affichage de la sequence -------------------
			local elements_noms 	= #()
			for i = 1 to sequence.count do (
				local elem_nom = sequence[i].nom
				if est_instance 	id:i 	do elem_nom += " *"
				append elements_noms	elem_nom
			)	
			lbx_sequence.items 		=  for elem_nom in elements_noms collect elem_nom
			
			
			--- les parametres de l'element (le subrollout)  ---------------			
			--- on retire les vieux rollouts --------
			if subroll_param.rollouts.count > 0 do 
				for subRoll in subroll_param.rollouts  do
					removeSubRollout subroll_param	subRoll
				
			---- on ajoute le nouveau -----------------
			if lbx_sequence.selection > 0 then (
				
				local composant_actif 		=  sequence[  lbx_sequence.selection ]
				addSubRollout 	subroll_param		composant_actif.roll_parametres
				
				spn_elem_long.indeterminate		=	false
				spn_elem_long.enabled 				=	true
				
				spn_elem_long.value = sequence_elem_long[  lbx_sequence.selection ]				
				edTxt_nom.text	=	sequence[  lbx_sequence.selection ].nom
				
			) else(
				
				spn_elem_long.indeterminate		=	true
				spn_elem_long.enabled 				=	false
				
				edTxt_nom.enabled = false
				edTxt_nom.text	=	""
			)
			
		) --- fin actualiser -----------
		
		
		
		
		
		on roll_sequence		open 				do 	actualiser ()
		on lbx_sequence 		selected sel 	do	actualiser ()
		
		on lbx_sequence	 rightClick 	_id 	do	(
			lbx_sequence.selection = _id
			actualiser ()
			creer_RCM_edition ()
			
		)
		
		
		
		on btn_ajouter 		pressed 			do 	creer_RCM_ajouter ()
		on btn_retirer 		pressed 			do	retirer_element 		lbx_sequence.selection 
		on btn_monter 		pressed 			do	monter_element 		lbx_sequence.selection 
		on btn_descendre 	pressed		 	do	descendre_element 	lbx_sequence.selection 
		on spn_elem_long 	changed val	do	(
			sequence_elem_long[  lbx_sequence.selection ] = val
			redrawviews ()
		)
		
		on edTxt_nom entered txt do renommer_element		lbx_sequence.selection 	txt
	)
	rollout roll_divers  "Divers"
	(
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 	"Vitrage" 				type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	
	------------ FONCTIONS	----------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
-- 		--- rester dans les bonnes limites ------
-- 		if align_prof > profondeur do align_prof = profondeur
		
		
		--- longueur de l'ensemble ----------
		local longueur_est_contrainte = true
		local longueur_contrainte = 0
		for elem_long in sequence_elem_long do
			if elem_long == 0 do longueur_est_contrainte	=	false
		if longueur_est_contrainte and sequence.count > 0  do (
			for elem_long in sequence_elem_long do (
				longueur_contrainte += elem_long
				longueur_contrainte += cadre_largeur
			)
			longueur_contrainte += cadre_largeur
			longueur = longueur_contrainte
		)
		
	)
	
	--------- divers ------------------
	fn est_porte	_compo	=	classof	_compo	==	cp_menuis_porte
	fn est_fixe		_compo	=	classof	_compo	==	cp_menuis_fixe
	fn est_copiable			=	 roll_sequence.lbx_sequence.selection != 0
	fn est_instance	id:		= (
		if id == unsupplied do id = roll_sequence.lbx_sequence.selection
		local result =false
		for i = 1 to sequence.count where i != id do
			if sequence[i] == sequence[ id] do result = true
		result
	)
	
	
	--------------- comopsants ----------------------------------
	fn actualiser_composants	= with redraw off (
		/* 
		
		--- maj des composants de la sequence -------------
		local longueur_passage 	= longueur 	- 2*cadre_largeur
		local nbr_meneaux			= sequence.count - 1
		
		local longueur_total_meneaux	=	( sequence.count - 1 )* compo_meneau.longueur 
		
		local longueur_definies_total 	= 0
		local nbr_elem_definies 		= 0
		for i = 1 to sequence.count do (
			if sequence_elem_long[i] != 0 do (
				longueur_definies_total+= sequence_elem_long[i]
				nbr_elem_definies += 1
			)
		)
		
		local longueur_composant	= ( longueur_passage - ( longueur_total_meneaux + longueur_definies_total ) ) / ( sequence.count - nbr_elem_definies )
		
		
		
		sequence_tmp 				= #()
		for i = 1 to sequence.count do (
			
			local compo_temp 				= 	copy sequence[i]
	
			if sequence_elem_long[i] != 0 then	compo_temp.longueur 	= 	sequence_elem_long[i]
													else		compo_temp.longueur	=	longueur_composant
			
			if est_porte 	compo_temp 	then
				compo_temp.hauteur			=	hauteur - cadre_largeur
			else
				compo_temp.hauteur			=	hauteur - 2*cadre_largeur
			
			compo_temp.profondeur		=	0 -- profondeur
			compo_temp.cadre_use			= false
			compo_temp.low_poly			=	low_poly
			
			append sequence_tmp		compo_temp
		)
		
		
		--- Si notre sequence est vide
		if sequence.count == 0 do (
			local compo_temp = createInstance cp_menuis_fixe
			
			append	sequence_tmp  	compo_temp
			
			compo_temp.hauteur		=	hauteur - 2*cadre_largeur
			compo_temp.profondeur		=	profondeur
			compo_temp.cadre_use			= false
			compo_temp.low_poly			=	low_poly
			compo_temp.longueur			=	longueur 	- 2*cadre_largeur
		)
		 */
		
	)  --- fin composants_actualiser  ------------------
	
	fn actualiser = (
		corriger_parametres ()		
		actualiser_composants()		
		if roll_sequence.open do	roll_sequence.actualiser ()		
		redrawViews ()
		
	)
	
	
	
	
	
	
	
	
	--------------- sequence ----------------------------------
	fn ajouter_element		_element_plug	 =(
		
		
		local nvel_element = createinstance	_element_plug
		append sequence		nvel_element
		append sequence_elem_long	0.
		
		---- actualisations -----------
		actualiser ()

	)
	fn retirer_element		_id	 	=(
		
		deleteItem sequence 				_id
		deleteItem sequence_elem_long 	_id
		
		---- actualisations -----------
		actualiser ()

	)
	fn monter_element 		_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		local meneau_temp 	= sequence_elem_long[ _id ]
		deleteItem 	sequence 				_id
		deleteItem sequence_elem_long 	_id
		insertItem 	elem_temp			sequence  					(	_id - 1 )
		insertItem 	meneau_temp		sequence_elem_long  	(	_id - 1 )
		
		---- actualisations -----------
		actualiser ()

	)
	fn	descendre_element 	_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		local meneau_temp 	= sequence_elem_long[ _id ]
		deleteItem 	sequence 				_id
		deleteItem sequence_elem_long 	_id
		if _id == sequence.count then (
			append sequence 				elem_temp
			append sequence_elem_long	meneau_temp
		) else (
			insertItem 	elem_temp		sequence  					(	_id + 1 )
		insertItem 	meneau_temp		sequence_elem_long  	(	_id + 1 )
		)
		
		
		---- actualisations -----------
		actualiser ()

	)
	
	fn renommer_element	_id	_nv_nom =(
		sequence[ _id ].nom = _nv_nom
		if roll_sequence.open do	roll_sequence.actualiser ()
	)
	
	
	fn dupliquer_element 	id_elem_select:		=(
		
		if id_elem_select 	== unsupplied do
			id_elem_select 		= 	roll_sequence.lbx_sequence.selection
		local nvel_element 			= copy sequence[ id_elem_select ]
		local nvel_element_long 	= copy sequence_elem_long[ id_elem_select ]
		append sequence		nvel_element
		append sequence_elem_long	nvel_element_long
		
		---- actualisations -----------
		actualiser ()

	)
	fn instancier_element 	id_elem_select:		=(
		
		
		if id_elem_select 	== unsupplied	do
			id_elem_select 		= 	roll_sequence.lbx_sequence.selection
		local nvel_element 			=  sequence[ id_elem_select ]
		local nvel_element_long 	=  sequence_elem_long[ id_elem_select ]
		
		
		append sequence		nvel_element
		append sequence_elem_long	nvel_element_long
		
		---- actualisations -----------
		actualiser ()

	)
	
	fn rendreUnique_element id_elem_select:		=(
		
		if id_elem_select 	== unsupplied do
			id_elem_select 		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem_select ] = copy sequence[ id_elem_select ] 
		
		---- actualisations -----------
		actualiser ()

	)
	
	
	
	
	
	
	
	
	
	--------------- Passerelle Element Sequence  ----------------------------------
	fn ajouter_element_menuis		_element_plug	 =(
		
		local 	id_elem 		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem ].ajouter_element_menuis		_element_plug	
		
		---- actualisations -----------
		actualiser ()
	)
	fn retirer_element_menuis		_id	 	=(
		
		local 	id_elem 		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem ].retirer_element_menuis		_id
		
		---- actualisations -----------
		actualiser ()

	)
	fn monter_element_menuis 		_id 		=(
		
		local 	id_elem 		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem ].monter_element_menuis		_id
		
		---- actualisations -----------
		actualiser ()

	)
	fn	descendre_element_menuis 	_id 		=(
		
		local 	id_elem 		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem ].descendre_element_menuis		_id
		
		---- actualisations -----------
		actualiser ()

	)
	
	fn renommer_element_menuis		_id	_nv_nom =(
		
		local 	id_elem 		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem ].renommer_element_menuis		_id	_nv_nom
		
		if roll_sequence.open do	roll_sequence.actualiser ()
	)
	
	
	fn dupliquer_element_menuis 		id_elem_select:		=(
		
		local 	id_elem		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem ].dupliquer_element_menuis 	id_elem_select:id_elem_select
		
		---- actualisations -----------
		actualiser ()

	)
	fn instancier_element_menuis 	id_elem_select:		=(
		
		local 	id_elem		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem ].instancier_element_menuis 	id_elem_select:id_elem_select
		
		
		---- actualisations -----------
		actualiser ()

	)
	
	fn rendreUnique_element_menuis	 id_elem_select:		=(
		
		local 	id_elem		= 	roll_sequence.lbx_sequence.selection
		sequence[ id_elem ].rendreUnique_element_menuis 	id_elem_select:id_elem_select
		
		---- actualisations -----------
		actualiser ()

	)
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		/* 
		---- le cadre  -------
		mesh	+	compo_cadre.mesh
		
		
		
		---- la sequence	-----
		local compo_travBas	= 	if low_poly	then	createInstance  cp_prim_boiteL else createInstance 	cp_prim_boite
		local depos_composant = [ cadre_largeur, 0, 0 ]
		for i = 1 to	sequence_tmp.count do (
			
			---- le composant -----
			local composant 		= sequence_tmp [i]
			local calage_y		= 	0	--	if est_fixe		composant		then 	0 else  -( composant.ouvrant_profondeur / 2 )
			local calage_z			= if est_porte		composant		then 	0 else  cadre_largeur
			
			local depose_temp 	= if  not est_fixe 	composant 	then  	depos_composant  	+ [0, align_prof + calage_y ,calage_z ]
																					else		depos_composant 	+ [0,align_prof,cadre_largeur ]
			
			
			mgr_mesh.attacher		mesh		composant	transf:depose_temp
			
			---- la traverse du bas ------------
			if not est_porte 	composant 	do (
				compo_travBas.hauteur 		= 	cadre_largeur
				compo_travBas.profondeur		=	profondeur
				compo_travBas.longueur		=	composant.longueur
				mgr_mesh.attacher		mesh		compo_travBas	transf:depos_composant
			)
				
			
			depos_composant.x += composant.longueur
			
			--- le meneau- ----
			if i != sequence_tmp.count do (				
				mgr_mesh.attacher		mesh		compo_meneau	transf:depos_composant
				depos_composant.x += compo_meneau.longueur
			)
		)
		
		
		 */
	)  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		local pt_epaisseur
		
		on mousePoint click do
			case click of
			(
				1: (	
						pt_debut 		=  gridPoint
						nodeTM.translation = pt_debut
				)
				3: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= 	length 		( gridPoint - pt_debut )
					local norm_dir 		=	normalize 	(gridPoint - pt_debut )
					local angle_pts		=	acos			(dot  [1,0,0]  norm_dir)	
					
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_hauteur	=	gridPoint
					
				)
				3:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
					
				)
			)		
	) --- fin tool create ---------
	
	
) --------- fin plugin --------------


