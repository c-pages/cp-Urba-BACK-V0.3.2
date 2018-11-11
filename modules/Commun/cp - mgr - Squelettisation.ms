
---- les evenements ------------------------------------------------------------
struct str_squel_evnt_segment (
	id_pt_evnt			= 	0,
	pos_pt_evnt		= 	[0,0,0],
	dist_depuis_pt 	= 	0,
	distance_toEvt		= 	0	/* ,
	passe_prevu 		=	0 */
)

struct str_squel_evnt_division (
	id_pt_evnt,											--> index du point évenement:       (id_pt_evnt)
	pos_pt_evnt,	                                 	--> position du point évènement:    (pos_pt_evnt)
	id_pt_intersec,                                    --> segment_intersection:           (id_pt_intersec)
	distance_toEvt	,
	pt_intersection,
	pt_o 
	/* 
	rapport_collision,
	pt_intersec_relatif,
	*/
)


---- les faces resultat du squelette --------
struct str_squel_face (
	id_pt_segment		=	0,
	pt_seg_1		= [0,0,0],		--->	le premier point du segment original du polygone.
	pt_seg_2		= [0,0,0],		--->	le second point du segment original du polygone.
	pt_arret_1		= [0,0,0],
	pt_arret_2		= [0,0,0],
	
	pts =#(),
	
	pts_squelette		= #()				--->	les points du squelette, formant la face.
)


---- la structure principale ------------------------------------------------------------
struct  str_squelettisation (
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"str_squel."	  	var:var	 param:param	catch (),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		
		
		
	---------------- Membres  -----------------------------
	private
		precision 						= 1,		--	<<------ en cm ?!?
		decallageHT 					= 1,
		compteur_de_passes 		= 0,
		
		squelette_result 			=#(),	---	<--------- le resultat ( liste de 'str_squel_face' )
		indent_distance 			= precision	,
		
		angles_poly 				=	#(),
		normals_bisecs_poly 	=	#(),
	
	
		passes_max = 200,
		
		decallage_z = 1.,
		
		
		
	---------- Operations -----------------------------
-- 	private
public
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
			local precision_angle = 0.001
			
			local result = ( get_angle_vecteur  vec1 )  - ( get_angle_vecteur  vec2 )
			if result < 0 do result = 360 + result
			if abs (result - 360.) < precision_angle do result = 0 
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
		fn decaller_bisectrice 		_pt_a_decaller		_vec_avt		_vec_aprs		_distance	=(
			
			local	norm_bisectrice 				= get_normal_bisectionOriente_2vecteurs 	_vec_avt 		_vec_aprs
			local distance_aux_segments 	= _distance
			local angle_pt 							= get_angle_vecteurs 	_vec_avt	 _vec_aprs
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
		
		
	---------------- Divers -----------------------------
	private
		
		fn cleanner_pts_doublons 	pts= (
			local precisionDoublons		=	.2
			local pts_result 	=#()
			for i = 1 to pts.count do (
				local j = if i == pts.count then 1 else i + 1 
					
				if distance pts[i]  pts[j] > precisionDoublons then
					append pts_result pts[i]
				else (
-- 					debug "				---> supprimer doublon " var:i
-- 					debug "				---> pts[i]  " var:pts[i] 
				)
			)
			
			
			pts_result
		),
		
		fn calculer_angles 		pts	=	(
			
			---- ( B-1)		la liste des angles internes du polygone ----		
			angles_poly 				=	#()
			---- et la liste des normals des bisectrices du polygone ----	
			normals_bisecs_poly 	=	#()
			for i = 1 to pts.count do (
				local j 		= if  i == pts.count then 1 else i + 1
				local k 		= if  i == 1 then pts.count else i - 1
				local angle_pt = get_angle_vecteurs  (pts[k] - pts[i]) 	(pts[j] - pts[i])
				append angles_poly					angle_pt
				local norm_bisec_poly = get_normal_bisectionOriente_2vecteurs  (pts[k] - pts[i]) 	(pts[j] - pts[i])
				append normals_bisecs_poly 	norm_bisec_poly
			)
		),
		fn supprimer_anglesNuls	_pts =(
			local precision_angleNul		=	.001
			local result =#()
			for i = 1 to _pts.count do (
				if angles_poly[i] > precision_angleNul then (
					append result 	_pts[i]
					
					
				) else (
					
-- 					--****** PROVISOIRE ********
-- 					point pos:_pts[i]	name:"angle nul"  centermarker:off axistripod:off cross:on Box:off  constantscreensize:off drawontop:off size:2.5 wirecolor:yellow
-- 					debug "Angle nul" var:_pts[i]
-- 					--****** PROVISOIRE ********
				)
			)
			
			debug "	---->angles nuls " var:angles_poly
-- 			result = cleanner_pts_doublons 	result
			
			result
		),
		fn supprimer_anglesPlats	_pts =(
			local precision_anglePalt		=	.001
			local result =#()
			for i = 1 to _pts.count do (
				if abs (angles_poly[i] - 180)  > precision_anglePalt  then (
					append result 	_pts[i]
					
					
				) else (
					
-- 					--****** PROVISOIRE ********
-- 					point pos:_pts[i]	name:"angle plat"  centermarker:off axistripod:off cross:on Box:off  constantscreensize:off drawontop:off size:2.5 wirecolor:yellow
-- 					debug "Angle plat" var:_pts[i]
-- 					--****** PROVISOIRE ********
				)
			)
			
			debug "	---->angles plats " var:angles_poly
-- 			result = cleanner_pts_doublons 	result
			
			result
		),
		fn actualiserEtCleanner_angles 	pts	=(
			debug "actualiserEtCleanner_angles"
			
			pts = cleanner_pts_doublons 	pts
			
			calculer_angles 			pts
			pts = supprimer_anglesNuls	pts
			
			pts = cleanner_pts_doublons 	pts
			
			calculer_angles 			pts
			pts = supprimer_anglesPlats	pts
			
			pts = cleanner_pts_doublons 	pts
			
			calculer_angles 			pts
			
			pts
		),
		
		
	---------- Evenements ----------
	private
		fn get_evenements_segment		pts		angles_poly		normals_bisecs_poly	=(
			
			local evts_segments =#()
			
			---- ( B-2)	La distance à parcourir pour avoir le prochain 'Evnmt de Segment':	-----
			----	 (il peut y avoir plusieurs evenements en mm temps, à la meme distance, donc plusieurs pts à stocker )	----
			local distance_toEvt 	= -1			---->	la distance jusqu'au prochain evenement segment
			local ids_pt_evt 		= #()		---->	Les points concernés dans le prochain evement segment
			--- pour chaques points ----------
			for i = 1 to pts.count do (
				
				-- les points concernés -----------
				local j 		= if  i == pts.count then 1 else i + 1
				local pt_1	= pts[i]
				local pt_2	= pts[j]
				
				--- la longueur du segment au point 'i'. ---
				local longueur_seg 		= 		distance pt_1 pt_2
				
				--- la longueur necéssaire pour fermer la face 'Evnmt de Segment' ----
				local tan_omega_avt 	= 		tan (angles_poly[i]/2)
				local tan_omega_aprs 	= 		tan (angles_poly[j]/2)
				local seg_dist   			=   	longueur_seg * (  ( tan_omega_avt * tan_omega_aprs ) / (tan_omega_avt + tan_omega_aprs) )
-- 				
-- 				local seg_dist_exact   	=   	longueur_seg * (  ( tan_omega_avt * tan_omega_aprs ) / (tan_omega_avt + tan_omega_aprs) )
-- 				local seg_dist				= 		( floor ( seg_dist_exact * 10000. ) ) / 10000.
				
				
				--- et donc on verifie si c'est le prochain evenement, et on stock si besoin ------
				if seg_dist > 0 and seg_dist		<= indent_distance 	do (
					
					debug "seg_dist" var:seg_dist
					debug "distance_toEvt" var:distance_toEvt
					
					
					if distance_toEvt == -1 then (
						distance_toEvt 	= seg_dist
						ids_pt_evt 			= #(i)
					) else if seg_dist >= 0 do (
						if distance_toEvt > seg_dist then (
							distance_toEvt 		= seg_dist
							ids_pt_evt 			=#(i)
						) else if distance_toEvt == seg_dist do (
							append ids_pt_evt 	i
						)
					)
				) --- fin seg_dist > 0 --------
			) -- fin du for chaques pts -----
			
			
			
			---- ( B-3)	et donc on créé les évenements segments	-----------
			for i = 1 to ids_pt_evt.count do (
				
				-- les ids des points concernés -----------
				local id_evt 			= ids_pt_evt[i]
				local id_evt_avt		= if id_evt == 1 then pts.count else id_evt - 1
				local id_evt_aprs		= if id_evt == pts.count then 1 else id_evt + 1
				
				-- la position du point fusionné -----------
				local vec_seg_avt		=	pts[id_evt_avt] 		- pts[id_evt] 
				local vec_seg_aprs		=	pts[id_evt_aprs] 	- pts[id_evt]
				local normal_diag		=	normals_bisecs_poly[id_evt]
				local dist_depuis_pt 	= 	distance_toEvt / sin ( angles_poly[id_evt] / 2 )
				local pos_evt 				= 	pts[id_evt] + normal_diag * dist_depuis_pt
				local dist_passe		 	= 	 sin ( angles_poly[id_evt] / 2 )
				
-- 				local passe_prevu		=	compteur_de_passes + integer ( dist_depuis_pt / indent_distance ) - 1
				
				--- la creation de l'evenement -----------
				local nv_evt 	= str_squel_evnt_segment 	id_pt_evnt:			id_evt				\
																			pos_pt_evnt:		pos_evt 			\
																			distance_toEvt:		distance_toEvt		\
																			dist_depuis_pt:	dist_depuis_pt	/* \
																			passe_prevu:		passe_prevu */
				append evts_segments 	nv_evt
			)
			
			evts_segments
			
		),
		
		fn get_evenements_intersections		pts		pts_back		decalage:indent_distance			=(
			
			local evts_intersections =#()
			
			
			if pts.count > 3 do (
				
				
				----- on analyse s'il y a evenement division --------------
				for i = 1 to pts.count do (
					
					-- les ids des points concernés -----------
					local id_pt 				= i
					local id_pt_svt		= if id_pt == pts.count then 1 else id_pt + 1
					local id_pt_avt		= if id_pt == 1 then pts.count else id_pt - 1
					
					local pt 				= pts[id_pt]
					local pt_svt 			= pts[id_pt_svt]
					
					local pt_back			=   pts_back[id_pt]
					
					local pt_back_svt	=   pts_back[id_pt_svt]
					
					
					for id_ptTest = 1 to pts.count where id_ptTest !=  id_pt  and id_ptTest !=  id_pt_avt  and id_ptTest !=  id_pt_svt   do (
						
						local id_ptTest_svt		= if id_ptTest == pts.count then 1 else id_ptTest + 1
						local pt_segTest 		= pts[id_ptTest]
						local pt_segTest_svt 	= pts[id_ptTest_svt]
						
-- 						local intersection_trajectoire_point		 = get_intersection_vecteurs			pt   	pt_back		pt_segTest		pt_segTest_svt
						
						
						local intersection_segments = get_intersection_vecteurs		pt   	pt_svt		pt_segTest		pt_segTest_svt
						
						
						if intersection_segments  != undefined  do (
							/* 
							debug "INTERSECTION	segments "
							
							debug "	pt   	pt_svt	" var:#(pt  , 	pt_svt	)
							debug "	pt_segTest   	pt_segTest_svt	" var:#(pt_segTest  , 	pt_segTest_svt	)
							debug ""
							debug "	id_pt" var:id_pt
							debug "	id_pt_svt" var:id_pt_svt
							debug "	id_pt_avt" var:id_pt_avt
							debug "	id_ptTest" var:id_ptTest
							debug""
							debug "	pt" var:pt
							debug "	pt_svt" var:pt_svt
							debug "	pt_back" var:pt_back
							debug "	pt_segTest" var:pt_segTest
							debug "	pt_segTest_svt" var:pt_segTest_svt
							debug "	---->	intersection_segments" var:intersection_segments
							 */
							
							
							local nv_evt
							
							local intersection_demiDroite		 = get_intersection_demiDroite_segment			pt   	pt_back		pt_segTest		pt_segTest_svt
							
							if intersection_demiDroite  != undefined  then (
								
								nv_evt = str_squel_evnt_division 		id_pt_evnt:id_pt 		id_pt_intersec:id_ptTest 	pos_pt_evnt:intersection_demiDroite
								
							) else (
								
								intersection_demiDroite		 = get_intersection_demiDroite_segment			pt_svt   	pt_back_svt		pt_segTest		pt_segTest_svt
								
								if intersection_demiDroite  != undefined  do
									nv_evt = str_squel_evnt_division 		id_pt_evnt:id_pt_svt 		id_pt_intersec:id_ptTest 	pos_pt_evnt:intersection_demiDroite
							)
							
							
							
							if nv_evt  != undefined  do (
								
								
-- 								debug "INTERSECTION	demiDroite"
-- 								debug "pts" var:pts
-- 								debug "pts_back" var:pts_back
								
-- 								debug "	nv_evt" var:nv_evt
								
-- 								local nv_evt = str_squel_evnt_division 		id_pt_evnt:id_pt 		id_pt_intersec:id_ptTest 	pos_pt_evnt:intersection_demiDroite
								append evts_intersections  nv_evt	
								
								
								
								
								---- on calcul la distance avant d'entrer en collision ----------------------------------------------------------------------------------
								local id_pt_segment_1	=	 nv_evt.id_pt_intersec
								local id_pt_segment_2	=	 if nv_evt.id_pt_intersec	==	pts.count then 1 else id_pt_segment_1	+	1
								local droite_pt1 			=	pts_back[ id_pt_segment_1 ]
								local droite_pt2 			=	pts_back[ id_pt_segment_2 ]						
								local pt_o					=	pts_back[ nv_evt.id_pt_evnt ]
								
								local vitesse_point 		= pts[ nv_evt.id_pt_evnt ]	-	pts_back[ nv_evt.id_pt_evnt]
								
								---- calcul vitesse de la droite	-----
								local vec_pt_segment_retreci		=	pts[id_pt_segment_1] - pts[id_pt_segment_2] 
								local norm_pt_segment_retreci		=	normalize	vec_pt_segment_retreci							
								local vec_droite							=	( droite_pt2 - droite_pt1 ) * rotateZMatrix 90
								local norm_droite							=	normalize vec_droite 
		-- 							debug "	norm_droite 1 " var:norm_droite
		-- 							local dot_droite							=	dot	norm_droite	norm_pt_segment_retreci	
								
								--- si on est pas dans le bon sens on tourne --------
		-- 							if dot_droite< 0 do
		-- 								norm_droite =			 norm_droite * rotateZMatrix 180
								
								
								
								local vitesse_droite 		=  norm_droite *	indent_distance
								
								
								local v_relative 				= 	vitesse_point - vitesse_droite
								local pt_intersec_relatif	=	get_intersection_droite_droite		droite_pt1		droite_pt2		pt_o	( pt_o + v_relative )
								local dist_rel					=	length		v_relative
								local dist_interst_rel		=	distance 	pt_o		pt_intersec_relatif
								
								
								
								
								local rapport_collision			=	dist_interst_rel / dist_rel
								
								local vec_intersection_result	=	vitesse_point * rapport_collision
								local pt_intersection_result	=	pt_o + vec_intersection_result
								
								
								nv_evt.pt_o					=	 pt_o
-- 								local distance_toEvt		=	decalage * rapport_collision
-- 								nv_evt.distance_toEvt		=	( floor ( distance_toEvt * 10000. ) ) / 10000.
								nv_evt.distance_toEvt		=	decalage * rapport_collision
								
								nv_evt.pt_intersection		=	pt_intersection_result
								
								/* 
								debug "	droite_pt1" 				var:droite_pt1							
								debug "	droite_pt2" 				var:droite_pt2		
								
								debug "dest p orig" var:(pt_o + v_relative)
								
								debug "	vitesse_point" 				var:vitesse_point							
								debug "	vitesse_droite" 				var:vitesse_droite		
								debug "	norm_droite" 					var:norm_droite
								debug "	pt_intersec_relatif" 			var:pt_intersec_relatif
								debug "	dist_rel" 						var:dist_rel
								debug "	dist_interst_rel" 				var:dist_interst_rel
								debug "	rapport_collision" 				var:rapport_collision
								debug "	vec_intersection_result" 	var:vec_intersection_result
								
							point pos:pt_intersection_result		name:"evt intersec"  centermarker:off axistripod:off cross:on Box:on  constantscreensize:off drawontop:off size:2.5 wirecolor:green
						 */
							)
-- 							append intersections ( str_intersec 	id_pt:id_pt		id_pt_seg:id_ptTest		pos:intersection )
						)
					) -- fin for do  id_ptTest ---- 
					
					
					
				
				) --- fin for do pts.count ----
			)
			evts_intersections
		),
		
		
		/* 
		fn get_evenements_divisions_PAR_TRAJECTOIRE_DES_POINTS		pts		pts_back	decalage:indent_distance			=(
			
			local evts_divisions =#()
			
			
			if pts.count > 3 do (
				----- on analyse s'il y a evenement division --------------
				for i = 1 to pts.count do (
					
					-- les ids des points concernés -----------
					local id_pt 			= i
					local id_pt_avt	= if id_pt == 1 then pts.count else id_pt - 1
					local id_pt_aprs	= if id_pt == pts.count then 1 else id_pt + 1
					
					local pt 				= pts[id_pt]
					local pt_avt			= pts[id_pt_avt]
					local pt_aprs 			= pts[id_pt_aprs]
					
					local pt_evt			=	 pts[id_pt]
					local pt_evt_back	=   pts_back[id_pt]
					
					
					for id_ptTest = 1 to pts.count where id_ptTest !=  id_pt and id_ptTest !=  id_pt_avt  and id_ptTest !=  id_pt_aprs  do (
						
						local id_ptTest_apres	= if id_ptTest == pts.count then 1 else id_ptTest + 1
						local pt_segTest_1 		= pts[id_ptTest]
						local pt_segTest_2 		= pts[id_ptTest_apres]
						
-- 						debug "INTERSECTION"
						
-- 						local intersection = get_intersection_demiDroite_segment		pt_evt   	pt_evt_back		pt_segTest_1		pt_segTest_2
						local intersection = get_intersection_vecteurs		pt_evt   	pt_evt_back		pt_segTest_1		pt_segTest_2
						
						
						
						
						
						
						
						
						if intersection  != undefined  do (
							
							
							debug "INTERSECTION"
							debug "pts" var:pts
							debug "pts_back" var:pts_back
							
							
							
							local nv_evt = str_squel_evnt_division 		id_pt_evnt:id_pt 		id_pt_intersec:id_ptTest 	pos_pt_evnt:intersection
							append evts_divisions  nv_evt	
							
							
							
							
							---- on calcul la distance avant d'entrer en collision ----------------------------------------------------------------------------------
-- 							local pts_apresCollision	=	retrecir_polygone		pts		decalage
							
							local id_pt_segment_1	=	 nv_evt.id_pt_intersec
							local id_pt_segment_2	=	 if nv_evt.id_pt_intersec	==	pts.count then 1 else id_pt_segment_1	+	1
							local droite_pt1 			=	pts_back[ id_pt_segment_1 ]
							local droite_pt2 			=	pts_back[ id_pt_segment_2 ]						
							local pt_o					=	pts_back[ nv_evt.id_pt_evnt ]
							
							local vitesse_point 		= pts[ nv_evt.id_pt_evnt ]	-	pts_back[ nv_evt.id_pt_evnt]
							
							---- calcul vitesse de la droite	-----
							local vec_pt_segment_retreci		=	pts[id_pt_segment_1] - pts[id_pt_segment_2] 
							local norm_pt_segment_retreci		=	normalize	vec_pt_segment_retreci							
							local vec_droite							=	( droite_pt2 - droite_pt1 ) * rotateZMatrix 90
							local norm_droite							=	normalize vec_droite 
-- 							debug "	norm_droite 1 " var:norm_droite
-- 							local dot_droite							=	dot	norm_droite	norm_pt_segment_retreci	
							
							--- si on est pas dans le bon sens on tourne --------
-- 							if dot_droite< 0 do
-- 								norm_droite =			 norm_droite * rotateZMatrix 180
							
							
							
							local vitesse_droite 		=  norm_droite *	indent_distance
							
							
							local v_relative 				= 	vitesse_point - vitesse_droite
							local pt_intersec_relatif	=	get_intersection_droite_droite		droite_pt1		droite_pt2		pt_o	( pt_o + v_relative )
							local dist_rel					=	length		v_relative
							local dist_interst_rel		=	distance 	pt_o		pt_intersec_relatif
							
							
							
							
							local rapport_collision			=	dist_interst_rel / dist_rel
							
							local vec_intersection_result	=	vitesse_point * rapport_collision
							local pt_intersection_result	=	pt_o + vec_intersection_result
							
							
							nv_evt.pt_o					=	 pt_o
							nv_evt.distance_toEvt		=	decalage * rapport_collision
							nv_evt.pt_intersection		=	pt_intersection_result
							
							
							debug "	droite_pt1" 				var:droite_pt1							
							debug "	droite_pt2" 				var:droite_pt2		
							
							debug "dest p orig" var:(pt_o + v_relative)
							
							debug "	vitesse_point" 				var:vitesse_point							
							debug "	vitesse_droite" 				var:vitesse_droite		
							debug "	norm_droite" 					var:norm_droite
							debug "	pt_intersec_relatif" 			var:pt_intersec_relatif
							debug "	dist_rel" 						var:dist_rel
							debug "	dist_interst_rel" 				var:dist_interst_rel
							debug "	rapport_collision" 				var:rapport_collision
							debug "	vec_intersection_result" 	var:vec_intersection_result
							
						)
					) -- fin for do  id_ptTest ---- 
				
				) --- fin for do pts.count ----
			)
			evts_divisions
		),
		 */
		
		
		
		
		fn get_evt_plusProche	_evts =(
			
			/* 
			---- fonction de comparaison pour qsort ------------------------------
			fn compare_dist_evts 	evt_1 	evt_2 =			(
				local d = evt_1.distance_toEvt	-	evt_2.distance_toEvt			--(length v1)-(length v2)
				case of
				(
					(d < 0.): -1
					(d > 0.): 1
					default: 0
				)
			)
			 */
			
			
			
			
			local evts_result =#()
			local dist_min = 1e30
			for evt in _evts do (
				if evt.distance_toEvt < dist_min then (
					dist_min = evt.distance_toEvt 
					evts_result = #(evt)
				) else if evt.distance_toEvt == dist_min do
					append evts_result	evt
			)
			
-- 			qsort 	evts_result 	compareFN
			
			evts_result
		),
		
		
		
		/* 
		fn get_polys_evts_intersections		evts_intersections		pts			=  (
			
-- 			debug "------------>		checker_evenements_divisions" var:pts
			
			local polys_result 			=	#()
			local polysIds_aTester 		=	#( #{1..pts.count} )
			
			if pts.count > 3 do (
-- 				evts_divisions =	get_evenements_divisions		pts	decalage:indent_distance
			
				
-- 				debug "------------>		evts_divisions" var:evts_divisions
				
				
				------   2)	Les 'Evnmts  Division' -------------------------		
				for i=1 to evts_intersections.count  do (
					
					local evt = evts_intersections[i]
					
					for polyIds_aTester in polysIds_aTester do (
						
						--- Poly 1 -----
						local poly_1 		= #()
						local id_seg 		= evt.id_pt_intersec
						local id_seg_svt 	= if id_seg == pts.count then 1 else	id_seg + 1	
						
						
						local id_pt_courant 		= id_seg_svt		
						
						local trouve 	= false					
						while not trouve do (						
							append poly_1 					id_pt_courant
							if id_pt_courant == evt.id_pt_evnt  do trouve= true
							id_pt_courant = if id_pt_courant == pts.count then  1 else id_pt_courant + 1
						)
						
						
					) ---- for poly a atester ---------
					
				) --- for evenements ----
				
				
				
					local evt = evt_division	--evts_divisions[i]
					
					--******* PROVISOIRE ********
					debug "########## 'Evnmts de Division' ##########"
					debug "		passe" var:compteur_de_passes
					debug "		evts_divisions" var:evt
					--******* PROVISOIRE ********
					
					local id_pt_intersec 		= evt.id_pt_intersec										
					local id_pt_intersec_svt 	= id_pt_intersec + 1										
					if id_pt_intersec_svt > pts.count do id_pt_intersec_svt = 1	
					
					--- copy des tableaux ------
					local pts_copy1 			= deepcopy pts
					local pts_copy2 			= deepcopy pts
					
					
					
					------------- Creation des polygones resultants -------------------------------------
					--- Poly 1 -----
					local poly_1 = #()					
					local id_pt = id_pt_intersec_svt
					local trouve = false					
					while not trouve do (						
						append poly_1 					pts_copy1[id_pt]						
						if id_pt == evt.id_pt_evnt  do trouve= true						
						id_pt += 1
						if id_pt > pts.count do id_pt = 1						
					)
					
					
					if poly_1.count > 2 do (
						--******* PROVISOIRE ********
						debug "-------	POLY 1 --------"
						debug "poly_1"	var:poly_1
						ss = SplineShape pos:pts[1] name:("poly_1: " + compteur_de_passes as string )  wirecolor:red
						addNewSpline ss
						for pt in poly_1 do
							addKnot ss 1 #corner #line  pt--	( pt + [0,0,decallageHT * compteur_de_passes ] )
						close  ss 1 
						updateShape ss
						--******* PROVISOIRE ********
					)
					
					
					
					
					--- Poly 2 -----
					local poly_2 = #()
					local id_pt = evt.id_pt_evnt
					local trouve = false
					while not trouve do (						
						append poly_2 					pts_copy2[id_pt]
						if id_pt == id_pt_intersec do trouve= true						
						id_pt += 1
						if id_pt > pts.count do id_pt = 1
					)
					
					
					
					if poly_1.count > 2 do (
						--******* PROVISOIRE ********
						debug "-------	POLY 2 --------"
						debug "poly_2"	var:poly_2
						ss = SplineShape pos:pts[1] name:("poly_2: " + compteur_de_passes as string )  wirecolor:red
						addNewSpline ss
						for pt in poly_2 do
							addKnot ss 1 #corner #line 	 pt--	( pt + [0,0,decallageHT * compteur_de_passes ] )
						close  ss 1 
						updateShape ss
						--******* PROVISOIRE ********
					)
					
					polys_result = #( poly_1, poly_2 )
					
-- 				)	-----	fin evenement divisions -----------------------------------------------
			) --- fin if pts.count > 3	------------
			
			
			polys_result
		), --- fin 	get_evenements_divisions
		
		 */
		
		fn get_ids_polys_evtDivision		evt		ids_pts		pts	=  (
			
			local polys_result =#()
			/* 
			debug "			------>	ids_pts" var:ids_pts
			debug "				------>	evt.id_pt_evnt " var:evt.id_pt_evnt 
			debug "				------>	evt.id_pt_intersec " var:evt.id_pt_intersec 
			 */
				
				
				------------- Creation des polygones resultants -------------------------------------
				if ids_pts.count > 3 and findItem	ids_pts		evt.id_pt_evnt != 0 and  findItem	ids_pts		evt.id_pt_intersec	 != 0 	then (
					
					
					
					local pt_intersec 			= evt.id_pt_intersec
					local id_pt_intersec			=	findItem	ids_pts		evt.id_pt_intersec
					
					local pt_intersec_svt 		= if id_pt_intersec == ids_pts.count then 1 else  id_pt_intersec + 1					
					local id_pt_intersec_svt	=	ids_pts[ pt_intersec_svt ]
					
					/* 
					debug "				------>	pt_intersec_svt" var:pt_intersec_svt
					debug "					------>	id_pt_intersec" var:id_pt_intersec
					debug "					------>	id_pt_intersec_svt" var:id_pt_intersec_svt
					
					 */
					
					
					--- copy des tableaux ------
					local pts_copy1 			= deepcopy pts
					local pts_copy2 			= deepcopy pts
				
					
					--- Poly 1 -----
					local poly_1 				= #()					
					local id_pt 					= 	id_pt_intersec_svt
					local id_pts_courant	=	findItem	ids_pts	id_pt
					local trouve 				= false
					while not trouve do (
						local id_pt	=	ids_pts[	id_pts_courant	]
						append poly_1 		id_pt
						if id_pt == evt.id_pt_evnt  do trouve= true	
						
						id_pts_courant += 1
						if id_pts_courant > ids_pts.count do id_pts_courant = 1						
					)
					debug "						------>	poly_1" var:poly_1
					append polys_result 		poly_1
					
					
					--- Poly 2 -----
					local poly_2 	= #()
					local id_pt 		= evt.id_pt_evnt
					local id_pts_courant	=	findItem	ids_pts	id_pt
					local trouve 	= false
					while not trouve do (						
						local id_pt	=	ids_pts[	id_pts_courant	]
						append poly_2 		id_pt
						if id_pt == pt_intersec do trouve= true
						
						id_pts_courant += 1
						if id_pts_courant > ids_pts.count do id_pts_courant = 1	
					)
					debug "						------>	poly_2" var:poly_2
					append polys_result 		poly_2
				
				
			) --- fin if pts.count > 3	------------
			else polys_result = #(deepcopy ids_pts)
			
			polys_result
			
			
		), --- fin 	get_evenements_divisions
		
		fn get_polys_evts_intersections		evts_intersections		pts			=  (
			
			local polys_result 		=	#()
			
			local ids_pts 					=	#{1..pts.count} as array
			local ids_polys_aTester 	=	#( ids_pts )
			local ids_pts_courant 		=	#{1..pts.count} as array
			
-- 			debug "			------>	evts_intersections" var:evts_intersections
			
			for evt in evts_intersections do (
				
-- 				debug "			------>	ids_polys_aTester" var:ids_polys_aTester
				
				local ids_polys_temp =#()
				for ids_poly_aTester in ids_polys_aTester do (
					ids_polys_temp  	+= get_ids_polys_evtDivision		evt		ids_poly_aTester		pts
					debug "				------>	ids_polys_temp" var:ids_polys_temp
					
				)
				
				ids_polys_aTester = ids_polys_temp
				
			)
			
-- 			debug "			------>	ids_polys_aTester" var:ids_polys_aTester
			
			for ids_poly_aTester in ids_polys_aTester do (
				pts_poly = for idpt in ids_poly_aTester collect pts[idpt]
				append polys_result 	pts_poly
			)
			
-- 			debug "			------>	POLYS_RESULT" var:polys_result
			
			polys_result
		),
		/* 
		fn get_polys_evtDivision		evt_division		pts			=  (
			
-- 			debug "------------>		checker_evenements_divisions" var:pts
			
			local polys_result =#()
			
			if pts.count > 3 do (
-- 				evts_divisions =	get_evenements_divisions		pts	decalage:indent_distance
			
				
-- 				debug "------------>		evts_divisions" var:evts_divisions
				
				
				------   2)	Les 'Evnmts  Division' -------------------------		
-- 				for i=1 to evts_divisions.count  do (
					
					local evt = evt_division	--evts_divisions[i]
					
					--******* PROVISOIRE ********
					debug "########## 'Evnmts de Division' ##########"
					debug "		passe" var:compteur_de_passes
					debug "		evts_divisions" var:evt
					--******* PROVISOIRE ********
					
					local id_pt_intersec 		= evt.id_pt_intersec										
					local id_pt_intersec_svt 	= id_pt_intersec + 1										
					if id_pt_intersec_svt > pts.count do id_pt_intersec_svt = 1	
					
					--- copy des tableaux ------
					local pts_copy1 			= deepcopy pts
					local pts_copy2 			= deepcopy pts
					
					
					
					------------- Creation des polygones resultants -------------------------------------
					--- Poly 1 -----
					local poly_1 = #()					
					local id_pt = id_pt_intersec_svt
					local trouve = false					
					while not trouve do (						
						append poly_1 					pts_copy1[id_pt]						
						if id_pt == evt.id_pt_evnt  do trouve= true						
						id_pt += 1
						if id_pt > pts.count do id_pt = 1						
					)
					
					
					if poly_1.count > 2 do (
						--******* PROVISOIRE ********
						debug "-------	POLY 1 --------"
						debug "poly_1"	var:poly_1
						ss = SplineShape pos:pts[1] name:("poly_1: " + compteur_de_passes as string )  wirecolor:red
						addNewSpline ss
						for pt in poly_1 do
							addKnot ss 1 #corner #line  pt--	( pt + [0,0,decallageHT * compteur_de_passes ] )
						close  ss 1 
						updateShape ss
					--******* PROVISOIRE ********
					)
					
					
					
					
					--- Poly 2 -----
					local poly_2 = #()
					local id_pt = evt.id_pt_evnt
					local trouve = false
					while not trouve do (						
						append poly_2 					pts_copy2[id_pt]
						if id_pt == id_pt_intersec do trouve= true						
						id_pt += 1
						if id_pt > pts.count do id_pt = 1
					)
					
					
					
					if poly_1.count > 2 do (
						--******* PROVISOIRE ********
						debug "-------	POLY 2 --------"
						debug "poly_2"	var:poly_2
						ss = SplineShape pos:pts[1] name:("poly_2: " + compteur_de_passes as string )  wirecolor:red
						addNewSpline ss
						for pt in poly_2 do
							addKnot ss 1 #corner #line 	 pt--	( pt + [0,0,decallageHT * compteur_de_passes ] )
						close  ss 1 
						updateShape ss
						--******* PROVISOIRE ********
					)
					
					polys_result = #( poly_1, poly_2 )
					
-- 				)	-----	fin evenement divisions -----------------------------------------------
			) --- fin if pts.count > 3	------------
			
			
			polys_result
		), --- fin 	get_evenements_divisions
		 */
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	---------------- Coeur de l'algorithme  -----------------------------
	private
		---- on execute si notre polygone à plus de 2 segments		 ----
		fn creer_squelette 	pts 	pans_points:		squel_faces:	pente:	= 	if pts.count> 2 and compteur_de_passes < passes_max do (
			
			
			debug ""
			debug ""
			debug "------------------------ CREER_SQUELETTE -----------------------------------"
			debug "----- pts -----" var:pts
			
			if pente != unsupplied do (
				decallage_z =	indent_distance * tan pente
			)
			
			
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			------------------- (A)	Analyses initiales ------------------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			debug ""
			debug "------------ (A)	Analyses initiales --------------------------"
			/* 
			--******* PROVISOIRE ********
			ss = SplineShape pos:pts[1] name:("Passe: " + compteur_de_passes as string )  wirecolor:[100,100,255]
			addNewSpline ss
			for pt in pts do
				addKnot ss 1 #corner #line pt	--	( pt + [0,0,decallageHT * compteur_de_passes ] )
			close  ss 1 
			updateShape ss
			--******* PROVISOIRE ********
			 */
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			------------------- (B)	Calculs préliminaires  ------------------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			/* actualiser_angles		pts		
			pts	= supprimer_anglesNuls			pts
			actualiser_angles		pts		
			debug "	---> angles_poly" var:angles_poly
			pts	= supprimer_anglesPlats		pts
			actualiser_angles		pts		
			debug "	---> angles_poly" var:angles_poly
			*/
			pts	=	actualiserEtCleanner_angles	pts
-- 			calculer_angles 	pts
			debug "		---> pts" var:pts
			
			
			------	( A-2 BIS )  Version avec squel_faces ---------
			if squel_faces == unsupplied do (
				squel_faces = #()
				for i = 1 to pts.count do (
					local nv_squel_face	=	str_squel_face ()
					local j 		= if  i == pts.count then 1 else i + 1
					nv_squel_face.id_pt_segment	=	i
					nv_squel_face.pt_seg_1			= pts[i]
					nv_squel_face.pt_seg_2			= pts[j]
					
				
					append nv_squel_face.pts 	pts[i]
					append nv_squel_face.pts 	pts[j]
					
					append squel_faces 	nv_squel_face
				)
			)

			
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			------------------- (C)	 la BOUCLE de retrécissement -------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
			debug ""
			debug "------------ (C)	 la BOUCLE de retrécissement  --------------------------"
			
			---- Pour chaque indentation (indent_distance) tant qu'on est pas au prochain 'Evnmt de Segment' ( dist_parcourue < segEvnt_dist )
			local dist_parcourue 			= 0
			local pts_back					= deepCopy pts
			local pts_retrecissement		= deepCopy pts
			pts_retrecissement 				= retrecir_polygone		pts_retrecissement			indent_distance
			pts_retrecissement.z			+=	 decallage_z
			local on_a_fini 					= false
			
			
			
			
			
			
			---- sinon c'est parti pour la BOUCLE ---------------------------------------------------------------------------------------------------------------
			while  not on_a_fini	/* z */ and compteur_de_passes< passes_max and pts_retrecissement.count > 2 do (
				
				compteur_de_passes += 1 
				debug "----- compteur_de_passes -----" var:compteur_de_passes
				
				  (
					if debug_mode do (
						--******* PROVISOIRE ********
						ss = SplineShape pos:pts_retrecissement[1] name:("Passe: " + compteur_de_passes as string )  wirecolor:[100,100,100]
						addNewSpline ss
						for pt in pts_retrecissement do
							addKnot ss 1 #corner #line pt	--	( pt + [0,0,decallageHT * compteur_de_passes ] )
						close  ss 1 
						updateShape ss
						--******* PROVISOIRE ********
					)
				)  
				
				---- les evenements -----------------------
				local evts_segments 		=		get_evenements_segment				pts_back					angles_poly		normals_bisecs_poly
				local evts_intersections 	=  	get_evenements_intersections		pts_retrecissement		pts_back	--decalage:indent_distance	
				local evts_aTraiter			=		get_evt_plusProche		( evts_segments + evts_intersections )
				
				
				
				
				
				debug "--------> evts_segments"	var:evts_segments				
				debug "--------> evts_intersections"	var:evts_intersections
				debug "--------> EVTS_ATRAITER"	var:evts_aTraiter
				
				if evts_aTraiter.count > 0 do (
					
					debug""
					debug "pts_retrecissement avant Event"	var:pts_retrecissement
					
					---- on applique le retrecissement 	jusqu'a la distance de l'evenement ----------------------
					local distance_toEvt		=	evts_aTraiter[1].distance_toEvt
-- 					pts_retrecissement 			= retrecir_polygone		pts_back			distance_toEvt
					pts_retrecissement 		= retrecir_polygone		pts_back			( mod  distance_toEvt  indent_distance )
					pts_retrecissement.z	+=	( mod  distance_toEvt  indent_distance ) / indent_distance * decallage_z
					
					dist_parcourue += ( mod  distance_toEvt  indent_distance )
					
					
					debug "pts_retrecissement apres Event"	var:pts_retrecissement
					debug""
					
					
					--******* PROVISOIRE ********
					if debug_mode do (
						ss = SplineShape pos:pts_retrecissement[1] name:("Passe Evt: " + compteur_de_passes as string )  wirecolor:[255,255,100]
						addNewSpline ss
						for pt in pts_retrecissement do
							addKnot ss 1 #corner #line pt	--	( pt + [0,0,decallageHT * compteur_de_passes ] )
						close  ss 1 
						updateShape ss
					)
					--******* PROVISOIRE ********
					
					/* 
					
					
					for squel in squel_faces do (
						
						
						local id 			=	squel.id_pt_segment
						local id_svt	=	if id == pts_retrecissement.count then 1 else id + 1
						squel.pt_arret_1		=	pts_retrecissement[id]
						squel.pt_arret_2		=	pts_retrecissement[id_svt]
-- 						squel.pt_arret_1.z	=	dist_parcourue * 1
-- 						squel.pt_arret_2.z	=	dist_parcourue * 1
						
						
						
						
						--******* PROVISOIRE ********
						ss = SplineShape pos:squel.pt_seg_1		 name:("Squel" )  wirecolor:[255,255,100]
						addNewSpline ss
						addKnot ss 1 #corner #line squel.pt_seg_1	
						addKnot ss 1 #corner #line squel.pt_seg_2
						addKnot ss 1 #corner #line squel.pt_arret_2	
						addKnot ss 1 #corner #line squel.pt_arret_1
						close  ss 1 
						updateShape ss
						--******* PROVISOIRE ********
						
						
						
						append squelette_result 	squel
					)
					
					
					 */
					
					
					----- FACE RESULTAT ----------------------------
					for squel_face in squel_faces do (
						local id 			=	squel_face.id_pt_segment
						local id_svt	=	if id == pts_retrecissement.count then 1 else id + 1
						
						append squel_face.pts 	pts_retrecissement[id_svt]
						append squel_face.pts 	pts_retrecissement[id]
						
						
						
						if debug_mode do (
							--******* PROVISOIRE ********
							ss = SplineShape pos:squel_face.pts[1]		 name:("Squel" )  wirecolor:[255,255,100]
							addNewSpline ss
							addKnot ss 1 #corner #line squel_face.pts[1]		
							addKnot ss 1 #corner #line squel_face.pts[2]	
							addKnot ss 1 #corner #line squel_face.pts[3]		
							addKnot ss 1 #corner #line squel_face.pts[4]	
							close  ss 1 
							updateShape ss
							--******* PROVISOIRE ********
						)
						
						
						
						
						append squelette_result 	squel_face
					)					
					----- FACE RESULTAT ----------------------------
					
					
					/* 
					----------- evenements segments ------------------
					for i = 1 to evts_segments.count do (
						
						local evt = evts_segments[i]
						 */
					
					----------- evenements segments ------------------
					if  evts_segments.count > 0 then (
						
						local evt = evts_segments[1]
						
						-- les ids des points concernés -----------
						local id_pt_evnt 				= evt.id_pt_evnt
						local id_pt_avt_evnt		= if id_pt_evnt == 1 then pts_retrecissement.count else id_pt_evnt - 1
						local id_pt_aprs_evnt		= if id_pt_evnt == pts_retrecissement.count then 1 else id_pt_evnt + 1
						local pos_pt_evnt			=	pts_retrecissement[id_pt_evnt]
						
						
						
						
						
						--- on supprime LES points de l'evenement pour les rem:placer pas LE point de l'evenement ----
						if id_pt_evnt == pts_retrecissement.count then (
							deleteItem		pts_retrecissement 		id_pt_evnt
							deleteItem		pts_retrecissement 		1
							append			pts_retrecissement		evt.pos_pt_evnt
							
							
						) else (
							deleteItem		pts_retrecissement		id_pt_evnt
							deleteItem		pts_retrecissement 		id_pt_evnt
							insertItem		evt.pos_pt_evnt			pts_retrecissement	id_pt_evnt	
						)
						
						
						this.creer_squelette 	pts_retrecissement
						
						
-- 						calculer_angles pts_retrecissement
						
						/* 
						---- maj des ids des points des evenements  ---------
						for j = i to evts_segments.count do (
							local evt_aCorriger 			= evts_segments[j]
							
							evt_aCorriger.id_pt_evnt -= 1
							if evt_aCorriger.id_pt_evnt == 0 do evt_aCorriger.id_pt_evnt == pts_retrecissement.count
						)
						
						
						if evts_intersections.count  > 0 do (
							for j = evts_intersections.count to  1	do (
								
								
								local evt_aCorriger 			= evts_intersections[j]
								
								if evt_aCorriger.id_pt_evnt == id_pt_evnt or evt_aCorriger.id_pt_evnt == id_pt_aprs_evnt then (
									debug "		On supprime event intersection !!!"
									deleteItem evts_intersections j
								)else (
								
									evt_aCorriger.id_pt_evnt -= 1
									if evt_aCorriger.id_pt_evnt == 0 do evt_aCorriger.id_pt_evnt == pts_retrecissement.count
									evt_aCorriger.id_pt_intersec -= 1
									if evt_aCorriger.id_pt_intersec == 0 do evt_aCorriger.id_pt_intersec == pts_retrecissement.count
										
								)
							)
						)
						
						 */
						
					) else
					
					if evts_intersections.count > 0 then (
						----------- evenements intersections ------------------
						local polys_division	=	get_polys_evts_intersections		evts_intersections	pts_retrecissement
						for pts_poly in polys_division do	
							this.creer_squelette 	pts_poly
							
						
					) else (
						
						
						
-- 						this.creer_squelette 	pts_retrecissement
					
					)
					
					
					on_a_fini = true
					
				) --- fin on a des evts a traiter --------
				
				
				
				
				if not on_a_fini do (
					
					pts_back = deepcopy pts_retrecissement
					dist_parcourue += indent_distance
					pts_retrecissement = retrecir_polygone		pts_retrecissement		indent_distance
					pts_retrecissement.z			+=	 decallage_z
				)
				
				dist_parcourue += indent_distance
				
			) ------ fin du while Grosse BOUCLE ------------------------------
			
			
		),	---- fin creer squelette ----------------
	
		
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
		
		
		
	---------------- Interface  -----------------------------
	public
		fn exe 		pts 	pans_points:	pente:	= (
			debug "----- EXECUTER -----------------------------"
			
			compteur_de_passes = 0
			squelette_result = #()
			
			local bb_pts 				= get_BB_shape 	pts
			local longueurs_BBpts 	= #( bb_pts[2].x - bb_pts[1].x ,  bb_pts[2].y - bb_pts[1].y )
			precision 					= ( amax longueurs_BBpts  ) / 1000			
			indent_distance 			= precision
			debug "longueurs_BBpts" var:longueurs_BBpts	
			debug "--->	precision" var:precision
			
			
			
			
			creer_squelette 	pts 	pans_points:pans_points	pente:pente
			
			
			squelette_result
		)

)   --  fin structure -------------------------------





/* 


debug_mode = true
clearlistener ()

squel = str_squelettisation ()

shp = $Rectangle010
pts = for i = 1 to numknots shp collect getKnotPoint  shp 1 i 

squel.exe	 pts	pente:45


 */


