

plugin geometry  Urba_terrain
name:"Terrain"
classID:#(321546,753189)
category:"CP | Urba"
invisible:true
extends:editable_poly 
replaceUI:true 
version:0
(


		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	
		try if true  do ::debuger 	_txt	prefix:"urba | Urba_terrain"	  	var:var	 param:param	
		catch ()
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------




		
		include	 "$userScripts\\cp-Urba\\modules\\Terrain\\Terrain - triangulation.ms" 
		include	 "$userScripts\cp-Urba\modules\Batiment\\divers\\Batiment - Geometrie.ms"
		
		
		local geo			= 	str_geometrie 		m_plug:this
		local trianguler 	= 	str_triangulation_shape ()
		
		parameters main rollout:params		(
			terrain_shape			type:#node 		ui:btn_trace_pick		animatable:false		invisibleInTV:true
			terrain_relief			type:#node 		/* ui:btn_trace_pick	 */	animatable:false		invisibleInTV:true
			terrain_precision		type: #float	 	ui:spn_precision 		default:300.		 	animatable:false		invisibleInTV:true
			
			
		)
		rollout params "Terrain" width:162 height:49
		(
			
			fn shape_filt 		obj = superclassof obj == shape
			
			pickbutton 'btn_trace_pick' "Pick shape" pos:[16,4] width:125 height:20 filter:shape_filt autoDisplay:true align:#left
			spinner 'spn_precision' "" pos:[72,26] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			label 'lbl_precision' "Précision:" pos:[15,25] width:44 height:14 align:#left
		)
		
		
		
		
		fn get_BB_shape =(
			local result #([0,0,0],[0,0,0])
			local pts_contour = #()
			for i = 1 to numSplines  this.terrain_shape do 
				append pts_contour ( for j= 1 to numKnots 	this.terrain_shape collect getKnotPoint this.terrain_shape i j )
			
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
			
		)
		
		
		
		fn get_intersection_vecteurs		vec1_pt_1   vec1_pt_2		vec2_pt_1	vec2_pt_2 =(
			
			local pt_intersec
			
			local vec_1 = vec1_pt_2 - vec1_pt_1
			local vec_2 = vec2_pt_2 - vec2_pt_1
			
-- 			pt_P = vec1_pt_1 + coef_vec1*vec_1
-- 			pt_P = vec2_pt_1 + m*vec_2
			
			if vec_1.x*vec_2.y-vec_1.y*vec_2.x == 0 then (
-- 				debug "##### PARALLELES #####"
			) else (
				
				local coef_vec2 = -(-vec_1.x*vec1_pt_1.y+vec_1.x*vec2_pt_1.y+vec_1.y*vec1_pt_1.x-vec_1.y*vec2_pt_1.x)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
				local coef_vec1 = -(vec1_pt_1.x*vec_2.y-vec2_pt_1.x*vec_2.y-vec_2.x*vec1_pt_1.y+vec_2.x*vec2_pt_1.y)/(vec_1.x*vec_2.y-vec_1.y*vec_2.x)
-- 				debug "coef_vec1" var:coef_vec1
-- 				debug "coef_vec2" var:coef_vec2
				
				if coef_vec1 > 0 and coef_vec1 < 1 and coef_vec2 > 0 and coef_vec2 <1 do
					pt_intersec	= vec2_pt_1 + coef_vec2*vec_2
-- 					pt_intersec	= vec1_pt_1 + coef_vec1*vec_1
				
			)
			
			pt_intersec
			
		)
		
		fn projectionZ	 pt 	=(
			local result 
			if terrain_relief != undefined do 
				result = intersectRay 	terrain_relief	 	(ray 	[pt.x, pt.y, 0 /*1e20*/]	 [0,0,-1])
			result
		)
		
		
		fn survol_contour		_pts_test		=(
			
			local survol = false
			
			--- on chope les points ----------------
			local pts_contour = #()
			for i = 1 to numSplines  this.terrain_shape do 
				append pts_contour ( for j= 1 to numKnots 	this.terrain_shape collect getKnotPoint this.terrain_shape i j )
			
			--- creation des triangles -----------
			local triangles_shape = #()
			for pts_spline in pts_contour do (
				local spline_tri = trianguler.executer		pts_spline
				for tri in spline_tri do
					append triangles_shape 	tri
			)
			
			--- on regarde si les points du carrées survolent un des triangles de notre shape -----------
			for triangle in triangles_shape do (
				if trianguler.est_dansTriangle	triangle[1]	triangle[2]	triangle[3]	_pts_test do
					survol = true
			)
			
			survol
		)
		
		fn point_est_aGaucheDuSegment	_pt_seg_1	_pt_seg_2	_pt_aTester	=(
			
			local crossProd 	= cross (  _pt_seg_2 - _pt_seg_1 ) ( _pt_aTester - _pt_seg_1 )
			local sensDot 		= dot crossProd  [0,0,1]
			local sens 			= if sensDot > 0 then true else false
-- 				format "point_est_aGaucheDuSegment : %\n" sens
			sens
			
		)
		
		fn construire =(
			
-- 			debug "construire"
-- 			debug "terrain_shape" var:this.terrain_shape
			
			if this.terrain_shape != undefined do (
				
				--- on chope les points ----------------
				local pts_contour = #()
				for i = 1 to numSplines  this.terrain_shape do 
					append pts_contour ( for j= 1 to numKnots 	this.terrain_shape collect getKnotPoint this.terrain_shape i j )
				
				
				
				--- parametre quadrillage	-----------
				local precision 			= terrain_precision
				local BB_contour 		= get_BB_shape  ()
				local index_x				=	floor ( BB_contour[1].x / precision )
				local index_y				=	floor ( BB_contour[1].y / precision )
				local index_x_max		=	floor ( BB_contour[2].x / precision )
				local index_y_max		=	floor ( BB_contour[2].y / precision )
				
				
				
				---- construction ----------------------
				geo.vider ()
				
				--- on parcours toutes les cases ----------------
				while index_y <= index_y_max do (
					index_x				=	floor ( BB_contour[1].x / precision )
					while index_x <= index_x_max do (
						
						debug "-------CASE ------"
						debug "-------X ------" var:index_x
						debug "-------Y ------" var:index_y
						
						------ les point de la case -------------------------------
						local pts_case 	  = #()
						append pts_case		[index_x * 	precision, index_y * 	precision, 0 ]
						append pts_case		[index_x * 	precision , ( index_y + 1 ) * 	precision , 0 ]
						append pts_case		[( index_x + 1 ) * 	precision , ( index_y + 1 ) * 	precision , 0 ]
						append pts_case		[( index_x + 1 ) * 	precision , index_y * 	precision, 0 ]
						
						
						
						----- on regarde si les points de la case survolent le shape ---------------
						local on_survol = false
						for pt_case in pts_case do 							
							if survol_contour 	pt_case do 
								on_survol = true
						
						
						
						
						
						----------- on cherche les INTERSECTIONS potentielles entre les edges de la case et les edges du contour -----------------
						local caseEtContour_seCoupent = false
						local intersections_carre_contour = #()
						
						--- une intersection -------
						struct str_intersection (
							pos,
							id_pt_case,
							id_pt_contour,
							id_spline_contour
						)
						
						--- pour chaque point de la case -----
						for i_pt_case = 1 to pts_case.count do (
							
							--- les points ----
							local pt_case 				= pts_case[i_pt_case]
							local j_pt_case 			= if i_pt_case == pts_case.count  then 1 else i_pt_case + 1
							local pt_case_suivant 	= pts_case[j_pt_case]
							
							--- pour chaque point du contour ----
							for i_pts_spline = 1 to pts_contour.count do (
								local pts_spline = pts_contour[i_pts_spline]
								
								for i_shp = 1 to pts_spline.count do (
									local pt_shp = pts_spline[i_shp]
									local j_shp = if i_shp == pts_spline.count  then 1 else i_shp + 1
									local pt_shp_suivant = pts_spline[j_shp]
									
									local intersection = get_intersection_vecteurs	 pt_case 	pt_case_suivant		pt_shp		pt_shp_suivant
									
									if intersection != undefined 	do (
										caseEtContour_seCoupent = true
										append 	intersections_carre_contour 		( str_intersection pos:intersection	id_pt_case:i_pt_case		id_pt_contour:i_shp 	id_spline_contour:i_pts_spline 	)
									)
										
								)
							)
						)
						
						
						
						--- on le projete sur le relief ----------
						for pt in pts_case do (
							local pt_projection = projectionZ 	pt	
							if pt_projection != undefined do 
								pt.z =	pt_projection.pos.z
						) 
						
						
						
						debug "on_survol" var:on_survol
						debug "caseEtContour_seCoupent" var:caseEtContour_seCoupent
						debug "intersections_carre_contour" var:intersections_carre_contour
						
						----- creation des faces --------------------------------------
						--- si la case survol le contour -----
						if  on_survol do (
							--- si les edges de la case ne coupent pas le contour, alors on a une case pleine --------------
							if not caseEtContour_seCoupent then (
								--- on dessine un carrée plein -----------
								geo.face	pts_case
							
							--- sinon,si les edges de la case coupent le contour, on doit faire la découpe ------------
							) else (
								
								debug "---	on doit faire la découpe ---"
								
								-- On part du premier point de la case --------------------
								local pts_face_aConstruire 	=	#()
								
								local sens 							= 	1
								local shp_courant 				=	pts_case
								local shp_courant_spline		=	1
								local shp_courant_type		=	#case
								local i_courant 					= 1
								local pt_courant 					=	shp_courant[ i_courant ]
								local est_dansLeContour		= 	if survol_contour pt_courant then true else false
								
								-- si le premier point survol le contour, on l'ajoute aux point de construction ---------
								if est_dansLeContour do 			append pts_face_aConstruire 	pt_courant
								
								
								
								------------------ on parcours les points pour construire la face -----------------------------
								local pt_initial	= pt_courant
								local compteur_secours = 0
								-----   tant que le point_courant est different du point initiale -----------
								while ( pt_courant != pt_initial or pts_face_aConstruire.count <= 1 ) and compteur_secours < 50 do (
									compteur_secours += 1
									
									debug "pt_courant" var:pt_courant
									debug "----->	compteur_secours " var:compteur_secours
												debug "----->	shp_courant_type" var:shp_courant_type
									
									--- le point suivant ------------
									i_suivant = i_courant + 1
									if i_suivant > shp_courant.count do i_suivant = 1
									local pt_suivant 		=	shp_courant[ i_suivant ]
									
									
									
									-- on cherche le point suivant : intersection ou point suivant  ? --------	
									local on_a_une_intersection = false
									local id_intersec = 1
									while id_intersec	<=  intersections_carre_contour.count and not on_a_une_intersection do (
										
										local intersec = intersections_carre_contour[id_intersec]
										--- en fonction du shape que l'on est en train de suivre -------------
										case shp_courant_type of (
											
											#case: ( --- la CASE ------------------
												---- on regarde si on trouve l'id courante de la case dans les intersections -------
												if i_courant	==	intersec.id_pt_case	then (
													
												debug "INTERSECTION" var:intersec
													--- on regarde dans quel sens va le contour pour savoir dans quelle sens aller ----
													if 	point_est_aGaucheDuSegment		pt_courant	pt_suivant		pts_contour[ intersec.id_spline_contour ][intersec.id_pt_contour] 	then (
														sens 					= 1
														i_courant			=	intersec.id_pt_contour
													) else (
														sens 					= -1
														i_courant 			= if i_courant > shp_courant.count	then 1 else	intersec.id_pt_contour + 1
													)
													
													--- on change de shape courant -----------
													on_a_une_intersection	= true
													shp_courant_spline		= intersec.id_spline_contour
													shp_courant 				= pts_contour[ shp_courant_spline ]
													shp_courant_type		=	#contour
													pt_courant 				=	intersec.pos													
													append pts_face_aConstruire 	pt_courant
													debug " APPEND -> pts_face_aConstruire" var:pts_face_aConstruire
									
												)
											) --- fin la case ------------------
											
											#contour: ( --- le CONTOUR  ------------------
												
												---- on regarde si on trouve l'id courante et l'id du spline du contour	dans les intersections -------
												if i_courant	==	intersec.id_pt_contour and  shp_courant_spline	== intersec.id_spline_contour then (
													
													debug "INTERSECTION" var:intersec
													
													--- on change de shape courant -----------
													sens 							= 1
													i_courant					= intersec.id_pt_case
													on_a_une_intersection 	= true
													shp_courant_spline		= 1
													shp_courant 				= pts_case
													shp_courant_type		=	#case
													pt_courant 				=	intersec.pos
													append pts_face_aConstruire 	pt_courant
													debug " APPEND -> pts_face_aConstruire" var:pts_face_aConstruire
													
												)
											) --- fin contour ----
											
										)	--- fin case type shape courant ----------------------
										
										---- si on a pas d'intersection, on ajoute le point suivant ----------
										if not on_a_une_intersection do (
											i_courant 		=	i_suivant
											pt_courant 	=	pt_suivant
											append pts_face_aConstruire 	pt_courant
											debug " APPEND point suivant -> pts_face_aConstruire" var:pts_face_aConstruire
										)
										
										debug "----->	pts_face_aConstruire " var:pts_face_aConstruire
										
										id_intersec += 1
									) --- fin for intersections ------------
									
									---- Construction de la face ------------------
									if pts_face_aConstruire.count > 2 do	(		
										debug "----->	CONSTRUCTION: " var:pts_face_aConstruire				
										--- on le projete sur le relief ----------
										for pt in pts_face_aConstruire do (
											local pt_projection = projectionZ 	pt	
											if pt_projection != undefined do 
												pt.z =	pt_projection.pos.z
										) 
										geo.face	pts_face_aConstruire
										
									pts_face_aConstruire = #()
									)
									
									
								) ---- fin while parcours les points pour creer face découpée  -----------
							) ---- fin creation d'une face découpée ---
							
						) --- fin survol ----------
						
						index_x += 1
					) ---- fin les cases sur X ---
					index_y += 1
				) ---- fin les cases sur Y ---
				
			) -- fin on a un contour -----
			
		) --- fin Fonction construire ---------------------
	

		fn actualiser =(

			construire ()
			redrawViews ()
		)
		fn initialiser =(

			geo.m_plug = this
			
		)
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on load 						do 	(
		debug "load du plugin"



		initialiser ()
	)
	on clone 	_original 	do (
-- 		debug "clone du plugin"
		initialiser ()
	)
	on create do (
		debug "creation du plugin"
		initialiser ()
	)
	on update do	(
		debug "update du plugin"
		debug "shape : " var:surface_node
-- 		initialiser ()
	)

)

















