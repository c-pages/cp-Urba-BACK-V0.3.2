

/* -----------------------------
initialiser les membre suivant  :
	*	m_plug							<----------- le plugin portant les parametres
	*	m_fichier_classeBase			<----------- la class de base � g�rer
	*	m_dossier_constructeurs		<----------- le dossier contenant les constructeurs
	*	m_dialog							<----------- le rollout pour manipuler les donn�es de 'm_classe_base'
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
		m_core,
		
		---- la classe de base � g�rer	--------------
		m_fichier_classeBase = "",
		m_classeBase,
		
		---- le prefixe utilis� pour les noms des parametres de l'objet --------
		m_prefix_nomParametres ="",
		
		---- le dossier on sont rang�s les constructeurs de composants ----------
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
			local result = m_dossier_constructeurs != undefined 
			result
		),
		fn initialiser_constructeurs =(
			
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
	public
		fn get_constructeurs		= (
			
			if m_constructeursBase.count == 0 do
				initialiser_constructeurs ()
			
			m_constructeursBase
		),
		fn get_constructeur_index 		_typeAChercher 	visibles:false	=(
			
			local result = 0
			local index_bouton = 0			
			
			for i = 1 to m_constructeursBase.count  do (
				local constructeur = m_constructeursBase[i]
				if constructeur.est_editable  () do 
					index_bouton += 1
				
				if constructeur.type  as string == _typeAChercher as string do
					if visibles 	then		result = index_bouton
									else		result = i
				
			)
			result
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
		fn get_element_index 	_element	=(
			local param_index 
			if hasProperty	_element	"id" do
				param_index = get_param_index_parIDUnique 	_element.id
			param_index
		),
		
		--- enrgistrer un parametre simple ---------
		fn enregistrer_parametre 	_param_nom		_value		index:	=(
			
			local param 				= getProperty	m_plug	  _param_nom
			
			if index != undefined and index!=unsupplied then (
				
				if  index  	!= 0 then 
					param[ index ] =		_value
				else
					append 	param		_value
			
			--- sinon on a un parametre simple ----------------
			) else 	setProperty	m_plug	  _param_nom		_value
		
		),
		
		--- gestion #PARAMS --------
		fn enregistrer_paramsElem 	_params	=(			
			
			local params_TMP = copy 	_params
			
			for prop_params_Nom in  ( getPropNames	_params ) do (
				
				local prop_value	= getProperty _params  prop_params_Nom
				case classOf prop_value of (
					Array:(
							local tab_value =#()
						
							if prop_value.count > 0 then (
								
								-- on a une structure � nous --------
								if superclassOf prop_value[1] == StructDef then (
									
									for _struct in  prop_value do (
										-- on enregistre l'element sur le plug ------------
										m_core.enregistrer_element 	_struct
										
										-- on ajoute l'id au tableau du params a enrgistrer -------
										append tab_value 	_struct.id
									)
									--- on enregistre les parametres de la structure 
									
									prop_value = tab_value
								) 
							) 
							
						)
					default:(		)
				)	---- fin case	---------
				
				
				setProperty params_TMP 	prop_params_Nom 	( prop_value )
				
			) -- fin 	for prop_params_Nom   -----
			local result = mgr_datas.get_datas_string		params_TMP
			result
		),
		fn charger_paramsElem 		_value		_params	=(
			
			local params_TMP 	= copy 	_params
			if _params != undefined do (
				mgr_datas.set_datas_string		_value		params_TMP
				
				for paramNom in getPropNames	params_TMP  do (
					local propVal = getProperty params_TMP	paramNom
					if classOf propVal == array do (
						for i = 1 to propVal.count do (
							local env_elem = m_core.get_element_parID 	propVal[i]
							if env_elem != undefined do propVal[i] = env_elem
						)
					)
				)
			)
			params_TMP
		),
	
		
		public	
		fn enregistrer_parametres		_element		=(
			debug "###		enregistrer_parametres		###"
			debug "###		_element" var:_element
			local prop_element_Noms 	= getPropNames	_element
			local elem_index 				= get_element_index		_element
			
			--- si param deja present, on actualise -------------------
			for prop_element_Nom in prop_element_Noms do (
				
				local prop_element 			= getProperty _element  prop_element_Nom
				local param_nom 				= m_prefix_nomParametres + "_" + prop_element_Nom
				
				----  en fonction de la classe du param ---------------
				case classOf prop_element of (
					MAXScriptFunction:() 
					Array: 		(
						
						---- si on a un tableau de STRUCTs � nous (composants, menuiseries, ... )	on fait la liste des IDUniques	---------------------
						if prop_element.count != 0 then 
							if superclassOf	prop_element[1] == StructDef do	(
								local liste_ids = #()
								for ss_elem in prop_element do (
									append 	liste_ids	ss_elem.id
									m_core.enregistrer_element  	ss_elem									
								)
								prop_element = liste_ids								
							)
						
						--- on enregistre -----------
						enregistrer_parametre 	param_nom		( mgr_datas.array_to_string	prop_element )		index:elem_index
						
					)
					default: 	(
						
						---- si on a les #PARAMS ---------------
						if prop_element_Nom == #params do 							
							prop_element = enregistrer_paramsElem  	prop_element
						
						--- on enregistre -----------
						enregistrer_parametre 	param_nom		prop_element		index:elem_index
						
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
						Array: 		(
							-- si on a une liste d'�l�ment � nous	-------------
							local tab_params	=		( mgr_datas.string_to_array	param_value )
							if tab_params.count > 0 then (
								if classOf	tab_params[1] == string do
									if findString tab_params[1]	"ID_" != undefined do (
										
										-- on check si c'est l'instance d'un element deja present -----------
										param_value = #()
										for elemID in tab_params do	(
											
											local	param_instance
											
											for param_present in param_value do 
												if param_present.id == elemID do
													param_instance = param_present
											
											
											if param_instance != undefined then 
												append	param_value  	param_instance
											else append param_value	( m_core.get_element_parID  elemID )
											
										)
										
									)
									
							)  else param_value = tab_params
							
							---- on charge ----------------
							setProperty	_element	  prop_element_Nom		param_value
						)
						default: 	(
							
							--- si on a les parametres #PARAMS d'un composant  -----
							if prop_element_Nom == #params then (
								
								param_value = charger_paramsElem  	param_value			_element.params
								setProperty	_element	  prop_element_Nom		param_value	
								
							)
							
							--- sinon on a un parametres classique -----
							else 	setProperty	_element	  prop_element_Nom		param_value		
						)
						
					) -- fin case  classOf prop_element 
				) -- fin if MAXScriptFunction --------
			) -- fin for prop_element	--------
		),
		
		
		
		
		
		
		---- Creation/Suppression etc. ---------------------------------------------------
		fn creer_element		idUnique:		idConstructeur:		enregistrer:false	=(
			
			----------------- Structure d'un �l�ment	------------------------------------------
			m_classeBase	=	fileIn	 m_fichier_classeBase			
			nvl_element 		= m_classeBase 	()
			
			----- facon constructeur --------
			if idConstructeur != unsupplied do (
				-- si on a un type et non pas un index	de constructeur -------------
				if classof 	idConstructeur == name or classof idConstructeur == string	do
					idConstructeur = get_constructeur_index		idConstructeur			
				if idConstructeur != 0 do
					m_constructeursBase[ idConstructeur ].initialiser		nvl_element
			)
			
			--- id Unique -----------
			if idUnique != unsupplied do 
				nvl_element.id = idUnique
			
			---	la reference au manager	--------------
			nvl_element.set_manager 	this
			
			-- si besoin on enregistre direct sur le plug -----
			if enregistrer do enregistrer_parametres	nvl_element
			
			nvl_element
			
		),
		fn dupliquer_element			_element		enregistrer:false 	=(
			debug "dupliquer_element"
			
			--- si on a recuperer un index � la place de l'element lui-meme, on va chercher l'�l�ment ---------------------------
			if classof  _element == integer then
				_element = this.get_element_parIndex  _element
			
			debug "_element" var:_element
			
			-- On construit l'element dupliqu�	 ----------------
			local nvl_element
			if a_constructeurs () then
				nvl_element = creer_element	enregistrer:enregistrer	idConstructeur:( _element.type )
			else 	nvl_element = creer_element	enregistrer:enregistrer
			
			
			
			
			--- On duplique les parametres ----------------
			local prop_element_Noms = getPropNames	_element
			
			--- si param deja present, on actualise -------------------
			for prop_element_Nom in prop_element_Noms where prop_element_Nom != #id do (
				
				debug "prop_element_Nom" var:prop_element_Nom
				local prop_element 			= getProperty _element  prop_element_Nom
				
				---- si on a les #PARAMS ---------------
				if prop_element_Nom == #params then (
					prop_element = mgr_datas.get_datas_string		prop_element
					mgr_datas.set_datas_string		prop_element		nvl_element.params
					
				) else (
				----  sinon en fonction de la classe du param ---------------
					case classOf prop_element of (
						MAXScriptFunction:() 
						Array: 		(
							
							---- si on a un tableau de STRUCTs � nous (composants, menuiseries, ... )	on fait la liste des IDUniques	---------------------
							if prop_element.count != 0 then 
								if superclassOf	prop_element[1] == StructDef do	(
									local liste_copie = #()
									for ss_elem in prop_element do (
										local		ss_elem_copie = m_core.dupliquer_element	ss_elem 	enregistrer:enregistrer
										append 	liste_copie		ss_elem_copie
										
									)
									prop_element = liste_copie								
								)
							
							debug "Array----> prop_element" var:prop_element
							setProperty	nvl_element	  prop_element_Nom		prop_element 
						)
						default: 	(
							debug "default----> prop_element" var:prop_element
							setProperty	nvl_element	  prop_element_Nom		prop_element
						)
					) -- fin case
					
				)
				
				debug "prop_element" var:prop_element
				
			)-- fin for
			nvl_element.nom += " - copie"
			debug "RESULT DUPLIQUER" var:nvl_element
			if enregistrer do
				m_core.enregistrer_element	nvl_element
			
			nvl_element
			
		),
		fn supprimer_element 		_element	=(
			debug"supprimer_element"
			debug"_element -1-"	var:_element
			--- si on a recuperer un index � la place de l'element lui-meme, on va chercher l'�l�ment ---------------------------
			if classof  _element == integer then
				_element = this.get_element_parIndex  	_element
-- 			else if classof  _element == string or classof  _element == name then
				
			debug"_element -2-"	var:_element
			
			local prop_element_Noms = getPropNames	_element
			
			local param_index = 0
			-- si c'est un tableau de parametres ( donc s'il exite une liste d'IDs )-------------
			if hasproperty	m_plug	  ( m_prefix_nomParametres + "_id" ) do 			
				param_index = get_param_index_parIDUnique 		_element.id
			
			
			--- si param deja present, on actualise -------------------
			for prop_element_Nom in prop_element_Noms do (
				
				
				local prop_element 	= getProperty 	_element  	prop_element_Nom
				
				-- si c'est pas une fonction --------------
				if classof prop_element != MAXScriptFunction do (
					
					
					-- si c'est un tableau de parametres ( donc s'il exite une liste d'IDs )-------------
					if hasproperty	m_plug	  ( m_prefix_nomParametres + "_id" ) do (
						
						debug "prop_element_Nom" var:prop_element_Nom
						
						local param_nom 		= m_prefix_nomParametres + "_" + prop_element_Nom					
						local param_value		= getProperty	m_plug		param_nom
						
						
						deleteItem	param_value	 param_index 
					)
					
				) -- fin if MAXScriptFunction --------
			) -- fin for prop_element	--------
		),			
		
		
		
		
		
		
		---- Accessions	-------------------
		fn	get_element_parIndex				_index =(
-- 			debug "get_element_parIndex"
			local element
			local params_ids 	= getProperty	m_plug	  ( m_prefix_nomParametres + "_id" )
			local param_id		= params_ids[ _index ]
-- 			debug "params_ids" var:params_ids
-- 			debug "param_id" var:param_id
			if _index <= params_ids.count do (
				if a_constructeurs () then 		(
					local params_types	= getproperty	m_plug		( m_prefix_nomParametres + "_type" )
-- 					local param_id			= params_ids[ _index ]
					element 		= creer_element	idUnique:param_id		idConstructeur:params_types[ _index ]
				) else element 	= creer_element	idUnique:param_id
				
				charger_parametres		element
			)
-- 			debug "element PAR INDEX ---------->" var:element
			element
		),
		fn get_element_parID  		_idUnique	=(
			
			local result
			local index_result = 0
			local params_ids 			= getProperty	m_plug	  ( m_prefix_nomParametres + "_id" )
			for i = 1 to params_ids.count do (
				if params_ids[i] == _idUnique do index_result = i
			)
			if index_result != 0 do
				result = get_element_parIndex 	index_result
			result
		),
		fn get_elements =(
			
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
		
		
		fn a_desParametres	_index:	=(
			local result
			
			local params_nom 	= m_prefix_nomParametres + "_params"
			local params
			
			-- si c'est un tableau de parametres ( donc s'il exite une liste d'IDs )-------------
			if hasproperty	m_plug	  ( m_prefix_nomParametres + "_id" ) then (				
				local params_liste		= getProperty m_plug  	params_nom
				params						= params_liste[_index ]				
			) else 	params				= getProperty m_plug  	params_nom
			
			result = params != ""
			
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
				m_dialog
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
			m_core 							=	m_plug.core
			m_fichier_classeBase 		= 	fichier_classeBase
			if dossier_constructeurs != unsupplied do 
				m_dossier_constructeurs 	= 	dossier_constructeurs
			if fichier_dialog != unsupplied do 
				m_dialog 						= 	fileIn 	( "$userScripts\cp-Urba\modules\Batiment\\rollouts\\" + fichier_dialog ) 
			m_prefix_nomParametres 	= 	prefix_nomParametres
			
			mgr_datas 						= m_core.get_mgrDatas ()
			
			
			--- les constructeurs -----------
			if a_constructeurs () do
				initialiser_constructeurs ()
			
		)
		
		
	
)








