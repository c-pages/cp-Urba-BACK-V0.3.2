



struct modelisation (
	
		fn creer_mur 	_id_pt_bas		_id_pt_ht	_pt2 	_this	 ht:	= (
			
			/*	------------    SCHEMA  	-----------------------------------------------------
																						
																						
					 ____________________________	2	--> pt_ht		
						|													|																						
						|													|																						
						|													|															
						|													|	 																																	
						|													|																
						| 													|  																	
						|													|																			
						|													|																		
			vec_ht	|													|																	
						|													|	  																	
						|													|																			
						|  													|  
						|													|																						
						|													|																						
						|													|																					
						|													|																						
					_pt_bas __________________________   _pt2	--> pt_bas
											vec_longueur
			
			
			*/	----------------------------------------------------------------------------------------
			
			
			
			local hauteur
			
			if ht != unsupplied then	hauteur = ht
				else hauteur 	=	_this.niveaux_hauteur 
			
			local pts_pos_esp = 	#()		
			append pts_pos_esp 	( _pt2 )
			append pts_pos_esp 	( _pt2 + [0,0,hauteur] )
			
			local pts_ids_esp = geo_ptr.creer.points  pts_pos_esp 	_this
			append pts_ids_esp 	( _id_pt_ht )
			append pts_ids_esp 	( _id_pt_bas )
			
			geo_ptr.creer.edges  pts_ids_esp 	_this	--	fermer:true		
			geo_ptr.creer.face  	 pts_ids_esp 	_this
			
			pt_bas 	= pts_ids_esp[1]
			pt_ht		= pts_ids_esp[2]
			
			#(pt_bas, pt_ht)
		),
		
		fn baie_simple	 _id_pt_bas		_id_pt_ht		_normDir		_this = (
			
			
			/*	------------    SCHEMA  	-----------------------------------------------------
																						
																						
					PTHT	____________________________	6				
						|													|																						
						|													|																						
						|		10	_______________________	|	_	9																			
			vec_rtmb	|	  /	|											|	  /	|																																				
						|	/	|											|	/	|																			
						|  /	|											|  /	|
						4	_____________________________	5		|																	
						|		|											|		|																			
						|		|											|		|																			
						|		|											|		|																			
			vec_ht	|		7	_______________________	|	_	8																		
						|	  /												|	  /																				
						|	/												|	/ vec_prof																				
						|  /												|  /																			
						3	_____________________________	2				
						|													|																						
			vec_allege |													|																						
						|													|																					
						|													|																						
					PTBAS_____________________________	1	
											vec_longueur
			
			
			*/	----------------------------------------------------------------------------------------
			
			
			
			-------	Les vecteurs generaux 	--------
			local vec_allege 		= if allege_use 	then 	[0,0,0] 
																else		[0,0,1] *	allege_hauteur
			local vec_rtmb 		= if hauteur_use 	then 	[0,0,0] 
																else		[0,0,1] *	( _this.niveaux_hauteur - (allege_hauteur + m_compo.hauteur ) )
			local vec_ht 			= [0,0,1] * _this.niveaux_hauteur - ( vec_allege + vec_rtmb ) 
			local vec_longueur 	= _normDir * m_compo.longueur
			local norm_prof		= _normDir * rotateZ ( matrix3 1 ) 90
			local vec_prof			=  norm_prof * mur_profondeur
			
			
			-------	Creation des points 	--------
			local pt_bas 	= polyop.getVert 	_this.delegate		_id_pt_bas	
			local pt_1 		= pt_bas	+  vec_longueur
			local pt_2 		= pt_1		+  vec_allege
			local pt_3 		= pt_bas	+ 	vec_allege
			local pt_4 		= pt_3		+ 	vec_ht
			local pt_5 		= pt_4		+ 	vec_longueur
			local pt_6 		= pt_5		+ 	vec_rtmb
			local pt_7 		= pt_3		+ 	vec_prof
			local pt_8 		= pt_2		+ 	vec_prof
			local pt_9 		= pt_5		+ 	vec_prof
			local pt_10		= pt_4		+ 	vec_prof
			local pt_ht 	= polyop.getVert 	_this.delegate		_id_pt_ht	
			
			local pts_pos 	= #( pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
			local pts_ids 	= m_geo.creer.points 	pts_pos		_this
			
			-------	Creation des edges 	--------
			m_geo.creer.edges 		#(	_id_pt_bas, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		 _this
			m_geo.creer.edges 		#(	pts_ids[2], 		pts_ids[8], 		pts_ids[7] , 	pts_ids[3] )		 _this
			m_geo.creer.edges 		#(	pts_ids[5], 		pts_ids[9], 		pts_ids[10] , 	pts_ids[4] )		 _this
			m_geo.creer.edges 		#(	pts_ids[8], 		pts_ids[9])		 _this
			m_geo.creer.edges 		#(	pts_ids[7], 		pts_ids[10])	 _this
			m_geo.creer.edges 		#(	pts_ids[5], 		pts_ids[6], 		_id_pt_ht , 	pts_ids[4] )		 _this
			
			-------	Creation des faces 	--------
			m_geo.creer.face 		#(	_id_pt_bas, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		 _this
			m_geo.creer.face 		#(	pts_ids[2], 		pts_ids[8], 		pts_ids[7] , 	pts_ids[3] )		 _this
			m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[4], 		pts_ids[10] , 	pts_ids[9] )		 _this
			m_geo.creer.face 		#(	pts_ids[2], 		pts_ids[5], 		pts_ids[9], 		pts_ids[8] )		 _this
			m_geo.creer.face 		#(	pts_ids[3], 		pts_ids[7], 		pts_ids[10], 	pts_ids[4] )		 _this
			m_geo.creer.face 		#(	pts_ids[7], 		pts_ids[8], 		pts_ids[9], 		pts_ids[10] )		 _this
			m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[6], 		_id_pt_ht , 	pts_ids[4] )		 _this
			
			pts_results = #(pts_ids[1] , pts_ids[6])
																																				
			
			
			pts_results
			
			
		)
	
	
	
)