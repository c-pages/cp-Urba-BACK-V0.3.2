


/* 
global elemFac_menuiserie

dossier = "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\menuiseries\\fix"
-- plugs_aCharger = getfiles		( dossier + "*.ms" )
for plug_aCharger in plugs_aCharger do
	filein plug_aCharger
	 */

include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Fix.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Ouvrant.ms"


plugin simpleObject 	urba_menuis_ensemble
name:"Ensemble"
classID:#(782522,1273452)
category:"CP | Urba | Batiment"
(
	local m_menuiserie
	
	
	parameters transfo
	(
		transformation	type:#matrix3	default:(matrix3 1)
	)
	parameters main rollout:params
	(
		longueur 	type:#worldUnits 	ui:spn_longueur 	default:1E-3
		hauteur	 	type:#worldUnits 	ui:spn_hauteur 	default:1E-3
		epaisseur	 	type:#worldUnits 	ui:spn_epaisseur			default:7
		nbr_menuis		 	type:#integer		 	ui:spn_nbr_menuis	 	default:1
		
		rotTEMP			 	type:#float 			ui:spn_rotTEMP					default:0
		
		on rotTEMP set  val do
			transformation =  rotateZMatrix	rotTEMP
		
	)
	rollout params "Facade" width:239 height:282
	(
		spinner 'spn_longueur' "longueur" pos:[13,7] width:70 height:16 range:[0.001,1e+09,0.001] type:#worldunits align:#left
		spinner 'spn_hauteur' "hauteur" pos:[13,26] width:70 height:16 range:[0.001,1e+09,0.001] type:#worldunits align:#left
		spinner 'spn_nbr_menuis' "nbr_menuis" pos:[13,47] width:70 height:16 range:[1,1e+09,1] type:#integer align:#left
		spinner 'spn_epaisseur'	 	"epaisseur" 		type:#worldunits range:[-1000,1000,0]
		spinner 'spn_rotTEMP'	 	"rotTmp" 		type:#float range:[-360,360,0]
		
-- 		listbox 'lbx1' "" pos:[14,88] width:139 height:6 align:#left
-- 		pickbutton 'btn1' "+" pos:[14,70] width:16 height:16 align:#left
-- 		pickbutton 'btn2' "-" pos:[29,70] width:16 height:16 align:#left
	)
	
	
	
	
	fn ajoute_menuiserie 	largeur		hauteur		prof		transf:	epaisseur:		matId_menuis:		matId_vitrage:	=(
		
		---- on creer le sous objet model ---------------------
		if m_menuiserie == undefined do
			m_menuiserie = createInstance  urba_menuis_fix	
		m_menuiserie.largeur 				= largeur
		m_menuiserie.hauteur 				= hauteur
		m_menuiserie.profondeur 			= prof
		
		if transf!= unsupplied do
			m_menuiserie.transformation 		= transf
		
		if matId_menuis!= unsupplied do
			m_menuiserie.matId_menuis 			= matId_menuis
		if matId_vitrage!= unsupplied do
			m_menuiserie.matId_vitrage 			= matId_vitrage
		
		if epaisseur		!= unsupplied do
			m_menuiserie.epaisseur 			= epaisseur
		
		--- onl'ajoute a notre mesh ----------
		mesh += m_menuiserie.mesh
-- 		meshop.attach	mesh		m_menuiserie.mesh
		
	)
	
	
	
	
	
	
	on buildMesh do
	(
-- 		format "build facade_sequence \n"
		delete mesh
		
		
		local mtrx_depose = matrix3 1 * transformation
		for i = 1 to nbr_menuis do (
			ajoute_menuiserie 	longueur		hauteur		5		epaisseur:epaisseur		transf:mtrx_depose
			translate mtrx_depose ( [longueur,0,0]  * transformation )
		)
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
			2: (longueur = abs gridDist.x)
			3: hauteur = gridDist.z
		)
	)
)




















