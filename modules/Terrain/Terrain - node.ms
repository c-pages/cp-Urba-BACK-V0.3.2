

plugin geometry  Urba_terrain
name:"Terrain"
classID:#(715486,322784)
category:"CP | Urba"
invisible:true
extends:editable_poly 
replaceUI:true 
version:0
(


		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	
		try if true  do ::debuger 	_txt	prefix:"urba | Urba_terrain"	  	var:var	 param:param	
		catch ()
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------




		include	 "$userScripts\cp-Urba\modules\Batiment\\divers\\Batiment - Geometrie.ms"
		
		
		local geo		= 	str_geometrie 		m_plug:this
		
		
		parameters main rollout:params		(
			terrain_shape			type:#node 		ui:btn_trace_pick		animatable:false		invisibleInTV:true
			terrain_precision		type: #float	 	ui:spn_precision 		default:300.		 	animatable:false		invisibleInTV:true
		)
		rollout params "Terrain" width:162 height:49
		(
			
			fn shape_filt 		obj = superclassof obj == shape
			
			pickbutton 'btn_trace_pick' "Pick shape" pos:[16,4] width:125 height:20 filter:shape_filt autoDisplay:true align:#left
			spinner 'spn_precision' "" pos:[72,26] width:76 height:16 range:[20,1e+06,0] type:#worldunits align:#left
			label 'lbl_precision' "Précision:" pos:[15,25] width:44 height:14 align:#left
		)
		
		
		
		
		fn get_BB =(
			local result #([0,0,0],[0,0,0])
			local pts_shape = #()
			for i = 1 to numSplines  this.terrain_shape do 
				append pts_shape ( for j= 1 to numKnots 	this.terrain_shape collect getKnotPoint this.terrain_shape i j )
			
			local minX = minY 	= minZ =1e10
			local maxX = maxY 	= maxZ = -1e10
			
			for pts_face in pts_shape do 
				for pt in pts_face do (
					if pt.x < minX 		do minX = pt.x 
					if pt.y < minY 	do minY = pt.y
					if pt.z < minZ 		do minZ = pt.z 
					if pt.x > maxX 	do maxX = pt.x 
					if pt.y > maxY 	do maxY = pt.y 
					if pt.z > maxZ 	do maxZ = pt.z 
				)
			
			#([minX,minY,minZ],[maxX,maxY,maxZ])
			
		)
		
		fn quadriller   	 = 	with redraw off (
			
			debug	"quadriller !!!!!"
			
-- 			modPanel.setCurrentObject _node.modifiers[#Quadriller]			
-- 			subobjectLevel = 4
			
			
			
			local offset = [ -20,-20,0 ]			
			
			--- BB ---
			local BB = get_BB ()
			
			---- sur X ----------------------------------------------------------------------------------------
			local plane_normal = Point3 1 0 0 
			local plane_center = BB[1]
			
			local plane_center_abs = plane_center 
			plane_center_abs.x = ( floor ( plane_center_abs.x / terrain_precision ) ) * terrain_precision 
			plane_center_abs.y = ( floor ( plane_center_abs.y / terrain_precision ) ) * terrain_precision 			
			plane_center.x = plane_center_abs.x  + offset.x
			plane_center.y = plane_center_abs.y  + offset.y
			/* 
			local b_continue = true
			while  plane_center.x < BB[2].x and b_continue do (
				this.delegate.SetOperation	#Slice
				
				plane_center.x 		+= terrain_precision
				
				this.delegate.SetSlicePlane 	plane_normal	 plane_center
				
				this.delegate.Commit() 
				
-- 				--- annulation ? ----------
-- 				if keyboard.escPressed do 
-- 					if queryBox "annuler ?" do 
-- 						b_continue = false
			)
			if b_continue do (
			---- sur Y ----------------------------------------------------------------------------------------
				local plane_normal = Point3 0 1 0
				local plane_center = BB[1]
				
				local plane_center_abs = plane_center
				plane_center_abs.x = ( floor ( plane_center_abs.x / m_plug.relief_precision ) ) * terrain_precision
				plane_center_abs.y = ( floor ( plane_center_abs.y / m_plug.relief_precision ) ) * terrain_precision				
				plane_center.x = plane_center_abs.x	+ offset.x
				plane_center.y = plane_center_abs.y 	+ offset.y
				
				while  plane_center.y < BB[2].y do (
					_cible.SetOperation	#Slice
					
					plane_center.y += terrain_precision
					
		-- 			point size:50 pos:plane_center
					
					this.delegate.SetSlicePlane 	plane_normal	 plane_center
					
					this.delegate.Commit() 
					
					
-- 					--- annulation ? ----------
-- 					if keyboard.escPressed do 
-- 						if queryBox "annuler ?" do 
-- 							b_continue = false
				)
			)
			 */
			b_continue
			
			subobjectLevel = 0
			
		)-- fin fonction
		
		
		
		
		fn construire =(
			
			debug "construire"
			debug "terrain_shape" var:this.terrain_shape
			
			if this.terrain_shape != undefined do (
				
				--- mise à jour des points ----------------
				local pts_shape = #()
				for i = 1 to numSplines  this.terrain_shape do 
					append pts_shape ( for j= 1 to numKnots 	this.terrain_shape collect getKnotPoint this.terrain_shape i j )
				
				debug "pts_face" var:pts_face
				
				geo.vider ()
				for pts_face in pts_shape do 
					geo.face	pts_face
				
				
				quadriller ()
			)
		)


		fn actualiser =(

			construire ()
			
		)
		fn initialiser =(

			geo.m_plug = this
			
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
		debug "shape : " var:surface_node
-- 		initialiser ()
	)

)

















