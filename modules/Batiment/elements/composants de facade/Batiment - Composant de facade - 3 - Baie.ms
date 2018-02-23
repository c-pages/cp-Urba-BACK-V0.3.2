
------ parametres de base	-----------------------------
compo_titre 		= "Baie"	
compo_type		=	#baie
compo_toolTip 	=	"Ouverture dans un mur."


--- les parametres du composant	---------
struct compo_params	(
		
		longueur						= 100,
		hauteur							= 210,
		hauteur_use					=	true,
		profondeur					= 20,
		
		allege_hauteur 		 		= 100,
		allege_use					=	true,
		
		menuis_largeur				=	7.,
		menuis_epaisseur			=	3.,			
		menuis_divisions			=	0,	
		menuis_allege_use		=	false,
		menuis_allege_ht			=	100,
		menuis_trav_use			=	false,
		menuis_trav_ht			=	210,			
		menuis_ouvrant_use		=	true,
		menuis_double_use		=	true,
		
		tablette_use					= true,
		tablette_hauteur 			= 5,
		tablette_debord 			= 5,
		tablette_cote 				= 5,
		
		volet								= false,
		coffre							= false
		
)

--- les rollout du composant	---------
rollout compo_dialog "Baie" width:180 height:532 (
		local m_rollPrt
		local m_compo
		
		edittext 'edt_nom' "" pos:[7,3] width:186 height:16 align:#left
		
		label 'lbl19' "Longeur:" pos:[11,37] width:49 height:13 align:#left
		spinner 'spn_longueur' "" pos:[116,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		label 'lbl21' "Hauteur:" pos:[11,53] width:49 height:13 align:#left
		spinner 'spn_hauteur' "" pos:[116,52] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		GroupBox 'grp1' "Baie" pos:[6,21] width:187 height:85 align:#left
		label 'lbl24' "Allège:" pos:[11,68] width:49 height:13 align:#left
		spinner 'spn_allege' "" pos:[116,67] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		checkbutton 'ckb_hauteur' "" pos:[96,51] width:17 height:17 toolTip:"Toute hauteur Valeur négative pour descendre depuis plafond" align:#left
		checkbutton 'ckb_allege' "" pos:[96,67] width:17 height:17 align:#left
		label 'lbl29' "Profondeur:" pos:[11,84] width:59 height:13 align:#left
		spinner 'spn_profondeur' "" pos:[116,83] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		
		
		
		GroupBox 'grp_divers' "Divers" pos:[6,254] width:187 height:114 align:#left
		checkbox 'chk_tablette' "Tablette" pos:[10,269] width:59 height:16 align:#left
		label 'lbl_tablette_hauteur' "Hauteur:" pos:[11,284] width:49 height:13 align:#left
		spinner 'spn_tablette_hauteur' "" pos:[116,283] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		label 'lbl_tablette_debord' "Débord:" pos:[11,299] width:49 height:13 align:#left
		spinner 'spn_tablette_debord' "" pos:[116,298] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		label 'lbl_tablette_cote' "Cotés:" pos:[11,315] width:59 height:13 align:#left
		spinner 'spn_tablette_cote' "" pos:[116,314] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		checkbox 'chk_volets' "Volets" pos:[10,330] width:47 height:16 align:#left
		checkbox 'chk_coffreStore' "Coffre store" pos:[10,344] width:81 height:16 align:#left
		GroupBox 'grp_menuiseries' "Menuiseries" pos:[6,110] width:187 height:141 align:#left
		
		label 'lbl_allege_hauteur' "Hauteur:" pos:[11,199] width:50 height:13 align:#left
		spinner 'spn_allege_hauteur' "" pos:[116,198] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		checkbox 'chk_allege' "Allège" pos:[10,184] width:48 height:16 align:#left
		label 'lbl_traverse_hauteur' "Hauteur:" pos:[11,228] width:50 height:13 align:#left
		spinner 'spn_traverse_hauteur' "" pos:[116,227] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		checkbox 'chk_traverse' "Traverse" pos:[10,213] width:64 height:16 align:#left
		label 'lbl_menuis_epaisseur' "Epaisseur:" pos:[11,139] width:51 height:13 align:#left
		spinner 'spn_menuis_epaisseur' "" pos:[116,138] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		label 'lbl_menuis_largeur' "Largeur:" pos:[11,124] width:42 height:13 align:#left
		spinner 'spn_menuis_Largeur' "" pos:[116,123] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
		checkbox 'chk_double' "Double" pos:[137,154] width:48 height:16 enabled:false align:#left
		checkbox 'chk_ouvrant' "Ouvrant" pos:[10,154] width:57 height:16 align:#left
		
		label 'lb_divisions' "Divisions:" pos:[11,171] width:59 height:13 align:#left
		spinner 'spn_divisions' "" pos:[116,170] width:70 height:16 range:[0,4,0] type:#integer scale:1 align:#left
		
		
		fn actualiser =(
			spn_longueur.value 			= m_compo.params.longueur
			edt_nom.text 					=	m_compo.nom
			spn_profondeur.value 		=	m_compo.params.profondeur	
			ckb_hauteur.checked		=	m_compo.params.hauteur_use 
			ckb_allege.checked			=	m_compo.params.allege_use
	
			if not ckb_hauteur.checked then (
				spn_hauteur.enabled 	= true
				spn_hauteur.value 		=	m_compo.params.hauteur 
			) else (
				spn_hauteur.enabled 			= false
				spn_hauteur.indeterminate 	=	true
			)
			if not ckb_allege.checked then (
				spn_allege.enabled 				= true
				spn_allege.value 					=	m_compo.params.allege_hauteur 
			) else (
				spn_allege.enabled 				= false
				spn_allege.indeterminate 		=	true
			)
			
			chk_tablette.checked 				= m_compo.params.tablette_use
			lbl_tablette_hauteur.enabled 		= m_compo.params.tablette_use
			spn_tablette_hauteur.enabled 	= m_compo.params.tablette_use
			lbl_tablette_cote.enabled 			= m_compo.params.tablette_use
			spn_tablette_cote.enabled 		= m_compo.params.tablette_use
			spn_tablette_debord.enabled 	= m_compo.params.tablette_use
			lbl_tablette_debord.enabled 		= m_compo.params.tablette_use
			
			spn_profondeur.value 					=	m_compo.params.profondeur
			spn_tablette_hauteur.value 			=	m_compo.params.tablette_hauteur
			spn_tablette_debord.value 			=	m_compo.params.tablette_debord
			spn_tablette_cote.value 				=	m_compo.params.tablette_cote
			
			spn_tablette_hauteur.indeterminate = not m_compo.params.tablette_use
			spn_tablette_cote.indeterminate 	= not m_compo.params.tablette_use
			spn_tablette_debord.indeterminate 	= not m_compo.params.tablette_use
			
			spn_menuis_epaisseur.value 				=	m_compo.params.menuis_epaisseur
			spn_menuis_Largeur.value 				=	m_compo.params.menuis_largeur
			chk_double.checked 						=	m_compo.params.menuis_double_use
			chk_ouvrant.checked 						=	m_compo.params.menuis_ouvrant_use
			
			spn_allege_hauteur.value 					=	m_compo.params.menuis_allege_ht
			spn_allege_hauteur.enabled 				=	m_compo.params.menuis_allege_use
			spn_allege_hauteur.indeterminate 		= not m_compo.params.menuis_allege_use
			lbl_allege_hauteur.enabled 				=	m_compo.params.menuis_allege_use
			chk_allege.checked 							=	m_compo.params.menuis_allege_use
			
			spn_traverse_hauteur.value 				=	m_compo.params.menuis_trav_ht
			lbl_traverse_hauteur.enabled 				=	m_compo.params.menuis_trav_use
			spn_traverse_hauteur.indeterminate 	= not m_compo.params.menuis_trav_use
			chk_traverse.checked 						=	m_compo.params.menuis_trav_use
			spn_traverse_hauteur.enabled 			=	m_compo.params.menuis_trav_use
			
			spn_divisions.value 							=	m_compo.params.menuis_divisions
			
		) -- fin actualiser -------
	
		on edt_nom entered txt 	do			(
				m_compo.nom = txt
				m_rollPrt.actualiser ()
			)
		on spn_longueur changed val 	do
			m_compo.params.longueur 					= val
		on spn_hauteur changed val 	do
			m_compo.params.hauteur 					= val
		on spn_allege changed val 	do
			m_compo.params.allege_hauteur 	= val
		on ckb_hauteur changed state do			(
				m_compo.params.hauteur_use 	= state
				actualiser ()
			)
		on ckb_allege changed state do			(
				m_compo.params.allege_use 	= state											
				actualiser ()
			)
		on spn_profondeur changed val 	do
			m_compo.params.profondeur	= val
		on chk_tablette changed state do			(
				m_compo.params.tablette_use 	= state											
				actualiser ()
			)
		on spn_tablette_hauteur changed val 	do
			m_compo.params.tablette_hauteur 					= val
		on spn_tablette_debord changed val 	do
			m_compo.params.tablette_debord 	= val
		on spn_tablette_cote changed val 	do
			m_compo.params.tablette_cote	= val
		on spn_allege_hauteur changed val 	do
			m_compo.params.menuis_allege_ht 		= val
		on chk_allege changed state do			(
				m_compo.params.menuis_allege_use 	= state											
				actualiser ()
			)
		on spn_traverse_hauteur changed val 	do
			m_compo.params.menuis_trav_ht 					= val
		on chk_traverse changed state do			(
				m_compo.params.menuis_trav_use 	= state											
				actualiser ()
			)
		on spn_menuis_epaisseur changed val 	do
			m_compo.params.menuis_epaisseur 					= val
		on spn_menuis_Largeur changed val 	do
			m_compo.params.menuis_largeur 					= val
		on chk_double changed state do			(
				m_compo.params.menuis_double_use 	= state											
				actualiser ()
			)
		on chk_ouvrant changed state do			(
				m_compo.params.menuis_ouvrant_use 	= state											
				actualiser ()
			)
		on spn_divisions changed val 	do
			m_compo.params.menuis_divisions	= val
		
	)
	
------ la fonction de construction	---------
fn compo_fnConstruire  		_plug			_ptsIDs_accroche		_normDir		_composant 	est_DansBalcon:false	= ( 
-- 		_plug		pts_accroches		_normDir		 _composant	
	
		--- Result -------------
		local pt_result_1, pt_result_2, pt_result_3
	
	
	-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	_composant
		local ptr_params		  	= 	_composant.params
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
	
	-------------  constantes locales			-----------------------------------------------------------------------------------------------------------------
		local decalage_epaisseur = 1
		
	-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
		local longueur						= ptr_params.longueur
		local hauteur						= ptr_params.hauteur
		local hauteur_use					=	ptr_params.hauteur_use
		local profondeur					= ptr_params.profondeur
		
		local allege_hauteur 		 		= ptr_params.allege_hauteur
		local allege_use					=	ptr_params.allege_use
		
		local menuis_largeur				=	ptr_params.menuis_largeur
		local menuis_epaisseur			=	ptr_params.menuis_epaisseur
		local menuis_divisions			=	ptr_params.menuis_divisions
		local menuis_allege_use		=	ptr_params.menuis_allege_use
		local menuis_allege_ht			=	ptr_params.menuis_allege_ht
		local menuis_trav_use			=	ptr_params.menuis_trav_use
		local menuis_trav_ht			=	ptr_params.menuis_trav_ht
		local menuis_ouvrant_use	=	ptr_params.menuis_ouvrant_use
		local menuis_double_use		=	ptr_params.menuis_double_use
		
		local tablette_use					= ptr_params.tablette_use
		local tablette_hauteur 			= ptr_params.tablette_hauteur
		local tablette_debord 			= ptr_params.tablette_debord
		local tablette_cote 				= ptr_params.tablette_cote
		
		local volet							= ptr_params.volet
		local coffre							= ptr_params.coffre		
		
		
		--- Vecteurs directeurs ------------
		local vec_ep_dalle 	= [0,0,1] 		* 	ptr_plug.const_dalle_epaisseur		
		local vec_allege 		= if allege_use 		then 	[0,0,0] 
																	else		[0,0,1] *	allege_hauteur
		local vec_rtmb 		= if hauteur_use 	then 	[0,0,0] 
																	else		[0,0,1] *	( ptr_plug.etages_hauteur - (allege_hauteur + hauteur ) )				
		local norm_prof		= _normDir 	* rotateZ ( matrix3 1 ) 90				
		local vec_ht 				= if hauteur_use 	then 	[0,0,1] *	 ptr_plug.etages_hauteur
																	else		[0,0,1] * 	 hauteur				
		local vec_longueur 	= _normDir * longueur
		local norm_prof		= _normDir * rotateZ ( matrix3 1 ) 90
		local vec_prof			=  norm_prof * profondeur
		
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= _ptsIDs_accroche[1]
		local id_ptAccroche_2 	= _ptsIDs_accroche[2]
		local id_ptAccroche_3 	= _ptsIDs_accroche[3]
		
		local ptAccroche_1		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	
		local ptAccroche_2		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	
		local ptAccroche_3		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	
		
		
	-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		
		---- LA DALLE  -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_2 		= ptAccroche_1		+ 	vec_longueur
		local pt_3 		= pt_2					+	vec_ep_dalle
		
		--- creation des points --------------
		local pts_pos 	= #( pt_2, pt_3 )
		local pts_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		local nvlFace = ptr_geo.face 		#(	 id_ptAccroche_1, 		pts_ids[1], 		pts_ids[2], 		id_ptAccroche_2	)		
		ptr_geo.set_matID 	nvlFace	#mur
		
		--- Result -------------
		pt_result_1 = pts_ids[1]
		pt_result_2 = pts_ids[2]
		
		
		
		---- LA BAIE -----------------------------------------------------------------------				
		-------	Creation des points 	--------
		--- mur d'allege ----
		local pt_bas 	= ptAccroche_2
		local pt_ht 	= ptAccroche_3
		
		local pt_1 		= pt_bas	+  vec_longueur
		local pt_2 		= pt_1		+  vec_allege + [0,0,decalage_epaisseur]
		local pt_3 		= pt_bas	+ 	vec_allege + [0,0,decalage_epaisseur]
		
		local pt_4 		= pt_bas	+ 	vec_ht
		local pt_5 		= pt_4		+ 	vec_longueur				
		local pt_6 		= pt_ht		+ 	vec_longueur
		local pt_7 		= pt_3		+ 	vec_prof
		local pt_8 		= pt_2		+ 	vec_prof
		local pt_9 		= pt_5		+ 	vec_prof
		local pt_10		= pt_4		+ 	vec_prof
		
		--- creation des points --------------
		local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
		local pts_ids 	= ptr_geo.points 	pts_pos	
		
		--- Result -------------
		pt_result_3 = pts_ids[6]
		
		
		----- pour plus tard, ...  le raccord avec les menuiseries, et return -----
		local ids_pts_racc_menuis =#(pts_ids[7], pts_ids[8], pts_ids[9], pts_ids[10])
		
		-------	Creation des faces 	--------
		local nvlFace = ptr_geo.face 		#(	id_ptAccroche_2, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		 
		ptr_geo.set_matID 	nvlFace	#mur 	
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[3], 		pts_ids[2], 		pts_ids[8] , 	pts_ids[7] )		 	
		if tablette_use and not est_DansBalcon	then		ptr_geo.set_matID 	nvlFace	#menuiserie
																		else 	ptr_geo.set_matID 	nvlFace	#mur
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[10], 	pts_ids[9], 		pts_ids[5], 		pts_ids[4] )
		ptr_geo.set_matID 	nvlFace	#mur
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[5], 		pts_ids[6], 		id_ptAccroche_3 )
		ptr_geo.set_matID 	nvlFace	#mur
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[3], 		pts_ids[7], 		pts_ids[10],   	pts_ids[4] )
		ptr_geo.set_matID 	nvlFace	#mur
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[8], 		pts_ids[2], 		pts_ids[5],   	pts_ids[9] )
		ptr_geo.set_matID 	nvlFace	#mur
		
		
		
		
		
		
		
		
		--- CADRE MENUISERIE ----------------------------------------------------------------------------------------------------------------		
		
		local vec_men_ep			= norm_prof	*	menuis_epaisseur
		local vec_men_lrg			=	_normDir		*	menuis_largeur
		local vec_men_ht				=	[0,0,1] 		*	menuis_largeur
		local vec_men_allegeHt	=	[0,0,1] 		*	menuis_allege_ht
		local vec_men_travHt		=	[0,0,1] 		*	menuis_trav_ht
		
		-------	Placement des points 	--------
		local pt_A	= ptr_geo.get_vertex	ids_pts_racc_menuis[1]		
		local pt_B	= ptr_geo.get_vertex	ids_pts_racc_menuis[2]		
		local pt_C	= ptr_geo.get_vertex	ids_pts_racc_menuis[3]		
		local pt_D	= ptr_geo.get_vertex	ids_pts_racc_menuis[4]
		
		local pt_1		= pt_A		+ 	vec_men_lrg 	+ 	vec_men_ht
		local pt_2		= pt_B		- 	vec_men_lrg 		+ 	vec_men_ht
		local pt_3		= pt_C		- 	vec_men_lrg 		- 	vec_men_ht
		local pt_4		= pt_D		+ 	vec_men_lrg 	- 	vec_men_ht
		
		local pt_5		= pt_1		+ 	vec_men_ep
		local pt_6		= pt_2		+ 	vec_men_ep
		local pt_7		= pt_3		+ 	vec_men_ep
		local pt_8		= pt_4		+ 	vec_men_ep
		
		
		--- creation des points --------------
		local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
		local pts_ids 	= ptr_geo.points 	pts_pos
		
		----- pour plus tard, ... 
		local pts_pourOuvrant	= #( pt_5, pt_6, pt_7, pt_8  )
		
		---- cadre ------
		local nvlFace = ptr_geo.face 		#(	ids_pts_racc_menuis[1]	, 			ids_pts_racc_menuis[2]	, 			ids_pts_racc_menuis[3]	, 			ids_pts_racc_menuis[4]	 ,
											pts_ids[4], 		pts_ids[3], 		pts_ids[2], 		pts_ids[1] , 	
											pts_ids[4], 		ids_pts_racc_menuis[4]	 )			
		ptr_geo.set_matID 	nvlFace	#menuiserie			
		
		local nvlFace = ptr_geo.face 		#(	pts_ids[1], 	pts_ids[2], 	pts_ids[6],   	pts_ids[5]  )	
		ptr_geo.set_matID 	nvlFace	#menuiserie	
		local nvlFace = ptr_geo.face 		#(	pts_ids[6], 	pts_ids[2], 	pts_ids[3],   	pts_ids[7]  )	
		ptr_geo.set_matID 	nvlFace	#menuiserie	
		local nvlFace = ptr_geo.face 		#(	pts_ids[7], 	pts_ids[3], 	pts_ids[4],   	pts_ids[8]  )	
		ptr_geo.set_matID 	nvlFace	#menuiserie	
		local nvlFace = ptr_geo.face 		#(	pts_ids[1], 	pts_ids[5], 	pts_ids[8],   	pts_ids[4]  )		
		ptr_geo.set_matID 	nvlFace	#menuiserie
		
		--- la face du fond -----------
		if not menuis_ouvrant_use do (
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 	pts_ids[6], 	pts_ids[7],   	pts_ids[8]  )		
			ptr_geo.set_matID 	nvlFace	#vitrage
		)
		
		
		
		
		--- TABLETTE  ----------------------------------------------------------------------------------------------------------------		
		if tablette_use and not est_DansBalcon do (
			
			local vec_tab_ht		= 	[0,0,1] 		* tablette_hauteur
			local vec_tab_deb	= -norm_prof 	* tablette_debord
			local vec_tab_cote	= _normDir 	* tablette_cote					
			
			-------	Placement des points 	--------
			local pt_1 		= pt_bas	+  vec_allege 	- 	vec_tab_ht		-	vec_tab_cote	+ vec_tab_deb + [ 0,0, decalage_epaisseur ]
			local pt_2 		= pt_1		+  2 * vec_tab_cote 				+	vec_longueur 	
			local pt_3 		= pt_2		+ 	vec_tab_ht				
			local pt_4		= pt_1		+ 	vec_tab_ht
			
			local pt_5		= pt_1		-	vec_tab_deb
			local pt_6		= pt_2		-	vec_tab_deb			
			local pt_7		= pt_3		-	vec_tab_deb
			local pt_8		= pt_4		-	vec_tab_deb
			
			--- creation des points --------------
			local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
			local pts_ids 	= ptr_geo.points 	pts_pos
			
			-------	Creation des faces 	--------
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )	
			ptr_geo.set_matID 	nvlFace	#menuiserie					
			local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4], 		pts_ids[8] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7], 		pts_ids[3] )	
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			
		)
		
		
		
		
		
		
		
		---  ALLEGE  ----------------------------------------------------------------------------------------------------------------	
		if menuis_allege_use do (
			local vec_allege_ht = vec_men_ht * 1.5
			-------	Placement des points 	--------
			local pt_1 		= pt_bas	+ 	[0,0,1] * menuis_allege_ht	- 	 vec_allege_ht	 + vec_men_lrg + vec_prof
			local pt_2 		= pt_1		+	vec_longueur 			- 2 * vec_men_lrg 
			local pt_3 		= pt_2		+   vec_allege_ht	
			local pt_4		= pt_1		+ 	 vec_allege_ht
			
			local pt_5		= pt_1		+	vec_men_ep
			local pt_6		= pt_2		+	vec_men_ep			
			local pt_7		= pt_3		+	vec_men_ep
			local pt_8		= pt_4		+	vec_men_ep
			
			
			--- creation des points --------------
			local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
			local pts_ids 	= ptr_geo.points 	pts_pos
			
			
			-------	Creation des faces 	--------
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )
			ptr_geo.set_matID 	nvlFace	#menuiserie						
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )	
			ptr_geo.set_matID 	nvlFace	#menuiserie					
			local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			
-- 					-- la face vitre du bas
-- 					local pts_pos 	= #( 	 pts_pourOuvrant[1], pts_pourOuvrant[2] ,pt_6 , pt_5)
-- 					local pts_ids 	= ptr_geo.points 	pts_pos
-- 					local nvlFace = ptr_geo.face 		#(pts_ids[1], 		pts_ids[2]	, 		pts_ids[3] , 	pts_ids[4] )
-- 					ptr_geo.set_matID 	nvlFace	#vitrage			
			
			----- pour plus tard, ... 
-- 					pts_pourOuvrant[1]		= pt_8
-- 					pts_pourOuvrant[2]		= pt_7
			
		)
		
		
		---  TRAVERSE	  ----------------------------------------------------------------------------------------------------------------	
		if menuis_trav_use do (
			
			local vec_traverse_ht = vec_men_ht * 1.5
			-------	Placement des points 	--------
			local pt_1 		= pt_bas	+ 	[0,0,1] * menuis_trav_ht	- 	 vec_allege_ht	 + vec_men_lrg + vec_prof
			local pt_2 		= pt_1		+	vec_longueur 			- 2 * vec_men_lrg 
			local pt_3 		= pt_2		+   vec_allege_ht	
			local pt_4		= pt_1		+ 	 vec_allege_ht
			
			local pt_5		= pt_1		+	vec_men_ep
			local pt_6		= pt_2		+	vec_men_ep			
			local pt_7		= pt_3		+	vec_men_ep
			local pt_8		= pt_4		+	vec_men_ep
			
			
			--- creation des points --------------
			local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
			local pts_ids 	= ptr_geo.points 	pts_pos
			
			
			-------	Creation des faces 	--------
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )
			ptr_geo.set_matID 	nvlFace	#menuiserie						
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )	
			ptr_geo.set_matID 	nvlFace	#menuiserie					
			local nvlFace = ptr_geo.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			
-- 					-- la face vitre du bas
-- 					local pts_pos 	= #( 	 pts_pourOuvrant[1], pts_pourOuvrant[2] ,pt_6 , pt_5)
-- 					local pts_ids 	= ptr_geo.points 	pts_pos
-- 					local nvlFace = ptr_geo.face 		#(pts_ids[1], 		pts_ids[2]	, 		pts_ids[3] , 	pts_ids[4] )
-- 					ptr_geo.set_matID 	nvlFace	#vitrage			
			
			----- pour plus tard, ... 
-- 					pts_pourOuvrant[1]		= pt_8
-- 					pts_pourOuvrant[2]		= pt_7
			
		)
		
		
		local pos_largeur_temp1 = pts_pourOuvrant[1]
		local pos_largeur_temp2 = pts_pourOuvrant[4]
		--- DIVISION  ----------------------------------------------------------------------------------------------------------------	
		for i = 1 to  menuis_divisions  do (
-- 				if menuis_double_use do (
			
			local largeur_vitre = ( distance	pts_pourOuvrant[1] 	pts_pourOuvrant[2] ) / ( menuis_divisions + 1 )
			
			-------	Placement des points 	--------
			local pt_1		= pts_pourOuvrant[1]   			- 		vec_men_lrg - vec_men_ep 	+ _normDir * largeur_vitre * i 
			local pt_2		= pt_1 + 2 * vec_men_lrg
			local pt_3		= pts_pourOuvrant[4]   			+ 		vec_men_lrg - vec_men_ep	+ _normDir * largeur_vitre * i 
			local pt_4		= pt_3  - 2 * vec_men_lrg
			
			local pt_5		= pt_1		+ 	vec_men_ep
			local pt_6		= pt_2		+ 	vec_men_ep
			local pt_7		= pt_3		+ 	vec_men_ep
			local pt_8		= pt_4		+ 	vec_men_ep
			
			--- creation des points --------------
			local pts_pos 	= #( pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
			local pts_ids 	= ptr_geo.points 	pts_pos
			
			---- faces ------
			local nvlFace = ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )				
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )				
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )				
			ptr_geo.set_matID 	nvlFace	#menuiserie			
			
			if menuis_ouvrant_use do (
				
				local pt_1_men = pt_1
				local pt_2_men = pt_2
				local pt_3_men = pt_3
				local pt_4_men = pt_4
				
				local vec_bandeau_ep = vec_men_ep/2
				
				-------	Placement des points 	--------
				local pt_1		= pt_1_men	+ vec_men_lrg * 3/4	-  	vec_bandeau_ep 	-  	vec_men_ht
				local pt_2		= pt_2_men 	- vec_men_lrg * 3/4	-  	vec_bandeau_ep 	-  	vec_men_ht
				local pt_3		= pt_3_men	- vec_men_lrg * 3/4	-  	vec_bandeau_ep 	+  vec_men_ht
				local pt_4		= pt_4_men  	+ vec_men_lrg * 3/4	-  	vec_bandeau_ep 	+  vec_men_ht
				
				local pt_5		= pt_1		+ 	vec_bandeau_ep
				local pt_6		= pt_2		+ 	vec_bandeau_ep
				local pt_7		= pt_3		+ 	vec_bandeau_ep
				local pt_8		= pt_4		+ 	vec_bandeau_ep
				
				--- creation des points --------------
				local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
				local pts_ids 	= ptr_geo.points 	pts_pos
				
				---- faces ------
				local nvlFace = 	ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )					
				ptr_geo.set_matID 	nvlFace	#menuiserie			
				local nvlFace = 	ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )					
				ptr_geo.set_matID 	nvlFace	#menuiserie			
				local nvlFace = 	ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )				
				ptr_geo.set_matID 	nvlFace	#menuiserie			
				
			)
		)
		
		
		
		
		---- Result final -----------------------------------------------------------------------
		#( pt_result_1, pt_result_2, pt_result_3 )
	
	) ---- fin  compo_fnConstruire	--------
	




	
	
	
	
	/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------  VERSION ANTERIEURE   ---------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
						,
				
				
				
				
				
													
													
													
				
				
				
				
				local pos_largeur_temp1 = pts_pourOuvrant[1]
				local pos_largeur_temp2 = pts_pourOuvrant[4]
				--- DOUBLE  ----------------------------------------------------------------------------------------------------------------	
				for i = 1 to  menuis_divisions  do (
-- 				if menuis_double_use do (
					
					local largeur_vitre = ( distance	pts_pourOuvrant[1] 	pts_pourOuvrant[2] ) / ( menuis_divisions + 1 )
					
					-------	Placement des points 	--------
					local pt_1		= pts_pourOuvrant[1]   			- 		vec_men_lrg - vec_men_ep 	+ _normDir * largeur_vitre * i 
					local pt_2		= pt_1 + 2 * vec_men_lrg
					local pt_3		= pts_pourOuvrant[4]   			+ 		vec_men_lrg - vec_men_ep	+ _normDir * largeur_vitre * i 
					local pt_4		= pt_3  - 2 * vec_men_lrg
					
					local pt_5		= pt_1		+ 	vec_men_ep
					local pt_6		= pt_2		+ 	vec_men_ep
					local pt_7		= pt_3		+ 	vec_men_ep
					local pt_8		= pt_4		+ 	vec_men_ep
					
					--- creation des points --------------
					local pts_pos 	= #( pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
					local pts_ids 	= ptr_geo.points 	pts_pos
					
					---- faces ------
					local nvlFace = ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )				
					ptr_geo.set_matID 	nvlFace	#menuiserie			
					local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )				
					ptr_geo.set_matID 	nvlFace	#menuiserie			
					local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )				
					ptr_geo.set_matID 	nvlFace	#menuiserie			
					
					if menuis_ouvrant_use do (
						
						local pt_1_men = pt_1
						local pt_2_men = pt_2
						local pt_3_men = pt_3
						local pt_4_men = pt_4
						
						local vec_bandeau_ep = vec_men_ep/2
						
						-------	Placement des points 	--------
						local pt_1		= pt_1_men	+ vec_men_lrg * 3/4	-  	vec_bandeau_ep 	-  	vec_men_ht
						local pt_2		= pt_2_men 	- vec_men_lrg * 3/4	-  	vec_bandeau_ep 	-  	vec_men_ht
						local pt_3		= pt_3_men	- vec_men_lrg * 3/4	-  	vec_bandeau_ep 	+  vec_men_ht
						local pt_4		= pt_4_men  	+ vec_men_lrg * 3/4	-  	vec_bandeau_ep 	+  vec_men_ht
						
						local pt_5		= pt_1		+ 	vec_bandeau_ep
						local pt_6		= pt_2		+ 	vec_bandeau_ep
						local pt_7		= pt_3		+ 	vec_bandeau_ep
						local pt_8		= pt_4		+ 	vec_bandeau_ep
						
						--- creation des points --------------
						local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
						local pts_ids 	= ptr_geo.points 	pts_pos
						
						---- faces ------
						local nvlFace = 	ptr_geo.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )					
						ptr_geo.set_matID 	nvlFace	#menuiserie			
						local nvlFace = 	ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )					
						ptr_geo.set_matID 	nvlFace	#menuiserie			
						local nvlFace = 	ptr_geo.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )				
						ptr_geo.set_matID 	nvlFace	#menuiserie			
						
					)
				)
				
				
-- 				 
-- 				--- OUVRANT  ----------------------------------------------------------------------------------------------------------------	
-- 				if menuis_ouvrant_use do (
-- 					
-- 					-------	Placement des points 	--------
-- 					local pt_1		= pts_pourOuvrant[1]
-- 					local pt_2		= pts_pourOuvrant[2]
-- 					local pt_3		= pts_pourOuvrant[3]
-- 					local pt_4		= pts_pourOuvrant[4]
-- 					
-- 					local pt_5		= pt_1		+ 	vec_men_lrg 	+ 	vec_men_ht
-- 					local pt_6		= pt_2		- 	vec_men_lrg 	+ 	vec_men_ht
-- 					local pt_7		= pt_3		- 	vec_men_lrg 	- 	vec_men_ht
-- 					local pt_8		= pt_4		+ 	vec_men_lrg 	- 	vec_men_ht
-- 					
-- 					local pt_9		= pt_5		+ 	vec_men_ep
-- 					local pt_10		= pt_6		+ 	vec_men_ep
-- 					local pt_11		= pt_7		+ 	vec_men_ep
-- 					local pt_12		= pt_8		+ 	vec_men_ep
-- 					
-- 					local pts_pourOuvrant	= #( pt_9, pt_10, pt_11, pt_12  )
-- 					
-- 					--- creation des points --------------
-- 					local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 , pt_9, pt_10, pt_11, pt_12 )
-- 					local pts_ids 	= ptr_geo.points 	pts_pos
-- 					
-- 					---- cadre ------
-- 					
-- 					local nvlFace = ptr_geo.face 		#(	pts_ids[1]	, pts_ids[2], pts_ids[3], pts_ids[4], pts_ids[8], pts_ids[7], pts_ids[6], pts_ids[5], pts_ids[8], pts_ids[4] )	
-- 					ptr_geo.set_matID 	nvlFace	#menuiserie					
-- 					
-- 					local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[10],   	pts_ids[9]  )		
-- 					ptr_geo.set_matID 	nvlFace	#menuiserie			
-- 					local nvlFace = ptr_geo.face 		#(	pts_ids[10], 	pts_ids[6], 		pts_ids[7],   	pts_ids[11]  )		
-- 					ptr_geo.set_matID 	nvlFace	#menuiserie			
-- 					local nvlFace = ptr_geo.face 		#(	pts_ids[12], 	pts_ids[11], 	pts_ids[7],   	pts_ids[8]  )		
-- 					ptr_geo.set_matID 	nvlFace	#menuiserie			
-- 					local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[9], 		pts_ids[12],   	pts_ids[8]  )		
-- 					ptr_geo.set_matID 	nvlFace	#menuiserie			
					
					----vitrage
-- 					local nvlFace = ptr_geo.face 		#(	pts_ids[9], 		pts_ids[10], 		pts_ids[11],   	pts_ids[12]  )		
-- 					ptr_geo.set_matID 	nvlFace	#vitrage			
-- 					
-- 				)
-- 				
-- 				 			
				
				----------------------------
-- 				format "-------------> 	BAIE -> pt_results :%\n" #( pt_result_1, pt_result_2, pt_result_3 )
				
				---- Result final -----------------------------------------------------------------------
				#( pt_result_1, pt_result_2, pt_result_3 )
				
				
			), 
	*/
	
	
	
	

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
str_modelBase 	tooltip:compo_tooltip		titre:compo_titre	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	