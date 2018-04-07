
		rollout rollout_grille 	"Grille" width:162 height:539
		(
			
			fn shape_filt 		obj = superclassof 	obj == shape
			fn geo_filt 			obj = superclassof 	obj == GeometryClass
			fn poly_filt 			obj = classof 			obj == Editable_Poly
			
			
			
			fn actualiser =(
				lbx_contours.items 	= for contour_node in contours_nodes collect if contour_node != undefined then  contour_node.name else "<deleted>"
				lbx_reliefs.items 		= for relief_node in reliefs_nodes collect if relief_node != undefined then  relief_node.name else "<deleted>"
				btn_supprimer_contour.enabled 	=	 lbx_contours.selection	!= 0 
				btn_supprimer_relief.enabled 		=	 lbx_reliefs.selection	!= 0 
			)
			
			
			
			spinner 'spn_resolution' "" pos:[92,36] width:60 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			label 'lbl_resolution' "Résolution :" pos:[15,35] width:59 height:13 align:#left
			spinner 'spn_posX' "" pos:[60,65] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			spinner 'spn_posY' "" pos:[60,81] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			checkbutton 'ckb_lier_XY' "" pos:[136,64] width:8 height:34 align:#left
			GroupBox 'grp_position' "Position :" pos:[10,52] width:140 height:50 align:#left
			label 'lbl_posX' "x:" pos:[22,64] width:13 height:13 align:#left
			label 'lbl_posY' "y:" pos:[21,80] width:13 height:13 align:#left
			dropDownList 'ddl_reference' "" pos:[5,4] width:150 height:21 items:#("Individuelle", "Monde") align:#left
			GroupBox 'grp_cadre' "" pos:[5,23] width:152 height:85 align:#left
			on spn_resolution changed val do
			(
					actualiser ()
					core.actualiser ()
			)
			on spn_posX changed val do
			(
					actualiser ()
					core.actualiser ()
			)
			on spn_posY changed val do
			(
					actualiser ()
					core.actualiser ()
			)
		)
		
		rollout rollout_global "Global" width:162 height:539
		(
			
			fn shape_filt 		obj = superclassof 	obj == shape
			fn geo_filt 			obj = superclassof 	obj == GeometryClass
			fn poly_filt 			obj = classof 			obj == Editable_Poly
			
			pickbutton 'btn_contour_pick' "+" pos:[10,186] width:16 height:16 filter:shape_filt autoDisplay:false align:#left
			spinner 'spn_precision' "" pos:[62,44] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			listbox 'lbx_contours' "" pos:[10,203] width:137 height:6 align:#left
			GroupBox 'grp_contours' "Contours" pos:[4,172] width:153 height:119 align:#left
			
			button 'btn_supprimer_contour' "-" pos:[25,186] width:16 height:16 align:#left
			pickbutton 'btn_relief_pick' "+" pos:[10,308] width:16 height:16 filter:geo_filt autoDisplay:false align:#left
			listbox 'lbx_reliefs' "" pos:[10,325] width:137 height:6 align:#left
			GroupBox 'grp_reliefs' "Reliefs" pos:[4,294] width:153 height:119 align:#left
			button 'btn_supprimer_relief' "-" pos:[25,308] width:16 height:16 align:#left
			spinner 'spn_decallageZ' "" pos:[82,419] width:76 height:16 range:[-1e+10,1e+10,0] type:#worldunits align:#left
			label 'lbl4' "Hauteur:" pos:[11,419] width:61 height:14 align:#left
			checkbox 'chk_world' "World" pos:[10,15] width:116 height:11 align:#left
			
			fn actualiser =(
				lbx_contours.items 	= for contour_node in contours_nodes collect if contour_node != undefined then  contour_node.name else "<deleted>"
				lbx_reliefs.items 		= for relief_node in reliefs_nodes collect if relief_node != undefined then  relief_node.name else "<deleted>"
				btn_supprimer_contour.enabled 	=	 lbx_contours.selection	!= 0 
				btn_supprimer_relief.enabled 		=	 lbx_reliefs.selection	!= 0 
			)
			
			
			
			spinner 'spn3' "" pos:[62,60] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			groupBox 'grp3' "Grille" pos:[4,-1] width:153 height:139 align:#left
			checkButton 'ckb1' "" pos:[138,43] width:8 height:34 align:#left
			groupBox 'grp4' "Taille" pos:[10,31] width:141 height:50 align:#left
			label 'lbl4' "x:" pos:[19,43] width:13 height:13 align:#left
			label 'lbl5' "y:" pos:[18,59] width:13 height:13 align:#left
			spinner 'spn4' "" pos:[62,94] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			spinner 'spn5' "" pos:[62,110] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			checkButton 'ckb2' "" pos:[138,93] width:8 height:34 align:#left
			groupBox 'grp5' "Position" pos:[10,81] width:141 height:50 align:#left
			label 'lbl6' "x:" pos:[19,93] width:13 height:13 align:#left
			label 'lbl7' "y:" pos:[18,109] width:13 height:13 align:#left
			on rollout_terrain open do
				actualiser ()
			on btn_contour_pick picked obj do
			(
				max modify mode
				ajouter_contour	obj
				ajouter_relief   obj
				actualiser ()
				lbx_contours.selection += 1
				
				
				/* if appendIfUnique contours_nodes obj do (
					core.actualiser ()
			-- 					core.actualiser_contours ()
			-- 					core.construire ()
				) */
			)
			on spn_precision changed val do
			(
					actualiser ()
					core.actualiser ()
			)
			on lbx_contours selected sel do
			(
					actualiser ()
				
				)
			on lbx_contours doubleClicked sel do
			(
					select contours_nodes[sel]
				)
			on btn_supprimer_contour pressed do
			(
				
				if lbx_contours.selection > 0 do (
					local selecBack = copy lbx_contours.selection
					deleteItem contours_nodes 	lbx_contours.selection
					actualiser ()
					lbx_contours.selection = selecBack - 1
					core.actualiser ()
				)
			)
			on btn_relief_pick picked obj do
			(
				max modify mode
				
				if appendIfUnique reliefs_nodes	 obj do (
					actualiser ()
					lbx_reliefs.selection += 1
					core.actualiser ()
				)
			)
			on lbx_reliefs selected sel do
			(
			
					actualiser ()
				)
			on lbx_reliefs doubleClicked sel do
			(
			
					select reliefs_nodes[sel]
				)
			on btn_supprimer_relief pressed do
			(
				if lbx_reliefs.selection > 0 do (
					local selecBack = copy lbx_reliefs.selection
					deleteItem reliefs_nodes  lbx_reliefs.selection
					actualiser ()
					lbx_reliefs.selection = selecBack - 1
					core.actualiser ()
				)
			)
			on spn_decallageZ changed val do
			(
					core.actualiser ()
			)
			on spn3 changed val do
			(
					actualiser ()
					core.actualiser ()
			)
			on spn4 changed val do
			(
					actualiser ()
					core.actualiser ()
			)
			on spn5 changed val do
			(
					actualiser ()
					core.actualiser ()
			)
		)
		