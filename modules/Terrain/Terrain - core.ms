


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
		
		mgr_geo				= 	str_geometrie 		(),
-- 		mgr_trianguler 	= 	str_triangulation_shape (),
		mgr_shapes		= 	str_terrain_outils_shape (),
		mgr_datas			=	str_datasToString (),
		mgr_booleen		=	str_terrain_booleen (),
		
		m_contour_points =#(),
		
		m_ecouteur_terrain,
		
	
	
	
	
	
	public
	
	
	
	
	
	
		fn get_contour_pts	= (
			
			local 	result_pts		=	#()
			for datas_spline_contour in m_plug.contour_pts do
					append result_pts		( mgr_datas.toArray	 datas_spline_contour )
			
			result_pts
		),
		
		
		fn get_BB_contour 	=(
			local result #([0,0,0],[0,0,0])
			
			local pts_contour = get_contour_pts ()
			
			local minX = minY 	= minZ =1e10
			local maxX = maxY 	= maxZ = -1e10
			
			for pts_face in pts_contour do 
				for pt in pts_face do (
					if pt.x < minX 		do minX = pt.x 
					if pt.y < minY 	do minY = pt.y
					if pt.z < minZ 		do minZ = pt.z 
					if pt.x > maxX 	do maxX = pt.x 
					if pt.y > maxY 	do maxY = pt.y 
					if pt.z > maxZ 	do maxZ = pt.z 
				)
			
			#([minX,minY,minZ],[maxX,maxY,maxZ])
			
		),
		
		fn projectionZ	 pt 	_node_cible	=(
			local result = 	 pt
			if _node_cible != undefined do (
				local rayon =  intersectRay 	_node_cible	 	(ray 	[pt.x, pt.y, -1e+7]	 [0,0,-1] )
				if rayon != undefined do 
					result.z = rayon.pos.z
			)
			result
		),

		fn projeter		=(
			
			
			local ids_pts_total = #{1.. polyop.getNumVerts m_plug.delegate	}
			local pts_total =#()
			for id_pt in  ids_pts_total do (
				local pt = polyop.getVert m_plug.delegate  id_pt
				local maxZ = -1e+10
				for relief in m_plug.reliefs_nodes do (
					pt_proj = projectionZ 	pt		relief
					if pt_proj.z > maxZ do 
						maxZ = pt_proj.z
				)
				pt.z = maxZ + m_plug.decallageZ
				
				append pts_total pt
			)
			polyop.setVert m_plug.delegate	ids_pts_total 	pts_total
		),
		
		
		
		
		fn quadriller  		 = (
			
			debug "quadriller"
			
			local offset = [ -20,-20,0 ]
			
			
			--- BB ---
			local BB = get_BB_contour ()
			
			local p_largeur = m_plug.grille_largeur
			
			---- sur X ----------------------------------------------------------------------------------------
			local plane_normal = Point3 1 0 0
			local plane_center = BB[1]
			
			local plane_center_abs = plane_center --+ _node.pos
			plane_center_abs.x = ( floor ( plane_center_abs.x / p_largeur ) ) * p_largeur 
			plane_center_abs.y = ( floor ( plane_center_abs.y / p_largeur ) ) * p_largeur 			
			plane_center.x = plane_center_abs.x + offset.x
			plane_center.y = plane_center_abs.y  + offset.y
			
			while  plane_center.x < BB[2].x do (
				local faces = #{1..polyop.getNumFaces m_plug.delegate	}
				local rayon	=	ray plane_center	plane_normal
				polyop.slice m_plug.delegate	 faces 	rayon
				plane_center.x += p_largeur
			)
			
			---- sur Y ----------------------------------------------------------------------------------------
			local plane_normal = Point3 0 1 0
			local plane_center = BB[1]
			
			local plane_center_abs = plane_center --+ _node.pos
			plane_center_abs.x = ( floor ( plane_center_abs.x / p_largeur ) ) * p_largeur 
			plane_center_abs.y = ( floor ( plane_center_abs.y / p_largeur ) ) * p_largeur 				
			plane_center.x = plane_center_abs.x	+ offset.x
			plane_center.y = plane_center_abs.y 	+ offset.y
			
			while  plane_center.y < BB[2].y do (
				local faces = #{1..polyop.getNumFaces m_plug.delegate	}
				local rayon	=	ray plane_center	plane_normal
				polyop.slice m_plug.delegate	 faces 	rayon
				plane_center.y += p_largeur
			)
			
			
			b_continue 
			
		), -- fin fonctoin
	
		
		fn construire = undo off with redraw off  (
			
			---- on vide ---------------
			mgr_geo.vider ()
			
			if m_plug.reliefs_nodes.count > 0  and m_plug.contours_nodes.count > 0   do with redraw off (
			
				local chrono_debut = timeStamp ()
				
				
				debug "construire"
				
				--- on recuprere le noeud root de la hierachie de booleens ----------------
				local		nd_root 					= mgr_booleen.hierarchiser 			m_contour_points
				local		pts_pret_pourFace 	= mgr_booleen.get_boleens_pts		nd_root
				
				--- on créé les faces  ------------
				for pts_spline_contour in pts_pret_pourFace do
					mgr_geo.face 	pts_spline_contour	smGrp:1
				
				
				
				local chrono_tmp= timeStamp ()
				--- on quadrille   ------------
				quadriller ()
				debug ("Terrain : quadriller en " +  (  ((timeStamp ()) - chrono_tmp ) / 1000.0)	as string + "s." )
				
				--- on projete -------------------
				local chrono_tmp= timeStamp ()
				projeter	()
				debug ("Terrain : projection en " +  (  ((timeStamp ()) - chrono_tmp ) / 1000.0)	as string + "s." )
				
				debug ("---> Terrain : Construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." )
			
				displayTempPrompt ("Terrain : Construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." ) 30000
				
			)
			
			
			redrawViews ()
			
		),
	
		fn actualiser_contours =(
			
			local chrono_debut = timeStamp ()
			
			m_contour_points =#()
			
			---- maj des points -------------
			
			for 	contour_node in m_plug.contours_nodes do
				m_contour_points	+= 	( mgr_shapes.get_pts_from_shape		contour_node )
			
			
			local datas_pts_contour =#()
			for pts_spline_contour in m_contour_points do
					append datas_pts_contour		( mgr_datas.toString	pts_spline_contour )
			
			
			--- on enregistre les points sur le node pour pas avoir a recalucler a chaque fois	------------------
			m_plug.contour_pts	=	datas_pts_contour
			
			debug ("Terrain : Contours actualisé en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." )
		),
		
		
		fn ecouteurs_activer =(
			
			---   deformation geometrie des objets en reference ------------------
			fn fct_ecouteur_terrain		 ev nds = (
				undo off with redraw off (
					
					--- actualiser - shape ------
					if superclassof ( GetAnimByHandle nds[1] )  == shape  then (
						format "nds : " 
						for nd_id in nds do (
							local nd = GetAnimByHandle nd_id
							format " %, " nd.name
							case classof  nd of (
								Urba_terrain: nd.actualiser_contours ()
							)
						)
						format "\n" 
					) else 	if classof  ( GetAnimByHandle nds[1] ) != Urba_terrain_mgr and classof  ( GetAnimByHandle nds[1] ) != Urba_terrain  do (
						format "nds : " 
						for nd_id in nds do (
							local nd = GetAnimByHandle nd_id
							format " %, " nd.name
							case classof  nd of (
								Urba_terrain: nd.actualiser_reliefs ()
							)
						)
						format "\n" 
					)
				)
				redrawviews ()
			)---- fin 	fct_ecouteur_terrain
			
			
			m_ecouteur_terrain = undefined
			gc light:true
			m_ecouteur_terrain = NodeEventCallback 	mouseup:true 	geometryChanged:fct_ecouteur_terrain		topologyChanged:fct_ecouteur_terrain
					
				
				
			
		),
		
		fn initialiser		_plug =(
			
			---- les pointeurs --------
			m_plug				=	_plug
			m_core				=	m_plug.core
			mgr_geo.m_plug 	= m_plug
			
			
			ecouteurs_activer ()
			
		)
	
)


