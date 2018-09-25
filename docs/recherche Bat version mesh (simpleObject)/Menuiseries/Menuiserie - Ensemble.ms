
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\mgr - presets.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Fix.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Ouvrant.ms"


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
	local m_sequence 	=	#()
	local mgr_presets 	=	str_presets_manager ()
	
	
	

	
	
	
	
	
	
	
	------------ PARAMETRES	----------------------------------------------------------------------------------------------------------------------
	parameters params_transformation		(
		transformation	type:#matrix3	default:(matrix3 1)
	)
	parameters params_general rollout:roll_general	(
		
		----- global ----------------
		longueur 			type:#worldUnits 	ui:spn_longueur 		default:1E-3
		hauteur	 			type:#worldUnits 	ui:spn_hauteur 		default:1E-3
		epaisseur	 		type:#worldUnits 	ui:spn_epaisseur		default:7
		profondeur	 		type:#worldUnits 	ui:spn_profondeur	default:5		
		
		------	sequence	---------------
		sequence_datas	type:#stringTab		tabSizeVariable:true
		
	)----- fin parameters main	---------------------------
	
	
	
	
	
	
	-----------------    FONCTIONS	 ----------------------------------------------------------------------------------------------------------------------
	fn creer_menuiserie 		_type		long:		haut:		prof:	 epais:	transf:		matId_menuis:		matId_vitrage:	=(
		
		---- on creer le sous objet model ---------------------
		local menuiserie 
		case _type of (
			#fix:				menuiserie = createInstance  urba_menuis_fix	
			#ouvrant:		menuiserie = createInstance  urba_menuis_ouvrant	
		)
		if long 				!= unsupplied do		menuiserie.largeur 				= long		
		if haut 				!= unsupplied do		menuiserie.hauteur 				= haut		
		if prof 				!= unsupplied do		menuiserie.profondeur 			= prof		
		if epais				!= unsupplied do		menuiserie.epaisseur 			= epais		
		if transf				!= unsupplied do		menuiserie.transformation 		= transf		
		if matId_menuis	!= unsupplied do		menuiserie.matId_menuis 		= matId_menuis		
		if matId_vitrage	!= unsupplied do		menuiserie.matId_vitrage 		= matId_vitrage
		
		menuiserie
		
	)
	fn charger_params 			=(
		m_sequence = #()
		for elem_datas in sequence_datas do (
			local nvl_menuiserie 	=  mgr_presets.get_element_from_datas		elem_datas
			append	m_sequence		nvl_menuiserie
		)
	)
	fn enregistrer_params 		=(
		
		sequence_datas = #()
		for elem in m_sequence do (
			local params_menuis 	= mgr_presets.get_params	elem
			append	sequence_datas		params_menuis
		)
		
		redrawviews ()
	)
	
	
	------ sequence ------------
	fn ajouter_element		_type 	=(
		
		debug"ajouter_element"
		
		local nvl_menuis 			= creer_menuiserie 	_type
		append	m_sequence		nvl_menuis
		
		enregistrer_params 	()
		
		nvl_menuis
	)
	fn retirer_element		_id	 	=(
		deleteItem m_sequence 	_id
		enregistrer_params  ()
	)
	fn monter_element 		_id 		=(
		local elem_temp = m_sequence[ _id ]
		deleteItem m_sequence 	_id
		insertItem 	elem_temp		m_sequence  (	_id - 1 )
		enregistrer_params 	()
	)
	fn	descendre_element 	_id 		=(
		local elem_temp = m_sequence[ _id ]
		deleteItem m_sequence 	_id
		insertItem 	elem_temp		m_sequence  (	_id + 1 )
		enregistrer_params 	()
	)
	
	
	
	
	
	
	
	
	
	------------ ROLLOUT	----------------------------------------------------------------------------------------------------------------------
	rollout roll_general	"Ensemble Menuisé"	(
		
		local m_parent
		
		fn ouvrir_RCMenu =(
			
			rcMenu nvMenu
			(
				menuItem btn_fix  					"Fix" 			
				menuItem btn_ouvrant  			"Ouvrant" 	
				
				on btn_fix 				picked do	(
					$.ajouter_element	#fix
					$.roll_general.actualiser ()
					$.roll_general.lbx_sequence.selection = $.roll_general.lbx_sequence.items.count
					$.roll_general.actualiser ()
				)
				on btn_ouvrant		picked do	(
					$.ajouter_element	#ouvrant
					$.roll_general.actualiser ()
					$.roll_general.lbx_sequence.selection = $.roll_general.lbx_sequence.items.count
					$.roll_general.actualiser ()
				)
				
			)
			
			popUpMenu 	nvMenu
		)
		
		
	
		group "Global" (
			spinner 'spn_longueur' 			"Longueur" 		range:[0.001,1e+09,0.001] type:#worldunits align:#right
			spinner 'spn_hauteur' 			"Hauteur"   		range:[0.001,1e+09,0.001] type:#worldunits align:#right
			spinner 'spn_epaisseur'	 	"Epaisseur" 		type:#worldunits range:[0,1000,0] align:#right
			spinner 'spn_profondeur'	 	"Profondeur" 	type:#worldunits range:[0,1000,0] align:#right
		)
		group "Sequence" (
			button		'btn_ajouter_element'		"+" width: 20 height:20 align:#left across:4
			button		'btn_retirer_element'			"-" width: 20 height:20 align:#left
			button		'btn_monter_element'		"/\\" width: 20 height:20 align:#left
			button		'btn_descendre_element'	"\/" width: 20 height:20 align:#left
			listbox		'lbx_sequence' 				"" width:145 height:8 align:#left
-- 			label			'lbl_params'	 					"Parametres: "  align:#left
			subrollout	'subroll_param_elem'		width: 145 height:280 align:#left
		)
		
		
		fn actualiser =(
			
			--- la sequence	-------------			
			local sequence_noms		=	#()
			for  i = 1 to sequence_datas.count do (	
				local elem_data 			= sequence_datas[i]
				local nvl_menuiserie 	=  mgr_presets.get_element_from_datas	elem_data
				local nom 					= ( classof nvl_menuiserie ).name
				append sequence_noms	nom
			)
			lbx_sequence.items = for nom in sequence_noms collect nom
			
			
			--- les boutons --------------
			btn_retirer_element.enabled 			= lbx_sequence.selection != 0
			btn_monter_element.enabled			= lbx_sequence.selection > 1
			btn_descendre_element.enabled		= lbx_sequence.selection !=  lbx_sequence.items.count
			
			
			--- les parametres de l'element (le subrollout)  ---------------			
			if lbx_sequence.selection > 0 do (
				--- on retire les vieux rollouts --------
				if subroll_param_elem.rollouts.count > 0 do 
					for subRoll in subroll_param_elem.rollouts  do
						removeSubRollout subroll_param_elem	subRoll				
				---- on ajoute le nouveau -----------------
				local nvl_menuiserie 	=  m_sequence[  lbx_sequence.selection ]
				addSubRollout 	subroll_param_elem		nvl_menuiserie.roll_general
				nvl_menuiserie.roll_general.m_parent	=	this				
			)
			
		) --- fin actualiser  ------
		
		on roll_general open do (
-- 			if selection.count > 0 do 
				charger_params 	()
			actualiser ()
		)
		
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
	tool create
	(
		on mousePoint click do
		case click of
		(
			1: nodeTM.translation = gridPoint
			3: #stop
		)
		on mouseMove click do
		case click of
		(
			2: (longueur = abs gridDist.x)
			3: hauteur = gridDist.z
		)
	) --- fin tool create
	
	
	
	
	
	
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do
	(
		---- on vide le mesh -----------
		delete mesh
		
		---- la sequence est vide --------------------------
		if sequence_datas.count == 0 then (			
			local nvl_menuiserie	=		creer_menuiserie 	#fix	long:longueur		haut:hauteur		prof:5		epais:epaisseur		--transf:mtrx_insertion
			mesh += nvl_menuiserie.mesh
		
		--------- Sinon on construit la sequence ----------------
		) else (			
			---- preparation longueurs ------------
			local dist_imposees	 	= 	0
			local nbr_divis				=	0
			for elem in m_sequence do 
				if elem.largeur != 0 then
					dist_imposees += elem.largeur 
				else nbr_divis += 1			
			local longueur_elem 	= ( longueur - dist_imposees ) / nbr_divis
			
			---- on pose les éléménts --------------------------
			local mtrx_insertion 		= matrix3 1 * transformation
			for  i = 1 to sequence_datas.count do (	
				
				--- on creer l'element depuis les params du plug	--------------------------------
				local elem_data 					= sequence_datas[i]
				local menuiserie_temp 			=  mgr_presets.get_element_from_datas		elem_data
				
				---- on actualise les paramatres de l'element  (si param == 0 alors on utilise le parametre general ) ---------------
				if menuiserie_temp.largeur 	== 0 	do	menuiserie_temp.largeur 		= longueur_elem				
				if menuiserie_temp.epaisseur	== 0 	do	menuiserie_temp.epaisseur		= epaisseur				
				if menuiserie_temp.hauteur  	== 0 	then	menuiserie_temp.hauteur 		= hauteur
					else (
						local imposte_tmp = creer_menuiserie 	#fix	long:		menuiserie_temp.largeur	\
																						haut:		( hauteur - menuiserie_temp.hauteur  )	\
																						prof:		5	\
																						epais:	menuiserie_temp.epaisseur		\
																						transf:	( mtrx_insertion * transMatrix [0,0, menuiserie_temp.hauteur ] )
						meshop.attach	mesh		imposte_tmp.mesh
					)
				if menuiserie_temp.profondeur  == 0 do	menuiserie_temp.profondeur			= profondeur
				
				----- on place l'élément -----				
				menuiserie_temp.transformation 		= mtrx_insertion
				
				---- on l'attache a notre mesh ---------------
				meshop.attach	mesh		menuiserie_temp.mesh
				
				---- on translate le point d'insertion ---------------
				translate mtrx_insertion ( [ menuiserie_temp.largeur ,0,0]  * transformation )
				
			) 
		) --- fin creation de la sequence -------------
		
	) ---- fin on BUILD ------------------
	on load 						do 	(
		debug "load du plugin"
		charger_params ()
	)
	on clone 	_original 	do (
-- 		initialiser ()
		charger_params ()
	)
	on create do (
-- 		debug "creation du plugin"
-- 		initialiser ()
-- 		actualiser ()
	)
	on update do	(
-- 		debug "update du plugin"
-- 		debug "shape : " var:surface_node
-- 		initialiser ()
	)
	
	
	
	
) -----------	fin plugin --------------------




















