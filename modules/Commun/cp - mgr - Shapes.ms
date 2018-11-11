
	
struct str_mgr_shape (







	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	public
-- 		m_debug	= true,
		m_debug = false,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | shape"	  	var:var	 param:param		catch (),
		m_tab_format_nd = "		",
		fn format_noeud 	_nd =(
			local indent_prfix = "|    "
			debug (  m_tab_format_nd +  "+ " + _nd.nom + "" )
			if _nd.enfants.count >0 	do	m_tab_format_nd += indent_prfix
			for enft in _nd.enfants 	do 	format_noeud enft
			if _nd.enfants.count >0 	do	m_tab_format_nd = substring m_tab_format_nd 1 (	m_tab_format_nd.count -	indent_prfix.count )
		),
		fn	debug_nd  _nd = if m_debug do (			 
			
-- 			debug "----------------------------------------------------"
			format_noeud 	_nd 
		),
		fn debug_calque	_calq	=(
			debug "----------------------------------------------------------------------------"
			debug ("[ " + _calq.nom  + "(#" + _calq.operation as name + ") ]" )
			for nd in _calq.noeuds do
				debug_nd nd
-- 			debug "----------------------------------------------------"
			
		),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		
		
		--- constantes---------
		PRECISION_COURBE 			= .1,--50,			--- en cm. ----
		DOTMAX_COURBE 				= .999,	--- en dot ?!?. ----
		SEUIL_POINTS_EGAUX  	= .000001,
		SEUIL_DOT  	= 	1e-05,		--0,	
		-- constante pr debug-----------------
-- 		SAUVETAGE_MAX 			= 100,
		
-- 	private
	public --- DEBUG en est en private normalement ----
		
		----------------- tableaux -----------------
		fn sont_egaux_tableaux 	first 	second =		(
			debug "sont_egaux_tableaux"
			result = true
			if first.count != second.count then (
				debug "	---->	sortie #1 : FALSE"
				result = false
			) 	else if first.count == 0 then (
				debug "	---->	sortie #2 : TRUE"
				result = true
			)	else (
				for i = 1 to first.count do
								case classof first[i] of (
									Point3:		(
										if distance first[i]  second[i]	> SEUIL_POINTS_EGAUX	do (
												debug "	---->	sortie #3 : TRUE"
												debug ( "	---->	sortie #3 :  first[i] -> " +  first[i] as string )
												debug ( "	---->	sortie #3 :  second[i] -> " +  second[i] as string )
														result = false
										)
										
									)
									default:		(
														if first[i] != second[i] do (
																	debug "	---->	sortie #3 : TRUE"
												debug ( "	---->	sortie #3 :  first[i] -> " +  first[i] as string )
												debug ( "	---->	sortie #3 :  second[i] -> " +  second[i] as string )
																			result = false
															)
														)
								)
				
						
			)
			result
		),
		
		fn boucler 							_array				_id_item 		=(
			
			if _id_item >	_array.count do _id_item = mod _id_item _array.count
			if _id_item < 1 do _id_item += _array.count
			_id_item as integer
		),
		
		fn get_partie_tableau		_tableau		_id_debut	_id_fin	sens:1		=(
			
			
			
-- 			debug "get_partie_tableau	()"
-- 			
			
			
			
			local result = #()
			local id_debut		=	_id_debut
			local id_fin			=	_id_fin
			
			
			if sens == 1 then
				if id_fin < id_debut do (
					id_fin += _tableau.count
				)
			else
				if id_debut < id_fin  do (
					id_debut += _tableau.count
				)
			
-- 			debug "	sens"	var:sens
-- 			debug "	_id_debut"	var:_id_debut
-- 			debug "	id_debut"	var:id_debut
-- 			debug "	_id_fin"	var: _id_fin
-- 			debug "	id_fin"	var: id_fin
-- 			debug "	_tableau.count"	var: _tableau.count
			result = for id = id_debut to id_fin by sens	collect	_tableau[ ( boucler _tableau id ) ]
			
		),
		
		
		
		
		--- Analyse position de points (survol_triangles etc..)		-------------
		fn point_estSurSegment	_pt_test		_pt_A		_pt_B	=(
			
			local pt_A = _pt_A
			local pt_B = _pt_B
			
			local pt_C = _pt_test
			
			
			local vec_CA	=	pt_A - pt_C
			local vec_CB	=	pt_B - pt_C

			local norm_CA		=	normalize vec_CA
			local norm_CB		=	normalize vec_CB

			local dot_CA_CB	=	dot 	norm_CA		norm_CB 
			
-- 			debug "	###	dot_CA_CB "  var:dot_CA_CB
			
-- 			local result =  ( 1 + dot_CA_CB   ) < SEUIL_DOT
			
			local result =		( dot_CA_CB	==	-1 )
			
-- 			debug  "	###	( dot_CA_CB	==	-1 )" var:( dot_CA_CB	==	-1 )
			
-- 			if not result and dot_CA_CB < 0 	do (
-- 				local dist_pt_seg		=		this.get_distance_point_segment		_pt_test		_pt_A		_pt_B
-- 				debug  "	###	dist_pt_seg" var:dist_pt_seg
-- 				if dist_pt_seg == 0 /* < SEUIL_POINTS_EGAUX  */do
-- 					result = true
-- 			)
-- 			debug "	###	point_estSurSegment" var:result
			result
			
		),
		fn est_aGauche		_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			
/* 			if inclure_segment then (
				sens = if sensDot > 0 then true 
				else (
					if point_estSurSegment  _pt_aTester  _pt_seg_1	_pt_seg_2
					false
					
				)
			) else  */
				sens = if sensDot > 0 then true else false
			sens
			
		),
		fn est_dansTriangle		_pt_tri_1	_pt_tri_2	_pt_tri_3	_pt_aTester 			inclure_segmts:false		=(
			local result = false
			
-- 			debug "est_dansTriangle	--> _pt_aTester" var:_pt_aTester
			local est_aGauche1 = est_aGauche  _pt_tri_1 	_pt_tri_2 	_pt_aTester 
			local est_aGauche2 = est_aGauche  _pt_tri_2 	_pt_tri_3 	_pt_aTester 
			local est_aGauche3 = est_aGauche  _pt_tri_3 	_pt_tri_1 	_pt_aTester
			
-- 			debug "	--> est_aGauche1" var:est_aGauche1
-- 			debug "	--> est_aGauche2" var:est_aGauche2
-- 			debug "	--> est_aGauche3" var:est_aGauche3
			
			if inclure_segmts do (
				if not est_aGauche1 do
					est_aGauche1 = 	point_estSurSegment	_pt_aTester    _pt_tri_1 	_pt_tri_2 
				if not est_aGauche2 do
					est_aGauche2 = 	point_estSurSegment	_pt_aTester    _pt_tri_2 	_pt_tri_3
				if not est_aGauche3 do
					est_aGauche3 = 	point_estSurSegment	_pt_aTester    _pt_tri_3 	_pt_tri_1
			)
			
			
			
			
			if est_aGauche1	and est_aGauche2  and est_aGauche3 do
				result = true
			
					
				
				
			
-- 			debug ( "est_dansTriangle ( " +  _pt_aTester as string + " )" 	)	var:result

			
			result
		),
		fn survol_triangles  					_pt_aTester			_pts_triangles_shape 	=(
			local result = false
			for pts_tri in _pts_triangles_shape do
				if est_dansTriangle		pts_tri[1]	pts_tri[2]	pts_tri[3]	_pt_aTester do
					result = true
			result			
		),
		fn BBs_seCroisent		_shp_1  	_shp_2	 =(
			
			local BB_1 = get_BB_shape	_shp_1
			local BB_2 = get_BB_shape	_shp_2
			
			local result = true
			if BB_1[1].x > BB_2[2].x  	do result = false
			if BB_1[2].x < BB_2[1].x  	do result = false
			
			if BB_1[1].y > BB_2[2].y  	do result = false
			if BB_1[2].y < BB_2[1].y  	do result = false
			result
		),
		
		
		
		
		
		----- accessions divers  ----------------------------
		--- points ------------
		fn get_longueur_segment	_shp	_id_spline	_id_pt 	=(
			
-- 			debug "----- get_longueur_segment -------- " var: _id_pt
			
			local tab_longueurs_sgts		=	getSegLengths 	_shp 	_id_spline	 cum:false 		byVertex:true 	numArcSteps:100
-- 			debug "tab_longueurs_sgts" var: tab_longueurs_sgts
			local nbr_pts_total 				=	numknots	 		_shp	_id_spline
-- 			debug "nbr_pts_total" var: nbr_pts_total
			local longueur_result			= 	tab_longueurs_sgts[ nbr_pts_total + 2 + _id_pt]
			
-- 			debug "longueur_result" var: longueur_result
			
			longueur_result
			
		),

		
		
	
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
		),
		fn get_angle_vecteurs 		vec1 	vec2	=(
			
			local result_angle
			result_angle = acos(dot (normalize vec1) (normalize vec2))
			result_angle
				 
				
-- 			local result = ( get_angle_vecteur  vec1 )  - ( get_angle_vecteur  vec2 )
-- 			if result < 0 do result = 360 + result
-- 			result
		),
		fn get_angle_vecteurs_2 		vec1 	vec2	=(
			local result = ( get_angle_vecteur  vec1 )  - ( get_angle_vecteur  vec2 )
			if result < 0 do result = 360 + result
			result
		),
		fn get_normal_bisectionOriente_2vecteurs 		_vec1 	_vec2		=(
			
			local	norm_dir 
			
			local norm_vec_1 = (normalize _vec1)
			local norm_vec_2 = (normalize _vec2)			
			
			
			if  norm_vec_1 ==  [-1,0,0] and norm_vec_2 == [1,0,0] then 
				norm_dir = [0,1,0]
			else if norm_vec_1 ==  [1,0,0] and norm_vec_2 == [-1,0,0] then 
				norm_dir = [0,-1,0]
			else if norm_vec_1 ==  [0,1,0] and norm_vec_2 == [0,-1,0] then 
				norm_dir = [1,0,0]
			else if norm_vec_1 ==   [0,-1,0] and norm_vec_2 == [0,1,0] then 
				norm_dir = [-1,0,0]
			else (
				
				local crossProd 	= cross _vec1 	_vec2
				local sensDot 		= dot crossProd  [0,0,1]
				local sens 			= if sensDot > 0 then -1 else 1
				
				norm_dir 		= normalize ( ( norm_vec_1 + norm_vec_2 ) * sens )
				
			---- s'ils sont alignés, on fait les 4 cas 
			)  
			
			
			
			norm_dir
			
		),
		
		fn	get_angle_vecteur_oriente 	vec1_pt1	vec1_pt2	vec2_pt1	vec2_pt2 =(
			local v1 = vec1_pt2 - vec1_pt1
			local v2 = vec2_pt2 - vec2_pt1
			
			local result_angle = get_angle_vecteurs_2 	v1 v2	 
			
			if est_aGauche		vec1_pt1	vec1_pt2		( vec1_pt2 +  v2 ) do 
				result_angle	=	 - result_angle
			
			result_angle
		),
		fn	get_angle_oriente 	vec1	 =(
			local v1 = [1,0,0]
			local v2 = vec1
			
			local result_angle = get_angle_vecteurs	 	v1 v2	 
			
			if est_aGauche		v1	[0,0,0]		vec1 do 
				result_angle	=	 - result_angle
			
			result_angle
		),
		
		
		
		

		fn get_distance_point_segment		_pt		_seg_pt1	_seg_pt2 =(
-- 			debug "			--->	get_distance_point_segment " var:#( _pt	,	_seg_pt1,	_seg_pt2 )
			
			local pt 			= _pt
			local vec_1 		= (_seg_pt2  -  _seg_pt1)
			local vec_2 		=  ( _pt  -  _seg_pt1)
			
			local angle_test 	= get_angle_vecteur    vec_1 vec_2
-- 			debug "			--->	angle_test" var:angle_test
			local longueur_hypo = length vec_2
-- 			debug "			--->		longueur_hypo" var:longueur_hypo
			local dist_result 	= abs ( longueur_hypo	* sin  angle_test )
			dist_result
			
		),
		fn get_aire_triangle	_pts_triangle =(
-- 			debug "		--->	get_aire_triangle " var:_pts_triangle
			local l 		= 	distance	_pts_triangle[1]	_pts_triangle[2]
			local h		=	get_distance_point_segment  _pts_triangle[3]	_pts_triangle[1]	_pts_triangle[2]
-- 			debug "		--->	L" var:l
-- 			debug "		--->	h" var:h
			local aire 	= l * h / 2
-- 			debug "		--->	aire " var:aire
			aire
		),
		
		
		
		
		
		fn get_intersection_droites		vec1_pt_1   vec1_pt_2		vec2_pt_1	vec2_pt_2 =(
			
			local pt_intersec
			
			local vec_1 = vec1_pt_2 - vec1_pt_1
			local vec_2 = vec2_pt_2 - vec2_pt_1
			
-- 			pt_P = vec1_pt_1 + coef_vec1*vec_1
-- 			pt_P = vec2_pt_1 + m*vec_2
			
			if vec_1.x*vec_2.y-vec_1.y*vec_2.x == 0 then (
-- 				debug "##### PARALLELES #####"
			) else (
				
				local coef_vec2 = -(-vec_1.x*vec1_pt_1.y+vec_1.x*vec2_pt_1.y+vec_1.y*vec1_pt_1.x-vec_1.y*vec2_pt_1.x)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				local coef_vec1 = -(vec1_pt_1.x*vec_2.y-vec2_pt_1.x*vec_2.y-vec_2.x*vec1_pt_1.y+vec_2.x*vec2_pt_1.y)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
-- 				debug "coef_vec1" var:coef_vec1
-- 				debug "coef_vec2" var:coef_vec2
				
-- 				if coef_vec1 > 0 and coef_vec1 < 1 and coef_vec2 > 0 and coef_vec2 <1 do
					pt_intersec	= vec2_pt_1 + coef_vec2*vec_2
-- 					pt_intersec	= vec1_pt_1 + coef_vec1*vec_1
				
			)
			
			pt_intersec
			
		),
		fn get_intersection_vecteurs		vec1_pt_1   vec1_pt_2		vec2_pt_1	vec2_pt_2 =(
			
			local pt_intersec
			
			local vec_1 = vec1_pt_2 - vec1_pt_1
			local vec_2 = vec2_pt_2 - vec2_pt_1
			
			
			if vec_1.x*vec_2.y-vec_1.y*vec_2.x == 0 then (
-- 				debug "##### PARALLELES #####"
			) else (
				
				local coef_vec2 = -(-vec_1.x*vec1_pt_1.y+vec_1.x*vec2_pt_1.y+vec_1.y*vec1_pt_1.x-vec_1.y*vec2_pt_1.x)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				local coef_vec1 = -(vec1_pt_1.x*vec_2.y-vec2_pt_1.x*vec_2.y-vec_2.x*vec1_pt_1.y+vec_2.x*vec2_pt_1.y)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)

				
				if coef_vec1 > 0 and coef_vec1 < 1 and coef_vec2 > 0 and coef_vec2 <1 do
					pt_intersec	= vec2_pt_1 + coef_vec2*vec_2
				
			)
			
			pt_intersec
			
		),
		fn get_intersection_demiDroite_segment		pt_demiDrt_orig	pt_demiDrt_direction  	seg_pt_1  seg_pt_2 =(
			
			local result
			
			local pt_intersection 		=  get_intersection_droites		pt_demiDrt_orig   pt_demiDrt_direction		seg_pt_1	seg_pt_2 
			if pt_intersection != undefined do (
				
				local vec_intersection 		= pt_intersection 			- pt_demiDrt_orig
				local	norm_intersection	= normalize vec_intersection
				local vec_demiDroite 		= pt_demiDrt_direction		- pt_demiDrt_orig
				local	norm_demiDroite		= normalize vec_demiDroite
				
				local dot_intersection 		= dot norm_intersection 	norm_demiDroite	
-- 				
				-- on test le segment ------
				local dist_seg_1 		= 	length	( seg_pt_1 -	pt_intersection )
				local dist_seg_2 		= 	length	( seg_pt_2 -	pt_intersection )
				local dist_seg_test 	=  length	( seg_pt_1 -	seg_pt_2 )
				
				--- si on est sur la demi droite ---------------
				if abs ( dist_seg_test  - ( dist_seg_1 + dist_seg_2  ) ) < .01 and dot_intersection > 0 do
					result		=  pt_intersection				
			)
			result
		),
		fn get_intersection_droite_droite		droite1_pt_1		droite1_pt_2 		droite2_pt_1		droite2_pt_2 =(
-- 			debug "get_intersection_droite_droite"
			local pt_intersec	
		
			local vec_1 = droite1_pt_2 - droite1_pt_1
			local vec_2 = droite2_pt_2 - droite2_pt_1
			
			
-- 			debug "(vec_1.x*vec_2.y-vec_1.y*vec_2.x)" var:(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
			local coef_vec2 = -(-vec_1.x*droite1_pt_1.y+vec_1.x*droite2_pt_1.y+vec_1.y*droite1_pt_1.x-vec_1.y*droite2_pt_1.x)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)

			local coef_vec1 = -(droite1_pt_1.x*vec_2.y-droite2_pt_1.x*vec_2.y-vec_2.x*droite1_pt_1.y+vec_2.x*droite2_pt_1.y)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
-- 			if coef_vec1 > 0 and coef_vec1 < 1 and coef_vec2 > 0 and coef_vec2 <1 do

				pt_intersec	= droite2_pt_1 + coef_vec2*vec_2
			
-- 			debug "pt_intersec"
			pt_intersec
			
		),
		
		
		
		
		fn point_lePlusHautSurY 			_pts		=(
			local maxi = _pts[1].y
			local result_id = 1
			for i = 1 to _pts.count do (
				local pt = _pts[	i ]
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			
	-- 			debug "point_lePlusHautSurY"	var:result_id
			result_id
		),
		fn point_lePlusAGauche		_pts =(
			local index = 0
			local minX = 1e10
			
			for i = 1 to _pts.count do (
				if _pts[i].x < minX do (
					minX = _pts[i].x
					index = i
				)
			)
			
			index
		),	
		fn points_lesPlusLoinDuSegment 			_pts			_pt_seg1		_pt_seg2 	=(
			
			local result_index 	= #()
			local dist_max 		= -1e+10
			for i = 1 to _pts.count do (
				/* 
				local pt 			= _pts[i]
				local vec_1 		= (_pt_seg2  -  _pt_seg1)
				local vec_2 		=  ( pt  -  _pt_seg1)
				
				local angle_test 	= get_angle_vecteur    vec_1 vec_2
				
				local dist_test 	= abs ( ( dot  vec_1  vec_2 ) * tan  angle_test ) */
				
				local dist_test  = get_distance_point_segment  	_pts[i]			_pt_seg1		_pt_seg2
				
				if dist_test > dist_max then (
					dist_max 		= dist_test
					result_index 	= #(i)
				) else if dist_test == dist_max do (
					append result_index	i
				)
			)
			result_index
		),
		
		
		
		
		
		--- shapes ------------
		fn get_BB_shape		_pts_shp 	=(
			local result #([0,0,0],[0,0,0])
			
			
			local minX = minY 	= minZ =1e10
			local maxX = maxY 	= maxZ = -1e10
			
			for pt in _pts_shp do (
				if pt.x < minX 		do minX = pt.x 
				if pt.y < minY 	do minY = pt.y
				if pt.z < minZ 		do minZ = pt.z 
				if pt.x > maxX 	do maxX = pt.x 
				if pt.y > maxY 	do maxY = pt.y 
				if pt.z > maxZ 	do maxZ = pt.z 
			)
			
			#([minX,minY,minZ],[maxX,maxY,maxZ])
			
		),
		fn get_aire_BB  		_pts_shp 	=(
			local BB 		= get_BB_shape		_pts_shp
			(BB[2].x - BB[1].x) * (BB[2].y - BB[1].y)
		),
		fn get_lePlusGros_shape	_pts_shps =(
			local aireMax = 0
			local id_result = 0
			for i = 1 to _pts_shps.count do (
				local pts_shp = _pts_shps[i]
				local aire = get_aire_BB 	pts_shp
				if aire> aireMax do (
					id_result = i
					aireMax = aire
				)
			)
			id_result
		),
		fn get_lePlusPetit_shape	_pts_shps =(
			local aireMin = 1e+20
			local id_result = 0
			for i = 1 to _pts_shps.count do (
				local pts_shp = _pts_shps[i]
				local aire = get_aire_BB 	pts_shp
				if aire< aireMin do (
					id_result = i
					aireMin = aire
				)
			)
			id_result
		),
		fn edge_lePlusGrand				_pts 		=(
			local longueurEdgeMax = 0
			local	resultPts = #()
			for i = 1 to _pts.count do (
				local j = i+1
				if j > _pts.count  do j = 1
				local pt 			= _pts[	i ]
				local pt_suivant	= _pts[	j ]
				local longueurEdge = distance	pt	pt_suivant
				if longueurEdge > longueurEdgeMax do (
					longueurEdgeMax = longueurEdge
					resultPts = #(pt, pt_suivant)
				)
			)
			resultPts
		),
		fn get_distance_shapes  _pts_shp1  _pts_shp2 =(
			
			struct	str_dist_shapes	(
				id_pt_shp1	=	0,
				id_pt_shp2	=	0,
				distance		= 1e+10
			)
			
			
			local id_pt_connexion_1	=	0
			local id_pt_connexion_2	=	0 
			local dist_min					= 1e+10
			local result 
			
			for id_pt1 = 1 to  _pts_shp1.count do (
				local pt1	=	_pts_shp1[ id_pt1 ]
				for id_pt2 = 1 to  _pts_shp2.count do (
					local pt2			=	_pts_shp2[ id_pt2 ]
					local dist_test	=	distance	pt1 pt2
					if dist_test < dist_min do (
						dist_min = dist_test
						id_pt_connexion_1	=	id_pt1
						id_pt_connexion_2	=	id_pt2
						result = str_dist_shapes  id_pt_shp1:id_pt1	id_pt_shp2:id_pt2	distance:dist_test
					)				
				)
			)
			
			result
			
		),
		fn get_shape_lePlusProche	_pts_shp1		_pts_shps_aTester 		=(
			
			struct	str_shape_lePlusProche	(
				id_shp 		= 	0,
				id_pt_shp1	=	0,
				id_pt_shp2	=	0
			)
			
			local dist_min	= 1e+10
			local result = str_shape_lePlusProche ()
			
			local pts_shp1	= _pts_shp1
			
			for  i = 1 to _pts_shps_aTester.count do (
				local pts_shp2	= _pts_shps_aTester[ i ]
				
				local dist_test = get_distance_shapes 	pts_shp1  	pts_shp2
				if dist_test.distance < dist_min do (
					dist_min = dist_test.distance					
					result.id_shp 		= 	i
					result.id_pt_shp1	=	dist_test.id_pt_shp1
					result.id_pt_shp2	=	dist_test.id_pt_shp2
				)
			)
				
			result
		),
		fn get_id_shp_enfant_proche 		_shp_1  	shps_tests 	=(
			
			local result = 0
			if _shp_1.count != 0 then (
				--- on cherches les shapes qui sont à l'interieur -------
				local shps_interieur =#()
				for shp in shps_tests do
					if shape_estDans_shape	 _shp_1 		shp do
						append shps_interieur	shp
				
-- 				--- si on a des shapes à l'interieur ---------------
				--- parmis ceux à l'interieur on prend le plus proche ---------------------------
				if shps_interieur.count > 0 do 
					result 	= 	( get_shape_lePlusProche 		_shp_1	shps_interieur ).id_shp
					
			) else result = 1
			
			result
		),
		fn get_ids_shapes_aLInterieur		_shp		_shps_aTester  =(
			local ids_result =#()
			for i = 1 to _shps_aTester.count do (
				local shp_aTester = _shps_aTester[i]
				if shape_estDans_shape 	_shp 	shp_aTester  do
					append  ids_result		i
			)
			ids_result
		),
		fn get_aire_shape	_pts_shp	 =(
			local triangles_duShape 	= 	this.trianguler 	_pts_shp
			local result_aire 				=	0
			for tri in triangles_duShape do result_aire +=	get_aire_triangle	tri
-- 			debug "	--->	get_aire_shape " var:result_aire
			result_aire
		),
		
		
		
		fn decaller_bisectrice 		_pt_a_decaller		_vec_avt		_vec_aprs		_distance	=(
			
			local	norm_bisectrice 				= get_normal_bisectionOriente_2vecteurs 	_vec_avt 		_vec_aprs
			local distance_aux_segments 	= _distance
			local angle_pt 							= get_angle_vecteurs_2 	_vec_avt	 _vec_aprs
			local distance_sur_bisectrice 	= distance_aux_segments / ( sin ( angle_pt /2) )		
			
			local result	 			= _pt_a_decaller 	+ norm_bisectrice		* distance_sur_bisectrice 
			
			result
			
		),
		fn retrecir_polygone 		_pts		_decalage	= (
			
			local poly_result = #()
			
			---- ( C-2 )	on applique le retrecissement à chaque points ( pour obtenir la lise : pts_retrecissement)  ---------
			for i = 1 to _pts.count do (
				
				-- les ids des points concernés -----------
				local id_pt 			= i
				local id_pt_avt		= if id_pt == 1 then _pts.count else id_pt - 1
				local id_pt_aprs	= if id_pt == _pts.count then 1 else id_pt + 1
				
				local pt 			= _pts[id_pt]
				local pt_avt		= _pts[id_pt_avt]
				local pt_aprs 	= _pts[id_pt_aprs]
				
				local vec_avt		= _pts[id_pt_avt] 	- _pts[id_pt] 
				local vec_aprs 		= _pts[id_pt_aprs] 	- _pts[id_pt] 
				
				
				----	on trouve la position de destination de chaque point du polygone après rétrécissement (pts_pos_dest).
				local pt_dest 		= decaller_bisectrice 		pt		vec_avt		vec_aprs		_decalage
-- 					pt_dest.z += decallageHT
				
				poly_result[i] 	= pt_dest
				
			)
			poly_result
		),
		
		
		
		--- sens du shape ----------------------
		fn est_sensPositif 				_pts 		=(
			debug "est_sensPositif"
			local result 			= true
			local id_pointHaut 	=  point_lePlusHautSurY  	_pts
			
			local	id_pt_1 			= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 		= id_pointHaut 		---- le point origine
			local	id_pt_2 			= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = _pts.count
			if id_pt_2 > _pts.count  do id_pt_2 = 1
			
			local	pt_1 		= _pts [	id_pt_1	]
			local	pt_ori 	= _pts [	id_pt_ori	]
			local	pt_2 		= _pts [	id_pt_2	]

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
			debug "est_sensPositif FIN"
			result
			
		),
		fn changer_sens 					_pts 		=(
			debug "changer_sens()"
			local result =#()
			for i= _pts.count to 1 by -1 do 
				append result 	_pts[i]
			debug "changer_sens()	FIN"
			result
		),
		fn get_positionRelative_BB		_pts_shpA		_pts_shpB 	=(
			
			local BB_A		= get_BB_shape	_pts_shpA
			local BB_B 		= get_BB_shape	_pts_shpB
			local result
			
			if BB_A[1].x < BB_B[1].x 	and	BB_A[2].x > BB_B[2].x  	and	BB_A[1].y < BB_B[1].y  	and	BB_A[2].y > BB_B[2].y then
				result = #interieur
			else if BB_A[1].x > BB_B[1].x 	and	BB_A[2].x < BB_B[2].x  	and	BB_A[1].y > BB_B[1].y  	and	BB_A[2].y < BB_B[2].y then
				result = #exterieur
			else if BB_A[1].x > BB_B[2].x 	or		BB_A[2].x < BB_B[1].x 	or BB_A[1].y > BB_B[2].y 	or		BB_A[2].y < BB_B[1].y 	then
				result = #aCoté
			else 
				result = #seCroisent
			
			
			result
		),
		
		
		

	-----------------  Axe Principale ----------------------
	public
		fn get_axePrincipal_mtrx				_pts  					=(
			
			local ptsEdgeLePlusLong 	= edge_lePlusGrand	_pts
			
			local axeVecteur_x 		= 	normalize (ptsEdgeLePlusLong[2] - ptsEdgeLePlusLong[1])			
			local axeVecteur_y		= 	axeVecteur_x 	* rotateZ ( matrix3 1 ) 90		
			local axeVecteur_z		= 	[0,0,1]
			
			local axeMtrx			= matrix3 axeVecteur_x 	axeVecteur_y		 axeVecteur_z	 [0,0,0]
			
			axeMtrx
		),
		fn get_axePrincipal_BB					_pts  	_mtrxAxe  	=(
			
			local pt1 = _pts[1] * inverse _mtrxAxe
			local xMin = xMax = pt1.x
			local yMin = yMax = pt1.y
			local zMin = zMax = pt1.z
			
			for i = 2 to _pts.count do (
				local pt = _pts[i] * inverse _mtrxAxe
				if pt.x < xMin 		do xMin 		= pt.x
				if pt.x > xMax 	do xMax 	= pt.x
				if pt.y < yMin 		do yMin 	= pt.y
				if pt.y > yMax 	do YMax 	= pt.y
				if pt.z < zMin 		do zMin 		= pt.z
				if pt.z > zMax 	do zMax 	= pt.z
			)
			
-- 			#([xMin, yMin, zMin]*  _mtrxAxe, [xMax, yMax, zMax]*  _mtrxAxe)
			#([xMin, yMin, zMin] , [xMax, yMax, zMax] )
			
		),
		fn get_axePrincipal_orientation		_mtrxAxe 		_vec 					=(
			
			local mtrx_Direction 	= _mtrxAxe
			local vec_direction 	= [1,0,0] * mtrx_Direction
			
			local vec1_dir = normalize 	_vec	
			
			local valTest =  abs  (dot  vec_direction	vec1_dir ) 
			
			if valTest	 > cos 45 then 
				#parallele
			else 
				#perpendiculaire
			 
		),
		
		
		
		
		
		
		
		---------------------- collisions ------------------------
		fn BBs_seCroisent		_shp_1  	_shp_2	 =(
			local result = false
			
			
			
			if _shp_1.count > 0 do 	(
				
				
				
				local BB_1 = get_BB_shape	_shp_1
				local BB_2 = get_BB_shape	_shp_2
				
				if get_positionRelative_BB		_pts_shpA		_pts_shpB  == #aCoté do (
					
					
				)
				
				/* 
				--- les X de BB2 dans X de BB1 ---------------
				if BB_2[1].x > BB_1[1].x	and BB_2[1].x < BB_1[2].x or BB_2[2].x > BB_1[1].x	and BB_2[2].x < BB_1[2].x do
					--- les Y de BB2 dans Y de BB1 ---------------
					if BB_2[1].x > BB_1[1].x	and BB_2[1].x < BB_1[2].x or BB_2[2].x > BB_1[1].x	and BB_2[2].x < BB_1[2].x 
				
				
				
				
				if BB_1[1].x > BB_2[2].x  			then result = false
				else if BB_1[2].x < BB_2[1].x  	then result = false
				else if BB_1[1].y > BB_2[2].y  	then result = false
				else if BB_1[2].y < BB_2[1].y  	do result = false
					
				 */
			)
			result
		),
		------- renvois la position d'un shape par rapport à un autre: si un shapes est ' l'interieur d'un autre (trou boolean), se croisent ou à l'exterieur ---------
		fn get_positionRelative_shapes 		_pts_shpA		_pts_shpB 		renvoyer_intersections:true		=(
			
-- 			debug "\n"
-- 			debug "----------get_positionRelative_shapes()----------------------------------------"
			
-- 			debug "		_pts_shpA" var:_pts_shpA
-- 			debug "		_pts_shpB" var:_pts_shpB
-- 			debug "		renvoyer_intersections" var:renvoyer_intersections
			
			struct	str_intersection	(
				pos,
				id_A,
				id_B
			)
			
			
			local result_pos 		= #aCoté		---- #exterieur,  #interieur, #seCroisent, ou	 #aCoté	 --------------
			local intersections 	=#()
			
			local BB_pos_relative		=  get_positionRelative_BB		_pts_shpA 		_pts_shpB 
			
			
-- 				debug "-------->BB_pos_relative " var:BB_pos_relative
			---- si les BB se croisent	-------------------
			if  BB_pos_relative != #aCoté 	then (
			
-- 				debug "-------->BB  seCroisent"
				---- on regadre si les edges se coupent --- si oui --->  #seCroisent -----------------
				local trouve = false
				local  i = 1
				while i <= _pts_shpA.count and  not trouve do (
					
					local pt_shpA			= _pts_shpA[ i ]
					local i_svt	=	if i == _pts_shpA.count  then 1 else i + 1
					local pt_shpA_svt	= _pts_shpA[ i_svt ]
					
-- 							debug "-------->pt_shpA " var:pt_shpA
-- 							debug "-------->pt_shpA_svt " var:pt_shpA_svt
					local  j = 1
					while j <= _pts_shpB.count 	and  not trouve  do (
						
						local pt_shp2			= _pts_shpB[ j ]
						local j_svt	=	if j == _pts_shpB.count  then 1 else j + 1
						local pt_shp2_svt	= _pts_shpB[ j_svt ]
						
-- 							debug "-------->pt_shpB " var:pt_shp2
-- 							debug "-------->pt_shpB_svt " var:pt_shp2
						
						local intersection_pos = get_intersection_vecteurs		pt_shpA   pt_shpA_svt		pt_shp2		pt_shp2_svt 
						if intersection_pos != undefined do (
							append intersections  ( str_intersection 	pos:		intersection_pos		\
																								id_A:	i 								\
																								id_B:	j 								)
							if not renvoyer_intersections do trouve = true
-- 							debug "-------->	INTERSECTION <-----------------" 
-- 							debug "	-------->_pts_shpA " 	var:_pts_shpA
-- 							debug "	-------->_pts_shpB " 	var:_pts_shpB
-- 							debug "	-------->pt_shpA " 		var:pt_shpA
-- 							debug "	-------->pt_shp2 "  		var:pt_shp2
																								
						)
						j+= 1
					)
					i+= 1
				)
				
				
				
				---- si on a des intersections, alors ils se croisent ------------------------------------
				if intersections.count > 0 then (
					
-- 					debug "		--------> On a des intersections"
					
					
					result_pos 					= #seCroisent
					result_intersections		=	intersections
					
				) else (
-- 					debug "		--------> On a PAS d'intersection"
					---- s'il ne se croisent pas alors ils sont tout à l'interieur ou à l'extierieur l'un de l'autre -------------------------
					local pts_triangles_shpA = this.trianguler	_pts_shpA
 					local pts_triangles_shp2 = this.trianguler	_pts_shpB
					
					if survol_triangles  	_pts_shpB[1]	pts_triangles_shpA	 then 
						result_pos = #interieur
					else  if survol_triangles  	_pts_shpA[1]		pts_triangles_shp2	 then 
						result_pos = #exterieur
				)
				
			) else (
				
-- 				debug "-------->BB  seCroisent   PAS "
				result_pos 				= 	BB_pos_relative
				result_intersections	=	#()
			)
			
			
			---- on renvois le resultat --------------
			struct str_result (
				position,
				intersections
			)
			
			
			
			local result  =	str_result  position:result_pos		 intersections:result_intersections
			
			result
		),
		fn shape_estDans_shape		_shp_1  shp_test 	=(
			if _shp_1.count == 0 then 			
				true
			else 	if not BBs_seCroisent	_shp_1	shp_test then
				false	
			else if (get_positionRelative_shapes  _shp_1	shp_test )[i] == #interieur then 
				true
			else 
				false
		),
		fn point_est_dansShape		_pt		_pts_shp 	=(		
			local triangles	=	this.trianguler 	_pts_shp
			
			survol_triangles  	_pt		triangles			
		), 
		
		
		
		----- chercher les segments etant sur le meme axe qu'un point	-----
		-----	Axe: #orizontal ou #vertical	----
		
		fn get_sgts_sur_memeAxe		_axe		 _pts_shp		_pt_test	/* 	ds_matiere:false	 */ =(
-- 			debug ""
-- 			debug "------get_sgts_sur_memeAxe"
-- 			debug "	_pt_test" var:_pt_test
			local result = #()
-- 			local pt_test  					=	_pts_shp[_id_pt_test]
-- 			local id_pt_test_precedant	=	boucler 	_pts_shp	(_id_pt_test - 1 )
			
		
			
			for i= 1 to _pts_shp.count   do (
				local pt_courant	= _pts_shp[ i]
				
				if _pt_test != pt_courant do (
					local i_suivant 	= boucler _pts_shp ( i+1)
					local pt_suivant 	=_pts_shp[ i_suivant ]
					
					
					----- on regarde si on est du coté matiere de l'edge  testé -----------------
-- 					local on_est_ds_matiere = est_aGauche		pt_courant	pt_suivant   	_pt_test
-- 					
-- 					debug "	---	> on_est_ds_matiere" var:on_est_ds_matiere
-- 					
-- 					if not ds_matiere or ds_matiere and	on_est_ds_matiere do (
						case _axe of (
							#horizontal:		if pt_courant.y >= _pt_test.y and pt_suivant.y < _pt_test.y 	or 	pt_courant.y <= _pt_test.y and pt_suivant.y >= _pt_test.y do (
														--- si on touche une lihne horizontale on ajoute les deux points -------------------
														if abs ( pt_courant.y -  pt_suivant.y )  < SEUIL_POINTS_EGAUX   then (
															
	-- 																			debug "		--->	(A) -- horizontal "
															
															appendifunique result i	
															appendifunique result i_suivant
														) else (
															appendifunique result i	
	-- 																			debug "		--->	(A)  "
														)
													) 
							#vertical:			if pt_courant.x >= _pt_test.x and pt_suivant.x < _pt_test.x 		or 	pt_courant.x <= _pt_test.x and pt_suivant.x >= _pt_test.x do (
														--- si on touche une lihne horizontale on ajoute les deux points -------------------
														if abs ( pt_courant.x -  pt_suivant.x )  < SEUIL_POINTS_EGAUX   then (
															appendifunique result i	
															appendifunique result i_suivant
	-- 																			debug "		--->	(B) -- horizontal "
														) else (
															appendifunique result i	
	-- 																			debug "		--->	(B)  "
														)
													) 
		-- 					default: 			debug "		/!\	ERREUR dans 'get_segments_surMemeAxe()' l'axe doit etre '#horizontal: ou '#vertical'		/!\	"
						)
					)
-- 				)
			)
			
-- 																			debug "			--->	result " var:result
				
			result
		),
		
		
		
		
		----- manipulation de  points  ---------------
		fn nettoyer_points_inutiles	_pts	 	_seuil:.9999		=(
			
			local DOTMAX_COURBE 	= _seuil	--- en dot ?!?. ----
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
					
					if abs dot_vecs >=	DOTMAX_COURBE do (
						append ids_aSupprimer 	id_pt_contour
					)
					
				)
				
				
				for i = ids_aSupprimer.count to 1 by -1 do
					deleteItem pts_result[id_spline_contour]  ids_aSupprimer[i]
				
			)
			
			pts_result
		),
		fn interpoler_shape 		_shp_node								=(
-- 			debug "INTERPOLER_SHAPE()"
			
			
			
			local result	=#()
			
			m_pts_contour = #()
			
			
			---- pour chacune des splines du shape ----------------
			for id_spline_contour	=	1	to numsplines  _shp_node do (
				
				local pts_spline_contour = for j= 1 to numKnots 	_shp_node	id_spline_contour	 collect getKnotPoint _shp_node 		id_spline_contour	 	j 
				local pt_result 	= #()
				
				if not isClosed _shp_node	id_spline_contour	 do
					close _shp_node	id_spline_contour	
				
				---- pour chacun des points de la spline -----------------------------------
				for id_pt_contour	=	1	to pts_spline_contour.count  do (
-- 					debug ""
-- 					debug "id_pt_contour" var:id_pt_contour
					
					---- le point	-
					local pt_contour  		= getKnotPoint _shp_node 		id_spline_contour	 	id_pt_contour
					local id_pt_contour_svt = if id_pt_contour != pts_spline_contour.count then id_pt_contour + 1 else 1
					
					local pt_contour_type 			= getKnotType 		_shp_node  id_spline_contour	 id_pt_contour
					local pt_contour_svt_type 	= getKnotType 		_shp_node  id_spline_contour	 id_pt_contour_svt
					
-- 					debug "pt_contour_type" var:pt_contour_type
-- 					debug "pt_contour_svt_type" var:pt_contour_svt_type
					
					if pt_contour_type != #corner or pt_contour_svt_type != #corner then (
-- 						debug "-------------->		ON A UNE COURBE"
						----- Interpolation  - adaptif ----------------------------					
						local longueur_segment 	= get_longueur_segment		_shp_node		id_spline_contour		id_pt_contour 
						local pos_courbe 			= 0
						local nbr_division 			= floor ( longueur_segment / PRECISION_COURBE)
-- 						debug "longueur_segment" var:longueur_segment
-- 						debug "nbr_division" var:nbr_division
						local increment_courbe 	= 1 / nbr_division
						
						local tangent					=	normalize ( tangentBezier3D   _shp_node 	id_spline_contour 	id_pt_contour 		0 )
						local tangent_derniere		= 	tangent
						
						append pt_result	( interpBezier3D 		_shp_node 	id_spline_contour 	id_pt_contour 		0 )
						
						while pos_courbe < 1 do (
							
	-- 							debug "---# pos_courbe # " var:pos_courbe
							local pt_interpol 	= interpBezier3D 		_shp_node 	id_spline_contour 	id_pt_contour 		pos_courbe
							tangent 				= normalize ( tangentBezier3D   _shp_node 	id_spline_contour 	id_pt_contour 		pos_courbe )
							
	-- 						debug "------------>	tangent  " var:tangent
							local dot_tangents = dot tangent tangent_derniere
							
	-- 						debug "------------>	dot_tangents" var:dot_tangents
							if dot_tangents <	DOTMAX_COURBE do (
								tangent_derniere = tangent
								
-- 						debug "--------------> ON Ajoute un point"
								
								append pt_result	pt_interpol
							)
							pos_courbe	+= increment_courbe
							
						)
					) else append pt_result	pt_contour
-- 							)
-- 					) ---- fin case type -------------------
					
				)
				
				--- on met les points dans l'ordre	----------
				if not est_sensPositif 	pt_result 	 do (
					pt_result = changer_sens		pt_result
				)
				append result	pt_result
			)
			
			
			--- on recalle les points à la transform du shape ------------
			for shp in result do
				for pt in shp do
					pt += [10000,0,0]	---inverse _shp.transform
			
			---- on vire les points en ligne droite ----------
			result = nettoyer_points_inutiles	result
-- 			debug "result" var:result
			result
		),

		
	------------------- INTERFACE -----------------------------------------------------------------------
		
		---- TRIANGULATION ----------------
		/* 
		fn decouper_polygone_monotone		_liste_pts		balayage:#verticale		=(
			debug "decouper_polygone_monotone"
				debug "_liste_pts" var:_liste_pts
			------ on cherche les 'pointes'---------
			---			Pour chaque point P, vérifiez si les points voisins sont tous deux du même côté de la ligne de balayage.
			---			Si c'est le cas, vérifiez la ligne de balayage suivante de l'autre côté. 
			---			Casser le polygone sur la ligne entre le point d'origine et l'un des points de celui-ci.
			local polys_result =#()
			
			--- pour chaque polygones --------
			local pts_deRupture =#()
			for id_poly = 1 to _liste_pts.count do (
				
				debug "id_poly" var:id_poly
				
				local pts = _liste_pts[id_poly]
				for i = 1 to pts.count do (
					
					debug "i" var:i
					local i_precedant 	= boucler pts ( i - 1 )
					local i_suivant 		= boucler pts ( i + 1 )
					
					local pt_courant 		= pts [i]					
					local pt_precedant 	= pts [i_precedant]					
					local pt_suivant 		= pts [i_suivant]
					
					
					case balayage of (
						#verticale: (
							if pt_precedant.y < pt_courant.y and pt_suivant.y < pt_courant.y do (
-- 								debug "		------->	on a un point de rupture"	var:pt_courant
								if 
								append pts_deRupture 	pt_courant
							)
								
						)
					) -- fin case balayage -------
					
					
				)
			)
			
								debug "		------->	points de  rupture"	var:pts_deRupture
			
			
			
			polys_result
			
		),
		 */
		
	-----------------  divers ----------------------
	public
		fn estPignon 	_pts		_id		=(
			
			local mtrx_AP	= get_axePrincipal_mtrx 	_pts
			local j 				= boucler  _pts  (_id+1)
			local vec 			= (_pts[j]-_pts[_id])
			local orientation 	= get_axePrincipal_orientation		mtrx_AP		vec
			
			if orientation == #perpendiculaire 
				then true 
				else false
		),
	
	
		
	private
		fn intersection 	_pt_orig 	_pt_2 		_pt_seg_1 	_pt_seg_2  		 =(
			local pt_result
			local seuil = 1
			
			local vec_proj		= _pt_orig - _pt_2
			local vec_seg		= _pt_seg_1 - _pt_seg_2
			
			local norm_proj		= normalize vec_proj
			local norm_seg		= normalize vec_seg
			local dot_proj_seg 	= dot norm_proj norm_seg
			
			
			--- si pas parallele -------------------------
			local a1, b1, a2, b2 
			local d1_vert = false
			local d2_vert = false
			if dot_proj_seg != 1 and dot_proj_seg != -1 do (
				
				--- données pour les eaquations de droite y = ax + b ----
				-- droite projeté----------------------
				if (( _pt_orig.y *1000) as integer /1000  == ( _pt_2.y *1000) as integer /1000) then (
					-- horizontale --
					a1 = 0
					b1 	= _pt_orig.y 
				) else if (( _pt_orig.x *1000) as integer /1000  == ( _pt_2.x *1000) as integer /1000) then (
					-- verticale --s
					a1 	= 1
					b1 	= _pt_orig.y - _pt_orig.x
					d1_vert = true
				) else (
					a1 	= (_pt_orig.y - _pt_2.y ) / (_pt_orig.x - _pt_2.x)
					b1 	= _pt_orig.y - a1*_pt_orig.x
				)		
				-- droite reception
				if _pt_seg_1.y == _pt_seg_2.y then (
					-- horizontale --
					a2 = 0
					b2 	= _pt_seg_1.y 
				) else if _pt_seg_1.x == _pt_seg_2.x then (
					-- verticale --
					a2 	= 1
					b2 	= _pt_seg_1.y - _pt_seg_1.x
					d2_vert = true
				) else (
					a2 	= (_pt_seg_1.y - _pt_seg_2.y ) / (_pt_seg_1.x - _pt_seg_2.x)
					b2 	= _pt_seg_1.y - a2*_pt_seg_1.x
				)
				
				
				
				
				local x, y
				if 	d1_vert then (
					if not d2_vert do (
						x =   _pt_orig.x
						y =   a2 * x + b2
					)
				) else 	if 	d2_vert then (
					if not d1_vert do (
						x =   _pt_seg_1.x
						y =   a1 * x + b1
					)
				) else (
						x =   ( b2 - b1 ) / (a1  - a2 )
						y =   a1 * x + b1
				)
				
				-- si on a un point on verifie la suite -----------------------------
				if x != undefined do (
					
					local pt_proj  = [x,0,y]
					
						--- si projection est dans le bon sens ----------
						if   dot  ( normalize ( _pt_orig - _pt_2 ) )  (  normalize (   pt_proj - _pt_orig) )   > 0 do (
							
							local precision = 1000
							local dist_seg 		= ( ( distance _pt_seg_1 	_pt_seg_2 ) * precision as integer ) / precision
							local dist_ptProj 		= ( ( distance _pt_seg_1 	pt_proj 		+ distance _pt_seg_2 	pt_proj ) * precision as integer ) / precision	
							
							if  dist_ptProj  as string == dist_seg as string  do 
								pt_result 	= pt_proj
							
						)
				)
				
			)
			pt_result
		),
		fn chercher_pt_a90degGauche	_id_pt  	vec_pt		 =(
			
			local seuil = 1			
			local vertexSurLigne = #()
			local mtrx_AP 		= m_plug.axeP_mtrx			
			local pt 				= _pts[ _id_pt ] 			* 	inverse  	mtrx_AP	
			local norm_pt 		= normalize vec_pt			
			local mtrx_rotateZ90	=	rotateY	(matrix3 1)	90
			local norm_test 			= norm_pt * mtrx_rotateZ90			
			local pt_virtuel 			= pt + norm_test			
			local a,b
			local verticale 		= false
			
			if (( pt.y *1000) as integer /1000  == ( pt_virtuel.y *1000) as integer /1000) then (
				-- horizontale --
				a = 0
				b = pt.y 
			) else if (( pt.x *1000) as integer /1000  == ( pt_virtuel.x *1000) as integer /1000) then (
				-- verticale --
				a 	= 1
				b 	= pt.y - pt.x
				verticale = true
			) else (
				a 	= (pt.y - pt_virtuel.y ) / (pt.x - pt_virtuel.x)
				b 	= pt.y - a*pt.x
			)		
			
			
			if not verticale then (
				for i=1 to _pts.count do (
					local pt_test = _pts[i] * 	inverse  	mtrx_AP	
					
					if  abs ( pt_test.y - ( pt_test.x * a + b ) ) < seuil do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
							
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			) else (
				for i=1 to _pts.count do (
					local pt_test = _pts[i] * 	inverse  	mtrx_AP	
					
					if  abs ( pt_test.x - pt.x ) < seuil  do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
							
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			)
			
			vertexSurLigne
			local result 
			local dist_min = 0
			for id_pt_test in vertexSurLigne do (
				local pt_test = _pts[ id_pt_test ] 			* 	inverse  	mtrx_AP	
				local dist_test = distance pt pt_test
				if  dist_test < dist_min or dist_min == 0 do (
					result = id_pt_test
					dist_min = dist_test
				)
			)
			
			result
			
		),
		fn unir 	_listeTraces 	=(
			
			local traces = #() 
			
			for trace in _listeTraces do (
				local traceTmp = for _pt  in trace collect _pt
					append traces traceTmp
			)
				
			
			
			local continu = true
			local suivant = false
			local idTrace1 = 1
			local idTrace2 = 1
			local trace1, trace2
			
			
			while traces.count > 1 and	continu do (
				trace1 	= traces[idTrace1]
				suivant 	= false
				for idTrace2 = 1 to traces.count where idTrace1 != idTrace2 and  not suivant 	do (
					
					trace2 	= traces[ idTrace2 ]
					
					local ptsCommuns			= #()
					local ptsCommuns_trouve = false
					local idCommun_rect1 		= 0
					
					for i = 1 to  trace1.count  where not  ptsCommuns_trouve   do (
						local id1 = trace1[i]
						local id2 =	finditem 	trace2	 id1
						
						if  id2 != 0 then (
							
							append ptsCommuns id1
							if ptsCommuns.count == 2 do 
								ptsCommuns_trouve = true
						)
					)
				
					
					if ptsCommuns.count > 1 then (
						local idPt1_communTrace2 = findItem	trace2  ptsCommuns[1]
						local idPt2_communTrace2 = boucler	trace2  ( idPt1_communTrace2 + 1 )
						
						if trace2[ idPt2_communTrace2 ] != ptsCommuns[2] then (
							local id_Pt1_trace2 = boucler trace2 (idPt1_communTrace2 + 1)
							local id_Pt2_trace2 = boucler trace2 (idPt1_communTrace2 + 2)
							
							local idPt1_communTrace1 = findItem	trace1  ptsCommuns[1]
							local idPt2_communTrace1 = boucler trace1 ( idPt1_communTrace1 + 1 )
							if trace1[ idPt2_communTrace1 ] != ptsCommuns[2] then (
								local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[2] ) + 1 )
								insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
								insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
								
							) else (
								local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[1] ) + 1 )
								insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
								insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
							)
							
							
							
						) else (
							local id_Pt1_trace2 = boucler trace2 (idPt2_communTrace2 +1)
							local id_Pt2_trace2 = boucler trace2 (idPt2_communTrace2 +2)
-- 								format "		-> - B - on insert a partir de %\n" trace2[ id_Pt1_trace2 ]
							
							local idPt1_communTrace1 = findItem	trace1  ptsCommuns[1]
							local idPt2_communTrace1 = boucler trace1 ( idPt1_communTrace1 + 1 )
							if trace1[ idPt2_communTrace1 ] != ptsCommuns[2] then (
								local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[2] ) + 1 )
								insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
								insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
								
							) else (
								local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[1] ) + 1 )
								insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
								insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
							)
							
							
						)
						
						traces[idTrace1] = ordonner_Points 	trace1
						deleteItem  traces 	idTrace2
						idTrace1 = 1
						
						suivant = true
					)
				)
				if suivant == false do 	
					idTrace1 += 1
				if idTrace1 > traces.count - 1 do 	
					continu = false
				
			) -- fin du while --------
			
			
			traces
			
			
			
		),
	
	public ---TEMP --
		fn chercher_alignements	_pts		_idTest		_seuil		=(
			
			local mtrx_AP 			= get_axePrincipal_mtrx 	_pts
			local pt_test				= _pts[_idTest]		* inverse  mtrx_AP
			local result =#()
		
			for i = 1  to _pts.count do (
				
				local j 				= boucler 	_pts	( i + 1)
				local pt 			= _pts[i]	* inverse  mtrx_AP
				local pt_suivant 	= _pts[j]	* inverse  mtrx_AP
				
				
				if estPignon  _pts	_idTest		 and estPignon  _pts 	i 	 					do 	(
					if abs ( pt_test.x - pt.x ) < _seuil do 
						appendIfUnique result i
					if abs ( pt_test.x - pt_suivant.x ) < _seuil do 
						appendIfUnique result i
				)
				
				if not estPignon  _pts	_idTest		 and not estPignon _pts i  	do (
					if abs ( pt_test.y - pt.y ) < _seuil do
						appendIfUnique result i
					if abs ( pt_test.y - pt_suivant.y ) < _seuil do 
						appendIfUnique result i
				)
				
			)
				
				

			result
		),
		
		
	-----------------  Optimisations ----------------------
	public
		fn orthonormer 		&_pts	_seuil  =(
			debug"orthonormer"
			
			local mtrx_AP	= get_axePrincipal_mtrx 	_pts
			local pts_result 	= deepcopy _pts
			
			local grps_de_points = #()
			
			--- on fait les groupes de point à aligner -----------
			local i = 1
			while i <= _pts.count do (
				
				local pt_courant = _pts[i]
				
				local groupe = #(i)
				
				local pt_courant_estPignon = estPignon	 _pts	  i  
				local onChangeDePoint = true
				local i_aTester = i+ 1
				
				while  onChangeDePoint do (
					if i_aTester >  _pts.count  then i_aTester = 1 
					if estPignon	 _pts	  i_aTester  ==   pt_courant_estPignon
						then (
							append groupe  i_aTester
						) else
							onChangeDePoint = false
						
					i_aTester += 1
				)
				i += groupe.count
				
				
				-- on checked les doublons premier-drenier-------------
				if i > _pts.count and grps_de_points.count > 1 do (
					local present  = false
					for pt_test_id in groupe do (
						if findItem grps_de_points[1]  pt_test_id != 0 do
							present = true
					)
					if present do (
						for pt_tmp_id in grps_de_points[1]  do
							appendIfUnique	 groupe  pt_tmp_id
						deleteItem grps_de_points 1
					)
				)
				
				append grps_de_points  groupe
				
				
			)
			
			for grp in grps_de_points do (
				
				-- on cherche la position moyenne du groupe de points -------
				local position_moyenne = 0
				
				for  i = 1 to grp.count do (
					local idPt  			= grp[i ]
					local pt 				= _pts[idPt]				* inverse  mtrx_AP 
					if   estPignon _pts  idPt  then (
						position_moyenne += ( /* pt_suivant.x -  */pt.x ) /( grp.count + 1 )
					)else (
						position_moyenne += ( /* pt_suivant.y -  */pt.y ) /( grp.count + 1 )
					)
				)
				
				local idPt  			= grp[ grp.count ]
				local idPt_suivant 	= idPt + 1
				if idPt_suivant > _pts.count do idPt_suivant = 1
				local pt_suivant 	= _pts[idPt_suivant]	*  inverse mtrx_AP 
				if   estPignon _pts  idPt  then (
					position_moyenne += ( pt_suivant.x ) /( grp.count + 1 )
				)else (
					position_moyenne += ( pt_suivant.y ) /( grp.count + 1 )
				)
				
				
				-- on bouge les points	-------
				
				for  i = 1 to grp.count do (
					
					local idPt  			= grp[i ]
					local	pt 				= pts_result[idPt]				*	inverse  mtrx_AP  	
					
					if   estPignon _pts  idPt  then (
-- 						pts_result[idPt] 				= ( pt 				+ [position_moyenne - pt.x , 0,0 ] 		* _seuil/100			) *   mtrx_AP 
						pts_result[idPt] 				= ( pt 				) 
						pts_result[idPt].x += ( position_moyenne - pt.x ) 	* _seuil/100		
						
					)else (
-- 						pts_result[idPt] 				= ( pt 				- [0,position_moyenne - pt.y , 0 ] 		* _seuil/100			) *   mtrx_AP 
						pts_result[idPt] 				= ( pt 				) 
						pts_result[idPt].y += ( position_moyenne - pt.y ) 	* _seuil/100		
					)
					pts_result[idPt] *= mtrx_AP
				)
				local idPt  			= grp[ grp.count ]
				local idPt_suivant = idPt + 1
				if idPt_suivant > _pts.count do idPt_suivant = 1
				local	pt_suivant 				= pts_result[idPt_suivant]				*	inverse  mtrx_AP  	
				pts_result[idPt_suivant] 	= ( pt_suivant ) 
				if   estPignon _pts  idPt  then (
						pts_result[idPt_suivant].x += ( position_moyenne - pt_suivant.x ) 	* _seuil/100		
				)else(
						pts_result[idPt_suivant].y += ( position_moyenne - pt_suivant.y ) 	* _seuil/100		
				)
				pts_result[idPt_suivant] *= mtrx_AP
				
			)
			
			_pts = pts_result
			
		),
		fn souder 				&_pts	_seuil  =(
			debug "souder"
			debug "_pts" var:_pts
			
			local i = 1
			while i <=_pts.count do (
				
					debug "i" var:i
				local j= i+1
				if j > _pts.count  do j =1
					
				local pt 			= _pts[i]
				local ptSuivant 	= _pts[j]
				if distance pt ptSuivant <= _seuil do (
					debug "		SOUDURE"
					deleteitem _pts j
					_pts[i] = ( pt + ptSuivant ) / 2
					i = 1
				debug "		_pts" var:_pts
				)
				i+=1
			)
			
		),
		fn aplanir 				&_pts	_seuil  =(
			debug "aplanir"
			
			local i = 1
			while i <= _pts.count do (
				
				local h = i - 1
				if h < 1  do h = _pts.count
				local j= i+1
				if j > _pts.count  do j =1
				local ptDAvant 	= _pts[h]
				local pt 			= _pts[i]
				local ptSuivant 	= _pts[j]
				
				local vec1 = normalize (ptDAvant - pt)
				local vec2 = normalize (ptSuivant - pt)
				
				local anglePt = acos(dot vec1 vec2)			
				if 	anglePt >= 180 - _seuil  then (
					deleteitem _pts i
					i = 0
				)
				dot
				i +=1
			)

			result
		),
		fn aligner				&_pts	_seuil  =(	
			debug "aligner"
			
			local mtrx_AP 	= get_axePrincipal_mtrx 	_pts
			local pts_result = deepcopy _pts
			for i = 1 to   _pts.count  do (
				
				local aligns = 	chercher_alignements	_pts	i		_seuil	
				
				local pt_moyenne = [0,0,0]
				for id_align in aligns do 
					pt_moyenne += _pts[id_align]	* inverse  mtrx_AP
				pt_moyenne /=  aligns.count
				
				for id_align in aligns  do (
					
					local j 						= boucler _pts (  id_align + 1 )
					local pt 					= _pts[id_align]	* inverse  mtrx_AP  
					local pt_suivant 			= _pts[j]	* inverse  mtrx_AP
					
					local vec_moyenne1 	= pt_moyenne	 - pt
					local vec_moyenne2 	= pt_moyenne	 - pt_suivant
					local vec_align1, vec_align2
					if not estPignon  _pts	id_align		 then (
						vec_align1 			= [0,vec_moyenne1.y,0] 
						vec_align2 			= [0,vec_moyenne2.y,0] 						
					) else (
						vec_align1 			= [vec_moyenne1.x,0,0] 
						vec_align2 			= [vec_moyenne2.x,0,0] 
					)
					
					pt 							= _pts[id_align]	* inverse  mtrx_AP  	+ vec_align1 
					pt_suivant 					= _pts[j]			* inverse  mtrx_AP  	+ vec_align2
					
					pts_result[id_align] 	= pt *   mtrx_AP 
					pts_result[j] 			= pt_suivant *   mtrx_AP 
					
				)
			)
			_pts = pts_result
		),
		fn projeter		 		&_pts 	=(
			
			debug"projeter"
			local mtrx_AP 	= get_axePrincipal_mtrx 	_pts
			local seuil = 5
			local result
			local trace 		= _pts
			local trace_temp =  for item in trace collect item
			
			local est_subdivise_total = false
			while not est_subdivise_total do (
				
				local est_subdivise = false
				local est_trouve = false
				
				local i = 1
				while i <=  trace_temp.count and not est_trouve do (
					
					local id_direction_suiv		=  boucler trace_temp  (i+1)
					local id_direction_prec		= 	boucler trace_temp  (i-1)
					
					local pt_orig		= 	trace_temp[ i ]	* 	inverse  	mtrx_AP  
					local pt_suiv		=	trace_temp[ id_direction_suiv  ]  * 	inverse  	mtrx_AP
					local pt_prec		= 	trace_temp[ id_direction_prec  ] * 	inverse  	mtrx_AP
					
					---- les segments a tester------------
					local compteur_segment = 0
					while compteur_segment <  trace_temp.count  - 2 and not est_trouve do (
						
						--- le segment -----
						local id_seg_1 	= boucler trace_temp  ( i + compteur_segment + 1 )
						local id_seg_2 	= boucler trace_temp  ( i + compteur_segment + 2	)
						
						local pt_seg_1	= trace_temp[ id_seg_1 ]	* 	inverse  	mtrx_AP
						local pt_seg_2	= trace_temp[ id_seg_2 ] 	* 	inverse  	mtrx_AP 
						
						--- la projection 1 -------
						local pt_proj = intersection 	pt_orig		pt_suiv		pt_seg_1	 	pt_seg_2		
						
						if pt_proj != undefined  do (	
							
							if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do (
								if not pt_est_dejaPresent   trace_temp  	( pt_proj	* 	mtrx_AP )	 do ( 
									local id_place = trouver_pt	 trace_temp  ( pt_seg_1 * 	mtrx_AP )
									insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
									est_subdivise = est_trouve = true
								)
							)
						)
						
						--- la projection 2 -------
						local pt_proj = intersection 	pt_orig		pt_prec		pt_seg_1	 	pt_seg_2	
						
						if pt_proj != undefined  do (	
							
							if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do (
								if not pt_est_dejaPresent   trace_temp  	( pt_proj	* 	mtrx_AP )	 do ( 
									local id_place = trouver_pt	 trace_temp  ( pt_seg_1 * 	mtrx_AP )
									insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
									est_subdivise = est_trouve = true
								)
							)
						)
						
						compteur_segment +=  1
					) -- fin while compteur_segment
					
					i += 1
					
				) -- fin while i  --
				
				if not est_subdivise do est_subdivise_total = true
				
			) -- fin while not est_subdivise_total
			
			_pts = trace_temp
			
		),
		
		
		------Subdivision ----------------------------------------------------------
		fn scanner_points 	_shape	=(
			
			local ptsSurface				=#()
			
			---- On chope les points de la surface a scanner -----------
			for id_pt = 1 to ( numKnots 	_shape 	1 ) do	(
				local pt_shape 	= getKnotPoint 	_shape 	1 	id_pt
				local pt_surface 	= pt_shape * inverse  _shape.transform
				append ptsSurface 	 pt_surface
			)
			
			
			--- on fait tourner les spline dans le meme sens ----
			if not est_sensPositif 	ptsSurface 	 do
				trace_absolu = changer_sens		ptsSurface
			
			ptsSurface
			
		),
		fn subdiviser		 	_pts 		=(
			debug "subdiviser"
			
			--- on  les points projetés au tracé --------
			projeter		_pts
			
			local result = #()
			local result_reste =#()
			
			m_rectangles_traces 		= #()
			
			local seuil 					= 1
			local mtrx_AP 			= get_axePrincipal_mtrx 	_pts
			local trace 				= _pts
			
			for i = 1 to  trace.count 	do (
				
				local pt_orig			= 	trace[ i ]	* 	inverse  	mtrx_AP 
				local id_pt_preced 	= boucler 	trace	( i - 1)
				local pt_preced 		= trace[ id_pt_preced ] * 	inverse  	mtrx_AP	
				local vec_pt 			= pt_orig - pt_preced		
				local id_pt_1, id_pt_2, id_pt_3, id_pt_4
				
				id_pt_1	= chercher_pt_a90degGauche	i 	vec_pt	 
				
				if id_pt_1 != undefined then (
					local norm 		= vec_pt * (rotateY	(matrix3 1)	90 )
					id_pt_2				= chercher_pt_a90degGauche	id_pt_1 	norm		 
				)  				
				if id_pt_2 != undefined then (
					local norm	 	= vec_pt * (rotateY	(matrix3 1)	180 )
					id_pt_3 				= chercher_pt_a90degGauche	id_pt_2 	norm	 
				)  				
				if id_pt_3 != undefined then (
					local norm	 	= vec_pt * (rotateY	(matrix3 1)	270 )
					id_pt_4 				= chercher_pt_a90degGauche	id_pt_3 	norm	 
				)  
				
				---- si on a les quatre points -------
				if id_pt_4 == i do (
					
					local pt_rect_1 = trace[ id_pt_1 ]	* 	inverse  	mtrx_AP 
					local pt_rect_2 = trace[ id_pt_2 ]	* 	inverse  	mtrx_AP 
					local pt_rect_3 = trace[ id_pt_3 ]	* 	inverse  	mtrx_AP 
					
					local surf = ( distance pt_orig pt_rect_1 ) * ( distance pt_orig pt_rect_3 )  / 10000
					
					local rect =  #( i, id_pt_1, id_pt_2, id_pt_3 )
					
					local rect_ordo = ordonner_Points 	rect
					append m_rectangles_traces 		rect_ordo
					virerDoublonsDansTableau 	m_rectangles_traces
					
				)
			) -- fin while i  --
			
			
		),
		fn decouper 		 	_pts 		=(
			debug "decouper"
			
			
			--  points concaves -----------------
			
			
			local result = #()
			local result_reste =#()
			
			
			
			local seuil 				= 1
			local mtrx_AP 			= get_axePrincipal_mtrx 	_pts
			local trace 				= _pts
			local trace_restant 	= for i = 1 to trace.count collect i
			
			--- creer la face tracé pour tester intersection 	------------
			
			for sstrace in   m_rectangles_traces 	do (
				
				local estValide = true
				
				local pt_rect_1 = trace[ sstrace[ 1 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_2 = trace[ sstrace[ 2 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_3 = trace[ sstrace[ 3 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_4 = trace[ sstrace[ 4 ] ]	* 	inverse  	mtrx_AP 
				
				local surf = ( distance pt_rect_2 	pt_rect_1 ) * ( distance pt_rect_1 pt_rect_4 )  / 10000
				
				
				if m_plug.sousTraces_surf_min_use do
					if surf < m_plug.sousTraces_surf_min do estValide = false
				if m_plug.sousTraces_surf_max_use do
					if surf > m_plug.sousTraces_surf_max do estValide = false
									
				if estValide then (
					local nvTrace = str_ssTrace 		trace:sstrace		etages:m_plug.sousTraces_etages
					appendIfUnique result  nvTrace
					
				) else (
					
					append result_reste 		sstrace
					virerDoublonsDansTableau 		result_reste
					
				)
			
			) -- fin while i  --
			
			result_reste = unir  result_reste
			
			if result_reste.count >0 do (
				for traceResultRest in result_reste do (
					local nvTrace = str_ssTrace 	trace:traceResultRest	etages:m_plug.niveaux_nbre
					append  result  nvTrace
				)
			)
			
			
			m_sousTraces = result
			
		),
		
		
		
		
		---- BACK		TRIANGULATION 		BACK  ----------------
		--- renvois le tableau des triangles créés -------
		i_debug = 0,
		fn trianguler  _pts 	return_ptsIDs:false 	=(
			
-- 			debug "-------------------- TRIANGULER SHP -----------------------------------------------"
			local pts_poly 			= deepcopy _pts
			
			local result_triangles	= #()
			
			--------------- tant qu'il reste plus de trois point dans le polygone -------------------------------------------------------------------------------------------------------------------------			
			while pts_poly.count >= 3 do (
				
				
-- 				debug" trianguler" var:(i_debug += 1)
				
				
				-- on commence avec le point le plus a gauche du polygone--
				local id_pt_aTester 	= point_lePlusAGauche  pts_poly		
				
-- 				pt_orig_triangle = point pos:pts_poly[id_pt_aTester]	name:( uniqueName "pt_orig_triangle " ) centermarker:off axistripod:off cross:on Box:off size:5 constantscreensize:off drawontop:off
				
				-- le point d'avant ---
				local id_pt_avant 	= if id_pt_aTester == 1 	then	pts_poly.count 
																				else	id_pt_aTester - 1		
				-- et le point d'aprés ---
				local id_pt_apres 	= if id_pt_aTester == pts_poly.count 	then	1
																									else	id_pt_aTester + 1
				--- Le triangle à tester ---
				local triangle_aTester = #(pts_poly[id_pt_avant], pts_poly[id_pt_aTester], pts_poly[id_pt_apres])
				
				
-- 				debug "triangle_aTester" var:triangle_aTester
				
				----- Puis on cherche parmis les points restants du polygone ceux qui seraient à l'interieur du trangle ------------------------------------------------------------------------------		
				local ids_pts_dansTriangle =#()
				
-- 				debug "----------------------> dansTriangle ?" 
				for i = 1 to pts_poly.count do (
-- 					debug "		----------------------> id " var:i
					local pt_atester 				= pts_poly[i]
-- 					debug "		----------------------> pt_atester " var:pt_atester
					local pt_est_dansTriangle 		= est_dansTriangle 	triangle_aTester[1]	 triangle_aTester[2]	 triangle_aTester[3]	  pt_atester
-- 					debug "		----------------------> pt_est_dansTriangle " var:pt_est_dansTriangle
					
					if pt_est_dansTriangle do append ids_pts_dansTriangle  i
				)
				
-- 				debug "--------> ids_pts_dansTriangle" var:ids_pts_dansTriangle
				
				
				
				------- soit on trouve des points dans le triangle		---->	 on doit découper en 2 polygones		------------------------------------------------------------------------------
				if ids_pts_dansTriangle.count > 0 then (
					
-- 					debug "-----> 	DECOUPAGE	->		de " var:pts_poly
					
					local pts_dansTriangle	=	for id_pt in ids_pts_dansTriangle collect pts_poly[id_pt]
					
					---- si on en trouve : on cherche le plus éloigné de la 'diagonale' du triangle ----
					local IDs_pts_diagonal 	= 	points_lesPlusLoinDuSegment  	pts_dansTriangle		triangle_aTester[3]		triangle_aTester[1]
					
-- 					debug "-----> 	pts_dansTriangle : " var:pts_dansTriangle
-- 					debug "-----> 	IDs_pts_diagonal : " var:IDs_pts_diagonal
					
					
					--- on gere si on a plusieurs points pour la diagonal --------------------
					local IDpt_decoupe 
					if IDs_pts_diagonal.count > 1 then (
						debug "Choisir un pt diagonal " 
						debug "	-> id_pt_aTester" var:id_pt_aTester
						local dist_id_min = 1e+10
						for id_pt in IDs_pts_diagonal do (
							local id_diag 		= ids_pts_dansTriangle[id_pt]
							debug "	-> id_diag" var:id_diag
-- 							local dist_test = abs ( id_pt_aTester - id_diag )
							/* if id_diag < id_pt_aTester then (
								dist_test = id_pt_aTester - 
								id_diag = id_diag + pts_poly.count
								
							)		 */					
							
-- 							debug "	-> id_diag" var:id_diag
							
-- 							local dist_to_id = abs (id_diag - id_pt_aTester )
							local dist_to_id 			=  abs (id_diag - id_pt_aTester )
							local dist_to_id_inv 		= abs (( pts_poly.count - id_pt_aTester ) -  id_diag )
							
-- 							debug "	-> dist_to_id" var:dist_to_id
-- 							debug "	-> dist_to_id_inv" var:dist_to_id
							if dist_to_id_inv < dist_to_id do dist_to_id = dist_to_id_inv
								
-- 							debug "	--------------> dist_to_id" var:dist_to_id
							if dist_to_id <= dist_id_min do (
								
								
								
								
								IDpt_decoupe 	= id_diag
								dist_id_min 	= dist_to_id
							)
								
						)
						debug "	----------------------------------------> IDPT_DECOUPE" var:IDpt_decoupe
					) else					
						IDpt_decoupe 		= 	ids_pts_dansTriangle[ IDs_pts_diagonal[1] ]
					
					
					
					
					-- on decoupe le polygone en 2 avec la digonale entre ce dernier point et le point à tester --
					--- premier polygone découpé -------
					local IDsPts_poly1  = #(IDpt_decoupe)
					local pts_poly1  = #()
					local  i = boucler  pts_poly  (id_pt_aTester ) 
					while i 	!= IDpt_decoupe  do (
						append IDsPts_poly1		 i 
						i = boucler 	pts_poly		(i+1) 	
					)				
					pts_poly1 = for idPt in IDsPts_poly1 collect pts_poly[idPt]
					--- second polygone découpé -------
					local IDsPts_poly2  = #(id_pt_aTester)
					local pts_poly2  = #()
					local  i = boucler  pts_poly  (IDpt_decoupe ) 
					while i 	!= id_pt_aTester   do (
						append IDsPts_poly2		 i 
						i = boucler 	pts_poly		(i+1) 	
					)				
					pts_poly2 = for idPt in IDsPts_poly2 collect pts_poly[idPt]

-- 					debug"pts_poly1" var:pts_poly1
-- 					debug"pts_poly2" var:pts_poly2
					
					result_triangles += trianguler  pts_poly1	return_ptsIDs:return_ptsIDs
					result_triangles += trianguler  pts_poly2	return_ptsIDs:return_ptsIDs
					
					if false and m_debug do (
						sp = splineShape name:( "tri - decoupage poly " + i_debug as string + " - 1")
						addnewSpline sp
						for pt in pts_poly1 do		addknot sp 1 #corner #curve  pt
						close sp 1
						updateShape sp
						sp = splineShape name:( "tri - decoupage poly " + i_debug as string + " - 2")
						addnewSpline sp
						for pt in pts_poly2 do		addknot sp 1 #corner #curve  pt
						close sp 1
						updateShape sp
	-- 						selectMore sp
						  
					)
					
					
					
					
					-- on vide les points de poly car on a lancé la fonction recursivement sur les deux poly trouvés, et on veut sortir de la boucle----
					pts_poly = #()
					
				------- soit on a pas de points dans le triangle, 		---->	donc on peut le treer tranquile 		------------------------------------------------------------------------------
				) else (
					
-- 					debug "-----> 	TRIANGLE	->		" 
					
					
					---- si on en trouve pas: 	on peut creer le triangle et retirer le point tester de la liste du polygone ----
					--- soit on renvois les ids des points ----
					if return_ptsIDs then 	(
						local id_pt_1 = findItem _pts 	triangle_aTester[1]
						local id_pt_2 = findItem _pts 	triangle_aTester[2]
						local id_pt_3 = findItem _pts 	triangle_aTester[3]
						append 	result_triangles  	[ id_pt_1, id_pt_2, id_pt_3 ]
					--- soit on renvois les coordonnées des points ----
					) else	append 	result_triangles  	triangle_aTester
					
					deleteItem pts_poly  id_pt_aTester
					
					
					
					
					
					/* 
					
					if false and m_debug do (
						sp = splineShape name:( "triangle " + i_debug as string )
						addnewSpline sp

						for pt in triangle_aTester do		addknot sp 1 #corner #curve  pt
						close sp 1
						updateShape sp
					)  */
				)
				
			)  --- fin du while il ya plus de 3 pts dans le polygone ------
-- 			debug "result_triangles" var:result_triangles
			result_triangles
			
		) --- fin fonction decoupage polygone ----------

	
)
