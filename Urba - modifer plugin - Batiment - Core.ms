

include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures secondaires.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Geometrie.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Surfaces.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Elements.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Construction.ms"






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
		---  Elément du batiments -------------------
		mgr_facades			= str_mgr_arrayParametres (),
		mgr_surface			= str_surfaces (),
		
		---  Rollouts Facade -------------------
		roll_facades 			= 	filein	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout facade.ms",
		roll_facades_pos	= [500,500],
		roll_facades_taille	= [500,300],
		
		--- Sous structures  -------------------
		m_construction		= str_construction 	(),
		
		
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
		
		
	private
	---- Parametres --------------------
		fn charger =(
			
			debug "charger"
			
			--- les facades --------
			for id in m_plug.fac_ids do (
				debug "charger" var:id
				nvFacade = mgr_facades.creer	enregistrer:false
				nvFacade.charger 	m_plug		id
			)
			
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
			mgr_facades.initialiser		class:str_facade	plug:m_plug
			mgr_surface.initialiser		m_plug
			m_construction.initialiser	m_plug
			
			--- chargement des parametres ------------------
			charger ()
			
			
		),
		
	----- Editeur de facades -----------------
		fn facadeEditeur_ouvrir 	_index	=(
			debug "ouvrir_facadeEditeur"
			createDialog 	roll_facades	style:				#(#style_resizing) 	\
													pos:					roll_facades_pos		\
													width:				roll_facades_taille.x	\
													height:				roll_facades_taille.y	
			
			roll_facades.initialiser 		m_plug
			roll_facades.set_facade 	( mgr_facades.get_parIndex	_index )
			
		),
		fn facadeEditeur_fermer 			=(
			destroyDialog 	roll_facades
		),
		fn creer_facade 							=(
			local nv_facade 	= mgr_facades.creer ()
			
			facadeEditeur_ouvrir	 	( mgr_facades.get_items () ).count
			
			nv_facade
		),
		
		
	----- Accessions -----------------------
		fn get_surface_points		=	mgr_surface.get_points	(),
		
		fn get_facades_noms 	=	mgr_facades.get_noms (),
		fn get_facades				=	mgr_facades.get_items (),
		
		fn get_construction		= m_construction,
		fn get_geo					= m_construction.m_geo,
		fn get_matID				= m_construction.m_matID,
		
		
	----- Surface ---------------------
		fn assigner_surface 		_nodeTHIS		_shape 		=(
			
			_nodeTHIS.transform = _shape.transform
			mgr_surface.assigner		_shape
			
			actualiser ()
			
		)
		
		
		
)  ---- fin batiment core -------------------------












