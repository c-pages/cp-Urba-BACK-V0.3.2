







struct str_urba_terrain_core ( 
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	
			try if true  do ::debuger 	_txt	prefix:"urba | str_urba_terrain_core"	  	var:var	 param:param	
			catch (),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	private
		m_plug,
		m_editeur_rollout ,
-- 		callbackItem,
-- 		m_editeur_rollout_ouvert = false,
	
		
	private
		fn creer_terrain = (
			
			debug "-------	Creation du modele	--------"
			
			debug "-------	m_plug.cadre_shape	" var:m_plug.cadre_shape	
			local nv_terrain 	= Urba_terrain ()			
			nv_terrain.set_contour	 	m_plug.cadre_shape	
			
-- 			nv_terrain.contour_node 		=  m_plug.cadre_shape			
			nv_terrain.grille_largeur		 	= 	m_plug.relief_precision
			nv_terrain.relief_node			=	m_plug.relief_node
			nv_terrain.actualiser ()
			
		),
		
-- 		topologyChanged


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
				creer_terrain ()
				redrawViews ()
			)
			
		),
		
		
		
		fn initialiser _plug =(
			m_plug = _plug
			/* 
			fn CallbackFn1 ev nds = (
			if classof  ( GetAnimByHandle nds[1] ) != Urba_terrain_mgr and classof  ( GetAnimByHandle nds[1] ) != Urba_terrain  do
				for nd_id in nds do (
					local nd = GetAnimByHandle nd_id
					case classof  nd of (
						Urba_terrain: nd.actualiser ()
-- 						Urba_terrain_mgr: nd.actualiser ()
					)
				)
			-- 		format "-->%\n" 
			)


				callbackItem = undefined
				gc light:true
				callbackItem = NodeEventCallback 	mouseup:true 	geometryChanged:CallbackFn1
				 */
				
			--editeur_rollout_ouvrir()
		)
	
	
	
)