/*#########################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale

	QUARTIER - les rolllouts du plug
	
########################################################################################################################*/


-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  --------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

rollout roll_global "Global" width:195 height:410
(


	fn shape_filt 		obj = superclassof obj == shape


	GroupBox 'grp_presets' "Presets :" pos:[8,1] width:162 height:39 align:#left
	button 'btn_enregistrer' "Enregistrer" pos:[88,19] width:77 height:16 align:#left
	button 'btn_charger' "Charger" pos:[13,19] width:76 height:16 enabled:true align:#left

	--- Surface ------
	checkbutton 'chkbtn_surbillance' "Surbrillance" pos:[98,54] width:66 height:19 highlightColor:(color 180 180 50) toolTip:"Revele dans le viewport les contours séléctionnés dans la liste.." align:#left
	checkbutton 'chkbtn_ajouter_contour' "+" pos:[13,54] width:19 height:19 toolTip:"Ajouter à contour au quartier." filter:shape_filt autoDisplay:false align:#left
	GroupBox 'grp_contours' "Contours :" pos:[8,40] width:162 height:287 align:#left
	button 'btn_retirer_contour' "-" pos:[31,54] width:19 height:19 toolTip:"Retirer le contour séléctionné du quartier." align:#left
	
	multiListBox 'lbx_contours' "" pos:[13,75] width:150 height:16 align:#left
	
	button 'btn_select' "Select" pos:[13,289] width:76 height:16 align:#left
	button 'btnselect_unused' "Unused" pos:[88,289] width:76 height:16 align:#left
	button 'btn163' "Nouvelle typologie" pos:[13,304] width:150 height:16 toolTip:"Crée une nouvelle typologie utilisant les contours selectionnés comme groupe à utiliser." align:#left
	
	
	
	
	
	fn afficher_contours =(
		local noms_contours = for contour in p_contours collect contour.name
		lbx_contours.items = noms_contours
	)

	fn actualiser =(
		afficher_contours ()
		
		btn_retirer_contour.enabled = ( lbx_contours.selection as array).count > 0 
		format  "lbx_contours.selection : % , count : %\n" lbx_contours.selection		( lbx_contours.selection as array).count
	)





	
	
	
	
	
	
	
	
	
	
	
	on roll_global open do
		actualiser ()
	on roll_global close do
		()
	on btn_enregistrer pressed do
		()
	on btn_charger pressed do
		()
	on chkbtn_surbillance changed state do
	(
		)
	on chkbtn_ajouter_contour changed state do
	(
			format "pique contours ... \n"
			
			case state of (
				true: (
					local shps_aAjouter = pickObject prompt:"popo"	filter:shape_filt  count:#multiple  forceListenerFocus:false
					if shps_aAjouter.count > 0 do (
						core.ajouter_contours	shps_aAjouter
						actualiser ()
					)
					chkbtn_ajouter_contour.checked = false
				)
			)
			format "... pique contours fin. \n"
		
		)
	on btn_retirer_contour pressed do
	(
		
		)
	on lbx_contours selected _id do
		actualiser ()
	on btn_select pressed do
	(
		
		)
	on btnselect_unused pressed do
	(
		
		)
	on btn163 pressed do
	(
		
		)
)



rollout roll_typologies "Typologies" width:182 height:447
(


	fn shape_filt 		obj = superclassof obj == shape



	--- Surface ------
	checkbutton 'chkbtn_surbillance' "Surbrillance" pos:[110,27] width:66 height:19 highlightColor:(color 180 180 50) toolTip:"Revele dans le viewport les contours séléctionnés dans la liste.." align:#left
	checkbutton 'btn_ajouter_typologie' "+" pos:[8,27] width:19 height:19 toolTip:"Créer une nouvelle typologie de bâtiment." align:#left
	button 'btn_supprimer_typologie' "-" pos:[26,27] width:19 height:19 toolTip:"Supprimer la typologie." align:#left
	GroupBox 'grp8' "Conditions contours  " pos:[6,133] width:168 height:120 align:#left
	GroupBox 'grp9' "Batiments  " pos:[6,259] width:168 height:162 align:#left
		
		
		
	
	spinner 'spn21' "" pos:[26,164] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn22' "" pos:[103,164] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	checkbutton 'ckb45' "" pos:[90,164] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl20' "Surface :" pos:[14,149] width:52 height:15 align:#left
	checkbutton 'ckb46' "" pos:[13,164] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	spinner 'spn23' "" pos:[101,370] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn25' "" pos:[26,194] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn26' "" pos:[103,194] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	checkbutton 'ckb49' "" pos:[90,194] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl23' "Largeur :" pos:[14,179] width:52 height:15 align:#left
	checkbutton 'ckb50' "" pos:[13,194] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	spinner 'spn27' "" pos:[26,224] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn28' "" pos:[103,224] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	checkbutton 'ckb51' "" pos:[90,224] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl24' "Longueur :" pos:[14,209] width:52 height:15 align:#left
	checkbutton 'ckb52' "" pos:[13,224] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	button 'btn82' "Select." pos:[123,273] width:42 height:16 align:#left
	dropdownList 'ddl16' "" pos:[8,7] width:168 height:21 align:#left
	label 'lbl31' "+" pos:[92,370] width:7 height:15 align:#left
	spinner 'spn41' "" pos:[101,385] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl32' "-" pos:[94,385] width:7 height:15 align:#left
	GroupBox 'grp50' "Contours sources  " pos:[6,74] width:168 height:55 align:#left
	radiobuttons 'rdo1' "" pos:[19,88] width:58 height:32 labels:#("Tous", "Groupe") columns:1 align:#left
	button 'btn115' "Editer" pos:[101,104] width:63 height:16 align:#left
	listbox 'lbx11' "" pos:[16,290] width:149 height:3 align:#left
	spinner 'spn52' "" pos:[101,337] width:64 height:16 range:[0,100,0] type:#float scale:1 align:#left
	label 'lbl41' "Pourcentage :" pos:[18,337] width:71 height:15 align:#left
	button 'btn116' "+" pos:[17,273] width:16 height:16 align:#left
	button 'btn117' "-" pos:[32,273] width:16 height:16 align:#left
	edittext 'edt13' "" pos:[5,47] width:154 height:16 align:#left
	spinner 'spn111' "" pos:[101,355] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl88' "Etages :" pos:[18,355] width:47 height:15 align:#left
	colorPicker 'cp1' "" pos:[155,46] width:21 height:19 color:(color 255 255 0) align:#left
)

















