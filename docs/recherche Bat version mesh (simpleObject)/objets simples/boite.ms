
plugin simpleObject		simple_boite
name:"simple_boite"
classID:#(736867,153465)
category:"Scripted Primitives"
-- invisible:true
(
	parameters transfo
	(
		transformation	type:#matrix3		default:(matrix3 1)
		
	)
	parameters main rollout:roll_params
	(
		largeur 			type:#worldUnits 	ui:spn_largeur 			default:100
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:250
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:30
		
		matId			type:#integer 			ui:spn_matId 				default:1
	)
	
	
	
	
	
	rollout roll_params "Two Faces Parameters"
	(
		spinner spn_largeur 		"largeur" 		type:#worldunits range:[-1000,1000,0]
		spinner spn_hauteur 		"hauteur" 		type:#worldunits range:[-1000,1000,0]
		spinner spn_profondeur 	"profondeur" 	type:#worldunits range:[-1000,1000,0]
		
		spinner spn_matId 			"matId" 			type:#integer	 range:[1,1000,1]
	)
	
	on buildMesh do
	(
-- 		format "build boite \n"
		--- on vide le mesh ----------
		delete mesh
		
		--- on place les points ---------
		local pt_1	=	[0,0,0]
		local pt_2	=	[largeur,0,0]
		local pt_3	=	[largeur,0,hauteur]
		local pt_4	=	[0,0,hauteur]
		local pt_5	=	[0,profondeur,hauteur]
		local pt_6	=	[largeur,profondeur,hauteur]
		local pt_7	=	[0,profondeur,0]
		local pt_8	=	[largeur,profondeur,0]
		
		local pts 	= #(pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8) 
		
		--- on transform les points ---------------
		for i = 1 to pts.count do 	pts[i] *= transformation
		
		--- on creer les vertex ---------
		setMesh 	mesh 	verts:pts
		
		----- on creer les faces --------------
		local faces = #(	#(1,2,3,4) , #(6,5,4,3) , #(2,8,6,3), #(8,7,5,6) , #(7,1,4,5), #(7,8,2,1) )
		for face in faces do 
			meshop.createPolygon mesh	face  	--matID:51	--(matId)
		
		----- matID -------
		for i = 1 to mesh.faces.count do
			setFaceMatID 	mesh	i  matId
		
		
		---- on les retourne si besoin --------
		if largeur * profondeur * hauteur < 0 do meshop.flipNormals	mesh		#{1..mesh.faces.count}
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box  tm:(inverse transformation)
		
	)
	
	tool create
	(
		on mousePoint click do
		case click of
		(
			1: nodeTM.translation = gridPoint
			3: #stop
		)
		on mouseMove click do
		case click of
		(
			2: (largeur = abs gridDist.x; profondeur = abs gridDist.y)
			3: hauteur = gridDist.z
		)
	)
)