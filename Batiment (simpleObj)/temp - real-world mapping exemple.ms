plugin simpleObject SpherePlus 
name:"Sphere_Plus"
category:"Standard Primitives"
classID:#(0x68b2b559, 0x7b555bd2)
(
	fn syncRadius val = 
	(
		if this.radius1 != val do this.radius1 = val
		if this.radius2 != val do this.radius2 = val
		if this.radius3 != val do this.radius3 = val
	)
	parameters main rollout:rltParams
	(
		rows type:#integer default:4 ui:uiRows		
		columns type:#integer default:8 ui:uiColumns
		radius1 type:#float ui:uiRadius1 default:0
		radius2 type:#float ui:uiRadius2 default:0
		radius3 type:#float ui:uiRadius3 default:0
		uniform type:#boolean ui:uiUniform default:false
		hemisphere type:#float ui:uiHemisphere default:1.0
		cap type:#boolean ui:uiCap default:false
		mapCoords type:#boolean ui:uiMapCoords default:true
		realWorldMapSize type:#boolean ui:uiRealWorldMapSize default:false
		
		on radius1 set val do if uniform do syncRadius val
		on radius2 set val do if uniform do syncRadius val
		on radius3 set val do if uniform do syncRadius val
			
		on uniform set val do if val do syncRadius radius1
	)
	
	rollout rltParams "Parameters"
	(
		spinner uiRows "Rows" range:[1,100,16] type:#integer
		spinner uiColumns "Columns" range:[3,100,32] type:#integer
		spinner uiRadius1 "Radius X:" range:[0,1e9,0] scale:.1 type:#worldunits offset:[0,9]
		spinner uiRadius2 "Radius Y:" range:[0,1e9,0] scale:.1 type:#worldunits
		spinner uiRadius3 "Radius Z:" range:[0,1e9,0] scale:.1 type:#worldunits
		checkBox uiUniform "Uniform " checked:false offset:[67,0] enabled:true
		spinner uiHemisphere "Hemisphere:" range:[0.0,1.0,1.0] scale:.005 type:#float offset:[0, 9]
		checkBox uiCap "Cap " checked:false offset:[67,0] enabled:false
		checkBox uiMapCoords "Generate Mapping Coords" checked:true offset:[0, 9]
		checkBox uiRealWorldMapSize "Real-World Map Size" checked:false
		
		on uiHemisphere changed val do (uiCap.enabled = (val != 1.0))
	)
	
	on hasUVW do map_coords
		
	on setGenUVW bool do map_coords = bool
	
	fn genMesh = 
	(
		format "build...%" (timestamp())

		local vertCount 	= (rows+2 )* columns --add the both polar ends to the rows count
		local facesCount =  columns * (rows-1) * 2 
		local rowAngle = 180.0 / (rows+1) * hemisphere
		local columnAngle = 360.0 / columns
		local capRow = 0
		
		/*Set Vertices*/
		local verticesArr = #()
		
		for h = 1 to (rows+2) do
		(
			for v = 1 to columns do
			(									
				calcX = radius1 * cos((v-1) * columnAngle) * sin((h-1)*rowAngle)
				calcY = radius2 * sin((v-1)* columnAngle) * sin((h-1)*rowAngle)
				calcZ = radius3 * cos((h-1) * rowAngle)
				
				pos = [calcX,calcY,calcZ] + [0,0,0] --include nodes matrix
				append verticesArr pos
			)
		)
		
		/*Cap Mesh*/
		if hemisphere != 1.0 then
		(
			/*duplicate the last six verts for later use in capping the SpherePlus*/
			lastVert = verticesArr.count
			startingVert = lastVert - (columns - 1)--the starting vert to begin collecting at
			
			lastVerticesRow = (for i = startingVert to lastVert collect verticesArr[i])
			join verticesArr lastVerticesRow
			capRow = 1
			vertCount += columns
		)
		
		/*Set Faces*/
		local facesArr = #()
		local rowEnd = columns as integer
		
		loops = (rows + 1 + capRow)*columns
		for v = 1 to loops do
		(
			if v < rowEnd then
			(
				append facesArr [v+1, v, v+columns]
				append facesArr [ v+columns ,  v+columns+1 , v+1 ] 
			)else(
				append facesArr [ 1+v-columns , v , v+columns]
				append facesArr [v+columns , v+1, 1+v-columns ]
				rowEnd += columns
			)
		)
		
		/*Set Mesh*/
		 setMesh mesh verts:verticesArr faces:facesArr
		triCount = (rows+1+capRow)*columns*2
		for f in #{1..triCount} do setEdgeVis mesh f 3 false
		for f in #{1..triCount} do setFaceSmoothGroup mesh f 1
		if hemisphere != 1.0 and cap do (
			for f in #{(triCount-(columns*2)+1)..triCount} do setFaceSmoothGroup mesh f 2
		)
		
		
		
		format "vertCount : %\n" vertCount
		format "verticesArr : %\n" verticesArr
		format "facesArr : %\n" facesArr
		
		/*Set Texture Coordinates*/
		if mapCoords do (
			setNumTVerts mesh vertCount
			if realWorldMapSize then
			(
				for i = 1 to vertCount do
				(
					setTVert mesh i verticesArr[i]
				)
			)
			else 
			(
				 local maxLength = amax #(radius1,radius2,radius3)
				 for i = 1 to vertCount do
				(
					 setTVert mesh i (verticesArr[i] / maxLength + [0, 0, 0]/2)
				)
			)
			buildTVFaces mesh false
			for i = 1 to facesArr.count do
			(
				setTVFace mesh i facesArr[i]
			)
		)
		
		
		
		
		
		/*Weld Polars*/
		if hemisphere == 1.0 then
		(
			local weldBottomVerts = for i = vertCount to (vertCount - (columns-1)) by -1 collect i
			meshop.weldvertset mesh weldBottomVerts --weld end verts first because it changes the vert count
		)
		else
		(
			if cap do 
			(
				local weldBottomVerts = for i = vertCount to (vertCount - (columns-1)) by -1 collect i
				meshop.weldvertset mesh weldBottomVerts --weld end verts first because it changes the vert count
			)
		)
		
		 local weldTopVerts = for i = 1 to columns collect i
		 meshop.weldvertset mesh weldTopVerts
		
		 update mesh
	)
	
	on buildMesh do (genMesh())
	
	tool create
	(
		local first_pos
		
		on mousePoint click do (
			case click of (
				1: (radius1 = radius2 = radius3 = 0; coordSys grid (nodeTM.translation = first_pos = gridPoint))
				2: #stop
			)
		)
			
		on mouseMove click do (
			case click of (
				2: (
						radius1 = radius2 = radius3 = length (gridDist * [1, 1, 0])
						if altKey do
						(
							nodeTM.translation = [0,0,0]
						)
					)
			)
		)
	)
)
