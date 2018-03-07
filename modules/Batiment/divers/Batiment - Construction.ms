

--- la structure pour créer des geometries du delegate -------------------
include	 "$userScripts\cp-Urba\modules\Batiment\\divers\\Batiment - Geometrie.ms"




----------- Construction des batiments----------------------------------------------------------------------
struct str_construction (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
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
		fn filtrer_facades_parEtages   	_facades 		_etageCourant	 =(
			
			local facades_result =#()
			
			--- on filtre par etages ---------------
			for facde in _facades 		 where facde.params.sequence.count >0 do (
				if facde.params.etagesMin_use then (
					if _etageCourant	>= facde.params.etagesMin  do (
						if facde.params.etagesMax_use then (
							if _etageCourant <= facde.params.etagesMax   do 	
								append facades_result facde
						)	else (
							append facades_result facde
						)
					)
				) else (
					append facades_result facde
				)
			)
			
			facades_result
		),
		fn filtrer_facades_parMurs		_facades	_mur_longueur		_pts		_id_pt				=(
			
			local facades_result 		= #()
			local est_pignon				= m_outils_shape.estPignon 	_pts		_id_pt
			
			---- si la sequence peut rentrer sur le segment de facade ------------
			for facde in _facades /* where  	 facde.sequence.count >0  */do (
				
				if  facde.params.sequence.count >0  do (
				if facde.params.get_longueur () < _mur_longueur do (
					
					---- si la facade est limité en longueur min -----
					if not facde.params.longueurMin_use or facde.params.longueurMin_use	 and 	facde.params.longueurMin < _mur_longueur do (
						
						---- si la facade est limité en longueur max -----
						if not facde.params.longueurMax_use or facde.params.longueurMax_use	 and 	facde.params.longueurMax > _mur_longueur do (
							
							---- si la facade est sur le bon type de mur -----
							case  facde.params.murs of (
								1: append facades_result facde
								2: if not est_pignon do append facades_result facde
								3: if est_pignon do append facades_result facde
							)
						)
					)
				)
			)
			)
	
			facades_result
			
		),
		/* 
-- 		fn filtrer_facades		
		fn choisir_parProbas		_liste	 = (
			local result 	
			
			local probaTotal = 0
			for elem in _liste do 
				probaTotal += elem.probabilite
			local tirage = random  1.  probaTotal
			local trouve = false
			local id = 1
			local probacourant = 0
			if _liste.count > 0 do (
				while not trouve and probacourant <= probaTotal	do (
					probacourant += _liste[id].probabilite
					if tirage < probacourant do (
						trouve = true
						result = _liste[id]
					)
					id += 1
				)
			)
			result
		),
		*/
		
		---- elements simples-------------------
	private
	
		fn creer_murPlein		_longueur	 =(
			local nvComposant	 				= 	m_plug.core.get_murPlein _longueur
			nvComposant
		),
		fn creer_dalle	z 	matID:#int_sol		flipNormal:false	=(
			local surface_points 	= m_plug.core.get_surface_points ()
			for pt in surface_points do pt.z = z
			local face = m_geo.face		surface_points 	matID:matID    flipNormal:flipNormal
			
			face
		),
		
		------------ Construction-------------------------
	private
		fn creer_proxy					&z =(
			local ht_bat = m_plug.const_dalle_epaisseur 
			for i = 0 to m_plug.etages_nbre do 
				ht_bat += m_plug.core.get_etage_ht	i	+ m_plug.const_dalle_epaisseur  
			
			local hauteur_proxy	=		ht_bat 
			local surface_points 	= m_plug.core.get_surface_points 	()
			local faces 				= m_geo.facesContour	 	surface_points		z 		hauteur_proxy
			m_geo.set_matID 		faces		#mur
			
			z += hauteur_proxy
			creer_dalle	( z ) -- matID:#int_sol
			
		),
		fn creer_ssBassement  		&z	=(
			
			local surface_points 	= m_plug.core.get_surface_points 	()
			local faces = m_geo.facesContour	 	surface_points		z 		m_plug.const_ssBassement_epaisseur
			m_geo.set_matID 		faces		#mur
			z += m_plug.const_ssBassement_epaisseur
			
		),
		fn creer_etages 				&z	=(
			
			local z_initial 			= copy z
			local facades_total	= 	m_plug.core.get_facades ()			
			local surface_points 	= m_plug.core.get_surface_points ()
			
			/* 
			----- les étages-----------
			local liste_etages_ht = #()
			for 
			m_plug.etages_min[ _index ]			=	_etages_min
			m_plug.etages_max_use[ _index ]	=	_etages_max_use
			m_plug.etages_max[ _index ]		=	_etages_max
			m_plug.etages_hauteurs[ _index ]	=	_etages_hauteurs		
			
			 */
			
			---- boucle étages ---------------------
			for n_etage = 0 to m_plug.etages_nbre do (
				
				
				--- hauteur de l'étage -------------
				local etage_ht = (m_plug.core.get_etage_ht 	n_etage )
				
				
				
				--- Creation du sol	-----------------------------
				if m_plug.interieur_planchers do
					creer_dalle	( z + m_plug.const_dalle_epaisseur )  matID:#int_sol
				
				
				--- on regarde si on a des facades pour cet étage	---------------
				local facades_etages 	= 	filtrer_facades_parEtages		facades_total 		n_etage
				local onA_uneFacade 	= 	facades_etages.count > 0
				
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
					local facades_pourCeMur		=	filtrer_facades_parMurs		facades_etages		mur_longueur	surface_points		id_pt
					
					if facades_pourCeMur.count > 0 	then	(
							if facades_pourCeMur[1] != undefined then
								onA_uneFacade = true
							else	onA_uneFacade = false
						) else	onA_uneFacade = false
						
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
				if m_plug.interieur_planchers do
					creer_dalle	( z + m_plug.const_dalle_epaisseur )  matID:#int_plafond   flipNormal:true
				
				
				z += m_plug.const_dalle_epaisseur
				
			) --- fin boucle etages -------------
			
		),
		fn creer_toiture					&z =(
			
			local surface_points 				= m_plug.core.get_surface_points ()
			for pt in surface_points do
				pt.z = z
			
			local toiture				=	m_plug.core.get_toiture ()
			toiture.construire	 	m_plug			surface_points	--	normDir_axeprincipal
		),		
		
		
		--------- INTERFACE --------------------------------------------------------------------
	public
		fn initialiser 	_plug =(
			m_plug = _plug
			m_geo.initialiser	_plug			
		),
		fn actualiser 	 =(
			
			debug "actualiser"
			
			--- on vide la geametrie ------------
			m_geo.vider ()
			
			--- si on a pas de surface on dessine le logo ------------
			if m_plug.surface_node == undefined then 				
				m_geo.face		logo
			
			--- sinon on consrtuit le batiment ------------
			else	with redraw OFF (
				
				-- on desactive l'undo pour aller plus vite ---------------
				undo off (
					
					local chrono_debut = timeStamp ()
					
					---- On définie le Z initial 	----
					local zCourant = -( m_plug.const_ssBassement_epaisseur + m_plug.const_dalle_epaisseur )  + m_plug.const_batiment_decallage
					
					local mode_edition_facades = ( m_plug.core.get_facade_enEdition ()  ) != undefined
					if not m_plug.affiche_asProxy and not  mode_edition_facades	then (
						
						---- ...  et on construit le batiment -----
						creer_ssBassement 			&zCourant
						creer_etages						&zCourant
						creer_toiture						&zCourant
					
					) else (
						---- ...  et on construit le proxy -----
						creer_ssBassement 			&zCourant
						creer_proxy 						&zCourant
					)
				)
				
				displayTempPrompt ("Bâtiment construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." ) 30000
				debug "Batiment construit en "var:( (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." )
				
			)
			
			redrawViews ()
			
		)
		
) ---- fin struct construire ------------------


























