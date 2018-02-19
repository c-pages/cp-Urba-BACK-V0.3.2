
	
	

	

----------------- Manager des COMPOSANTS	------------------------------------------
struct 	str_mgr_composants (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_composants",
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix	catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
		m_plug,
-- 	private
		public
		m_modelesBase =#(),
		
		---- Le tableau des éléments --------
		m_items	=	#(),

		
		
		---- INTERFACE -------------------------------------------
	public
		fn creer 	_idModel	/* enregistrer:true  */=(
			--- on importe le fichier du struct des composants  (pour avoir accés meme si le plug est pas actif)---
			include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Elements - Composant.ms"
			
			local nvComposant = str_composant () ---	get_nouveauComposant ()
			m_modelesBase[_idModel].initialiser	nvComposant
			
-- 			if enregistrer do
-- 				nvComposant.enregistrer	 	m_plug
			
			nvComposant
		),
		
		
		
		fn get_model_ID 	_typeAChercher	=(
			local result
			for i = 1 to m_modelesBase.count  do (
				local model = m_modelesBase[i]
				if model.type  as string == _typeAChercher as string
					do result = i
			)
			result
		),
		fn get_model_par_type 	_typeAChercher	=(
			local result
			for model in m_modelesBase do
				if model.type == _typeAChercher
					do result = model
			result
		),
		
		fn get_murPlein = creer  ( get_model_ID	#murPlein )  /* enregistrer:false	 */,
		
		
		fn get_modeles = m_modelesBase,
		
		
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
				local id_model = get_model_ID  type
				nvComposant 	= creer	id_model enregistre:false
				
				nvComposant.charger		m_plug		
			)
			nvComposant
		),
		-----INIT	--------------
	public
		fn initialiser	_plug	=(
			debug "initialiser ()"
			m_plug = _plug
			
			
			--- on va chercher les fichiers des assets pour les composants de facades -------------
			m_modelesBase =#()
			local dossier_composants 		= 	getdir #userScripts + "\cp-Urba\datas\composants\\" 
			local liste_des_fichiersComposants	=	getfiles (dossier_composants+ "*.ms" )
			
			for fichierCompo in liste_des_fichiersComposants do (
				local nv_model_compo =  fileIn fichierCompo
				append m_modelesBase  	nv_model_compo
			)
			
		)
		
		
) -- fin creer composant ---------
	


----------------- Manager des FACADES	------------------------------------------
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Elements - Facade.ms"

struct str_mgr_facades (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_facades",
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
			
			
			if enregistrer do (
				append		m_items	nv_element
				nv_element.enregistrer	 	m_plug
			)
			
			nv_element
			
		),	
		
		fn dupliquer		_facade 	cible:	=(
			local nvlFacade 
			if cible == unsupplied then
				nvlFacade = creer		enregistrer:false
			else
				nvlFacade = cible
			
			local propNoms = getPropNames _facade
			for propNom in propNoms do (
				local propOriginal = ( getProperty  _facade 	propNom )
				local type = classof propOriginal
				case type of (
					--- les trucs qu'on zappe ------
					MAXScriptFunction:	()
					array:		setProperty nvlFacade 	propNom 	(for val in propOriginal collect val )
					default:		setProperty nvlFacade 	propNom 	propOriginal
				)
			)
			nvlFacade
		),
		fn supprimer 	_idUnique	=	(
			local elem_a_supprimer = get_parID	_idUnique
			elem_a_supprimer.supprimer		m_plug
		),
		
		fn charger =(
			m_items = #()
			for id in m_plug.fac_ids do (
				debug "charger" var:id
				nvFacade = creer	enregistrer:false
				nvFacade.charger 	m_plug		id
				append	m_items	nvFacade
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

