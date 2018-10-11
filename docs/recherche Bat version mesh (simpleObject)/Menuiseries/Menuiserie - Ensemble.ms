
include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\recherche - simpleObject - mgr - Construction Menuiseries.ms"





plugin simpleObject 	urba_menuis_ensemble
name:"Ensemble"
classID:#(0x21304168, 0x530c47ab)
category:"CP | Urba | menuiseries"
(
	
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuis_ensemble"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	
	-----------------    VARIABLES ----------------------------------------------------------------------------------------------------------------------
	local roll_general
	local mgr_constr		=	str_contruction_menuiseries ()
	
	
	
	

	
	
	
	
	
	
	
	
	
	------------ PARAMETRES	----------------------------------------------------------------------------------------------------------------------
	parameters params_general rollout:roll_general	(
		
		----- global ----------------
		longueur 				type:#worldUnits 		ui:spn_longueur 		default:1E-3
		hauteur	 				type:#worldUnits 		ui:spn_hauteur 		default:1E-3
		profondeur	 			type:#worldUnits 		ui:spn_profondeur	default:5		
		
		----- les menuiseries -------------
		menuis_epaisseur	 	type:#worldUnits 		ui:spn_epaisseur		default:7
		
	)
	
	
	
	parameters params_sequence rollout:roll_sequence	(
		------	la sequence	---------------
		sequence				type:#maxObjectTab	tabSizeVariable:true
		seq_useGlobSet		type:#boolTab			tabSizeVariable:true
		
	)----- fin parameters main	---------------------------
	
	
	
	
	
	
	
	-----------------    FONCTIONS	 ----------------------------------------------------------------------------------------------------------------------
	fn actualiser_sequence =(
		
		---- preparation longueurs ------------
		local dist_imposees	 	= 	0
		local nbr_divis				=	0
		
		for i = 1 to sequence.count do 	if not seq_useGlobSet[i]
			then		dist_imposees += sequence[i].longueur 
			else 		nbr_divis += 1
		
		local longueur_epaiss		=	menuis_epaisseur * ( nbr_divis + 1) 
		local longueur_ss_epaiss	=	( ( longueur - dist_imposees ) - longueur_epaiss )/ nbr_divis			
		local longueur_elem			=	longueur_ss_epaiss + menuis_epaisseur
		
		
		
		
		/* 
		---- preparation longueurs ------------
		local nbr_elems				=	sequence.count		
		local longueur_epaiss		=	menuis_epaisseur * ( nbr_elems + 1) 
		local longueur_ss_epaiss	=	( longueur  - longueur_epaiss )/ nbr_elems			
		local longueur_elem			=	longueur_ss_epaiss + menuis_epaisseur
		 */
		
		
		---- on pose les éléménts --------------------------
		for  i = 1 to sequence.count  do (
			local elem = sequence[i]
			----- on gere la longueur de chaque element pour bien centrer les montant -----------------------
			if sequence.count  > 1 then (					
				elem.montant_D = 	not ( i < sequence.count or i == 1	)
				if i == sequence.count 				do 	longueur_elem		=	longueur_ss_epaiss +  2*menuis_epaisseur					
			) else 	longueur_elem		=	longueur_ss_epaiss +  2*menuis_epaisseur
			
			if seq_useGlobSet[i]	do (
				elem.longueur 				= 	longueur_elem
				elem.hauteur				=	hauteur
				elem.profondeur 			= 	profondeur
				elem.menuis_epaisseur 	= 	menuis_epaisseur
			)
		)
		
		redrawviews ()
		
	)
	
	
	
	
	
	------ sequence ------------
	fn ajouter_element		_type 	=(		
		local nvl_menuis 		= mgr_constr.creer_menuiserie 		_type
		append	sequence			nvl_menuis
		append 	seq_useGlobSet	true
		actualiser_sequence()
		nvl_menuis
	)
	fn retirer_element		_id	 	=(
		deleteItem sequence 			_id
		deleteItem seq_useGlobSet 	_id
		actualiser_sequence()
	)
	fn monter_element 		_id 		=(
		local elem_temp = sequence[ _id ]
		local elem_globSet_temp = sequence[ _id ]
		deleteItem 	sequence 			_id
		deleteItem 	seq_useGlobSet 	_id
		insertItem 	elem_temp					sequence  			(	_id - 1 )
		insertItem 	elem_globSet_temp		seq_useGlobSet  	(	_id - 1 )
		actualiser_sequence()
	)
	fn	descendre_element 	_id 		=(
		local elem_temp = sequence[ _id ]
		local elem_globSet_temp = sequence[ _id ]
		deleteItem sequence 	_id
		deleteItem seq_useGlobSet 	_id
		insertItem 	elem_temp					sequence  			(	_id + 1 )
		insertItem 	elem_globSet_temp		seq_useGlobSet  	(	_id + 1 )
		actualiser_sequence()
	)
	
	
	
	
	
	
	------------ ROLLOUT	----------------------------------------------------------------------------------------------------------------------
	rollout roll_general	"Global"	(
		
		spinner 'spn_longueur' 			"Longueur" 			range:[0.001,1e+09,0.001] type:#worldunits align:#right
		spinner 'spn_hauteur' 			"Hauteur"   			range:[0.001,1e+09,0.001] type:#worldunits align:#right
		spinner 'spn_profondeur'	 	"Profondeur" 		type:#worldunits range:[0,1000,0] align:#right
		spinner 'spn_epaisseur'	 	"Menuiseries" 		type:#worldunits range:[0,1000,0] align:#right

		
		----- global ---------
		on spn_longueur 					changed val do actualiser_sequence ()
		on spn_hauteur 					changed val do actualiser_sequence ()
		on spn_profondeur				changed val do actualiser_sequence ()
		on spn_epaisseur 				changed val do actualiser_sequence ()
		
	)
	rollout roll_sequence	"Séquence"	(
		
		fn ouvrir_RCMenu =(
			--- POUR CREER MENU A LA VOLEE ---------------
			--- 		popo = for clas in GeometryClass.classes where findstring (clas as string) "Urba"  != undefined collect clas as string			
			--- POUR CREER MENU A LA VOLEE ---------------
			
			rcMenu nvMenu			
			(
				menuItem btn_fix  					"Fix" 			
				menuItem btn_ouvrant  			"Ouvrant" 	
				menuItem btn_porte  				"Porte" 	
				
				on btn_fix 				picked do	(
					$.ajouter_element	#fix
					$.roll_sequence.actualiser ()
					$.roll_sequence.lbx_sequence.selection = $.roll_sequence.lbx_sequence.items.count
					$.roll_sequence.actualiser ()
				)
				on btn_ouvrant		picked do	(
					$.ajouter_element	#ouvrant
					$.roll_sequence.actualiser ()
					$.roll_sequence.lbx_sequence.selection = $.roll_sequence.lbx_sequence.items.count
					$.roll_sequence.actualiser ()
				)
				on btn_porte		picked do	(
					$.ajouter_element	#porte
					$.roll_sequence.actualiser ()
					$.roll_sequence.lbx_sequence.selection = $.roll_sequence.lbx_sequence.items.count
					$.roll_sequence.actualiser ()
				)
				
			)
			
			popUpMenu 	nvMenu
		) --- fin ouvrir_RCMenu ----
		
		
		
		button		'btn_ajouter_element'		"+" width: 20 height:20 align:#left across:4
		button		'btn_retirer_element'			"-" width: 20 height:20 align:#left
		button		'btn_monter_element'		"/\\" width: 20 height:20 align:#left
		button		'btn_descendre_element'	"\/" width: 20 height:20 align:#left
		listbox		'lbx_sequence' 				""  height:5 align:#left
		
		checkbox	shk_useGlobalSet				"Use global settings" 				
		
		subrollout	'subroll_param_elem'				height:300 align:#left
		
		
		fn actualiser =(
			
			lbx_sequence.items = for elem in sequence collect  ( classof elem ).name
			
			--- les boutons --------------
			btn_retirer_element.enabled 			= lbx_sequence.selection != 0
			btn_monter_element.enabled			= lbx_sequence.selection > 1
			btn_descendre_element.enabled		= lbx_sequence.selection !=  lbx_sequence.items.count
			
			if seq_useGlobSet.count > 0 then (
				shk_useGlobalSet.enabled 		= true 
				shk_useGlobalSet.checked		=	seq_useGlobSet[ lbx_sequence.selection  ]
			) else 
				shk_useGlobalSet.enabled 		= false
			
			
			
			--- les parametres de l'element (le subrollout)  ---------------			
			if lbx_sequence.selection > 0 do (
				
				--- on retire les vieux rollouts --------
				if subroll_param_elem.rollouts.count > 0 do 
					for subRoll in subroll_param_elem.rollouts  do
						removeSubRollout subroll_param_elem	subRoll
				
				---- on ajoute le nouveau -----------------
				local nvl_menuiserie 		=  sequence[  lbx_sequence.selection ]
				nvl_menuiserie.m_parent	=	this				
				addSubRollout 	subroll_param_elem		nvl_menuiserie.roll_general
				
				for contro in nvl_menuiserie.roll_general.controls do 
					contro.enabled = not shk_useGlobalSet.checked
				
			)
			
		) --- fin actualiser  ------
		
		
		
		
		on roll_sequence open do	actualiser ()
		
		on shk_useGlobalSet changed state do (
			seq_useGlobSet[ lbx_sequence.selection  ] = state
			actualiser ()
		)
			
		----- sequence ---------
		on btn_ajouter_element pressed 		do 	ouvrir_RCMenu ()
		on btn_retirer_element pressed 			do 	(
			retirer_element 		lbx_sequence.selection
			lbx_sequence.selection -= 1
			actualiser ()
		)
		on lbx_sequence selected sel 			do	actualiser ()
		on btn_monter_element pressed 		do 	(
			monter_element 		lbx_sequence.selection
			lbx_sequence.selection -= 1
			actualiser ()
		)
		on btn_descendre_element pressed 	do 	(
			descendre_element 	lbx_sequence.selection
			lbx_sequence.selection += 1
			actualiser ()
		)
		
	) ----- fin rollout ---------------------------
	
	
	
	
	
	
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create	(
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
		
		
		
		
		
		
		
		
	) --- fin tool create
	
	
	
	
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do
	(
		---- on vide le mesh -----------
		delete mesh
		
		---- si la sequence est vide on fait un fixe de base --------------------------
		if sequence.count == 0 then (
			
			mgr_constr.ajouter_menuiserie 	mesh		#fix	long:		longueur		\
																			ht:		hauteur		\
																			prof:		profondeur	\
																			epais:	menuis_epaisseur
			
		--------- Sinon on construit la sequence ----------------
		) else (
			
			
			---- on pose les éléménts --------------------------
			local mtrx_insertion 		= matrix3 1 
			for  elem in  sequence do	(
				local nv_mesh = copy elem.mesh
				mgr_constr.transform_vertex		nv_mesh	transf:mtrx_insertion
				
				--- on l'ajoute a notre mesh ----------
				meshop.attach	mesh		nv_mesh
				
				---- on maj le point d'insertion ---------------
				translate mtrx_insertion ( [ elem.longueur ,0,0]  )
				
			)
			
		) --- fin creation de la sequence -------------
		
	) ---- fin on BUILD ------------------
	
	
	
	
	
	
	
	on load 						do 	(
		debug "load du plugin"
-- 		charger_params ()
	)
	on clone 	_original 	do (		
-- 		charger_params ()
	)
	on create do (
		
	)
	on update do	(
-- 		charger_params ()
	)
	
	
	
	
) -----------	fin plugin --------------------




















