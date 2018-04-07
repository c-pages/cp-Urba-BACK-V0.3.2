
		
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
			on hauteur				set  val 			do core.set_etape_aActualiser 4
			
		)
		
		
		parameters params_grille rollout:rollout_grille		(
			
			----- on utilise local ou monde -----------------
			grille_monde_use			type:#boolean	 	default:true		animatable:false		invisibleInTV:true
			
			---- local -------------
			grille_resolution			type:#float	 		default:500.		animatable:false		invisibleInTV:true
			grille_position				type:#point3		default:[0,0,0]	animatable:false		invisibleInTV:true
			
			---- monde (partagé avec tout les terrains de la scene) -------------
			grille_monde_resolution	type: #float	 	default:500.		animatable:false		invisibleInTV:true
			grille_monde_position	type:#point3		default:[0,0,0]	animatable:false		invisibleInTV:true
			
			----- Evenements ------------------------------------------------------------------------------------------------------------------------------
			on grille_resolution		set  val		do core.set_etape_aActualiser 2
			on grille_position			set  val		do core.set_etape_aActualiser 2
			
			on grille_monde_resolution			set  val		do (
				
				--- si on est en monde, on actualise  ---------------
				if this.grille_monde_use do	core.set_etape_aActualiser 2
					
				--- on actualise tout les mondes de tout le monde ---------------
				for nd_terrain in geometry where classof nd_terrain == Urba_terrain do
					if nd_terrain.grille_monde_resolution != val do 
						nd_terrain.grille_monde_resolution = val 
				
			)
			
			on grille_monde_position			set  val		do (		
				--- si on est en monde, on actualise  ---------------
				if grille_monde_use do	core.set_etape_aActualiser 2
						
				--- on actualise tout les monde de tout le monde ---------------
				for nd_terrain in geometry where classof nd_terrain == Urba_terrain do
					if nd_terrain.grille_monde_position != val do 
						nd_terrain.grille_monde_position = val 
				
			)
		)
		
	
		rollout rollout_global "Global" width:180 height:539
		(
			
			fn shape_filt 		obj = superclassof 	obj == shape
			fn geo_filt 			obj = superclassof 	obj == GeometryClass
			fn poly_filt 			obj = classof 			obj == Editable_Poly
			
			pickbutton 'btn_contour_pick' "+" pos:[10,12] width:16 height:16 filter:shape_filt autoDisplay:false align:#left
			listbox 'lbx_contours' "" pos:[10,29] width:160 height:10 align:#left
			GroupBox 'grp_contours' "Contours" pos:[5,-2] width:170 height:172 align:#left
			
			button 'btn_supprimer_contour' "-" pos:[25,12] width:16 height:16 align:#left
			pickbutton 'btn_relief_pick' "+" pos:[10,187] width:16 height:16 filter:geo_filt autoDisplay:false align:#left
			listbox 'lbx_reliefs' "" pos:[10,204] width:160 height:6 align:#left
			GroupBox 'grp_reliefs' "Reliefs" pos:[5,173] width:170 height:120 align:#left
			button 'btn_supprimer_relief' "-" pos:[25,187] width:16 height:16 align:#left
			spinner 'spn_hauteur' "" pos:[80,298] width:93 height:16 range:[-1e+10,1e+10,0] type:#worldunits align:#left
			label 'lbl4' "Hauteur:" pos:[10,298] width:61 height:14 align:#left
			
			
			
			fn actualiser =(
			/* 	lbx_contours.items 	= for contour_node in contours_nodes collect if contour_node != undefined then  contour_node.name else "<deleted>"
				lbx_reliefs.items 		= for relief_node in reliefs_nodes collect if relief_node != undefined then  relief_node.name else "<deleted>"
				btn_supprimer_contour.enabled 	=	 lbx_contours.selection	!= 0 
				btn_supprimer_relief.enabled 		=	 lbx_reliefs.selection	!= 0  */
			)
			
			
			
			
			
			on btn_contour_pick picked obj do
			(
				max modify mode
				ajouter_contour	obj
				actualiser ()
				lbx_contours.selection += 1				
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

		rollout rollout_grille "Grille" width:180 height:539
		(
		
			
			spinner 'spn_resolution' "" pos:[80,35] width:90 height:16 range:[1,1e+10,0] type:#worldunits align:#left
			label 'lbl_resolution' "Résolution :" pos:[15,34] width:59 height:13 align:#left
			spinner 'spn_posX' "" pos:[80,63] width:85 height:16 range:[-1e+10,1e+10,0] type:#worldunits align:#left
			spinner 'spn_posY' "" pos:[80,79] width:85 height:16 enabled:false range:[-1e+10,1e+10,0] type:#worldunits align:#left
			GroupBox 'grp_Position' "Position :" pos:[10,50] width:160 height:50 align:#left
			label 'lbl_posX' "x:" pos:[20,62] width:13 height:13 align:#left
			label 'lbl_posY' "y:" pos:[19,78] width:13 height:13 align:#left
			dropdownList 'ddl_reference' "" pos:[80,1] width:96 height:21 items:#("Monde", "Local") align:#left
			GroupBox 'grp_local' "Local" pos:[5,21] width:170 height:85 align:#left
			label 'lbl_type' "Type :" pos:[5,5] width:59 height:13 align:#left
			
			spinner 'spn_monde_resolution' "" pos:[80,123] width:90 height:16 range:[1,1e+10,0] type:#worldunits align:#left
			label 'lbl_monde_resolution' "Résolution :" pos:[15,122] width:59 height:13 align:#left
			spinner 'spn_monde_posX' "" pos:[80,151] width:85 height:16 range:[-1e+10,1e+10,0] type:#worldunits align:#left
			spinner 'spn_monde_posY' "" pos:[80,167] width:85 height:16 enabled:false range:[-1e+10,1e+10,0] type:#worldunits align:#left
			GroupBox 'grp_monde_position' "Position :" pos:[10,138] width:160 height:50 align:#left
			label 'lbl_monde_posX' "x:" pos:[20,150] width:13 height:13 align:#left
			label 'lbl_monde_posY' "y:" pos:[19,166] width:13 height:13 align:#left
			GroupBox 'grp_monde' "Monde" pos:[5,109] width:170 height:85 align:#left
			
			
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
							if not grille_monde_use do	core.actualiser ()
						)
			on spn_posX changed val do
			(	
							if grille_lier_pos do val.y = val.x
							grille_position.x			=	val
							if not grille_monde_use do	core.actualiser ()
							actualiser ()
						)
			on spn_posY changed val do
			(
							grille_position.y			=	val
							if not grille_monde_use do	core.actualiser ()
						)
			on ddl_reference selected sel do
			(
							grille_monde_use = if sel == 1 then true else false
							actualiser ()
							core.actualiser ()
						)
			on spn_monde_resolution changed val do
			(
							grille_monde_resolution	=	val
							if grille_monde_use do	core.actualiser ()
						)
			on spn_monde_posX changed val do
			(	
							grille_monde_position.x	=	val
							if grille_monde_use do	core.actualiser ()
						)
			on spn_monde_posY changed val do
			(
							grille_monde_position.y	=	val
							if grille_monde_use do	core.actualiser ()
						)
		)
		
		
/* 	rollout roll_aPropos 			"A propos" 	rolledUp:false	(
		label 'lbl_axeP' "Urba | V0.3.1 | 2018" pos:[5,2]  align:#left
		HyperLink 'hpl1' "c-pages.fr" pos:[5,15] address:"http://c-pages.fr" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
		HyperLink 'hpl2' "Git" pos:[145,15] address:"https://github.com/c-pages/cp-Urba-Cleanage" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
-- 		label 'lbl6' "2018" pos:[5,15] align:#left
	)

	
	 */
	
	
