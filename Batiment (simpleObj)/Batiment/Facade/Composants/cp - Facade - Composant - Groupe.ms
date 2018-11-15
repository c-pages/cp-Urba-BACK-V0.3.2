
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
	
	
	---- pré déclaration -----------
	local corriger_parametres 
	
	--- composant ---
	local compo_cadre, compo_vitrage
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	---- la sequence à construire issue de la sequence	------------------------
	local sequence_aConstruire
	
--------------- PARAMETERES  ----------------------------------------------------------------------------------------------------------------------
	parameters params_parameters rollout:roll_parametres	(
		
		nom	 					type:#string 			ui:edTxt_nom							default:"Groupe"
		
		etirable					type:#boolean 		/*  ui:shk_etirable	 */	 				default:false
		
		longueur 				type:#worldUnits		 /*  	ui:spn_longueur  	 */				default:0.
		hauteur	 				type:#worldUnits 	/* ui:spn_hauteur  		*/				default:0.
		
		
		elements				type:#maxObjectTab		tabSizeVariable:true
		
		
	)
	parameters params_divers ---rollout:roll_divers
	(
		
		------ options --------------
		low_poly							type:#boolean 	/* 	ui:shk_lowPoly		 */		default:false
		
	)	-----	fin parametres --------------------
	
	
	
	
	
	
	--------------- ROLLOUTS  ----------------------------------------------------------------------------------------------------------------------

	rollout roll_parametres 				"Paramètres"	(
		editText 	edTxt_nom		 		"Nom:" 	
		spinner 	spn_repetition 		"Répétition" 			type:#integer 	range:[0,1e20,0]
-- 			checkbox	shk_etirable			"Etirable" 	
-- 			spinner 	spn_longueur 			"Longueur" 			type:#worldunits 	range:[0,1e20,0]
-- 		fn actualiser =(
-- 			spn_longueur.indeterminate		=	etirable
-- 			spn_longueur.enabled 				=	not	etirable 
-- 		)
-- 		on roll_parametres	open 					do actualiser ()
-- 		on shk_etirable		changed state  	do actualiser ()
	)
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn actualiser_composants	= with redraw off (
		
	)  --- fin actualiser_composants  ------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		--- Construction ---------------------------------------------------------------------------------------
		setMesh mesh numverts:0
		
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