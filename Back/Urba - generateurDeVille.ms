

struct str_elem_facade	(
	fichier 	=	"",
	largeur	=	500
)

struct str_facade (
	elements 		=	#(),
	sequence_elems 	=	#()
)


struct str_style (
	
	nom 						= "Style par defaut",
	wirecolor,
	
	facades_rdc 			=	#(),
	facades_niveaux 	=	#(),
	toitures					=	#(),
	
	etages_min 			= 1,		----	les nombre d'étages minimum que doit avoir un batiment pour utiliser ce style
	etages_max 			= 5,		----	les nombre d'étages maximum que doit avoir un batiment pour utiliser ce style
	surf_min				= 0,		---- 	en cm²
	surf_max				= 0,		---- 	en cm², si min et max = 0 alors le style est appliqué à toutes surfaces
	
	hauteur_etage 					= 250,	
	epaisseur_sousBassement		= 50,
	epaisseur_dalle					= 20

)


struct str_batiment (
	style, 
	tracee ,
	id_subSpline 	= 0 ,
	object,
	
	fn get_surfBB = (
		
		local result 	= 0
		
		local minX 	= 100000000000000000000.
		local maxX = -100000000000000000000.
		local minY 	= 100000000000000000000.
		local maxY = -100000000000000000000.
		
		for id_knot_tracee = 1 to (numKnots tracee 	id_subSpline)   do	(
			knt = getKnotPoint tracee 	id_subSpline 	id_knot_tracee
			if knt.x < minX 	do minX 	= knt.x
			if knt.x > maxX do maxX 	= knt.x
			if knt.y < minY 	do minY 	= knt.y
			if knt.y > maxY do maxY 	= knt.y
		)
		
		result = ( maxX - minX ) * ( maxY - minY )
				
		result
	),
	fn setStyle 	nvStyle =(
		style = nvStyle
		object.wireColor = style.wireColor
	),
	selectionner =(
		clearSelection ()
-- 		select object
	),
	
	
	
	---- MODELISATION ----
	fn creerPolyVide =(
		object = convertToPoly (mesh ())
		object.EditablePoly.SetSelection #Face #{1..25}
		object.EditablePoly.delete #Face
			
		object.name = uniqueName "Urba - Bat "
		object
	),
	
	fn creerFace 	listeDesPoints =(
		
		local verts = object.verts.count
		
		-- les vertex --
		for pt in  listeDesPoints do 
			polyop.createVert object	pt
		
		
		-- les edges --
		for i = 1 to listeDesPoints.count - 1 do 
			polyop.createEdge object (verts+i) (verts+i+1)
		polyop.createEdge object (verts+listeDesPoints.count) (verts+1)
		
		-- la face --
		local listeVertexPrFace = #()
		for i = 1 to listeDesPoints.count  do 
			append listeVertexPrFace ( verts+i )
		polyop.createPolygon object  listeVertexPrFace
		
	),
	
	fn creerFaceVerticale 	pt1 	pt2 	&z 	hauteur	=(
		
		local verts = object.verts.count
-- 		local z = copy Zmin
		polyop.createVert object	[pt2.x, pt2.y, z]	
		polyop.createVert object	[pt1.x, pt1.y, z]
		polyop.createVert object	[pt1.x, pt1.y, z + hauteur]
		polyop.createVert object	[pt2.x, pt2.y, z + hauteur]
		
		polyop.createEdge object (verts+1) (verts+2)
		polyop.createEdge object (verts+2) (verts+3)
		polyop.createEdge object (verts+3) (verts+4)
		polyop.createEdge object (verts+4) (verts+1)
		
		polyop.createPolygon object  #((verts+1),(verts+2),(verts+3),(verts+4))
		
		object
		
	),
	
	fn creerFacesContour	 	altitude 	hauteur =(
		
		for id_pt = 1 to (numKnots 	tracee 	id_subSpline)  - 1 do	 (
			knt_1 = getKnotPoint 	tracee 	id_subSpline 	id_pt
			knt_2 = getKnotPoint 	tracee 	id_subSpline 	( id_pt + 1 )
			creerFaceVerticale 	knt_1		knt_2 	altitude 	hauteur
		)
		
		knt_1 = getKnotPoint 	tracee 	id_subSpline 	(numKnots 	tracee 	id_subSpline)
		knt_2 = getKnotPoint 	tracee 	id_subSpline 	1
		
		creerFaceVerticale 	knt_1		knt_2 	altitude 	hauteur
		
	),
	
	
	
	
	
	---  CREATION DES PARTIES DES BATIMENTS ----
	fn creer_ssBassement 	&z	=(
		creerFacesContour		z 	style.epaisseur_sousBassement 
		z += style.epaisseur_sousBassement
	),
	fn creer_RdC 		&z	=(
		
	),
	fn creer_etages 	&z	=(
		
		-- le nombre d'étages --
		local nbrEtages = random 		style.etages_min 		style.etages_max
		
		for i = 1 to nbrEtages do (
			
			--- plancher ---
			if style.epaisseur_dalle  != 0 do (
				creerFacesContour	z 	style.epaisseur_dalle 
				z += style.epaisseur_dalle
			)
			
			--- un etage ---
			creerFacesContour	z 	style.hauteur_etage 
			z += style.hauteur_etage
			
		)
		
	),
	fn creer_toitTerrasse &z=(
		
		local listeDesPoints = #()
		for i = 1 to numKnots tracee 	id_subSpline do (
			pt = getKnotPoint tracee 	id_subSpline 	i 
			pt.z = z
			
			insertItem   pt listeDesPoints 1
-- 			append listeDesPoints  pt
		)
		creerFace listeDesPoints
	),
	
	
	
	
	on create do (
		-- le poly créé-------------
		creerPolyVide ()
	)
)

struct str_ville (
	
	public
	
		---- les membres ----
		nom					=	"Ville",
		tracee,								--	la spline delimitant les batiments
		batiments 			=#(),		--	les batiments de la ville, un par subSpline fermée
		
		styles				=#(),		
		styles_pourcent	=#(),		--	les pourcentages des styles à appliquer aux batiments
		
	private
		
		
		
		fn pointLePlusHautsurY 	shp 	spline	=(
			local maxi = -10000000000000000 
			local result_id = 0
			for i = 1 to numKnots shp 	spline do (
				local pt = getKnotPoint shp 	spline 	i
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			result_id
		),

		fn estPolygone_sensPositif 	shp	id_spline =(
			
			local result 			= false
			local id_pointHaut = pointLePlusHautsurY  	shp	id_spline 
			
			local	id_pt_1 	= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 	= id_pointHaut 		---- le point origine
			local	id_pt_2 	= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = numKnots shp	id_spline 
			if id_pt_2 > numKnots shp	id_spline  do id_pt_2 = 1
			
			local	pt_1 	= getKnotPoint shp 	id_spline 	id_pt_1
			local	pt_ori 	= getKnotPoint shp 	id_spline 	id_pt_ori
			local	pt_2 	= getKnotPoint shp 	id_spline 	id_pt_2

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
			result
			
		),
		
		fn preparerSpline =(
			for id_subSpline = 1 to (numSplines tracee) do					
				if isClosed  tracee	id_subSpline	do
					if not estPolygone_sensPositif tracee id_subSpline do
						reverse		tracee	id_subSpline	
		),
		
		fn choisirStyle 	nvBat	=(
			
			local surf = nvBat.get_surfBB ()
			
			-- le style en fonction du la surface 		--get_surfBB_SubSpline  	tracee 	id_subSpline
			local stylesPossibles =#()
			for style in styles do (
				--format  "style %\n" style
				if surf > style.surf_min and surf < style.surf_max or surf > style.surf_min  and style.surf_max == 0 do
					appendIfunique stylesPossibles style
			)
				--format  "stylesPossibles %\n" stylesPossibles
			local id_styleTiree = random 1 	stylesPossibles.count
				--format  "id_styleTiree %\n" id_styleTiree
			local styleCourant = stylesPossibles [ id_styleTiree ]
			
			nvBat.setStyle 	styleCourant
			
			styleCourant
			
		),
		
		fn choisirZ =(
			
			local resultZ = 0.
			
			resultZ
			
		),
		
	public
		
		
		fn selectAll = with redraw off (
			clearSelection ()
			for bat in batiments do 
				selectMore bat.object
		),
		fn selectionner id: =(
			if id == unsupplied then
				select tracee
			else
				select batiments[id].object
		),
		
		---- les fonctions ----
		fn creerBatiment  id_subSpline:1 =(
			
			---- l'objet batiment -----
			local nvBat 	= 	str_batiment 	id_subSpline:id_subSpline \
															tracee: tracee
			append batiments nvBat
			nvBat.object.parent = tracee
			
			---- le style ----
			choisirStyle 	nvBat
			
			---- la position en Z ----
			local zCourant 	= 		choisirZ () --tracee.pos.z
			
			---- La creation de la geometrie ----
			nvBat.creer_ssBassement 		&zCourant
			nvBat.creer_RdC 					&zCourant
			nvBat.creer_etages 				&zCourant
			nvBat.creer_toitTerrasse 		&zCourant
			
		),
		
		fn generer 	nvTracee =(
			
			tracee = copy nvTracee
			tracee.name = uniqueName "Urba - Ville "
			preparerSpline ()
			 
			-- status bar ---
			progressStart "Urba: Génération de la ville ..." 
			
			-- Création des batiments sur chaque spline close	--
			for id_subSpline = 1 to (numSplines tracee) do	(
				
				-- status bar ---
				progressUpdate ( id_subSpline as float/ (numSplines tracee) * 100 )
				
				if isClosed  tracee	id_subSpline	do 	creerBatiment	id_subSpline:id_subSpline
			)
			
			-- status bar ---
			progressEnd() 
			
		)
		
	
) -- fin struct ville --











struct generateurDeVille (
	
	private
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="generateurDeVille",
	fn debug 	_txt  var:	 param:    =(
		if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	),
	
	
		styles 				= #(), -- fin des styles
		presets_villes	=	#(
					
			str_ville 	nom:"Normande" \
							styles:#(
								str_style 	nom:"Maisonette" \
												wirecolor:[250,250,50] \
												facades_rdc:#(
													str_facade 	elements:#( str_elem_facade 	fichier:""	largeur:125	) \
																	sequence_elems:#(1,1,1,0)
													) \
												facades_niveaux:#(
													str_facade 	elements:#( str_elem_facade 	fichier:""	largeur:125	) \
																		sequence_elems:#(1)
													) \
												toitures:#() \
												etages_min:1 \
												etages_max:2 \
												surf_max:3000000\
												epaisseur_dalle:0\
												hauteur_etage:500,
								
								str_style 	nom:"Immeuble" \
												wirecolor:[50,50,250] \
												facades_rdc:#() \
												facades_niveaux:#() \
												toitures:#() \
												etages_min:5 \
												etages_max:15 \
												surf_min:3000000
							)
		
			),
		
		ville_courante,	-- la ville actuelement en train d'etre editer
		
		
		
	public
		fn sauvegarder 	=(
		),
		fn charger 		=(
		),
		fn getStyle id =(
			if id >0 and id <= styles.count do
				styles[id]
		),
		
		fn creerVille	tracee 	= 
			with redraw off (
						
				if tracee != undefined do 
					if superClassOf tracee == shape do (
					
						max create mode
						---- on choisi le type de ville ----
						ville_courante = copy presets_villes[1]	--str_ville 	tracee:tracee 
						---- on genere les batiments
						ville_courante.generer	tracee	
						
						
					)
				debug "ville_courante" var:ville_courante.nom
				ville_courante
				
			) -- fin fn creerVille
			
		
)	-- fin generateurDeVille --

urba 	= generateurDeVille ()
ville 	= urba.creerVille $contours
ville.selectionner id:1

-- ville.batiments

