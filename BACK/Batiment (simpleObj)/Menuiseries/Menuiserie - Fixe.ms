


plugin simpleObject		urba_menuiserie_fixe
name:"Fixe"
classID:#(0x154a56e1, 0x726397f7)
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
	local corriger_parametres 
	
	--- composant ---
	local compo_chassisVitre
	
	parameters params_dimensions rollout:roll_dimensions	(
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
	)
	parameters params_general rollout:roll_parametres	(
		
		----- les menuiseries -----------
		cadre_largeur	 				type:#worldUnits 	default:3.5
		profondeur	 					type:#worldUnits 	default:5.
		vitrage_epaisseur				type:#worldUnits 	default:1.
		
		travBasse_hauteur		 	type:#worldUnits 	default:10.
		
		----- ouvrants ---------------------
		ouvrant_epaisseur	 		type:#worldUnits 	default:4.	
		ouvrant_profondeur	 		type:#worldUnits 	default:4.	
		ouvrant_callage	 			type:#worldUnits 	default:1.5
		div_largeur	 					type:#worldUnits 	default:2.
		div_profondeur	 			type:#worldUnits 	default:3.
		
		
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr	default:0.
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr	default:0.
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti		default:0.
		
		symetrie							type:#boolean 		ui:shk_symetrie				default:false
		ouvert_angle					type:#float 			ui:spn_angle				default:0.
		
		on ouvrant_decallage		set val 	do	corriger_parametres ()
	)	-----	fin parametres --------------------
	
	parameters params_divers rollout:roll_divers	(
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)	-----	fin parametres --------------------
	
	
	
	
	
	rollout roll_dimensions  "Dimensions"	(
		spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
	)
	rollout roll_parametres  "Paramètres"	(
		spinner 	spn_cadre_travB_ht	 "Trav B. ht." 			type:#worldunits range:[0,1e20,0]
		group "Croisillons" (	
			spinner 	spn_div_montants_nbr	 "Nbr. montants" 	type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 "Nbr. traverses" 	type:#integer			range:[0,1e20,0]
			spinner 	spn_div_calage_verti 	"Calage vertical" 	type:#worldunits		range:[-1e20,1e20,0]
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
		
		if compo_chassisVitre == undefined	do
			compo_chassisVitre		= createInstance  menuiserie_composant_chassisVitre
		
		local longueur_passage 	=	longueur - 2* cadre_largeur
		local hauteur_passage		= 	hauteur - ( cadre_largeur 	- travBasse_hauteur )
		
		-----	le vitrage 	-------------
		compo_chassisVitre.longueur						=	longueur
		compo_chassisVitre.hauteur						=	hauteur
		compo_chassisVitre.profondeur 					= profondeur
		compo_chassisVitre.cadre_largeur 				= cadre_largeur
		
		compo_chassisVitre.travBasse_hauteur 		= travBasse_hauteur		
		compo_chassisVitre.vitrage_epaisseur	 		= vitrage_epaisseur
		compo_chassisVitre.div_montants_nbr 		= div_montants_nbr
		compo_chassisVitre.div_traverses_nbr 		= div_traverses_nbr
		compo_chassisVitre.div_largeur				 	= div_largeur
		compo_chassisVitre.div_profondeur			 	= div_profondeur		
		compo_chassisVitre.div_calage_verti		 	= div_calage_verti		
		compo_chassisVitre.low_poly			 			= low_poly		
		compo_chassisVitre.matId_menuis	 			= matId_menuis
		compo_chassisVitre.matId_vitrage	 			= matId_vitrage
		
	)  --- fin actualiser_composants  ------------------
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		---- le chassis -------
		mesh	+	compo_chassisVitre.mesh
		
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






		


