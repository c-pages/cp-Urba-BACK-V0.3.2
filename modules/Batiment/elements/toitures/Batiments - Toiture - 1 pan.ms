



--- parametres de base	-----------------------------
toiture_nom 	= "1 pan"	
toiture_type	=	#pan1
toiture_toolTip =	"..."

--- les parametres du composant	---------
struct toiture_params	(
	pente 					= 15,
	decalage_hauteur 	= 20,
	orientation				=	0,
	debord					= 50.,
	epaisseur 				= 15
)
--- les rollout du composant	---------
rollout toiture_dialog "Toiture - 1 pan" width:180 height:115
(
	local m_plug
	local m_toiture
	local mgr_toiture
	
	label 'lbl_pente' "Pente (°):" pos:[9,10] width:61 height:13 align:#left
	spinner 'spn_pente' "" pos:[92,9] width:70 height:16 range:[0.001,70,0] type:#float scale:1 align:#left
	label 'lbl_decallage' "Décallage (z)" pos:[9,26] width:63 height:13 align:#left
	spinner 'spn_decallage' "" pos:[92,25] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl_orientation' "Orientation (°):" pos:[9,42] width:70 height:13 align:#left
	spinner 'spn_orientation' "" pos:[92,41] width:70 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	
	
	label 'lbl_debord' "Debord" pos:[9,58] width:63 height:13 align:#left
	spinner 'spn_debord' "" pos:[92,57] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl_epaisseur' "Epaisseur" pos:[9,74] width:70 height:13 align:#left
	spinner 'spn14' "" pos:[92,73] width:70 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	
	
	
	fn actualiser =(
		spn_pente.value 	= 	m_toiture.params.pente
-- 		edt_nom.text 			=	m_toiture.nom
	)

	on spn_pente changed val do
	(
			m_toiture.params.pente		= val
			mgr_toiture.enregistrer_parametres 	m_toiture
			m_plug.core.actualiser ()
		)
	on spn_decallage changed val do
	(
			m_toiture.params.decalage_hauteur		= val
			mgr_toiture.enregistrer_parametres 	m_toiture
			m_plug.core.actualiser ()
		)
	on spn_orientation changed val do
	(
			m_toiture.params.orientation		= val
			mgr_toiture.enregistrer_parametres 	m_toiture
			m_plug.core.actualiser ()
		)
	on spn_debord changed val do
	(
			m_toiture.params.debord		= val
			mgr_toiture.enregistrer_parametres 	m_toiture
			m_plug.core.actualiser ()
		)
	on spn14 changed val do
	(
			m_toiture.params.epaisseur		= val
			mgr_toiture.enregistrer_parametres 	m_toiture
			m_plug.core.actualiser ()
		)
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 _composant		= (
	
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local mgr_surface  		= 	_plug.core.get_mgr_surface ()
		local ptr_geo 				= 	_plug.core.get_geo ()
		
-------------  PARAMETRES 	 et constantes		-----------------------------------------------------------------------------------------------------------------
		local toiture_pente 		= _composant.params.pente
		local toiture_hauteur		= _composant.params.decalage_hauteur
		local toiture_orient		= _composant.params.orientation
		local toiture_debord		= _composant.params.debord
		local toiture_epaisseur	= _composant.params.epaisseur
	
		local	 mtrx_axeP	=	mgr_surface.get_axePrincipal ()
		local	 BB_axeP		=	mgr_surface.get_axeP_BB ()
		rotateZ 		mtrx_axeP		toiture_orient	
		translate 	mtrx_axeP		BB_axeP[1]
	
		local diag_axeP		=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
		local largeur 		=	diag_axeP.x
		local longeur 		= 	diag_axeP.z
		local hauteur 		= largeur * tan 		toiture_pente
		local z 					= pts_accroches[1].z
		
		local nvlsFaces 		= #()
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		--- gestion de l'angle de la pente .... ----
		
		local pt_0 = (  [0,0,0]  *  mtrx_axeP )
		local pt_1 = (  [0,0,longeur]  *  mtrx_axeP )
		local pt_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )
		
		local vec1 = pt_1 - pt_0
		local vec2 = pt_2 - pt_0
		
		local pt_Origine = pt_0
		pt_Origine.z =  z + toiture_hauteur
		
		local plan_pente = ptr_geo.get_plan_2vecs_1Point		vec1		vec2		pt_Origine
		
		local pointsPente = #()
		local pointsMurs   =#()
		for i = 1 to  pts_accroches.count do (
			
			local j = i+1
			if j >  pts_accroches.count  do j = 1
			
			--- point Mur ----
			local pt 			= 	pts_accroches[i]	
			pt.z = z
			append pointsMurs  pt		
			
			local pt_result = plan_pente.projeter_point_verticalement 	pt
			
			append pointsPente  pt_result
			
		)
		
		---- on recalle les points sur Z----
		local recalleZ = 0
		for pt in pointsPente do (
			local ecart = abs ( (z + toiture_hauteur) - pt.z )
			if pt.z < z + toiture_hauteur and recalleZ < ecart do				
				recalleZ = ecart
		)
		for pt in pointsPente do pt.z += recalleZ			
		
		--- creation de la face du dessus ----
		local faceDessus =  ptr_geo.face 	pointsPente 	
		append nvlsFaces faceDessus
		ptr_geo.set_matID  faceDessus	#toiture
		
		---- creation des raccord mur ----------
		local facesMurs = #()
		for i = 1 to pointsMurs.count  do (
			
			local j = i+1
			if j >  pointsMurs.count  do j = 1
			
			local ptMur1 		= pointsMurs[i]
			local ptMur2 		= pointsMurs[j]
			local ptPente3 		= pointsPente[j]
			local ptPente4		= pointsPente[i]
			
			local pointsRaccord 	= #(ptMur1, ptMur2, ptPente3, ptPente4)
			local faceMurs 			= ptr_geo.face 	pointsRaccord
			
			ptr_geo.set_matID  faceMurs	#mur
			
			append nvlsFaces faceMurs
			
		)
	
		
		
		-- souder les points --
		local vertsASouder =#()
		for IDFace in nvlsFaces do (
			local vertsFace = polyop.getFaceVerts ptr_plug.delegate	 IDFace
			for vert in vertsFace do 
				appendIfUnique  vertsASouder 	vert
		)
		ptr_geo.souder		(vertsASouder as bitArray)
		
		
		---- debord et epaisseur du toit -----
		ptr_geo.biseauter	faceDessus 	0.0 	toiture_debord
		ptr_geo.extruder	faceDessus 	toiture_epaisseur

		
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
parametresTMP = toiture_params () 
str_modelBase 	tooltip:toiture_tooltip		nom:toiture_nom	type:toiture_type	params:(parametresTMP)	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
