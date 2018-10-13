
plugin simpleObject		menuiserie_composant_chassis
name:"Chassis"
classID:#(0x7094146b, 0x7896bea1)
category:"CP | Menuiserie | Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuis_fix"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	--- le manager de primitives---------------	
	local mgr_constr	=	str_mgr_primitives ()
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	
	
	
	parameters params_general rollout:roll_general
	(
		
		----- global ----------------
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- les menuiseries -------------
		menuis_epaisseur	 			type:#worldUnits 	ui:spn_epaisseur			default:0.
		
		----- les divisions -------------
		div_horiz		 				type:#integer		 	ui:spn_div_horiz			default:0.
		div_verti			 				type:#integer		 	ui:spn_div_verti			default:0.
		div_epaisseur	 				type:#worldUnits 	ui:spn_div_epaisseur		default:0.
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		montant_G						type:#boolean 		ui:shk_montant_G		default:true
		montant_D						type:#boolean 		ui:shk_montant_D		default:true
		traverse_B						type:#boolean 		ui:shk_traverse_B		default:true
		traverse_B_epaisseur		type:#worldUnits 	ui:spn_traverse_B_ep	default:0.
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
		----- pour rester dans valeurs corrects ------------------------
		on menuis_epaisseur 		set val do corriger_parametres ()
		on profondeur			 		set val do corriger_parametres ()
		on hauteur 					set val do corriger_parametres ()
		on traverse_B_epaisseur 	set val do corriger_parametres ()
		
		on div_horiz			 		set val do corriger_parametres ()
		on div_verti 					set val do corriger_parametres ()
		on div_epaisseur			 	set val do corriger_parametres ()
		
		
		
	)	-----	fin parametres --------------------
	
	
	rollout roll_general  "Chassis"
	(
		group "Global" (
			spinner spn_longueur 			"longueur" 					type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 			"Hauteur" 					type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 		"Profondeur" 				type:#worldunits range:[0,1e20,0]
		)
		group "Menuiserie" (
			spinner spn_epaisseur	 			"Epaisseur" 				type:#worldunits range:[0,1e20,0]
			checkbox	shk_montant_G		"Montant gauche" 			
			checkbox	shk_montant_D		"Montant droit" 
			checkbox	shk_traverse_B		"traverse basse" 		
			spinner 	spn_traverse_B_ep	"Epaisseur" 				type:#worldunits range:[0,1e20,0]
		)
		group "Division" (
			spinner spn_div_horiz	 		"Horizontale" 				type:#integer			range:[0,1e20,0]
			spinner spn_div_verti	 		"Verticale" 					type:#integer			range:[0,1e20,0]
			spinner spn_div_epaisseur	"Epaisseur" 					type:#worldunits 	range:[0,1e20,0]
		)
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 				type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 	"Vitrage" 					type:#integer range:[1,1000,1]
		)
		
		
		
		
		fn actualiser = (
			spn_traverse_B_ep.Indeterminate 	= not traverse_B
			spn_traverse_B_ep.enabled 			= traverse_B
		)
		
		on roll_general		open 				do	actualiser ()		
		on shk_traverse_B	changed val 	do	actualiser ()
		
	) 	---- fin rollout	-----------------------
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn corriger_parametres 	=(
		
		---- epaisseur des menuiseries --------
		if menuis_epaisseur >longueur/2 do menuis_epaisseur = longueur/2 
		if menuis_epaisseur + traverse_B_epaisseur > hauteur do (
			local rapport 				=  traverse_B_epaisseur	/	( menuis_epaisseur + traverse_B_epaisseur ) 
			menuis_epaisseur 		= 	hauteur *  ( 1- rapport)
			traverse_B_epaisseur 	=	hauteur *	rapport
		)
		
		
		---- les divisions ----------
		if div_epaisseur > profondeur do  div_epaisseur = profondeur 
		if longueur - 2*menuis_epaisseur < div_horiz * div_epaisseur do 
			div_horiz = ( longueur - 2*menuis_epaisseur  ) / div_epaisseur
		local hauteurMax = if traverse_B 	then hauteur - ( menuis_epaisseur  + traverse_B_epaisseur )
													else	hauteur - 2* menuis_epaisseur
		if  hauteurMax< div_verti * div_epaisseur do 
			div_verti = hauteurMax / div_epaisseur
		
	)

	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		--- la longueur des traverses------
		local posX_traverses	=	0
		local long_trav	=	longueur
		if montant_G	do (
			long_trav 			-= menuis_epaisseur
			posX_traverses 	+= menuis_epaisseur
		)
		if montant_D	do long_trav -= menuis_epaisseur
		
		
		
		---- on creer le sous objet model ---------------------
		local nv_cadre = createInstance  menuiserie_composant_cadre	longueur:				longueur				\
																								hauteur:					hauteur				\
																								profondeur:				profondeur			\
																								menuis_epaisseur:	menuis_epaisseur	\
																								montant_G:			montant_G			\
																								montant_D:			montant_D			\
																								traverse_B:				false					\
																								low_poly:				low_poly				\
																								matId_menuis:			matId_menuis
		
		meshop.attach		mesh		nv_cadre.mesh
		
		
		
		
		
		
		---- la traverse basse ----------
		local espace_vide_H =	long_trav
		if traverse_B do (
			if low_poly then
				mgr_constr.ajouter_boite_L 	mesh		long:			espace_vide_H				\
																	prof:			profondeur						\
																	ht:			traverse_B_epaisseur				\
																	transf:		[posX_traverses,0,0]		\
																	horiz:			true								\
																	matID:		matId_menuis					
			else
				mgr_constr.ajouter_boite	 	mesh		long:			espace_vide_H						\
																	prof:			profondeur						\
																	ht:			traverse_B_epaisseur				\
																	transf:		[posX_traverses,0,0]		\
																	matID:		matId_menuis	\
																	bool:			true	
		)
		
		
		
		
		----- les divisions ------------------
		local posY_traverses	=	0
		if traverse_B do	posY_traverses	=	traverse_B_epaisseur
			
		
		local espace_div_H 		= ( espace_vide_H - div_horiz * div_epaisseur ) / ( div_horiz + 1 )
		local depose_div_H		= [posX_traverses + espace_div_H, 	profondeur/2 -  div_epaisseur / 2,		posY_traverses	]
		
		local espace_vide_V 	= (hauteur - 	menuis_epaisseur	- posY_traverses		)
		local espace_div_V 		= ( espace_vide_V - div_verti * div_epaisseur ) / ( div_verti + 1 )
		local depose_div_V		= [posX_traverses, 	profondeur/2 -  div_epaisseur / 2,		posY_traverses  + espace_div_V 	]
		
		-------- divisions horizontales --------------
		for i = 1 to div_horiz do (
			if low_poly then
				mgr_constr.ajouter_boite_U 	mesh		long:			div_epaisseur					\
																	prof:			div_epaisseur					\
																	ht:			espace_vide_V				\
																	transf:		depose_div_H					\
																	matID:		matId_menuis					
			else
				mgr_constr.ajouter_boite	 	mesh		long:			div_epaisseur					\
																	prof:			div_epaisseur					\
																	ht:			espace_vide_V				\
																	transf:		depose_div_H					\
																	matID:		matId_menuis	
			
			depose_div_H.x += espace_div_H + div_epaisseur
		)
		
		-------- divisions verticales --------------
		for i = 1 to div_verti do (
			if low_poly then
				mgr_constr.ajouter_boite_U 	mesh		long:			espace_vide_H			\
																	prof:			div_epaisseur				\
																	ht:			div_epaisseur				\
																	horiz:			true							\
																	transf:		depose_div_V				\
																	matID:		matId_menuis					
			else
				mgr_constr.ajouter_boite	 	mesh		long:			espace_vide_H			\
																	prof:			div_epaisseur				\
																	ht:			div_epaisseur				\
																	horiz:			true							\
																	transf:		depose_div_V				\
																	matID:		matId_menuis	
			
			depose_div_V.z += espace_div_V + div_epaisseur
		)
		
		
		
		
		
		
		---- le vitrage ----------
		local ep_vitrage = 2
		if low_poly then
			mgr_constr.ajouter_plan_Vertical	 	mesh		long:			espace_vide_H					\
																			ht:			espace_vide_V				\
																			transf:		[posX_traverses, 	profondeur/2 ,		posY_traverses ]						\
																			matID:		matId_vitrage					
		else
			mgr_constr.ajouter_boite	 	mesh		long:			espace_vide_H				\
																prof:			ep_vitrage						\
																ht:			espace_vide_V				\
																transf:		[posX_traverses, 	profondeur/2 -  ep_vitrage / 2,		posY_traverses ]					\
																matID:		matId_vitrage	
		
		
		
		--- on clean -----
		if mesh.numfaces> 1 do
			meshop.autoSmooth		mesh 	#{1..mesh.numfaces} 		10
		
		
		
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
				1: (	pt_debut 	=  gridPoint
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
					div_epaisseur			=	profondeur
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
				5: ( 
					menuis_epaisseur 	= 		length ( gridPoint - pt_epaisseur )
					traverse_B_epaisseur = menuis_epaisseur
				)
				
			)		
	) --- fin tool create ---------
	
	
	
	
)