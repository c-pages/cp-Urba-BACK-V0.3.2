
plugin simpleObject		urba_menuiserie_ensemble
name:"Ensemble"
classID:#(0x3872840c, 0xa1a0c21)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuiserie_ensemble"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres , 	actualiser_composants 
	
	--- composant ---
	local compo_cadre, compo_montants
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_general rollout:roll_general
	(
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 					default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur				default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 					default:0.
		
		----- les menuiseries -----------
		cadre_largeur					type:#worldUnits 	ui:spn_cadre_largeur			default:0.	
		montants_largeur				type:#worldUnits 	ui:spn_montants_largeur		default:0.	
		montants_profondeur		type:#worldUnits 	ui:spn_montants_profondeur	default:0.	
		
		on longueur 					set val do actualiser_composants ()
		on profondeur 				set val do actualiser_composants ()
		on hauteur 					set val do actualiser_composants ()
		on cadre_largeur				set val do actualiser_composants ()
		on montants_largeur 		set val do actualiser_composants ()
		on montants_profondeur	set val do actualiser_composants ()
	)
	
	parameters params_divers rollout:roll_divers
	(
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
		on low_poly		set val do actualiser_composants ()
		on matId_menuis	set val do actualiser_composants ()
		on matId_vitrage	set val do actualiser_composants ()
		
	)	-----	fin parametres --------------------
	
	parameters params_sequence rollout:roll_sequence
	(
		sequence	type:#maxObjectTab	tabSizeVariable:true
	)
	
	rollout roll_general  "Paramètres"
	(
		
		spinner spn_longueur 				"longueur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_hauteur 				"Hauteur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_profondeur 			"Profondeur" 			type:#worldunits range:[0,1e20,0]
		
		group "Menuiserie" (
			spinner spn_cadre_largeur	"Largeur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_montants_largeur	"Largeur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_montants_profondeur	"Largeur" 				type:#worldunits 	range:[0,1e20,0]
			
			
			
		)
		
	)
	
	rollout roll_sequence  "Séquence"
	(
		
		fn get_menuiserie_plugins =(
			local geo_classes			=	GeometryClass.classes 
			local menuiseries_classes 	= for geo_classe in geo_classes	where findstring ( geo_classe as string )		"urba_menuiserie_" != undefined	 and geo_classe != urba_menuiserie_ensemble	collect	geo_classe
			menuiseries_classes
		)
		fn creer_RCM_ajouter	=(
			--- on recupere les plug necessaires ---------
			local menuiseries_plugins = get_menuiserie_plugins ()
			
			--- on ecrit le menu ---------
			local menu_txt=""
			menu_txt += "rcmenu  menu_ajouter (\n"
			---- les boutons ----
			for menuis_plug in menuiseries_plugins do
				menu_txt += "menuItem	btn_" + menuis_plug.name as string + "	\"" + menuis_plug.name + "\"\n" 
			---- les evenements ----
			for menuis_plug in menuiseries_plugins do
				menu_txt += "on		btn_" + menuis_plug.name as string + " picked do $.ajouter_element " + menuis_plug as string+ "\n" 
			menu_txt += ")"
			
			---- on ouvre le menu -----
			execute menu_txt
			popUpMenu	menu_ajouter
			
		) --- fin creer_RCM_ajouter ---------------
		
		
		
		button 		btn_ajouter 		"+"			across:4
		button 		btn_retirer	 		"-"			
		button 		btn_monter			"/\\"			
		button 		btn_descendre	"\\/"			
		listBox		lbx_sequence		""	height:5
		subrollout	subroll_param		""	height:500
		
		fn actualiser =(
			lbx_sequence.items =  for compo in sequence collect ( classof compo ).name
			
			--- les parametres de l'element (le subrollout)  ---------------			
			if lbx_sequence.selection > 0 do (
				
				--- on retire les vieux rollouts --------
				if subroll_param.rollouts.count > 0 do 
					for subRoll in subroll_param.rollouts  do
						removeSubRollout subroll_param	subRoll
				
				---- on ajoute le nouveau -----------------
				local composant_actif 		=  sequence[  lbx_sequence.selection ]
				addSubRollout 	subroll_param		composant_actif.roll_general
				/* 
				for contro in nvl_menuiserie.roll_general.controls do 
					contro.enabled = not shk_useGlobalSet.checked
				 */
			)
		)
		
		
		
		
		
		on roll_sequence	open do actualiser ()
		on btn_ajouter pressed do creer_RCM_ajouter ()
		on lbx_sequence selected sel 			do	actualiser ()
		
		
		
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
	
	
	
	--------------- comopsants ----------------------------------
	fn actualiser_composants	= with redraw off (
		
		
		---- creation des composants ------------------
		if compo_cadre 		== undefined	do	compo_cadre		= 	createInstance  menuiserie_composant_cadre
		if compo_montants	== undefined	do	compo_montants	= 	createInstance  urba_primitive_boite
		
		
		----- maj du cadre ----------------------
		compo_cadre.longueur 						= longueur
		compo_cadre.profondeur 					= profondeur
		compo_cadre.hauteur 						= hauteur		
		compo_cadre.menuis_largeur	 			= cadre_largeur	
		compo_cadre.travBasse_hauteur	 		= cadre_largeur	
		compo_cadre.travBasse		 			= true	
		compo_cadre.low_poly			 			= low_poly		
		compo_cadre.matId_menuis	 			= matId_menuis
		
		----- montants ----------------------
		compo_montants.longueur 				= montants_largeur
		compo_montants.profondeur 				= montants_profondeur
		compo_montants.hauteur 					= hauteur	- 2* cadre_largeur
		
		--- maj des composants de la sequence -------------
		local longueur_composant	=	( longueur	- 2* cadre_largeur - ( sequence.count - 1 )* compo_montants.longueur )	/	sequence.count
		for composant in sequence do (
			
			composant.longueur			=	longueur_composant
			composant.hauteur			=	hauteur - 2*cadre_largeur
			composant.profondeur		=	profondeur
			composant.cadre_use		= false
			composant.low_poly			=	low_poly
		)
	)  --- fin composants_actualiser  ------------------
	
	
	--------------- sequence ----------------------------------
	fn ajouter_element	_element_plug	 =(
		
		debug "AJOUTER" var: _element_plug
		local nvel_element = createinstance	_element_plug
		append sequence	nvel_element
		
		actualiser_composants()
		if roll_sequence.open do
				roll_sequence.actualiser ()
	)
	fn retirer_element		_id	 	=(
		deleteItem sequence 			_id
		actualiser_composants()
	)
	fn monter_element 		_id 		=(
		local elem_temp = sequence[ _id ]
		deleteItem 	sequence 			_id
		insertItem 	elem_temp					sequence  			(	_id - 1 )
		actualiser_composants()
	)
	fn	descendre_element 	_id 		=(
		local elem_temp = sequence[ _id ]
		deleteItem sequence 	_id
		insertItem 	elem_temp					sequence  			(	_id + 1 )
		actualiser_composants()
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		
		--- vider le mesh --------
		delete mesh
		
		---- le cadre  -------
		mesh	+	compo_cadre.mesh
		
		---- la sequence	-----
		local depos_composant = [ cadre_largeur, 0, cadre_largeur ]
		for i = 1 to	sequence.count do (
			
			---- le composant -----
			local composant = sequence [i]
			mgr_mesh.attacher		mesh		composant	transf:depos_composant
			depos_composant.x += composant.longueur
			
			--- le montant- ----
			if i != sequence.count do (				
				mgr_mesh.attacher		mesh		compo_montants	transf:depos_composant
				depos_composant.x += compo_montants.longueur
			)
		)
		
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
				5: #stop
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
					
					pt_profondeur	=	gridPoint
					
				)
				3:	(
					 	profondeur			= 	length ( gridPoint - pt_profondeur )
							
						montants_profondeur	=	profondeur
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
					
				)
				5: (
					cadre_largeur			 	= length ( gridPoint - pt_epaisseur )	
					montants_largeur	= cadre_largeur
				)
					
			)		
	) --- fin tool create ---------
	
	
	
)		------- fin plugin		-----------------










