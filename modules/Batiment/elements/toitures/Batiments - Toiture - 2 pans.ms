



--- parametres de base	-----------------------------
toiture_titre 	= "2 pans"	
toiture_type	=	#2pans
toiture_toolTip =	"..."

--- les parametres du composant	---------
struct toiture_params	(
	pente 					= 	30,
	decalage_hauteur 	= 	0.,
	orientation				=	0,
	debord					= 50.,
	epaisseur 				= 15
)
--- les rollout du composant	---------
rollout toiture_dialog "Toiture - 2 pans" width:180 height:128
(
	local m_plug
	local m_toiture
	local mgr_toiture
	
	label 'lbl_pente' "Pente (�):" pos:[9,10] width:61 height:13 align:#left
	spinner 'spn_pente' "" pos:[92,9] width:70 height:16 range:[0.001,70,0] type:#float scale:1 align:#left
	label 'lbl_decallage' "D�callage (z)" pos:[9,26] width:63 height:13 align:#left
	spinner 'spn_decallage' "" pos:[92,25] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl_orientation' "Orientation (�):" pos:[9,42] width:70 height:13 align:#left
	spinner 'spn_orientation' "" pos:[92,41] width:70 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	label 'lbl_debord' "D�bord" pos:[9,58] width:70 height:13 align:#left
	spinner 'spn_debord' "" pos:[92,57] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl9' "Epaisseur" pos:[9,75] width:70 height:13 align:#left
	spinner 'spn_epaisseur' "" pos:[92,73] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	
	fn actualiser =(
		spn_pente.value 			= 	m_toiture.params.pente
		spn_orientation.value 	= 	m_toiture.params.orientation
		spn_decallage.value 		= 	m_toiture.params.decalage_hauteur
		spn_debord.value 			= 	m_toiture.params.debord
		spn_epaisseur.value 		= 	m_toiture.params.epaisseur
	)
	fn initialiser _plug	_toiture	=(
		m_plug			= _plug
		m_toiture 		= _toiture
		mgr_toiture	= m_plug.core.get_mgr_toiture ()
		actualiser ()
	)

	
	on spn_pente changed val do
	(
			m_toiture.params.pente		= val
			mgr_toiture.enregistrer ()
			m_plug.core.actualiser ()
		)
	on spn_decallage changed val do
	(
			m_toiture.params.decalage_hauteur		= val
			mgr_toiture.enregistrer ()
			m_plug.core.actualiser ()
		)
	on spn_orientation changed val do
	(
			m_toiture.params.orientation		= val
			mgr_toiture.enregistrer ()
			m_plug.core.actualiser ()
		)
	on spn_debord changed val do
	(
			m_toiture.params.debord		= val
			mgr_toiture.enregistrer ()
			m_plug.core.actualiser ()
		)
	on spn_epaisseur changed val do
	(
			m_toiture.params.epaisseur		= val
			mgr_toiture.enregistrer ()
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
	
		local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
		local largeur 		=	diag_axeP.x
		local longeur 		= 	diag_axeP.z
		local hauteur 		= largeur * tan 		toiture_pente
		local z 					= pts_accroches[1].z
		
		local nvlsFaces 				= #()
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		--- gestion de l'angle de la pente .... ----
		--- Plan de la Pente 1  ----
		local pt_P1_0 = (  [0,0,0]  *  mtrx_axeP )
		local pt_P1_1 = (  [0,0,longeur]  *  mtrx_axeP )
		local pt_P1_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )	
	
		local vecP1_1 = pt_P1_1 - pt_P1_0
		local vecP1_2 = pt_P1_2 - pt_P1_0
		
		local pt_Origine = pt_P1_0
		pt_Origine.z =  z + toiture_hauteur
		local plan_pente1 =  ptr_geo.get_plan_2vecs_1Point		vecP1_1		vecP1_2		pt_Origine

	
	
	
		--- Plan de la Pente 1  ----
		local pt_P2_0 = (  [largeur,0,longeur]  *  mtrx_axeP )
		local pt_P2_1 = (  [largeur,0,0]  *  mtrx_axeP )
		local pt_P2_2 = (  [0 ,hauteur,longeur]  *  mtrx_axeP )			
	
		local vecP2_1 = pt_P2_1 - pt_P2_0
		local vecP2_2 = pt_P2_2 - pt_P2_0
		
		local pt_Origine = pt_P2_0
		pt_Origine.z =  z + toiture_hauteur
		local plan_pente2 = ptr_geo.get_plan_2vecs_1Point			vecP2_1		vecP2_2		pt_Origine
	
		--- Plan verticale faitage ------
		local pt_F_0 = (  [largeur /2 ,0,0]  *  mtrx_axeP )
		local pt_F_1 = (  [largeur /2 ,0,longeur]  *  mtrx_axeP )
		local pt_F_2	=	pt_F_0 + [0,0,100]				
		
		local vec_F_1 = pt_F_1 - pt_F_0
		local vec_F_2 = pt_F_2 - pt_F_0				
		
		local pt_Origine = pt_F_0
		pt_Origine.z =  z 
		
		local plan_verticaleFaitage = ptr_geo.get_plan_2vecs_1Point			vec_F_1		vec_F_2		pt_Origine
		
		
		
		---- creation des liste des points-----------
		local pointsPente = #()
		local pointsPente1 = #()
		local pointsPente2 = #()
		local pointsMurs   =#()
		for i = 1 to  pts_accroches.count do (
			
			local j = i+1
			if j >  pts_accroches.count  do j = 1
			
			
			--- point Mur ----
			local pt 			= 	pts_accroches[i]	
			pt.z = z
			append pointsMurs  pt		
			
			--- point pente ----
			local pt_pente1 = plan_pente1.projeter_point_verticalement 	pt
			local pt_pente2 = plan_pente2.projeter_point_verticalement 	pt
			if pt_pente1.z < pt_pente2.z then (
				append pointsPente  	(copy pt_pente1 )
				append pointsPente1 	(copy pt_pente1 )
			) else  (
				append pointsPente  	(copy pt_pente2 )
				append pointsPente2  (copy pt_pente2 )
			)
			
			--- point mur - faitage ----
			local pt_suivant 	= 	pts_accroches[j]	
			pt_suivant.z = z
			local intersect = plan_verticaleFaitage.coupe_segment	pt 	pt_suivant							
			if intersect do (
				local pt_faitage_mur = plan_verticaleFaitage.get_intersection_segment 	pt 	pt_suivant
				append pointsMurs  	(copy pt_faitage_mur )
				local pt_faitage_pente = plan_pente1.projeter_point_verticalement 	pt_faitage_mur
				append pointsPente  	(copy pt_faitage_pente )
				append pointsPente1 	(copy pt_faitage_pente )
				append pointsPente2 	(copy pt_faitage_pente )
			)
			
			
			
		)
		
		
		---- on recalle les points sur Z----
		local ptZMin = 100000000000000000
		for pt in pointsPente1 do 
			if pt.z < ptZMin  do				
				ptZMin = pt.z
		
		for pt in pointsPente2 do 
			if pt.z < ptZMin  do				
				ptZMin = pt.z
		
		local recalleZ = abs ( (z + toiture_hauteur) - ptZMin )
			
		for i = 1 to pointsPente1.count 	do 
			pointsPente1[i] =  pointsPente1[i] + [0,0,recalleZ]		
		
		for i = 1 to pointsPente2.count 	do 
			pointsPente2[i] =  pointsPente2[i]  + [0,0,recalleZ]		
		
		
		
		
		--------- creation des geometries ---------------------
		--- les murs ----
		for i = 1 to pointsMurs.count  do (
			
			local j = i+1
			if j > pointsMurs.count do j = 1
			
			local ptMur1 	= pointsMurs[ i ]
			local ptMur2 	= pointsMurs[ j ]
			local ptPente3 	= pointsPente[ j ] + [0,0,recalleZ]
			local ptPente4	= pointsPente[ i ] + [0,0,recalleZ]
			
			local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
			local nvlFace = ptr_geo.face 	pointsRaccord 	
			append nvlsFaces nvlFace
			-- m_matID --
			ptr_geo.set_matID  nvlFace	#mur
		) 
		
		--- les pentes -----
		local facesDessus =#()
		local face1 =  ptr_geo.face 		pointsPente1 	
		local face2 =  ptr_geo.face 		pointsPente2 	
		
		append facesDessus face1
		append facesDessus face2
		
		append nvlsFaces face1
		append nvlsFaces face2
		
		
		-- m_matID --
		ptr_geo.set_matID  facesDessus	#toiture
		
		
		
		
		
		
		-- souder les points --
		local vertsASouder =#()
		for IDFace in nvlsFaces do (
			local vertsFace = polyop.getFaceVerts ptr_plug.delegate	 IDFace
			for vert in vertsFace do 
				appendIfUnique  vertsASouder 	vert
			-- ptr_plug.delegate.weldThreshold
		)
		ptr_geo.souder   (vertsASouder as bitArray)
		
		
		---- debord et epaisseur du toit -----
		facesDessus = #( ptr_plug.delegate.getNumFaces () - 1, ptr_plug.delegate.getNumFaces () )

		ptr_geo.biseauter	facesDessus 	0.0 	toiture_debord
		ptr_geo.extruder	facesDessus 	toiture_epaisseur
)


	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
parametresTMP = toiture_params () 
str_modelBase 	tooltip:toiture_tooltip		titre:toiture_titre	type:toiture_type	params:(parametresTMP)	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	