
	
	
	
	

rollout roll_urba_editeurToiture "Urba - Editeur de toiture" width:453 height:294
(
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =(
			local m_debug = true
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:"urba | roll_urba_editeurToiture"
			catch ()
		)
		
		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_plug				---- pointeur vers le plug ----
		
		local m_toiture
		local m_changement = false
		
		--- rollout	---------	
		local largeur_params		= 	235
		local largeur_min 				= 	490
		local hauteur_min 			= 	300
		
		------------  UI	----------------------------------------------------------------------------------		
		
	edittext 'edt_nom_toiture' "" pos:[7,12] width:200 height:16 align:#left
	button 'btn_enregistrer' "S" pos:[224,11] width:19 height:19 toolTip:"Sauvegarder preset." align:#left
	button 'btn_charger' "O" pos:[206,11] width:19 height:19 toolTip:"Ouvrir preset." align:#left
	subRollout 'subroll_parametres' "Parametres" pos:[24,63] width:210 height:208 align:#left
	GroupBox 'grp_prop' "Propriétés" pos:[12,45] width:232 height:238 align:#left
	listBox 'lbx4_elements' "" pos:[260,65] width:171 height:16 align:#left
	button 'btn_ajouter_element' "+" pos:[261,46] width:18 height:18 align:#left
		
		------------  Fonctions	----------------------------------------------------------------------------------
		
		fn actualiser 							=(
			debug "actualiser ()"
			
			--- le subRollout des composants	-------
			for rollAVirer in subroll_parametres.rollouts do
				removeSubRollout	subroll_parametres	rollAVirer
			if m_toiture != undefined do (
				local toiture_subRoll = m_toiture.get_dialog () 
				addSubRollout	subroll_parametres 	toiture_subRoll
				toiture_subRoll.mgr_toiture = m_plug.core.get_mgr_toiture ()
				m_toiture.initialiser_dialog	 		m_plug  
				
			) 
		)
		fn redimensionnerFenetre 		_taille 	=(
		
		)
		fn initialiser 			_plug 		=(
			
			m_plug 		= _plug
			
			-- la fenetre ----
			redimensionnerFenetre  (getDialogSize	roll_urba_editeurToiture)
			
		)
		
		fn set_toiture	_toiture =(
			m_toiture  = _toiture
			actualiser ()
		)
		
		
		
		
	----------------- Evenements ------------------------------------------------------------------------
	
	
	button 'btn16' "-" pos:[278,46] width:18 height:18 align:#left
)
	
	
	
	
	
	
	
	
	