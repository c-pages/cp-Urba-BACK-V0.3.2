	point_2 = $Point002
		point_1 = $Point001
	fn get_mur_cardinal   	_pt1	_pt2	 =(
		local result 
			local norm_mur = normalize	(	_pt2	 - _pt1 )
		
			local norm_OuestEst 	= [1,0,0]
			if abs norm_mur.x > abs norm_mur.y then (
				if norm_mur.x > 0 then
						result = #sud
				else
						result = #nord
			) else (
				if norm_mur.Y > 0 then
						result = #est
				else
						result = #ouest
			)
			
		)
		
		
		
		get_mur_cardinal  point_1.pos   point_2.pos