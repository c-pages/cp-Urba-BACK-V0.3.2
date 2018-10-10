
include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Primitives\\Primitive - Boite.ms"

struct str_contruction_base	(
	
	
		fn transform_vertex		_mesh	id_debut:			id_fin:		transf:	=(
			if classof transf == point3 do transf = transMatrix transf
			local transf_tab =#()
			for id_pt = id_debut to  id_fin do (
				local pos_base 	=  meshop.getVert  _mesh 	id_pt
				local pos_dest 	= pos_base * transf
				append transf_tab ( pos_dest - pos_base)
			)
			meshop.moveVert 	_mesh	#{id_debut..id_fin} transf_tab
		),
		
		
		fn ajouter_cylindre 	_mesh	rayon:0		ht:0		transf:	matID:	=(
			
			--- on stock l'id du vertex pour pouvoir deplacer les point si besoin ----------------
			local id_vertex_debut 	= 	( meshop.getNumVerts _mesh + 1 )
			local id_face_debut 	= 	( meshop.getNumFaces  _mesh + 1 )
			
			
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
			
			
			--- on l'ajoute a notre mesh ----------
			meshop.attach		_mesh		nv_cylindre.mesh
			
			----- et on place la menuiserie si besoin ---------------
			if transf		!= unsupplied do	(
				transform_vertex			_mesh		id_debut:	id_vertex_debut	\
																id_fin:		(meshop.getNumVerts 	_mesh)	\
																transf:		transf
			)
			if matID!= unsupplied do (
				for id = id_face_debut to ( meshop.getNumFaces  _mesh ) do
					setFaceMatID _mesh  id 	matID
			)
			
		), --- fin creer boite	------------------
		
		
		
		fn ajouter_boite 	_mesh	long:0		prof:0		ht:0		transf:			matID:	=(
			
			--- on stock l'id du vertex pour pouvoir deplacer les point si besoin ----------------
			local id_vertex_debut = ( meshop.getNumVerts _mesh + 1 )
			
			
			---- on creer le sous objet model ---------------------
			local nvl_boite = createInstance  urba_prim_boite		longueur:	long		\
																					hauteur:		ht			\
																					profondeur:	prof
			
			if matID!= unsupplied do
				nvl_boite.matID 				= matID
			
			
			
			--- on l'ajoute a notre mesh ----------
			meshop.attach		_mesh		nvl_boite.mesh
			
			----- et on place la menuiserie si besoin ---------------
			if transf		!= unsupplied do	(
				
				
				transform_vertex			_mesh		id_debut:	id_vertex_debut	\
																id_fin:		(meshop.getNumVerts 	_mesh)	\
																transf:		transf
			)
			
		) --- fin creer boite	------------------
	
	
	
	
)




