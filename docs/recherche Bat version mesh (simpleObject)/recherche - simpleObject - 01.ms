
plugin simpleObject		ssObject_1
name:"ssObject_1"
classID:#(156789,55253)
category:"Scripted Primitives"
invisible:true
(
	parameters transfo
	(
		transformation	type:#matrix3	
	)
	parameters main rollout:roll_params
	(
		largeur 			type:#worldUnits 	ui:spn_largeur 			default:100
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:250
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:30
	)
	
	
	
	
	
	rollout roll_params "Two Faces Parameters"
	(
		spinner spn_largeur 		"largeur" 		type:#worldunits range:[-1000,1000,0]
		spinner spn_hauteur 		"hauteur" 		type:#worldunits range:[-1000,1000,0]
		spinner spn_profondeur 	"profondeur" 	type:#worldunits range:[-1000,1000,0]
	)
	
	on buildMesh do
	(
		--- on place les points ---------
		local pt_1	=	[0,0,0]
		local pt_2	=	[largeur,0,0]
		local pt_3	=	[largeur,0,hauteur]
		local pt_4	=	[0,0,hauteur]
		local pt_5	=	[0,profondeur,hauteur]
		local pt_6	=	[largeur,profondeur,hauteur]
		local pts 	= #(pt_1, pt_2, pt_3, pt_4, pt_5, pt_6) 
		
		--- on transform les points ---------------
		for i = 1 to pts.count do 	pts[i] *= transformation
		
		--- on creer les vertex ---------
		setMesh 	mesh 	verts:pts
		
		----- on creer les faces --------------
		meshop.createPolygon mesh	#(1,2,3,4)  smGroup:1 		matID:1
		meshop.createPolygon mesh	#(6,5,4,3)  smGroup:2 		matID:1
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box  tm:(inverse transformation)
		
	)
	
)







plugin simpleObject compos_de_ssObj
name:"compos_de_ssObj"
classID:#(354488,3588718)
category:"Scripted Primitives"
(
-- 	local ssObj_1
	
	
	
	parameters main rollout:params
	(
		length 	type:#worldUnits 	ui:length 	default:1E-3
		width 	type:#worldUnits 	ui:width 	default:1E-3
		height 	type:#worldUnits 	ui:height 	default:1E-3
		decal 	type:#worldUnits 	ui:decal 		default:200
		rotat		type:#worldUnits 	ui:rotation 	default:1E-3

		
		etages	type:#integer		 ui:etages	 default:0
		------- Surface		------------------
-- 		shp		type:#node 		ui:btn_pick_surface		animatable:false		invisibleInTV:true
	)
	rollout params "SquareTube" width:162 height:158
	(
		spinner 'height' "Height" pos:[47,7] width:70 height:16 range:[0.001,1e+09,0.001] type:#worldunits align:#left
		spinner 'width' "Width" pos:[50,28] width:70 height:16 range:[0.001,1e+09,0.001] type:#worldunits align:#left
		spinner 'length' "Length" pos:[45,49] width:70 height:16 range:[-1e+09,1e+09,0.001] type:#worldunits align:#left
		spinner 'rotation' "rotation" pos:[45,70] width:70 height:16 range:[-1e+09,1e+09,0.001] type:#float align:#left
		
		
		spinner 'decal' "decal" pos:[45,91] width:70 height:16 range:[-1e+09,1e+09,0.001] type:#worldunits align:#left
		spinner 'etages' "etages" pos:[45,111] width:70 height:16 range:[-1e+09,1e+09,0.001] type:#worldunits align:#left
-- 		pickButton 'btn_pick_surface' "PickButton" pos:[17,73] width:130 height:19 align:#left


		on btn_pick_surface picked obj do
		(

		)
	)
	
	
	fn ajoute_ssObj 	largeur		hauteur				prof		transf	=(
		
		---- on creer le sous objet model ---------------------
		if ssObj_1 == undefined do
			ssObj_1 = createInstance  ssObject_1	
		ssObj_1.largeur 				= largeur
		ssObj_1.hauteur 				= hauteur
		ssObj_1.profondeur 			= prof		
		ssObj_1.transformation 	= transf
		
		--- onl'ajoute a notre mesh ----------
		mesh += ssObj_1.mesh
		
	)
	
	
	
	
	
	
	
	
	
	
	on buildMesh do
	(
-- 		format "BUILD\n"
		delete mesh
		
		
		
		ajoute_ssObj 	width		height				length		(rotateZMatrix  rotat)
		ajoute_ssObj 	width		height				length		(transMatrix  [decal,0,0 ] *  ( rotateZMatrix  rotat ))
		
		local mtrx_etage = rotateZMatrix  rotat
		for i = 1 to	etages  do (
			translate mtrx_etage [0,0,height]
			ajoute_ssObj 	width		height				length		mtrx_etage
			ajoute_ssObj 	width		height				length		(transMatrix  [decal,0,0 ] *  mtrx_etage )
		)
		
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
			2: (width = abs gridDist.x; length = abs gridDist.y)
			3: height = gridDist.z
		)
	)
)




















