
	
	

	
----------------- Manager de laTOITURE	------------------------------------------
struct 	str_mgr_toiture (
	
	private
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_toitures",
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix	catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	---- Membres ---------------------------------------------------------------------------------------------------------------------------------
		m_plug ,				----	le plugin	----
		m_toiture,				----	la toiture active	----
	
		--- le dossier on sont rangés les modeles de composants ----------
		m_dossier_models 		= 	getdir #userScripts + "\\cp-Urba\\modules\\Batiment\\elements\\toitures\\" ,
	
		---- Modeles source pour la construction des composants	---------------------
		m_modelesBase 	=#(),
		
		
	---- FONCTIONS ---------------------------------------------------------------------------------------------------------------------------------
	private
		fn importer_models =(
			
			--- on va chercher les fichiers des assets pour les composants de facades -------------
			m_modelesBase =#()
			local fichiers_toiture	=	getfiles (m_dossier_models+ "*.ms" )	
			for fichier_toiture in fichiers_toiture do (
				local nv_model_toiture =  fileIn fichier_toiture
				append m_modelesBase  	nv_model_toiture
			)
			
		),
	---- INTERFACE ---------------------------------------------------------------------------------------------------------------------------------
	public
		
			
		
	---- accessions ------
		fn a_desParametres	=	m_toiture.a_desParametres (),
		fn get_index_courant =(
			local result
			for i = 1 to m_modelesBase.count  do (
				local model = m_modelesBase[i]
				if model.type  as string == m_toiture.type as string
					do result = i
			)
			result
		),
		fn get_index_parType 	_type =(
			local result
			for i = 1 to m_modelesBase.count  do (
				local model = m_modelesBase[i]
				if model.type  as string == _type as string
					do result = i
			)
			result
			
		),
		fn get_modeles = (
			
			if m_modelesBase.count == 0 do
				importer_models ()
			
			m_modelesBase
		),
		fn get_courant =(
			m_toiture
		),
		
		
		
	------ creation de la toiture ------
		fn assigner	_id =(
			
			--- on importe le fichier du struct des composants  (pour avoir accés meme si le plug est pas actif)---
			include	 "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Toiture.ms"
			debug "assigner"
			debug "m_modelesBase"	var:m_modelesBase
			
			m_toiture= str_toiture () ---	get_nouveauComposant ()
			m_modelesBase[_id ].initialiser	m_toiture
			
			this.enregistrer ()
			
			m_toiture
			
		),
		
		
		
	---- parametres du plug -------------------------
		fn enregistrer =(
			local mgr_datas = m_plug.core.get_mgrDatas ()
			m_plug.toiture_type  		=	m_toiture.type as name 
			m_plug.toiture_params  	=	(	mgr_datas.get_datas_string	m_toiture.params	)
		),
		fn charger =(
			local mgr_datas = m_plug.core.get_mgrDatas ()
			
			local typeACharger 	= m_plug.toiture_type
			local indexModel 		= get_index_parType    typeACharger
			assigner	indexModel
			
			mgr_datas.set_datas_string		m_plug.toiture_params  	m_toiture.params		
			
		),
	
		
		
		
	---- Initialisations ------
		fn initialiser	_plug	=(
			debug "initialiser ()"
			m_plug = _plug
			importer_models ()
		)
		
		
		
		
) -- fin creer composant ---------






----------------- Manager des COMPOSANTS	-------------------------------------------------------------------------------------------------------------------------
struct 	str_mgr_composantsDeFacade (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_composants",
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix	catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	
	------------ MEMBRES ------------------------------------------------------------------------------------------------------------------------
	private
		m_plug,
		
		--- le dossier on sont rangés les modeles de composants ----------
		m_dossier_models 		= 	getdir #userScripts + "\cp-Urba\modules\Batiment\elements\composants de facade\\" ,
		
		---- structures servant de model à la construction des composants	---------------------
		m_modelesBase =#(),
		
		---- Le tableau des éléments --------
		m_items	=	#(),
		
		
	------------ INTERFACE  ------------------------------------------------------------------------------------------------------------------------
	public
		---- creation d'un composant ------
		fn creer 	_idModel		=(
			--- on importe le fichier du struct des composants  (pour avoir accés meme si le plug est pas actif)---
			include	 "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Composant de facade.ms"
			
			local nvComposant = str_composant () ---	get_nouveauComposant ()
			m_modelesBase[_idModel].initialiser	nvComposant
			
			nvComposant
		),
		
		----------------- Models de base	------------------------------
		---- recupere l'index du modele de composant  ------
		fn get_model_ID 				_typeAChercher	=(
			local result
			for i = 1 to m_modelesBase.count  do (
				local model = m_modelesBase[i]
				if model.type  as string == _typeAChercher as string
					do result = i
			)
			result
		),
		fn get_model_par_type 		_typeAChercher	=(
			local result
			for model in m_modelesBase do
				if model.type == _typeAChercher
					do result = model
			result
		),
		fn get_modeles 				= m_modelesBase,
		
		----------------- Divers------------------------------	
		---- pour recuperer un 'mur plein' temporaire ------
		fn get_murPlein = creer  ( get_model_ID	#murPlein ),
		
		--- charge en mémoire les parametres des composant des facades depuis le plugin --------
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
		
		-----------------Initialisastion	---------------------------------------------------
		fn initialiser	_plug	=(
			debug "initialiser ()"
			m_plug = _plug
			
			--- on va chercher les fichiers des assets pour les composants de facades -------------
			m_modelesBase =#()
			local liste_des_fichiersComposants	=	getfiles (m_dossier_models+ "*.ms" )			
			for fichierCompo in liste_des_fichiersComposants do (
				local nv_model_compo =  fileIn fichierCompo
				append m_modelesBase  	nv_model_compo
			)
			
		)
		
		
) -- fin manager de composants ---------






----------------- Structure d'un élément	------------------------------------------
include	 "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Facade.ms"

----------------- Manager des FACADES	------------------------------------------
struct str_mgr_facades (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_facades",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
	
	---- MEMBRES ----------------------------------------------------------------------------------------------------------------
	private
		m_plug,
		
		--- le manager des composants -------------
		mgr_composants 	= str_mgr_composantsDeFacade (),
		
		
		---- Le tableau des éléments --------
		m_items	=	#(),
		
		
	---- FONCTIONS ----------------------------------------------------------------------------------------------------------------

	---- INTERFACE -------------------------------------------
	public
		fn actualiser = (
			
		),
		
		---- Accessions ----------------
		
		fn get_mgr_composants 	= mgr_composants,
			
		fn get_parID  		_idUnique	=(
			
				debug "get_parID"	
				format  "_idUnique : %\n"		_idUnique
			local result
			for item in m_items do (
				if item.id as string == _idUnique  as string do result = item
				format  "item.id : %\n"		item.id
-- 				debug "item.id"		var:item.id
			)
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
			if cible == unsupplied	then
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
					array:		setProperty nvlFacade 	propNom 	( for val in propOriginal collect val )
					default:		setProperty nvlFacade 	propNom 	propOriginal
				)
			)
			nvlFacade
		),
		fn supprimer 	_idUnique	=	(
			local elem_a_supprimer = get_parID		_idUnique
			local indexASupprimer = elem_a_supprimer.supprimer		m_plug
			deleteItem	m_items	indexASupprimer
		),
		
		fn charger =(
			m_items = #()
			for id in m_plug.fac_ids do (
				debug "charger" var:id
				nvFacade = creer	enregistrer:false
				nvFacade.id  = id
				nvFacade.charger 	m_plug		
				append	m_items	nvFacade
			)
		),
		
		
		
		
		
		fn initialiser		class:  plug: =(
			
			
			--- on vide les m_items ------
			m_items	=	#()
			
			-- on assigne les pointeurs -----------
			if class== unsupplied or plug == unsupplied do
				messagebox "str_mgr_arrayParametres : Probleme d'initialisation"
			m_class 	= 	class
			m_plug		=	plug
			
			-- on initialiser le manager des composants
			mgr_composants.initialiser		m_plug
			
			
		)
		
	
-- 		---- Parametres Block ----
-- 		fn lire			=	lire_parametres(),
-- 		fn ecrire			=	ecrire_parametres()
	
)	--	fin manager de facades ------






----------------- Manager de la surface		------------------------------------------
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
		fn get_axePrincipal 	= m_outils.get_axePrincipal_mtrx 		( get_points () ),
		fn get_axeP_BB			= m_outils.get_axePrincipal_BB 		( get_points () )  ( get_axePrincipal () ),
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





