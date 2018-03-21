

 (


struct 	str_composant_generique	 (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_composant_generique",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		
		
		
		
	------ Membres ------------------------------------------------------------------------------
	public
		id						=	"",		
		nom					=	"",
		type					=	undefined,		
		params				=	undefined,
		
		
	private		
		m_type_classe ="",						--- le type de la classe ---
		m_dialog 				= undefined,		---- Rollout -----------------------------------
		fnVirt_construire	= (),					---- Fonction virtuelle pour construire le composant	----
		
		
	------ Fonctions ------------------------------------------------------------------------------
	public
		---- Mutations -----------------------
		fn set_dialog 		_dialog 				= ( m_dialog 				= _dialog ),
		fn set_construire 	_fnConstruire 	= ( fnVirt_construire 		= _fnConstruire ),
		fn set_params			_params		= ( 
			params					= copy  _params 
			if params != undefined do (
				for propnom in  getpropnames _params do (
					local val = getproperty	_params	propnom 
					case classOf val of (
						MAXScriptFunction:() 
						array:	setproperty	_params	propnom 	(for elem in val collect copy elem )
						default:	setproperty	_params	propnom 	(copy val )
					)
				)
			)
		),
		
		
		---- Accessions -----------------------
		fn get_typeClasse		= m_type_classe,
		fn get_dialog				=	m_dialog,		
		fn a_desParametres	=	params != undefined,
		fn get_longueur 		=	if ( a_desParametres () ) then params.longueur else 0,
		
		
		--- Initialisations -----------------------
		fn set_typeClasse	_type_classe	= m_type_classe = _type_classe,
		fn initialiser_dialog 	 	_plug  roll_parent:		ptr_this:		=(
				m_dialog = copy m_dialog
			if ( a_desParametres () )  do (
				if roll_parent != unsupplied do
						m_dialog.m_rollPrt		= 	roll_parent
				if ptr_this  == unsupplied do
					ptr_this = this
				m_dialog.m_compo	=	ptr_this
-- 			format "######### m_dialog.m_compo : %\n" m_dialog.m_compo
				m_dialog.m_plug		=	_plug
				m_dialog.actualiser()
			)
		),
		
		fn generer_ID =(
			format "generer_ID\n"
			id = "ID_" + get_typeClasse () + "_"
			seed ( timeStamp () )
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		),
		fn initialiser 		_type	_nom 	=(
			
			generer_ID ()
			
			type 				=	_type 			
			nom				=	_nom
			
		),
		
		
		
		
		---- Construction du mesh 	( fonction virtuelle ) -----------------------
		fn construire							_plug	 	pts		\
													norm_dir:				\
													onConstruitLaDalle:true	 	\
													profondeur:0			\
													dist_hauteur:		\
													ptr_baie:				\
													compo_debut:	\
													etage_ht:			\
													transformation:	\
													inverse_ouverture:	\
													onConstruit_gardeCorps:		= 
		
				fnVirt_construire			 _plug		pts	\
													norm_dir:norm_dir		\
													onConstruitLaDalle:onConstruitLaDalle  		\
													profondeur:profondeur	\
													dist_hauteur:dist_hauteur		\
													ptr_baie:ptr_baie	\
													this:this	\
													compo_debut:compo_debut	\
													etage_ht:etage_ht			\
													transformation:transformation	\
													inverse_ouverture:inverse_ouverture	\
													onConstruit_gardeCorps:onConstruit_gardeCorps	
		
) ---- fin composant -------------------------------


)