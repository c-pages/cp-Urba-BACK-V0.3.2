
	
( ----	FileIn ----
	
	


--- parametres de base	-----------------------------
toiture_nom 		= "2 pans"	
toiture_type		=	#pans2
toiture_toolTip 	=	"..."

--- les parametres du composant	---------
struct toiture_params	(
	pente 					= 	15,
	
	decalage_hauteur 	= 	0.,
	decalage_largeur 	= 	0.,
	
	orientation				=	0,
	
	debord					= 15.,
	epaisseur 				= 15
	
)

--- les rollout du composant	---------
rollout toiture_dialog "Toiture - 2 pans" width:180 height:128
(
	local m_plug
	local m_compo
	local m_rollPrt
	
	label 'lbl_pente' "Pente (°):" pos:[9,10] width:61 height:13 align:#left
	spinner 'spn_pente' "" pos:[92,9] width:70 height:16 range:[0.001,70,0] type:#float scale:1 align:#left
	label 'lbl_decallage' "Décallage (Z)" pos:[9,26] width:63 height:13 align:#left
	spinner 'spn_decallage' "" pos:[92,25] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl_orientation' "Orientation (°):" pos:[9,56] width:70 height:13 align:#left
	spinner 'spn_orientation' "" pos:[92,55] width:70 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	label 'lbl_debord' "Débord" pos:[9,72] width:70 height:13 align:#left
	spinner 'spn_debord' "" pos:[92,71] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl9' "Epaisseur" pos:[9,89] width:70 height:13 align:#left
	spinner 'spn_epaisseur' "" pos:[92,87] width:70 height:16 range:[0,10000,0] type:#worldunits scale:1 align:#left
	label 'lbl6' "Décallage (X)" pos:[9,42] width:63 height:13 align:#left
	spinner 'spn_decallage_larg' "" pos:[92,41] width:70 height:16 range:[-10000,10000,0] type:#worldunits scale:1 align:#left
	
	fn actualiser =(
		spn_pente.value 			= 	m_compo.params.pente
		spn_orientation.value 	= 	m_compo.params.orientation
		spn_decallage.value 		= 	m_compo.params.decalage_hauteur
		spn_debord.value 			= 	m_compo.params.debord
		spn_epaisseur.value 		= 	m_compo.params.epaisseur
	)
	

	
	on spn_pente changed val do
	(
			m_compo.params.pente		= val
		m_rollPrt.changer_un_truc ()
		)
	on spn_decallage changed val do
	(
			m_compo.params.decalage_hauteur		= val
		m_rollPrt.changer_un_truc ()
		)
	on spn_orientation changed val do
	(
		
		--- limiter le décalage -------------
			local mgr_surface  		= 	m_plug.core.get_mgr_surface ()
			local toiture_orient		= m_compo.params.orientation
			local	 mtrx_axeP			=	mgr_surface.get_axePrincipal ()
			local	 BB_axeP				=	mgr_surface.get_axeP_BB ()
			rotateZ 		mtrx_axeP		toiture_orient	
			translate 	mtrx_axeP		BB_axeP[1]
			mtrx_axeP.translation 	= [0,0,0]
		
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
			local largeur 		=	diag_axeP.x
			
			mtrx_axeP.translation = [0,0,0]
			decallage_largeur = val
			if abs decallage_largeur > largeur/ 2 do (
				if decallage_largeur <0 then 	
					decallage_largeur = - largeur/ 2 + 5
				else
					decallage_largeur =  largeur/ 2  - 5
			)
			
			
			
			
			m_compo.params.orientation		= val
			m_rollPrt.changer_un_truc ()
		)
	on spn_debord changed val do
	(
			m_compo.params.debord		= val
			m_rollPrt.changer_un_truc ()
		)
	on spn_epaisseur changed val do
	(
			m_compo.params.epaisseur		= val
			m_rollPrt.changer_un_truc ()
		)
	on spn_decallage_larg changed val do
	(
		--- limiter le décalage -------------
			local mgr_surface  		= 	m_plug.core.get_mgr_surface ()
			local toiture_orient		= m_compo.params.orientation
			local	 mtrx_axeP			=	mgr_surface.get_axePrincipal ()
			local	 BB_axeP				=	mgr_surface.get_axeP_BB ()
			rotateZ 		mtrx_axeP		toiture_orient	
			translate 	mtrx_axeP		BB_axeP[1]
			mtrx_axeP.translation 	= [0,0,0]
		
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
			local largeur 		=	diag_axeP.x
			
			mtrx_axeP.translation = [0,0,0]
			decallage_largeur = val
			if abs decallage_largeur > largeur/ 2 do (
				if decallage_largeur <0 then 	
					decallage_largeur = - largeur/ 2 + 5
				else
					decallage_largeur =  largeur/ 2  - 5
			)
			
			
			
			m_compo.params.decalage_largeur		= decallage_largeur
			spn_decallage_larg.value = decallage_largeur
			
			m_rollPrt.changer_un_truc ()
			actualiser ()
			
		)
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 this:		= (
	
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local mgr_toiture  		= 	_plug.core.get_mgr_toiture ()
		local mgr_surface  		= 	_plug.core.get_mgr_surface ()
		local ptr_geo 				= 	_plug.core.get_geo ()

	
	
	
		
-------------  PARAMETRES 	 et constantes		-----------------------------------------------------------------------------------------------------------------
		local toiture_pente 		= this.params.pente
		local toiture_decal_ht	= this.params.decalage_hauteur
		local toiture_decal_larg	= this.params.decalage_largeur
		local toiture_orient		= this.params.orientation
		local toiture_debord		= this.params.debord
		local toiture_epaisseur	= this.params.epaisseur
	
		local	 mtrx_axeP	=	mgr_surface.get_axePrincipal ()
		local	 BB_axeP		=	mgr_surface.get_axeP_BB ()
		rotateZ 		mtrx_axeP		toiture_orient	
		translate 	mtrx_axeP		BB_axeP[1]
	
		local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
		local largeur 		=	diag_axeP.x
		local longeur 		= 	diag_axeP.z
		local hauteur 		= largeur * tan 		toiture_pente
		local z 					= pts_accroches[1].z
		
		local mtrx_axeP_temp = copy mtrx_axeP
		mtrx_axeP_temp.translation = [0,0,0]


		
		local vec_decall_larg 	= [toiture_decal_larg,0, 0]  * mtrx_axeP_temp 
		
		local nvlsFaces 				= #()
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		--- gestion de l'angle de la pente .... ----
		--- Plan de la Pente 1  ----
		local pt_P1_0 = (  [0,0,0]  *  mtrx_axeP 						+ vec_decall_larg )
		local pt_P1_1 = (  [0,0,longeur]  *  mtrx_axeP 				+ vec_decall_larg )
		local pt_P1_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP 	+ vec_decall_larg )	
	
		local vecP1_1 = pt_P1_1 - pt_P1_0
		local vecP1_2 = pt_P1_2 - pt_P1_0
		
		local pt_Origine = pt_P1_0
		pt_Origine.z =  z + toiture_decal_ht
		local plan_pente1 =  ptr_geo.get_plan_2vecs_1Point		vecP1_1		vecP1_2		pt_Origine

	
	
	
		--- Plan de la Pente 1  ----
		local pt_P2_0 = (  [largeur,0,longeur]  *  mtrx_axeP  	+ vec_decall_larg )	
		local pt_P2_1 = (  [largeur,0,0]  *  mtrx_axeP  				+ vec_decall_larg )	
		local pt_P2_2 = (  [0 ,hauteur,longeur]  *  mtrx_axeP 	+ vec_decall_larg )	
	
		local vecP2_1 = pt_P2_1 - pt_P2_0
		local vecP2_2 = pt_P2_2 - pt_P2_0
		
		local pt_Origine = pt_P2_0
		pt_Origine.z =  z + toiture_decal_ht
		local plan_pente2 = ptr_geo.get_plan_2vecs_1Point			vecP2_1		vecP2_2		pt_Origine
	
		--- Plan verticale faitage ------
		local pt_F_0 = (  [largeur /2 ,0,0]  *  mtrx_axeP 	+ vec_decall_larg )
		local pt_F_1 = (  [largeur /2 ,0,longeur]  *  mtrx_axeP 	+ vec_decall_larg )
		local pt_F_2	=	pt_F_0 + [0,0,100]					+ vec_decall_larg 
		
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
		
		local recalleZ = abs ( (z + toiture_decal_ht) - ptZMin )
			
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
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  	tooltip:toiture_tooltip		nom:toiture_nom	type:toiture_type	params:(toiture_params () )	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
