
plugin simpleObject		urba_menuiserieBase_cadre
name:"Cadre"
classID:#(0x191d683f, 0x345d8d04)
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
		
		------ options --------------
		low_poly				type:#boolean 		ui:shk_lowPoly				default:true
		montant_G			type:#boolean 		ui:shk_montant_G		default:true
		montant_D			type:#boolean 		ui:shk_montant_D		default:true
		traverse_B			type:#boolean 		ui:shk_traverse_B		default:true
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		
	)
	rollout roll_general  "Cadre"
	(
		group "Menuiserie" (
			spinner spn_longueur 		"longueur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 		"Hauteur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 	"Profondeur" 	type:#worldunits range:[0,1e20,0]
			spinner spn_epaisseur	 	"Epaisseur" 		type:#worldunits range:[0,1e20,0]
		)
		group "Qualité" (
			checkbox	shk_lowPoly			"Low poly"
		)
		
		group "Options" (	
			checkbox	shk_montant_G		"Montant gauche" 			
			checkbox	shk_montant_D		"Montant droit" 		
			checkbox	shk_traverse_B		"traverse basse" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 		type:#integer range:[1,1000,1]
		)
		
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
		
		
		---- la version low poly ----------------
		if low_poly then (
			
			--- montant  gauche ----------
			if montant_G do
				mgr_constr.ajouter_boite_L 	mesh		long:		menuis_epaisseur		\
																	prof:		profondeur				\
																	ht:		hauteur					\
																	matID:	matId_menuis			
			
			--- montant droite ----------
			if montant_D do
				mgr_constr.ajouter_boite_L 	mesh		long:			menuis_epaisseur							\
																	prof:			profondeur									\
																	ht:			hauteur										\
																	sym:			true											\
																	transf:		[longueur - menuis_epaisseur,0,0]	\
																	matID:		matId_menuis								
			
			--- traverse basse ----------
			if traverse_B do
				mgr_constr.ajouter_boite_L 	mesh		long:			long_trav						\
																	prof:			profondeur						\
																	ht:			menuis_epaisseur		\
																	transf:		[posX_traverses,0,0]		\
																	horiz:			true								\
																	matID:		matId_menuis					
			
			--- traverse	haute ----------
			mgr_constr.ajouter_boite_L 	mesh		long:			long_trav														\
																prof:			profondeur														\
																ht:			menuis_epaisseur												\
																horiz:			true																\
																sym:			true																\
																transf:		[posX_traverses,0,hauteur - menuis_epaisseur]		\
																matID:		matId_menuis													
		
		---- la version normale ----------------
		) else (
			
			--- montant  gauche ----------
			if montant_G do
				mgr_constr.ajouter_boite 	mesh		long:		menuis_epaisseur		\
																prof:		profondeur				\
																ht:		hauteur					\
																matID:	matId_menuis			\
																bool:		false
			
			--- montant droite ----------
			if montant_D do
				mgr_constr.ajouter_boite 	mesh		long:			menuis_epaisseur							\
																prof:			profondeur									\
																ht:			hauteur										\
																transf:		[longueur - menuis_epaisseur,0,0]	\
																matID:		matId_menuis								\
																bool:			false
			
			--- traverse basse ----------
			if traverse_B do
				mgr_constr.ajouter_boite 	mesh		long:			long_trav						\
																prof:			profondeur						\
																ht:			menuis_epaisseur		\
																transf:		[posX_traverses,0,0]		\
																matID:		matId_menuis					\
																bool:			false
			
			--- traverse	haute ----------
			mgr_constr.ajouter_boite 	mesh		long:			long_trav														\
															prof:			profondeur														\
															ht:			menuis_epaisseur												\
															transf:		[posX_traverses,0,hauteur - menuis_epaisseur]	\
															matID:		matId_menuis													\
															bool:			false
		
			
		)
		
		
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
				5: menuis_epaisseur 	= length ( gridPoint - pt_epaisseur )
			)		
	) --- fin tool create ---------
	
	
	
	
)