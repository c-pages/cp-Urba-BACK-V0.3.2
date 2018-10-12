
plugin simpleObject		urba_menuiserieBase_chassis
name:"Chassis"
classID:#(0x7094146b, 0x7896bea1)
category:"CP | Menuiserie base"
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
	
	
	
	
	
	parameters params_general rollout:roll_general
	(
		
		----- global ----------------
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- les menuiseries -------------
		menuis_epaisseur	 			type:#worldUnits 	ui:spn_epaisseur			default:0.
		traverse_B_epaisseur		type:#worldUnits 	ui:spn_traverse_B_ep	default:0.
		
		----- les divisions -------------
		div_horiz		 				type:#integer		 	ui:spn_div_horiz			default:0.
		div_verti			 				type:#integer		 	ui:spn_div_verti			default:0.
		div_epaisseur	 				type:#worldUnits 	ui:spn_div_epaisseur		default:0.
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)
	rollout roll_general  "Chassis"
	(
		group "Menuiserie" (
			spinner spn_longueur 			"longueur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 			"Hauteur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
			spinner spn_epaisseur	 		"Epaisseur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_traverse_B_ep	"Trav. basse ép." 	type:#worldunits range:[0,1e20,0]
		)
		group "Division" (
			spinner spn_div_horiz	 		"Horizontale" 			type:#integer			range:[0,1e20,0]
			spinner spn_div_verti	 		"Verticale" 				type:#integer			range:[0,1e20,0]
			spinner spn_div_epaisseur	"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
		)
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 	"Vitrage" 				type:#integer range:[1,1000,1]
		)
	)
	
	

	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		---- le contour du chassis --------
	
		---- on creer le sous objet model ---------------------
		local nv_cadre = createInstance  urba_menuiserieBase_cadre	longueur:				longueur				\
																							hauteur:					hauteur				\
																							profondeur:				profondeur			\
																							menuis_epaisseur:	menuis_epaisseur	\
																							traverse_B:				false					\
																							low_poly:				low_poly				\
																							matId_menuis:			matId_menuis
		
		meshop.attach		mesh		nv_cadre.mesh
		
		
		---- la traverse basse ----------
		local espace_vide_H = (longueur - 2*		menuis_epaisseur)
		
		if low_poly then
			mgr_constr.ajouter_boite_L 	mesh		long:			espace_vide_H				\
																prof:			profondeur						\
																ht:			traverse_B_epaisseur				\
																transf:		[menuis_epaisseur,0,0]		\
																horiz:			true								\
																matID:		matId_menuis					
		else
			mgr_constr.ajouter_boite	 	mesh		long:			espace_vide_H						\
																prof:			profondeur						\
																ht:			traverse_B_epaisseur				\
																transf:		[menuis_epaisseur,0,0]		\
																matID:		matId_menuis	\
																bool:			true	
		
		
		
		
		
		----- les divisions ------------------
		local espace_div_H 		= ( espace_vide_H - div_horiz * div_epaisseur ) / ( div_horiz + 1 )
		local depose_div_H		= [menuis_epaisseur + espace_div_H, 	profondeur/2 -  div_epaisseur / 2,		traverse_B_epaisseur]
		
		local espace_vide_V 	= (hauteur - 	menuis_epaisseur	- traverse_B_epaisseur		)
		local espace_div_V 		= ( espace_vide_V - div_verti * div_epaisseur ) / ( div_verti + 1 )
		local depose_div_V		= [menuis_epaisseur, 	profondeur/2 -  div_epaisseur / 2,		traverse_B_epaisseur  + espace_div_V ]
		
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
				mgr_constr.ajouter_boite_U 	mesh		long:			espace_vide_H					\
																	prof:			div_epaisseur					\
																	ht:			div_epaisseur				\
																	horiz:			true								\
																	transf:		depose_div_V					\
																	matID:		matId_menuis					
			else
				mgr_constr.ajouter_boite	 	mesh		long:			espace_vide_H					\
																	prof:			div_epaisseur					\
																	ht:			div_epaisseur				\
																	horiz:			true								\
																	transf:		depose_div_V					\
																	matID:		matId_menuis	
			
			depose_div_V.z += espace_div_V + div_epaisseur
		)
		
		
		
		
		
		
		---- le vitrage ----------
		local ep_vitrage = 2
		if low_poly then
			mgr_constr.ajouter_plan_Vertical	 	mesh		long:			espace_vide_H					\
																			ht:			espace_vide_V				\
																			transf:		[menuis_epaisseur, 	profondeur/2 ,		traverse_B_epaisseur ]						\
																			matID:		matId_vitrage					
		else
			mgr_constr.ajouter_boite	 	mesh		long:			espace_vide_H				\
																prof:			ep_vitrage						\
																ht:			espace_vide_V				\
																transf:		[menuis_epaisseur, 	profondeur/2 -  ep_vitrage / 2,		traverse_B_epaisseur ]					\
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
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
				5: menuis_epaisseur 	= traverse_B_epaisseur		=		length ( gridPoint - pt_epaisseur )
			)		
	) --- fin tool create ---------
	
	
	
	
)