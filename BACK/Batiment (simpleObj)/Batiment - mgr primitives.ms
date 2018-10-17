
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Primitives\\Batiment - Primitive - Plan vertical.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Primitives\\Batiment - Primitive - Plan horizontal.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Primitives\\Batiment - Primitive - Boite.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Primitives\\Batiment - Primitive - Boite U.ms"
filein "$userScripts\\cp-Urba\\Batiment (simpleObj)\\Primitives\\Batiment - Primitive - Boite L.ms"
	
	
	
struct str_mgr_primitives	(
	
	
	
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
	-- 	m_debug = false,
		m_dbgPrefix ="str_contruction_base",
		fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix,
		------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
		--------- TRANSFORMATION   ------------------------------------------------------------------------------------------------------
		fn transformer		_mesh		transf:	=(
			if classof transf == point3 do transf = transMatrix transf
			local transf_tab =#()
			for id_pt = 1 to   _mesh.numverts  do (
				local pos_base 	=  meshop.getVert  _mesh 	id_pt
				local pos_dest 	= pos_base * transf
				append transf_tab ( pos_dest - pos_base)
			)
			meshop.moveVert 	_mesh	#{1.._mesh.numverts} transf_tab
		),
		
		/* 
		createInstance  urba_primitive_planVertical
		createInstance  urba_primitive_planHorizontal
		createInstance  urba_primitive_boite_L
		createInstance  urba_primitive_boite_U
		createInstance  urba_primitive_boite
		 */
		
		--------- CREATION D'OBJETS PRIMITFS ------------------------------------------------------------------------------------------------------
		fn ajouter_plan_vertical	_mesh	long:0		ht:0			transf:		matID:			bool:false	=(
			
			---- on creer le sous objet model ---------------------
			local nv_plan	 = createInstance  urba_primitive_planVertical	longueur:	long		\
																								hauteur:		ht			
			
			if matID!= unsupplied do	nv_plan.matID 		= matID
			
			
			----- et on place la menuiserie si besoin ---------------
			local plan_Mesh = copy nv_plan.mesh
			if transf		!= unsupplied do	
				transformer			plan_Mesh			transf:transf
			
			
			--- on l'ajoute a notre mesh ----------
			if not bool 	then 	meshop.attach		_mesh		plan_Mesh
							else 		_mesh + plan_Mesh
			
			nv_plan
			
		), --- fin creer plan vertical	------------------
		fn ajouter_plan_horizontal	_mesh	long:0		prof:0			transf:		matID:			bool:false	=(
			
			---- on creer le sous objet model ---------------------
			local nv_plan	 = createInstance  urba_primitive_planHorizontal	longueur:	long		\
																									profondeur:	prof			
			
			if matID!= unsupplied do	nv_plan.matID 		= matID
			
			
			----- et on place la menuiserie si besoin ---------------
			local plan_Mesh = copy nv_plan.mesh
			if transf		!= unsupplied do	
				transformer			plan_Mesh			transf:transf
			
			
			--- on l'ajoute a notre mesh ----------
			if not bool 	then 	meshop.attach		_mesh		plan_Mesh
							else 		_mesh + plan_Mesh
			
			nv_plan
			
		), --- fin creer plan vertical	------------------
		fn ajouter_boite_L 			_mesh	long:0		prof:0		ht:0			sym:false		horiz: false		transf:			matID:		bool:false	=(
			
			---- on creer le sous objet model ---------------------
			local nvl_boite = createInstance  urba_primitive_boite_L	longueur:	long		\
																							hauteur:		ht			\
																							profondeur:	prof		\
																							symetrie:	sym		\
																							horizontal:	horiz		
			
			if matID!= unsupplied do	nvl_boite.matID 		= matID
			
			
			----- et on place la menuiserie si besoin ---------------
			local boite_Mesh = copy nvl_boite.mesh
			if transf		!= unsupplied do	
				transformer			boite_Mesh			transf:transf
			
			
			--- on l'ajoute a notre mesh ----------
			if not bool 	then 	meshop.attach		_mesh		boite_Mesh
							else 		_mesh + boite_Mesh
			
			nvl_boite
			
		), --- fin creer boite L	------------------
		fn ajouter_boite_U			_mesh	long:0		prof:0		ht:0			horiz: false		transf:			matID:		bool:false	=(
			
			---- on creer le sous objet model ---------------------
			local nvl_boite = createInstance  urba_primitive_boite_U	longueur:	long		\
																							hauteur:		ht			\
																							profondeur:	prof		\
																							horizontal:	horiz		
			
			if matID!= unsupplied do	nvl_boite.matID 		= matID
			
			
			----- et on place la menuiserie si besoin ---------------
			local boite_Mesh = copy nvl_boite.mesh
			if transf		!= unsupplied do	
				transformer			boite_Mesh			transf:transf
			
			
			--- on l'ajoute a notre mesh ----------
			if not bool 	then 	meshop.attach		_mesh		boite_Mesh
							else 		_mesh + boite_Mesh
			
			nvl_boite
			
		), --- fin creer boite L	------------------
		fn ajouter_boite 				_mesh	long:0		prof:0		ht:0			transf:			matID:			bool:false	=(
			
			---- on creer le sous objet model ---------------------
			local nvl_boite = createInstance  urba_primitive_boite		longueur:	long		\
																							hauteur:		ht			\
																							profondeur:	prof
			
			if matID!= unsupplied do	nvl_boite.matID 		= matID
			
			
			----- et on place la menuiserie si besoin ---------------
			local boite_Mesh = copy nvl_boite.mesh
			if transf		!= unsupplied do	
				transformer			boite_Mesh			transf:transf
			
			
			--- on l'ajoute a notre mesh ----------
			if not bool 	then 	meshop.attach		_mesh		boite_Mesh
							else 		_mesh + boite_Mesh
			
			nvl_boite
			
		) --- fin creer boite	------------------
	
)	----	fin struct	str_mgr_primitives --------------------




