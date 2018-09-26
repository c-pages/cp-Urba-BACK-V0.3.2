

include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Primitives\\Primitive - Boite.ms"
	
plugin simpleObject		urba_menuis_fix
name:"Fix"
classID:#(0x4dd385d2, 0x5dd07f21)
category:"CP | Urba | menuiseries"
invisible:true
(
	local m_boite
	
	parameters params_transformation 	(
		transformation	type:#matrix3	default:(matrix3 1)
	)
	parameters params_general rollout:roll_general
	(
		
		largeur 			type:#worldUnits 	ui:spn_largeur 			default:0
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:0
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:0
		
		epaisseur	 	type:#worldUnits 	ui:spn_epaisseur			default:0
		vitrage_ep	 	type:#worldUnits 	default:2
		
		matId_menuis		type:#integer 		ui:spn_matId_menuis	default:1
		matId_vitrage		type:#integer 		ui:spn_matId_vitrage	default:2
		
	)
	
	
	
	
	
	rollout roll_general  "Fix"
	(
		
		local m_parent
		
		group "Global" (
			spinner spn_largeur 		"Largeur" 		type:#worldunits range:[-1000,1000,0]
			spinner spn_hauteur 		"Hauteur" 		type:#worldunits range:[-1000,1000,0]
			spinner spn_profondeur 	"Profondeur" 	type:#worldunits range:[-1000,1000,0]
			spinner spn_epaisseur	 	"Epaisseur" 		type:#worldunits range:[-1000,1000,0]
		)
		
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 		type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage	"Vitrage" 			type:#integer range:[1,1000,1]
		)
		
		on spn_largeur 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_hauteur 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_profondeur 		changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_epaisseur 		changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_menuis 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_vitrage 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		
	)
	
	fn enregistrer_params	=()
	fn creer_boite 	largeur		hauteur		prof		transf:	matID:	=(
		
		---- on creer le sous objet model ---------------------
		if m_boite == undefined do
			m_boite = createInstance  urba_prim_boite	
		m_boite.largeur 				= largeur
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
	
	
	
	on buildMesh do	(
		--- vider le mesh --------
		delete mesh
		
		local matrx_origine = matrix3 1
		
		--- montant vertical 1 ----------
		local mtrx_verti_1 =	matrx_origine  * transformation
		creer_boite 	epaisseur		hauteur		profondeur		transf:mtrx_verti_1		matID:matId_menuis
		
		--- montant vertical 2 ----------
		local mtrx_verti_2 =	matrx_origine * transMatrix  [largeur - epaisseur,0,0]	 * transformation
		creer_boite 	epaisseur		hauteur		profondeur		transf:mtrx_verti_2	matID:matId_menuis
		
		--- montant horizontal 1 ----------
		local mtrx_hori_1 =		matrx_origine * transMatrix  [epaisseur,0,0]	 		* transformation
		creer_boite 	( largeur - 2 *epaisseur)		epaisseur		profondeur		transf:mtrx_hori_1	matID:matId_menuis
		
		--- montant horizontal 2 ----------
		local mtrx_hori_2 =		matrx_origine * transMatrix  [epaisseur,0,hauteur - epaisseur]	 	* transformation
		creer_boite 	( largeur - 2 *epaisseur)		epaisseur		profondeur		transf:mtrx_hori_2	matID:matId_menuis
		
		--- vitrage ----------
		local mtrx_vitrage =	matrx_origine * transMatrix  [epaisseur, (profondeur - vitrage_ep) / 2  , epaisseur]	 	* transformation
		creer_boite 	( largeur - 2 *epaisseur)		( hauteur - 2 *epaisseur)		vitrage_ep		transf:mtrx_vitrage	matID:matId_vitrage
		
	)
	
	
	
	tool create
	(
		on mousePoint click do
		case click of
		(
			1: nodeTM.translation = gridPoint
			3: #stop
		)
		on mouseMove click do
		case click of
		(
			2: (width = abs gridDist.x; length = abs gridDist.y)
			3: height = gridDist.z
		)
	)
)

