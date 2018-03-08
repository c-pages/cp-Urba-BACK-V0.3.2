
struct 	str_bat_VP 		(
	private
		fn fn_afficher_longueurs =(
			
			gw.setTransform (matrix3 1)
			
			
			if selection.count == 1 and classof $ == Urba_Batiment do (
				local bat 				= $
				local fcd				= bat.core.get_facade_enEdition 	()
				local surface_pts 	= 	bat.core.get_surface_points		()
				
					for ptID = 1 to surface_pts.count do (
						
						local ptID_suivant = ptID + 1
						if ptID_suivant > surface_pts.count do ptID_suivant = 1
							
						local vec_sousBassmt	=	[0,0,1] * bat.const_ssBassement_epaisseur
						local vec_dalle				=	[0,0,1] * bat.const_dalle_epaisseur
						local vec_decallage		=	[0,0,1] * 300
	
						local pt 						= surface_pts[ptID] *  bat.transform 
						local pt_suivant 			= surface_pts[ptID_suivant] *  bat.transform  
						local longueur_facade 	= ( (floor ( ( distance pt pt_suivant ) * 10 ) ) / 10 )
						local txt_affichage 		= "  " + longueur_facade as string + " cm"
						
						local col_valid 			= yellow
						local col_nonValid 	= [ 100, 100 , 100 ]
						local col_divers 		= white
						
						---- les longueurs------
						local color_affichage 	 = col_divers
						local longueur_valid = true
						if fcd != undefined do			(
							local lg_min_fcd = amax #(  fcd.params.longueurMin , fcd.params.get_longueur () )
							
							if longueur_facade < lg_min_fcd do
								longueur_valid = false
							
							if fcd.params.longueurMax_use and longueur_facade >  fcd.params.longueurMax do
								longueur_valid = false
						)
						if longueur_valid then (
							color_affichage 	 = col_valid
							gw.setColor	#line		col_valid
						) else (
							color_affichage 	 = col_nonValid
							gw.setColor	#line		col_nonValid
						)
						
						
						local vec_affichage_lgs = 	vec_sousBassmt 	+ vec_dalle + vec_decallage
						local pt_milieu_facade 	= ( (pt + pt_suivant) /2 )  - vec_affichage_lgs
						gw.polyline #( pt - vec_affichage_lgs , pt_suivant - vec_affichage_lgs )	false
						gw.Marker pt_milieu_facade		#xMarker   color:color_affichage
						gw.text 	( pt_milieu_facade	 - [0,0,100] )	txt_affichage  	color:color_affichage
						
						--- les etages	----------------
						if  fcd != undefined  and  longueur_valid do (
							local z = 0
							for etageNum = 0 to bat.etages_nbre do (
								
								local etage_valid	=		bat.core.est_valide		fcd			etageNum		ptID 
								local etage_ht 		= bat.core.get_etage_ht	 	etageNum	 + bat.const_dalle_epaisseur
								

								if etage_valid do (
									gw.setColor	#line		col_valid
									local ecart 		= 10
									local norm_dir 	= normalize ( pt_suivant - pt )
									local pt_1 		=  pt + [0,0,z] 				+ 	norm_dir * ecart	+ [0,0,ecart]
									local pt_2 		=  pt_suivant + [0,0,z]	- 	norm_dir * ecart	+ [0,0,ecart]
									local pt_3 		=  pt_2 + [0,0,etage_ht - 2*ecart ] 
									local pt_4 		=  pt_1 + [0,0,etage_ht - 2*ecart ] 
									gw.polyline #( pt_1, pt_2, pt_3, pt_4		)	true 
									
-- 									local pt_centre = ( pt_1 + pt_2 + pt_3 + pt_4 ) / 4
-- 									gw.text 	pt_centre		( etageNum as string )  	color:col_valid
									
								)
								
								
								z+= etage_ht
							)
							
						)
					
					)
			)
			gw.updateScreen() 
		),

	public
		fn cacher_longueurs	=(
			unregisterRedrawViewsCallback 	urba_fn_afficher_longueurs
			redrawviews ()
		),

		fn afficher_longueurs			=(
			cacher_longueurs()
			
			registerRedrawViewsCallback 		urba_fn_afficher_longueurs 	
			completeRedraw() 
		),
		on create do (
			format "initialiser\n"
			global 	urba_fn_afficher_longueurs  = fn_afficher_longueurs
			format "> urba_fn_afficher_longueurs : %\n" urba_fn_afficher_longueurs
		)
	
)
 /*	
 vp_test = _urba_bat_VP ()


vp_test.VP_cacher_longueurs()
vp_test.VP_afficher_longueurs()

*/

/* 
fn	fn_VP_afficher_axePrincipal		 =(
		
	
	

		gw.setTransform (matrix3 1)
		
		
		for o in selection where classof o == urba_batiment  do (
			
			local largeurFleche = 100
			local BB_axeP 	= o.axeP_BB
			local mtrx_axeP	= o.axeP_mtrx 
			local mtrx_axeP2	= o.axeP_mtrx 
				
			translate mtrx_axeP 	BB_axeP[1]
			
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP ) - (BB_axeP[1]  * inverse mtrx_axeP  )
			local largeur 		=	diag_axeP.x
			local longeur 		= 	diag_axeP.z
-- 				
			------ l'AXE----------------
			if o.affiche_axe do (
				---- dessin de l'Axe-----------------
				local ptAxe_1 =  [largeur/2,0,0]  *   mtrx_axeP   * o.transform
				local ptAxe_2 =  [largeur/2,0,longeur - largeurFleche ]  *     mtrx_axeP    * o.transform

				gw.setColor	#line	yellow
				gw.Polyline #( ptAxe_1, ptAxe_2 )	false
				
				---- dessin de la fleche de l'axe -----------------
				local ptFleche_1 = (  [largeur/2,0,longeur + 0 ]  ) *  mtrx_axeP    * o.transform
				local ptFleche_2 = (  [largeur/2,0,longeur + 0 ]   + [largeurFleche/ 3,0,-largeurFleche ]) *  mtrx_axeP    * o.transform
				local ptFleche_3 = (  [largeur/2,0,longeur + 0 ]   + [-largeurFleche/ 3,0,-largeurFleche ]) *  mtrx_axeP    * o.transform
				
				gw.Polyline #( ptFleche_1, ptFleche_2, ptFleche_3 )	true
			)
			
			
			
			--- sous tracés -------------
			if o.affiche_ssTraces do (
				
				
				local rectangles = o.trace.rectangles_traces
				
				for i = 1 to rectangles.count do (
-- 					format "o.sousTraces.count :%\n"	o.sousTraces.count
					local rect = rectangles[i]
					
					local barycentre = [0,0,0]
					for id_pt = 1 to rect.count do (
						local id_ptSuiv = id_pt + 1
						if id_ptSuiv > rect.count do id_ptSuiv = 1
						local id_rect 				= rect[ id_pt ]
						local id_rect_suivant 	= rect[ id_ptSuiv ]
						
						local pt 			= o.trace_courant[ id_rect  ] 				*  o.transform 
						local pt_suivant 	= o.trace_courant[ id_rect_suivant  ]  	*  o.transform 
						gw.setColor	#line	gray
						gw.polyline #( pt, pt_suivant )	false
						barycentre += pt
					)
						
					local pt_0 = o.trace_courant[ rect[ 1 ] ]
					local pt_1 = o.trace_courant[ rect[ 2 ] ]
					local pt_2 = o.trace_courant[ rect[ 4 ] ]
					
					barycentre /= rect.count
					
					local surf = ( distance pt_1 pt_0 ) * ( distance pt_2 pt_0 ) / 10000
					gw.text 		barycentre	( surf as string + " m²" )  	color:gray
				)
				
				
				local sousTraces = o.sousTraces
-- 				local barycentre = [0,0,0]
				for i = 1 to sousTraces.count do (
-- 					format "o.sousTraces.count :%\n"	o.sousTraces.count
					
					local nvSsTrace = str_ssTrace ()
					local sousTrace = o.trace.datasMgr.set_datas_string 		sousTraces[i] 		nvSsTrace 	_this
					
					for id_pt = 1 to sousTrace.trace.count do (
						local id_ptSuiv = id_pt + 1
						if id_ptSuiv > sousTrace.trace.count do id_ptSuiv = 1
						local id_ssTrace 				= sousTrace.trace[ id_pt ]
						local id_ssTrace_suivant 	= sousTrace.trace[ id_ptSuiv ]
						
						local pt 			= o.trace_courant[ id_ssTrace  ] 		*  o.transform 
						local pt_suivant 	= o.trace_courant[ id_ssTrace_suivant  ]  	*  o.transform 
						gw.setColor	#line	yellow
						gw.polyline #( pt, pt_suivant )	false
-- 						barycentre += pt
					)
						
-- 					local pt_0 = o.trace_courant[ sousTrace[ 1 ] ]
-- 					local pt_1 = o.trace_courant[ sousTrace[ 2 ] ]
-- 					local pt_2 = o.trace_courant[ sousTrace[ 4 ] ]
					
-- 					barycentre /= sousTraces.count
					
-- 					local surf = ( distance pt_1 pt_0 ) * ( distance pt_2 pt_0 ) / 10000
-- 					gw.text 		barycentre	( surf as string + " m²" )  	color:gray
				)
				
				
				
				
			)
				
				
	-- 			gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
			
			
			
			for i = 1 to o.trace_courant.count do (
				
					
				local j = i + 1
				if j > o.trace_courant.count do j = 1
				local pt = o.trace_courant[i] *  o.transform 
				local pt_suivant = o.trace_courant[j] *  o.transform 
				
				---- les pignons et gouttereaux -----
				local col = red
				local estPignon = o.trace.est_pignon i 
				if estPignon then (
					if o.affiche_pignons do (
						gw.setColor	#line	blue
						gw.polyline #( pt, pt_suivant )	false
						
						local longueurFacade = ( distance pt pt_suivant ) as string
							gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
						
					)
				)else (
					if o.affiche_gouttereaux do (
						gw.setColor	#line	red
						gw.polyline #( pt,pt_suivant )	false
						
						local longueurFacade = ( distance pt pt_suivant ) as string
							gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
						
					)
				)
				---- les points du trace_courant -----
				if o.affiche_trace do (
					gw.text 		(pt + [0,0,10]) 	(i as string )  	color:yellow
-- 					gw.Marker 	pt 	#hollowBox 	color:yellow
				)
			
			)
			
		)
		gw.enlargeUpdateRect #whole  


	)
	fn VP_toggle	=(
		unregisterRedrawViewsCallback 	fn_VP_afficher_axePrincipal
		if 	 this.affiche_axe or  this.affiche_trace or  this.affiche_pignons or  this.affiche_gouttereaux   or  this.affiche_ssTraces do
			registerRedrawViewsCallback 		fn_VP_afficher_axePrincipal 	
	)
	fn actualiser_cacherGeo =(
		if this.cache_geometrie then (
			local faces = #{1..(polyop.getNumFaces delegate)} as array
			polyop.setHiddenFaces 	this.delegate 	faces
		) else
			polyop.unHideAllFaces 	this.delegate
	)
	
	
	
	
	
	
	 */
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 