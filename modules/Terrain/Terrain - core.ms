


-- include	 "$userScripts\\cp-Urba\\modules\\Terrain\\Terrain - triangulation.ms" 
include	 "$userScripts\\cp-Urba\\modules\\Batiment\\divers\\Batiment - Geometrie.ms"
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - outils - shape.ms" 
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - Outils - booleen shape.ms" 



struct	str_terrain_node_core	(
		
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"urba | str_terrain_node_core"	  	var:var	 param:param		catch (),
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	
	
	private
		m_plug,
		m_core,
		
		----- le logo -----------
		m_logo = #(	[13765.1,-1907.73,0], [14840.2,-1907.73,0], [14840.2,-1837.5,0], [14738.9,-1837.5,0], [14598.5,-1590.46,0], [14478.1,-1802.27,0], 
							[14331.9,-1545.08,0], [14292.4,-1614.6,0], [14173.3,-1405.04,0], [13927.4,-1837.5,0], [13765.1,-1837.5,0]),
							

	---- managers  ------------------
		mgr_geo				= 	str_geometrie 		(),
		mgr_shapes		= 	str_terrain_outils_shape (),
		mgr_datas			=	str_datasToString (),
		
	----- les points stockés pour manip -----
		m_contour_points =#(),
		/* 
	---- ecouteurs ------------------
		m_ecouteur_terrain,
		m_ecouteur_terrain_topo,
		m_ecouteur_terrain_transfo,
		 */
	
	
	
	
	
	public
	
	
	
	
	/* 
	
		fn get_contour_pts	= (
			
			local 	result_pts		=	#()
			for datas_spline_contour in m_plug.contour_pts do
					append result_pts		( mgr_datas.toArray	 datas_spline_contour )
			
			result_pts
			
			
		),
		
		*/
		fn get_BB_contour 	=(
			local result #([0,0,0],[0,0,0])
			
			local pts_contour = deepCopy m_contour_points	---	get_contour_pts ()
			
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
			
			------ debug ---------------------------
-- 			try delete $min catch ()
-- 			try delete $max catch ()
-- 			point pos:[minX,minY,minZ] size:500 name:"min"
-- 			point pos:[maxX,maxY,maxZ] size:500 name:"max"
			------ debug ---------------------------
			
			
			
			#([minX,minY,minZ],[maxX,maxY,maxZ])
			
		),
		
		fn projectionZ	 pt 	_node_cible	=(
			local result = 	 pt
			if _node_cible != undefined do (
				local rayon =  intersectRay 	_node_cible	 	(ray 	( [pt.x, pt.y, -1e+7] * m_plug.transformation )	 [0,0,-1] )
				if rayon != undefined do 
					result.z = rayon.pos.z
			)
			result
		),

		fn projeter		=(
			
			local ids_pts_total = #{1.. polyop.getNumVerts m_plug.delegate	}
			local pts_total =#()
			for id_pt in  ids_pts_total do (
				local pt = ( polyop.getVert m_plug.delegate  id_pt )
				pt.z = 0
				local maxZ = -1e+10
				for relief in m_plug.reliefs_nodes do (
					pt_proj = projectionZ 	pt		relief
					if pt_proj.z > maxZ do (
						maxZ = pt_proj.z
						pt.z = maxZ	- m_plug.transformation.translation.z	
					)
				)
				pt.z = pt.z  + m_plug.decallageZ
				---- la position sur Z  ----------
				
				append pts_total pt
				
			)
			polyop.setVert m_plug.delegate	ids_pts_total 	pts_total
		),
		
		fn quadriller  		 = (
			
			debug "quadriller"
			
			local offset = [ -20,-20,0 ]
			
			
			--- BB ---
			local BB 			= get_BB_contour ()
			local pt_origine 	= BB[1] 	
			local p_largeur 	= m_plug.grille_largeur
			
			local plane_normal 			= Point3 1 0 0
			local plane_center_abs 	= copy pt_origine --+ _node.pos
			plane_center_abs.x 			= ( floor ( plane_center_abs.x / p_largeur ) ) * p_largeur 
			plane_center_abs.y 			= ( floor ( plane_center_abs.y / p_largeur ) ) * p_largeur 
			
			debug "m_plug.transformation " var:m_plug.transformation 
			
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
 
			polyop.retriangulate m_plug.delegate	#{1..polyop.getNumFaces m_plug.delegate	}

		), -- fin fonctoin
	
		
		fn appliquerMapping =(
			
			--- Mapping de maniere global, TODO:generer par  composants---
			local matrxMapping = matrix3 1 	--
-- 			local axeP_mtrx = m_plug.core.get_axePrincipal ()
-- 			rotateZ matrxMapping  (- (quatToEuler2  axeP_mtrx.rotationpart).z )
			polyop.applyUVWMap 	m_plug.delegate  #box	 tm:matrxMapping  channel:1
			
		),
		
		
		
		
		
		fn activer_ecouteur 	=	if TERRAIN_ECOUTEUR == undefined do (
			
			
			--  NODEEVENTCALLBACK--------
			---   deformation geometrie des objets en reference ------------------
			fn fct_ecouteur_terrain_topo		 ev nds = (
				
				/* undo off  */with redraw off (
					
						--- les terrain de la scene ---------
						local terrains = for obj in geometry where classof obj == Urba_terrain collect  obj
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
				
				
				local terrains = for obj in geometry where classof obj == Urba_terrain collect  obj
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
							
							if classof nd == Urba_terrain do (
								nd.set_transform 	nd.transform
								
								if nd.rotation 	!= (quat 0 0 0 1)	do
									nd.rotation 	= (quat 0 0 0 1)
								if nd.scale 		!= [1,1,1]	do
									nd.scale 		= [1,1,1]
								
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
		
		
		
		
		
		
		
		
		----------------------------- INTERFACE --------------------------------------
	public
		fn actualiser_contours 			=(
			
			local chrono_debut = timeStamp ()
			
			---- maj des points -------------
			m_contour_points =#()			
			if m_plug.contours_nodes.count > 0 do (
				for 	contour_node in m_plug.contours_nodes do
					m_contour_points	+= 	( mgr_shapes.get_points_from_shape		contour_node  /* transformation:m_plug.transformation */	)
				
				
				---- on transforme nos points de contours en points pour création de face -------------
				m_contour_points = mgr_shapes.preparer_points_pour_geometrie		m_contour_points
				
				
				--- on annule la transformation de l'objet ----------------------
				for i  in 1 to  m_contour_points.count do
					for j in 1 to m_contour_points[i].count do 
						m_contour_points[i][j] *= inverse	m_plug.transformation
					/* 
				--- on enregistre les points sur le node pour pas avoir a recalucler a chaque fois	------------------
				local datas_pts_contour =#()
				for pts_spline_contour in m_contour_points do
						append datas_pts_contour		( mgr_datas.toString	pts_spline_contour )	
				m_plug.contour_pts	=	datas_pts_contour
				 */
				debug ("Terrain : Contours actualisé en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." )
			)
		),
		
		fn construire 	= undo off  (
			
			---- on vide ---------------
			mgr_geo.vider ()
			
			if m_contour_points.count == 0 do actualiser_contours ()
				
			
			if /* m_plug.reliefs_nodes.count > 0  and  */m_plug.contours_nodes.count > 0   do with redraw off (
			
				local chrono_debut = timeStamp ()
				
				debug "construire"
				
				--- on créé les faces  ------------
				for pts_spline_contour in m_contour_points do (
					local triangles = mgr_shapes.trianguler 	pts_spline_contour

					for pts_tri in triangles do 	mgr_geo.face pts_tri	smGrp:1
					
					mgr_geo.souder_tout  ()
					
				)
				
				/* 
				--------  cleanner les edges  ---------
				local grille_segts	=	 polyop.getEdgeSelection m_plug.delegate
				local total_segts = #{1..polyop.getNumEdges m_plug.delegate}
				local invis_segts = total_segts - grille_segts			
				polyOp.setEdgeSelection m_plug.delegate invis_segts
				m_plug.delegate.remove selLevel:#edge
				
			
				 */
				
				local chrono_tmp= timeStamp ()
				--- on quadrille   ------------
				quadriller ()
				debug ("Terrain : quadriller en " +  (  ((timeStamp ()) - chrono_tmp ) / 1000.0)	as string + "s." )
				
				
				
				
				
				
				
				
				
				
				
				--- on projete -------------------
				local chrono_tmp= timeStamp ()
				projeter	()
				debug ("Terrain : projection en " +  (  ((timeStamp ()) - chrono_tmp ) / 1000.0)	as string + "s." )
				
				polyop.retriangulate m_plug.delegate	#{1..polyop.getNumFaces m_plug.delegate	}
				
				
				/* 
				--------  cleanner les edges  ---------
				local grille_segts	=	 polyop.getEdgeSelection m_plug.delegate
				local total_segts = #{1..polyop.getNumEdges m_plug.delegate}
				local invis_segts = total_segts - grille_segts			
				polyOp.setEdgeSelection m_plug.delegate invis_segts
				m_plug.delegate.remove selLevel:#edge
				
				--- on clean les triangles	-------------
				local chrono_tmp= timeStamp ()				
				--------  cleanner les edges  ---------
				local slice_segts	=	 polyop.getEdgeSelection  m_plug.delegate
				local total_segts = #{1..polyop.getNumEdges m_plug.delegate}
				local invis_segts = total_segts - slice_segts			
				polyOp.setEdgeSelection m_plug.delegate invis_segts
				m_plug.delegate.remove selLevel:#edge
	-- 			polyop.retriangulate $ #{1..744}
			
				
				debug ("Terrain : retriangulate en " +  (  ((timeStamp ()) - chrono_tmp ) / 1000.0)	as string + "s." )
				 */
				appliquerMapping ()
				
				debug ("---> Terrain : Construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." )
			
				displayTempPrompt ("Terrain : Construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." ) 30000
				
			)
			/* 
				polyop.retriangulate $	#{1..polyop.getNumFaces $	}	
			 */
			redrawViews ()
			
		),
	
		
		
		fn initialiser		_plug =(
			
			---- les pointeurs --------
			m_plug				=	_plug
			m_core				=	m_plug.core
			mgr_geo.m_plug 	= m_plug
			
			
			activer_ecouteur ()
			
		)
	
)


