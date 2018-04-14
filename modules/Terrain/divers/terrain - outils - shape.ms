
include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - mgr - Datas to string.ms" 

struct str_terrain_outils_shape (
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	public
		m_debug	=	true,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | shape"	  	var:var	 param:param		catch (),
	
		m_tab_format_nd = "		",		
		fn format_noeud 	_nd =(
			local indent_prfix = "|    "
			debug (  m_tab_format_nd + _nd.nom + "" )
			if _nd.enfants.count >0 	do	m_tab_format_nd += indent_prfix
			for enft in _nd.enfants 	do 	format_noeud enft
			if _nd.enfants.count >0 	do	m_tab_format_nd = substring m_tab_format_nd 1 (	m_tab_format_nd.count -	indent_prfix.count )
		),
		fn	debug_nd  _nd = if m_debug do (			 
			
			debug "----------------------------------------------------"
			format_noeud 	_nd 
			debug "----------------------------------------------------"
		),
		
		
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		
		
		--- constantes---------
		PRECISION_COURBE 			= 50,			--- en cm. ----
		SEUIL_POINTS_EGAUX  	= .01,
		-- constante pr debug-----------------
		SAUVETAGE_MAX 			= 100,
		
-- 	private
	public --- DEBUG en est en private normalement ----
		
		fn sont_egaux_tableaux 	first 	second =
		(
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
		
		----------------- tableaux -----------------
		fn boucler 							_array				_id_item 		=(
			
			if _id_item >	_array.count do _id_item = mod _id_item _array.count
			if _id_item < 1 do _id_item += _array.count
			_id_item as integer
		),
	
	
	
		--- Analyse position de points (survol_triangles etc..)		-------------
		fn est_aGauche		_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
			sens
			
		),
		fn est_dansTriangle		_pt_tri_1	_pt_tri_2	_pt_tri_3	_pt_aTester =(
			if est_aGauche  _pt_tri_1 	_pt_tri_2 	_pt_aTester and est_aGauche  _pt_tri_2 	_pt_tri_3 	_pt_aTester  and est_aGauche  _pt_tri_3 	_pt_tri_1 	_pt_aTester then (
-- 				if _pt_aTester == _pt_tri_1 or _pt_aTester == _pt_tri_2 or _pt_aTester == _pt_tri_3 then
-- 					false
-- 				else
					true
			) else false
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
			
			local tab_longueurs_sgts		=	getSegLengths 	_shp 	_id_spline	 cum:false byVertex:true numArcSteps:100
			local nbr_pts_total 				=	numknots	 		_shp	_id_spline
			local longueur_result			= 	tab_longueurs_sgts[ nbr_pts_total + 2 + _id_pt]
			
			longueur_result
			
		),
		fn	get_angleVecteurs v1 v2 =(
-- 			debug "get_angleVecteurs"
-- 			debug "dot (normalize v1) (normalize v2)" var:(dot (normalize v1) (normalize v2))
			local result_angle
-- 			if abs (dot (normalize v1) (normalize v2)) == 0 then 
-- 				result_angle = 0
-- 			else
				result_angle = acos(dot (normalize v1) (normalize v2))
-- 			format "angle entre vec :%\n" result_angle
			result_angle
		),
		fn get_distance_point_segment		_pt		_seg_pt1	_seg_pt2 =(
-- 			debug "			--->	get_distance_point_segment " var:#( _pt	,	_seg_pt1,	_seg_pt2 )
			
			local pt 			= _pt
			local vec_1 		= (_seg_pt2  -  _seg_pt1)
			local vec_2 		=  ( _pt  -  _seg_pt1)
			
			local angle_test 	= get_angleVecteurs    vec_1 vec_2
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
				
				local angle_test 	= get_angleVecteurs    vec_1 vec_2
				
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
		
		
		
		--- sens du shape ----------------------
		fn est_sensPositif 					_pts 		=(
-- 			debug "est_sensPositif"
			local result 				= true
			local id_pointHaut 	=  point_lePlusHautSurY  	_pts
			
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
			
-- 			debug "est_sensPositif" var:result
			
			result
			
		),
		fn changer_sens 					_pts 		=(
			debug "changer_sens"
			local result =#()
			for i= _pts.count to 1 by -1 do 
				append result 	_pts[i]
			result
		),
		fn BBs_seCroisent		_shp_1  	_shp_2	 =(
			local result = true
			if _shp_1.count > 0 do 	(
				local BB_1 = get_BB_shape	_shp_1
				local BB_2 = get_BB_shape	_shp_2
				
				if BB_1[1].x > BB_2[2].x  			then result = false
				else if BB_1[2].x < BB_2[1].x  	then result = false
				else if BB_1[1].y > BB_2[2].y  	then result = false
				else if BB_1[2].y < BB_2[1].y  	do result = false
			)
			result
		),
		------- renvois la position d'un shape par rapport à un autre: si un shapes est ' l'interieur d'un autre (trou boolean), se croisent ou à l'exterieur ---------
		fn get_positionRelative_shapes 		_pts_shp1		_pts_shp_aTester 	=(
			
-- 			debug "get_positionRelative_shapes"
			
			struct	str_intersection	(
				pos,
				id_pt_1 =0,
				id_pt_2 =0				
			)
			
			
			local result = #aCoté		---- #exterieur,  #interieur, #seCroisent, ou	 #aCoté	 --------------
			local intersections =#()
			
			if  BBs_seCroisent 	_pts_shp1 		_pts_shp_aTester do (
			
				---- on regadre si les edges se coupent --- si oui --->  #seCroisent -----------------
				local se_coupent = false
				local  i = 1
				while i <= _pts_shp1.count and not se_coupent do (
					
					local pt_shp1			= _pts_shp1[ i ]
					local i_svt	=	if i == _pts_shp1.count  then 1 else i + 1
					local pt_shp1_svt	= _pts_shp1[ i_svt ]
					
					local  j = 1
					while j <= _pts_shp_aTester.count and not se_coupent do (
						
						local pt_shp2			= _pts_shp_aTester[ j ]
						local j_svt	=	if j == _pts_shp_aTester.count  then 1 else j + 1
						local pt_shp2_svt	= _pts_shp_aTester[ j_svt ]
						
						local intersection = get_intersection_vecteurs		pt_shp1   pt_shp1_svt		pt_shp2		pt_shp2_svt 
						if intersection != undefined do (
							append intersections ( str_intersection pos:intersection		id_pt_1:i 	id_pt_2:j 	)
							se_coupent = true
						)
						j+= 1
					)
					i+= 1
				)
				
				---- si on a des intersections, alors ils se croisent ------------------------------------
				if intersections.count > 0 then
					result = #seCroisent				
				else (
					---- s'il ne se croisent pas alors ils sont tout à l'interieur ou à l'extierieur l'un de l'autre -------------------------
					local pts_triangles_shp1 = this.trianguler	_pts_shp1
 					local pts_triangles_shp2 = this.trianguler	_pts_shp_aTester
					
					if survol_triangles  	_pts_shp_aTester[1]	pts_triangles_shp1	 then 
						result = #interieur
					else  if survol_triangles  	_pts_shp1[1]		pts_triangles_shp2	 then 
						result = #exterieur
						
				)
				
			)
			
			result
		),
		
		fn shape_estDans_shape		_shp_1  shp_test =(
			if _shp_1.count == 0 then 			
				true
			else 	if not BBs_seCroisent	_shp_1	shp_test then
				false	
			else if get_positionRelative_shapes  _shp_1	shp_test  == #interieur then 
				true
			else 
				false
		),
		fn point_est_dansShape		_pt		_pts_shp 	=(		
			local triangles	=	this.trianguler 	_pts_shp
			
			survol_triangles  	_pt		triangles			
		), 
		
		
		
		
		
		
		
		fn get_idsPts_connexion   	_pts_shp1		_pts_shp2 	=(
			
			local results = #()
			
			--- on cherche les points des shpes les plus proches pour les connecter --------------
			
			local dist_min					= 1e+10			
			for id_pt1 = 1 to  _pts_shp1.count do (
				local pt1	=	_pts_shp1[ id_pt1 ]
				for id_pt2 = 1 to  _pts_shp2.count do (
					local pt2			=	_pts_shp2[ id_pt2 ]
					local dist_test	=	distance	pt1 pt2
					if dist_test < dist_min then (
						
						local id_pt2_svt	=	if id_pt2 == _pts_shp2.count  then 1 else id_pt2 + 1
						local pt_2_svt 		= _pts_shp2[ id_pt2_svt ]
						---- si plus proche --------------
						dist_min = dist_test
						results = #()
						append results 	#( id_pt1 , id_pt2 )
					) else
					if abs ( dist_test - dist_min )  == 0   then (
						append results 	#( id_pt1 , id_pt2 )
					)
					
				)
				
			)
			results
		),
		
		
		
		------------------ 	Booleen  ---->   geometrie 	-----------------------------------
		fn ajouter_shape_aBooleen			_pts_shp_booleen		_pts_shp_aAjouter	 =(
			
-- 			debug "ajouter_shape_aBooleen"
			
			local chrono_temp = timeStamp ()
			--- on cherche les points des shpes les plus proches pour les connecter --------------
			local connexions	=	get_idsPts_connexion   	_pts_shp_booleen		_pts_shp_aAjouter 
			
			
			
			
-- 			debug"connexions" var:connexions
			local connexion = connexions[1]
			--- si on a plusieurs connexions ------------------
			if connexions.count > 1 then (
				
				local id_pt_origine 	= connexions[1][2]
				local pt_origine 		= _pts_shp_aAjouter[id_pt_origine]
				
				local angle_min 			= 1e+10
				while connexions.count > 1 do (
					
					---- si on a des connexion vers le meme point ------------------
					if id_pt_origine == connexions[2][2] then (
						
						local	id_pt_cnx1			= connexions[1][1]
						local id_pt_cnx1_svt	=	if id_pt_cnx1 == _pts_shp_booleen.count  then 1 else id_pt_cnx1 + 1
						local id_pt_cnx1_prcd	=	if id_pt_cnx1 == 1  then _pts_shp_booleen.count else id_pt_cnx1 - 1
						
						local pt_cnx1 			= _pts_shp_booleen[id_pt_cnx1]
						local pt_cnx1_svt	= _pts_shp_booleen[id_pt_cnx1_svt]
						local pt_cnx1_prcd	= _pts_shp_booleen[id_pt_cnx1_prcd]
						
						if pt_cnx1_svt == pt_cnx2_prcd then (
							local pt_est_aGauche 	= est_aGauche		pt_cnx1		pt_cnx1_svt		pt_origine	
							if pt_est_aGauche then 
								connexion = deepcopy  connexions[1]
							else 
								connexion = deepcopy  connexions[2]
						) else (
							local pt_est_aGauche 	= est_aGauche		pt_cnx1_prcd		pt_cnx1		pt_origine
							if pt_est_aGauche then 
								connexion = deepcopy  connexions[1]
							else 
								connexion = deepcopy  connexions[2]
						)
					) 
					deleteItem connexions 1
				)
			)   
			
			local id_pt_connexion_1 =	connexion[1]
			local id_pt_connexion_2 =	connexion[2]
			
			
-- 			debug  ("	TIME:	on cherche les points des shpes les plus proches pour les connecter : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
-- 			local chrono_temp = timeStamp ()
			
			---- les premier shape -----------
			local pts_result = #()
			if id_pt_connexion_1 != 0 do (
				pts_result = #( _pts_shp_booleen[ id_pt_connexion_1 ] )
				for i_compteur = 1 to  _pts_shp_booleen.count do (
					local id_pt = i_compteur + id_pt_connexion_1 
					if id_pt > _pts_shp_booleen.count do 
						id_pt -= _pts_shp_booleen.count 
					local pt = _pts_shp_booleen[id_pt]
					append pts_result	pt
				)
			)
			
-- 			debug  ("	TIME:	les premier shape : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
-- 			local chrono_temp = timeStamp ()
			
			---- les second shape, on l'ajoute a l'envers  -----------
			for i_compteur =  _pts_shp_aAjouter.count to 1 by -1 do (
				local id_pt = i_compteur + id_pt_connexion_2 
				if id_pt > _pts_shp_aAjouter.count do 
					id_pt -= _pts_shp_aAjouter.count 
				local pt = _pts_shp_aAjouter[id_pt]
				append pts_result	pt
			)
			if id_pt_connexion_2 != 0 do
				append 	pts_result	( _pts_shp_aAjouter[ id_pt_connexion_2 ] )
			
-- 			debug  ("	TIME:	les second shape, on l'ajoute a l'envers : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
			
			pts_result
			
		),
		fn creer_pts_pourFace			_noeud			=(
			
-- 			local chrono_temp = timeStamp ()
			
			local pts_result 	=	#()
			local pts_noeud 	=	_noeud.get_pts	()
			
			---- Version on prend les enfants 1 par 1 le plus pret ----------------------
			local enfants_a_traiter	 = for nd in  _noeud.enfants collect nd
			while enfants_a_traiter.count > 0 do (
				
				local shps_enfants_a_traiter	=	for enfant in enfants_a_traiter collect ( enfant.get_pts() )
				
				local infos_enfant_proche		=	get_shape_lePlusProche	pts_noeud		shps_enfants_a_traiter
				local enfant_proche				=	 enfants_a_traiter[ infos_enfant_proche.id_shp ]
				
				pts_noeud = ajouter_shape_aBooleen  	pts_noeud		( enfant_proche.get_pts() )
				
				for petitEnfant in enfant_proche.enfants do
					pts_result += creer_pts_pourFace  petitEnfant
				
				deleteItem enfants_a_traiter  infos_enfant_proche.id_shp
				
			) 
			
			/* 
			
			---- Version on prend les enfants 1 par 1 le plus pret ----------------------
			local enfants_a_traiter	 = for i = 1 to  _noeud.enfants.count collect _noeud.enfants[i]
			while enfants_a_traiter.count > 0 do (
				
				local shps_enfants_a_traiter	=	for enfant in enfants_a_traiter collect ( enfant.get_pts() )
				
				local enfant_aTraiter
				local id_aTraiter = infos_enfant_proche.id_shp
				if pts_noeud.count > 0 then (
					local infos_enfant_proche		=	get_shape_lePlusProche	pts_noeud		shps_enfants_a_traiter
					enfant_aTraiter				=	 enfants_a_traiter[ id_aTraiter ]
					
				) else (
					id_aTraiter = 1
					enfant_aTraiter = enfants_a_traiter[ id_aTraiter ]
					
				)
				pts_noeud 							= ajouter_shape_aBooleen  	pts_noeud		( enfant_aTraiter.get_pts() )
				
				for petitEnfant in enfant_aTraiter.enfants do
					pts_result += creer_pts_pourFace  petitEnfant
				
				deleteItem enfants_a_traiter  id_aTraiter
			 */
			/* ---- Version on prend les enfants 1 par 1 a la suite ----------------------
			for enfant in _noeud.enfants do (
				pts_noeud = ajouter_shape_aBooleen  		pts_noeud		( enfant.get_pts() )
				for petitEnfant in enfant.enfants do
					pts_result += creer_pts_pourFace  petitEnfant
			)
			*/
			
			
			
			append pts_result 	pts_noeud
-- 			debug  ("	TIME:	creer_pts_pourFace : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
			pts_result
		),
		fn get_pts_from_hierachie		_noeud_root	=(
			
			local pts_result =#()
			
			for enfant in _noeud_root.enfants do 
				pts_result += creer_pts_pourFace  enfant
			
			pts_result
			
		),
		
		
		
		
		
		------------------ OPERATIONS BOOLEENNES ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		---- membres operations booleennes--------------
		m_nds_bases			,
		m_nds_operateurs	,
		m_intersections		,
		
		---- fonction secondaires operations booleennes--------------
		fn est_nd_deBase	_nd_aTester	=(
			findItem	m_nds_bases		_nd_aTester != 0
		),
		
		/* 
		fn sont_noeuds_egaux		_nd_1		_nd_2 =(
			format "\n\n"
				debug " --------------------------sont_noeuds_egaux -------------------------------------------"
				debug " ---------	_nd_1" var:_nd_1
				debug " ---------	_nd_2" var:_nd_2
			
			local result = true
			if _nd_1 == undefined and _nd_2 == undefined then  (
				debug " DIFFERENCE #1"
				result = true
			) else if _nd_1 == undefined then   (
				debug " DIFFERENCE #2"
				result = false
			) 	else if _nd_2 == undefined then   (
				debug " DIFFERENCE #3"
				result = false
			) else if _nd_1.nom == _nd_1.nom then   (
				debug " DIFFERENCE #4"
				result = false
			) else if _nd_1.en_creux == _nd_1.en_creux then   (
				debug " DIFFERENCE #5"
				result = false
			) else if not sont_egaux_tableaux ( _nd_1.get_pts () ) ( _nd_2.get_pts () ) then   (
				debug " DIFFERENCE #6"
				result = false
			) else if not sont_noeuds_egaux		_nd_1.parent	_nd_2.parent then   (
				debug " DIFFERENCE #7"
				result = false
			)  else if _nd_1.enfants.count != _nd_2.enfants.count then   (
				debug " DIFFERENCE #8"
				result = false
			) else for i = 1 to _nd_1.enfants.count do
				if not sont_noeuds_egaux		_nd_1.enfants[1]	_nd_2.enfants[1] do   (
				debug ( " DIFFERENCE #9-" + i as string )
					result = false
				)
			result
		),
		 */
		
		
		
		fn get_intersections		_nd =(
			
			local result 			= #()
			local est_uneBase		=	est_nd_deBase		_nd
			
			case est_uneBase of (
				true:		result		=	for inter in m_intersections where  inter.nd_base 			==  _nd   collect  inter
				false:	result		=	for inter in m_intersections where inter.nd_operateur 	== _nd 	collect inter
			)
			
			
			----------	on les classe ?	-----
			fn compare_ordre_bases	 nd1 nd2 =			(
				case of				(
					(nd1.id_base < nd2.id_base): 	-1
					(nd1.id_base > nd2.id_base): 	1
					default: 0
				)
			)
			fn compare_ordre_ope	 nd1 nd2 =			(
				case of				(
					(nd1.id_operateur < nd2.id_operateur): 	-1
					(nd1.id_operateur > nd2.id_operateur): 	1
					default: 0
				)
			)
			
			
			if est_uneBase then
				qsort result		 compare_ordre_bases
			else
				qsort result		 compare_ordre_ope
			
			result
		),
		/* 
		fn get_pts_jusquA_prochaine_intersection 	_nd_courant		_inter_courante		=(
			
			local shp_courant 	= _nd_courant.get_pts ()
			local est_uneBase		=	est_nd_deBase	_nd_courant
			local id_debut			=	if est_uneBase then	_inter_courante.id_base	else	_inter_courante.id_operateur
			local intersections_avec_nd	=	get_intersections		_nd_courant
			
			debug "-----> intersections_avec_nd" var:intersections_avec_nd
			
			---- on cherche la prochaine intersection	-------
			local i = 1
			local trouve = false
			local id_pt_next_intersc = 0
			while i <= intersections_avec_nd.count and not trouve do (
				local inter_avec_nd = intersections_avec_nd[ i ]
				if est_uneBase then 
					if inter_avec_nd.id_base > id_debut do (
						id_pt_next_intersc = i
						trouve = true
					)
				i+=1
			)
			
			debug "id_pt_next_intersc" var:id_pt_next_intersc
			
			---- on creer le bout de  ligne	-------		
			local 	result_pts 			=#()
			local 	result_inter_svt		=	intersections_avec_nd [ id_pt_next_intersc ]
			local 	prochain_stop 		= intersections_avec_nd [ id_pt_next_intersc ].id_base
			debug "result_inter_svt" var:result_inter_svt
			if id_pt_next_intersc != 0 do (
				local id_pt_courant		=	id_debut
				result_pts 					=	#( id_pt_courant )
				
				while 	id_pt_courant != prochain_stop do (
					local id_pt_suivant	=	boucler 	shp_courant	( id_pt_courant + 1 )
					append result_pts	 id_pt_suivant
					id_pt_courant += 1
				)
					
			)
			
			#( result_pts , result_inter_svt )
			
		),
		 */
		
		
		
		-------		Opérations booleennes 	-----------------------------------------------------------------------------------------------------------------------------------------------------------
		fn operation_booleenne		operation			_nds_base 			_nds_operateur			 =(
			
			if classof _nds_base !=array do 	_nds_base = #(_nds_base)
			if classof _nds_operateur !=array do 	_nds_operateur = #(_nds_operateur)
			
			
			format "\n\n\n\n"
			format "\n\n\n\n"
			debug "-------------------------- operation_booleenne	--------------------------------------------"
			debug "type			"	var:operation
			debug "_nd_base		"	var:_nds_base
			debug "_nd_operateur	"	var:_nds_operateur
			debug "--------------------------------------------------------------------------------------------"
			

			struct	str_intersection	(
				pos,
				
				nd_operateur,
				id_operateur 	=	0,
				nd_base,
				id_base 	=	0,
				
				nd,
				id_pt=0
			)
			
			--- on renvois une liste de liste de shapes ---------
			local 	result_nds = #()
			
			
			
			-------  ( 0 )	les noeuds en jeux	----------------------------------------------------------------------------------------------------------------------------------------------------------
			m_nds_bases			=	#()
			for nd_base in _nds_base do (
				if (nd_base.get_pts()).count > 0 do
					append m_nds_bases nd_base 
				m_nds_bases+= nd_base.get_descendance ()
			)
			m_nds_operateurs	= #()
			for nd_operateur in _nds_operateur do (
				if (nd_operateur.get_pts()).count > 0 do
					append 		m_nds_operateurs 	nd_operateur 
				m_nds_operateurs	+= 	nd_operateur.get_descendance ()
			)
			
			
			
			
			--- si on sousrtrait, on inverse les pleins et creux des operateurs	-------------
			if operation == #soustraction do (
				debug "on inverse les bases"
				for i = 1 to m_nds_operateurs.count 	do
					m_nds_operateurs[i].en_creux	=	not  m_nds_operateurs[i].en_creux	
			)
			
			
			--- on retourne les pts des noeuds en creux -------------------
			--- bases	--
			for i = 1 to m_nds_bases.count where m_nds_bases[i].en_creux do (
				debug "m_nds_bases[i]" var:m_nds_bases[i].nom
				m_nds_bases[i].changer_sens ()
			)
			--- operateurs ----
			for i = 1 to m_nds_operateurs.count where m_nds_operateurs[i].en_creux do 
					m_nds_operateurs[i].changer_sens ()
			
			
			
			
			--------- debug ------------------------------
			debug "m_nds_bases		" var:m_nds_bases				param:#nom
			debug "m_nds_operateurs	" var:m_nds_operateurs	param:#nom
/* 			sp = splineShape name:"bases"
			for j in 1 to m_nds_bases.count do (
				addnewSpline sp
				local pts_tmp = m_nds_bases[j].get_pts ()
				for pt in pts_tmp do		addknot sp j #corner #curve  pt
				close sp j
				updateShape sp
			)
			sp = splineShape name:"operateurs"
			for j in 1 to m_nds_bases.count do (
				addnewSpline sp
				local pts_tmp = m_nds_operateurs[j].get_pts ()
				for pt in pts_tmp do		addknot sp j #corner #curve  pt
				close sp j
				updateShape sp
			)
			--------- debug ------------------------------
 */







			
			---------  ( 0 )		les intersections  operateur <--> bases		 ---------------------------------------------------------------------------------------------------------------------------
			m_intersections =#()
			local ids_operateur_intersection 	 =	#{}	--1..m_nds_operateurs.count}
			local ids_base_intersection 			=	#{}	--1..m_nds_bases.count}
			
			for i_ope = 1 to m_nds_operateurs.count do (
				local nd_ope		=	m_nds_operateurs[ i_ope ]
				local pts_ope 	= nd_ope.get_pts ()
				
				local ope_aIntersection = false
				
				for i in 1 to pts_ope.count do (
					
					local pt_ope 		= pts_ope[i]
					local i_svt				= if i == pts_ope.count then 1 else  i + 1
					local pt_ope_svt 	= pts_ope[ i_svt ]
					
					for i_base = 1 to m_nds_bases.count do (
						local nd_base	=	m_nds_bases[ i_base ]
						
						
						local base_aIntersection = false
						
						local pts_base = nd_base.get_pts ()
						for j in 1 to pts_base.count do (
							
							local pt_base 			= pts_base[ j ]
							local j_svt				= if j == pts_base.count then 1 else  j + 1
							local pt_base_svt 	= pts_base[ j_svt ]
							
							local intersection_pos 	= get_intersection_vecteurs	pt_ope	pt_ope_svt		pt_base	pt_base_svt
							if intersection_pos != undefined  do (
								append m_intersections ( str_intersection 	pos:					intersection_pos	\
																							nd_operateur:		m_nds_operateurs[ i_ope ]					\
																							nd_base:				m_nds_bases[ i_base ]				\
																							id_operateur:		i 							\
																							id_base:				j 							)
								ids_base_intersection[ i_base ]		= true
								ids_operateur_intersection[ i_ope ] = true
							)
						)
						
					)
				
				)
					
			)
			
			local		nds_operateur_ssIntersection 	=	#()	--1..m_nds_operateurs.count}
			local 	nds_base_ssIntersection 			=	#()	--1..m_nds_bases.count}
			
			for i = 1 to m_nds_operateurs.count where not ids_operateur_intersection[i]	do 
				append nds_operateur_ssIntersection		m_nds_operateurs[i]
			
			for i = 1 to m_nds_bases.count where not ids_base_intersection[i]	do 
				append nds_base_ssIntersection		m_nds_bases[i]
			
			
			
			
			local ids_intersections_aTraiter	=#{1..m_intersections.count}
			
			debug ""
			debug"------ analyse intersection	---------------------------------------------------------------"
			debug ""
			debug "m_intersections				" var:m_intersections
			debug "ids_base_intersection			" var:ids_base_intersection
			debug "ids_operateur_intersection	" var:ids_operateur_intersection
			debug "nds_base_ssIntersection		" var:nds_base_ssIntersection	param:#nom
			debug "nds_operateur_ssIntersection	" var:nds_operateur_ssIntersection	param:#nom
			debug "--------------------------------------------------------------------------------------------"
			
			
			
			
			---------------  on gere les noeuds sans intersection	-------------------------
			case operation	of (
				#addition:		(
					-- on ajoute tout au resultat	-----
					for nd in nds_operateur_ssIntersection do (
						debug "ADDITION D UN OPERATEUR"
						append	result_nds	( nd )
					)
					for nd in nds_base_ssIntersection do (
						debug "ADDITION D UNE BASE"
						append	result_nds	( nd )
					)
				)
				#soustraction:		(
					-- on ajoute les bases	-----
					for nd in nds_base_ssIntersection do
						append	result_nds	( nd)
					-- on supprime les opes -------------------
					for nd in nds_operateur_ssIntersection do
						nd.supprimer ()
				)
				#intersection:		(
					-- on supprime tout -------------------
					for nd in nds_base_ssIntersection do
						nd.supprimer ()
					for nd in nds_operateur_ssIntersection do
						nd.supprimer ()
				)
				#union:		(
					-- on ajoute vraiment tout tout -------------------
					for nd in m_nds_bases do
						append	result_nds	( nd)
					for nd in m_nds_operateurs do
						append	result_nds	( nd)
				)
			)
		
			
			
			
-- 			if m_intersections.count > 0 do (
			
			
			
			
			
			
			
			---- tant qu'il reste des points à traiter	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
			local	il_reste_des_points 	=	m_intersections.count > 0  and operation != #union
			local sauvetage 				=	0
			local annuler = false
			while il_reste_des_points	and not annuler do (
				format "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
				debug "------------------------------------------------- TANT QU'IL RESTE DES POINTS à TRAITER	--------------------------------------------------------------------------------------------------------------------------------------------------------------------"
				debug "------->	ids_intersections_aTraiter" var:ids_intersections_aTraiter
				
				---- Le point demarrage, la premiere intersection de la liste --------------------
				local intersection_aTraiter		=	m_intersections[ ( ids_intersections_aTraiter as array )[1] ]
-- 				local intersection_aTraiter		=	m_intersections[1]
				debug "intersection_aTraiter" 	var:intersection_aTraiter
				
				
				---- les noeuds initiaux -------------------------
				local nd_initial						=	intersection_aTraiter.nd_base
				local id_pt_initial					=	intersection_aTraiter.id_base
				
				---- on regarde la position du point d'intersection pour voir si on inverse les noeuds --------------------
				local pt_test_intersection		=	intersection_aTraiter.pos
				local pt_test_operateur		= ( intersection_aTraiter.nd_operateur.get_pts() )[ intersection_aTraiter.id_operateur ]
				local pt_test_base				= ( intersection_aTraiter.nd_base.get_pts() )[ intersection_aTraiter.id_base ]
				
				if operation == #addition then
					if  est_aGauche		pt_test_base		pt_test_intersection 	pt_test_operateur		do (
						nd_initial					=	intersection_aTraiter.nd_operateur
						id_pt_initial					=	intersection_aTraiter.id_operateur
						
						debug "On inverse les noeuds initiaux, on est a GAUCHE"
					)
					
				else 	if not  est_aGauche		pt_test_base		pt_test_intersection 	pt_test_operateur		do (
						nd_initial					=	intersection_aTraiter.nd_operateur
						id_pt_initial					=	intersection_aTraiter.id_operateur
						
						debug "On inverse les noeuds initiaux, on est PAS a GAUCHE"
					)
					
					
					
				
					
				debug "nd_initial" var:nd_initial param:#nom
				
				local pt_initial 				= intersection_aTraiter.pos
				
				
				
				------ ( B )	On initialise les contitions courantes	----------------------------------------------------------------------------------------------------------------------------------------------
				local shp_enConstruction = #()
				
				
				--- le point courant initial	----------
				local nd_courant		=	nd_initial
				local shp_courant	= nd_courant.get_pts()
-- 				local nds_aTester		= 	if est_nd_deBase	nd_courant then 	m_nds_operateurs else		m_nds_bases
				
				local id_pt_courant	=	id_pt_initial
				local pt_courant		=	pt_initial
				local sens = 1
				
				
				
				shp_enConstruction = #()
				
				
				
				
				
				
				
				
				
				
				------ ( C ) 	Tant qu'on est pas retourné à notre point de départ	----------------------------------------------------------------------------------------------------------------
				local on_a_fini_laBoucle = false
				local annuler = false
				while not on_a_fini_laBoucle  and not annuler	do (
					format "\n\n"
					debug "------------------------------------------------- tant qu'on a pas fini la boucle	----------------------------------------------------------------------------------------------------------------"
					
				
				
					debug "nd_courant" 		var:nd_courant.nom
-- 					debug "nds_aTester" 	var:nds_aTester		param:#nom
					debug "pt_courant" 		var:pt_courant
					debug "" 	
					
					
					--- on fait le segment  jusqu'a la prochaine intersection 	----------------------------
-- 					local intersec_initial = 
					local on_continue = true
					while on_continue and not annuler		do (
						
						
						append 	shp_enConstruction		pt_courant
						
						--- on cherche la prochaine intersection ------------
						local dist_proche = 1e+10
						local prochaine_intersec = undefined
						local intersec_nd_courant = get_intersections		nd_courant
						
						/* 
						format "\n"
						debug "---------------------------------------"
						debug "id_pt_courant" 	var:id_pt_courant
						debug "pt_courant" 		var:pt_courant
						debug "shp_enConstruction" 		var:shp_enConstruction
						debug "intersec_nd_courant" 	var:intersec_nd_courant
						 */
						for 	intersection in 	intersec_nd_courant  do (
							
							
							if distance pt_courant	intersection.pos < 	dist_proche do
								if distance pt_courant		intersection.pos 	> SEUIL_POINTS_EGAUX do
									
									if est_nd_deBase		 nd_courant then (
										if intersection.id_base == id_pt_courant  do ( 
											local pt_base = shp_courant[	intersection.id_base  ]
											if 	( distance pt_courant		pt_base + distance pt_courant		intersection.pos )  - distance intersection.pos  pt_base 			< SEUIL_POINTS_EGAUX do	(
													dist_proche = distance pt_courant	intersection.pos
													prochaine_intersec = intersection
												)
										)
									) else (
										if intersection.id_operateur == id_pt_courant  do ( 
											local pt_ope = shp_courant[	intersection.id_operateur  ]
											if 	( distance pt_courant		pt_ope + distance pt_courant		intersection.pos )  - distance intersection.pos  pt_ope 			< SEUIL_POINTS_EGAUX do											 (
													dist_proche = distance pt_courant	intersection.pos
													prochaine_intersec = intersection
												)
										)
									)
									
						)-- fin for ----------
						
						debug "prochaine_intersec" 	var:prochaine_intersec
						
						
						
						
						---- si on a une intersection ----------------
						if prochaine_intersec != undefined then (
							
							
							debug "---------> INTERSECTION"
							debug "---------> prochaine_intersec" var:prochaine_intersec
							
							ids_intersections_aTraiter[ findItem m_intersections	prochaine_intersec	 ] = false
							
							--- on change de noeud courant	------
							if est_nd_deBase		nd_courant 	then (
								nd_courant		=	prochaine_intersec.nd_operateur
								id_pt_courant 	=  prochaine_intersec.id_operateur
	 							debug "	--->	on est sur une base, on bascule sur l'operateur."
	-- 							nds_aTester	=	nds_bases
							) else (
								nd_courant		=	prochaine_intersec.nd_base
								id_pt_courant 	=  prochaine_intersec.id_base
	 							debug "	--->	on est sur l'operateur, on passe sur une base."							
	-- 							nds_aTester	=	nds_bases
							)
							
							-----  on valide si on est sur un point intersection ------------------
							shp_courant		= 	nd_courant.get_pts()
							pt_courant 		=	prochaine_intersec.pos
							
-- 							append 		shp_enConstruction 	pt_courant
							
-- 							deleteItem 	m_intersections		1 --catch ()
							/* 
							local  i = 1 
							local trouve = false
							while i <= m_intersections.count and not trouve do (
								local inter = m_intersections[i]
								if distance inter.pos  pt_courant  <  .001  do (
									deleteItem m_intersections i
									
									trouve = true
								)
								i+=1
							) */
							
							--- on pâssse ----------
							on_continue = false
							
						---- si on a  pas d' intersection ----------------
						) else (
							
							
							
							
							debug "---------> SUIVANT"
							
							id_pt_courant 		= boucler	shp_courant		( id_pt_courant + 1 )
							pt_courant 		= shp_courant [ id_pt_courant ]
							
						)
						
						---- sortie -----------------
						if prochaine_intersec == intersection_aTraiter do 
							on_continue = false
						
						--- SAUVETAGE	----
						sauvetage += 1
						if sauvetage > SAUVETAGE_MAX do 
							annuler = true
						
						
						
					) -- FIN --- on fait le segment  jusqu'a la prochaine intersection 	-------------------------
					
					
					----------- ( 3 )	sortie ? si on est retourné sur le point initial, on sort	--------------------------------------------	
					
					if distance	pt_courant  pt_initial <  SEUIL_POINTS_EGAUX	then 
						on_a_fini_laBoucle = true
					
					--- SAUVETAGE	----
					sauvetage+= 1
					if sauvetage > SAUVETAGE_MAX do annuler = true
					
				)	---- Fin -	tant qu'on a pas fini la boucle	------------------------------------------------------------------------------------------------------
				
				--- on creer le noeud resultat -----------
				local nv_nd = this.creer_noeud_booleen 	pts:shp_enConstruction	nom:(operation as string + "_" + result_nds.count as string )
				
				---- on ajoute le noeud obtenu -----------------------------------
				append 	result_nds	nv_nd
				
				
				
				---------- SORTIES ---------------------------------------------
				---- test pour sortie  correct	----------------------------------------------------------------------------------------------------

				if 	( ids_intersections_aTraiter as array ).count == 0 do (
					il_reste_des_points = false
					format "\n\n"
					debug  "####################################################################################################################################"
					debug  "								FIN DE L'OPERATION : OK"
					debug  "####################################################################################################################################"
					
					
					
				)
				--- SAUVETAGE	----
				sauvetage += 1
				if sauvetage > SAUVETAGE_MAX do (
					annuler = true
					format "\n\n"
					debug  "####################################################################################################################################"
					debug ( "##########################	/!\	SAUVETAGE : " + sauvetage as string  + " boucles !	/!\	####################################################################")
					debug  "####################################################################################################################################"
					format "\n\n"
				)
				
			)	---- Fin -	tant qu'il reste des points à traiter		--------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
			
			debug  "####################################################################################################################################"
			debug  ( "								RESULTAT : " )
			debug 	"								result_nds" var:result_nds	 param:#nom
			debug  "####################################################################################################################################"
			format "\n\n"
			
			result_nds
			
		),
		
		
		------------------ hierarchie booleenne -----------------------------------
		fn creer_noeud_booleen 	pts: 	nom:	=(
			
			---- noeud de la hierarchie ----------
			struct str_terrain_booleen_node (
				--------- membres ------------------------------------------------------------------
				private
				
				
				
					mgr_shp,
					pts 					=	#(),
					
					dist_auParent	=	0,
				public
					nom 				=	"",
					
					en_creux			=	true	,		---- si le noeud est en creu ou en plein
					
					
				public
					parent			=	undefined,
					enfants			=	#(),
					
					
					
				--------- Fonctions ------------------------------------------------------------------
				public					
					
					
					fn maj_enCreux			=(
						if parent != undefined then
							en_creux = not parent.en_creux
						else en_creux = false
						
						for enfant in enfants do
							enfant.maj_enCreux ()
					),
					
					fn est_enCreux	= en_creux,
					fn changer_sens =(
						mgr_shp.debug "changer_sens" var:nom
						pts = mgr_shp.changer_sens pts
						),
					
					fn set_parent			_ndParent 	= (
						if parent != undefined and parent  != _ndParent do
							parent.retirer_enfant	this
						
						parent  = _ndParent
						maj_enCreux ()
					),
					fn ajouter_enfant 	_neudEnfant 	distance_toParent:	= (
						format  "**************************	AJOUTER_ENFANT	--->	this : %		enfant a jouter : %\n"	nom		_neudEnfant.nom
						--- le placer dans l'ordre du plus proche au plus loin ---------------
						local distTest	=	distance_toParent	--struct_prt.get_distance_shapes 	pts	_neudEnfant.pts
						local trouve = false
						if distTest != unsupplied and distTest != undefined do (
							
							local	dist_au_nvl_enfant	 		= distTest.distance
							
							_neudEnfant.dist_auParent 		= dist_au_nvl_enfant
							
							local id_cible = 0
							local i = 1
							while i <= enfants.count and not trouve do (
								local enfant = enfants[i]
								if dist_au_nvl_enfant <	 enfant.dist_auParent do (
									insertItem	_neudEnfant 	enfants	i
									trouve = true
								)
								i += 1
							)
						)
						if not trouve do
							append enfants  _neudEnfant
						
						
						_neudEnfant.set_parent  	this
					),
					fn retirer_enfant		_enfant 		=(
						local id_enfant = findItem enfants	_enfant
						if id_enfant != 0 do
							deleteItem enfants id_enfant
					),
					fn set_pts  			_pts			= pts = _pts,
					
					
					fn get_pts  			= pts,
					fn get_descendance	=(
						local result = #()
						for enfant in enfants do (
							append result enfant
							result		+=	enfant.get_descendance()
						)
						result
					),
					
					fn supprimer			=(
						if parent	!=	undefined do
							parent.retirer_enfant	this
					),
					
					fn initialiser 	_ptr_shp = mgr_shp = _ptr_shp
					
					
				
			)--- fin du struct----
			
		
			
			local nv_noeud = str_terrain_booleen_node	()--	struct_prt:this
			nv_noeud.initialiser	this
			if pts != unsupplied and pts != undefined do (
				if not est_sensPositif pts do 
					pts = changer_sens pts
				
				nv_noeud.set_pts 	pts
			)
			if nom != unsupplied do (
				nv_noeud.nom= nom
				if nom != "root" and nom != "nd_provisoire" do
					nv_noeud.en_creux = false
				
			)
			
			nv_noeud
			
		),
		
		
		fn inserer_noeud		_nd_courant		_nd_aIntegrer 		operation:#union	=(
			
			format "\n\n\n\n"
			debug "######## inserer_noeud	########################"
			debug "_nd_courant" var:_nd_courant.nom
			debug "_nd_courant" var:( _nd_courant.get_pts())
			debug "_nd_aIntegrer" var:_nd_aIntegrer.nom
			debug "_nd_aIntegrer" var:(_nd_aIntegrer.get_pts())
			debug "operation" var:operation
			debug "#######################################################"
			
/* 			
* 										Positon relative A B.						Mode opération de B																	Resultat
* 		on a 4 possibilités : 	---->	B et A sont à coté l'un de l'autre.		( A + B = A et B ).		---->	B est ajouter au niveau de A				----> 	A et B
* 																					( A - B = A ).				---->	B est un trou dans le vide.				----> 	A
* 																					( A | B = 0 ).				---->	Il reste 0 shapes, pas d'intersection.	----> 	-VIDE-
* 																					union
* 			
* 								---->	B est entierement dans A.				( A + B = A ).				---->	A absorbe totalement B.					----> 	A
* 																					( A - B = B dans A ).		---->	B est un trou complet dans A			----> 	B dans A
* 																					( A | B = B ).				---->	Il ne reste que B. 						----> 	B
* 		
* 		
*  								---->	A est entierement dans B.				( A + B = B ).				---->	B absorbe totalement A.					----> 	B
* 																					( A - B = 0 ).				---->	B fait disparaitre A => 0 shapes.		----> 	-VIDE-
* 																					( A | B = A ).				---->	Il ne reste que A.						----> 	A
* 																			
* 																			
* 								---->	A et B se coupent. 						( A + B = A ).				---->	faire les tracés.							----> 	tracés
* 																					( A - B = B dans A ).		---->	faire les tracés.							----> 	tracés
* 																					( A | B = B ).				---->	faire les tracés.							----> 	tracés
*/
			local integration_reussie 	= false			
			
			
			if _nd_courant.nom == "root" or  _nd_courant.nom == "nd_provisoire"	then (
				
				debug"----> on est dans un noeud RACINE"
				
				
				---- on regarde si un enfant du noeud courant	rentre dedans	-----------------
				local i = 1
				local  enfantsTemp = 		for enft in   _nd_courant.enfants collect enft
				while enfantsTemp.count > 0  do (
					local enfant = enfantsTemp[1]
					local result_integration =  inserer_noeud		enfant		_nd_aIntegrer 		operation:operation
					debug "--	ROOOT	---> result_integration" var:result_integration
					if result_integration do (
-- 						enfantsTemp = 		for enft in   _nd_courant.enfants collect enft
						integration_reussie = true
					 )
					deleteItem enfantsTemp 1
				)
				
				debug"----> integration ENFANT reussie" var:integration_reussie
				debug"----> ENFANTS RACINE		" var:_nd_courant.enfants
				
				if not integration_reussie do (
					
-- 					local distance_toParent = get_distance_shapes 	( _nd_courant.get_pts() )	( _nd_aIntegrer.get_pts () )
					_nd_courant.ajouter_enfant 		_nd_aIntegrer	--distance_toParent:distance_toParent	
					/* 
					local enfants_a_ajouter = #()
					for enfant in	_nd_courant.enfants  do 
						if shape_estDans_shape	( _nd_aIntegrer.get_pts () )	 ( enfant.get_pts() )   then
							append enfants_a_ajouter enfant
					
					---- ajoute tout les enfants du noeud courant qui rentre dans le noeud à integrer.	-----------------
					for enfant in enfants_a_ajouter do (
						local distance_toParent = get_distance_shapes 	( _nd_courant.get_pts() ) 	( enfant.get_pts() ) 
						_nd_aIntegrer.ajouter_enfant 	enfant	distance_toParent:distance_toParent
					)
					
					---- ajoute le noeud à integrer aux enfant du noeud courant.	-----------------
					local distance_toParent = get_distance_shapes 	( _nd_courant.get_pts() )	( _nd_aIntegrer.get_pts () )
					_nd_courant.ajouter_enfant 		_nd_aIntegrer	distance_toParent:distance_toParent	
						debug " ?! ?! ?! ? 	cet enfant	?! ?! ?! ? "
					 */
					--- fin du boulot -----------					
					integration_reussie = true
				)
			
			) else (
				
				-------- en fonction de la position relative des shapes ------------------------------------------
				local pos_relative = get_positionRelative_shapes 	( _nd_courant.get_pts() )	( _nd_aIntegrer.get_pts () )
				
				case pos_relative of (
					
					#aCoté:	 	(			----> 	B et A sont à coté l'un de l'autre.	---------------------------------------------------------
						debug "A et B sont à coté l'un de l'autre."
						
						
						----------  en fonction du type d'opération -------------
						case operation of (
							
									--------- 	B est ajouter au niveau de A				----> 	A et B			--------------------------------	
									#addition:	 		(
-- 										_nd_courant.ajouter_enfant	_nd_aIntegrer	
-- 										integration_reussie = true
											/* 
											---- on regarde si un enfant du noeud courant	rentre dedans	-----------------
											for enfant in	_nd_courant.enfants  do (
												local result_integration =  inserer_noeud		enfant		_nd_aIntegrer 		_operation
												debug "-----> result_integration" var:result_integration
												if result_integration do
													integration_reussie = true
											) */
									)
									---------	B est un trou dans le vide.				----> 	A	--------------------------------	
									#soustraction:	 		(
										
										
										--- fin du boulot, B disparait, rien à faire  -----------		
									)
									---------	Il reste 0 shapes, pas d'intersection.	----> 	-VIDE-	--------------------------------	
									#intersection:	 		(
										---- on supprime le noeud courant ----------------
										_nd_courant.supprimer ()	
										integration_reussie = true
									)
									
									#union:(
										_nd_courant.parent.ajouter_enfant	_nd_aIntegrer	
										integration_reussie = true
									)
							) --- fin case operation-	---------------------
						
						) ---- fin #aCoté ---------------------------------------------------------
						
						
						
					#interieur:	 (			---->	B est entierement dans A.			---------------------------------------------------------
							debug "B est entierement dans A."
							debug "operation " var:operation
							----------  en fonction du type d'opération -------------
							case operation of (
									---------	A absorbe totalement B	----> 	A	--------------------------------	
									#addition:	 		(
										debug "DEBUT D ADDITION"
										--- fin du boulot, B disparait, rien à faire  -----------
										integration_reussie = true
										
										_nd_aIntegrer.supprimer ()
										debug "FIN D ADDITION"
									)
									---------	B est un trou complet dans A	----> 	B dans A	--------------------------------	
									#soustraction:	 		(
										
										debug "	**********		DEBUT  SOUSTRACTION	interieur	**********"
											---- on essaye de l'integrer dans les enfants de A  -----
											local integration_dans_enfant = false	
											for enfant in	_nd_courant.enfants  do (
-- 												if shape_estDans_shape	( _nd_aIntegrer.get_pts () )	 ( enfant.get_pts() )   then
												local pos_enfant	=	get_positionRelative_shapes 	( enfant.get_pts() )	( _nd_aIntegrer.get_pts () )
												if pos_enfant != #aCoté do (
													if enfant.en_creux	then
														inserer_noeud  		enfant  		_nd_aIntegrer		operation:#addition
													else
														inserer_noeud  		enfant  		_nd_aIntegrer		operation:#soustraction
														
													integration_dans_enfant = true
												)
-- 												local integration = inserer_noeud  		enfant  		_nd_aIntegrer		#soustraction
-- 												if integration then  
-- 													integration_dans_enfant = true
											)
											
											--- si il ne s'integre pas dans un enfant, on l'integre au neoud courant	----------------
											if not integration_dans_enfant   do (
												---- ajoute le noeud à integrer aux enfant du noeud courant.	-----------------
												local distance_toParent = get_distance_shapes 	( _nd_courant.get_pts() )	( _nd_aIntegrer.get_pts () )
												_nd_courant.ajouter_enfant 		_nd_aIntegrer	distance_toParent:distance_toParent
											)
											
											integration_reussie = true
									)
									---------	Il ne reste que B. 	----> 	B	--------------------------------	
									#intersection:	 		(
										--- on copie les points de B dans A	------------------
										_nd_courant.set_pts 	( _nd_aIntegrer.get_pts () )
										integration_reussie = true
									)
									
									#union:(
										_nd_courant.ajouter_enfant	_nd_aIntegrer	
										integration_reussie = true
									)
							) --- fin case operation-	---------------------
	
							
						) ---- fin #interieur ---------------------------------------------------------
						
						
						
					#exterieur:	(			---->	A est entierement dans B			.---------------------------------------------------------
							debug "A est entierement dans B."
						
							----------  en fonction du type d'opération -------------
							case operation of (
									---------	B absorbe totalement A.					----> 	B	--------------------------------	
									#addition:	 		(
										--- on copie les points de B dans A	------------------
										_nd_courant.set_pts 	( _nd_aIntegrer.get_pts () )
										integration_reussie = true
									)
									---------	B fait disparaitre A => 0 shapes.		----> 	-VIDE-	--------------------------------	
									#soustraction:	 		(
										_nd_courant.supprimer ()	
										integration_reussie = true
									)
									---------	Il ne reste que A.						----> 	A	--------------------------------	
									#intersection:	 		(
										--- fin du boulot, B disparait, rien à faire  -----------
										integration_reussie = true									
									)
									
									#union:(
									
										local prt	=	_nd_courant.parent
										_nd_aIntegrer.ajouter_enfant		_nd_courant
										prt.ajouter_enfant		_nd_aIntegrer
										integration_reussie = true
									)
							) --- fin case operation-	---------------------
						) ---- fin #exterieur ---------------------------------------------------------
						
						
						
					#seCroisent:	(		---->	A et B se coupent, on va avoir du decoupage à faire ! 					---------------------------------------------------------
							debug "A et B se coupent. "
						
-- 						case operation of (
-- 							#addition: (
								
								debug "----	lancement OPERATION" var:operation
								local shapes_booleens 	= 	operation_booleenne		operation		_nd_courant		_nd_aIntegrer
								debug "shapes_booleens COUNT" var:shapes_booleens.count
								
								local nom_nd_courant 		= _nd_courant.nom
								local nd_courant_parent 	= _nd_courant.parent	
								
								_nd_courant.supprimer ()
								if shapes_booleens.count > 0 then (
-- 									_nd_courant.set_pts  shapes_booleens[ 1 ]
									
									local nvx_noeuds = 	this.get_noeuds_from_ptsShapes	shapes_booleens 		nom:_nd_courant.nom
									
									for i = 1 to   nvx_noeuds.count	do 
										inserer_noeud		nd_courant_parent	nvx_noeuds[i]
									
									
								) else 	_nd_courant.supprimer ()
								
								_nd_aIntegrer.supprimer ()
								
								debug "----	fin OPERATION" var:operation
-- 							)
							/* 
							#soustraction: (
								
								debug "----	lancement OPERATION" var:operation
								local shapes_booleens 	= 	operation_booleenne		operation		_nd_courant		_nd_aIntegrer
								debug "shapes_booleens COUNT" var:shapes_booleens.count
								
								local nom_nd_courant = _nd_courant.nom
								local nd_courant_parent = _nd_courant.parent	
								
								_nd_courant.supprimer ()
								_nd_aIntegrer.supprimer ()
								
								local i = 1 
								for shp in  shapes_booleens	do (
									local nv_nd = creer_noeud_booleen 	pts:shp				nom:(nom_nd_courant	+ "_" + (  i+=1 ) as string)
									nd_courant_parent.ajouter_enfant		nv_nd 	
								)
								
								debug "----	fin OPERATION" var:operation
							)
							 */
							/* 
						)
							if operation as name	 != #union then (
								
								debug "----	lancement OPERATION" var:operation
								local shapes_booleens 	= 	operation_booleenne		operation		_nd_courant		_nd_aIntegrer
								debug "shapes_booleens COUNT" var:shapes_booleens.count
								
								local nom_nd_courant = _nd_courant.nom
								local nd_courant_parent = _nd_courant.parent	
								
								_nd_courant.supprimer ()
								_nd_aIntegrer.supprimer ()
								
								local i = 1 
								for shp in  shapes_booleens	do (
									local nv_nd = creer_noeud_booleen 	pts:shp				nom:(nom_nd_courant	+ "_" + (  i+=1 ) as string)
									nd_courant_parent.ajouter_enfant		nv_nd 	
								)
								
								debug "----	fin OPERATION" var:operation
							) else (
-- 								_nd_courant.parent.ajouter_enfant		_nd_aIntegrer
								
							) */
							--- fin du boulot -----------					
							integration_reussie = true
						
						
						) ---- fin #seCroisent ---------------------------------------------------------
						
				)	---	fin case position relative	------------------------------------
				
				
			)
				
				
			debug  "FIN 	 inserer_noeud	########################"
			debug  "integration_reussie" var:integration_reussie
			debug_nd	 _nd_courant
			format"\n\n"
			integration_reussie
			
		),
		
		
		
		
		
		
		
		
		----- manipulation de  points  ---------------
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
		fn interpoler_shape 		_shp_node		=(
			
			local result	=#()
	
			local dotmax_courbe 		= .999	--- en dot ?!?. ----
			
			m_pts_contour = #()
			
			
			---- pour chacune des splines du shape ----------------
			for id_spline_contour	=	1	to numsplines  _shp_node do (
				
				local pts_spline_contour = for j= 1 to numKnots 	_shp_node	id_spline_contour	 collect getKnotPoint _shp_node 		id_spline_contour	 	j 
				local pt_result 	= #()
				for id_pt_contour	=	1	to pts_spline_contour.count do (
					
					local pt_contour  		= getKnotPoint _shp_node 		id_spline_contour	 	id_pt_contour
					local id_pt_contour_svt = if id_pt_contour != pts_spline_contour.count then id_pt_contour + 1 else 1
-- 					local pt_contour_svt  	= getKnotPoint _shp_node 		id_spline_contour	 	id_pt_contour_svt
					
					local pt_contour_type 			= getKnotType 		_shp_node  id_spline_contour	 id_pt_contour
					local pt_contour_svt_type 	= getKnotType 		_shp_node  id_spline_contour	 id_pt_contour_svt
					
					if pt_contour_type != #corner or pt_contour_svt_type != #corner then (
						
						----- Interpolation  - adaptif ----------------------------					
						local longueur_segment 	= get_longueur_segment	_shp_node	id_spline_contour		id_pt_contour 
						local pos_courbe 			= 0
						local nbr_division 			= floor ( longueur_segment / PRECISION_COURBE)
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
							if dot_tangents <	dotmax_courbe do (
								tangent_derniere = tangent
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
					debug "CUILA----------------->"
					pt_result = changer_sens		pt_result
					debug "<-----------------CUILA"
				)
				append result	pt_result
			)
			
			
			--- on recalle les points à la transform du shape ------------
			for shp in result do
				for pt in shp do
					pt += [10000,0,0]	---inverse _shp.transform
			
			---- on vire les points en ligne droite ----------
			result = nettoyer_points_inutiles	result
			
			result
		),
		fn interpoler_pts_from_shape  	_shp_node	=( 
			
			local pts_shps = interpoler_shape 		_shp_node
			
			--- on les plaque sur z=0 -----
			for shp in pts_shps do	shp.z = 0
			
			pts_shps
		),
		
		
	------------------- INTERFACE -----------------------------------------------------------------------
		
		fn get_noeuds_from_pts 		_pts_shps 		nom:"nv_nd"	=(
			
			local nd_porteur 		=	creer_noeud_booleen 	nom:"nd_provisoire"
-- 			local result_nds	=	#()
			local pts_shps 		= _pts_shps
			
			local i = 0
			for pts_shp in pts_shps do (
				nv_nd = creer_noeud_booleen 	pts:pts_shp	nom:( nom	+ "_" + (  i+=1 ) as string)
				nd_porteur.enfants	=	operation_booleenne		#union	nd_porteur		nv_nd
				
-- 				if nom != unsupplied  do
-- 					nv_nd.nom = ( nom + "_" + (  i+=1 ) as string )
-- 				nv_nd.maj_enCreux ()
-- 				nv_nd.parent = undefined
			)
			
-- 			result_nds
			nd_porteur.enfants
		),
		
		
	public
		fn get_noeuds_from_shape 		_shape 			=(
			
			local nd_porteur 	=	creer_noeud_booleen 		nom:"nd_provisoire"
			local pts_shps 	= 	interpoler_pts_from_shape		_shape
			local result 		= get_noeuds_from_pts	pts_shps	nom:_shape.name
-- 			for nd in result  do
-- 				nd.nom = (_shape.name	+ "_" + (  i+=1 ) as string)
			result
			
		),
		
		
		
		--- renvois le tableau des triangles créés -------
		fn trianguler  _pts =(
-- 			debug "-------------------- TRIANGULER -----------------------------------------------"
			local pts_poly 			= deepcopy _pts
			
			local result_triangles	= #()
			
			--------------- tant qu'il reste plus de trois point dans le polygone -------------------------------------------------------------------------------------------------------------------------			
			while pts_poly.count >= 3 do (
-- 				format "\n\n---------------------------------------------------------------------"
				
				
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
					
-- 					debug "-----> 	DECOUPAGE	->		pt_orig_triangle" var:pt_orig_triangle.name
					
					local pts_dansTriangle	=	for id_pt in ids_pts_dansTriangle collect pts_poly[id_pt]
					
					---- si on en trouve : on cherche le plus éloigné de la 'diagonale' du triangle ----
					local IDs_pts_diagonal 	= 	points_lesPlusLoinDuSegment  	pts_dansTriangle		triangle_aTester[3]		triangle_aTester[1]
					
-- 					debug "-----> 	pts_dansTriangle : " var:pts_dansTriangle
-- 					debug "-----> 	IDs_pts_diagonal : " var:IDs_pts_diagonal
					
					
					--- on gere si on a plusieurs points pour la diagonal --------------------
					local IDpt_decoupe 
					if IDs_pts_diagonal.count > 1 then (
-- 						debug "Choisir un pt diagonal " 
-- 						debug "-> id_pt_aTester" var:id_pt_aTester
						local dist_id_min = 1e+10
						for id_pt in IDs_pts_diagonal do (
							local id_diag 		= ids_pts_dansTriangle[id_pt]
-- 							local dist_test = abs ( id_pt_aTester - id_diag )
							/* if id_diag < id_pt_aTester then (
								dist_test = id_pt_aTester - 
								id_diag = id_diag + pts_poly.count
								
							)		 */					
							
-- 							debug "	-> id_diag" var:id_diag
							local dist_to_id = abs (id_diag - id_pt_aTester )
-- 							debug "	-> dist_to_id" var:dist_to_id
							if dist_to_id < dist_id_min do (
								IDpt_decoupe 	= id_diag
								dist_id_min 	= dist_to_id
							)
								
						)
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

					result_triangles += trianguler  pts_poly1
					result_triangles += trianguler  pts_poly2
					
					
					
					/* 
					sp = splineShape name:(Uniquename "decoupage poly 1 - ")
					addnewSpline sp
					for pt in pts_poly1 do		addknot sp 1 #corner #curve  pt
					close sp 1
					updateShape sp
					sp = splineShape name:(Uniquename "decoupage poly 2 - ")
					addnewSpline sp
					for pt in pts_poly2 do		addknot sp 1 #corner #curve  pt
					close sp 1
					updateShape sp
-- 						selectMore sp
					  */
					
					
					
					
					
					-- on vide les points de poly car on a lancé la fonction recursivement sur les deux poly trouvés, et on veut sortir de la boucle----
					pts_poly = #()
					
				------- soit on a pas de points dans le triangle, 		---->	donc on peut le treer tranquile 		------------------------------------------------------------------------------
				) else (
					
-- 					debug "-----> 	TRIANGLE	->		pt_orig_triangle" var:pt_orig_triangle.name
					
					
					---- si on en trouve pas: 	on peut creer le triangle et retirer le point tester de la liste du polygone ----
					append 	result_triangles  triangle_aTester
					deleteItem pts_poly  id_pt_aTester
					/* 
-- 					for j in 1 to triangle_aTester.count do (
						sp = splineShape name:( "triangle " + pt_orig_triangle.name )
						addnewSpline sp

						for pt in triangle_aTester do		addknot sp 1 #corner #curve  pt
						close sp 1
						updateShape sp
-- 					)
						 */
				)
				
			)  --- fin du while il ya plus de 3 pts dans le polygone ------
			
			result_triangles
			
		) --- fin fonction decoupage polygone ----------

		/* 
		---- on entre une liste de listes de points  (nos differents shapes à analyser )------------
		---- renvois une liste des points avec fusion des shapes à trous en une seule liste pour creéation de face troué ---------
		fn creer_hierarchie_booleens		 	_pts_shps 	=(
			
			---- on cherche les booleens --------------------
			local pts_results 	=  preparer_booleens 	_pts_shps
			
			pts_results
			
		)
	
		 */
			
	
)









