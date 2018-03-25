
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




struct str_squel_evnt_segment (
	id_pt_evnt		= 0,
	pos_pt_evnt		= [0,0,0]	
)

struct str_squel_evnt_division (
	id_pt_evnt,											--> index du point évenement:       (id_pt_evnt)
	pos_pt_evnt,	                                    --> position du point évènement:    (pos_pt_evnt)
	id_pt_intersec	                                    --> segment_intersection:           (id_pt_intersec)
	
)



struct  str_squelettisation (
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"urba | str_squelettisation"	  	var:var	 param:param	catch (),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		precision = 5,
		
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
			
			local	norm_dir 		= ( norm_vec_1 + norm_vec_2 ) * sens
			
			norm_dir
			
		),
		fn decaller 		_pt_a_decaller		_pt_avt	_pt_aprs		_distance	=(
			
			local	vec_avt			= _pt_avt - _pt_a_decaller
			local	vec_aprs			= _pt_aprs - _pt_a_decaller
				
			local	norm_bisectrice 				= get_normal_bisectionOriente_2vecteurs 	vec_avt 	vec_aprs
			local distance_aux_segments 	= _distance
			local angle_pt 							= get_angle_vecteurs vec_avt vec_aprs
			local distance_sur_bisectrice 	= distance_aux_segments / ( sin ( angle_pt /2) )		
			
			local result	 			= _pt_a_decaller 	+ norm_bisectrice		* distance_sur_bisectrice 
			
			result
			
		),
	public
		fn executer 	pts 	pans_points:		=(
			
			debug "executer"
			debug "----- analyse -----"
			
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

			debug "pans_points" var:pans_points

			------ Calculs préliminaires  ------------------------------------------------
			---- si notre polygone à 2 segments: FIN ----
			if pts.count <=2 do ()
			
			---- la liste des angles internes du polygone ----
			local angles_poly =#()
			for i = 1 to pts.count do (
				local j 		= if  i == pts.count then 1 else i + 1
				local k 		= if  i == 1 then pts.count else i - 1
				local angle_pt = get_angle_vecteurs  (pts[k] - pts[i]) 	(pts[j] - pts[i])
				append angles_poly	angle_pt
			)
			
			debug "angles_poly" var:angles_poly
			
			
			---- la distance à parcourir pour avoir le prochain 'Evnmt de Segment':	-----
			local segEvnt_dist
			local seg_dist_min 	= 0
			local ids_pt_evt 		= #()
			local pos_pt_evt 		
			for i = 1 to pts.count do (
				
			debug "- i ----- " var:i
				-- les ids des points concernés -----------
				local j 		= if  i == pts.count then 1 else i + 1
				local pt_1	= pts[i]
				local pt_2	= pts[j]
				
				--- la longueur du segment au point 'i'. ---
				local longueur_seg 	= distance pt_1 pt_2
				
			debug "longueur_seg" var:longueur_seg
				--- la longueur necéssaire pour fermer la face 'Evnmt de Segment' ----
-- 				local seg_dist    		=   longueur_seg / ( cos (angles_poly[i]/2) +  cos (angles_poly[j]/2) )
				local seg_dist    		=   longueur_seg / (1 / ( tan (angles_poly[i]/2) ) + (1 / ( tan (angles_poly[j]/2) )) )
			debug "(1 / ( tan (angles_poly[i]/2) ))" var:(1 / ( tan (angles_poly[i]/2) ))
			debug "(1 / ( tan (angles_poly[j]/2) ))" var:(1 / ( tan (angles_poly[j]/2) ))
			debug "seg_dist" var:seg_dist
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
			
			debug "seg_dist_min" var:seg_dist_min
			debug "ids_pt_evt" var:ids_pt_evt
			
			
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
				local normal_diag		=	get_normal_bisectionOriente_2vecteurs 		vec_seg_avt 	vec_seg_aprs	
				local pos_evt 			= pts[id_evt] + normal_diag * seg_dist_min
				
				--- la creation de l'evenement -----------
				local nv_evt 	= str_squel_evnt_segment 	id_pt_evnt:id_evt	\
																					pos_pt_evnt:pos_evt
				append evts_segments 	nv_evt
			)
			
			
			
			debug "evts_segments" var:evts_segments
			
			
			
			------ la boucle de retrécissement ------------------------------------------------
			---- Pour chaque indentation (indant_distance) tant qu'on est pas au prochain 'Evnmt de Segment' ( dist_parcourue < segEvnt_dist )
			 local dist_parcourue = 0
			while dist_parcourue < seg_dist_min do (
				-----  on stock la position actuel de chaque point du polygone (pts_pos_back) ------
				local pts_pos_back 	= deepCopy pts
				local pts_pos_dest 	= #() 
				
				---- on applique le retrecissement à chaque points ---------
				for i = 1 to pts.count do (
					
					-- les ids des points concernés -----------
					local id_pt 			= i
					local id_pt_avt		= if id_pt == 1 then pts.count else id_pt - 1
					local id_pt_aprs	= if id_pt == pts.count then 1 else id_pt + 1
					
					local pt 		= pts[id_pt]
					local pt_avt	= pts[id_pt_avt]
					local pt_aprs = pts[id_pt_aprs]
					
					----	on trouve la position de destination de chaque point du polygone après rétrécissement (pts_pos_dest).
					local pt_dest 		= decaller 		pt		pt_avt	pt_aprs		indant_distance
					debug "pt_dest"	var:pt_dest
					pts_pos_dest[i] 	= pt_dest
					point pos:pt_dest size:5
					debug "pts_pos_dest"	var:pts_pos_dest
					
				)
				pts = deepcopy pts_pos_dest
				dist_parcourue += indant_distance
				
			) ------ fin du while retrécissement ------------------------------
			
			
			
			
			-- 		|       *   pour chaque points (id_pt) du polygone (pts_poly):
			-- 		|               -   on cherche les intersection entre la demi-droite formée par sa trajectoire (pts_pos_dest[id_pt] - pts_pos_backet[id_pt]) chacun des segments du polygone (pt_evnt):
			-- 		|                       ==>     on a une intersection:
			-- 		|                                       -   On calcul la distance à parcourir pour atteindre le moment de l'intersection (dist_avt_intersec).
			-- 		|                                       -   et donc on déclanche un 'Evnmt de Division' à la distance de l'intersection (dist_avt_intersec).
			-- 		|                       ==>     on a plusieurs intersections:
			-- 		|                                       -   On calcul pour chaque intersections trouvées la distance à parcourir pour les atteindre, pour trouver la plus petite (dist_intersec_min).
			-- 		|                                       -   et donc on déclenche un 'Evnmt de Division' à la distance de l'intersection la plus proche (dist_intersec = dist_intersec_min).
			-- 		|                       ==>     on a pas d'intersections: on continue tranquilou.
			-- 		|
			-- 		|       *   pour chaque évenement rencontré, d'abord les 'Evts de segment', puis les 'Evnmts de Division':
			-- 		|               1) Les 'Evnmts de Segment':     
			--		|										--> index du point évenement:       (id_pt_evnt)
			-- 		|                                              	 --> position du point évènement:    (pos_pt_evnt)
			-- 		|
			-- 		|                           *   On ajoute aux points pour la face du segment evenement (pans_points[id_pt_evnt]) la position du point evenement (pos_pt_evnt)
			-- 		|                           *   On créé la face formée par nos points (pans_points[id_pt_evnt])
			-- 		|                           *   On retire le point source de l'évènement (id_pt_evnt) de la liste des points du polygone (pts_poly) et de la liste des faces à créer (pans_points).
			-- 		|                           *   On met à jour les index des points des evenement restant à traiter (on retire 1 aux points étant après (id_pt_evnt)).
			-- 		|                           *   On ajoute à la liste de points des pans du segment précedant le point evenement (pos_pt_evnt) au début de la liste.
			-- 		|                           *   On ajoute à la liste de points des pans du segment suivant le point evenement (pos_pt_evnt) à la fin de la liste.)
			-- 		|
			-- 		|               2) Les 'Evnmts de Division':    
			--		|										--> index du point évenement:       (id_pt_evnt)
			-- 		|                                               	--> position du point évènement:    (pos_pt_evnt)
			-- 		|                                               	--> segment_intersection:           (id_pt_intersec)
			-- 		|
			-- 		|                           *   On obtient 2 polygones :    #( id_pt_intersec+1 -> id_pt_evnt )
			-- 		|                                                           #( id_pt_evnt       -> id_pt_intersec )
			-- 		|                           *   On construit les listes des faces pour chaque polygone (pans_pts_poly_1 et pans_pts_poly_2)
			-- 		|                           *   On met à jour les index des points des evenement restant à traiter (on retire 1 aux index étant après (id_pt_evnt)).
			-- 		|                           *   On relance avec les 2 polygones obtenues, en faisant passer les listes des faces respectives (pans_pts_poly_1 et pans_pts_poly_2).
			-- 		|                           *   On arrete cette boucle. FIN
			-- 		|
			-- 		|       *   On met à jour la distance parcourue (dist_parcourue) en lui ajoutant la distance à indenter (indant_distance) ou la distance parcourue (dist_avt_intersec) si il y a eu un 'Evnmt de Division'.


		)

)   --  fin structure -------------------------------













clearlistener ()


squel = str_squelettisation ()


shp = $Line001
pts = for i = 1 to numknots shp collect getKnotPoint  shp 1 i 

pts

squel.executer pts







