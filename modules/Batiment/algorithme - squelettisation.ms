
/*---------------------------------------------------------------------------------------------------------------------------------------
------------ Algorithme de squelettisation de polygone --------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

    l'idée c'est d'appliquer des rétrécissements succéssifs sur le polygone jusqu'à rencontrer un des évènements suivant, puis de recommencer avec les nouveaux éléments obtenus:
            1) 'Evnmt de Segment':    la distance entre deux point du polygone devient nul.
                                        ---->   on retire le point de la liste du polygone.
            2) 'Evnmt de Division':   Un point entre en contact avec segment du polygone.
                                        ---->   Division du polygone, donne: 1 point du squelette + 1 polygone, ou 2 polygones.
            3) 'Evnmt simultané'':     (à voir) Un ou plusieurs 'Evnmt de Segment' et/ou 'Evnmt de Division' dans le même instant.



    ---- l'Algorithme simplifé ------------------------------------------------------------------------------------------------------------------------------------
    Tant que notre polygone à plus de 3 segments:
        |   - On calcul la distance à parcourir avant le prochain 'Evnmt de Segment' ( il peut y avoir plusieurs 'Evnmt de Segment' en même temps ! )
        |   - On fait tourner la boucle de rétrecissement jusqu'à ce que:
        |               --> on arrive à/aux 'Evnmts de Segment'.
        |               --> on rencontre un ou plusieurs 'Evnmt de Division'.
        |               --> et donc peut-être un 'Evnmt simultané' finalement.
        |   - On analyse les évènements récoltés, pour chaque évènement:
        |               # 'Evnmt de Segment':     -	On créer la face du segment fusionné, en utilisant sa liste de points associés (pans_points).
        |                                           		-	On continue avec le polygone en retirant le point du segment fusionné ( on le retire aussi de la liste (pans_points) ).
        |               # 'Evnmt de Division':     -	On relance avec les deux polygone obtenus.
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------







-------------------------------------------------------------------------------------------------------------------------------------------
-------- l'Algorithme détaillé ---------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
---- Entrées -----------------
    * 'pts_poly' 				<-- les points du polygone.
---- Entrées optionelles ----
    * 'pans_points'			<-- liste des points des futurs faces pour chaque segment du polygone. 
									On l'a en entrée ( pas à la première boucle) pour continuer à créer la face si elle n'est pas encore terminer.
	
	
	
---- Sortie -----------------
	* 'pans_points'			<-- liste des points des faces pour chaque segment de notre polygone d'entrée.
	
-------------------------------------------------------------------------------------------------------------------------------------------








-------------------------------------------------------------------------------------
    *   	si notre polygone à 2 segments: FIN
    *	On a la liste des points (pts_poly) formant le poygone à squeletiser.
	
---- (A)	Analyse initiale ------------------------------------------------
    ( A-1 )	On choisi une valeur pour la distance à parcourir pour chaque indentation (indent_distance)
            /!\ attention au rapport precision/temps de calcul, peut etre deux niveaux de précision differents?     /!\
            /!\                                                 ou peut etre un moyen de calculer la distance?      /!\
    ( A-2 )	on initialise (pans_points) si 'unsupplied', les listes de points par segment du polygone qui vont créer la face de la géometrie du pans de toit.


---- (B)	 Calculs préliminaires  ------------------------------------------------
    *   ( B-1)		la liste des angles internes du polygone (angles).
    *   ( B-2)		la distance (segEvnt_dist) à parcourir pour avoir un 'Evnmt de Segment':
			-   pour chaque point:
                        long_seg    =   pts_poly[i-1] -   pts_poly[i]                               			<--- la longueur du segment au point 'i'.
                        seg_dist    =   long_seg / ( (cos)angles[i-1]/2 +  (cos)angles[i]/2 )       	<--- la longueur necéssaire pour fermer la face, 'Evnmt de Segment' (cos?cot?).
			-   On prend le 'seg_dist' le plus petit, ça donne la distance (segEvnt_dist) à parcourir avant le prochain 'Evnmt de Segment'.
    *   ( B-3)		Et donc on créer le ou les evenements segments on fonction de ce que l'on a trouvé ci dessus.
			-	Il peut y avoir plusieurs 'Evnmt de Segment' en même temps (à la même distance)


---- (C)	 la boucle de retrécissement ------------------------------------------------
    Pour chaque indentation (indent_distance) tant qu'on est pas au prochain 'Evnmt de Segment' ( dist_parcourue < segEvnt_dist ):
    |       *   ( C-1 )	on stock la position actuel de chaque point du polygone (pts_pos_back).
    |       *   ( C-2 )	on trouve la position de destination de chaque point du polygone après rétrécissement (pts_retrecissement).
    |       *   ( C-3 )	On cherche les evenement de division :
    |					pour chaque points (id_pt) du polygone rétréci (pts_retrecissement):
    |               -   on cherche les intersection entre la demi-droite formée par sa trajectoire (pts_pos_dest[id_pt] - pts_pos_back[id_pt]) et chacun des segments du polygone (pt_evnt):
    |                       ==>     on a une intersection:
    |                                       -   On calcul la distance à parcourir pour atteindre le moment de l'intersection (dist_avt_intersec).
    |                                       -   et donc on déclanche un 'Evnmt de Division' à la distance de l'intersection (dist_avt_intersec).
    |                       ==>     on a plusieurs intersections:
    |                                       -   On calcul pour chaque intersections trouvées la distance à parcourir pour les atteindre, pour trouver la plus petite (dist_intersec_min).
    |                                       -   et donc on déclenche un 'Evnmt de Division' à la distance de l'intersection la plus proche (dist_intersec = dist_intersec_min).
    |                       ==>     on a pas d'intersections: on continue tranquilou.
    |
    |       *   ( C-4 )	pour chaque évenement rencontré, d'abord les 'Evts de segment', puis les 'Evnmts de Division':
    |               1) Les 'Evnmts de Segment':     	--> index du point évenement:       (id_pt_evnt)
    |                                               				--> position du point évènement:    (pos_pt_evnt)
    |
    |                           *   On ajoute aux points pour la face du segment evenement (pans_points[id_pt_evnt]) la position du point evenement (pos_pt_evnt)
    |                           *   On créé la face formée par nos points (pans_points[id_pt_evnt])
    |                           *   On retire le point source de l'évènement (id_pt_evnt) de la liste des points du polygone (pts_poly) et de la liste des faces à créer (pans_points).
    |                           *   On met à jour les index des points des evenement restant à traiter (on retire 1 aux points étant après (id_pt_evnt)).
    |                           *   On ajoute à la liste de points des pans du segment précedant le point evenement (pos_pt_evnt) au début de la liste.
    |                           *   On ajoute à la liste de points des pans du segment suivant le point evenement (pos_pt_evnt) à la fin de la liste.)
    |
    |               2) Les 'Evnmts de Division':   --> index du point évenement:			(id_pt_evnt)
    |                                            				--> position du point évènement:		(pos_pt_evnt)
    |                                             			--> segment_intersection:				(id_pt_intersec)
    |
    |                           *   On obtient 2 polygones :    	#( id_pt_intersec+1 -> id_pt_evnt )
    |                                                          				#( id_pt_evnt       -> id_pt_intersec )
    |                           *   On construit les listes des faces pour chaque polygone (pts_poly_1 et  pts_poly_2)
    |                           *   On met à jour les index des points des evenement restant à traiter (on retire 1 aux index étant après (id_pt_evnt)).
    |                           *   On relance avec les 2 polygones obtenues, en faisant passer les listes des faces respectives (pans_pts_poly_1 et pans_pts_poly_2).
    |                           *   On arrete cette boucle. FIN
    |
    |       *   On met à jour la distance parcourue (dist_parcourue) en lui ajoutant la distance à indenter (indent_distance) ou la distance parcourue (dist_avt_intersec) si il y a eu un 'Evnmt de Division'.



---------------------------------------------------------------------------------------------------------------------------------------*/


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
	distance_toEvt,
	
	
	rapport_collision,
	pt_intersec_relatif,
	pt_o
)


---- les faces resultat du squelette --------
struct str_squel_face (
	id_pt_segment	=	0,
	pt_seg_1			= [0,0,0],		--->	le premier point du segment original du polygone.
	pt_seg_2			= [0,0,0],		--->	le second point du segment original du polygone.
	pts_squelette	= #()				--->	les points du squelette, formant la face.
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
	
	
	
	---------------- Divers -----------------------------
	private
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
			
				debug "##### get_intersection_vecteurs #####"
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
			local angle_pt 						= get_angle_vecteurs 	_vec_avt	 _vec_aprs
			local distance_sur_bisectrice 	= distance_aux_segments / ( sin ( angle_pt /2) )		
			
			local result	 			= _pt_a_decaller 	+ norm_bisectrice		* distance_sur_bisectrice 
			
			result
			
		),
		
		fn retrecir_polygone 	_pts		_decalage	= (
			
			local poly_result = #()
			
			---- ( C-2 )	on applique le retrecissement à chaque points ( pour obtenir la lise : pts_retrecissement)  ---------
			for i = 1 to _pts.count do (
				
				-- les ids des points concernés -----------
				local id_pt 			= i
				local id_pt_avt	= if id_pt == 1 then _pts.count else id_pt - 1
				local id_pt_aprs	= if id_pt == _pts.count then 1 else id_pt + 1
				
				local pt 			= _pts[id_pt]
				local pt_avt	= _pts[id_pt_avt]
				local pt_aprs 	= _pts[id_pt_aprs]
				
				local vec_avt		= _pts[id_pt_avt] 	- _pts[id_pt] 
				local vec_aprs 	= _pts[id_pt_aprs] 	- _pts[id_pt] 
				
				----	on trouve la position de destination de chaque point du polygone après rétrécissement (pts_pos_dest).
				local pt_dest 		= decaller_bisectrice 		pt		vec_avt		vec_aprs		_decalage
-- 					pt_dest.z += decallageHT
				
				poly_result[i] 	= pt_dest
				
			)
			poly_result
		),
		
		
		
	---------- Evenements ----------
	private
		fn get_evenements_segment		pts		angles_poly		normals_bisecs_poly	=(
			
			local evts_segments =#()
			
			---- ( B-2)	La distance à parcourir pour avoir le prochain 'Evnmt de Segment':	-----
			----	 (il peut y avoir plusieurs evenements en mm temps, à la meme distance, donc plusieurs pts à stocker )	----
			local distance_toEvt 	= 0			---->	la distance jusqu'au prochain evenement segment
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
				local seg_dist    			=   	longueur_seg * (  ( tan_omega_avt * tan_omega_aprs ) / (tan_omega_avt + tan_omega_aprs) )
				
				
				--- et donc on verifie si c'est le prochain evenement, et on stock si besoin ------
				if seg_dist > 0 and seg_dist		<= indent_distance 	do (
					if distance_toEvt == 0 then (
						distance_toEvt 		= seg_dist
						ids_pt_evt 			= #(i)
					) else if seg_dist > 0 do (
						if distance_toEvt > seg_dist then (
							distance_toEvt 		= seg_dist
							ids_pt_evt 			=#(i)
						) else if distance_toEvt == seg_dist do 
							append ids_pt_evt 	i
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
		fn get_evenements_divisions		pts		decalage:indent_distance			=(
			
			local evts_divisions =#()
			
			local pts_back	=	deepcopy pts
			local pts_reduc	=	retrecir_polygone	pts		decalage
			
			if pts.count > 3 do (
				----- on analyse s'il y a evenement division --------------
				for i = 1 to pts.count do (
					
					-- les ids des points concernés -----------
					local id_pt 			= i
					local id_pt_avt	= if id_pt == 1 then pts_reduc.count else id_pt - 1
					local id_pt_aprs	= if id_pt == pts_reduc.count then 1 else id_pt + 1
					
					local pt 				= pts_reduc[id_pt]
					local pt_avt		= pts_reduc[id_pt_avt]
					local pt_aprs 		= pts_reduc[id_pt_aprs]
					
					local pt_evt			=	 pts_reduc[id_pt]
					local pt_evt_back	=   pts_back[id_pt]
					
					
					for id_ptTest = 1 to pts_reduc.count where id_ptTest !=  id_pt and id_ptTest !=  id_pt_avt  and id_ptTest !=  id_pt_aprs  do (
						
						local id_ptTest_apres	= if id_ptTest == pts_reduc.count then 1 else id_ptTest + 1
						local pt_segTest_1 		= pts_reduc[id_ptTest]
						local pt_segTest_2 		= pts_reduc[id_ptTest_apres]
						
-- 						debug "INTERSECTION"
						
						local intersection = get_intersection_demiDroite_segment		pt_evt   pt_evt_back		pt_segTest_1		pt_segTest_2
						
						if intersection  != undefined  do (
-- 							debug "INTERSECTION"
							local nv_evt = str_squel_evnt_division 		id_pt_evnt:id_pt 		id_pt_intersec:id_ptTest 	pos_pt_evnt:intersection
							append evts_divisions  nv_evt	
							
							
							
							
							---- on calcul la distance avant d'entrer en collision ----------------------------------------------------------------------------------
							local pts_apresCollision	=	retrecir_polygone		pts		decalage
							
							local id_pt_segment_1	=	 nv_evt.id_pt_intersec
							local id_pt_segment_2	=	 if nv_evt.id_pt_intersec	==	pts.count then 1 else id_pt_segment_1	+	1
							local droite_pt1 			= 	pts[ id_pt_segment_1 ]
							local droite_pt2 			= 	pts[ id_pt_segment_2 ]						
							local pt_o					=	pts[ nv_evt.id_pt_evnt ]
							
							local vitesse_point 		= pts[ nv_evt.id_pt_evnt] 	-	pts_apresCollision[ nv_evt.id_pt_evnt ]
							
							---- calcul vitesse de la droite	-----
							local vec_pt_segment_retreci	=	pts[id_pt_segment_1] 	-	pts_apresCollision[id_pt_segment_1]
							local norm_pt_segment_retreci	=	normalize	vec_pt_segment_retreci
							
							local vec_droite			=	droite_pt2 - droite_pt1
							local norm_droite			=	normalize vec_droite
							--- si on est pas dans le bon sens on tourne --------
							if dot	norm_droite	norm_pt_segment_retreci	< 0 do
								norm_droite =			 norm_droite * rotateZMatrix 180
							local vitesse_droite 		=  norm_droite *	indent_distance
							
							-- 
							local v_relative 				= 	vitesse_point - vitesse_droite
							local pt_intersec_relatif	=	get_intersection_droite_droite		droite_pt1		droite_pt2		pt_o	( pt_o + v_relative )
							local dist_rel					=	length		v_relative
							local dist_interst_rel		=	distance 	pt_o	pt_intersec_relatif

							
-- 							local vec_intersection_result	=	vitesse_point * rapport_collision
-- 							local pt_intersection_result	=	pt_o + vec_intersection_result
							
							local rapport_collision			=	dist_interst_rel / dist_rel
							
							nv_evt.pt_o	=	 pt_o
							nv_evt.pt_intersec_relatif	=	 pt_intersec_relatif
							
-- 							nv_evt.dist_interst_rel	=	 dist_interst_rel
-- 							nv_evt.dist_rel	=	 dist_rel
							
							nv_evt.rapport_collision	=	 rapport_collision
							nv_evt.distance_toEvt		=	decalage * rapport_collision
							
						)
					) -- fin for do  id_ptTest ---- 
				
				) --- fin for do pts.count ----
			)
			evts_divisions
		),
		
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
		
		
		
		
		
		
		fn get_polys_evtDivision		evt_division		pts			=  (
			
-- 			debug "------------>		checker_evenements_divisions" var:pts
			
			local polys_result =#()
			
			if pts.count > 3 do (
-- 				evts_divisions =	get_evenements_divisions		pts	decalage:indent_distance
			
				
-- 				debug "------------>		evts_divisions" var:evts_divisions
				
				
				------   2)	Les 'Evnmts  Division' -------------------------		
-- 				for i=1 to evts_divisions.count  do (
					
					local evt = evt_division	--evts_divisions[i]
					
					/******* PROVISOIRE ********/
					debug "########## 'Evnmts de Division' ##########"
					debug "		passe" var:compteur_de_passes
					debug "		evts_divisions" var:evt
					/******* PROVISOIRE ********/
					
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
						/******* PROVISOIRE ********/
						debug "-------	POLY 1 --------"
						debug "poly_1"	var:poly_1
						ss = SplineShape pos:pts[1] name:("poly_1: " + compteur_de_passes as string )  wirecolor:red
						addNewSpline ss
						for pt in poly_1 do
							addKnot ss 1 #corner #line  pt--	( pt + [0,0,decallageHT * compteur_de_passes ] )
						close  ss 1 
						updateShape ss
						/******* PROVISOIRE ********/
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
						/******* PROVISOIRE ********/
						debug "-------	POLY 2 --------"
						debug "poly_2"	var:poly_2
						ss = SplineShape pos:pts[1] name:("poly_2: " + compteur_de_passes as string )  wirecolor:red
						addNewSpline ss
						for pt in poly_2 do
							addKnot ss 1 #corner #line 	 pt--	( pt + [0,0,decallageHT * compteur_de_passes ] )
						close  ss 1 
						updateShape ss
						/******* PROVISOIRE ********/
					)
					
					polys_result = #( poly_1, poly_2 )
					
					/* 
					---------- on relance avec les poygone obtenus----------------------------
					local compteur_de_passes_back 	= compteur_de_passes
					this.creer_squelette 	poly_1 		pans_points:faces_poly_1
					compteur_de_passes 					= compteur_de_passes_back
					this.creer_squelette 	poly_2 		pans_points:faces_poly_2
					 */
-- 				)	-----	fin evenement divisions -----------------------------------------------
			) --- fin if pts.count > 3	------------
			
			
			polys_result
		), --- fin 	get_evenements_divisions
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	---------------- Coeur de l'algorithme  -----------------------------
	private
		---- on execute si notre polygone à plus de 2 segments		 ----
		fn creer_squelette 	pts 	pans_points:		squel_faces:		= 	if pts.count> 2 and compteur_de_passes < 200 do (
			
			
			debug ""
			debug ""
			debug "------------------------ CREER_SQUELETTE -----------------------------------"
			debug "----- pts -----" var:pts
			
			
			/******* PROVISOIRE ********/
-- 			for pt in pts do
-- 				point size:20 centermarker:off axistripod:off cross:on Box:off pos:pt
			/******* PROVISOIRE ********/
			
			
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			------------------- (A)	Analyses initiales ------------------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			debug ""
			debug "------------ (A)	Analyses initiales --------------------------"
			
			------	(A-1)	On choisi une valeur pour la distance à parcourir pour chaque indentation (indent_distance)
			local indent_distance = precision		
			
		/* 	------	( A-2 ) On initialise les listes de points par segment du polygone qui vont créer la face de la géometrie du pans de toit. ----
			if pans_points == unsupplied do (
				pans_points = #()
				for i = 1 to pts.count do (
					local j 		= if  i == pts.count then 1 else i + 1
					local pt_1	= pts[i]
					local pt_2	= pts[j]
					append pans_points 	#( pt_2, pt_1 )
				)
			) */
			------	( A-2 BIS )  Version avec squel_faces ---------
			if squel_faces == unsupplied do (
				squel_faces = #()
				for i = 1 to pts.count do (
					local nv_squel_face	=	str_squel_face ()
					local j 		= if  i == pts.count then 1 else i + 1
					nv_squel_face.id_pt_segment	=	i
					nv_squel_face.pt_seg_1			= pts[i]
					nv_squel_face.pt_seg_2			= pts[j]
					append squel_faces 	nv_squel_face
				)
			)

-- 			debug "		squel_faces" var:squel_faces
			
			
			/******* PROVISOIRE ********/
		/* 	for pan_pts in pans_points do (
				ss = SplineShape pos:pan_pts[1] wirecolor:green name:("Face exe: " + compteur_de_passes as string )
				addNewSpline ss
				for pt in pan_pts do
					addKnot ss 1 #corner #line pt
				close  ss 1 
				updateShape ss
			) */
			/******* PROVISOIRE ********/
						
			

			
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			------------------- (B)	Calculs préliminaires  ------------------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			debug ""
			debug "------------ (B)	Calculs préliminaires --------------------------"
			
			---- ( B-1)		la liste des angles internes du polygone ----		
			local angles_poly 				=	#()
			---- et la liste des normals des bisectrices du polygone ----	
			local normals_bisecs_poly 	=	#()
			for i = 1 to pts.count do (
				local j 		= if  i == pts.count then 1 else i + 1
				local k 		= if  i == 1 then pts.count else i - 1
				local angle_pt = get_angle_vecteurs  (pts[k] - pts[i]) 	(pts[j] - pts[i])
				append angles_poly					angle_pt
				local norm_bisec_poly = get_normal_bisectionOriente_2vecteurs  (pts[k] - pts[i]) 	(pts[j] - pts[i])
				append normals_bisecs_poly 	norm_bisec_poly
			)
			
			
			
			
			
			
			
			
			
			
			
			
			/* 
			
			
			---- ( B-2)	La distance à parcourir pour avoir le prochain 'Evnmt de Segment':	-----
			----	 (il peut y avoir plusieurs evenements en mm temps, à la meme distance, donc plusieurs pts à stocker )	----
			local seg_dist_min 	= 0			---->	la distance jusqu'au prochain evenement segment
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
				local seg_dist    			=   	longueur_seg * (  ( tan_omega_avt * tan_omega_aprs ) / (tan_omega_avt + tan_omega_aprs) )
				
				
				--- et donc on verifie si c'est le prochain evenement, et on stock si besoin ------
				if seg_dist > 0 do (
					if seg_dist_min == 0 then (
						seg_dist_min 		= seg_dist
						ids_pt_evt 			= #(i)
					) else if seg_dist > 0 do (
						if seg_dist_min > seg_dist then (
							seg_dist_min 		= seg_dist
							ids_pt_evt 			=#(i)
						) else if seg_dist_min == seg_dist do 
							append ids_pt_evt 	i
					)
				) --- fin seg_dist > 0 --------
			) -- fin du for chaques pts -----
			
			---- ( B-3)	et donc on créé les évenements segments	-----------
			local evts_segments =#()
			for i = 1 to ids_pt_evt.count do (
				
				-- les ids des points concernés -----------
				local id_evt 			= ids_pt_evt[i]
				local id_evt_avt		= if id_evt == 1 then pts.count else id_evt - 1
				local id_evt_aprs		= if id_evt == pts.count then 1 else id_evt + 1
				
				-- la position du point fusionné -----------
				local vec_seg_avt		=	pts[id_evt_avt] 		- pts[id_evt] 
				local vec_seg_aprs		=	pts[id_evt_aprs] 	- pts[id_evt]
				local normal_diag		=	normals_bisecs_poly[id_evt]
				local dist_depuis_pt 	= 	seg_dist_min / sin ( angles_poly[id_evt] / 2 )
				local pos_evt 				= 	pts[id_evt] + normal_diag * dist_depuis_pt
				local dist_passe		 	= 	 sin ( angles_poly[id_evt] / 2 )
				
				local passe_prevu		=	compteur_de_passes + integer ( dist_depuis_pt / indent_distance ) - 1
				
				--- la creation de l'evenement -----------
				local nv_evt 	= str_squel_evnt_segment 	id_pt_evnt:		id_evt				\
																			pos_pt_evnt:		pos_evt 			\
																			seg_dist_min:		seg_dist_min		\
																			dist_depuis_pt:	dist_depuis_pt	\
																			passe_prevu:		passe_prevu
				append evts_segments 	nv_evt
			)
			
			
			*/
			/* 
			local evts_segments =		get_evenements_segment		pts		angles_poly		normals_bisecs_poly			
			local evts_divisions =  	get_evenements_divisions		pts		decalage:indent_distance	
				
			
			debug "	--->	evts_segments" var:evts_segments
			debug "	--->	evts_divisions" var:evts_divisions
			
			
			 */
			
			
			
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			------------------- (C)	 la BOUCLE de retrécissement -------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
			debug ""
			debug "------------ (C)	 la BOUCLE de retrécissement  --------------------------"
			
			---- Pour chaque indentation (indent_distance) tant qu'on est pas au prochain 'Evnmt de Segment' ( dist_parcourue < segEvnt_dist )
			local dist_parcourue 			= 0
			local pts_retrecissement 		= deepCopy pts
			local on_a_un_evenement 	= false
			local on_a_fini 					= false
			
-- 			---- si on a pas d'evenement segment on n'a pas besoin de faire la boucle ( c'est un peu zarb ça, peut etre pas necessaire, à voir ) ------------
-- 			if evts_segments.count == 0 do 
-- 				on_a_fini = true
			
			---- sinon c'est parti pour la BOUCLE ---------------------------------------------------------------------------------------------------------------
			while not on_a_un_evenement  and not on_a_fini	and dist_parcourue < 500  and compteur_de_passes< 200 do (
				
				compteur_de_passes += 1 
				debug "----- compteur_de_passes -----" var:compteur_de_passes
				
				
				---- les evenements -----------------------
				local evts_segments 	=		get_evenements_segment		pts_retrecissement		angles_poly		normals_bisecs_poly
				local evts_divisions 		=  	get_evenements_divisions		pts_retrecissement		decalage:indent_distance	
				
				local evts_aTraiter		=		get_evt_plusProche		( evts_segments + evts_divisions )
				
				debug "--------> EVTS_ATRAITER"	var:evts_aTraiter
				
				
				
				------ Les Evenements segments --------------------
-- 				evts_segments 	=		get_evenements_segment		pts_retrecissement		angles_poly		normals_bisecs_poly
				
				if evts_segments.count > 0 then (
					
					
					---- on prend le premier evenement ----------
					local evt = ( get_evt_plusProche 	evts_segments )[1]
				
					debug "	--->	evts_segments" var:evt
					
					
					-- les ids des points concernés -----------
					local id_pt_evnt 				= evt.id_pt_evnt
					local id_pt_avt_evnt		= if id_pt_evnt == 1 then pts_retrecissement.count else id_pt_evnt - 1
					local id_pt_aprs_evnt		= if id_pt_evnt == pts_retrecissement.count then 1 else id_pt_evnt + 1
					local pos_pt_evnt			=	pts_retrecissement[id_pt_evnt]
					
					pts_retrecissement 		= retrecir_polygone		pts_retrecissement		( mod evt.distance_toEvt	indent_distance )
					
					--- on supprime LES point de l'evenement pour les rem:placer pas LE point de l'evenement ----
					if id_pt_evnt == pts_retrecissement.count then (
						deleteItem		pts_retrecissement 		id_pt_evnt
						deleteItem		pts_retrecissement 		1
						append			pts_retrecissement		evt.pos_pt_evnt
					) else (
						deleteItem		pts_retrecissement		id_pt_evnt
						deleteItem		pts_retrecissement 		id_pt_evnt
						insertItem		evt.pos_pt_evnt			pts_retrecissement	id_pt_evnt	
					)
					
					/******* PROVISOIRE ********/
					ss = SplineShape pos:pts_retrecissement[1] name:("Passe: " + compteur_de_passes as string )  wirecolor:yellow
					addNewSpline ss
					for pt in pts_retrecissement do
						addKnot ss 1 #corner #line pt	--	( pt + [0,0,decallageHT * compteur_de_passes ] )
					close  ss 1 
					updateShape ss
					/******* PROVISOIRE ********/
					
					this.creer_squelette 	pts_retrecissement
					
					on_a_fini = true
					
				) else (
					
					------ Les Evenements division --------------------		
					evts_divisions 	=  	get_evenements_divisions		pts_retrecissement		decalage:indent_distance	
					if evts_divisions.count > 0 then (
						
						
						
						
						---- on prend le premier evenement ----------
						local evt = ( get_evt_plusProche		evts_divisions  )[1]
						
						debug "	--->	evts_divisions" var:evt
						
						/* 
						id_pt_evnt,											--> index du point évenement:       (id_pt_evnt)
						pos_pt_evnt,	                                 	--> position du point évènement:    (pos_pt_evnt)
						id_pt_intersec
						 */
						
						/* 
						---- on cherche le moment ( et le point) precis de l'intersection ----------------------------------------------------------------------------------
						local pts_apresCollision	=	retrecir_polygone		pts_retrecissement		indent_distance
						
						local id_pt_segment_1	=	 evt.id_pt_intersec
						local id_pt_segment_2	=	 if evt.id_pt_intersec	==	pts_retrecissement.count then 1 else id_pt_segment_1	+	1
						local droite_pt1 			= 	pts_retrecissement[ id_pt_segment_1 ]
						local droite_pt2 			= 	pts_retrecissement[ id_pt_segment_2 ]						
						local pt_o					=	pts_retrecissement[ evt.id_pt_evnt ]
						
						local vitesse_point 		= pts_retrecissement[ evt.id_pt_evnt] 	-	pts_apresCollision[ evt.id_pt_evnt ]
						
						---- calcul vitesse de la droite	-----
						local vec_pt_segment_retreci	=	pts_retrecissement[id_pt_segment_1] 	-	pts_apresCollision[id_pt_segment_1]
						local norm_pt_segment_retreci	=	normalize	vec_pt_segment_retreci
						
						local vec_droite			=	droite_pt2 - droite_pt1
						local norm_droite			=	normalize vec_droite
						--- si on est pas dans le bon sens on tourne --------
						if dot	norm_droite	norm_pt_segment_retreci	< 0 do
							norm_droite =			 norm_droite * rotateZMatrix 180
						local vitesse_droite 		=  norm_droite *	indent_distance
						
						-- 
						local v_relative 				= vitesse_point - vitesse_droite
						local pt_intersec_relatif	=	get_intersection_droite_droite		droite_pt1		droite_pt2		pt_o	( pt_o + v_relative )
						local dist_rel					=	length		v_relative
						local dist_interst_rel		=	distance 	pt_o	pt_intersec_relatif

						
						local vec_intersection_result	=	vitesse_point * rapport_collision
						local pt_intersection_result	=	pt_o + vec_intersection_result
						
						local rapport_collision			=	dist_interst_rel / dist_rel
						 */
						
						
						
						
						
						
						
						
						---- donc on applique le retrecissement avec le rapport -----------
						pts_retrecissement	=	retrecir_polygone		pts_retrecissement		evt.distance_toEvt
						
						
						
						/* 
						
						---- on cherche le moment precis de l'intersection -------------						
						droite_pt1 = getKnotPoint	$Droite	1	1
						droite_pt2 = getKnotPoint	$Droite	1	2
						
						pt_o	=	getKnotPoint	$	1	3

						v1 = ( getKnotPoint	$v1	1	2 ) - ( getKnotPoint	$v1	1	1 ) 
						v2 = ( getKnotPoint	$v2	1	2 ) - ( getKnotPoint	$v2	1	1 ) 

						v_relative = v1 - v2

						pt_intersec_relatif	=	get_intersection_droite_droite		droite_pt1		droite_pt2		pt_o	( pt_o + v_relative )

						dist_rel	=	length		v_relative

						dist_interst_rel	=	distance 	pt_o	pt_intersec_relatif

						rapport	=	dist_interst_rel / dist_rel




						vec_intersection_result	=	v1 * rapport
						pt_intersection_result	=	pt_o + vec_intersection_result
						 */
						 
						
						
						
						
						
						
						
						
						
						
						
						
						---- et on recupere les polygones resultants --------------------
						local polys_division	=	get_polys_evtDivision		evt		pts_retrecissement	
						
						---------- on relance avec les poygone obtenus----------------------------
						local compteur_de_passes_back 	= compteur_de_passes
						if polys_division[1].count > 2 do
							this.creer_squelette 	polys_division[1] 		--pans_points:faces_poly_1
						compteur_de_passes 					= compteur_de_passes_back
						if polys_division[2].count > 2 do
							this.creer_squelette 	polys_division[2] 		--pans_points:faces_poly_2
						
						on_a_fini = true
						
					)
				)
				
-- 				debug "	--->	evts_segments" var:evts_segments
-- 				debug "	--->	evts_divisions" var:evts_divisions
				
				
				
				
				
				
				-----  ( C-1 )	on stock la position actuel de chaque point du polygone (pts_pos_back) ------
-- 				local pts_pos_back 	= deepCopy pts_retrecissement
				
				if not on_a_fini do (
					pts_retrecissement = retrecir_polygone		pts_retrecissement		indent_distance
				
				
				
					/******* PROVISOIRE ********/
					ss = SplineShape pos:pts_retrecissement[1] name:("Passe: " + compteur_de_passes as string )  wirecolor:blue
					addNewSpline ss
					for pt in pts_retrecissement do
						addKnot ss 1 #corner #line pt	--	( pt + [0,0,decallageHT * compteur_de_passes ] )
					close  ss 1 
					updateShape ss
					/******* PROVISOIRE ********/
				)
				
				
				
				
				/* 
				---- ( C-2 )	on applique le retrecissement à chaque points ( pour obtenir la lise : pts_retrecissement)  ---------
				for i = 1 to pts_retrecissement.count do (
					
					-- les ids des points concernés -----------
					local id_pt 			= i
					local id_pt_avt	= if id_pt == 1 then pts.count else id_pt - 1
					local id_pt_aprs	= if id_pt == pts.count then 1 else id_pt + 1
					
					local pt 			= pts_retrecissement[id_pt]
					local pt_avt	= pts_retrecissement[id_pt_avt]
					local pt_aprs 	= pts_retrecissement[id_pt_aprs]
					
					local vec_avt		= pts[id_pt_avt] 	- pts[id_pt] 
					local vec_aprs 	= pts[id_pt_aprs] 	- pts[id_pt] 
					
					----	on trouve la position de destination de chaque point du polygone après rétrécissement (pts_pos_dest).
					local pt_dest 		= decaller_bisectrice 		pt		vec_avt		vec_aprs		indent_distance
-- 					pt_dest.z += decallageHT
					
					pts_retrecissement[i] 	= pt_dest
					
				)
				
				 */
				
				
				
				
				
			
				
				
				
				------   2)	Les 'EVENEMENTS DE DIVISION' -------------------------		
				---		( C-3 )	On cherche les evenements de division --------------------
				---   on cherche les intersections pour chaque points, entre la demi-droite formée par sa trajectoire( pt_Back -> pt_retréci ) et chacun des segments du polygone ----
-- 				local on_a_evts_divisions =  checker_evenements_divisions		pts_retrecissement		pts_pos_back
				
				/* 
				local evts_divisions =#()
				for i = 1 to pts_retrecissement.count do (
					
					-- les ids des points concernés -----------
					local id_pt 			= i
					local id_pt_avt	= if id_pt == 1 then pts_retrecissement.count else id_pt - 1
					local id_pt_aprs	= if id_pt == pts_retrecissement.count then 1 else id_pt + 1
					
					local pt 				= pts_retrecissement[id_pt]
					local pt_avt		= pts_retrecissement[id_pt_avt]
					local pt_aprs 		= pts_retrecissement[id_pt_aprs]
					
					local pt_evt			=	 pts_retrecissement[id_pt]
					local pt_evt_back	=   pts_pos_back[id_pt]
					
					
					for id_ptTest = 1 to pts_retrecissement.count where id_ptTest !=  id_pt and id_ptTest !=  id_pt_avt  and id_ptTest !=  id_pt_aprs  do (
						
						local id_ptTest_apres	= if id_ptTest == pts_retrecissement.count then 1 else id_ptTest + 1
						local pt_segTest_1 		= pts_retrecissement[id_ptTest]
						local pt_segTest_2 		= pts_retrecissement[id_ptTest_apres]
						
						local intersection = get_intersection_demiDroite_segment		pt_evt   pt_evt_back		pt_segTest_1	pt_segTest_2
						
						if intersection  != undefined  do (
							local nv_evt = str_squel_evnt_division 		id_pt_evnt:id_pt 		id_pt_intersec:id_ptTest 	pos_pt_evnt:intersection
							append evts_divisions  nv_evt	
							
							
							point pos:intersection wirecolor:yellow  name:("id_pt:" + id_pt as string + " id_intrsc: " + id_ptTest as string )
							
							
						)
					)
				
				)
				 */
				
-- 				debug "	on_a_evts_divisions" var:on_a_evts_divisions
				
				
				
				
				(
-- 										if not on_a_evts_divisions do (
-- 											---- ( C-4 )	on controle les evenements ------------------------------------------------------------------------
-- 											------   1)	Les 'EVENEMENTS DE SEGMENT' -------------------------		
-- 											local ids_evts_a_retirer 		=#()
-- 											local ids_pts_a_retirer 		=#()
-- 											local squelette_result_temp =#()
-- 											for i=1 to evts_segments.count  where pts_retrecissement.count > 2    do (
-- 												
-- 												local evt = evts_segments[i]
-- 												
-- 												-- on test si on a atteind la position de l'evenement ---------
-- 												if dist_parcourue >= evt.seg_dist_min - indent_distance or evt.seg_dist_min <= 0 do (
-- 													
-- 													--- on declenche l'evenement ----------
-- 													on_a_un_evenement = true
-- 													
-- 													/******* PROVISOIRE ********/
-- 													debug "########## 'Evnmts de Segment' ##########"
-- 													debug "		passe" var:compteur_de_passes
-- 													/* for pan_pts in pans_points do (
-- 														ss = SplineShape pos:pan_pts[1] wirecolor:red name:("Face passe: " + compteur_de_passes as string )
-- 														addNewSpline ss
-- 														for pt in pan_pts do
-- 															addKnot ss 1 #corner #line pt
-- 														close  ss 1 
-- 														updateShape ss
-- 													) */
-- 													/******* PROVISOIRE ********/
-- 													
-- 													
-- 													-- les ids des points concernés -----------
-- 													local id_pt_evnt 				= evt.id_pt_evnt
-- 													local id_pt_avt_evnt		= if id_pt_evnt == 1 then pts_retrecissement.count else id_pt_evnt - 1
-- 													local id_pt_aprs_evnt		= if id_pt_evnt == pts_retrecissement.count then 1 else id_pt_evnt + 1
-- 													local pos_pt_evnt			=	pts_retrecissement[id_pt_evnt]
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													debug "pts_retrecissement	Avant" var:pts_retrecissement
-- 													
-- 													pts_pos_back 	= deepCopy pts_retrecissement
-- 													---- 	on applique le retrecissement  jusqu'a l'evenement  ---------
-- 													for i = 1 to pts_retrecissement.count do (
-- 														
-- 														-- les ids des points concernés -----------
-- 														local id_pt 			= i
-- 														local id_pt_avt	= if id_pt == 1 then pts.count else id_pt - 1
-- 														local id_pt_aprs	= if id_pt == pts.count then 1 else id_pt + 1
-- 														
-- 														local pt 			= pts_retrecissement[id_pt]
-- 														local pt_avt	= pts_retrecissement[id_pt_avt]
-- 														local pt_aprs 	= pts_retrecissement[id_pt_aprs]
-- 														
-- 														local vec_avt		= pts[id_pt_avt] 	- pts[id_pt] 
-- 														local vec_aprs 	= pts[id_pt_aprs] - pts[id_pt] 
-- 														
-- 														----	on trouve la position de destination de chaque point du polygone après rétrécissement (pts_pos_dest).
-- 														local pt_dest 		= decaller_bisectrice 		pt		vec_avt		vec_aprs		( mod evt.seg_dist_min	indent_distance )
-- 									-- 					pt_dest.z += decallageHT
-- 														
-- 														pts_retrecissement[i] 	= pt_dest
-- 														
-- 													)
-- 													--- on supprime LES point de l'evenement pour les rem:placer pas LE point de l'evenement ----
-- 													if id_pt_evnt == pts_retrecissement.count then (
-- 														deleteItem		pts_retrecissement 		id_pt_evnt
-- 														deleteItem		pts_retrecissement 		1
-- 														append			pts_retrecissement		evt.pos_pt_evnt		
-- 													) else (
-- 														deleteItem		pts_retrecissement		id_pt_evnt
-- 														deleteItem		pts_retrecissement 		id_pt_evnt
-- 														insertItem		evt.pos_pt_evnt		pts_retrecissement	id_pt_evnt	
-- 													)
-- 													
-- 													debug "pts_retrecissement	Apres" var:pts_retrecissement
-- 													
-- 													
-- 													/******* PROVISOIRE ********/
-- 													ss = SplineShape pos:pts_retrecissement[1] name:("Passe: " + compteur_de_passes as string )  wirecolor:yellow
-- 													addNewSpline ss
-- 													for pt in pts_retrecissement do
-- 														addKnot ss 1 #corner #line 	( pt + [0,0,decallageHT * compteur_de_passes ] )
-- 													close  ss 1 
-- 													updateShape ss
-- 													/******* PROVISOIRE ********/
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													
-- 													----- RESULTAT ?!?!? -----------
-- 													----   On met à jour les faces des segmets concernés ---------
-- 							-- 						append 		pans_points[id_pt_evnt]									pos_pt_evnt
-- 							-- 						insertItem 	pos_pt_evnt		pans_points[id_pt_avt_evnt]		 1									
-- 							-- 						append  		pans_points[id_pt_aprs_evnt]							pos_pt_evnt
-- 													
-- 													--- (BIS)	Version avec squel_faces  ------
-- 													append  		squel_faces[id_pt_evnt].pts_squelette				pos_pt_evnt
-- 													insertItem  	pos_pt_evnt			squel_faces[id_pt_aprs_evnt].pts_squelette		1
-- 													
-- 													
-- 													append			ids_evts_a_retirer		i 
-- 													insertItem  	id_pt_evnt			ids_pts_a_retirer		1
-- 													
-- 													
-- 													----   On créé la face formée par nos points (pans_points[id_pt_evnt] ou squel_faces[id_pt_evnt]  )	---------------------------
-- 													--- (BIS)	 on valide le segment du squelette -----------------
-- 													append			squelette_result_temp		squel_faces[id_pt_evnt]
-- 													/* 
-- 													--- (BIS)	 on supprime le segment qui a ete validé --------
-- 													deleteItem	squel_faces				id_pt_evnt
-- 													 */
-- 													 
-- 													 
-- 													 
-- 													/******* PROVISOIRE ********/
-- 													/* ss = SplineShape pos:pans_points[evt.id_pt_evnt][1]  
-- 													addNewSpline ss
-- 													for pt in pans_points[evt.id_pt_evnt] do
-- 														addKnot ss 1 #corner #line pt
-- 													close  ss 1 
-- 													updateShape ss
-- 													addmodifier ss  ( edit_poly() ) */
-- 													/******* PROVISOIRE ********/
-- 													
-- 													
-- 													
-- 													
-- 																			

-- 													----   On retire le point source de l'évènement (id_pt_evnt) de la liste des points du polygone (pts_poly) et de la liste des faces à créer (pans_points).
-- 							-- 						deleteItem pts_retrecissement  		id_pt_evnt
-- 							-- 						deleteItem pans_points 				id_pt_evnt
-- 													
-- 													
-- 													
-- 													
-- 													----   On met à jour les index des points des evenement restant à traiter (on retire 1 aux points étant après (id_pt_evnt)).
-- 													for j = i+1 to evts_segments.count do (
-- 														local evt_a_modifer = evts_segments[j]
-- 														evt_a_modifer.id_pt_evnt = if evt_a_modifer.id_pt_evnt  == 1 then pts_retrecissement.count else evt_a_modifer.id_pt_evnt  - 1
-- 													)
-- 													/*
-- 													for j = 1 to evts_divisions.count do (
-- 														local evt_a_modifer = evts_divisions[j]
-- 														evt_a_modifer.id_pt_evnt 		= if evt_a_modifer.id_pt_evnt  == 1 		then pts_retrecissement.count else evt_a_modifer.id_pt_evnt  - 1
-- 														evt_a_modifer.id_pt_intersec 	= if evt_a_modifer.id_pt_intersec  == 1 	then pts_retrecissement.count else evt_a_modifer.id_pt_intersec  - 1
-- 													)
-- 													
-- 													 */
-- 													
-- 													
-- 						-- 							if pts_retrecissement.count <= 2  then 
-- 														on_a_fini = true
-- 													
-- 												) --- fin declenchement de l'evenement ---------
-- 												
-- 											)  ----- fin evenements  'segments' -------------------		
-- 											
-- 											
-- 											-------on retire les evets segments déclenchés -----
-- 											for i_aRetirer = ids_evts_a_retirer.count  to 1 by -1  do
-- 												deleteItem evts_segments 	 ids_evts_a_retirer[i_aRetirer]
-- 											ids_evts_a_retirer =#()
-- 											
-- 											
-- 											
-- 											---- on reste les divisions -------------
-- 						-- 					on_a_fini =  checker_evenements_divisions		pts_retrecissement		pts_pos_back
-- 										
-- 											
-- 										)
				)
				
				
				
				
				
				
				/* 
				
				if evts_segments.count == 0 and not on_a_fini do (
					on_a_fini = true
					if pts_retrecissement.count > 2 do (
						debug " ************ on a pas fini, on relance (je sais pas bien pourquoi on est là) .... **********************************************"
-- 						creer_squelette 	pts_retrecissement 	pans_points:pans_points
					)
				)
				 */
				
			
				if on_a_fini do (
					/******* PROVISOIRE ********/
					/* for pan_pts in pans_points do (
						ss = SplineShape pos:pan_pts[1]
						addNewSpline ss
						for pt in pan_pts do
							addKnot ss 1 #corner #line pt
						close  ss 1 
						updateShape ss
						addmodifier ss  ( edit_poly() )
					) */
					
					/******* PROVISOIRE ********/
				)
				
				dist_parcourue += indent_distance
				
			) ------ fin du while Grosse BOUCLE ------------------------------
			
			
		),	---- fin creer squelette ----------------
	
		
		
		
		
		
	---------------- Interface  -----------------------------
	public
		fn exe 		pts 	pans_points:		= (
			debug "----- EXECUTER -----------------------------"
			compteur_de_passes = 0
			creer_squelette 	pts 	pans_points:pans_points
		)

)   --  fin structure -------------------------------













clearlistener ()

squel = str_squelettisation ()

shp = $Rectangle001
-- for obj in objects where obj != shp do delete obj


-- pt1 = $Point007.pos
-- pt2 = $Point006.pos
-- pt3 = $Point005.pos
-- pt4 = $Point004.pos
-- pt_intersc = ( squel.get_intersection_demiDroite_segment 	pt1 	pt2 		pt3 pt4)
-- format "pt_intersc 	---> %\n" 	pt_intersc
-- if pt_intersc != undefined do
-- 	point pos:pt_intersc size:50


pts = for i = 1 to numknots shp collect getKnotPoint  shp 1 i 
squel.exe	 pts




/*


droite_pt1 = getKnotPoint	$Droite	1	1
droite_pt2 = getKnotPoint	$Droite	1	2
pt_o	=	getKnotPoint	$	1	3

v1 = ( getKnotPoint	$v1	1	2 ) - ( getKnotPoint	$v1	1	1 ) 
v2 = ( getKnotPoint	$v2	1	2 ) - ( getKnotPoint	$v2	1	1 ) 

v_relative = v1 - v2

pt_intersec_relatif	=	get_intersection_droite_droite		droite_pt1		droite_pt2		pt_o	( pt_o + v_relative )

dist_rel	=	length		v_relative

dist_interst_rel	=	distance 	pt_o	pt_intersec_relatif

rapport	=	dist_interst_rel / dist_rel




vec_intersection_result	=	v1 * rapport
pt_intersection_result	=	pt_o + vec_intersection_result


*/




