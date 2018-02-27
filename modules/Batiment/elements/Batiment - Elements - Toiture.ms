

 


struct 	str_toiture (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_toiture",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	
	------ Membres ------------------------------------------------------------------------------
	public
		---- Parametres -----------------------------------
-- 		nom					=	"",
		type					=	undefined,
		params				=	undefined,
		
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
		fn get_dialog				=	m_dialog,
		fn a_desParametres	=	params != undefined,
		
		--- Initialisations -----------------------
		fn initialiser_dialog 	_plug 	=(
			m_dialog.m_plug		= 	_plug
			m_dialog.m_toiture	=	this
			m_dialog.mgr_toiture	= _plug.core.get_mgr_toiture ()
			m_dialog.actualiser()
		),
		fn initialiser 		_type	_nom 	=(
			
			type 				=	_type 			
			nom				=	_nom
			
		),
		
		---- Construction du mesh 	( fonction virtuelle ) -----------------------
		fn construire		_plug	 	pts_accroches					= 		fnVirt_construire	 _plug	pts_accroches		this	
		
) ---- fin composant -------------------------------
