

clearlistener ()


---- OUTILS DIVERS -------
fn get_angle_vecteur 	vec	=(
	
	local result = 0
	local angle_tan = atan ( vec.y / vec.x )
	
	if vec.x >=0 then (
		if vec.y >= 0 then 	result = angle_tan
		else 	result = 360 + angle_tan
	) else (		
		if vec.y >= 0 then 	result = 180 + angle_tan
		else result = 180 + angle_tan
	)
	
	result
)

fn pointLePlusHautsurY 	shp 	spline	=(
	local maxi = -10000000000000000 
	local result_id = 0
	for i = 1 to numKnots shp 	spline do (
		local pt = getKnotPoint shp 	spline 	i
		if  pt.y > maxi do ( 
			maxi = pt.y
			result_id = i
		)
	)
	result_id
)

fn estPolygone_sensPositif 	shp	id_spline =(
	
	local result 			= false
	local id_pointHaut = pointLePlusHautsurY  	shp	id_spline 
	
	local	id_pt_1 	= id_pointHaut - 1 	---- le point d'avant
	local	id_pt_ori 	= id_pointHaut 		---- le point origine
	local	id_pt_2 	= id_pointHaut + 1	---- le point d'apres
	
	-- Boucler limite nombre des points
	if id_pt_1 < 1 do id_pt_1 = numKnots shp	id_spline 
	if id_pt_2 > numKnots shp	id_spline  do id_pt_2 = 1
	
	local	pt_1 	= getKnotPoint shp 	id_spline 	id_pt_1
	local	pt_ori 	= getKnotPoint shp 	id_spline 	id_pt_ori
	local	pt_2 	= getKnotPoint shp 	id_spline 	id_pt_2

	local	vec1 =  normalize ( pt_1 - pt_ori )
	local	vec2 =  normalize ( pt_2 - pt_ori )
	
	if vec2.x > vec1.X do result = not result
	
	result
)

fn get_pointsOuverts 	_node =(
	
	local		edgeOuverts 		= 	polyop.getOpenEdges _node
	local		vertexOuverts	=	( polyop.getVertsUsingEdge _node	edgeOuverts ) as array
	
	local		vert_HD = vertexOuverts[1]
	local		vert_HG = vertexOuverts[1]
	local		vert_BD = vertexOuverts[1]
	local		vert_BG = vertexOuverts[1]
	
	for vertex in vertexOuverts do (
		if _node.verts[vertex].pos.x >= _node.verts[vert_HD].pos.x and _node.verts[vertex].pos.z >= _node.verts[vert_HD].pos.z do 
			vert_HD = vertex
		if _node.verts[vertex].pos.x >= _node.verts[vert_BD].pos.x and _node.verts[vertex].pos.z <= _node.verts[vert_BD].pos.z do 
			vert_BD = vertex
		if _node.verts[vertex].pos.x <= _node.verts[vert_HG].pos.x and _node.verts[vertex].pos.z >= _node.verts[vert_HG].pos.z do 
			vert_HG = vertex
		if _node.verts[vertex].pos.x <= _node.verts[vert_BG].pos.x and _node.verts[vertex].pos.z <= _node.verts[vert_BG].pos.z do 
			vert_BG = vertex
	)
	
	struct points (
		HD,
		HG,
		BD,
		BG
	)
	
	local result = 	points	HD: vert_HD	\
										HG: vert_HG	\
										BD: vert_BD	\
										BG: vert_BG
	result
)








---- 
fn placer_modele 	model	knt_1	knt_2 	reverse:false		=(
	
	-- 	local model 	= 	$Box001

	---- FENETRE -----------
	local BB_modele 			= nodeLocalBoundingBox model
	local largeur_modele 	= BB_modele[2].x - BB_modele[1].x 
	
	local ligne_tracee 				= ( knt_2 - knt_1 )
	local longueur_ligne_tracee	=	length	ligne_tracee
	local rot 							= get_angle_vecteur		ligne_tracee
	
	if reverse do rot += 180
	
	-- nombre de fois que l'on integre le model ----
	local nbr_modeles 	= ( longueur_ligne_tracee / largeur_modele ) as integer
	local ecart 			= ligne_tracee / nbr_modeles 
	local nvxNodes 		= #()
	local nv_modele, model_davant, ptsOuverts
	
	-- on copie le model ----
	if nbr_modeles > 0 then (
		for i = 1 to nbr_modeles do (
			
			nv_modele 				= copy model
			append nvxNodes 	nv_modele
			ptsOuverts 			= get_pointsOuverts 	model
			
			rotate nv_modele (angleaxis rot [0,0,1])
			nv_modele.pos 				= (knt_1 + i * ecart - ecart/2) 
			

			-- on fait la face du premier coin --
			local facette = SplineShape 	pos:nv_modele.verts[ptsOuverts.BG].pos
			append nvxNodes facette
			addNewSpline facette
			
			addKnot facette 1 #corner 	#line 	nv_modele.verts[ptsOuverts.BG].pos
			addKnot facette 1 #corner 	#line 	nv_modele.verts[ptsOuverts.HG].pos
			if i == 1 then (
				addKnot facette 1 #corner 	#line 	[knt_1.x, knt_1.y, nv_modele.verts[ptsOuverts.HG].pos.z]
				addKnot facette 1 #corner 	#line 	[knt_1.x, knt_1.y, nv_modele.verts[ptsOuverts.BG].pos.z]
			) else (
				addKnot facette 1 #corner 	#line 	model_davant.verts[ptsOuverts.HD].pos
				addKnot facette 1 #corner 	#line 	model_davant.verts[ptsOuverts.BD].pos
			)
			
			close facette 1
			convertToPoly facette
			model_davant = nv_modele
			
		)
		
		-- derniere face du coin
		local facette = SplineShape	pos:nv_modele.verts[ptsOuverts.BG].pos
		append nvxNodes facette
		addNewSpline facette
		addKnot facette 1 #corner 	#line 	[knt_2.x, knt_2.y, nv_modele.verts[ptsOuverts.BG].pos.z]
		addKnot facette 1 #corner 	#line 	[knt_2.x, knt_2.y, nv_modele.verts[ptsOuverts.HG].pos.z]
		addKnot facette 1 #corner 	#line 	model_davant.verts[ptsOuverts.HD].pos
		addKnot facette 1 #corner 	#line 	model_davant.verts[ptsOuverts.BD].pos
		
		close facette 1
		convertToPoly facette
		
	) else (
		
		-- une seul face sans model----
		ptsOuverts = get_pointsOuverts 	model
		local facette = SplineShape	pos:[knt_1.x, knt_1.y, model.verts[ptsOuverts.HG].pos.z]
		append nvxNodes facette
		addNewSpline facette
		addKnot facette 1 #corner 	#line 	[knt_2.x, knt_2.y, model.verts[ptsOuverts.HG].pos.z]
		addKnot facette 1 #corner 	#line 	[knt_2.x, knt_2.y, model.verts[ptsOuverts.BG].pos.z]
		addKnot facette 1 #corner 	#line 	[knt_1.x, knt_1.y, model.verts[ptsOuverts.BG].pos.z]
		addKnot facette 1 #corner 	#line 	[knt_1.x, knt_1.y, model.verts[ptsOuverts.HG].pos.z]
		
		close facette 1
		convertToPoly facette
		
		
	)
	
	
	----	on attache tout les nodes créés	----
	for i=2 to nvxNodes.count do 
		nvxNodes[1].attach nvxNodes[i] nvxNodes[1]
	
	nvxNodes[1]
)




-- format "pointsOuverts : %\n" 	pointsOuverts


fn executer 	shp_tracee	= (
	
	max create mode
	
	-- le poly créé-------------
	local nvNode = convertToPoly (mesh ())
	nvNode.EditablePoly.SetSelection #Face #{1..25}
	nvNode.EditablePoly.delete #Face
	
	---- TRACéE----------
	--chaque splines	------------------------
	for id_subSpline_tracee = 1 to (numSplines shp_tracee) do	(
		
		if isClosed  shp_tracee	id_subSpline_tracee	do (
			-- les points  1 à nombre de point ---
			local knt_1
			local knt_2
			
			for id_knot_tracee = 1 to (numKnots shp_tracee 	id_subSpline_tracee)  - 1 do	(
				
				knt_1 = getKnotPoint shp_tracee 	id_subSpline_tracee 	id_knot_tracee
				knt_2 = getKnotPoint shp_tracee 	id_subSpline_tracee 	( id_knot_tracee + 1 )
				
				nodeTemp = placer_modele $Box001	knt_1		knt_2 	reverse:(estPolygone_sensPositif 	shp_tracee	id_subSpline_tracee)
				nvNode.attach 	nodeTemp	 nvNode
	
			)--end k loop
			
			-- la derniere spline pour fermer le shape ---		
			knt_1 = getKnotPoint shp_tracee 	id_subSpline_tracee 	(numKnots shp_tracee 	id_subSpline_tracee)
			knt_2 = getKnotPoint shp_tracee 	id_subSpline_tracee 	1
			
			nodeTemp = placer_modele $Box001	knt_1	knt_2 	reverse:(estPolygone_sensPositif 	shp_tracee	id_subSpline_tracee)
			nvNode.attach 	nodeTemp	 nvNode
			
		) -- fin isClosed ---
		
	)--end s loop
	
	nvNode
	
) -- fin executer



executer 	$












