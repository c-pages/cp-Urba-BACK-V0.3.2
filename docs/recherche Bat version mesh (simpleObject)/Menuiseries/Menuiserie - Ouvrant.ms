


include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Primitives\\Primitive - Boite.ms"
include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\recherche - simpleObject - mgr - Construction base.ms"


	
plugin simpleObject		urba_menuis_ouvrant
name:"Ouvrant"
classID:#(0x6f5f9c8f, 0x1da0418a)
category:"CP | Urba | menuiseries"
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuis_ouvrant"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	--- Optionnel:		Le plug contenant la menuiserie ("ensemble" de mensuierie) pour permettre d'enregistrer les parametres du fix dans le parent.
	local m_parent
	
	local mgr_constr	=	str_contruction_base ()
	
	
	
	parameters params_general rollout:roll_general
	(
		
		----- global ----------------
		longueur 				type:#worldUnits 		ui:spn_longueur 		default:1E-3
		hauteur	 				type:#worldUnits 		ui:spn_hauteur 		default:1E-3
		profondeur	 			type:#worldUnits 		ui:spn_profondeur	default:5		
		
		----- les menuiseries -------------
		menuis_epaisseur	 	type:#worldUnits 		ui:spn_epaisseur		default:7
		
		
		vitrage_ep	 			type:#worldUnits 											default:2
		
		ouverture_angle	 	type:#float			 	ui:spn_ouverture_angle			default:0
		ouverture_inverse	type:#boolean 		ui:shk_ouverture_inverser		default:false
		
		matId_menuis			type:#integer 			ui:spn_matId_menuis			default:1
		matId_vitrage			type:#integer 			ui:spn_matId_vitrage			default:2
		
		montant_G				type:#boolean 		default:true
		montant_D				type:#boolean 		default:true
		traverse_H				type:#boolean 		default:true
		
	)
	rollout roll_general "Ouvrant"	(
		
		group 	"Global" (
			spinner spn_longueur 						"longueur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 						"Hauteur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 					"Profondeur" 			type:#worldunits range:[0,1e20,0]
			spinner spn_epaisseur	 					"Menuiseries" 				type:#worldunits range:[0,1e20,0]
		)
		
		group 	"Ouverture" (
			checkbox	shk_ouverture_inverser		"Inverse" 				
			spinner 	spn_ouverture_angle	 	"Angle" 					type:#float range:[0,180,0]
		)
		
		group 	"Material ID" (
			spinner spn_matId_menuis 				"Menuiseries" 		type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage				"Vitrage" 			type:#integer range:[1,1000,1]
		)
		
	)
	
	
	
	
	
	on buildMesh do
	(
		
		--- vider le mesh --------
		delete mesh
		
		
		--- la longueur des traverses------
		local long_trav	=	longueur
		if montant_G	do long_trav -= menuis_epaisseur
		if montant_D	do long_trav -= menuis_epaisseur
		
		--- la hauteur du vitrage -----
		local ht_vitrage	=	hauteur - menuis_epaisseur 
		if traverse_H	do ht_vitrage -= menuis_epaisseur 
		
		
		
		
		------------ LE CADRE -----------------		
		--- montant G  ----------
		if montant_G do
			mgr_constr.ajouter_boite 	mesh		long:		menuis_epaisseur			\
															prof:		profondeur			\
															ht:		hauteur				\
															matID:	matId_menuis		
		
		--- montant D ----------	
		if montant_D do
			mgr_constr.ajouter_boite 	mesh		long:		menuis_epaisseur		\
															prof:		profondeur		\
															ht:		hauteur			\
															transf:	[longueur - menuis_epaisseur,0,0] 					\
															matID:	matId_menuis
		
		--- traverse haute ----------
		mgr_constr.ajouter_boite 	mesh		long:		long_trav		\
														prof:		profondeur		\
														ht:		menuis_epaisseur		 	\
														transf:	[menuis_epaisseur,0,hauteur - menuis_epaisseur]				\
														matID:	matId_menuis
		
		
		
		
		----- L'OUVRANT ----------------
		local matrix_ouverture 			
		local matrx_origine_ouvrant 	
		if not ouverture_inverse then (
			matrx_origine_ouvrant 	= transMatrix  [0, -profondeur / 2 ,0]
			matrix_ouverture 			= rotateZMatrix	ouverture_angle * transMatrix  [menuis_epaisseur,profondeur  ,0]
		) else (
			matrx_origine_ouvrant 	= transMatrix  [-longueur, -profondeur / 2 ,0]
			matrix_ouverture 			= rotateZMatrix	-ouverture_angle * transMatrix  [longueur + menuis_epaisseur,profondeur  ,0]
		)
		
		
		
		
		
		
		--- montant G ----------
		mgr_constr.ajouter_boite 	mesh		long:		menuis_epaisseur		\
														prof:		profondeur		\
														ht:		( hauteur - menuis_epaisseur )			\
														transf:	( matrx_origine_ouvrant	*	matrix_ouverture )	\
														matID:	matId_menuis
							
		--- montant D ----------
		mgr_constr.ajouter_boite 	mesh		long:		menuis_epaisseur		\
														prof:		profondeur		\
														ht:		( hauteur - menuis_epaisseur )			\
														transf:	( matrx_origine_ouvrant * transMatrix  [long_trav - menuis_epaisseur,0,0]	*	matrix_ouverture )	\
														matID:	matId_menuis
		
		--- traverse B ----------
		mgr_constr.ajouter_boite 	mesh		long:		( long_trav - 2 *menuis_epaisseur)		\
														prof:		profondeur		\
														ht:		menuis_epaisseur			\
														transf:	( matrx_origine_ouvrant * transMatrix  [menuis_epaisseur,0,0]	*	matrix_ouverture )	\
														matID:	matId_menuis
		
		--- traverse ht ----------
		mgr_constr.ajouter_boite 	mesh		long:		( long_trav - 2 *menuis_epaisseur)		\
														prof:		profondeur		\
														ht:		menuis_epaisseur			\
														transf:	( matrx_origine_ouvrant * transMatrix  [menuis_epaisseur,0,hauteur - 2 * menuis_epaisseur]	*	matrix_ouverture )	\
														matID:	matId_menuis
		
		--- vitrage ----------
		mgr_constr.ajouter_boite 	mesh		long:		( long_trav - 2 *menuis_epaisseur)		\
														prof:		vitrage_ep		\
														ht:		( hauteur - 3 *menuis_epaisseur)			\
														transf:	( matrx_origine_ouvrant * transMatrix  [menuis_epaisseur, (profondeur - vitrage_ep) / 2  , menuis_epaisseur]	*	matrix_ouverture )	\
														matID:	matId_vitrage
		
	)
	
	
	
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				4: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	hauteur 					= length ( gridPoint - pt_hauteur )
			)
		
	)
)

