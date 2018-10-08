


include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Primitives\\Primitive - Boite.ms"
	
plugin simpleObject		urba_menuis_ouvrant
name:"Ouvrant"
classID:#(0x6f5f9c8f, 0x1da0418a)
category:"CP | Urba | menuiseries"
-- invisible:true
(
	local m_boite
-- 	
-- 	parameters params_transformation
-- 	(
-- 		transformation	type:#matrix3	default:(matrix3 1)
-- 	)
	parameters params_general rollout:roll_general
	(
		
		longueur 				type:#worldUnits 	ui:spn_longueur 					default:0
		hauteur 					type:#worldUnits 	ui:spn_hauteur 					default:0
		profondeur	 			type:#worldUnits 	ui:spn_profondeur				default:0		
		epaisseur	 			type:#worldUnits 	ui:spn_epaisseur					default:7
		vitrage_ep	 			type:#worldUnits 											default:2
		
		ouverture_aGauche	type:#boolean 		ui:shk_ouverture_AGauche		default:true
		ouverture_angle	 	type:#float			 	ui:spn_ouverture_angle			default:0
		
		matId_menuis			type:#integer 			ui:spn_matId_menuis			default:1
		matId_vitrage			type:#integer 			ui:spn_matId_vitrage			default:2
		
	)
	
	
	
	
	
	rollout roll_general "Ouvrant"	(
		
		local m_parent
		
		group 	"Global" (
			spinner spn_longueur 						"longueur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 						"Hauteur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 					"Profondeur" 			type:#worldunits range:[0,1e20,0]
			spinner spn_epaisseur	 					"Epaisseur" 				type:#worldunits range:[0,1e20,0]
		)
		
		group 	"Ouverture" (
			checkbox	shk_ouverture_AGauche	"A Gauche" 				
			spinner 	spn_ouverture_angle	 	"Angle" 					type:#float range:[0,180,0]
		)
		
		group 	"Material ID" (
			spinner spn_matId_menuis 				"Menuiseries" 		type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage				"Vitrage" 			type:#integer range:[1,1000,1]
		)
		
		on spn_longueur 					changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_hauteur 					changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_profondeur 				changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_epaisseur 				changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on shk_ouverture_AGauche	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_ouverture_angle		changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_menuis 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_vitrage 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		
	)
	
	fn enregistrer_params	=()
	fn creer_boite 	longueur		hauteur		prof	transformation:	translation:		orientation:		matID:	=(
		
		---- on creer le sous objet model ---------------------
		if m_boite == undefined do
			m_boite = createInstance  urba_prim_boite	
		m_boite.longueur 				= longueur
		m_boite.hauteur 				= hauteur
		m_boite.profondeur 			= prof	
		
		if matID!= unsupplied do
			m_boite.matID 				= matID
		
-- 		if orientation!= unsupplied do	
-- 			rotate m_boite orientation
		
		--- onl'ajoute a notre mesh ----------
		local id_pt_debut = ( meshop.getNumVerts mesh + 1 )
		meshop.attach	mesh		m_boite.mesh
		
		if translation!= unsupplied do	
			meshop.moveVert 	mesh	#{id_pt_debut..(meshop.getNumVerts mesh)} translation
		
		if transformation		!= unsupplied do	(
			local transf_tab =#()
			for id_pt = id_pt_debut to  (meshop.getNumVerts mesh) do (
				local pos_base =  meshop.getVert  mesh id_pt
				local pos_dest = pos_base * transformation
				append transf_tab ( pos_dest - pos_base)
			)
			meshop.moveVert 	mesh	#{id_pt_debut..(meshop.getNumVerts mesh)} transf_tab
			
			
		)
	)
	
	
	on buildMesh do
	(
		
		delete mesh
		
		local matrx_origine = matrix3 1
		
		------------ LE CADRE -----------------		
		--- montant vertical 1 ----------
		creer_boite 	epaisseur		hauteur		profondeur		/* transf:mtrx_verti_1 */		matID:matId_menuis
		
		--- montant vertical 2 ----------	
		creer_boite 	epaisseur		hauteur		profondeur		translation:[longueur - epaisseur,0,0]	matID:matId_menuis
		
		--- montant horizontal 2 ----------
		creer_boite 	( longueur - 2 *epaisseur)		epaisseur		profondeur		translation:[epaisseur,0,hauteur - epaisseur]	matID:matId_menuis
		
		
		----- L'OUVRANT ----------------
		local matrix_ouverture 			= rotateZMatrix	ouverture_angle * transMatrix  [epaisseur,profondeur  ,0]
		local matrx_origine_ouvrant 	= matrx_origine  * transMatrix  [0, -profondeur / 2 ,0]

		--- montant vertical 1 ----------
		local mtrx_verti_1 =	matrx_origine_ouvrant	*	matrix_ouverture
		creer_boite 	epaisseur		( hauteur - epaisseur )		profondeur		transformation:mtrx_verti_1		matID:matId_menuis
		
		--- montant vertical 2 ----------
		local mtrx_verti_2 =	matrx_origine_ouvrant * transMatrix  [longueur - 3 * epaisseur,0,0]	*	matrix_ouverture
		creer_boite 	epaisseur		( hauteur - epaisseur )			profondeur		transformation:mtrx_verti_2	matID:matId_menuis
		
		--- montant horizontal 1 ----------
		local mtrx_hori_1 =		matrx_origine_ouvrant * transMatrix  [epaisseur,0,0]	*	matrix_ouverture
		creer_boite 	( longueur - 4 *epaisseur)		epaisseur		profondeur		transformation:mtrx_hori_1	matID:matId_menuis
		
		--- montant horizontal 2 ----------
		local mtrx_hori_1 =		matrx_origine_ouvrant * transMatrix  [epaisseur,0,hauteur - 2 * epaisseur]	*	matrix_ouverture
		creer_boite 	( longueur - 4 *epaisseur)		epaisseur		profondeur		transformation:mtrx_hori_1	matID:matId_menuis

		--- vitrage ----------
		local mtrx_vitrage =	matrx_origine_ouvrant * transMatrix  [epaisseur, (profondeur - vitrage_ep) / 2  , epaisseur]	*	matrix_ouverture
		creer_boite 	( longueur - 4 *epaisseur)		( hauteur - 3 *epaisseur)		vitrage_ep	transformation:mtrx_vitrage		matID:matId_vitrage
		
	)
	
	
	
	tool create
	(
		/* on mousePoint click do
		case click of
		(
			1: nodeTM.translation = gridPoint
			3: #stop
		)
		on mouseMove click do
		case click of
		(
			2: (longueur = abs gridDist.x)
			3: hauteur = gridDist.z
		) */
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

