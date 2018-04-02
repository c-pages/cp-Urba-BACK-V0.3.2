

struct	str_outils_shape (
	
	private
		fn point_estAGauche		_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
-- 				format "point_est_aGaucheDuSegment : %\n" sens
			sens
			
		),
		----- accessions divers  ---------------
		fn get_longueur_segment	_shp	_id_spline	_id_pt 	=(
			
			local tab_longueurs_sgts		=	getSegLengths 	_shp 	_id_spline	 cum:false byVertex:true numArcSteps:100
			local nbr_pts_total 				=	numknots	 		_shp	_id_spline
			local longueur_result			= 	tab_longueurs_sgts[ nbr_pts_total + 2 + _id_pt]
			longueur_result
		),
		fn get_intersection_vecteurs		vec1_pt_1   vec1_pt_2		vec2_pt_1	vec2_pt_2 =(
			

			local pt_intersec
			
			local vec_1 = vec1_pt_2 - vec1_pt_1
			local vec_2 = vec2_pt_2 - vec2_pt_1
			
			
			if vec_1.x*vec_2.y-vec_1.y*vec_2.x != 0 then (
				
				local coef_vec2 = -(-vec_1.x*vec1_pt_1.y+vec_1.x*vec2_pt_1.y+vec_1.y*vec1_pt_1.x-vec_1.y*vec2_pt_1.x)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				local coef_vec1 = -(vec1_pt_1.x*vec_2.y-vec2_pt_1.x*vec_2.y-vec_2.x*vec1_pt_1.y+vec_2.x*vec2_pt_1.y)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				
				if coef_vec1 > 0 and coef_vec1 < 1 and coef_vec2 > 0 and coef_vec2 <1 do
					pt_intersec	= vec2_pt_1 + coef_vec2*vec_2
				
			)
			
			pt_intersec
			
		),
		fn pointLePlusHautsurY 			_pts		=(
			local maxi = _pts[1].y
			local result_id = 1
			for i = 1 to _pts.count do (
				local pt = _pts[	i ]
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			
	-- 			debug "pointLePlusHautsurY"	var:result_id
			result_id
		),
		fn est_sensPositif 					_pts 		=(
			
			local result 				= true
			local id_pointHaut 	=  pointLePlusHautsurY  	_pts
			
			local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 		= id_pointHaut 		---- le point origine
			local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = _pts.count
			if id_pt_2 > _pts.count  do id_pt_2 = 1
			
			local	pt_1 		= _pts [	id_pt_1		]
			local	pt_ori 		= _pts [	id_pt_ori	]
			local	pt_2 		= _pts [	id_pt_2		]

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
			result
			
		),
		fn changer_sens 					_pts 		=(
			local result =#()
			for i= _pts.count to 1 by -1 do 
				append result _pts[i]
			result
		),
	
		----- manipulation de  shape  ---------------
		fn nettoyer_points_inutiles	_pts	 	_seuil:.9999		=(
			
			local dotmax_courbe 	= _seuil	--- en dot ?!?. ----
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
					
					if abs dot_vecs >=	dotmax_courbe do (
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
					local longueur_segment 	= get_longueur_segment	_shp	id_spline_contour		id_pt_contour 
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
			
			
			result
		),
		
		
		
	public
		---- mutateur-------------------------------
		fn get_pts_from_shape			_shp 	=	(
			
			--- on créer les points à partir du shape	----------
			local pts_result 	=  interpoler_shape				_shp
			
			--- on supprime les points en ligne droite	----------
			pts_result 			= nettoyer_points_inutiles  	pts_result
			
			--- on met les points dans l'ordre	----------
			for pts_spline_result in pts_result do
				if not est_sensPositif 	pts_spline_result 	 do
					pts_spline_result = changer_sens		pts_spline_result
			
			pts_result
		)
		
			
	
)


popo = str_outils_shape ()
popo.get_pts_from_shape  $













