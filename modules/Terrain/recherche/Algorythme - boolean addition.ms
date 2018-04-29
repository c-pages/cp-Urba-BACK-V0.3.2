/*


-------------------------------------------------------------------------------------	CALCULER_BOOLEEN  	poly_A	poly_B	#opertation		-------------------------------------------------------------------------------------
	*	On retourne les tracé en creux
	* 	On calcul les intersections
	*	....

-------------------------------------------------------------------------------------	OPERER_POLYGONES	poly_A	poly_B	#opertation		-------------------------------------------------------------------------------------

*******************************************************************************************************	
***						 				#opertation:	ADDITION	:	A+B								     ****
*******************************************************************************************************

	*	Suivant la position relative entre A et B : 
				
				# 	A Coté:		En mode #Addition, les deux polys sont validés	=> 	RESULT_INTREGRATION = FALSE
										=> 	RESULT_polys		= #( A, B )
				
				#	Interieur:		B étant entierement dans A, on regarde d'abord les operations entre B et les enfants de A:
										*	pour chaque  A_enfant
														---->	OPERER_POLYGONES		A_enfant + B		#ADDITION
										*	Si aucun A_enfant n'a integré B alors on ajoute B est un enfant de A		=>	A(B)
										=> 	RESULT_INTREGRATION = TRUE
										=> 	RESULT_polys	= #( A(B) )
										
										
				#	Exterieur:	B intègre entirement A, donc on regarde d'abord les operations entre A et les enfants de B:
										*	pour chaque  B_enfant
														---->	OPERER_POLYGONES 		B_enfant + A		#ADDITION
										*	Si aucun B_enfant n'a integré A alors B est le parent de A		=>	B(A)
										=> 	RESULT_INTREGRATION = TRUE
										=> 	RESULT_polys	= #( B(A) )
										
				#	SeCoupent:	On va avoir un ou plusieurs polygones à renovoyer :
										*	On retire A de son parent.
											On calcul le booleen			 CALCULER_BOOLEEN		A + B (ope_A_B)
											RESULT_polys	= #( ope_A_B )
										*	puis pour chaque B_enfant
												------>		OPERER_POLYGONES 		A + B_enfant 	(ope_A_enfantB)
												on ajoute à 	RESULT_polys	 ( ope_A_enfantB )
										*	puis pour chaque A_enfant :
												------>		OPERER_POLYGONES	 	A_enfant + B 	(ope_enfantA_B)
												on ajoute à 	RESULT_polys	 ( ope_enfantA_B )
												* puis avec chaque B_enfant :
													------>		OPERER_POLYGONES	 	 A_enfant + B_enfant 	(ope_enfantA_enfantB)
													on ajoute à 	RESULT_polys	 ( ope_enfantA_enfantB )
										=> 	RESULT_INTREGRATION = TRUE
										

	*	On renvois	 RESULT_INTREGRATION 		et 		RESULT_polys






------------------------------------------------------------------------------------	OPERER_CALQUES		calque_A		calque_B		#opertation		-------------------------------------------------------------------------------------
	*	Polys_operants = les polygones du calque B.
	*	Pour chaque polygone du calque A : Poly_A
				---->	Porteur_resultats = Vide
				*		 avec chaque polygone de polys_operants : Poly_operant
								---->	On calcul le booleen	OPERER_POLYGONES	poly_A	poly_B	#operation
								---->	Et on ajoute le resultat à 	Porteur_resultats
				---->	Si aucune operation n'a integré Poly_A, on l'ajoute aux resultats.
				---->	on passe les resultats de chaque tour de poly_A	en tant que operants	:	Polys_operants = Porteur_resultats pour recommancer avec le 	Poly_A suivant.
	*	on renvois 	Porteur_resultats.





 */
 
 
 
 
 /* 
			 
			 
			 
				__________________________________________________________________________________
				
								fn 	OPERATION_BOOL		calque_A  	calque_B		#Operation 
				__________________________________________________________________________________
				
				*	On prend tout les polygones des calques : Polys_A et Polys_B. (avec toute leur descendance !)
				
				*	On analyse les intersections entre chacuns de ces polygones.
						---->	on recupère la liste des intersections et les polygones sans intesections (polygones isolés).
				*	On s'occupe des polygones isolés : en fonction de l'operation on va ajouter, ou pas, les polygones au resultat:
						---->		#Addition : 		On ajoute tout les polygones isolés.
						---->		#Soustraction : 	On ajoute les polygones isolés du Calque A.
						---->		#Union : 			On ajoute rien.
				*	On choisi la premiere intersection et le sens de départ.
				*	On boucle tant qu'il reste des intersections à intégrer :
						---->	on ajoute les points jusqu'à la prochaine intersection
						---->	une fois à l'intersection on regarde ce que l'on fait:	choix du polygone courant et de la direction en fonction de l'opération en cours.
						---->	Si on arrive au point initial: On ajoute le polygone obtenu aux resultats.
				*	On renvois les resultats (dans un calque ?)
			 
			 
			 
			 
			 
			 
			 
			 
			 
  */
 
 
		fn operation_booleene 		_calque_A		_calque_B		operation:#union =(
			/*__________________________________________________________________________________
			
							fn 	OPERATION_BOOL		calque_A  	calque_B		#Operation 
			__________________________________________________________________________________
			
			*	On prend tout les polygones des calques : Polys_A et Polys_B. (avec toute leur descendance !)
			
			*	On analyse les intersections entre chacuns de ces polygones.
					---->	on recupère la liste des intersections et les polygones sans intesections (polygones isolés).
			*	On s'occupe des polygones isolés : en fonction de l'operation on va ajouter, ou pas, les polygones au resultat:
					---->		#Addition : 		On ajoute tout les polygones isolés.
					---->		#Soustraction : 	On ajoute les polygones isolés du Calque A.
					---->		#intersection : 	On ajoute rien.
			*	On choisi la premiere intersection et le sens de départ.
			*	On boucle tant qu'il reste des intersections à intégrer :
					---->	on ajoute les points jusqu'à la prochaine intersection
					---->	une fois à l'intersection on regarde ce que l'on fait:	choix du polygone courant et de la direction en fonction de l'opération en cours.
					---->	Si on arrive au point initial: On ajoute le polygone obtenu aux resultats.
			*	On renvois les resultats (dans un calque ?)
			__________________________________________________________________________________*/

			--- On renvois un calque	-------------
			local 	calque_result = this.creer_calque	nom:"RESULTAT BOOL"
			
			---- 		On prend tout les polygones des calques : Polys_A et Polys_B. (avec toute leur descendance !)		----------------
			local 	polys_A	=	_calque_A.get_polygones ()
			local 	polys_B	=	_calque_B.get_polygones ()
			
			---- on retire tout les enfants de tout le monde -------------
			for poly in polys_A do	poly.enfants = #()
			for poly in polys_B do	poly.enfants = #()
			
			debug "-----------------------------------------------------------------"
			debug "polys_A"	var:polys_A param:#nom
			debug "polys_B"	var:polys_B param:#nom
			
			
			
			
			---- 		On analyse les intersections entre chacuns de ces polygones.		----------------
			---- 				---->	on recupère la liste des intersections et les polygones sans intesections (polygones isolés).		----------------
			struct intersection (
				pos,
				poly_A,
				poly_B,
				id_pt_A,
				id_pt_B
			)
			
			local intersections	=#()
			local ids_polys_A_isoles	=#{1..polys_A.count}
			local ids_polys_B_isoles	=#{1..polys_B.count}
			
			for id_A in 1 to polys_A.count do (
				local poly_A = polys_A[ id_A ]
				for id_B in 1 to  polys_B.count do (
					local poly_B = polys_B[ id_B ]
					
					local pos_relative = 	poly_A.get_positionRelative		poly_B
					case pos_relative.position		of (								
						#aCoté:	 		(
							
							)
						#interieur:		(
								
							)
						#exterieur:		(
								
							)
						#seCroisent:	(
								ids_polys_A_isoles[ id_A ] = false
								ids_polys_B_isoles[ id_B ] = false
								for inter in pos_relative.intersections do (
									local nvl_intersection = intersection 	pos:		inter.pos	\
																						poly_A:	poly_A		\
																						poly_B:	poly_B		\
																						id_pt_A:	inter.id_A	\
																						id_pt_B:	inter.id_B
									append	intersections	nvl_intersection
								)
							)
					)	--	fin case of position relative	----------------
					
				)
				
			)---- fin for poly_A	------------
			
			debug "-----------------------------------------------------------------"
			debug "intersections"	var:intersections
			debug "ids_polys_A_isoles"	var:ids_polys_A_isoles --	param:#nom
			debug "ids_polys_B_isoles"	var:ids_polys_B_isoles	--	param:#nom
			
			
			
			
			
			
			
			/* 
			---- 		On s'occupe des polygones isolés : en fonction de l'operation on va ajouter, ou pas, les polygones au resultat:		----------------
			case operation of (
					#addition:	 	(
						--------	Addition : 		On ajoute tout les polygones isolés.		--------------------------------
						for id_poly in ( ids_polys_A_isoles as array) do
							calque_result.ajouter_polygone	polys_A[ id_poly ]
						for id_poly in ( ids_polys_B_isoles as array) do
							calque_result.ajouter_polygone	polys_B[ id_poly ]
					)
					#soustraction:	 (
						--------	Soustraction : 	On ajoute les polygones isolés du Calque A.		----------------------------
						for id_poly in ( ids_polys_A_isoles as array) do
							calque_result.ajouter_polygone	polys_A[ id_poly ]
					)
					#intersection:	 (
						--------	intersection : 			On ajoute rien.		------------------------------------------------							
					)
					#union:			(
						--------	intersection : 			On ajoute tout.		------------------------------------------------
						for id_poly in ( ids_polys_A_isoles as array) do
							calque_result.ajouter_polygone	polys_A[ id_poly ]
						for id_poly in ( ids_polys_B_isoles as array) do
							calque_result.ajouter_polygone	polys_B[ id_poly ]						
					)
			)
			
			
			
			 */
			
			
			
			---- 		On boucle tant qu'il reste des intersections à intégrer :		----------------
			local	il_reste_des_points 	=	intersections.count > 0  and operation != #union
			local ids_intersections_aTraiter 	= #{1..intersections.count}
			local sauvetage 				=	0
			
			local annuler = false
			while il_reste_des_points	and not annuler do (
				
				format"\n\n\n\n"
				debug "------------------------------------------------------------------------------------------"
				debug "						On boucle tant qu'il reste des intersections à intégrer "
				debug "ids_intersections_aTraiter" var:ids_intersections_aTraiter 
				
				
				---- Le point demarrage, la premiere intersection de la liste --------------------
				local id_intersection_aTraiter = ( ids_intersections_aTraiter as array )[1]
				local intersection_aTraiter		=	intersections[ id_intersection_aTraiter ]
				ids_intersections_aTraiter [ id_intersection_aTraiter ] = false
			
				---- Les conditions initiales	------------------------------------------------------
				local shp_initial		
				local id_pt_initial			
				local pt_initial 				
				local operateur_courant 
				local poly_courant
				
				---- on regarde la position du point d'intersection pour voir si on bascule tout de suite de polygone --------------------
				local poly_A						=	intersection_aTraiter.poly_A
				local poly_B						=	intersection_aTraiter.poly_B
				
				local pts_A							= 	poly_A.get_pts()
				local pts_B							= 	poly_B.get_pts()
				
				poly_courant 			= poly_A
				poly_autre				= poly_B
				shp_initial				= poly_courant.get_pts ()
				operateur_courant	=	#A
				id_pt_initial				=	intersection_aTraiter.id_pt_A
						
				
				pt_initial				=	intersection_aTraiter.pos--shp_initial[ id_pt_initial ]
				
				
				
				
				
				
				
				
				local shp_courant	= shp_initial	
				local shp_autre		= poly_autre.get_pts ()
				
				local sens 				= 1
				if 	poly_courant.en_creux	do 	 sens = 1
				
				
				----- INtersection : on regarde ou l'on va -----------------------------
				case operation of (
					#addition: (
						
						local pt_test_intersection		=	intersection_aTraiter.pos
						
						local shp_autre
						local pt_test_courant
						local pt_test_autre
						if operateur_courant		==	#A	then (
							
							local poly_test_courant 	= intersection_aTraiter.poly_A
							local id_ptTest_courant =  intersection_aTraiter.id_pt_A
							if poly_test_courant.en_creux do id_ptTest_courant = mgr_shp.boucler		shp_courant	(id_ptTest_courant+1)
							pt_test_courant		= 	shp_courant[ id_ptTest_courant ]
							
							
							local poly_test_autre 		= intersection_aTraiter.poly_B
							shp_autre 						= intersection_aTraiter.poly_B.get_pts()
							local id_ptTest_autre =  intersection_aTraiter.id_pt_B
							if poly_test_autre.en_creux do id_ptTest_autre = mgr_shp.boucler		shp_autre	(id_ptTest_autre+1)
							pt_test_autre		= 	shp_autre[ id_ptTest_autre ]
							
						) else (
							
							local poly_test_courant 	= intersection_aTraiter.poly_B
							local id_ptTest_courant =  intersection_aTraiter.id_pt_B
							if poly_test_courant.en_creux do id_ptTest_courant = mgr_shp.boucler		shp_courant	(id_ptTest_courant+1)
							pt_test_courant		= 	shp_courant[ id_ptTest_courant ]
							
							
							local poly_test_autre 		= intersection_aTraiter.poly_A
							shp_autre 						= intersection_aTraiter.poly_A.get_pts()
							local id_ptTest_autre =  intersection_aTraiter.id_pt_A
							if poly_test_autre.en_creux do id_ptTest_autre = mgr_shp.boucler		shp_autre	(id_ptTest_autre+1)
							pt_test_autre		= 	shp_autre[ id_ptTest_autre ]
							
							
						)
						local operateur_est_aGauche = mgr_shp.est_aGauche		pt_test_courant		pt_test_intersection 	pt_test_autre	
						if  operateur_est_aGauche 	do (
							
							debug"##########	EST_AGAUCHE		##########################"
							poly_courant 			= poly_B
							shp_initial				= poly_courant.get_pts ()
							shp_courant	= shp_initial	
							operateur_courant	=	#B
							id_pt_initial				=	intersection_aTraiter.id_pt_B		
						)
						
					)
					
				)
				
				
				
				----- les points du polygone que l'on va creer ----------------
				local shp_enConstruction = #()
				
				
				sens = if 	poly_courant.en_creux	then 	-1	else 1
				
				--- le point courant initial	----------				
				if sens == -1 do id_pt_initial = mgr_shp.boucler	shp_courant (id_pt_initial+1)
				local id_pt_courant	=	id_pt_initial
				local pt_courant		=	pt_initial
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				------ Tant qu'on est pas retourné à notre point de départ	----------------------------------------------------------------------------------------------------------------
				local on_a_fini_laBoucle = false
				local annuler = false
				while not on_a_fini_laBoucle  and not annuler	do (
					
					local on_continue = true
					
					while on_continue and not annuler		do (
						
						append 	shp_enConstruction		pt_courant
						
						debug "operateur_courant" var:operateur_courant
						debug "id_pt_courant" var:id_pt_courant
						debug "pt_courant" var:pt_courant
						debug "shp_enConstruction" var:shp_enConstruction
						
						debug "sens" var:sens 
						debug "------------------------------------------------------------------------------------------"
						
						--- on cherche la prochaine intersection ------------
						local dist_proche = 1e+10
						local prochaine_intersec = undefined
						
						for 	intersection in 	intersections  do (								
-- 							debug "			--> intersection" var:intersection
-- 							debug "			-->par la : #1"
							local id_pt_test = id_pt_courant
							if sens == - 1 do id_pt_test = mgr_shp.boucler	shp_courant	(id_pt_test - 1 )
							
							---- pour choisir la plus proche ---------------
							if distance pt_courant	intersection.pos < 	dist_proche do (								
-- 								debug "			-->par la : #2"
								
								---- pour choisir une intersection qui ne soit pas là ou l'on est ---------------
								if distance pt_courant		intersection.pos 	> SEUIL_POINTS_EGAUX do (
-- 									debug "			-->par la : #3"
									
									if operateur_courant 	==	#A then (
-- 										debug "			-->par la : #4-1"
-- 										if 
										if poly_courant == intersection.poly_A 	and 	intersection.id_pt_A == id_pt_test	do ( 
-- 											debug "			-->par la : #5-1"
											local id_pt_base = 	intersection.id_pt_A 
											if sens == - 1 do id_pt_base = mgr_shp.boucler	shp_courant	(id_pt_base + 1 )
											local pt_base = shp_courant[	id_pt_base  ]
											if 	( distance pt_courant		pt_base + distance pt_courant		intersection.pos )  - distance intersection.pos  pt_base 			< SEUIL_POINTS_EGAUX do	(
-- 												debug "			-->par la : #6-1 ##################"
												
													dist_proche = distance pt_courant	intersection.pos
													prochaine_intersec = intersection
												)
										)
									) else (
-- 										debug "			-->par la : #4-2"
										if poly_courant == intersection.poly_B 	and 	intersection.id_pt_B == id_pt_test	 do ( 
-- 											debug "			-->par la : #5-2"
											local id_pt_ope = 	intersection.id_pt_B
											if sens == - 1 do id_pt_ope = mgr_shp.boucler	shp_courant	(id_pt_ope + 1 )
											local pt_ope = shp_courant[	id_pt_ope  ]
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
						
						---- si on a une intersection ----------------
						if prochaine_intersec != undefined then (
							
							debug "--->	INTERSECTION"
							
							--- on change de noeud courant	------
							if  operateur_courant 	==	#A 	then (
								
								operateur_courant 	=	#B
								poly_courant = prochaine_intersec.poly_B
								shp_courant	= 	prochaine_intersec.poly_B.get_pts ()
								id_pt_courant 	=  prochaine_intersec.id_pt_B
								
							) else (
								operateur_courant 	=	#A
								poly_courant = prochaine_intersec.poly_A
								shp_courant	= 	prochaine_intersec.poly_A.get_pts ()
								id_pt_courant 	=  prochaine_intersec.id_pt_A									
							)
							
							sens = if 	poly_courant.en_creux	then 	-1	else 1
							
-- 							-----  on valide  ------------------
							pt_courant 		=	prochaine_intersec.pos		
							if sens == -1 	do 	id_pt_courant		= mgr_shp.boucler		shp_courant	( id_pt_courant + 1 )
							
							id_intersection_aTraiter	=	findItem	intersections		prochaine_intersec
							ids_intersections_aTraiter [ id_intersection_aTraiter ] = false
							
							
							--- on sort ----------
							on_continue = false
							
						---- si on a  pas d' intersection, on passe au point suivant ----------------
						) else (
							
							debug "--->	SUIVANT"
							
							id_pt_courant 		= mgr_shp.boucler	shp_courant		( id_pt_courant + sens )
							pt_courant 		= shp_courant [ id_pt_courant ]
							
						)
						
					
						debug "--------------------------------------------"
						debug "prochaine_intersec" var:prochaine_intersec
						debug "intersection_aTraiter" var:intersection_aTraiter
						debug "--------------------------------------------"
						format"\n\n"
						
						--- SAUVETAGE	----
						sauvetage += 1
						if sauvetage > SAUVETAGE_MAX do 
							annuler = true
						
						
					) -- FIN --- on fait le segment  jusqu'a la prochaine intersection 	-------------------------
					
					
					----------- ( 3 )	sortie ? si on est retourné sur le point initial, on sort	--------------------------------------------	
					
					if distance	pt_courant  pt_initial <  SEUIL_POINTS_EGAUX	then 
						on_a_fini_laBoucle = true
					
						format"\n\n"
						format"\n\n"
						format"\n\n"
						debug "--------------------------------------------------------------------------------------"
						debug "pt_courant" var:pt_courant
						debug "pt_initial" var:pt_initial
						debug "on_a_fini_laBoucle" var:on_a_fini_laBoucle
						debug "--------------------------------------------------------------------------------------"
						format"\n\n"
						format"\n\n"
						format"\n\n"
					
					
					
					--- SAUVETAGE	----
					sauvetage+= 1
					if sauvetage > SAUVETAGE_MAX do annuler = true
					
				)	---- Fin -	tant qu'on a pas fini la boucle	------------------------------------------------------------------------------------------------------
				
				
				
				
				
				--- on creer le noeud resultat -----------
				local nv_poly = mgr_polys.creer_polygone 	pts:shp_enConstruction	\
																	nom:(intersection_aTraiter.poly_A.nom + "_" +intersection_aTraiter.poly_B.nom  + "_" + calque_result.polygones.count as string )	 
				
				
				---- on ajoute le noeud obtenu -----------------------------------
				calque_result.ajouter_polygone	nv_poly
				
				
				---------- SORTIES ---------------------------------------------
				---- test pour sortie  correct	----------------------------------------------------------------------------------------------------

			 	if 	(ids_intersections_aTraiter as array ).count ==  0	do (
					il_reste_des_points = false
					
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
			
			
			
			
			---- 		On s'occupe des polygones isolés : en fonction de l'operation on va ajouter, ou pas, les polygones au resultat:		----------------
			local polys_A_isoles = for id_poly in (ids_polys_A_isoles as array ) collect polys_A[ id_poly ]
			local polys_B_isoles = for id_poly in (ids_polys_B_isoles as array ) collect polys_B[ id_poly ]
			
			case operation of (
					#addition:	 	(
						--------	Addition : 		On ajoute tout les polygones isolés.		--------------------------------
						for poly in polys_A_isoles do
							calque_result.ajouter_polygone	poly
						for poly in polys_B_isoles  do
							calque_result.ajouter_polygone	poly
					)
					#soustraction:	 (
						--------	Soustraction : 	On ajoute les polygones isolés du Calque A.		----------------------------
						for id_poly in ( ids_polys_A_isoles as array) do
							calque_result.ajouter_polygone	polys_A[ id_poly ]
					)
					#intersection:	 (
						--------	intersection : 			On ajoute rien.		------------------------------------------------							
					)
					#union:			(
						--------	intersection : 			On ajoute tout.		------------------------------------------------
						for id_poly in ( ids_polys_A_isoles as array) do
							calque_result.ajouter_polygone	polys_A[ id_poly ]
						for id_poly in ( ids_polys_B_isoles as array) do
							calque_result.ajouter_polygone	polys_B[ id_poly ]						
					)
			)
			
			
			
			debug "---------	CALQUE_RESULT	--------------------------------------------------------"
			debug_calque	calque_result
			
			
			calque_result
		),
		
		
		