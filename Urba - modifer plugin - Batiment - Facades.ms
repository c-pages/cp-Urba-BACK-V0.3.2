





---- manager des facades -----
struct 	str_facades (
		
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_facades",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
	------------------------------------------------------------------------------------------------------------------------------------------------------
	------------ MEMBRES	--------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------
	---- Pointeurs divers --------------------
	public
		m_construire,		---- struct de construction ----
		m_this,				---- le plugin: 'this' ----
		m_dialog,			---- la fenetre de m_dialog ----
		
	---- Parametres de la fenetre  --------------------
	private
		m_dialog_pos 				= [1235,223],
		m_dialog_estOuvert 		= false,
		
	---- Pour manipuler les parametres du batiment  --------------------
		m_paramsNoms 			= #(	#nom, #etages_nbre_min, #etages_nbre_max, #longueur_min, #longueur_max, #murs, #repeter, #etirer, #sequence	),		
		m_datasMgr 				= str_datasMgr 	m_prt:this,
		m_presets 					= str_presets_batiment 	fichier_dossier:			( getDir #userScripts	 + "\\cp-Urba\\lib\\façades\\"		)	\
																			fichier_categorie:			"Urba - Façades"	\
																			fichier_extension:			"fcd"	\
																			params_aEnregistrer:	m_paramsNoms,
		
	---- Le scanner de mesh  --------------------
		m_scannerMesh 			= str_enregistreurDeNode (),
		
	---- Les parametres du batiment  --------------------
		m_facades_total			= #(), 		---- les facades du batiment en struct-		--------------
		m_composants_total		= #(), 		---- les composant du batiment en struct	---------------
		m_modeles_total			= #(), 		---- les modeles du batiment en struct		---------------
		m_parametriques_total	= #(), 		---- ---------------
		
		m_facade_courante 		= str_facade (),
		m_id_courant 				= 0,
		
	---- Createur de composant -----------------
		creerComposant 			= str_createur_de_composant 	m_this:m_this,
		
		
	------------------------------------------------------------------------------------------------------------------------------------------------------
	------------ FONCTIONS -------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------
	private
	----	Composants 	-----------------
		fn get_composant_idUnique_param		_id 	 		=(
			local strg_param 	= m_this.facades_composants[_id]
			local idStrg 			= findstring 	strg_param		"#FAC_CMP_"
			local result 			= substring 	strg_param 	idStrg	  19 
			result
		),
		fn get_composants_ids_param 				 			=(
			local result =#()
			for i = 1 to m_this.facades_composants.count	 do (
				append result  ( get_composant_idUnique_param i )
			)
			result
		),
		fn get_composant_idParam				_idUnique	=(
			
			local composants_ids = get_composants_ids_param 	()	
			local result = 0
			for i= 1 to 	composants_ids.count	 do
				if composants_ids[i] == _idUnique do result = i
			result
		),
		fn get_composant							_idUnique	=(
			
			local result
			for compo in m_composants_total do
				if compo.id == _idUnique do result = compo
			result
			
		),
	----	Modeles	 -----------------
		fn get_modele_idUnique_param			_id 	 		=(
			local strg_param 	= m_this.facades_modeles[_id]
			local idStrg 			= findstring 	strg_param		"#FAC_MOD_"
			local result 			= substring 	strg_param 	idStrg	  19 
			result
		),
		fn get_modeles_ids_param 	 							=(
			local result =#()
			for i = 1 to m_this.facades_modeles.count	 do (
				append result  ( get_modele_idUnique_param i	 )
			)
			result
		),
		fn get_modele_idParam						_idUnique	=(
			
			local modeles_ids = get_modeles_ids_param 	()	
			local result = 0
			for i= 1 to 	modeles_ids.count	 do
				if modeles_ids[i] == _idUnique do result = i
			result
		),
		fn get_modele									_idUnique	=(
			local result
			for modele in m_modeles_total do
				if modele.id == _idUnique do result = modele
			result
		),
	----	Composants 	parametriques 	-----------------
		fn get_parametrique_idUnique_param	_id 	 		=(
			local strg_param 	= m_this.facades_parametriques[_id]
			local idStrg 			= findstring 	strg_param		"#FAC_P"
			local result 			= substring 	strg_param 	idStrg	  19 
			result
			
		),
		fn get_parametriques_ids_param 	 					=(
			local result =#()
			for i = 1 to m_this.facades_parametriques.count	 do (
				append result  ( get_parametrique_idUnique_param 	i )
			)
			result
		),
		fn get_parametrique_idParam				_idUnique	=(
			
			local modeles_ids = get_parametriques_ids_param 	()	
			local result = 0
			for i= 1 to 	modeles_ids.count	 do
				if modeles_ids[i] == _idUnique do result = i
			result
		),
		fn get_parametrique							_idUnique	=(
			local result
			for param in m_parametriques_total do
				if param.id == _idUnique do result = param
			result
		),
		
		
		
	----------------	 PARAM  <---->  STRUCT 	--------------------------------------------------------------------------------------------------------
	private
		----- creation des structs -----
		fn params_toStructs 									=(
			
			------ Modeles -------
			m_modeles_total				= #()
			for modele in m_this.facades_modeles 	do (
				local nvModele =   str_facade_modele ()
				m_datasMgr.set_datas_string		modele		nvModele
				append m_modeles_total 	nvModele
			)
			
			------ Parametriques -------
			m_parametriques_total				= #()
			for strg_param in m_this.facades_parametriques 	do (
				local nvParam 					
				local idStrg 		= findstring 	strg_param		"#FAC_P"
				local type	 		= substring 	strg_param 	(idStrg+6)	  2 
				case type of (
					"MP": 	nvParam = str_facadeParam_murPlein ()
					"BS":		nvParam = str_facadeParam_baieSimple ()
					"BT":		nvParam = str_facadeParam_baie ()
					"ES":		nvParam = str_facadeParam_espacement ()
					"BD":		nvParam = str_facadeParam_balcon ()
					"BF":		nvParam = str_facadeParam_balconFin ()
				)
				m_datasMgr.set_datas_string			strg_param		nvParam		
				append m_parametriques_total 		nvParam
			)
			
			
			------ Composants -------
			m_composants_total		= #()
			for compo in m_this.facades_composants 	do (
				local nvCompo =   str_facade_composant ()
				m_datasMgr.set_datas_string		compo		nvCompo	
				append m_composants_total 		nvCompo
				if nvCompo.type == #parametrique do
					nvCompo.param[1].actualiser 	nvCompo		m_construire
			)
			
			------ Façades -------
			m_facades_total				= #()
			for fac in m_this.facades_items 	do (
				local nvfacade =   str_facade ()
				m_datasMgr.set_datas_string		fac		nvfacade	
				append m_facades_total 		nvfacade	
			)
			
		),
		----- Enregistrer les structs dans les parametres  -------------------------------------
		fn enregistrer_parametrique		_param			=(
			
			local id_param = get_parametrique_idParam		_param.id		
			
			if id_param != 0 then
				m_this.facades_parametriques[id_param] = 	(m_datasMgr.get_datas_string  _param)
			else
				append	m_this.facades_parametriques			(m_datasMgr.get_datas_string  _param)
			
		),
		fn enregistrer_modele				_modele			=(
			
			local id_modele = get_modele_idParam		_modele.id	
			
			if id_modele != 0 then
				m_this.facades_modeles[id_modele] = 	(m_datasMgr.get_datas_string  _modele)
			else
				append	m_this.facades_modeles			(m_datasMgr.get_datas_string  _modele)
			
		),
		fn enregistrer_composant	 		_composant	=(
			
			local id_compo 			= get_composant_idParam		_composant.id		
			
			local string_compo 		= (m_datasMgr.get_datas_string  _composant)
			
			if id_compo != 0 then (
				m_this.facades_composants[id_compo] =	string_compo
			) else (
				append	m_this.facades_composants			string_compo
			)
			
		),
		fn enregistrer_facade				_facade			=(
			
			local sequence_longueur = 0			
			for compo in _facade.sequence do (
				
				sequence_longueur += compo.longueur
				
				for modele in compo.modeles do 
					enregistrer_modele	modele	  
				
				enregistrer_parametrique	compo.param[1]	  
				enregistrer_composant		compo	 		 
			)
			
			m_facade_courante.sequence_longueur = sequence_longueur
			
			local id_compo 		= m_id_courant
			local string_compo 	= (m_datasMgr.get_datas_string  _facade )
			
			if m_id_courant != 0 then
				m_this.facades_items[m_id_courant] = (m_datasMgr.get_datas_string  _facade)
			else
				append	m_this.facades_items		(m_datasMgr.get_datas_string  _facade)
			
		),
		
		
		----------------	 Constructeurs  ...		 	--------------------------------------------------------------------------------------------------------
	private
		---- creer une instance temporaire d'un composant mur plein et la renvois -----
		fn get_nouveauMurPlein					_longueur		 					=(
			local 	nvComposant 	= 	str_facade_composant 	type:#Parametrique
			local 	nvParam 		= 	str_facadeParam_murPlein			()
			nvComposant.param 	= #( nvParam )
			nvComposant.param[1].initialiser 	nvComposant		m_this.construire	
			nvComposant.longueur 	= _longueur
			nvComposant
		),
		---- Creations de base -------
		fn get_nouveauModele					_composant	_node			=(
			
			--- preparation du model -------
			local nd_Tmp 			=  _node
			local transformBack 	=	_node.transform
			positionnerPivot_modele 	nd_Tmp
			nd_Tmp.rotation = quat 0 0 0 1
			nd_Tmp.pos  = [0,0,0]
			
			--- creation de l'objet ----
			local nvModele = 		m_scannerMesh.get_datas 		nd_Tmp			
			if 	_composant.longueur < nvModele.longueur	do
				_composant.longueur = nvModele.longueur			
			nvModele.nom		+=	" " + _composant.modeles.count as string
			_node.transform 	= 		transformBack
			
			--- on le range dans les tableaux -----
			append _composant.modeles				nvModele
			append _composant.modeles_probas 	100
			
			append m_modeles_total	nvModele
			
			
		),
		fn get_nouveauComposant			_pos	 _type	 param_type:	=(	--- param_type: pour creation composant parametrique	--->	#MurPlein	, 	#BaieSimple, 
			debug "creer_composant"
			
			local nvComposant 	= str_facade_composant 	type:_type
			local nvParam
			
			case param_type as name of (
				#MurPlein:			nvParam 	= 	str_facadeParam_murPlein			()		
				#BaieSimple:		nvParam 	= 	str_facadeParam_baieSimple		() 
				#BaieTablette:	nvParam 	= 	str_facadeParam_baie				() 
				#Espacement:		nvParam 	= 	str_facadeParam_espacement	() 
				#Balcon:			nvParam 	= 	str_facadeParam_balcon			() 
				default:				()
			)
			
			--- exceptions -------------
			if nvParam != undefined do (
				nvComposant.param = #( nvParam )
				nvComposant.param[1].initialiser 	nvComposant		m_this.construire	
				append 		m_parametriques_total		nvComposant.param[1]
			)
			
			if param_type as name == #Balcon do (
				
				local nvCompo_balconFin 	= str_facade_composant 	type:_type
				nvCompo_balconFin.param = #( str_facadeParam_balconFin 	() )
				nvCompo_balconFin.param[1].initialiser 	nvCompo_balconFin		m_this.construire	
				
				
				append 		m_parametriques_total		nvCompo_balconFin.param[1]
				
				insertItem 	nvCompo_balconFin 			m_facade_courante.sequence 	( _pos + 1 )			
				append 		m_composants_total	nvCompo_balconFin
				
			)
			
			
			
			
			
			insertItem 	nvComposant 			m_facade_courante.sequence 	( _pos + 1 )			
			append 		m_composants_total	nvComposant
			
			nvComposant
			
		),
		fn get_nouvelleFacade 															=(
			local nvlFacade = str_facade ()
			
			nvlFacade.nom	+=	" " + (m_this.facades_items.count + 1  ) as string
			append m_facades_total	nvlFacade
			nvlFacade
		),
		---- Copie et instanciations -------
		fn get_copieComposant			_idCompoADupliquer	 	 		=(
			
			local composantSource 	= 	m_facade_courante.sequence[_idCompoADupliquer]		

			-- si balcon on degage
			if _idCompoADupliquer == 0 do
				return	0
			
			
			local nvComposant 			=  str_facade_composant 	type:composantSource.type
			debug "nvComposant ETAPE 1" var:nvComposant
			
			
			-- Parametrique ----
			if composantSource.type == #parametrique do (
				local nvParam			
				
				debug "classof composantSource.param" var:(classof composantSource.param)
				
				case classof composantSource.param[1]  of (
					str_facadeParam_murPlein:		nvParam 	= 	str_facadeParam_murPlein			()		
					str_facadeParam_baieSimple:		nvParam 	= 	str_facadeParam_baieSimple		() 
					str_facadeParam_baie:				nvParam 	= 	str_facadeParam_baie				() 
					str_facadeParam_espacement:	nvParam 	= 	str_facadeParam_espacement	() 
					str_facadeParam_balcon:			nvParam 	= 	str_facadeParam_balcon			() 
					default:									()
				)
			debug "nvComposant ETAPE 2" var:nvComposant
				debug "nvParam DUPLICATE 1" var:nvParam
				if nvParam != undefined do (
					-- copier les params
					local params_aCopier = getPropNames composantSource.param[1]
					for nomProp in params_aCopier do (
						local prop = ( getProperty  composantSource.param[1] 	nomProp )
						case classof prop of (
							MAXScriptFunction:	()
							default:					setProperty nvParam  nomProp	 (copy  prop)
						)
					)
					nvComposant.param = #( nvParam )
					debug "nvComposant DUPLICATE 2" var:nvComposant
					nvComposant.param[1].initialiser 	nvComposant		m_this.construire	
					
					debug "nvComposant DUPLICATE 3" var:nvComposant
					append 		m_parametriques_total		nvComposant.param[1]
					debug "nvComposant DUPLICATE 4" var:nvComposant
					
					debug "nvComposant DUPLICATE 5" var:nvComposant
				)
			debug "nvComposant ETAPE 6" var:nvComposant
			)
			debug "nvComposant ETAPE FIN" var:nvComposant
			
			
			
			
			-- copie des proprietes du composant
			nvComposant.nom 			=	/* copy */ composantSource.nom	
			nvComposant.longueur		=	/* copy */ composantSource.longueur
			nvComposant.hauteur		= 	/* copy */ composantSource.hauteur
			
			
			
			insertItem 	nvComposant 			m_facade_courante.sequence 	( _idCompoADupliquer + 1 )			
			append 		m_composants_total	nvComposant
			
			nvComposant
			
			
		),
		fn get_copieFacade 				_id									=(
			
			local facadesource 	= 	m_facades_total[_id]
			local nvlFacade 		= 	str_facade ()
			local stringFacade 	= 	m_datasMgr.get_datas_string 	facadesource 
			m_datasMgr.set_datas_string		stringFacade		nvlFacade	
			
			nvlFacade.nom	+=	" " + (m_this.facades_items.count + 1  ) as string
			
			append m_facades_total	nvlFacade
			nvlFacade
		),
		---- Suppressions -------
		fn supprimer_facade				_id			 						=(
			
			local facadeAVirer = m_facades_total[_id]
			
			for compo in facadeAVirer.sequence do
				supprimer_composant	compo
			
			/* 
			------ Parametriques -------
			m_parametriques_total				= #()
			for strg_param in m_this.facades_parametriques 	do (
				local nvParam 					
				local idStrg 		= findstring 	strg_param		"#FAC_P"
				local type	 		= substring 	strg_param 	(idStrg+6)	  2 
				case type of (
					"MP": 		nvParam = str_facadeParam_murPlein ()
					"BS":		nvParam = str_facadeParam_baieSimple ()
					"BT":		nvParam = str_facadeParam_baie ()
					"ES":		nvParam = str_facadeParam_espacement ()
					"BD":		nvParam = str_facadeParam_balcon ()
					"BF":		nvParam = str_facadeParam_balconFin ()
				)
				m_datasMgr.set_datas_string			strg_param		nvParam		
				append m_parametriques_total 		nvParam
			)
			
			
			------ Composants -------
			m_composants_total		= #()
			for compo in m_this.facades_composants 	do (
				local nvCompo =   str_facade_composant ()
				m_datasMgr.set_datas_string		compo		nvCompo	
				append m_composants_total 		nvCompo
				if nvCompo.type == #parametrique do
					nvCompo.param[1].actualiser 	nvCompo		m_construire
			)
			
			
			*/
			
			deleteItem 	m_facades_total 			_id
			deleteItem 	m_this.facades_items	_id
			
		),
		
		
		----------------	 INTERFACE			 	--------------------------------------------------------------------------------------------------------
	public
		
		---- Actualiser -----
		fn actualiser =(
			params_toStructs 	()
		),
		fn valider_modifs =(
			enregistrer_facade  	m_facade_courante
			m_construire.batiment ()
			m_this.actualiser_rollouts ()
		),
		
		---- Accessions -----
		fn get_facades_noms 	=	for comp in m_facades_total  collect comp.nom,
		fn get_facades_count 	=	m_facades_total.count,
		fn get_facades			=	m_facades_total,		
		fn get_modeles  			=	m_modeles_total,
		---- Get universelle 	----
		fn get_parametre			_iUnique		 =(
			
			---- un composant ------------
			local elemTmp =  ( get_composant  _iUnique 		)	
			
			---- un modele ------------
			if elemTmp == undefined do 
				elemTmp = ( get_modele  _iUnique 		)	
			
			---- un parametrique ------------
			if elemTmp == undefined do 
				elemTmp = ( get_parametrique  _iUnique 		)	
			
			elemTmp
		),
		---- Creations -----
		fn creer_murPlein			_long									= get_nouveauMurPlein	_long,
		fn creer_modele			_composant	_nodeSource	= get_nouveauModele			_composant	_nodeSource,
		fn creer_composant		_pos	 _type	 param_type:	= get_nouveauComposant		_pos	 			_type	 			param_type:param_type,
		fn creer_facade													= get_nouvelleFacade (),
		---- Duplications -----
		fn dupliquer_facade 			_id	= get_copieFacade 			_id,
		fn dupliquer_composant 	_id	= get_copieComposant 	_id,
		
		
		
		
		
		----------------	 FENETRE				 	----------------------------------------------------
	public
		fn est_ouvert = m_dialog_estOuvert,
		fn fermer 						quiet:false	=(
			
			-- on demande si on veut enregistrer ----
			if not quiet do if queryBox "Enregistrer les modifications ?"	title:"Urba | Bâtiment | Façade" 	do 
					enregistrer_facade 	 m_facade_courante		
			
			--- Actiualiser position de la fenetre ----
			if m_dialog_estOuvert do
				m_dialog_pos = getDialogPos m_dialog	
			m_dialog_estOuvert = false
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		),
		fn ouvrir  			_id 		=(
			
			m_id_courant 			= _id
			m_facade_courante 	= str_facade ()
			m_facade_courante 	= m_facades_total[_id]	--m_datasMgr.set_datas_string 		m_this.facades_items[m_id_courant]  	 m_facade_courante		m_this
			
			
			include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout facade.ms"
			m_dialog = roll_urba_editeurFacades
			
			---- creation de la fenetre ----
			createDialog m_dialog 	style:				#(#style_resizing) 	\
										pos:				m_dialog_pos
-- 										lockHeight:		true						\
-- 										lockWidth:		true						\
			m_dialog_estOuvert = true
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			
			m_dialog.m_facade 	= m_facade_courante
			
			m_dialog.initialiser ()
			
		)
		
		
		
		
		
		
) ---------- fin struct FACADES ----------------------

















