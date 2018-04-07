


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
		mgr_geo				= 	str_geometrie 		(),
		mgr_shapes		= 	str_terrain_outils_shape (),
		mgr_datas			=	str_datasToString (),
		
	----- les points stockés pour manip -----
		m_pts_contours	 		=	#(),		---- les listes de points issues des points des splines contours, cleannés et dans le bon sens. ------------
-- 		m_noeuds_booleens		=	#(),		---- la hierarchie booleenne de tout nos contours. ------------
		m_pts_faces				=	#(),		---- les listes de points des faces de base. ------------
		m_pts_quadrillages		=	#(),		---- les positions des points des faces une fois les quadrillage fait et cleanné .------------
		m_pts_aligner_auShapes	=	#(),		----.------------
		m_pts_decallageZ	=	#(),		----.------------
		
		m_pts_projections		=	#(),		---- les positions des points des faces une fois la projection faite, on peut donc changer facilement le decallage sur Z. ------------
		
		m_etape_aActualiser	=	0,

		
	------------ Fonctions	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		fn get_BB_contour 	=(
-- 			debug "get_BB_contour"
			
			local result = #([0,0,0],[0,0,0])
			
			local pts_contour = deepCopy m_pts_contours	---	get_contour_pts ()
			
			--- on replace dans 
			local minX = minY 	= minZ =1e10
			local maxX = maxY 	= maxZ = -1e10
			
			for pts_face in pts_contour do 
				for pt in pts_face do (
					
					pt *= m_plug.transformation
					
					if pt.x < minX 		do minX = pt.x 
					if pt.y < minY 	do minY = pt.y
					if pt.z < minZ 		do minZ = pt.z 
					if pt.x > maxX 	do maxX = pt.x 
					if pt.y > maxY 	do maxY = pt.y 
					if pt.z > maxZ 	do maxZ = pt.z 
				)
			
-- 			debug "get_BB_contour ?!?"
			result = #([minX,minY,minZ],[maxX,maxY,maxZ])
-- 				
			debug "result ?!?" var:result
			result
		),
		
		
		----------- geometrie	( à glisser dans la structure geometrie !!! ! ! ! ! ! ! !  )---------------------------------------------------
		fn projectionZ	 pt 	_node_cible	=(
			local result = 	 pt
			if _node_cible != undefined do (
				local rayon =  intersectRay 	_node_cible	 	(ray 	( [pt.x, pt.y, -1e+7] * m_plug.transformation )	 [0,0,-1] )
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
				for relief in m_plug.reliefs_nodes do (
					pt_proj = projectionZ 	pt		relief
					if pt_proj.z > maxZ do (
-- 				debug"	------> projection !!"
						maxZ = pt_proj.z
						pts_result[i].z = maxZ	- m_plug.transformation.translation.z	
-- 				debug"	------> pts_result[i].z !!" var:pts_result[i].z
					)
				)
				
			)
-- 			debug"		------> pts_result !!" var:pts_result
			pts_result
		),
		fn quadriller_geometrie_base  		 = (
			
			debug "quadriller_geometrie_base"
			
			local offset = [ -20,-20,0 ]
			
			--- BB ---
			local BB 			= get_BB_contour ()
			local pt_origine 	= BB[1] 
			local p_largeur 	= if m_plug.grille_monde_use	then m_plug.grille_monde_resolution	else	 m_plug.grille_resolution
			
			debug "quadriller_geometrie_base ?!?!?!?"
			
			local plane_normal 			= Point3 1 0 0
			local plane_center_abs 	= copy pt_origine --+ _node.pos
			plane_center_abs.x 			= ( floor ( plane_center_abs.x / p_largeur ) ) * p_largeur 
			plane_center_abs.y 			= ( floor ( plane_center_abs.y / p_largeur ) ) * p_largeur 
			
			debug "m_plug.transformation " --var:m_plug.transformation 
			
			local mtrx_node			=	copy	m_plug.transformation
			local mtrx_node_orient	=	copy mtrx_node
			mtrx_node_orient.translation	=	[0,0,0]
			
			---- sur X ----------------------------------------------------------------------------------------
			local plane_normal 	= /* normalize */ (	( Point3 1 0 0 ) 	*  inverse	mtrx_node_orient )
			local plane_center 	=	( copy  plane_center_abs	) 	*  inverse	mtrx_node
			local vec_X			=	p_largeur * plane_normal	
			local nbr_slice_X		= floor ( ( BB[2] - BB[1] ).x	/	 p_largeur ) + 1
			
			for i in 1 to nbr_slice_X do (
				local faces = #{1..polyop.getNumFaces m_plug.delegate	}
				local rayon	=	ray plane_center	plane_normal
				polyop.slice m_plug.delegate	 faces 	rayon
				
				plane_center += vec_X
			)
			
			
			---- sur Y ----------------------------------------------------------------------------------------
			local plane_normal 	= /* normalize */ (	( Point3 0 1 0 ) 	*  inverse	mtrx_node_orient )
			local plane_center 	=	( copy  plane_center_abs	) 	*  inverse	mtrx_node
			local vec_Y			=	p_largeur * plane_normal	
			local nbr_slice_Y		= floor ( ( BB[2] - BB[1] ).y	/	 p_largeur ) + 1
			
			for i in 1 to nbr_slice_Y do (
				local faces = #{1..polyop.getNumFaces m_plug.delegate	}
				local rayon	=	ray plane_center	plane_normal
				polyop.slice m_plug.delegate	 faces 	rayon		
				
-- 				mgr_geo.souder_tout  ()
				
				plane_center += vec_Y
			)
			
			
			
			
			
			--------  cleanner les edges  -------------------------------------------------
			local grille_segts			=	 polyop.getEdgeSelection m_plug.delegate
			local total_segts 		= #{1..polyop.getNumEdges m_plug.delegate}
			local bordure_segts		=	polyop.getOpenEdges m_plug.delegate 
			local invis_segts 			= total_segts - grille_segts - bordure_segts
			polyOp.setEdgeSelection m_plug.delegate invis_segts

			ids_pts_aVirer 			= polyop.getVertsUsingEdge m_plug.delegate invis_segts
			for	id_pt_aVirer in 	ids_pts_aVirer do (				
				local sgts_duPoint = polyop.getEdgesUsingVert    m_plug.delegate 	id_pt_aVirer
				for id_sgt_duPoint in sgts_duPoint do 
					if bordure_segts[ id_sgt_duPoint ] do 
						ids_pts_aVirer[ id_pt_aVirer ] = false
			)

			polyOp.setVertSelection m_plug.delegate ids_pts_aVirer
			m_plug.delegate.remove selLevel:#edge
			m_plug.delegate.remove selLevel:#vertex
 
-- 			polyop.retriangulate m_plug.delegate	#{1..polyop.getNumFaces m_plug.delegate	}
 
		), -- fin fonctoin
	
		
		
		
		
		----------------- Ecouteurs	----------------------
		fn activer_ecouteur 	=	if TERRAIN_ECOUTEUR == undefined do (
			
			
			--  NODEEVENTCALLBACK--------
			---   deformation geometrie des objets en reference ------------------
			fn fct_ecouteur_terrain_topo		 ev nds = (
				
				/* undo off  */with redraw off (
					
						--- les terrain de la scene ---------
						local terrains = for obj in geometry where classof obj.baseObject == Urba_terrain collect  obj
						for nd_id in nds do (
							local nd = GetAnimByHandle nd_id
							case superclassof  nd of (
								shape:			(
									for terrain_nd in  terrains do
										if terrain_nd.aCommeContour  nd do 
											terrain_nd.actualiser_contours ()
								)
								geometryClass: (
									for terrain_nd in  terrains do
										if terrain_nd.aCommeRelief  nd do 
											terrain_nd.actualiser_reliefs ()
								)
							) --- fin case ---------
						)
				)
				redrawviews ()
			)---- fin 	fct_ecouteur_terrain
			
			fn fct_ecouteur_terrain_transf		 ev nds = (
				
				
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
								if terrain_nd.aCommeRelief  nd do  (
									terrain_nd.core.set_etape_aActualiser 3
									terrain_nd.actualiser ()
								)
							
							if classof nd.baseObject == Urba_terrain do (
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
			
			
			
			TERRAIN_ECOUTEUR_topo 		= undefined
			TERRAIN_ECOUTEUR_transf 	= undefined
			gc light:true
		
			TERRAIN_ECOUTEUR_topo		= NodeEventCallback 	mouseup:true 														\
																					geometryChanged:		fct_ecouteur_terrain_topo		\
																					topologyChanged:		fct_ecouteur_terrain_topo		
			
			TERRAIN_ECOUTEUR_transf 	= NodeEventCallback	mouseup:true 														\
																					controllerOtherEvent:	fct_ecouteur_terrain_transf		
		),
		
		
		
		
		
		
		
		
	
		fn actualiser_pts_contours 		=(
			---- maj des points -------------
			m_pts_contours =#()			
			if m_plug.contours_nodes.count > 0 do 
				for 	contour_node in m_plug.contours_nodes do
					m_pts_contours	+= 	( mgr_shapes.interpoler_pts_from_shape		contour_node  )
		),
		
		fn actualiser_pts_faces =
			m_pts_faces = mgr_shapes.creer_hierarchie_booleens	m_pts_contours,
		
		fn creer_geometrie_base = (
			for pts_shp in m_pts_faces do	mgr_geo.face	pts_shp smGrp:1
			mgr_geo.souder_tout()
		),
		
		fn actualiser_pts_quadrillages =(
			quadriller_geometrie_base ()
			m_pts_quadrillages = for i in 1 to polyop.getNumVerts  m_plug.delegate	collect	polyop.getVert  m_plug.delegate		i
		),
		
		fn actualiser_pts_projections =
			m_pts_projections  = projeter_sur_reliefs		m_pts_quadrillages,
		
		fn realigner_auShapes	=
			m_pts_aligner_auShapes = 	for i in 1 to m_pts_projections.count collect 	m_pts_projections[i] * inverse	m_plug.transformation,
		
		fn actualiser_pts_decallageZ =(			
			m_pts_decallageZ	=	deepcopy m_pts_aligner_auShapes			
			m_pts_decallageZ.z += m_plug.hauteur
		),
		
		fn bouger_geometries	=(
			
			---- on bouge les vertex-----------
-- 			debug "---- on bouge les vertex-----------"
			local ids_pts_total = #{1..polyop.getNumVerts m_plug.delegate}
			local pos_pts_final = deepcopy	m_pts_decallageZ
			debug "	---->	ids_pts_total" var:ids_pts_total
			debug "	---->	pos_pts_final" var:pos_pts_final
			
			polyop.setVert m_plug.delegate	ids_pts_total 	pos_pts_final			
			polyop.retriangulate	m_plug.delegate #{1..polyop.getNumFaces m_plug.delegate}
		),
		
	----------------------------- INTERFACE --------------------------------------
	public
		fn set_etape_aActualiser	val	= (
			debug "set_etape_aActualiser"
-- 			debug "val" var:val
			if val < m_etape_aActualiser  or m_etape_aActualiser == 0 do m_etape_aActualiser = val
			debug "m_etape_aActualiser" var:m_etape_aActualiser
		),
		
		
		fn actualiser =(
			debug "actualiser"
			
			
			---- si on a pas de shape,  on dessine le logo -----------
			if m_plug.contours_nodes.count == 0 then (
				debug "--- creation du logo ----"
				
				--- creation du logo ----
				mgr_geo.face	m_logo
				
			---- soit on dessine le terrain -----------------------
			) else (
				
				debug "--- creation du terrain ----"
				
				---- On actualise seulement le necéssaire -----------------------------------------------
				local etape = m_etape_aActualiser
				
				if etape <= 1 do (
					
					
					------ 	(1-1)	creer les pts contours de base -----------------------
					actualiser_pts_contours ()
					------	(1-2)	et creer les points des faces de base -------------------
					actualiser_pts_faces	()
					
				)
				
				------	(2)	creer le quadrillage  ----------------------------------
				if etape <= 2 do (
					--- on vide la géométrie	-------------------
					mgr_geo.vider ()
					------	(1-3)	pour enfin créer les faces de la géometrie de base. -------------------
					creer_geometrie_base ()
					actualiser_pts_quadrillages ()
				)
				
				------	(3)	creer la projection  -----------------------------------
				if etape <= 3 do (
					actualiser_pts_projections ()
				)
				
				------	(4)	on se recalle sur les shapes  --------------------------
				if etape <= 4 do (
					realigner_auShapes ()
				)
				
				------	(5)	appliquer le decallage sur Z  --------------------------
				if etape <= 5 do (
					actualiser_pts_decallageZ ()
					
					bouger_geometries ()
				)
			)
			
			m_etape_aActualiser = 0
		),
		
		 /*
		fn actualiser_contours 			=(
			
			local chrono_debut = timeStamp ()
			
			---- maj des points -------------
			m_contour_points =#()			
			if m_plug.contours_nodes.count > 0 do (
				for 	contour_node in m_plug.contours_nodes do
					m_contour_points	+= 	( mgr_shapes.get_points_from_shape		contour_node  	)
				
				
				---- on transforme nos points de contours en points pour création de face -------------
				m_contour_points = mgr_shapes.preparer_points_pour_geometrie		m_contour_points
				
				
				--- on annule la transformation de l'objet ----------------------
				for i  in 1 to  m_contour_points.count do
					for j in 1 to m_contour_points[i].count do 
						m_contour_points[i][j] *= inverse	m_plug.transformation
					
-- 				--- on enregistre les points sur le node pour pas avoir a recalucler a chaque fois	------------------
-- 				local datas_pts_contour =#()
-- 				for pts_spline_contour in m_contour_points do
-- 						append datas_pts_contour		( mgr_datas.toString	pts_spline_contour )	
-- 				m_plug.contour_pts	=	datas_pts_contour
				
				debug ("Terrain : Contours actualisé en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." )
			)
		),
		
		fn construire 	= undo off  (
			
			---- on vide ---------------
			mgr_geo.vider ()
			
			if m_contour_points.count == 0 do actualiser_contours ()
				
			
			if m_plug.contours_nodes.count > 0   do with redraw off (
			
				local chrono_debut = timeStamp ()
					
				debug "construire"
				
				--- on créé les faces  ------------
				for pts_spline_contour in m_contour_points do (
					local triangles = mgr_shapes.trianguler 	pts_spline_contour

					for pts_tri in triangles do 	mgr_geo.face pts_tri	smGrp:1
					
					mgr_geo.souder_tout  ()
					
				)
				
				
-- 				--------  cleanner les edges  ---------
-- 				local grille_segts	=	 polyop.getEdgeSelection m_plug.delegate
-- 				local total_segts = #{1..polyop.getNumEdges m_plug.delegate}
-- 				local invis_segts = total_segts - grille_segts			
-- 				polyOp.setEdgeSelection m_plug.delegate invis_segts
-- 				m_plug.delegate.remove selLevel:#edge
				
			
				
				
				local chrono_tmp= timeStamp ()
				--- on quadrille   ------------
				quadriller_geometrie_base ()
				debug ("Terrain : quadriller_geometrie_base en " +  (  ((timeStamp ()) - chrono_tmp ) / 1000.0)	as string + "s." )
				
				
				
				
				
				
				
				
				
				
				
				--- on projete -------------------
				local chrono_tmp= timeStamp ()
				projeter_sur_reliefs	()
				debug ("Terrain : projection en " +  (  ((timeStamp ()) - chrono_tmp ) / 1000.0)	as string + "s." )
				
				polyop.retriangulate m_plug.delegate	#{1..polyop.getNumFaces m_plug.delegate	}
				
				
				
-- 				--------  cleanner les edges  ---------
-- 				local grille_segts	=	 polyop.getEdgeSelection m_plug.delegate
-- 				local total_segts = #{1..polyop.getNumEdges m_plug.delegate}
-- 				local invis_segts = total_segts - grille_segts			
-- 				polyOp.setEdgeSelection m_plug.delegate invis_segts
-- 				m_plug.delegate.remove selLevel:#edge
-- 				
-- 				--- on clean les triangles	-------------
-- 				local chrono_tmp= timeStamp ()				
-- 				--------  cleanner les edges  ---------
-- 				local slice_segts	=	 polyop.getEdgeSelection  m_plug.delegate
-- 				local total_segts = #{1..polyop.getNumEdges m_plug.delegate}
-- 				local invis_segts = total_segts - slice_segts			
-- 				polyOp.setEdgeSelection m_plug.delegate invis_segts
-- 				m_plug.delegate.remove selLevel:#edge
-- 	-- 			polyop.retriangulate $ #{1..744}
-- 			
-- 				
-- 				debug ("Terrain : retriangulate en " +  (  ((timeStamp ()) - chrono_tmp ) / 1000.0)	as string + "s." )
				
				
				debug ("---> Terrain : Construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." )
			
				displayTempPrompt ("Terrain : Construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." ) 30000
				
			)
			
-- 				polyop.retriangulate $	#{1..polyop.getNumFaces $	}	
			
			redrawViews ()
			
		),
	
		 */
		
		fn initialiser		_plug =(
			
			---- les pointeurs --------
			m_plug				=	_plug
			m_core				=	m_plug.core
			mgr_geo.m_plug 	= m_plug
			
			
			activer_ecouteur ()
			
		)
	
)


