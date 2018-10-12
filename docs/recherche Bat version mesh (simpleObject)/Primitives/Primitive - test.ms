
include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\recherche - simpleObject - mgr - Construction base.ms"

clearListener ()
plugin simpleObject		urba_prim_test
name:"TEST"
classID:#(0xaa9b842, 0x5d8f876b)
category:"CP | Primitives"
(
	
	local mgr_constr	=	str_contruction_base ()
	
	local ajouter
	
	fn transform_vertex		_mesh	id_debut:1			id_fin:		transf:	=(
		if id_fin == unsupplied do id_fin = _mesh.numverts 
		if classof transf == point3 do transf = transMatrix transf
		local transf_tab =#()
		for id_pt = id_debut to  id_fin do (
			local pos_base 	=  meshop.getVert  _mesh 	id_pt
			local pos_dest 	= pos_base * transf
			append transf_tab ( pos_dest - pos_base)
		)
		meshop.moveVert 	_mesh	#{id_debut..id_fin} transf_tab
	)
	
	
	fn creer_boite 		long:0		prof:0		ht:0		transf:			matID:	=(
		
		---- on creer le sous objet model ---------------------
		local nvl_boite = createInstance  urba_prim_boite		longueur:	long		\
																				hauteur:		ht			\
																				profondeur:	prof
		if matID!= unsupplied do	nvl_boite.matID 		= matID
		
		
		----- et on place la menuiserie si besoin ---------------
		local boite_Mesh = copy nvl_boite.mesh
		if transf		!= unsupplied do	
			transform_vertex			boite_Mesh			transf:transf
		
		format "nvl_boite : %\n" nvl_boite
		nvl_boite
		
	) --- fin creer boite	------------------

	
	
	
	
	
	
	
	
	parameters main rollout:roll_params
	(
		monMaxObject		type:#maxObject
	)
	
	rollout roll_params "Two Faces Parameters" width:162 height:98
	(
		button 'btn1' "Button" pos:[24,30] width:123 height:27 align:#left
		
		checkbox 'chk1' "Checkbox" pos:[40,76] width:43 height:8 align:#left
		
		on btn1 pressed do
			ajouter ()
		on chk1 changed state do
	(
	
		)
	)
	
	
	
	fn ajouter =(
		format "Ajouter\n"
		monMaxObject = creer_boite long:		10			\
												prof:		10			\
												ht:		10				\
												matID:	10		\
												bool:		true
		format "monMaxObject : %\n" monMaxObject
		redrawviews ()
	)
	
	
		
	on buildMesh do
	(
		
		--- on vide le mesh ----------
		delete mesh
		if monMaxObject != undefined do 
			mesh + monMaxObject.mesh
		
		
	) --------- fin on build mesh --------------------------
	
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: 	#stop
			)
	
	) ----- fin tool create -------------
) --------- fin plugin --------------
