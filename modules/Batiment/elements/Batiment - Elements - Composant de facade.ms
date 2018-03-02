

 (


struct 	str_composant (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_composant",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		
		
		
		
	------ Membres ------------------------------------------------------------------------------
	public
		---- Parametres -----------------------------------
		id						=	"ID_facCompo_",		
		nom					=	"",
		type					=	undefined,
		params				=	undefined,
		
	private		
		---- Rollout -----------------------------------
		m_dialog 			= undefined,
		
		---- Fonction virtuelle pure pour construire le composant	----
		fnVirt_construire	= (),
		
		mgr, 		-------  le manager manipulant ces structs  ---------------
		
	------ Fonctions ------------------------------------------------------------------------------
	public
		---- Mutations -----------------------
		fn set_dialog 		_dialog 				= ( m_dialog 				= _dialog ),
		fn set_construire 	_fnConstruire 	= ( fnVirt_construire 		= _fnConstruire ),
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
		fn set_manager		_mgr				= ( mgr						= _mgr ),
		
		---- Accessions -----------------------
		fn get_typeClasse		= "facCompo",
		fn get_dialog				=	m_dialog,
		fn get_manager			= mgr,
		fn a_desParametres	=	params != undefined,
		fn get_longueur 		=	if ( a_desParametres () ) then params.longueur else 0,
		
		--- parametres -------------------
		fn enregistrer			= mgr.enregistrer_parametres	this,
		fn charger					= mgr.charger_parametres			this,
		
		--- Initialisations -----------------------
		fn initialiser_dialog 	_roll_parent 	_plug =(
			if ( a_desParametres () )  do (
				m_dialog.m_rollPrt		= 	_roll_parent
				m_dialog.m_compo	=	this
				m_dialog.m_plug		=	_plug
				m_dialog.actualiser()
			)
		),
		fn initialiser 		_type	_nom 	=(
			
			---- id unique ----
			for i= 1 to 10 do id += ( random 0 9 ) as string	
			
			type 				=	_type 			
			nom				=	_nom
			
		),
		
		---- Construction du mesh 	( fonction virtuelle ) -----------------------
		fn construire		_plug	 	pts_accroches		_normDir		onConstruitLaDalle:true	 profondeur:0	= 		
						fnVirt_construire	 _plug	pts_accroches		_normDir		this	onConstruitLaDalle:onConstruitLaDalle  profondeur:profondeur
		
) ---- fin composant -------------------------------


)