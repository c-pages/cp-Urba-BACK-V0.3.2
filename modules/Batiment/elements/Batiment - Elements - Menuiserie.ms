 (
	struct 	str_menuiserie (
		
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		private
			m_debug = true,
			m_dbgPrefix ="urba | str_menuiserie",
			fn debug 	_txt  var:	 param:    =(
				try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
				catch ()
			),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		
		
		------ Membres ------------------------------------------------------------------------------
		private 
			mgr,
			
		public
			---- Parametres -----------------------------------
			id 			="Menuis_",
			nom 			= "Menuiserie",
			
			type 			= "Fixe",	----  liste_types = #( "Fixe", "Fenêtre", "Porte pleine", "Porte vitrée", "Porte de garage" )
			longueur 	= 0,	
			allege_ht	=	0,
			
			ouvrant_ht		=	0,
			ouvrant_sens		=	1,
			
			ouvert_proba 	= 0,
			ouvert_min	 	= 0,
			ouvert_max 		= 0,
			
			
		private		
			---- Rollout -----------------------------------
			m_dialog 			= undefined,
			
			---- Fonction virtuelle pure pour construire le composant	----
			fnVirt_construire	= (),
			
		------ Fonctions ------------------------------------------------------------------------------
		public
			---- Mutations -----------------------
			fn set_dialog 			_dialog 				= ( m_dialog 				= _dialog ),
			fn set_construire 		_fnConstruire 	= ( fnVirt_construire 		= _fnConstruire ),
			fn set_params			_params			= ( params					= _params ),
			
			---- Accessions -----------------------		
			fn get_typeClasse		= "facMenis",			
			fn set_manager		_mgr				= ( mgr						= _mgr ),
			
			fn get_manager			= mgr,
			fn get_dialog				=	m_dialog,
			fn a_desParametres	=	params != undefined,
			
			--- parametres -------------------
			fn enregistrer			= mgr.enregistrer_parametres	this,
			fn charger					= mgr.charger_parametres			this,
				
			--- Initialisations -----------------------
			fn initialiser_dialog 	_plug 	=(
				m_dialog.m_plug			= 	_plug
				m_dialog.m_menuiserie	=	this
				m_dialog.mgr_toiture		= _plug.core.get_mgr_toiture ()
				m_dialog.actualiser()
			),
			/* 
			fn initialiser_dialog 	_roll_parent 	_plug =(
				if ( a_desParametres () )  do (
					m_dialog.m_rollPrt		= 	_roll_parent
					m_dialog.m_compo	=	this
					m_dialog.m_plug		=	_plug
					m_dialog.actualiser()
				)
			), */
			fn initialiser 	=(
				
				---- id unique ----
				for i= 1 to 10 do id += ( random 0 9 ) as string	
				
			),
			
			---- Construction du mesh 	( fonction virtuelle ) -----------------------
			fn construire		_plug	 	pts_accroches					= 		fnVirt_construire	 _plug	pts_accroches		this	,

		
			on create do initialiser ()
	) ---- fin composant -------------------------------
)