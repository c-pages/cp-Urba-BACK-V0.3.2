



struct str_terrain_booleen		(
	
	
	private
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"urba | str_terrain_booleen"	  	var:var	 param:param		catch (),
		m_tab_format_nd = "	|	",
		fn	format_noeud  _nd =(			
			local indent_prfix = "|    "
			format (  m_tab_format_nd + _nd.nom + "\n" )
			if _nd.enfants.count >0 	do	m_tab_format_nd += indent_prfix
			for enft in _nd.enfants 	do 	format_noeud enft
			if _nd.enfants.count >0 	do	m_tab_format_nd = substring m_tab_format_nd 1 (	m_tab_format_nd.count -	indent_prfix.count )
		),
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		
-- 	private
	public ---  <----  public pour debug -----------
	
		--- si un point est a gauche du segment	-------------
		fn point_estAGauche	_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
-- 				format "point_estAGauche : %\n" sens
			sens
			
		),

		--- si un point est dans un triangle	-------------
		fn est_dansTriangle		_pt_tri_1	_pt_tri_2	_pt_tri_3	_pt_aTester =(
			if point_estAGauche  _pt_tri_1 	_pt_tri_2 	_pt_aTester and point_estAGauche  _pt_tri_2 	_pt_tri_3 	_pt_aTester  and point_estAGauche  _pt_tri_3 	_pt_tri_1 	_pt_aTester then (
-- 				if _pt_aTester == _pt_tri_1 or _pt_aTester == _pt_tri_2 or _pt_aTester == _pt_tri_3 then
-- 					false
-- 				else
					true
			) else false
		),
		
		
		fn survol  	_pt_aTester			_pts_triangles_shape 	=(
			local result = false
			for pts_tri in _pts_triangles_shape do
				if est_dansTriangle		pts_tri[1]	pts_tri[2]	pts_tri[3]	_pt_aTester do
					result = true
			result			
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
			local dist_max 		= -1e+10
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
					local IDpt_decoupe = 	ids_pts_dansTriangle[IDpt_diagonal ]
					
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
		
		fn get_aire_BB  _pts_shp =(
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
		
		--- Renvois la distance la plus courte entre les points des deux shapes ----------
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
		
		
		------- savoir si un shapes est ' l'interieur d'un autre (trou boolean), se croisent ou à l'exterieur ---------
		fn get_positionRelative_shapes 		_pts_shp1		_pts_shp_aTester 	=(
			
-- 			debug "get_positionRelative_shapes"
			
			struct	str_intersection	(
				pos,
				id_pt_1 =0,
				id_pt_2 =0				
			)
			
			
			local result = #exterieur		---- #exterieur,  #interieur, #intersection, ou	 #aCoté	 --------------
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
				
-- 				debug "_pts_shp1" var:_pts_shp1
-- 				debug "_pts_shp_aTester" var:_pts_shp_aTester
				
				local pts_triangles_shp1 = trianguler	_pts_shp1
				local pts_triangles_shp2 = trianguler	_pts_shp_aTester
				
-- 				debug "pts_triangles_shp1" var:pts_triangles_shp1
-- 				debug "pts_triangles_shp2" var:pts_triangles_shp2
					
-- 				debug "survol  	_pts_shp_aTester[1]	pts_triangles_shp1	" var:( survol  	_pts_shp_aTester[1]	pts_triangles_shp1	 )
-- 				debug "survol  	_pts_shp1[1]				pts_triangles_shp2	" var:( survol  	_pts_shp1[1]		pts_triangles_shp2	 )
				
				if survol  	_pts_shp_aTester[1]	pts_triangles_shp1	 then 
					result = #interieur
				else if survol  	_pts_shp1[1]		pts_triangles_shp2	 then 
					result = #exterieur
				else
					result = #aCoté
					
			)
			
-- 			debug "position Relative" var:result
			
			result
		),

		
		fn shape_estDans_shape		_shp_1  shp_test =(
			if _shp_1.count == 0 then 			
				true
			else 	if get_positionRelative_shapes  _shp_1	shp_test  == #interieur then 
				true
			else 
				false
		),

		
		fn get_id_shp_enfant_proche 		_shp_1  	shps_tests 	=(
			
			local result = 0
			if _shp_1.count != 0 then (
				--- on cherches les shapes qui sont à l'interieur -------
				local shps_interieur =#()
				for shp in shps_tests do
					if shape_estDans_shape	 _shp_1 		shp do
						append shps_interieur	shp
				
				--- si on a des shapes à l'interieur ---------------
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
		
		
		
		
		
		------------------ Preparation pour geometrie -----------------------------------
		fn creer_shape_aTrou		_pts_shp1		_pts_shp2 =(
			
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
			local pts_result = #()
			if id_pt_connexion_1 != 0 do (
				pts_result = #( _pts_shp1[ id_pt_connexion_1 ] )
				for i_compteur = 1 to  _pts_shp1.count do (
					local id_pt = i_compteur + id_pt_connexion_1 
					if id_pt > _pts_shp1.count do 
						id_pt -= _pts_shp1.count 
					local pt = _pts_shp1[id_pt]
					append pts_result	pt
				)
			)
			
			---- les second shape, on l'ajoute a l'envers  -----------
			for i_compteur =  _pts_shp2.count to 1 by -1 do (
				local id_pt = i_compteur + id_pt_connexion_2 
				if id_pt > _pts_shp2.count do 
					id_pt -= _pts_shp2.count 
				local pt = _pts_shp2[id_pt]
				append pts_result	pt
			)
			if id_pt_connexion_2 != 0 do
				append 	pts_result	( _pts_shp2[ id_pt_connexion_2 ] )
			
			
			pts_result
			
		),
		fn creer_pts_pourFace		_noeud	=(
			
			local pts_result =#( )
			local pts_noeud =_noeud.get_pts	()
			for enfant in _noeud.enfants do (
				pts_noeud = creer_shape_aTrou  	pts_noeud		( enfant.get_pts() )
				for petitEnfant in enfant.enfants do
					pts_result += creer_pts_pourFace  petitEnfant
			)
			append pts_result 	pts_noeud
			pts_result
		),
		fn get_boleens_pts		_noeud_root	=(
			
			local pts_result =#()
			
			for enfant in _noeud_root.enfants do 
				pts_result += creer_pts_pourFace  enfant
			
			pts_result
			
		),
		
		
		
		
		
		------------------ hierarchie booleenne -----------------------------------
		fn creer_noeud_hierarchie 	pts: 	nom:	=(
			
			---- noeud de la hierarchie ----------
			struct str_terrain_booleen_node (
				
					struct_prt ,
					
				
				public
					pts 			=	#(),
					nom 			="",
					dist_auParent = 0,
					
					parent,
				public
					enfants		=	#(),
					
					fn set_parent		_ndParent = (
						if parent != undefined and parent  != _ndParent do
							parent.retirer_enfant	this
						parent  = _ndParent
					),
					fn ajouter_enfant 	_neudEnfant = (
						local distTest	=	struct_prt.get_distance_shapes 	pts	_neudEnfant.pts
						
						local trouve = false
						if distTest != undefined do (
								
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
					fn retirer_enfant	_enfant =(
						local id_enfant = findItem enfants	_enfant
						if id_enfant != 0 do
							deleteItem enfants id_enfant
					),
					fn set_pts  _pts= pts = _pts,
					fn get_pts  = pts
					
			)--- fin du struct----
			
			
			
			local nv_noeud = str_terrain_booleen_node		struct_prt:this
			if pts != unsupplied do nv_noeud.set_pts 	pts
			if nom != unsupplied do nv_noeud.nom= nom
			nv_noeud
			
		),
		fn integrer_nd_dans_hierarchie		_nd_courant		_nd_aIntegrer 	=(
			
			local integration_reussie = false			
			
			local est_dans_shape = shape_estDans_shape		_nd_courant.pts  	( _nd_aIntegrer.get_pts ())	
			if est_dans_shape	then (
				
				integration_reussie = true
				
				---- les enfants -----
				local integration_dans_enfant = false	
				for enfant in	_nd_courant.enfants  do (
					
					local integration = integrer_nd_dans_hierarchie  		enfant  		_nd_aIntegrer
					if integration then  
						integration_dans_enfant = true
				)
				
				if not integration_dans_enfant   then (
					
					local enfants_a_ajouter =#()
					for enfant in	_nd_courant.enfants  do (		
						if shape_estDans_shape	( _nd_aIntegrer.get_pts () )	enfant.pts   then
							append enfants_a_ajouter enfant
					)
					
					for enfant in enfants_a_ajouter do
							_nd_aIntegrer.ajouter_enfant 	enfant
					
					_nd_courant.ajouter_enfant 		_nd_aIntegrer
				) 
				
			) 
			
			integration_reussie
			
		),
		fn hierarchiser 		_pts_shapes		=(
			
			local 	nd_root				=	creer_noeud_hierarchie 	nom:"root"	
			local 	shps_aTraiter	=	deepCopy _pts_shapes
			
			local i = 1
			for shp in  	shps_aTraiter  do (
				local nv_nd = 	creer_noeud_hierarchie 		pts:shp	nom:("noeud " + i as string )
				integrer_nd_dans_hierarchie		nd_root		nv_nd
				i+=1
			)
			
			nd_root
		),
		
		
		
		
		
		
	
		
		
		
		
		
		
		
		
	public
		/* 
		fn preparer_points_pour_geometrie		_pts =(
			
			--- on recuprere le noeud root de la hierachie de booleens ----------------
			local		nd_root 		= hierarchiser 				_pts
			local		pts_result	= get_boleens_pts		nd_root
			pts_result
		), */
		
		---- on entre une liste de listes de points  (nos differents shapes à analyser )------------
		---- renvois une liste des points avec fusion des shapes à trous en une seule liste pour creéation de face troué ---------
		fn preparer_points_pour_geometrie		 	_shapes_pts_aAnalyser 	=(
			
			---- on cherche les booleens --------------------
			local pts_shps			=	 deepCopy 		_shapes_pts_aAnalyser
			local pts_shps_result 	=	#()
			
			while pts_shps.count > 1 do (
				
				local	shp_courant 					= 	pts_shps[1]
				local shps_restant					=	for i = 2 to pts_shps.count collect pts_shps[i]
				local shape_lePlusProche 			=	get_shape_lePlusProche	shp_courant	shps_restant
				local shp_lePlusProche				=	shps_restant[ shape_lePlusProche.id_shp ]
				local posRelative_auPlusProche 	= get_positionRelative_shapes		shp_courant  	shp_lePlusProche
				case posRelative_auPlusProche of (
					#interieur: 		(
						pts_shps[1] = creer_shape_aTrou		shp_courant		shp_lePlusProche
						deleteItem pts_shps		( shape_lePlusProche.id_shp + 1 )
					)
					#exterieur: 	(
						pts_shps[1] = creer_shape_aTrou		shp_courant		shp_lePlusProche
						deleteItem pts_shps		( shape_lePlusProche.id_shp + 1 )
					)
					default: 		(
						append 		pts_shps_result  ( deepcopy pts_shps[1] )
						deleteItem 	pts_shps		 1
					)
				)
			)
			append 		pts_shps_result  ( deepcopy pts_shps[1] )
			
			
			
			local		nd_root 		= hierarchiser 				pts_shps_result
			local		pts_result	= get_boleens_pts		nd_root
			
			
-- 			pts_shps_result
			pts_result
			
			
		)
	
	
	
	
	
) --- fin struct booleen -----------------------------------



