

plugin geometry 	 Urba_terrain_node
name:"Terrain"
classID:#(836115,762584)
category:"CP | Urba"
invisible:false
extends:point 
replaceUI:true 
version:0
(






editable_poly




		fn update =(

			format " update :%\n" update
			format " map :%\n" map
			

		)




		parameters main rollout:params
		(
			--     bendamt type:#float animatable:true ui:bendamt default:0.0
			--     on bendamt set val do delegate.angle = val
		)
		rollout params "SupaMod Parameters" width:162 height:27		(
			button 'btn_update' "Update" pos:[29,6] width:104 height:17 align:#left

			on btn_update pressed  do update ()
			-- 	  
		)
)

















