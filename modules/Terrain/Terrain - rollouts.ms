




rollout roll_terrain_global "Terrain" width:161 height:259
(
	
	local m_plug
	local m_core
	
	fn shape_filt 		obj = superclassof obj == shape
	fn geo_filt 			obj = superclassof obj == GeometryClass
	
	pickbutton 'btn_pick_relief' "Pick node" pos:[10,38] width:115 height:20 filter:geo_filt autoDisplay:true align:#left
	pickbutton 'btn_trace_pick' "Pick shape" pos:[13,213] width:125 height:20 filter:shape_filt autoDisplay:true align:#left
	spinner 'spn_precision' "" pos:[72,60] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
	label 'lbl_precision' "Précision:" pos:[15,59] width:44 height:14 align:#left
	GroupBox 'grp_global' "Global" pos:[5,4] width:151 height:115 align:#left
	GroupBox 'grp_trace' "Tracés" pos:[5,121] width:151 height:133 align:#left
	checkbox 'chk_trace_invert' "Invert" pos:[14,234] width:75 height:14 align:#left
	pickbutton 'btn_pick_cadre' "Pick shape" pos:[10,93] width:115 height:20 filter:shape_filt autoDisplay:true align:#left
	label 'lbl_cadre' "Cadre :" pos:[15,79] width:34 height:14 align:#left
	label 'lbl_relief' "Relief:" pos:[15,23] width:42 height:14 align:#left
	listbox 'lbx_traces' "" pos:[14,154] width:123 height:4 align:#left
	button 'btn_trace_ajouter' "+" pos:[14,137] width:16 height:16 align:#left
	button 'btn_trace_supprimer' "-" pos:[30,137] width:16 height:16 align:#left
	button 'btn_relief_select' "Sel" pos:[126,38] width:20 height:20 toolTip:"Selectionner" align:#left

	button 'btn_cadre_select' "Sel" pos:[127,93] width:20 height:20 toolTip:"Selectionner" align:#left
	
	fn actualiser =(
		
		format "inDialog  :%\n" roll_terrain_global.inDialog  
		
		
		if  roll_terrain_global.inDialog  then (			
			
			spn_precision.value 		= m_plug.relief_precision
			btn_pick_relief.object 	= m_plug.relief_node
			btn_pick_cadre.object 	= m_plug.cadre_shape
			
		) else (
			
			if m_plug.core.editeur_rollout_estOuvert () do (				
				local editeur  = m_plug.core.get_editeur_rollout ()				
				editeur.actualiser ()
			)
		)
		
	)
		
	fn initialiser   =(
		
		m_plug = undefined
		m_core = undefined
		for obj in helpers where classof obj as string == "Urba_terrain_mgr" do (
			m_plug = obj
			m_core = obj.core
		)
		format "get_terrain_mgr	--->	m_plug:% \n" m_plug
		
	)
	
	
	
	
	on roll_terrain_global open do
	(
			
			initialiser ()
			
			actualiser ()
		)
	on btn_pick_relief picked obj do
	(
			m_plug.relief_node = obj
			m_plug.actualiser ()
			actualiser ()
		)
	on btn_trace_pick picked obj do
	(
		
		)
	on spn_precision changed val do
	(
			m_plug.relief_precision = val
			m_plug.actualiser ()
			actualiser ()
		)
	on chk_trace_invert changed state do
	(
		
		)
	on btn_pick_cadre picked obj do
	(
			m_plug.cadre_shape = obj
			m_plug.actualiser ()
			actualiser ()
		
		)
	on lbx_traces selected sel do
	(
		
		)
	on lbx_traces doubleClicked sel do
	(
		
		)
	on btn_trace_ajouter pressed do
	(
		
		)
	on btn_trace_supprimer pressed do
	(
		
		)
)


-- roll_terrain_global

