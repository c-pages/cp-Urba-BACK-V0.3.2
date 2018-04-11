
		
		-------		3 operations :	#addition ( A + B ), #soustraction ( A - B ) et #intersection ( A | B ).	---------------------------
		fn operation_booleenne		operation			_nd_base 			_nd_operateur			 =(
			
			debug "operation_booleenne"
			debug "type"	var:operation
			

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
			local 	result_pts_shps = #()
			
			
			
			-------  ( 0 )	les noeuds en jeux	----------------------------------------------------------------------------------------------------------------------------------------------------------
			nds_bases			=	#( copy _nd_base ) 		+	( deepcopy ( _nd_base.get_descendance ()	)	)
			nds_operateurs	=	#( copy _nd_operateur ) 	+	( deepcopy ( _nd_operateur.get_descendance ()	)	)
			
			--- si on sousrtrait, on inverse les pleins et creux	-------------
			if operation == #soustraction do (
-- 				for i = 1 to nds_bases.count 	do
-- 					nds_bases[i].en_creux	=	not  nds_bases[i].en_creux	
				for i = 1 to nds_operateurs.count 	do
					nds_operateurs[i].en_creux	=	not  nds_operateurs[i].en_creux	
			)
			
			
			--- on retourne les pts des noeuds en creux -------------------
			--- bases	--
			for i = 1 to nds_bases.count where nds_bases[i].en_creux do 
					nds_bases[i].pts = changer_sens 	nds_bases[i].pts 
			--- operateurs ----
			for i = 1 to nds_operateurs.count where nds_operateurs[i].en_creux do 
					nds_operateurs[i].pts = changer_sens 	nds_operateurs[i].pts 
			
			
			debug "nds_bases" var:nds_bases				param:#nom
			debug "nds_operateurs" var:nds_operateurs	param:#nom
			
			
			
			---------  ( 0 )		les intersections  operateur <--> bases		 ---------------------------------------------------------------------------------------------------------------------------
			local intersections_total =#()		
			for nd_ope in nds_operateurs do (
				for i in 1 to nd_ope.pts.count do (
					
					local pt_ope 			= nd_ope.pts[i]
					local i_svt				= if i == nd_ope.pts.count then 1 else  i + 1
					local pt_ope_svt 	= nd_ope.pts[ i_svt ]
					
					for nd_base in nds_bases do (
						for j in 1 to nd_base.pts.count do (
							
							local pt_base 			= nd_base.pts[ j ]
							local j_svt				= if j == nd_base.pts.count then 1 else  j + 1
							local pt_base_svt 	= nd_base.pts[ j_svt ]
							
							local intersection_pos 	= get_intersection_vecteurs	pt_ope	pt_ope_svt		pt_base	pt_base_svt
							if intersection_pos != undefined  do (
								append intersections_total ( str_intersection 	pos:					intersection_pos	\
																								nd_operateur:		nd_ope				\
																								id_operateur:		i 						\
																								nd_base:			nd_base				\
																								id_base:				j )
							)
						)
					)
				)			
			)
			local ids_intersections_aTraiter	=#{1..intersections_total.count}
			
			
			
			
			
			
			
			
			
			---- tant qu'il reste des points à traiter	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
			local	il_reste_des_points 	=	true
			local sauvetage 				=	0
			local sauvetage_max 		= 200
			while il_reste_des_points	and sauvetage < sauvetage_max do (
				
				sauvetage += 1
				format "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
				debug "------------------------------------------------- TANT QU'IL RESTE DES POINTS à TRAITER	--------------------------------------------------------------------------------------------------------------------------------------------------------------------"
				
				local result_pts = #()

				---- Le point demarrage, la premiere intersection de la liste --------------------
				local intersection_aTraiter		=	intersections_total[ ( ids_intersections_aTraiter as array )[1] ]
				debug "intersection_aTraiter" 	var:intersection_aTraiter
				
				
				---- les noeuds initiaux -------------------------
				local nd_initial						=	intersection_aTraiter.nd_base
				local id_pt_initial					=	intersection_aTraiter.id_base
				
				---- on regarde la position du point d'intersection pour voir si on inverse les noeuds --------------------
				local pt_test_intersection		=	intersection_aTraiter.pos
				local pt_test_operateur		= 	intersection_aTraiter.nd_operateur.pts[ intersection_aTraiter.id_operateur ]
				local pt_test_base				= 	intersection_aTraiter.nd_base.pts[ intersection_aTraiter.id_base ]
				
				if operation == #addition then
					if  est_aGauche		pt_test_base		pt_test_intersection 	pt_test_operateur		do (
						nd_initial					=	intersection_aTraiter.nd_operateur
						id_pt_initial					=	intersection_aTraiter.id_operateur
						
						debug "On inverse les noeuds initiaux"
					)
					
				else if operation == #soustraction then
					if not  est_aGauche		pt_test_base		pt_test_intersection 	pt_test_operateur		do (
						nd_initial					=	intersection_aTraiter.nd_operateur
						id_pt_initial					=	intersection_aTraiter.id_operateur
						
						debug "On inverse les noeuds initiaux"
					)
					
					
				
					
				debug "nd_initial" var:nd_initial param:#nom
				
				local pt_initial 				= intersection_aTraiter.pos
				
				
				
				------ ( B )	On initialise les contitions courantes	----------------------------------------------------------------------------------------------------------------------------------------------
				--- le point courant initial	----------
				local nd_courant		=	nd_initial
				local nds_aTester	= 	if est_nd_deBase	nd_courant then 	nds_operateurs else		nds_bases
				
				local id_pt_courant	=	id_pt_initial
				local pt_courant		=	pt_initial
				
				local sens = 1
				
				
				
				
				
				
				
				
				
				
				
				
				
				------ ( C ) 	Tant qu'on est pas retourné à notre point de départ	----------------------------------------------------------------------------------------------------------------
				local on_a_fini_laBoucle = false
				while not on_a_fini_laBoucle  and sauvetage < sauvetage_max 	do (
					format "\n\n"
					debug "------------------------------------------------- tant qu'on a pas fini la boucle	----------------------------------------------------------------------------------------------------------------"
					
				
				
					debug "nd_courant" 		var:nd_courant.nom
					debug "nds_aTester" 	var:nds_aTester		param:#nom
					debug "id_pt_courant" 	var:id_pt_courant
					debug "pt_courant" 		var:pt_courant
					
					
					--- SAUVETAGE	----
					sauvetage+= 1
					
					
					----------- ( 1 )	Le point suivant	--------------------------------------------	
					local id_pt_svnt	= boucler	nd_courant.pts	 ( id_pt_courant + sens ) 
					local pt_suivant	=	nd_courant.pts[ id_pt_svnt ]
					
					
					
					
					----------- ( 2 )	intersection entre pt courant et pt suivant --------------------------------------------	
					local distMin =	1e+10
					local intersection  = undefined
					for nd in nds_aTester do (
						
						--- on cherche si intersection avec l'autres shapes ----
						for j = 1 to nd.pts.count do (
							
							local pt_autre			= 	nd.pts[ j ]
							local j_svt				=	boucler 	nd.pts		( j + 1 )
							local pt_autre_svt	= 	nd.pts[ j_svt ]
							
							local intersec_pos = get_intersection_vecteurs		pt_courant   pt_suivant		pt_autre		pt_autre_svt 
							if intersec_pos != undefined and distance intersec_pos 	pt_courant > .001 and distance pt_courant 	intersec_pos < distMin  do (
								intersection =  str_intersection 		nd:		nd					\
																				pos:		intersec_pos	\
																				id_pt:	j
								distMin = distance pt_courant 	intersec_pos
							)
						)
					)
					
					
					
					
					
					
					-----------------------	 ( 2.1 )	Si on a une intersection,  on passe au point d'intersection et on change de noeud  --------------------------------------------	
					if intersection != undefined then (
						----------------------------------> changement de noeud ----------------------------------
						----------------------------------		( a ) Addition	:			-	On inverse juste les noeuds
						----------------------------------		
						----------------------------------		 ( b ) Soustraction	:	-	On inverse juste les noeuds
						----------------------------------		
						----------------------------------		 ( c ) Intersection	:	-	On inverse juste les noeuds
						debug "---->	Intersection !"
						
-- 						
-- 						if est_aGauche 
						
						
						--- on change de noeud courant	------
						nd_courant		=	intersection.nd
						if est_nd_deBase		nd_courant 	then (
							debug "	--->	on est sur une base, on bascule sur l'operateur."
							nds_aTester	=	nds_operateurs
						) else (
							debug "	--->	on est sur l'operateur, on passe sur une base."							
							nds_aTester	=	nds_bases
						)
						
						-----  on valide si on est sur un point intersection ------------------
						id_pt_courant 	=  intersection.id_pt
						pt_courant 	=	intersection.pos
						
						append result_pts 	pt_courant
						local  i = 1 
						local trouve = false
						while i <= intersections_total.count and not trouve do (
							local inter = intersections_total[i]
							if distance inter.pos  pt_courant  <  .001  do (
								ids_intersections_aTraiter[ i ] = false
								trouve = true
							)
							i+=1
						)
						
						
						
						
						
						
						
					-----------------------	 ( 2.2 )	Si pas dintersection, on passe au point suivant --------------------------------------------	
					) else (
						debug "---->	point suivant !"
						--- on passe au POINT SUIVANT ----
						id_pt_courant	=	id_pt_svnt
						pt_courant		=	pt_suivant
						
						
						--	on ajoute le point --
						if operation != #intersection or   point_est_dansShape 	pt_courant  	_nd_operateur.pts do
							append result_pts 	( copy pt_courant )
						
					)
					
					
					
					
					
					
					
					----------- ( 3 )	sortie ? si on est retourné sur le point initial, on sort	--------------------------------------------	
					if distance	pt_courant  pt_initial < .001	then 
						on_a_fini_laBoucle = true
					
					
					
					
				)	---- Fin -	tant qu'on a pas fini la boucle	------------------------------------------------------------------------------------------------------
				
				
				
				---- on ajoute le shape obtenu -----------------------------------
				append 	result_pts_shps	result_pts
				
				
				---- test pour sortie ----------------------------------------------
				if ( ids_intersections_aTraiter as array).count ==0 do
					il_reste_des_points = false
				
			)	---- Fin -	tant qu'il reste des points à traiter		--------------------------------------------------------------------------------------------------------------------------------------------------------------------
						
					
					
			
			result_pts_shps
			
		),
		
		