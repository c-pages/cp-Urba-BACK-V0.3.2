--Destroy the dialog if it is already open 
try(destroyDialog rollout_Urb_Bat_editeur)catch()


rollout sub01 "Général" width:255 height:427
(
	edittext 'edt1' "" pos:[5,3] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,3] width:18 height:18 align:#left

	--- Global ------
	GroupBox 'grp_global' "Etages :" pos:[10,20] width:235 height:199 align:#left
-- 	spinner 'spn_rotation_axeP' "" pos:[88,87] width:48 height:16 range:[-360,360,0] type:#float scale:1 align:#left
-- 	label 'lbl_axeP' "Orientation:" pos:[10,87] width:59 height:15 align:#left
-- 	button 'btn_rotation' "+90" pos:[137,87] width:24 height:16 align:#left
	label 'lbl_nbre' "Nbre. d'étages:" pos:[27,39] width:92 height:15 align:#left
	spinner 'spn_nbres' "" pos:[160,38] width:72 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_hauteur' "" pos:[160,54] width:72 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Hauteur :" pos:[27,55] width:76 height:15 align:#left
	
	---- particuliers ---
	listbox 'lbx_etages_particuliers' "" pos:[33,104] width:185 height:4 align:#left
	button 'btn_ajouter_etages_particuliers' "+" pos:[32,87] width:16 height:16 align:#left
	
	button 'btn_supprimer_etages_particuliers' "-" pos:[48,87] width:16 height:16 align:#left
	spinner 'spn_etageMin_particuliers' "" pos:[127,165] width:40 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_etage_particuliers' "Etages :" pos:[35,162] width:50 height:19 align:#left
	spinner 'spn_etageMax_particuliers' "" pos:[179,165] width:40 height:16 range:[0,1e+13,0] type:#integer align:#left
	label 'lbl_hauteur_particuliers' "Hauteur :" pos:[35,180] width:55 height:22 align:#left
	checkbutton 'ckb_etageMax_particuliers' ">" pos:[166,165] width:16 height:16 align:#left
	spinner 'spn_hauteur_particuliers' "" pos:[127,181] width:92 height:16 range:[0,1e+13,0] type:#worldunits align:#left
	
	label 'lbl16' "Décallage (Z):" pos:[27,240] width:92 height:18 align:#left
	spinner 'spn20' "" pos:[160,240] width:72 height:16 range:[-1e+13,1e+13,0] type:#worldunits scale:1 align:#left

	checkbox 'chk2' "Cloisons intèrieures" pos:[26,259] width:141 height:16 align:#left
	GroupBox 'grp38' "Divers" pos:[10,223] width:235 height:60 align:#left
	GroupBox 'grp42' "Variations" pos:[20,72] width:213 height:135 align:#left
)






rollout sub02 "Façades" width:255 height:352
(


	
	edittext 'edt1' "" pos:[5,3] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,3] width:18 height:18 align:#left
	
	spinner 'spn_etages' "" pos:[95,49] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_etagesMax' "" pos:[172,49] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left		
		
		
		
		
		
		
		
		
			
	GroupBox 'grp_global' "Appliqué à " pos:[10,32] width:235 height:89 align:#left
					
		
		
			
				
				
	spinner 'spn_longueur_min' "" pos:[95,64] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	spinner 'spn_longueur_max' "" pos:[172,64] width:63 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	checkbutton 'chk_longueur_max' "" pos:[159,64] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	checkbutton 'chk_longueur_min' "" pos:[82,64] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl_longueur' "Longueur:" pos:[20,65] width:52 height:15 align:#left
					
		
	checkbutton 'ckb_mur_nord' "Nord" pos:[82,98] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_sud' "Sud" pos:[121,98] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_est' "Est" pos:[159,98] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_ouest' "Ouest" pos:[197,98] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl_appliquerA' "Murs:" pos:[20,81] width:32 height:15 align:#left
					
	dropdownList 'ddl_murs' "" pos:[82,79] width:154 height:21 selection:3 align:#left
		
	checkbutton 'chk_etagesMax' "" pos:[159,49] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl30' "Etages :" pos:[20,49] width:52 height:15 align:#left
	
	checkbutton 'chk_etages' "" pos:[82,49] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	
	
					
	GroupBox 'grp_sequence' "Séquence" pos:[10,125] width:235 height:217 align:#left
		
	button 'btn_monter' "/\\" pos:[222,162] width:16 height:16 toolTip:"Monter le composant." align:#left
	button 'btn_descendre' "\/" pos:[222,177] width:16 height:16 toolTip:"Descendre le composant." align:#left
		
		
		
	button 'btn_dupliquer_composant' "Dup." pos:[54,146] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	button 'btn_instancier_composant' "Inst." pos:[88,146] width:35 height:16 toolTip:"Créer une instance du composant sélectionné." align:#left
	button 'btn_supprimer_composant' "Sup." pos:[182,145] width:35 height:16 toolTip:"Supprimer" align:#left
		
		
	listbox 'lbx_sequence' "" pos:[20,162] width:200 height:12 align:#left
		
		
		
	
	
	
	
	
	
	button 'btn29' "Nouv." pos:[20,146] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
)

rollout sub03 "Toiture" width:557 height:427
(

	
	edittext 'edt1' "" pos:[5,3] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,3] width:18 height:18 align:#left
	label 'lbl_appliquerA' "Type :" pos:[10,24] width:32 height:15 align:#left
					
	dropdownList 'ddl_murs' "" pos:[75,22] width:170 height:21 selection:3 align:#left
	
	subRollout 'subroll_parametres' "Parametres" pos:[20,66] width:205 height:209 align:#left
	GroupBox 'grp_prop' "Propriétés" pos:[10,48] width:235 height:238 align:#left
		
)
rollout sub04 "Interieur" width:255 height:427
(


	
	edittext 'edt1' "" pos:[5,3] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,3] width:18 height:18 align:#left
	--- Global ------
	GroupBox 'grp_global' "Murs :" pos:[10,56] width:235 height:245 align:#left

)
rollout sub05 "Matériaux" width:255 height:427
(


	
	edittext 'edt1' "" pos:[5,3] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,3] width:18 height:18 align:#left
	--- Global ------
	GroupBox 'grp_global' "Murs :" pos:[10,56] width:235 height:245 align:#left

)











--Create a rollout
rollout rollout_Urb_Bat_editeur "Urb - Bat - Editeur" width:329 height:502
(
	--Add a dot net tab control
	dotNetControl 'tabs' "system.windows.forms.tabControl" pos:[10,7] width:308 height:25 align:#left 
 
 
 
 
 
 
	--Add a sub rollout.
	subRollout 'subRoll' "Sub" pos:[40,43] width:278 height:407 align:#left
	
	--Function to show all properties, methods and events for any dotNet object
	fn showProps obj=
	(
		clearListener()
		format "Properties:\n"
		showProperties obj
		format "\nMethods:\n"
		showMethods obj
		format "\nEvents:\n"
		showEvents obj
	)
	
	--Add rollouts to the subRollout based on which tab is currently selected. 
	fn addTabRollout index=
	(
		--Remove any existing rollouts first. 
 		for x in subRoll.rollouts do removeSubRollout subRoll x
		
		sub=case index of
		(
			default:
			(
				sub01
				
			)
			1:
			(
				sub02
			)
			2:
			(
				sub03
			)
			3:
			(
				sub04
			)
			4:
			(
				sub05
			)
		)
		addSubRollout subRoll sub
	)
	
	--Tab initilization function.
	fn initTabs tab labels:#() =
	(
		--Clear any existing tabs incase we do an update of them at some point. 
		tab.tabPages.clear()
		--Set the size mode so that we can control their width. 
		tab.sizeMode=tab.sizeMode.fixed
		--Set the width of every tab.
		tab.itemSize=dotnetObject "System.Drawing.Size" ((tab.width/( labels.count /* - 1 */ ) ) - 5)   23
		--Loop through all the labels that we pass to the function and add a tab by the same name. 
 		for x in labels do tab.tabPages.add x
	)
	
	--When the mouse button is released on a tab get the selected tab and pass it to our addTabRollout function. 
	button 'btn10' "Valider" pos:[10,456] width:96 height:35 align:#left
	
	--When the rollout opens initilize the tab control
	button 'btn_annuler' "Annuler" pos:[222,456] width:96 height:35 align:#left
	button 'btn13' "Maj" pos:[10,43] width:28 height:28 enabled:true align:#left
	checkbutton 'ckb4' "Surf" pos:[10,170] width:28 height:28 highlightColor:(color 255 255 0) align:#left
	checkbutton 'ckb5' "Etg." pos:[10,116] width:28 height:28 highlightColor:(color 255 255 0) align:#left
	checkbutton 'ckb6' "Fcd." pos:[10,143] width:28 height:28 highlightColor:(color 255 255 0) align:#left
	progressBar 'pb1' "ProgressBar" pos:[10,35] width:308 height:6 align:#left
	
	checkbutton 'ckb87' "Auto" pos:[10,70] width:28 height:28 highlightColor:(color 255 255 0) align:#left
	on rollout_Urb_Bat_editeur open do
	(
	-- 		showProps tabs
		
		initTabs tabs labels:#("Général", "Façades", "Toiture", "Materiaux")
		addTabRollout 0
	)
	on tabs mouseUp senderArg arg do
	(
	-- 		showProps arg
		addTabRollout senderArg.SelectedIndex
	)
)
--Create the dialog
-- createDialog rollout_Urb_Bat_editeur


createDialog 	rollout_Urb_Bat_editeur		style:				#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu) 	\
														lockWidth:			true





























