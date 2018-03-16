(
	
	struct str_droite (
		a,
		b,
		c,
		
		---- ou -----
		pt 	= [0,0,0],
		dir	= [0,0,0],
		
		fn get_intersection_plan		_P 	=(
			
			/*-------------DETAIL CALCUL -----------
			--- equation parametreique de l a droite ------------
			x=pt.x+dir.x*T
			y=pt.y+dir.y*T
			z=pt.z+dir.z*T
			
			----- equation du plan -----
			_P.a*x + _P.b*y + _P.c*z + _P.d = 0
			
			donc :
			_P.a*(pt.x+dir.x*T) + _P.b*(pt.y+dir.y*T) + _P.c*(pt.z+dir.z*T) + _P.d = 0
			
			_P.a*pt.x+_P.a*dir.x*T + _P.b*pt.y+ _P.b*dir.y*T + _P.c*pt.z+_P.c*dir.z*T + _P.d = 0
			 _P.a*dir.x*T   +  _P.b*dir.y*T   + _P.c*dir.z*T   = -(_P.a*pt.x	+	_P.b*pt.y	+	_P.c*pt.z + _P.d )
			
			( _P.a*dir.x +  _P.b*dir.y   + _P.c*dir.z) *T   = -(_P.a*pt.x	+	_P.b*pt.y	+	_P.c*pt.z + _P.d )
			T   = -(_P.a*pt.x	+	_P.b*pt.y	+	_P.c*pt.z + _P.d ) / ( _P.a*dir.x +  _P.b*dir.y   + _P.c*dir.z) 
			
			*/
			
			
			local T   = -(_P.a*pt.x	+	_P.b*pt.y	+	_P.c*pt.z + _P.d ) / ( _P.a*dir.x +  _P.b*dir.y   + _P.c*dir.z) 
			local x=pt.x+dir.x*T
			local y=pt.y+dir.y*T
			local z=pt.z+dir.z*T
			
			result_pt = [x,y,z]
			DEBUG_point = point size:200 pos:result_pt
			select DEBUG_point
			result_pt
		)
		
		
		
	)
	
	
	struct str_plan (
		
		
			------------ DEBUG	----------------------------------------------------------------------------------
		private
			m_debug 			= true,
			m_dbgPrefix 		="str_plan",
			fn debug 	_txt  var:	 param:    =(
				try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
				catch ()
			),
			
			------------ Membres ----------------------------------------------------------------------------------
		public
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
				normal =  normalize ( cross    norm2 	norm1 )
				
				--- definition equation ---------
				a = normal.x as double
				b = normal.y as double
				c = normal.z	as double
				d = -( a*_point.x + b*_point.y + c*_point.z ) as double
				
			),
			fn creerFrom_3Points		_pt1 	_pt2  	_pt3	=(
				
				local vec1 = _pt2 - _pt1
				local vec2 = _pt2 - _pt3
				local pt 	= _pt2
				
				creerFrom_2vecs_et_1Point	vec1 	vec2  	pt
				
				debug "Plan ---------------"
				debug "a" var:a
				debug "b" var:b
				debug "c" var:c
				debug "d" var:d
				debug "normal" var:normal
			),
			
			
			--- diverses  operations -----------
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
				local vecSeg 	= _segPt2 - _segPt1
				local vecInter = pointIntersect - _segPt1
				
				if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
					true
				else
					false
				
			),
			
			fn get_intersection_avec_plan  	_plan_2 =(
				
				------------- 3 cas possibles, mais deux seulements sont nous sont utiles --------------
-- 				debug "Plan 1, normal" var:normal
-- 				debug "Plan 2, normal" var:_plan_2.normal
			
				local pt_result
				local dir_result = normalize (cross normal 	_plan_2.normal )
				local mtrx_dir_DEBUG  = matrixfromnormal dir_result
				
				debug "dir_result" var:dir_result
				
					local a2 = _plan_2.a as double
					local b2 = _plan_2.b as double
					local c2 = _plan_2.c as double
					local d2 = _plan_2.d as double
					local normal2 = _plan_2.normal
				--- cas 1 et 2 : Plans paralleles, confondu ou pas -----------
				if normal == _plan_2.normal or normal == -_plan_2.normal then (
					debug "Pas d'intersection, les plans sont parralelles !"
					#pasIntersection
					
				)  else if abs normal.z == 1 or abs normal2.z == 1 then (
					
					debug "On a un des deux plan horizontal, cas particulier à ecrire"
					
					/* 
-- 					debug "dir_result" var:dir_result
					-- si on a un plan1  horizontal ---------
					if abs normal.z == 1 then (
						
						debug "plan 1 horizontal --> on choisu un Z=D1"
						
						local z = d
						
						
					) else if abs normal2.z == 1 then (
						
						debug "plan 2 horizontal --> on choisie un Z=D2"
						local z = d2
						
						
-- 						a*x + b*y + c*z + d =  c2*z + d2
						
						
						
-- 						a*x + b*y + c*z + d = 0
-- 						a2*x + b2*y + c2*z + d2 = 0
-- 						
-- 						local y = 0
-- 						
-- 						a*x  + c*z + d = 0
-- 						a2*x + c2*z + d2 = 0
-- 						x = -( c*z + d )/a =  -( c2*z + d2 )/a2
-- 						
-- 						
-- 						-( c*z + d )/a =  -( c2*z + d2 )/a2
-- 						-c*z/a  - d/a  = -c2*z/a2 - d2/a2
-- 						
-- 						-c*z/a + c2*z/a2 = d/a - d2/a2
-- 						
-- 						-c*z*a2/(a*a2) + c2*z*a/(a2*a) = d/a - d2/a2
-- 						(-c*z*a2 + c2*z*a)/(a2*a) = d/a - d2/a2
-- 						
-- 						-c*z*a2 + c2*z*a	= ( d/a - d2/a2 ) *(a2*a) 
-- 						(-c*a2 + c2*a)*z	= ( d/a - d2/a2 ) *(a2*a) 
						
						
						
						
					)  */
					) else (
					if abs dir_result.x == 1 then (
						
						debug "on chois un X=0"
						local x	=	0
						local z  = ( - d2/b2 +  d/b ) * (b*b2) / (-c*b2+ c2*b)
						local y = (-c*z - d)/b						
						pt_result = [x,y,z]
						
					) else if abs dir_result.y == 1 then (
						
						debug "on chois un Y=0"
						local z	= ( d/a - d2/a2 ) *(a2*a) /(-c*a2 + c2*a)
						local x = -( c*z + d )/a 
						local y = 0
						pt_result = [x,y,z ]
						
					) else (
						
						debug "on chois un Z=0"
						
						local z  =  0
						local x  =  ( - d2/b2 + d/b  ) * (b*b2) / (a2*b -  a*b2)
						local y  =  (-a*x - d )/ b
-- 						local z	= ( d/a - d2/a2 ) *(a2*a) /(-c*a2 + c2*a)
-- 						local x = -( c*z + d )/a 
-- 						local y = 0
						pt_result = [x,y,z ]
						
					)
					
					debug "pt_result" var:pt_result
					
					pt_DEBUG = point 	axistripod:on  transform:mtrx_dir_DEBUG size:200
					select pt_DEBUG
					pt_DEBUG.pos = pt_result
					
-- 					local droite_result = str_droite  pt:pt_result  dir:dir_result
-- 					
-- 					droite_result
					
				)
				
				
			),
			
			
			---debogger -----------
			fn representer_plan 		_pos		=(
				local pt_du_plan 		= projeter_point_verticalement 	_pos
				local matrx_transf 	= matrixFromNormal  normal
				local plan  				= plane transform:matrx_transf length:1000 width:1000
				plan.pos 					= pt_du_plan
				select plan
			)
			
			
			
			
	)
	str_plan ()
)