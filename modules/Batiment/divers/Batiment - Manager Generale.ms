struct  str_manager_global (
	
	---- MEMBRES ----------------------------------------------------------------------------------------------------------------
	private
		m_plug,
		
		--- le dossier on sont rangés les constructeurs de composants ----------
		m_dossier_constructeurs ,	----		= 	getdir #userScripts + "\\cp-Urba\\modules\\Batiment\\elements\\toitures\\" ,
		
		---- constructeurs source pour la construction des composants	---------------------
		m_constructeursBase 	=#(),
		
		---- le rollout	--------------------
		m_dialog			,	----			= 	filein	 "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - rollout facade.ms",
		m_dialog_estOuvert 	= false,
		m_dialog_pos			= [700,200],
		m_dialog_taille			= [500,500],
		
		---- FONCTIONS --------------------------------------------------------------------------------------------------------------

	public
		---- Parametres ----------------		
		fn enregistrer_parametres		_element		=(
		),
		fn charger_parametres 			_element		  =(
		),
		
	
		---- Creation/Suppression etc. ----
		fn creer_element		idUnique:	=(
			----------------- Structure d'un élément	------------------------------------------
			include	 "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Facade.ms"
			
			nvl_element = str_facade 	() --	id:m_plug.fac_ids[_index]
			if id != unsupplied do 
				nvl_element.id = idUnique
			nvl_element
		),
	
		---- Accessions	-------------------
		fn	get_element_fromParam_parIndex				_index =(
			
			local nvl_facade = get_nvl_element 	id:m_plug.fac_ids[_index]
			charger_parametres		nvl_facade
			nvl_facade
		),
		fn get_element_fromParam_parIDUnique  		_idUnique	=(
			local result
			local index_result = 0
			for i = 1 to m_plug.fac_ids.count do (
				if m_plug.fac_ids[i] == _idUnique do index_result = i
			)
			result = get_facade_parIndex 	index_result
		),
		fn get_elements_fromParam =(
			local facades = #()
			for idUnique in m_plug.fac_ids do
				append facades	( get_facade_parIDUnique 	idUnique)
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
		
		
				
		-----------------Constructeur	---------------------------------------------------
		fn initialiser_constructeurs =(	
			--- on va chercher les fichiers des assets pour les composants de facades -------------
			m_constructeursBase =#()
			local fichiers_toiture	=	getfiles ( m_dossier_constructeurs+ "*.ms" )	
			for fichier_toiture in fichiers_toiture do (
				local nv_constructeur_toiture =  fileIn fichier_toiture
				append m_constructeursBase  	nv_constructeur_toiture
			)
		),
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
		
		
		
		----------------- Initialiser	---------------------------------------------------
		fn initialiser	_plug	=(
			debug "initialiser ()"
			m_plug = _plug
			initialiser_constructeurs ()
		)
		
		
	
)









