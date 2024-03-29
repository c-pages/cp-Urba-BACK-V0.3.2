
plugin 		simpleObject		cp_facadeCompo_groupe
name:		"Groupe"
classID:		#(0x91ef199, 0x43204119)
category:	"CP | Facade	| Composant"
-- invisible:true
(
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_facadeCompo_groupe"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pr� d�claration -----------
	local corriger_parametres 
	
	--- composant ---
	local compo_cadre, compo_vitrage
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	---- la sequence � construire issue de la sequence	------------------------
	local sequence_aConstruire
	
	--------------- PARAMETERES  ----------------------------------------------------------------------------------------------------------------------
	parameters params_parameters rollout:roll_parametres	(
		
		nom	 					type:#string 		/* 	ui:edTxt_nom	 */						default:"Groupe"
		
-- 		etirable					type:#boolean 		/*  ui:shk_etirable	 */	 				default:false
		
		longueur 				type:#worldUnits		 /*  	ui:spn_longueur  	 */				default:0.
		hauteur	 				type:#worldUnits 	/* ui:spn_hauteur  		*/				default:0.
		
		
		repetition				type:#integer 			ui:spn_repetition		default:1
		
		elements				type:#maxObjectTab		tabSizeVariable:true
		
		parent					type:#maxObject	
		
		
		
-- 		on elements 	tabChanged  	_operation		 _index	_count		do (
-- 			longueur = 0
-- 			for elem in elements do
-- 				longueur += elem.longueur
-- 		)


	/* 
		on longueur 	get 	_arg do (
			debug "###GET	LONGUEUR" var:nom
			local result_longueur = 0
			debug "GET	--	elements" var:elements
			for elem in elements do (
				debug "GET	--	elem" var:elem
				local elem_lg	=	elem.longueur
				debug "GET	--	elem_lg" var:elem_lg
				result_longueur += elem_lg
			)
			debug "GET	--	repetition" var:repetition
			result_longueur *= repetition
			debug "GET	--	LONGUEUR" var:result_longueur
			result_longueur
		)
 */
	)
	
	
	
	parameters params_hasard rollout:roll_hasard
	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
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
	
	
	
	
	
	--------------- ROLLOUTS  ----------------------------------------------------------------------------------------------------------------------
	rollout roll_parametres 				"Param�tres"	(
-- 		editText 	edTxt_nom		 		"Nom:" 	
		spinner 	spn_repetition 		"R�p�tition" 			type:#integer 	range:[1,1e20,0]
-- 			checkbox	shk_etirable			"Etirable" 	
-- 			spinner 	spn_longueur 			"Longueur" 			type:#worldunits 	range:[0,1e20,0]
-- 		fn actualiser =(
-- 			spn_longueur.indeterminate		=	etirable
-- 			spn_longueur.enabled 				=	not	etirable 
-- 		)
-- 		on roll_parametres	open 					do actualiser ()
-- 		on shk_etirable		changed state  	do actualiser ()
	)
	
	
	
	rollout roll_divers  "Divers"	(
		 group "Qualit�" (
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
			spinner spn_fen_ouvMax 			"Max (�)" 		type:#float			 range:[0,180,0]
		)
	
	)
	
	
	
	
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn est_ouvrable		_compo	=	classof	_compo	==	cp_facadeCompo_ensemble
	

	fn get_longueur	=	(
		local result_longueur = 0
		for elem in elements do
			result_longueur += elem.get_longueur ()
		result_longueur *= repetition
		result_longueur
	)
	
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
		for elem in elements do
			elem.set_hasard	_fen_ouvMax	_fen_proba_ouv
	)
	
	
	
	/* 
	-----elements -------------
	fn ajouter_element		_elem	id:		=(
		if id == unsupplied then
			append elements	_elem
		else
			insertItem		_elem		elements		id
		_elem.parent = this
	)
	fn retirer_element		_id		=(
		local elem_avirer	=	elements[_id]
		deleteItem	 elements	_id
		elem_avirer.parent = undefined
		
		elem_avirer
	)
	 */
	
	
	
	fn actualiser_composants	= with redraw off (
		
		sequence_aConstruire 				= 	#()
		
		for elem in elements do (
			
			--- le composant ----------------
			local compo_temp 				= 	copy elem				
			compo_temp.hauteur			=	hauteur
			compo_temp.low_poly			=	low_poly
			compo_temp.set_hasard		fen_ouvMax	fen_proba_ouv
-- 			if est_ouvrable	 compo_temp do (		--- hasard ------
-- 				compo_temp.fen_ouvMax		=	fen_ouvMax
-- 				compo_temp.fen_proba_ouv	=	fen_proba_ouv
-- 			)
			append sequence_aConstruire		compo_temp
			
		) --- fin for sequence ------------------
		
	)  --- fin actualiser_composants  ------------------
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		--- Construction ---------------------------------------------------------------------------------------
		if elements.count == 0	then
			setMesh mesh numverts:0
		else (
			
			---- la sequence	-----		
			local depos_composant = [ 0, 0, 0 ]
			for j = 1 to repetition do (
				for i = 1 to	sequence_aConstruire.count do (
					
					---- le composant -----
					local composant 		= copy sequence_aConstruire [i]
					local align_y =	0	
					mgr_mesh.attacher		mesh		composant	transf:( depos_composant + [0,align_y,0] )
					
					depos_composant.x += composant.get_longueur()
					
				)
			)
		)
		
	)
	
	
	
	
	
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
	
	
	
) ---- fin du plugin --------------------------