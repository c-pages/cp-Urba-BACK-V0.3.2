
struct str_shape_outils_TMP (

	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba | str_shape_outils_TMP",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	----------------- tableaux -----------------
	private
		fn boucler 							_array				_id_item 		=(
			
			if _id_item >	_array.count do _id_item = mod _id_item _array.count
			if _id_item < 1 do _id_item += _array.count
			_id_item as integer
		),
		fn trouver_pt 						_arraydePts  		_pt 	 			=(
			local result = 0
			local seuil = 1
			local i = 1
			while i <= _arraydePts.count and  result == 0 do (
				local pt  =_arraydePts[i]
				if distance 	pt  _pt < seuil do
					result = i
				i+=1
			)
-- 			format "pt_est_dejaPresent :%\n" result
			result
		),
		fn pt_est_dejaPresent 			_arraydePts  		_pt 	 			=(
			local result = ( trouver_pt	_arraydePts	_pt ) != 0
			result
		),
		fn comparerTableaux 			first 				second 				=(
			result = true
			if first.count != second.count then
				result = false
			else
				for i = 1 to first.count do
					if first[i] != second[i] do result = false
			result
		),
		fn virerDoublonsDansTableau  _tab 			= (
			for i = 1 to _tab.count do
			(
				for j = _tab.count to i+1 by -1 do
				(
					test = ( ComparerTableaux  _tab[i] _tab[j] )
					if test do
					(
						deleteItem _tab j
					)
				)--end j loop
			)--end i loop
		),
		fn ordonner_Points 				_id_pts	 		=(
			--#(2, 3, 4, 1), #(3, 4, 1, 2), #(4, 1, 2, 3)
			local min 		=	amin _id_pts
			local id_min 	= finditem _id_pts 	min
			local tab_debut = #()
			local tab_result = #()
			for i = id_min to  _id_pts.count	 do (
				append tab_debut _id_pts[i]
			)
			for i = id_min to  _id_pts.count	 do 
				deleteItem _id_pts id_min
			tab_result = tab_debut + _id_pts
			tab_result
		),
		
		
	----------------- Divers -----------------
	public
		fn surface 								_pts 	 	=(
			--- on creer une face sur le tracé ---------
			local faceTemp = m_geo.pointsEtFaces 	_pts
			
			--- pour utiliser cette fonction : ------
			local result = polyop.getFaceArea  m_plug.delegate faceTemp
			
			--- on supprime la face, verts et edges créés--------
			polyop.deleteFaces 	m_plug.delegate faceTemp
			
			result
		),
		fn edge_lePlusGrand				_pts 		=(
			local longueurEdgeMax = 0
			local	resultPts = #()
			for i = 1 to _pts.count do (
				local j = i+1
				if j > _pts.count  do j = 1
				local pt 			= _pts[	i ]
				local pt_suivant	= _pts[	j ]
				local longueurEdge = distance	pt	pt_suivant
				if longueurEdge > longueurEdgeMax do (
					longueurEdgeMax = longueurEdge
					resultPts = #(pt, pt_suivant)
				)
			)
			resultPts
		),
		fn pointLePlusHautsurY 			_pts		=(
			local maxi = _pts[1].y
			local result_id = 1
			for i = 1 to _pts.count do (
				local pt = _pts[	i ]
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			
	-- 			debug "pointLePlusHautsurY"	var:result_id
			result_id
		),
		fn est_sensPositif 					_pts 		=(
			
			local result 				= true
			local id_pointHaut 	=  pointLePlusHautsurY  	_pts
			
			local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 		= id_pointHaut 		---- le point origine
			local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = _pts.count
			if id_pt_2 > _pts.count  do id_pt_2 = 1
			
			local	pt_1 		= _pts [	id_pt_1		]
			local	pt_ori 		= _pts [	id_pt_ori	]
			local	pt_2 		= _pts [	id_pt_2		]

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
			result
			
		),
		fn changer_sens 					_pts 		=(
			local result =#()
			for i= _pts.count to 1 by -1 do 
				append result _pts[i]
			result
		),
		
	-----------------  Axe Principale ----------------------
	private
		fn get_axePrincipal_mtrx				_pts  					=(
			
			local ptsEdgeLePlusLong 	= edge_lePlusGrand	_pts
			
			local axeVecteur 		= 	normalize (ptsEdgeLePlusLong[2] - ptsEdgeLePlusLong[1])
			local axeMtrx				=  ( matrixFromNormal		axeVecteur )
			
			if axeMtrx.row1	==	[0,0,-1]  then 				
				axeMtrx =  (rotateYMatrix 180) *(rotateXMatrix 180) *  (rotateZMatrix -90) * axeMtrx
			 else if axeMtrx.row1	==	[0,0,1] do
				axeMtrx =  (rotateYMatrix 180)  *(rotateXMatrix 180)  * (rotateZMatrix 90) * axeMtrx
			
			axeMtrx
		),
		fn get_axePrincipal_BB					_pts  	_mtrxAxe  	=(
			
			local pt1 = _pts[1] * inverse _mtrxAxe
			local xMin = xMax = pt1.x
			local yMin = yMax = pt1.y
			local zMin = zMax = pt1.z
			
			for i = 2 to _pts.count do (
				local pt = _pts[i] * inverse _mtrxAxe
				if pt.x < xMin 		do xMin 		= pt.x
				if pt.x > xMax 	do xMax 	= pt.x
				if pt.y < yMin 		do yMin 	= pt.y
				if pt.y > yMax 	do YMax 	= pt.y
				if pt.z < zMin 		do zMin 		= pt.z
				if pt.z > zMax 	do zMax 	= pt.z
			)
			
			#([xMin, yMin, zMin]*  _mtrxAxe, [xMax, yMax, zMax]*  _mtrxAxe)
			
		),
		fn get_axePrincipal_orientation		_mtrxAxe 	_vec 					=(
			
			local mtrx_Direction = _mtrxAxe
			local vec_direction = [0,0,1] * mtrx_Direction
			
			local vec1_dir = normalize 	_vec	
			
			local valTest =  abs  (dot  vec_direction	vec1_dir ) 
			
			if valTest	 > cos 45 then 
				#parallele
			else 
				#perpendiculaire
			 
		),
		
		
		
		
	-----------------  divers ----------------------
	public
		fn estPignon 	_pts		_id		=(
			
			local mtrx_AP	= get_axePrincipal_mtrx 	_pts
			local j 			= boucler  _pts  (_id+1)
			local vec 		= (_pts[j]-_pts[_id])
			local orientation 	= get_axePrincipal_orientation		mtrx_AP		vec
			
			if orientation == #perpendiculaire 
				then true 
				else false
		),
	private
		fn intersection 	_pt_orig 	_pt_2 		_pt_seg_1 	_pt_seg_2  		 =(
			local pt_result
			local seuil = 1
			
			local vec_proj		= _pt_orig - _pt_2
			local vec_seg		= _pt_seg_1 - _pt_seg_2
			
			local norm_proj		= normalize vec_proj
			local norm_seg		= normalize vec_seg
			local dot_proj_seg 	= dot norm_proj norm_seg
			
			
			--- si pas parallele -------------------------
			local a1, b1, a2, b2 
			local d1_vert = false
			local d2_vert = false
			if dot_proj_seg != 1 and dot_proj_seg != -1 do (
				
				--- données pour les eaquations de droite y = ax + b ----
				-- droite projeté----------------------
				if (( _pt_orig.z *1000) as integer /1000  == ( _pt_2.z *1000) as integer /1000) then (
					-- horizontale --
					a1 = 0
					b1 	= _pt_orig.z 
				) else if (( _pt_orig.x *1000) as integer /1000  == ( _pt_2.x *1000) as integer /1000) then (
					-- verticale --s
					a1 	= 1
					b1 	= _pt_orig.z - _pt_orig.x
					d1_vert = true
				) else (
					a1 	= (_pt_orig.z - _pt_2.z ) / (_pt_orig.x - _pt_2.x)
					b1 	= _pt_orig.z - a1*_pt_orig.x
				)		
				-- droite reception
				if _pt_seg_1.z == _pt_seg_2.z then (
					-- horizontale --
					a2 = 0
					b2 	= _pt_seg_1.z 
				) else if _pt_seg_1.x == _pt_seg_2.x then (
					-- verticale --
					a2 	= 1
					b2 	= _pt_seg_1.z - _pt_seg_1.x
					d2_vert = true
				) else (
					a2 	= (_pt_seg_1.z - _pt_seg_2.z ) / (_pt_seg_1.x - _pt_seg_2.x)
					b2 	= _pt_seg_1.z - a2*_pt_seg_1.x
				)
				
				
				
				
				local x, y
				if 	d1_vert then (
					if not d2_vert do (
						x =   _pt_orig.x
						y =   a2 * x + b2
					)
				) else 	if 	d2_vert then (
					if not d1_vert do (
						x =   _pt_seg_1.x
						y =   a1 * x + b1
					)
				) else (
						x =   ( b2 - b1 ) / (a1  - a2 )
						y =   a1 * x + b1
				)
				
				-- si on a un point on verifie la suite -----------------------------
				if x != undefined do (
					
					local pt_proj  = [x,0,y]
					
						--- si projection est dans le bon sens ----------
						if   dot  ( normalize ( _pt_orig - _pt_2 ) )  (  normalize (   pt_proj - _pt_orig) )   > 0 do (
							
							local precision = 1000
							local dist_seg 		= ( ( distance _pt_seg_1 	_pt_seg_2 ) * precision as integer ) / precision
							local dist_ptProj 		= ( ( distance _pt_seg_1 	pt_proj 		+ distance _pt_seg_2 	pt_proj ) * precision as integer ) / precision	
							
							if  dist_ptProj  as string == dist_seg as string  do 
								pt_result 	= pt_proj
							
						)
				)
				
			)
			pt_result
		),
		fn chercher_pt_a90degGauche	_pts	_id_pt  	vec_pt		 =(
			
			local seuil = 1			
			local vertexSurLigne = #()
			local mtrx_AP	= get_axePrincipal_mtrx 	_pts
			local pt 				= _pts[ _id_pt ] 			* 	inverse  	mtrx_AP	
			local norm_pt 		= normalize vec_pt			
			local mtrx_rotateZ90	=	rotateY	(matrix3 1)	90
			local norm_test 			= norm_pt * mtrx_rotateZ90			
			local pt_virtuel 			= pt + norm_test			
			local a,b
			local verticale 		= false
			
			if (( pt.z *1000) as integer /1000  == ( pt_virtuel.z *1000) as integer /1000) then (
				-- horizontale --
				a = 0
				b = pt.z 
			) else if (( pt.x *1000) as integer /1000  == ( pt_virtuel.x *1000) as integer /1000) then (
				-- verticale --
				a 	= 1
				b 	= pt.z - pt.x
				verticale = true
			) else (
				a 	= (pt.z - pt_virtuel.z ) / (pt.x - pt_virtuel.x)
				b 	= pt.z - a*pt.x
			)		
			
			
			if not verticale then (
				for i=1 to _pts.count do (
					local pt_test = _pts[i] * 	inverse  	mtrx_AP	
					
					if  abs ( pt_test.z - ( pt_test.x * a + b ) ) < seuil do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
							
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			) else (
				for i=1 to _pts.count do (
					local pt_test = _pts[i] * 	inverse  	mtrx_AP	
					
					if  abs ( pt_test.x - pt.x ) < seuil  do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
							
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			)
			
			
			local result 
			local dist_min = 0
			for id_pt_test in vertexSurLigne do (
				local pt_test = _pts[ id_pt_test ] 			* 	inverse  	mtrx_AP	
				local dist_test = distance pt pt_test
				if  dist_test < dist_min or dist_min == 0 do (
					result = id_pt_test
					dist_min = dist_test
				)
			)
			
			result
			
		),
		fn unir 	_listeTraces 	=(
			
			local traces = #() 
			
			for trace in _listeTraces do (
				local traceTmp = for _pt  in trace collect _pt
					append traces traceTmp
			)
				
			
			
			local continu = true
			local suivant = false
			local idTrace1 = 1
			local idTrace2 = 1
			local trace1, trace2
			
			
			while traces.count > 1 and	continu do (
				trace1 	= traces[idTrace1]
				suivant 	= false
				for idTrace2 = 1 to traces.count where idTrace1 != idTrace2 and  not suivant 	do (
					
					trace2 	= traces[ idTrace2 ]
					
					local ptsCommuns			= #()
					local ptsCommuns_trouve = false
					local idCommun_rect1 		= 0
					
					for i = 1 to  trace1.count  where not  ptsCommuns_trouve   do (
						local id1 = trace1[i]
						local id2 =	finditem 	trace2	 id1
						
						if  id2 != 0 then (
							
							append ptsCommuns id1
							if ptsCommuns.count == 2 do 
								ptsCommuns_trouve = true
						)
					)
				
					
					if ptsCommuns.count > 1 then (
						local idPt1_communTrace2 = findItem	trace2  ptsCommuns[1]
						local idPt2_communTrace2 = boucler	trace2  ( idPt1_communTrace2 + 1 )
						
						if trace2[ idPt2_communTrace2 ] != ptsCommuns[2] then (
							local id_Pt1_trace2 = boucler trace2 (idPt1_communTrace2 + 1)
							local id_Pt2_trace2 = boucler trace2 (idPt1_communTrace2 + 2)
							
							local idPt1_communTrace1 = findItem	trace1  ptsCommuns[1]
							local idPt2_communTrace1 = boucler trace1 ( idPt1_communTrace1 + 1 )
							if trace1[ idPt2_communTrace1 ] != ptsCommuns[2] then (
								local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[2] ) + 1 )
								insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
								insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
								
							) else (
								local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[1] ) + 1 )
								insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
								insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
							)
							
							
							
						) else (
							local id_Pt1_trace2 = boucler trace2 (idPt2_communTrace2 +1)
							local id_Pt2_trace2 = boucler trace2 (idPt2_communTrace2 +2)
-- 								format "		-> - B - on insert a partir de %\n" trace2[ id_Pt1_trace2 ]
							
							local idPt1_communTrace1 = findItem	trace1  ptsCommuns[1]
							local idPt2_communTrace1 = boucler trace1 ( idPt1_communTrace1 + 1 )
							if trace1[ idPt2_communTrace1 ] != ptsCommuns[2] then (
								local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[2] ) + 1 )
								insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
								insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
								
							) else (
								local idPt2_communTrace1 = boucler trace1		( (finditem trace1  ptsCommuns[1] ) + 1 )
								insertItem   trace2[  id_Pt2_trace2 ]	trace1	 idPt2_communTrace1
								insertItem   trace2[  id_Pt1_trace2 ]	trace1	 idPt2_communTrace1
							)
							
							
						)
						
						traces[idTrace1] = ordonner_Points 	trace1
						deleteItem  traces 	idTrace2
						idTrace1 = 1
						
						suivant = true
					)
				)
				if suivant == false do 	
					idTrace1 += 1
				if idTrace1 > traces.count - 1 do 	
					continu = false
				
			) -- fin du while --------
			
			
			traces
			
			
			
		),
		fn chercher_alignements	_pts		_idTest		_seuil		=(
			
			local mtrx_AP 			= get_axePrincipal_mtrx 	_pts
			local pt_test				= _pts[_idTest]		* inverse  mtrx_AP
			local result =#()
		
			for i = 1  to _pts.count do (
				
				local j 				= boucler 	_pts	( i + 1)
				local pt 			= _pts[i]	* inverse  mtrx_AP
				local pt_suivant 	= _pts[j]	* inverse  mtrx_AP
				
				
				if estPignon  _pts	_idTest		 and estPignon  _pts 	i 	 					do 	(
					if abs ( pt_test.z - pt.z ) < _seuil do 
						appendIfUnique result i
					if abs ( pt_test.z - pt_suivant.z ) < _seuil do 
						appendIfUnique result i
				)
				
				if not estPignon  _pts	_idTest		 and not estPignon _pts i  	do (
					if abs ( pt_test.x - pt.x ) < _seuil do
						appendIfUnique result i
					if abs ( pt_test.x - pt_suivant.x ) < _seuil do 
						appendIfUnique result i
				)
				
			)
				
				

			result
		),
		
		
		
		
	-----------------  Optimisations ----------------------
	public
		fn orthonormer 		&_pts	_seuil  =(
			debug "orthonormer"
			local mtrx_AP = get_axePrincipal_mtrx 	_pts
			
			for i = 1 to _pts.count do (
				
				local j = i + 1
				if j > _pts.count do j = 1
				local pt = _pts[i]	* inverse  mtrx_AP 
				local pt_suivant = _pts[j] *  inverse mtrx_AP 
				local vec_moyenne 
				
				local est_pignon = estPignon _pts  i
				if not est_pignon then (
					local moyenneX = ( pt_suivant.x - pt.x ) /2					
					vec_moyenne = [moyenneX,0,0] * _seuil / 100
				) else  (
					local moyenneZ = ( pt_suivant.z - pt.z ) /2					
					 vec_moyenne = [0,0,moyenneZ] * _seuil / 100
				) 
				
				pt 			= _pts[i]	* inverse  mtrx_AP  + vec_moyenne 
				pt_suivant 	= _pts[j]	* inverse  mtrx_AP  - vec_moyenne 
				
				_pts[i] = pt *   mtrx_AP 
				_pts[j] = pt_suivant  *   mtrx_AP 
			)
			
		),
		fn souder 				&_pts	_seuil  =(
			debug "souder"
			
			local i = 1
			while i <=_pts.count do (
				
-- 					debug "i" var:i
				local j= i+1
				if j > _pts.count  do j =1
					
				local pt 			= _pts[i]
				local ptSuivant 	= _pts[j]
				if distance pt ptSuivant <= _seuil do (
					debug "SOUDURE"
					deleteitem _pts j
					_pts[i] = ( pt + ptSuivant ) / 2
					i = 1
				)
				i+=1
			)
			
		),
		fn aplanir 				&_pts	_seuil  	=(
			debug "aplanir"
			
			local i = 1
			while i <= _pts.count do (
				
				local h = i - 1
				if h < 1  do h = _pts.count
				local j= i+1
				if j > _pts.count  do j =1
				local ptDAvant 	= _pts[h]
				local pt 			= _pts[i]
				local ptSuivant 	= _pts[j]
				
				local vec1 = normalize (ptDAvant - pt)
				local vec2 = normalize (ptSuivant - pt)
				
				local anglePt = acos(dot vec1 vec2)			
				if 	anglePt >= 180 - _seuil  then (
					deleteitem _pts i
					i = 0
				)
				dot
				i +=1
			)

			result
		),
		fn aligner				&_pts	_seuil  		=(	
			debug "aligner"
			
			local mtrx_AP 	= get_axePrincipal_mtrx 	_pts
			
			for i = 1 to   _pts.count  do (
				
				local aligns = 	chercher_alignements	_pts	i		_seuil	
				
				local pt_moyenne = [0,0,0]
				for id_align in aligns do 
					pt_moyenne += _pts[id_align]	* inverse  mtrx_AP
				pt_moyenne /=  aligns.count
				
				for id_align in aligns  do (
					
					local j 						= boucler _pts (  id_align + 1 )
					local pt 					= _pts[id_align]	* inverse  mtrx_AP  
					local pt_suivant 			= _pts[j]	* inverse  mtrx_AP  
					local vec_moyenne1 	= pt_moyenne	 - pt
					local vec_moyenne2 	= pt_moyenne	 - pt_suivant
					local vec_align1, vec_align2
					if estPignon  _pts	id_align		 then (
						vec_align1 			= [0,0,vec_moyenne1.z] 
						vec_align2 			= [0,0,vec_moyenne2.z] 						
					) else (
						vec_align1 			= [vec_moyenne1.x,0,0] 
						vec_align2 			= [vec_moyenne2.x,0,0] 
					)
					
					pt 							= _pts[id_align]	* inverse  mtrx_AP  	+ vec_align1 
					pt_suivant 					= _pts[j]			* inverse  mtrx_AP  	+ vec_align2
					
					_pts[id_align] 	= pt *   mtrx_AP 
					_pts[j] 			= pt_suivant *   mtrx_AP 
					
				)
			)
		),
		fn projeter		 		&_pts 	=(
			
			local mtrx_AP 	= get_axePrincipal_mtrx 	_pts
			local seuil = 5
			local result
			local trace 		= _pts
			local trace_temp =  for item in trace collect item
			
			local est_subdivise_total = false
			while not est_subdivise_total do (
				
				local est_subdivise = false
				local est_trouve = false
				
				local i = 1
				while i <=  trace_temp.count and not est_trouve do (
					
					local id_direction_suiv		=  boucler trace_temp  (i+1)
					local id_direction_prec		= 	boucler trace_temp  (i-1)
					
					local pt_orig		= 	trace_temp[ i ]	* 	inverse  	mtrx_AP  
					local pt_suiv		=	trace_temp[ id_direction_suiv  ]  * 	inverse  	mtrx_AP
					local pt_prec		= 	trace_temp[ id_direction_prec  ] * 	inverse  	mtrx_AP
					
					---- les segments a tester------------
					local compteur_segment = 0
					while compteur_segment <  trace_temp.count  - 2 and not est_trouve do (
						
						--- le segment -----
						local id_seg_1 	= boucler trace_temp  ( i + compteur_segment + 1 )
						local id_seg_2 	= boucler trace_temp  ( i + compteur_segment + 2	)
						
						local pt_seg_1	= trace_temp[ id_seg_1 ]	* 	inverse  	mtrx_AP
						local pt_seg_2	= trace_temp[ id_seg_2 ] 	* 	inverse  	mtrx_AP 
						
						--- la projection 1 -------
						local pt_proj = intersection 	pt_orig		pt_suiv		pt_seg_1	 	pt_seg_2		
						
						if pt_proj != undefined  do (	
							
							if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do (
								if not pt_est_dejaPresent   trace_temp  	( pt_proj	* 	mtrx_AP )	 do ( 
									local id_place = trouver_pt	 trace_temp  ( pt_seg_1 * 	mtrx_AP )
									insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
									est_subdivise = est_trouve = true
								)
							)
						)
						
						--- la projection 2 -------
						local pt_proj = intersection 	pt_orig		pt_prec		pt_seg_1	 	pt_seg_2	
						
						if pt_proj != undefined  do (	
							
							if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do (
								if not pt_est_dejaPresent   trace_temp  	( pt_proj	* 	mtrx_AP )	 do ( 
									local id_place = trouver_pt	 trace_temp  ( pt_seg_1 * 	mtrx_AP )
									insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
									est_subdivise = est_trouve = true
								)
							)
						)
						
						compteur_segment +=  1
					) -- fin while compteur_segment
					
					i += 1
					
				) -- fin while i  --
				
				if not est_subdivise do est_subdivise_total = true
				
			) -- fin while not est_subdivise_total
			
			_pts = trace_temp
			
		),
		
		
	--- Accession ---------------------
		------Subdivision ----------------------------------------------------------
		fn scanner_points 	_shape	=(
			
			local pts_surface				=#()
			
			---- On chope les points de la surface a scanner -----------
			for id_pt = 1 to ( numKnots 	_shape 	1 ) do	(
				local pt_shape 	= getKnotPoint 	_shape 	1 	id_pt
				local pt_surface 	= pt_shape * inverse  _shape.transform
				append pts_surface 	 pt_surface
			)
			
			
			--- on fait tourner les spline dans le meme sens ----
			if not est_sensPositif 	pts_surface 	 do
				trace_absolu = changer_sens		pts_surface
			
			--- on gere les OPTIMISATIONS  ----
			souder				&pts_surface		30
			orthonormer		&pts_surface		100
			aplanir				&pts_surface		20
			aligner				&pts_surface		50
			projeter				&pts_surface
			
			
			
			pts_surface
			
		),
		
		
		
		fn subdiviser		 	_shape	=(
			
			debug "subdiviser"
			
-- 			--- on  les points projetés au tracé --------
-- 			projeter		&_pts
			
			local 	_pts	=	scanner_points 	_shape	
			local result 					= #()
			local result_reste 			= #()
			
			local rectangles_traces 		= #()
			
			local seuil 					= 1
			local mtrx_AP 				= get_axePrincipal_mtrx 	_pts
			local trace 					= _pts
			
			for i = 1 to  trace.count 	do (
				
				local pt_orig				= 	trace[ i ]	* 	inverse  	mtrx_AP 
				local id_pt_preced 	= boucler 	trace	( i - 1)
				local pt_preced 		= trace[ id_pt_preced ] * 	inverse  	mtrx_AP	
				local vec_pt 				= pt_orig - pt_preced		
				
				local id_pt_1, id_pt_2, id_pt_3, id_pt_4
				
				-- on part du premier point, on cherche a gauche ---
				id_pt_1	= chercher_pt_a90degGauche		_pts	i 	vec_pt	 
				
				---- si on a trouvé un point, on continue -----
				if id_pt_1 != undefined then (
					local norm 		= vec_pt * (rotateY	(matrix3 1)	90 )
					id_pt_2				= chercher_pt_a90degGauche		_pts		id_pt_1 	norm		 
				)
				
				---- si on a trouvé un point, on continue -----
				if id_pt_2 != undefined then (
					local norm	 	= vec_pt * (rotateY	(matrix3 1)	180 )
					id_pt_3 				= chercher_pt_a90degGauche	_pts		id_pt_2 	norm	 
				)
				
				---- si on a trouvé un point, on continue -----
				if id_pt_3 != undefined then (
					local norm	 	= vec_pt * (rotateY	(matrix3 1)	270 )
					id_pt_4 				= chercher_pt_a90degGauche	_pts		id_pt_3 	norm	 
				)
				
				---- et si on a retombe sur le premier point, c'est qu'on a un rectangle-------
				if id_pt_4 == i do (
					
					debug "ON A UN RECTANGLE"
					
					local pt_rect_1 = trace[ id_pt_1 ]	* 	 	_shape.transform 
					local pt_rect_2 = trace[ id_pt_2 ]	* 	 	_shape.transform 
					local pt_rect_3 = trace[ id_pt_3 ]	* 	 	_shape.transform 
					local pt_rect_4 = trace[ id_pt_4 ]	* 	 	_shape.transform 
					
					local surf = ( distance pt_orig pt_rect_1 ) * ( distance pt_orig pt_rect_3 )  / 10000
					
					local corner =  #( id_pt_1, id_pt_2, id_pt_3, id_pt_4  )
					
					local rect_ordo = ordonner_Points 		corner
					append rectangles_traces 		rect_ordo
					virerDoublonsDansTableau 	rectangles_traces
					
					
					----- DEBUG	---- on dessine le rectangle ----
					local shapeDecoupe = line ()
					addNewSpline shapeDecoupe
					addKnot shapeDecoupe 1 #corner #line  	pt_rect_1
					addKnot shapeDecoupe 1 #corner #line  	pt_rect_2
					addKnot shapeDecoupe 1 #corner #line  	pt_rect_3
					addKnot shapeDecoupe 1 #corner #line  	pt_rect_4				
					close shapeDecoupe 1
					updateshape shapeDecoupe
				   
				   
				   
				)
				
				
				
			) -- fin while i  --
			
			rectangles_traces
			
		),
		
		
		
		fn decouper_rectangles 		_shape	=(
			
			debug "decouper_rectangles"
			local 	pts = scanner_points	_shape
			
			local 	rectangles_traces 		= #()
			
			subdiviser		pts
			
		)
		
	
	
)

for obj in objects where obj != $Shape007 do delete obj
test = str_shape_outils_TMP ()
clearlistener ()
test.subdiviser	$Shape007