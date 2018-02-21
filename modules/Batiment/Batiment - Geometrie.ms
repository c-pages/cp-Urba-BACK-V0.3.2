struct	str_geometrie	(
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_geometrie",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
		m_plug, 
		
		
	----- vider la geometrie ----------------
		fn vider 													=(
			if (polyop.getNumFaces m_plug.delegate) >0 do (
				local listeDesFaces = #{1..(polyop.getNumFaces m_plug.delegate)} as array
				polyop.deleteFaces m_plug.delegate	listeDesFaces		delIsoVerts:true
				polyop.deleteIsoVerts m_plug.delegate
			)
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
		fn face		_liste_pts						matID:			=(
			
			--- si on a liste de point3 on créé les points d'abord
			if classof 	_liste_pts[1] 	== Point3 do
				_liste_pts = points		_liste_pts
			
			-- on crer la face ----
			local result = polyop.createPolygon m_plug.delegate  _liste_pts
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
		fn facesContour	ptsContours	 altitude 		hauteur 			=(
			
			
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
			
			facesDuContour
			
		
		),
		
		
	------ Initialisation de la structure ------------
		fn initialiser _plug =(
			debug "initialiser"
			m_plug= _plug
		)
		
) --- fin GEo

