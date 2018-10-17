


----- primitives ---------------------
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Batiment - mgr primitives.ms"

----- Menuiserie base ----------------
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Batiment - mgr mesh.ms"

--- Composants -----------
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Menuiseries\\Composants\\Menuiserie - Composant - Poignée.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Menuiseries\\Composants\\Menuiserie - Composant - Cadre.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Menuiseries\\Composants\\Menuiserie - Composant - Panneau.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Menuiseries\\Composants\\Menuiserie - Composant - Chassis vitré.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Menuiseries\\Composants\\Menuiserie - Composant - Meneau.ms"

struct str_mgr_menuiseries_composants	(
	
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
	-- 	m_debug = false,
		m_dbgPrefix ="str_contruction_base",
		fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix,
		------------ DEBUG	----------------------------------------------------------------------------------
		
		--- le manager de primitives---------------	
		mgr_prim	=	str_mgr_primitives (),
		

		
		fn transformer		_mesh		_transf	=	mgr_prim.transformer		_mesh		transf:_transf,
		
		
		
		fn get_chassis	=	(
			local nv_chassis	 = createInstance  menuiserie_composant_chassis		
			nv_chassis
		),
		fn get_cadre =(
			local nv_chassis	 = createInstance  menuiserie_composant_cadre
			nv_chassis
		)
	
)	----	fin struct	str_mgr_primitives --------------------




