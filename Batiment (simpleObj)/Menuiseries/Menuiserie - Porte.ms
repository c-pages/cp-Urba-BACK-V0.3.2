


plugin simpleObject		urba_menuiserie_porte
name:"Porte"
classID:#(0x69b93b76, 0x1be9ef01)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuiserie_porteBattante"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	----- les composants -----------	
	local	compo_cadre,	compo_ouvrant_vitree,	compo_ouvrant_plein, compo_ouvrant_1 , compo_ouvrant_2, 	compo_poignee
	
	
	
	parameters params_dimensions rollout:rol_global	(
		longueur 		type:#worldUnits 	ui:spn_longueur 			default:0.
		hauteur	 		type:#worldUnits 	ui:spn_hauteur 			default:0.
		cadre_use		type:#boolean 		ui:shk_cadre				default:true
	)
	parameters params_general rollout:roll_parametres	(
		
		----- les menuiseries -----------
		cadre_largeur	 				type:#worldUnits 	default:3.5
		profondeur	 					type:#worldUnits 	default:5.
		vitrage_epaisseur				type:#worldUnits 	default:1.
		
		----- ouvrants ---------------------
		ouvrant_profondeur	 		type:#worldUnits 	default:4.	
		ouvrant_callage	 			type:#worldUnits 	default:1.5
		ouvrant_travBasse_ht	 	type:#worldUnits 	default:10.
		div_largeur	 					type:#worldUnits 	default:2.
		div_profondeur	 			type:#worldUnits 	default:3.
		
		ouvrant_double				type:#boolean 		ui:shk_double								default:false
		ouvrant_tierce					type:#boolean 		ui:shk_tierce								default:false
		ouvrant_tierce_pourcent	type:#float		 		ui:spn_tierce_pourcent					default:50.
		
		ouvrant_vitree					type:#boolean 		ui:shk_vitree								default:false		
		ouvrant_cadre_larg		 	type:#worldUnits 	ui:spn_ouvrant_cadre_larg				default:7.	
		ouvrant_cadre_travB_ht	type:#worldUnits 	ui:spn_ouvrant_cadre_travB_ht		default:12.		
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr				default:0.
		div_montants_nbr_2		 	type:#integer		 	ui:spn_div_montants_nbr_2			default:0.
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr				default:0.
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti					default:0.
		
		symetrie							type:#boolean 		ui:shk_symetrie							default:false
		ouvert_angle_1				type:#float 			ui:spn_angle_1							default:0.
		ouvert_angle_2				type:#float 			ui:spn_angle_2							default:0.
		
		
		---- Poignées ---------------------
		poignee_use					type:#boolean 		ui:shk_poignee							default:true
		poignee_hauteur	 			type:#worldUnits 	default:90.
		poignee_align_x				type:#worldUnits 	default:1.
	
	)	-----	fin parametres --------------------
	parameters params_divers rollout:roll_divers	(
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_poignee					type:#integer 			ui:spn_matId_poignee	default:3
		
	)	-----	fin parametres --------------------
	
	
	
	
	rollout rol_global  "Global"	(
		spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		checkbox	shk_cadre				"Cadre" 		
	)
	
	rollout roll_parametres  "Paramètres"	(		
		
		checkbox	shk_double							"Double" across:2
		checkbox	shk_tierce							"Tiercée"
		spinner 	spn_tierce_pourcent 			"(%)" 					type:#float				range:[0,100,0] 
		spinner 	spn_angle_1 						"Ouverture" 			type:#float				range:[0,180,0]
		checkbox	shk_symetrie						"Inverser sens"	
		spinner 	spn_angle_2 						"Ouverture 2" 			type:#float				range:[0,180,0]
		checkbox	shk_vitree							"Vitrée"				
		spinner 	spn_ouvrant_cadre_larg	 	"Menuis. larg." 		type:#worldunits range:[0,1e20,0]
		spinner 	spn_ouvrant_cadre_travB_ht	 "Trav B. ht." 			type:#worldunits range:[0,1e20,0]
		
		group 	"Croisillons" (	
			spinner 	spn_div_montants_nbr	 "Montants 1" 	type:#integer				range:[0,1e20,0]
			spinner 	spn_div_montants_nbr_2	 "Montants 2" 	type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 "Traverses" 	type:#integer				range:[0,1e20,0]
			spinner 	spn_div_calage_verti 	"Align. vert." 	type:#worldunits			range:[-1e20,1e20,0]
		)
		group 	"Options" (	
			checkbox	shk_poignee						"Poignée"
		)
		
		fn actualiser =(
			shk_symetrie.enabled = not ouvrant_double
			if ouvrant_double do shk_symetrie.triState = 2
			
			spn_ouvrant_cadre_larg.indeterminate			=	not ouvrant_vitree
			spn_ouvrant_cadre_larg.enabled 				=	ouvrant_vitree
			spn_ouvrant_cadre_travB_ht.indeterminate	=	not ouvrant_vitree
			spn_ouvrant_cadre_travB_ht.enabled 			=	ouvrant_vitree
			spn_div_montants_nbr.indeterminate			=	not ouvrant_vitree
			spn_div_montants_nbr.enabled 					=	ouvrant_vitree
			spn_div_traverses_nbr.indeterminate			=	not ouvrant_vitree
			spn_div_traverses_nbr.enabled 					=	ouvrant_vitree
			spn_div_calage_verti.indeterminate				=	not ouvrant_vitree
			spn_div_calage_verti.enabled 					=	ouvrant_vitree
		)
		on roll_parametres	open 					do actualiser ()
		on shk_double 		changed state 	do actualiser ()
		on shk_vitree	 		changed state 	do actualiser ()
	)
	
	rollout roll_divers  "Divers"	(
		group "Qualité" (
			checkbox	shk_lowPoly				"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 			"Menuiseries" 			type:#integer 			range:[1,1000,1]
			spinner spn_matId_vitrage 			"Vitrage" 				type:#integer 			range:[1,1000,1]
			spinner spn_matId_poignee 			"Poignée" 				type:#integer 			range:[1,1000,1]
		)
		
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------

	---- les composants ---------------------
	fn actualiser_composants	= with redraw off (
		
		
		---- creation des composants ------------------
		if compo_cadre 					== undefined	do	compo_cadre				= 	createInstance  menuiserie_composant_cadre
		if compo_ouvrant_plein 		== undefined	do	compo_ouvrant_plein	= 	createInstance  urba_primitive_boite
		if compo_ouvrant_vitree 		== undefined	do	compo_ouvrant_vitree	= 	createInstance  menuiserie_composant_chassisVitre
		if compo_poignee					== undefined	do	compo_poignee			= 	createInstance  menuiserie_composant_poignee
		
		local longueur_passage 	= if not cadre_use	then longueur 	else longueur 	- 2*cadre_largeur
		local hauteur_passage 		= if not cadre_use	then hauteur 		else hauteur 	- cadre_largeur
		
		---- maj du cadre ------------------
		if cadre_use do (
			compo_cadre.longueur 						= longueur
			compo_cadre.profondeur 					= profondeur
			compo_cadre.hauteur 						= hauteur
			compo_cadre.menuis_largeur	 			= cadre_largeur	
			compo_cadre.travBasse					= false		
			compo_cadre.low_poly			 			= low_poly		
			compo_cadre.matId_menuis	 			= matId_menuis
		)
		
		
		
		
		
		
		---- maj ouvrant		----
		local ouvrant_longueur_tmp	=	if not ouvrant_double then  longueur_passage		else longueur_passage / 2
	
		compo_ouvrant_vitree.longueur 					= ouvrant_longueur_tmp	
		compo_ouvrant_vitree.profondeur 				= ouvrant_profondeur
		compo_ouvrant_vitree.hauteur 					= hauteur_passage
		
		compo_ouvrant_vitree.cadre_largeur 			= ouvrant_cadre_larg
		compo_ouvrant_vitree.travBasse_hauteur		= ouvrant_cadre_travB_ht		
		compo_ouvrant_vitree.low_poly			 		= low_poly
		compo_ouvrant_vitree.matId_menuis	 		= matId_menuis
		compo_ouvrant_vitree.matId_vitrage	 		= matId_vitrage		
		compo_ouvrant_vitree.div_montants_nbr 		= div_montants_nbr
		compo_ouvrant_vitree.div_traverses_nbr 		= div_traverses_nbr
		compo_ouvrant_vitree.div_largeur				= div_largeur
		compo_ouvrant_vitree.div_profondeur			= div_profondeur
		compo_ouvrant_vitree.div_calage_verti		= div_calage_verti
		compo_ouvrant_vitree.vitrage_epaisseur		= vitrage_epaisseur
		
		--- plein ---		
		compo_ouvrant_plein.longueur	 				= ouvrant_longueur_tmp
		compo_ouvrant_plein.profondeur 				= ouvrant_profondeur
		compo_ouvrant_plein.hauteur 					= hauteur_passage
		
		
		compo_ouvrant_1	=	 if ouvrant_vitree then compo_ouvrant_vitree else compo_ouvrant_plein
		
	
		if not ouvrant_double then (
			compo_ouvrant_1.longueur 				= longueur_passage
		) else (
			if  ouvrant_tierce then (
				
				compo_ouvrant_1.longueur 	= longueur_passage 	*  ouvrant_tierce_pourcent / 100 
				
				compo_ouvrant_2 							= copy compo_ouvrant_1
				compo_ouvrant_2.longueur 				=  longueur_passage	* ( 100 - ouvrant_tierce_pourcent ) / 100
				 if ouvrant_vitree  do
					compo_ouvrant_2.div_montants_nbr 	=  div_montants_nbr_2
			
			)	else 	(
				compo_ouvrant_1.longueur 	= longueur_passage / 2
				compo_ouvrant_2 				= compo_ouvrant_1
			)
		)
		
		
	)  --- fin composants_actualiser  ------------------
	
	
	
	
	
	
		
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		---- le cadre -------
		if cadre_use do 
			mgr_mesh.attacher		mesh		compo_cadre
		
		----Données ------------	
		local origine_ouv_1
		local rotate_ouv_1
		local recalle_ouv_1
		
		local origine_ouv_2
		local rotate_ouv_2
		local recalle_ouv_2
		
		local longueur_ouvrant_1 	= compo_ouvrant_1.longueur 
		local callage_montant_G 	= 	if cadre_use then cadre_largeur	else	0
		local callage_montant_D 	= callage_montant_G
		local ouvrant_pos_z 		= 0
		
		if  symetrie and not ouvrant_double	then (
			origine_ouv_1	=	transMatrix	[ -longueur_ouvrant_1, - ouvrant_profondeur ,	ouvrant_pos_z ]	
			rotate_ouv_1	=	rotateZMatrix -ouvert_angle_1
			recalle_ouv_1	=	transMatrix	[longueur - callage_montant_G, ouvrant_callage + ouvrant_profondeur ,	0 ]
		) else (
			origine_ouv_1	=	transMatrix	[ 0, -ouvrant_profondeur,	ouvrant_pos_z ]
			rotate_ouv_1	=	rotateZMatrix 	ouvert_angle_1 
			recalle_ouv_1	=	transMatrix	[callage_montant_G, ouvrant_callage + ouvrant_profondeur,	0 ]
		)
		if  ouvrant_double do (			
			local longueur_ouvrant_2 	= compo_ouvrant_2.longueur 
			origine_ouv_2	=	transMatrix	[ -longueur_ouvrant_2, -ouvrant_profondeur ,	ouvrant_pos_z ]
			rotate_ouv_2 	=  rotateZMatrix -ouvert_angle_2
			recalle_ouv_2	=	transMatrix	[longueur - callage_montant_D, ouvrant_callage + ouvrant_profondeur,	0 ]
		)
		
		
		
		---- 1er ouvrant ------------
		local transf_ouvrant_1	=	origine_ouv_1 * rotate_ouv_1 * recalle_ouv_1		
		mgr_mesh.attacher		mesh		compo_ouvrant_1 	transf:transf_ouvrant_1

		---- 2nd ouvrant	------------
		if  ouvrant_double do (
			local	transf_ouvrant_2 = origine_ouv_2 * rotate_ouv_2 * recalle_ouv_2		
			mgr_mesh.attacher		mesh		compo_ouvrant_2 	transf:transf_ouvrant_2
		)
		
		
		
		
		-------- poignées -------------
		---- poignée 1 et interieur 1 ------------------------
		local hauteur_min 			= 108
		local largeur_menuis_min	= 5
		if poignee_use and not low_poly and hauteur -  cadre_largeur > hauteur_min and ouvrant_cadre_larg > largeur_menuis_min	do (
			
-- 			local longueur_passage = compo_ouvrant.longueur
			
			if   symetrie  then (
				
				compo_poignee.symetrie 			= true
				compo_poignee.symetrie_sens 	= true
				compo_poignee_transf 				= 	transMatrix	[ -(longueur_ouvrant_1  - poignee_align_x) , -ouvrant_profondeur,	poignee_hauteur ]   * rotate_ouv_1 * recalle_ouv_1
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
				
				if ouvrant_vitree do (
					compo_poignee.symetrie 			= false
					compo_poignee.symetrie_sens 	= true
					compo_poignee_transf 				= 	transMatrix	[ -(longueur_ouvrant_1  - poignee_align_x) , 0,	poignee_hauteur ]   * rotate_ouv_1 * recalle_ouv_1
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
				)
				
			)	else (
				
				compo_poignee.symetrie 			= true
				compo_poignee.symetrie_sens 	= false
				compo_poignee_transf 				=	transMatrix	[ longueur_ouvrant_1 - 4 - poignee_align_x , -ouvrant_profondeur,	poignee_hauteur ]  * rotate_ouv_1 * recalle_ouv_1
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
				
				if ouvrant_vitree do (
					compo_poignee.symetrie 			= false
					compo_poignee.symetrie_sens 	= false
					compo_poignee_transf 				= 	transMatrix	[ longueur_ouvrant_1 - 4 - poignee_align_x , 0,	poignee_hauteur ]  * rotate_ouv_1 * recalle_ouv_1
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
				)
			) 
			
			
			---- poignée double porte ------------------------
			if    ouvrant_double	do (
				
				compo_poignee.symetrie 			= true
				compo_poignee.symetrie_sens 	= true
				compo_poignee_transf 				= 	transMatrix	[ -longueur_ouvrant_2 + poignee_align_x , -ouvrant_profondeur,	poignee_hauteur ]   * rotate_ouv_2 * recalle_ouv_2
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
				
				if ouvrant_vitree	do (
					compo_poignee.symetrie 			= false
					compo_poignee.symetrie_sens 	= true
					compo_poignee_transf 				= 	transMatrix	[- longueur_ouvrant_2 + poignee_align_x , 0,	poignee_hauteur ]   * rotate_ouv_2 * recalle_ouv_2
					mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
				)
		 	) --- if ouvrant_double --
			 
			
			
		) --- fin poignées (if not low poly )------
		
		
	)  ----- fin on buld mesh ---------------------------------------------------------------------
	
	
	
	
	
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
						hauteur = 210
				)
				2: #stop
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
					
					pt_hauteur				=	gridPoint
					
					
				)
			)		
	) --- fin tool create ---------
	
	
) ------- fin plugin ---------------------






		


