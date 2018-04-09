struct str_tmp (
	
	fn projectionZ	 	pt 	_node_cible	=(
		local result = 	 pt
		if _node_cible != undefined do (
			local pos_ray	=		[pt.x, pt.y, 1e+5] --* m_plug.transformation
-- 			pos_ray.z = 	
			local rayon =  intersectRay 	_node_cible	(ray 	pos_ray	 [0,0,1] )
			if rayon != undefined do (
				format "INTERSEC : %\n" rayon
				result.z = rayon.pos.z
			)
		)
		result
	)
	
)
tt = str_tmp ()



-- intersectRay 	$Sphere001	(ray 	$cible.pos	 [0,0,-1] )

$cible.pos.z = 0

$cible.pos  = tt.projectionZ	 	$cible.pos 	$Sphere001



