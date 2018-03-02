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
			
		---- Parametres -----------------------------------
		public
			id 			="Menuis_",
			nom 			= "Menuiserie",
			type 			= undefined ,	----  liste_types = #( "Fixe", "Fenêtre", "Porte pleine", "Porte vitrée", "Porte de garage"   ......   )
			
			longueur 	= 0,			
			
			params		=	undefined,
			
		---- Rollout et fct internes	-----------------------------------
		private		
			m_dialog 			= undefined,
			
			---- Fonction virtuelle pure pour construire le composant	----
			fnVirt_construire	= (),
			
		------ Fonctions ------------------------------------------------------------------------------
		public
			---- Mutations -----------------------
			fn set_dialog 			_dialog 				= ( m_dialog 				= _dialog ),
			fn set_construire 		_fnConstruire 	= ( fnVirt_construire 		= _fnConstruire ),
			fn set_params			_params			= ( 
				params					= copy  _params 
				if params != undefined do (
					for propnom in  getpropnames _params do (
						local val = getproperty	_params	propnom 
						case classOf val of (
						array:	setproperty	_params	propnom 	(for elem in val collect copy elem )
							default:	setproperty	_params	propnom 	(copy val )
						)
					)
				)
			),
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
			
			fn initialiser 		_type	_nom 	=(
				
				---- id unique ----
				for i= 1 to 10 do id += ( random 0 9 ) as string	
				
				type 				=	_type 			
				nom				=	_nom
				
			),
			
			---- Construction du mesh 	-----------------------
			fn construire		_plug		_ptr_baie		 pt_origine	_normDir		_hauteur	= 	
							fnVirt_construire  _plug		_ptr_baie		 pt_origine	_normDir		_hauteur	  this--,

		
-- 			on create do initialiser ()
	) ---- fin composant -------------------------------
)