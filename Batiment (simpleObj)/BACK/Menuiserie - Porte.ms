


plugin simpleObject		urba_menuiserie_portePivot
name:"Porte pivot"
classID:#(0x6cdf5915, 0x6f44b72a)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuiserie_portePivot"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	----- les composants -----------	
	local	compo_cadre,	compo_ouvrant_vitree,	compo_ouvrant_plein, 	compo_poignee
	
	
	
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
		
		----- ouvrants ---------------------
		ouvrant_vitree					type:#boolean 		ui:shk_vitree				default:true
		ouvrant_epaisseur	 		type:#worldUnits 	ui:spn_ouvrant_ep		default:0.	
		ouvrant_profondeur	 		type:#worldUnits 	ui:spn_ouvrant_prof		default:0.	
		ouvrant_decallage	 		type:#worldUnits 	ui:spn_ouvrant_decal	default:0.	
		ouvrant_travB_ep			type:#worldUnits 	ui:spn_traverse_B_ep	default:0.
		div_horiz		 				type:#integer		 	ui:spn_div_horiz			default:0.
		div_verti			 				type:#integer		 	ui:spn_div_verti			default:0.
		div_epaisseur	 				type:#worldUnits 	ui:spn_div_epaisseur		default:0.
		
		inverser							type:#boolean 		ui:shk_inverser			default:false
		ouvert_angle_1				type:#float 			ui:spn_angle_1			default:0.
		ouvrant_double				type:#boolean 		ui:shk_double				default:false
		ouvert_angle_2				type:#float 			ui:spn_angle_2			default:2.
		
		---- poignée ------
		poignee_use					type:#boolean 		ui:shk_poignee			default:false
		poignee_int_use				type:#boolean 		ui:shk_poignee_int		default:false
		poignee_ht						type:#worldUnits 	ui:spn_poignee_ht		default:100.
		poignee_posX					type:#worldUnits 	ui:spn_poignee_posX	default:0.
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_poignee					type:#integer 			ui:spn_matId_poignee	default:3
		
		on cadre_epaisseur			set val 	do	corriger_parametres ()
		on ouvrant_decallage		set val 	do	corriger_parametres ()
		on ouvrant_epaisseur		set val 	do	corriger_parametres ()
		on hauteur						set val 	do	corriger_parametres ()
		on longueur					set val 	do	corriger_parametres ()
		on poignee_ht					set val 	do	corriger_parametres ()
		on poignee_posX				set val 	do	corriger_parametres ()
		
	)	-----	fin parametres --------------------
	
	
	
	
	rollout roll_general  "Fenêtre"
	(
		group "Global" (
			spinner spn_longueur 				"longueur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_hauteur 				"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_profondeur 			"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner spn_cadre_ep	 			"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
			checkbox	shk_montant_G		"Montant gauche" 			
			checkbox	shk_montant_D		"Montant droit" 
		)
		group "Ouvrant" (	
			spinner 	spn_ouvrant_prof		"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_ouvrant_ep		"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_traverse_B_ep	 "Trav. Basse ép." 	type:#float				range:[0,180,0]
			spinner 	spn_ouvrant_decal	"Décallage prof." 		type:#worldunits 	range:[0,1e20,0]
			checkbox	shk_double				"double"
			checkbox	shk_inverser			"inverser"
			spinner 	spn_angle_1	 		"Ouvertue 1" 			type:#float				range:[0,180,0]
			spinner 	spn_angle_2	 		"Ouvertue 2" 			type:#float				range:[0,180,0]
		)
		group "Vitrée" (	
			checkbox	shk_vitree				"Vitrée"
			spinner 	spn_div_epaisseur	"Divisions ép." 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_div_horiz	 		"Div. Horizontale" 	type:#integer			range:[0,1e20,0]
			spinner 	spn_div_verti	 		"Div. Verticale" 		type:#integer			range:[0,1e20,0]
		)
		group "Poignée" (	
			checkbox	shk_poignee			"Poignée"
			spinner 	spn_poignee_ht		"Hauteur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_poignee_posX	"Decallage X" 		type:#worldunits 	range:[0,1e20,0]
			checkbox	shk_poignee_int		"Interieur"
		)
		
		group "Qualité" (
			checkbox	shk_lowPoly			"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
			spinner spn_matId_poignee 		"Poignée" 				type:#integer range:[1,1000,1]
		)
		
		
		fn actualiser = (
			
			shk_inverser.enabled = not ouvrant_double
			if not ouvrant_double do shk_inverser.triState  = 2
				
			spn_angle_2.Indeterminate 			= not ouvrant_double
			spn_angle_2.enabled 					= ouvrant_double
			
			spn_poignee_ht.Indeterminate 		= not poignee_use
			spn_poignee_ht.enabled 				= poignee_use
			spn_poignee_posX.Indeterminate 	= not poignee_use
			spn_poignee_posX.enabled 			= poignee_use
			
			shk_poignee_int.enabled 				=  poignee_use
			if not poignee_use do shk_poignee_int.triState  = 2
			
			spn_div_epaisseur.enabled 			= ouvrant_vitree
			spn_div_epaisseur.Indeterminate 	= not ouvrant_vitree
			spn_div_horiz.enabled 					= ouvrant_vitree
			spn_div_horiz.Indeterminate 			= not ouvrant_vitree
			spn_div_verti.enabled 					= ouvrant_vitree
			spn_div_verti.Indeterminate 			= not ouvrant_vitree
			
		)
		
		on roll_general 		open 				do actualiser  ()
		on shk_double			changed state do actualiser  ()
		on shk_poignee		changed state do actualiser  ()
		on shk_vitree			changed state do actualiser  ()
		
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
		if ouvrant_decallage > profondeur - ouvrant_profondeur do ouvrant_decallage = profondeur - ouvrant_profondeur
			
		if poignee_ht  + 18 + cadre_epaisseur > hauteur do poignee_ht = hauteur - 18 - cadre_epaisseur
		if poignee_ht < 0 do poignee_ht = 0
		
		if ouvrant_vitree then 
			if poignee_posX + 4 > ouvrant_epaisseur do poignee_posX = ouvrant_epaisseur - 4
		else
			if poignee_posX + 4 > longueur  -  2*cadre_epaisseur do poignee_posX = longueur  -  2*cadre_epaisseur  - 4
	)
	---- les composants ---------------------
	fn composants_actualiser	= with redraw off (
		
		
		
		
		---- creation des composants ------------------
		if compo_cadre 				== undefined	do	compo_cadre				= 	createInstance  menuiserie_composant_cadre
		if compo_ouvrant_plein 	== undefined	do	compo_ouvrant_plein	= 	createInstance  urba_primitive_boite
		if compo_ouvrant_vitree 	== undefined	do	compo_ouvrant_vitree	= 	createInstance  menuiserie_composant_chassis
		if compo_poignee				== undefined	do	compo_poignee			= 	createInstance  menuiserie_composant_poignee
		
		local longueur_passage = longueur
		if montant_G do longueur_passage -=  cadre_epaisseur
		if montant_D do longueur_passage -=  cadre_epaisseur
		
		----- maj du cadre ----------------------
		compo_cadre.longueur 						= longueur
		compo_cadre.profondeur 					= profondeur
		compo_cadre.hauteur 						= hauteur
		compo_cadre.menuis_epaisseur 			= cadre_epaisseur	
		compo_cadre.montant_G	 				= montant_G
		compo_cadre.montant_D	 				= montant_D
		compo_cadre.traverse_B		 			= false	
		compo_cadre.low_poly			 			= low_poly		
		compo_cadre.matId_menuis	 			= matId_menuis
		
		---- maj ouvrant	vitree	----
		if not ouvrant_double then 
			compo_ouvrant_vitree.longueur 				= longueur_passage
		else
			compo_ouvrant_vitree.longueur 				= longueur_passage / 2
	
		compo_ouvrant_vitree.profondeur 				= ouvrant_profondeur
		compo_ouvrant_vitree.hauteur 					= hauteur	-  cadre_epaisseur
		compo_ouvrant_vitree.menuis_epaisseur 		= ouvrant_epaisseur
		compo_ouvrant_vitree.traverse_B_epaisseur	= ouvrant_travB_ep		
		compo_ouvrant_vitree.low_poly			 		= low_poly
		compo_ouvrant_vitree.matId_menuis	 		= matId_menuis
		compo_ouvrant_vitree.matId_vitrage	 		= matId_vitrage		
		compo_ouvrant_vitree.div_horiz 					= div_horiz
		compo_ouvrant_vitree.div_verti 					= div_verti
		compo_ouvrant_vitree.div_epaisseur			= div_epaisseur
		
		---- maj ouvrant plein --------
		if not ouvrant_double then 
			compo_ouvrant_plein.longueur 				= longueur - 2* cadre_epaisseur
		else
			compo_ouvrant_plein.longueur 				= (longueur - 2* cadre_epaisseur ) / 2
		
		compo_ouvrant_plein.profondeur 				= ouvrant_profondeur
		compo_ouvrant_plein.hauteur 					= hauteur	-  cadre_epaisseur
		
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
		
		local longueur_ouvrant = compo_ouvrant_vitree.longueur 
		local callage_montant_G = if montant_G then cadre_epaisseur else 0
		local callage_montant_D = if montant_D then cadre_epaisseur else 0
		
		if  inverser and not ouvrant_double	then (
			origine_ouv_1	=	transMatrix	[ -longueur_ouvrant, - ouvrant_profondeur ,	0 ]	
			rotate_ouv_1	=	rotateZMatrix -ouvert_angle_1
			recalle_ouv_1	=	transMatrix	[longueur - callage_montant_G, ouvrant_decallage + ouvrant_profondeur ,	0 ]
		) else (
			origine_ouv_1	=	transMatrix	[ 0, -ouvrant_profondeur,	0 ]
			rotate_ouv_1	=	rotateZMatrix 	ouvert_angle_1 
			recalle_ouv_1	=	transMatrix	[callage_montant_G, ouvrant_decallage + ouvrant_profondeur,	0 ]
		)
		if  ouvrant_double do (			
			origine_ouv_2	=	transMatrix	[ -longueur_ouvrant, -ouvrant_profondeur ,	0 ]
			rotate_ouv_2 	=  rotateZMatrix -ouvert_angle_2
			recalle_ouv_2	=	transMatrix	[longueur - callage_montant_D, ouvrant_decallage+ ouvrant_profondeur,	0 ]
		)
		
		
		---- 1er ouvrant ------------	
		local transf_ouvrant_1	=	origine_ouv_1 * rotate_ouv_1 * recalle_ouv_1		
		if ouvrant_vitree	then 	mgr_mesh.attacher		mesh		compo_ouvrant_vitree 	transf:transf_ouvrant_1
								else		mgr_mesh.attacher		mesh		compo_ouvrant_plein 	transf:transf_ouvrant_1
		
		---- 2nd ouvrant	------------
		if  ouvrant_double do (
			local	transf_ouvrant_2 = origine_ouv_2 * rotate_ouv_2 * recalle_ouv_2			
			if ouvrant_vitree	then 	mgr_mesh.attacher		mesh		compo_ouvrant_vitree 	transf:transf_ouvrant_2
									else		mgr_mesh.attacher		mesh		compo_ouvrant_plein 	transf:transf_ouvrant_2
		)
		
		
		-------- poignées -------------		
		if poignee_use	do (
			
			
			---- poignée 1 et interieur 1 ------------------------
			if   inverser  and not ouvrant_double	then (
				compo_poignee.symetrie 			= true
				compo_poignee.inverser_sens 	= true
				compo_poignee_transf 				= 	transMatrix	[ -(longueur_ouvrant  - poignee_posX) , -ouvrant_profondeur,	poignee_ht ]   * rotate_ouv_1 * recalle_ouv_1
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
				if poignee_int_use	do (
					compo_poignee.symetrie 			= false
					compo_poignee.inverser_sens 	= true
					compo_poignee_transf 				= 	transMatrix	[ -(longueur_ouvrant  - poignee_posX) , 0,	poignee_ht ]   * rotate_ouv_1 * recalle_ouv_1
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
				)
		 	) else (
				compo_poignee.symetrie 			= true
				compo_poignee.inverser_sens 	= false
				compo_poignee_transf 	=	transMatrix	[ longueur_ouvrant - 4 - poignee_posX , -ouvrant_profondeur,	poignee_ht ]  * rotate_ouv_1 * recalle_ouv_1
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
				if poignee_int_use	do (
					compo_poignee.symetrie 			= false
					compo_poignee.inverser_sens 	= false
					compo_poignee_transf = 	transMatrix	[ longueur_ouvrant - 4 - poignee_posX , 0,	poignee_ht ]  * rotate_ouv_1 * recalle_ouv_1
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
				)
			) 
			
			
			
			---- poignée 1 et interieur 1 ------------------------
			if    ouvrant_double	do (
				compo_poignee.symetrie 			= true
				compo_poignee.inverser_sens 	= true
				compo_poignee_transf 				= 	transMatrix	[ -longueur_ouvrant + poignee_posX , -ouvrant_profondeur,	poignee_ht ]   * rotate_ouv_2 * recalle_ouv_2
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
				if poignee_int_use	do (
					compo_poignee.symetrie 			= false
					compo_poignee.inverser_sens 	= true
					compo_poignee_transf 				= 	transMatrix	[- longueur_ouvrant + poignee_posX , 0,	poignee_ht ]   * rotate_ouv_2 * recalle_ouv_2
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
				)
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
					ouvrant_travB_ep = cadre_epaisseur
					ouvrant_epaisseur = cadre_epaisseur
					ouvrant_decallage = cadre_epaisseur /2	
					
					composants_actualiser ()
				)
					
			)		
	) --- fin tool create ---------
	
	
) ------- fin plugin ---------------------






		


