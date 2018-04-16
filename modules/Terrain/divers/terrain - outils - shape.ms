
include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - mgr - Datas to string.ms" 

struct str_terrain_outils_shape (






		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	public
		m_debug	=	true,
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
-- 			debug "changer_sens()"
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
		fn get_positionRelative_shapes 		_pts_shpA		_pts_shpB 		renvoyer_intersections:true		=(
			
-- 			debug "get_positionRelative_shapes()"
			
			struct	str_intersection	(
				pos,
				id_A,
				id_B
			)
			
			
			local result_pos 		= #aCoté		---- #exterieur,  #interieur, #seCroisent, ou	 #aCoté	 --------------
			local intersections 	=#()
			
			---- si les BB se croisent	-------------------
			if  BBs_seCroisent 	_pts_shpA 		_pts_shpB do (
			
-- 				debug "-------->BBs_seCroisent 	_pts_shpA 		_pts_shpB " var:(BBs_seCroisent 	_pts_shpA 		_pts_shpB )
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
-- 							debug "-------->INTERSECTION " 
																								
						)
						j+= 1
					)
					i+= 1
				)
				
				
				
				---- si on a des intersections, alors ils se croisent ------------------------------------
				if intersections.count > 0 then (
					
					result_pos 					= #seCroisent
					result_intersections		=	intersections
					
				) else (
					---- s'il ne se croisent pas alors ils sont tout à l'interieur ou à l'extierieur l'un de l'autre -------------------------
					local pts_triangles_shpA = this.trianguler	_pts_shpA
 					local pts_triangles_shp2 = this.trianguler	_pts_shpB
					
					if survol_triangles  	_pts_shpB[1]	pts_triangles_shpA	 then 
						result_pos = #interieur
					else  if survol_triangles  	_pts_shpA[1]		pts_triangles_shp2	 then 
						result_pos = #exterieur
						
				)
				
			)
			
			local result  =#( result_pos, result_intersections)
			result
		),
		
		fn shape_estDans_shape		_shp_1  shp_test =(
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
-- 		m_nds_bases			,
-- 		m_nds_operateurs	,
-- 		m_intersections		,

		
		fn get_booleen_nds					_nd_A 			_nd_B	operation:#union		intersections:#()	=(
			
-- 			debug "get_booleen_nds()"
			
-- 			if classof _nds_base 		!=array do 	_nds_base = #(_nds_base)
-- 			if classof _nds_operateur 	!=array do 	_nds_operateur = #(_nds_operateur)
-- 			format "\n\n\n\n"
			local pts_A = _nd_A.get_pts ()
-- 			local sens = 1
			if 	_nd_A.en_creux	do 	 sens = -1
		
			local pts_B = _nd_B.get_pts ()
-- 			if 	_nd_A.en_creux	do 	pts_B =	changer_sens	pts_B
			
			format "\n\n\n\n"
			debug "-------------------------- get_booleen_nds	--------------------------------------------"
			debug "	operation"			var:operation
			debug "	pts_A"				var:pts_A
			debug "	pts_B"				var:pts_B
-- 			debug "	intersections"	var:intersections
-- 			delete $intersection*
-- 			for intersection in intersections do
-- 				point pos:intersection.pos	name:(uniquename "intersection" )  centermarker:off axistripod:off cross:on Box:on size:4 constantscreensize:off drawontop:off wirecolor:blue
			debug "--------------------------------------------------------------------------------------------"

			local 	result_nds 	= #()

			
			
			
			---- tant qu'il reste des intersections à traiter	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
			local	il_reste_des_points 	=	intersections.count > 0  and operation != #union
			local ids_intersections_aTraiter 	= #{1..intersections.count}
			local sauvetage 				=	0
			local annuler = false
			while il_reste_des_points	and not annuler do (
-- 				format "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
-- 				debug "------------------------------------------------- TANT QU'IL RESTE DES intersections à TRAITER	--------------------------------------------------------------------------------------------------------------------------------------------------------------------"
-- 				debug "------->	intersections" var:intersections
-- 				debug "------->	ids_intersections_aTraiter" var:ids_intersections_aTraiter				
				---- Le point demarrage, la premiere intersection de la liste --------------------
				local id_intersection_aTraiter = ( ids_intersections_aTraiter as array )[1]
-- 				debug "------->	id_intersection_aTraiter" var:id_intersection_aTraiter			
				local intersection_aTraiter		=	intersections[ id_intersection_aTraiter ]
				ids_intersections_aTraiter [ id_intersection_aTraiter ] = false
-- 				local intersection_aTraiter		=	m_intersections[1]
-- 				debug "intersection_aTraiter" 	var:intersection_aTraiter
				
				
				---- les noeuds initiaux -------------------------
-- 				local nd_initial						=	intersection_aTraiter.nd_A
				local id_pt_initial		=	intersection_aTraiter.id_B				
				local pt_initial 			= intersection_aTraiter.pos
				local shp_initial		= pts_B
				local trace_courant =	#B
				
				---- on regarde la position du point d'intersection pour voir si on inverse les noeuds --------------------
				local pt_test_intersection	=	intersection_aTraiter.pos
				local pt_test_base				= pts_A[ intersection_aTraiter.id_A ]
				local pt_test_operateur		= pts_B[intersection_aTraiter.id_B]
				
				
				if operation == #addition then
					if not est_aGauche		pt_test_base		pt_test_intersection 	pt_test_operateur		do (
-- 						nd_initial					=	intersection_aTraiter.nd_operateur
						shp_initial			= pts_A
						trace_courant		=	#A
						id_pt_initial			=	intersection_aTraiter.id_A
-- 						debug "On inverse les noeuds initiaux, on est a GAUCHE"
					)
					
				else 	if   est_aGauche		pt_test_base		pt_test_intersection 	pt_test_operateur		do (
-- 						nd_initial					=	intersection_aTraiter.nd_operateur
						shp_initial			= pts_A
						trace_courant		=	#A
						id_pt_initial			=	intersection_aTraiter.id_A
						
-- 						debug "On inverse les noeuds initiaux, on est PAS a GAUCHE"
					)
					
					
					
				
					
-- 				debug "nd_initial" var:nd_initial param:#nom
				
				
				
				local shp_courant	= shp_initial
				
				------ ( B )	On initialise les contitions courantes	----------------------------------------------------------------------------------------------------------------------------------------------
				local shp_enConstruction = #()
				
				
				--- le point courant initial	----------
-- 				local nd_courant		=	nd_initial
-- 				local nds_aTester		= 	if est_nd_deBase	nd_courant then 	m_nds_operateurs else		m_nds_bases
				
				local id_pt_courant	=	id_pt_initial
				local pt_courant		=	pt_initial
				local sens = 1
			if 	_nd_A.en_creux	do 	 sens = -1
				
				
				
				
				
				
				
				
				
				
				
				
				------ ( C ) 	Tant qu'on est pas retourné à notre point de départ	----------------------------------------------------------------------------------------------------------------
				local on_a_fini_laBoucle = false
				local annuler = false
				while not on_a_fini_laBoucle  and not annuler	do (
-- 					format "\n\n"
-- 					debug "------------------------------------------------- tant qu'on a pas fini la boucle	----------------------------------------------------------------------------------------------------------------"
					
				
				
-- 					debug "nd_courant" 		var:nd_courant.nom
-- 					debug "nds_aTester" 	var:nds_aTester		param:#nom
-- 					debug "id_pt_courant" 		var:id_pt_courant
-- 					debug "pt_courant" 			var:pt_courant
-- 					debug "trace_courant" 		var:trace_courant
-- 					debug "" 	
					
					
					--- on fait le segment  jusqu'a la prochaine intersection 	----------------------------
-- 					local intersec_initial = 
					local on_continue = true
					while on_continue and not annuler		do (
						
						
						append 	shp_enConstruction		pt_courant
						
						--- on cherche la prochaine intersection ------------
						local dist_proche = 1e+10
						local prochaine_intersec = undefined
-- 						local intersec_nd_courant = get_intersections		nd_courant
						
						
-- 						format "\n"
-- 						debug "---------------------------------------"
-- 						debug "id_pt_courant" 	var:id_pt_courant
-- 						debug "pt_courant" 		var:pt_courant
-- 						debug "shp_enConstruction" 		var:shp_enConstruction
-- 						debug "intersec_nd_courant" 	var:intersec_nd_courant
						
						for 	intersection in 	intersections  do (
							
-- 							debug "			--> intersection" var:intersection
-- 							debug "			-->par la : #1"
							if distance pt_courant	intersection.pos < 	dist_proche do (
-- 								debug "			-->par la : #2"
								if distance pt_courant		intersection.pos 	> SEUIL_POINTS_EGAUX do (
-- 									debug "			-->par la : #3"
									
									if trace_courant 	==	#A then (
-- 										debug "			-->par la : #4-1"
										if intersection.id_A == id_pt_courant  do ( 
-- 											debug "			-->par la : #5-1"
											local pt_base = shp_courant[	intersection.id_A  ]
											if 	( distance pt_courant		pt_base + distance pt_courant		intersection.pos )  - distance intersection.pos  pt_base 			< SEUIL_POINTS_EGAUX do	(
-- 												debug "			-->par la : #6-1 ##################"
												
													dist_proche = distance pt_courant	intersection.pos
													prochaine_intersec = intersection
												)
										)
									) else (
-- 										debug "			-->par la : #4-2"
										if intersection.id_B == id_pt_courant  do ( 
-- 											debug "			-->par la : #5-2"
											local pt_ope = shp_courant[	intersection.id_B  ]
											if 	( distance pt_courant		pt_ope + distance pt_courant		intersection.pos )  - distance intersection.pos  pt_ope 			< SEUIL_POINTS_EGAUX do											 (
-- 												debug "			-->par la : #6-2 ##################"
												
													dist_proche = distance pt_courant	intersection.pos
													prochaine_intersec = intersection
												)
										)
									)
								)
							)
						)		-- fin for ----------
						
-- 						debug "intersections" 				var:intersections param:#pos
-- 						debug "prochaine_intersec" 	var:prochaine_intersec
						
						
						
						
						---- si on a une intersection ----------------
						if prochaine_intersec != undefined then (
							
							
-- 							debug "---------> INTERSECTION"
-- 							debug "---------> prochaine_intersec" var:prochaine_intersec
							
-- 							ids_intersections_aTraiter[ findItem m_intersections	prochaine_intersec	 ] = false
							
							--- on change de noeud courant	------
							if  trace_courant 	==	#A 	then (
-- 								nd_courant		=	prochaine_intersec.nd_operateur
								trace_courant 	=	#B
								shp_courant	= 	pts_B
								id_pt_courant 	=  prochaine_intersec.id_B
-- 	 							debug "	--->	on est sur A, on bascule sur B."
	-- 							nds_aTester	=	nds_bases
							) else (
								trace_courant 	=	#A
-- 								nd_courant		=	prochaine_intersec.nd_base
								shp_courant		= 	pts_A
								id_pt_courant 	=  prochaine_intersec.id_A
-- 	 							debug "	--->	on est sur B, on passe sur A."							
	-- 							nds_aTester	=	nds_bases
							)
							
-- 							-----  on valide si on est sur un point intersection ------------------
-- 							shp_courant		= 	nd_courant.get_pts()
							pt_courant 		=	prochaine_intersec.pos
							
-- 							append 		shp_enConstruction 	pt_courant
							id_intersection_aTraiter	=	findItem	intersections		prochaine_intersec
							ids_intersections_aTraiter [ id_intersection_aTraiter ] = false
-- 							deleteItem 	intersections		1 --catch ()
							
-- 							local  i = 1 
-- 							local trouve = false
-- 							while i <= m_intersections.count and not trouve do (
-- 								local inter = m_intersections[i]
-- 								if distance inter.pos  pt_courant  <  .001  do (
-- 									deleteItem m_intersections i
-- 									
-- 									trouve = true
-- 								)
-- 								i+=1
-- 							) 
						
							
							--- on pâssse ----------
							on_continue = false
							
						---- si on a  pas d' intersection ----------------
						) else (
							
-- 							debug "---------> SUIVANT"
							
							id_pt_courant 		= boucler	shp_courant		( id_pt_courant + sens )
							pt_courant 		= shp_courant [ id_pt_courant ]
							
						)
						
-- 						debug "---------> pt_courant" var:pt_courant
						
						---- sortie  ou suivant -----------------
						if prochaine_intersec == intersection_aTraiter then 
							on_continue = false
-- 						else 
-- 							deleteItem intersections 1
						
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
				
				if 	_nd_A.en_creux	do 	shp_enConstruction =	changer_sens	shp_enConstruction
				local nv_nd = this.creer_noeud_booleen 	pts:shp_enConstruction	\
																				nom:(_nd_A.nom + "_" +_nd_B.nom  /* + "--->" + operation as string  */+ "_" + result_nds.count as string )	
				
-- 				nv_nd.enfants = for enfant in _nd_A.enfants collect enfant
-- 				debug "------------------------------------->	_nd_A" var:_nd_A
-- 				debug "------------------------------------->	_nd_B" var:_nd_B
				debug "------------------------------------->	nv_nd" var:nv_nd
				debug "------------------------------------->	shp_enConstruction" var:shp_enConstruction
				
				
				 
				---- on ajoute le noeud obtenu -----------------------------------
				append 	result_nds	nv_nd
				
-- 				append 	result_nds	shp_enConstruction
				
				
				---------- SORTIES ---------------------------------------------
				---- test pour sortie  correct	----------------------------------------------------------------------------------------------------

			 	if 	(ids_intersections_aTraiter as array ).count ==  0	do (
					il_reste_des_points = false
-- 					format "\n\n"
-- 					debug  "####################################################################################################################################"
-- 					debug  "								FIN DE L'OPERATION : OK"
-- 					debug  "####################################################################################################################################"
-- 					
-- 					
					
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
			
			
			debug "--------------------------------------------------------------------------------------------"
			debug  ( "								RESULTAT booleen: " )
			debug 	"								result_nds" var:result_nds
-- 			for nd_result in result_nds do
-- 				debug_nd	 nd_result
			
			debug "--------------------------------------------------------------------------------------------"
			format "\n\n"
			
			result_nds
			
		),
		
		
		
		-------		Opérations booleennes 	-----------------------------------------------------------------------------------------------------------------------------------------------------------
		fn operation_booleenne				operation			_nd_A 			_nd_B			 		=(
			
			format "\n\n\n\n"
			debug "-------------------------- operation_booleenne	--------------------------------------------"
			debug "operation	"	var:operation
			debug "_nd_A		"	var:_nd_A
			debug "_nd_B		"	var:_nd_B
			debug "--------------------------------------------------------------------------------------------"
			
			local result_nds	=#()
			
			local pos_relative = get_positionRelative_shapes 	( _nd_A.get_pts() )	( _nd_B.get_pts () )
			
			debug "pos_relative		"	var:pos_relative
			case pos_relative[1] of (
				
				#aCoté:	 	(			----> 	B et A sont à coté l'un de l'autre.	---------------------------------------------------------
					debug "A et B sont à coté l'un de l'autre."
					----------  en fonction du type d'opération -------------
					case operation of (			
								--------- 	B est ajouter au niveau de A				----> 	A et B			--------------------------------	
								#addition:	 		(
									result_nds = #( _nd_A , _nd_B )
								)
								---------	B est un trou dans le vide.				----> 	A	--------------------------------	
								#soustraction:	 		(
									result_nds = #( _nd_A )
								)
								---------	Il reste 0 shapes, pas d'intersection.	----> 	-VIDE-	--------------------------------	
								#intersection:	 		(
									result_nds = #( )
								)
								#union:(
									result_nds = #( _nd_A , _nd_B )
								)
						) --- fin case operation-	---------------------
					) ---- fin #aCoté ---------------------------------------------------------
					
				#interieur:	 (			---->	B est entierement dans A.			---------------------------------------------------------
						debug "B est entierement dans A."
						----------  en fonction du type d'opération -------------
						case operation of (
								---------	A absorbe totalement B	----> 	A	--------------------------------	
								#addition:	 		(
									
-- 									local enfants_ndA = for nd in_nd_A.enfants collect nd
									
									for enfant in _nd_A.enfants do
										operation_booleenne				operation			enfant 			_nd_B
									
									_nd_A.ajouter_enfant	_nd_B
									result_nds = #( _nd_A  )
								)
								---------	B est un trou complet dans A	----> 	B dans A	--------------------------------	
								#soustraction:	 		(
									for enfant in _nd_A.enfants do
										operation_booleenne				operation			enfant 			_nd_B
									_nd_B.ajouter_enfant	_ndA
									result_nds = #( _nd_B  )
								)
								---------	Il ne reste que B. 	----> 	B	--------------------------------	
								#intersection:	 		(
									result_nds = #( _nd_B  )
								)
								
								#union:(
									_nd_A.ajouter_enfant		_nd_B
									result_nds = #( _nd_A  )
								)
						) --- fin case operation-	---------------------

						
					) ---- fin #interieur ---------------------------------------------------------
					
					
					
				#exterieur:	(			---->	A est entierement dans B			.---------------------------------------------------------
						debug "A est entierement dans B."
						----------  en fonction du type d'opération -------------
						case operation of (
								---------	B absorbe totalement A.					----> 	B	--------------------------------	
								#addition:	 		(
									result_nds = #( _nd_B  )
								)
								---------	B fait disparaitre A => 0 shapes.		----> 	-VIDE-	--------------------------------	
								#soustraction:	 		(
									result_nds = #( )
								)
								---------	Il ne reste que A.						----> 	A	--------------------------------	
								#intersection:	 		(		
									result_nds = #( _nd_A)
								)
								
								#union:(
									_nd_B.ajouter_enfant	_nd_A
									result_nds = #( _nd_B  )
								)
						) --- fin case operation-	---------------------
					) ---- fin #exterieur ---------------------------------------------------------
					
					
					
				#seCroisent:	(		---->	A et B se coupent, on va avoir du decoupage à faire ! 					---------------------------------------------------------
						local result_enfants	=#()
						local enfants_ndA = for nd in _nd_A.enfants	 collect nd
						for enfant in  enfants_ndA	 do
							result_enfants += 	operation_booleenne				operation			enfant 			_nd_B
-- 						_nd_A.enfants=  #()
						debug "A et B se croisent."
						result_nds	 		=	get_booleen_nds	  _nd_A 		_nd_B		operation:operation		intersections:pos_relative[2]
						result_nds	+= result_enfants
-- 						local result_enfants	=#()
-- 						local enfants_ndA = for nd in _nd_A.enfants	 collect nd
-- 						_nd_A.enfants=  #()
-- 						for enfant in  enfants_ndA	 do
-- 							result_nds += 	operation_booleenne				operation			enfant 			_nd_B
						
						result_nds
					/* 
						local calque_result		=	this.creer_calque	()
						local result_bool	 		=	get_booleen_nds	  _nd_A 		_nd_B		operation:operation		intersections:pos_relative[2]
						
						for nd in result_bool do 
							calque_result.ajouter_noeud	nd	operation:#union	

						result_nds = calque_result.noeuds
						 */
					) ---- fin #seCroisent ---------------------------------------------------------
					
			)	---	fin case position relative	------------------------------------
			
			result_nds
			
		),
		
		
		
		
		
		
		/* 
		fn inserer_noeud_dans_calque 		_nd_aInserer		_calque		operation:#union		=(
			debug "inserer_noeud_dans_calque()"
			debug "operation" var:operation
			
			local nds_du_calque	=	for nd in _calque.noeuds collect nd
			_calque.noeuds =#()
			if nds_du_calque.count == 0 then (
				debug "nds_du_calque.count == 0"
				_calque.noeuds  = #( _nd_aInserer )
			) else (
				for nd_calque in nds_du_calque do (
					local result_bool = operation_booleenne  	operation		nd_calque		_nd_aInserer	
					debug "---->	result_bool" var:result_bool
					_calque.noeuds	+=	result_bool
				)
			)
			debug "_calque.noeuds" var:_calque.noeuds
			_calque
		),
		 */
		
		
		
		
		fn operer_calques 	_calque_A		_calque_B	=(
			
			debug "operer_calques-------------ajouter_noeud--------------------------------------------------------"
			debug ( "operer_calques---->	operation :" + _calque_B.operation )
			debug ( "operer_calques---->	_calque_A :" + _calque_A.nom )
			debug ( "operer_calques---->	_calque_A.noeuds :"  ) var:_calque_A.noeuds param:#nom
			debug ( "operer_calques---->	_calque_B :" + _calque_B.nom )
-- 			debug ( "operer_calques---->	_calque_B.noeuds :" ) var:_calque_B.noeuds param:#nom
-- 			local calque_result = copy _calque_A
			local nds_B = for nd in _calque_B.noeuds	collect nd	--#()
-- 			_calque_B.noeuds	=#()
			
-- 			for nd in _calque_B.noeuds do(
-- 				append nds_B	nd
-- 				nds_B += nd.get_descendance ()
-- 			)
			
			debug ( "operer_calques---->	nds_B"  ) var:nds_B	 param:#nom
			debug "operer_calques--------------------------------------------------------------------------------"
			for nd_B in nds_B do (
				format"\n"
				debug ( "################### 		operer_calques---->	ajouter :" + nd_B.nom )
				debug_calque _calque_A
				_calque_A.ajouter_noeud		nd_B		operation:_calque_B.operation
-- 				debug "operer_calques---------> _calque_A.noeuds" var:_calque_A.noeuds
			)
			debug "--- FIN operer_calques--------------------------------------------------------------------------------"
			debug_calque _calque_A
			debug "--- FIN operer_calques--------------------------------------------------------------------------------"
			_calque_A
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
					calque			,
					
					
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
					fn inverser_enCreux =	(
						en_creux = not en_creux
						for enfant in enfants do
							enfant.maj_enCreux ()
					),
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
						if _neudEnfant.calque != undefined do
							_neudEnfant.calque.retirer_nd	_neudEnfant
						_neudEnfant.set_parent  	this
					),
					fn retirer_enfant		_enfant 		=(
						local id_enfant = findItem enfants	_enfant
						if id_enfant != 0 do
							deleteItem enfants id_enfant
					),
					fn set_pts  			_pts			= pts =  for pt in _pts collect pt,
					
					
					fn get_pts  			= for pt in pts collect pt,
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
					fn set_calque 		_calque =(
						if calque != undefined and calque  != _calque do
							calque.retirer_nd	this
						
						calque  = _calque
						maj_enCreux ()
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
-- 			debug "interpoler_shape()"
-- 			debug "_shp_node" var:_shp_node
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
		fn interpoler_pts_from_shape  	_shp_node	=( 
			
			local pts_shps = interpoler_shape 		_shp_node
			
			--- on les plaque sur z=0 -----
			for shp in pts_shps do	shp.z = 0
			
			pts_shps
		),
		
		
	------------------- INTERFACE -----------------------------------------------------------------------
		
		fn get_noeuds_from_pts 		_pts_shps 		nom:"nv_nd"	=(
			
-- 			local nd_porteur 		=	creer_noeud_booleen 	nom:"nd_provisoire"
			local result_nds	=	#()
			local pts_shps 		= _pts_shps
			
			local i = 0
			for pts_shp in pts_shps do (
				local nv_nd = creer_noeud_booleen 	pts:pts_shp	nom:( nom	+ "_" + (  i+=1 ) as string)
				append result_nds 	nv_nd
-- 				nd_porteur.enfants	=	operation_booleenne		#union	nd_porteur		nv_nd
				
-- 				if nom != unsupplied  do
-- 					nv_nd.nom = ( nom + "_" + (  i+=1 ) as string )
-- 				nv_nd.maj_enCreux ()
-- 				nv_nd.parent = undefined
			)
			
-- 			nd_porteur.enfants
			result_nds
		),
		
		fn integrer_noeud		_nd_A		_nd_B	=(
			debug "	#######	integrer_noeud	#######"
			local result
			
			local pos_relative	=	get_positionRelative_shapes 		( _nd_A.get_pts () ) 		( _nd_B.get_pts () )  		renvoyer_intersections:false	
			debug "	---->	pos_relative" var:pos_relative
			case pos_relative[1] of (
				
				#aCoté:	 		result = false
				
				#interieur:		 (
						------ on regarde s'il rentre dans les enfants	--------------
-- 						for enfant in _nd_A.enfants do (
						
						local a_ete_integre	=	false		
						local	enfants_ndA = 	for nd in _nd_A.enfants collect nd
						local i = 1
						while	 i <= enfants_ndA.count and not a_ete_integre	do (
							local ndA_enfant	=	enfants_ndA[ i ]
-- 								for nd_calque in noeuds	do (
							local integration_reussie	=	integrer_noeud		ndA_enfant	_nd_B
							if integration_reussie do a_ete_integre = true
							i += 1
						)
						
						if not a_ete_integre do
							_nd_A.ajouter_enfant 	_nd_B
							
						
						result = true
							
					) ---- fin #interieur	----------
					
					
					
				#exterieur:		(
					
						if _nd_B.parent != undefined then (
							local parent_B = _nd_B.parent 
							_nd_B.ajouter_enfant 	_nd_A
							append 	_nd_A.calque.noeuds	_nd_B
-- 							parent_B.ajouter_enfant	_nd_A
						) else (
							_nd_B.ajouter_enfant 	_nd_A
							append 	_nd_A.calque.noeuds	_nd_B
						)
						result = true
						
					) ---- fin #exterieur	----------
				
					
					
				#seCroisent:		(
				
						debug "###########################################################"
						debug "#############################################################"
						debug "#########											#########"
						debug "#########	/!\	hmm! probleme, il ne devrait y 		#########"
						debug "#########	avoir d'intersection de noeuds ici 		#########"
						debug "#########											#########"
						debug "#############################################################"
						result = #PROBLEME
					result = true
					) ---- fin #seCroisent	----------
			)
			
			result
		),
		
		
	public
		fn get_noeuds_from_shape 		_shape 			=(
			
			local nd_porteur 	=	creer_noeud_booleen 		nom:"nd_provisoire"
			local pts_shps 	= 	interpoler_pts_from_shape		_shape
			local result 		= 	get_noeuds_from_pts	pts_shps	nom:_shape.name
-- 			for nd in result  do
-- 				nd.nom = (_shape.name	+ "_" + (  i+=1 ) as string)
			result
			
		),
		fn creer_calque	shape_node:	nom:	=(
			
			debug "creer_calque()"
			if shape_node != unsupplied	do 
				debug "shape_node" var:shape_node.name
			if nom != unsupplied	do 
				debug "nom" var:nom
			
			
			
			----- un calque --------------------------------------------------------------------------------------------
			struct str_calque (
				private
					mgr_shape,
				
				public					
					noeuds			=	#(),
					operation	=	#addition,
					nom			="",
				
				
				---- fonctions	--------------------------------------------------------------
				private
						
					fn integrer_noeuds 	_nds =(
						local debug = mgr_shape.debug
						debug "-----------integrer_noeuds--------------------------"
						debug "----------->	_nds"var:_nds
							
							noeuds = #()
-- 						local nds_calque = noeuds
-- 						local nds_du_calque = #()
						for nd in _nds do (
							nd.set_calque this
							debug "----------->	 integrer"	var:nd.nom
							debug "----------->	 pts"	var:(nd.get_pts() )
							debug "----------->	 noeuds"	var:noeuds	param:#nom
							local a_ete_integre	=	false						
							local nds_calque = 	for nd in noeuds collect nd	
							local i = 1
							while	 i <= nds_calque.count and not a_ete_integre	do (
								local nd_calque	=	nds_calque[i]								
								local integration_reussie	=	mgr_shape.integrer_noeud	nd_calque		nd
								if integration_reussie do a_ete_integre	= true
								i += 1
								mgr_shape.debug_calque 	this
							)
							
							debug "----------->	a_ete_integre"var:a_ete_integre
							if not a_ete_integre do (
								noeuds = nds_calque
								append noeuds nd
							)
							
							mgr_shape.debug_calque 	this
						) --- fin pour chaque noeuds	_nds	----------------------------
						
						
					),
				public
					fn	ajouter_noeud		_nd_aInserer	operation:#union		=	(
-- 						mgr_shape.inserer_noeud_dans_calque 		_nd		this	
						mgr_shape.debug 		"CALQUE---->	ajouter_noeud"
						mgr_shape.debug ( 	"CALQUE---->	nom :" + nom )
						mgr_shape.debug ( 	"CALQUE---->	_nd_aInserer :" + _nd_aInserer.nom )
						mgr_shape.debug ( 	"CALQUE---->	operation :" + operation )
						
							
						mgr_shape.debug ( 	"CALQUE---->	noeuds :" + noeuds as string )
-- 						local nds_du_calque = #()
-- 						for nd in noeuds do(
-- 							append nds_du_calque	nd
-- 							nds_du_calque += nd.get_descendance ()
-- 						)
						
						
						if noeuds.count == 0 then (
							noeuds  = #( _nd_aInserer )
						) else (
							
							------- 
							local enfants_aInserer = for nd in _nd_aInserer.enfants  collect nd
							
							for nd_aInserer_enfant  in enfants_aInserer do (
								local result_bool = #()
								local nds_du_calque	=	for nd in noeuds collect nd
-- 								noeuds =#()
								for nd_calque in nds_du_calque do (
-- 									ajouter_noeud		nd_aInserer_enfant
									result_bool += mgr_shape.operation_booleenne  	operation		nd_calque		nd_aInserer_enfant
									mgr_shape.debug "result_bool" var:result_bool
									mgr_shape.debug_calque	this
								)
								integrer_noeuds		result_bool
							)
							
								mgr_shape.debug "****************************************************************** <--- là" 
							mgr_shape.debug_calque	this
							local result_bool = #()
							local nds_du_calque	=	for nd in noeuds collect nd
							for nd_calque in nds_du_calque do (
-- 									ajouter_noeud		nd_aInserer_enfant
								result_bool += mgr_shape.operation_booleenne  	operation		nd_calque		_nd_aInserer
								mgr_shape.debug "result_bool" var:result_bool
							)
								mgr_shape.debug "****************************************************************** <--- et là" 
							integrer_noeuds		result_bool
							
						)
						
									mgr_shape.debug_calque	this
-- 						_nd_aInserer.set_calque	this
						
					),
					fn retirer_nd		_nd 		=(
						local id_nd= findItem noeuds	_nd
						if id_nd != 0 do
							deleteItem noeuds id_nd
					),
					fn get_pts =(
						local pts_result =#()						
						for nd in noeuds do 
							pts_result += mgr_shape.creer_pts_pourFace  nd
						
						pts_result
					),
					fn initialiser 	_mgr_shape 	= mgr_shape = _mgr_shape
					
			) ---- fin struct calque --------------------------------------------------------------------------------------------
			local nv_calque = str_calque 	()
			nv_calque.initialiser 	this
			
			
			
			
			
			if shape_node != unsupplied	do (
				nv_calque.nom 	= shape_node.name
				local noeuds 			= get_noeuds_from_shape		shape_node
				debug "noeuds" var:noeuds
				for nd in noeuds do (
					nv_calque.ajouter_noeud 	nd
					
					debug "----------->	nv_calque" var:nv_calque
				)
			)
			
			if nom != unsupplied do
				nv_calque.nom 		= nom
			
			
			debug_calque	nv_calque
			nv_calque
			
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









