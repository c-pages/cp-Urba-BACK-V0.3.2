

struct str_datasToString (
	
		m_prt,
		
	private
		separateur_params 			="§",
		separateur_mutation 			= "¨",
		separateur_mutationTab 	= "£",
		separateur_items 				= "^",
	
	
	public
		fn array_to_string		_tab	=(
			local tabString = ""
			for item in _tab do (
				case classof item  of (
					string:	tabString += item 		as string + separateur_items
					Integer:	tabString += item 		as string + separateur_items
					Float:	tabString += item 		as string + separateur_items
					Point3:	tabString += item 		as string + separateur_items
					Array:	tabString += item 		as string + separateur_items
					
					---- les reste doit etre nos struct a nous ... -------
					default:	tabString += item.id 	as string + separateur_items
				)
			)
			tabString
		),
		fn string_to_array		_string	=(
			
			local tabResult = #()
			local items 	= filterString 	_string 		separateur_items
			
			for item in items do (
				local data_exe 	= execute item
				--------------- string ---------------
				if data_exe 		== undefined then 
					append tabResult ( item )
				else 
					append tabResult 	data_exe
				/* --------------- un objet ---------------
				else	if classof data_exe == Name then (
					local elemTmp =  ( m_prt.get_parametre	  item 	)						
					--- un id (name)------
					if elemTmp == undefined do	elemTmp = item
					append tabResult		elemTmp
				--------------- Nombres ---------------		
				) else 	append tabResult 	( data_exe)
				 */
			)
			tabResult
		),
		
	public
		fn get_datas_string 		_element	=(
			local txtResult = ""
			
			if _element != undefined do (
				local propNames = getPropNames _element
				for param in propNames do (
					local prop = ( getProperty  _element 	param )
					local type = classof prop
					case type of (
						--- les trucs qu'on zappe ------
						MAXScriptFunction:	()
						RolloutClass:()
						--- les trucs qu'on prend en compte	------
						array: (
							local tabString = array_to_string		prop
							txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
						)
						Name:		(
							txtResult+=  param as string  + separateur_mutation	+	"#" + prop as string  + separateur_params
						)
						default:						(
								txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
						)
					) -- fin scase --
					
				)
			)
			txtResult
			
		),
		fn set_datas_string 		_datas_string 		_element 		=(
			if _datas_string != undefined then (
				local datasTab 	= filterString 	_datas_string 		separateur_params
				for datas in datasTab do (
					local dataTab		= filterString datas 	separateur_mutation
					local propNom 	= dataTab[1]
					local typeProp 	= classof ( getProperty _element propNom  )
					case typeProp of (
						--- les trucs qu'on zappe ------
						MAXScriptFunction:	()
						RolloutClass:()
						--- les trucs qu'on prend en compte	------
						string:		(
								local data =   dataTab[2]
								if data   == undefined do data =""
								setProperty _element propNom data
						)
						array: (
							if dataTab.count >1 do (
								local datas_liste  = filterString	dataTab[2] 	separateur_items
								local tabResult =#()
								for data in datas_liste do (
									local data_exe 	= execute data
									--------------- string ---------------
									if data_exe 		== undefined then 	append tabResult ( data)
									--------------- un objet ---------------
									else	if classof data_exe == Name then (	
										local elemTmp =  ( m_prt.get_parametre	  data 	)	
										--- un id (name)------
										if elemTmp == undefined do	elemTmp = data
										append tabResult		elemTmp
									--------------- Nombres ---------------	
									) else 	append tabResult 	( data_exe)
								)
								setProperty _element 	propNom 	tabResult
							)
						)
						default:						(
							if dataTab[2] != undefined do  (							
								local data = execute dataTab[2]							
								setProperty _element propNom data
							)						
						)
					)
				)
			)
			_element = undefined
		)

)



struct str_mgr_arrayParametres (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_arrayParametres",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
	
	---- MEMBRES ----------------------------------------------------------------------------------------------------------------
	public
		m_plug,
		
	private
		---- la class de réference ----------
		m_class,
		
		---- Le tableau des éléments --------
		m_items	=	#(),
		
		
	---- FONCTIONS ----------------------------------------------------------------------------------------------------------------

	---- INTERFACE -------------------------------------------
	public
		fn initialiser		class:  plug: =(
			
			
			--- on vide les items ------
			m_items	=	#()
			
			-- on assigne les pointeurs -----------
			if class== unsupplied or plug == unsupplied do
				messagebox "str_mgr_arrayParametres : Probleme d'initialisation"
			m_class 	= 	class
			m_plug		=	plug
			
			
		),
		fn actualiser = (
			
		),
		
		---- Accessions ---
		fn get_parID  	_idUnique =(
			
			local result
			for item in m_items do
				if item.id == _idUnique do result = compo
			result
			
		),
		fn get_parIndex  	_index =(
			m_items[_index]			
		),
		
		fn get_noms 	=	for item in m_items collect item.nom,
		fn get_items	= 	m_items,
		
		
		---- Creation/Suppression ----
		fn creer		enregistrer:true		=(
			
			debug "creer"
			
			local nv_element = m_class ()
			append		m_items	nv_element
			
			if enregistrer do
				nv_element.enregistrer	 	m_plug
			
			nv_element
			
		),	
		
		fn supprimer 	_idUnique	=	(
			local elem_a_supprimer = get_parID	_idUnique
			elem_a_supprimer.supprimer		m_plug
		),
		
		fn charger =(
			
			for id in m_plug.fac_ids do (
				debug "charger" var:id
				nvFacade = creer	enregistrer:false
				nvFacade.charger 	m_plug		id
			)
		)
		
	
-- 		---- Parametres Block ----
-- 		fn lire			=	lire_parametres(),
-- 		fn ecrire			=	ecrire_parametres()
	
)	--	fin manager de composants ------







struct str_shape_outils (

	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = false,
	m_dbgPrefix ="urba | str_shape_outils",
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
	public
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
		fn chercher_pt_a90degGauche	_id_pt  	vec_pt		 =(
			
			local seuil = 1			
			local vertexSurLigne = #()
			local mtrx_AP 		= m_plug.axeP_mtrx			
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
			
			vertexSurLigne
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
		
		
		------Subdivision ----------------------------------------------------------
		
		fn scanner_points 	_shape	=(
			
			local ptsSurface				=#()
			
			---- On chope les points de la surface a scanner -----------
			for id_pt = 1 to ( numKnots 	_shape 	1 ) do	(
				local pt_shape 	= getKnotPoint 	_shape 	1 	id_pt
				local pt_surface 	= pt_shape * inverse  _shape.transform
				append ptsSurface 	 pt_surface
			)
			
			
			--- on fait tourner les spline dans le meme sens ----
			if not m_outils.est_sensPositif 	ptsSurface 	 do
				trace_absolu = m_outils.changer_sens		ptsSurface
			
			ptsSurface
			
		),
		fn subdiviser		 	_pts 		=(
			debug "subdiviser"
			
			--- on  les points projetés au tracé --------
			projeter		_pts
			
			local result = #()
			local result_reste =#()
			
			m_rectangles_traces 		= #()
			
			local seuil 					= 1
			local mtrx_AP 			= get_axePrincipal_mtrx 	_pts
			local trace 				= _pts
			
			for i = 1 to  trace.count 	do (
				
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
					
					local surf = ( distance pt_orig pt_rect_1 ) * ( distance pt_orig pt_rect_3 )  / 10000
					
					local rect =  #( i, id_pt_1, id_pt_2, id_pt_3 )
					
					local rect_ordo = ordonner_Points 	rect
					append m_rectangles_traces 		rect_ordo
					virerDoublonsDansTableau 	m_rectangles_traces
					
				)
			) -- fin while i  --
			
			
		),
		fn decouper 		 	_pts 		=(
			debug "decouper"
			
			
			--  points concaves -----------------
			
			
			local result = #()
			local result_reste =#()
			
			
			
			local seuil 				= 1
			local mtrx_AP 			= get_axePrincipal_mtrx 	_pts
			local trace 				= _pts
			local trace_restant 	= for i = 1 to trace.count collect i
			
			--- creer la face tracé pour tester intersection 	------------
			
			for sstrace in   m_rectangles_traces 	do (
				
				local estValide = true
				
				local pt_rect_1 = trace[ sstrace[ 1 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_2 = trace[ sstrace[ 2 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_3 = trace[ sstrace[ 3 ] ]	* 	inverse  	mtrx_AP 
				local pt_rect_4 = trace[ sstrace[ 4 ] ]	* 	inverse  	mtrx_AP 
				
				local surf = ( distance pt_rect_2 	pt_rect_1 ) * ( distance pt_rect_1 pt_rect_4 )  / 10000
				
				
				if m_plug.sousTraces_surf_min_use do
					if surf < m_plug.sousTraces_surf_min do estValide = false
				if m_plug.sousTraces_surf_max_use do
					if surf > m_plug.sousTraces_surf_max do estValide = false
									
				if estValide then (
					local nvTrace = str_ssTrace 		trace:sstrace		etages:m_plug.sousTraces_etages
					appendIfUnique result  nvTrace
					
				) else (
					
					append result_reste 		sstrace
					virerDoublonsDansTableau 		result_reste
					
				)
			
			) -- fin while i  --
			
			result_reste = unir  result_reste
			
			if result_reste.count >0 do (
				for traceResultRest in result_reste do (
					local nvTrace = str_ssTrace 	trace:traceResultRest	etages:m_plug.niveaux_nbre
					append  result  nvTrace
				)
			)
			
			
			m_sousTraces = result
			
		)
		
	
	
)


struct str_poly_outils (
	
	
		---- manipulation de tableaux ----
		fn ComparerTableaux 	first 	second =
		(
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
		
		
		
		
		
		
		---- groupes de selection  ----
		fn grouperFaces 	_node 	_faces 	_nom 	=(
			if _node.faces[_nom] == undefined  
							then		_node.faces[_nom] = 	_faces
							else		(								
								tabFaces = for face in _node.faces[_nom] collect face.index
								tabFaces += _faces
								_node.faces[_nom] = tabFaces
							)
		),
		fn degrouperFaces 	_node 	_facesARetirer 	_nom 	=(
			if _node.faces[_nom] != undefined  do		(								
				tabFaces = for face in _node.faces[_nom] collect 	face.index
					for  _face in _facesARetirer do (
						idItem = findItem tabFaces   _face
						if idItem >0 do deleteItem 	tabFaces  idItem
					)
				_node.faces[_nom] = tabFaces
			)
		),
		
		
		
		---- manipulation des selection  ----
		fn etendreSelecFaces		_node 	_faces	= (
			
			_faces_a_retirer = _faces 		---- ( polyop.getFaceSelection  _node ) as array
			_node.EditablePoly.GrowSelection ()
			_facesExtension	= ( polyop.getFaceSelection  _node ) 
			for face in _faces_a_retirer 	do _facesExtension	[face] 	= false
			polyop.setFaceSelection  _node 	_facesExtension	
			
		),
		
		fn etendreFaces		_node 	_faces	= (
			local selectBack = polyop.getFaceSelection  _node
			polyop.setFaceSelection  _node 	_faces
			_node.EditablePoly.GrowSelection ()
			local facesEtendus	=  polyop.getFaceSelection  _node 
			format "facesEtendus : %\n" facesEtendus
			polyop.setFaceSelection  _node  selectBack
			facesEtendus
		),
		
		fn facesDuDessous		_node	_faces	=	(
			
			local _selectBack 	= 	polyop.getFaceSelection  _node 
			local	_facesDuBas 	= #()
			for _face in _faces do (
				polyop.setFaceSelection  	_node 	#(_face)
				outils.etendreSelecFaces 	_node 	#(_face)
				facesCadre = polyop.getFaceSelection  _node
				local		_faceDuBas
				for _faceCadre in facesCadre do 
					if _faceDuBas == undefined 	
						then _faceDuBas = _faceCadre
					else	if ( outils.centreDeLaFace	_node	_faceCadre ).z  <  (outils.centreDeLaFace	_node	_faceDuBas ).z 	
						then _faceDuBas = _faceCadre
				
				append _facesDuBas _faceDuBas
			)
			
			format "Faces du bas : %\n" _facesDuBas
			polyop.setFaceSelection  _node 	_selectBack
			
			for _face in _facesDuBas do
				format "face : %  centre Z : % \n" 	_face	( outils.centreDeLaFace	_node	_face )
			
			
			_facesDuBas
		),		
		fn BACKfacesDuDessous		_node	_faces	=	(
			
			local	_facesDuBas = #()
			for _face in _faces do (
				polyop.setFaceSelection  _node 	#(_face)
				outils.etendreSelecFaces 		_node 	#(_face)
				facesCadre = polyop.getFaceSelection  _node
				local		_faceDuBas
				for _faceCadre in facesCadre do 
					if _faceDuBas == undefined 	then _faceDuBas = _faceCadre
						else	if ( outils.centreDeLaFace		_node		_faceCadre ).z  <  (outils.centreDeLaFace		_node		_faceDuBas ).z 	then _faceDuBas = _faceCadre
				
				append _facesDuBas _faceDuBas
			)
			
			format "Faces du bas : %\n" _facesDuBas
			_facesDuBas
		),
		
		fn faceLaPlusProche		_node		_faces		_ptReference 	= (							
			local faceLaPlusProche
			local distMin = 1000000000000.0
			for faceTmp in _faces do (
				centreFaceTmp 		= 		outils.centreDeLaFace		_node		faceTmp
				dist = length 	(  	centreFaceTmp - _ptReference )
				if dist < distMin do (
					distMin = dist
					faceLaPlusProche = faceTmp
				)
			)
			faceLaPlusProche
		),
		
		---- selection par taille ----
		fn arreteLaPlusPetite		_node		_listeArretes	= (
			
			local arretePlusPetite,  longMin
			
			for arrete in _listeArretes do (
				listePoints = polyop.getEdgeVerts  	_node	arrete
				pt1 = _node.verts[listePoints[1]]
				pt2 = _node.verts[listePoints[2]]
				longueurArrete =  length ( pt1.position	- pt2.position  )
				
				if longMin == undefined do (
					longMin = longueurArrete					
					arretePlusPetite = arrete
				)
				
				if longueurArrete < longMin do (
					longMin = longueurArrete
					arretePlusPetite = arrete
				)
				
			) -- fin for do --
			
			arretePlusPetite
			
		),
		fn arretesLesPlusPetites		_node		_listeArretes	 nbre: = (
			
			local _arretesPlusPetites,  longMin
			local _nbresArretes = floor ( (_listeArretes as array).count / 2 )
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresArretes	= floor ( (_listeArretes as array).count / 2 )
				else		_nbresArretes	= nbre
				
			while _result.count < _nbresArretes do (
				local _arreteAAJouter = arreteLaPlusPetite		_node		_listeArretes
				
				deleteItem	_listeArretes 	_arreteAAJouter
				append 		_result  		_arreteAAJouter
			)
			
			_result
			
		),		
		fn facesLesPlusPetites	_node	_faces	nbre: =(
			local _nbresFaces 
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresFaces	= floor ( (_faces as array).count / 2 )
				else		_nbresFaces	= nbre
			
			while _result.count != _nbresFaces do (
				local _min = 1000000000000000000000000000.0
				local _faceAAJouter
				for _face in _faces do (
					if polyop.getFaceArea _node _face <= _min  and (findItem _result _face ) == 0 do (
						_faceAAJouter 	= _face
						_min 				= polyop.getFaceArea _node _face 
					)
				)
				append _result 	_faceAAJouter
			)
			_result
		),		
		fn facesLesPlusGrandes	_node	_faces	nbre:  =(
			local _nbresFaces 
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresFaces	= floor ( (_faces as array).count / 2 )
				else		_nbresFaces	= nbre
			
			while _result.count != _nbresFaces do (
				local _min = 0.0
				local _faceAAJouter
				for _face in _faces do (
					if polyop.getFaceArea _node _face >= _min  and (findItem _result _face ) == 0 do (
						_faceAAJouter 	= _face
						_min 				= polyop.getFaceArea _node _face 
					)
				)
				append _result 	_faceAAJouter
			)
			_result
		),
		
		
		---- selection par position ----
		fn faceLaPlusHaute 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute = undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  > ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			faceHaute
		),		
		fn faceLaPlusBasse 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute == undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  < ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			 faceHaute
		),
		
		
		fn get_hauteurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local hauteur = BB[2].z -  BB[1].z 
			hauteur
		),
		fn get_largeurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local largeur = BB[2].x -  BB[1].x 
			largeur
		),
		fn get_angle_vecteur 	vec	=(
			
			local result = 0
			local angle_tan = atan ( vec.y / vec.x )
			
			if vec.x >=0 then (
				if vec.y >= 0 then 	result = angle_tan
				else 	result = 360 + angle_tan
			) else (		
				if vec.y >= 0 then 	result = 180 + angle_tan
				else result = 180 + angle_tan
			)
			
			result
		),		
		
		---- meusures ----
		fn ZMinFace 	_node  _listeFaces = (
			
			local pointLePlusBas
			
			for face in _listeFaces do (
				listePoints = polyop.getFaceVerts  	_node	face
				for IDpt in listePoints do (
					pt = _node.verts[IDpt]
					if pointLePlusBas == undefined do pointLePlusBas = pt.position.z
					if pointLePlusBas > pt.position.z do pointLePlusBas = pt.position.z
				)
			)			
			 	pointLePlusBas			
		),
		fn largeurFace 	_node _face = (
			local listePoints = polyop.getFaceVerts  	_node	_face
			local result = 0
			for  i=1 to listePoints.count-1 do (
				pt_1 = _node.verts[ listePoints[ i ] ]				
				for  j=i+1 to listePoints.count do (				
					pt_2 	= _node.verts[ listePoints[ j ] ]
					dist 		= length ( pt_2.position - pt_1.position )
					if pt_1.position.z == pt_2.position.z and dist > result
						do result = dist
				)
			)
			 result
		),
		fn hauteurFace 	_node 	_face = (
			local _listePoints = polyop.getFaceVerts  	_node	_face
			local _result = 0, _mini = 10000000000, _maxi = 0
			for  _pt in _listePoints 	do (
				_pt = _node.verts[ _pt ]		
				if _pt.position.z < _mini 	do _mini 	= _pt.position.z
				if _pt.position.z > _maxi 	do _maxi 	= _pt.position.z
			)
			_result = _maxi  - _mini
			_result
		),
		
		
		fn centreDeLaFace	_node	_face = (
			
			local versionMax = true
			local centre = [0,0,0]
			
			---- la version max fait  une position  moyenne de tout les points , => pb si 5points sur  la face par ex ----
			if versionMax then
				centre = polyop.getFaceCenter _node _face
			
			---- debut de version centre perso qui deconne ----
			else (
				
				local listePoints 							= polyop.getFaceVerts  	_node	_face
				local pointsAlignesVerticalement	= #()
				local ptsResult 								= #()
				local coinHtG, coinHtD, coinBsG, coinBsD
				
				---- regrouper les points alignés verticalement	----
				for  i=1 to listePoints.count do (
					
					local	ID_pt_1 	= listePoints[ i ] 
					local	pt_1 		= _node.verts[ ID_pt_1 ]				
					local resultTmp = #( ID_pt_1 )
					
					for  j=1 to listePoints.count do (
						ID_pt_2 = listePoints[ j ] 					
						pt_2 = _node.verts[ ID_pt_2 ]
						
						if floor (  pt_1.position.x * 10 )	== floor ( pt_2.position.x * 10 ) do 
							if floor ( pt_1.position.y * 10 ) == floor ( pt_2.position.y * 10 ) do 
								appendIfUnique resultTmp 		ID_pt_2
						
					)
					sort resultTmp
					
					if resultTmp.count > 1 do 	append 	 	pointsAlignesVerticalement 		resultTmp
					
				)
				
				virerDoublonsDansTableau  pointsAlignesVerticalement 
				
				---- selection dans chaque groupe de points du plus haut et du plus bas	----
				for listPts in pointsAlignesVerticalement do (
					---- min ----
					local minZ, maxZ
					for ptID in listPts do (
						if minZ == undefined do minZ = ptID
						if maxZ == undefined do maxZ = ptID
						
						if _node.verts[ ptID ].position.z > _node.verts[ minZ ].position.z   do minZ =ptID
						if _node.verts[ ptID ].position.z < _node.verts[ maxZ ].position.z  do maxZ =ptID
						
					)
					append ptsResult minZ
					append ptsResult maxZ
				)
				
				sort ptsResult
				
				---- moyenne des points hauts et bas	----
				if ptsResult.count != 0 do (
					for IDpt in ptsResult do  (
						centre += _node.verts[ IDpt ].position
						format "_node.verts[ IDpt ].position : %\n" _node.verts[ IDpt ].position
					)
					centre = centre / ptsResult.count
	-- 				format "	=>	centre : %\n" centre
				)
						format "face : %\n" 	_face
				format "	=>	centre : %\n" centre
				
				centre
			)
		) -- fin else
		
)	-- fin struct outils poly

