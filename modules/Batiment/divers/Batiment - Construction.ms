

--- la structure pour créer des geometries du delegate -------------------
include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - Geometrie.ms"



----------- Construction des batiments----------------------------------------------------------------------
struct str_construction (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
-- 		m_debug = true,
		m_debug = true,
		m_dbgPrefix ="urba | str_construction",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		fn logout 	_txt  var:	 param:    =(
			::ecrire 	_txt  	var:var	 param:param	prefix:m_dbgPrefix	script:"URBA"
		),
		
		
		
		---- Membres --------------------------------------------------------------------------------------------------------------------
	private
		m_plug,
	public			
		m_geo		= 	str_geometrie 	(),
		
		
		---- Outils -------------
	private
		m_outils_poly			=	str_poly_outils (),
		m_outils_shape			=	str_shape_outils (),
		
		
		---- tracé Logo  -------------------
	private
		logo = #(	[14.1994,37.717,0], 	[14.1994,-189.586,0], 	[287.927,-189.586,0], 	[287.927,139.601,0], 	[174.501,253.027,0], 	[174.501,479.879,0], 	[61.0754,479.879,0], 	[61.0754,366.453,0], \
						[-52.3504,479.879,0], 	[-392.628,139.601,0], 	[-392.628,-189.586,0],	[-118.9,-189.586,0], 	[-118.9,37.717,0]),
		
		
		
		
		
	---- Fonctions --------------------------------------------------------------------------------------------------------------------
	private
		
		------------ FILTRES-------------------------
		fn filtrer_facades  	_facades  	_etageNum		_id_pt	=(
			
			local facades_result 		= #()
			for facde in _facades  do 
				if 	m_plug.core.est_valide		facde			_etageNum		_id_pt  do
					append facades_result  facde
			facades_result
		),
		
		
		---- elements simples-------------------
	private	
		fn creer_murPlein		_longueur	 =(
			local nvComposant	 				= 	m_plug.core.get_murPlein _longueur
			nvComposant
		),
		fn creer_dalle	z 	matID:#int_sol		flipNormal:false		encart:	=(
			local surface_points 	= m_plug.core.get_surface_points ()
			for pt in surface_points do pt.z = z
			
			local pts_dalle = #()
			if encart != unsupplied then (
				for i = 1 to surface_points.count do (
					local j = if i == surface_points.count then 1 else i + 1
					local k = if i == 1 then surface_points.count else i - 1
					
					local pt 				= 		surface_points[i]
					local	pt_suivant 		=  	surface_points[j]
					local	pt_precedant 	=  	surface_points[k]
					
					local pt_encart 		= m_geo.encart 		pt	(pt_suivant - pt )  	(pt_precedant - pt ) 		encart
					append pts_dalle  pt_encart
				)
				
			) else pts_dalle = surface_points
			
			
			local face = m_geo.face		pts_dalle 	matID:matID    flipNormal:flipNormal
			
			face
		),
		
		------------ Construction-------------------------
	private
		fn creer_proxy					&z =(
			
			
			---- facades------------------
			local ht_bat = m_plug.const_dalle_epaisseur 
			for i = 0 to m_plug.etages_nbre do 
				ht_bat += 	m_plug.core.get_etage_ht	i	+ m_plug.const_dalle_epaisseur 
			
			local hauteur_proxy		=		ht_bat 
			local surface_points 	= m_plug.core.get_surface_points 	()
			local faces 				= m_geo.facesContour	 	surface_points		z 		hauteur_proxy 	matID:#mur
			
			z += hauteur_proxy
			
			---- toiture------------------
			surface_points.z += z
			
			local toiture				=	m_plug.get_toiture ()
			toiture.construire	 	m_plug			surface_points
			/* 
			case m_plug.toiture_type	as name of (
				#sans: (
-- 					debug "Pas de toiture	-	PROXY"
					creer_dalle	( z )  matID:#mur
				)
				#terrasse: (
-- 					debug "toiture terrase	-	PROXY"
				)
				#pan1: (
-- 					debug "toiture 1 PAN	-	PROXY"
				)
				
			) */
			
			
		),
		fn creer_ssBassement  		&z	bat_edition:		=(
			
			if bat_edition!= unsupplied then ()
			
			local surface_points 	= m_plug.core.get_surface_points 	()
			local faces = m_geo.facesContour	 	surface_points		z 		m_plug.const_ssBassement_epaisseur
			m_geo.set_matID 		faces		#mur
			z += m_plug.const_ssBassement_epaisseur
			
		),
		fn creer_etages 				&z	bat_edition:		=(
			
			local bat
			if bat_edition!= unsupplied then 
				bat = bat_edition
			else
				bat =m_plug
			
			local surface_points 	= m_plug.core.get_surface_points ()
			local z_initial 			= copy z
			local facades_total	= 	bat.get_facades ()
			
			
			---- boucle étages ---------------------
			for n_etage = 0 to bat.etages_nbre do (
				
				
				--- hauteur de l'étage -------------
				local etage_ht = (bat.get_etage_ht 	n_etage )
				
				
				
				--- Creation du sol	-----------------------------
				if bat.interieur_use	 do
					creer_dalle	( z + m_plug.const_dalle_epaisseur )  matID:#int_sol		encart:m_plug.const_murExt_epaisseur	
				
				---- on fait le tour des murs 	---------------------
				for id_pt = 1 to surface_points.count do	 (
					
					--- on chope les 2 points du mur a construire et quelques infos (longueur et normal)----------
					local pt_mur_1 = surface_points[ id_pt ]
					local pt_mur_2						
					if id_pt == surface_points.count 	then	pt_mur_2 = surface_points[ 1 ]
																		else	pt_mur_2 = surface_points[ id_pt + 1 ]
					pt_mur_1.z = pt_mur_2.z = z
					local	mur_longueur 		= distance pt_mur_1 	pt_mur_2
					local	mur_norm 			= normalize ( pt_mur_2 -	pt_mur_1 )
					
					---  on regarde si on a des facades pour ce mur ---------------
					local facades_pourCeMur		=	 filtrer_facades  		facades_total  	n_etage		id_pt	
-- 					filtrer_facades_parMurs		facades_etages		mur_longueur	surface_points		id_pt
-- 					
					local 	onA_uneFacade = true
					if facades_pourCeMur.count == 0 	do
						onA_uneFacade = false
						
					---- si on  a des facades on construit la sequence --------------------
					if 	onA_uneFacade  then 
						facades_pourCeMur[1].construire		m_plug 		#(pt_mur_1, pt_mur_2 )	etage_ht:etage_ht		onConstruit_gardeCorps:( n_etage!=0 )
					
						
					else (
					--- sinon un mur plein --------------
						
						local pt_accroche_1 	= 	pt_mur_1 
						local pt_accroche_2 	= 	pt_mur_1 			+ [0,0,	m_plug.const_dalle_epaisseur]
						local pt_accroche_3 	= 	pt_accroche_2 	+ [0,0,  etage_ht ]	
						
						local ptsIDs_accroche 	= ( m_geo.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	)
						
						--- le Composant 'Mur plein' temporaire	------
						local compoTmp 	= creer_murPlein		mur_longueur 	
						ptsIDs_accroche 	= compoTmp.construire		m_plug 		 ptsIDs_accroche		norm_dir:mur_norm  
						
					)
					
				)
				
				z += etage_ht
				
				--- Creation du plafond, ------------------------
				if bat.interieur_use do
					creer_dalle	( z + m_plug.const_dalle_epaisseur )  matID:#int_plafond   flipNormal:true
				
				
				z += m_plug.const_dalle_epaisseur
				
			) --- fin boucle etages -------------
			
		),
		fn creer_toiture					&z 	bat_edition:		=(
			
			local bat
			if bat_edition!= unsupplied then 
				bat = bat_edition
			else
				bat =m_plug
			
			
			--- la toiture en elle meme ---------------
			local surface_points 				= m_plug.core.get_surface_points ()
			for pt in surface_points do
				pt.z = z
			
			local toiture				=	bat.get_toiture ()
			toiture.construire	 	m_plug			surface_points	--	normDir_axeprincipal
			
		),		
		
		fn creer_bat_modeEdition  &z 	bat =(
			
			local surface_points 	= m_plug.core.get_surface_points 	()
			local ht_bat = m_plug.const_dalle_epaisseur 
			
			local faces = m_geo.facesContour	 	surface_points		z 		m_plug.const_ssBassement_epaisseur
			m_geo.set_matID 		faces		#mur
			z += m_plug.const_ssBassement_epaisseur
			
			
			for i = 0 to bat.etages_nbre do 
				ht_bat += bat.get_etage_ht	i	+ m_plug.const_dalle_epaisseur  
			
			local hauteur_proxy	=		ht_bat 
			local faces 				= m_geo.facesContour	 	surface_points		z 		hauteur_proxy matID:#mur
			
			
			z += hauteur_proxy
			creer_dalle	( z )  matID:#mur
		),
		
		
		
		----------- UVWmap------------------
		fn appliquerMapping =(
			
			--- Mapping de maniere global, TODO:generer par  composants---
			local matrxMapping = matrix3 1 	--
			local axeP_mtrx = m_plug.core.get_axePrincipal ()
			rotateZ matrxMapping  (- (quatToEuler2  axeP_mtrx.rotationpart).z )
			polyop.applyUVWMap 	m_plug.delegate  #box	 tm:matrxMapping  channel:1
			
		),
		
		--------- INTERFACE --------------------------------------------------------------------
	public
		fn initialiser 	_plug =(
			m_plug = _plug
			m_geo.initialiser	_plug			
		),
		fn actualiser 	 	bat_edition:	proxy:false	=(
			
-- 			debug "actualiser"
			
			--- on vide la geametrie ------------
			m_geo.vider ()
			
			
			--- si on a pas de surface on dessine le logo ------------
			if m_plug.surface_node == undefined then 				
				m_geo.face		logo
			
			--- sinon on consrtuit le batiment ------------
			else	with redraw OFF (
				
				-- on desactive l'undo pour aller plus vite ---------------
				undo off (
					
					
					local bat
					if bat_edition!= unsupplied then 
						bat = bat_edition
					else
						bat =m_plug
					
					
					---- On définie le Z initial 	----
					local zCourant = -( m_plug.const_ssBassement_epaisseur + m_plug.const_dalle_epaisseur )  + bat.decallage_z
					
-- 					local mode_edition_facades = ( m_plug.core.get_facade_enEdition ()  ) != undefined
					
					
					seed m_plug.alea_seed
			
					if bat_edition != unsupplied then (
						
-- 						debug "Construction MODE EDITION"
-- 						debug "bat_edition" var:bat_edition
						
						if proxy then
							creer_bat_modeEdition 			&zCourant		bat_edition
						else (
							---- ...  et on construit le batiment -----
							creer_ssBassement 				&zCourant		bat_edition:bat_edition
							creer_etages						&zCourant		bat_edition:bat_edition
							creer_toiture						&zCourant		bat_edition:bat_edition
						)
							
					) else if not m_plug.affiche_asProxy 	then (
						
						local chrono_debut = timeStamp ()
						
						---- ...  et on construit le batiment -----
						creer_ssBassement 				&zCourant
						creer_etages						&zCourant
						creer_toiture						&zCourant
					
						displayTempPrompt ("Bâtiment construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." ) 30000
-- 						debug "Batiment construit en "var:( (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." )
						
					) else (
						---- ...  et on construit le proxy -----
						creer_ssBassement 				&zCourant
						creer_proxy 						&zCourant
					)
					
					appliquerMapping ()
					
				)
				
				
			)
			
			redrawViews ()
			
		)
		
) ---- fin struct construire ------------------


























