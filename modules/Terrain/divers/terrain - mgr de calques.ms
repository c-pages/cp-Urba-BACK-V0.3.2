

include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\terrain - mgr de polygones.ms" 


----- un calque -------------------------------------------------------------------------------------------
struct str_calque (
	
		--------------- DEBUG --------------------------------------------		
		m_debug	=	true,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | clq."	  	var:var	 param:param		catch (),
		
		m_tab_format_poly = "    ",
		fn format_polygone 	_poly =(
			local indent_prfix = "|    "
			debug (  m_tab_format_poly +  "+ " + _poly.nom + "" )
			if _poly.enfants.count >0 	do	m_tab_format_poly += indent_prfix
			for enft in _poly.enfants 	do 	format_polygone enft
			if _poly.enfants.count >0 	do	m_tab_format_poly = substring m_tab_format_poly 1 (	m_tab_format_poly.count -	indent_prfix.count )
		),
		fn	debug_poly  _poly = if m_debug do (			 
			format_polygone 	_poly 
		),
		fn debug_calque	_calq	=(
			debug ( "calque: " + _calq.nom	+" ---------------------")
			for _poly in _calq.polygones do
				debug_poly _poly
		),	
		--------------- DEBUG --------------------------------------------
		
	
	
	
	
	
	
	
	
	
	private
		mgr_polys 		= str_mgr_polygones (),
		
	public					
		polygones		=	#(),
		operation		=	#addition,
		nom				=	"",
		
	---- fonctions	--------------------------------------------------------------
	public
		fn	ajouter_polygone		_polygone_aAjouter		/* 	brut_mode:false	 */	=	(
-- 			--format "\n\n"
			debug "==================	ajouter_polygone =================================================="
			debug "_polygone_aAjouter" var:_polygone_aAjouter.nom
			debug_calque this
			debug "===================================================================="
			
			local chrono_1 = timeStamp()
			
			local en_creux_BACK = _polygone_aAjouter.en_creux
			
			
			_polygone_aAjouter.calque = this
			
			--- on regarde si on peut l'inserer dans un polygone deja present dans le calque ----------------------------
			local a_ete_integre			=	false		
			local i = 1
			local polygones_aTraiter = for poly in polygones collect poly
			
			while	 i <= polygones_aTraiter.count and not a_ete_integre	do (
				local poly_calque				=	polygones_aTraiter[ i ]
				local chrono_2 = timeStamp()
				local integration_reussie	=	mgr_polys.inserer_poly_ds_poly		_polygone_aAjouter		poly_calque
				debug "inserer_poly_ds_poly" var:( (  ((timeStamp ()) - chrono_2 ) / 1000.0)		as string + " s.")
				if integration_reussie do a_ete_integre = true
				i += 1
			)
			
			debug "ajouter_polygone:	a_ete_integre" var:a_ete_integre
			---- s'il a pas été inserer, on l'ajoute basiquement aux polygones du calque- ---------------------------------
			if not a_ete_integre do (
				append 		polygones 		_polygone_aAjouter
				
				
			)
			
-- 			if brut_mode do _polygone_aAjouter.en_creux	=	en_creux_BACK
				
			
-- 			debug "a_ete_integre" var:a_ete_integre
			debug "polygones" var:polygones param:#nom
			
			debug_calque this
			debug "===================================================================="
			
			debug "--->	ajouter_polygone"  var:( (  ((timeStamp ()) - chrono_1 ) / 1000.0)		as string + " s.\n\n")
-- 			--format "\n\n"
			polygones
			
		),
		fn retirer_polygone		_polygone 		=(
			local id_polygone= findItem polygones	_polygone
			if id_polygone != 0 do
				deleteItem polygones id_polygone
		),
		fn get_polygones 	descendance:false	 =(	--	all:false
			
			local result = #()
			
			if descendance then 
				for poly in polygones do (
					local dup = mgr_polys.dupliquer 	poly
					result += dup.get_descendance ()	
				) 
			else
				result += 	for poly in polygones collect ( mgr_polys.dupliquer 	poly )
			/* 
			---- on duplique tout ?!? --------------
			local result_polys = #()
			for poly_source in result do
				append result_polys		( mgr_polys.dupliquer   poly_source  )
			
			result_polys
			*/
			result
		),
	
		
		
	public
		--------------------------- Trianguler  -------------------------------------------------------------------------------
		----- 	triangulation avec decoupage en polygones montones par balayage vertical et horizontal, 			----
		------	puis decoupage des polygones restant façon oreille peut etre...										----
		------------------------------------------------------------------------------------------------------------------------
		fn trianguler =(
			debug "trianguler"
			
			local result_triangles =#()
			for poly in polygones do
				result_triangles += poly.trianguler ()
			
			debug "result_triangles"
			result_triangles
			
		)
		
		
		
		
		
) ---- fin struct calque --------------------------------------------------------------------------------------------



struct	str_mgr_calques	(

	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	false,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | calq."	  	var:var	 param:param		catch (),
		
		m_tab_format_poly = "    ",
		fn format_polygone 	_poly =(
			local indent_prfix = "|    "
			debug (  m_tab_format_poly +  "+ " + _poly.nom + "" )
			if _poly.enfants.count >0 	do	m_tab_format_poly += indent_prfix
			for enft in _poly.enfants 	do 	format_polygone enft
			if _poly.enfants.count >0 	do	m_tab_format_poly = substring m_tab_format_poly 1 (	m_tab_format_poly.count -	indent_prfix.count )
		),
		fn	debug_poly  _poly = if m_debug do (			 
			format_polygone 	_poly 
		),
		fn debug_calque	_calq	=(
			debug ( "calque: " + _calq.nom	+" ---------------------" + _calq.operation )
			for _poly in _calq.polygones do
				debug_poly _poly
		),	
		
	public
		fn debug_pile	=	(
			debug "----------------------------------------------------------------------------"
			debug "				PILE des calques"
			local i = -1
			for calque in this.m_pile do (
				
				debug "----------------------------------------------------------------------------"
				debug ("	Calque " + (i+1) as string + " : [ " + calque.nom  + "(#" + calque.operation as name + ") ]" )
				debug "----------------------------------------------------------------------------"
				debug_calque calque
			)
			debug "----------------------------------------------------------------------------"
			
		),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		
		
		
		
		
		
		
		
	
	-----------------	Membres	------------------------------------------------------------------------------------------------------------------------------------------------------
	private	
		m_pile 		=	#(),
		
		---- Managers		----------------------------
		mgr_polys	=	str_mgr_polygones (),
		mgr_shp				=	str_outils_shape (),
		
	
		SEUIL_POINTS_EGAUX  	= .01,
		-- constante pr debug-----------------
		SAUVETAGE_MAX 			= 100,
	
	
	-----------------	Fonctions	internes ------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		
		
		----- operation Booleene entre calques ----------------
		fn operation_booleene 		_calque_A		_calque_B		operation:#union =(
			/*__________________________________________________________________________________
			
							fn 	OPERATION_BOOL		calque_A  	calque_B		#Operation 
			__________________________________________________________________________________
			
			*	On prend tout les polygones des calques : polys_A_total et polys_B_total. (avec toute leur descendance !)
			
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
			
			---- 		On prend tout les polygones des calques : polys_A_total et polys_B_total. (avec toute leur descendance !)		----------------
			local 	polys_A_total	=	_calque_A.get_polygones 	descendance:true
			local 	polys_B_total	=	_calque_B.get_polygones 	descendance:true
			
			---- on retire tout les enfants de tout le monde -------------
			for poly in polys_A_total do	poly.detacher ()
			for poly in polys_B_total do	poly.detacher ()
			
			---- les poly racines des calques	----------------
			local 	polys_A	=	_calque_A.get_polygones 	()
			local 	polys_B	=	_calque_B.get_polygones 	()
			
			
			debug "-----------------------------------------------------------------"
			debug "OPERATION BOOLENNE"	var:operation
			debug "polys_A_total"	var:polys_A_total param:#nom
			debug "polys_B_total"	var:polys_B_total param:#nom
			
			
			
			
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
			local ids_polys_A_isoles	=#{1..polys_A_total.count}
			local ids_polys_B_isoles	=#{1..polys_B_total.count}
			
			for id_A in 1 to polys_A_total.count do (
				local poly_A = polys_A_total[ id_A ]
				for id_B in 1 to  polys_B_total.count do (
					local poly_B = polys_B_total[ id_B ]
					
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
			
			
			
			
			
			
			
			---- 		On boucle tant qu'il reste des intersections à intégrer :		--------------------------------------------------------------------------------------------------
			local	il_reste_des_points 	=	intersections.count > 0  and operation != #union
			local ids_intersections_aTraiter 	= #{1..intersections.count}
			local sauvetage 				=	0
			
			local annuler = false
			while il_reste_des_points	and not annuler do (
				
				debug "\n\n\n\n"
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
				if 	poly_courant.en_creux	do 	 sens = -1
				
				
				----- INtersection : on regarde ou l'on va -----------------------------
-- 				case operation of (
-- 					#addition: (
						
						local pt_test_intersection		=	intersection_aTraiter.pos
						
						local shp_autre
						local pt_test_courant
						local pt_test_autre
						if operateur_courant		==	#A	then (
							
							local poly_test_courant 	= intersection_aTraiter.poly_A
							local id_ptTest_courant 	=  intersection_aTraiter.id_pt_A							
-- 							if 	poly_test_courant.en_creux	do 	 id_ptTest_courant = mgr_shp.boucler		shp_courant	(id_ptTest_courant+1)
								
							if poly_test_courant.en_creux do id_ptTest_courant = mgr_shp.boucler		shp_courant	(id_ptTest_courant+1)
							pt_test_courant				= 	shp_courant[ id_ptTest_courant ]
							
							
							local poly_test_autre 		= intersection_aTraiter.poly_B
							
							local sensB 				= 1
							if 	poly_test_autre.en_creux	do 	 sensB = -1
					
							shp_autre 						= intersection_aTraiter.poly_B.get_pts()
							local id_ptTest_autre 		=  intersection_aTraiter.id_pt_B
							if poly_test_autre.en_creux do id_ptTest_autre = mgr_shp.boucler		shp_autre	(id_ptTest_autre+1)
							pt_test_autre					= 	shp_autre[ id_ptTest_autre ]
							
						) else (
							
							local poly_test_courant 	= intersection_aTraiter.poly_B
							local id_ptTest_courant 	=  intersection_aTraiter.id_pt_B
							if 	poly_test_courant.en_creux	do 	 id_ptTest_courant = mgr_shp.boucler		shp_courant	(id_ptTest_courant+1)
-- 							if poly_test_courant.en_creux do id_ptTest_courant = mgr_shp.boucler		shp_courant	(id_ptTest_courant+sens)
							pt_test_courant				= 	shp_courant[ id_ptTest_courant ]
							
							
							local poly_test_autre 		= intersection_aTraiter.poly_B
							local sensB 				= 1
							if 	poly_test_autre.en_creux	do 	 sensB = -1
							shp_autre 						= intersection_aTraiter.poly_A.get_pts()
							local id_ptTest_autre 		=  intersection_aTraiter.id_pt_A
-- 							if 	poly_test_autre.en_creux	do 	 id_ptTest_autre = mgr_shp.boucler		shp_autre	(id_ptTest_autre+1)
							if poly_test_autre.en_creux do 	id_ptTest_autre = mgr_shp.boucler		shp_autre	(id_ptTest_autre+1)
							pt_test_autre					= 	shp_autre[ id_ptTest_autre ]
							
							
						)
						
						local operateur_est_aGauche = mgr_shp.est_aGauche		pt_test_courant		pt_test_intersection 	pt_test_autre	
						
						debug "operateur_est_aGauche" var:operateur_est_aGauche
						
						if   operateur_est_aGauche /* and operation != #intersection  */ or  operateur_est_aGauche and operation == #intersection 	do (
							
							debug"##########	 EST_AGAUCHE		##########################"
							poly_courant 			= poly_B
							shp_initial				= poly_courant.get_pts ()
							shp_courant			= shp_initial	
							operateur_courant	=	#B
							id_pt_initial				=	intersection_aTraiter.id_pt_B		
						)
						
-- 					)
-- 					
-- 				)
				
				
				
				----- les points du polygone que l'on va creer ----------------
				local shp_enConstruction = #()
				local en_creux = poly_courant.en_creux
				
				
				sens = 1
				debug "ici ------- > sens	---> operation" var:operation
				
				case operation of (
					#addition :(
						debug "ici ------- > #addition"
						if poly_courant.en_creux 	then  
							sens =	-1	
					)
					#soustraction:(
							debug "ici ------- > #soustraction"
						if operateur_courant 	==	#A and	poly_courant.en_creux 	then  
							sens =	-1	
							
						if 	operateur_courant 	==	#B and not poly_courant.en_creux 	then  
							sens =	-1	
					)
					#intersection:(
						
							debug "ici ------- > #intersection"
						if operateur_courant 	==	#A and	not poly_courant.en_creux 	then  (
							sens =	-1	
							debug "la"
						)
						if 	operateur_courant 	==	#B and  not poly_courant.en_creux	 then  (
							sens =	-1	
							debug "ici"
						)
					)
				)
				debug "ici ------- > sens" var:sens
				
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
						
						debug "poly_courant" var:poly_courant
						debug "operateur_courant" var:operateur_courant
						debug "id_pt_courant" var:id_pt_courant
						debug "pt_courant" var:pt_courant
						debug "shp_enConstruction" var:shp_enConstruction
						
						debug "sens" var:sens 
						debug "------------------------------------------------------------------------------------------"
						
						--- on cherche la prochaine intersection ------------
						local dist_proche = 1e+10
						local prochaine_intersec = undefined
						
						if not poly_courant.en_creux		do
							en_creux = false
						
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
							
							debug "--->	poly_courant	" var:poly_courant.nom							
							debug "--->				" var:poly_courant
							debug "--->	operation" var:operation	
							
							debug "--->	operation == #soustraction" var:(operation == #soustraction)	
							
							
							
							sens = 1							
							case operation of (
								#addition :(
									if poly_courant.en_creux 	then  
										sens =	-1	
								)
								#soustraction:(
									if operateur_courant 	==	#A and	poly_courant.en_creux 	then  
										sens =	-1	
										
									if 	operateur_courant 	==	#B and not poly_courant.en_creux then  
										sens =	-1	
								)
								#intersection:(
									
									if operateur_courant 	==	#A and	not poly_courant.en_creux 	then  
										sens =	-1	
										
									if 	operateur_courant 	==	#B and  not poly_courant.en_creux then  
										sens =	-1	
								)
							)
							
							
							debug "--->	sens" var:sens	
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
						debug "--------------------------------------------\n\n"
						
						--- SAUVETAGE	----
						sauvetage += 1
						if sauvetage > SAUVETAGE_MAX do 
							annuler = true
						
						
					) -- FIN --- on fait le segment  jusqu'a la prochaine intersection 	-------------------------
					
					
					----------- ( 3 )	sortie ? si on est retourné sur le point initial, on sort	--------------------------------------------	
					
					if distance	pt_courant  pt_initial <  SEUIL_POINTS_EGAUX	then 
						
						on_a_fini_laBoucle = true
					
						debug"\n\n\n\n\n\n"
						debug "--------------------------------------------------------------------------------------"
						debug "pt_courant" var:pt_courant
						debug "pt_initial" var:pt_initial
						debug "on_a_fini_laBoucle" var:on_a_fini_laBoucle
						debug "--------------------------------------------------------------------------------------\n\n\n\n\n\n"

					
					
					
					--- SAUVETAGE	----
					sauvetage+= 1
					if sauvetage > SAUVETAGE_MAX do annuler = true
					
				)	---- Fin -	tant qu'on a pas fini la boucle	------------------------------------------------------------------------------------------------------
				
				
				
				
				--- on creer le noeud resultat -----------
				local nv_poly = mgr_polys.creer_polygone 	pts:			shp_enConstruction	\
																			en_creux: 	en_creux\
																			nom:			(intersection_aTraiter.poly_A.nom + "_" +intersection_aTraiter.poly_B.nom  + "_" + calque_result.polygones.count as string )	 
				nv_poly.reset_sens ()
				
				---- on ajoute le noeud obtenu -----------------------------------
				calque_result.ajouter_polygone		nv_poly		--	brut_mode:true
				debug_calque	calque_result
				
				---------- SORTIES ---------------------------------------------
				---- test pour sortie  correct	----------------------------------------------------------------------------------------------------

			 	if 	(ids_intersections_aTraiter as array ).count ==  0	do (
					il_reste_des_points = false
					
				) 
				--- SAUVETAGE	----
				sauvetage += 1
				if sauvetage > SAUVETAGE_MAX do (
					annuler = true
					--format "\n\n"
					debug  "####################################################################################################################################"
					debug ( "##########################	/!\	SAUVETAGE : " + sauvetage as string  + " boucles !	/!\	####################################################################")
					debug  "####################################################################################################################################"
					--format "\n\n"
				)
				
			)	---- Fin -	tant qu'il reste des points à traiter		--------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
			
			
			
			
			
			
			
			
			
					debug  "######	1	##############################################################################################################################"
				debug_calque	calque_result			
					debug  "####################################################################################################################################"
			
			---- 		On s'occupe des polygones isolés : en fonction de l'operation on va ajouter, ou pas, les polygones au resultat:		----------------
			--format "\n\n"
				debug "--- les polygones isolés de A ----------------------------------------------------------------------------------------"
			
			
			
			--- les polygones isolés de A ----------------------------------------------------------------------------------------
			local polys_A_isoles = for id_poly in (ids_polys_A_isoles as array ) collect polys_A_total[ id_poly ]
			for poly_A_isol in polys_A_isoles do (
				
				local polyA_dans_polyB
				debug "-------> poly_A_isol" var:poly_A_isol
				--- avec les polygone de B -------------
				for poly_B in polys_B do (
					local est_ds_polyB	=	mgr_polys.est_dans_polygone		poly_B 		poly_A_isol	
					if est_ds_polyB	!= undefined do 
						polyA_dans_polyB = est_ds_polyB
					debug "	-------> polyA_dans_polyB" var:polyA_dans_polyB
				)
				
				--- on regarde dons si on est dans un vide -------------
				local est_dans_vide
				--- si notre polyA est dans un poly B : ---------				
				if polyA_dans_polyB != undefined then
					est_dans_vide = polyA_dans_polyB.en_creux
				else
					est_dans_vide = true
				
					debug "-------> est_dans_vide" var:est_dans_vide
				
				---- on regarde si on l'ajoute ou pas ----------------
				local on_ajoute = false
				case operation of (
					#addition: (
						---- V dans V =  true ----------
						if  poly_A_isol.en_creux	and est_dans_vide		then
							on_ajoute = true
						---- P dans V =  true ----------
						else if not poly_A_isol.en_creux	and est_dans_vide		then
							on_ajoute = true
						---- P dans P =  false ----------
						---- V dans P =  false ----------
					)
					#soustraction: (	------	ca a l'aire d'etre la meme logique que pour l'addition ...	----------------------------
						---- V dans V =  true ----------
						if  poly_A_isol.en_creux	and est_dans_vide		then
							on_ajoute = true
						---- P dans V =  true ----------
						else if not poly_A_isol.en_creux	and est_dans_vide		then
							on_ajoute = true
						---- P dans P =  false ----------
						---- V dans P =  false ----------
					)
					#intersection: (	
						if polyA_dans_polyB != undefined	and  not polyA_dans_polyB.en_creux	then
							on_ajoute = true

						---- V dans P =  true ----------
-- 						if  poly_B_isol.en_creux	and not est_dans_vide		then
-- 							on_ajoute = true
						---- P dans P =  true ----------
-- 						else if not poly_B_isol.en_creux	and not est_dans_vide		then
-- 							on_ajoute = true
						---- P dans V =  false ----------
						---- V dans V =  false ----------
					)
					
				)
				
					debug  "######	AVANT	##############################################################################################################################"
				debug_calque	calque_result			
					debug  "####################################################################################################################################"
			
				
				---- on ajoute le noeud obtenu -----------------------------------
				if on_ajoute do	
					calque_result.ajouter_polygone	poly_A_isol		--	brut_mode:true
				
					debug  "######	APRES	##############################################################################################################################"
				debug_calque	calque_result			
					debug  "####################################################################################################################################"
			
				
			) ---- fin polygones A isolés ---------------------------
			
			
			
			
			
			
			
			--format "\n\n"
			debug "--- les polygones isolés de B ----------------------------------------------------------------------------------------"
			--- les polygones isolés de B ----------------------------------------------------------------------------------------
			local polys_B_isoles = for id_poly in (ids_polys_B_isoles as array ) collect polys_B_total[ id_poly ]
			debug "polys_B_isoles" var:polys_B_isoles param:#nom
			for poly_B_isol in polys_B_isoles do (
				local polyB_dans_polyA
				
				debug "-------> poly_B_isol" var:poly_B_isol
				--- avec les polygones de A -------------
				for poly_A in polys_A do (
					local est_ds_polyA	=	mgr_polys.est_dans_polygone		poly_A 		poly_B_isol	
					if est_ds_polyA	!= undefined do 
						polyB_dans_polyA = est_ds_polyA
					debug "	-------> est_ds_polyA" var:est_ds_polyA
				)
				
				--- on regarde dons si on est dans un vide -------------
				local est_dans_vide
				--- si notre polyA est dans un poly B : ---------				
				if polyB_dans_polyA != undefined then
					est_dans_vide = polyB_dans_polyA.en_creux
				else
					est_dans_vide = true
				
				
				debug "-------> est_dans_vide" var:est_dans_vide
				---- on regarde si on l'ajoute ou pas ----------------
				local on_ajoute = false
				case operation of (
					#addition: (
						---- V dans V =  true ----------
						if  poly_B_isol.en_creux	and est_dans_vide		then
							on_ajoute = true
						---- P dans V =  true ----------
						else if not poly_B_isol.en_creux	and est_dans_vide		then
							on_ajoute = true
						---- P dans P =  false ----------
						---- V dans P =  false ----------
					)
					#soustraction: (	------	la c'est differents avec B ----------
						---- V dans P =  true ----------
						if  poly_B_isol.en_creux	and not est_dans_vide		then
							on_ajoute = true
						---- P dans P =  true ----------
						else if not poly_B_isol.en_creux	and not est_dans_vide		then
							on_ajoute = true
						---- P dans V =  false ----------
						---- V dans V =  false ----------
					)
					#intersection: (	
						---- V dans P =  true ----------
						if  poly_B_isol.en_creux	and not est_dans_vide		then
							on_ajoute = true
						
						if  not poly_B_isol.en_creux		and not est_dans_vide		then
							on_ajoute = true
						
						---- P dans P =  true ----------
-- 						else if not poly_B_isol.en_creux	and not est_dans_vide		then
-- 							on_ajoute = true
						---- P dans V =  false ----------
						---- V dans V =  false ----------
					)
					
				)
				
				debug "-------> on_ajoute" var:on_ajoute
				
				
				---- on ajoute le noeud obtenu -----------------------------------
				if on_ajoute do	
					calque_result.ajouter_polygone	poly_B_isol	--	brut_mode:true
				
				debug_calque	calque_result
				
				
			) ---- fin polygones A isolés ---------------------------
			
			
			
			
			
			
			
			
			
			
			
			
			debug "---------	CALQUE_RESULT	--------------------------------------------------------"
			debug_calque		calque_result
			--format "\n\n\n"
			
			calque_result
		),

		----- calculer la pile complete des calques ----------------
		fn calculer_pile	=(
			
			debug "calculer_pile ()"
			
			local result_calque = this.creer_calque ()
			if m_pile.count >0 then (
				--- on renvois un calque -----------
				result_calque = m_pile[1]	--	this.creer_calque ()
				
-- 				debug "----->	result_calque" var:result_calque
				---- pour chaque calque de la pile-------------
				for i = 2 to m_pile.count do (
					local calque = m_pile[i]
					--- on calcule l'operation avec chacun des polygones du calque pile	--------
					result_calque = 		operation_booleene		result_calque	calque	operation:calque.operation
					debug_calque		result_calque		
				)
				
			) 
			
			
-- 			debug_calque		result_calque		
			
			result_calque
		),
		
		
		
		
		
		
		
	-----------------	Interface	------------------------------------------------------------------------------------------------------------------------------------------------------
	public
		
	-------------- calques -----------------------------------------
		---- Manipulations -------------
		fn creer_calque		shape_node:	nom:"temporaire"		=(
			
			local chrono_1	=	timeStamp ()
			--- Creation d'un calque vide	---------
			local nv_calque = str_calque 	nom:nom
			
			--- Si on a un shape en entrée, on ajoute les polygones du shape au nv calque ----------
			if shape_node != unsupplied	do (
				
				nv_calque.nom 	= shape_node.name
				--- creation des polys à partir du shape -----
				local polygones 	= mgr_polys.creer_fromShape	shape_node
				
				--- Ajout des polys au nv calque -----
				for poly  in polygones do (
				local chrono_2	=	timeStamp ()
			
					nv_calque.ajouter_polygone 	poly
				debug "--->	nv_calque.ajouter_polygone"  var:( (  ((timeStamp ()) - chrono_2 ) / 1000.0)		as string + " s.")
				)
			)
			
			debug "--->	creer_calque"  var:( (  ((timeStamp ()) - chrono_1 ) / 1000.0)		as string + " s.")
			nv_calque
			
		),
		
	-------------- la pile -----------------------------------------
		---- Accessions -------------
		fn get_pts_resultat	=(
			local result = calculer_pile ()
			result.get_pts ()
		),
		
		fn get_calque_pile = (
-- 			debug "get_calque_pile"
			calculer_pile ()
			
		),
		
		fn get_calques = 	for calque in m_pile collect calque,
		
		---- Manipulations -------------
		fn vider = m_pile =#(),
		fn ajouter_calque		_calque			index:0	=(
			if index != 0 then 
				insertItem		_calque		m_pile	index
			else 
				append 	m_pile 	_calque
		),		
		fn supprimer_calque	_calque	=(
			
		)
		
		
		
		
		

) ---------- FIN structure mgr calques --------------------------------------------------------------






















