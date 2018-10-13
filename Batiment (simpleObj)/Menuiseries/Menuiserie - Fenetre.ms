


plugin simpleObject		urba_menuiserie_fenetre
name:"Fenêtre"
classID:#(0x485379cf, 0x2fa066d9)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuiserie_fixe"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local composants_actualiser 
	
	--- le manager de primitives---------------	
	local mgr_compo	=	str_mgr_menuiseries_composants ()
	
	--- le manager de primitives---------------	
	local mgr_prim	=	str_mgr_primitives ()
	
	
	
	parameters params_general rollout:roll_general
	(
		
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- les menuiseries -----------
		cadre_epaisseur	 			type:#worldUnits 	ui:spn_cadre_ep			default:0.
		
		----- ouvrants ---------------------
		ouvrant_epaisseur	 		type:#worldUnits 	ui:spn_ouvrant_ep		default:0.	
		ouvrant_profondeur	 		type:#worldUnits 	ui:spn_ouvrant_prof		default:0.	
		ouvrant_decallage	 		type:#worldUnits 	ui:spn_ouvrant_decal	default:0.	
		div_horiz		 				type:#integer		 	ui:spn_div_horiz			default:0.
		div_verti			 				type:#integer		 	ui:spn_div_verti			default:0.
		div_epaisseur	 				type:#worldUnits 	ui:spn_div_epaisseur		default:0.
		
		inverser							type:#boolean 		ui:shk_inverser			default:false
		ouvert_angle_1				type:#float 			ui:spn_angle_1			default:0.
		fen_double						type:#boolean 		ui:shk_double				default:false
		ouvert_angle_2				type:#float 			ui:spn_angle_2			default:0.
		
		----- les composants -----------	
		compo_cadre					type:#maxObject
		compo_ouvrant				type:#maxObject
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
		on longueur					set val 	do	composants_actualiser ()
		on profondeur					set val 	do	composants_actualiser ()
		on hauteur						set val 	do	composants_actualiser ()
		on cadre_epaisseur			set val 	do	composants_actualiser ()
		
		on ouvrant_epaisseur		set val 	do	composants_actualiser ()
		on ouvrant_profondeur		set val 	do	composants_actualiser ()
		on ouvrant_decallage		set val 	do	(
			if val > profondeur do ouvrant_decallage = profondeur
			composants_actualiser ()
			
			
		)
		on div_horiz					set val 	do	composants_actualiser ()
		on div_verti					set val 	do	composants_actualiser ()
		on div_epaisseur				set val 	do	composants_actualiser ()
		
		on inverser						set val 	do	composants_actualiser ()
		on ouvert_angle_1			set val 	do	composants_actualiser ()
		on fen_double					set val 	do	composants_actualiser ()
		on ouvert_angle_2			set val 	do	composants_actualiser ()
		
		
		on low_poly					set val 	do	composants_actualiser ()
		
		on matId_menuis				set val 	do	composants_actualiser ()
		on matId_vitrage				set val 	do	composants_actualiser ()
		
	)	-----	fin parametres --------------------
	
	
	
	
	rollout roll_general  "Fenêtre"
	(
		group "Global" (
			spinner spn_longueur 				"longueur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_hauteur 				"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_profondeur 			"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner spn_cadre_ep	 			"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
		)
		group "Ouvrant" (	
			spinner spn_ouvrant_prof			"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner spn_ouvrant_ep			"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_ouvrant_decal		"Décallage" 			type:#worldunits 	range:[0,1e20,0]
		)
		group "Ouvrant" (	
			spinner 	spn_div_epaisseur	"Divisions ép." 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_div_horiz	 		"Div. Horizontale" 	type:#integer			range:[0,1e20,0]
			spinner 	spn_div_verti	 		"Div. Verticale" 		type:#integer			range:[0,1e20,0]
			
			checkbox	shk_inverser			"inverser"
			spinner 	spn_angle_1	 		"Ouvertue 1" 			type:#float				range:[0,180,0]
			checkbox	shk_double				"double"
			spinner 	spn_angle_2	 		"Ouvertue 2" 			type:#float				range:[0,180,0]
			
		)
		
		group "Qualité" (
			checkbox	shk_lowPoly			"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn composants_actualiser	= with redraw off (
		
		------ definition initiales----------
		
		---- maj du cadre ------------------
		compo_cadre.longueur 						= longueur
		compo_cadre.profondeur 					= profondeur
		compo_cadre.hauteur 						= hauteur
		compo_cadre.menuis_epaisseur 			= cadre_epaisseur
		
		compo_cadre.low_poly			 			= low_poly
		
		compo_cadre.matId_menuis	 			= matId_menuis
		
		---- maj ouvrant		----
		if not fen_double then 
			compo_ouvrant.longueur 				= longueur - 2* cadre_epaisseur
		else
			compo_ouvrant.longueur 				= (longueur - 2* cadre_epaisseur ) / 2
	
		compo_ouvrant.profondeur 				= ouvrant_profondeur
		compo_ouvrant.hauteur 					= hauteur	- 2* cadre_epaisseur
		compo_ouvrant.menuis_epaisseur 		= ouvrant_epaisseur
		compo_ouvrant.traverse_B_epaisseur	= ouvrant_epaisseur
		
		compo_ouvrant.low_poly			 		= low_poly
		
		compo_ouvrant.matId_menuis	 		= matId_menuis
		compo_ouvrant.matId_vitrage	 		= matId_vitrage
		
		compo_ouvrant.div_horiz 					= div_horiz
		compo_ouvrant.div_verti 					= div_verti
		compo_ouvrant.div_epaisseur				= div_epaisseur
		
	)  --- fin composants_actualiser  ------------------
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		---- la base -------
		meshop.attach	mesh		compo_cadre.mesh
		
		---- ouvrants -----------
-- 		if not fen_double then (
			local transf_ouvrant
			if  inverser and not fen_double	then 
				transf_ouvrant = ( transMatrix	[ -(longueur - 2* cadre_epaisseur), 0 ,	0 ]  * rotateZMatrix -ouvert_angle_1  * transMatrix	[longueur - cadre_epaisseur, ouvrant_decallage ,	cadre_epaisseur ]  )
			else
				transf_ouvrant = ( rotateZMatrix ouvert_angle_1 * transMatrix	[cadre_epaisseur, ouvrant_decallage ,	cadre_epaisseur ] )
			
			compo_ouvrant_mesh	=	copy	compo_ouvrant.mesh
			mgr_prim.transformer		compo_ouvrant_mesh		transf:transf_ouvrant
			meshop.attach	mesh		compo_ouvrant_mesh
			
			if  fen_double do (
				transf_ouvrant_2 = ( transMatrix	[ -(longueur - 2* cadre_epaisseur)/2, 0 ,	0 ]  * rotateZMatrix -ouvert_angle_2   * transMatrix	[longueur - cadre_epaisseur, ouvrant_decallage ,	cadre_epaisseur ]   )
				compo_ouvrant_mesh	=	copy	compo_ouvrant.mesh
				mgr_prim.transformer		compo_ouvrant_mesh		transf:transf_ouvrant_2
				meshop.attach	mesh		compo_ouvrant_mesh
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
					
					composants_actualiser ()
					
					pt_profondeur	=	gridPoint
					
					
				)
				3:	(
					profondeur 				= 	length ( gridPoint - pt_profondeur )
					
					composants_actualiser ()
					
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
					
					composants_actualiser ()
					
				)
				5: (
					cadre_epaisseur 	= length ( gridPoint - pt_epaisseur )	
					ouvrant_decallage = cadre_epaisseur /2	
					
					composants_actualiser ()
				)
					
			)		
	) --- fin tool create ---------
	
	on create do (
		compo_cadre			= 	mgr_compo.get_cadre ()
		compo_ouvrant		= 	mgr_compo.get_chassis ()
	)
) ------- fin plugin ---------------------






		


