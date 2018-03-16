


	
( ----	FileIn ----
	
	


--- parametres de base	-----------------------------
toiture_nom 	= "1 pan"	
toiture_type	=	#pan1
toiture_toolTip =	"..."

--- les parametres du composant	---------
struct toiture_params	(
	pente 					= 6,
	decalage_hauteur 	= 20,
	orientation				=	0,
	debord					= 50.,
	epaisseur 				= 15,
	
	fn VP_afficher 	nd	surface_pts	z	=(
		
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	nd
		local mgr_surface  		= 	nd.core.get_mgr_surface ()
		local ptr_geo 				= 	nd.core.get_geo ()
		
-------------  PARAMETRES 	 et constantes		-----------------------------------------------------------------------------------------------------------------
		local toiture_pente 		= pente
		local toiture_hauteur		= decalage_hauteur
		local toiture_orient		= orientation
		local toiture_debord		= debord
		local toiture_epaisseur	= epaisseur
	
		local	 mtrx_axeP	=	mgr_surface.get_axePrincipal ()
		local	 BB_axeP		=	mgr_surface.get_axeP_BB ()
		
		rotateZ 		mtrx_axeP		toiture_orient	
		translate 	mtrx_axeP		BB_axeP[1]
	
		local diag_axeP		=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
		local largeur 		=	diag_axeP.y
		local longeur 		= 	diag_axeP.x
		local hauteur 		= largeur * tan 		toiture_pente
-- 		local z 					= surface_pts[1].z
		
		local nvlsFaces 		= #()
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		--- gestion de l'angle de la pente .... ----
		
		local pt_0 = (  [0,0,0]  *  mtrx_axeP )
		local pt_1 = (  [longeur,0,0]  *  mtrx_axeP )
		local pt_2 = (  [0,largeur ,hauteur]  *  mtrx_axeP )
		
		local vec1 = pt_1 - pt_0
		local vec2 = pt_2 - pt_0
		
		local pt_Origine = pt_0
		pt_Origine.z =  z + toiture_hauteur
		
		local plan_pente = ptr_geo.get_plan_2vecs_1Point		vec1		vec2		pt_Origine
		
		local pointsPente = #()
		local pointsMurs   =#()
		for i = 1 to  surface_pts.count do (
			
			local j = i+1
			if j >  surface_pts.count  do j = 1
			
			--- point Mur ----
			local pt 			= 	surface_pts[i]	
			pt.z = z
			append pointsMurs  pt		
			
			local pt_result = plan_pente.projeter_point_verticalement 	pt
			
			append pointsPente  ( pt_result * nd.transform )
			
		)
		
		---- on recalle les points sur Z----
		local recalleZ = 0
		for pt in pointsPente do (
			local ecart = abs ( (z + toiture_hauteur) - pt.z )
			if pt.z < z + toiture_hauteur and recalleZ < ecart do				
				recalleZ = ecart
		)
		for pt in pointsPente do pt.z += recalleZ
		
		gw.setColor	#line		yellow
		gw.polyline pointsPente	true
		
		
	)
	
)
--- les rollout du composant	---------
rollout toiture_dialog "Paramètres"  width:215 height:115
(
	local m_plug
	local m_compo
	local m_rolloutP
	
	label 'lbl_pente' "Pente (°):" pos:[9,10] width:61 height:13 align:#left
	spinner 'spn_pente' "" pos:[133,9] width:70 height:16 range:[0.001,70,0] type:#float scale:1 align:#left
	label 'lbl_decallage' "Décallage (z)" pos:[9,26] width:63 height:13 align:#left
	spinner 'spn_decallage' "" pos:[133,25] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl_orientation' "Orientation (°):" pos:[9,42] width:70 height:13 align:#left
	spinner 'spn_orientation' "" pos:[133,41] width:70 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	
	
	label 'lbl_debord' "Debord" pos:[9,58] width:63 height:13 align:#left
	spinner 'spn_debord' "" pos:[133,57] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl_epaisseur' "Epaisseur" pos:[9,74] width:70 height:13 align:#left
	spinner 'spn14' "" pos:[133,73] width:70 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	
	
	
	fn actualiser =(
		spn_pente.value 	= 	m_compo.params.pente
-- 		edt_nom.text 			=	m_compo.nom
	)

	on spn_pente changed val do
	(
			m_compo.params.pente		= val
		m_rolloutP.changer_un_truc ()
		)
	on spn_decallage changed val do
	(
			m_compo.params.decalage_hauteur		= val
		m_rolloutP.changer_un_truc ()
		)
	on spn_orientation changed val do
	(
			m_compo.params.orientation		= val
		m_rolloutP.changer_un_truc ()
		)
	on spn_debord changed val do
	(
			m_compo.params.debord		= val
		m_rolloutP.changer_un_truc ()
		)
	on spn14 changed val do
	(
			m_compo.params.epaisseur		= val
		m_rolloutP.changer_un_truc ()
		)
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 this:		= (
	
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local mgr_surface  		= 	_plug.core.get_mgr_surface ()
		local ptr_geo 				= 	_plug.core.get_geo ()
		
-------------  PARAMETRES 	 et constantes		-----------------------------------------------------------------------------------------------------------------
		local toiture_pente 		= this.params.pente
		local toiture_hauteur		= this.params.decalage_hauteur
		local toiture_orient		= this.params.orientation
		local toiture_debord		= this.params.debord
		local toiture_epaisseur	= this.params.epaisseur
	
		local	 mtrx_axeP	=	mgr_surface.get_axePrincipal ()
		local	 BB_axeP		=	mgr_surface.get_axeP_BB ()
		
		rotateZ 		mtrx_axeP		toiture_orient	
		translate 	mtrx_axeP		BB_axeP[1]
	
		local diag_axeP		=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
		local largeur 		=	diag_axeP.y
		local longeur 		= 	diag_axeP.x
		local hauteur 		= largeur * tan 		toiture_pente
		local z 					= pts_accroches[1].z
		
		local nvlsFaces 		= #()
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		--- gestion de l'angle de la pente .... ----		
		local pt_0 = (  [0,0,0]  *  mtrx_axeP )
		local pt_1 = (  [longeur,0,0]  *  mtrx_axeP )
		local pt_2 = (  [0,largeur ,hauteur]  *  mtrx_axeP )
		
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
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  	tooltip:toiture_tooltip		nom:toiture_nom	type:toiture_type	params:(toiture_params () )	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	