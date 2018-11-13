
plugin 		simpleObject		cp_facadeCompo_groupe
name:		"Groupe"
classID:		#(0x5b4e91a1, 0x66f01359)
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
	
	
	
	--------------- PARAMETERES  ----------------------------------------------------------------------------------------------------------------------
	parameters params_general rollout:roll_general	(
		
		elements					type:#maxObjectTab	tabSizeVariable:true
		
	)
	
	
	
	
	--------------- ROLLOUTS  ----------------------------------------------------------------------------------------------------------------------
	rollout roll_general 			"Paramètres"	(
		
	)
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn actualiser_composants	= with redraw off (
		
	)  --- fin actualiser_composants  ------------------
	
	
	
	
	
	---------- Elements ----------------------------------------
	fn ajouter_element		_element =(
		
	)
	fn retirer_element		_element =(
		
	)
	fn monter_element		_element =(
		
	)
	fn descendre_element	_element =(
		
	)
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		--- Construction ---------------------------------------------------------------------------------------
		
		
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