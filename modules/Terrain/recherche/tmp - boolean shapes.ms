
struct str_terrain_booleen		(
	
	
	private
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"urba | str_terrain_booleen"	  	var:var	 param:param		catch (),
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
-- 	private
	public ---  <----  public pour debug -----------
	
		--- si un point est a gauche du segment	-------------
		fn point_est_aGaucheDuSegment	_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
-- 				format "point_est_aGaucheDuSegment : %\n" sens
			sens
			
		),

		--- si un point est dans un triangle	-------------
		fn est_dansTriangle		_pt_tri_1	_pt_tri_2	_pt_tri_3	_pt_aTester =(
			if point_est_aGaucheDuSegment  _pt_tri_1 	_pt_tri_2 	_pt_aTester and point_est_aGaucheDuSegment  _pt_tri_2 	_pt_tri_3 	_pt_aTester  and point_est_aGaucheDuSegment  _pt_tri_3 	_pt_tri_1 	_pt_aTester then
				true
			else false
		),
		
		
		fn survol  	_pt_aTester			_pts_triangles_shape 	=(
			local result = false
			for pts_tri in _pts_triangles_shape do
				if est_dansTriangle		pts_tri[1]	pts_tri[2]	pts_tri[3]	_pt_aTester do
					result = true
			result			
		),
		
		
		
		---- Renvois lindex du point situé le plus à gauche de la liste ------
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


		----------------- tableaux -----------------
		fn boucler 							_array				_id_item 		=(
			
			if _id_item >	_array.count do _id_item = mod _id_item _array.count
			if _id_item < 1 do _id_item += _array.count
			_id_item as integer
		),


		---angle  2 vecteurs ----------
		fn	get_angleVecteurs v1 v2 =(
			result_angle = acos(dot (normalize v1) (normalize v2))
-- 			format "angle entre vec :%\n" result_angle
			result_angle
		),



		---- renvois le point le plus éloigné du segment parmis la liste des 	'_pts'	 ---------
		fn point_lePlusLoinDuSegment 			_pts			_pt_seg1		_pt_seg2 	=(
			local result_index 	= 0
			local dist_max 		= 0
			for i = 1 to _pts.count do (
				local pt = _pts[i]
				local vec_1 = (_pt_seg2  -  _pt_seg1)
				local vec_2 =  ( pt  -  _pt_seg1)
				local angle_test = get_angleVecteurs    vec_1 vec_2
				local dist_test = ( dot  vec_1  vec_2 ) * sin angle_test
				if dist_test > dist_max do (
					dist_max 		= dist_test
					result_index 	= i
				)
			)
			result_index
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
	
	

		------- le fonction  traingulation d'un polygone  ---------------------
		--- renvois le tableau des triangles decoupés -------
		fn trianguler  _pts =(
			
			local pts_poly 			= deepcopy _pts
			
			local result_triangles	= #()
			
			--------------- tant qu'il reste plus de trois point dans le polygone ------------------			
			while pts_poly.count >= 3 do (
				
				
				-- on commence avec le point le plus a gauche du polygone--
				local id_pt_aTester 	= point_lePlusAGauche  pts_poly		
				
				-- le point d'avant ---
				local id_pt_avant 	= if id_pt_aTester == 1 	then	pts_poly.count 
																				else	id_pt_aTester - 1		
				-- et le point d'aprés ---
				local id_pt_apres 	= if id_pt_aTester == pts_poly.count 	then	1
																									else	id_pt_aTester + 1
				--- Le triangle à tester ---
				local triangle_aTester = #(pts_poly[id_pt_avant], pts_poly[id_pt_aTester], pts_poly[id_pt_apres])
				
				
				----- Puis on cherche parmis les points restants du polygone ceux qui seraient à l'interieur du trangle ----		
				local ids_pts_dansTriangle =#()		
				for i = 1 to pts_poly.count do(
					local pt_atester 				= pts_poly[i]
					local pt_dansTriangle 		= est_dansTriangle 	triangle_aTester[1]	 triangle_aTester[2]	 triangle_aTester[3]	  pt_atester
					
					if pt_dansTriangle do append ids_pts_dansTriangle  i
				)
				
				if ids_pts_dansTriangle.count > 0 then (
					
					
-- 					format "		************	On a un point dans un triangle !!! --> id:%		**************\n"  id_pt_aTester
					local pts_dansTriangle	=	for id_pt in ids_pts_dansTriangle collect pts_poly[id_pt]
						
					---- si on en trouve : on cherche le plus éloigné de la 'diagonale' du triangle ----
					local IDpt_diagonal = 	point_lePlusLoinDuSegment  	pts_dansTriangle		triangle_aTester[3]		triangle_aTester[1]
					local IDpt_decoupe = ids_pts_dansTriangle[IDpt_diagonal ]
					
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
					
					
					-- on vide les points de poly car on a lancé la fonction recursivement sur les deux poly trouvés, et on veut sortir de la boucle----
					pts_poly = #()
					
				) else (
					---- si on en trouve pas: on peut creer le triangle et retirer le point tester de la liste du polygone ----
					append 	result_triangles  triangle_aTester
					deleteItem pts_poly  id_pt_aTester
					
				)
				
			)  --- fin du while il ya plus de 3 pts dans le polygone ------
			
			result_triangles
			
		), --- fin fonction decoupage polygone ----------

		
		
		
		------- savoir si un shapes est ' l'interieur d'un autre (trou boolean), se croisent ou à l'exterieur ---------
		fn get_positionRelative_shapes 		_pts_shp1		_pts_shp_aTester 	=(
			
			struct	str_intersection	(
				pos,
				id_pt_1 =0,
				id_pt_2 =0				
			)
			
			
			local result = #exterieur		---- #exterieur,  #interieur, ou #intersection --------------
			local intersections =#()
			
			---- on regadre si les edges se coupent --- si oui --->  #intersection -----------------			
			for i = 1 to _pts_shp1.count do (
				
				local pt_shp1			= _pts_shp1[ i ]
				local i_svt	=	if i == _pts_shp1.count  then 1 else i + 1
				local pt_shp1_svt	= _pts_shp1[ i_svt ]
				
				for j = 1 to _pts_shp_aTester.count do (
					
					local pt_shp2			= _pts_shp_aTester[ j ]
					local j_svt	=	if j == _pts_shp_aTester.count  then 1 else j + 1
					local pt_shp2_svt	= _pts_shp_aTester[ j_svt ]
					
					local intersection = get_intersection_vecteurs		pt_shp1   pt_shp1_svt		pt_shp2		pt_shp2_svt 
					if intersection != undefined do
						append intersections ( str_intersection pos:intersection		id_pt_1:i 	id_pt_2:j 	)
						
				)
			)
			
			---- si on a des intersections, alors ils se croisent ------------------------------------
			if intersections.count > 0 then
				result = #intersection
			
				
			else (
				---- s'il ne se croisent pas alors ils sont tout à l'interieur ou à l'extierieur l'un de l'autre -------------------------
				local pts_triangles_shp1 = trianguler	_pts_shp1
				
				if survol  	_pts_shp_aTester[1]	pts_triangles_shp1	 then 
					result = #interieur
				else 
					result = #exterieur
				
			)
			
			result
		),


		fn get_shapes_pointsProche 		_pts_shp1		_pts_shp2 =(
			
			struct str_connexion (
				id_pt_shp1	=	0,
				id_pt_shp2	=	0
			)
			
			
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
			
		),


		fn fusionner_pts_booleen		_pts_shp1		_pts_shp2 =(
			
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
			
		),
	
	public
		---- on entre une liste de listes de points  (nos differents shapes à analyser )------------
		---- renvois une liste des points avec fusion des shapes à trous en une seule liste pour creéation de face troué ---------
		fn analyser_booleens 	_shapes_pts_aAnalyser 	=(
			
			---- on cherche les booleens --------------------
			local pts_shps			=	 _shapes_pts_aAnalyser
			local pts_booleen		= 	#()
			local pts_shps_result 	=	#()
			for i = 1 to pts_shps.count - 1 do (
				local pts_shp1	= pts_shps[ i ]
				for j = i+1 to pts_shps.count do (
					local pts_shp2	= pts_shps[ j ]
					local posRelative = get_positionRelative_shapes		pts_shp1  	pts_shp2
					format "posRelative : %\n" posRelative
				)
			)
			
			
			
		)
	
	
	
	
	
) --- fin struct booleen -----------------------------------



clearlistener ()

shp1 = $Line008
booleen = str_terrain_booleen ()
pts = #()
for spl = 1 to Numsplines shp1 do 
	append	pts	( for i = 1 to numknots	shp1 spl	collect getKnotPoint	shp1 spl i )


booleen.analyser_booleens	pts





/* 
pts_tri = booleen.trianguler	pts[1]



booleen.survol  	$point001.pos			pts_tri 












-- shp2 = $Line003

	

pts_result = fusionner_pts_booleen		pts_1 	pts_2




			sp = splineShape name:"result"
			addnewSpline sp
			
			for pt in pts_result do
				addknot sp 1 #corner #curve  pt
			close sp 1
-- 			updateShape sp
select sp


 */







