

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
		mgr_surfaces			= str_surfaces (),
		
		---  Rollouts flottants -------------------
		roll_facades,
		
		--- Sous structures  -------------------
		m_construction	= str_construction 	(),
		
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
		
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	public	
	----- Initialisation  -----------------------
		fn initialiser 	_plug		= (
			
			debug "initialiser"
			
			---- initialisation des structures -----
			m_plug = 	_plug			
			mgr_facades.initialiser		class:str_facade
			mgr_surfaces.initialiser		_plug
			m_construction.initialiser	_plug
			
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
		
		
		
	----- Actualiser  -----------------------
		fn actualiser =(
			
			---- on actualise la surface ----
			mgr_surfaces.actualiser ()
			
			---- on consrtuit ----
			m_construction.actualiser ()
			
		),
		fn choisir_surface 	_nodeTHIS		_shape 		=(
			
			_nodeTHIS.transform = _shape.transform
			
			actualiser ()
			
		)
		
		
		
)  ---- fin batiment core -------------------------












