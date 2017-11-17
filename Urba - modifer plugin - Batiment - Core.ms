

include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures secondaires.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Geometrie.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Construction.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Surfaces.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Elements.ms"






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
		
		---  Rollouts flottants -------------------
		roll_facades 		= 	filein	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollout facade.ms",
		roll_facades_pos		= [500,500],
		roll_facades_taille	= [500,300],
		
		--- Sous structures  -------------------
		m_construction	= str_construction 	(),
		
		
		----- Ecouteurs	----------------------
		m_ecouteur_surface_handler,
		
		
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
	private
	----- Actions sur le node -----------------------
		fn centrer_pivot 		_node	=(
		
			_node.transform = (matrix3 1)
			ResetPivot 			_node
			
			---- centrer le pivot ----
			local pt_sommeDesPts = 0
			for pt in _node.surface_points do
				pt_sommeDesPts += pt
			local pt_centre = pt_sommeDesPts / _node.surface_points.count
			_node.pos = pt_centre
			
		),
		
		
		
	private
	---- Parametres --------------------
		fn charger =(
			
			--- les facades --------
			for id in m_plug.fac_ids do (
				nvFacade = mgr_facades.creer()
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
		
		/* 
	---- Ecouteurs -----------------
		fn activer_ecouteurs 	_nodeTHIS	=(			
-- 			m_ecouteur_surface_handler = when geometry m_plug.surface_node	 changes 	 do 
-- 														_nodeTHIS.actualiser () 
		),
		fn desactiver_ecouteurs =(
-- 			deleteChangeHandler m_ecouteur_surface_handler			
		),
		
		fn surface_changed =(
			
		), */
		
	----- Editeur de facades -----------------
		fn ouvrir_facadeEditeur 	_index	=(
			debug "ouvrir_facadeEditeur"
			createDialog 	roll_facades	style:				#(#style_resizing) 	\
													pos:					roll_facades_pos		\
													width:				roll_facades_taille.x	\
													height:				roll_facades_taille.y	
			
			roll_facades.initialiser 		m_plug
			roll_facades.set_facade 	( mgr_facades.get_parIndex	_index )
			
		),
		fn fermer_facadeEditeur 		=(
			destroyDialog 	roll_facades
		),
		
		
		
	----- Parametres du plug -----------------------
		--- lire/ecrire -------------
		fn lire_params 	=(),
		fn ecrire_params	=(),
		
		--- Gestion ---------------
		fn creer_facade =(
			local nv_facade 	= mgr_facades.creer ()
			nv_facade
		),
		
		
	----- Accessions -----------------------
		fn get_facades_noms =mgr_facades.get_noms (),
		
		fn choisir_surface 	_nodeTHIS		_shape 		=(
			
			_nodeTHIS.transform = _shape.transform
			
-- 			activer_ecouteurs 	_nodeTHIS	
			
			actualiser ()
			
		)
		
		
		
)  ---- fin batiment core -------------------------












