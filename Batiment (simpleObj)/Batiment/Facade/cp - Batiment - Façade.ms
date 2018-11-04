
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
	local	ajouter_element_facade, retirer_element_facade, dupliquer_element_facade, instancier_element_facade, rendreUnique_element_facade, monter_element_facade, descendre_element_facade, renommer_element_facade, ouvrir_parametres
	local est_instance
	
	local sequence_tmp
	
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_general rollout:roll_general	(
		
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 					default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur				default:10.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 					default:0.
		
	)
	parameters params_sequence rollout:roll_parametres	(
		
		repartition					type:#integer				ui:ddl_repartition			default:1
		nbr_repetitions			type:#integer				ui:spn_repetitions		default:1
		sequence					type:#maxObjectTab	tabSizeVariable:true
		
	)
	parameters params_divers rollout:roll_divers	(
		
		nom	 							type:#string 			default:"Facade"
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	
	
	parameters params_contraintes rollout:roll_contraintes	(
		
		etages_min_use		type:#boolean 		ui:chk_etages_min			default:false
		etages_min				type:#integer			ui:spn_etages_min			default:0
		etages_max_use		type:#boolean 		ui:chk_etages_max			default:false
		etages_max				type:#integer			ui:spn_etages_max			default:0
		
		longueur_min_use		type:#boolean 		ui:chk_longueur_min			default:false
		longueur_min			type:#integer			ui:spn_longueur_min			default:0
		longueur_max_use		type:#boolean 		ui:chk_longueur_max			default:false
		longueur_max			type:#integer			ui:spn_longueur_max			default:0
		
		mur_nord			type:#boolean 		ui:ckb_mur_nord			default:false
		mur_sud			type:#boolean 		ui:ckb_mur_sud			default:false
		mur_est			type:#boolean 		ui:ckb_mur_est				default:false
		mur_ouest		type:#boolean 		ui:ckb_mur_ouest			default:false
		
		murs				type:#integer			ui:ddl_murs					default:0
		
	)
	
	
	
	parameters params_hasard rollout:roll_hasard
	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	
	
	rollout roll_general 			"Paramètres"	(
		
		spinner spn_longueur 				"longueur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_hauteur 				"Hauteur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_profondeur 			"Profondeur" 			type:#worldunits range:[0,1e20,0]
		
-- 		group "Cadre" (
-- 			spinner spn_cadre_largeur			"Largeur" 				type:#worldunits 	range:[0,1e20,0]
-- 		)
	)
	rollout roll_parametres  	"Séquence"		(
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
		
		fn get_composant_facade =(
			
			local geo_classes			=	GeometryClass.classes 
			local facades_classes 	= for geo_classe in geo_classes	where findstring ( geo_classe as string )		"cp_facadeCompo" != undefined	 collect	geo_classe
			facades_classes
		)
		
		--- Menus cliques droit ----------------------------------------------------------------------------------------------
		fn creer_RCM_ajouter	=(

			--- on recupere les plug necessaires ---------
-- 			local menuiseries_plugins 	= get_menuiserie_plugins ()
			local facades_plugins 		= get_composant_facade ()
			
			--- on ecrit le menu -----------------------------------------------------------------------------------------------
			local menu_txt=""
			menu_txt += "rcmenu  menu_ajouter (\n"
			
			
			---- les boutons ------------------------------------------------------------------------------------------------
			---- elements pleins -----------------------------------
-- 			menu_txt +=			"subMenu \"Pleins\" (\n"
			for facade_plug in facades_plugins do
				menu_txt += "menuItem	btn_" + facade_plug.name as string + "	\"" + facade_plug.name + "\"\n" 
-- 			menu_txt +=			")\n"
			
			
			/* 
			---- menuiseries ------------
			menu_txt +=			"subMenu \"Menuiseries\" (\n"
			for menuis_plug in menuiseries_plugins do
				menu_txt += "menuItem	btn_" + menuis_plug.name as string + "	\"" + menuis_plug.name + "\"\n" 
			 */
-- 			menu_txt += "menuItem	btn_ensemble 	\"Ensemble menuisé\"\n" 
-- 			menu_txt +=			")\n"
			
			---- les evenements ------------------------------------------------------------------------------------------------
			/* for menuis_plug in menuiseries_plugins do
				menu_txt += "on		btn_" + menuis_plug.name as string + " picked do $.ajouter_element " + menuis_plug as string+ "\n" 
			 */
			for facade_plug in facades_plugins do
				menu_txt += "on		btn_" + facade_plug.name as string + " picked do $.ajouter_element_facade " + facade_plug as string+ "\n" 
			
			
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
				
				on		btn_dupliquer 		picked 	do $.dupliquer_element_facade ()
				on		btn_instancier 	picked 	do $.instancier_element_facade ()
				on		btn_rendreUnique picked 	do $.rendreUnique_element_facade ()
			)
			
			popUpMenu	RCmenu_edition
			
		) --- fin creer_RCM_ajouter ---------------
		
		
		
		
		--- UI ----------------------------------------------------------------------------------------------
		group "Répartition" (
			dropDownList	ddl_repartition		""	 items:#("Répartir",  "Répéter"/*,   "Etirer" , "Centrer","Aligner à gauche", "Aligner à droite" */)
			spinner spn_repetitions 		"Répétitions" 			type:#integer range:[1,1000,1]
		)
		/* 
		button 		btn_ajouter 		"+"			across:4
		button 		btn_retirer	 		"-"			
		button 		btn_monter			"/\\"			
		button 		btn_descendre	"\\/"
		 */
		button 		btn_ajouter_mur 		"Mur"		width:50	across:3		align:#left
		button 		btn_ajouter_baie 		"Baie"		width:50	align:#left
		button 		btn_ajouter_autre 	""		width:50	align:#left	enabled:false
		
		listBox		lbx_sequence		""	height:10
		
		button 		btn_dupliquer	 		"Dup."			width:27	height:17	across:6	align:#left
		button 		btn_instancier	 		"Ins."			width:27			height:17			align:#left
		button 		btn_rendreUnique	 	"Uni."			width:27			height:17			align:#left
		button 		btn_retirer	 		"Sup."				width:27		height:17			align:#left
		button 		btn_monter			"/\\"			width:27		height:17		align:#left
		button 		btn_descendre	"\\/"			width:27		height:17		align:#left
		
		
		subrollout	subroll_param		""	height:300
		
		dotNetControl btn_resize 	"System.Windows.Forms.Button" 		align:#left /* width:150 */ height:10
		
		
		
		
		fn actualiser =(
			
-- 			---- repartition -------
			spn_repetitions.enabled = ddl_repartition.selection == 2
			
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
			)
			
			---- les boutons ------
			btn_retirer.enabled 			= lbx_sequence.selection != 0
			btn_monter.enabled 			= lbx_sequence.selection > 1
			btn_descendre.enabled 	= lbx_sequence.selection < sequence.count and lbx_sequence.selection != 0
			
			
			
		) --- fin actualiser -----------
		
		----- Gestion du resize du subRollout -----------------------
		local resize_enCours 			= false
		local pos_initial					=	[0,0]
		local subRoll_hauteur_init		=	0
		local btnResize_pos_init		=	[0,0]
		local roll_hauteur_init			=	[0,0]
		fn resize_surbRoll =(
			if resize_enCours do (
				local mouse_pos 			= mouse.posUnscaled
				local changement_ht 	= mouse_pos.y - pos_initial.y
				local subRoll_nvl_ht 	= subRoll_hauteur_init 		+ 	changement_ht
				
				if subRoll_nvl_ht >	50 do (
					subroll_param.height		=	subRoll_nvl_ht
					btn_resize.pos.y			=	btnResize_pos_init.y		+	changement_ht
					roll_parametres.height	=	roll_hauteur_init 	+ 	changement_ht
				)
			)
		)
		
		
		
		
		
		on roll_parametres		open 				do 	(
			actualiser ()
			
			---- le bouton resize -----------------------
			btn_resize.FlatStyle	=		(dotNetClass "System.Windows.Forms.FlatStyle").flat	
			btn_resize.BackColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			btn_resize.ForeColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
		)
		
		
		---- repartition ---------
		on ddl_repartition selected  val do actualiser ()
		
		----- Sequence -----------------
		on lbx_sequence 		selected sel 	do	actualiser ()		
		on lbx_sequence	 rightClick 	_id 	do	(
			lbx_sequence.selection = _id
			actualiser ()
			creer_RCM_edition ()
			
		)
		on btn_ajouter_mur	 	pressed 			do 	ajouter_element_facade 	cp_facadeCompo_mur
		on btn_ajouter_baie		pressed 			do 	ajouter_element_facade 	cp_facadeCompo_baie
		
		on btn_dupliquer 			pressed 			do	dupliquer_element_facade 			lbx_sequence.selection 
		on btn_instancier 		pressed 			do	instancier_element_facade 		lbx_sequence.selection 
		on btn_rendreUnique	pressed 			do	rendreUnique_element_facade 	lbx_sequence.selection 
		on btn_retirer 			pressed 			do	retirer_element_facade 			lbx_sequence.selection 
		on btn_monter 			pressed 			do	monter_element_facade 			lbx_sequence.selection 
		on btn_descendre 		pressed		 	do	descendre_element_facade 		lbx_sequence.selection 
		
		
		
		------------ le bouton resize -----------------------
		on	btn_resize	MouseDown 	do (
			resize_enCours 				= true
			pos_initial						=	mouse.posUnscaled
			subRoll_hauteur_init			= 	subroll_param.height
			btnResize_pos_init			=	btn_resize.pos
			roll_hauteur_init				=	roll_parametres.height
		)
		on	btn_resize	MouseUp 		do	resize_enCours = false		
		on	btn_resize	MouseMove 	do 	resize_surbRoll ()
		on	btn_resize	MouseLeave 	do	resize_enCours = false		
		
		
	)
	rollout roll_contraintes "Contraintes"
	(
		group "Etages" (
			checkbox 	chk_etages_min	"Minimum"   width:57			height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left		across:2
			spinner 	spn_etages_min	"" 				width:57 height:16 range:[-1e+13,1e+13,0] type:#integer scale:1 align:#right
			checkbox 	chk_etages_max 	"Maximum"  width:57			height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left	across:2
			spinner 	spn_etages_max 	""  			width:57 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#right
		)
		group "Longeur" (		
			checkbox 	chk_longueur_min 	"Minimum" 	width:57			height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left	across:2
			spinner 	spn_longueur_min 	""  			width:57 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#right
			checkbox 	chk_longueur_max 	"Maximum"  width:57			height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left	across:2
			spinner 	spn_longueur_max		"" 				width:57 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#right
		)
		group "Murs" (
			checkbutton ckb_mur_nord 		"N."  	width:30 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left	across:4
			checkbutton ckb_mur_sud 		"S."  	width:30 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			checkbutton ckb_mur_est 		"E." 		width:30 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			checkbutton ckb_mur_ouest 		"O."	width:30 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			
			dropdownList ddl_murs ""  height:21 selection:3 align:#left
		)
		
		fn actualiser= (
			spn_etages_min.indeterminate		=	not etages_min_use
			spn_etages_min.enabled 			=	etages_min_use 
			
			spn_etages_max.indeterminate	=	not etages_max_use
			spn_etages_max.enabled 			=	etages_max_use 
			
			spn_longueur_min.indeterminate	=	not longueur_min_use
			spn_longueur_min.enabled 			=	longueur_min_use 
			
			spn_longueur_max.indeterminate	=	not longueur_max_use
			spn_longueur_max.enabled 		=	longueur_max_use 
			
		)
		on roll_contraintes open do actualiser ()
			
		on chk_etages_min 		changed state do actualiser ()
		on chk_etages_max 		changed state do actualiser ()
		on chk_longueur_min 	changed state do actualiser ()
		on chk_longueur_max	changed state do actualiser ()
			
			
		
	) --- fin rollout facades-------------------------
	
	
	rollout roll_divers  			"Divers"			(
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
			spinner spn_matId_huisserie 	"Huisserie" 				type:#integer range:[1,1000,1]
			spinner spn_matId_mur 			"Mur" 					type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	rollout roll_hasard  "Hasard"	(
		
		spinner spn_hasard_seed 			"Seed" 					type:#integer		 range:[0,1e20,0]
		
		group "Fenetres" (
			spinner spn_fen_proba_ouv 		"Proba (%)" 			type:#float			 range:[0,100,0]
			spinner spn_fen_ouvMax 			"Max (°)" 		type:#float			 range:[0,180,0]
		)
	
	)
	
	
	
	------------ FONCTIONS	----------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
-- 		--- rester dans les bonnes limites ------
-- 		if align_prof > profondeur do align_prof = profondeur
		
		/* 
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
		 */
	)
	
	
	--------- divers ------------------
	fn est_baie			_compo	=	classof	_compo	==	cp_facadeCompo_baie
	fn est_porte		_compo	=	classof	_compo	==	cp_menuis_porte
	fn est_fixe			_compo	=	classof	_compo	==	cp_menuis_fixe
	fn est_unPlein		_compo	=	classof	_compo	==	cp_facadeCompo_mur	--	_compo.category	as string ==	"CP | Facade	| Pleins"
	fn est_copiable			=	 roll_parametres.lbx_sequence.selection != 0
	fn est_instance	id:		= (
		if id == unsupplied do id = roll_parametres.lbx_sequence.selection
		local result =false
		for i = 1 to sequence.count where i != id do
			if sequence[i] == sequence[ id] do result = true
		result
	)
	
	
	fn est_valide	_pt_1 		_pt_2  			_etage		_etages_nbre	=(
		
		local pt_1 = _pt_1
		local pt_2 = _pt_2
		local result_valid 		= true
		
		
		--- longueur ------------
		local longueur_mur 	= distance		pt_1 	pt_2
		if longueur_min_use and longueur_mur < longueur_min do
			result_valid = false
		if longueur_max_use and longueur_mur > longueur_max do
			result_valid = false
		
		
		---- etages -------------
		if etages_max_use and  _etage > etages_max do
			result_valid = false
		
		local etage_min_tmp	=	etages_min
		if etage_min_tmp < 0 do etage_min_tmp = _etages_nbre + etages_min + 1
		if etages_min_use and  _etage < etage_min_tmp do
			result_valid = false
		
		result_valid
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- comopsants ----------------------------------
	fn actualiser_composants	= with redraw off (
-- 		
-- 		seed	hasard_seed
		
		sequence_tmp 				= 	#()
		
		--- Si notre sequence est vide ------------------------------------
		if sequence.count == 0 then (
			
			local compo_temp = createInstance cp_facadeCompo_mur
			
			append	sequence_tmp  	compo_temp
			
			compo_temp.hauteur			=	hauteur 
			compo_temp.profondeur		=	profondeur
			compo_temp.low_poly			=	low_poly
			compo_temp.longueur			=	longueur
			compo_temp.matId	=	matId_mur
			
			
		)  else (	----- on construit la sequence ---------------------------------------
		
		
			/* --- analyse initiale ------------------
			local longueur_definies_total 		= 0
			local nbr_elem_definies 			= 0
			for i = 1 to sequence.count do 
				if sequence[i].longueur != 0 do (
					longueur_definies_total+= sequence[i].longueur
					nbr_elem_definies += 1
				) */
-- 			local longueur_composant	= ( longueur - longueur_definies_total  ) / ( sequence.count - nbr_elem_definies )
			
			
			local longueur_composant	
			case repartition of (
				1: 	(	-----	Répartir -------------------
					/* 
					local longueur_definies_total 		= 0
					local nbr_elem_definies 			= 0
					for i = 1 to sequence.count do (
						if sequence[i].longueur != 0 do (
							longueur_definies_total += sequence[i].longueur * nbr_repetitions
							nbr_elem_definies += 1 * nbr_repetitions
						)			
					)		
					longueur_composant		=  ( longueur - longueur_definies_total  )  	/ ( ( nbr_repetitions *2*sequence.count - nbr_elem_definies)    + 1  )
					*/
					
					local longueur_definies_total 		= 0
					local nbr_elem_definies 			= 0
					for i = 1 to sequence.count do (
						if sequence[i].longueur != 0 do (
							longueur_definies_total+= sequence[i].longueur
							nbr_elem_definies += 1
						)			
					)
					longueur_composant		=  ( longueur - longueur_definies_total  )  	/ (  2*sequence.count - nbr_elem_definies  + 1   )
					
				)
				2: 	(	-----	Repeter -------------------			
					local longueur_definies_total 		= 0
					local nbr_elem_definies 			= 0
					for i = 1 to sequence.count do (
						if sequence[i].longueur != 0 do (
							longueur_definies_total += sequence[i].longueur * nbr_repetitions
							nbr_elem_definies += 1 * nbr_repetitions
						)			
					)		
					longueur_composant		=  ( longueur - longueur_definies_total  )  	/ ( /*  */ ( nbr_repetitions *2*sequence.count - nbr_elem_definies)    + 1  )
				)
				
			) ---- fin case repart --------------------------
			
			local sequence_base =#()
			
			
			--- le premier mur ----------------	
			local compo_murRepart				=	createInstance cp_facadeCompo_mur
			compo_murRepart.longueur		=	longueur_composant 
			compo_murRepart.hauteur			=	hauteur 
			compo_murRepart.profondeur		=	profondeur
			compo_murRepart.low_poly		=	low_poly
			compo_murRepart.matId			=	matId_mur
			
			append sequence_tmp		compo_murRepart
			
			
			
			--- on creer la sequence à construire ----------------------
			local repet_temp = if repartition == 2 then nbr_repetitions else 1
			
-- 			for repet = 1 to repet_temp do (
				for i = 1 to sequence.count do (
					
					--- le composant ----------------
					local compo_temp 				= 	copy sequence[i]
			
					if compo_temp.longueur == 0 do
						compo_temp.longueur 	= 		longueur_composant
					
					compo_temp.hauteur			=	hauteur
					compo_temp.low_poly			=	low_poly
					
					--- hasard ------
					if est_baie	 compo_temp do (
						compo_temp.fen_ouvMax		=	fen_ouvMax
						compo_temp.fen_proba_ouv	=	fen_proba_ouv
					)		 
	
					append sequence_base		compo_temp
-- 					append sequence_tmp		compo_temp
					
					
					
					case repartition of (
						1: 	append sequence_base		compo_murRepart
						2: 	append sequence_base		compo_murRepart
					)
					 
-- 					case repartition of (
-- 						1: 	append sequence_tmp		compo_murRepart
-- 						2: 	append sequence_tmp		compo_murRepart
-- 					)
				) --- fin for sequence ------------------
-- 			)
-- 			for repet = 1 to repet_temp do 	sequence_tmp +=  sequence_base
			for repet = 1 to repet_temp do 	sequence_tmp += for compo in  sequence_base collect copy compo
			
			
			---- le hasard -----------------
			--  on rend unique le compo qui a besoin d'estre ouvert, mais ca rend l'operation plus long a construire -------------
			for i = 1 to sequence_tmp.count do (
-- 				local compo_temp = 
				if est_baie	 sequence_tmp[i] do (
					local est_ouverte =   ( random 0.  100. ) < fen_proba_ouv 
					if est_ouverte 	do
						sequence_tmp[i] = copy sequence_tmp[i]
				)
			)
			 
			
		) ---- fin creation de la sequence ---------------------------
		
		
	)  --- fin composants_actualiser  -----------------------------------------------------------------------
	
	fn actualiser = (
		corriger_parametres ()		
		actualiser_composants()		
		if roll_parametres.open do	roll_parametres.actualiser ()		
		redrawViews ()
		
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	fn ouvrir_parametres		_element =(
		createdialog 	_element.roll_parametres	width:250
	)
	
	--------------- sequence ----------------------------------
	fn ajouter_element_facade		_element_plug	 =(
		
		local	id_elem_select 	= 	roll_parametres.lbx_sequence.selection
		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_element 		= createinstance	_element_plug
		
		if id_elem_select != 0 and id_elem_select	!= sequence.count	then	
			insertItem nvl_element 					sequence 					id_elem_insert
		else		
			append sequence						nvl_element
		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection = id_elem_insert 
			roll_parametres.actualiser ()	
		)
		
	)
	fn retirer_element_facade		_id	 	=(
		
		deleteItem sequence 				_id
		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection -= 1 
			roll_parametres.actualiser ()	
		)
		
	)
	fn monter_element_facade 		_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		deleteItem 	sequence 				_id
		insertItem 	elem_temp			sequence  					(	_id - 1 )
		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection -=  1
			roll_parametres.actualiser ()	
		)
	)
	fn	descendre_element_facade 	_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		deleteItem 	sequence 				_id
		if _id == sequence.count then 
			append sequence 				elem_temp
		else 
			insertItem 	elem_temp		sequence  					(	_id + 1 )
		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection +=  1
			roll_parametres.actualiser ()	
		)
	)
	fn renommer_element_facade	_id	_nv_nom =(
		sequence[ _id ].nom = _nv_nom
		if roll_parametres.open do	roll_parametres.actualiser ()
	)
	
	
	fn dupliquer_element_facade 	_id		=(
		
		
		local nvl_element 			= copy sequence[ _id ]
		
		if _id != 0 and _id	!= sequence.count	then	
			insertItem nvl_element 		sequence 		(_id+1)
		else
			append sequence		nvl_element
		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection = (_id+1) 
			roll_parametres.actualiser ()	
		)
	)
	fn instancier_element_facade 	_id		=(

		
		local nvl_element 			=  sequence[ _id ]
		
		if _id != 0 and _id	!= sequence.count	then	
			insertItem nvl_element 		sequence 		(_id+1)
		else
			append sequence		nvl_element
		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection = (_id+1) 
			roll_parametres.actualiser ()	
		)
	)
	fn rendreUnique_element_facade	_id		=(
		
		sequence[ _id ] = copy sequence[ _id ] 
		
		---- actualisations -----------
		actualiser ()
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
-- 		local chrono_debut = timestamp ()
		
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		
		
		---- la sequence	-----		
		local depos_composant = [ 0, 0, 0 ]
		for i = 1 to	sequence_tmp.count do (
			
			---- le composant -----
			local composant 		= sequence_tmp [i]
			local align_y =	0	-- if est_unPlein	composant then 0 else profondeur - composant.profondeur
			
			mgr_mesh.attacher		mesh		composant	transf:( depos_composant + [0,align_y,0] )
			
			depos_composant.x += composant.longueur
			
		)
		
-- 		local chrono_fin = timeStamp()
-- 		debug  "build mesh :" var:( ((chrono_fin - chrono_debut) / 1000.0) as string + "s.")
		
		
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


