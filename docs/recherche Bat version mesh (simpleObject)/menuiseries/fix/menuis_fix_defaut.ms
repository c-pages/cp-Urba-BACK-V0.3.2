


include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\objets simples\\boite.ms"
	
plugin simpleObject		elemFac_menuiserie
name:"elemFac_menuiserie"
classID:#(125512,563854)
category:"Scripted Primitives"
-- invisible:true
(
	local m_boite
	
	parameters transfo
	(
		transformation	type:#matrix3	default:(matrix3 1)
	)
	parameters main rollout:roll_params
	(
		largeur 			type:#worldUnits 	ui:spn_largeur 			default:100
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:250
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:5
		
		epaisseur	 	type:#worldUnits 	ui:spn_epaisseur			default:7
		vitrage_ep	 	type:#worldUnits 	default:2
		
		
		matId_menuis		type:#integer 			ui:spn_matId_menuis			default:1
		matId_vitrage		type:#integer 			ui:spn_matId_vitrage			default:2
		
		
-- 		rot			 	type:#float 			ui:spn_rot					default:0
		
	)
	
	
	
	
	
	rollout roll_params "Two Faces Parameters"
	(
		spinner spn_largeur 		"largeur" 		type:#worldunits range:[-1000,1000,0]
		spinner spn_hauteur 		"hauteur" 		type:#worldunits range:[-1000,1000,0]
		spinner spn_profondeur 	"profondeur" 	type:#worldunits range:[-1000,1000,0]
		spinner spn_epaisseur	 	"epaisseur" 					type:#worldunits range:[-1000,1000,0]
		spinner spn_matId_menuis 	"matId_menuis" 		type:#integer range:[1,1000,1]
		spinner spn_matId_vitrage	 	"matId_vitrage" 		type:#integer range:[1,1000,1]
-- 		spinner spn_rot	 	"rot" 						type:#float range:[-360,360,0]
		
		
	)
	
	fn ajoute_boite 	largeur		hauteur		prof		transf:	matID:	=(
		
		---- on creer le sous objet model ---------------------
		if m_boite == undefined do
			m_boite = createInstance  simple_boite	
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
	
	
	
	on buildMesh do
	(
-- 		format "build menuiserie \n"
		delete mesh
		
-- 		transformation =  rotateZMatrix	rot
		
		local matrx_origine = matrix3 1		
		
		--- montant vertical 1 ----------
		local mtrx_verti_1 =	matrx_origine  * transformation		
		ajoute_boite 	epaisseur		hauteur		profondeur		transf:mtrx_verti_1		matID:matId_menuis
		
		--- montant vertical 2 ----------
		local mtrx_verti_2 =	matrx_origine * transMatrix  [largeur - epaisseur,0,0]	 * transformation		
		ajoute_boite 	epaisseur		hauteur		profondeur		transf:mtrx_verti_2	matID:matId_menuis
		
		--- montant horizontal 1 ----------
		local mtrx_hori_1 =		matrx_origine * transMatrix  [epaisseur,0,0]	 		* transformation	
		ajoute_boite 	( largeur - 2 *epaisseur)		epaisseur		profondeur		transf:mtrx_hori_1	matID:matId_menuis
		
		--- montant horizontal 2 ----------
		local mtrx_hori_2 =		matrx_origine * transMatrix  [epaisseur,0,hauteur - epaisseur]	 	* transformation	
		ajoute_boite 	( largeur - 2 *epaisseur)		epaisseur		profondeur		transf:mtrx_hori_2	matID:matId_menuis
		
		--- vitrage ----------
		local mtrx_vitrage =	matrx_origine * transMatrix  [epaisseur, (profondeur - vitrage_ep) / 2  , epaisseur]	 	* transformation	
		ajoute_boite 	( largeur - 2 *epaisseur)		( hauteur - 2 *epaisseur)		vitrage_ep		transf:mtrx_vitrage	matID:matId_vitrage
		
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

