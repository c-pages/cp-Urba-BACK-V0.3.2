


include	 "$userScripts\\cp-Urba\\modules\\Batiment\\divers\\Batiment - Geometrie.ms"
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - outils - shape.ms" 
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - Outils - booleen shape.ms" 



struct	str_terrain_node_core	(
	
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"Terrain | core	"	  	var:var	 param:param		catch (),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	
	
	------------ Membres	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_plug,
		m_core,
		
		----- le logo -----------
		m_logo = #([-605.581,-231.857,0], [636.61,-231.857,0], [636.61,-86.025,0], [377.346,-86.025,0], [219.367,260.627,0], [65.4331,-77.1487,0], [-49.6755,175.43,0], [-83.7085,100.755,0], [-196.462,348.168,0], [-394.335,-86.025,0], [-605.581,-86.025,0]),
		
		
	---- managers  ------------------
		mgr_geo							= 	str_geometrie 		(),
		mgr_shapes					= 	str_terrain_outils_shape (),
		mgr_datas						=	str_datasToString (),
		
	----- les points stockés pour manip -----
-- 		m_pts_contours	 			=	#(),		---- les listes de points issues des points des splines contours, cleannés et dans le bon sens. ------------
		m_ndRoot_contour			=	undefined,
		m_pts_faces					=	#(),		---- les listes de points des faces de base. ------------
		m_pts_quadrillages			=	#(),		---- les positions des points des faces une fois les quadrillage fait et cleanné .------------
		m_pts_aligner_auShapes	=	#(),		----.------------
		m_pts_decallageZ			=	#(),		----.------------
		
		m_pts_projections			=	#(),		---- les positions des points des faces une fois la projection faite, on peut donc changer facilement le decallage sur Z. ------------
		
		m_etape_aActualiser		=	0,

		
		NBR_FACES_ALERT_display	=	10000,
		NBR_FACES_ALERT_rendu		=	100000,
		
	------------ Fonctions	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		
		----------------- Ecouteurs	----------------------
		fn activer_pre_post_rendu =(
			
			---- PRERENDU	-----------
			callbacks.removescripts 	id:	#urbaTerrain_preRenderProxy
			callbacks.removescripts 	id:#urbaTerrain_postRenderProxy
			gc()
			
			global terrains_asProxy =#()
			local		txt_pre ="with redraw off (\n"
			-- 			txt_pre +="			format \"Ecouteur PRE rendu\\n\"\n"
						txt_pre +="	for terrain in objects where classof terrain == Urba_Terrain do (\n"
						txt_pre +="		if 	terrain.grille_proxy_use  do (\n"
						txt_pre +="			terrain.grille_proxy_use = false\n"
						txt_pre +="			terrain.core.actualiser etape:2\n"
						txt_pre +="			append	terrains_asProxy		terrain\n"
						txt_pre +="	)	\n	)	\n )	\n	"
			callbacks.addscript 	#preRender 	txt_pre 		id:#urbaTerrain_preRenderProxy



			---- post rendu	-----------
			local		txt_post ="	for terrain in terrains_asProxy do (\n"
					txt_post +="			terrain.grille_proxy_use = true\n"
					txt_post +="			terrain.core.actualiser  etape:2\n"
					txt_post +="		)\n"
			callbacks.addscript 	#postRender 	txt_post 		id:#urbaTerrain_postRenderProxy


		),
		fn activer_ecouteurs 	=	if TERRAIN_ECOUTEUR == undefined do (
			
			
			--  NODEEVENTCALLBACK--------
			---   deformation geometrie des objets en reference ------------------
			fn fct_ecouteur_terrain_topo		 ev nds = undo off	(
-- 				format "	###	EVT:	fct_ecouteur_terrain_topo\n"
				
				with redraw off (
					
					--- les terrain de la scene ---------
					local terrains = for obj in geometry where classof obj.baseObject == Urba_terrain collect  obj
					for nd_id in nds do (
						local nd = GetAnimByHandle nd_id
						case superclassof  nd of (
							shape:			(
								for terrain_nd in  terrains do
									if terrain_nd.aCommeContour  nd do (
										terrain_nd.core.set_etape_aActualiser 1
										terrain_nd.actualiser ()
									)
							)
							geometryClass: (
								for terrain_nd in  terrains do
									if terrain_nd.aCommeRelief  nd do ((
										terrain_nd.core.set_etape_aActualiser	3
										terrain_nd.actualiser ()
									)
								)
							)
						) --- fin case ---------
					)
				)
				redrawviews ()
			)---- fin 	fct_ecouteur_terrain
			
			fn fct_ecouteur_terrain_transf		 ev nds = undo off	(
-- 				format "	###	EVT:	fct_ecouteur_terrain_transf\n"
				
				local terrains = for obj in geometry where classof obj.baseObject == Urba_terrain collect  obj
				for nd_id in nds do (
					local nd = GetAnimByHandle nd_id
					case superclassof  nd of (
						shape:			(
							for terrain_nd in  terrains do
								if terrain_nd.aCommeContour  nd do  with redraw off (
									terrain_nd.core.set_etape_aActualiser 1
									terrain_nd.actualiser ()
								)
						)
						geometryClass: (
							for terrain_nd in  terrains do
								if terrain_nd.aCommeRelief  nd do   with redraw off (
									terrain_nd.core.set_etape_aActualiser 3
									terrain_nd.actualiser ()
								)
							
							if classof nd.baseObject == Urba_terrain do with redraw off (
								
								nd.set_transform 	nd.transform
								
								if nd.rotation 	!= (quat 0 0 0 1)	do
									nd.rotation 	= (quat 0 0 0 1)
								if nd.scale 		!= [1,1,1]	do
									nd.scale 		= [1,1,1]
								
								nd.core.set_etape_aActualiser 4
								nd.actualiser () 
								
							)
						)
					) --- fin case ---------
				)
			)---- fin 	fct_ecouteur_terrain
			
			fn fct_ecouteur_terrain_deleted		 ev nds = undo off	(
				local terrains = for obj in geometry where classof obj.baseObject == Urba_terrain collect  obj
				for terrain_nd in  terrains do (
					local aActualiser = false
					for contour_node in terrain_nd.contours_nodes do (
						if isDeleted contour_node or contour_node == Undefined do (
							terrain_nd.core.set_etape_aActualiser 1
							aActualiser = true
						)
					)
					
					if not aActualiser do
						for relief_node in terrain_nd.reliefs_nodes do (
							if isDeleted relief_node  or relief_node == Undefined do (
								
								terrain_nd.core.set_etape_aActualiser 3
								aActualiser = true
							)
						)
					
					if aActualiser do (
-- 				format "	###	EVT	----> a actualiser !!\n"
						terrain_nd.actualiser ()
						
					)
				)
			)---- fin 	fct_ecouteur_terrain
			
			
			TERRAIN_ECOUTEUR_deleted	= undefined
			TERRAIN_ECOUTEUR_topo 		= undefined
			TERRAIN_ECOUTEUR_transf 	= undefined
			gc light:true
		
			TERRAIN_ECOUTEUR_deleted	= NodeEventCallback 	mouseup:true 												\
																					deleted:						fct_ecouteur_terrain_deleted
			
			TERRAIN_ECOUTEUR_topo		= NodeEventCallback 	mouseup:true 														\
																					geometryChanged:		fct_ecouteur_terrain_topo		\
																					topologyChanged:		fct_ecouteur_terrain_topo		
			
			TERRAIN_ECOUTEUR_transf 	= NodeEventCallback	mouseup:true 														\
																					controllerOtherEvent:	fct_ecouteur_terrain_transf		
			
			
			
			
			
			activer_pre_post_rendu ()
		),
		
		
		
		----- accessions -----------------------------
		fn get_BB_contour 	=(
-- 			debug "get_BB_contour"
			
			local result = #([0,0,0],[0,0,0])
			
-- 			local pts_contour = deepCopy m_pts_contours	---	get_contour_pts ()
			
			--- on replace dans 
			local minX = minY 	= minZ =1e10
			local maxX = maxY 	= maxZ = -1e10
			
			for shp_node in m_plug.contours_nodes do (
				
				for id_spline in 1 to numSplines shp_node do (
					
					
					for id_pt in 1 to numKnots shp_node	id_spline	do (
						
						local pt = getKnotPoint	shp_node	id_spline		id_pt
						
						pt *= m_plug.transformation
						
						if pt.x < minX 		do minX = pt.x 
						if pt.y < minY 	do minY = pt.y
						if pt.z < minZ 		do minZ = pt.z 
						if pt.x > maxX 	do maxX = pt.x 
						if pt.y > maxY 	do maxY = pt.y 
						if pt.z > maxZ 	do maxZ = pt.z 
					)
				)
			)
-- 			debug "get_BB_contour ?!?"
			result = #([minX,minY,minZ],[maxX,maxY,maxZ])
-- 				
-- 			debug "result ?!?" var:result
			result
		),
		fn get_largeur_grille 	 estim:false	=(
			if m_plug.grille_proxy_use and not estim	then		m_plug.grille_proxy_resolution
			else if m_plug.grille_monde_use				then 	m_plug.grille_monde_resolution	
																	else	 	m_plug.grille_resolution
		),
		fn get_aire_terrain =(
			local aire_terrain = 0
			for pts_shp in	m_pts_faces do
				aire_terrain += mgr_shapes.get_aire_shape		pts_shp
			aire_terrain
		),
		
		
		----------- geometrie	( à glisser dans la structure geometrie !!! ! ! ! ! ! ! !  )---------------------------------------------------
		fn projectionZ	 pt 	_node_cible	=(
			local result = 	 copy		pt
			if _node_cible != undefined do (
				local pos_ray	=	[pt.x, pt.y, 1e+5	] --* m_plug.transformation
				local rayon =  intersectRay 	_node_cible	(ray 	pos_ray	 [0,0,-1] )
				if rayon != undefined do 
					result.z = rayon.pos.z
			)
			result
		),
		fn projeter_sur_reliefs	_pts	=(
-- 			debug"projeter_sur_reliefs"
			local pts_result = deepCopy _pts
			for i = 1 to pts_result.count do (
				local pt = pts_result[i]
				pt.z = 0
				local maxZ = -1e+10
				for relief in m_plug.reliefs_nodes where relief != undefined and not isdeleted relief do (
					local pt_proj = projectionZ 	pt		relief
					if pt_proj.z > maxZ do (
						maxZ = pt_proj.z 
						pts_result[i].z = maxZ
					)
				)
				
			)
-- 			debug"		------> pts_result !!" var:pts_result
			pts_result
		),
		fn quadriller_geometrie_base  	rendu:false	 = (
			
-- 			debug "quadriller_geometrie_base"
			
			
			local mtrx_node					=	copy	m_plug.transformation
			local mtrx_node_orient			=	copy mtrx_node
			mtrx_node_orient.translation	=	[0,0,0]
			
			--- BB ---
			local BB 			= get_BB_contour ()
			local pt_origine 	= BB[1] 
			local p_largeur 	= 	get_largeur_grille	()
			local decallage_grille	 		=  if m_plug.grille_monde_use	then m_plug.grille_monde_position	else	 m_plug.grille_position
			local vec_decallage_grille		= [0,0,0]
			vec_decallage_grille.x			= 	mod decallage_grille.x	p_largeur 
			vec_decallage_grille.y			= 	mod decallage_grille.y	p_largeur 
			
			local plane_normal 			= Point3 1 0 0
			local plane_center_abs 	= 	( (copy  pt_origine )  ) 	*  inverse	mtrx_node
			plane_center_abs.x 			= ( floor ( plane_center_abs.x / p_largeur ) ) * p_largeur 
			plane_center_abs.y 			= ( floor ( plane_center_abs.y / p_largeur ) ) * p_largeur 
			plane_center_abs 			+= vec_decallage_grille
			
			---- sur X ----------------------------------------------------------------------------------------
			local plane_normal 	=  (	( Point3 1 0 0 ) 	*  inverse	mtrx_node_orient )
			local plane_center 	=	copy  plane_center_abs
			local vec_X			=	p_largeur * plane_normal	
			local nbr_slice_X		=	floor ( ( BB[2] - BB[1] ).x	/	 p_largeur ) + 1
			
			for i in 1 to nbr_slice_X do (
				
				local faces = #{1..polyop.getNumFaces m_plug.delegate	}
				local rayon	=	ray plane_center	plane_normal
				polyop.slice m_plug.delegate	 faces 	rayon
				
				plane_center += vec_X
			)
			
			
			---- sur Y ----------------------------------------------------------------------------------------
			local plane_normal 	=  (	( Point3 0 1 0 ) 	*  inverse	mtrx_node_orient )
			local plane_center 	=	copy  plane_center_abs
			local vec_Y			=	p_largeur * plane_normal	
			local nbr_slice_Y		= floor ( ( BB[2] - BB[1] ).y	/	 p_largeur ) + 1
			
			for i in 1 to nbr_slice_Y do (
				local faces = #{1..polyop.getNumFaces m_plug.delegate	}
				local rayon	=	ray plane_center	plane_normal
				polyop.slice m_plug.delegate	 faces 	rayon		
				
-- 				mgr_geo.souder_tout  ()
				
				plane_center += vec_Y
			)
			
			
			
			
-- 			if m_plug.nettoyer_triangles do (
				--------  cleanner les edges  -------------------------------------------------
				local grille_segts			=	 polyop.getEdgeSelection m_plug.delegate
				local total_segts 		= #{1..polyop.getNumEdges m_plug.delegate}
				local bordure_segts		=	polyop.getOpenEdges m_plug.delegate 
				local invis_segts 			= total_segts - grille_segts - bordure_segts
				polyOp.setEdgeSelection m_plug.delegate invis_segts

				local ids_pts_invis			= 	polyop.getVertsUsingEdge 		m_plug.delegate 	invis_segts
				local ids_pts_bords			=	polyop.getVertsUsingEdge   	m_plug.delegate 	bordure_segts
				
				local ids_pts_aVirer 			= 	ids_pts_invis - ids_pts_bords
				

				polyOp.setVertSelection m_plug.delegate ids_pts_aVirer
				m_plug.delegate.remove selLevel:#edge
				m_plug.delegate.remove selLevel:#vertex
-- 			)
			polyop.retriangulate m_plug.delegate	#{1..polyop.getNumFaces m_plug.delegate	}
 
		), -- fin fonctoin
		
		
		
		
		
		
		
		
		
	---------  Actualisations de l'objet ----------------------------------------------
		fn actualiser_noeuds_boolleens 		=(

			m_ndRoot_contour			=		mgr_shapes.creer_noeud_hierarchie 	nom:"root"	
			
			if m_plug.contours_nodes.count > 0 do (
				
				for 	i = 1 to	m_plug.contours_nodes.count  where m_plug.contours_nodes[ i ] != undefined and not isdeleted m_plug.contours_nodes[ i ] do (
					local contour_node 	= 	m_plug.contours_nodes[i]
					local nds_contours 	=	mgr_shapes.get_noeuds_from_shape			contour_node		
					for nd_contour in nds_contours do (
						
						debug "---------------------------------------------------------------------------------------"
						debug (  "integration nd_contour	" + i as string )
						debug "---------------------------------------------------------------------------------------"
						mgr_shapes.integrer_nd_dans_hierarchie		m_ndRoot_contour		nd_contour 		m_plug.contours_operations[i]	
						debug "---------------------------------------------------------------------------------------"
						mgr_shapes.format_noeud		m_ndRoot_contour
						debug "---------------------------------------------------------------------------------------"
					)
				)
			)
			debug "--------> m_ndRoot_contour	" var:m_ndRoot_contour
			debug "--------> m_ndRoot_contour.enfants	" var:m_ndRoot_contour.enfants	param:#nom
			
			
		),
		
		fn actualiser_pts_faces =(
-- 			debug "	(1-2)	actualiser_pts_faces"
			
			
			
			
			
			m_pts_faces = mgr_shapes.get_pts_from_hierachie		m_ndRoot_contour
			
			debug "--------> m_pts_faces	" var:m_pts_faces
			/* ----- DEBUG-------------------
			sp = splineShape name:(Uniquename "m_pts_faces ")
			for j in 1 to m_pts_faces.count do (
				addnewSpline sp

				for pt in m_pts_faces[j] do		addknot sp j #corner #curve  pt
				close sp j
				updateShape sp
-- 				selectMore sp
			)
			----- DEBUG------------------- */
			
			
-- 			debug "	---->		m_pts_faces" var:m_pts_faces
		),
		
		fn creer_geometrie_base = (
-- 			debug "	(2-1)	creer_geometrie_base"

			--- version faces ---------------
			for pts_shp in m_pts_faces do	mgr_geo.face	pts_shp smGrp:1
-- 			
-- 			--- version triangles ---------------
-- 			local triangles =#()
-- 			for pts_shp in m_pts_faces do	
-- 				triangles += mgr_shapes.trianguler 	pts_shp
-- 			for pts_tri in triangles do	mgr_geo.face	pts_tri 		smGrp:1
			
			/* ----- DEBUG-------------------
			sp = splineShape name:(Uniquename "triangles ")
			for j in 1 to triangles.count do (
				addnewSpline sp

				for pt in triangles[j] do		addknot sp j #corner #curve  pt
				close sp j
				updateShape sp
-- 				selectMore sp
			)
			----- DEBUG------------------- */

			
			mgr_geo.souder_tout ()
			
		),
		
		fn actualiser_pts_quadrillages =(
-- 			debug "	(2-2)	actualiser_pts_quadrillages"
			if m_plug.grille_use	do	quadriller_geometrie_base ()
			m_pts_quadrillages = for i in 1 to polyop.getNumVerts  m_plug.delegate	collect	polyop.getVert  m_plug.delegate		i
		),
		
		fn actualiser_pts_projections =(
-- 			debug "	(3)		actualiser_pts_projections"
			m_pts_projections  = projeter_sur_reliefs		m_pts_quadrillages
		),
		
		fn realigner_auShapes	=(
-- 			debug "	(4)		realigner_auShapes"
			m_pts_aligner_auShapes = 	for i in 1 to m_pts_projections.count collect 	m_pts_projections[i] * inverse	m_plug.transformation
		),
		
		fn actualiser_pts_decallageZ =(		
-- 			debug "	(5-1)	actualiser_pts_decallageZ"	
			m_pts_decallageZ	=	deepcopy m_pts_aligner_auShapes			
			m_pts_decallageZ.z += m_plug.hauteur
		),
		
		fn placer_pts_geometrie	=(
-- 			debug "	(5-2)	placer_pts_geometrie"	
			
			---- on bouge les vertex-----------
-- 			debug "---- on bouge les vertex-----------"
			local ids_pts_total = #{1..polyop.getNumVerts m_plug.delegate}
			local pos_pts_final = deepcopy	m_pts_decallageZ
-- 			debug "	---->	ids_pts_total" var:ids_pts_total
-- 			debug "	---->	pos_pts_final" var:pos_pts_final
			
			polyop.setVert m_plug.delegate	ids_pts_total 	pos_pts_final			
			polyop.retriangulate	m_plug.delegate #{1..polyop.getNumFaces m_plug.delegate}
		),
		
	----------------------------- INTERFACE --------------------------------------
	public
		
		
		fn estimer_nbre_FacesFinal 	resol:	=(
			if resol == unsupplied do resol = get_largeur_grille	estim:true
			
			--- l'aire du BB total ------------
			local BB			 			= 	get_BB_contour ()
			local largeur_BB			=	( BB[2].x - BB[1].x )
			local longueur_BB		=	( BB[2].y - BB[1].y ) 
			local aire_BB				=	largeur_BB * longueur_BB
			
-- 			debug "aire_BB" var:aire_BB
			---  le nombre de cases dans le BB total ------------
			local lgr_grille 			= resol
			local nbre_cases_BB_x	=	( floor ( largeur_BB / lgr_grille ) ) 	+	1	--* lgr_grille 	
			local nbre_cases_BB_y	=	( floor ( longueur_BB / lgr_grille ) ) +	1	--* lgr_grille			
			local nbre_cases_BB	=	nbre_cases_BB_x	*	nbre_cases_BB_y
-- 			debug "nbre_cases_BB_x" var:nbre_cases_BB_x
-- 			debug "nbre_cases_BB_y" var:nbre_cases_BB_y
-- 			debug "nbre_cases_BB" var:nbre_cases_BB
			
-- 			--- la surface reel (2D)	de notre terrain ----
			local aire_terrain			=	get_aire_terrain ()
-- 			
-- 			debug "aire_terrain" var:aire_terrain
-- 			debug "aire_terrain" var:aire_terrain
-- 			--- on fait le ratio de tout ça	-----------
-- 			local correctif_estimation	=	1.2
			local estimation 				= 	integer ( nbre_cases_BB / aire_BB *  aire_terrain ) -- * correctif_estimation
-- 			local estimation 			= nbre_cases_BB	--		integer ( nbre_cases_BB / aire_BB *  aire_terrain )
			
			estimation
			
		),
		
		fn check_estimation_faces 	resol:		=(
			
			local result 								= true
			local nbr_estim_faces					=	estimer_nbre_FacesFinal		resol:resol
			
			---- alert	pour passer en proxy -----------
			if nbr_estim_faces >	NBR_FACES_ALERT_display and not m_plug.grille_proxy_use do (
				local query = yesNoCancelBox	( "Attention, nombre de vertex élevé: " + nbr_estim_faces as string + "\n\nPasser en Proxy ?" )
				case query of (
					#yes: 		m_plug.grille_proxy_use = true
					#cancel:	result = false
				)
			)
			if nbr_estim_faces >	NBR_FACES_ALERT_rendu do (
				local query =yesNoCancelBox	( "Attention, nombre de vertex élevé \n\nNombre de vertex Alerte: " + NBR_FACES_ALERT_rendu as string + "\nNombre de vertex estimés: " + nbr_estim_faces as string  + "\n\nContinuer et augmenter la limite de l'alerte?")
				case query of (
					#yes: 		NBR_FACES_ALERT_rendu = nbr_estim_faces
					#cancel:	result = false
				)
			)
--  				result = queryBox	"Attention, le nombre de vertex résultant est élevé. (" + nbr_estim_faces as string + " faces est.)\n Voulez-vous voulez-vous continuer ?"
			
			result
		),
		
		
		fn set_etape_aActualiser	val	= (
-- 			debug "set_etape_aActualiser"
-- 			debug "val" var:val
			if val < m_etape_aActualiser  or m_etape_aActualiser == 0 do m_etape_aActualiser = val
-- 			debug "m_etape_aActualiser" var:m_etape_aActualiser
		),
		
		fn actualiser 	etape:m_etape_aActualiser	=(
			debug "actualiser"
			
-- 			debug "	---->	etape_aActualiser" var:m_etape_aActualiser
			
			---- si on a pas de shape,  on dessine le logo -----------
			if m_plug.contours_nodes.count == 0 then (
-- 				debug "--- creation du logo ----"
				
				--- on vide la géométrie	-------------------
				mgr_geo.vider ()
				
				--- creation du logo ----
				mgr_geo.face	m_logo
				
			---- soit on dessine le terrain -----------------------
			) else (
				
-- 				debug "--- creation du terrain ----"
				
				---- On actualise seulement le necéssaire -----------------------------------------------
-- 				local etape = 
				
				local affichage_tpsVide = "-"
				local chrono_debut = timeStamp ()
				---- analyse des contours	-------------------
			
				local chrono_1		=	affichage_tpsVide
				local chrono_1_1		=	affichage_tpsVide
				local chrono_1_2		=	affichage_tpsVide
				
				
				--- on verifie si on doit changer l'etape ---------------------------
				if 	m_noeuds_contours == undefined or m_noeuds_contours.enfants.count > 0 or m_pts_faces.count == 0 or m_pts_quadrillages.count == 0 do
					etape = 1
		
		
				----------- ( 1 ) les points de la geometrie de base ----------------
				if etape <= 1 do (
					local chrono_temp = timeStamp ()
					local chrono_temp_2 = timeStamp ()
					------ 	(1-1)	creer les pts contours de base -----------------------
					actualiser_noeuds_boolleens ()
					chrono_1_1 = (  ((timeStamp ()) - chrono_temp ) / 1000.0)
					local chrono_temp = timeStamp ()
					------	(1-2)	et creer les points des faces de base -------------------
					actualiser_pts_faces	()
					chrono_1_2 = (  ((timeStamp ()) - chrono_temp ) / 1000.0)
					chrono_1 = (  ((timeStamp ()) - chrono_temp_2 ) / 1000.0)
				)
				
				
				------	(2)	creer le quadrillage  ----------------------------------
				local chrono_2_1 =affichage_tpsVide
				local chrono_2_2 =affichage_tpsVide
				if etape <= 2 do (
					local chrono_temp = timeStamp ()
					--- on vide la géométrie	-------------------
					mgr_geo.vider ()
					
					------	(1-3)	pour enfin créer les faces de la géometrie de base. -------------------
					creer_geometrie_base ()
					
					chrono_2_1	=	(  ((timeStamp ()) - chrono_temp ) / 1000.0)					
					local chrono_temp = timeStamp ()
					
					actualiser_pts_quadrillages ()
					
					chrono_2_2	=	(  ((timeStamp ()) - chrono_temp ) / 1000.0)
				)
				
-- 				etape = 10
				------	(3)	creer la projection  -----------------------------------
				local chrono_3 =affichage_tpsVide
				if etape <= 3 do (
					local chrono_temp = timeStamp ()
					actualiser_pts_projections ()
					chrono_3 = (  ((timeStamp ()) - chrono_temp ) / 1000.0)	
				)
				
				
				local chrono_temp = timeStamp ()
				------	(4)	on se recalle sur les shapes  --------------------------
				if etape <= 4 do (
					realigner_auShapes ()
				)
				
				------	(5)	appliquer le decallage sur Z  --------------------------
				if etape <= 5 do (
					actualiser_pts_decallageZ ()
-- 					
					placer_pts_geometrie ()
				)
				
				
				local debug_detail = true
				if debug_detail do (
					debug ("----------------------------------------------------------------------------------------" )
					debug ("---	(1)			Analyse des contours : 					" +  chrono_1	as string  )
					debug ("---	(1)			*	actualiser_noeuds_boolleens : 			" +  chrono_1_1	as string  )
					debug ("---	(1)			*	actualiser_pts_faces : 				" +  chrono_1_2	as string  )
					debug ("---	(2-1)		Construction de la géometrie de base : 	" +  chrono_2_1	as string  )
					debug ("---	(2-2)		Quadrillage : 							" +  chrono_2_2	as string  )
					debug ("---	(3)			Projection sur les reliefs : 			" +  chrono_3	as string  )
					debug ("---	(4 et 5)	Actualiser la position des points : 	" +  (  ((timeStamp ()) - chrono_temp ) / 1000.0)	as string  )				
					debug ("-------------------------------------------------------------------" )
				)
				debug ("---				TERRAIN construit en : 					" +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string   + " s." )
				
				if debug_detail do (						
					debug ("---				Faces: 	" +  (  polyop.getNumFaces m_plug.delegate )	as string   + " 		(estimées: " + (  estimer_nbre_FacesFinal () )	as string + ")" )
					debug ("---				Vertex: " +  (  polyop.getNumVerts m_plug.delegate )	as string  )
-- 					format "\n"
-- 					debug ("---				Faces (estimées): 	" + (  estimer_nbre_FacesFinal () )	as string  )
					debug ("-------------------------------------------------------------------" )		
				)
				displayTempPrompt ("Terrain construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + " s." ) 30000
			 
			)
			
			m_etape_aActualiser = 0
			
		),
		
		fn initialiser		_plug =(
			
			---- les pointeurs --------
			m_plug				=	_plug
			m_core				=	m_plug.core
			mgr_geo.m_plug 	= m_plug
			
			
			activer_ecouteurs ()
			
		)
	
)




















