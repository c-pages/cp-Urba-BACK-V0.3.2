(
	
	struct str_droite (
		a,
		b,
		c
	)
	
	
	struct str_plan (
			------------ DEBUG	----------------------------------------------------------------------------------
		private
			m_debug = true,
			m_dbgPrefix ="str_plan",
			fn debug 	_txt  var:	 param:    =(
				try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
				catch ()
			),
			
			------------ Membres ----------------------------------------------------------------------------------
		private
			a,
			b,
			c,
			d,
			normal ,
			
			------------ Fonctions ----------------------------------------------------------------------------------
		public
			--- creation -----------
			fn creerFrom_2vecs_et_1Point	_vec1 	_vec2  	_point	=(
				
				---le vec normal du plan-----
				local norm1 = normalize _vec1
				local norm2 = normalize _vec2		
				normal =  cross    norm2 	norm1
				
				--- definition equation ---------
				a = normal.x
				b = normal.y
				c = normal.z		
				d = -( a*_point.x + b*_point.y + c*_point.z )
				
			),
			fn creerFrom_3Points		_pt1 	_pt2  	_pt3	=(
				local vec1 = _pt2 - _pt1
				local vec2 = _pt2 - _pt3
				local pt 	= _pt2
				
				creerFrom_2vecs_et_1Point	vec1 	vec2  	pt
				
			),
			
			
			--- divers -----------
			fn projeter_point_verticalement 		_pt 	=(
	-- 			debug "projeter_point_verticalement"
				local result = copy _pt
				result.z =  -( a*_pt.x + b*_pt.y + d ) / c
				result
				
			),
			

			fn get_intersection_segment	_segPt1		_segPt2			=(
				
				local k	= -( a * _segPt1.x 		+	b * _segPt1.y 	+	c * _segPt1.z 	+ d ) 	/	( a * ( _segPt2.x -  _segPt1.x ) + b * ( _segPt2.y -  _segPt1.y )  + c * ( _segPt2.z -  _segPt1.z )  )

				local ptResult 	= [0,0,0]
				ptResult.x 		=  _segPt1.x + k * ( _segPt2.x 	-  _segPt1.x )
				ptResult.y 		=  _segPt1.y + k * ( _segPt2.y 	-  _segPt1.y )
				ptResult.z 			=  _segPt1.z + k * ( _segPt2.z 	-  _segPt1.z )
				
				ptResult
				
			),
			fn coupe_segment		_segPt1		_segPt2			=(
				
				local pointIntersect = get_intersection_segment 	_segPt1		_segPt2 		
				-- debug-------
	-- 			point pos:pointIntersect isSelected:true
				
				local vecSeg 	= _segPt2 - _segPt1
				local vecInter = pointIntersect - _segPt1
				
				if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
					true
				else
					false
				
			)
			
			
			
			
	)
	str_plan ()
)