

/* -----------------------------
initialiser les membre suivant  :
	*	m_plug							<----------- le plugin portant les parametres
	*	m_fichier_classeBase			<----------- la class de base à gérer
	*	m_dossier_constructeurs		<----------- le dossier contenant les constructeurs
	*	m_dialog							<----------- le rollout pour manipuler les données de 'm_classe_base'
	*	m_prefix_nomParametres		<----------- le prefix des noms de parametres
*/ -----------------------------


struct  str_manager_parametres (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:"urba | str_manager_parametres_univ"	catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	
	
	---- MEMBRES ----------------------------------------------------------------------------------------------------------------
	private
		m_plug,
		
		---- la classe de base à gérer	--------------
		m_fichier_classeBase = "",
		m_classeBase,
		
		---- le prefixe utilisé pour les noms des parametres de l'objet --------
		m_prefix_nomParametres ="",
		
		---- le dossier on sont rangés les constructeurs de composants ----------
		m_dossier_constructeurs ,	----		= 	getdir #userScripts + "\\cp-Urba\\modules\\Batiment\\elements\\toitures\\" ,
		
		----- constructeurs source pour la construction des composants	---------------------
		m_constructeursBase 	=#(),
		
		---- le rollout	--------------------
		m_dialog,					----			= 	filein	 "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - rollout facade.ms",
		m_dialog_estOuvert 	= false,
		m_dialog_pos			= [700,200],
		m_dialog_taille			= [500,500],
		
		--- pour transformer tableaux et struct en texte pour les enregistrer et inversement our les lire ----------
		mgr_datas ,			
		
		
		
		
		
		
		---- FONCTIONS --------------------------------------------------------------------------------------------------------------
		
		---- Constructeur	---------------------------------------------------
	private
		fn a_constructeurs = (
			
-- 			debug "a_constructeurs" 
			local result = m_dossier_constructeurs != undefined 
-- 			debug "a_constructeurs"  var:result
			result
		),
		fn initialiser_constructeurs =(
			debug "initialiser_constructeurs"
			if a_constructeurs () do (
				--- on va chercher les fichiers des assets pour les composants de facades -------------
				m_constructeursBase =#()
				local fichiers_toiture	=	getfiles ( m_dossier_constructeurs+ "*.ms" )	
				for fichier_toiture in fichiers_toiture do (
					local nv_constructeur_toiture =  fileIn fichier_toiture
					append m_constructeursBase  	nv_constructeur_toiture
				)
			)
		),
		fn get_constructeur_ID 		_type =(
			debug "get_constructeur_ID"
			debug "_type" var:_type
			local result = 0
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
		
		
		
		
		
		---- Parametres ---------------------------------------------------
	private
		--- pour recuperer lindex dans les tableaux de parametre, correspondant a l'element a cet IDUnique	--------
		fn get_param_index_parIDUnique		_idUnique =(
			local index 			= 0
			local param_id 		= m_prefix_nomParametres + "_id" 
			local param_arrayId_TEMP 	= getProperty	m_plug	  param_id				
			for i = 1 to param_arrayId_TEMP.count do
				if param_arrayId_TEMP[i] == _idUnique do
					index = i
			index
		),
		
		
	public
		fn enregistrer_parametres		_element		=(
			debug "enregistrer_parametres () "
			
			local prop_element_Noms = getPropNames	_element
			
			--- si param deja present, on actualise -------------------
			for prop_element_Nom in prop_element_Noms do (
				
				local prop_element 			= getProperty _element  prop_element_Nom
				local param_nom 				= m_prefix_nomParametres + "_" + prop_element_Nom
				
				---- si on a les #PARAMS ---------------
				if prop_element_Nom == #params do
					prop_element = mgr_datas.get_datas_string		prop_element
				
				----  en fonction de la classe du param ---------------
				case classOf prop_element of (
					MAXScriptFunction:() 
					Array: 		(
						
						local param 				= getProperty	m_plug	  param_nom	
						
						--- si on a  un tableau ------------
						if classof param == arrayParameter then (						
							local param_index = get_param_index_parIDUnique 	_element.id
							if  param_index  	!= 0 then 
								param[ param_index ] =		mgr_datas.array_to_string	prop_element
							else
								append 	param		( mgr_datas.array_to_string	prop_element )
							
						--- sinon on a un parametre simple ----------------
						) else 	setProperty	m_plug	  param_nom		( mgr_datas.array_to_string	prop_element )
					
					)
					default: 	(
						
						local param 				= getProperty	m_plug	  param_nom	
						
						--- si on a  un tableau ------------
						if classof param == arrayParameter then (		
							local param_index = get_param_index_parIDUnique 	_element.id
							if  param_index  	!= 0 then 
								param[ param_index ] =		prop_element
							else
								append 	param		( prop_element )
							
						--- sinon on a un parametre simple ----------------
						) else 	setProperty	m_plug	  param_nom		( prop_element )
						
					)
				) -- fin case
			)-- fin for
		),
		fn charger_parametres 			_element		=(
			
			local prop_element_Noms = getPropNames	_element
			
			--- si param deja present, on actualise -------------------
			for prop_element_Nom in prop_element_Noms do (
				
				local prop_element 	= getProperty 	_element  	prop_element_Nom
				
				-- si c'est pas une fonction --------------
				if classof prop_element != MAXScriptFunction do (
					
					local param_nom 		= m_prefix_nomParametres + "_" + prop_element_Nom					
					local param_value		= getProperty	m_plug		param_nom
					
					-- si c'est un tableau de parametres ( donc s'il exite une liste d'IDs )-------------
					if hasproperty	m_plug	  ( m_prefix_nomParametres + "_id" ) do (
						local param_index = get_param_index_parIDUnique 		_element.id
						param_value		=	param_value[ param_index ]
					)
					
					case classOf prop_element of (
						MAXScriptFunction:()
						Array: 		setProperty	_element	  prop_element_Nom		( mgr_datas.string_to_array	param_value )
						default: 	(
							--- si on a les parametres #PARAMS d'un composant  -----
							if prop_element_Nom == #params then 									
								mgr_datas.set_datas_string		param_value		_element.params
							--- sinon on a un parametres classique -----
							else 	setProperty	_element	  prop_element_Nom		param_value		
						)
						
					) -- fin case  classOf prop_element 
				) -- fin if MAXScriptFunction --------
			) -- fin for prop_element	--------
		),
		
		
		
		
		
		
		
		
		---- Creation/Suppression etc. ---------------------------------------------------
		fn creer_element		idUnique:		idConstructeur:		=(
			debug "creer_composant"
			
			----------------- Structure d'un élément	------------------------------------------
			m_classeBase	=	fileIn	 m_fichier_classeBase
			
			nvl_element 		= m_classeBase 	()
			
			----- facon constructeur --------
			if idConstructeur != unsupplied do (
				-- si on a un type et non pas un index	de constructeur -------------
				if classof 	idConstructeur == name or classof idConstructeur == string	do
					idConstructeur = get_constructeur_ID		idConstructeur			
				if idConstructeur != 0 do
					m_constructeursBase[ idConstructeur ].initialiser		nvl_element
			)
			
			--- id Unique -----------
			if idUnique != unsupplied do 
				nvl_element.id = idUnique
			
			nvl_element
			
		),
		
		
		
		
		---- Accessions	-------------------
		fn	get_element_parIndex				_index =(
			debug "get_element_parIndex"
			
			local element
			local params_ids 	= getProperty	m_plug	  ( m_prefix_nomParametres + "_id" )
			local param_id		= params_ids[ _index ]
			if _index <= params_ids.count do (
				if a_constructeurs () then (
					local params_ids 			= getProperty	m_plug		( m_prefix_nomParametres + "_id" )
					local params_types		= getproperty	m_plug		( m_prefix_nomParametres + "_type" )
					element 		= creer_element	idUnique:param_id		idConstructeur:params_types[ _index ]
				) else element 	= creer_element	idUnique:param_id
				
				charger_parametres		element
			)
			element
		),
		fn get_element_parIDUnique  		_idUnique	=(
			debug "get_element_parIDUnique"
			local result
			local index_result = 0
			local params_ids 			= getProperty	m_plug	  ( m_prefix_nomParametres + "_id" )
			for i = 1 to params_ids.count do (
				if params_ids[i] == _idUnique do index_result = i
			)
			result = get_element_parIndex 	index_result
		),
		fn get_elements =(
			debug "get_elements"
			local result
			
			-- si c'est un tableau de parametres ( donc s'il exite une liste d'IDs )-------------
			if hasproperty	m_plug	  ( m_prefix_nomParametres + "_id" ) then (
				
				local elements 				= #()
			
				local params_ids 			= getProperty	m_plug	  ( m_prefix_nomParametres + "_id" )
				local i = 1
				for  i = 1 to params_ids.count do (
					local param_id	= params_ids[ i ]
					
					--- on construit l'element, avec ou sans constructeur	--------------
					local element 	
					if a_constructeurs () then (
						local params_types_nom 	= m_prefix_nomParametres + "_type"
						local params_types			= getproperty	m_plug		params_types_nom
						element = creer_element	idUnique:param_id		idConstructeur:params_types[ i ]
					) else element = creer_element	idUnique:param_id
					
					--- on charge les parametres	--------------
					charger_parametres 	element
					
					append elements 	element
					
				)
				
				result = elements
				
			
			-- si c'est des parametres simples	 -------------
			) else (
				
				local element 		
				
				if a_constructeurs () then (
					local param_type_nom 	= m_prefix_nomParametres + "_type"
					local param_type			= getproperty	m_plug		param_type_nom
					element = creer_element			idConstructeur:param_type
				) else element = creer_element	()
				
				charger_parametres	element
				
				result = element
				
			)
			
			
			result
		),
		
		
		
	----- rollout --------------------------
		fn dialog_estOuvert		= m_dialog_estOuvert,
		fn ouvrir_dialog 			=(
			if m_dialog != undefined do (
				createDialog 	m_dialog		style:				#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu) 	\
														pos:					m_dialog_pos		\
														width:				m_dialog_taille.x	\
														height:				m_dialog_taille.y	\
														lockWidth:			true
				
				m_dialog.initialiser 		m_plug		
				m_dialog_estOuvert 		= true
			)
		),
		fn fermer_dialog 			=(
			if m_dialog != unsupplied do (
				destroyDialog 	m_dialog
				m_dialog_estOuvert = false
			)
		),
		fn	set_dialog_taille	_taille 	=	m_dialog_taille 	= _taille,
		fn	set_dialog_pos		_pos 	=	m_dialog_pos 	= _pos,
		
		
		
		
		
		
		----------------- Initialiser	---------------------------------------------------
		fn initialiser	plug:							\
							fichier_classeBase:			\
							dossier_constructeurs:	\
							fichier_dialog:				\
							prefix_nomParametres:	=(
			
			debug "initialiser ()"
			
			m_plug 							=	plug
			m_fichier_classeBase 		= 	fichier_classeBase
			if dossier_constructeurs != unsupplied do 
				m_dossier_constructeurs 	= 	dossier_constructeurs
			if fichier_dialog != unsupplied do 
				m_dialog 						= 	( fileIn 	( "$userScripts\cp-Urba\modules\Batiment\\rollouts\\" + fichier_dialog ) )
			m_prefix_nomParametres 	= 	prefix_nomParametres
			
			mgr_datas 						= m_plug.core.get_mgrDatas ()
			
			
			--- les constructeurs -----------
			if a_constructeurs () do
				initialiser_constructeurs ()
			
		)
		
		
	
)









