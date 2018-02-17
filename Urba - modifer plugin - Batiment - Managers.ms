
	
	

	

----------------- Manager des COMPOSANTS	------------------------------------------
struct 	str_mgr_composants (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_composants",
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix	catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
		m_plug,
	private
		
		m_modelesBase =#(),
		
		---- Le tableau des éléments --------
		m_items	=	#(),
		
		fn get_nouveauComposant =(
			--- on importe le fichier du struct des composants (pour avoir accés meme si le plug est pas actif)---
			include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Elements - Composant.ms"
			str_composant ()
		),
		
		
		
		
		/*
		fn espacement 	=(
			
			--- les parametres du composant --------------
			local params = struct param (
				longueur = 0
			)
			local dialog  = rollout dialog "Espacement" width:180 height:70	(
									local m_compo, m_rollPrt, m_param
									fn actualiser =()
								)
			fn fnConstruire  	_plug	 	pts_accroches		_normDir			_composant		=()
			
			--- Creation du composant --------------
			local nvComposant = get_nouveauComposant 	()
			nvComposant.initialiser			#FAC_COMP_ESP		"Espacement"
			nvComposant.set_dialog			dialog
			nvComposant.set_params	 	( params () )
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		),
		---- Mur plein -------------------------------------------
		fn murPlein 	=(
			
			local params = struct param (
				longueur = 100
			)
			local dialog  = rollout dialog "Mur plein" width:180 height:70	(
									local m_compo
									local m_rollPrt
									local m_param
									
									edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
									GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
									label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
									spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
									
									fn actualiser =(
										spn_longueur.value 	= 	m_compo.longueur
										edt_nom.text 			=	m_compo.nom
									)

									on spn_longueur changed val do (
										m_compo.longueur = val		
										m_rollPrt.actualiser ()
									)
									on edt_nom	 entered txt 	do	(
										m_compo.nom = txt
										m_rollPrt.actualiser ()
									)
									
								)
			fn fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= (
									
									
							-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
									local ptr_plug				= 	_plug
									local ptr_composant  	= 	_composant
									local ptr_geo 				= 	ptr_plug.core.get_geo ()
									local matID					=	ptr_plug.core.get_matID ()
									
							-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
									local ep_dalle 			= ptr_plug.etages_epaiss_dalle
									local ht_niveaux 		= ptr_plug.etages_hauteur
									local longueur 			= ptr_composant.params.longueur
									
									
							-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
									--- Result -------------
									local pt_result_1, pt_result_2, pt_result_3
									
									--- Vecteurs ------------
									local vec_ep_dalle 	= [0,0,1] 		* 	ep_dalle
									local vec_ht 			= [0,0,1] 		* 	ht_niveaux
									local vec_longueur 	= _normDir 	* 	longueur
									
									--- Points d'accroche ------------
									local id_ptAccroche_1 	= pts_accroches[1]
									local id_ptAccroche_2 	= pts_accroches[2]
									local id_ptAccroche_3 	= pts_accroches[3]
									
									local ptAccroche_1		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	
									local ptAccroche_2		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	
									local ptAccroche_3		=	polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	
									
									
									
									---- LA DALLE  -----------------------------------------------------------------------			
									-------	Creation des points 	--------
									local pt_2 		= ptAccroche_1		+ 	vec_longueur
									local pt_3 		= pt_2					+	vec_ep_dalle
									
									--- creation des points --------------
									local pts_pos 	= #( pt_2, pt_3 )
									local pts_ids 	= ptr_geo.points 	pts_pos		
									
									-------	Creation des faces 	--------
									local nvlFace = ptr_geo.face 		#(	 id_ptAccroche_1, 		pts_ids[1], 		pts_ids[2], 		id_ptAccroche_2	)		 	
									polyop.setFaceMatID	 ptr_plug.delegate		nvlFace	  ( matID.mur + 1 )
									
									--- Result -------------
									pt_result_1 = pts_ids[1]
									pt_result_2 = pts_ids[2]
									
									
									
									---- LE MUR -----------------------------------------------------------------------			
									-------	Creation des points 	--------
									local pt_3 		= pt_3		+	vec_ht
									
									--- creation des points --------------
									local pts_pos 	= #( pt_3 )
									local pts_ids 	= ptr_geo.points 	pts_pos		
									
									-------	Creation des faces 	--------
									local nvlFace = ptr_geo.face 		#(	 		id_ptAccroche_2, 		pt_result_2, 		pts_ids[1], 		id_ptAccroche_3	)		 	
									polyop.setFaceMatID	 ptr_plug.delegate		nvlFace	  matID.mur
									
									--- Result -------------
									pt_result_3 = pts_ids[1]
									
									
									---- Result final -----------------------------------------------------------------------
									#( pt_result_1, pt_result_2, pt_result_3 )
									
								)
			
			local nvComposant = get_nouveauComposant 	()
			nvComposant.initialiser			#FAC_COMP_MUP		"Mur plein"
			nvComposant.set_dialog			dialog
			nvComposant.set_params	 	( params() )
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		), 
		---- Balcon -------------------------------------------
		fn balcon 		=(
			
			--- les parametres du composant --------------
			local params = struct param (
				longueur = 100,
				largeur	= 100
			)
			local dialog  = rollout dialog "Balcon" width:180 height:70	(
											local m_compo
											local m_rollPrt
											local m_param
										
											edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
											GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
											label 'lbl_largeur' "Largeur:" pos:[13,37] width:49 height:13 align:#left
											spinner 'spn_largeur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
											
											fn actualiser =(
												spn_largeur.value 	= 	m_param.largeur
												edt_nom.text 			=	m_compo.nom
											)

											on spn_largeur changed val do 
												m_param.largeur = val		
											
											on edt_nom	 entered txt 	do	(
												m_compo.nom = txt
												m_rollPrt.actualiser ()
											)
											
									)
			fn fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= (
				
				--- Result -------------
				local pt_result_1, pt_result_2, pt_result_3
				
				--- Vecteurs ------------
				local vec_ep_dalle 	= [0,0,1] 			* 	m_plug.etages_epaiss_dalle			
				local vec_longueur 	= _normDir 		* 	m_compo.longueur
				local norm_balcon	= _normDir * rotateZ ( matrix3 1 ) -90
				local vec_largeur		= norm_balcon 	*	 largeur				
				
				--- Points d'accroche ------------
				local id_ptAccroche_1 	= pts_accroches[1]
				local id_ptAccroche_2 	= pts_accroches[2]
				local id_ptAccroche_3 	= pts_accroches[3]
				
				local ptAccroche_1		=	polyop.getVert 	m_plug.delegate		id_ptAccroche_1	
				local ptAccroche_2		=	polyop.getVert 	m_plug.delegate		id_ptAccroche_2	
				local ptAccroche_3		=	polyop.getVert 	m_plug.delegate		id_ptAccroche_3	
				
				
				-------	Placement des points 	--------
				local pt_1 		= ptAccroche_1
				local pt_2 		= pt_1		+  vec_longueur
				local pt_3 		= pt_2		+ 	vec_ep_dalle				
				local pt_4		= pt_1		+ 	vec_ep_dalle
				
				local pt_5		= pt_1		+	vec_largeur
				local pt_6		= pt_2		+	vec_largeur		
				local pt_7		= pt_3		+	vec_largeur
				local pt_8		= pt_4		+	vec_largeur
				
				--- creation des points --------------
				local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
				local pts_ids 	= ptr_geo.points 	pts_pos		
				
				-------	Creation des faces 	--------
				local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[5], 		pts_ids[8], 		pts_ids[4] )		 			
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[7] , 	pts_ids[8] )		 				
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )					
				local nvlFace = ptr_geo.face 		#(	pts_ids[6], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[7] )		 		
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[6], 		pts_ids[5] )		 		
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )			
				local nvlFace = ptr_geo.face 		#(	pts_ids[8], 		pts_ids[7], 		pts_ids[3], 		pts_ids[4] )		 				
				polyop.setFaceMatID	 m_plug.delegate		nvlFace	   ( matID.mur + 1 )
				
				
				
				
				#()
			)
			
			--- Creation du composant --------------
			local nvComposant = get_nouveauComposant 	()
			nvComposant.initialiser			#FAC_COMP_BAL		"Balcon"
			nvComposant.set_dialog		dialog
			nvComposant.set_params	 	( params () )
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		),
		---- Balcon fin -------------------------------------------
		fn balconFin 	=(
			
			--- les parametres du composant --------------
			local params = struct param (
				longueur = 0
			)
			
			--- les parametres du composant --------------
			local dialog  = rollout dialog "Balcon fin" (
								)
			fn fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= ()
			
			--- Creation du composant --------------
			local nvComposant = get_nouveauComposant 	()
			nvComposant.initialiser			#FAC_COMP_BAF		"Balcon fin"
			nvComposant.set_dialog			dialog
			nvComposant.set_params	 	( params () )
			nvComposant.set_construire 	fnConstruire
			
			nvComposant
			
		),
		*/
		
		
		---- INTERFACE -------------------------------------------
	public
		fn creerMere  	_idModel	=(
			debug	"creerMere"
			local nvComposant = get_nouveauComposant ()
			m_modelesBase[_idModel].initialiser	nvComposant
			nvComposant
		),
		
		
		
		fn creer		_typeDeComposant		=(
			local nvComposant
			case	_typeDeComposant of (
				#espacement:		nvComposant =  creerMere 1	---		espacement()
				#murPlein:			nvComposant =  creerMere 2	---		murPlein()
				#balcon:				nvComposant = balcon()
				#balconFin:			nvComposant = balconFin()
			)
-- 			if ajouterAItems	do	append m_items	nvComposant
			nvComposant
		),
		fn charger		_id		  =(
			
			--- on cherche s'il existe deja comme parametre -----
			local index_composant= 0
			local i=1
			local trouve = false
			
			while i <= m_plug.fac_compos_ids.count and not trouve 	do (
				
				if ( execute m_plug.fac_compos_ids[i] ) as string == ( _id ) as string do (
					index_composant = i
				)
				i+= 1
			)
			
			
			local nvComposant
			--- on charge	------------------------------------
			if index_composant != 0 then (
				local type = m_plug.fac_compos_types[index_composant]
				
				case		( type as name )	of (
					#FAC_COMP_ESP:  	nvComposant 	= creer	#espacement
					#FAC_COMP_MUP:  	nvComposant 	= creer	#murPlein
				)
				
				nvComposant.charger		m_plug		
			)
			nvComposant
		),
		
		fn get_murPlein = creer  #murPlein,
		
		-----INIT	--------------
	public
		fn initialiser	_plug	=(
			debug "initialiser ()"
			m_plug = _plug
			
			
			--- on va chercher les fichiers des assets pour les composants de facades -------------
			m_modelesBase =#()
			local dossier_composants 		= 	getdir #userScripts + "\cp-Urba\assets\composants\\" 
			local liste_des_fichiersComposants	=	getfiles (dossier_composants+ "*.compo" )
			
			for fichierCompo in liste_des_fichiersComposants do (
				append m_modelesBase  ( fileIn fichierCompo ) 
			)
			debug "m_modelesBase" var:m_modelesBase 		param:"titre"
			
		)
		
		
) -- fin creer composant ---------
	


----------------- Manager des FACADES	------------------------------------------
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Elements - Facade.ms"

struct str_mgr_facades (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_arrayParametres",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
	
	---- MEMBRES ----------------------------------------------------------------------------------------------------------------
	public
		m_plug,
		m_mgr_composants,
		
	private
		
		---- Le tableau des éléments --------
		m_items	=	#(),
		
		
	---- FONCTIONS ----------------------------------------------------------------------------------------------------------------

	---- INTERFACE -------------------------------------------
	public
		fn actualiser = (
			
		),
		
		---- Accessions ---
		fn get_parID  		_idUnique	=(
			
			local result
			for item in m_items do
				if item.id == _idUnique do result = compo
			result
			
		),
		fn get_parIndex  	_index 		=(
			m_items[_index]			
		),
		
		fn get_noms 	=	for item in m_items collect item.nom,
		fn get_items	= 	m_items,
		
		---- Creation/Suppression ----
		fn creer		enregistrer:true		=(
			
			debug "creer"
			
			local nv_element = str_facade ()
			append		m_items	nv_element
			
			if enregistrer do
				nv_element.enregistrer	 	m_plug
			
			nv_element
			
		),	
		
		fn supprimer 	_idUnique	=	(
			local elem_a_supprimer = get_parID	_idUnique
			elem_a_supprimer.supprimer		m_plug
		),
		
		fn charger =(
			
			for id in m_plug.fac_ids do (
				debug "charger" var:id
				nvFacade = creer	enregistrer:false
				nvFacade.charger 	m_plug		id
				/* 
				-- on charge les composants ----
				for compoID in nvFacade.sequence do (
-- 					debug "charger" var:id
					nvComposant = mgr_composants.creer	enregistrer:false
					nvFacade.charger 	m_plug		id
				) */
			)
		),
		
		
		
		
		
		fn initialiser		class:  plug: =(
			
			
			--- on vide les items ------
			m_items	=	#()
			
			-- on assigne les pointeurs -----------
			if class== unsupplied or plug == unsupplied do
				messagebox "str_mgr_arrayParametres : Probleme d'initialisation"
			m_class 	= 	class
			m_plug		=	plug
			m_mgr_composants = plug.core.get_mgr_composants ()
			
			
		)
		
	
-- 		---- Parametres Block ----
-- 		fn lire			=	lire_parametres(),
-- 		fn ecrire			=	ecrire_parametres()
	
)	--	fin manager de composants ------


----------------- Manager des surfaces	------------------------------------------
----------- Tracé du batiment et autres manipulations du shape source ----------------
struct str_mgr_surfaces (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = false,
	m_dbgPrefix ="urba | str_surfaces",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	
	
	---- Pointeurs divers --------------------
	public
		m_plug,			---- le plugin: 'this' -----
		
	private
		
		m_outils					= str_shape_outils (),
		
		
	---- FONCTIONS ----------------------------------------------------------------
	private
		
	--- Aquisition shape ---------------------
		fn scanner_points 	_shape	=(
			
			local ptsSurface				=#()
			
			---- On chope les points de la surface a scanner -----------
			for id_pt = 1 to ( numKnots 	_shape 	1 ) do	(
				local pt_shape 	= getKnotPoint 	_shape 	1 	id_pt
				local pt_surface 	= pt_shape * inverse  _shape.transform
				append ptsSurface 	 pt_surface
			)
			
			
			--- on fait tourner les spline dans le meme sens ----
			if not m_outils.est_sensPositif 	ptsSurface 	 do
				trace_absolu = m_outils.changer_sens		ptsSurface
			
			ptsSurface
			
		),
		fn valider_shape 		_shape 	=(
			
			local id_premiertraceFerme 	= 0
			local b_result 						= true
			
			--- on ne prend que des splineShape -----
			if classOf _shape !=	line	 do(
				messagebox "Attention ! Le shape piqué doit être une Line."
				b_result = false
			) 
			
			--- on ne prend que la premiere spline fermée -----
			if b_result and numSplines _shape > 1 do (
				messagebox "Attention ! Le shape piqué doit posséder une seule spline."
				b_result = false
			) 
			
			--- si la spline n'est pas close  -----------
			if b_result and not 	isClosed  _shape 1 then (
				messagebox "Attention ! Le shape piqué doit être clos."
				b_result = false
			) 
			
			b_result
			
		),
		
		
		
	---- INTERFACE ----------------------------------------------------------------
	public
	--- Initialisation ---------------------
		fn initialiser _plug =(
			debug "initialiser"
			m_plug 				= _plug
		),
		
	--- Actualisation ---------------------
		fn actualiser  =(
			
		),
		
	--- Accession ---------------------
		fn get_points =(
			
			debug "actualiser"
			
			local pts_surface 
			
			if m_plug.surface_node != undefined do (
				
				--- on scanne les points ---- 
				pts_surface = 	scanner_points		m_plug.surface_node		
				
				--- on gere les OPTIMISATIONS  ----
				if m_plug.optim_souder			do	m_outils.souder				&pts_surface		m_plug.optim_souder_seuil
				if m_plug.optim_orthonormer	do	m_outils.orthonormer		&pts_surface		m_plug.optim_ortho_seuil
				if m_plug.optim_aplanir			do	m_outils.aplanir				&pts_surface		m_plug.optim_aplanir_seuil
				if m_plug.optim_aligner			do	m_outils.aligner				&pts_surface		m_plug.optim_aligner_seuil
				if m_plug.optim_projeter		do	m_outils.projeter			&pts_surface
				
			)
			
			pts_surface

		),	
		
	--- Assigner nouveau shape  ---------------------
		fn assigner 	_shape  =(
			
			debug "assigner"
			
			if _shape != undefined do (
				
				---- si pas valide on clean -------
				if not valider_shape 		_shape then 					
					m_plug.surface_node 				= undefined
					
				--- sinon on assigne les points de base ---- 
				else 	m_plug.surface_node				= 	_shape
				
				actualiser ()
				
			)
			
			debug "surface_node" 	var:m_plug.surface_node
			
		)
		
		/* ,
		
		fn subdiviser		 =(
			m_outils.subdiviser		 	( get_points() )
		) */
		
		
) -- fin struct Surface ------------------------




----------------- Manager des Toitures	------------------------------------------
struct 	str_mgr_toitures (
	items = #()
)

