


filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Menuiserie base\\Batiment - Menuiserie base - Cadre.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Menuiserie base\\Batiment - Menuiserie base - Chassis.ms"

	
struct str_mgr_menuiseries	(
	
	
	
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
	-- 	m_debug = false,
		m_dbgPrefix ="str_contruction_base",
		fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix,
		------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
		--------- TRANSFORMATION   ------------------------------------------------------------------------------------------------------
		fn transform_vertex		_mesh		transf:	=(
			if classof transf == point3 do transf = transMatrix transf
			local transf_tab =#()
			for id_pt = 1 to   _mesh.numverts  do (
				local pos_base 	=  meshop.getVert  _mesh 	id_pt
				local pos_dest 	= pos_base * transf
				append transf_tab ( pos_dest - pos_base)
			)
			meshop.moveVert 	_mesh	#{1.._mesh.numverts} transf_tab
		)
	
)	----	fin struct	str_mgr_primitives --------------------




