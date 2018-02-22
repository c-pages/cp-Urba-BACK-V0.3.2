

--- la structure pour créer des geometries du delegate -------------------
include	 "$userScripts\cp-Urba\modules\Batiment\Batiment - Geometrie.ms"




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
		
		
		
		---- Membres ---------------------------------------------
	private
		m_plug,
	public			
		m_geo		= 	str_geometrie 	(),
-- 		m_matID	= 	str_prefs_matID () ,	--fileIn "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - material IDs.ms",
		
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
			for facde in _facades 		 where facde.sequence.count >0 do (
				if facde.etages_min_use then (
					if _etageCourant	>= facde.etages_min  do (
						if facde.etages_max_use then (
							if _etageCourant <= facde.etages_max   do 	
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
				
				if  facde.sequence.count >0  do (
				if facde.sequence_longueur < _mur_longueur do (
					
					---- si la facade est limité en longueur min -----
					if not facde.longueur_min_use or facde.longueur_min_use	 and 	facde.longueur_min < _mur_longueur do (
						
						---- si la facade est limité en longueur max -----
						if not facde.longueur_max_use or facde.longueur_max_use	 and 	facde.longueur_max > _mur_longueur do (
							
							---- si la facade est sur le bon type de mur -----
							case  facde.murs of (
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
			local mgr_composants 				=	m_plug.core.get_mgr_composants ()
			local nvComposant	 				= 	mgr_composants.get_murPlein	()
			nvComposant.params.longueur 	=	_longueur
			nvComposant
		),
		fn get_sequenceFacade		_facade		_longueur_facade	=(
			
-- 			debug "get_sequenceFacade" 
			
			local	nbr_espacemts				=	0
			local	nbr_repetitions				=	0
			local	longueur_restant			=	0
			local	longueur_espacement	=	0
			local	espacer 						= _facade.mode == 4
			local longueur_sequence 		= _facade.get_sequence_longueur		()	
			
			local	sequence_totale 			= #()
			
			
			-----	calcul du nombre d'espacements de la sequence	--------------------------------------
			for compo in _facade.sequence do
					if compo.type  == #espacement 	do
						nbr_espacemts += 1
			
			-----	calcul de la longueur des espacements de la sequence	--------------------------------------
			case _facade.mode of (
				1:  	(	--- Repeter ----
					nbr_repetitions				= floor ( _longueur_facade / longueur_sequence )
					longueur_restant 			= _longueur_facade - longueur_sequence * nbr_repetitions
					longueur_espacement 	= longueur_restant / ( 2	+ nbr_espacemts * nbr_repetitions )
					espacer 						= false
				)
				2: 	(	--- Etirer ----
					nbr_repetitions				= 1						
					longueur_restant 			= _longueur_facade - longueur_sequence * nbr_repetitions 	
					longueur_espacement 	= longueur_restant / ( 2	+ nbr_espacemts * nbr_repetitions )

				)
				3: 	(	--- Centrer ----					
					nbr_repetitions				= 1		
					longueur_restant 			= _longueur_facade - longueur_sequence * nbr_repetitions 	
					longueur_espacement 	= longueur_restant / (  nbr_espacemts * nbr_repetitions )
					
				)
				4:		(	--- Espacer ----	
					nbr_repetitions				= floor ( _longueur_facade / longueur_sequence )
					longueur_restant 			= _longueur_facade - longueur_sequence * (nbr_repetitions )		
					longueur_espacement 	= longueur_restant / ( 1 + nbr_espacemts * nbr_repetitions)
				)						
			)
			
-- 			debug "----------------------------------------------------"
-- 			debug "_longueur_facade" var:_longueur_facade
-- 			debug "longueur_sequence" var:longueur_sequence
-- 			debug "nbr_repetitions" var:nbr_repetitions
-- 			debug "longueur_restant" var:longueur_restant
-- 			debug "longueur_espacement" var:longueur_espacement
-- 			debug "----------------------------------------------------"
			
			-------------------- la SEQUENCE TOTALE	----------------------------------------------------------------------------------------
			-----	si on a une sequence avec une longueur nulle, on creer un seul mur plein	--------------------------------------		
		 	if longueur_sequence	== 0 then (
				sequence_totale 	= #( creer_murPlein  longueur_facade )
			) else (
				
				-----	on remplace les espacements de la sequence par des murs pleins	--------------------------------------
				local sequence_simple		= for compo in 	_facade.sequence collect compo
				for i=1 to _facade.sequence.count do (
					local composant = sequence_simple[i]
					if composant.type  == #espacement 	then
						sequence_simple[i] = creer_murPlein  longueur_espacement
				)
				
				--------------puis on creer la sequence total du mur	--------------------------------------
				----- le premier espacement ------------
				if _facade.mode != 3 do 
					append sequence_totale	(  creer_murPlein  longueur_espacement )
				
				-- les boucles de la facade simple	--------
				for i = 1 to nbr_repetitions do (				
					----- les repetitions de sequence ------------------
					for compo	in	 sequence_simple	do 						
						append sequence_totale	compo
					if espacer do 
						append sequence_totale	(  creer_murPlein  longueur_espacement )
				)
				
				----- le dernier espacement ------------
				if not espacer and  _facade.mode != 3 do 
						append sequence_totale	(  creer_murPlein  longueur_espacement )					
				
			)
			
			sequence_totale
		),
		fn creer_sequence		_pt1		_pt2		_facade					=(
			
-- 			debug "creer_sequence"
			
			------------ ANALYSE ------------------------------------------------------------------
			local longueur_facade 	= 	distance _pt1 _pt2
			local normDir				=	normalize ( _pt2 - _pt1)			
			
			--- on  recupere la sequence totale de la facade en question ----
			local sequenceTotal  		=	get_sequenceFacade		_facade		longueur_facade	
			
			------------ CONSTRUCTION  DE LA FACADE	------------------------------------
			--- on créé  les 3 premiers points --------				
			local pt_accroche_1 		= 	_pt1
			local pt_accroche_2 		= 	pt_accroche_1 + [0,0,m_plug.const_dalle_epaisseur]
			local pt_accroche_3 		= 	pt_accroche_2 + [0,0,m_plug.etages_hauteur]			
			local ptsIDs_accroche 	= ( m_geo.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	 	)
			
			
			--- gestion balcon	------
			local balcon_ptID_debut, 		balcon_pts_debut, 		balcon_aConstruire
			
			---  on créé la facade avec la sequence total --------
			for composant in sequenceTotal do (
				case composant.type of (
					#balcon:(
						balcon_pts_debut 	= ptsIDs_accroche
						balcon_aConstruire 	= composant
					)
					#balconFin:(
						local		pt_balcon_debut	=	polyop.getVert 	m_plug.delegate		balcon_pts_debut[1]	
						local		pt_balcon_fin		=	polyop.getVert 	m_plug.delegate		ptsIDs_accroche[1]	
						balcon_aConstruire.params.longueur = 		(	distance	pt_balcon_debut 	pt_balcon_fin	)
						balcon_aConstruire.construire	 	m_plug			balcon_pts_debut		normDir
-- 					balcon_aConstruire.params.longueur = 	0
					)
					default:(
						-----	construction geometrie du composant	----------
						ptsIDs_accroche = composant.construire	 	m_plug			ptsIDs_accroche		normDir		--		est_DansBalcon:(balcon_aConstruire != undefined )
						
					)
				)
			) --- fin de la sequence -----
			
		),
		
		------------ Construction-------------------------
	private
		fn creer_ssBassement  		&z	=(
			
			local surface_points 	= m_plug.core.get_surface_points ()
			local faces = m_geo.facesContour	 	surface_points		z 		m_plug.const_ssBassement_epaisseur
			m_geo.set_matID 		faces		#mur
			z += m_plug.const_ssBassement_epaisseur
			
		),
		fn creer_facades 				&z	=(
			
			local z_initial 			= copy z
			local facades_total	= 	m_plug.core.get_facades ()			
			local surface_points 	= m_plug.core.get_surface_points ()
			
			---- boucle étages ---------------------
			for n_etage = 0 to m_plug.etages_nbre do (
				
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
					
					if facades_pourCeMur.count > 0 
							then	(
								if facades_pourCeMur[1] != undefined then
									onA_uneFacade = true
								else	onA_uneFacade = false
							) else	onA_uneFacade = false
							
					---- si on  a des facades on construit la sequence --------------------
					if 	onA_uneFacade  then 
						creer_sequence		pt_mur_1		pt_mur_2	 facades_pourCeMur[1]
						
					else (
					--- sinon un mur plein --------------
						
						local pt_accroche_1 	= 	pt_mur_1 
						local pt_accroche_2 	= 	pt_mur_1 			+ [0,0,	m_plug.const_dalle_epaisseur]
						local pt_accroche_3 	= 	pt_accroche_2 	+ [0,0,m_plug.etages_hauteur]	
						
						local ptsIDs_accroche 	= ( m_geo.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	)
						
						--- le Composant 'Mur plein' temporaire	------
						local compoTmp 	= creer_murPlein		mur_longueur 	
						ptsIDs_accroche 	= compoTmp.construire	m_plug 		 ptsIDs_accroche		mur_norm 
						
					)
					
				)
				
				z += m_plug.etages_hauteur + m_plug.const_dalle_epaisseur
				
			) --- fin boucle etages -------------
			/* 
			local faces = m_geo.facesContour	 (	m_plug.core.get_surface_points ()	)	z 	m_plug.const_dalle_epaisseur
			m_geo.set_matID 		faces		#mur
			z += m_plug.const_dalle_epaisseur
			 */
		),
		fn creer_toiture					&z =(
			
			local surface_points 				= m_plug.core.get_surface_points ()
			for pt in surface_points do
				pt.z = z
			
			local toiture							=	m_plug.core.get_toiture ()
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
					local zCourant = -( m_plug.const_ssBassement_epaisseur + m_plug.const_dalle_epaisseur )
					
					---- ...  et on construit le batiment -----
					creer_ssBassement 			&zCourant
					creer_facades					&zCourant
					creer_toiture						&zCourant
					
				)
				
				displayTempPrompt ("Bâtiment construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." ) 30000
				
			)
			
			redrawViews ()
			
		)
		
) ---- fin struct construire ------------------


























