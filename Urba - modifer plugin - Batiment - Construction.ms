

-- fileIn "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - material IDs.ms"
 struct 	str_prefs_matID (
	mur 				= 	10,
	menuiserie 	= 	20,
	vitrage 			= 	30,
	toiture 			= 	40,
	metal			=	50
)

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
		m_matID	= 	str_prefs_matID () ,	--fileIn "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - material IDs.ms",
		
		---- Outils -------------
	private
		m_outils_poly			=	str_poly_outils (),
		m_outils_shape			=	str_shape_outils (),
		
-- 		---- Constructeur -------------
-- 	private
		cstr_composants /* 	= str_constructeur_composants () */,
		
		---- tracé Logo  -------------------
	private
		logo = #(	[14.1994,37.717,0], 	[14.1994,-189.586,0], 	[287.927,-189.586,0], 	[287.927,139.601,0], 	[174.501,253.027,0], 	[174.501,479.879,0], 	[61.0754,479.879,0], 	[61.0754,366.453,0], \
						[-52.3504,479.879,0], 	[-392.628,139.601,0], 	[-392.628,-189.586,0],	[-118.9,-189.586,0], 	[-118.9,37.717,0]),
		
		
		---- constantes------------------
	private
		const_ep_ssBassement 	= 	100,
-- 		const_ep_dalle 				= 20,
		const_ep_mur	 			= 20,
		const_ep_couvertine	 	= 5,
		
		
		
		
		
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
			for facde in _facades where  	 facde.sequence.count >0 do
				if facde.sequence_longueur < _mur_longueur do (
					---- si la facade est limité en longueur min -----
					if not facde.longueur_min_use or facde.longueur_min_use	 and 	facde.longueur_min < _mur_longueur do
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
			local 	nvComposant 	= 	cstr_composants.get_murPlein	()
			nvComposant.params.longueur 	= _longueur
			nvComposant
		),	
		fn creer_sequence		_pt1		_pt2		_facade					=(
		
		
-- 			-------- DEBUG----------------------
-- 			local chrono_debut = timeStamp ()
-- 			-------- DEBUG----------------------
			
			--- passerelle ----------
-- 			local creer_murPlein = m_plug.facades.creer_murPlein
			
			debug "creer_sequence"
			
			------------ ANALYSE ------------------------
			local pt_bas, pt_ht	 
			
			local longueurFacade 		= distance _pt1 _pt2
			local normDir					=	normalize ( _pt2 - _pt1)
			local rot 							= m_outils_poly.get_angle_vecteur		normDir
			local longueur_sequence 	= _facade.get_sequence_longueur		()
			local sequence 					= _facade.sequence 		
			local b_espacer 				= _facade.mode == 4
			
-- 			debug "creer_sequence	-1-"
			
			-----	si on a une sequence avec une longueur nulle, on creer un seul mur plein	--------------------------------------
			if longueur_sequence	== 0 then (
				
				sequence = #( creer_murPlein  longueurFacade )
				
			) 
			
				
			-----	calcul du nombre d'espacements de la sequence	--------------------------------------
			local nbr_espacemts 		= 0
			for compo in sequence do
					if compo.type  == #FAC_COMP_ESP 	do
						nbr_espacemts += 1
			
			debug "creer_sequence	-2-"
			
			-----	calcul de la longueur des espacements de la sequence	--------------------------------------
			local nbrRepetitions
			local longueur_restant
			local longueur_espacement
			case _facade.mode of (
				1:  	(	--- Repeter ----
					nbrRepetitions				= floor ( longueurFacade / longueur_sequence )
					longueur_restant 			= longueurFacade - longueur_sequence * nbrRepetitions
					longueur_espacement 	= longueur_restant / ( 2	+ nbr_espacemts * nbrRepetitions )
					b_espacer = false
				)
				2: 	(	--- Etirer ----
					nbrRepetitions				= 1						
					longueur_restant 			= longueurFacade - longueur_sequence * nbrRepetitions 	
					longueur_espacement 	= longueur_restant / ( 2	+ nbr_espacemts * nbrRepetitions )

				)
				3: 	(	--- Centrer ----					
					nbrRepetitions				= 1		
					longueur_restant 			= longueurFacade - longueur_sequence * nbrRepetitions 	
					longueur_espacement 	= longueur_restant / (  nbr_espacemts * nbrRepetitions )
					
				)
				4:		(	--- Espacer ----	
					nbrRepetitions				= floor ( longueurFacade / longueur_sequence )
					longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
					longueur_espacement 	= longueur_restant / ( 1 + nbr_espacemts * nbrRepetitions)
				)						
			)
			
			debug "nbrRepetitions"	var:nbrRepetitions
			
			------------ CONSTRUCTION ------------------------
			
			
			---- pour les balcons --------
			local 	balcon_aConstruire = undefined
			local 	balcon_pt_debut 	, balcon_ptID_debut
			
			--- on creer les 3 premiers points --------				
			local pt_accroche_1 	= 	_pt1
			local pt_accroche_2 	= 	pt_accroche_1 + [0,0,m_plug.etages_epaiss_dalle]
			local pt_accroche_3 	= 	pt_accroche_2 + [0,0,m_plug.etages_hauteur]
			
			local ptsIDs_accroche 		= ( m_geo.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	 	)
			
			
-- 			debug "ptsIDs_accroche	-1-" var:ptsIDs_accroche
			----- le premier espacement ------------
			if _facade.mode != 3 do (
				
				--- Composant 'Mur plein' temporaire	------
				local compoTmp = creer_murPlein		longueur_espacement
				ptsIDs_accroche = compoTmp.construire		m_plug	 	ptsIDs_accroche		normDir
				
			)
			
-- 			debug "ptsIDs_accroche	-2-" var:ptsIDs_accroche
		
			----- les repetitions de sequence ------------------
			for i = 1 to nbrRepetitions do (
				
-- 				debug "creer_sequence	-	nbrRepetitions" var:i
				
				--- la sequence --------
				for composant in sequence do (
					
					-------- DEBUG----------------------
					local chrono_debut_compo = timeStamp ()
					-------- DEBUG----------------------
					
-- 			debug "ptsIDs_accroche	-3a-" var:ptsIDs_accroche
					case  composant.type of (
						--- espacement	----------
						#FAC_COMP_ESP: (
							--- Composant 'Mur plein' temporaire	------
							local compoTmp = creer_murPlein		longueur_espacement
							ptsIDs_accroche = compoTmp.construire		m_plug	 	ptsIDs_accroche		normDir
						)
						--- mur plein	----------
						#FAC_COMP_MUP:	(
							ptsIDs_accroche = composant.construire	 	m_plug			ptsIDs_accroche		normDir		--		est_DansBalcon:(balcon_aConstruire != undefined )
						)
					)
					
					
					
-- 			debug "ptsIDs_accroche	-3b-" var:ptsIDs_accroche
					/* 
					case composant.type    of (
						 #Modele:			(
														
						) -- fin modele 
						#Parametrique: 	(
							local pts_accroche 
							local est_espacement 	= findString composant.param[1].id "#FAC_PES" != undefined
							local est_Balcon_deb 	= findString composant.param[1].id "#FAC_PBD" != undefined
							local est_Balcon_fin 	= findString composant.param[1].id "#FAC_PBF" != undefined
							
							---  ESPACEMENT  ----------
							if 	est_espacement 	then (
								
								--- Composant 'Mur plein' temporaire	------
								local compoTmp = creer_murPlein		longueur_espacement 
								ptsIDs_accroche = compoTmp.param[1].construire	 ptsIDs_accroche		normDir 
								
							---  BALCON  ----------
							) else 	if est_Balcon_deb then  (
								balcon_ptID_debut 	= ptsIDs_accroche[1]	
								balcon_pt_debut 		= polyop.getVert 	m_plug.delegate		ptsIDs_accroche[1]	
								balcon_aConstruire 	= composant
							) else if 	est_Balcon_fin 	then (
								balcon_aConstruire.longueur 			= distance	(polyop.getVert 	m_plug.delegate		ptsIDs_accroche[1]	) 	balcon_pt_debut
								balcon_aConstruire.param[1].construire	 #(balcon_ptID_debut, ptsIDs_accroche[2], ptsIDs_accroche[3])		normDir 
								balcon_aConstruire.longueur 			= 0
								balcon_aConstruire = undefined
							---  DEFAULT  ----------
							) else (
								
								ptsIDs_accroche = composant.param[1].construire	 ptsIDs_accroche		normDir	 		est_DansBalcon:(balcon_aConstruire != undefined )
								
							)
						) -- fin 	#Parametrique
						
					) -- fin case ---------------
					 */
					
					-------- DEBUG----------------------
					local chrono_fin_compo = timeStamp ()
-- 						debug "creer_sequence		compo" var:composant.nom
-- 						debug "creer_sequence		durée compo" var:(   (chrono_fin_compo - chrono_debut_compo ) / 1000.0)
					-------- DEBUG----------------------
				
					
					
				) --- fin de la sequence -----
				
				if b_espacer do (
					
					--- Composant 'Mur plein' temporaire	------
					local compoTmp = creer_murPlein		longueur_espacement 		
					ptsIDs_accroche = compoTmp.construire	 	m_plug		ptsIDs_accroche		normDir
					
				)
				
			)  --- fin de la repetition
			 
			
			if not b_espacer and  _facade.mode != 3 do (
				
				--- le dernier espacement --------				
				--- Composant 'Mur plein' temporaire	------
				local compoTmp = creer_murPlein		longueur_espacement 		
				ptsIDs_accroche = compoTmp.construire		m_plug	 	ptsIDs_accroche		normDir
				
			)
			
-- 			-------- DEBUG----------------------
-- 			local chrono_fin = timeStamp ()
-- 			debug "creer_sequence		durée TOTAL" var:(   (chrono_fin - chrono_debut ) / 1000.0)
-- 			-------- DEBUG----------------------
			
		),
		
		
		------------ TOITURES-------------------------		
	private
		fn toitPentes 				&z	_nbrePentes	=(
			
			local surface_points 	= m_plug.core.get_surface_points ()
			
			local	 mtrx_axeP	=	m_plug.axeP_mtrx
			local	 BB_axeP	=	m_plug.axeP_BB
			translate mtrx_axeP	BB_axeP[1]
			
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
			local largeur 		=	diag_axeP.x
			local longeur 		= 	diag_axeP.z
			local hauteur 		= largeur * tan m_plug.toit_pente		--	largeur /2 --* random .3 1.5
			
			local nvlsFaces 				= #()
			
			case _nbrePentes of (
				1: ( ---------- 1 PENTE ----------------------------------------------------------------------------------------------------
						--- gestion de l'angle de la pente .... ----
	-- 						hauteur = hauteur/4
						
						local pt_0 = (  [0,0,0]  *  mtrx_axeP )
						local pt_1 = (  [0,0,longeur]  *  mtrx_axeP )
						local pt_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )
						
						local vec1 = pt_1 - pt_0
						local vec2 = pt_2 - pt_0
						
						local pt_Origine = pt_0
						pt_Origine.z =  z + m_plug.toit_hauteur
					
						local plan_pente = str_plan ()
						plan_pente.creerFrom_2vecs_et_1Point	vec1	vec2		pt_Origine
						
						local pointsPente = #()
						local pointsMurs   =#()
						for i = 1 to  surface_points.count do (
							
							local j = i+1
							if j >  surface_points.count  do j = 1
							
							--- point Mur ----
							local pt 			= 	surface_points[i]	
							pt.z = z
							append pointsMurs  pt		
							
							local pt_result = plan_pente.projeter_point_verticalement 	pt
	-- 						pt_result.z += m_plug.toit_hauteur
							append pointsPente  pt_result
							
						)
						
						--- creation de la face du dessus ----
						local faceDessus =  m_geo.pointsEtFaces 	pointsPente 	
						append nvlsFaces faceDessus
						
						-- m_matID --
						polyop.setFaceMatID m_plug.delegate  #(faceDessus) 	m_matID.toiture
						
						---- creation des raccord mur ----------
						local facesMurs = #()
						for i = 1 to pointsMurs.count  do (
							
							local j = i+1
							if j >  pointsMurs.count  do j = 1
							
							local ptMur1 		= pointsMurs[i]
							local ptMur2 		= pointsMurs[j]
							local ptPente3 	= pointsPente[j]
							local ptPente4	= pointsPente[i]
							
							local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
							local faceMurs = m_geo.pointsEtFaces 	pointsRaccord 	
							append nvlsFaces faceMurs
							polyop.setFaceMatID m_plug.delegate  #(faceMurs) 	m_matID.mur
						)
					
						
						
						-- souder les points --
						local vertsASouder =#()
						for IDFace in nvlsFaces do (
							local vertsFace = polyop.getFaceVerts m_plug.delegate	 IDFace
							for vert in vertsFace do 
								appendIfUnique  vertsASouder 	vert
							-- m_plug.delegate.weldThreshold
						)
						polyop.weldVertsByThreshold m_plug.delegate 		(vertsASouder as bitArray)
						
						
						---- debord et epaisseur du toit -----
						polyop.bevelFaces 	m_plug.delegate  	faceDessus 	0.0 	30.
						polyop.extrudeFaces m_plug.delegate  	faceDessus 	20.
						
						
-- 						format ".extrustionType : %\n" m_plug.delegate.extrustionType
-- 						polyop.extrudeFaces m_plug.delegate  	nvlsFaces 	0.0
-- 						polyop.extrudeFaces m_plug.delegate  	nvlsFaces 	0.0
						
						
				)
				2: (---------- 2 PENTES ----------------------------------------------------------------------------------------------------
					
					
						--- Plan de la Pente 1  ----
						local pt_P1_0 = (  [0,0,0]  *  mtrx_axeP )
						local pt_P1_1 = (  [0,0,longeur]  *  mtrx_axeP )
						local pt_P1_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )	
					
						local vecP1_1 = pt_P1_1 - pt_P1_0
						local vecP1_2 = pt_P1_2 - pt_P1_0
						
						local pt_Origine = pt_P1_0
						pt_Origine.z =  z + m_plug.toit_hauteur
						local plan_pente1 = str_plan ()
						plan_pente1.creerFrom_2vecs_et_1Point	vecP1_1		vecP1_2		pt_Origine
					
					
					
						--- Plan de la Pente 1  ----
						local pt_P2_0 = (  [largeur,0,longeur]  *  mtrx_axeP )
						local pt_P2_1 = (  [largeur,0,0]  *  mtrx_axeP )
						local pt_P2_2 = (  [0 ,hauteur,longeur]  *  mtrx_axeP )			
					
						local vecP2_1 = pt_P2_1 - pt_P2_0
						local vecP2_2 = pt_P2_2 - pt_P2_0
						
						local pt_Origine = pt_P2_0
						pt_Origine.z =  z + m_plug.toit_hauteur
						local plan_pente2 = str_plan ()
						plan_pente2.creerFrom_2vecs_et_1Point	vecP2_1		vecP2_2		pt_Origine
					
						--- Plan verticale faitage ------
						local pt_F_0 = (  [largeur /2 ,0,0]  *  mtrx_axeP )
						local pt_F_1 = (  [largeur /2 ,0,longeur]  *  mtrx_axeP )
						local pt_F_2	=	pt_F_0 + [0,0,100]				
						
						local vec_F_1 = pt_F_1 - pt_F_0
						local vec_F_2 = pt_F_2 - pt_F_0				
						
						local pt_Origine = pt_F_0
						pt_Origine.z =  z 
						
						local plan_verticaleFaitage = str_plan ()
						plan_verticaleFaitage.creerFrom_2vecs_et_1Point	vec_F_1		vec_F_2		pt_Origine
						
						
						
						---- creation des liste des points-----------
						local pointsPente = #()
						local pointsPente1 = #()
						local pointsPente2 = #()
						local pointsMurs   =#()
						for i = 1 to  surface_points.count do (
							
							local j = i+1
							if j >  surface_points.count  do j = 1
							
							
							--- point Mur ----
							local pt 			= 	surface_points[i]	
							pt.z = z
							append pointsMurs  pt		
							
							--- point pente ----
							local pt_pente1 = plan_pente1.projeter_point_verticalement 	pt
							local pt_pente2 = plan_pente2.projeter_point_verticalement 	pt
							if pt_pente1.z < pt_pente2.z then (
								append pointsPente  	pt_pente1
								append pointsPente1 	pt_pente1
								
							) else  (
								append pointsPente  	pt_pente2
								append pointsPente2  	pt_pente2
							)
							
							--- point mur - faitage ----
							local pt_suivant 	= 	surface_points[j]	
							pt_suivant.z = z
							local intersect = plan_verticaleFaitage.coupe_segment	pt 	pt_suivant							
							if intersect do (
								local pt_faitage_mur = plan_verticaleFaitage.get_intersection_segment 	pt 	pt_suivant
								append pointsMurs  	pt_faitage_mur
								local pt_faitage_pente = plan_pente1.projeter_point_verticalement 	pt_faitage_mur
								append pointsPente  pt_faitage_pente
								
								
								append pointsPente1 	pt_faitage_pente
								append pointsPente2 	pt_faitage_pente
							)
							
							
							
						)
						
						
						
						
						--------- creation des geometries ---------------------
						--- les murs ----
						for i = 1 to pointsMurs.count  do (
							
							local j = i+1
							if j > pointsMurs.count do j = 1
							
							local ptMur1 		= pointsMurs[ i ]
							local ptMur2 		= pointsMurs[ j ]
							local ptPente3 	= pointsPente[ j ]
							local ptPente4	= pointsPente[ i ]
							
							local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
							local nvlFace = m_geo.pointsEtFaces 	pointsRaccord 	
							append nvlsFaces nvlFace
							-- m_matID --
							polyop.setFaceMatID m_plug.delegate  nvlFace 	m_matID.mur
						) 
						
						
						--- les pentes -----
						local facesDessus =#()
						local face1 =  m_geo.pointsEtFaces 		pointsPente1 	
						local face2 =  m_geo.pointsEtFaces 		pointsPente2 	
						
						append facesDessus face1
						append facesDessus face2
						
						append nvlsFaces face1
						append nvlsFaces face2
						
						
						-- m_matID --
						polyop.setFaceMatID m_plug.delegate  facesDessus 	m_matID.toiture
						
						
						
						
						
						-- souder les points --
						local vertsASouder =#()
						for IDFace in nvlsFaces do (
							local vertsFace = polyop.getFaceVerts m_plug.delegate	 IDFace
							for vert in vertsFace do 
								appendIfUnique  vertsASouder 	vert
							-- m_plug.delegate.weldThreshold
						)
						polyop.weldVertsByThreshold m_plug.delegate 		(vertsASouder as bitArray)
						
						facesDessus = #( m_plug.delegate.getNumFaces () - 1, m_plug.delegate.getNumFaces () )
						---- debord et epaisseur du toit -----
						polyop.bevelFaces 		m_plug.delegate  	facesDessus 	0.0 	30.
						polyop.extrudeFaces 	m_plug.delegate  	facesDessus 	20.
				)
			)
		),		
		fn acrotere					_face		= (
			
			---- les murs -----
			-- m_matID --
			polyop.setFaceMatID m_plug.delegate  #(_face) 	m_matID.mur
			-- gemoetrie --			
			polyop.bevelFaces m_plug.delegate 	#(_face) 	0 	-const_ep_mur
			local faceAExtruder = #{_face+1..(polyop.getNumFaces m_plug.delegate)} as array
			polyop.extrudeFaces  m_plug.delegate 	faceAExtruder 	m_plug.toit_hauteur
			
			
			---- la couvertine  -----
			-- m_matID --
			polyop.setFaceMatID m_plug.delegate  faceAExtruder 	m_matID.metal
			-- gemoetrie --
			polyop.bevelFaces m_plug.delegate 	faceAExtruder		0 	const_ep_couvertine
			polyop.extrudeFaces m_plug.delegate 	faceAExtruder		const_ep_couvertine
			
			local faceToitsSurface = m_outils_poly.etendreFaces  	m_plug.delegate 	#(_face)
			
			format "faceToitsSurface : %\n" faceToitsSurface
			
			
			-- m_matID --
			polyop.setFaceMatID m_plug.delegate  faceToitsSurface 	m_matID.toiture
			
		),		
		fn toit 						&z =(
			
			local surface_points 	= m_plug.core.get_surface_points ()
			
			case m_plug.toit_type of (
				1: (	---- PLAT	----	-- for pt in m_plug.surface_points collect [pt.x,pt.y,z]
					m_geo.pointsEtFaces		surface_points		  	m_matID:m_matID.toiture
				)
				2: (	---- ACROTERE	----
					
					
					--- creation de la facette globale-----
					local faceDuToit 			= m_geo.pointsEtFaces		surface_points		
					
					acrotere			faceDuToit
					
				)
				3: (	---- 1 PAN	----
					toitPentes					&z  1
				)
				4: (	---- 2 PANS	----
					toitPentes					&z  2
				)
			)
		),		
		
		
		------------ FACADES-------------------------
	private
		fn creer_ssBassement  		&z	=(
			
			local surface_points 	= m_plug.core.get_surface_points ()
			m_geo.facesContour	 	surface_points		z 	const_ep_ssBassement	
			z += const_ep_ssBassement
			
		),
		fn creer_facades 				&z	=(
			
			debug "Construction des étages ----------------------------------------------------------------------"
			
			local z_initial 			= copy z
			local facades_total	= 	m_plug.core.get_facades ()			
			local surface_points 	= m_plug.core.get_surface_points ()
			
			---- boucle étages ---------------------
			for n_etage = 0 to m_plug.etages_nbre do (
				
-- 				debug "etage num" var:n_etage
				
				--- on regarde si on a des facades pour cet étage	---------------
				local facades_etages 	= 	filtrer_facades_parEtages		facades_total 		n_etage
				local onA_uneFacade 	= 	facades_etages.count > 0
				
				---- on fait le tour des murs 	---------------------
				for id_pt = 1 to surface_points.count do	 (
-- 					
-- 					debug "id_pt	-----------------------------------" 
					
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
							)else	onA_uneFacade = false
					
-- 					debug "onA_uneFacade" var:onA_uneFacade
-- 					debug "facades_pourCeMur" var:facades_pourCeMur
									
					
					---- si on  a des facades ------
					if 	onA_uneFacade  then (
						
						--- on construit la sequence --------------
						creer_sequence		pt_mur_1		pt_mur_2	 facades_pourCeMur[1]
						
					) else (
					--- sinon un mur plein --------------
						
						local pt_accroche_1 	= 	pt_mur_1 
						local pt_accroche_2 	= 	pt_mur_1 + [0,0,	m_plug.etages_epaiss_dalle]
						local pt_accroche_3 	= 	pt_accroche_2 + [0,0,m_plug.etages_hauteur]	
						
						local ptsIDs_accroche 	= ( m_geo.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	)
						
						--- le Composant 'Mur plein' temporaire	------
						local compoTmp 	= creer_murPlein		mur_longueur 	
						ptsIDs_accroche 	= compoTmp.construire	m_plug 		 ptsIDs_accroche		mur_norm 
						
					)
					
				)
				
				z += m_plug.etages_hauteur + m_plug.etages_epaiss_dalle
				
				/* --- dalle plancher ---
				if const_ep_dalle  != 0 do (
					local nvlsFaces = m_geo.facesContour	m_plug.surface_points	z 	const_ep_dalle	m_plug
					facesDunEtage  += nvlsFaces
					z += const_ep_dalle
				)  */
				
			) --- fin boucle etages -------------
			
			m_geo.facesContour	 (	m_plug.core.get_surface_points ()	)	z 	m_plug.etages_epaiss_dalle
			z += m_plug.etages_epaiss_dalle
			
		),
		
		
		
		/* 
		fn creer_facades 					&z	=(
			
			debug "Construction des étages ----------------------------------------------------------------------"
			
			local z_initial 			= copy z
			local facades_total	= 	m_plug.core.get_facades ()			
			local surface_points 	= m_plug.core.get_surface_points ()
			
			---- boucle étages ---------------------
			for n_etage = 0 to m_plug.etages_nbre do (
				
				debug "etage num" var:n_etage
				
				--- filtre par etages ---------------
				local facades_etages 	= 	filtrer_facades_parEtages		facades_total 		n_etage
				local onA_uneFacade 	= 	facades_etages.count > 0
				
				---- boucle  murs ---------------------
				for id_pt = 1 to surface_points.count do	 (
					
					debug "id_pt	-----------------------------------" 
					
					--- les 2 points du mur ----------
					local pt_mur_1 = surface_points[ id_pt ]
					local pt_mur_2						
					if id_pt == surface_points.count 	then	pt_mur_2 = surface_points[ 1 ]
																		else	pt_mur_2 = surface_points[ id_pt + 1 ]
					pt_mur_1.z = pt_mur_2.z = z
					
					local	mur_longueur 		= distance pt_mur_1 	pt_mur_2
					local	mur_norm 			= normalize ( pt_mur_2 -	pt_mur_1 )
					
					---  filtre par  murs  ---------------
					local facades_pourCeMur			=	filtrer_facades_parMurs		facades_etages		mur_longueur	surface_points		id_pt
					
					if facades_pourCeMur.count > 0 do 
						if facades_pourCeMur[1].sequence.count == 0
							then		onA_uneFacade = false
							else 		onA_uneFacade = true
					
					debug "onA_uneFacade" var:onA_uneFacade
					debug "facades_pourCeMur" var:facades_pourCeMur
					
					-- on verifie qu'il a des composants -----
					
					
					
					---- si on  a des facades ------
					if 	onA_uneFacade  then (
						
						--- on construit la sequence --------------
						creer_sequence		pt_mur_1		pt_mur_2	 facades_pourCeMur[1]
						
					) else (
					--- sinon un mur plein --------------
						
						--- Composant 'Mur plein' temporaire	------
						local pt_accroche_1 	= 	pt_mur_1 
						local pt_accroche_2 	= 	pt_mur_1 + [0,0,	m_plug.etages_epaiss_dalle]
						local pt_accroche_3 	= 	pt_accroche_2 + [0,0,m_plug.etages_hauteur]	
						
						local ptsIDs_accroche 	= ( m_geo.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	)
						
						local compoTmp 	= creer_murPlein		mur_longueur 	
						ptsIDs_accroche 	= compoTmp.construire	m_plug 		 ptsIDs_accroche		mur_norm 
						
					)
					
				)
				
				z += m_plug.etages_hauteur + m_plug.etages_epaiss_dalle
				
-- 				 --- dalle plancher ---
-- 				if const_ep_dalle  != 0 do (
-- 					local nvlsFaces = m_geo.facesContour	m_plug.surface_points	z 	const_ep_dalle	m_plug
-- 					facesDunEtage  += nvlsFaces
-- 					z += const_ep_dalle
-- 				)  
				
			) --- fin boucle etages -------------
			
			m_geo.facesContour	 (	m_plug.core.get_surface_points ()	)	z 	m_plug.etages_epaiss_dalle
			z += m_plug.etages_epaiss_dalle
			
		),
		 */
		
		/* 
		--------- MODELES -----------------
		fn importer_modeles				=(
			modeles_import =#()
			for modele in m_plug.facades.get_modeles ()	 do (
				--- nouveau node -----
				local 	nvNode = convertToPoly (mesh ())
				append 	modeles_import		nvNode
				polyop.deleteFaces	nvNode	(#{1..25} as array)		
					
				m_plug.facades.scan.creer_objet		modele			ndDest:nvNode
			)
		),
		fn retirer_modelesImports	   =(			
			for modele in modeles_import	 do delete modele
			modeles_import =#()
		),
		 */
		
		
		--------- INTERFACE --------------------------------------------------------------------
	public
		fn initialiser 	_plug =(
			m_plug = _plug
			m_geo.initialiser	_plug
			cstr_composants = _plug.core.get_mgr_composants ()
			
		),
		fn actualiser 	 =(
			
			debug "actualiser"
			
			--- on vide la geametrie ------------
			m_geo.vider ()
			
			
			--- si on a pas de surface on dessine le logo ------------
			if m_plug.surface_node == undefined then 				
				m_geo.face		logo
			
			
			
			--- sinon on consrtuit le batiment ------------
			else 	with redraw OFF (
				
				debug "On consrtuit le batiment "
				
				-- on desactive l'undo pour aller plus vite ---------------
				undo off (
					
					local chrono_debut = timeStamp ()
					
					---- On définie le Z initial 	----
					local zCourant = -( const_ep_ssBassement + m_plug.etages_epaiss_dalle )
					
					---- ...  et on construit le batiment -----
					creer_ssBassement 			&zCourant
					creer_facades					&zCourant
-- 					toit					&zCourant
					
					
					
					/*	--- Mapping de maniere global, TODO:generer par  composants		---
					
					matrxMapping = matrix3 1 
					rotateZ matrxMapping  ( 90 - (quatToEuler2  m_plug.axeP_mtrx.rotationpart).z )
					polyop.applyUVWMap 	m_plug.delegate  #box	 tm:matrxMapping  channel:1
					
					*/	-----------------------------------
					
				)
				
				displayTempPrompt ("Bâtiment construit en " +  (  ((timeStamp ()) - chrono_debut ) / 1000.0)	as string + "s." ) 10000
				
			)
			
			redrawViews ()
			
		)
		
) ---- fin struct construire ------------------


























