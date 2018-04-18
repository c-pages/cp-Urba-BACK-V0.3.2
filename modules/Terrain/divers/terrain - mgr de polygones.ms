
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - outils - shape.ms" 


---- polygone de la hierarchie ----------
struct str_polygone (
	--------- membres ------------------------------------------------------------------
	private
		
		
		
		mgr_shp				=	str_outils_shape (),
		pts 					=	#(),
		
		dist_auParent		=	0,
	public
		nom 					=	"",
		
		en_creux			=	true	,		---- si le polygone est  creux ou  plein
		
		
	public
		parent			=	undefined,
		enfants			=	#(),
		calque			,
		
		
	--------- Fonctions ------------------------------------------------------------------
	public					
		
		
		fn maj_enCreux			=(
			if parent != undefined then
				en_creux = not parent.en_creux
			else en_creux = false
			
			for enfant in enfants do
				enfant.maj_enCreux ()
		),
		
		fn est_enCreux	= en_creux,
		fn inverser_enCreux =	(
			en_creux = not en_creux
			for enfant in enfants do
				enfant.maj_enCreux ()
		),
		fn changer_sens =(
			mgr_shp.debug "changer_sens" var:nom
			pts = mgr_shp.changer_sens pts
			),
		
		fn set_parent			_polygoneParent 	= (
			if parent != undefined and parent  != _polygoneParent do
				parent.retirer_enfant	this
			
			parent  = _polygoneParent
			maj_enCreux ()
		),
		fn ajouter_enfant 	_neudEnfant 	distance_toParent:	= (
			
			--- le placer dans l'ordre du plus proche au plus loin ---------------
			local distTest	=	distance_toParent	--struct_prt.get_distance_shapes 	pts	_neudEnfant.pts
			local trouve = false
			if distTest != unsupplied and distTest != undefined do (
				
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
			if _neudEnfant.calque != undefined do
				_neudEnfant.calque.retirer_polygone	_neudEnfant
			_neudEnfant.set_parent  	this
		),
		fn retirer_enfant		_enfant 		=(
			local id_enfant = findItem enfants	_enfant
			if id_enfant != 0 do
				deleteItem enfants id_enfant
		),
		fn set_pts  			_pts			= pts =  for pt in _pts collect pt,
		
		
		fn get_pts  			= for pt in pts collect pt,
		fn get_descendance	=(
			local result = #()
			for enfant in enfants do (
				append result enfant
				result		+=	enfant.get_descendance()
			)
			result
		),
		
		fn supprimer			=(
			if parent	!=	undefined do
				parent.retirer_enfant	this
		),
		fn set_calque 		_calque =(
			if calque != undefined and calque  != _calque do
				calque.retirer_polygone	this
			
			calque  = _calque
			maj_enCreux ()
		),
		fn initialiser 	_ptr_shp = mgr_shp = _ptr_shp
		
)--- fin du struct----














struct str_mgr_polygones (
	
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	true,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | polys"	  	var:var	 param:param		catch (),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
	
	
	
	
		mgr_shp	=	str_outils_shape (),
	
	
		SEUIL_POINTS_EGAUX  	= .01,
		-- constante pr debug-----------------
		SAUVETAGE_MAX 			= 100,
	
	
	
	
	------------ Fonstions internes 	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	private
	
		fn get_idsPts_connexion   	_pts_shp1		_pts_shp2 	=(
			
			local results = #()
			
			--- on cherche les points des shpes les plus proches pour les connecter --------------
			
			local dist_min					= 1e+10			
			for id_pt1 = 1 to  _pts_shp1.count do (
				local pt1	=	_pts_shp1[ id_pt1 ]
				for id_pt2 = 1 to  _pts_shp2.count do (
					local pt2			=	_pts_shp2[ id_pt2 ]
					local dist_test	=	distance	pt1 pt2
					if dist_test < dist_min then (
						
						local id_pt2_svt	=	if id_pt2 == _pts_shp2.count  then 1 else id_pt2 + 1
						local pt_2_svt 		= _pts_shp2[ id_pt2_svt ]
						---- si plus proche --------------
						dist_min = dist_test
						results = #()
						append results 	#( id_pt1 , id_pt2 )
					) else
					if abs ( dist_test - dist_min )  == 0   then (
						append results 	#( id_pt1 , id_pt2 )
					)
					
				)
				
			)
			results
		),
		fn ajouter_shape_aBooleen			_pts_shp_booleen		_pts_shp_aAjouter	 =(
			
-- 			debug "ajouter_shape_aBooleen"
			
			local chrono_temp = timeStamp ()
			--- on cherche les points des shpes les plus proches pour les connecter --------------
			local connexions	=	get_idsPts_connexion   	_pts_shp_booleen		_pts_shp_aAjouter 
			
			
			
			
-- 			debug"connexions" var:connexions
			local connexion = connexions[1]
			--- si on a plusieurs connexions ------------------
			if connexions.count > 1 then (
				
				local id_pt_origine 	= connexions[1][2]
				local pt_origine 		= _pts_shp_aAjouter[id_pt_origine]
				
				local angle_min 			= 1e+10
				while connexions.count > 1 do (
					
					---- si on a des connexion vers le meme point ------------------
					if id_pt_origine == connexions[2][2] then (
						
						local	id_pt_cnx1			= connexions[1][1]
						local id_pt_cnx1_svt	=	if id_pt_cnx1 == _pts_shp_booleen.count  then 1 else id_pt_cnx1 + 1
						local id_pt_cnx1_prcd	=	if id_pt_cnx1 == 1  then _pts_shp_booleen.count else id_pt_cnx1 - 1
						
						local pt_cnx1 			= _pts_shp_booleen[id_pt_cnx1]
						local pt_cnx1_svt	= _pts_shp_booleen[id_pt_cnx1_svt]
						local pt_cnx1_prcd	= _pts_shp_booleen[id_pt_cnx1_prcd]
						
						if pt_cnx1_svt == pt_cnx2_prcd then (
							local pt_est_aGauche 	= mgr_shp.est_aGauche		pt_cnx1		pt_cnx1_svt		pt_origine	
							if pt_est_aGauche then 
								connexion = deepcopy  connexions[1]
							else 
								connexion = deepcopy  connexions[2]
						) else (
							local pt_est_aGauche 	= mgr_shp.est_aGauche		pt_cnx1_prcd		pt_cnx1		pt_origine
							if pt_est_aGauche then 
								connexion = deepcopy  connexions[1]
							else 
								connexion = deepcopy  connexions[2]
						)
					) 
					deleteItem connexions 1
				)
			)   
			
			local id_pt_connexion_1 =	connexion[1]
			local id_pt_connexion_2 =	connexion[2]
			
			
-- 			debug  ("	TIME:	on cherche les points des shpes les plus proches pour les connecter : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
-- 			local chrono_temp = timeStamp ()
			
			---- les premier shape -----------
			local pts_result = #()
			if id_pt_connexion_1 != 0 do (
				pts_result = #( _pts_shp_booleen[ id_pt_connexion_1 ] )
				for i_compteur = 1 to  _pts_shp_booleen.count do (
					local id_pt = i_compteur + id_pt_connexion_1 
					if id_pt > _pts_shp_booleen.count do 
						id_pt -= _pts_shp_booleen.count 
					local pt = _pts_shp_booleen[id_pt]
					append pts_result	pt
				)
			)
			
-- 			debug  ("	TIME:	les premier shape : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
-- 			local chrono_temp = timeStamp ()
			
			---- les second shape, on l'ajoute a l'envers  -----------
			for i_compteur =  _pts_shp_aAjouter.count to 1 by -1 do (
				local id_pt = i_compteur + id_pt_connexion_2 
				if id_pt > _pts_shp_aAjouter.count do 
					id_pt -= _pts_shp_aAjouter.count 
				local pt = _pts_shp_aAjouter[id_pt]
				append pts_result	pt
			)
			if id_pt_connexion_2 != 0 do
				append 	pts_result	( _pts_shp_aAjouter[ id_pt_connexion_2 ] )
			
-- 			debug  ("	TIME:	les second shape, on l'ajoute a l'envers : " +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string + " s." ) 
			
			pts_result
			
		),
	------------ Interface	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	public	
	
		fn inserer_poly_ds_poly		_poly_aInserer		_poly_dest 		=(
			if (_poly_dest.get_pts()).count == 0 then (
				_poly_dest.ajouter_enfant	_poly_aInserer
			) else (
				local pos_relative = mgr_shp.get_positionRelative_shapes 		(_poly_dest.get_pts ())		(_poly_aInserer.get_pts ())	renvoyer_intersections:false
				case pos_relative[1] of (
					
					#aCoté:	 		result = false
					
					#interieur:		 (
							------ on regarde s'il rentre dans les enfants du poly destination	--------------	
							local a_ete_integre	=	false		
							local	enfants_dest = 	for enfant in _poly_dest.enfants collect enfant
							local i = 1
							while	 i <= enfants_dest.count and not a_ete_integre	do (
								local enfant_dest			=	enfants_dest[ i ]
								local integration_reussie	=	inserer_poly_ds_poly		_poly_aInserer			enfant_dest
								if integration_reussie do a_ete_integre = true
								i += 1
							)
							
							----- sinon on l'ajoute aux enfants du poly dest ----------------
							if not a_ete_integre do
								_poly_dest.ajouter_enfant 		_poly_aInserer
								
							result = true
							
						) ---- fin #interieur	----------
						
						
						
					#exterieur:		(
						
							if _poly_aInserer.parent != undefined then (
								local parent_B = _poly_aInserer.parent 
								_poly_aInserer.ajouter_enfant 	_poly_dest
								append 	_poly_dest.calque.polygones	_poly_aInserer
	-- 							parent_B.ajouter_enfant	_poly_dest
							) else (
								_poly_aInserer.ajouter_enfant 	_poly_dest
								append 	_poly_dest.calque.polygones	_poly_aInserer
							)
							result = true
							
						) ---- fin #exterieur	----------
					
						
						
					#seCroisent:		(
					
							debug "###########################################################"
							debug "#############################################################"
							debug "#########											#########"
							debug "#########	/!\	hmm! probleme, il ne devrait y 		#########"
							debug "#########	avoir d'intersection de noeuds ici 		#########"
							debug "#########											#########"
							debug "#############################################################"
							result = #PROBLEME
						result = true
						) ---- fin #seCroisent	----------
				)
			)
			result
		),
		
		fn calculer_booleen  	_poly_A 			_poly_B	operation:#union		intersections:#()	=(
			
			format "\n\n\n\n"
			debug "-------------------------- calculer_booleen ()	--------------------------------------------"
			debug "	operation"			var:operation
			debug "	_poly_A"				var:_poly_A
			debug "	_poly_B"				var:_poly_B			
			debug "--------------------------------------------------------------------------------------------"
			
			
			
			--- les points des polys -----------
			local pts_A = _poly_A.get_pts ()
			local pts_B = _poly_B.get_pts ()
			
			

			local 	result_polys 	= #()

			
			
			
			---- tant qu'il reste des intersections à traiter	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
			local	il_reste_des_points 	=	intersections.count > 0  and operation != #union
			local ids_intersections_aTraiter 	= #{1..intersections.count}
			local sauvetage 				=	0
			local annuler = false
			while il_reste_des_points	and not annuler do (
-- 				format "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
-- 				debug "------------------------------------------------- TANT QU'IL RESTE DES intersections à TRAITER	--------------------------------------------------------------------------------------------------------------------------------------------------------------------"
-- 				debug "------->	intersections" var:intersections
-- 				debug "------->	ids_intersections_aTraiter" var:ids_intersections_aTraiter				
				---- Le point demarrage, la premiere intersection de la liste --------------------
				local id_intersection_aTraiter = ( ids_intersections_aTraiter as array )[1]
-- 				debug "------->	id_intersection_aTraiter" var:id_intersection_aTraiter			
				local intersection_aTraiter		=	intersections[ id_intersection_aTraiter ]
				ids_intersections_aTraiter [ id_intersection_aTraiter ] = false
-- 				local intersection_aTraiter		=	m_intersections[1]
-- 				debug "intersection_aTraiter" 	var:intersection_aTraiter
				
				
				---- les noeuds initiaux -------------------------
-- 				local nd_initial						=	intersection_aTraiter.nd_A
				local id_pt_initial		=	intersection_aTraiter.id_B				
				local pt_initial 			= intersection_aTraiter.pos
				local shp_initial		= pts_B
				local trace_courant =	#B
				
				---- on regarde la position du point d'intersection pour voir si on inverse les noeuds --------------------
				local pt_test_intersection	=	intersection_aTraiter.pos
				local pt_test_base				= pts_A[ intersection_aTraiter.id_A ]
				local pt_test_operateur		= pts_B[intersection_aTraiter.id_B]
				
				
				if operation == #addition then
					if not mgr_shp.est_aGauche		pt_test_base		pt_test_intersection 	pt_test_operateur		do (
-- 						nd_initial					=	intersection_aTraiter.nd_operateur
						shp_initial			= pts_A
						trace_courant		=	#A
						id_pt_initial			=	intersection_aTraiter.id_A
-- 						debug "On inverse les noeuds initiaux, on est a GAUCHE"
					)
					
				else 	if   mgr_shp.est_aGauche		pt_test_base		pt_test_intersection 	pt_test_operateur		do (
-- 						nd_initial					=	intersection_aTraiter.nd_operateur
						shp_initial			= pts_A
						trace_courant		=	#A
						id_pt_initial			=	intersection_aTraiter.id_A
						
-- 						debug "On inverse les noeuds initiaux, on est PAS a GAUCHE"
					)
					
					
					
				
					
-- 				debug "nd_initial" var:nd_initial param:#nom
				
				
				
				local shp_courant	= shp_initial
				
				------ ( B )	On initialise les contitions courantes	----------------------------------------------------------------------------------------------------------------------------------------------
				local shp_enConstruction = #()
				
				
				--- le point courant initial	----------
-- 				local nd_courant		=	nd_initial
-- 				local nds_aTester		= 	if est_nd_deBase	nd_courant then 	m_nds_operateurs else		m_nds_bases
				
				local id_pt_courant	=	id_pt_initial
				local pt_courant		=	pt_initial
				local sens = 1
				if 	_poly_A.en_creux	do 	 sens = -1
				
				
				
				
				
				
				
				
				
				
				
				
				------ ( C ) 	Tant qu'on est pas retourné à notre point de départ	----------------------------------------------------------------------------------------------------------------
				local on_a_fini_laBoucle = false
				local annuler = false
				while not on_a_fini_laBoucle  and not annuler	do (
-- 					format "\n\n"
-- 					debug "------------------------------------------------- tant qu'on a pas fini la boucle	----------------------------------------------------------------------------------------------------------------"
					
				
				
-- 					debug "nd_courant" 		var:nd_courant.nom
-- 					debug "nds_aTester" 	var:nds_aTester		param:#nom
-- 					debug "id_pt_courant" 		var:id_pt_courant
-- 					debug "pt_courant" 			var:pt_courant
-- 					debug "trace_courant" 		var:trace_courant
-- 					debug "" 	
					
					
					--- on fait le segment  jusqu'a la prochaine intersection 	----------------------------
-- 					local intersec_initial = 
					local on_continue = true
					while on_continue and not annuler		do (
						
						
						append 	shp_enConstruction		pt_courant
						
						--- on cherche la prochaine intersection ------------
						local dist_proche = 1e+10
						local prochaine_intersec = undefined
-- 						local intersec_poly_courant = get_intersections		nd_courant
						
						
-- 						format "\n"
-- 						debug "---------------------------------------"
-- 						debug "id_pt_courant" 	var:id_pt_courant
-- 						debug "pt_courant" 		var:pt_courant
-- 						debug "shp_enConstruction" 		var:shp_enConstruction
-- 						debug "intersec_poly_courant" 	var:intersec_poly_courant
						
						for 	intersection in 	intersections  do (
							
-- 							debug "			--> intersection" var:intersection
-- 							debug "			-->par la : #1"
							if distance pt_courant	intersection.pos < 	dist_proche do (
-- 								debug "			-->par la : #2"
								if distance pt_courant		intersection.pos 	> SEUIL_POINTS_EGAUX do (
-- 									debug "			-->par la : #3"
									
									if trace_courant 	==	#A then (
-- 										debug "			-->par la : #4-1"
										if intersection.id_A == id_pt_courant  do ( 
-- 											debug "			-->par la : #5-1"
											local pt_base = shp_courant[	intersection.id_A  ]
											if 	( distance pt_courant		pt_base + distance pt_courant		intersection.pos )  - distance intersection.pos  pt_base 			< SEUIL_POINTS_EGAUX do	(
-- 												debug "			-->par la : #6-1 ##################"
												
													dist_proche = distance pt_courant	intersection.pos
													prochaine_intersec = intersection
												)
										)
									) else (
-- 										debug "			-->par la : #4-2"
										if intersection.id_B == id_pt_courant  do ( 
-- 											debug "			-->par la : #5-2"
											local pt_ope = shp_courant[	intersection.id_B  ]
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
						
-- 						debug "intersections" 				var:intersections param:#pos
-- 						debug "prochaine_intersec" 	var:prochaine_intersec
						
						
						
						
						---- si on a une intersection ----------------
						if prochaine_intersec != undefined then (
							
							
-- 							debug "---------> INTERSECTION"
-- 							debug "---------> prochaine_intersec" var:prochaine_intersec
							
-- 							ids_intersections_aTraiter[ findItem m_intersections	prochaine_intersec	 ] = false
							
							--- on change de noeud courant	------
							if  trace_courant 	==	#A 	then (
-- 								nd_courant		=	prochaine_intersec.nd_operateur
								trace_courant 	=	#B
								shp_courant	= 	pts_B
								id_pt_courant 	=  prochaine_intersec.id_B
-- 	 							debug "	--->	on est sur A, on bascule sur B."
	-- 							nds_aTester	=	nds_bases
							) else (
								trace_courant 	=	#A
-- 								nd_courant		=	prochaine_intersec.nd_base
								shp_courant		= 	pts_A
								id_pt_courant 	=  prochaine_intersec.id_A
-- 	 							debug "	--->	on est sur B, on passe sur A."							
	-- 							nds_aTester	=	nds_bases
							)
							
-- 							-----  on valide si on est sur un point intersection ------------------
-- 							shp_courant		= 	nd_courant.get_pts()
							pt_courant 		=	prochaine_intersec.pos
							
-- 							append 		shp_enConstruction 	pt_courant
							id_intersection_aTraiter	=	findItem	intersections		prochaine_intersec
							ids_intersections_aTraiter [ id_intersection_aTraiter ] = false
-- 							deleteItem 	intersections		1 --catch ()
							
-- 							local  i = 1 
-- 							local trouve = false
-- 							while i <= m_intersections.count and not trouve do (
-- 								local inter = m_intersections[i]
-- 								if distance inter.pos  pt_courant  <  .001  do (
-- 									deleteItem m_intersections i
-- 									
-- 									trouve = true
-- 								)
-- 								i+=1
-- 							) 
						
							
							--- on pâssse ----------
							on_continue = false
							
						---- si on a  pas d' intersection ----------------
						) else (
							
-- 							debug "---------> SUIVANT"
							
							id_pt_courant 		= mgr_shp.boucler	shp_courant		( id_pt_courant + sens )
							pt_courant 		= shp_courant [ id_pt_courant ]
							
						)
						
-- 						debug "---------> pt_courant" var:pt_courant
						
						---- sortie  ou suivant -----------------
						if prochaine_intersec == intersection_aTraiter then 
							on_continue = false
-- 						else 
-- 							deleteItem intersections 1
						
						--- SAUVETAGE	----
						sauvetage += 1
						if sauvetage > SAUVETAGE_MAX do 
							annuler = true
						
						
						
					) -- FIN --- on fait le segment  jusqu'a la prochaine intersection 	-------------------------
					
					
					----------- ( 3 )	sortie ? si on est retourné sur le point initial, on sort	--------------------------------------------	
					
					if distance	pt_courant  pt_initial <  SEUIL_POINTS_EGAUX	then 
						on_a_fini_laBoucle = true
					
					--- SAUVETAGE	----
					sauvetage+= 1
					if sauvetage > SAUVETAGE_MAX do annuler = true
					
				)	---- Fin -	tant qu'on a pas fini la boucle	------------------------------------------------------------------------------------------------------
				
				
				
				
				
				--- on creer le noeud resultat -----------
				
				if 	_poly_A.en_creux	do 	shp_enConstruction =	mgr_shp.changer_sens	shp_enConstruction
				local nv_poly = this.creer_polygone 	pts:shp_enConstruction	\
																	nom:(_poly_A.nom + "_" +_poly_B.nom  /* + "--->" + operation as string  */+ "_" + result_polys.count as string )	
				
-- 				nv_poly.enfants = for enfant in _poly_A.enfants collect enfant
-- 				debug "------------------------------------->	_poly_A" var:_poly_A
-- 				debug "------------------------------------->	_poly_B" var:_poly_B
				debug "------------------------------------->	nv_poly" var:nv_poly
				debug "------------------------------------->	shp_enConstruction" var:shp_enConstruction
				
				
				 
				---- on ajoute le noeud obtenu -----------------------------------
				append 	result_polys	nv_poly
				
-- 				append 	result_polys	shp_enConstruction
				
				
				---------- SORTIES ---------------------------------------------
				---- test pour sortie  correct	----------------------------------------------------------------------------------------------------

			 	if 	(ids_intersections_aTraiter as array ).count ==  0	do (
					il_reste_des_points = false
-- 					format "\n\n"
-- 					debug  "####################################################################################################################################"
-- 					debug  "								FIN DE L'OPERATION : OK"
-- 					debug  "####################################################################################################################################"
-- 					
-- 					
					
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
			
			
			debug "--------------------------------------------------------------------------------------------"
			debug  ( "								RESULTAT booleen: " )
			debug 	"								result_polys" var:result_polys
-- 			for nd_result in result_polys do
-- 				debug_poly	 nd_result
			
			debug "--------------------------------------------------------------------------------------------"
			format "\n\n"
			
			result_polys
			
		),
		fn operation_booleene  	_poly_A 		_poly_B	operation:#union		=(
			
			debug "operation_booleene ()"
			local result_polys	=#()
			
			local pos_relative = mgr_shp.get_positionRelative_shapes 	( _poly_A.get_pts() )	( _poly_B.get_pts () )
			
			debug "pos_relative		"	var:pos_relative
			case pos_relative[1] of (
				
				#aCoté:	 	(			----> 	B et A sont à coté l'un de l'autre.	---------------------------------------------------------
					debug "A et B sont à coté l'un de l'autre."
					----------  en fonction du type d'opération -------------
					case operation of (			
								--------- 	B est ajouter au niveau de A				----> 	A et B			--------------------------------	
								#addition:	 		(
									result_polys = #( _poly_A , _poly_B )
								)
								---------	B est un trou dans le vide.				----> 	A	--------------------------------	
								#soustraction:	 		(
									result_polys = #( _poly_A )
								)
								---------	Il reste 0 shapes, pas d'intersection.	----> 	-VIDE-	--------------------------------	
								#intersection:	 		(
									result_polys = #( )
								)
								#union:(
									result_polys = #( _poly_A , _poly_B )
								)
						) --- fin case operation-	---------------------
					) ---- fin #aCoté ---------------------------------------------------------
					
				#interieur:	 (			---->	B est entierement dans A.			---------------------------------------------------------
						debug "B est entierement dans A."
						----------  en fonction du type d'opération -------------
						case operation of (
								---------	A absorbe totalement B	----> 	A	--------------------------------	
								#addition:	 		(
									
									local polys_tmp =#()
									
									--- au premier tour on opere avec les enfants du polygone A ------------
									local polygones_aOperer	=	for poly in _poly_A.enfants collect poly
										
									--- si le calque à operer a des enfants,  ----------
									if polygones_aOperer.count == 0	then (
										
										inserer_poly_ds_poly		_poly_B	_poly_A
										
									) else (
										--- pour chacun des enfants du polygone B ... --------------
										for polygone_operant in _poly_B.enfants do (
											
											debug "	---->	polygone_operant" var:polygone_operant
											
											local polygones_result =#()
											
											----  à chacun des enfants du polygone A  ... ----------
											for polygone_aOperer in polygones_aOperer do (
												debug "	---->	polygone_aOperer" var:polygone_aOperer
												
												-----  ... on applique l'operation booleenne.  -----------------------
												polygones_result +=	operation_booleene  	polygone_aOperer 		polygone_operant		operation:operation
												
											)
										
											--- apres on opère chaque tour avec le resultat precedant et on recommence avec le polygone operant suivante ------------
											polygones_aOperer = polygones_result
											
										)
										
										---- une fois qu'on a fini on actualise les enfants de A ------
										_poly_A.enfants = #()
										for poly in polygones_aOperer do
											inserer_poly_ds_poly		poly		_poly_A
										
									)
									
									--- on renvoie A -------------------
									result_polys = #( _poly_A  ) 
									
									
								)
								---------	B est un trou complet dans A	----> 	B dans A	--------------------------------	
								#soustraction:	 		(
									for enfant in _poly_A.enfants do
										operation_booleene				operation			enfant 			_poly_B
									_poly_B.ajouter_enfant	_ndA
									result_polys = #( _poly_B  )
								)
								---------	Il ne reste que B. 	----> 	B	--------------------------------	
								#intersection:	 		(
									result_polys = #( _poly_B  )
								)
								
								#union:(
									_poly_A.ajouter_enfant		_poly_B
									result_polys = #( _poly_A  )
								)
						) --- fin case operation-	---------------------

						
					) ---- fin #interieur ---------------------------------------------------------
					
					
					
				#exterieur:	(			---->	A est entierement dans B			.---------------------------------------------------------
						debug "A est entierement dans B."
						----------  en fonction du type d'opération -------------
						case operation of (
								---------	B absorbe totalement A.					----> 	B	--------------------------------	
								#addition:	 		(
									result_polys = #( _poly_B  )
								)
								---------	B fait disparaitre A => 0 shapes.		----> 	-VIDE-	--------------------------------	
								#soustraction:	 		(
									result_polys = #( )
								)
								---------	Il ne reste que A.						----> 	A	--------------------------------	
								#intersection:	 		(		
									result_polys = #( _poly_A)
								)
								
								#union:(
									_poly_B.ajouter_enfant	_poly_A
									result_polys = #( _poly_B  )
								)
						) --- fin case operation-	---------------------
					) ---- fin #exterieur ---------------------------------------------------------
					
					
					
				#seCroisent:	(		---->	A et B se coupent, on va avoir du decoupage à faire ! 					---------------------------------------------------------
						debug "A et B se croisent."
					
						local polys_tmp = #()
						
						--- au premier tour on opere avec les enfants du polygone A ------------
						local polygones_aOperer	=	for poly in _poly_A.enfants collect poly
							
						--- si le calque à operer A n'a pas d'enfants,  ----------
						if polygones_aOperer.count == 0	then (
							
							--- pour chacun des enfants du polygone B ... --------------
							for polygone_operant in _poly_B.enfants do 
								polys_tmp += 	operation_booleene				_poly_A 			polygone_operant	  operation:operation
							
							---- puis avec le poly A ----------
							polys_tmp += 	calculer_booleen	  _poly_A 		_poly_B		operation:operation		intersections:pos_relative[2]	---	operation_booleene				_poly_A 			_poly_B	  operation:operation
							
							---- une fois qu'on a fini on insere tout ça dans un poly provisoire --------------- ------
							local poly_result =  this.creer_polygone	()
							for poly in polys_tmp do
								inserer_poly_ds_poly		poly		poly_result
							
							
							result_polys = poly_result.enfants
							
						) else (
							--- pour chacun des enfants du polygone B ... --------------
							for polygone_operant in _poly_B.enfants do (
								
								debug "	---->	polygone_operant" var:polygone_operant
								
								local polygones_result =#()
								
								----  à chacun des enfants du polygone A  ... ----------
								for polygone_aOperer in polygones_aOperer do (
									debug "	---->	polygone_aOperer" var:polygone_aOperer
									
									-----  ... on applique l'operation booleenne.  -----------------------
									polygones_result +=	operation_booleene  	polygone_aOperer 		polygone_operant		operation:operation
									
								)
							
								--- apres on opère chaque tour avec le resultat precedant et on recommence avec le polygone operant suivante ------------
								polygones_aOperer = polygones_result
								
							)
							
							---- puis avec le poly A ----------
							polygones_aOperer += 	calculer_booleen	  _poly_A 		_poly_B		operation:operation		intersections:pos_relative[2]	---	operation_booleene				_poly_A 			_poly_B	  operation:operation
							
							
							---- une fois qu'on a fini on insere tout ça dans un poly provisoire --------------- ------
							local poly_result =  this.creer_polygone	()
							for poly in polygones_aOperer do
								inserer_poly_ds_poly		poly		poly_result
							
							debug "-------------------------------------------------------------------------------------------"
							debug_poly poly_result
							
							result_polys = poly_result.enfants
						)
						
-- 						--- on renvoie A -------------------
-- 						result_polys = #( _poly_A  ) 
						
						/* local result_enfants	=#()
						local enfants_ndA = for nd in _poly_A.enfants	 collect nd
						for enfant_A in  enfants_ndA	 do
							result_enfants += 	operation_booleene				enfant_A 			_poly_B  operation:operation
						debug "A et B se croisent.-------------"
						result_polys	 =	calculer_booleen	  _poly_A 		_poly_B		operation:operation		intersections:pos_relative[2]
						result_polys	+= result_enfants
						
						result_polys */
					) ---- fin #seCroisent ---------------------------------------------------------
					
			)	---	fin case position relative	------------------------------------
			
			result_polys
		),
	
	
	
		fn creer_pts_pourFace			_poly			=(
			
-- 			local chrono_temp = timeStamp ()
			
			local pts_result 	=	#()
			local pts_poly 	=	_poly.get_pts	()
			
			---- Version on prend les enfants 1 par 1 le plus pret ----------------------
			local enfants_a_traiter	 = for poly in  _poly.enfants collect poly
			while enfants_a_traiter.count > 0 do (
				
				local shps_enfants_a_traiter	=	for enfant in enfants_a_traiter collect ( enfant.get_pts() )
				
				local infos_enfant_proche		=	mgr_shp.get_shape_lePlusProche	pts_poly		shps_enfants_a_traiter
				local enfant_proche				=	 enfants_a_traiter[ infos_enfant_proche.id_shp ]
				
				pts_poly = ajouter_shape_aBooleen  	pts_poly		( enfant_proche.get_pts() )
				
				for petitEnfant in enfant_proche.enfants do
					pts_result += creer_pts_pourFace  petitEnfant
				
				deleteItem enfants_a_traiter  infos_enfant_proche.id_shp
				
			)
			
			append pts_result 	pts_poly
			
			pts_result
		),
		fn creer_polygone 	pts: 	nom:		=(
			
			----	renvoie un nouveau polygonne	----
			local nv_polygone = str_polygone	()		----	struct_prt:this
			
			nv_polygone.initialiser	this
			if pts != unsupplied and pts != undefined do (
				if not mgr_shp.est_sensPositif 	pts do 
					pts = mgr_shp.changer_sens pts
				
				nv_polygone.set_pts 	pts
			)
			if nom != unsupplied do (
				nv_polygone.nom= nom
				if nom != "root" and nom != "temporaire" do
					nv_polygone.en_creux = false
				
			)
			
			nv_polygone
			
		),
		fn creer_fromShape		_shape_node	=(
			
			--- on renvoie une liste de polygones --------
			local result_polys	=	#()
			
			--- on recupere nos tracés à partir des splines du shape_node
			local pts_shps 	= 	mgr_shp.interpoler_shape		_shape_node
			
			
			--- et on créé un polygone par tracé		-------------
			local i = 0
			for pts_shp in pts_shps do (
				--- le nouveau polygone ---
				local nom_poly 	=  _shape_node.name	+ "_" + (  i+=1 ) as string
				local nv_poly 		= creer_polygone		pts:pts_shp	nom:nom_poly
				append result_polys nv_poly
-- 				
-- 				--- on l'ajoute à la hierarchie resultante --------------
-- 				inserer	 result_polys 	nv_poly
			)
			
			result_polys
		)

		
		
		

	
) ------ fin struct mgr polys ---------------------------






























