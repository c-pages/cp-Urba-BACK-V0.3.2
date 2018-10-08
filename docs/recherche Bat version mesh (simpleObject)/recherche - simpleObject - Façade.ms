

include 	"$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Ensemble.ms"

plugin simpleObject		urba_facade
name:"Façade"
classID:#(0x52270659, 0x47a18321)
category:"CP | Urba | menuiseries"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_facade"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	local m_boite
	
	parameters params_transformation 	(
		transformation	type:#matrix3	default:(matrix3 1)
	)
	parameters params_general rollout:roll_general
	(
-- 		norm_dir			type:#point3
-- 		pt_debut		type:#point3		
-- 		pt_fin			type:#point3		
		
		longueur			type:#worldUnits 	ui:spn_longueur 			default:0.1
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:250
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:30
		
		matId_mur			type:#integer 		ui:spn_matId_mur		default:1
		matId_menuis		type:#integer 		ui:spn_matId_menuis	default:2
		matId_vitrage		type:#integer 		ui:spn_matId_vitrage	default:3
	)
	
	
	
	
	fn creer_boite 	longueur		hauteur		prof		transf:	matID:	=(
		
		---- on creer le sous objet model ---------------------
		if m_boite == undefined do
			m_boite = createInstance  urba_prim_boite	
		m_boite.largeur	 			= longueur
		m_boite.hauteur 				= hauteur
		m_boite.profondeur 			= prof	
		
		if transf!= unsupplied do	
			m_boite.transformation 	= transf		
		if matID!= unsupplied do
			m_boite.matID 				= matID
		
		
		--- onl'ajoute a notre mesh ----------
-- 		mesh += m_boite.mesh
		meshop.attach	mesh		m_boite.mesh
		
	)
	
	rollout roll_general  "Façade"
	(
		
		local m_parent
		
		group "Global" (
			spinner spn_longueur 		"Longueur" 		type:#worldunits range:[0.1,1e20,0]	--	enabled:false
			spinner spn_hauteur 		"Hauteur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 	"Profondeur" 	type:#worldunits range:[0,1e20,0]
		)
		
		group "Material ID" (
			spinner spn_matId_mur	 	"Murs" 				type:#integer range:[1,1000,1]
			spinner spn_matId_menuis 	"Menuiseries" 		type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage	"Vitrage" 			type:#integer range:[1,1000,1]
		)
		
-- 		on roll_general open do longueur = length ( pt_fin - pt_debut )
		
		on spn_longueur 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_hauteur 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_profondeur 		changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		
		on spn_matId_mur	 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_menuis 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_vitrage 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		
	)
	rollout roll_sequence  "Séquence"
	(
	)
	
	fn enregistrer_params	=()
	
	
	
	
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		creer_boite 	longueur		hauteur		profondeur		/* transf:mtrx_mur_1	 */	matID:matId_mur
		
	)
	
	
	
	tool create
	(
		local pt_debut
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				2: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 		= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
				)
			)
	)
)
