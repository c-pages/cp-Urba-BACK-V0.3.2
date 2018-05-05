
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - outils - shape.ms" 


---- polygone de la hierarchie ----------
struct str_polygone (
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	true,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | polys"	  	var:var	 param:param		catch (),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
	
	--------- membres ------------------------------------------------------------------
	private
		
		
		
		mgr_shp				=	str_outils_shape (),
		mgr_polys 			,
	
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
		
			
		fn reset_sens = if not 	mgr_shp.est_sensPositif 	pts	do changer_sens (),
			
		fn set_parent			_polygoneParent 	= (
			if parent != undefined and parent  != _polygoneParent do
				parent.retirer_enfant	this
			
			parent  = _polygoneParent
			maj_enCreux ()
		),
		fn ajouter_enfant 	_neudEnfant 	distance_toParent:	= (
			
			debug "aJOUTER ENFANT a "  var:this.nom
			debug "enfant a ajouter"	var:_neudEnfant.nom
			
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
			
			
			_neudEnfant.calque = calque
			_neudEnfant.set_parent  	this
			
			debug "enfants" var:enfants	param:#nom
			debug " FIN aJOUTER ENFANT	FIN" 
		),
		fn retirer_enfant		_enfant 		=(
			local id_enfant = findItem enfants	_enfant
			if id_enfant != 0 do
				deleteItem enfants 	id_enfant
-- 			format"##############################\n"
		),
		
		fn detacher =(
			enfants = #()
			parent = undefined
		),
		fn get_descendance	=(
			local result = #()
			for enfant in enfants do 				
				result		+=	enfant.get_descendance()
			
			append result 	this
			result
		),
		
		fn est_un_enfant	_poly_test	=(
			local descendance = get_descendance ()
			local id_item = findItem descendance	_poly_test
			if id_item != 0 then true else false 
		),
		
		
		fn set_pts  			_pts			= pts =  for pt in _pts collect pt,
		
		
		fn get_pts  			 oriente:false 	= (
			
			local result = for pt in pts collect pt				
			if oriente and en_creux do
					result = mgr_shp.changer_sens	result			
			result			
		),
		
		fn supprimer			=(
			if parent	!=	undefined then
				parent.retirer_enfant	this

			this
		),
		fn set_calque 		_calque =(
			
			for enfant in enfants do 
				enfant.set_calque 		_calque
			
			if calque != undefined and calque  != _calque do
				calque.retirer_polygone	this
			
			calque  = _calque
			maj_enCreux ()
		),
		
		
		fn get_positionRelative 		_poly_a_tester	=(
			mgr_shp.get_positionRelative_shapes 	(  get_pts () )	(  _poly_a_tester.get_pts () )	 renvoyer_intersections:false
		),
		
		--- on regarde si on a ou pas un parent ----------
		fn est_exterieur =  parent == undefined,
		
		
	
		
		
		
		fn trianguler =(
			debug "trianguler"
			local polys_total 	= get_descendance ()
			
			local triangles = mgr_polys.trianguler		polys_total
			
			
			debug "----------------------------------->	triangles" var:triangles
			debug "FIN	trianguler"
			triangles
			
			
			
		),
		
		
		
		fn initialiser		_mgr_polys = 
					mgr_polys = _mgr_polys
		
		
		
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
			
			--- on cherche les points des shpes les plus proches --------------
			
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
			
			debug "ajouter_shape_aBooleen"
			
			local chrono_temp = timeStamp ()
			
			--- on cherche les points des shpes les plus proches pour les connecter --------------
			local connexions	=	get_idsPts_connexion   	_pts_shp_booleen		_pts_shp_aAjouter 
			
			
			
			
			debug"connexions" var:connexions
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
		
		
		
		
		
		/* 
		
		fn ajouter_shape_aBooleen			_pts_shp_booleen		_pts_shp_aAjouter	 =(
			
			debug "ajouter_shape_aBooleen"
			
			local chrono_temp = timeStamp ()
			--- on cherche les points des shpes les plus proches pour les connecter --------------
			local connexions	=	get_idsPts_connexion   	_pts_shp_booleen		_pts_shp_aAjouter 
			
			
			
			
			debug"connexions" var:connexions
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
			
		), */
	------------ Interface	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	----- TRIANGULATION ---------------------------------------
	private
	
	
		fn get_sgts_sur_memeAxe		_axe		_polys_total		_id_poly_test		_id_test		=(
-- 			debug "get_sgts_sur_memeAxe"
			
			---- renvois un tableau de liste d'index de point ( 1 tableau par poly_total ) --- 
			local segments_surMemeAxe =#()
			local pts_test 		= _polys_total[ _id_poly_test ].get_pts  oriente:true 
			local pt_test 			= pts_test[ _id_test ]
			local id_test_prcdt 	= mgr_shp.boucler pts_test ( _id_test - 1 )
			
			for id_poly = 1 to _polys_total.count  do (
				local poly = _polys_total[ id_poly ]
				local sgts_surMemeAxe	=	mgr_shp.get_sgts_sur_memeAxe		_axe		( poly.get_pts oriente:true )		pt_test	
					
				--- on retire ceux en trop -----------------
				for i_idsSgt	=	sgts_surMemeAxe.count to 1 by -1  do(
					local id_sgt = sgts_surMemeAxe[  i_idsSgt]
					if id_poly == _id_poly_test then (
						if _id_test == id_sgt or id_test_prcdt== id_sgt do
							deleteItem sgts_surMemeAxe	 i_idsSgt
					)
				)
				
				append segments_surMemeAxe		sgts_surMemeAxe
				
			)
-- 			debug "segments_surMemeAxe" var:segments_surMemeAxe
			segments_surMemeAxe
		),
		
		
		---- renvois les points de connexions en balayage 
		fn get_connexions  		_axe		_polys		_id_poly			_id_pt 	=(
			
			
			debug "get_connexions"
			
			struct str_connexion	(
				id_poly_A	=	0,
				id_poly_B	=	0,
				id_pt_A		=	0,
				id_pt_B		=	0,
				
				passages = 0 ,
				
				
				fn 	basculer 	_id_base =(
					format "BASCULER\n"
					if _id_base == id_poly_A then
						id_poly_B
					else 
						id_poly_A
				),
				fn get_id_pt	_mode =(
					if _mode == #A then
						id_pt_A
					else 
						id_pt_B					
				),
				fn est_courante  _id_poly  _id_pt =(
					local result = false
					if ( _id_poly == id_poly_A and _id_pt == id_pt_A) or ( _id_poly == id_poly_B and _id_pt == id_pt_B ) then
						result = true
					result
				)
			)
			
			
			
			
			
			local result = #()
			
			local pts 				= _polys[ _id_poly ].get_pts oriente:true 
			local pt_courant 		= pts[ _id_pt ]
			
			
			local sgts_sur_memeAxe =	get_sgts_sur_memeAxe		#horizontal			_polys		_id_poly		_id_pt
			---------- DEBUG--------------------------
			
			
			--- pour chaque polygone --------------------
			----	on cherche la connexion la plus proche --------------
			local distMin_intersection_D = 1e14
			local distMin_intersection_G = 1e14
			
			local pts_debug =#()
			for id_polys_sgt_surAxe = 1 to sgts_sur_memeAxe.count do (
				
				
-- 				debug "----->	id_polys_sgt_surAxe" var:id_polys_sgt_surAxe
				
				
				local poly 				= _polys[ id_polys_sgt_surAxe ]												
				local pts 				= poly.get_pts 	oriente:true
				
				local sgts_surAxe 	= sgts_sur_memeAxe [ id_polys_sgt_surAxe ]
				
-- 					debug "	----->	sgts_surAxe" var:sgts_surAxe
				local id_poly_valide_G 	= 0
				local id_poly_valide_D 	= 0
				local id_seg_valide_G 	= 0
				local id_seg_valide_D 	= 0
								
				--- pour chque segment sur le meme axe que notre point  --------------------
				for id_sgt_surAxe in sgts_surAxe do (
					
-- 					debug "	----->	id_sgt_surAxe" var:id_sgt_surAxe
					
					local pt_sgt_surAxe 			= pts[ id_sgt_surAxe ]
					local id_sgt_surAxe_svnt		= mgr_shp.boucler	pts ( id_sgt_surAxe + 1 )
					local pt_sgt_surAxe_svnt 		= pts[ id_sgt_surAxe_svnt ]
					
					local pt_courant_horiz 			= pt_courant + [1,0,0]
					local intersection 				= mgr_shp.get_intersection_droite_droite			pt_courant 	pt_courant_horiz		pt_sgt_surAxe		pt_sgt_surAxe_svnt
					
					
-- 					debug "	----->	intersection" var:intersection
					
					--- la connexion  a Gauche -----
					if intersection.x < pt_courant.x then (
						if distance pt_courant  intersection < distMin_intersection_G do (

							distMin_intersection_G = distance pt_courant  intersection
							id_poly_valide_G 	= id_polys_sgt_surAxe
							id_seg_valide_G 	= id_sgt_surAxe
						)
						
					) else (
					--- la connexion  a Droite -----
						if distance pt_courant  intersection < distMin_intersection_D do (

							distMin_intersection_D = distance pt_courant  intersection
							id_poly_valide_D 	= id_polys_sgt_surAxe
							id_seg_valide_D 	= mgr_shp.boucler	 pts	( id_sgt_surAxe + 1 )
							
						)
					)
				)
				
				
				
				if id_seg_valide_G != 0 and id_seg_valide_D != 0 do (
					
				
					--- on creer les connexions	---------------------
					local connexion_G = str_connexion	id_poly_A:	_id_poly									\
																	id_poly_B:	id_poly_valide_G						\
																	id_pt_A:		_id_pt									\
																	id_pt_B:		id_seg_valide_G 
					append result connexion_G
					
					if id_poly_valide_G != id_poly_valide_D or  id_seg_valide_G != id_seg_valide_D do ( 
					local connexion_D = str_connexion	id_poly_A:	_id_poly									\
																	id_poly_B:	id_poly_valide_D						\
																	id_pt_A:		_id_pt									\
																	id_pt_B:		id_seg_valide_D
					append result connexion_D
					)
					
				)
				
				
			)
			
			
			
			result
			
		),
	public 
	
		fn decouper_polygone_monotone		_polys		balayage:#verticale		=(
			debug "decouper_polygone_monotone"
			debug "_polys" var:_polys param:#nom
			------ on cherche les 'pointes'---------
			---			Pour chaque point P, vérifiez si les points voisins sont tous deux du même côté de la ligne de balayage.
			---			Si c'est le cas, vérifiez la ligne de balayage suivante de l'autre côté. 
			---			Casser le polygone sur la ligne entre le point d'origine et l'un des points de celui-ci.
			
			
			
			
			
			
			
			
			
			
			
			
			--- pour chaque polygones --------
			local pts_deRupture 			=#()
			local pts_deRupture_horiz 	=#()
			local connexions				 	=#()
			
			
			for id_poly = 1 to _polys.count do (
				
-- 				debug "id_poly" var:id_poly
				
				local poly_courant 	= _polys[id_poly]
				local pts 				= poly_courant.get_pts  oriente:true
				
-- 				debug "------> pts COURANT" var:pts
				for i = 1 to pts.count do (
-- 					debug "\n"
-- 					debug "i" var:i
					local i_precedant 	= mgr_shp.boucler pts ( i - 1 )
					local i_suivant 		= mgr_shp.boucler pts ( i + 1 )
					
					local pt_courant 		= pts [i]					
					local pt_precedant 	= pts [i_precedant]					
					local pt_suivant 		= pts [i_suivant]
-- 					
-- 				debug "pt_precedant" var:pt_precedant
-- 				debug "pt_suivant" var:pt_suivant
					
					
					
					
					---- on cherche les points de ruptures ----------------------
					case balayage of (
						#verticale: (
							
							
-- 							debug "pt_courant" var:pt_courant
							
							
							-------- CAS 1 : segment horizontal ------------------------
							if pt_suivant.y == pt_courant.y and 	pt_precedant.y <  pt_courant.y	then (
-- 								debug "------>	segment horizontal"
-- 								debug "pt_suivant" var:pt_suivant
								append pts_deRupture_horiz		#( pt_courant, pt_suivant )
							)
							
							
							-------- CAS 2 : pointe  ------------------------
							else	if pt_precedant.y < pt_courant.y and pt_suivant.y < pt_courant.y do (
								local est_sensPositif = mgr_shp.est_sensPositif	#( pt_precedant, pt_courant, pt_suivant) 
-- 								debug "est_sensPositif" var:est_sensPositif
-- 								if  est_sensPositif	do 
								
-- 								debug "		------->	on a un point de rupture"	var:pt_courant
								if 	poly_courant.est_exterieur ()   then (
									if not est_sensPositif do (
										
										append pts_deRupture 	pt_courant
										
										
										connexions += get_connexions  		#horizontal		_polys		id_poly		i 	
										
										debug "connexions" var:connexions
										---------- DEBUG--------------------------
										
									)
									
									
								) else(
									
										append pts_deRupture 	pt_courant
										
										connexions += get_connexions  		#horizontal		_polys		id_poly		i 	
										
-- 										debug "connexions" var:connexions
										---------- DEBUG--------------------------
										
										
								)
									
								
							)
								
						)
					) -- fin case balayage -------
					
					
				)
					
					
					
					
			)
			
			debug "		------->	connexions"			var:connexions
			debug "		------->	points de  rupture"			var:pts_deRupture
			debug "		------->	points de  rupture horiz"	var:pts_deRupture_horiz
			
			
			
			
			
			
			
			
			--------- on decoupe les polygones en fonction des connexions 			-----------------------
			local list_pts_decoupe =#()
			local pts_decoupe_courant =#()
			if connexions.count > 0 then (
				
				local ids_connexions_aTraiter = #{1..connexions.count}
				
				---- la premiere courante -----------------
				local id_premiere_connexion 	= (ids_connexions_aTraiter as array )[1]
				local cnx_courante 				= connexions [ id_premiere_connexion ]
				
				local id_poly_courant 			= cnx_courante.id_poly_A
				
				debug ">>>>>>>>>>>>>>>	1 -----   id_poly_courant" var:id_poly_courant
				local mode_poly_courant 		= #A
				
				---- on commence avec les points de la connexion -------------------------------------------
				local pts_courant 		= _polys[ id_poly_courant ].get_pts 	oriente:true
				debug ">>>>>>>>>>>>>>>	1 -----   pts_courant------------" var:pts_courant
				local id_pt_courant  	= cnx_courante.get_id_pt 		mode_poly_courant
				local pt_courant 			= pts_courant [ id_pt_courant ]
				
				debug ">>>>>>>>>>>>>>>	1 -----   id_pt_courant" var:id_pt_courant
				debug ">>>>>>>>>>>>>>>	1 -----   pt_courant" var:pt_courant
				-----  les conditions initiales- --------------------------
				local id_poly_initial 		= id_poly_courant
				local id_pt_initial 		= id_pt_courant
				
				---- le premier point --------------
				append pts_decoupe_courant 		pt_courant
				
				local onA_desConnexions_aTraiter 	= true
				
				----- tant qu'on a des connexions ----------------------------------------------------------------
				while onA_desConnexions_aTraiter do(

					debug "----------------------------		tant qu'on a des connexions 	----------------------------------------------------------------"
					
				
					---- on traverse  --------------
					 if mode_poly_courant == #A then (
						mode_poly_courant 		= #B 
						id_poly_courant			=	cnx_courante.id_poly_b
					 ) else (

						mode_poly_courant 		=	#A
						id_poly_courant			=	cnx_courante.id_poly_a
					 )
					
-- 					id_poly_courant			=	cnx_courante.basculer		id_poly_courant
					pts_courant 				= _polys[ id_poly_courant ].get_pts 	oriente:true
					id_pt_courant  			= cnx_courante.get_id_pt 		mode_poly_courant
					pt_courant 				= pts_courant [ id_pt_courant ]
					
				debug ">>>>>>>>>>>>>>>	2 -----   pt_courant" var:pt_courant
					cnx_courante.passages +=1
					
-- 					---- le second point --------------
					append pts_decoupe_courant 		pt_courant
					
					----- on retire cet connexion des connexions a traiter ----------------------
					ids_connexions_aTraiter[ id_premiere_connexion ] = false
					
					
					
					
					
					----- on remplie jusqu'à trouver la prochaine connexion ------------------------
					local onA_uneConnexion 	= false
					local onA_faitLeTour 		= false
					while not 	onA_uneConnexion	and not  onA_faitLeTour do (
						
						debug "----------------------------		on remplie jusqu'à trouver la prochaine connexion 	----------------------------------------------------------------"
						
						debug " PT" var:pts_decoupe_courant.count
						
			
						debug "pt_courant" var:pt_courant
						debug "mode_poly_courant" var:mode_poly_courant
						debug "id_poly_courant" var:id_poly_courant
						debug "id_pt_courant" 	var:id_pt_courant
						
						debug "id_poly_initial" 	var:id_poly_initial
						debug "id_pt_initial" 			var:id_pt_initial
						
						
						
						--- on regarde si on est sur une connexion  -----------
						local cnx_trouve 
						local id_cnx = 1
						local id_cnx_trouve  = 0
						while  id_cnx <= connexions.count 	do (
							if ids_connexions_aTraiter[ id_cnx ] and connexions[ id_cnx ] != cnx_courante do (
								if connexions[ id_cnx ].est_courante 		id_poly_courant 	id_pt_courant	then (
									
									debug "	--------> on est sur une connexion" var:connexions[ id_cnx ]
									---- on est sur une connexion -----------------
									cnx_trouve 			= connexions[ id_cnx ]
									onA_uneConnexion 	= true
									id_cnx_trouve  		= id_cnx
									
								) 
							)
							id_cnx += 1
						)
						
						if onA_uneConnexion then (
							debug "	--------> CONNEXION"
							cnx_courante = cnx_trouve
							cnx_courante.passages += 1 
							
							
							/* 
							---- on ajoute le point de la connexion 
							id_pt_courant  			= cnx_courante.get_id_pt 		id_poly_courant
							pt_courant 				= pts_courant [ id_pt_courant ]
							append pts_decoupe_courant 		pt_courant
							*/
							
							----- on retire cet connexion des connexions a traiter si on a fait les deux passages ----------------------
							if cnx_courante.passages > 1 do
								ids_connexions_aTraiter[ id_cnx_trouve ] = false
							
							
-- 							append pts_decoupe_courant 		pt_courant
							
						) else 
							debug "	--------> PT NORMAL"							
						
						
						
						--- le point courant ----------------------
						id_pt_courant  			= mgr_shp.boucler	pts_courant	( id_pt_courant + 1 )
						pt_courant 				= pts_courant [ id_pt_courant ]
						append pts_decoupe_courant 		pt_courant
						
						
						
						--- on regarde si on a fait le tour  -----------
						if  id_poly_initial 		== id_poly_courant		and  id_pt_initial 	== id_pt_courant then  (
							--- on a fait le tour -------------
							
							debug "-------> ON A FAIT LE TOUR  				 <------------------- "
						
					
							debug "-------> pts_decoupe_courant" var:pts_decoupe_courant
					
							onA_faitLeTour = true
							
							--- on ajoute nos points au resultat -----
							append list_pts_decoupe	pts_decoupe_courant
							pts_decoupe_courant = #()
							
					
							
							--- on change de connexion ----------
							if (ids_connexions_aTraiter as array ).count > 0 then (
								
								id_premiere_connexion 	= (ids_connexions_aTraiter as array )[1]
								cnx_courante 				= connexions [ id_premiere_connexion ]								
								id_poly_courant 	= cnx_courante.id_poly_A
							
								---- on commence avec les points de la connexion -------------------------------------------
								pts_courant 		= _polys[ id_poly_courant ].get_pts 	oriente:true
								id_pt_courant  	= cnx_courante.get_id_pt 		mode_poly_courant
								pt_courant 		= pts_courant [ id_pt_courant ]
								
								-----  les conditions initiales- --------------------------
								id_poly_initial 		= id_poly_courant
								id_pt_initial 		= id_pt_courant
								
								---- le premier point --------------
								append pts_decoupe_courant 		pt_courant
								
							) else 
								onA_desConnexions_aTraiter = false
							
						)
						
						
						
						
						
						
							
						debug "pts_decoupe_courant" 			var:pts_decoupe_courant
						
						
					)
					
				)
				
			) else append list_pts_decoupe
			
			
			list_pts_decoupe
			
		),
		
		fn trianguler		_polys =(
			
			debug "--------trianguler-------------------------------------"
			local triangles = #()
			
			----- PREMIER BALAYAGE    --- VERTICAL ---------------
			local polys_monotones	=	decouper_polygone_monotone	_polys	balayage:#verticale
			debug "polys_monotones" var:polys_monotones
			
			for poly in polys_monotones do (
				---- on a un triangle  --------
				if poly.count == 3 then	
					append triangles poly
				else if poly.count > 3 do (
					----- SECOND BALAYAGE    --- 	HORIZONTAL ---------------
					local polys_monotones_pass2	=		decouper_polygone_monotone	_polys	balayage:#horizontal
					
			debug "polys_monotones_pass2" var:polys_monotones_pass2
					for poly_pass2 in polys_monotones_pass2 do (
						
						---- on a un triangle  --------
						if poly_pass2.count == 3 then
							append triangles 	poly_pass2
						else (
							----- on doit avoir des polygone monontone -------
							--- c'est qu'on fait lee triangles façon "oreille" ----------
							
							triangles += mgr_shp.trianguler 	poly_pass2
						)
						
					)
					
					
				)
			)
			debug "triangles" var:triangles
			triangles
		),
	
	public	
	
		fn inserer_poly_ds_poly		_poly_aInserer		_poly_dest 		=(
			
			--format "\n\n"
-- 			debug "	//////////////////////////			inserer_poly_ds_poly()		//////////////////////////"
-- 			debug "_poly_aInserer" var:_poly_aInserer.nom
-- 			debug "_poly_dest" var:_poly_dest.nom
-- 			debug "_poly_dest  POINTS" var:(_poly_dest.get_pts ())
			
			/* 
			struct str_result	(
				est_aCote 		= false,
				est_enfantDe	= undefined,
				est_parentDe	= undefined
			)
			local result = str_result()
			 */
			
			local result = false
			
			
			if (_poly_dest.get_pts()).count == 0 then (
				_poly_dest.ajouter_enfant		_poly_aInserer
				result = true
			) else (
				
				
				
				--- on utlise les BB !!!  on considere que les shape sont clean ici : ils ne se croisent pas entre eux ....	-----------------------------------------------
				local pos_relative = mgr_shp.get_positionRelative_BB 		(_poly_dest.get_pts ())		(_poly_aInserer.get_pts ())	
				
				
				debug "pos_relative" var:pos_relative
				case pos_relative of (
					
					#aCoté:	 		result = false		--result.est_aCote = true
					
					#interieur:		(
							------ on regarde s'il rentre dans les enfants du poly destination	--------------	
							local a_ete_integre	=	false		
							local	enfants_dest = 	for enfant in _poly_dest.enfants collect enfant
							local i = 1
							while	 i <= enfants_dest.count and not a_ete_integre	do (
								local enfant_dest	=	enfants_dest[ i ]
								local integration_reussie		=	inserer_poly_ds_poly		_poly_aInserer			enfant_dest
								if  integration_reussie do a_ete_integre = true
								i += 1
							)
							
							debug"a_ete_integre		" var:a_ete_integre
							----- sinon on l'ajoute aux enfants du poly dest ----------------
							if not a_ete_integre do (
								
								_poly_dest.ajouter_enfant 		_poly_aInserer
								
							)
							result = true
								
							
						) ---- fin #interieur	----------
						
						
						
					#exterieur:		(
						
						local parent_dest = _poly_dest.parent 
						_poly_aInserer.ajouter_enfant		_poly_dest
						
						local calque_dest = _poly_dest.calque 
						
						if parent_dest != undefined then (
-- 							debug	"parent_dest != undefined "
							parent_dest.ajouter_enfant	_poly_aInserer
							result = true	
-- 							result = fasle	
						) --else append		calque_dest.polygones		_poly_aInserer

							
						) ---- fin #exterieur	----------
					
						
						
					#seCroisent:		(
					
-- 							debug "###########################################################"
-- 							debug "#############################################################"
-- 							debug "#########											#########"
-- 							debug "#########	/!\	hmm! probleme, il ne devrait y 	PAS	#########"
-- 							debug "#########	avoir d'INTERSECTION de polygones ici, on est dans l'insertion dans : inserer_poly_ds_poly() 	#########"
-- 							debug "#########											#########"
-- 							debug "#############################################################"
							result = #PROBLEME
						) ---- fin #seCroisent	----------
				)
			)
-- 			debug "	/////////////////////////////////////////////////////////////////////////////" var:result
			
			result
		),
		
		fn est_dans_polygone		_poly_A 		_poly_B		=(
			
			local pos_relative = mgr_shp.get_positionRelative_shapes 	( _poly_A.get_pts() )	( _poly_B.get_pts () )	renvoyer_intersections:false
			local result
			
			if  pos_relative.position == #interieur do (
				local parent 
				for poly_enfant in _poly_A.enfants do (
					local est_dans_enfant = 	est_dans_polygone		poly_enfant 	_poly_B
					if est_dans_enfant != undefined do
						parent	=	est_dans_enfant
				)
				if parent != undefined then 
					result = parent
				else
					result = _poly_A
			)
			
			result
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
		
		fn dupliquer		_poly 	=(
			local nv_poly = creer_polygone	nom:_poly.nom	pts:(_poly.get_pts ()) 
			
-- 			nv_poly.dist_auParent		=	_poly.dist_auParent
			nv_poly.en_creux				=	 _poly.en_creux
			
			for enfant_poly in _poly.enfants do ( 
				local dup_enfant = dupliquer enfant_poly
				append	nv_poly.enfants	 dup_enfant
				dup_enfant.parent = nv_poly
			)
			nv_poly.set_calque  undefined	
						
			nv_poly
		), 
		
		
		fn creer_fromShape		_shape_node	=(
			
			--- on renvoie une liste de polygones --------
			local result_polys	=	#()
			
			local chrono_1 = timeStamp ()
			--- on recupere nos tracés à partir des splines du shape_node
			local pts_shps 	= 	mgr_shp.interpoler_shape		_shape_node
-- 			
-- 			debug "--->	interpolation"  var:( (  ((timeStamp ()) - chrono_1 ) / 1000.0)		as string + " s.")
-- 			
			--- et on créé un polygone par tracé		-------------
			local i = 0
			for pts_shp in pts_shps do (
				--- le nouveau polygone ---
				local nom_poly 	=  _shape_node.name	+ "_" + (  i+=1 ) as string
				local nv_poly 		= creer_polygone		pts:pts_shp	nom:nom_poly
				append result_polys nv_poly
-- 				debug "PTS:" var:(nv_poly.get_pts())
-- 				
-- 				--- on l'ajoute à la hierarchie resultante --------------
-- 				inserer	 result_polys 	nv_poly
			)
			
			result_polys
		)

		
		
		

	
) ------ fin struct mgr polys ---------------------------






























