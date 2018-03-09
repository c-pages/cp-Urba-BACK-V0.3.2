fn encart  _pts 	_dist	=(
	clearselection ()
	for i = 1 to _pts.count  do (
		
		local j = if i ==  _pts.count then 1 	else i +1
		local k = if i ==  1 then _pts.count 	else i - 1
			
		local pt_concerne 		= _pts[i]
		local pt1 					= _pts[k]
		local pt2 					= _pts[j]
		
		local		vec1 = pt1 - pt_concerne
		local		vec2 = pt2 - pt_concerne
		
		local norm_vec_1 = (normalize vec1)
		local norm_vec_2 = (normalize vec2)
		local dotPt 	=	dot  norm_vec_1  norm_vec_2
		local acosPt 	= acos  dotPt
		local asinPt 	= asin  dotPt
		

		local crossProd 	= cross (  pt_concerne - pt1 ) ( pt2 - pt1 )
		local sensDot 		= dot crossProd  [0,0,1]
		local sens = if sensDot > 0 then -1 else 1
		local		norm_dir = norm_vec_1 + norm_vec_2
		
		
		local 	pt_result = pt_concerne + norm_dir* _dist * sens

		objresult = point pos:pt_result
		selectmore objresult
		format "pt % ----------\n" i 
-- 		format "	dotPt : %\n" dotPt
-- 		format "	acosPt : %\n" acosPt
-- 		format "	asinPt : %\n" asinPt
		format "	>>>>>	resultSens : %\n" resultSens
	)
)	

shp = $Line001
pts = for i = 1 to numknots shp collect		getKnotPoint 	shp	1	i
	clearlistener ()
encart  pts 	50

-- ss = SplineShape pos:pointA
--   addNewSpline ss
--   addKnot ss 1 #corner #line PointA
--   addKnot ss 1 #corner #line PointB
--   updateShape ss
--   ss
--   
--   getknot
/* 
shp = $Line001
pt_1 = getKnotPoint 	shp	1	1
pt_2 = getKnotPoint  shp	1	2
pt_3 = getKnotPoint  shp	1	3

vec_1 = pt_1 - pt_2
vec_2 = pt_3 - pt_2

norm_1 = normalize vec_1
norm_2 = normalize vec_2

norm_dir = norm_1 + norm_2

dist = -75

pt_result = pt_2 + norm_dir* dist

objresult = point pos:pt_result
select objresultg




 */