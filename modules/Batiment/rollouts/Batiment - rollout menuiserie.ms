


--- les rollout du composant	---------
rollout rollout_menuiserie "Menuiserie" width:203 height:233
(
		local m_rollPrt
		local m_compo
		
		---- golbal --------------
	label 'lbl19' "Longeur:" pos:[11,42] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[116,42] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	GroupBox 'grp1' "Global" pos:[6,7] width:187 height:77 align:#left
	
	dropdownList 'ddl_type' "" pos:[76,23] width:111 height:21 items:#("Fixe", "Fenêtre", "Porte pleine", "Porte vitrée", "Porte de garage") align:#left
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
	spinner 'spn_ouvert_max' "" pos:[105,192] width:70 height:16 range:[100,100,0] scale:1 align:#left
	label 'lbl_ouvert_min' "Minimum (%) :" pos:[22,177] width:80 height:13 align:#left
	spinner 'spn_ouvert_min' "" pos:[105,177] width:70 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_sens' "Sens :" pos:[11,126] width:49 height:13 align:#left
	dropdownList 'ddl_ouverture_sens' "" pos:[76,123] width:111 height:21 items:#("Droite", "Gauche", "Vers le haut", "Vers le bas") align:#left
	
	GroupBox 'grp_ouverture' "Ouverture" pos:[12,147] width:169 height:66 align:#left
	
	local btns_ouverture = #( lbl_hauteur, spn_hauteur, grp_ouverture, grp_ouvrant, lbl_ouvert_proba, spn_ouvert_proba, lbl_ouvert_max, spn_ouvert_max, lbl_ouvert_min, spn_ouvert_min, lbl_sens, ddl_ouverture_sens)
	fn actualiser =(
		if ddl_type.selection == 1 then
			roll_menuiserie.height		=	90
		else 
			roll_menuiserie.height		=	233
		
		btns_ouverture.enabled = ddl_type.selection != 1
		
		spn_hauteur.indeterminate = not ddl_type.selection != 1
		spn_ouvert_proba.indeterminate = not ddl_type.selection != 1
		spn_ouvert_max.indeterminate = not ddl_type.selection != 1
		spn_ouvert_min.indeterminate = not ddl_type.selection != 1
		if ddl_type.selection == 1 do ddl_ouverture_sens.selection = 0
		
	)
	
	
	on roll_menuiserie open do
		actualiser ()
	on ddl_type selected _val do
		actualiser ()
)
/* 
createDialog	roll_menuiserie
 */









