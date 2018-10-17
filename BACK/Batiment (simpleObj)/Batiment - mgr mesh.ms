struct str_mgr_mesh (
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
-- 	m_debug = true,
	m_debug = false,
	m_dbgPrefix ="str_mgr_mesh",
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix,
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	fn transformer		_mesh	_transf	=(
		if classof _transf == point3 do _transf = transMatrix _transf
		local transf_tab =#()
		for id_pt = 1 to   _mesh.numverts  do (
			local pos_base 	=  meshop.getVert  _mesh 	id_pt
			local pos_dest 	= pos_base * _transf
			append transf_tab ( pos_dest - pos_base)
		)
		meshop.moveVert 	_mesh	#{1.._mesh.numverts} transf_tab
	),
	fn attacher		_mesh		_composant		transf:	=(
		debug "attacher"
		if classof _composant != trimesh do  _composant = _composant.mesh
		local compo_mesh	=	copy _composant
		if transf != unsupplied do	transformer				compo_mesh		transf
			
		if _mesh.verts.count == 0 then
			_mesh + compo_mesh
		else
			meshop.attach		_mesh		compo_mesh
	)
	
)