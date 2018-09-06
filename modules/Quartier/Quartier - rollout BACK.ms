rollout quartier_rollout "Quartier" width:766 height:348
(
	listbox 'lbx1' "" pos:[8,29] width:220 height:21 align:#left
	button 'btn_ajouter_shape' "+" pos:[162,8] width:20 height:20 align:#left
	button 'btn2' "-" pos:[181,8] width:20 height:20 align:#left
	GroupBox 'grp1' "Parametres" pos:[503,23] width:235 height:299 align:#left
	GroupBox 'grp8' "Conditions" pos:[509,90] width:220 height:69 align:#left
	dropdownList 'ddl5' "" pos:[516,177] width:188 height:21 align:#left
	button 'btn30' "..." pos:[705,195] width:20 height:20 align:#left
	GroupBox 'grp9' "Model" pos:[510,160] width:220 height:63 align:#left
	edittext 'edt2' "" pos:[513,198] width:191 height:17 align:#left
	GroupBox 'grp10' "Variations" pos:[509,228] width:220 height:64 align:#left
		
	button 'btn_facade_monter' "/\\" pos:[1061,79] width:16 height:16 toolTip:"Monter le composant." align:#left
	button 'btn_facade_descendre' "\/" pos:[1061,94] width:16 height:16 toolTip:"Descendre le composant." align:#left
	button 'btn_facade_dupliquer' "Dup." pos:[876,60] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	button 'btn_facade_supprimer' "Sup." pos:[1025,60] width:35 height:16 toolTip:"Supprimer" align:#left
	listbox 'lbx_facades' "" pos:[842,77] width:218 height:7 align:#left
	button 'btn_facade_nouveau' "Nouv." pos:[842,60] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	
	edittext 'edt_facade_nom' "" pos:[845,193] width:207 height:16 align:#left
	button 'btn_facades_presets' "" pos:[1054,193] width:16 height:16 align:#left
	
	spinner 'spn_contrainte_etages' "" pos:[918,227] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_contrainte_etagesMax' "" pos:[995,227] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	
	GroupBox 'grp_constraintes' "Contraintes" pos:[846,210] width:222 height:89 align:#left
	
	spinner 'spn_contrainte_longueur_min' "" pos:[918,242] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	spinner 'spn_contrainte_longueur_max' "" pos:[995,242] width:63 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	checkbutton 'chk_contrainte_longueur_max' "" pos:[982,242] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	checkbutton 'chk_contrainte_longueur_min' "" pos:[905,242] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl_contrainte_longueur' "Long.:" pos:[854,243] width:52 height:15 align:#left
	
	checkbutton 'ckb_mur_nord' "Nord" pos:[905,276] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_sud' "Sud" pos:[944,275] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_est' "Est" pos:[982,276] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_ouest' "Ouest" pos:[1020,276] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl_contrainte_murs' "Murs:" pos:[854,259] width:32 height:15 align:#left
	
	dropdownList 'ddl_contrainte_murs' "" pos:[905,257] width:154 height:21 selection:3 align:#left
	
	checkbutton 'chk_contrainte_etagesMax' "" pos:[982,227] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl_contrainte_etages' "Etages :" pos:[854,227] width:52 height:15 align:#left
	
	checkbutton 'chk_contrainte_etages' "" pos:[905,227] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	
	
	--- parametre facade	------
	
	
		
		
		
		
		
		
	
	GroupBox 'grp_parametres' "Paramètres" pos:[840,175] width:235 height:133 align:#left
	spinner 'spn21' "" pos:[583,105] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn22' "" pos:[660,105] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	checkbutton 'ckb45' "" pos:[647,105] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl20' "Surface :" pos:[519,106] width:52 height:15 align:#left
	checkbutton 'ckb46' "" pos:[570,105] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	spinner 'spn23' "" pos:[581,244] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn24' "" pos:[658,244] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	checkbutton 'ckb47' "" pos:[645,244] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl21' "Etages :" pos:[517,245] width:52 height:15 align:#left
	checkbutton 'ckb48' "" pos:[568,244] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl22' "Texture :" pos:[517,265] width:47 height:15 align:#left
	dropdownList 'ddl16' "" pos:[568,263] width:154 height:21 selection:3 align:#left
	spinner 'spn25' "" pos:[583,121] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn26' "" pos:[660,121] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	checkbutton 'ckb49' "" pos:[647,121] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl23' "Largeur :" pos:[519,122] width:52 height:15 align:#left
	checkbutton 'ckb50' "" pos:[570,121] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	spinner 'spn27' "" pos:[583,137] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn28' "" pos:[660,137] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	checkbutton 'ckb51' "" pos:[647,137] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl24' "Longueur :" pos:[519,138] width:52 height:15 align:#left
	checkbutton 'ckb52' "" pos:[570,137] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	button 'btn81' "Select." pos:[123,308] width:53 height:20 align:#left
	button 'btn82' "Select. Batiments" pos:[510,298] width:104 height:20 align:#left
	GroupBox 'grp32' "Quartier" pos:[241,9] width:511 height:324 align:#left
	dropdownList 'ddl18' "" pos:[255,26] width:196 height:21 align:#left
	button 'btn83' "+" pos:[452,27] width:20 height:20 align:#left
	button 'btn84' "-" pos:[472,27] width:20 height:20 align:#left
	button 'btn85' "+" pos:[705,176] width:20 height:20 align:#left
	dropdownList 'ddl24' "" pos:[511,40] width:196 height:21 align:#left
	button 'btn104' "+" pos:[708,40] width:20 height:20 align:#left
	edittext 'edt11' "" pos:[507,64] width:222 height:17 align:#left
	listbox 'lbx20' "" pos:[265,94] width:220 height:17 align:#left
	button 'btn105' "+" pos:[444,72] width:20 height:20 align:#left
	button 'btn106' "-" pos:[463,72] width:20 height:20 align:#left
	label 'lbl33' "Shapes:" pos:[7,12] width:52 height:15 align:#left
	edittext 'edt12' "" pos:[256,48] width:235 height:17 align:#left
	label 'lbl34' "Batiments:" pos:[266,78] width:52 height:15 align:#left
	button 'btn124' "OSM" pos:[200,8] width:29 height:20 align:#left
	button 'btn143' "Unused" pos:[175,308] width:53 height:20 align:#left
)














-- createdialog quartier_rollout

