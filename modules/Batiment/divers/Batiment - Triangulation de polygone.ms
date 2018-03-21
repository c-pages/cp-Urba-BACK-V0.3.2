









	struct str_triangulation_shape  (
		
		
		--- si un point est dans un triangle	-------------
		fn point_est_aGaucheDuSegment	_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
-- 				format "point_est_aGaucheDuSegment : %\n" sens
			sens
			
		),

		--- si un point est à gauche d'un segment	-------------
		fn est_dansTriangle	_pt_tri_1	_pt_tri_2	_pt_tri_3	_pt_aTester =(
			if point_est_aGaucheDuSegment  _pt_tri_1 	_pt_tri_2 	_pt_aTester and point_est_aGaucheDuSegment  _pt_tri_2 	_pt_tri_3 	_pt_aTester  and point_est_aGaucheDuSegment  _pt_tri_3 	_pt_tri_1 	_pt_aTester then
				true
			else false
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


		------- le fonction principale du decoupage ---------------------
		--- renvois le tableau des triangles decoupés -------
		fn trianguler  _pts =(
			
			format" ######### trianguler ###### pts:%\n"  _pts
			
			local pts_poly 			= deepcopy _pts
			
			local result_triangles	= #()
			
			--------------- tant qu'il reste plus de trois point dans le polygone ------------------
			while pts_poly.count >= 3 do (
				
				
				-- on commence avec le point le plus a gauche du polygone--
				local id_pt_aTester 	= point_lePlusAGauche  pts_poly		
					format "--------------  id_pt_aTester --> :%  ------------------------\n"  id_pt_aTester
				-- le point d'avant ---
				local id_pt_avant 	= if id_pt_aTester == 1 	then	pts_poly.count 
																				else	id_pt_aTester - 1		
				-- et le point d'aprés ---
				local id_pt_apres 	= if id_pt_aTester == pts_poly.count 	then	1
																									else	id_pt_aTester + 1
				--- Le triangle à tester ---
				local triangle_aTester = #(pts_poly[id_pt_avant], pts_poly[id_pt_aTester], pts_poly[id_pt_apres])
				
				format "triangle_aTester --> :(%, %, %)\n"  id_pt_avant  id_pt_aTester  id_pt_apres
				
				----- Puis on cherche parmis les points restants du polygone ceux qui seraient à l'interieur du trangle ----		
				local ids_pts_dansTriangle =#()		
				for i = 1 to pts_poly.count do(
					local pt_atester 				= pts_poly[i]
					local pt_dansTriangle 		= est_dansTriangle 	triangle_aTester[1]	 triangle_aTester[2]	 triangle_aTester[3]	  pt_atester
					
-- 					format "	i:%	pt_dansTriangle :%\n"  i  pt_dansTriangle
					
					if pt_dansTriangle do append ids_pts_dansTriangle  i
				)
				format "		ids_pts_dansTriangle --> :%\n"  ids_pts_dansTriangle
				
				if ids_pts_dansTriangle.count > 0 then (
					
					
-- 					format "		************	On a un point dans un triangle !!! --> id:%		**************\n"  id_pt_aTester
					local pts_dansTriangle	=	for id_pt in ids_pts_dansTriangle collect pts_poly[id_pt]
						
					---- si on en trouve : on cherche le plus éloigné de la 'diagonale' du triangle ----
					local IDpt_diagonal = 	point_lePlusLoinDuSegment  	pts_dansTriangle		triangle_aTester[3]		triangle_aTester[1]
					local IDpt_decoupe = ids_pts_dansTriangle[IDpt_diagonal ]
					
					format "			IDpt_decoupe --> :%\n"  IDpt_decoupe
					format "			id_pt_aTester --> :%\n"  id_pt_aTester
					
					-- on decoupe le polygone en 2 avec la digonale entre ce dernier point et le point à tester --
					--- premier polygone découpé -------
					local IDsPts_poly1  = #(IDpt_decoupe)
					local pts_poly1  = #()
					local  i = boucler  pts_poly  (id_pt_aTester ) 
					while i 	!= IDpt_decoupe  do (
						format "				creation du poly 1 : i: --> :%\n"  i
						append IDsPts_poly1		 i 
						i = boucler 	pts_poly		(i+1) 	
					)				
					pts_poly1 = for idPt in IDsPts_poly1 collect pts_poly[idPt]
					format "			---->	IDsPts_poly1 --> :%\n"  IDsPts_poly1
					
					--- second polygone découpé -------
					local IDsPts_poly2  = #(id_pt_aTester)
					local pts_poly2  = #()
					local  i = boucler  pts_poly  (IDpt_decoupe ) 
					while i 	!= id_pt_aTester   do (
						format "			creation du poly 2 : i: --> :%\n"  i
						append IDsPts_poly2		 i 
						i = boucler 	pts_poly		(i+1) 	
					)				
					pts_poly2 = for idPt in IDsPts_poly2 collect pts_poly[idPt]
					format "			---->	IDsPts_poly2 --> :%\n"  IDsPts_poly2
					

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
			
		) --- fin fonction decoupage polygone ----------

	) --- fin structure triangulation

	
	
	
mgr_triangulation = str_triangulation_shape()
	/* 
pt1 	= $point001.pos
pt2 	= $point002.pos
pt3	= $point004.pos
pt_atester	= $point003.pos
 */
shp = $Line008
points =#()
for i = 1 to numknots shp 1 do
		append points (getKnotPoint shp 1 i )
 
-- point_lePlusAGauche points
 clearlistener ()
-- IDpt_lePlusLoin = point_lePlusLoinDuSegment  points  pt1  pt_atester
-- point box:on axistripod:off centerMark:off cross:off  isSelected:true pos:points[IDpt_lePlusLoin]

-- mgr_triangulation.est_dansTriangle  points[3]  points[1]  points[2]    points[5]




clearSelection ()

triangles =	mgr_triangulation. trianguler   points
for tri in triangles do (
	sp = splineShape pos:tri[1]
	addnewSpline sp
	addKnot sp  1  #corner #line tri[1]
	addKnot sp  1  #corner #line tri[2]
	addKnot sp  1  #corner #line tri[3]
	close sp 1
updateShape sp
	selectmore sp
)
 
-- point_lePlusLoinDuSegment
-- point_parRapportA_segment  pt1 pt2 	pt3
-- est_dansTriangle pt1 pt2 pt3 pt_atester

