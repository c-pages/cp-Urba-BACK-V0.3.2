
rollout sub_materiaux "" width:255 height:427
(


	local m_rolloutP
	local m_core
	local m_plug
	
	edittext 'edt1' "" pos:[5,0] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,0] width:18 height:18 align:#left
	
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
	)
	
	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	
	--- Global ------
-- 	GroupBox 'grp_global' "Murs :" pos:[10,56] width:235 height:245 align:#left
	
	/* 
	
	fn changer_taille_rollout 	_taille	=(
		
	)
	  */

)
