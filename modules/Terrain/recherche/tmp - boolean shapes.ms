






fn get_shapes_a_trou		_pts	=(
	
)





fn boolean_pts_shapes		_pts_shp1		_pts_shp2 =(
	
	--- on cherche les deux points des shpes les plus proches pour les connecter --------------
	local id_pt_connexion_1	=	0
	local id_pt_connexion_2	=	0
	local dist_min					= 1e+10
	
	for id_pt1 = 1 to  _pts_shp1.count do (
		local pt1	=	_pts_shp1[ id_pt1 ]
		for id_pt2 = 1 to  _pts_shp2.count do (
			local pt2			=	_pts_shp2[ id_pt2 ]
			local dist_test	=	distance	pt1 pt2
			if dist_test < dist_min do (
				dist_min = dist_test
				id_pt_connexion_1	=	id_pt1
				id_pt_connexion_2	=	id_pt2
			)				
		)
	)
	
	---- les premier shape -----------
	local pts_result = #( _pts_shp1[ id_pt_connexion_1 ] )
	for i_compteur = 1 to  _pts_shp1.count do (
		local id_pt = i_compteur + id_pt_connexion_1 
		if id_pt > _pts_shp1.count do 
			id_pt -= _pts_shp1.count 
		local pt = _pts_shp1[id_pt]
		append pts_result	pt
	)
	
	
	---- les second shape -----------
	for i_compteur =  _pts_shp2.count to 1 by -1 do (
		local id_pt = i_compteur + id_pt_connexion_2 
		if id_pt > _pts_shp2.count do 
			id_pt -= _pts_shp2.count 
		local pt = _pts_shp2[id_pt]
		append pts_result	pt
	)
	append 	pts_result	( _pts_shp2[ id_pt_connexion_2 ] )
	
	
	pts_result
	
)




shp1 = $Line002

shp2 = $Line003


pts_1 = for i = 1 to numknots	shp1	collect getKnotPoint	shp1 1 i
pts_2 = for i = 1 to numknots	shp2	collect getKnotPoint	shp2 1 i


pts_result = boolean_pts_shapes	pts_1 pts_2




			sp = splineShape name:"result"
			addnewSpline sp
			
			for pt in pts_result do
				addknot sp 1 #corner #curve  pt
			close sp 1
			updateShape sp











