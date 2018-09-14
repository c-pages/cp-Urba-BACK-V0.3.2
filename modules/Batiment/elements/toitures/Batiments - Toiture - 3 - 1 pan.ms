


	
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
	
	elements 				=	#(),
	
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
rollout toiture_dialog "Paramètres" width:215 height:284
(
	local m_plug
	local m_compo
	local m_rolloutP
	
	label 'lbl_pente' "Pente (°):" pos:[9,2] width:61 height:13 align:#left
	spinner 'spn_pente' "" pos:[133,1] width:70 height:16 range:[0.001,70,0] type:#float scale:1 align:#left
	label 'lbl_decallage' "Décallage (z)" pos:[9,18] width:63 height:13 align:#left
	spinner 'spn_decallage' "" pos:[133,17] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl_orientation' "Orientation (°):" pos:[9,34] width:70 height:13 align:#left
	spinner 'spn_orientation' "" pos:[133,33] width:70 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	
	
	label 'lbl_debord' "Debord" pos:[9,50] width:63 height:13 align:#left
	spinner 'spn_debord' "" pos:[133,49] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl_epaisseur' "Epaisseur" pos:[9,66] width:70 height:13 align:#left
	spinner 'spn_epaisseur' "" pos:[133,65] width:70 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	
	
	
	listbox 'lbx_elements' "" pos:[9,117] width:201 height:4 align:#left
	button 'btn_elements_nouveau' "Nouv." pos:[9,101] width:35 height:16 align:#left
	button 'btn_elements_supprimer' "Supp." pos:[176,101] width:35 height:16 align:#left
	GroupBox 'grp_elements' "Elements" pos:[2,83] width:219 height:97 align:#left
	
	fn actualiser =(
		
		lbx_elements.items 						= for elem in m_compo.params.elements collect elem.nom		
		
		
-- 		m_core = m_rolloutP.m_core
		
		spn_pente.value 				= 	m_compo.params.pente
		spn_orientation.value 		= 	m_compo.params.orientation
		spn_decallage.value 		= 	m_compo.params.decalage_hauteur
		spn_debord.value 			= 	m_compo.params.debord
		spn_epaisseur.value 		= m_compo.params.epaisseur
		
		
		
		
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
	on spn_epaisseur changed val do
	(
			m_compo.params.epaisseur		= val
		m_rolloutP.changer_un_truc ()
		)
	on lbx_elements selected _index do
		actualiser ()
	on btn_elements_nouveau pressed do
		m_plug.core.get_menu_contructeur  #toitElements
	on btn_elements_supprimer pressed do
	(
		deleteItem 		m_compo.params.elements		lbx_elements.selection
		actualiser ()
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
		
		
		-------------  CONSTRUCTION  NORMAL		-----------------------------------------------------------------------------------------------------------------
		if not  _plug.affiche_asProxy	then (
			
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

			
			
			
			
			
			
			---- les elements -----------
			if  this.params.elements.count > 0 do (
				local face_center = polyop.getFaceCenter  	ptr_plug.delegate  faceDessus
				local faceNormal = polyop.getFaceNormal  	ptr_plug.delegate  faceDessus
				
				local mgr_surface	= _plug.core.get_mgr_surface ()
				
				local mtrx_principale 	= mgr_surface.get_axePrincipal ()
				
				local transf_insertion		=	mtrx_principale * ( transMatrix face_center )  
				
				
				for elem in this.params.elements do
					elem.construire	 	ptr_plug			surface_points  	transformation:transf_insertion
			)
			
			
			
		)	---   FIN CONTRUCTION  NORMAL -----------------
		
		
		
		
		else (
		-------------  CONSTRUCTION  PROXY		-----------------------------------------------------------------------------------------------------------------
			
			
			
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
				
				ptr_geo.face		pointsPente	matID:#toiture
				
			)
			
			
		)
		
	)		---- fin 	toiture_fnConstruire---------------
	



------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  	tooltip:toiture_tooltip		nom:toiture_nom	type:toiture_type	params:(toiture_params () )	dialog:toiture_dialog		fnConstruire:toiture_fnConstruire

	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
