/* 
--- les rollout du composant	---------
rollout roll_menuiserie_fixe "Fixe" width:200 height:81
(
		local m_rollPrt
		local m_compo
		
		---- golbal --------------
	edittext 'edt_nom' "" pos:[3,3] width:187 height:16 align:#left
	GroupBox 'grp1' "Global" pos:[6,21] width:187 height:53 align:#left
	label 'lbl24' "Allège pleine :" pos:[11,35] width:77 height:13 align:#left
	spinner 'spn_allege' "" pos:[116,35] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		
		---- traverses --------
	
	---- sequence --------
		
		---- volet --------
		
		
	label 'lbl_repetitions' "Répetitions :" pos:[11,51] width:77 height:13 align:#left
	spinner 'spn_repetitions' "" pos:[116,51] width:70 height:16 range:[0,100000,0] type:#integer scale:1 align:#left
)
createdialog  roll_menuiserie_fixe

 */



--- les rollout du composant	---------
rollout roll_menuiserie "Menuiserie" width:200 height:207
(
		local m_rollPrt
		local m_compo
		
		---- golbal --------------
	edittext 'edt_nom' "" pos:[3,3] width:187 height:16 align:#left
	label 'lbl19' "Longeur:" pos:[11,56] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[116,56] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl21' "Hauteur:" pos:[11,71] width:49 height:13 align:#left
	spinner 'spn_hauteur' "" pos:[116,71] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	GroupBox 'grp1' "Global" pos:[6,21] width:187 height:88 align:#left
		
		---- traverses --------
	
	---- sequence --------
		
		---- volet --------
	GroupBox 'grp_ouverture' "Ouverture" pos:[5,114] width:187 height:84 align:#left
	label 'lbl_ouvert_proba' "Probabilité (%) :" pos:[11,144] width:80 height:13 align:#left
	spinner 'spn_ouvert_proba' "" pos:[116,144] width:70 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_ouvert_max' "Maximum (%) :" pos:[11,174] width:80 height:13 align:#left
	spinner 'spn_ouvert_max' "" pos:[116,174] width:70 height:16 range:[100,100,0] scale:1 align:#left
	label 'lbl_ouvert_min' "Minimum (%) :" pos:[11,159] width:80 height:13 align:#left
	spinner 'spn_ouvert_min' "" pos:[116,159] width:70 height:16 range:[0,100,0] scale:1 align:#left
	dropdownList 'ddl_ouverture_sens' "" pos:[76,125] width:111 height:21 items:#("Droite", "Gauche", "Vers le haut", "Vers le bas") align:#left
	
	
	dropdownList 'ddl_type' "" pos:[76,37] width:111 height:21 items:#("Fixe", "Fenêtre", "Porte pleine", "Porte vitrée", "Porte de garage") align:#left
	label 'lbl_allege' "Allège :" pos:[11,86] width:49 height:13 align:#left
	spinner 'spn_allege' "" pos:[116,86] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl51' "Type :" pos:[11,39] width:49 height:13 align:#left
	label 'lbl59' "Sens :" pos:[11,128] width:49 height:13 align:#left
)



createdialog  roll_menuiserie_ouvrant










