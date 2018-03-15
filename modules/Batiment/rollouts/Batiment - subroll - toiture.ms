
rollout sub_toiture "" width:557 height:427
(

	local m_rolloutP
	local m_core
	local m_plug
	local m_bat
	
	edittext 'edt1' "" pos:[5,-1] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,-1] width:18 height:18 align:#left
	label 'lbl_appliquerA' "Type :" pos:[10,20] width:32 height:15 align:#left
					
	dropdownList 'ddl_toiture' "" pos:[75,18] width:170 height:21 selection:3 align:#left
	
	subRollout 'subroll_parametres' "Parametres" pos:[10,41] width:235 height:209 align:#left
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		local index_toiture 	= m_bat.get_toiture_index		m_core	
		ddl_toiture.selection 	= 	index_toiture
		
		local dialog_toiture = m_bat.toiture.get_dialog ()		
		for x in subroll_parametres.rollouts do removeSubRollout subroll_parametres x
		addSubRollout subroll_parametres 	dialog_toiture
		
		dialog_toiture.m_compo		= m_bat.toiture		
		dialog_toiture.m_rolloutP	= m_rolloutP
		dialog_toiture.m_plug		= m_plug
		dialog_toiture.actualiser ()
		
-- 		btn_editer_toiture.enabled = mgr_toiture.a_desParametres		()
		
		
		
	)
	

	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
		
		local mgr_toiture 			= m_core.get_mgr_toiture ()
		local models_toiture 		= mgr_toiture.get_constructeurs ()
		ddl_toiture.items 		=  ( for  model in models_toiture collect model.nom )
	)
	/* 
	fn changer_taille_rollout 	_taille	=(
		
	) */
	 
	on ddl_toiture selected _val do
	(
			
			
			local nvl_toiture 			=	m_core.creer_toiture		_val
			
			
			m_bat.toiture = nvl_toiture
			
			m_rolloutP.changer_un_truc ()
			
			actualiser ()
		)
)

















