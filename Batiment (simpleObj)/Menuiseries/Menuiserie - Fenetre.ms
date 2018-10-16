


plugin simpleObject		urba_menuiserie_fenetre
name:"Fenêtre"
classID:#(0x485379cf, 0x2fa066d9)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuiserie_fenetre"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	----- les composants -----------	
	local	compo_cadre					
	local	compo_ouvrant
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	parameters params_general rollout:roll_general
	(
		
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- les menuiseries -----------
		cadre_epaisseur	 			type:#worldUnits 	ui:spn_cadre_ep			default:0.
		montant_G						type:#boolean 		ui:shk_montant_G		default:true
		montant_D						type:#boolean 		ui:shk_montant_D		default:true
		traverse_B						type:#boolean 		ui:shk_traverse_B		default:true
		
		----- ouvrants ---------------------
		ouvrant_epaisseur	 		type:#worldUnits 	ui:spn_ouvrant_ep		default:0.	
		ouvrant_profondeur	 		type:#worldUnits 	ui:spn_ouvrant_prof		default:0.	
		ouvrant_decallage	 		type:#worldUnits 	ui:spn_ouvrant_decal	default:0.	
		div_horiz		 				type:#integer		 	ui:spn_div_horiz			default:0.
		div_verti			 				type:#integer		 	ui:spn_div_verti			default:0.
		div_epaisseur	 				type:#worldUnits 	ui:spn_div_epaisseur		default:0.
		
		inverser							type:#boolean 		ui:shk_inverser			default:false
		ouvert_angle_1				type:#float 			ui:spn_angle_1			default:0.
		ouvrant_double						type:#boolean 		ui:shk_double				default:false
		ouvert_angle_2				type:#float 			ui:spn_angle_2			default:0.
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
		on ouvrant_decallage		set val 	do	corriger_parametres ()
		
	)	-----	fin parametres --------------------
	
	
	
	
	rollout roll_general  "Fenêtre"
	(
		group "Global" (
			spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_profondeur 		"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_cadre_ep	 		"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
			checkbox	shk_montant_G		"Montant gauche" 			
			checkbox	shk_montant_D		"Montant droit" 
			checkbox	shk_traverse_B		"traverse basse" 	
		)
		group "Ouvrant" (	
			spinner spn_ouvrant_prof			"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner spn_ouvrant_ep			"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_ouvrant_decal		"Décallage prof." 		type:#worldunits 	range:[0,1e20,0]
			checkbox	shk_inverser			"inverser"
			spinner 	spn_angle_1	 		"Ouvertue 1" 			type:#float				range:[0,180,0]
			checkbox	shk_double				"double"
			spinner 	spn_angle_2	 		"Ouvertue 2" 			type:#float				range:[0,180,0]
		)
		group "Division" (	
			spinner 	spn_div_epaisseur	"Divisions ép." 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_div_horiz	 		"Div. Horizontale" 	type:#integer			range:[0,1e20,0]
			spinner 	spn_div_verti	 		"Div. Verticale" 		type:#integer			range:[0,1e20,0]
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
	---- les parametres ----------------
	fn corriger_parametres 	=(
		if ouvrant_decallage > profondeur - ouvrant_profondeur do ouvrant_decallage = profondeur - ouvrant_profondeur
	)
	---- les composants ---------------------
	fn composants_actualiser	= with redraw off (
		
		---- creation des composants ------------------
		if compo_cadre 	== undefined	do	compo_cadre			= 	createInstance  menuiserie_composant_cadre
		if compo_ouvrant == undefined	do	compo_ouvrant		= 	createInstance  menuiserie_composant_chassis		
		
		local longueur_passage = longueur
		if montant_G do longueur_passage -=  cadre_epaisseur
		if montant_D do longueur_passage -=  cadre_epaisseur
		local hauteur_passage = hauteur - cadre_epaisseur
		if traverse_B do hauteur_passage -= cadre_epaisseur
		
		
		---- maj du cadre ------------------
		compo_cadre.longueur 						= longueur
		compo_cadre.profondeur 					= profondeur
		compo_cadre.hauteur 						= hauteur
		compo_cadre.menuis_epaisseur 			= cadre_epaisseur		
		compo_cadre.montant_G	 				= montant_G
		compo_cadre.montant_D	 				= montant_D
		compo_cadre.traverse_B	 				= traverse_B
		compo_cadre.low_poly			 			= low_poly		
		compo_cadre.matId_menuis	 			= matId_menuis
		
		---- maj ouvrant		----
		if not ouvrant_double then 
			compo_ouvrant.longueur 				= longueur_passage
		else
			compo_ouvrant.longueur 				= longueur_passage / 2
	
		compo_ouvrant.profondeur 				= ouvrant_profondeur
		compo_ouvrant.hauteur 					= hauteur_passage
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
		
		composants_actualiser ()
		
		--- vider le mesh --------
		delete mesh
		
		---- le cadre -------
		mgr_mesh.attacher		mesh		compo_cadre
		
		----Données ------------	
		local origine_ouv_1
		local rotate_ouv_1
		local recalle_ouv_1
		
		local origine_ouv_2
		local rotate_ouv_2
		local recalle_ouv_2
		
		local longueur_ouvrant = compo_ouvrant.longueur 
		local callage_montant_G = if montant_G then cadre_epaisseur else 0
		local callage_montant_D = if montant_D then cadre_epaisseur else 0
		local ouvrant_pos_z = if traverse_B then cadre_epaisseur else 0
		if  inverser and not ouvrant_double	then (
			origine_ouv_1	=	transMatrix	[ -longueur_ouvrant, - ouvrant_profondeur ,	ouvrant_pos_z ]	
			rotate_ouv_1	=	rotateZMatrix -ouvert_angle_1
			recalle_ouv_1	=	transMatrix	[longueur - callage_montant_G, ouvrant_decallage + ouvrant_profondeur ,	0 ]
		) else (
			origine_ouv_1	=	transMatrix	[ 0, -ouvrant_profondeur,	ouvrant_pos_z ]
			rotate_ouv_1	=	rotateZMatrix 	ouvert_angle_1 
			recalle_ouv_1	=	transMatrix	[callage_montant_G, ouvrant_decallage + ouvrant_profondeur,	0 ]
		)
		if  ouvrant_double do (			
			origine_ouv_2	=	transMatrix	[ -longueur_ouvrant, -ouvrant_profondeur ,	ouvrant_pos_z ]
			rotate_ouv_2 	=  rotateZMatrix -ouvert_angle_2
			recalle_ouv_2	=	transMatrix	[longueur - callage_montant_D, ouvrant_decallage+ ouvrant_profondeur,	0 ]
		)
		
		
		
		---- 1er ouvrant ------------
		local transf_ouvrant_1	=	origine_ouv_1 * rotate_ouv_1 * recalle_ouv_1		
		mgr_mesh.attacher		mesh		compo_ouvrant 	transf:transf_ouvrant_1

		---- 2nd ouvrant	------------
		if  ouvrant_double do (
			local	transf_ouvrant_2 = origine_ouv_2 * rotate_ouv_2 * recalle_ouv_2		
			mgr_mesh.attacher		mesh		compo_ouvrant 	transf:transf_ouvrant_2
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
					profondeur 				= 	length ( gridPoint - pt_profondeur )
					ouvrant_profondeur	=	profondeur / 2
					
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
					
				)
				5: (
					cadre_epaisseur 	= length ( gridPoint - pt_epaisseur )	
					ouvrant_epaisseur = cadre_epaisseur
					ouvrant_decallage = cadre_epaisseur /2	
					
				)
					
			)		
	) --- fin tool create ---------
	
) ------- fin plugin ---------------------






		


