

include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures secondaires.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Geometrie.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Construction.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Managers.ms"




struct str_batiment_core (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba | Batiment CORE",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	
	
	-------- MEMBRES	--------------------------------------------------------------------------------------------------------
	public
		m_plug,
	
	
	
	private
		---  Managers des Eléments du batiments -------------------
		mgr_facades			= str_mgr_facades (),
		mgr_composants 	= str_mgr_composants (),
		mgr_surface			= str_mgr_surfaces (),
		mgr_toitures			= str_mgr_toitures (),
		
		---- convertisseur Parametres to String  -------------
		mgr_datas 				= str_datasToString 	m_prt:this,
		
		---  Rollouts Facade -------------------
		roll_facades 				= 	filein	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout facade.ms",
		roll_facades_pos		= [500,500],
		roll_facades_taille		= [500,300],
		
		--- Sous structures  -------------------
		m_construction		= str_construction 	(),
		
		
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
		
		
	private
	---- Parametres --------------------
		fn charger =(
			
			debug "charger"
			
			--- les facades --------
			mgr_facades.charger ()
			
			
		),
		
		
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	public	
		
	----- Actualiser  -----------------------
		fn actualiser =(
			
			---- on actualise la surface ----
			mgr_surface.actualiser ()
			
			---- on consrtuit ----
			m_construction.actualiser ()
			
		),
		
		
	----- Initialisation  -----------------------
		fn initialiser 	_plug		= (
			
			debug "initialiser"
			
			m_plug = 	_plug			
			
			---- initialisation des structures -----
			mgr_surface.initialiser			m_plug
			mgr_facades.initialiser			class:str_facade		plug:m_plug
			mgr_composants.initialiser		m_plug
			mgr_toitures.initialiser			m_plug
			m_construction.initialiser		m_plug
			
			--- chargement des parametres ------------------
			charger ()
			
		),
		
	----- Editeur de facades -----------------
		fn get_facadeEditeur_rollout = roll_facades,
		fn facadeEditeur_ouvrir 	_index	=(
			debug "ouvrir_facadeEditeur"
			createDialog 	roll_facades	style:				#(#style_resizing) 	\
													pos:					roll_facades_pos		\
													width:				roll_facades_taille.x	\
													height:				roll_facades_taille.y	/* \
													modal:				true \ 
													escapeEnable:	true */
			
			roll_facades.initialiser 		m_plug
			roll_facades.set_facade 	( mgr_facades.get_parIndex	_index )
			
		),
		fn facadeEditeur_fermer 			=(
			destroyDialog 	roll_facades
		),
		
		
	--- manager les facades	---------------
		fn creer_facade 							=(
			local nv_facade 	= mgr_facades.creer ()
			nv_facade
		),
		fn supprimer_facade		_index =(
			local facadeASupprimer = mgr_facades.get_parIndex		_index
			local confirmation = querybox ( "Supprimer "  + facadeASupprimer.nom + " ?" )
			if confirmation do (
				mgr_facades.supprimer		facadeASupprimer.id
			)
			m_plug.actualiser_rollouts ()
			
			actualiser ()
		),
		
		fn creer_composant		_facade		_IDmodelCompo			=(
			local nv_composant 	= mgr_composants.creer		_IDmodelCompo
			
			_facade.ajouter_composant	nv_composant
			
			--- maj de la longueur de la sequence ---
			_facade.update_sequence_longueur ()
			
			nv_composant
		),
		
		
	----- Accessions -----------------------
		fn get_surface_points		=	mgr_surface.get_points	(),
		
		fn get_facades_noms 		=	mgr_facades.get_noms (),
		fn get_facades					=	mgr_facades.get_items (),
		
		fn get_construction			= m_construction,
		fn get_geo						= m_construction.m_geo,
		fn get_matID					= m_construction.m_matID,
			
		fn get_mgr_composants 	= mgr_composants,
		fn get_mgr_facades	 		= mgr_facades,
		fn get_mgrDatas 				= mgr_datas,
		
	---- mutateurs	------
		fn set_roll_editeurDeFacade_position	_pos 	=( roll_facades_pos = _pos),
		fn set_roll_editeurDeFacade_taille		_taille 	=( roll_facades_taille = _taille),
		
	----- Surface ---------------------
		fn assigner_surface 		_nodeTHIS		_shape 		=(
			
			_nodeTHIS.transform = _shape.transform
			mgr_surface.assigner		_shape
			
			actualiser ()
			
		)
		
		
		
)  ---- fin batiment core -------------------------












