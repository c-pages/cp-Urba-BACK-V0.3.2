
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\mgr - presets.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Fix.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Ouvrant.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Porte.ms"

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
	local m_sequence 	=	#()
	
	local mgr_constr		=	str_contruction_menuiseries ()
	local mgr_presets 	=	str_presets_manager ()
	
	
	

	
	
	
	
	
	
	
	------------ PARAMETRES	----------------------------------------------------------------------------------------------------------------------
	parameters params_general rollout:roll_general	(
		
		----- global ----------------
		longueur 			type:#worldUnits 	ui:spn_longueur 		default:1E-3
		hauteur	 			type:#worldUnits 	ui:spn_hauteur 		default:1E-3
		epaisseur	 		type:#worldUnits 	ui:spn_epaisseur		default:7
		profondeur	 		type:#worldUnits 	ui:spn_profondeur	default:5		
		
		------	la sequence	---------------
		sequence_datas	type:#stringTab		tabSizeVariable:true
		
	)----- fin parameters main	---------------------------
	
	
	
	
	
	
	-----------------    FONCTIONS	 ----------------------------------------------------------------------------------------------------------------------
	
	
	
	
	
	
	
	------ parametres ---------------------
	fn charger_params 			=(
		m_sequence = #()
		for elem_datas in sequence_datas do
			append	m_sequence		( mgr_presets.get_element_from_datas		elem_datas )		
	)
	fn enregistrer_params 		=(		
		sequence_datas = #()
		for elem in m_sequence do 
			append	sequence_datas		( mgr_presets.get_params		elem )
		redrawviews ()
	)
	
	
	
	
	
	
	------ sequence ------------
	fn ajouter_element		_type 	=(		
		local nvl_menuis 			= mgr_constr.creer_menuiserie 		_type
		append	m_sequence	nvl_menuis		
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
		
		
		fn ouvrir_RCMenu =(
			
			
			
			
			--- POUR CREER MENU A LA VOLEE ---------------
			--- 		popo = for clas in GeometryClass.classes where findstring (clas as string) "Urba"  != undefined collect clas as string			
			--- POUR CREER MENU A LA VOLEE ---------------
			
			
			
			
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
		
		
	
		group "Menuiserie" (
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
			listbox		'lbx_sequence' 				""  height:5 align:#left
			subrollout	'subroll_param_elem'		height:200 align:#left
		)
		
		
		fn actualiser =(
			
			lbx_sequence.items = for elem in m_sequence collect  ( classof elem ).name
			
			
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
				local nvl_menuiserie 		=  m_sequence[  lbx_sequence.selection ]
				nvl_menuiserie.m_parent	=	this				
				addSubRollout 	subroll_param_elem		nvl_menuiserie.roll_general
			)
			
		) --- fin actualiser  ------
		
		on roll_general open do (
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
		if m_sequence.count == 0 then (
			
			mgr_constr.ajouter_menuiserie 	mesh		#fix	long:		longueur		\
																	ht:		hauteur		\
																	prof:		profondeur	\
																	epais:	epaisseur
		
			
			
			
			
		--------- Sinon on construit la sequence ----------------
		) else (
			
			---- preparation longueurs ------------
			local dist_imposees	 	= 	0
			local nbr_divis				=	0
			
			for elem in m_sequence do 	if elem.longueur != 0 
				then		dist_imposees += elem.longueur 
				else 		nbr_divis += 1
			
			local longueur_epaiss		=	epaisseur * ( nbr_divis + 1) 
			local longueur_ss_epaiss	=	( ( longueur - dist_imposees ) - longueur_epaiss )/ nbr_divis			
			local longueur_elem			=	longueur_ss_epaiss + epaisseur
			
			
			
			---- on pose les éléménts --------------------------
			local mtrx_insertion 		= matrix3 1 
			for  i = 1 to sequence_datas.count do (	
				
				
				
				--- on creer l'element depuis les params du plug	--------------------------------
				local elem_data 					= sequence_datas[i]
				local menuiserie_instance 		=  mgr_presets.get_element_from_datas		elem_data
				
				
				----- on gere la longueur de chaque element pour bien centrer les montant -----------------------
				if sequence_datas.count  > 1 then (					
					if i < sequence_datas.count or i == 1		do  	menuiserie_instance.montant_D = false
					if i == sequence_datas.count 				do 	longueur_elem		=	longueur_ss_epaiss +  2*epaisseur					
				) else 	longueur_elem		=	longueur_ss_epaiss +  2*epaisseur
				
				
				
				
				---- on actualise les paramatres de l'element  (si param == 0 alors on utilise le parametre general ) ---------------
				menuiserie_instance.m_parent 		= this
				if menuiserie_instance.longueur 		== 0 	do	menuiserie_instance.longueur 		= longueur_elem 
				if menuiserie_instance.epaisseur		== 0 	do	menuiserie_instance.epaisseur		= epaisseur
				if menuiserie_instance.profondeur  	== 0 	do	menuiserie_instance.profondeur		= profondeur
				if menuiserie_instance.hauteur  		== 0 	then	menuiserie_instance.hauteur 			= hauteur
					else  --- sinon on creer l'imposte --------------
						mgr_constr.ajouter_menuiserie 	mesh		#fix	long:		menuiserie_instance.longueur	\
																	ht:		( hauteur - menuiserie_instance.hauteur  )	\
																	prof:		profondeur	\
																	epais:	epaisseur		\
																	transf:	( mtrx_insertion * transMatrix [0,0, menuiserie_instance.hauteur ] )
					
				
				
				
				--- on stock l'id du vertex pour pouvoir deplacer les point si besoin ----------------
				local id_vertex_debut = ( meshop.getNumVerts mesh + 1 )
				
				--- on l'ajoute a notre mesh ----------
				meshop.attach	mesh		menuiserie_instance.mesh
				
				----- et on place l'élément ---------------
				if transf		!= unsupplied do	
					mgr_constr.transform_vertex		mesh		id_debut:	id_vertex_debut	\
																id_fin:		(meshop.getNumVerts mesh)	\
																transf:		mtrx_insertion
		
				
				---- on translate le point d'insertion ---------------
				translate mtrx_insertion ( [ menuiserie_instance.longueur ,0,0]  )
				
			)
		) --- fin creation de la sequence -------------
		
	) ---- fin on BUILD ------------------
	
	
	
	
	
	
	
	on load 						do 	(
		debug "load du plugin"
		charger_params ()
	)
	on clone 	_original 	do (		
		charger_params ()
	)
	on create do (
		
	)
	on update do	(
		charger_params ()
	)
	
	
	
	
) -----------	fin plugin --------------------




















