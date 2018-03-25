struct	str_geometrie	(
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_geometrie",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
		m_plug, 
		
	---- Material IDs -----------------
		fn get_id_materialType  _type =(
			local matID = include	  "$userScripts\cp-Urba\Modules\Batiment\divers\Batiment - material IDs.ms"
			local ids_propnames = getpropnames matID
			local result = 1
			for propNom in ids_propnames do
				if _type as name == propNom do
					result = getproperty 	matID	propNom
			result
		),
		fn set_matID _faces	_matID =(
			if _faces != undefined and _matID != undefined do 	(
				if classof _faces 	!= array 		do _faces 		= #( _faces)
					if classof _matID 	== name		do _matID 	= get_id_materialType  _matID
				for fc in _faces where fc != undefined do
					polyop.setFaceMatID m_plug.delegate 	fc  	 _matID		
				
			)
		),
		
	----- vider la geometrie ----------------
		fn vider 													=(
			if (polyop.getNumFaces m_plug.delegate) >0 do (
				local listeDesFaces = #{1..(polyop.getNumFaces m_plug.delegate)} as array
				polyop.deleteFaces m_plug.delegate	listeDesFaces		delIsoVerts:true
				polyop.deleteIsoVerts m_plug.delegate
			)
		),
		
		fn fliperNormal  _faces =(
			debug "	###	fliperNormal	###	"
			if classof _faces != array do _faces = #(_faces )
			debug " _faces" var:_faces
			
			resultFlip = polyop.flipNormals m_plug.delegate	 _faces
			debug " resultFlip" var:resultFlip
		),
		
	----- constructions élémentaires ----------------
		fn points	_liste_pts_position								=(
			local result = #()
			for pos_pts in _liste_pts_position do 			
				append result ( polyop.createVert 	m_plug.delegate		pos_pts )
			result
		),
		fn edges	_liste_pts_id					fermer:false	=(
			local result = #()
			
			for i = 1 to _liste_pts_id.count - 1	 do 	(	
				local pt_id_1 = _liste_pts_id[i]
				local pt_id_2 = _liste_pts_id[i+1]
				append result ( polyop.createEdge 	m_plug.delegate	 pt_id_1	 pt_id_2 )
			)
			if fermer do (
				local pt_id_1 = _liste_pts_id[_liste_pts_id.count]
				local pt_id_2 = _liste_pts_id[1]
				append result ( polyop.createEdge 	m_plug.delegate	 pt_id_1	 pt_id_2 )
			)
			result
		),
		fn face		_liste_pts						matID:1		flipNormal:false		=(
			
			--- si on a liste de point3 on créé les points d'abord
			for i = 1 to _liste_pts.count do
				if classof 	_liste_pts[i]	== Point3 do
					_liste_pts[i] = (points		#(_liste_pts[i]) )[1]
			
			-- si on doit inverser les points pour fliper la face ---------
			if flipNormal do (				
				local result =#()
				for i= _liste_pts.count to 1 by -1 do 
					append result 	_liste_pts[i]
				_liste_pts =  result
			)

			-- on crer la face ----
			local result = polyop.createPolygon m_plug.delegate  _liste_pts
			set_matID 	result	matID 
			
			
-- 			-- si on doit inverser les points pour fliper la face ---------
-- 			if flipNormal do fliperNormal	result
				
			result
		),
		
	----- constructions élémentaires 2 ----------------
		fn faceVerticale 	pt1 	pt2 		z 					ht:			=(
		
			local VERSION_BACK = true
			
			if not VERSION_BACK then (
				------------	NOUVELLE VERSION	----------------
				
				
			) else (  
				------------	VERSION BACK 	----------------
				
				local hauteur 
				if ht != unsupplied then	hauteur = ht
					else hauteur 	=	m_plug.niveaux_hauteur 
				
				local verts = polyop.getNumVerts m_plug.delegate		
				
				polyop.createVert m_plug.delegate	[pt2.x, pt2.y, z]	
				polyop.createVert m_plug.delegate	[pt1.x, pt1.y, z]
				polyop.createVert m_plug.delegate	[pt1.x, pt1.y, z + hauteur]
				polyop.createVert m_plug.delegate	[pt2.x, pt2.y, z + hauteur]
				
				polyop.createEdge m_plug.delegate (verts+1) (verts+2)
				polyop.createEdge m_plug.delegate (verts+2) (verts+3)
				polyop.createEdge m_plug.delegate (verts+3) (verts+4)
				polyop.createEdge m_plug.delegate (verts+4) (verts+1)
				
				polyop.createPolygon m_plug.delegate  #((verts+4),(verts+3),(verts+2),(verts+1))
			)
		),
		fn facesContour	ptsContours	 altitude 		hauteur 		matID:	=(
			
			
			local facesDuContour =#()
			local listePts = #()
			if hauteur <0 then
				listePts = for i = ptsContours.count to 1 by -1 collect ptsContours[i]
			else listePts = ptsContours
			
			for i_pt = 1 to listePts.count do	 (
				local pt_1 = listePts[i_pt]
				local pt_2 
				
				if i_pt == listePts.count then
					pt_2 = listePts[1]
				else pt_2 =  listePts[i_pt + 1 ]
				
				local nvlFace = faceVerticale 		pt_1		pt_2 	altitude 		ht:hauteur
				if nvlFace != undefined do
					appendIfUnique facesDuContour	nvlFace
				
			)
			
			if matID != unsupplied do set_matID  facesDuContour matID
				
			facesDuContour
			
		
		),
	
	
	---- Operations diverses ------------
		fn extruder 	_faces 	_hauteur	=(
			if classof _faces != array do _faces = #(_faces)
			polyop.extrudeFaces  m_plug.delegate 	_faces 	_hauteur
		),
		fn biseauter	_faces 	_hauteur	_largeur =(
			if classof _faces != array do _faces = #(_faces)
			polyop.bevelFaces m_plug.delegate 	_faces 	_hauteur 	_largeur			
		),
		fn souder	_pts =(
			polyop.weldVertsByThreshold m_plug.delegate 		( _pts as bitArray)
		),
		
	--- accessions diverse -------
		fn get_vertex  _idPt =(
			polyop.getVert 	m_plug.delegate		_idPt
		),
		
		
		
		
		
		
	--- operations -------------
		
		fn get_normal_bisectionOriente_2vecteurs 		_vec1 	_vec2		=(
			
			local norm_vec_1 = (normalize _vec1)
			local norm_vec_2 = (normalize _vec2)			
			local crossProd 	= cross _vec1 	_vec2
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then -1 else 1
			
			local	norm_dir 		= ( norm_vec_1 + norm_vec_2 ) * sens
			
			norm_dir
			
		),
		fn encart 		_pt	_vec1 	_vec2	_dist	=(
			
			local pt_concerne 	= _pt			
			local	vec1 				= pt1 - pt_concerne
			local	vec2 				= pt2 - pt_concerne			
			local	norm_dir 			= get_normal_bisectionOriente_2vecteurs 	vec1 	vec2
			
			local result	 			= pt_concerne + norm_dir* _dist 
			
			result
			
		),

		

		
	--- plans ---------------
		fn get_plan_2vecs_1Point	_vec1	_vec2		_pt_Origine =(
			local nvPlan  = include		"$userScripts\cp-Urba\modules\Batiment\divers\Batiment - Plan.ms"
			nvPlan.creerFrom_2vecs_et_1Point	_vec1	_vec2		_pt_Origine
			nvPlan
		),
	
		
	----- ELEMENTS BASIQUES DE CONSTRUCTION 		----------------------
		
		---  Boite sans les faces dessus et dessus-------------------
		fn allege 		_pt_A		_vec_long		_hauteur		_profondeur			matID:1 	=(
			
			--- les vecteurs -------------------------
			local norm_prof = (normalize _vec_long ) 	* rotateZ ( matrix3 1 ) 90
			
			local	vec_lg		= _vec_long
			local	vec_ht		= [0,0,1] * _hauteur
			local	vec_prof	= norm_prof * _profondeur
			
			--- localiser les point dans l'espace	--------			
			local pt_1			=	_pt_A
			local pt_2 		= pt_1	+ 	vec_ht	
			local pt_3 		= 	pt_2	+ 	vec_lg		
			local pt_4 		= pt_1	+ 	vec_lg
			
			local pt_5 		= pt_2	+ 	vec_prof				
			local pt_6 		= pt_3	+ 	vec_prof
			
			--- creation des points 		--------------
			local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6 )
			local pts_ids 	= points 	pts_pos
			
			-------	Creation des faces 	--------
			local faces =#()
			append faces ( face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 		pts_ids[4] )		 matID:matID )
			append faces ( face 		#(	pts_ids[2], 		pts_ids[5], 		pts_ids[6] , 		pts_ids[3] )		 matID:matID )
			
			faces
		),
		
		
		---  Boite sans les faces dessus et dessus-------------------
		fn tube 		_pt_A	_vec_ht		_vec_larg		_vec_ep		matID:1 	=(
			
			--- localiser les point dans l'espace	--------			
			local pt_1			=	_pt_A
			local pt_2 		= pt_1	+ 	_vec_ht	
			local pt_3 		= 	pt_2	+ 	_vec_larg		
			local pt_4 		= pt_1	+ 	_vec_larg
			
			local pt_5 		= pt_1	+ 	_vec_ep				
			local pt_6 		= pt_2	+ 	_vec_ep
			local pt_7			= pt_3	+ 	_vec_ep				
			local pt_8 		= pt_4	+ 	_vec_ep
			
			--- creation des points 		--------------
			local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
			local pts_ids 	= points 	pts_pos
			
			-------	Creation des faces 	--------
			local faces =#()
			append faces ( face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 		pts_ids[4] )		 matID:matID )
			append faces ( face 		#(	pts_ids[5], 		pts_ids[8], 		pts_ids[7] , 		pts_ids[6] )		 matID:matID )
			append faces ( face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 		pts_ids[8] )		 matID:matID )
			append faces ( face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[6] , 		pts_ids[5] )		 matID:matID )
			
			faces
		),
		
		
	------ Initialisation de la structure ------------
		fn initialiser _plug =(
-- 			debug "initialiser"
			m_plug= _plug
		)
		
) --- fin GEo

