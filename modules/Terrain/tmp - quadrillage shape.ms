

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
		fn get_longueur_segment		_id_spline	_id_pt 	=(
			
			local tab_longueurs_sgts		=	getSegLengths 	m_shp_contour 	_id_spline	 cum:false byVertex:true numArcSteps:100
			local nbr_pts_total 				=	numknots	 		m_shp_contour	_id_spline
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
		
		
		
	public
		---- mutateur-------------------------------
		fn get_pts_from_shape			_shp 	=	(
			
			local pts_result =  	 interpoler_shape		_shp
			
			
			for pts_spline_contour in m_pts_contour do
				if not est_sensPositif 	pts_spline_contour 	 do
					pts_spline_contour = changer_sens		pts_spline_contour
				
			m_pts_contour
		)
		
			
	
)

struct str_quadriller (
	

	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =		try if true  do ::debuger 	_txt	prefix:"str_quadriller"	  	var:var	 param:param		catch (),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	
	
	
	private
		m_shp_contour 	=	undefined,
		m_pts_contour 	=	#(),
		m_resolution 		=	100,
		
		
	public
		----- case ---------------
		fn get_pts_case		_pt	decalle_id_x:0	decalle_id_y:0	=(
			
			local index_x				=	floor ( _pt.x / m_resolution ) + decalle_id_x
			local index_y				=	floor ( _pt.y / m_resolution ) + decalle_id_y
			local pts_case 	  = #()
			append pts_case		[index_x * 	m_resolution, index_y * 	m_resolution, _pt.z ]
			append pts_case		[( index_x + 1 ) * 	m_resolution , index_y * 	m_resolution,  _pt.z ]
			append pts_case		[( index_x + 1 ) * 	m_resolution , ( index_y + 1 ) * 	m_resolution ,  _pt.z ]
			append pts_case		[index_x * 	m_resolution , ( index_y + 1 ) * 	m_resolution ,  _pt.z ]
-- 			
-- 			-- debug---------
-- 			for pt_case in pts_case do	point pos:pt_case	size:50	wirecolor:blue 	box:off	centerMark:off		axisTripod:off		cross:on name:"point case"
-- 			-- debug---------
			
			pts_case
		),
		
		
		
		fn point_estAGauche		_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
-- 				format "point_est_aGaucheDuSegment : %\n" sens
			sens
			
		),
		----- accessions divers  ---------------
		fn get_longueur_segment		_id_spline	_id_pt 	=(
			
			local tab_longueurs_sgts		=	getSegLengths 	m_shp_contour 	_id_spline	 cum:false byVertex:true numArcSteps:100
			local nbr_pts_total 				=	numknots	 		m_shp_contour	_id_spline
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
		
		fn ordonner_Points 				_pts	 		=(
			
			local x_min	=	1e+10
			local y_min	=	1e+10
			local index_premier = 0
			for i = 1 to _pts.count  do  (
				if _pts[i].x < x_min do
					if _pts[i].y < y_min do
						index_premier = i
			)
-- 			format "index_premier : %\n"	index_premier
			local i = 0
			local result = #()
			local secours = 1
			while	 i !=  index_premier and secours < 20 do  (
-- 			format "i : %\n"	i
				if i == 0 do i = index_premier
				local pt = _pts [i]
				append result pt
				
				secours += 1
				 
				i += 1 
				if i > _pts.count do i = 1
				
			)
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
		
		
		
			
		fn comparer_tableaux 	first 	second =
		(
			result = true
			if first.count != second.count then
				result = false
			else
				for i = 1 to first.count do
					if first[i] != second[i] do result = false
			result
		),
		
		fn trouve_dansTableau		_tab	_val	=(
			result = 0
			for i_tab = 1 to  _tab.count do 
				if comparer_tableaux	_tab[i_tab] 	_val do 
					result = i_tab
			
			result
		),
		
		
		----- Interface  -------------------------------------------------------------------------
	public
		---- mutateur-------------------------------
		fn set_shape			_shp 	=	(
			
			m_shp_contour 	= 	_shp
			
			m_pts_contour 	= 	interpoler_shape		_shp
			
			for pts_spline_contour in m_pts_contour do
				if not est_sensPositif 	pts_spline_contour 	 do
					pts_spline_contour = changer_sens		pts_spline_contour
				
			m_pts_contour
		),
		fn set_resolution		_val 	= m_resolution = _val,
		
		
		
		
		
		
		
		
		
		
		
		
		
		---- QUADRILLER ---------------------------------------------------------------------
		fn quadriller	=(
			
			debug "---------------quadriller-------------"
			
			
			--- une intersection -------
			struct str_intersection (
				pos,
				id_pt_test,
				id_spline_test,
				id_pt_courant,
				id_spline_courant
			)			
			
			
			
			
			if m_shp_contour != undefined do (
				
				
				
				------------ 	( 1 ) 	On commence par construire les bords, toutes les cases tronquées ----------------------------------------------------
				---- pour chacune des splines du shape ----------------
-- 				for id_spline_contour	=	1	to numsplines  m_shp_contour do (
				
				
				
				--- on prend le premier point de cette spline -------------
				local id_spline_courant 	=	1
				local shp_courant 			= 	m_pts_contour
				local pts_shp_courant		=	shp_courant[id_spline_courant]
				local id_pt_courant 			= 	0
				local pt_initial 				=  pts_shp_courant[ 1 ]
				local pt_courant 				= 	pt_initial
				local pts_case				=	get_pts_case	pt_courant
				local pts_shps_test			=	#( get_pts_case	pt_courant )
				local sens 						=	1
				
				
				local pt_retour_initial	
				
				local	on_continue_leTour = true
				local compteur_general = 0
				
				
			
					local pts_aConstruire_total 	=#()
				local pt_retour 				= undefined
				local id_pt_retour 			= 1
				local id_spline_retour 		= id_spline_courant
				local pts_case_retour		= #()
				while on_continue_leTour and compteur_general < 100 do (
					
					compteur_general += 1
					
					local pts_aConstruire 			=#()
					
					-- debug---------
-- 					debug "###############	on_continue_leTour	###############" 
-- 					debug "compteur_general" var:compteur_general
					
					for pt_case in pts_case do	point pos:pt_case	size:50	wirecolor:blue 	box:off	centerMark:off		axisTripod:off		cross:on name:( "point case " + compteur_general as string )
					-- debug---------
			
			
					pts_aConstruire 	= #( pt_courant )
					pt_initial 			= pt_courant
					
-- 					debug "pt_initial" var:pt_initial
					
					pt_retour 				= undefined
					id_pt_retour 			= 1
					id_spline_retour 		= id_spline_courant
					pts_case_retour		= #()
					
					
					------------ cheminement decoupe  --------------------------------------------
					local compteurSecours 	= 1
					local on_continue 			= true
					while on_continue and compteurSecours <100	do (
						
-- 						debug "####	POINT"	var:compteurSecours
-- 						debug "	---->	pt_courant"	var:pt_courant
-- 						debug "	---->	pts_shp_courant"	var:pts_shp_courant
-- 						debug "	---->	pts_shps_test"	var:pts_shps_test
						
						--- initialisation  -----
						if id_pt_courant == 0 do id_pt_courant = 1
						
						--- le point suivant ----------
						local id_pt_suivant 	= id_pt_courant + sens
						if id_pt_suivant > pts_shp_courant.count do  id_pt_suivant = 1
						if id_pt_suivant < 1  do  id_pt_suivant = pts_shp_courant.count 
							
						local pt_suivant 		= pts_shp_courant[ id_pt_suivant ]
						
-- 						debug "	---->	pt_suivant"	var:pt_suivant
						
						
						--- on test les intersections ----------- ----------
						local id_spline_test = 1
						local intersections 	= #()
						while  id_spline_test <=  pts_shps_test.count do (
							
-- 							debug "		---->	id_spline_test"	var:id_spline_test
							
							local pts_spline_test = pts_shps_test[id_spline_test]
							
							local	id_pt_test 		= 1
							while id_pt_test <= pts_spline_test.count do (
								
-- 								debug "			---->	id_pt_test"	var:id_pt_test
								
								--- les points ----
								local pt_test 				= pts_spline_test[id_pt_test]
								local id_pt_test_svt		= if id_pt_test == pts_spline_test.count  then 1 else id_pt_test + 1
								local pt_test_suivant 	= pts_spline_test[id_pt_test_svt]
								
								--- le test ----------
								local pt_intersection 			= get_intersection_vecteurs	 pt_test 	pt_test_suivant		pt_courant		pt_suivant							
								if pt_intersection != undefined 	and distance pt_intersection pt_courant > .001	do (
-- 											debug "	---->	On a une intersection !"	
	-- 										debug "	---->	distance	 intersection.pos  pt_courant"	var:( distance	pt_intersection  pt_courant )
	-- 										debug "	---->	distance	pt_intersection  pt_courant > .001	"	var:( distance	pt_intersection  pt_courant > .001	 )
											append intersections ( str_intersection 	pos:						pt_intersection		\
																									id_pt_test:				id_pt_test				\
																									id_spline_test:			id_spline_test			\
																									id_pt_courant:		id_pt_courant			\
																									id_spline_courant:	id_spline_courant	)
								)
								--- suivant --------------
								id_pt_test += 1
								
							)
							id_spline_test += 1
						)
							
						
						------------ 	( 1-2 ) 	Si on a intersection, alors on change de ligne  ----------------------------------------------------
						if intersections.count > 0 then (
							
							---- on choisi la plus proche des intersections trouvés ---------------------
							local intersection
							local distMin = 1e+10
							for intersec in intersections do
								if distMin > distance pt_courant intersec.pos do (
									distMin = distance pt_courant intersec.pos
									intersection = intersec
								)
							
							
							
-- 							debug "		**** 	POINT INTERSECTION"
-- 							debug "			---->	intersection"	var:intersection
-- 							debug "			---->	distance	 intersection.pos  pt_courant"	var:(distance	intersection.pos  pt_courant)
							point 	pos:intersection.pos	size:30	wirecolor:red	 box:off	centerMark:on		axisTripod:off		cross:on name:"point intersection"
							
							
							--- on stock le premiere intersection, pour pouvoir y revenir ------
							if pt_retour == undefined do (
								pt_retour 			= 	intersection.pos
								id_pt_retour 		= 	id_pt_courant
								id_spline_retour 	= 	id_spline_courant
								
								
								pts_case_retour	=	deepcopy 	pts_case
								
-- 							debug "		**** 	 intersection.id_pt_test intersection.id_pt_test intersection.id_pt_test intersection.id_pt_test intersection.id_pt_test" var: intersection.id_pt_test
								 
-- 							debug "		pts_case_retour" var: pts_case_retour
								case intersection.id_pt_test of (
									1: pts_case_retour.y	-=	m_resolution
									2: pts_case_retour.x	+=	m_resolution
									3: pts_case_retour.y	+=	m_resolution
									4: pts_case_retour.x	-=	m_resolution
								) 
-- 							debug "		pts_case_retour" var: pts_case_retour
								/* 
								case intersection.id_pt_test of (
									1: pts_case_retour	=	get_pts_case	pt_retour		decalle_id_y:	-1
									2: pts_case_retour	=	get_pts_case	pt_retour	--	decalle_id_x:	1
									3: pts_case_retour	=	get_pts_case	pt_retour		decalle_id_y:	1
									4: pts_case_retour	=	get_pts_case	pt_retour		decalle_id_x:	-2
								)*/
							)
							
							local pt_test_intersec = pts_shps_test[	intersection.id_spline_test ][intersection.id_pt_test]
							if not point_estAGauche			pt_courant		pt_suivant 		pt_test_intersec 	 then (							
								id_pt_courant 		= intersection.id_pt_test
								sens 					= 1
							) else(							
								id_pt_courant 		= intersection.id_pt_test + 1
								sens 					= -1
							)
								
							pt_courant 					= intersection.pos
							
							local tmp     			=  deepcopy shp_courant
						
							id_spline_courant		=  intersection.id_spline_test 
							shp_courant 			= 	pts_shps_test
							pts_shp_courant		=	shp_courant[id_spline_courant]
							pts_shps_test			=	tmp
							
							
							
						) else  ( ---- si on a pas d'intersection on rajoute le point suivant -----------------
							
-- 							debug "		**** 	POINT suivant"
-- 							append pts_aConstruire		pt_suivant
						
							--- indentation---------
							id_pt_courant += sens
							if id_pt_courant > pts_shp_courant.count do id_pt_courant = 1
							if id_pt_courant < 1  do id_pt_courant = pts_shp_courant.count
							
							pt_courant = pts_shp_courant[ id_pt_courant ]
						)
						
						
						
						--- sortie ----
						compteurSecours+= 1
-- 						debug "			-----test de fin de face -----"
-- 						debug "				-----> pt_initial" var:pt_initial
-- 						debug "				-----> pt_courant" var:pt_courant
-- 						debug "				-----> pt_courant ==  pt_initial " var:(pt_courant ==  pt_initial )
-- 						debug "				-----> distance	pt_courant   pt_initial " var:(distance	pt_courant   pt_initial )
						
						
						if  distance	pt_courant   pt_initial < .01 then (
							on_continue = false
							format"\n"
							debug "pts_aConstruire" var:pts_aConstruire
							debug "pts_aConstruire_total" var:pts_aConstruire_total
							debug "trouve_dansTableau	----> " var:(trouve_dansTableau		pts_aConstruire_total	pts_aConstruire)
							
							pts_aConstruire =  ordonner_Points  pts_aConstruire 
							
							---- on construit notre face ----------------------------------------
							if  trouve_dansTableau		pts_aConstruire_total	pts_aConstruire == 0	do (
								
								--- DEBUG----------------------
								local sp = splineShape name:(uniqueName "result")
								addnewSpline sp						
								for pt in pts_aConstruire do
									addknot sp 1 #corner #curve  pt
								close sp 1
	-- 							updateShape sp
								addModifier	sp (edit_poly () )
								select sp
								--- DEBUG----------------------
								
								append pts_aConstruire_total		pts_aConstruire
							)
						) else 
							append pts_aConstruire		 pt_courant
						
					) ---- fin while cheminement decoupe ------------
					
					
					
					
					
					
					---- on retourne au point de la premiere intersection --------------------
					if pt_retour != undefined then  (
						
						point 	pos:pt_retour		size:30	wirecolor:yellow box:on	centerMark:off		axisTripod:off		cross:off name:"point retour"
-- 						debug "RETOUR	!!!!!!!!!!!"
-- 						debug "---->	pt_retour" var:pt_retour
-- 						debug "---->	id_pt_retour" var:id_pt_retour
-- 						debug "---->	id_spline_retour" var:id_spline_retour
						
						pt_courant				=	pt_retour
						id_pt_courant			= 	id_pt_retour
						id_spline_courant		=	id_spline_retour
						
						shp_courant 			= m_pts_contour
						pts_shp_courant		=	shp_courant[id_spline_courant]
						pts_case				=	pts_case_retour
						pts_shps_test			=	#( pts_case )
						
						
						----- si on a fini le tour du contour, on change de spline -------------------------
						if pt_retour_initial != undefined and distance	pt_retour_initial  pt_courant < .01  do (
							id_spline_courant 	+=1
							if id_spline_courant <=  m_pts_contour.count then (
								
								id_pt_courant			=	1
								pts_shp_courant		=	shp_courant[id_spline_courant]
								pt_courant				=	pts_shp_courant[ 1 ]
								pts_case				=	pts_case_retour
								pts_shps_test			=	#( pts_case )
								pts_case				=	get_pts_case	pt_courant
								pts_shps_test			=	#( get_pts_case	pt_courant )
								pt_retour_initial	= undefined
								
								point 	pos:pt_courant		size:80	wirecolor:yellow box:on	centerMark:off		axisTripod:off		cross:off name:"point retour"
								
							---- sinon on arrete tout -------------------
							)	else	on_continue_leTour = false
							
						)
						
						
						
						if 	pt_retour_initial	== undefined do
							pt_retour_initial = pt_retour
						
					) else (
						on_continue_leTour = false
						
						
					)
					/* 
					
					if on_continue_leTour do (
						---- on construit notre face ----------------------------------------
						--- DEBUG----------------------
						local sp = splineShape name:(uniqueName "result")
						addnewSpline sp						
						for pt in pts_aConstruire do
							addknot sp 1 #corner #curve  pt
						close sp 1
						updateShape sp
						addModifier	sp (edit_poly () )
						select sp
						--- DEBUG----------------------
					) */
					
					
				)---- fin for splines -----------------
				
				
			) --- fin if contour existe ---------
			
		) --- fin quadriller -------
	
) ---- fin struct -----------------------------------------------------------




clearListener ()


(
		quadrillage = str_quadriller ()

-- 		pts = quadrillage.set_shape	$'Line001'


-- 		-- for spl in pts do
-- 		-- 	for pt in spl do
-- 		-- 		point pos:pt	size:1
-- 			
-- 			
		for spl in pts do (
			
			local sp = splineShape name:"result"
			addnewSpline sp
			
			for pt in spl do
				addknot sp 1 #corner #curve  pt
			close sp 1
			updateShape sp
			
		)


-- 		quadrillage.set_shape	$'tracé cadre'
pts =		quadrillage.set_shape	$'Line007'
-- 		quadrillage.quadriller ()



)



