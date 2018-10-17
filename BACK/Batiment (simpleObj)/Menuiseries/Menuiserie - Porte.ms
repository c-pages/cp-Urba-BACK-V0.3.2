


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
	local	compo_cadre,	compo_ouvrant_vitree,	compo_ouvrant_plein, 	compo_poignee
	
	
	
	parameters params_general rollout:roll_general	(
		
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 				default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 				default:0.
		profondeur	 			type:#worldUnits 	ui:spn_cadre_prof 			default:0.
		
		symetrie_x						type:#boolean 		ui:shk_sym_X					default:false
		symetrie_y						type:#boolean 		ui:shk_sym_Y					default:false
		
		ouvert_angle1					type:#float 			ui:spn_ouvert_angle			default:0.
		
		---- Cadre ---------------------
		cadre_use						type:#boolean 		ui:shk_cadre					default:true
		cadre_largeur					type:#worldUnits 	ui:spn_cadre_larg 			default:0.
		
		---- Ouvrant ---------------------
		ouvrant_profondeur 			type:#worldUnits 	ui:spn_ouvrant_prof 		default:0.
		ouvrant_largeur				type:#worldUnits 	ui:spn_ouvrant_largeur 		default:0.
		ouvrant_alignement			type:#worldUnits 	ui:spn_ouvrant_align 		default:0.
		vitree_use						type:#boolean 		ui:shk_vitree					default:true
		div_montants_nbr			type:#integer		 	ui:spn_div_montants_nbr	default:0.
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr	default:0.
		div_calage_verti				type:#worldUnits 	ui:spn_div_calage_verti 	default:0.
		div_largeur 						type:#worldUnits 	ui:spn_div_largeur 			default:0.
		div_profondeur				type:#worldUnits 	ui:spn_div_profondeur 		default:0.
		travBasse_hauteur			type:#worldUnits 	ui:spn_travBasse_ht			default:0.
		
		---- Poignées ---------------------
		poignee_ext_use				type:#boolean 		ui:shk_poignee_ext			default:false
		poignee_int_use				type:#boolean 		ui:shk_poignee_int			default:false
		poignee_hauteur	 			type:#worldUnits 	ui:spn_poignee_ht 			default:90.
		poignee_align_x				type:#worldUnits 	ui:spn_poignee_alignX 		default:2.

		
		/* 
		on cadre_epaisseur			set val 	do	corriger_parametres ()
		on ouvrant_decallage		set val 	do	corriger_parametres ()
		on ouvrant_epaisseur		set val 	do	corriger_parametres ()
		on hauteur						set val 	do	corriger_parametres ()
		on longueur					set val 	do	corriger_parametres ()
		on poignee_hauteur					set val 	do	corriger_parametres ()
		on poignee_align_x				set val 	do	corriger_parametres ()
		 */
	)	-----	fin parametres --------------------
	parameters params_divers rollout:roll_divers	(
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_poignee					type:#integer 			ui:spn_matId_poignee	default:3
		
	)	-----	fin parametres --------------------
	
	
	
	
	rollout roll_general  "Paramètres"	(
		
		spinner 	spn_longueur 					"longueur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_hauteur 					"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		checkbox	shk_sym_X						"Symétrie X"
		checkbox	shk_sym_Y						"Symétrie Y"
		spinner 	spn_ouvert_angle				"Ouvertue" 				type:#float				range:[0,180,0]

		group "Cadre" (
			checkbox	shk_cadre					"Cadre"
			spinner		spn_cadre_prof			"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_cadre_larg 			"Largeur" 				type:#worldunits 	range:[0,1e20,0]
		)
		group "Ouvrant" (	
			spinner 	spn_ouvrant_prof			"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_ouvrant_align		"Align. prof." 			type:#worldunits 	range:[0,1e20,0]
			checkbox	shk_vitree					"Vitrée" 		
			spinner 	spn_ouvrant_largeur		"Largeur" 				type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_travBasse_ht		"Trav. basse ht." 		type:#worldunits 	range:[0,1e20,0]
			label			lbl_divisions					"Divisions      "				align:#right
			spinner 	spn_div_montants_nbr	"Nbr. montants" 		type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	"Nbr. traverses" 		type:#integer			range:[0,1e20,0]
			spinner 	spn_div_calage_verti 	"Calage vertical" 		type:#worldunits		range:[-1e20,1e20,0]
			spinner 	spn_div_largeur			"Div. largeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_div_profondeur		"Div. profondeur" 		type:#worldunits 	range:[0,1e20,0]
		)
		group "Poignée" (
			checkbox	shk_poignee_ext			"Poignée ext."
			checkbox	shk_poignee_int			"Poignée int."
			spinner 	spn_poignee_ht			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_poignee_alignX		"Align. X" 				type:#worldunits 	range:[0,1e20,0]
		)
		
		fn actualiser = (
			
			---- cadre -----
			spn_cadre_prof.Indeterminate 			= not cadre_use
			spn_cadre_prof.enabled 					= cadre_use
			spn_cadre_larg.Indeterminate 			= not cadre_use
			spn_cadre_larg.enabled 					= cadre_use
			
			---- vitrée -----
			spn_div_montants_nbr.Indeterminate 	= not vitree_use
			spn_div_montants_nbr.enabled 			= vitree_use
			spn_div_traverses_nbr.Indeterminate 	= not vitree_use
			spn_div_traverses_nbr.enabled 			= vitree_use
			spn_div_calage_verti.Indeterminate 	= not vitree_use
			spn_div_calage_verti.enabled 			= vitree_use
			spn_div_largeur.Indeterminate 			= not vitree_use
			spn_div_largeur.enabled 					= vitree_use
			spn_div_profondeur.Indeterminate 		= not vitree_use
			spn_div_profondeur.enabled 				= vitree_use
			
			---- poignées -----
			spn_poignee_ht.Indeterminate 			= not poignee_ext_use 	or not poignee_int_use
			spn_poignee_ht.enabled 					= poignee_ext_use			or  poignee_int_use
			spn_poignee_alignX.Indeterminate 		= not poignee_ext_use 	or not poignee_int_use
			spn_poignee_alignX.enabled 				= poignee_ext_use			or  poignee_int_use
			
		)
		
		on roll_general 	open 				do actualiser ()
		on shk_cadre 		changed val 	do actualiser ()
		on shk_vitree 		changed val 	do actualiser ()
		on shk_poignee_ext 	changed val 	do actualiser ()
		on shk_poignee_int 	changed val 	do actualiser ()
		
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
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
		if ouvrant_decallage > profondeur - ouvrant_profondeur do ouvrant_decallage = profondeur - ouvrant_profondeur
			
		if poignee_hauteur  + 18 + cadre_epaisseur > hauteur do poignee_hauteur = hauteur - 18 - cadre_epaisseur
		if poignee_hauteur < 0 do poignee_hauteur = 0
		
		if ouvrant_vitree then 
			if poignee_align_x + 4 > ouvrant_epaisseur do poignee_align_x = ouvrant_epaisseur - 4
		else
			if poignee_align_x + 4 > longueur  -  2*cadre_epaisseur do poignee_align_x = longueur  -  2*cadre_epaisseur  - 4
	)
	---- les composants ---------------------
	fn actualiser_composants	= with redraw off (
		
		
		---- creation des composants ------------------
		if compo_cadre 				== undefined	do	compo_cadre				= 	createInstance  menuiserie_composant_cadre
		if compo_ouvrant_plein 	== undefined	do	compo_ouvrant_plein	= 	createInstance  urba_primitive_boite
		if compo_ouvrant_vitree 	== undefined	do	compo_ouvrant_vitree	= 	createInstance  menuiserie_composant_chassisVitre
		if compo_poignee				== undefined	do	compo_poignee			= 	createInstance  menuiserie_composant_poignee
		
		
		----- maj du cadre ----------------------
		compo_cadre.longueur 						= longueur
		compo_cadre.profondeur 					= profondeur
		compo_cadre.hauteur 						= hauteur		
		compo_cadre.menuis_largeur	 			= cadre_largeur	
		compo_cadre.travBasse		 			= false	
		compo_cadre.low_poly			 			= low_poly		
		compo_cadre.matId_menuis	 			= matId_menuis
		
		
		--- maj des ouvrants -------------
		local longueur_passage 	=	if cadre_use 	then longueur - 2* cadre_largeur 	else 	longueur
		local hauteur_passage		= 	if cadre_use 	then hauteur - cadre_largeur 		else 	hauteur
		
		compo_ouvrant_vitree.longueur	 				= longueur_passage
		compo_ouvrant_vitree.profondeur 				= ouvrant_profondeur
		compo_ouvrant_vitree.hauteur 					= hauteur_passage
		compo_ouvrant_vitree.cadre_largeur	 		= ouvrant_largeur
		compo_ouvrant_vitree.travBasse_hauteur		= travBasse_hauteur	
		compo_ouvrant_vitree.vitrage_epaisseur		= 2		
		
		compo_ouvrant_vitree.div_montants_nbr 		= div_montants_nbr
		compo_ouvrant_vitree.div_traverses_nbr		= div_traverses_nbr
		compo_ouvrant_vitree.div_calage_verti		= div_calage_verti
		compo_ouvrant_vitree.div_largeur				= div_largeur
		compo_ouvrant_vitree.div_profondeur			= div_profondeur
		
		compo_ouvrant_vitree.low_poly			 		= low_poly
		compo_ouvrant_vitree.matId_menuis	 		= matId_menuis
		compo_ouvrant_vitree.matId_vitrage	 		= matId_vitrage		
		
	)  --- fin composants_actualiser  ------------------
	
	
	
	
	
	
	
		
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		---- le cadre -------------------------------------------------
		if cadre_use do
			mgr_mesh.attacher		mesh		compo_cadre
		
		
		----Données ------------	
		local origine_ouv_1
		local rotate_ouv_1
		local recalle_ouv_1
		
		local longueur_base 		= compo_ouvrant_vitree.longueur 		
		local longueur_passage 	=	if cadre_use 	then longueur - 2* cadre_largeur 	else 	longueur		
		local callage_montant_G 	= 	if cadre_use 	then cadre_largeur else 0
		local callage_montant_D 	= 	if cadre_use 	then cadre_largeur else 0
		
		if  symetrie_x then (
			origine_ouv_1	=	transMatrix		[ -longueur_passage, - ouvrant_profondeur ,	0 ]	
			rotate_ouv_1	=	rotateZMatrix 	-ouvert_angle1
			recalle_ouv_1	=	transMatrix		[longueur - callage_montant_G, ouvrant_alignement + ouvrant_profondeur ,	0 ]
			
		) else (
			origine_ouv_1	=	transMatrix		[ 0, -ouvrant_profondeur,	0 ]
			rotate_ouv_1	=	rotateZMatrix 	ouvert_angle1 
			recalle_ouv_1	=	transMatrix		[callage_montant_G, ouvrant_alignement + ouvrant_profondeur,	0 ]
			
		)

		
		----  ouvrant -----------------------------------------
		local transf_ouvrant_1			=	origine_ouv_1 * rotate_ouv_1 * recalle_ouv_1		
		local compo_ouvrant_temp 	= 	if vitree_use	then		compo_ouvrant_vitree
																		else		compo_ouvrant_plein
		compo_ouvrant_temp.longueur 	=	longueur_passage
		mgr_mesh.attacher		mesh		compo_ouvrant_temp 	transf:transf_ouvrant_1
		
		
		
		-------- poignées -------------		
		
		
		---- poignée 1 et interieur 1 ------------------------
		compo_poignee.low_poly = low_poly
		if   symetrie_x  then (
			if poignee_ext_use do (
				compo_poignee.symetrie 			= true
				compo_poignee.inverser_sens 	= true
				compo_poignee_transf 				= 	transMatrix	[ -(longueur_passage  - poignee_align_x) , -ouvrant_profondeur,	poignee_hauteur ]   * rotate_ouv_1 * recalle_ouv_1
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
			)
			if poignee_int_use do (
				compo_poignee.symetrie 			= false
				compo_poignee.inverser_sens 	= true
				compo_poignee_transf 				= 	transMatrix	[ -(longueur_passage  - poignee_align_x) , 0,	poignee_hauteur ]   * rotate_ouv_1 * recalle_ouv_1
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
			)
		)	else (
			if poignee_ext_use do (
				compo_poignee.symetrie 			= true
				compo_poignee.inverser_sens 	= false
				compo_poignee_transf 	=	transMatrix	[ longueur_passage - 4 - poignee_align_x , -ouvrant_profondeur,	poignee_hauteur ]  * rotate_ouv_1 * recalle_ouv_1
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf
			)
			if poignee_int_use do (
				compo_poignee.symetrie 			= false
				compo_poignee.inverser_sens 	= false
				compo_poignee_transf = 	transMatrix	[ longueur_passage - 4 - poignee_align_x , 0,	poignee_hauteur ]  * rotate_ouv_1 * recalle_ouv_1
				mgr_mesh.attacher		mesh		compo_poignee 	transf:compo_poignee_transf	
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
					pt_profondeur			=	gridPoint
				)
				3:	(
					profondeur 	= 	length ( gridPoint - pt_profondeur )
					ouvrant_profondeur	=	profondeur / 2
					
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
				5: (
					cadre_largeur 			= length ( gridPoint - pt_epaisseur )	
					travBasse_hauteur 	= cadre_largeur
					ouvrant_largeur 		= cadre_largeur
					ouvrant_alignement 	= profondeur /2	
					div_largeur				=	ouvrant_largeur
					div_profondeur		= ouvrant_profondeur
				)
					
			)		
	) --- fin tool create ---------
	
	
) ------- fin plugin ---------------------






		


