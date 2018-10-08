

include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Primitives\\Primitive - Boite.ms"
	
plugin simpleObject		urba_menuis_fix
name:"Fix"
classID:#(0x4dd385d2, 0x5dd07f21)
category:"CP | Urba | menuiseries"
-- invisible:true
(
	
	parameters params_translationormation 	(
		translationormation	type:#matrix3	default:(matrix3 1)
	)
	parameters params_general rollout:roll_general
	(
		
		longueur			type:#worldUnits 	ui:spn_longueur 			default:0
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:0
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:0
		
		epaisseur	 	type:#worldUnits 	ui:spn_epaisseur			default:7.
		vitrage_ep	 	type:#worldUnits 	default:2
		
		matId_menuis		type:#integer 		ui:spn_matId_menuis	default:1
		matId_vitrage		type:#integer 		ui:spn_matId_vitrage	default:2
		
	)
	
	
	
	
	
	rollout roll_general  "Fix"
	(
		
		group "Global" (
			spinner spn_longueur 		"Longueur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 		"Hauteur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 	"Profondeur" 	type:#worldunits range:[0,1e20,0]
			spinner spn_epaisseur	 	"Epaisseur" 		type:#worldunits range:[0,1e20,0]
		)
		
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 		type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage	"Vitrage" 			type:#integer range:[1,1000,1]
		)
		
		on spn_longueur 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_hauteur 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_profondeur 		changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_epaisseur 		changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_menuis 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_vitrage 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		
	)
	
	fn enregistrer_params	=()
	fn creer_boite 	longueur		hauteur		prof		translation:		matID:	=(
		
		---- on creer le sous objet model ---------------------
		nvl_boite = createInstance  urba_prim_boite	
		nvl_boite.longueur	 			= longueur
		nvl_boite.hauteur 				= hauteur
		nvl_boite.profondeur 			= prof	
		
		if matID!= unsupplied do	nvl_boite.matID 				= matID
		
		
		--- onl'ajoute a notre mesh ----------
		local id_pt_debut = ( meshop.getNumVerts mesh + 1 )
		meshop.attach	mesh		nvl_boite.mesh
		
		--- et on le place ----------
		if translation!= unsupplied do		
			meshop.moveVert 	mesh	#{id_pt_debut..(meshop.getNumVerts mesh)} translation
	)
	
	
	
	on buildMesh do	(
		--- vider le mesh --------
		delete mesh
		
		local matrx_origine = matrix3 1
		
		--- montant vertical 1 ----------
		creer_boite 	epaisseur		hauteur		profondeur			matID:matId_menuis
		
		--- montant vertical 2 ----------
		creer_boite 	epaisseur		hauteur		profondeur		translation:[longueur - epaisseur,0,0]	matID:matId_menuis
		
		--- montant horizontal 1 ----------
		creer_boite 	( longueur - 2 *epaisseur)		epaisseur		profondeur		translation: [epaisseur,0,0]	matID:matId_menuis
		
		--- montant horizontal 2 ----------
		creer_boite 	( longueur - 2 *epaisseur)		epaisseur		profondeur		translation:[epaisseur,0,hauteur - epaisseur]		matID:matId_menuis
		
		--- vitrage ----------
		creer_boite 	( longueur - 2 *epaisseur)		( hauteur - 2 *epaisseur)		vitrage_ep		translation:[epaisseur, (profondeur - vitrage_ep) / 2  , epaisseur]	matID:matId_vitrage
		
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

