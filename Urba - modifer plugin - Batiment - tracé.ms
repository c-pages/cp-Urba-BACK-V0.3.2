



----------- Tracé du batiment et autres manipulations----------------
struct str_trace (
	
	---- Pointeurs divers --------------------
	public
		m_geo,
		m_this,			---- le plugin: 'this' -----
		
	private
		m_regles_ssTrace 		= #(),
		m_sousTraces 			= #(),
		m_rectangles_traces 	= #(),
		
		m_datasMgr = str_datasMgr 	m_prt:this,
		
		-----------------  Opérations diverses ----------------------
		fn surface 							_trace 	 	=(
			--- on creer une face sur le tracé ---------
			local faceTemp = m_geo.pointsEtFaces 	_trace
			
			--- pour utiliser cette fonction : ------
			local result = polyop.getFaceArea  m_this.delegate faceTemp
			
			--- on supprime la face, verts et edges créés--------
			polyop.deleteFaces 	m_this.delegate faceTemp
			
			result
		),
		fn edge_lePlusGrand			_trace 	=(
			local longueurEdgeMax = 0
			local	resultPts = #()
			for i = 1 to _trace.count do (
				local j = i+1
				if j > _trace.count  do j = 1
				local pt 			= _trace[	i ]
				local pt_suivant	= _trace[	j ]
				local longueurEdge = distance	pt	pt_suivant
				if longueurEdge > longueurEdgeMax do (
					longueurEdgeMax = longueurEdge
					resultPts = #(pt, pt_suivant)
				)
			)
			resultPts
		),
		fn pointLePlusHautsurY 		_trace	=(
			local maxi = _trace[1].y
			local result_id = 1
			for i = 1 to _trace.count do (
				local pt = _trace[	i ]
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			
	-- 			debug "pointLePlusHautsurY"	var:result_id
			result_id
		),
		fn est_sensPositif 				_trace 	=(
			
			local result 				= true
			local id_pointHaut 	=  pointLePlusHautsurY  	_trace
			
			local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 		= id_pointHaut 		---- le point origine
			local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = _trace.count
			if id_pt_2 > _trace.count  do id_pt_2 = 1
			
			local	pt_1 		= _trace [	id_pt_1		]
			local	pt_ori 		= _trace [	id_pt_ori	]
			local	pt_2 		= _trace [	id_pt_2		]

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
			result
			
		),
		fn reverse 						_trace 	=(
			local result =#()
			for i= _trace.count to 1 by -1 do 
				append result _trace[i]
			result
		),
		
		-----------------  Axe P ----------------------
		fn mtrx_axeP			_trace  							=(
			
			local ptsEdgeLePlusLong 	= edge_lePlusGrand	_trace
			
			local axeVecteur 		= 	normalize (ptsEdgeLePlusLong[2] - ptsEdgeLePlusLong[1])
			local axeMtrx				=  ( matrixFromNormal		axeVecteur )
			
			if axeMtrx.row1	==	[0,0,-1]  then 				
				axeMtrx =  (rotateYMatrix 180) *(rotateXMatrix 180) *  (rotateZMatrix -90) * axeMtrx
			 else if axeMtrx.row1	==	[0,0,1] do
				axeMtrx =  (rotateYMatrix 180)  *(rotateXMatrix 180)  * (rotateZMatrix 90) * axeMtrx
			
			axeMtrx
		),
		fn BB_axeP			_trace  		_mtrxAxe  	=(
			
			local pt1 = _trace[1] * inverse _mtrxAxe
			local xMin = xMax = pt1.x
			local yMin = yMax = pt1.y
			local zMin = zMax = pt1.z
			
			for i = 2 to _trace.count do (
				local pt = _trace[i] * inverse _mtrxAxe
				if pt.x < xMin 		do xMin 		= pt.x
				if pt.x > xMax 	do xMax 	= pt.x
				if pt.y < yMin 		do yMin 	= pt.y
				if pt.y > yMax 	do YMax 	= pt.y
				if pt.z < zMin 		do zMin 		= pt.z
				if pt.z > zMax 	do zMax 	= pt.z
			)
			
			#([xMin, yMin, zMin]*  _mtrxAxe, [xMax, yMax, zMax]*  _mtrxAxe)
			
		),
		fn vec_axeP					_vec 				=(
			
			local mtrx_Direction = m_this.axeP_mtrx.rotationpart as matrix3
			local vec_direction = [0,0,1] * mtrx_Direction
			
			local vec1_dir = normalize _vec	
			
			local valTest =  abs  (dot  vec_direction	vec1_dir ) 
			
			if valTest	 > cos 45 then 
				#parallele
			else 
				#perpendiculaire
			 
		),
	
		
		
		---- tableaux -----------
		fn boucler 	_array	_id_item 		=(
			
			
			if _id_item >	_array.count do _id_item = mod _id_item _array.count
			if _id_item < 1 do _id_item += _array.count
			_id_item as integer
		),
		fn trouver_pt 		_arraydePts  	_pt 	 =(
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
		fn pt_est_dejaPresent 		_arraydePts  	_pt 	 =(
			local result = ( trouver_pt	_arraydePts	_pt ) != 0
			result
		),
		
		---- manipulation de tableaux ----
		fn ComparerTableaux 	first 	second =		(
			result = true
			if first.count != second.count then
				result = false
			else
				for i = 1 to first.count do
					if first[i] != second[i] do result = false
			result
		),
		fn virerDoublonsDansTableau  _tab = (
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
	
		
		fn 	ordonner_Points 		_id_pts	 =(
			--#(2, 3, 4, 1), #(3, 4, 1, 2), #(4, 1, 2, 3)
			local min 		=	amin _id_pts
			local id_min 	= finditem _id_pts min
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
		
		
		fn estPignon 		_id		=(
			local j = boucler  m_this.trace_courant  (_id+1)
			orientation = vec_axeP			(m_this.trace_courant[j]-m_this.trace_courant[_id])
			if orientation == #perpendiculaire then true else false
		),
		
		
		fn actualiser_axeP	  	=(
			
			local mtrxTmp 			= mtrx_axeP  m_this.trace_original 	
			rotateZ	mtrxTmp		m_this.axeP_orientation
			m_this.axeP_mtrx 			= mtrxTmp		
			m_this.axeP_BB				=	BB_axeP		m_this.trace_courant 		m_this.axeP_mtrx
			
-- 			actualiser_pignonsEtGouttereaux m_this
			
		),
		
		
		
		
		-----------------  Optimisation ----------------------
		fn orthonormer 			=(
			
			local mtrx_AP = m_this.axeP_mtrx
			
			for i = 1 to m_this.trace_courant.count do (
				
				local j = i + 1
				if j > m_this.trace_courant.count do j = 1
				local pt = m_this.trace_courant[i]	* inverse  mtrx_AP 
				local pt_suivant = m_this.trace_courant[j] *  inverse mtrx_AP 
				local vec_moyenne 
				
				local est_pignon = estPignon i
				if not est_pignon then (
					local moyenneX = ( pt_suivant.x - pt.x ) /2					
					vec_moyenne = [moyenneX,0,0] * m_this.seuil_ortho / 100
				) else  (
					local moyenneZ = ( pt_suivant.z - pt.z ) /2					
					 vec_moyenne = [0,0,moyenneZ] * m_this.seuil_ortho / 100
				) 
				
				pt 			= m_this.trace_courant[i]	* inverse  mtrx_AP  + vec_moyenne 
				pt_suivant 	= m_this.trace_courant[j]	* inverse  mtrx_AP  - vec_moyenne 
				
				m_this.trace_courant[i] = pt *   mtrx_AP 
				m_this.trace_courant[j] = pt_suivant  *   mtrx_AP 
			)
		/* 	--- les Gouttereaux  --
			for i = 1 to m_this.trace_courant.count do (
				local j = i + 1
				if j > m_this.trace_courant.count do j = 1
				local pt = m_this.trace_courant[i]	* inverse  mtrx_AP 
				local pt_suivant = m_this.trace_courant[j] *  inverse mtrx_AP 
				
				local estPignon = findItem m_this.idtrace_pignons i != 0 
				if  estPignon then (
					
					local moyenneZ = ( pt_suivant.z - pt.z ) /2					
					local vec_moyenne = [0,0,moyenneZ] * m_this.seuil_ortho / 100
					pt 			= m_this.trace_courant[i]	* inverse  mtrx_AP  + vec_moyenne 
					pt_suivant 	= m_this.trace_courant[j]	* inverse  mtrx_AP  - vec_moyenne 
					
					m_this.trace_courant[i] = pt *   mtrx_AP 
					m_this.trace_courant[j] = pt_suivant  *   mtrx_AP 
				) 
			) */
			
	-- 			result
		),
		fn souder 					=(
			
			local i = 1
			while i <=m_this.trace_courant.count do (
				local j= i+1
				if j > m_this.trace_courant.count  do j =1
				local pt 			= m_this.trace_courant[i]
				local ptSuivant 	= m_this.trace_courant[j]
				if distance pt ptSuivant <= m_this.seuil_souder do (
					deleteitem m_this.trace_courant j
					m_this.trace_courant[i] = ( pt + ptSuivant ) / 2
					i = 1
				)
				i+=i
			)
			
		),
		fn optimiser 				=(
			
			local i = 1
			while i <= m_this.trace_courant.count do (
				
				local h = i - 1
				if h < 1  do h = m_this.trace_courant.count
				local j= i+1
				if j > m_this.trace_courant.count  do j =1
				local ptDAvant 	= m_this.trace_courant[h]
				local pt 			= m_this.trace_courant[i]
				local ptSuivant 	= m_this.trace_courant[j]
				
				local vec1 = normalize (ptDAvant - pt)
				local vec2 = normalize (ptSuivant - pt)
				
				local anglePt = acos(dot vec1 vec2)			
				if 	anglePt >= 180 - m_this.seuil_optimiser  then (
					deleteitem m_this.trace_courant i
					i = 0
				)
				dot
				i +=1
			)

			result
		),
		fn chercher_alignements		_idTest				=(
			
			local seuil 			= m_this.seuil_aligner	
			local mtrx_AP 	= m_this.axeP_mtrx
			local pt_test					= m_this.trace_courant[_idTest]		* inverse  mtrx_AP
			local result =#()
		
			for i = 1  to m_this.trace_courant.count do (
				
				local j 				= boucler 	m_this.trace_courant	( i + 1)
				local pt 			= m_this.trace_courant[i]	* inverse  mtrx_AP
				local pt_suivant 	= m_this.trace_courant[j]	* inverse  mtrx_AP
				
				
				if estPignon  	_idTest		 and estPignon  i 	 					do 	(
					if abs ( pt_test.z - pt.z ) < seuil do 
						appendIfUnique result i
					if abs ( pt_test.z - pt_suivant.z ) < seuil do 
						appendIfUnique result i
				)
				
				if not estPignon  	_idTest		 and not estPignon i  	do (
					if abs ( pt_test.x - pt.x ) < seuil do
						appendIfUnique result i
					if abs ( pt_test.x - pt_suivant.x ) < seuil do 
						appendIfUnique result i
				)
				
			)
				
				

			result
		),
		fn aligner						=(	
			
			local mtrx_AP 	= m_this.axeP_mtrx
			
			for i = 1 to   m_this.trace_courant.count  do (
				
				local aligns = 	chercher_alignements		i			
				
				local pt_moyenne = [0,0,0]
				for id_align in aligns do 
					pt_moyenne += m_this.trace_courant[id_align]	* inverse  mtrx_AP
				pt_moyenne /=  aligns.count
				
				for id_align in aligns  do (
					
					local j 						= boucler m_this.trace_courant (  id_align + 1 )
					local pt 					= m_this.trace_courant[id_align]	* inverse  mtrx_AP  
					local pt_suivant 			= m_this.trace_courant[j]	* inverse  mtrx_AP  
					local vec_moyenne1 	= pt_moyenne	 - pt
					local vec_moyenne2 	= pt_moyenne	 - pt_suivant
					local vec_align1, vec_align2
					if estPignon  	id_align		 then (
						vec_align1 			= [0,0,vec_moyenne1.z] 
						vec_align2 			= [0,0,vec_moyenne2.z] 						
					) else (
						vec_align1 			= [vec_moyenne1.x,0,0] 
						vec_align2 			= [vec_moyenne2.x,0,0] 
					)
					
					pt 							= m_this.trace_courant[id_align]	* inverse  mtrx_AP  	+ vec_align1 
					pt_suivant 					= m_this.trace_courant[j]			* inverse  mtrx_AP  	+ vec_align2
					
					m_this.trace_courant[id_align] 	= pt *   mtrx_AP 
					m_this.trace_courant[j] 			= pt_suivant *   mtrx_AP 
					
				)
			)
		),
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
				
-- 				format "pas parallele"
				
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
-- 				if a1 != a2 then (
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
-- 				)
				
				-- si on a un point on verifie la suite -----------------------------
				if x != undefined do (
					
					local pt_proj  = [x,0,y]
					
-- 					--- si le point projeté
-- 					if distance pt_proj  	_pt_seg_1 > seuil  and distance pt_proj  	_pt_seg_2 > seuil  do (
-- 						
-- 						format ", sup au seuil"*
					
						--- si projection est dans le bon sens ----------
						if   dot  ( normalize ( _pt_orig - _pt_2 ) )  (  normalize (   pt_proj - _pt_orig) )   > 0 do (
							
-- 							format ", on est dans le bon sens"
							local precision = 1000
							local dist_seg 		= ( ( distance _pt_seg_1 	_pt_seg_2 ) * precision as integer ) / precision
							local dist_ptProj 		= ( ( distance _pt_seg_1 	pt_proj 		+ distance _pt_seg_2 	pt_proj ) * precision as integer ) / precision							
-- 							format "( dist_seg: %,  dist_ptProj:%)" dist_seg  dist_ptProj
							
							if  dist_ptProj  as string == dist_seg as string  do (
-- 								format "PROJECTION ! \n"
-- 								format ", et on est dans le segment !"
								pt_result 	= pt_proj
							)
						)
-- 					)
				)
				
-- 				format "\n"
			)
			pt_result
		),
		fn projeter_trace		 		=(
			
			local mtrx_AP 	= m_this.axeP_mtrx
			local seuil = 5
			local result
			local trace 		= m_this.trace_courant
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
			
			m_this.trace_courant = trace_temp
			
		),
		fn chercher_pt_a90degGauche	_id_pt  	vec_pt		 =(
			
			local seuil = 1
			
-- 			format "chercher_pt_a90degGauche: %\n" _id_pt
			local vertexSurLigne = #()
			local mtrx_AP 		= m_this.axeP_mtrx
			
-- 			local id_pt_preced 	= boucler 	m_this.trace_courant	(_id_pt - 1)
			local pt 				= m_this.trace_courant[ _id_pt ] 			* 	inverse  	mtrx_AP	
-- 			local pt_preced 		= m_this.trace_courant[ id_pt_preced ] * 	inverse  	mtrx_AP	
			
-- 			local vec_pt 			= pt - pt_preced
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
				for i=1 to m_this.trace_courant.count do (
					local pt_test = m_this.trace_courant[i] * 	inverse  	mtrx_AP	
					-- y = a*x + b
					if  abs ( pt_test.z - ( pt_test.x * a + b ) ) < seuil do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
-- 						format "dot_test_dir: %\n" dot_test_dir
-- 						format "norm_pt: %\n" (normalize vec_pt )
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			) else (
				for i=1 to m_this.trace_courant.count do (
					local pt_test = m_this.trace_courant[i] * 	inverse  	mtrx_AP	
					-- y = a*x + b
					if  abs ( pt_test.x - pt.x ) < seuil  do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
-- 						format "dot_test_dir: %\n" dot_test_dir
-- 						format "vec_pt: %\n" (normalize vec_pt )
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			)
			
-- 			format "->	vertexSurLigne: %\n" vertexSurLigne
			vertexSurLigne
			local result 
			local dist_min = 0
			for id_pt_test in vertexSurLigne do (
				local pt_test = m_this.trace_courant[ id_pt_test ] 			* 	inverse  	mtrx_AP	
				local dist_test = distance pt pt_test
				if  dist_test < dist_min or dist_min == 0 do (
					result = id_pt_test
					dist_min = dist_test
				)
			)
			
-- 			format "->	result: %\n" result
			result
			
		),
	/* 	fn unir_traces 	_rect1 	_rect2 =(
	
			format "unir_traces ->	_rect1 : %	_rect2:%\n" _rect1 _rect2
			local result = #()
			local ptsCommuns_trouve = false
			local idCommun_rect1 = 0
			if _rect1.count == 0 then (
				result = _rect2
			) else (
				
				--- on cherche  pt commun 1 -------
				local ptsCommuns =#()
				for i = 1 to  _rect1.count  do (
					local id1 = _rect1[i]
					local id2 =	finditem 	_rect2	 id1
					if  id2 != 0 then (
			 			append ptsCommuns id1
					)  
				)
				
				if ptsCommuns.count >= 2 then (
					for i = 1 to  _rect1.count  where not  ptsCommuns_trouve  do (
						local id1 = _rect1[i]
						local id2 =	finditem 	_rect2	 id1
						append result id1
						if  id2 != 0 then (
							append ptsCommuns id1
							
							ptsCommuns_trouve = true
							idCommun_rect1 = i
							local id_pt1 = boucler  _rect2  (  id2 + 1 )
							local id_pt2 = boucler  _rect2  (  id2 + 2 )
							append result 	_rect2[ id_pt1 ]
							append result 	_rect2[ id_pt2 ] 
						)  
					)
					for i = idCommun_rect1 + 1 to _rect1.count  do (
						append result 	_rect1[i]
					)
					format "unir_traces ->	result : %\n" result
				)
				
			)
			result
			
		),
		 */
		

		fn unir 	_listeTraces 	=(
			
-- 			format "unir 	_listeTraces : %\n" _listeTraces
			local traces = #() --for trace in _listeTraces collect trace
			
			for trace in _listeTraces do (
				local traceTmp = for _pt  in trace collect _pt
					append traces traceTmp
			)
				
			
			
			local continu = true
			local suivant = false
			local idTrace1 = 1
			local idTrace2 = 1
			local trace1, trace2
		-- 	local result 	= #()
			
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
				-- 			append result id1
							if  id2 != 0 then (
-- 								format "	-> id2 : %\n" id2
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
-- 					)
				)
				if suivant == false do (
					idTrace1 += 1
				)
-- 			format "idTrace1 : %	traces.count :%\n" idTrace1 traces.count
				if idTrace1 > traces.count - 1 do (
					continu = false
	-- 				append result trace1
				)
			) -- fin du while --------
			
			
-- 			format "traces : %\n" traces
			traces
			
			
			
		),
		fn subdiviser		 		=(
			
			--- on  les points projetés au tracé --------
			projeter_trace 		()
			
			
			
			local result = #()
			local result_reste =#()
			
			m_rectangles_traces 		= #()
			
			
			local seuil 					= 1
			local mtrx_AP 			= m_this.axeP_mtrx
			local trace 				= m_this.trace_courant
			
			
			for i = 1 to  trace.count 	do (
-- 			format "	->	subdiviser, i: %\n" i
				
				local pt_orig			= 	trace[ i ]	* 	inverse  	mtrx_AP 
				local id_pt_preced 	= boucler 	trace	( i - 1)
				local pt_preced 		= trace[ id_pt_preced ] * 	inverse  	mtrx_AP	
				local vec_pt 			= pt_orig - pt_preced		
				local id_pt_1, id_pt_2, id_pt_3, id_pt_4
				
				id_pt_1	= chercher_pt_a90degGauche	i 	vec_pt	 
				
				if id_pt_1 != undefined then (
					local norm 		= vec_pt * (rotateY	(matrix3 1)	90 )
					id_pt_2				= chercher_pt_a90degGauche	id_pt_1 	norm		 
				)  				
				if id_pt_2 != undefined then (
					local norm	 	= vec_pt * (rotateY	(matrix3 1)	180 )
					id_pt_3 				= chercher_pt_a90degGauche	id_pt_2 	norm	 
				)  				
				if id_pt_3 != undefined then (
					local norm	 	= vec_pt * (rotateY	(matrix3 1)	270 )
					id_pt_4 				= chercher_pt_a90degGauche	id_pt_3 	norm	 
				)  
				
				---- si on a les quatre points -------
				if id_pt_4 == i do (
					
					local pt_rect_1 = trace[ id_pt_1 ]	* 	inverse  	mtrx_AP 
					local pt_rect_2 = trace[ id_pt_2 ]	* 	inverse  	mtrx_AP 
					local pt_rect_3 = trace[ id_pt_3 ]	* 	inverse  	mtrx_AP 
					
-- 					format "	->	subdiviser, id_pt_1: %\n" id_pt_1
-- 					format "	->	subdiviser, id_pt_2: %\n" id_pt_2
-- 					format "	->	subdiviser, id_pt_3: %\n" id_pt_3
					
					local surf = ( distance pt_orig pt_rect_1 ) * ( distance pt_orig pt_rect_3 )  / 10000
					
					local rect =  #( i, id_pt_1, id_pt_2, id_pt_3 )
-- 					format "	->	subdiviser, rect: %\n" rect
					
					local rect_ordo = ordonner_Points 	rect
-- 					format "	->	subdiviser, rect_ordo: %\n" rect_ordo
					append m_rectangles_traces 		rect_ordo
-- 					format "->	subdiviser, m_rectangles_traces: %\n" ( m_rectangles_traces )
					virerDoublonsDansTableau 	m_rectangles_traces
					
-- 				format "->	subdiviser, m_rectangles_traces: %\n" ( m_rectangles_traces )
				)
			) -- fin while i  --
			
-- 			format "	->	subdiviser, m_rectangles_traces: %\n" ( m_rectangles_traces )
			
		),
		fn decouper 		 		=(
			
			
			--  points concaves -----------------
			
			
			local result = #()
			local result_reste =#()
			
			
			
			local seuil 					= 1
			local mtrx_AP 			= m_this.axeP_mtrx
			local trace 				= m_this.trace_courant
			local trace_restant 		= for i = 1 to trace.count collect i
			
-- 			--- creer la face tracé pour tester intersection ------------
			
			for sstrace in   m_rectangles_traces 	do (
				
				local estValide = true
				
				local pt_rect_1 = trace[ sstrace[ 1 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_2 = trace[ sstrace[ 2 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_3 = trace[ sstrace[ 3 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_4 = trace[ sstrace[ 4 ] ]	* 	inverse  	mtrx_AP 
				
				local surf = ( distance pt_rect_2 	pt_rect_1 ) * ( distance pt_rect_1 pt_rect_4 )  / 10000
				
				
				if m_this.sousTraces_surf_min_use do
					if surf < m_this.sousTraces_surf_min do estValide = false
				if m_this.sousTraces_surf_max_use do
					if surf > m_this.sousTraces_surf_max do estValide = false
									
				if estValide then (
					local nvTrace = str_ssTrace 		trace:sstrace		etages:m_this.sousTraces_etages
					appendIfUnique result  nvTrace
					
				) else (
					
					append result_reste 		sstrace
					virerDoublonsDansTableau 		result_reste
					
				)
			
-- 			format "découpage, result_reste: %\n" ( result_reste )
			) -- fin while i  --
			
-- 			format "découpage, result_reste: %\n" ( result_reste )
			result_reste = unir  result_reste
-- 			
-- 			format "découpage, result_reste: %\n" ( result_reste )
			if result_reste.count >0 do (
				for traceResultRest in result_reste do (
					local nvTrace = str_ssTrace 	trace:traceResultRest	etages:m_this.niveaux_nbre
					append  result  nvTrace
				)
			)
			
-- 			virerDoublonsDansTableau 	result
-- 			format "découpage, m_sousTraces: %\n" ( result )			
-- 			format "			-> m_rectangles_traces: %\n" ( m_rectangles_traces )
			
			m_sousTraces = result
			
		
			
		
		),
		
	 
		
		/* 
		---- sous tracés ------------
		fn params_toStructs 	m_this	=		(		
			------ Modeles -------
			m_regles_ssTrace				= #()
			for regle_ssTrace in m_this.m_regles_ssTrace 	do (
				local nvl_regleSsTrace = str_regle_ssTrace ()
				m_datasMgr.set_datas_string		regle_ssTrace		nvl_regleSsTrace		m_this
				append 	m_regles_ssTrace		nvl_regleSsTrace
			)
			
			m_sousTraces		= #()		
-- 			set_datas_string 		_datas_string 		_element 	m_this	
			for sousTrace_string in m_this.m_sousTraces 	do (
				local ssTrace =	m_datasMgr.get_string_to_array		sousTrace_string	
				append 	m_sousTraces		ssTrace
			)
			
			
			
			
		),
		fn structs_toParam 	m_this	=		(			
			
			m_this.m_regles_ssTrace	= #()			
			for regle_ssTrace in m_regles_ssTrace 	do (
				local regle_string = 	m_datasMgr.get_datas_string		regle_ssTrace	
				append 	m_this.m_regles_ssTrace		regle_string
			)
			
			m_this.m_sousTraces		= #()		
			for sousTrace in m_sousTraces 	do (
				local ssTrace_string = 	m_datasMgr.get_array_to_string		sousTrace	
				append 	m_this.m_sousTraces		ssTrace_string
			)
			
			
		),
		
		fn ajouter_sousTrace	m_this =(	
			local nvl_regleSsTrace = str_regle_ssTrace ()
			append 	m_regles_ssTrace		nvl_regleSsTrace
			structs_toParam m_this
		),
		
		fn supprimer_sousTrace	_id	m_this =(	
			deleteItem m_regles_ssTrace 	_id
			deleteItem m_this.m_regles_ssTrace 	_id
-- 			structs_toParam 	m_this
		),
		
		 */
		
		
		------------tracé du batiment ---------------
		fn fromSpline 		_shapeNvtrace 	= (
			
			local trace_absolu					=#()
			local subSplineOuvertes 		=#()
			local nvtraceTMP 					=  copy _shapeNvtrace
			local id_premiertraceFerme 	= 0
			
			--- on ne prend que la premiere spline fermée-----
			convertToSplineShape nvtraceTMP
			local b_trouve = false
			for idSpline = 1 to (numSplines nvtraceTMP) while not b_trouve	do
				if isClosed  nvtraceTMP	idSpline	then	(
					id_premiertraceFerme = idSpline
					b_trouve = true
				)
			
			---- si on a trouvé la spline --------------------
			if id_premiertraceFerme != 0 do (
				
				---- mise a jour de trace_courant -----------
				for id_pt = 1 to ( numKnots 	nvtraceTMP 	id_premiertraceFerme ) do	 (
					ptSpline = ( getKnotPoint 	nvtraceTMP 	id_premiertraceFerme 	id_pt ) 
	-- 				ptSpline.z = 0
-- 					debug "ptSpline" var:ptSpline
					append trace_absolu 	 ptSpline
				)
				
				--- on fait tourner les spline dans le meme sens ----
				if not est_sensPositif 	trace_absolu 	 do
					trace_absolu = reverse		trace_absolu
			)
-- 			
			--- suppression de tracée temp -------------
			delete nvtraceTMP
			
			trace_absolu
		),
		
		
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		----------- INTERFACE ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	public
		---- Actualiser ----
		fn actualiser 	 	=(
-- 			
			
			m_this.trace_courant = m_this.trace_original as array
			actualiser_axeP 	()
			
			---- orthonormer -----------
			if m_this.trace_ortho 			do	orthonormer	()
			if m_this.trace_souder		do	souder			()
			if m_this.trace_optimiser 	do	optimiser		()
			if m_this.trace_aligner 		do	aligner 			() 	
			subdiviser		() 	
			if m_this.sousTraces_use 	then	decouper 		() 		
			else (
				local nvTrace = str_ssTrace 	trace:(for i = 1 to m_this.trace_courant.count collect i ) 	etages:m_this.niveaux_nbre
				m_this.trace.m_sousTraces = #(nvTrace)
			)
		 
			m_this.sousTraces = for ssTrace in m_sousTraces collect m_datasMgr.get_datas_string  ssTrace
		),
		
		---- Accessions ----
		fn 	sousTrace_fromString  	_string	_sousTrace		=	m_datasMgr.set_datas_string 		_string 		_sousTrace,
		fn 	est_pignon 		_id	= estPignon 		_id,
		
		
		fn definir	 	_shapeNvtrace  		_thisNode		=(
			
			local trace_absolu					= fromSpline 	_shapeNvtrace
			if trace_absolu.count > 0 do (
				
				-- on vide les tableaux ----
				_thisNode.trace_original 			=#()
				_thisNode.trace_courant			=#()
				
				_thisNode.transform = (matrix3 1)
				ResetPivot 			_thisNode
				
				---- centrer le pivot ----
				local pt_sommeDesPts = 0
				for pt in trace_absolu do
					pt_sommeDesPts += pt
				local pt_centre = pt_sommeDesPts / trace_absolu.count
				_thisNode.pos = pt_centre
				
				---- actualiser les tracés ----
				for pt in trace_absolu do (
					append _thisNode.trace_original			( pt * inverse _thisNode.transform )
					append _thisNode.trace_courant 		( pt * inverse _thisNode.transform )
				)
				
				--- Axe principal-------------------coordsys
				_thisNode.a_un_trace 			= true
				
				----- calcul de la surface du trace_courant ------
				_thisNode.surface = surface 		_thisNode.trace_courant
			)
			actualiser  ()
		)
		
) -- fin struct TRACE ---------



















