


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
	local	compo_cadre, compo_ouvrant_1, compo_ouvrant_2
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
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
-- 		ouvrant_cadre_larg	 		type:#worldUnits 	default:4.	
		ouvrant_profondeur	 		type:#worldUnits 	default:4.	
		ouvrant_callage	 			type:#worldUnits 	default:1.5
		ouvrant_cadre_larg		 	type:#worldUnits 	ui:spn_ouvrant_cadre_larg				default:4.	
		div_largeur	 					type:#worldUnits 	default:2.
		div_profondeur	 			type:#worldUnits 	default:3.
		
		ouvrant_double				type:#boolean 		ui:shk_double					default:false
		ouvrant_tierce					type:#boolean 		ui:shk_tierce					default:false
		ouvrant_tierce_pourcent	type:#float		 		ui:spn_tierce_pourcent		default:50.
		
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr		default:0.
		div_montants_nbr_2		 	type:#integer		 	ui:spn_div_montants_nbr_2	default:0.
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr		default:0.
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti			default:0.
		
		symetrie							type:#boolean 		ui:shk_symetrie				default:false
		ouvert_angle_1				type:#float 			ui:spn_angle_1				default:0.
		ouvert_angle_2				type:#float 			ui:spn_angle_2				default:0.
		
		on ouvrant_decallage		set val 	do	corriger_parametres ()
	)	-----	fin parametres --------------------
	parameters params_divers rollout:roll_divers	(
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)	-----	fin parametres --------------------
	
	
	
	
	rollout rol_global  "Global"	(
		spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		checkbox	shk_cadre				"Cadre" 		
	)
	rollout roll_parametres  "Paramètres"	(
		spinner 	spn_ouvrant_cadre_larg	 	"Menuis. larg." 		type:#worldunits range:[0,1e20,0]
		checkbox	shk_double							"double" across:2
		checkbox	shk_tierce							"Tiercée" 
		spinner 	spn_tierce_pourcent 			"(%)" 		type:#float				range:[0,100,0] 
		spinner 	spn_angle_1 						"Ouv. 1 (°)" 	type:#float				range:[0,180,0]
		checkbox	shk_symetrie						"Inverser sens"	
		spinner 	spn_angle_2 						"Ouv. 2 (°)" 	type:#float				range:[0,180,0]
		group "Croisillons" (	
			spinner 	spn_div_montants_nbr	 "Montants 1" 		type:#integer			range:[0,1e20,0]
			spinner 	spn_div_montants_nbr_2	 "Montants 2" 	type:#integer		range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 "Traverses" 		type:#integer			range:[0,1e20,0]
			spinner 	spn_div_calage_verti 	"Align. vert." 		type:#worldunits		range:[-1e20,1e20,0]
		)
		
		
		fn actualiser =(
			shk_symetrie.enabled = not ouvrant_double
			if ouvrant_double do shk_symetrie.triState = 2
				
			spn_angle_2.indeterminate			=	not ouvrant_double
			spn_angle_2.enabled 				=	ouvrant_double
			
			shk_tierce.enabled 					=  ouvrant_double
			if not ouvrant_double do shk_symetrie.triState = 2
			
			spn_tierce_pourcent.indeterminate		=	not ouvrant_double or not ouvrant_tierce
			spn_tierce_pourcent.enabled 				=	ouvrant_double and  ouvrant_tierce
			
			spn_div_montants_nbr_2.indeterminate	=	not ouvrant_double or not ouvrant_tierce
			spn_div_montants_nbr_2.enabled 			=	ouvrant_double and  ouvrant_tierce
		)
		on roll_parametres	open 					do actualiser ()
		on shk_double 		changed state 	do actualiser ()
		on shk_tierce	 		changed state 	do actualiser ()
	)
	rollout roll_divers  "Divers"	(
		group "Qualité" (
			checkbox	shk_lowPoly			"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	---- les composants ---------------------
	fn composants_actualiser	= with redraw off (
		
		---- creation des composants ------------------
		if compo_cadre 		== undefined	do	compo_cadre			= 	createInstance  menuiserie_composant_cadre
		if compo_ouvrant_1 	== undefined	do	compo_ouvrant_1	= 	createInstance  menuiserie_composant_chassisVitre				
		if compo_ouvrant_2 	== undefined	do	compo_ouvrant_2	= 	createInstance  menuiserie_composant_chassisVitre	
		
		local longueur_passage 	= if not cadre_use	then longueur 	else longueur 	- 2*cadre_largeur
		local hauteur_passage 		= if not cadre_use	then hauteur 		else hauteur 	- 2*cadre_largeur
		
		---- maj du cadre ------------------
		if cadre_use do (
			compo_cadre.longueur 						= longueur
			compo_cadre.profondeur 					= profondeur
			compo_cadre.hauteur 						= hauteur
			compo_cadre.menuis_largeur	 			= cadre_largeur	
			compo_cadre.travBasse_hauteur			= cadre_largeur		
			compo_cadre.low_poly			 			= low_poly		
			compo_cadre.matId_menuis	 			= matId_menuis
		)
		
		---- maj ouvrant		----
		compo_ouvrant_1.profondeur 				= ouvrant_profondeur
		compo_ouvrant_1.hauteur 					= hauteur_passage
		compo_ouvrant_1.cadre_largeur 			= ouvrant_cadre_larg
		compo_ouvrant_1.travBasse_hauteur		= ouvrant_cadre_larg		
		
		compo_ouvrant_1.div_montants_nbr 		= div_montants_nbr
		compo_ouvrant_1.div_traverses_nbr 		= div_traverses_nbr
		compo_ouvrant_1.div_largeur					= div_largeur
		compo_ouvrant_1.div_profondeur			= div_profondeur
		compo_ouvrant_1.div_calage_verti			= div_calage_verti
		compo_ouvrant_1.vitrage_epaisseur		= vitrage_epaisseur
		
		compo_ouvrant_1.low_poly			 		= low_poly
		compo_ouvrant_1.matId_menuis	 			= matId_menuis
		compo_ouvrant_1.matId_vitrage	 			= matId_vitrage		
	
		if not ouvrant_double then (
			compo_ouvrant_1.longueur 				= longueur_passage
		) else (
			if  ouvrant_tierce then (
				
				compo_ouvrant_1.longueur 	= longueur_passage 	*  ouvrant_tierce_pourcent / 100 
				
				compo_ouvrant_2 							= copy compo_ouvrant_1
				compo_ouvrant_2.longueur 				=  longueur_passage	* ( 100 - ouvrant_tierce_pourcent ) / 100
				compo_ouvrant_2.div_montants_nbr 	=  div_montants_nbr_2
			
			)	else 	(
				compo_ouvrant_1.longueur 	= longueur_passage / 2
				compo_ouvrant_2 				= compo_ouvrant_1
			)
		)
		
		
	)  --- fin composants_actualiser  ------------------
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		composants_actualiser ()
		
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
		
		local longueur_ouvrant 	= 	compo_ouvrant_1.longueur 
		local callage_montant_G 	= 	if cadre_use then cadre_largeur	else	0
		local callage_montant_D 	=	callage_montant_G
		local ouvrant_pos_z 		= 	callage_montant_G
		
		if  symetrie and not ouvrant_double	then (
			origine_ouv_1	=	transMatrix	[ -longueur_ouvrant, - ouvrant_profondeur ,	ouvrant_pos_z ]	
			rotate_ouv_1	=	rotateZMatrix -ouvert_angle_1
			recalle_ouv_1	=	transMatrix	[longueur - callage_montant_G, ouvrant_callage + ouvrant_profondeur ,	0 ]
		) else (
			origine_ouv_1	=	transMatrix	[ 0, -ouvrant_profondeur,	ouvrant_pos_z ]
			rotate_ouv_1	=	rotateZMatrix 	ouvert_angle_1 
			recalle_ouv_1	=	transMatrix	[callage_montant_G, ouvrant_callage + ouvrant_profondeur,	0 ]
		)
		if  ouvrant_double do (			
			origine_ouv_2	=	transMatrix	[ -compo_ouvrant_2.longueur, -ouvrant_profondeur ,	ouvrant_pos_z ]
			rotate_ouv_2 	=  rotateZMatrix -ouvert_angle_2
			recalle_ouv_2	=	transMatrix	[longueur - callage_montant_D, ouvrant_callage + ouvrant_profondeur,	0 ]
		)
		
		
		
		---- 1er ouvrant ------------
		local transf_ouvrant_1	=	origine_ouv_1 * rotate_ouv_1 * recalle_ouv_1		
		mgr_mesh.attacher		mesh		compo_ouvrant_1 	transf:transf_ouvrant_1
		
		try debug"compo_ouvrant_1" 	var:compo_ouvrant_1.ouvrant_cadre_larg	catch ()
		
		---- 2nd ouvrant	------------
		if  ouvrant_double do (
			
			local	transf_ouvrant_2 = origine_ouv_2 * rotate_ouv_2 * recalle_ouv_2		
			mgr_mesh.attacher		mesh		compo_ouvrant_2 	transf:transf_ouvrant_2
			
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
				3: #stop
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
				3:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
					
			)		
	) --- fin tool create ---------
	
) ------- fin plugin ---------------------






		


