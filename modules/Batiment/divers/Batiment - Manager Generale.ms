

/* -----------------------------
initialiser les membre suivant  :
	*	m_plug							<----------- le plugin portant les parametres
	*	m_fichier_classeBase			<----------- la class de base à gérer
	*	m_dossier_constructeurs		<----------- le dossier contenant les constructeurs
	*	m_dialog							<----------- le rollout pour manipuler les données de 'm_classe_base'
	*	m_prefix_nomParametres		<----------- le prefix des noms de parametres
*/ -----------------------------


struct  str_manager_parametres_univ (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:"urba | str_manager_parametres_univ"	catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	
	
	---- MEMBRES ----------------------------------------------------------------------------------------------------------------
	private
		m_plug,
		m_fichier_classeBase = "",
		m_classeBase,
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
		
		mgr_datas ,			
		
		---- FONCTIONS --------------------------------------------------------------------------------------------------------------
		---- Parametres ----------------
	private
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
			
			local index_param_present = get_param_index_parIDUnique _element.id
			local prop_element_Noms = getPropNames	_element
			
			--- si param deja present, on actualise -------------------
			for prop_element_Nom in prop_element_Noms do (
				local prop_element 			= getProperty _element  prop_element_Nom
				local param_nom 				= m_prefix_nomParametres + "_" + prop_element_Nom
				
				if prop_element_Nom == #params do
					prop_element = mgr_datas.get_datas_string		prop_element
				
				case classOf prop_element of (
					MAXScriptFunction:()
					Array: 		(					
						local param_arrayTEMP 		= getProperty	m_plug	  param_nom	
						if  index_param_present  	!= 0 then 
							param_arrayTEMP[ index_param_present ] =		mgr_datas.array_to_string	prop_element
						else
							append 	param_arrayTEMP		( mgr_datas.array_to_string	prop_element )		
					)
					default: 	(					
						local param_arrayTEMP 		= getProperty	m_plug	  param_nom		
						if  index_param_present  	!= 0 then 
							param_arrayTEMP[ index_param_present ] =		prop_element
						else	
							append 	param_arrayTEMP		( prop_element )
					)
				) -- fin case
				
			)-- fin for
			
			
			
		),
		fn charger_parametres 			_element		=(
		),
		
		
		-----------------Constructeur	---------------------------------------------------
		fn initialiser_constructeurs =(
			debug "initialiser_constructeurs"
			if m_dossier_constructeurs != "" do (
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
		
		
		
		
		---- Creation/Suppression etc. ----
		fn creer_element		idUnique:		idConstructeur:		=(
			
			----------------- Structure d'un élément	------------------------------------------
			m_classeBase	=	fileIn	 m_fichier_classeBase
			
			nvl_element 		= m_classeBase 	()
			
			----- facon constructeur --------
			if idConstructeur != unsupplied do (
				-- si on a un type et non pas un index	de constructeur -------------
				if classof 	idConstructeur == name or classof idConstructeur == string	do
					idConstructeur = get_constructeur_ID		idConstructeur			
				m_constructeursBase[ idConstructeur ].initialiser		nvl_element
			)
			
			--- id Unique -----------
			if idUnique != unsupplied do 
				nvl_element.id = idUnique
			
			nvl_element
			
		),
		
		---- Accessions	-------------------
		fn	get_element_parIndex				_index =(
			
			local nvl_facade = creer_element 	id:m_plug.fac_ids[_index]
			charger_parametres		nvl_facade
			nvl_facade
		),
		fn get_element_parIDUnique  		_idUnique	=(
			local result
			local index_result = 0
			for i = 1 to m_plug.fac_ids.count do (
				if m_plug.fac_ids[i] == _idUnique do index_result = i
			)
			result = get_facade_parIndex 	index_result
		),
		fn get_elements =(
			local elements 		= #()
			local params_ids_nom 	= m_prefix_nomParametres + "_id"
			local params_ids 			= getProperty	m_plug	  params_ids_nom	
-- 			for idUnique in params_ids do
-- 				append elements	( get_facade_parIDUnique 	idUnique)
			debug "params_ids" var:params_ids
			facades
		),
		
		fn a_desParametres		=	m_plug.toiture_params != "" and m_plug.toiture_params != undefined,
		
				
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
		
		
		
		
		
		
		----------------- Initialiser	---------------------------------------------------
		fn initialiser	plug:							\
							fichier_classeBase:			\
							dossier_constructeurs:	\
							dialog:							\
							prefix_nomParametres:	=(
			
			debug "initialiser ()"
			
			m_plug 							=	plug
			m_fichier_classeBase 		= 	fichier_classeBase
			m_dossier_constructeurs 	= 	dossier_constructeurs
			m_dialog 							= 	dialog
			m_prefix_nomParametres 	= 	prefix_nomParametres
			
			mgr_datas 						= m_plug.core.get_mgrDatas ()
			
			initialiser_constructeurs ()
			
		)
		
		
	
)









