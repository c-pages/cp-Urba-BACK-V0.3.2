

plugin geometry  Urba_terrain
name:"Terrain"
classID:#(354345,456434)
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



		include	 "$userScripts\\cp-Urba\\modules\\Terrain\\Terrain - node - core.ms" 

		local	core	=	str_terrain_node_core ()
		
		
		
		
		fn set_contour		_shp = core.set_contour		_shp 
		
		fn actualiser =(

			core.construire ()
			redrawViews ()
		)
		fn actualiser_relief =(
			
			core.construire ()
			redrawViews ()
		)
		fn actualiser_contour =(
			core.actualiser_contour()
			core.construire ()
			redrawViews ()
		)
		fn initialiser =(
			core.initialiser		this			
		)
		
		
		parameters main rollout:params		(
			contour_node		type:#node 		ui:btn_contour_pick		animatable:false		invisibleInTV:true
			relief_node			type:#node 		/* ui:btn_trace_pick	 */	animatable:false		invisibleInTV:true
			grille_largeur		type: #float	 	ui:spn_precision 		default:300.		 	animatable:false		invisibleInTV:true
			
			---- 
			contour_pts		type:#stringTab 	tabSize:0  		tabSizeVariable:true
			
-- 			on contour_node set 	_node  do 	set_contour 	_node
			
		)
		rollout params "Terrain" width:162 height:143
		(
			
			fn shape_filt 		obj = superclassof obj == shape
			
			pickbutton 'btn_contour_pick' "Pick shape" pos:[8,23] width:125 height:20 filter:shape_filt autoDisplay:true align:#left
			spinner 'spn_precision' "" pos:[58,82] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			label 'lbl_precision' "Précision:" pos:[8,82] width:44 height:14 align:#left
			pickbutton 'btn_relief_pick' "Pick relief" pos:[8,59] width:125 height:20 filter:shape_filt autoDisplay:true align:#left
			label 'lbl_contour' "Contour:" pos:[8,7] width:120 height:13 align:#left
			label 'lbl_relief' "Relief:" pos:[8,44] width:40 height:13 align:#left
			checkbox 'chk_invert' "Invert" pos:[8,100] width:98 height:15 align:#left
			
			on btn_contour_pick picked obj do
			(
				actualiser ()
			)
			on spn_precision changed val do
			(
				actualiser ()
				
			)
			on btn_relief_pick picked obj do
			(
				actualiser ()
				
			)
			on chk_invert changed state do
			(
				actualiser ()
				
			)
		)
		

	--------------- CREATION  ----------------------------------------------------------------------------------------------------------------------
	tool create (
		on mousePoint click do	(
			nodeTM.translation = worldPoint
			core.actualiser ()

			#stop
		)

	)

		
		
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on load 						do 	(
		debug "load du plugin"



		initialiser ()
	)
	on clone 	_original 	do (
-- 		debug "clone du plugin"
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
















