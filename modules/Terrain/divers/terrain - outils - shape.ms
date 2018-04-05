

struct str_datasToString (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = false,
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:"urba | str_datasToString"	catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	public
		m_prt,
	
	private
		separateur_params 			= "§",
		separateur_mutation 			= "¨",
		separateur_mutationTab 	= "£",
		separateur_items 				= "^",
	
	public
		fn toString		_tab	=(
			local tabString = ""
			for item in _tab do (
				debug "toString" var:(classof item)
				case classof item  of (
					
					string:		tabString += item 	as string + separateur_items
					Integer:		tabString += item 	as string + separateur_items
					Float:		tabString += item 	as string + separateur_items
					Point3:		tabString += item 	as string + separateur_items
					Array:		tabString += item 	as string + separateur_items
					
					---- les reste doit etre nos struct a nous ... -------
					default:		tabString += item 	as string + separateur_items
					
				)
			)
			tabString
		),
		fn toArray		_string	=(
			
			local tabResult = #()
			local items 	= filterString 	_string 		separateur_items
			
			for item in items do (
				
				local data_exe 	
				try data_exe = execute item catch ()
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
							local tabString = toString		prop
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
							debug "<<<<<<<<<<<<		set_datas_string	>>>>>>>>>>><>>><"
			if _datas_string != undefined then (
				local datasTab 	= filterString 	_datas_string 		separateur_params
				for datas in datasTab do (
					local dataTab		= filterString datas 	separateur_mutation
					local propNom 	= dataTab[1]
					debug "<<<<<<< propNom >>>>>>>" var:propNom
					local typeProp 	
					if  hasProperty _element propNom do
						typeProp 	= classof ( getProperty _element propNom  )
					debug "<<<<<<< typeProp >>>>>>>" var:typeProp
					case typeProp of (
						--- les trucs qu'on zappe ------
						MAXScriptFunction:	()
						RolloutClass:()
						--- les trucs qu'on prend en compte	------
						string:		(
							debug "string"
								local data =   dataTab[2]
								if data   == undefined do data =""
								setProperty _element propNom data
							debug "data" var:data
						)
						array: (
							debug "array"
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
							debug "data" var:tabResult
							)
						)
						default:						(
							debug "default" 
							/* 
							if dataTab[2] != undefined do  (							
								local data 		
								if execute dataTab[2]	 != undefined then
									data = execute dataTab[2]	
								else if	dataTab[2] == "undefined" then
									data = undefined
								else
									data = dataTab[2]	
								setProperty _element propNom data
								debug "data" var:data 
							*/
							if  hasProperty _element propNom do
								if dataTab[2] != undefined do  (						
									local data 		
									if execute dataTab[2]	 != undefined then
										try data = execute dataTab[2]	catch data = dataTab[2]	
									else
										data = dataTab[2]	
									
									if	data== "undefined" then
										data = undefined
									
									setProperty _element propNom data
									debug "data" var:data
								)						
						) -- fin default 
					) --- fin case ----------
				)
			)
			_element = undefined
		)

)

struct	str_terrain_outils_shape (
		
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	try if true  do ::debuger 	_txt	prefix:"urba | str_terrain_outils_shape"	  	var:var	 param:param		catch (),
		------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		precision_courbe 		= 50,			--- en cm. ----
		
	private
		fn point_estAGauche		_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
-- 				format "point_est_aGaucheDuSegment : %\n" sens
			sens
			
		),
		----- accessions divers  ---------------
		fn get_longueur_segment	_shp	_id_spline	_id_pt 	=(
			
			local tab_longueurs_sgts		=	getSegLengths 	_shp 	_id_spline	 cum:false byVertex:true numArcSteps:100
			local nbr_pts_total 				=	numknots	 		_shp	_id_spline
			local longueur_result			= 	tab_longueurs_sgts[ nbr_pts_total + 2 + _id_pt]
			longueur_result
		),
		fn get_intersection_vecteurs		vec1_pt_1   vec1_pt_2		vec2_pt_1	vec2_pt_2 =(
			

			local pt_intersec
			
			local vec_1 = vec1_pt_2 - vec1_pt_1
			local vec_2 = vec2_pt_2 - vec2_pt_1
			
			
			if vec_1.x*vec_2.y-vec_1.y*vec_2.x != 0 then (
				
				local coef_vec2 = -(-vec_1.x*vec1_pt_1.y+vec_1.x*vec2_pt_1.y+vec_1.y*vec1_pt_1.x-vec_1.y*vec2_pt_1.x)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				local coef_vec1 = -(vec1_pt_1.x*vec_2.y-vec2_pt_1.x*vec_2.y-vec_2.x*vec1_pt_1.y+vec_2.x*vec2_pt_1.y)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				
				if coef_vec1 > 0 and coef_vec1 < 1 and coef_vec2 > 0 and coef_vec2 <1 do
					pt_intersec	= vec2_pt_1 + coef_vec2*vec_2
				
			)
			
			pt_intersec
			
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
			debug "est_sensPositif"
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
			
			debug "est_sensPositif" var:result
			
			result
			
		),
		fn changer_sens 					_pts 		=(
			debug "changer_sens"
			local result =#()
			for i= _pts.count to 1 by -1 do 
				append result 	_pts[i]
			result
		),
	
		----- manipulation de  shape  ---------------
		fn nettoyer_points_inutiles	_pts	 	_seuil:.9999		=(
			
			local dotmax_courbe 	= _seuil	--- en dot ?!?. ----
			local pts_result 			= deepCopy	_pts
			
			---- pour chacune des splines du shape ----------------
			for id_spline_contour	=	1	to  pts_result.count do (
				
				local pt_result 			= 	#()
				local ids_aSupprimer 	=	#()
				local pts 					= 	pts_result[id_spline_contour]
				
				for id_pt_contour	=	1	to pts.count do (
					
					local pt_contour  = pts[ 	id_pt_contour]
					local id_pt_svt 	= if id_pt_contour == pts.count then 1 else id_pt_contour + 1
					local pt_suivant  = pts[ 	id_pt_svt ]
					
					local id_pt_avt	= if id_pt_contour == 1 then pts.count else id_pt_contour - 1
					local pt_precedant  = pts[ id_pt_avt ]
					
					local vec_1 = pt_suivant 		- pt_contour
					local vec_2 = pt_precedant 	- pt_contour
					
					
					local dot_vecs = dot (normalize vec_1) 	(normalize vec_2)
					
-- 					debug "------------>	dot_tangents" var:dot_tangents
					
					if abs dot_vecs >=	dotmax_courbe do (
						append ids_aSupprimer 	id_pt_contour
					)
					
				)
				
				
				for i = ids_aSupprimer.count to 1 by -1 do
					deleteItem pts_result[id_spline_contour]  ids_aSupprimer[i]
				
			)
			
			pts_result
		),
		fn interpoler_shape 	_shp		=(
			
			local result	=#()
	
			local dotmax_courbe 		= .999	--- en dot ?!?. ----
			
			m_pts_contour = #()
			
			
			---- pour chacune des splines du shape ----------------
			for id_spline_contour	=	1	to numsplines  _shp do (
				
				local pts_spline_contour = for j= 1 to numKnots 	_shp	id_spline_contour	 collect getKnotPoint _shp 		id_spline_contour	 	j 
				local pt_result 	= #()
				for id_pt_contour	=	1	to pts_spline_contour.count do (
					
					local pt_contour  		= getKnotPoint _shp 		id_spline_contour	 	id_pt_contour
					local id_pt_contour_svt = if id_pt_contour != pts_spline_contour.count then id_pt_contour + 1 else 1
-- 					local pt_contour_svt  	= getKnotPoint _shp 		id_spline_contour	 	id_pt_contour_svt
					
					local pt_contour_type 			= getKnotType 		_shp  id_spline_contour	 id_pt_contour
					local pt_contour_svt_type 	= getKnotType 		_shp  id_spline_contour	 id_pt_contour_svt
					
					if pt_contour_type != #corner or pt_contour_svt_type != #corner then (
						
						----- Interpolation  - adaptif ----------------------------					
						local longueur_segment 	= get_longueur_segment	_shp	id_spline_contour		id_pt_contour 
						local pos_courbe 			= 0
						local nbr_division 			= floor ( longueur_segment / precision_courbe)
						local increment_courbe 	= 1 / nbr_division
						
						local tangent					=	normalize ( tangentBezier3D   _shp 	id_spline_contour 	id_pt_contour 		0 )
						local tangent_derniere		= 	tangent
						
						append pt_result	( interpBezier3D 		_shp 	id_spline_contour 	id_pt_contour 		0 )
						
						while pos_courbe < 1 do (
							
	-- 							debug "---# pos_courbe # " var:pos_courbe
							local pt_interpol 	= interpBezier3D 		_shp 	id_spline_contour 	id_pt_contour 		pos_courbe
							tangent 				= normalize ( tangentBezier3D   _shp 	id_spline_contour 	id_pt_contour 		pos_courbe )
							
	-- 						debug "------------>	tangent  " var:tangent
							local dot_tangents = dot tangent tangent_derniere
							
	-- 						debug "------------>	dot_tangents" var:dot_tangents
							if dot_tangents <	dotmax_courbe do (
								tangent_derniere = tangent
								append pt_result	pt_interpol
							)
							pos_courbe	+= increment_courbe
							
						)
					) else append pt_result	pt_contour
-- 							)
-- 					) ---- fin case type -------------------
					
				)
				
			--- on met les points dans l'ordre	----------
				if not est_sensPositif 	pt_result 	 do
					pt_result = changer_sens		pt_result
				
				
				append result	pt_result
			)
			
			
			--- on recalle les points à la transform du shape ------------
			for shp in result do
				for pt in shp do
					pt += [10000,0,0]	---inverse _shp.transform
			
			result
		),
		
		
		
	public
		---- mutateur-------------------------------
		fn get_pts_from_shape			_shp 		transf: 	=	(
			
			debug "get_pts_from_shape"
			debug "_shp" var:_shp
			debug "_shp.transform" var:_shp.transform
			
			--- on créer les points à partir du shape	----------
			local pts_result 	=  interpoler_shape				_shp	transf:transf
			/* 
			--- on met les points dans l'ordre	----------
			for pts_spline_result in pts_result do
				if not est_sensPositif 	pts_spline_result 	 do
					pts_spline_result = changer_sens		pts_spline_result */
			
			--- on supprime les points en ligne droite	----------
			pts_result 			= nettoyer_points_inutiles  	pts_result
			
			
			pts_result
		)
		
			
	
)













