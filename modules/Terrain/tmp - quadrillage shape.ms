struct str_quadriller (
	
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =		try if true  do ::debuger 	_txt	prefix:"str_quadriller"	  	var:var	 param:param		catch (),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	
	
	
	private
		m_shp_contour 	=	undefined,
		m_pts_contour 	=	#(),
		m_resolution 		=	300,
		
		
	private
		fn get_pts_case		_pt	=(
			
			local index_x				=	floor ( _pt.x / m_resolution )
			local index_y				=	floor ( _pt.y / m_resolution )
			local pts_case 	  = #()
			append pts_case		[index_x * 	m_resolution, index_y * 	m_resolution, 0 ]
			append pts_case		[index_x * 	m_resolution , ( index_y + 1 ) * 	m_resolution , 0 ]
			append pts_case		[( index_x + 1 ) * 	m_resolution , ( index_y + 1 ) * 	m_resolution , 0 ]
			append pts_case		[( index_x + 1 ) * 	m_resolution , index_y * 	m_resolution, 0 ]
			
			-- debug---------
			for pt_case in pts_case do	point pos:pt_case
			
			pts_case
		),
		
		
		fn get_longueur_segment		_id_spline	_id_pt 	=(
			
			local tab_longueurs_sgts		=	getSegLengths 	m_shp_contour 	_id_spline	 cum:false byVertex:true numArcSteps:100
			local nbr_pts_total 				=	numknots	 		m_shp_contour	_id_spline
			local longueur_result			= 	tab_longueurs_sgts[ nbr_pts_total + 2 + _id_pt]
-- 			debug "tab_longueurs_sgts" var:tab_longueurs_sgts
-- 			debug "longueur_result" var:longueur_result
			longueur_result
		),
		
		
		
		fn nettoyer_points_inutiles	_pts	 =(
			
			local dotmax_courbe 	= .9999	--- en dot ?!?. ----
			local pts_result 			= deepCopy	_pts
			
			---- pour chacune des splines du shape ----------------
			for id_spline_contour	=	1	to  pts_result.count do (
				
				local pt_result 			= 	#()
				local ids_aSupprimer 	=	#()
				local pts 					= 	pts_result[id_spline_contour]
				
				for id_pt_contour	=	1	to pts.count do (
					
					local pt_contour  = pts[ 	id_pt_contour]
					local id_pt_svt 	= if id_pt_contour == pts.count then 1 else id_pt_contour + 1
					local pt_suivant  = pts[ 	id_pt_svt ]
					
					local id_pt_avt	= if id_pt_contour == 1 then pts.count else id_pt_contour - 1
					local pt_precedant  = pts[ id_pt_avt ]
					
					local vec_1 = pt_suivant 		- pt_contour
					local vec_2 = pt_precedant 	- pt_contour
					
					
					local dot_vecs = dot (normalize vec_1) 	(normalize vec_2)
					
-- 					debug "------------>	dot_tangents" var:dot_tangents
					
					if abs dot_vecs >	dotmax_courbe do (
						append ids_aSupprimer 	id_pt_contour
					)
					
				)
				
				
				for i = ids_aSupprimer.count to 1 by -1 do
					deleteItem pts_result[id_spline_contour]  ids_aSupprimer[i]
				
			)
			
			pts_result
		),
		
		
		fn interpoler_shape 	_shp	=(
			
			local result	=#()
	
			local precision_courbe 		= .1			--- en cm. ----
			local dotmax_courbe 		= .999	--- en dot ?!?. ----
			
			m_pts_contour = #()
			
			
			---- pour chacune des splines du shape ----------------
			for id_spline_contour	=	1	to numsplines  _shp do (
				
				local pts_spline_contour = for j= 1 to numKnots 	_shp	id_spline_contour	 collect getKnotPoint _shp 		id_spline_contour	 	j 
				local pt_result 	= #()
				for id_pt_contour	=	1	to pts_spline_contour.count do (
					
					local pt_contour  = getKnotPoint _shp 		id_spline_contour	 	id_pt_contour
					
					local type_knot 			= getKnotType 		_shp  id_spline_contour	 id_pt_contour
					
					
					
					----- Interpolation  - adaptif ----------------------------					
					local longueur_segment 	= get_longueur_segment		id_spline_contour		id_pt_contour 
					local pos_courbe 			= 0
					local nbr_division 			= floor ( longueur_segment / precision_courbe)
					local increment_courbe 	= 1 / nbr_division
					
					local tangent					=	normalize ( tangentBezier3D   _shp 	id_spline_contour 	id_pt_contour 		0 )
					local tangent_derniere		= 	tangent
					
					append pt_result	( interpBezier3D 		_shp 	id_spline_contour 	id_pt_contour 		0 )
					
					while pos_courbe < 1 do (
						
-- 							debug "---# pos_courbe # " var:pos_courbe
						local pt_interpol 	= interpBezier3D 		_shp 	id_spline_contour 	id_pt_contour 		pos_courbe
						tangent 				= normalize ( tangentBezier3D   _shp 	id_spline_contour 	id_pt_contour 		pos_courbe )
						
-- 						debug "------------>	tangent  " var:tangent
						local dot_tangents = dot tangent tangent_derniere
						
-- 						debug "------------>	dot_tangents" var:dot_tangents
						if dot_tangents <	dotmax_courbe do (
							tangent_derniere = tangent
							append pt_result	pt_interpol
						)
						pos_courbe	+= increment_courbe
						
					)
							
-- 							)
-- 					) ---- fin case type -------------------
					
				)
				append result	pt_result
			)
			
			result = nettoyer_points_inutiles  	result
			
			result
		),
		
		fn get_points_contour = m_pts_contour,
		
	public
		fn set_shape			_shp 	=	(
			
			m_shp_contour 	= 	_shp
			m_pts_contour 	= 	interpoler_shape		_shp
			
		),
		fn set_resolution		_val 	= m_resolution = _val,
			
		fn quadriller	=(
			
			debug "---------------quadriller-------------"
			
			
			
			
			if m_shp_contour != undefined do (
				
				
			
			
				---- pour chacune des splines du shape ----------------
				for id_spline_contour	=	1	to numsplines  m_shp_contour do (
					
					debug "---->	id_spline_contour" var:id_spline_contour
					
					--- on chope les points de la spline courante ----------------
					local pts_spline_contour = for j= 1 to numKnots 	m_shp_contour	id_spline_contour	 collect getKnotPoint m_shp_contour 		id_spline_contour	 	j 
					
					
					--- on prend le premier point de cette spline -------------
					local pts_shp_initial		=	pts_spline_contour
					local id_pt_initial 	= 1
					
					local pts_shp_courant	=	pts_shp_initial
					local id_pt_courant 	= 0
					local compteurSecours = 1
					local on_continue = true
					while on_continue and compteurSecours <50	do (
						
						debug "	compteurSecours" var:compteurSecours
						
						--- initialisation-----
						if id_pt_courant == 0 do id_pt_courant = id_pt_initial
						local id_pt_suivant 	= if id_pt_courant == pts_shp_courant.count then 1 else id_pt_courant  + 1
							
						local pt_courant 		= pts_shp_courant[ id_pt_courant ]
						local pt_suivant 		= pts_shp_courant[ id_pt_suivant ]
						
						local pts_case 		= get_pts_case	pt_courant
						debug "	---->	pts_case" var:pts_case
						
						
						
						--- on cherche les intersections ----
						
						
						
						
						
						
						
						--- indentation---------
						compteurSecours+= 1
						id_pt_courant += 1
						if id_pt_courant > pts_shp_courant.count do id_pt_courant = 1
						
						--- sortie ----
						if  id_pt_courant == id_pt_initial  and  pts_shp_courant == pts_shp_initial do on_continue = false
					)
					
				)---- fin for splines -----------------
				
				
			) --- fin if contour existe ---------
			
		) --- fin quadriller -------
	
) ---- fin struct -----------------------------------------------------------




clearListener ()


(
		quadrillage = str_quadriller ()

-- 		pts = quadrillage.set_shape	$'Line001'


		-- for spl in pts do
		-- 	for pt in spl do
		-- 		point pos:pt	size:1
			
			
-- 		for spl in pts do (
-- 			
-- 			local sp = splineShape name:"result"
-- 			addnewSpline sp
-- 			
-- 			for pt in spl do
-- 				addknot sp 1 #corner #curve  pt
-- 			close sp 1
-- 			updateShape sp
-- 			
-- 		)


		quadrillage.set_shape	$'tracé cadre'
		quadrillage.quadriller ()



)



