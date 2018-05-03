
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - outils - shape.ms" 


---- polygone de la hierarchie ----------
struct str_polygone (
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	false,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | polys"	  	var:var	 param:param		catch (),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
	
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
			format"##############################\n"
		),
		
		fn detacher =(
			enfants = #()
			parent = undefined
		),
		fn get_descendance	=(
			local result = #()
			for enfant in enfants do (
-- 				append result enfant
				result		+=	enfant.get_descendance()
			)
			append result 	this
			result
		),
		
		fn est_un_enfant	_poly_test	=(
			local descendance = get_descendance ()
			local id_item = findItem descendance	_poly_test
			if id_item != 0 then true else false 
		),
		
		
		fn set_pts  			_pts			= pts =  for pt in _pts collect pt,
		
		
		fn get_pts  			= (
			local result = for pt in pts collect pt
-- 			if en_creux do	mgr_shp.changer_sens	result
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
		)
		
		/* ,
		
		
		
		
		
		
		fn initialiser 	_ptr_shp = mgr_shp = _ptr_shp */
		
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
				
				
				local pos_relative = mgr_shp.get_positionRelative_shapes 		(_poly_dest.get_pts ())		(_poly_aInserer.get_pts ())	renvoyer_intersections:false
				debug "pos_relative" var:pos_relative
				case pos_relative.position of (
					
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
-- 								_poly_dest.ajouter_enfant 		_poly_aInserer
								
							
						) ---- fin #interieur	----------
						
						
						
					#exterieur:		(
-- 						debug	"#exterieur"
-- 						result.est_parentDe	 =	_poly_dest
						
						local parent_dest = _poly_dest.parent 
						_poly_aInserer.ajouter_enfant		_poly_dest
						
						local calque_dest = _poly_dest.calque 
-- 						inserer_poly_ds_poly			_poly_dest		_poly_aInserer
						if parent_dest != undefined then (
-- 							debug	"parent_dest != undefined "
							parent_dest.ajouter_enfant	_poly_aInserer
							result = true	
-- 							result = fasle	
						) --else append		calque_dest.polygones		_poly_aInserer
-- 						result = true	
						/* 
						local parent_B = _poly_dest.parent 
						inserer_poly_ds_poly			_poly_dest		_poly_aInserer
						if _poly_aInserer.parent != undefined then 
							parent_B.ajouter_enfant	_poly_aInserer
						 */
						/* 
								_poly_aInserer.ajouter_enfant 	_poly_dest
-- 								append 	_poly_dest.calque.polygones		_poly_aInserer
							) else (
								_poly_aInserer.ajouter_enfant 	_poly_dest
-- 								append 	_poly_dest.calque.polygones	_poly_aInserer
							)
-- 							result = true
							 */
-- 							result = false
							
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
			
-- 			nv_polygone.initialiser	this
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






























