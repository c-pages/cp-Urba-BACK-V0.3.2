

 


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
		
	------ Fonctions ------------------------------------------------------------------------------
	public
		---- Mutations -----------------------
		fn set_dialog 			_dialog 				= ( m_dialog 				= _dialog ),
		fn set_construire 		_fnConstruire 	= ( fnVirt_construire 		= _fnConstruire ),
		fn set_params			_params			= ( params					= _params ),
		
		---- Accessions -----------------------
		fn get_typeClasse		= "facCompo",
		fn get_dialog				=	m_dialog,
		fn a_desParametres	=	params != undefined,
		fn get_longueur 		=	if ( a_desParametres () ) then params.longueur else 0,
		
		--- Initialisations -----------------------
		fn initialiser_dialog 	_roll_parent 	=(
			if ( a_desParametres () )  do (
				m_dialog.m_rollPrt		= 	_roll_parent
				m_dialog.m_compo	=	this
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
		
		/* 
		---- Enregistrement / chargement	-----------------
		fn enregistrer 	_plug	=(
-- 			debug "enregistrer"
-- 			debug "id  "var:( id   as name )
			local mgr_datas = _plug.core.get_mgrDatas ()
			
				--- on cherche s'il existe deja comme parametre -----
			local index_composant = 0
			for i = 1 to _plug.fac_compos_ids.count do (
-- 				debug "_plug.fac_compos_ids[i] as name	  "var:(_plug.fac_compos_ids[i] as name	)  
-- 				debug "	== id   as name "var:( execute (_plug.fac_compos_ids[i] ) as string	== ( id   as string ) )
				
				if  execute (_plug.fac_compos_ids[i] ) as string	== id  as string do 
					index_composant = i
				
				)
			
			
			
			--- s'il n'existe pas encore, on l'ajoute -----
			if index_composant == 0 then (
				
				append 	_plug.fac_compos_ids 				id
				append 	_plug.fac_compos_noms  			nom
				append 	_plug.fac_compos_types  			type
				append 	_plug.fac_compos_params  		(	mgr_datas.get_datas_string	params	)
				
			--- s'il existe, on l'actualise -----
			) else (
				
				_plug.fac_compos_noms[index_composant] 		=	nom				
				_plug.fac_compos_types[index_composant]		=	type		
				_plug.fac_compos_params[index_composant]		=	(	mgr_datas.get_datas_string	params	)
				
			) 
		),
		fn charger 	_plug	idUnique: =(
			
-- 			debug "charger"
			if idUnique != unsupplied do id = idUnique as name
			
			local mgr_datas = _plug.core.get_mgrDatas ()
			
			--- on cherche s'il existe deja comme parametre -----
			local index_composant = 0
			local i= 1
			local trouve = false
			while i <= _plug.fac_compos_ids.count and not trouve	do (
				
				if (  _plug.fac_compos_ids[i] ) as name == id  do (
					index_composant = i
					trouve = true
				)
				i+= 1
			)
			
			-- on charge	------------------------------------
			if index_composant != 0 then (
				
				nom 				= 	_plug.fac_compos_noms[index_composant]
				type				=	_plug.fac_compos_types[index_composant] as name
				
				mgr_datas.set_datas_string		_plug.fac_compos_params[index_composant]			params
				
			)
		)

			 */
		
) ---- fin composant -------------------------------
