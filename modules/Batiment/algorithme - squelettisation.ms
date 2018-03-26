
/*---------------------------------------------------------------------------------------------------------------------------------------
------------ Algorithme de squelettisation de polygone --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

    l'idée c'est d'appliquer des rétrécissements succéssifs sur le polygone jusqu'à rencontrer un des évènements suivant, puis de recommencer avec les nouveaux éléments obtenus:
            1) 'Evnmt de Segment':    la distance entre deux point du polygone devient nul.
                                        ---->   on retire le point de la liste du polygone.
            2) 'Evnmt de Division':   Un point entre en contact avec segment du polygone.
                                        ---->   Division du polygone, donne: 1 point du squelette + 1 polygone, ou 2 polygones.
            3) 'Evnmt simultané'':     (à voir) Un ou plusieurs 'Evnmt de Segment' et/ou 'Evnmt de Division' dans le même instant.



    ---- l'Algorithme simplifé ----
    Tant que notre polygone à plus de 3 segments:
        |   - On calcul la distance à parcourir avant le prochain 'Evnmt de Segment' ( il peut y avoir plusieurs 'Evnmt de Segment' en même temps ! )
        |   - On fait tourner la boucle de rétrecissement jusqu'à ce que:
        |               --> on arrive à/aux 'Evnmts de Segment'.
        |               --> on rencontre un ou plusieurs 'Evnmt de Division'.
        |               --> et donc peut-être un 'Evnmt simultané' finalement.
        |   - On analyse les évènements récoltés, pour chaque évènement:
        |               # 'Evnmt de Segment':       - On créer la face du segment fusionné, en utilisant sa liste de points associés (pans_points).
        |                                           - On continue avec le polygone en retirant le point du segment fusionné ( on le retire aussi de la liste (pans_points) ).
        |               # 'Evnmt de Division':      - on relance avec les deux polygone obtenus.
    ---------------------------------







-------------------------------------------------------------------------------------------------------------------------------------------
-------- l'Algorithme détaillé ---------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
---- Entrées ----
    * 'pts_poly'                <-- les points du polygone.

---- Entrées optionelles ----
    * 'pans_points'             <-- liste des points de la futur face pour chaque segment du polygone.
-------------------------------------------------------------------------------------------------------------------------------------------



---- Analyse initiale ------------------------------------------------
    On a la liste des points (pts_poly) formant le poygone à squeletiser.
    On choisi une valeur pour la distance à parcourir pour chaque indentation (indant_distance)
            /!\ attention au rapport precision/temps de calcul, peut etre deux niveaux de précision differents?     /!\
            /!\                                                 ou peut etre un moyen de calculer la distance?      /!\
    on initialise (pans_points), si 'unsupplied', les listes de points par segment du polygone qui vont créer la face de la géometrie du pans de toit.


---- Calculs préliminaires  ------------------------------------------------
    *   si notre polygone à 2 segments: FIN
    *   la liste des angles internes du polygone (angles).
    *   la distance (segEvnt_dist) à parcourir pour avoir un 'Evnmt de Segment':
            -   pour chaque point:
                        long_seg    =   pts_poly[i-1] -   pts_poly[i]                               <--- la longueur du segment au point 'i'.
                        seg_dist    =   long_seg / ( (cos)angles[i-1]/2 +  (cos)angles[i]/2 )       <--- la longueur necéssaire pour fermer la face, 'Evnmt de Segment' (cos?cot?).
            -   On prend le 'seg_dist' le plus petit, ça donne la distance (segEvnt_dist) à parcourir avant le prochain 'Evnmt de Segment'.
    *   Il peut y avoir plusieurs 'Evnmt de Segment' en même temps (à la même distance)


---- la boucle de retrécissement ------------------------------------------------
    Pour chaque indentation (indant_distance) tant qu'on est pas au prochain 'Evnmt de Segment' ( dist_parcourue < segEvnt_dist ):
    |       *   on stock la position actuel de chaque point du polygone (pts_pos_back).
    |       *   on trouve la position de destination de chaque point du polygone après rétrécissement (pts_pos_dest).
    |       *   pour chaque points (id_pt) du polygone (pts_poly):
    |               -   on cherche les intersection entre la demi-droite formée par sa trajectoire (pts_pos_dest[id_pt] - pts_pos_backet[id_pt]) chacun des segments du polygone (pt_evnt):
    |                       ==>     on a une intersection:
    |                                       -   On calcul la distance à parcourir pour atteindre le moment de l'intersection (dist_avt_intersec).
    |                                       -   et donc on déclanche un 'Evnmt de Division' à la distance de l'intersection (dist_avt_intersec).
    |                       ==>     on a plusieurs intersections:
    |                                       -   On calcul pour chaque intersections trouvées la distance à parcourir pour les atteindre, pour trouver la plus petite (dist_intersec_min).
    |                                       -   et donc on déclenche un 'Evnmt de Division' à la distance de l'intersection la plus proche (dist_intersec = dist_intersec_min).
    |                       ==>     on a pas d'intersections: on continue tranquilou.
    |
    |       *   pour chaque évenement rencontré, d'abord les 'Evts de segment', puis les 'Evnmts de Division':
    |               1) Les 'Evnmts de Segment':     --> index du point évenement:       (id_pt_evnt)
    |                                               --> position du point évènement:    (pos_pt_evnt)
    |
    |                           *   On ajoute aux points pour la face du segment evenement (pans_points[id_pt_evnt]) la position du point evenement (pos_pt_evnt)
    |                           *   On créé la face formée par nos points (pans_points[id_pt_evnt])
    |                           *   On retire le point source de l'évènement (id_pt_evnt) de la liste des points du polygone (pts_poly) et de la liste des faces à créer (pans_points).
    |                           *   On met à jour les index des points des evenement restant à traiter (on retire 1 aux points étant après (id_pt_evnt)).
    |                           *   On ajoute à la liste de points des pans du segment précedant le point evenement (pos_pt_evnt) au début de la liste.
    |                           *   On ajoute à la liste de points des pans du segment suivant le point evenement (pos_pt_evnt) à la fin de la liste.)
    |
    |               2) Les 'Evnmts de Division':    --> index du point évenement:       (id_pt_evnt)
    |                                               --> position du point évènement:    (pos_pt_evnt)
    |                                               --> segment_intersection:           (id_pt_intersec)
    |
    |                           *   On obtient 2 polygones :    #( id_pt_intersec+1 -> id_pt_evnt )
    |                                                           #( id_pt_evnt       -> id_pt_intersec )
    |                           *   On construit les listes des faces pour chaque polygone (pans_pts_poly_1 et pans_pts_poly_2)
    |                           *   On met à jour les index des points des evenement restant à traiter (on retire 1 aux index étant après (id_pt_evnt)).
    |                           *   On relance avec les 2 polygones obtenues, en faisant passer les listes des faces respectives (pans_pts_poly_1 et pans_pts_poly_2).
    |                           *   On arrete cette boucle. FIN
    |
    |       *   On met à jour la distance parcourue (dist_parcourue) en lui ajoutant la distance à indenter (indant_distance) ou la distance parcourue (dist_avt_intersec) si il y a eu un 'Evnmt de Division'.



---------------------------------------------------------------------------------------------------------------------------------------*/


---- les evenemùents ------------------------------------------------------------
struct str_squel_evnt_segment (
	id_pt_evnt		= 0,
	pos_pt_evnt		= [0,0,0],
	seg_dist_min	= 0
)

struct str_squel_evnt_division (
	id_pt_evnt,											--> index du point évenement:       (id_pt_evnt)
	pos_pt_evnt,	                                    --> position du point évènement:    (pos_pt_evnt)
	id_pt_intersec	                                    --> segment_intersection:           (id_pt_intersec)
	
)



---- la structure principale ------------------------------------------------------------
struct  str_squelettisation (
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"urba | str_squelettisation"	  	var:var	 param:param	catch (),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		precision 		= 1,		--	<<------ en cm ?!?
		decallageHT 	= 1,
	
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
			local result = ( get_angle_vecteur  vec1 )  - ( get_angle_vecteur  vec2 )
			if result < 0 do result = 360 + result
			result
		),
		fn get_normal_bisectionOriente_2vecteurs 		_vec1 	_vec2		=(
			
			local norm_vec_1 = (normalize _vec1)
			local norm_vec_2 = (normalize _vec2)			
			local crossProd 	= cross _vec1 	_vec2
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then -1 else 1
			
			local	norm_dir 		= normalize ( ( norm_vec_1 + norm_vec_2 ) * sens )
			
			norm_dir
			
		),
		fn get_intersection_vecteurs		vec1_pt_1   vec1_pt_2		vec2_pt_1	vec2_pt_2 =(
			
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
		
		fn get_intersection_demiDroite_segment		pt_demiDrt_orig	pt_demiDrt_direction  	seg_pt_1  seg_pt_2 =(
			
			local result
			
			local pt_intersection 		=  get_intersection_vecteurs		pt_demiDrt_orig   pt_demiDrt_direction		seg_pt_1	seg_pt_2 
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
		
		/*
		fn get_intersection_droite_segment		pt_droite	direction_droite  	seg_pt_1  seg_pt_2 =(
			
			
			
			local normal_ligneProjection = 
			
			
			local vec1_pt_1 = pt_droite
			local vec1_pt_2 = pt_droite + direction_droite
			local vec2_pt_1 = seg_pt_1
			local vec2_pt_2 = seg_pt_2
			
			local pt_intersec
			
			local vec_1 = vec1_pt_2 - vec1_pt_1
			local vec_2 = vec2_pt_2 - vec2_pt_1
		),
		
		fn get_intersection_demiDroite_segment		pt_orig_demiDrt	direction_demiDrt  	seg_pt_1  seg_pt_2 =(
			
-- 		fn get_intersection_vecteurs		vec1_pt_1   vec1_pt_2		vec2_pt_1	vec2_pt_2 =(
			
			local vec1_pt_1 = pt_orig_demiDrt
			local vec1_pt_2 = pt_orig_demiDrt + direction_demiDrt
			local vec2_pt_1 = seg_pt_1
			local vec2_pt_2 = seg_pt_2
			
			local pt_intersec
			
			local vec_1 = vec1_pt_2 - vec1_pt_1
			local vec_2 = vec2_pt_2 - vec2_pt_1
			
-- 			pt_P = vec1_pt_1 + k*vec_1
-- 			pt_P = vec2_pt_1 + m*vec_2
			
			if vec_1.x*vec_2.y-vec_1.y*vec_2.x == 0 then 
				debug "##### PARALLELES #####"
			else (
				
				local coef_vec2 = -(-vec_1.x*vec1_pt_1.y+vec_1.x*vec2_pt_1.y+vec_1.y*vec1_pt_1.x-vec_1.y*vec2_pt_1.x)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				local coef_vec1 = -(vec1_pt_1.x*vec_2.y-vec2_pt_1.x*vec_2.y-vec_2.x*vec1_pt_1.y+vec_2.x*vec2_pt_1.y)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				debug "coef_vec1" var:coef_vec1
				debug "coef_vec2" var:coef_vec2
				
				
				if coef_vec2 > 0 and   coef_vec2 < 1 then
					debug "INTERSECTION"
-- 				else
				
			)
			
			#(coef_vec1, coef_vec2)
			
		), */
		
		fn decaller_bisectrice 		_pt_a_decaller		_vec_avt		_vec_aprs		_distance	=(
			
			local	norm_bisectrice 				= get_normal_bisectionOriente_2vecteurs 	_vec_avt 		_vec_aprs
			local distance_aux_segments 	= _distance
			local angle_pt 						= get_angle_vecteurs 	_vec_avt	 _vec_aprs
			local distance_sur_bisectrice 	= distance_aux_segments / ( sin ( angle_pt /2) )		
			
			local result	 			= _pt_a_decaller 	+ norm_bisectrice		* distance_sur_bisectrice 
			
			result
			
		),
		
		
		
		fn creer_squelette 	pts 	pans_points:		= if pts.count> 2 do (
			
-- 			debug "executer"
			debug "----- executer -----"
			debug "----- pts -----" var:pts
			
-- 			
-- 			/******* PROVISOIRE ********/
-- 			ss = SplineShape pos:pts[1]
-- 			addNewSpline ss
-- 			for pt in pts do
-- 				addKnot ss 1 #corner #line pt
-- 			close  ss 1 
-- 			updateShape ss
-- 			/******* PROVISOIRE ********/
-- 			
			
			------ Analyse initiale ------------------------------------------------
			local indant_distance = precision		
			
			------	on initialise les listes de points par segment du polygone qui vont créer la face de la géometrie du pans de toit. ----
			if pans_points == unsupplied do (
				pans_points = #()
				for i = 1 to pts.count do (
					local j 		= if  i == pts.count then 1 else i + 1
					local pt_1	= pts[i]
					local pt_2	= pts[j]
					append pans_points 	#( pt_2, pt_1 )
				)
			)

-- 			debug "pans_points" var:pans_points

			------ Calculs préliminaires  ------------------------------------------------
			---- si notre polygone à 2 segments: FIN ----
			if pts.count <=2 do ()
			
			---- la liste des angles internes du polygone ----
			---- et la liste des normals des bisectrices du polygone ----			
			local angles_poly 					=#()
			local normals_bisecs_poly 	=#()
			for i = 1 to pts.count do (
				local j 		= if  i == pts.count then 1 else i + 1
				local k 		= if  i == 1 then pts.count else i - 1
				local angle_pt = get_angle_vecteurs  (pts[k] - pts[i]) 	(pts[j] - pts[i])
				append angles_poly	angle_pt
				local norm_bisec_poly = get_normal_bisectionOriente_2vecteurs  (pts[k] - pts[i]) 	(pts[j] - pts[i])
				append normals_bisecs_poly 	norm_bisec_poly
			)
			
-- 			debug "angles_poly" var:angles_poly
			
			---- la distance à parcourir pour avoir le prochain 'Evnmt de Segment':	-----
			local segEvnt_dist
			local seg_dist_min 	= 0
			local ids_pt_evt 		= #()
			local pos_pt_evt 		
			for i = 1 to pts.count do (
				
-- 			debug "- i ----- " var:i
				-- les ids des points concernés -----------
				local j 		= if  i == pts.count then 1 else i + 1
				local pt_1	= pts[i]
				local pt_2	= pts[j]
				
				--- la longueur du segment au point 'i'. ---
				local longueur_seg 	= distance pt_1 pt_2
				
-- 			debug "longueur_seg" var:longueur_seg
				--- la longueur necéssaire pour fermer la face 'Evnmt de Segment' ----
-- 				local seg_dist    		=   longueur_seg / ( cos (angles_poly[i]/2) +  cos (angles_poly[j]/2) )
				
				local tan_omega_avt 	= tan (angles_poly[i]/2)
				local tan_omega_aprs 	= tan (angles_poly[j]/2)
				local seg_dist    			=   longueur_seg * (  ( tan_omega_avt * tan_omega_aprs ) / (tan_omega_avt + tan_omega_aprs) )
					
					
-- 			debug "(1 / ( tan (angles_poly[i]/2) ))" var:(1 / ( tan (angles_poly[i]/2) ))
-- 			debug "(1 / ( tan (angles_poly[j]/2) ))" var:(1 / ( tan (angles_poly[j]/2) ))
-- 			debug "seg_dist" var:seg_dist
				if seg_dist_min == 0 then (
					seg_dist_min 	= seg_dist
					ids_pt_evt 			= #(i)
				) else if seg_dist > 0 do (
					if seg_dist_min > seg_dist then (
						seg_dist_min 	= seg_dist
						ids_pt_evt 			=#(i)
					) else if seg_dist_min == seg_dist do 
						append ids_pt_evt 	i
				)
			) -- fin du for -----
			
-- 			debug "seg_dist_min" var:seg_dist_min
-- 			debug "ids_pt_evt" var:ids_pt_evt
			
			
			---- On créé les évenements segments	-----------
			local evts_segments =#()
			for i = 1 to ids_pt_evt.count do (
				
				-- les ids des points concernés -----------
				local id_evt 			= ids_pt_evt[i]
				local id_evt_avt	= if id_evt == 1 then pts.count else id_evt - 1
				local id_evt_aprs	= if id_evt == pts.count then 1 else id_evt + 1
				
				-- la position du point fusionné -----------
				local vec_seg_avt		=	pts[id_evt_avt] 	- pts[id_evt] 
				local vec_seg_aprs	=	pts[id_evt_aprs] 	- pts[id_evt]
				local normal_diag		=	normals_bisecs_poly[id_evt]
				local dist_depuis_pt 	= seg_dist_min / sin ( angles_poly[id_evt] / 2 )
				local pos_evt 			= pts[id_evt] + normal_diag * dist_depuis_pt
				
				--- la creation de l'evenement -----------
				local nv_evt 	= str_squel_evnt_segment 	id_pt_evnt:id_evt	\
																					pos_pt_evnt:pos_evt \
																					seg_dist_min:seg_dist_min
				append evts_segments 	nv_evt
			)
			
			
			
-- 			debug "evts_segments" var:evts_segments
			
			
			
			------ la BOUCLE de retrécissement ------------------------------------------------
			---- Pour chaque indentation (indant_distance) tant qu'on est pas au prochain 'Evnmt de Segment' ( dist_parcourue < segEvnt_dist )
			local dist_parcourue = 0
			local pts_retrecissement = deepCopy pts
			local on_a_un_evenement = false
			local on_a_fini = false
			if evts_segments.count == 0 do 
					on_a_fini = true
			
			while not on_a_un_evenement  and not on_a_fini	and dist_parcourue < 5000 do (
				
				-----  on stock la position actuel de chaque point du polygone (pts_pos_back) ------
				local pts_pos_back 	= deepCopy pts_retrecissement
				local pts_pos_dest 	= #()
				
				---- on applique le retrecissement à chaque points ---------
				for i = 1 to pts_retrecissement.count do (
					
					-- les ids des points concernés -----------
					local id_pt 			= i
					local id_pt_avt		= if id_pt == 1 then pts.count else id_pt - 1
					local id_pt_aprs	= if id_pt == pts.count then 1 else id_pt + 1
					
					local pt 		= pts_retrecissement[id_pt]
					local pt_avt	= pts_retrecissement[id_pt_avt]
					local pt_aprs = pts_retrecissement[id_pt_aprs]
					
					local vec_avt	= pts[id_pt_avt] 	- pts[id_pt] 
					local vec_aprs 	= pts[id_pt_aprs] - pts[id_pt] 
					
					----	on trouve la position de destination de chaque point du polygone après rétrécissement (pts_pos_dest).
					local pt_dest 		= decaller_bisectrice 		pt		vec_avt		vec_aprs		indant_distance
					pt_dest.z += decallageHT
					
-- 					debug "pt_dest"	var:pt_dest
					pts_retrecissement[i] 	= pt_dest
-- 					point pos:pt_dest size:5 centermarker:off axistripod:off cross:on Box:off wirecolor:(color 240 107 158)
-- 					debug "pts_pos_dest"	var:pts_pos_dest
					
				)
-- 					
				/******* PROVISOIRE ********/
				ss = SplineShape pos:pts_retrecissement[1]
				addNewSpline ss
				for pt in pts_retrecissement do
					addKnot ss 1 #corner #line pt
				close  ss 1 
				updateShape ss
				/******* PROVISOIRE ********/
				
				---   on cherche les intersections pour chaque points, entre la demi-droite formée par sa trajectoire et chacun des segments du polygone ----
				local evts_divisions =#()
				for i = 1 to pts_retrecissement.count do (
					
					-- les ids des points concernés -----------
					local id_pt 			= i
					local id_pt_avt	= if id_pt == 1 then pts_retrecissement.count else id_pt - 1
					local id_pt_aprs	= if id_pt == pts_retrecissement.count then 1 else id_pt + 1
					
					local pt 		= pts_retrecissement[id_pt]
					local pt_avt	= pts_retrecissement[id_pt_avt]
					local pt_aprs 	= pts_retrecissement[id_pt_aprs]
					
					local pt_evt			=	 pts_retrecissement[id_pt]
					local pt_evt_back	=   pts_pos_back[id_pt]
-- 						pt_evt_1.z = 0
-- 						pt_evt_2.z = 0
-- 							point pos:pt_evt_1 wirecolor:yellow 
-- 							point pos:pt_evt_2 wirecolor:yellow 
-- 					debug"pt_evt_1" var:pt_evt_1
-- 					debug"pt_evt_2" var:pt_evt_2
-- 					local vec_segment	= pts_retrecissemenGt[id_pt] - pts_pos_back[id_pt] 
					for id_ptTest = 1 to pts_retrecissement.count where id_ptTest !=  id_pt and id_ptTest !=  id_pt_avt  and id_ptTest !=  id_pt_aprs  do (
						
						local id_ptTest_apres	= if id_ptTest == pts_retrecissement.count then 1 else id_ptTest + 1
						local pt_segTest_1 		= 	 pts_retrecissement[id_ptTest]
						local pt_segTest_2 		= 	 pts_retrecissement[id_ptTest_apres]
						
-- 						
-- 						pt_segTest_1.z = 0
-- 						pt_segTest_2.z = 0
						
						local intersection = get_intersection_demiDroite_segment		pt_evt   pt_evt_back		pt_segTest_1	pt_segTest_2
						
						if intersection  != undefined  do (
							local nv_evt = str_squel_evnt_division 		id_pt_evnt:id_pt 		id_pt_intersec:id_ptTest 	
							point pos:intersection wirecolor:yellow  name:("id_pt:" + id_pt as string + " id_intrsc: " + id_ptTest as string )
							append evts_divisions  nv_evt
						)
					)
				
				)
				
				debug "evts_divisions" var:evts_divisions
				
				
				
				
				
				
				---- on controle les evenements ------------------------------------------------------------------------
				------   Les 'Evnmts de Segment' -------------------------		
				local ids_evts_a_retirer =#()
				for i=1 to evts_segments.count do (
					
					local evt = evts_segments[i]
					
-- 					debug "evt.seg_dist_min" var:evt.seg_dist_min
					
					-- on test si on a atteind la position de l'evenement ---------
					if dist_parcourue >= evt.seg_dist_min - indant_distance or evt.seg_dist_min <= 0 do (
						
						--- on declanche l'evenement ----------
						on_a_un_evenement = true
						debug "########## 'Evnmts de Segment' ##########"
						
						-- les ids des points concernés -----------
						local id_pt_evnt 			= evt.id_pt_evnt
						local id_pt_avt_evnt		= if id_pt_evnt == 1 then pts_retrecissement.count else id_pt_evnt - 1
						local id_pt_aprs_evnt	= if id_pt_evnt == pts_retrecissement.count then 1 else id_pt_evnt + 1
						local pos_pt_evnt			=	pts_retrecissement[id_pt_evnt]
						
						append ids_evts_a_retirer		i 
						
						
		                ----   On met à jour les faces des segmets concernés ---------
						append 		pans_points[id_pt_evnt]				pos_pt_evnt
						insertItem 	pos_pt_evnt								pans_points[id_pt_avt_evnt]	1
						append  	pans_points[id_pt_aprs_evnt]		pos_pt_evnt
						
						
	                    ----   On créé la face formée par nos points (pans_points[id_pt_evnt])
						/******* PROVISOIRE ********/
						ss = SplineShape pos:pans_points[evt.id_pt_evnt][1]  
						addNewSpline ss
						for pt in pans_points[evt.id_pt_evnt] do
							addKnot ss 1 #corner #line pt
						close  ss 1 
						updateShape ss
						addmodifier ss  ( edit_poly() )
						/******* PROVISOIRE ********/
						
						
		                ----   On retire le point source de l'évènement (id_pt_evnt) de la liste des points du polygone (pts_poly) et de la liste des faces à créer (pans_points).
						deleteItem pts_retrecissement  	id_pt_evnt
						deleteItem pans_points 			 	id_pt_evnt
						
						----   On met à jour les index des points des evenement restant à traiter (on retire 1 aux points étant après (id_pt_evnt)).
						for j = i+1 to evts_segments.count do (
							local evt_a_modifer = evts_segments[j]
							evt_a_modifer.id_pt_evnt = if evt_a_modifer.id_pt_evnt  == 1 then pts_retrecissement.count else evt_a_modifer.id_pt_evnt  - 1
						)
						for j = 1 to evts_divisions.count do (
							local evt_a_modifer = evts_divisions[j]
							evt_a_modifer.id_pt_evnt 		= if evt_a_modifer.id_pt_evnt  == 1 		then pts_retrecissement.count else evt_a_modifer.id_pt_evnt  - 1
							evt_a_modifer.id_pt_intersec = if evt_a_modifer.id_pt_intersec  == 1 	then pts_retrecissement.count else evt_a_modifer.id_pt_intersec  - 1
						)
						
						
						
						if pts_retrecissement.count > 2  then (
-- 							on_a_fini = true
-- 							
-- 							creer_squelette 	pts_retrecissement 	pans_points:pans_points

						) else (
							on_a_fini = true
							  ----   On créé les faces formée par nos points (pans_points[id_pt_evnt])
							/******* PROVISOIRE ********/
							
							for pan_pts in pans_points do (
								ss = SplineShape pos:pan_pts[1]
								addNewSpline ss
								for pt in pan_pts do
									addKnot ss 1 #corner #line pt
								close  ss 1 
								updateShape ss
								addmodifier ss  ( edit_poly() )
							)
							
							/******* PROVISOIRE ********/
								
						)
						
						
						
						
						
						
					) --- fin declenchement de l'evenement ---------
					
					
					
				)  ----- fin evenements  'segments' -------------------		
-- 				debug "evts_segments" var:evts_segments
				
				-------on retire les evets segments déclenchés -----
				for i_aRetirer = ids_evts_a_retirer.count  to 1 by -1  do
					deleteItem evts_segments 	 ids_evts_a_retirer[i_aRetirer]
				ids_evts_a_retirer =#()
				
				
				
				
				------   Les 'Evnmts  Division' -------------------------		
				for i=1 to evts_divisions.count do (
					
					local evt = evts_divisions[i]
					
					-- on gere les points créés ---------------
					debug "########## 'Evnmts de Division' ##########"
					
					local id_pt_intersec 			= evt.id_pt_intersec
					local id_pt_intersec_svt 	= id_pt_intersec + 1
					if id_pt_intersec_svt > pts_retrecissement.count do id_pt_intersec_svt = 1
					
					--- on cherche la position de 
					
					local id_pt_evnt 				= evt.id_pt_evnt 
					local id_pt_evnt_avnt 		= evt.id_pt_evnt - 1
					if id_pt_evnt_avnt <1 do id_pt_evnt_avnt = pts_retrecissement.count
					local id_pt_evnt_apres 	= evt.id_pt_evnt + 1
					if id_pt_evnt_apres > pts_retrecissement.count do id_pt_evnt_apres = 1
					
					local nv_pt = copy pts_retrecissement[id_pt_evnt]		
-- 					point pos:nv_pt  color:blue
					append 		pans_points[id_pt_evnt]							nv_pt
					insertItem 	nv_pt													pans_points[id_pt_evnt_avnt]		1
					insertItem 	nv_pt 													pans_points[id_pt_intersec]	 		1
-- 					append		pans_points[id_pt_intersec_svt]					nv_pt			 
					
					
					
					----	 On construit 2 polygones :    #( id_pt_intersec+1 -> id_pt_evnt )
					----                                 			 #( id_pt_evnt       -> id_pt_intersec )
					
					--- Poly 1 -----
					local poly_1 = #()
					local faces_poly_1 = #()
					local id_pt = id_pt_intersec_svt
					local trouve = false
					while not trouve do (						
						
						append poly_1 				pts_retrecissement[id_pt]
						append faces_poly_1		pans_points[id_pt]
						
						if id_pt == id_pt_evnt do trouve= true
						
						id_pt += 1
						if id_pt > pts_retrecissement.count do id_pt = 1
						
					)
					
					--- Poly 2 -----
					local poly_2 = #()
					local faces_poly_2 = #()
					local id_pt = id_pt_evnt
					local trouve = false
					while not trouve do (								
						
						append poly_2 				pts_retrecissement[id_pt]
						append faces_poly_2		pans_points[id_pt]
						
						if id_pt == id_pt_intersec do trouve= true
						
						id_pt += 1
						if id_pt > pts_retrecissement.count do id_pt = 1
					)
					
					
					on_a_fini = true
					
					
					
					
					/******* PROVISOIRE ********/
					debug "poly_1" var:poly_1
					ss = SplineShape pos:poly_1[1]
					addNewSpline ss
					for pt in poly_1 do
						addKnot ss 1 #corner #line pt
					close  ss 1 
					updateShape ss
					
					debug "poly_2" var:poly_2
					ss = SplineShape pos:poly_2[1]
					addNewSpline ss
					for pt in poly_2 do
						addKnot ss 1 #corner #line pt
					close  ss 1 
					updateShape ss
					/******* PROVISOIRE ********/
					
					creer_squelette 	poly_1 		pans_points:faces_poly_1
					creer_squelette 	poly_2 		pans_points:faces_poly_2
-- 					
					
					----   On met à jour les index des points des evenement restant à traiter (on retire 1 aux index étant après (id_pt_evnt)).
					----   On relance avec les 2 polygones obtenues, en faisant passer les listes des faces respectives (pans_pts_poly_1 et pans_pts_poly_2).
					
					
					----   On arrete cette boucle. FIN
				
				)
				
				
				
				
				
				
				
				
				if evts_segments.count == 0 and not on_a_fini do (
					on_a_fini = true
					if pts_retrecissement.count > 3 do
						creer_squelette 	pts_retrecissement 	pans_points:pans_points
				)
					
				
				
				
				dist_parcourue += indant_distance
				
			) ------ fin du while retrécissement ------------------------------
			

		),
	
		
	public
		fn exe 		pts 	pans_points:		= creer_squelette 	pts 	pans_points:pans_points

)   --  fin structure -------------------------------













clearlistener ()

squel = str_squelettisation ()



-- pt1 = $Point007.pos
-- pt2 = $Point006.pos
-- pt3 = $Point005.pos
-- pt4 = $Point004.pos
-- pt_intersc = ( squel.get_intersection_demiDroite_segment 	pt1 	pt2 		pt3 pt4)
-- format "pt_intersc 	---> %\n" 	pt_intersc
-- if pt_intersc != undefined do
-- 	point pos:pt_intersc size:50


shp = $Line002
pts = for i = 1 to numknots shp collect getKnotPoint  shp 1 i 
squel.exe	 pts







