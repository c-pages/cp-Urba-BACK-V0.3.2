(


	--- les rollout du composant	---------
	rollout rollout_menuiserie "Menuiserie" width:203 height:233 (
		
		
			local m_rollPrt
			local m_compo
			local m_plug
			local m_menuiserie
			
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

			
			
			local btns_ouverture = #( lbl_hauteur, spn_hauteur, grp_ouverture, grp_ouvrant, lbl_ouvert_proba, spn_ouvert_proba, lbl_ouvert_max, spn_ouvert_max, lbl_ouvert_min, spn_ouvert_min, lbl_sens, ddl_ouverture_sens)
			local	 liste_types = #( "Fixe", "Fenêtre", "Porte pleine", "Porte vitrée", "Porte de garage" )
			
			fn actualiser =(
				local indexTypeTmp = findItem  liste_types	m_menuiserie.type  
				format "m_menuiserie.type  : %\n"  m_menuiserie.type 
				format "indexTypeTmp : %\n"  indexTypeTmp
				ddl_type.selection = indexTypeTmp
				
				if ddl_type.selection == 1 then
					rollout_menuiserie.height		=	90
				else 
					rollout_menuiserie.height		=	233
				
				btns_ouverture.enabled 	= ddl_type.selection != 1
				
				
				spn_hauteur.indeterminate 		= not ddl_type.selection != 1
				spn_ouvert_proba.indeterminate	= not ddl_type.selection != 1
				spn_ouvert_max.indeterminate 	= not ddl_type.selection != 1
				spn_ouvert_min.indeterminate 	= not ddl_type.selection != 1
				
				spn_longueur.value			=	m_menuiserie.longueur
				spn_allege.value				=	m_menuiserie.allege_ht
				
				if ddl_type.selection != 1 do (
					spn_hauteur.value 		= m_menuiserie.ouvrant_ht
					spn_ouvert_proba.value	= m_menuiserie.ouvert_proba
					spn_ouvert_max.value 	= m_menuiserie.ouvert_min
					spn_ouvert_min.value 	= m_menuiserie.ouvert_max
				)
				
				
				if ddl_type.selection == 1 then ddl_ouverture_sens.selection = 0
														else ddl_ouverture_sens.selection = m_menuiserie.ouvrant_sens
				
			)
			fn initialiser	_plug		=(
				m_plug 			= _plug
				ddl_type.items 	= liste_types
			)
			fn set_menuiserie _menuis =(
				m_menuiserie	=	_menuis
				actualiser ()
			)
	-- 		
	-- 		on rollout_menuiserie open do
	-- 			actualiser ()
			on ddl_type selected _val do (
				m_menuiserie.type = liste_types[_val]
				actualiser ()
			)
			
			on ddl_ouverture_sens selected _val do (
				m_menuiserie.ouvrant_sens = _val
				actualiser ()
			)
			on spn_longueur  changed val  		do		m_menuiserie.longueur = val
			on spn_allege  changed val 			do		m_menuiserie.allege_ht = val
			on spn_hauteur  changed val  		do		m_menuiserie.ouvrant_ht = val
			on spn_ouvert_proba  changed val  do		m_menuiserie.ouvert_proba = val
			on spn_ouvert_max  changed val  	do		m_menuiserie.ouvert_min = val
			on spn_ouvert_min  changed val  	do		m_menuiserie.ouvert_max = val
			
	)
	
	rollout_menuiserie
)







