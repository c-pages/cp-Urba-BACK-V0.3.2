

include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures secondaires.ms"
include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Geometrie.ms"
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
		m_geometrie	= str_geometrie 	(),
		
		---- tracé initial -------------------
		logo = #(	[14.1994,37.717,0], 	[14.1994,-189.586,0], 	[287.927,-189.586,0], 	[287.927,139.601,0], 	[174.501,253.027,0], [174.501,479.879,0], [61.0754,479.879,0], [61.0754,366.453,0], \
						[-52.3504,479.879,0], 	[-392.628,139.601,0], 	[-392.628,-189.586,0],	[-118.9,-189.586,0], 	[-118.9,37.717,0]),
	
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
	private
		fn contruire =(
			---- on clean le modele ----
			m_geometrie.vider ()
			
		),
		fn creer_logo =(
			
			debug "logo_creer"
			m_geometrie.face	logo
			
		),
		
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	public	
	----- Initialisation  -----------------------
		fn initialiser 	_plug		doLogo:false	= (
			
			debug "initialiser"
			
			---- initialisation des structures -----
			m_plug = 	_plug			
			mgr_facades.initialiser		class:str_facade
			m_geometrie.initialiser		_plug
			mgr_surfaces.initialiser		_plug
			
			---- creation du logo si besoin -----
			if doLogo do creer_logo ()
			
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
		
	----- Geometrie -----------------------
		fn actualiser =(
			
			---- on actualise ----
			mgr_surfaces.actualiser ()
			
			---- on consrtuit ----
			contruire ()
			
		)
		
		
)  ---- fin batiment core -------------------------












