
plugin simpleObject		urba_prim_boite
name:"Boite"
classID:#(0x55f6e4c7, 0x22f553a7)
category:"CP | Primitives"
(
	
	parameters main rollout:roll_params
	(
		longueur 		type:#worldUnits 	ui:spn_longueur 			default:100
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:250
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:30
		
		matId			type:#integer 			ui:spn_matId 				default:1
	)
	
	rollout roll_params "Two Faces Parameters"
	(
		spinner spn_longueur 		"longueur" 		type:#worldunits range:[0,1e20,0]
		spinner spn_profondeur 	"profondeur" 	type:#worldunits range:[0,1e20,0]
		spinner spn_hauteur 		"hauteur" 		type:#worldunits range:[0,1e20,0]
		
		spinner spn_matId 			"matId" 			type:#integer	 range:[1,1000,1]
	)
	
	on buildMesh do
	(
		
		--- on vide le mesh ----------
		delete mesh
		
		--- on place les points ---------
		local pt_1	=	[0,0,0]
		local pt_2	=	[longueur,0,0]
		local pt_3	=	[longueur,0,hauteur]
		local pt_4	=	[0,0,hauteur]
		local pt_5	=	[0,profondeur,hauteur]
		local pt_6	=	[longueur,profondeur,hauteur]
		local pt_7	=	[0,profondeur,0]
		local pt_8	=	[longueur,profondeur,0]
		
		local pts 	= #(pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8) 
		
		--- on creer les vertex ---------
		setMesh 	mesh 	verts:pts
		
		----- on creer les faces --------------
		local faces = #(	#(1,2,3,4) , #(6,5,4,3) , #(2,8,6,3), #(8,7,5,6) , #(7,1,4,5), #(7,8,2,1) )
		for face in faces do 
			meshop.createPolygon mesh	face 
		
		----- matID -------
		for i = 1 to mesh.faces.count do
			setFaceMatID 	mesh	i  matId
		
		---- on les retourne si besoin --------
		if longueur * profondeur * hauteur < 0 do meshop.flipNormals	mesh		#{1..mesh.faces.count}
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box
		
	) --------- fin on build mesh --------------------------
	
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				4: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	hauteur 					= length ( gridPoint - pt_hauteur )
			)
		
	) ----- fin tool create -------------
) --------- fin plugin --------------


