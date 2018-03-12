( ---- fileIn --------------------

struct 	str_bat_VP 		(
	private
		fn fn_afficher_longueurs =(
			
			gw.setTransform (matrix3 1)
			
			
			if selection.count == 1 and classof $ == Urba_Batiment do (
				local nd	 = $
				
				local bat 				= nd.core.get_bat_edition ()
				
				local fcd				= nd.core.get_facade_enEdition 	()
				local surface_pts 	= 	nd.core.get_surface_points		()
				
					for ptID = 1 to surface_pts.count do (
						
						local ptID_suivant = ptID + 1
						if ptID_suivant > surface_pts.count do ptID_suivant = 1
							
						local vec_sousBassmt	=	[0,0,1] * nd.const_ssBassement_epaisseur
						local vec_dalle				=	[0,0,1] * nd.const_dalle_epaisseur
						local vec_decallage		=	[0,0,1] * 300
	
						local pt 						= surface_pts[ptID] *  nd.transform 
						local pt_suivant 			= surface_pts[ptID_suivant] *  nd.transform  
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

		fn fn_afficher_facades =(
			
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

		fn fn_afficher_etages =(
-- 			gw.wTransPoint 
			gw.setTransform (matrix3 1)
			
			
			if selection.count == 1 and classof $ == Urba_Batiment do (
				
				local nd	 = $
				
				local bat 				= nd.core.get_bat_edition ()
				
				local fcd				= nd.core.get_facade_enEdition 	()
				local surface_pts 	= 	nd.core.get_surface_points		()
				
				
				
				local z = bat.decallage_z
				for etageNum = 0 to bat.etages_nbre do (
					
					local etage_ht 		= bat.get_etage_ht	 	etageNum	 + nd.const_dalle_epaisseur
					local pts_etage =#()
					for ptID = 1 to surface_pts.count do (
						local pt 						= surface_pts[ptID] *  nd.transform 
						pt.z = z
						append pts_etage pt
					)
					z+= etage_ht
					gw.setColor	#line		blue
					gw.polyline pts_etage	true 
					gw.text 	( pts_etage[1] + [0,0,	( bat.get_etage_ht	 	etageNum	 )/2 ] )  	( "Niv: " + etageNum as string + " ht: " + ( bat.get_etage_ht	 	etageNum	 ) as string )  	color:blue
				
				)
				
				local etage_ht 		= bat.get_etage_ht	 	bat.etages_nbre 	 + nd.const_dalle_epaisseur
				local pts_etage =#()
				for ptID = 1 to surface_pts.count do (
					local pt 						= surface_pts[ptID] *  nd.transform 
					pt.z = z
					append pts_etage pt
				)
				gw.setColor	#line		blue
				gw.polyline pts_etage	true 
-- 				gw.text 	( pts_etage[1] + [0,0,	( bat.get_etage_ht	 	etageNum	 )/2 ]	( "Niv: " + etageNum as string + " ht: " + ( bat.get_etage_ht	 	etageNum	 ) as string )  	color:yellow
			
-- 				format "-----> surface_pts[ ptID_a_droite]: %\n" surface_pts[ ptID_a_droite]
-- 				gw.Marker surface_pts[ ptID_a_droite]		#xMarker   color:yellow
-- 				gw.text 	surface_pts[ ptID_a_droite]		( etageNum as string )  	color:col_valid
				
					/* local ptID_suivant = ptID + 1
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
				
				) */
			)
			gw.updateScreen() 
		),
		
	public
		fn longueurs		state =(
			unregisterRedrawViewsCallback 	urba_fn_afficher_longueurs
			case state of (
				true:		registerRedrawViewsCallback 		urba_fn_afficher_longueurs 	
				false:	unregisterRedrawViewsCallback 	urba_fn_afficher_longueurs
			)
			redrawviews ()
		),

		fn facades		state =(
			unregisterRedrawViewsCallback 	urba_fn_afficher_facades
			case state of (
				true:	registerRedrawViewsCallback 		urba_fn_afficher_facades 	
				false:	unregisterRedrawViewsCallback 	urba_fn_afficher_facades
			)
			redrawviews ()
		),
		fn etages		state =(
			unregisterRedrawViewsCallback 	urba_fn_afficher_etages
			case state of (
				true:	registerRedrawViewsCallback 		urba_fn_afficher_etages 	
				false:	unregisterRedrawViewsCallback 	urba_fn_afficher_etages
			)
			redrawviews ()
		),
		fn desactiver_tout =(
			longueurs 		false
			facades 		false
			etages	 		false
		),
		
		on create do (
			format "initialiser\n"
			global 	urba_fn_afficher_longueurs  	= fn_afficher_longueurs
			global 	urba_fn_afficher_facades  		= fn_afficher_facades
			global 	urba_fn_afficher_etages  		= fn_afficher_etages
		)
	
)
	str_bat_VP ()
 ) -- fileIn ------
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 