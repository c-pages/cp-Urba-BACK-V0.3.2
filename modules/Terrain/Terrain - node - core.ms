


include	 "$userScripts\\cp-Urba\\modules\\Terrain\\Terrain - triangulation.ms" 
include	 "$userScripts\\cp-Urba\\modules\\Batiment\\divers\\Batiment - Geometrie.ms"
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - outils - shape.ms" 



struct	str_terrain_node_core	(
		
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"urba | str_terrain_node_core"	  	var:var	 param:param		catch (),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_plug,
		m_core,
		
		mgr_geo				= 	str_geometrie 		(),
		mgr_trianguler 	= 	str_triangulation_shape (),
		mgr_shapes		= 	str_terrain_outils_shape (),
		mgr_datas			=	str_datasToString (),
		
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
			debug "projeter"
			local ids_pts_total = #{1.. polyop.getNumVerts m_plug.delegate	}
			local pts_total =#()
			for id_pt in  ids_pts_total do (
				local pt = polyop.getVert m_plug.delegate  id_pt
				pt = projectionZ 	pt		m_plug.relief_node
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
	
		
		fn construire =(
			
			---- on vide ---------------
			mgr_geo.vider ()
			
			if m_plug.relief_node != undefined and m_plug.contour_node != undefined do (
			
				--- on creer une face par spline ------------
				for pts_spline_contour in m_contour_points do
					mgr_geo.face 	pts_spline_contour
				
				--- on quadrille   ------------
				quadriller ()
				
				--- on projete -------------------
				projeter	()
			
			)
		),
	
		fn actualiser_contour =(
			
			m_contour_points =#()
			
			m_contour_points	=	mgr_shapes.get_pts_from_shape		m_plug.contour_node
			local datas_pts_contour =#()
			for pts_spline_contour in m_contour_points do
					append datas_pts_contour		( mgr_datas.toString	pts_spline_contour )
			
			--- on enregistre les points sur le node-	------------------
			m_plug.contour_pts	=	datas_pts_contour
			
		),
		
		fn set_contour 	_shp 	=(
			
			m_plug.contour_node	=	_shp
			
			actualiser_contour ()
			
		),
		
		fn ecouteurs_activer =(
			
				fn fct_ecouteur_terrain		 ev nds = (
					
					--- actualiser - shape ------
					if superclassof ( GetAnimByHandle nds[1] )  == shape  do
						for nd_id in nds do (
							local nd = GetAnimByHandle nd_id
							case classof  nd of (
								Urba_terrain: nd.actualiser_contour ()
							)
						)
					
					if classof  ( GetAnimByHandle nds[1] ) != Urba_terrain_mgr and classof  ( GetAnimByHandle nds[1] ) != Urba_terrain  do
						for nd_id in nds do (
							local nd = GetAnimByHandle nd_id
							case classof  nd of (
								Urba_terrain: nd.actualiser_relief ()
							)
						)
					
				)---- fin 	fct_ecouteur_terrain


				m_ecouteur_terrain = undefined
				gc light:true
				m_ecouteur_terrain = NodeEventCallback 	mouseup:true 	geometryChanged:fct_ecouteur_terrain
				
		),
		
		fn initialiser		_plug =(
			
			---- les pointeurs --------
			m_plug				=	_plug
			m_core				=	m_plug.core
			mgr_geo.m_plug 	= m_plug
			
			
			ecouteurs_activer ()
			
		)
	
)