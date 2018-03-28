







struct str_urba_terrain_core ( 
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	
			try if true  do ::debuger 	_txt	prefix:"urba | str_urba_terrain_core"	  	var:var	 param:param	
			catch (),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	private
		m_plug,
		m_editeur_rollout ,
-- 		m_editeur_rollout_ouvert = false,
	
		
	private
		fn quadriller  _node 		_cible 	 = 	with redraw off (
			
			debug	"quadriller !!!!!"
			
			modPanel.setCurrentObject _node.modifiers[#Quadriller]			
			subobjectLevel = 4
			
			
			
			local offset = [ -20,-20,0 ]			
			
			--- BB ---
			TM_BB = ( matrix3 1)
			translate TM_BB 	_node.pos
			local BB = nodeGetBoundingBox _node  TM_BB
			
			---- sur X ----------------------------------------------------------------------------------------
			local plane_normal = ( Point3 1 0 0 ) * _node.transform
			local plane_center = BB[1]
			
			local plane_center_abs = plane_center + _node.pos
			plane_center_abs.x = ( floor ( plane_center_abs.x / m_plug.relief_precision ) ) * m_plug.relief_precision 
			plane_center_abs.y = ( floor ( plane_center_abs.y / m_plug.relief_precision ) ) * m_plug.relief_precision 			
			plane_center.x = plane_center_abs.x - _node.pos.x + offset.x
			plane_center.y = plane_center_abs.y - _node.pos.y + offset.y
			
			local b_continue = true
			while  plane_center.x < BB[2].x and b_continue do (
				_cible.SetOperation	#Slice
				
				plane_center.x 		+= m_plug.relief_precision
				
				_cible.SetSlicePlane 	plane_normal	 plane_center
				
				_cible.Commit() 
				
				--- annulation ? ----------
				if keyboard.escPressed do 
					if queryBox "annuler ?" do 
						b_continue = false
			)
			if b_continue do (
			---- sur Y ----------------------------------------------------------------------------------------
				local plane_normal = Point3 0 1 0
				local plane_center = BB[1]
				
				local plane_center_abs = plane_center + _node.pos
				plane_center_abs.x = ( floor ( plane_center_abs.x / m_plug.relief_precision ) ) * m_plug.relief_precision 
				plane_center_abs.y = ( floor ( plane_center_abs.y / m_plug.relief_precision ) ) * m_plug.relief_precision 				
				plane_center.x = plane_center_abs.x - _node.pos.x	+ offset.x
				plane_center.y = plane_center_abs.y - _node.pos.y	+ offset.y
				
				while  plane_center.y < BB[2].y do (
					_cible.SetOperation	#Slice
					
					plane_center.y += m_plug.relief_precision
					
		-- 			point size:50 pos:plane_center
					
					_cible.SetSlicePlane 	plane_normal	 plane_center
					
					_cible.Commit() 
					
					
					--- annulation ? ----------
					if keyboard.escPressed do 
						if queryBox "annuler ?" do 
							b_continue = false
				)
			)
			
			b_continue
			
			subobjectLevel = 0
			
		), -- fin fonctoin
		
		fn creer_terrain = (
			
			max modify mode
			
			debug "----	Creation du cadre	----"
-- 			local cadre 		= m_plug.cadre_shape
			
			debug "m_plug.cadre_shape" var:m_plug.cadre_shape
			local nv_terrain 	= Urba_terrain ()
			nv_terrain.terrain_shape 		= m_plug.cadre_shape
			debug "nv_terrain.terrain_shape " var:nv_terrain.terrain_shape 
			nv_terrain.terrain_precision 	= m_plug.relief_precision
			nv_terrain.actualiser ()
			
			/* 
			local cadre_ref 	= reference	cadre
			local quadrillage 	= edit_Poly name:"Quadriller"
			addModifier cadre_ref 	quadrillage
			quadriller	cadre_ref		quadrillage	 */
-- 			resumeEditing()
		),
		
		
	public
		fn editeur_rollout_ouvrir =(
			
			
			
			m_editeur_rollout  					= fileIn	 "$userScripts\cp-Urba\Modules\Terrain\Terrain - rollouts.ms" 
			createDialog m_editeur_rollout
-- 			m_editeur_rollout_ouvert = true
		),
		fn editeur_rollout_fermer =(
			destroyDialog m_editeur_rollout
-- 			m_editeur_rollout_ouvert = false
		),
		fn editeur_rollout_estOuvert = m_editeur_rollout.open ,
		fn get_editeur_rollout = m_editeur_rollout,
		
		
		
		
		fn actualiser =(
			
			if m_plug.relief_node != undefined and m_plug.cadre_shape != undefined do (
				debug "-------	Creation du modele	--------"
				creer_terrain ()
			)
			
		),
		
		
		
		fn initialiser _plug =(
			m_plug = _plug
			--editeur_rollout_ouvrir()
		)
	
	
	
)