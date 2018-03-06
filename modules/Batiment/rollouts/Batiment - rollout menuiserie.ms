(


	--- les rollout du composant	---------
	rollout rollout_menuiserie "Menuiserie" width:200 height:419
	(
		
		
			local m_plug
		
			local m_menuiserie
		
				---- golbal --------------
		label 'lbl19' "Longeur:" pos:[11,42] width:49 height:13 align:#left
		spinner 'spn_longueur' "" pos:[116,42] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		GroupBox 'grp1' "Global" pos:[6,7] width:187 height:59 align:#left
			
		dropdownList 'ddl_type' "" pos:[76,23] width:111 height:21 align:#left
		label 'lbl51' "Type :" pos:[11,25] width:49 height:13 align:#left
			
			---- traverses --------
			
-- 		??? 'cust1' "???" pos:[11,90] width:171 height:313 align:#left
		subRollout 'subroll_parametres' "Paramètres" pos:[5,71] width:187 height:338 align:#left

			/* 
				---- golbal --------------
			label 'lbl19' "Longeur:" pos:[11,42] width:49 height:13 align:#left
			spinner 'spn_longueur' "" pos:[116,42] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
			GroupBox 'grp1' "Global" pos:[6,7] width:187 height:77 align:#left
			
			dropdownList 'ddl_type' "" pos:[76,23] width:111 height:21 align:#left
			label 'lbl_allege' "Allège pleine:" pos:[11,58] width:89 height:13 align:#left
			spinner 'spn_allege' "" pos:[116,58] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
			label 'lbl51' "Type :" pos:[11,25] width:49 height:13 align:#left
			
			---- traverses --------
			label 'lbl_hauteur' "Hauteur:" pos:[11,107] width:49 height:13 align:#left
			spinner 'spn_hauteur' "" pos:[116,107] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
			GroupBox 'grp_ouvrant' "Ouvrant" pos:[5,89] width:187 height:133 align:#left
			label 'lbl_ouvert_proba' "Probabilité (%) :" pos:[22,162] width:80 height:13 align:#left
			spinner 'spn_ouvert_proba' "" pos:[105,162] width:70 height:16 range:[0,100,0] scale:1 align:#left
			label 'lbl_ouvert_max' "Maximum (%) :" pos:[22,192] width:80 height:13 align:#left
			spinner 'spn_ouvert_max' "" pos:[105,192] width:70 height:16 range:[0,100,0] scale:1 align:#left
			label 'lbl_ouvert_min' "Minimum (%) :" pos:[22,177] width:80 height:13 align:#left
			spinner 'spn_ouvert_min' "" pos:[105,177] width:70 height:16 range:[0,100,0] scale:1 align:#left
			label 'lbl_sens' "Sens :" pos:[11,126] width:49 height:13 align:#left
			dropdownList 'ddl_ouverture_sens' "" pos:[76,123] width:111 height:21 items:#("Auto", "Droite", "Gauche", "Vers le haut", "Vers le bas") align:#left
			
			GroupBox 'grp_ouverture' "Ouverture" pos:[12,147] width:169 height:66 align:#left
 */
			
			
-- 			local btns_ouverture 	= #( lbl_hauteur, spn_hauteur, grp_ouverture, grp_ouvrant, lbl_ouvert_proba, spn_ouvert_proba, lbl_ouvert_max, spn_ouvert_max, lbl_ouvert_min, spn_ouvert_min, lbl_sens, ddl_ouverture_sens)
-- 			local	 liste_types 		= #( #Fixe, #Fenêtre, #PortePleine, #PorteVitree, #Porte_garage )
			
			fn actualiser =(
				
				local menuis_types 			= m_plug.core.get_menuiserie_constructeursTypes ()
				ddl_type.selection 				= findItem  menuis_types		m_menuiserie.type  
				
				spn_longueur.value			=	m_menuiserie.params.longueur
				
				--- le subRollout des composants	-------
				for rollAVirer in subroll_parametres.rollouts do
					removeSubRollout	subroll_parametres	rollAVirer
				if m_menuiserie != undefined do (
					local menuis_dialog = m_menuiserie.get_dialog ()
					addSubRollout	subroll_parametres 	menuis_dialog
					menuis_dialog.initialiser	 	m_plug
					menuis_dialog.set_menuiserie	m_menuiserie
				)
				
				
			)
			fn initialiser	_plug		=(
				m_plug 			= _plug
				ddl_type.items 	= m_plug.core.get_menuiserie_constructeursNoms ()
			)
			
			fn redimensionnerFenetre 		_taille 	=(
				rollout_menuiserie.width 		= 200
				subroll_parametres.height 		= _taille.y - ( subroll_parametres.pos.y + 9 )
				
				
			)
			fn set_menuiserie _menuis =(
				m_menuiserie	=	_menuis
				actualiser ()
			)
			
			
		
		on rollout_menuiserie resized _taille 				do
			redimensionnerFenetre 	_taille
		on spn_longueur changed val  		do
			m_menuiserie.longueur = val
	)
	
	rollout_menuiserie
)







