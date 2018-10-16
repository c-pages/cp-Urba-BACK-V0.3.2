
plugin simpleObject		urba_primitive_boite
name:"Boite"
classID:#(0x3046a558, 0x2e92f235)
category:"CP | Primitives"
-- invisible:true
(
	
	parameters main rollout:roll_params
	(
		longueur 		type:#worldUnits 	ui:spn_longueur 			default:0
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:0
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:0
		
		matId			type:#integer 			ui:spn_matId 				default:1
		
		--- non utilisé : pour compatibilité avec boite en L et en U ------------------
		symetrie			type:#boolean 
		horizontal		type:#boolean
		--- non utilisé	------------------
		
	)
	
	rollout roll_params "boite"
	(
		group "Global" (
			spinner spn_longueur 		"Longueur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 	"Profondeur" 	type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 		"Hauteur" 		type:#worldunits range:[0,1e20,0]
		)		
		group "Mat ID" (
			spinner spn_matId 			"MatId" 			type:#integer	 range:[1,1000,1]
		)
	)
	
	on hasUVW do map_coords
		
	on setGenUVW bool do map_coords = bool
		
	
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
		
		----- on creer les faces --------------
		local faces = #(	[1,2,3], [1,3,4],		[2,8,6], [2,6,3],		[7,1,4], [7,4,5]  ,		[4,3,6], [4,6,5],		[8,7,5], [8,5,6],		[2,1,7], [2,7,8] )
	
		--- mat ID ------
		local matIDs	= for i in faces collect MatId
		
		--- on creer les vertex ---------
		setMesh 	mesh 	verts:pts	faces:faces	materialIDs:matIDs
		
		----- On clean le mesh 	--------------
		meshop.autoSmooth		mesh 	#{1..mesh.numfaces} 		10
		meshop.autoEdge 		mesh 	#{1..mesh.Edges.count}	10	
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		
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


