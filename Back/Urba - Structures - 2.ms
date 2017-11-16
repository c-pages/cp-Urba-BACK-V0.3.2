


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------  FACADES  ------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------

---- les éléments de sequence façades --------------------------------
struct str_urba_elem_model (
	
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba elem_model",
	fn debug 	_txt  var:	 param:    =(
		if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	),
	
	
	
	
	
	nom = "Model",
	fichier ="",
	largeur = 100,
	
	fn get_largeur =(),
	
	fn importer = (
		
		debug "importer"
		
		local nodeImport
		local selectBack = selection
		clearSelection()
		
		debug "doesFileExist fichier" var:(doesFileExist fichier)
		debug "getFilenameType fichier " var:(getFilenameType fichier)
		
		if doesFileExist fichier do 
			if getFilenameType fichier == ".max" do (
				mergeMAXFile 	fichier #autoRenameDups 	#select 	#noRedraw 
		
				nodeImport = (selection as array )[1]
			)
		selection = selectBack
		nodeImport
	)
)

struct str_urba_elem_espace (
	nom = "Espace",
	largeur = 100,
	
	fn get_largeur =()
)

struct str_urba_elem_repart (
	nom = "Repart",
	
	fn get_largeur =()	
)




---------manager de SEQUENCE FACADE ------------
struct str_urba_facadeMgr (
	

	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba facadeMgr",
	fn debug 	_txt  var:	 param:    =(
		if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	),
	
	
	
	
	m_urba,
	
	elements =#(),
	
	
	
	
	
	
	
	
	
	fn print =(
		debug "---------------------------------------------------"
		for elem in elements do			
			debug "elem" var:elem
		debug "---------------------------------------------------"
	),
	
	
	
	
	fn getNbrRepart =(
		local nbrResult = 0
		for elem in elements do			
			if classOf elem == str_urba_elem_repart	do nbrResult += 1
		nbrResult
	),
	
	
	
	
	
	
	fn supprimer _id =(
		deleteItem elements 	_id
	),
	
	fn vider =(
		elements =#()
	),
	
	fn deplacer 	_id 	_idDest =(
		
		local elemABouger = elements[ _id ]
		supprimer _id 
-- 		if _idDest > _id then
			insertItem 	elemABouger	elements		(_idDest )
-- 		else 
-- 			insertItem 	elemABouger	elements		_idDest
		
	),
	fn monter _id =(
		deplacer _id (_id-1)
	),
	fn descendre _id =(
		deplacer _id (_id+1)
	),
	
	
	
	---- creation d'elements --------
	fn creer_model 	fichier:undefined	=(
		local nvElem = str_urba_elem_model fichier:fichier
		append elements nvElem
		nvElem		
	),
	fn creer_espacement =(
		local nvElem = str_urba_elem_espace ()
		append elements nvElem
		nvElem		
	),
	fn creer_repartition =(
		local nvElem = str_urba_elem_repart ()
		append elements nvElem
		nvElem		
	)
	
	
)




---------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------  Presets				 --------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------

---- Element De Facade -----
struct str_urba_preset_elementFacade (
	idUnique			=	"",
	
	type 				= 1,			---- 	les types : 	1=Extensible, 2=largeur fixe, 3=model 3D
	largeur			=	100.,		
	model			=	""			----	le model 3D ... (fichier ou struct ? .... )
)

---- FACADE -----
struct str_urba_preset_facade (
	idUnique			=	"",
	
	nom 				= 	"Nouvelle façade",
	elements 		=#()
)


---- BATIMENT -----
struct str_urba_preset_batiment (
	idUnique			=	"",
	
	nom 				= 	"Nouveau bâtiment",
	
	toiture_type		=	"",
	
	etages_facade	=	"",
	etages_min			= 	1,
	etages_max 		= 	5,
	etages_hauteur 	= 	250,
	
	rdc_facade			=	"",
	rdc_hauteur 		= 	300
)





---- VILLE -----
struct str_urba_preset_ville (
	idUnique		=	"V0",
	
	nom 			=	"Nouvelle ville",
	
	batiments 			=	#(),
	probabilites 		=	#(),
	surfaces_min		= 	#(),
	surfaces_max 		= 	#()
)





---------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------  MODELISATION et autre --------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------

struct str_urba_outils (
	
	----- tests divers -----------------
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
	
	
	fn preparerSpline 	_tracee	=(
		for id_subSpline = 1 to (numSplines _tracee) do					
			if isClosed  _tracee	id_subSpline	do
				if not estPolygone_sensPositif 	_tracee 	id_subSpline do
					reverse		_tracee	id_subSpline	
	),
	
	
	
	
	-------- modelisation-------------------------
	fn creerPolyVide =(
		object = convertToPoly (mesh ())
		object.EditablePoly.SetSelection #Face #{1..25}
		object.EditablePoly.delete #Face
			
		object.name = uniqueName "Urba - Batiment "
		object
	),
	
	fn creerFace  _object		_listeDesPoints  =(
		
		local verts = _object.verts.count
		
		-- les vertex --
		for pt in  _listeDesPoints do 
			polyop.createVert _object	pt
		
		
		-- les edges --
		for i = 1 to _listeDesPoints.count - 1 do 
			polyop.createEdge _object (verts+i) (verts+i+1)
		polyop.createEdge _object (verts+_listeDesPoints.count) (verts+1)
		
		-- la face --
		local listeVertexPrFace = #()
		for i = 1 to _listeDesPoints.count  do 
			append listeVertexPrFace ( verts+i )
		polyop.createPolygon _object  listeVertexPrFace
		
		_object
	),
	
	fn creerFaceVerticale 	_object	pt1 	pt2 	&z 	hauteur	=(
		
		local verts = _object.verts.count
-- 		local z = copy Zmin
		polyop.createVert _object	[pt2.x, pt2.y, z]	
		polyop.createVert _object	[pt1.x, pt1.y, z]
		polyop.createVert _object	[pt1.x, pt1.y, z + hauteur]
		polyop.createVert _object	[pt2.x, pt2.y, z + hauteur]
		
		polyop.createEdge _object (verts+1) (verts+2)
		polyop.createEdge _object (verts+2) (verts+3)
		polyop.createEdge _object (verts+3) (verts+4)
		polyop.createEdge _object (verts+4) (verts+1)
		
		polyop.createPolygon _object  #((verts+1),(verts+2),(verts+3),(verts+4))
		
		_object
		
	),
	
	fn creerFacesContour	 _object	 	_tracee		id_subSpline	altitude 		hauteur =(
		
		for id_pt = 1 to (numKnots 	_tracee 	id_subSpline)  - 1 do	 (
			knt_1 = getKnotPoint 	_tracee 	id_subSpline 	id_pt
			knt_2 = getKnotPoint 	_tracee 	id_subSpline 	( id_pt + 1 )
			creerFaceVerticale 	knt_1		knt_2 	altitude 	hauteur
		)
		
		knt_1 = getKnotPoint 	_tracee 	id_subSpline 	(numKnots 	_tracee 	id_subSpline)
		knt_2 = getKnotPoint 	_tracee 	id_subSpline 	1		
		creerFaceVerticale 	knt_1		knt_2 	altitude 	hauteur
		
	)
	
)












------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
















