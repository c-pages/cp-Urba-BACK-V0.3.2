


struct str_mgr_trimesh (
	
	private
	separateur_items 	= ";",
	separateur_tableaux = "°",
	
	public
	fn getdatas 	_node =(
		local dataResult =""		
		
		--- les vertex ----
		for i=1 to (polyop.getNumVerts  _node )  do
			dataResult += (polyop.getVert  _node 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		
		--- les edges ----
		for i=1 to (polyop.getNumEdges  _node )  do
			dataResult += (polyop.getEdgeVerts  _node 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		 
		--- les faces ----
		for i=1 to (polyop.getNumFaces  _node )  do
			dataResult += (polyop.getFaceVerts  _node 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		
		--- les smoothing group ----
		for i=1 to (polyop.getNumFaces  _node )  do
			dataResult += (polyop.getFaceSmoothGroup  _node 	i ) as string + separateur_items
		--- de la partie ----
		dataResult += separateur_tableaux 
		
		--- les material ID ----
		for i=1 to (polyop.getNumFaces  _node )  do
			dataResult += (polyop.getFaceMatID   _node 	i ) as string + separateur_items
			
		--- de la partie ----
		dataResult += separateur_tableaux 
		
		format "dataResult :%\n" dataResult
		dataResult
	),

	fn creer_objet		_params		node_dest:	transformation:  =(
		
		local datas = _params.datas_objet
		
		if node_dest == unsupplied then (
			node_dest = convertToPoly (mesh ())
			node_dest.EditablePoly.SetSelection #Face #{1..25}
			node_dest.EditablePoly.delete #Face
		) else 
			node_dest = node_dest.delegate
		
		--- initialement --------
		local nbrPtsInitial 		= node_dest.GetNumVertices ()
		local nbrFacesInitial 	= node_dest.GetNumFaces ()

		
		local donnees = filterString 	datas 	separateur_tableaux
-- 		format "donnees :%\n" donnees.count
		
		-- les vertex -- 
		local datas_pts = filterString 	donnees[1] 	separateur_items
		local pts = for data in datas_pts collect ( execute data )
		
		---- mise a la bonne taille du model ----------
		for IDvert 	in 	( _params.verts_Gauche as array ) do
			pts[ IDvert ] +=  [500,0,0] 	- [1,0,0]  * _params.largeur / 2
		for IDvert 	in 	( _params.verts_Droite as array ) do
			pts[ IDvert ] +=  [-500,0,0] 	+ [1,0,0]  * _params.largeur / 2
		for IDvert 	in 	( _params.verts_Devant as array ) do
			pts[ IDvert ] +=  [0, 500,0] 	- [0,1,0]  * _params.longueur / 2
		for IDvert 	in 	( _params.verts_Arriere as array ) do
			pts[ IDvert ] +=  [0, -500,0] 	+ [0,1,0]  * _params.longueur / 2
-- 		for IDvert 	in 	( _params.verts_Arriere as array ) do
-- 			pts[ IDvert ] +=  [0, -1000,0] 	+ [0,1,0]  * _params.longueur / 2
		
		
		
		
		
		---- creation des points ----------
		for pt in  pts do 
			polyop.createVert node_dest	( pt * transformation )
			
		-- les edges -- 
		local datas_edges = filterString 	donnees[2] 	separateur_items
-- 		format "datas_edges :%\n" datas_edges
		local edges = for data in datas_edges collect ( execute data )
		for edge_pts in  edges do 
			polyop.createEdge node_dest		( nbrPtsInitial + edge_pts[1]) 	(nbrPtsInitial + edge_pts[2] )
		
		-- les faces -- 
		local datas_faces = filterString 	donnees[3] 	separateur_items
-- 		format "datas_faces :%\n" datas_faces
		local faces = for data in datas_faces collect ( execute data )
		for face_pts in  faces do (
			local face_ptsTmp = for pt in face_pts collect ( pt + nbrPtsInitial )
			polyop.createPolygon	 ( node_dest)		face_ptsTmp
		)
		
		/* 
		--- les smoothing group ----
		local datas_smoothG = filterString 	donnees[4] 	separateur_items
		local faces = for data in datas_faces collect ( execute data + nbrFacesInitial )
		for i=1 to (polyop.getNumFaces  _node )  do
			dataResult += (polyop.getFaceSmoothGroup  _node 	i ) as string + separateur_items
		 */
		
		--- les id mat ----
		local datas_idMat = filterString 	donnees[5] 	separateur_items
		local idMats = for data in datas_idMat collect ( execute data  )
		local i = 1
		for idMat in idMats do (
			polyop.setFaceMatID  node_dest 	(i +nbrFacesInitial )  idMat
			i += 1
		)
-- 		for i=nbrFacesInitial to (polyop.getNumFaces  node_dest )  do
		
	)
	
)



/* 

popo = str_mgr_trimesh ()

data3D = popo.getdatas $

popo.creer_objet 	data3D


 */

