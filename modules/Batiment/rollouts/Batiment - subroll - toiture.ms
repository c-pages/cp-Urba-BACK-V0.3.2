
rollout sub_toiture "" width:557 height:427
(

	local m_rolloutP
	local m_core
	local m_plug
	local 	m_bat
	
	edittext 'edt1' "" pos:[5,-1] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,-1] width:18 height:18 align:#left
	label 'lbl_appliquerA' "Type :" pos:[10,20] width:32 height:15 align:#left
					
	dropdownList 'ddl_murs' "" pos:[75,18] width:170 height:21 selection:3 align:#left
	
	subRollout 'subroll_parametres' "Parametres" pos:[20,62] width:205 height:209 align:#left
	GroupBox 'grp_prop' "Propriétés" pos:[10,44] width:235 height:238 align:#left
	
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
	)
	

	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	/* 
	fn changer_taille_rollout 	_taille	=(
		
	) */
	 
		
)