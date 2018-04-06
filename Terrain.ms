

---- ecouteurs terrain ------------------
TERRAIN_ECOUTEUR_topo 		= undefined
TERRAIN_ECOUTEUR_transf 	= undefined
gc light:true
global TERRAIN_ECOUTEUR_topo, TERRAIN_ECOUTEUR_transf
---- ecouteurs terrain ------------------




plugin geometry  Urba_terrain
name:"Terrain"
classID:#(528514,174852)
category:"CP | Urba"
invisible:false
extends:editable_poly 
replaceUI:true 
version:0
(


		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	
		try if true  do ::debuger 	_txt	prefix:"urba | Urba_terrain"	  	var:var	 param:param	
		catch ()
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------



		include	 "$userScripts\\cp-Urba\\modules\\Terrain\\Terrain - core.ms" 

		local	core	=	str_terrain_node_core ()
		
		
		
		
		fn set_contour		_shp = core.set_contour		_shp 
		
		fn actualiser =(
			debug "actualiser"
			core.actualiser_contours  transf:$.transform
			core.construire ()
		)
		fn actualiser_reliefs =(
			core.construire ()
		)
		fn actualiser_contours =(
			core.actualiser_contours  transf:$.transform
			core.construire ()
		)
		fn initialiser =(
			core.initialiser		this			
		)
		
		
		fn aCommeContour	_node 	=	findItem this.contours_nodes	_node != 0
		fn aCommeRelief		_node 	=	findItem this.reliefs_nodes		_node != 0
		fn set_transform 		_mtrx		=	this.transformation = _mtrx
		
		fn ajouter_relief	_node =(
			if appendIfUnique this.reliefs_nodes	 _node do (
					this.rollout_terrain.actualiser ()
					actualiser_reliefs ()
				)
		)
		fn ajouter_contour		_node =(
			if appendIfUnique this.contours_nodes 	_node do (
				this.rollout_terrain.actualiser ()
				actualiser_contours ()
			)
		)
		
		
		parameters main rollout:rollout_terrain		(
			
			--- les nodes -----------
			contours_nodes		type:#nodeTab 		tabSize:0  		tabSizeVariable:true		--	 ui:btn_contour_pick		animatable:false		invisibleInTV:true
			reliefs_nodes			type:#nodeTab		tabSize:0  		tabSizeVariable:true		--	 ui:btn_relief_pick	 		animatable:false		invisibleInTV:true
			
			--- parametres divers -----------
			grille_largeur			type: #float	 	ui:spn_precision 			default:300.		 	animatable:false		invisibleInTV:true
			decallageZ				type: #float	 	ui:spn_decallageZ 			default:0.		 	animatable:false		invisibleInTV:true
			
			
			----  parametres perso  'private'	 ---------------
			contour_pts			type:#stringTab 		tabSize:0  						tabSizeVariable:true
			transformation			type: #matrix3	 	default:(matrix3 1 ) 		 	animatable:false		invisibleInTV:true
			
		)
		rollout rollout_terrain "Terrain" width:162 height:455
		(
			
			fn shape_filt 		obj = superclassof 	obj == shape
			fn geo_filt 			obj = superclassof 	obj == GeometryClass
			fn poly_filt 			obj = classof 			obj == Editable_Poly
			
			pickbutton 'btn_contour_pick' "+" pos:[10,49] width:16 height:16 filter:shape_filt autoDisplay:false align:#left
			spinner 'spn_precision' "" pos:[82,2] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			label 'lbl_precision' "Grille:" pos:[11,2] width:31 height:14 align:#left
			listbox 'lbx_contours' "" pos:[10,66] width:137 height:6 align:#left
			GroupBox 'grp_contours' "Contours" pos:[4,35] width:153 height:119 align:#left
			
			button 'btn_supprimer_contour' "-" pos:[25,49] width:16 height:16 align:#left
			pickbutton 'btn_relief_pick' "+" pos:[10,171] width:16 height:16 filter:geo_filt autoDisplay:false align:#left
			listbox 'lbx_reliefs' "" pos:[10,188] width:137 height:6 align:#left
			GroupBox 'grp_reliefs' "Reliefs" pos:[4,157] width:153 height:119 align:#left
			button 'btn_supprimer_relief' "-" pos:[25,171] width:16 height:16 align:#left
			spinner 'spn_decallageZ' "" pos:[82,18] width:76 height:16 range:[-1e+10,1e+10,0] type:#worldunits align:#left
			label 'lbl4' "Décallage Z:" pos:[11,18] width:61 height:14 align:#left
			
			fn actualiser =(
				lbx_contours.items 	= for contour_node in contours_nodes collect if contour_node != undefined then  contour_node.name else "<deleted>"
				lbx_reliefs.items 		= for relief_node in reliefs_nodes collect if relief_node != undefined then  relief_node.name else "<deleted>"
				btn_supprimer_contour.enabled 	=	 lbx_contours.selection	!= 0 
				btn_supprimer_relief.enabled 		=	 lbx_reliefs.selection	!= 0 
			)
			
			
			
			on rollout_terrain open do
				actualiser ()
			on btn_contour_pick picked obj do
			(
				max modify mode
				
				if appendIfUnique contours_nodes obj do (
					actualiser ()
					lbx_contours.selection += 1
					core.actualiser_contours ()
					core.construire ()
				)
			)
			on spn_precision changed val do
			(
					actualiser ()
					core.construire ()
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
					core.actualiser_contours ()
					core.construire ()
				)
			)
			on btn_relief_pick picked obj do
			(
				max modify mode
				
				if appendIfUnique reliefs_nodes	 obj do (
					actualiser ()
					lbx_reliefs.selection += 1
					core.construire ()
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
					core.construire ()
				)
			)
			on spn_decallageZ changed val do
			(
					core.construire ()
				
			)
		)
		

	--------------- CREATION  ----------------------------------------------------------------------------------------------------------------------
	tool create (
		on mousePoint click do	(
			nodeTM.translation =	worldPoint--- [0,0,0] 
			actualiser ()
			set_transform		nodeTM
			initialiser ()
			#stop
		)

	)

		
		
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on load 						do 	(
		debug "load du plugin"

		initialiser ()
	)
	on clone 	_original 	do (
		initialiser ()
	)
	on create do (
		
		debug "creation du plugin"
		initialiser ()
	)
	on update do	(
		debug "update du plugin"
-- 		initialiser ()
	)

)















