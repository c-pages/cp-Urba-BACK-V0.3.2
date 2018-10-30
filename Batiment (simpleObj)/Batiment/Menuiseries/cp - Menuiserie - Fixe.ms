


plugin simpleObject		cp_menuis_fixe
name:"Fixe"
classID:#(0x154a56e1, 0x726397f7)
category:"CP | Facade	| Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuis_fixe"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres 
	
	--- composant ---
	local compo_cadre, compo_vitrage
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_global rollout:roll_global	(
		longueur 				type:#worldUnits 	ui:spn_longueur 			default:0.
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 			default:0.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur		default:5.
		
		cadre_use				type:#boolean 		ui:shk_cadre				default:true
		travBasse_hauteur	type:#worldUnits 	ui:spn_travB_ht			default:3.5
	)
	parameters params_general rollout:roll_parametres	(
		
		
		
		
		----- les menuiseries -----------
		cadre_largeur	 				type:#worldUnits 	default:3.5
		vitrage_epaisseur				type:#worldUnits 	default:1.
		
		
		----- ouvrants ---------------------
		ouvrant_epaisseur	 		type:#worldUnits 	default:4.	
		ouvrant_profondeur	 		type:#worldUnits 	default:4.	
		ouvrant_callage	 			type:#worldUnits 	default:1.5
		div_profondeur	 			type:#worldUnits 	default:3.
		
		
		div_largeur	 					type:#worldUnits 	ui:spn_div_largeur			default:2.
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr	default:0.
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr	default:0.
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti		default:0.
		
	)	-----	fin parametres --------------------
	parameters params_divers rollout:roll_divers	(
		
		
		nom	 							type:#string 	default:"Fixe"
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)	-----	fin parametres --------------------
	
	
	
	
	
	rollout roll_global  "Global"	(
		spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_profondeur 		"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
		
		checkbox	shk_cadre				"Cadre" 		
		spinner 	spn_travB_ht			 "Trav B. ht." 			type:#worldunits range:[0,1e20,0]
		
		fn actualiser =( 
			
			spn_travB_ht.indeterminate		=	not cadre_use
			spn_travB_ht.enabled 				=	cadre_use
		)
	)
	rollout roll_parametres  "Paramètres"	(
		on roll_global	open do actualiser ()
		on shk_cadre	changed state do actualiser ()
		group "Croisillons" (	
			spinner		spn_div_largeur			 "Largeur" 		type:#worldunits		range:[0,1e20,0]
			spinner 	spn_div_montants_nbr	 "Montants" 	type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 "Traverses" 	type:#integer			range:[0,1e20,0]
			spinner 	spn_div_calage_verti 	"Align. vert." 	type:#worldunits		range:[-1e20,1e20,0]
		)
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
	fn actualiser_composants	= with redraw off (
		
		if compo_cadre 	== undefined	do	compo_cadre		= 	createInstance  	cp_compo_cadre
		if compo_vitrage 	== undefined	do	compo_vitrage		= createInstance  	cp_compo_panneau
		
		local longueur_passage 	= if not cadre_use	then longueur 	else longueur 	- 2*cadre_largeur
		local hauteur_passage 		= if not cadre_use	then hauteur 		else hauteur 	- ( cadre_largeur + travBasse_hauteur )
		
		---- maj du cadre ------------------
		if cadre_use do (
			compo_cadre.longueur 						= longueur
			compo_cadre.profondeur 					= profondeur
			compo_cadre.hauteur 						= hauteur
			compo_cadre.menuis_largeur	 			= cadre_largeur	
			compo_cadre.travBasse_hauteur			= travBasse_hauteur		
			compo_cadre.low_poly			 			= low_poly		
			compo_cadre.matId_menuis	 			= matId_menuis
		)
		
		-----	le vitrage 	-------------
		compo_vitrage.longueur						=	longueur_passage
		compo_vitrage.hauteur							=	hauteur_passage
		
		compo_vitrage.vitrage_epaisseur	 		= vitrage_epaisseur
		compo_vitrage.div_montants_nbr 			= div_montants_nbr
		compo_vitrage.div_traverses_nbr 			= div_traverses_nbr
		compo_vitrage.div_largeur				 		= div_largeur
		compo_vitrage.div_profondeur			 	= div_profondeur		
		compo_vitrage.div_calage_verti		 		= div_calage_verti		
		
		compo_vitrage.low_poly			 			= low_poly		
		compo_vitrage.matId_menuis	 				= matId_menuis
		compo_vitrage.matId_vitrage	 				= matId_vitrage
		
	)  --- fin actualiser_composants  ------------------
	
	fn	est_ouvrant = false
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		---- le cadre -------
		if cadre_use do 
			mgr_mesh.attacher		mesh		compo_cadre
		
		--- le vitrage --------
		local callage_G 	= 	if cadre_use then cadre_largeur			else	0
		local callage_B 	= 	if cadre_use then travBasse_hauteur	else	0
		
		mgr_mesh.attacher		mesh		compo_vitrage 	transf:[callage_G, profondeur / 2 , callage_B ]
		
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






		


