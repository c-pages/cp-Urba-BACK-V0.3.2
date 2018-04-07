
		
		----  parametres perso  'private'	 ---------------
		parameters	params_internes (			
			-- pas hyper clean mais : on stock la position pour pouvoir la soustraire, replacer le node à l'endroit des shapes-reliefs sans tenir compte de sa transformation, donc il faut pouvoir y acceder -------------------
			transformation			type: #matrix3	 	default:(matrix3 1 ) 		 	animatable:false		invisibleInTV:true
		)
		
		
		
		
		----  Parametres et rollouts  -----------------
		parameters main rollout:rollout_global		(
			
			--- les nodes -----------
			contours_nodes		type:#nodeTab 		tabSize:0  		tabSizeVariable:true		--	 ui:btn_contour_pick		animatable:false		invisibleInTV:true
			reliefs_nodes			type:#nodeTab		tabSize:0  		tabSizeVariable:true		--	 ui:btn_relief_pick	 		animatable:false		invisibleInTV:true
			
			--- parametres divers -----------
			hauteur					type: #float	 	ui:spn_hauteur 			default:0.		 	animatable:false		invisibleInTV:true
			
			----- Evenements ------------------------------------------------------------------------------------------------------------------------------
			on contours_nodes 	set  val index 	do core.set_etape_aActualiser 1
			on reliefs_nodes		set  val index 	do core.set_etape_aActualiser 3
			on hauteur				set  val 			do core.set_etape_aActualiser 5
			
		)
		
		
		parameters params_grille rollout:rollout_grille		(
			
			----- on utilise local ou monde -----------------
			grille_monde_use			type:#boolean	 	default:true		animatable:false		invisibleInTV:true
			
			---- local -------------
			grille_resolution			type:#float	 		default:250.		animatable:false		invisibleInTV:true
			grille_position				type:#point3		default:[0,0,0]	animatable:false		invisibleInTV:true
			
			---- monde (partagé avec tout les terrains de la scene) -------------
			grille_monde_resolution	type: #float	 	default:250.		animatable:false		invisibleInTV:true
			grille_monde_position	type:#point3		default:[0,0,0]	animatable:false		invisibleInTV:true
			
			----- Evenements ------------------------------------------------------------------------------------------------------------------------------
			on grille_resolution		set  val		do core.set_etape_aActualiser 2
			on grille_position			set  val		do core.set_etape_aActualiser 2
			
			on grille_monde_resolution			set  val		do (
				--- si on est en monde, on actualise  ---------------
				if grille_monde_use do	core.set_etape_aActualiser 2
					
				--- on actualise tout les mondes de tout le monde ---------------
				for nd_terrain in geometry where classof nd_terrain.baseObject == Urba_terrain do
					if nd_terrain.grille_monde_resolution != val do (
						nd_terrain.grille_monde_resolution = val 
						nd_terrain.core.set_etape_aActualiser 2
						if nd_terrain.grille_monde_use do	nd_terrain.actualiser ()
					)
			)
			
			on grille_monde_position			set  val		do (		
				--- si on est en monde, on actualise  ---------------
				if grille_monde_use do	core.set_etape_aActualiser 2
					
				--- on actualise tout les monde de tout le monde ---------------
				for nd_terrain in geometry where classof nd_terrain.baseObject == Urba_terrain do
					if nd_terrain.grille_monde_position != val do  (
						nd_terrain.grille_monde_position = val 
						nd_terrain.core.set_etape_aActualiser 2
						if nd_terrain.grille_monde_use do	nd_terrain.actualiser ()
					)
				
			)
		)
		
	
		rollout rollout_global "Global" width:180 height:539
		(
			
			fn shape_filt 		obj = superclassof 	obj == shape				and not aCommeContour 	obj
			fn geo_filt 			obj = superclassof 	obj == GeometryClass	and not aCommeRelief 		obj
			fn poly_filt 			obj = classof 			obj == Editable_Poly
			
			pickbutton 'btn_contour_pick' "+" pos:[10,12] width:16 height:16 filter:shape_filt autoDisplay:false align:#left --tooltip:"Pick a shape to add to the borders list."
 --tooltip:"Pick a shape to add to the borders list."
			listbox 'lbx_contours' "" pos:[10,29] width:160 height:10 align:#left
			GroupBox 'grp_contours' "Borders" pos:[5,-2] width:170 height:172 align:#left
			
			button 'btn_supprimer_contour' "-" pos:[25,12] width:16 height:16 align:#left --tooltip:"Remove the selected border from the list."
 --tooltip:"Remove the selected border from the list."
			pickbutton 'btn_relief_pick' "+" pos:[10,187] width:16 height:16 filter:geo_filt autoDisplay:false align:#left --tooltip:"Pick a editable_poly to add to the reliefs list."
 --tooltip:"Pick a editable_poly to add to the reliefs list."
			listbox 'lbx_reliefs' "" pos:[10,204] width:160 height:6 align:#left
			GroupBox 'grp_reliefs' "Reliefs" pos:[5,173] width:170 height:120 align:#left
			button 'btn_supprimer_relief' "-" pos:[25,187] width:16 height:16 align:#left --tooltip:"Remove the selected relief from the list."
 --tooltip:"Remove the selected relief from the list."
			spinner 'spn_hauteur' "" pos:[100,298] width:65 height:16 range:[-1e+10,1e+10,0] type:#worldunits align:#left  --tooltip:"Move the terrain verticaly."
  --tooltip:"Move the terrain verticaly."
			label 'lbl4' "Relative height :" pos:[10,298] width:77 height:14 align:#left
			
			
			
			fn actualiser =(
			 	lbx_contours.items 	= for contour_node in contours_nodes collect if contour_node != undefined then  contour_node.name else "<deleted>"
				lbx_reliefs.items 		= for relief_node in reliefs_nodes collect if relief_node != undefined then  relief_node.name else "<deleted>"
				btn_supprimer_contour.enabled 	=	 lbx_contours.selection	!= 0 
				btn_supprimer_relief.enabled 		=	 lbx_reliefs.selection	!= 0  
			)
			
			
			
			
			
			on rollout_global open do
				actualiser ()
			on btn_contour_pick picked obj do
			(
				max modify mode
				local selecBack = copy lbx_contours.selection
				ajouter_contour	obj
				actualiser ()
				lbx_contours.selection = selecBack + 1	
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
			on spn_hauteur changed val do
			(
					core.actualiser ()
			)
		)

		rollout rollout_grille "Grid" width:180 height:539
		(
		
			
			spinner 'spn_resolution' "" pos:[100,30] width:65 height:16 range:[1,1e+10,0] type:#worldunits align:#left
			label 'lbl_resolution' "Size :" pos:[15,29] width:59 height:13 align:#left
			spinner 'spn_posX' "" pos:[100,58] width:65 height:16 range:[-1e+10,1e+10,0] type:#worldunits align:#left
			spinner 'spn_posY' "" pos:[100,74] width:65 height:16 enabled:false range:[-1e+10,1e+10,0] type:#worldunits align:#left
			GroupBox 'grp_Position' "Position :" pos:[10,45] width:160 height:50 align:#left
			label 'lbl_posX' "x:" pos:[20,57] width:13 height:13 align:#left
			label 'lbl_posY' "y:" pos:[19,73] width:13 height:13 align:#left
			dropdownList 'ddl_reference' "" pos:[100,-4] width:65 height:21 items:#("World", "Local") align:#left
			GroupBox 'grp_local' "Local" pos:[5,16] width:170 height:85 align:#left
			label 'lbl_type' "Type :" pos:[10,0] width:59 height:13 align:#left
			
			spinner 'spn_monde_resolution' "" pos:[100,118] width:65 height:16 range:[1,1e+10,0] type:#worldunits align:#left
			label 'lbl_monde_resolution' "Size :" pos:[15,117] width:59 height:13 align:#left
			spinner 'spn_monde_posX' "" pos:[100,146] width:65 height:16 range:[-1e+10,1e+10,0] type:#worldunits align:#left
			spinner 'spn_monde_posY' "" pos:[100,162] width:65 height:16 enabled:false range:[-1e+10,1e+10,0] type:#worldunits align:#left
			GroupBox 'grp_monde_position' "Position :" pos:[10,133] width:160 height:50 align:#left
			label 'lbl_monde_posX' "x:" pos:[20,145] width:13 height:13 align:#left
			label 'lbl_monde_posY' "y:" pos:[19,161] width:13 height:13 align:#left
			GroupBox 'grp_monde' "World" pos:[5,104] width:170 height:85 align:#left
			
			
			fn actualiser =(
				
				ddl_reference.selection = if grille_monde_use then 1 else 2
				
				spn_resolution.enabled	= not grille_monde_use
				spn_posX.enabled		= not grille_monde_use
				spn_posY.enabled		= not grille_monde_use
				grp_local.enabled			= not grille_monde_use
				lbl_resolution.enabled	= not grille_monde_use
				grp_position.enabled		= not grille_monde_use
				lbl_posX.enabled			= not grille_monde_use
				lbl_posY.enabled			= not grille_monde_use	

				spn_resolution.value		= grille_resolution
				spn_posX.value 			= grille_position.x
				spn_posY.value 			= grille_position.y
				
				
				spn_monde_resolution.enabled	= grille_monde_use
				spn_monde_posX.enabled			= grille_monde_use
				spn_monde_posY.enabled			= grille_monde_use	
				grp_monde.enabled					= grille_monde_use
				lbl_monde_resolution.enabled		= grille_monde_use
				grp_monde_position.enabled		= grille_monde_use
				lbl_monde_posX.enabled			= grille_monde_use
				lbl_monde_posY.enabled			= grille_monde_use	
				
				spn_monde_resolution.value	= grille_monde_resolution
				spn_monde_posX.value 		= grille_monde_position.x
				spn_monde_posY.value 		= grille_monde_position.y
				
				
				
			)
			
			
			
			
			
			
			
			on rollout_grille open do
				actualiser ()
			on spn_resolution changed val do
			(
							grille_resolution			=	val
							if not grille_monde_use do	(
								core.set_etape_aActualiser 2
								core.actualiser ()
							)
						)
			on spn_posX changed val do
			(	
							if grille_lier_pos do val.y = val.x
							grille_position.x			=	val
							if not grille_monde_use do	(
								core.set_etape_aActualiser 2
								core.actualiser ()
							)
							actualiser ()
						)
			on spn_posY changed val do
			(
							grille_position.y			=	val
							if not grille_monde_use do	(
								core.set_etape_aActualiser 2
								core.actualiser ()
							)
						)
			on ddl_reference selected sel do
			(
							grille_monde_use = if sel == 1 then true else false
							actualiser ()
							core.set_etape_aActualiser 2
							core.actualiser ()
						)
			on spn_monde_resolution changed val do
			(
							grille_monde_resolution	=	val
							if grille_monde_use do	(
								core.set_etape_aActualiser 2
								core.actualiser ()
							)
						)
			on spn_monde_posX changed val do
			(	
							grille_monde_position.x	=	val
							if grille_monde_use do	(
								core.set_etape_aActualiser 2
								core.actualiser ()
							)
						)
			on spn_monde_posY changed val do
			(
							grille_monde_position.y	=	val
							if grille_monde_use do	(
								core.set_etape_aActualiser 2
								core.actualiser ()
							)
						)
		)
		
	
	
