
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - outils - shape.ms" 


---- polygone de la hierarchie ----------
struct str_polygone (
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	false,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | poly"	  	var:var	 param:param		catch (),
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
			mgr_shp.get_positionRelative_shapes 	(  get_pts () )	(  _poly_a_tester.get_pts () )	 renvoyer_intersections:true
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
		fn debug_pts 	_pts nom:("debug_")	=  if m_debug  do	(
			::debug_spline	_pts	nom:nom
		),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
	
	
	
	
		mgr_shp	=	str_outils_shape (),
	
	
		SEUIL_POINTS_EGAUX  	= .001,
		-- constante pr debug-----------------
		SAUVETAGE_MAX 			= 200000000,
	
	
	
	
	------------ Fonstions internes 	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	/* 
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
		
		 */
		
		
	------------ Interface	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	----- TRIANGULATION ---------------------------------------
	private
		fn get_pts_dansTriangle 	_pts_triangle		_pts	=(
			local ids_pts_dsTriangle =#()
			for i = 1 to  _pts.count do (
				local pt = _pts[i]
				if mgr_shp.est_dansTriangle  		_pts_triangle[1]	_pts_triangle[2]	_pts_triangle[3]			pt		do
					append	ids_pts_dsTriangle i
			)
			ids_pts_dsTriangle
		),
	
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
					
					--- ceux qui sont du shape a tester ----------
					if id_poly == _id_poly_test then (
						---- 
						if _id_test == id_sgt or id_test_prcdt== id_sgt do
							deleteItem sgts_surMemeAxe	 i_idsSgt
					)
				)
				
				append segments_surMemeAxe		sgts_surMemeAxe
				
			)
-- 			debug "segments_surMemeAxe" var:segments_surMemeAxe
			segments_surMemeAxe
		),
		
		fn  points_lesPlusLoinDuSegment			_polys		_listeDe_idsPoly_idsPt		_seg_pt_1  	_seg_pt_2 =(
-- 				debug "\n"
-- 				debug "points_lesPlusLoinDuSegment"	
-- 				debug "_seg_pt_1"	var:_seg_pt_1
-- 				debug "_seg_pt_2"	var:_seg_pt_2
-- 								for i = 1 to _polys.count do (
			local dist_max = 0
			local result
			for  idsPoly_idsPt	in _listeDe_idsPoly_idsPt do (
				
-- 				debug "idsPoly_idsPt"	var:idsPoly_idsPt
				local id_poly_dsTriangle	= idsPoly_idsPt[1]
				
-- 				debug "--->	id_poly_dsTriangle"	var:id_poly_dsTriangle
				local pts 						= _polys[ id_poly_dsTriangle ].get_pts oriente:true
-- 				debug "--->	pts" var:pts
				
				local pts_dsTriangle 		= for id_pt in idsPoly_idsPt[2] collect pts[ id_pt ]
				
				
-- 				debug "--->	pts_dsTriangle" var:pts_dsTriangle
				
				
				local	pt_connexion_lesPlusLoins_duSegmt	 = mgr_shp.points_lesPlusLoinDuSegment		pts_dsTriangle		_seg_pt_1  	_seg_pt_2
				
-- 				debug "--->	pt_connexion_lesPlusLoins_duSegmt" var:pt_connexion_lesPlusLoins_duSegmt
				
				
				for id_pt_loin in pt_connexion_lesPlusLoins_duSegmt do (
-- 					debug "	--->	id_pt_loin" var:id_pt_loin
					local id_pt_test = idsPoly_idsPt[2][id_pt_loin]
					local pt_test 		= pts[id_pt_test]
-- 					debug "	--->	pt_test" var:pt_test
					local dist_test 	= mgr_shp.get_distance_point_segment		pt_test		_seg_pt_1  	_seg_pt_2
-- 					debug "	--->	dist_test" var:dist_test
					if dist_test> dist_max do (
						dist_max = dist_test
						result = #(id_poly_dsTriangle, id_pt_test)
					)
					
				)
				
			)
			debug "--> pt_ connexion result" var:( ( _polys[result[1]]).get_pts oriente:true )[ result[2] ] 
-- 			debug "###########################################################"
			result
		),
		
		fn  point_lePlusProche_dePoint			_polys		_listeDe_idsPoly_idsPt		_pt_origine	 =(
-- 				debug "\n"
-- 				debug "point_lePlusProche_dePoint"	
-- 				debug "_polys"	var:_polys
-- 				debug "_listeDe_idsPoly_idsPt"	var:_listeDe_idsPoly_idsPt
-- 				debug "_pt_origine"	var:_pt_origine
-- 								for i = 1 to _polys.count do (
-- 			local dist_max = 0
			local result
			local dist_min 			= 1e14
			local id_poly_proche 	= 0
			local id_pt_proche 		= 0
			for  idsPoly_idsPt	in _listeDe_idsPoly_idsPt do (
				
-- 				debug "--->	idsPoly_idsPt" var:idsPoly_idsPt
-- 				debug "POPOPOPOPOPOPOPO 1"	
-- 				debug "idsPoly_idsPt"	var:idsPoly_idsPt
				local id_poly_dsTriangle	= idsPoly_idsPt[1]
				
-- 				debug "--->	id_poly_dsTriangle"	var:id_poly_dsTriangle
				local pts 						= _polys[ id_poly_dsTriangle ].get_pts oriente:true
-- 				debug "--->	pts" var:pts
				
-- 				local pts_dsTriangle 		= for id_pt in idsPoly_idsPt[2] collect pts[ id_pt ]
				local id_pt =  idsPoly_idsPt[2]
-- 				for id_pt in idsPoly_idsPt[2] do (
-- 				debug "--->	id_pt" var:id_pt
				local pt_test = pts[ id_pt ]
-- 			debug "--->	pt_test" var:pt_test
				local dist_test = distance		_pt_origine		pt_test
-- 											debug "		----->	###################################### "
				if dist_test < dist_min do (
					dist_min = dist_test
					id_poly_proche = id_poly_dsTriangle
					id_pt_proche = id_pt
-- 				debug "-------------->id_poly_proche"	 var:id_poly_proche
-- 				debug "-------------->id_pt_proche"	 var:id_pt_proche
					
-- 					)
				)
-- 				debug "POPOPOPOPOPOPOPO 2"	

			)
			result = #( id_poly_proche , id_pt_proche)
			
-- 				debug "result 1"	var:result
-- 			debug "--> pt_ connexion result" var:( ( _polys[result[1]]).get_pts oriente:true )[ result[2] ] 
-- 			debug "###########################################################"
			result
		),
		
		
		
		fn sont_egales_connexions 	_cnxn1 	_cnxn2 =(
			local result = false
			if 	_cnxn1.id_poly_A	== _cnxn2.id_poly_A	and  	_cnxn1.id_poly_B	== _cnxn2.id_poly_B	and _cnxn1.id_pt_A	== _cnxn2.id_pt_A	and _cnxn1.id_pt_B	== _cnxn2.id_pt_B then
				result = true
			else if 	_cnxn1.id_poly_A	== _cnxn2.id_poly_B	and  	_cnxn1.id_poly_B	== _cnxn2.id_poly_A	and _cnxn1.id_pt_A	== _cnxn2.id_pt_B	and _cnxn1.id_pt_B	== _cnxn2.id_pt_A do
				result = true
			
			result
		),
		
		
		fn ajouter_connexion	 _liste_connexions	connexion_aAjouter =(
			local est_deja_presente = false 
			local croise_intersection = false
			for cnxn in _liste_connexions do  (
				if sont_egales_connexions	 cnxn	connexion_aAjouter	do
					est_deja_presente = true
				
				local intersection_pos = mgr_shp.get_intersection_vecteurs		cnxn.pt_A   cnxn.pt_B		connexion_aAjouter.pt_A   connexion_aAjouter.pt_B
				if intersection_pos != undefined do 
					croise_intersection = true
-- 			debug "############ <------------------------------- chuis là"
			)
			
			
			
			if not est_deja_presente and not croise_intersection		do 
				append _liste_connexions	connexion_aAjouter

		),
		
		
		
		
		
		---- renvois les points de connexions en balayage 
		fn get_connexions  		_axe		_polys		_id_poly			_id_pt 	 	filtre:#tout		=(
			
-- 			debug"\n"
			debug "-------	get_connexions 	------------"
			debug "_id_poly" 		var:_id_poly
			debug "_id_pt" 		var:_id_pt
			debug "filtre" 		var:filtre
			
			struct str_connexion	(
				id_poly_A	=	0,
				id_poly_B	=	0,
				id_pt_A		=	0,
				id_pt_B		=	0,
				pt_A 	,
				pt_B 	,
				
				
				passages 	= #aucun ,
				
				
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
					local result = #non_courante
					if ( _id_poly == id_poly_A and _id_pt == id_pt_A) then
						result = #A
					else if  ( _id_poly == id_poly_B and _id_pt == id_pt_B ) then
						result = #B
					result
				)
			)
			
			
			
			
			
			local result = #()
			local poly_courant	=	_polys[ _id_poly ]
			local pts 				= poly_courant.get_pts oriente:true 
			local pt_courant 		= pts[ _id_pt ]
			
			
			local i_precedant 	= mgr_shp.boucler pts ( _id_pt - 1 )
			local i_suivant 		= mgr_shp.boucler pts ( _id_pt + 1 )			
			local pt_precedant 	= pts [i_precedant]					
			local pt_suivant 		= pts [i_suivant]			
			local est_sensPositif = mgr_shp.est_sensPositif	#( pt_precedant, pt_courant, pt_suivant) 
			
			if 	poly_courant.est_exterieur ()   and  not est_sensPositif 			or		not poly_courant.est_exterieur ()   and  not  est_sensPositif 		do (		
			
				local sgts_sur_memeAxe =	get_sgts_sur_memeAxe		_axe			_polys		_id_poly		_id_pt
				---------- DEBUG--------------------------
				
				debug "----> sgts_sur_memeAxe" var:sgts_sur_memeAxe
				
				--- pour chaque polygone --------------------
				----	on cherche la connexion la plus proche --------------
				local distMin_intersection_D = 1e14
				local distMin_intersection_G = 1e14
				
				local pts_debug =#()
	-- 					debug "	----->	sgts_surAxe" var:sgts_surAxe
				local id_poly_valide_G 	= 0
				local id_poly_valide_D 	= 0
				local id_seg_valide_G 	= 0
				local id_seg_valide_D 	= 0
				
				
				
				for id_polys_sgt_surAxe = 1 to sgts_sur_memeAxe.count do (
					
					
					
					local poly 				= _polys[ id_polys_sgt_surAxe ]												
					local pts 				= poly.get_pts 	oriente:true
					
					local sgts_surAxe 	= sgts_sur_memeAxe [ id_polys_sgt_surAxe ]
					
					--- pour chque segment sur le meme axe que notre point  --------------------
					for id_sgt_surAxe in sgts_surAxe do (
						
	-- 					debug "	----->	id_sgt_surAxe" var:id_sgt_surAxe
						
						local pt_sgt_surAxe 			= pts[ id_sgt_surAxe ]
						local id_sgt_surAxe_svnt		= mgr_shp.boucler	pts ( id_sgt_surAxe + 1 )
						local pt_sgt_surAxe_svnt 		= pts[ id_sgt_surAxe_svnt ]
						
						local pt_courant_axe
						if _axe == #horizontal then
							pt_courant_axe				= pt_courant + [1,0,0]
						else pt_courant_axe			= pt_courant + [0,1,0]
						
						local intersection 				= mgr_shp.get_intersection_droite_droite			pt_courant 	pt_courant_axe		pt_sgt_surAxe		pt_sgt_surAxe_svnt
						
						
						debug "	----->	intersection" var:intersection
						case _axe of (
							#horizontal:  (
							
										--- la connexion  a GAUCHE -----
										if intersection.x < pt_courant.x  then if  filtre == #tout or filtre == #gauche  do(
											if distance pt_courant  intersection < distMin_intersection_G do (

												distMin_intersection_G = distance pt_courant  intersection
												id_poly_valide_G 	= id_polys_sgt_surAxe
												
												--- on verifie qu'il n'ya pas de points dans le triangle ---------------
												local pts_triangle = #( pt_sgt_surAxe, pt_sgt_surAxe_svnt , pt_courant)
												
												debug "		----->	triangle " var:pts_triangle
												
												local 	polys_pts_dsTriangle = #()
												for i = 1 to _polys.count do (
													local ids_pts_result = get_pts_dansTriangle 		pts_triangle		( _polys[i].get_pts oriente: true )
													
													
													if ids_pts_result.count > 0 do (
														for id_pt_result in ids_pts_result do (
															local pts_result 					= _polys[i].get_pts oriente:true
															local id_pt_result_precedant 	= mgr_shp.boucler	pts_result  (id_pt_result - 1 )
															local id_pt_result_suivant 	= mgr_shp.boucler	pts_result  (id_pt_result + 1 )
															
															local pt_result					= pts_result[ id_pt_result ]
															local pt_result_precedant		= pts_result[ id_pt_result_precedant ]
															local pt_result_suivant			= pts_result[ id_pt_result_suivant ]
															
													
															local est_sensPositif_result	 = mgr_shp.est_sensPositif	#( pt_result_precedant, pt_result, pt_result_suivant) 
															
															if _id_poly ==  i		then (															
																if  id_pt_result != i_precedant 	and   id_pt_result != i_suivant do (
																	if not est_sensPositif_result do
																		append polys_pts_dsTriangle  #( i,  id_pt_result )
															
																)
																
																
															) else 
																append polys_pts_dsTriangle  #( i,  id_pt_result )

	-- 														if _id_poly !=  id_polys_sgt_surAxe			or _id_poly ==  id_polys_sgt_surAxe	and  id_pt_result != i_precedant 	and   id_pt_result != i_suivant do
	-- 															append polys_pts_dsTriangle  #( i,  id_pt_result )
														)
													)
												)
												
												debug "		----->	polys_pts_dsTriangle " var:polys_pts_dsTriangle
												if polys_pts_dsTriangle.count > 0 then (
													
													local pt_connexion_choisie	=	point_lePlusProche_dePoint		_polys 	polys_pts_dsTriangle		pt_courant
													
													debug "		----->	pt_connexion_choisie " var:pt_connexion_choisie
													
													id_poly_valide_G 	= 	pt_connexion_choisie[1]
													id_seg_valide_G 	=  pt_connexion_choisie[2]
												) else 
													id_seg_valide_G 	= id_sgt_surAxe
												
											)
											
										) else if  filtre == #tout or filtre == #droite do (
										--- la connexion  a DROITE -----
											if distance pt_courant  intersection < distMin_intersection_D  do (

												distMin_intersection_D = distance pt_courant  intersection
												id_poly_valide_D 	= id_polys_sgt_surAxe
												
												id_seg_valide_D 	= mgr_shp.boucler	 pts	( id_sgt_surAxe + 1 )
												local pt_sgt_surAxe_svnt 		= pts[ id_seg_valide_D ]
												
												
												--- on verifie qu'il n'ya pas de points dans le triangle ---------------
												local pts_triangle = #( pt_sgt_surAxe , pt_sgt_surAxe_svnt,  pt_courant)
												
												debug "		----->	triangle " var:pts_triangle
												
												
												local 	polys_pts_dsTriangle = #()
												for i = 1 to _polys.count do (
													local ids_pts_result = get_pts_dansTriangle 		pts_triangle		( _polys[i].get_pts oriente: true )
																										
													if ids_pts_result.count > 0 do (
														for id_pt_result in ids_pts_result do (
															local pts_result 					= _polys[i].get_pts oriente:true
															local id_pt_result_precedant 	= mgr_shp.boucler	pts_result  (id_pt_result - 1 )
															local id_pt_result_suivant 	= mgr_shp.boucler	pts_result  (id_pt_result + 1 )
															
															local pt_result					= pts_result[ id_pt_result ]
															local pt_result_precedant		= pts_result[ id_pt_result_precedant ]
															local pt_result_suivant			= pts_result[ id_pt_result_suivant ]
															
															local est_sensPositif_result	 = mgr_shp.est_sensPositif	#( pt_result_precedant, pt_result, pt_result_suivant) 
															
															if _id_poly ==  i		then (															
																if  id_pt_result != i_precedant 	and   id_pt_result != i_suivant do (
																	if not est_sensPositif_result do
																		append polys_pts_dsTriangle  #( i,  id_pt_result )
															
																)
																
																
															) else 
																append polys_pts_dsTriangle  #( i,  id_pt_result )

	-- 														if _id_poly !=  id_polys_sgt_surAxe			or _id_poly ==  id_polys_sgt_surAxe	and  id_pt_result != i_precedant 	and   id_pt_result != i_suivant do
	-- 															append polys_pts_dsTriangle  #( i,  id_pt_result )
														)
													)
												)
												
												debug "		----->	polys_pts_dsTriangle " var:polys_pts_dsTriangle
												
												if polys_pts_dsTriangle.count > 0 then (
													
													
													local pt_connexion_choisie	=	point_lePlusProche_dePoint		_polys 	polys_pts_dsTriangle		pt_courant
													
													debug "		----->	pt_connexion_choisie " var:pt_connexion_choisie
													
													id_poly_valide_D 	= 	pt_connexion_choisie[1]
													id_seg_valide_D 	=  pt_connexion_choisie[2]
												)else 
													id_seg_valide_D	= id_sgt_surAxe_svnt
												
												
												
											)
										)
										
									)
						/* 
							#vertical:  (
								--- la connexion  en BAS -----
								if intersection.y < pt_courant.y  then if  filtre == #tout or filtre == #bas  do (
									if distance pt_courant  intersection < distMin_intersection_G do (

										distMin_intersection_G = distance pt_courant  intersection
										id_poly_valide_G 	= id_polys_sgt_surAxe
										
										--- on verifie qu'il n'ya pas de points dans le triangle ---------------
										local pts_triangle = #( pt_sgt_surAxe, pt_sgt_surAxe_svnt , pt_courant)
										
										debug "		----->	triangle " var:pts_triangle
										
										local 	pts_dsTriangle = #()
										
										local 	polys_pts_dsTriangle = #()
										for i = 1 to _polys.count do (
											local pt_result = get_pts_dansTriangle 		pts_triangle		( _polys[i].get_pts oriente: true )
											if pt_result.count > 0 do
												append polys_pts_dsTriangle  #( i,  pt_result )
										)
										
										debug "		----->	polys_pts_dsTriangle " var:polys_pts_dsTriangle
										if polys_pts_dsTriangle.count > 0 then (
											
											local pt_connexion_choisie	=	point_lePlusProche_dePoint		_polys 	polys_pts_dsTriangle		pt_courant
											
											debug "		----->	pt_connexion_choisie " var:pt_connexion_choisie
											
											id_poly_valide_G 	= 	pt_connexion_choisie[1]
											id_seg_valide_G 	=  pt_connexion_choisie[2]
										) else 
											id_seg_valide_G 	= id_sgt_surAxe
										
									)
									
								) else if  filtre == #tout or filtre == #haut do (
								--- la connexion  a HAUTe -----
									if distance pt_courant  intersection < distMin_intersection_D  do (

										distMin_intersection_D = distance pt_courant  intersection
										id_poly_valide_D 	= id_polys_sgt_surAxe
										
										id_seg_valide_D 	= mgr_shp.boucler	 pts	( id_sgt_surAxe + 1 )
										local pt_sgt_surAxe_svnt 		= pts[ id_seg_valide_D ]
										
										--- on verifie qu'il n'ya pas de points dans le triangle ---------------
										local pts_triangle = #( pt_sgt_surAxe , pt_sgt_surAxe_svnt,  pt_courant)
										
										debug "		----->	triangle " var:pts_triangle
										
										local 	polys_pts_dsTriangle = #()
										for i = 1 to _polys.count do (
											local pt_result = get_pts_dansTriangle 		pts_triangle		( _polys[i].get_pts oriente: true )
											if pt_result.count > 0 do
												append polys_pts_dsTriangle  #( i,  pt_result )
										)
										
										debug "		----->	polys_pts_dsTriangle " var:polys_pts_dsTriangle
										
										if polys_pts_dsTriangle.count > 0 then (
											
											local pt_connexion_choisie	=	point_lePlusProche_dePoint		_polys 	polys_pts_dsTriangle		pt_courant
											
											debug "		----->	pt_connexion_choisie " var:pt_connexion_choisie
											
											id_poly_valide_D 	= 	pt_connexion_choisie[1]
											id_seg_valide_D 	=  pt_connexion_choisie[2]
											
										)else 
											id_seg_valide_D	= id_sgt_surAxe_svnt
										
									)
								)
								
							) */
						) --- fin case -------
						
					)
					
					
				)
				
				if id_seg_valide_G != 0  do (
					
	-- 				if do (
						
						debug "a gauche"
					local pts_A = _polys[_id_poly ].get_pts oriente:true
					local pts_B = _polys[id_poly_valide_G ].get_pts oriente:true
					
					
						--- on creer les connexions	---------------------
						local connexion_G = str_connexion	id_poly_A:	_id_poly							\
																		id_poly_B:	id_poly_valide_G				\
																		id_pt_A:		_id_pt							\
																		id_pt_B:		id_seg_valide_G				\
																		pt_A:			pts_A[ _id_pt ] 				\
																		pt_B:			pts_B[ id_seg_valide_G ]
						append result connexion_G
	-- 				)
				)
	-- 			
	-- 			debug "result" var:result
				if id_seg_valide_D != 0  do (
	-- 				if filtre == #tout or filtre == #droite do (
					debug "a droite"
					if id_poly_valide_G != id_poly_valide_D or  id_seg_valide_G != id_seg_valide_D do ( 
						
					local pts_A = _polys[_id_poly ].get_pts oriente:true
					local pts_B = _polys[id_poly_valide_D ].get_pts oriente:true
						
						
						
						local connexion_D = str_connexion	id_poly_A:	_id_poly							\
																		id_poly_B:	id_poly_valide_D				\
																		id_pt_A:		_id_pt							\
																		id_pt_B:		id_seg_valide_D				\
																		pt_A:			pts_A[ _id_pt ] 				\
																		pt_B:			pts_B[ id_seg_valide_D ]
						append result connexion_D
					)
	-- 				)
					
				)
				
			)
			debug "--------> fin get connexion " var:result
			result
			
		),
		
		fn analyser_connexions 					_polys		balayage:#verticale	 =(
			
			------ on cherche les 'pointes'---------
			---			Pour chaque point P, vérifiez si les points voisins sont tous deux du même côté de la ligne de balayage.
			---			Si c'est le cas, vérifiez la ligne de balayage suivante de l'autre côté. 
			---			Casser le polygone sur la ligne entre le point d'origine et l'un des points de celui-ci.
			
-- 			local pts_deRupture 			=#()
-- 			local pts_deRupture_horiz 	=#()
			local connexions				 	=#()
			for id_poly = 1 to _polys.count do (
				
				local poly_courant 	= _polys[id_poly]
				local pts 				= poly_courant.get_pts  oriente:true
				
				debug ""
				debug "----- id_poly ----- " var:id_poly
				
-- 				local sur_segment_ortho = false
				for i = 1 to pts.count do (
					
					
					local i_precedant 	= mgr_shp.boucler pts ( i - 1 )
					local i_suivant 		= mgr_shp.boucler pts ( i + 1 )
					
					local pt_courant 		= pts [i]					
					local pt_precedant 	= pts [i_precedant]					
					local pt_suivant 		= pts [i_suivant]
					
					debug  "	--> connexion ?		pt_courant " var:pt_courant
					debug  "	-->					pt_precedant" var:pt_precedant
					debug  "	-->					pt_suivant" var:pt_suivant
					debug  "		-->					pt_courant.y - pt_precedant.y" var:(pt_courant.y - pt_precedant.y)
					debug  "		-->					pt_courant.y - pt_suivant.y " var:(pt_courant.y - pt_suivant.y )
					
-- 					debug ( "pt_courant: "  + pt_courant as string +  "	pt_precedant: "  + pt_precedant as string + "	pt_suivant: "  + pt_suivant as string )
-- 					debug ( "pt_courant: "  +( ( pt_courant.y as double)  * 10000 )as string +  "	pt_precedant: "  + ((pt_precedant.y as double )* 10000 ) as string + "	pt_suivant: "  + ((pt_suivant.y as double  )* 10000 )as string )
-- 					
-- 					local est_sensPositif = mgr_shp.est_sensPositif	#( pt_precedant, pt_courant, pt_suivant) 
-- 					
					---- on cherche les points de ruptures ----------------------
					case balayage of (
						#verticale: (
							
							-------- CAS 1 : pointe  ------------------------
							if  pt_courant.y - pt_precedant.y  > SEUIL_POINTS_EGAUX  and  pt_courant.y - pt_suivant.y  >  SEUIL_POINTS_EGAUX 	then (
								
								debug "		----> CAS 1 : POINTE  "
								local 	 nvls_cnxns	= get_connexions  		#horizontal		_polys		id_poly		i 
								debug "nvls_cnxns" var:nvls_cnxns
								for nvl_cnxn in nvls_cnxns do	ajouter_connexion		connexions nvl_cnxn
								
							-------- CAS 2 : segment horizontal debut	------------------------
							) else 	if abs ( pt_suivant.y - pt_courant.y ) < SEUIL_POINTS_EGAUX	 and 	pt_courant.y - pt_precedant.y  > SEUIL_POINTS_EGAUX	then (
								
									debug "		----> CAS 2 : debut PLAT  "
									local 	 nvls_cnxns	= get_connexions  		#horizontal		_polys		id_poly		i   filtre:#gauche
									debug "nvls_cnxns" var:nvls_cnxns
									for nvl_cnxn in nvls_cnxns do	ajouter_connexion		connexions nvl_cnxn
									
							-------- CAS 3  le second point a connecter de la partie ortho --------------
							) else if   abs ( pt_precedant.y -  pt_courant.y ) < SEUIL_POINTS_EGAUX	and pt_courant.y - pt_suivant.y  >  SEUIL_POINTS_EGAUX then (
								
								debug "		----> CAS 3 : fin PLAT  "									
								local 	 nvls_cnxns	= get_connexions  		#horizontal		_polys		id_poly		i 	 filtre:#droite
								for nvl_cnxn in nvls_cnxns do	ajouter_connexion		connexions 	nvl_cnxn
								
							)
								
						)
						#horizontal: (
							
								-------- CAS 1 : pointe  ------------------------
-- 								if pt_precedant.y < pt_courant.y   and pt_suivant.y < pt_courant.y 	then (
									
								if  pt_courant.x - pt_precedant.x > SEUIL_POINTS_EGAUX  and pt_courant.x - pt_suivant.x  >  SEUIL_POINTS_EGAUX 	then (
									
									debug "		----> CAS 1 : POINTE  "
									local 	 nvls_cnxns	= get_connexions  		#vertical		_polys		id_poly		i 
									debug "nvls_cnxns" var:nvls_cnxns
									for nvl_cnxn in nvls_cnxns do	ajouter_connexion		connexions nvl_cnxn
								)
							-------- CAS 2 : segment horizontal debut	------------------------
							else 	if pt_suivant.x == pt_courant.x  and 	pt_precedant.x <  pt_courant.x 	then (
									
									debug "		----> CAS 2 : debut PLAT  "
									local 	 nvls_cnxns	= get_connexions  		#vertical		_polys		id_poly		i   filtre:#bas
									debug "nvls_cnxns" var:nvls_cnxns
									for nvl_cnxn in nvls_cnxns do	ajouter_connexion		connexions nvl_cnxn
									
								--- le second point a connecter de la partie ortho --------------
								) else if pt_suivant.x < pt_courant.x  and 	pt_precedant.x ==  pt_courant.x then (
									
									debug "		----> CAS 3 : fin PLAT  "									
									local 	 nvls_cnxns	= get_connexions  		#horizontal		_polys		id_poly		i 	 filtre:#haut
									for nvl_cnxn in nvls_cnxns do	ajouter_connexion		connexions 	nvl_cnxn
								)
								
							
						)
					) -- fin case balayage -------
					
					
					
					
					
					
-- 					debug "		----> connexions " var:connexions
				)
			)
			
			
			connexions
		),
		
		
		fn decouper_polygone_monotone		_polys		balayage:#verticale		=(
			
			------------ deBUG -----------------------------
			debug "decouper_polygone_monotone"
			debug "_polys" var:_polys param:#nom
			local debug_points_polys =#()
			for debug_poly in _polys do
				append debug_points_polys (debug_poly.get_pts  oriente:true )
			
			debug "debug_points_polys" var:debug_points_polys
			------------ deBUG -----------------------------
			
			
			
			local list_pts_decoupe =#()
			local pts_decoupe_courant =#()
			
			
			
			--- on recherche les connexions pour découpage	--------
			local connexions				 	= analyser_connexions 		_polys		balayage:balayage
			debug "		------->	CONNEXIONS TOTALES"			var:connexions
			
			
			
			
			
			----- les polys sans connexions ------------------------------
			local ids_poly_ss_connexion	=#{1.._polys.count}
			for cnxn in connexions do (
				ids_poly_ss_connexion [ cnxn.id_poly_A ] = false
				ids_poly_ss_connexion [ cnxn.id_poly_B ] = false
			)
			debug "		------->	################# ?! ?! ?! "	
			debug "		------->	ids_poly_ss_connexion"	 var:ids_poly_ss_connexion
			for i = 1 to _polys.count where  ids_poly_ss_connexion[i] do (				 
					local pts = _polys[i].get_pts ()					
					if not mgr_shp.est_sensPositif pts do pts = 	mgr_shp.changer_sens  pts
					append list_pts_decoupe	pts
			)
			
			
			
			
			
			
			--------- on decoupe les polygones en fonction des connexions 			-----------------------

			if connexions.count > 0 then (
				
				local ids_connexions_aTraiter = #{1..connexions.count}
				
				--- debug ----------
				for cnxn in connexions do (
					
					local pts1_dbg 	= _polys[cnxn.id_poly_A].get_pts oriente:true
					local pts2_dbg 	= _polys[cnxn.id_poly_B].get_pts oriente:true
					local pt1_dbg 	= 	pts1_dbg[ cnxn.id_pt_A ]
					local pt2_dbg 	= 	pts2_dbg[ cnxn.id_pt_B ]
					
					debug_pts 	#(pt1_dbg ,pt2_dbg )  nom:"debug_cnxn"
				)
				--- debug ----------
				
				
				
				
				---- la premiere courante -----------------
				local id_connexion_courante 	= (ids_connexions_aTraiter as array )[1]
				local cnx_courante 				= connexions [ id_connexion_courante ]
				local id_poly_courant 			= cnx_courante.id_poly_A
				
				local mode_poly_courant 		= #A
				
				---- on commence avec les points de la connexion -------------------------------------------
				local pts_courant 		= _polys[ id_poly_courant ].get_pts 	oriente:true
				local id_pt_courant  	= cnx_courante.get_id_pt 		mode_poly_courant
				local pt_courant 			= pts_courant [ id_pt_courant ]
				
				local pt_precedant 		= pt_courant
				
				-----  les conditions initiales- --------------------------
				local id_poly_initial 		= id_poly_courant
				local id_pt_initial 		= id_pt_courant
				
				---- le premier point --------------
				append pts_decoupe_courant 		pt_courant
				
				
				----- tant qu'on a des connexions ----------------------------------------------------------------
				local onA_desConnexions_aTraiter 	= true
				local SAUVETAGE = 0
				while onA_desConnexions_aTraiter and SAUVETAGE < SAUVETAGE_MAX		do (
					
					----- debug ------------
					SAUVETAGE += 1
					----- debug ------------
					
					debug "\n\n\n\n\n"
					debug "----------------------------		tant qu'on a des connexions 	----------------------------------------------------------------"
					debug "ids_connexions_aTraiter" var:ids_connexions_aTraiter
					debug "id_connexion_courante" var:id_connexion_courante
					debug "cnx_courante" var:cnx_courante
					debug "pts_courant" var:pts_courant
					
					
					
					----- on retire la connexion des connexions a traiter si on a fait les deux passages ----------------------
					if cnx_courante.passages  != #aucun	do
						ids_connexions_aTraiter[ id_connexion_courante ] = false
						
					
					if mode_poly_courant == #A then (
						mode_poly_courant 		= #B 
						id_poly_courant			=	cnx_courante.id_poly_b
						cnx_courante.passages = #A_vers_B
					) else (

						mode_poly_courant 		=	#A
						id_poly_courant			=	cnx_courante.id_poly_a
						cnx_courante.passages = #B_vers_A
					)
					
					
-- 					id_poly_courant			=	cnx_courante.basculer		id_poly_courant
					pts_courant 				= _polys[ id_poly_courant ].get_pts 	oriente:true
					id_pt_courant  			= cnx_courante.get_id_pt 		mode_poly_courant
					pt_courant 				= pts_courant [ id_pt_courant ]
					
					
-- 					---- le second point --------------
					append pts_decoupe_courant 		pt_courant
					
					
					---- on traverse la connexion --------------
					 
					 
					 
					----- on retire la connexion des connexions a traiter si on a fait les deux passages ----------------------
-- 					if cnx_courante.passages > 1 do
-- 						ids_connexions_aTraiter[ id_connexion_courante ] = false
					
					
-- 				debug ">>>>>>>>>>>>>>>	2 -----   pt_courant" var:pt_courant
					
					
					
					----- on remplie jusqu'à trouver la prochaine connexion ------------------------
					local onA_uneConnexion 	= false
					local onA_faitLeTour 		= false
					while not 	onA_uneConnexion	and not  onA_faitLeTour and SAUVETAGE < SAUVETAGE_MAX		do (
						
						
						----- debug ------------
						SAUVETAGE += 1
						----- debug ------------
						
						debug"\n\n"
						debug "----------------------------		on remplie jusqu'à trouver la prochaine connexion 	----------------------------------------------------------------"
						
						debug "----> PT" var:pts_decoupe_courant.count
						
						debug "cnx_courante" var:cnx_courante
						debug "ids_connexions_aTraiter" var:ids_connexions_aTraiter
			
						debug "pt_courant" var:pt_courant
							debug "	--------> pt_precedant" 				var:pt_precedant
						debug "mode_poly_courant" var:mode_poly_courant
						debug "id_poly_courant" var:id_poly_courant
						debug "id_pt_courant" 	var:id_pt_courant
						
-- 						debug "id_poly_initial" 	var:id_poly_initial
-- 						debug "id_pt_initial" 			var:id_pt_initial
						
						
						
						--- on regarde si on est sur une connexion  -----------
						local cnxions_trouves =#()
						local id_cnx = 1
						local id_cnx_trouve  = 0
						while  id_cnx <= connexions.count 	do (
							if /* ids_connexions_aTraiter[ id_cnx ] and  */connexions[ id_cnx ] != cnx_courante do (
								local test_onEstSurConnexion = connexions[ id_cnx ].est_courante 		id_poly_courant 	id_pt_courant
-- 								debug "test_onEstSurConnexion" var:test_onEstSurConnexion
								if test_onEstSurConnexion	 != #non_courante		then (
										
									debug "	--------> on est sur une connexion" var:connexions[ id_cnx ]
									---- on est sur une connexion -----------------
									append 		cnxions_trouves 	connexions[ id_cnx ]
									
									id_cnx_trouve  		= id_cnx
									
								) 
							)
							id_cnx += 1
						)
						
						if cnxions_trouves.count > 0  then (
							debug "	--------> CONNEXION"
							debug "	--------> cnxions_trouves" 			var:cnxions_trouves
							debug "	--------> pt_courant" 					var:pt_courant
							debug "	--------> pt_precedant" 				var:pt_precedant
							debug "	--------> pts_decoupe_courant" 	var:pts_decoupe_courant
							
							
							---- choix du passage verts le point le plus a gauche de la direction  -------------
							local vec_courant 	= 	pt_precedant - pt_courant
-- 								debug "	--------> PT poupuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu"	
							local cnx_trouve
							local angle_cnxn_min = 360
							for cnx in cnxions_trouves do (
								local pt_cnxn1		
								local pt_cnxn2		
								local pts_cnxn_A 	= _polys[ cnx.id_poly_A ].get_pts oriente:true
								local pts_cnxn_B 	= _polys[ cnx.id_poly_B ].get_pts oriente:true
								
								local mode_test 
								---- si la connexion relie 2 polygones differents  -----------------------------
								if cnx.id_poly_A  != cnx.id_poly_B then (
									mode_test = if cnx.id_poly_A == id_poly_courant then #A else #B
								) else (
								---- sinon on est sur le meme polygone-----------------------------
									mode_test = if id_pt_courant == cnx.id_pt_A  then #A else #B
								)
								
								
								
								case mode_test of (
									#A:	(
										pt_cnxn1 		= pts_cnxn_A[ cnx.id_pt_A ] 
										pt_cnxn2 		= pts_cnxn_B[ cnx.id_pt_B ] 
									)
									#B:	(
										pt_cnxn1 		= pts_cnxn_B[ cnx.id_pt_B ] 
										pt_cnxn2 		= pts_cnxn_A[ cnx.id_pt_A ] 
									)
								)
								
								
								debug "	--------> pt_cnxn1"	 var:pt_cnxn1
								debug "	--------> pt_cnxn2"	 var:pt_cnxn2
								local angle_cnxn 	= 	mgr_shp.get_angleVecteurs_oriente 	pt_precedant	pt_courant		pt_cnxn1		pt_cnxn2
								
								if angle_cnxn < angle_cnxn_min do (
									angle_cnxn_min = angle_cnxn
									cnx_trouve =  cnx
								)
							)
							
							---- on regarde l'angle avec le point suivant  -------------------
							local id_pt_suivant 	= mgr_shp.boucler pts_courant ( id_pt_courant + 1 )
							local pt_suivant 		= pts_courant[ id_pt_suivant ]
							local vec_suivant 	= pt_courant - pt_suivant
							
							
							local angle_suivant = mgr_shp.get_angleVecteurs_oriente 	pt_precedant	pt_courant		pt_courant		pt_suivant
							
							debug "	--------> angle_suivant"	 var:angle_suivant
							debug "	--------> angle_cnxn_min"	 var:angle_cnxn_min
							
							
							if angle_suivant < angle_cnxn_min then (
								
								debug "		--------> PT NORMAL apres comparaison"							
								
								
								cnx_courante		= undefined
								--- le point courant ----------------------
								pt_precedant 		= pt_courant
								
								id_pt_courant  			= id_pt_suivant
								pt_courant 				= pts_courant [ id_pt_courant ]
								
								append pts_decoupe_courant 		pt_courant
							) else (
							
								debug "		--------> PT connexion"							
								
							
								onA_uneConnexion = true
								
								cnx_courante 		= cnx_trouve
								
								pt_precedant 		= pt_courant
								
								debug "	--------> PT_PRECEDANT" var:pt_precedant
								mode_poly_courant 		=  cnx_courante.est_courante 		id_poly_courant 	id_pt_courant
								id_connexion_courante 	= findItem	connexions		cnx_courante
								
								
								debug "	--------> MODE_POLY_COURANT" var:mode_poly_courant
								debug "	--------> id_connexion_courante" var:id_connexion_courante
								
								if mode_poly_courant == #A then (
									id_poly_courant			=	cnx_courante.id_poly_a
-- 									cnx_courante.passages = #A_vers_B
								) else (
									id_poly_courant			=	cnx_courante.id_poly_b
-- 									cnx_courante.passages = #B_vers_A
								)
								
								debug "	--------> POUET POUET"
							
								pts_courant 		= _polys[ id_poly_courant ].get_pts 	oriente:true
								id_pt_courant 		= cnx_courante.get_id_pt 		mode_poly_courant
								pt_courant 		= pts_courant [ id_pt_courant ]
								
								
								debug "	--------> pt_courant" var:pt_courant
	-- 							append pts_decoupe_courant 		pt_courant
							)
						) else (
							debug "		--------> PT NORMAL"							
						
							cnx_courante		= undefined
						
							pt_precedant 		= pt_courant
							
							--- le point courant ----------------------
							id_pt_courant  			= mgr_shp.boucler	pts_courant	( id_pt_courant + 1 )
							pt_courant 				= pts_courant [ id_pt_courant ]
							
							debug "		--------> pts_decoupe_courant" var:pts_decoupe_courant
							append pts_decoupe_courant 		pt_courant
						)
						
						
						
						
						debug "		--------> pts_decoupe_courant POPOIPOUPOUIPOU" var:pts_decoupe_courant
						
						--- on regarde si on a fait le tour  -----------
						if  id_poly_initial 		== id_poly_courant		and  id_pt_initial 	== id_pt_courant then  (
							--- on a fait le tour -------------
							onA_faitLeTour = true
							
							--- on ajoute nos points au resultat -----
							append list_pts_decoupe	pts_decoupe_courant
							
							debug"\n\n\n"
							debug "--------------------- ON A FAIT LE TOUR  ----------------------------------- "
							debug "-------> pts_decoupe_courant" var:pts_decoupe_courant
							debug "-------> DEBUG_SHAPE" var:(debug_pts	pts_decoupe_courant) 
							debug "-------> list_pts_decoupe" var:list_pts_decoupe
							debug "---------------------------------------------------------------------------- "
							debug "\n\n\n\n\n\n\n\n"
							
							pts_decoupe_courant = #()
							
							
							
							
							--- on change de connexion ----------
							if (ids_connexions_aTraiter as array ).count > 0 then (
								
								id_connexion_courante 	= (ids_connexions_aTraiter as array )[1]
								cnx_courante 				= connexions [ id_connexion_courante ]	
								
								--- choix de la direction -------------
								if 	cnx_courante.passages ==#aucun or cnx_courante.passages == #B_vers_A	then (
									id_poly_courant 			= 	cnx_courante.id_poly_A
									mode_poly_courant		=	#A
								) else (
-- 									cnx_courante.passages = #B_vers_A
									id_poly_courant 			= cnx_courante.id_poly_B
									mode_poly_courant		=	#B
								)
								
								
								
							
								---- on commence avec les points de la connexion -------------------------------------------
								pts_courant 		= _polys[ id_poly_courant ].get_pts 	oriente:true
								id_pt_courant  	= cnx_courante.get_id_pt 		mode_poly_courant
								pt_courant 		= pts_courant [ id_pt_courant ]
								
						
								--- le point precedant ----------------------
-- 								local id_pt_precedant  			= mgr_shp.boucler	pts_courant	( id_pt_courant - 1 )
								pt_precedant 		= pt_courant		--pts_courant [ id_pt_precedant ]
							
								
								
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
				
			) else (
				---- on a pas besoin de le redecouper -----------------
				for poly in _polys do (
					local pts = poly.get_pts ()
					
					if not mgr_shp.est_sensPositif pts do pts = 	mgr_shp.changer_sens  pts
					append list_pts_decoupe	pts
				)
				
				
			)
			
			
			
			-------------- DEBUG ---------------------------------------
			if  SAUVETAGE == SAUVETAGE_MAX		do (				
				debug "\n\n"
				debug "	##################################################################################"
				debug "	##########	/!\		SAUVETAGE MAX => sortie de la boucle 		/!\ 	##########"
				debug "	##################################################################################\n\n\n"
			)
			-------------- DEBUG ---------------------------------------
			
			
			
			
			list_pts_decoupe
			
		),
	
		
	public 	
		fn trianguler		_polys =(
			
			debug "--------trianguler-------------------------------------"
			local triangles = #()
			
			----- PREMIER BALAYAGE    --- VERTICAL ---------------
			local polys_monotones	=	decouper_polygone_monotone	_polys	balayage:#verticale
			debug "polys_monotones" var:polys_monotones
			
			triangles = polys_monotones
			
			
			/* 
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
-- 						if poly_pass2.count == 3 then
							append triangles 	poly_pass2
-- 						else (
							----- on doit avoir des polygone monontone -------
							--- c'est qu'on fait lee triangles façon "oreille" ----------
							
-- 							triangles += mgr_shp.trianguler 	poly_pass2
-- 						)
						
					)
					
					
				)
			)
			*/
-- 			debug "triangles" var:triangles
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
-- 				local pos_relative = mgr_shp.get_positionRelative_BB 		(_poly_dest.get_pts ())		(_poly_aInserer.get_pts ())	
				local pos_relative = mgr_shp.get_positionRelative_shapes 		(_poly_dest.get_pts ())		(_poly_aInserer.get_pts ())	renvoyer_intersections:false
				
				
-- 				debug "pos_relative" var:pos_relative
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
							
-- 							debug"a_ete_integre		" var:a_ete_integre
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
		
		fn est_dans_polygone		_poly_A 				_poly_B		=(
			
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
	
		fn creer_pts_pourFace		_poly			=(
			
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






























