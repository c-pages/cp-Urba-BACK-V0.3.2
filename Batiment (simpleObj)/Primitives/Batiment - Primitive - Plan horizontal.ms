
plugin simpleObject		urba_primitive_planHorizontal
name:"Plan horizontal"
classID:#(0x66aff812, 0x7e864a94)
category:"CP | Primitives"
-- invisible:true
(
	
	parameters main rollout:roll_params
	(
		longueur 		type:#worldUnits 	ui:spn_longueur 			default:0
		profondeur		type:#worldUnits 	ui:spn_profondeur 			default:0
		
		matId			type:#integer 			ui:spn_matId 				default:1
	)
	
	rollout roll_params "boite"
	(
		group "Global" (
			spinner spn_longueur 		"Longueur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur	 	"Profondeur" 		type:#worldunits range:[0,1e20,0]
		)		
		group "Mat ID" (
			spinner spn_matId 			"MatId" 			type:#integer	 range:[1,1000,1]
		)
	)
	
	on buildMesh do
	(
		
		--- on vide le mesh ----------
		delete mesh
		
		--- on place les points ---------
		local pt_1		=	[0,0,0]
		local pt_2		=	[longueur,0,0]
		local pt_3		=	[longueur,profondeur,0]
		local pt_4		=	[0,profondeur, 0]		
		local pts	= #(pt_1, pt_2, pt_3, pt_4) 
		
		----- on creer les faces --------------
		local faces = #(	[1,2,3], [1,3,4] )
		
		--- on creer les vertex ---------
		setMesh 	mesh 	verts:pts	faces:faces	materialIDs:#(matId, matId)
		
		--- smoothing group ---------
		setFaceSmoothGroup mesh 1 1
		setFaceSmoothGroup mesh 2 1
		
		---- on clean les edges ---------
		meshop.autoEdge mesh #{1..mesh.Edges .count}	45.
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box
		
	) --------- fin on build mesh --------------------------
	
	tool create
	(
		local pt_debut
		local pt_profondeur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				3: #stop
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
				3:	profondeur 					= length ( gridPoint - pt_profondeur )
			)
		
	) ----- fin tool create -------------
) --------- fin plugin --------------

