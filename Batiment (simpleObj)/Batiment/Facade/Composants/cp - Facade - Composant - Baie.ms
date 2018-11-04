
plugin simpleObject		cp_facadeCompo_baie
name:"Baie"
classID:#(0x6acdec6f, 0x495efeca)
category:"CP | Facade	| Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_facadeCompo_baie"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres , 	actualiser_composants , ouvrir_roll_sequence
	local	ajouter_element_menuis, retirer_element_menuis,dupliquer_element_menuis,  instancier_element_menuis, rendreUnique_element_menuis, monter_element_menuis, descendre_element_menuis, renommer_element
	local est_instance
	
	/* 
		on btn_dupliquer 			pressed 			do	dupliquer_element_menuis 			lbx_sequence.selection 
		on btn_instancier 		pressed 			do	instancier_element_menuis 		lbx_sequence.selection 
		on btn_rendreUnique	pressed 			do	rendreUnique_element_menuis 	lbx_sequence.selection 
		on btn_retirer 			pressed 			do	retirer_element_menuis 			lbx_sequence.selection 
		on btn_monter 			pressed 			do	monter_element_menuis 			lbx_sequence.selection 
		on btn_descendre 		pressed		 	do	descendre_element_menuis 		lbx_sequence.selection 
			 */
	---- sequence provisoire pour construction du mesh -------
	local sequence_tmp
	
	---- composants ---------
	local compo_cadre, compo_meneau
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_global rollout:roll_global	(
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 				default:0.
	)
	parameters params_general rollout:roll_parametres	(
		
		nom	 					type:#string 			ui:edTxt_nom					default:"Baie"
		
		etirable					type:#boolean 		ui:shk_etirable					default:false
		
		longueur 				type:#worldUnits 	ui:spn_longueur 				default:120.
		baie_hauteur			type:#worldUnits 	ui:spn_baie_hauteur			default:-50.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur			default:15.
		allege_hauteur			type:#worldUnits 	ui:spn_allege_hauteur		default:100.
		
		menuis_largeur			type:#worldUnits 	ui:spn_menuis_largeur			default:5.
		menuis_profondeur		type:#worldUnits 	ui:spn_menuis_profondeur		default:7.
		
		sequence					type:#maxObjectTab	tabSizeVariable:true
-- 		sequence_elem_long		type:#floatTab			tabSizeVariable:true
		
	)
	parameters params_divers rollout:roll_divers
	(
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	
	parameters params_hasard rollout:roll_hasard
	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	
	
	rollout roll_global  "Global"	(
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
	)
	rollout roll_parametres  "Paramètres"	(		
		
		--- UI ------------------------------------------------------------------------------------------------------
		
		editText 	edTxt_nom		 	"Nom:" 	
		
		
		group "Dimensions" (
			checkbox	shk_etirable			"Etirable" 	
			spinner 	spn_longueur 			"Longueur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_baie_hauteur 	"Hauteur" 			type:#worldunits 	range:[-1e20,1e20,0]
			spinner 	spn_profondeur		"Profondeur" 		type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_allege_hauteur 	"Allège" 		type:#worldunits 	range:[0,1e20,0]
		)
		group "Menuiserie" (
			spinner 	spn_menuis_largeur 			"Largeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_menuis_profondeur 	"Profondeur" 		type:#worldunits 	range:[0,1e20,0]
			button		btn_editer_sequence		"Editer séquence"	width:110 height:25
		)
		group "Volets" (
			dropDownList	ddl_volet		""	 items:#("Aucun", "Battant", "Roulant")
		)
		
		
		
		
		on btn_editer_sequence pressed do ouvrir_roll_sequence ()
		
		
	)
	rollout roll_sequence  "Séquence"	(	
	
		--- divers ------------------------------------------------------------------------------------------------------
		fn get_menuiserie_plugins =(
			local geo_classes			=	GeometryClass.classes 
			local menuiseries_classes 	= for geo_classe in geo_classes	where findstring ( geo_classe as string )		"cp_baieElement" != undefined		collect	geo_classe
			menuiseries_classes
		)
		
		--- menus clique droit --------------------------------------------------------------
		fn creer_RCM_ajouter	=(

			
			
			--- on recupere les plug necessaires ---------
			local menuiseries_plugins = get_menuiserie_plugins ()
			
			--- on ecrit le menu ---------
			local menu_txt=""
			menu_txt += "rcmenu  menu_ajouter (\n"
			
			---- les boutons ------------------------------------------
			for menuis_plug in menuiseries_plugins do
				menu_txt += "menuItem	btn_" + menuis_plug.name as string + "	\"" + menuis_plug.name + "\"\n" 
			
			---- les evenements ---------------------------------------------
			for menuis_plug in menuiseries_plugins do
				menu_txt += "on		btn_" + menuis_plug.name as string + " picked do $.ajouter_element_menuis " + menuis_plug as string+ "\n" 
			
			--- fin du rc menu -----
			menu_txt += ")"
			
			---- on ouvre le menu -----
			RCmenu_ajouter	=	execute menu_txt
			popUpMenu	RCmenu_ajouter
			
		) --- fin creer_RCM_ajouter ---------------
		fn creer_RCM_edition	=(

			rcmenu  RCmenu_edition (
				
				local this_test
				
				menuItem	btn_dupliquer	 		"Dupliquer" 			enabled:($.est_copiable 	())
				menuItem	btn_instancier	 		"Instancier" 		enabled:($.est_copiable	())
				menuItem	btn_rendreUnique	 	"Rendre unique" 	enabled:($.est_instance	())
				
				on		btn_dupliquer 		picked 	do $.dupliquer_element_menuis ()
				on		btn_instancier 	picked 	do $.instancier_element_menuis ()
				on		btn_rendreUnique picked 	do $.rendreUnique_element_menuis ()
				
			)
			RCmenu_edition.this_test = $
			popUpMenu	RCmenu_edition
			
			format "par LA\n"
		) --- fin creer_RCM_ajouter ---------------
		
		
		
		
		------------------- UI -------------------------
-- 		button 		btn_ajouter 		"+"			across:4
		button 		btn_ajouter_fixe 				"Fixe"				width:50	across:3		align:#left
		button 		btn_ajouter_fenetre 		"Fenêtre"		width:50	align:#left
		button 		btn_ajouter_porte 			"Porte"			width:50	align:#left
		
		listBox		lbx_sequence		""	height:6
		
		button 		btn_dupliquer	 		"Dup."			width:27	height:17	across:6	align:#left
		button 		btn_instancier	 		"Ins."			width:27			height:17			align:#left
		button 		btn_rendreUnique	 	"Uni."			width:27			height:17			align:#left
		button 		btn_retirer	 		"Sup."				width:27		height:17			align:#left
		button 		btn_monter			"/\\"			width:27		height:17		align:#left
		button 		btn_descendre	"\\/"			width:27		height:17		align:#left
		
		subrollout	subroll_param		""	height:200
		
		dotNetControl btn_resize 	"System.Windows.Forms.Button" 		align:#left width:150 height:10
		
		
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
			if lbx_sequence.selection > 0 then 
				addSubRollout 	subroll_param		sequence[  lbx_sequence.selection ].roll_parametres
				
			---- les boutons ------
			btn_retirer.enabled 		= lbx_sequence.selection != 0
			btn_monter.enabled 		= lbx_sequence.selection > 1
			btn_descendre.enabled = lbx_sequence.selection < sequence.count and lbx_sequence.selection != 0
			
			
			
		) --- fin actualiser -----------
		
		
		
		
		----- Gestion du resize du subRollout -----------------------
		local resize_enCours 			= false
		local pos_initial					=	[0,0]
		local subRoll_hauteur_init		=	0
		local btnResize_pos_init		=	[0,0]
		local rollSequence_hauteur_init	=	[0,0]
		fn resize_surbRoll =(
			if resize_enCours do (
				local mouse_pos 			= mouse.posUnscaled
				local changement_ht 	= mouse_pos.y - pos_initial.y
				local subRoll_nvl_ht 	= subRoll_hauteur_init 		+ 	changement_ht
				
				if subRoll_nvl_ht >	50 do (
					subroll_param.height		=	subRoll_nvl_ht
					btn_resize.pos.y			=	btnResize_pos_init.y		+	changement_ht
					roll_sequence.height		=	rollSequence_hauteur_init 	+ 	changement_ht
				)
			)
		)
		
		
		
		
		
		on roll_sequence	open do (
			
			actualiser ()
			
			
			---- le bouton resize -----------------------
			btn_resize.FlatStyle	=		(dotNetClass "System.Windows.Forms.FlatStyle").flat	
			btn_resize.BackColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			btn_resize.ForeColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
		)
		
		
		------------ le bouton resize -----------------------
		on	btn_resize	MouseDown 	do (
			resize_enCours 				= true
			pos_initial						=	mouse.posUnscaled
			subRoll_hauteur_init			= subroll_param.height
			btnResize_pos_init			=	btn_resize.pos
			rollSequence_hauteur_init	=	roll_sequence.height
		)
		on	btn_resize	MouseUp 		do	resize_enCours = false		
		on	btn_resize	MouseMove 	do 	resize_surbRoll ()
		on	btn_resize	MouseLeave 	do	resize_enCours = false		
		
		
		
		-------- la sequence -----------
		
		on lbx_sequence 		selected sel 	do	actualiser ()
		
		on lbx_sequence	 rightClick 	_id 	do	(
			lbx_sequence.selection = _id
			actualiser ()
			creer_RCM_edition ()
			
		)
		
-- 		on btn_ajouter 		pressed 			do 	creer_RCM_ajouter ()
		on btn_ajouter_fixe 			pressed 			do 	ajouter_element_menuis 	cp_baieElement_fixe
		on btn_ajouter_fenetre 	pressed 			do 	ajouter_element_menuis 	cp_baieElement_fenetre
		on btn_ajouter_porte 		pressed 			do 	ajouter_element_menuis 	cp_baieElement_porte
		
		on btn_dupliquer 			pressed 			do	dupliquer_element_menuis 			lbx_sequence.selection 
		on btn_instancier 		pressed 			do	instancier_element_menuis 		lbx_sequence.selection 
		on btn_rendreUnique	pressed 			do	rendreUnique_element_menuis 	lbx_sequence.selection 
		on btn_retirer 			pressed 			do	retirer_element_menuis 			lbx_sequence.selection 
		on btn_monter 			pressed 			do	monter_element_menuis 			lbx_sequence.selection 
		on btn_descendre 		pressed		 	do	descendre_element_menuis 		lbx_sequence.selection 
		
		
	) ---- fin rollout ---------------------
	
	rollout roll_divers  "Divers"	(
		 group "Qualité" (
			checkbox	shk_lowPoly			"Low poly" 		
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
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		/* 
		
		--- longueur de l'ensemble ----------
		local longueur_est_contrainte 	= true
		local longueur_contrainte 			= 0
		for elem in sequence do
			if elem.longueur == 0 do longueur_est_contrainte	=	false
		if longueur_est_contrainte and sequence.count > 0  do (
		for elem in sequence do
				longueur_contrainte += elem.longueur
				longueur_contrainte += menuis_largeur
			)
			longueur_contrainte += menuis_largeur
			longueur = longueur_contrainte
		) */
	)
	
	fn actualiser = (
		corriger_parametres ()		
		actualiser_composants()		
		if roll_sequence.open do	roll_sequence.actualiser ()		
		redrawViews ()
	)
	
	
	
	--------- divers ------------------
	fn est_porte		_compo	=	classof	_compo	==	cp_baieElement_porte
	fn est_fenetre		_compo	=	classof	_compo	==	cp_baieElement_fenetre
	fn est_fixe			_compo	=	classof	_compo	==	cp_baieElement_fixe
	fn est_copiable			=	 roll_sequence.lbx_sequence.selection != 0
	fn est_instance	id:		= (
		if id == unsupplied do id = roll_sequence.lbx_sequence.selection
		local result =false
		for i = 1 to sequence.count where i != id do
			if sequence[i] == sequence[ id] do result = true
		result
	)
	fn get_longueur_composant =(
		local longueur_passage 			= longueur 	- 2*menuis_largeur
		local nbr_meneaux					= sequence.count - 1		
		local longueur_total_meneaux	=	( sequence.count - 1 )* menuis_largeur
		local longueur_definies_total 		= 0
		local nbr_elem_definies 			= 0
		for i = 1 to sequence.count do (
			if sequence[i].longueur != 0 do (
				longueur_definies_total+= sequence[i].longueur
				nbr_elem_definies += 1
			)
		)		
		local longueur_composant	= ( longueur_passage - ( longueur_total_meneaux + longueur_definies_total ) ) / ( sequence.count - nbr_elem_definies )
		
		longueur_composant
	)
	
	fn ouvrir_roll_sequence = (
		
		createDialog roll_sequence	width:180	
	)
	
	----------- Actualisation de la sequence		-----------------------------------
	fn actualiser_composants	= with redraw off (
		
-- 		seed hasard_seed
		
		
		---- creation des composants ------------------
		if compo_cadre 		== undefined	do	compo_cadre		= 	createInstance  cp_compo_cadre
		if compo_meneau		== undefined	do	compo_meneau	= 	createInstance  cp_compo_meneau
		
		local hauteur_baie_tmp 		=  baie_hauteur
		if baie_hauteur <= 0 do hauteur_baie_tmp = hauteur -	( -baie_hauteur + allege_hauteur )
		
		
		
		
		----- maj du cadre ----------------------
		compo_cadre.longueur 						= longueur
		compo_cadre.hauteur 						= hauteur_baie_tmp	
		compo_cadre.profondeur 					= menuis_profondeur
		compo_cadre.menuis_largeur	 			= menuis_largeur	
		compo_cadre.low_poly			 			= low_poly		
		compo_cadre.matId_menuis	 			= matId_menuis
		compo_cadre.travBasse					=	false
		
		----- Meneaux  ----------------------
		compo_meneau.longueur 					= menuis_largeur
		compo_meneau.profondeur 				= menuis_profondeur
		compo_meneau.hauteur 					= hauteur_baie_tmp	-  menuis_largeur
		compo_meneau.low_poly			 		= low_poly		
		
		
		
		--- maj des composants de la sequence -------------
		local longueur_composant	= get_longueur_composant ()
		sequence_tmp 				= #()
		for i = 1 to sequence.count do (
			
			local compo_temp 				= 	copy sequence[i]
	
			if compo_temp.longueur == 0 then		compo_temp.longueur 	= 		longueur_composant
			
			if est_porte 	compo_temp 	then		compo_temp.hauteur	=		hauteur_baie_tmp - menuis_largeur
													else		compo_temp.hauteur	=		hauteur_baie_tmp - 2*menuis_largeur
			
			compo_temp.profondeur		=	menuis_profondeur
			compo_temp.low_poly			=	low_poly
			
			---- hasard ouverture ---------
			if est_porte  compo_temp or est_fenetre compo_temp do (
				local est_ouverte =   ( random 0.  100. ) < fen_proba_ouv 
				if est_ouverte 	then (
					compo_temp.low_poly			=	false
					compo_temp.ouvert_angle_1 = random 0.		fen_ouvMax
					compo_temp.ouvert_angle_2 = random 0.		fen_ouvMax					
				)
			
			)			
			
			append sequence_tmp		compo_temp
		)
		
		
		
		--- Si notre sequence est vide
		if sequence.count == 0 do (
			local compo_temp = createInstance cp_baieElement_fixe
			
			append	sequence_tmp  	compo_temp
			
			compo_temp.hauteur			=	hauteur_baie_tmp 	- 2*menuis_largeur
			compo_temp.profondeur		=	menuis_profondeur
			compo_temp.low_poly			=	low_poly
			compo_temp.longueur			=	longueur 		- 2*menuis_largeur
		)
		
	)  --- fin actualiser_composants  ------------------
	
	
	
	
	
	
	
	--------------- sequence ----------------------------------
	fn ajouter_element_menuis		_element_plug	 =(
		
		local	id_elem_select 	= 	roll_sequence.lbx_sequence.selection
		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_element 		= createinstance	_element_plug
		
		if id_elem_select != 0 and id_elem_select	!= sequence.count	then	
			insertItem nvl_element 		sequence 		id_elem_insert
		 else 		
			append sequence		nvl_element
		---- actualisations -----------
		actualiser ()
		
		if roll_sequence.open do	(
			roll_sequence.lbx_sequence.selection = id_elem_insert 
			roll_sequence.actualiser ()	
		)
		
	)
	fn retirer_element_menuis		_id	 	=(
		
		deleteItem sequence 				_id
		
		---- actualisations -----------
		actualiser ()
	)
	fn monter_element_menuis 		_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		deleteItem 	sequence 				_id
		insertItem 	elem_temp			sequence  					(	_id - 1 )
		
		---- actualisations -----------
		actualiser ()
		
		if roll_sequence.open do	(
			roll_sequence.lbx_sequence.selection -=  1
			roll_sequence.actualiser ()	
		)
	)
	fn	descendre_element_menuis 	_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		deleteItem 	sequence 				_id
		if _id == sequence.count then 
			append sequence 				elem_temp
		else 
			insertItem 	elem_temp		sequence  					(	_id + 1 )		
		
		---- actualisations -----------
		actualiser ()
		
		if roll_sequence.open do	(
			roll_sequence.lbx_sequence.selection +=  1
			roll_sequence.actualiser ()	
		)
	)
	fn renommer_element_menuis	_id	_nv_nom =(
		sequence[ _id ].nom = _nv_nom
		if roll_sequence.open do	roll_sequence.actualiser ()
	)
	
	
	
	--------- edition sequence ---------------
	fn dupliquer_element_menuis _id		=(
		
		
		local nvl_element 			= copy sequence[ _id ]
		
		if _id != 0 and _id	!= sequence.count	then	
			insertItem nvl_element 		sequence 		(_id+1)
		else
			append sequence		nvl_element
		
		---- actualisations -----------
		actualiser ()
		
		if roll_sequence.open do	(
			roll_sequence.lbx_sequence.selection = (_id+1) 
			roll_sequence.actualiser ()	
		)
	)
	fn instancier_element_menuis 	_id		=(

		
		local nvl_element 			=  sequence[ _id ]
		
		if _id != 0 and _id	!= sequence.count	then	
			insertItem nvl_element 		sequence 		(_id+1)
		else
			append sequence		nvl_element
		
		---- actualisations -----------
		actualiser ()
		
		if roll_sequence.open do	(
			roll_sequence.lbx_sequence.selection = (_id+1) 
			roll_sequence.actualiser ()	
		)
	)	
	fn rendreUnique_element_menuis	 _id		=(
		
		sequence[ _id ] = copy sequence[ _id ] 
		
		---- actualisations -----------
		actualiser ()
	)
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		--- Construction ---------------------------------------------------------------------------------------
		---- la BAIE	------------------
		local hauteur_baie_tmp 		= allege_hauteur + baie_hauteur
		if baie_hauteur <= 0 do hauteur_baie_tmp = hauteur +	baie_hauteur
		
		
		---- Allege -----
		local pt_1	=	[0,					0,					0]
		local pt_2	=	[longueur,			0,					0]
		local pt_3	=	[0,					0,					allege_hauteur]
		local pt_4	=	[longueur,			0,					allege_hauteur]
		
		----- tableau bas ------
		local pt_5	=	[longueur,			profondeur,		allege_hauteur]
		local pt_6	=	[0,					profondeur,		allege_hauteur]
		
		----- tableau gauche ------
		local pt_7	=	[0,					profondeur,		hauteur_baie_tmp]
		local pt_8	=	[0,					0,					hauteur_baie_tmp]
		
		----- tableau droit ------
		local pt_9	=	[longueur,			0,					hauteur_baie_tmp]
		local pt_10	=	[longueur,			profondeur,		hauteur_baie_tmp]
		
		----- Imposte ------
		local pt_11	=	[longueur,			0,					hauteur]
		local pt_12	=	[0,					0,					hauteur]
		
		local pts 	= #(pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10, pt_11, pt_12) 
		
		----- on creer les faces ----------------------------------------------------
		
		local faces = #(	[1,2,4], [1,4,3],		[3,4,5], [3,5,6],		[3,6,7], [3,7,8]  ,		[5,4,9], [5,9,10],				[7,10,8], [8,10,9],		[8,9,11], [8,11,12] )
	
		--- mat ID ------
		local matIDs	= for i in faces collect matId_mur
		
		--- on creer les vertex ---------
		setMesh 	mesh 	verts:pts	faces:faces	materialIDs:matIDs
		
		----- On clean le mesh 	--------------
		meshop.autoSmooth		mesh 	#{1..mesh.numfaces} 		10
		meshop.autoEdge 		mesh 	#{1..mesh.Edges.count}	10	
		
		
		
		
		
		
		
		
		----- les composants -------------------------------------------------------------
		---- le cadre  -------
		mgr_mesh.attacher		mesh		compo_cadre 	transf:[0, profondeur  , allege_hauteur ]
		
		
		
		---- la sequence	-----
		local compo_travBas		= 	if low_poly	then	createInstance  cp_prim_boiteL  horizontal:true	else createInstance 	cp_prim_boite
		local depos_composant 	= [ menuis_largeur, profondeur  , allege_hauteur ]
		
		for i = 1 to	sequence_tmp.count do (
			
			---- le composant -----
			local composant 		= sequence_tmp [i]
			local calage_z			= if est_porte		composant		then 	0 else  menuis_largeur			
			local depose_temp 	= if  not est_fixe 	composant 	then  	depos_composant  	+ [0, 	0,		calage_z ]
																					else		depos_composant 	+ [0,		0,		menuis_largeur ]
			
			
			mgr_mesh.attacher		mesh		composant	transf:depose_temp
			
			
			
			---- la traverse du bas ------------
			if not est_porte 	composant 	do (
				compo_travBas.hauteur 		= 	menuis_largeur
				compo_travBas.profondeur		=	menuis_profondeur
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
		
		
		
		
		
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		
		
	)  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				4: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	hauteur 					= length ( gridPoint - pt_hauteur )
			)
	) --- fin tool create ---------
	
	
) ------- fin plugin ---------------------


