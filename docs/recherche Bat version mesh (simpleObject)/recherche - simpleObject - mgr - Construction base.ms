
include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Primitives\\Primitive - Boite.ms"

struct str_contruction_base	(
	
	
	
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
	-- 	m_debug = false,
		m_dbgPrefix ="str_contruction_base",
		fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix,
		------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
		--------- Placer un mesh ------------------------------------------------------------------------------------------------------
		fn transform_vertex		_mesh		transf:	=(
			if classof transf == point3 do transf = transMatrix transf
			local transf_tab =#()
			for id_pt = 1 to   _mesh.numverts  do (
				local pos_base 	=  meshop.getVert  _mesh 	id_pt
				local pos_dest 	= pos_base * transf
				append transf_tab ( pos_dest - pos_base)
			)
			meshop.moveVert 	_mesh	#{1.._mesh.numverts} transf_tab
		),
		
		
		
		
		
		--------- Creation d'objets simples ------------------------------------------------------------------------------------------------------
		fn ajouter_cylindre 	_mesh	rayon:0		ht:0		transf:	matID:	bool:false	=(
			
			--- on stock l'id du vertex pour pouvoir deplacer les point si besoin ----------------
			
			---- on creer le sous objet model ---------------------
			local nv_cylindre = createInstance  cylinder			radius:					rayon		\
																				height:					ht			\
																				heightsegs:				1	\
																				capsegs:				1	\
																				sides:					16\
																				smooth:					on	\
																				mapcoords:				on	\
																				realWorldMapSize:	on	\
																				slice:						off
																				
			local cyl_mesh = copy nv_cylindre.mesh
			
			if matID!= unsupplied do 
				for id = 1 to ( cyl_mesh.numverts) do
					setFaceMatID cyl_mesh  id 	matID
			
			----- et on place la menuiserie si besoin ---------------
			if transf		!= unsupplied do	
				transform_vertex			cyl_mesh			transf:transf
			
			--- on l'ajoute a notre mesh ----------
			if not bool 	then 	meshop.attach		_mesh		cyl_mesh
							else 		_mesh + cyl_mesh
			
			nv_cylindre
			
		), --- fin creer boite	------------------
		fn ajouter_boite 	_mesh	long:0		prof:0		ht:0		transf:			matID:	bool:false	=(
			
			---- on creer le sous objet model ---------------------
			local nvl_boite = createInstance  urba_prim_boite		longueur:	long		\
																					hauteur:		ht			\
																					profondeur:	prof
			if matID!= unsupplied do	nvl_boite.matID 		= matID
			
			
			----- et on place la menuiserie si besoin ---------------
			local boite_Mesh = copy nvl_boite.mesh
			if transf		!= unsupplied do	
				transform_vertex			boite_Mesh			transf:transf
			
			
			--- on l'ajoute a notre mesh ----------
			if not bool 	then 	meshop.attach		_mesh		boite_Mesh
							else 		_mesh + boite_Mesh
			
			nvl_boite
			
		) --- fin creer boite	------------------
	
	
)




