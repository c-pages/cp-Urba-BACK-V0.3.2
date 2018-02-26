
	
	

	
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
		
		--- le dossier on sont rangés les constructeurs de composants ----------
		m_dossier_constructeurs 		= 	getdir #userScripts + "\\cp-Urba\\modules\\Batiment\\elements\\toitures\\" ,
		
		---- constructeurs source pour la construction des composants	---------------------
		m_constructeursBase 	=#(),
		
		
		--- le rollout	--------------------
		m_dialog					= 	filein	 "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - rollout toiture.ms",
		m_dialog_estOuvert 	= false,
		m_dialog_pos			= [700,200],
		m_dialog_taille			= [257,500],
		
		
	---- FONCTIONS ---------------------------------------------------------------------------------------------------------------------------------
	public
		
		
	---- constructeurs -----------------------
		fn get_constructeur_ID 		_type =(
			local result
			for i = 1 to m_constructeursBase.count  do (
				local constructeur = m_constructeursBase[i]
				if constructeur.type  as string   == _type   as string 
					do result = i
			)
			result
			
		),
		fn get_constructeurs		= (
			
			if m_constructeursBase.count == 0 do
				initialiser_constructeurs ()
			
			m_constructeursBase
		),
		
		
	---- parametres du plug -------------------------
		fn enregistrer_parametres 		_toiture	=(
-- 			debug"enregistrer_parametres"
			local mgr_datas = m_plug.core.get_mgrDatas ()
			m_plug.toiture_type  		=	_toiture.type as name
			m_plug.toiture_params  	=	(	mgr_datas.get_datas_string	_toiture.params	)
-- 			debug"enregistrer_parametres" var:m_plug.toiture_params 
		),
		fn charger_parametres 		_toiture		=(
			
			local mgr_datas 		= m_plug.core.get_mgrDatas ()
			local string_params	=	copy m_plug.toiture_params 
			
			_toiture.type				= m_plug.toiture_type
			mgr_datas.set_datas_string		string_params  		_toiture.params	
			
		),
		
		
	------ creation de la toiture ------
		fn creer_toiture		_idConstructeur	 =(
-- 			debug "creer_toiture"
			--- on importe le fichier du struct des composants  (pour avoir accés meme si le plug est pas actif)---
			include	 "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Toiture.ms"
			
			local nvl_toiture= str_toiture () 
			m_constructeursBase[ _idConstructeur ].initialiser	nvl_toiture
-- 			enregistrer_parametres 	nvl_toiture
			
			nvl_toiture
			
		),
		
		
	--- la toiture -------------------
		fn a_desParametres		=	m_plug.toiture_params != "" and m_plug.toiture_params != undefined,
		fn get_index_courant 	=(
			local result
			for i = 1 to m_constructeursBase.count  do (
				local constructeur = m_constructeursBase[i]
				if constructeur.type  == m_plug.toiture_type
					do result = i
			)
			result
		),
		
		fn get_toiture =(
			local 	idConstructeur = get_constructeur_ID 	m_plug.toiture_type
			local		toiture = creer_toiture	idConstructeur
			charger_parametres	toiture
			toiture
		),
		
		
	----- rollout --------------------------
		fn dialog_estOuvert				= m_dialog_estOuvert,
		fn ouvrir_dialog 	_toiture		=(
			
			createDialog 	m_dialog		style:				#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu) 	\
													pos:					m_dialog_pos		\
													width:				m_dialog_taille.x	\
													height:				m_dialog_taille.y	\
													lockWidth:			true
													
			m_dialog.initialiser 		m_plug
			
			m_dialog.set_toiture 		_toiture
			m_dialog_estOuvert 		= true
		),
		fn fermer_dialog 					=(
			destroyDialog 	m_dialog
			m_dialog_estOuvert = false
		),
		fn	set_dialog_taille	_taille 	=	m_dialog_taille 	= _taille,
		fn	set_dialog_pos		_pos 	=	m_dialog_pos 	= _pos,
		
		
		
		
		
		-----------------Initialisastions	---------------------------------------------------
		fn initialiser_constructeurs =(	
			--- on va chercher les fichiers des assets pour les composants de facades -------------
			m_constructeursBase =#()
			local fichiers_toiture	=	getfiles ( m_dossier_constructeurs+ "*.ms" )	
			for fichier_toiture in fichiers_toiture do (
				local nv_constructeur_toiture =  fileIn fichier_toiture
				append m_constructeursBase  	nv_constructeur_toiture
			)
		),
		fn initialiser	_plug	=(
			debug "initialiser ()"
			m_plug = _plug
			initialiser_constructeurs ()
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
		
		--- le dossier on sont rangés les constructeurs de composants --------------------------------------
		m_dossier_constructeurs 		= 	getdir #userScripts + "\cp-Urba\modules\Batiment\elements\composants de facade\\" ,
		
		---- structures servant de constructeur à la construction des composants	---------------------
		m_constructeursBase =#(),
		
		
		
	------------ INTERFACE  ------------------------------------------------------------------------------------------------------------------------
	private 
		fn get_nvl_element 	id:	=(
			--- on importe le fichier du struct des composants  (pour avoir accés meme si le plug est pas actif)---
			include	 "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Composant de facade.ms"
			
			nvl_element = str_composant 	() --	id:m_plug.fac_ids[_index]
			if id != unsupplied do 
				nvl_element.id = id
			nvl_element
		),
	public	
		---- Parametres ----------------	
		fn enregistrer_parametres		_composant		=(
			
			local mgr_datas = m_plug.core.get_mgrDatas ()
				
				--- on cherche s'il existe deja comme parametre -----
			local index_composant = 0
			for i = 1 to m_plug.fac_compos_ids.count do 
				if  m_plug.fac_compos_ids[i]  == _composant.id  do 
					index_composant = i
			
			--- s'il n'existe pas encore, on l'ajoute -----
			if index_composant == 0 then (
				
				append 	m_plug.fac_compos_ids 				_composant.id
				append 	m_plug.fac_compos_noms  			_composant.nom
				append 	m_plug.fac_compos_types  			_composant.type
				append 	m_plug.fac_compos_params  		(	mgr_datas.get_datas_string	_composant.params	)
				
			--- s'il existe, on l'actualise -----
			) else (
				
				m_plug.fac_compos_noms[index_composant] 		=	_composant.nom				
				m_plug.fac_compos_types[index_composant]			=	_composant.type		
				m_plug.fac_compos_params[index_composant]		=	(	mgr_datas.get_datas_string	_composant.params	)
				
			) 
		),
		fn charger_parametres 			_composant		=(
			
			local mgr_datas = m_plug.core.get_mgrDatas ()
			
			--- on cherche s'il existe deja comme parametre -----
			local index_composant = 0
			local i= 1
			local trouve = false
			while i <= m_plug.fac_compos_ids.count and not trouve	do (
				
				if  m_plug.fac_compos_ids[i]  == _composant.id  do (
					index_composant = i
					trouve = true
				)
				i+= 1
			)
			
			-- on charge	------------------------------------
			if index_composant != 0 then (
				
				_composant.nom 				= 	m_plug.fac_compos_noms[index_composant]
				_composant.type				=	m_plug.fac_compos_types[index_composant] as name
				
				mgr_datas.set_datas_string		m_plug.fac_compos_params[index_composant]			_composant.params
				
			)
		),
		
		
		
		----------------- constructeurs de base	------------------------------
		fn get_constructeurs 					= m_constructeursBase,
		fn get_constructeur_ID 				_typeAChercher		=(
			local result
			for i = 1 to m_constructeursBase.count  do (
				local constructeur = m_constructeursBase[i]
				if constructeur.type  as string == _typeAChercher as string
					do result = i
			)
			result
		),
		fn get_constructeur_par_type 	_typeAChercher		=(
			local result
			for constructeur in m_constructeursBase do
				if constructeur.type == _typeAChercher
					do result = constructeur
			result
		),
		
		
		
		---- creation d'un composant ------
		fn creer_composant 				_idconstructeur		=(
			
			-- si on a un type et non pas un index	de constructeur -------------
			if classof 	_idconstructeur == name or classof _idconstructeur == string	do
				_idconstructeur = get_constructeur_ID	_idconstructeur
			
			
			local nvComposant = get_nvl_element () 
			m_constructeursBase[_idconstructeur].initialiser		nvComposant
			
			nvComposant
		),
		fn dupliquer_composant			_composant 			=(
			debug "dupliquer"
			
			local idconstructeur	= 		get_constructeur_ID 		_composant.type
			local nvComposant	= 		creer_composant			idconstructeur
			
			nvComposant.nom 	= _composant.nom	--	 +  " - copie"
			local nomsParams 	= getPropNames nvComposant.params
			for nomParam in nomsParams do 
				setProperty  nvComposant.params		nomParam   (	getProperty  _composant.params		nomParam  	)
			
			enregistrer_parametres		nvComposant
			
			nvComposant
		),
		
		
		---- accession des composants -----------
		fn	get_composant_parIndex				_index =(
			local nv_composant 	= creer_composant  	m_plug.fac_compos_types[_index]
			nv_composant.id 		= m_plug.fac_compos_ids[_index]
			charger_parametres		nv_composant
			nv_composant
		),
		fn get_composant_parIDUnique  		_idUnique	=(
			local result
			local index_result = 0
			for i = 1 to m_plug.fac_compos_ids.count do 
				if m_plug.fac_compos_ids[i] == _idUnique do index_result = i
					
			if index_result != 0 do
				result = get_composant_parIndex 		index_result
			
			result
		),
		---- pour recuperer un 'mur plein' temporaire ------
		fn get_murPlein = creer_composant  ( get_constructeur_ID	#mur ),
		
		
		
		---- boutons ------
		fn get_bouton_ID 							_typeAChercher		=(
			local result
			local index_bouton = 0
			for i = 1 to m_constructeursBase.count  do (
				local constructeur = m_constructeursBase[i]
				if constructeur.est_editable  () do (
					index_bouton += 1
					if constructeur.type  as string == _typeAChercher as string
						do result = index_bouton
				)
			)
			result
		),
		
		
		----------------- Initialisastions	---------------------------------------------------
		fn initialiser_constructeurs =(
			
			--- on va chercher les fichiers des assets pour les composants de facades -------------
			m_constructeursBase =#()
			local liste_des_fichiersComposants	=	getfiles (m_dossier_constructeurs+ "*.ms" )			
			for fichierCompo in liste_des_fichiersComposants do (
				local nv_constructeur_compo =  fileIn fichierCompo
				append m_constructeursBase  	nv_constructeur_compo
			)
			
		),		
		fn initialiser	_plug	=(
			debug "initialiser ()"
			m_plug = _plug
			initialiser_constructeurs ()
			
		)
		
		
) -- fin manager de composants ---------







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
		
		--- le rollout	--------------------
		m_dialog					= 	filein	 "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - rollout facade.ms",
		m_dialog_estOuvert 	= false,
		m_dialog_pos			= [700,200],
		m_dialog_taille			= [500,500],
		
		
	---- FONCTIONS --------------------------------------------------------------------------------------------------------------
	private 
		fn get_nvl_element 	id:	=(
			----------------- Structure d'un élément	------------------------------------------
			include	 "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Facade.ms"
			
			nvl_element = str_facade 	() --	id:m_plug.fac_ids[_index]
			if id != unsupplied do 
				nvl_element.id = id
			nvl_element
		),
	public
		---- Parametres ----------------		
		fn enregistrer_parametres		_facade		=(
			
			debug "enregistrer_parametres"
			
			local mgr_datas 			= m_plug.core.get_mgrDatas ()
			
			--- on cherche s'il existe deja comme parametre -----
			local index_facade = 0
			for i = 1 to m_plug.fac_ids.count do
				if m_plug.fac_ids[i]  == _facade.id  do index_facade = i
			
			
			--- s'il n'existe pas encore, on l'ajoute -----
			if index_facade == 0 then (
				
				append 	m_plug.fac_ids 			_facade.id
				append 	m_plug.fac_noms  	_facade.nom
				append    	m_plug.fac_modes		_facade.mode
				
				--- Limiteurs - Murs	---
				append 	m_plug.fac_murs		_facade.murs
				
				--- Limiteurs - Etages	---
				append 	m_plug.fac_etagesMin_uses 		_facade.etages_min_use
				append 	m_plug.fac_etagesMin  				_facade.etages_min
				append 	m_plug.fac_etagesMax_uses 		_facade.etages_max_use
				append 	m_plug.fac_etagesMax 				_facade.etages_max
				
				--- Limiteurs - longueurs	---
				append 	m_plug.fac_longueurMin_uses 	_facade.longueur_min_use
				append 	m_plug.fac_longueurMin 			_facade.longueur_min
				append 	m_plug.fac_longueurMax_uses 	_facade.longueur_max_use
				append 	m_plug.fac_longueurMax 			_facade.longueur_max
				
				--- la sequence de composants	-------
				append 	m_plug.fac_sequences 					( mgr_datas.array_to_string		#() )
-- 				append 	m_plug.fac_sequence_longueurs 	_facade.sequence_longueur
				
			--- s'il existe, on l'actualise -----
			) else (
				
				m_plug.fac_noms[index_facade] 		=	_facade.nom				
				m_plug.fac_modes[index_facade]		=	_facade.mode
				
				--- Limiteurs - Murs	---
				m_plug.fac_murs[index_facade]			= _facade.murs
				
				--- Limiteurs - Etages	---
				m_plug.fac_etagesMin_uses[index_facade] 		= _facade.etages_min_use
				m_plug.fac_etagesMin[index_facade]  				=	_facade.etages_min
				m_plug.fac_etagesMax_uses[index_facade] 		= _facade.etages_max_use
				m_plug.fac_etagesMax[index_facade] 				=	_facade.etages_max
				
				--- Limiteurs - longueurs	---
				m_plug.fac_longueurMin_uses[index_facade] 		= 	_facade.longueur_min_use
				m_plug.fac_longueurMin[index_facade] 				=	_facade.longueur_min
				m_plug.fac_longueurMax_uses[index_facade] 	=	_facade.longueur_max_use
				m_plug.fac_longueurMax[index_facade] 				= _facade.longueur_max
				
				-- la sequence	-----
				local sequenceIDs 	= for compo in _facade.sequence collect	compo.id
				m_plug.fac_sequences[index_facade] 					= mgr_datas.array_to_string		sequenceIDs		
-- 				m_plug.fac_sequence_longueurs[index_facade] 		= _facade.sequence_longueur		
				
				--- les composants -----
				for compo in _facade.sequence do
					mgr_composants.enregistrer_parametres	 compo			
				
			)
		),
		fn charger_parametres 			_facade		  =(
			
			debug "charger_parametres"
			
			local mgr_datas 			= m_plug.core.get_mgrDatas ()
						
			--- on cherche s'il existe deja comme parametre -----
			local index_facade = 0
			for i = 1 to m_plug.fac_ids.count do 				
				if m_plug.fac_ids[i] == _facade.id do 
					index_facade = i
				
			
			--- on charge	------------------------------------
			if index_facade != 0 then (
				
				_facade.id 								= m_plug.fac_ids[index_facade]
				_facade.nom 								= m_plug.fac_noms[index_facade]
				
				_facade.mode							= m_plug.fac_modes[index_facade]
				
				--- Limiteurs - Murs	---
				_facade.murs								= m_plug.fac_murs[index_facade]
				
				--- Limiteurs - Etages	---
				_facade.etages_min_use			= m_plug.fac_etagesMin_uses[index_facade] 
				_facade.etages_min					= m_plug.fac_etagesMin[index_facade] 
				_facade.etages_max_use			= m_plug.fac_etagesMax_uses[index_facade] 
				_facade.etages_max					= m_plug.fac_etagesMax[index_facade] 
				
				--- Limiteurs - longueurs	---
				_facade.longueur_min_use			= m_plug.fac_longueurMin_uses[index_facade] 
				_facade.longueur_min				= m_plug.fac_longueurMin[index_facade] 
				_facade.longueur_max_use		= m_plug.fac_longueurMax_uses[index_facade] 
				_facade.longueur_max				= m_plug.fac_longueurMax[index_facade] 
				
				--- Sequence	---
-- 				_facade.sequence_longueur		=	m_plug.fac_sequence_longueurs[index_facade]
				
				_facade.sequence						=  #()
				local sequence_IDs					= mgr_datas.string_to_array		 m_plug.fac_sequences[index_facade]
				
				for compoID in sequence_IDs do (
					
					local compoInstance = mgr_composants.get_composant_parIDUnique		compoID  
					
					if compoInstance != undefined then 
						nvComposant = 	compoInstance
					else	nvComposant = 	mgr_composants.charger_parametres 	compoID	
					
					append _facade.sequence	nvComposant
					
				) 
				
			) else messagebox ("Erreur de chargement de facade : " + _id as string )
			
		),
		
		
		---- Accessions ----------------
		--- manager ---
		fn get_mgr_composants = mgr_composants,
		
		
		--- facade ----
		fn	get_facade_parIndex				_index =(
			
			local nvl_facade = get_nvl_element 	id:m_plug.fac_ids[_index]
			charger_parametres		nvl_facade
			nvl_facade
		),
		fn get_facade_parIDUnique  		_idUnique	=(
			local result
			local index_result = 0
			for i = 1 to m_plug.fac_ids.count do (
				if m_plug.fac_ids[i] == _idUnique do index_result = i
			)
			result = get_facade_parIndex 	index_result
		),
		fn get_facades =(
			local facades = #()
			for idUnique in m_plug.fac_ids do
				append facades	( get_facade_parIDUnique 	idUnique)
			facades
		),
		
		
		
		---- Creation/Suppression etc. ----
		fn creer_facade	=(
			
			local nvl_facade = get_nvl_element ()
			
			nvl_facade.nom += " " + m_plug.fac_ids.count as string
			enregistrer_parametres		nvl_facade
			
			nvl_facade
			
		),
		fn supprimer_facade 		_index	=	(		
			
				deleteItem 	m_plug.fac_ids 							_index
				deleteItem 	m_plug.fac_noms  						_index
				deleteItem    m_plug.fac_modes						_index
				
				--- Limiteurs - Murs	---
				deleteItem 	m_plug.fac_murs							_index
				
				--- Limiteurs - Etages	---
				deleteItem 	m_plug.fac_etagesMin_uses 			 _index
				deleteItem 	m_plug.fac_etagesMin  				_index
				deleteItem 	m_plug.fac_etagesMax_uses 		 _index
				deleteItem 	m_plug.fac_etagesMax 					_index
				
				--- Limiteurs - longueurs	---
				deleteItem 	m_plug.fac_longueurMin_uses 	 	_index
				deleteItem 	m_plug.fac_longueurMin 				_index
				deleteItem 	m_plug.fac_longueurMax_uses 		_index
				deleteItem 	m_plug.fac_longueurMax 			 	_index
				
				--- la sequence de composants	-------
				deleteItem 	m_plug.fac_sequences 					_index
-- 				deleteItem 	m_plug.fac_sequence_longueurs 	_index
			
		),
		fn dupliquer_facade 		_facadeADupliquer	=(
			
			local nvlFacade 	= creer_facade		enregistrer:false
			nvlFacade.nom   	= _facadeADupliquer.nom + " - copie"
			nvlFacade.mode		= _facadeADupliquer.mode
			
			nvlFacade.murs		= _facadeADupliquer.murs
			
			nvlFacade.etages_min_use		= _facadeADupliquer.etages_min_use
			nvlFacade.etages_min			= _facadeADupliquer.etages_min
			nvlFacade.etages_max_use	= _facadeADupliquer.etages_max_use
			nvlFacade.etages_max			= _facadeADupliquer.etages_max
			
			nvlFacade.longueur_min_use	= _facadeADupliquer.longueur_min_use
			nvlFacade.longueur_min			= _facadeADupliquer.longueur_min
			nvlFacade.longueur_max_use	= _facadeADupliquer.longueur_max_use
			nvlFacade.longueur_max		= _facadeADupliquer.longueur_max
			
-- 			nvlFacade.sequence_longueur		= _facadeADupliquer.sequence_longueur
			for compoADupliquer in _facadeADupliquer.sequence do (
				local nvCompo	=	mgr_composants.dupliquer_composant		compoADupliquer
-- 				nvCompo.nom +=  " - copie"
				append 	nvlFacade.sequence	nvCompo
			)
			
			
			
			enregistrer_parametres		nvlFacade
			
			nvlFacade
		),
		
		
		
		
		----- rollout --------------------------
		fn dialog_estOuvert				= m_dialog_estOuvert,
		fn ouvrir_dialog 	_index		=(
			
			createDialog 	m_dialog		style:				#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu) 	\
													pos:					m_dialog_pos		\
													width:				m_dialog_taille.x	\
													height:				m_dialog_taille.y	
													
			m_dialog.initialiser 		m_plug
			local facadeAOuvrir 		= 	get_facade_parIndex		_index
			m_dialog.set_facade 		facadeAOuvrir
			m_dialog_estOuvert 		= true
		),
		fn fermer_dialog 					=(
				destroyDialog 	m_dialog
				m_dialog_estOuvert = false
		),
		fn	set_dialog_taille	_taille 	=	m_dialog_taille 	= _taille,
		fn	set_dialog_pos		_pos 	=	m_dialog_pos 	= _pos,
		
		
		
		---- Initialisation  ----
		fn initialiser		_plug =(
			
			-- on assigne les pointeurs -----------
			m_plug		=	_plug
			
			-- on initialiser le manager des composants
			mgr_composants.initialiser		m_plug
			
		)
		
		
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
		
		
		
) -- fin struct Surface ------------------------




















