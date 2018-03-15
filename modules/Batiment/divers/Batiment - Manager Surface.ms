


----------------- Manager de la surface		------------------------------------------
struct str_mgr_surfaces (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
-- 	m_debug = true,
	m_debug = false,
	m_dbgPrefix ="urba | str_surfaces",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	
	
	---- Pointeurs divers --------------------
	public
		m_plug,			---- le plugin: 'this' -----
		
-- 	private
		
		m_outils					= str_shape_outils (),
		
		
	---- FONCTIONS ----------------------------------------------------------------
	private
		m_points =#(),
	
	
	
	--- Aquisition shape ---------------------
		fn scanner_points 	_shape	=(
			
			local ptsSurface				=#()
			
			---- On chope les points de la surface a scanner -----------
			for id_pt = 1 to ( numKnots 	_shape 	1 ) do	(
				local pt_shape 	= getKnotPoint 	_shape 	1 	id_pt
				local pt_surface 	= pt_shape * inverse  _shape.transform
				append ptsSurface 	 pt_surface
			)
			
			
			--- on fait tourner les spline dans le meme sens ----
			if not m_outils.est_sensPositif 	ptsSurface 	 do
				trace_absolu = m_outils.changer_sens		ptsSurface
			
			ptsSurface
			
		),
		fn valider_shape 		_shape 	=(
			
			local id_premiertraceFerme 	= 0
			local b_result 						= true
			
			--- on ne prend que des splineShape -----
			if classOf _shape !=	line	 do(
				messagebox "Attention ! Le shape piqué doit être une Line."
				b_result = false
			) 
			
			--- on ne prend que la premiere spline fermée -----
			if b_result and numSplines _shape > 1 do (
				messagebox "Attention ! Le shape piqué doit posséder une seule spline."
				b_result = false
			) 
			
			--- si la spline n'est pas close  -----------
			if b_result and not 	isClosed  _shape 1 then (
				messagebox "Attention ! Le shape piqué doit être clos."
				b_result = false
			) 
			
			b_result
			
		),
		
		
		
	---- INTERFACE ----------------------------------------------------------------
	public
	--- Initialisation ---------------------
		fn initialiser _plug =(
			debug "initialiser"
			m_plug 				= _plug
		),
		
		
	--- Actualisation ---------------------
		fn actualiser  =(
			
			debug "actualiser"
			
			local pts_surface 
			m_points = #()
			if m_plug.surface_node != undefined do (
				
				--- on scanne les points ---- 
				pts_surface = 	scanner_points		m_plug.surface_node		
				
				--- on gere les OPTIMISATIONS  ----
				if m_plug.optim_souder			do	m_outils.souder				&pts_surface		m_plug.optim_souder_seuil
				if m_plug.optim_orthonormer	do	m_outils.orthonormer		&pts_surface		m_plug.optim_ortho_seuil
				if m_plug.optim_aplanir			do	m_outils.aplanir				&pts_surface		m_plug.optim_aplanir_seuil
				if m_plug.optim_aligner			do	m_outils.aligner				&pts_surface		m_plug.optim_aligner_seuil
				if m_plug.optim_projeter		do	m_outils.projeter			&pts_surface
				
				m_points = pts_surface
				
			)
			
			debug "m_points" var:m_points
			
		),
		
		
	--- Accession ---------------------
		fn get_points =(
			debug "get_points"
			debug "m_points" var:m_points
			/* 
			debug "actualiser"
			
			local pts_surface 
			
			if m_plug.surface_node != undefined do (
				
				--- on scanne les points ---- 
				pts_surface = 	scanner_points		m_plug.surface_node		
				
				--- on gere les OPTIMISATIONS  ----
				if m_plug.optim_souder			do	m_outils.souder				&pts_surface		m_plug.optim_souder_seuil
				if m_plug.optim_orthonormer	do	m_outils.orthonormer		&pts_surface		m_plug.optim_ortho_seuil
				if m_plug.optim_aplanir			do	m_outils.aplanir				&pts_surface		m_plug.optim_aplanir_seuil
				if m_plug.optim_aligner			do	m_outils.aligner				&pts_surface		m_plug.optim_aligner_seuil
				if m_plug.optim_projeter		do	m_outils.projeter			&pts_surface
				
			)
			
			pts_surface 
			*/
			deepcopy  m_points

		),	
		
		/* 
		fn get_axePrincipal_CORRECT = m_outils.get_axePrincipal_mtrx_CORRECT 		( get_points () ),
		 */
		fn get_axePrincipal 	= m_outils.get_axePrincipal_mtrx 		( get_points () ),
		fn get_axeP_BB			= m_outils.get_axePrincipal_BB 		( get_points () )  ( get_axePrincipal () ),
		fn get_mur_cardinal   	_pt1	_pt2	 =(
			local result 
			local norm_mur = normalize	(	_pt2	 - _pt1 )
		
			local norm_OuestEst 	= [1,0,0]
			if abs norm_mur.x > abs norm_mur.y then (
				if norm_mur.x > 0 then
						result = #sud
				else
						result = #nord
			) else (
				if norm_mur.Y > 0 then
						result = #est
				else
						result = #ouest
			)
			
		),
		fn est_pignon 	_id			=
			m_outils.estPignon 	( get_points () )		_id,
		
		
		
		fn creer_shape 	 = (
			ss = SplineShape pos:(get_points () ) [1]
		  addNewSpline ss
			for pt in (get_points () ) do
			addKnot ss 1 #corner #line pt
			
		  updateShape ss
			ss
		),
		
		
		
		
		
		--- Assigner nouveau shape  ---------------------
		fn assigner 	_shape  =(
			
			debug "assigner"
			
			if _shape != undefined do (
				
				---- si pas valide on clean -------
				if not valider_shape 		_shape then 					
					m_plug.surface_node 				= undefined
					
				--- sinon on assigne les points de base ---- 
				else 	m_plug.surface_node				= 	_shape
				
				actualiser ()
				
			)
			
			debug "surface_node" 	var:m_plug.surface_node
			
		)
		
		
		
) -- fin struct Surface ------------------------


