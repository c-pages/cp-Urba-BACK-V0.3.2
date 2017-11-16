/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA
	Générateur de ville
	
##########################################################################################################################
	
	Outils
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [27/07/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/



include "$userScripts\cp-Urba\Urba - Construction.ms"

------- diverses struct porteuses de parametres ----------
struct str_params_batiment (
	tracee,
	idSpline
)

struct str_styleVille (
	tracee,
	idSpline
)

struct str_equationPlan (
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="str_equationPlan",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		a,
		b,
		c,
		d,
		normal ,
		
		fn creerFrom_2vecs_et_1Point	_vec1 	_vec2  	_point	=(
			
-- 			debug "creerFrom_2vecs_et_1Point"
			---le vec normal du plan-----
			local norm1 = normalize _vec1
			local norm2 = normalize _vec2		
			normal =  cross    norm2 	norm1
			
			--- definition equation ---------
			a = normal.x
			b = normal.y
			c = normal.z		
			d = -( a*_point.x + b*_point.y + c*_point.z )
			
-- 			debug "a" var:a
-- 			debug "b" var:b
-- 			debug "c" var:c
-- 			debug "d" var:d
		),
		fn projeter_point_verticalement 		_pt 	=(
-- 			debug "projeter_point_verticalement"
			local result = copy _pt
			result.z =  -( a*_pt.x + b*_pt.y + d ) / c
			result
			
		),
		

		fn get_intersection_segment	_segPt1		_segPt2			=(
			
			local k	= -( a * _segPt1.x 		+	b * _segPt1.y 	+	c * _segPt1.z 	+ d ) 	/	( a * ( _segPt2.x -  _segPt1.x ) + b * ( _segPt2.y -  _segPt1.y )  + c * ( _segPt2.z -  _segPt1.z )  )

			local ptResult 	= [0,0,0]
			ptResult.x 			=  _segPt1.x + k * ( _segPt2.x 	-  _segPt1.x )
			ptResult.y 			=  _segPt1.y + k * ( _segPt2.y 	-  _segPt1.y )
			ptResult.z 			=  _segPt1.z + k * ( _segPt2.z 	-  _segPt1.z )
			
			ptResult
			
		),
		fn coupe_segment	_segPt1		_segPt2			=(
			
			local pointIntersect = get_intersection_segment 	_segPt1		_segPt2 		
			-- debug-------
-- 			point pos:pointIntersect isSelected:true
			
			local vecSeg 	= _segPt2 - _segPt1
			local vecInter = pointIntersect - _segPt1
			
			if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
				true
			else
				false
			
		)
		
		
		
		
)

---------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------  MODELISATION et autre -----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------
struct str_urba_outils (
		
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="Urba | Outils",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
		
		m_urba,
		
	private
		dossier_modelesFacades = GetDir  #userScripts	+	"\cp-Urba\lib\facades\\" ,
		ep_ssBassement = 100,
		ep_dalle = 20,
		
		constr = str_urba_construction (),
		
		
		-------- Divers ------------------------------------------------
	private
		fn get_angle_vecteur 	vec	=(
			
			local result = 0
			local angle_tan = atan ( vec.y / vec.x )
			
			if vec.x >=0 then (
				if vec.y >= 0 then 	result = angle_tan
				else 	result = 360 + angle_tan
			) else (		
				if vec.y >= 0 then 	result = 180 + angle_tan
				else result = 180 + angle_tan
			)
			
			result
		),		
		fn get_largeurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local largeur = BB[2].x -  BB[1].x 
			largeur
		),
		fn get_hauteurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local hauteur = BB[2].z -  BB[1].z 
			hauteur
		),
		fn get_paramsBatiment 	_nodeBat =(
			
			local porteurDeParams = str_params_batiment ()
			
			porteurDeParams.tracee 		= _nodeBat.modifiers[1].tracee[1].node
			porteurDeParams.idSpline		= _nodeBat.modifiers[1].idSpline
			
			porteurDeParams
		),
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
			
-- 			debug "pointLePlusHautsurY"	var:result_id
			result_id
		),
		fn estPolygone_sensPositif 	shp	idSpline =(
			
			local result 			= true
			local id_pointHaut 	= pointLePlusHautsurY  	shp	idSpline 
			
			local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 	= id_pointHaut 		---- le point origine
			local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = numKnots shp	idSpline 
			if id_pt_2 > numKnots shp	idSpline  do id_pt_2 = 1
			
			local	pt_1 		= getKnotPoint shp 	idSpline 	id_pt_1
			local	pt_ori 	= getKnotPoint shp 	idSpline 	id_pt_ori
			local	pt_2 		= getKnotPoint shp 	idSpline 	id_pt_2

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
			result
			
		),
		
		
		
	private
		fn get_edge_lePlusGrand	_spline 	_idSpline =(
			local 	longueurEdgeMax = 0
			local	resultEdgeId
			for i = 1 to ( numKnots _spline 	_idSpline) - 1 do (
				local pt 			= getKnotPoint _spline 	_idSpline 	i
				local pt_suivant	= getKnotPoint _spline 	_idSpline 	(i+1)
				local longueurEdge = distance	pt	pt_suivant
				if longueurEdge > longueurEdgeMax do (
					longueurEdgeMax = longueurEdge
					resultEdgeId = i
				)
			)
			resultEdgeId
		),
		fn get_axePrincipal  			_spline 	_idSpline  =(
			
			local edgeLePlusLong 	= get_edge_lePlusGrand	_spline 	_idSpline 
			local pts 					= #(	getKnotPoint _spline 	_idSpline 	edgeLePlusLong, 
													getKnotPoint _spline 	_idSpline 	( edgeLePlusLong + 1) )
			local axeVecteur 		= 	normalize (pts[2] - pts[1])
			local axeMtrx				=  /* inverse */  ( matrixFromNormal		axeVecteur )
-- 			translate	axeMtrx  pts[1]
-- 			debug "----- 1 ----->	axeMtrx" var:axeMtrx
			
			if axeMtrx.row1	==	[0,0,-1]  then (
				
				axeMtrx =  (rotateYMatrix 180) *(rotateXMatrix 180) *  (rotateZMatrix -90) * axeMtrx
-- 				debug "la on doit corriger un truc ?"
				
			) else if axeMtrx.row1	==	[0,0,1] do (
				
				axeMtrx =  (rotateYMatrix 180)  *(rotateXMatrix 180)  * (rotateZMatrix 90) * axeMtrx
-- 				debug "la on doit corriger un truc ?"
			)
			
-- 			debug "----- 2 ----->	axeMtrx" var:axeMtrx
			-- debug--
		-- 	local ptDebug = point transform:axeMtrx	
		-- 	select ptDebug
			
			
			axeMtrx
			
		),
		fn get_BB_axePrincipal  	_spline 	_idSpline  =(
			
			local mtrx_axePrincipal	=	get_axePrincipal 	_spline	_idSpline
			
			local pt1 = ( getKnotPoint _spline 	_idSpline 	1 ) * inverse mtrx_axePrincipal
			local xMin = xMax = pt1.x
			local yMin = yMax = pt1.y
			local zMin = zMax = pt1.z
			
			for i = 2 to ( numKnots _spline 	_idSpline) do (
				local pt = ( getKnotPoint _spline 	_idSpline 	i ) * inverse mtrx_axePrincipal
				if pt.x < xMin 		do xMin 		= pt.x
				if pt.x > xMax 	do xMax 	= pt.x
				if pt.y < yMin 		do yMin 	= pt.y
				if pt.y > yMax 	do YMax 	= pt.y
				if pt.z < zMin 		do zMin 		= pt.z
				if pt.z > zMax 	do zMax 	= pt.z
			)
			
			-- debug--
-- 			local ptDebug1 = point transform:mtrx_axePrincipal	pos:([xMin, yMin,zMin]*  mtrx_axePrincipal)	size:200
-- 			local ptDebug2 = point transform:mtrx_axePrincipal	pos:([xMax, yMax,zMax]*  mtrx_axePrincipal)	size:200
-- 			select #(ptDebug1,ptDebug2)
			
			#([xMin, yMin, zMin]*  mtrx_axePrincipal, [xMax, yMax, zMax]*  mtrx_axePrincipal)
			
		),
		
		
		
	public
		fn get_surfSplineBB 	tracee	idSpline	= (
			
			
			local result 	= 0
			
			local minX 	= 100000000000000000000.
			local maxX = -100000000000000000000.
			local minY 	= 100000000000000000000.
			local maxY = -100000000000000000000.
			
			for id_knot_tracee = 1 to (numKnots tracee 	idSpline)   do	(
				knt = getKnotPoint tracee 	idSpline 	id_knot_tracee
				if knt.x < minX 	do minX 	= knt.x
				if knt.x > maxX do maxX 	= knt.x
				if knt.y < minY 	do minY 	= knt.y
				if knt.y > maxY do maxY 	= knt.y
			)
			
			result = ( maxX - minX ) * ( maxY - minY )	/	10000
			
			result
		),
		fn get_surfBB 	_nodeBat	= (
			
			local param 		= get_paramsBatiment	_nodeBat		
			local tracee 		= param.tracee
			local idSpline		= param.idSpline
			get_surfSplineBB	tracee	idSpline

		),		
		
	-------- Gestion des models importés ---------------------------
	private
		listeDesPresetsModels	= #(),
		listeDesNodesModels	= #(),
		
		fn trouver_nodeModel	_model 	=(
			if listeDesNodesModels.count >0 then (
-- 				debug "trouver_nodeModel"
-- 				debug "_model" var:_model
				local id = findItem 	listeDesPresetsModels		_model
-- 				debug "id" var:id
		-- 		debug "listeDesNodesModels" var:listeDesNodesModels
		-- 		debug "listeDesNodesModels[id]" var:listeDesNodesModels[id]
				listeDesNodesModels[id]
			) else undefined
		),
		fn importerModel	_presetMod =(
			local selectBack = selection
			
			local adresseFichier = dossier_modelesFacades + _presetMod.fichier
			if not doesFileExist adresseFichier then (
				adresseFichier = getOpenFileName 	caption:( "Le fichier "+  _presetMod.fichier +" est manquant" )\
																filename:dossier_modelesFacades \
																types:"Max(*.max)|*.max|All|*.*|" \
																historyCategory:"Urba"
				if adresseFichier !=undefined do 
					_presetMod.fichier = filenameFromPath	adresseFichier
					m_urba.facades.modeles.sauvegarder 	_presetMod
			)
			if adresseFichier !=undefined then (
				mergeMAXFile 	adresseFichier 	#select 	#noRedraw	#deleteOldDups 	quiet:true
				local modelImport = selection[1]
				
				append listeDesNodesModels 	modelImport
				
				select selectBack
				
				true
			) else false
		),
		fn collecter_modeles_bat 	_presetBat	=(
			debug "collecter_modeles"
			
			local bat = _presetBat
			
			--- collect des presets des models ----
			listeDesPresetsModels	= #()
			local facadeTmpRdC , facadeTmpEtages
			local listeDeElements	= #()
			
			if bat.rdc_facade != "" do(
				facadeTmpRdC 		= m_urba.facades.presets.get_parIdUnique		bat.rdc_facade
				listeDeElements += facadeTmpRdC.elements
			)
			if bat.etages_facade != "" do (
				facadeTmpEtages	= m_urba.facades.presets.get_parIdUnique		bat.etages_facade
				listeDeElements += facadeTmpEtages.elements
			)
			
			
			for elem_idU in listeDeElements do if  elem_idU != undefined do (
				local elem = m_urba.facades.elementsDeFacade.get_parIdUnique		elem_idU
				
				--- gestion des modeles pour Facades ------------
				if elem.type == 3 do (
					local modelTmp = m_urba.facades.modeles.get_parIdUnique		elem.model
					appendIfUnique listeDesPresetsModels	modelTmp
				)
			)
		),
	public
		fn preparer_imports 	_presetsBats =(
			debug "collecter_modeles"
			
			--- collect des presets des models -----------------------------
			listeDesPresetsModels	= #()
			
			local annul = false
			for bat_idU in _presetsBats while not annul		do (
				local bat = m_urba.batiments.presets.get_parIdUnique		bat_idU
				collecter_modeles_bat	bat
				if keyboard.escPressed do annul = true
			)
			if not annul then  (
				-- merger les modeles ---
				listeDesNodesModels 				= #()
				for presetModel in listeDesPresetsModels  while not annul	do (
					local importReussi = importerModel	presetModel
					if not importReussi do (
						annul = true
						messageBox  ("Erreur lors de l'import d'un model !\nModel : " + presetModel.nom )
					)
					if keyboard.escPressed do annul = true
				)
			) 
			
			if annul then  false
				else true
			
		),
		fn supprimer_modelesImportes =(
			for nd in  listeDesNodesModels do
				delete nd
			listeDesPresetsModels	= #()
			listeDesNodesModels	= #()
		),
		
		
		
		
		
		
		-------- Modelisation Fondamentale-------------------------
	private
		fn creerPolyVide =(
			nvNode = convertToPoly (mesh ())
			nvNode.EditablePoly.SetSelection #Face #{1..25}
			nvNode.EditablePoly.delete #Face
			
			nvNode
		),
		fn viderPoly 	_poly =(
			
			local listeDesFaces = #{1..(polyop.getNumFaces _poly)} as array
			polyop.deleteFaces _poly	listeDesFaces		delIsoVerts:true
			polyop.deleteIsoVerts _poly
			
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
			
		),
		fn creerFaceVerticale 	_object	pt1 	pt2 	z 	hauteur	=(
			
			local verts = _object.verts.count
			
			polyop.createVert _object	[pt2.x, pt2.y, z]	
			polyop.createVert _object	[pt1.x, pt1.y, z]
			polyop.createVert _object	[pt1.x, pt1.y, z + hauteur]
			polyop.createVert _object	[pt2.x, pt2.y, z + hauteur]
			
			polyop.createEdge _object (verts+1) (verts+2)
			polyop.createEdge _object (verts+2) (verts+3)
			polyop.createEdge _object (verts+3) (verts+4)
			polyop.createEdge _object (verts+4) (verts+1)
			
			polyop.createPolygon _object  #((verts+4),(verts+3),(verts+2),(verts+1))
			
		),
		fn creerFacesContour	 _nodeBat	 		altitude 		hauteur =(
			
			local param 		= get_paramsBatiment	_nodeBat		
			local tracee 		= param.tracee
			local idSpline		= param.idSpline
			local listeDeFacesDunContour =#()
			
			for id_pt = 1 to ( numKnots 	tracee 	idSpline )  - 1 do	 (
				knt_1 = getKnotPoint 	tracee 	idSpline 	id_pt
				knt_2 = getKnotPoint 	tracee 	idSpline 	( id_pt + 1 )
				local nvlFace = creerFaceVerticale 	_nodeBat	knt_1		knt_2 	altitude 	hauteur
				if nvlFace != undefined do
					appendIfUnique listeDeFacesDunContour	nvlFace
			)
			
			knt_1 = getKnotPoint 	tracee 	idSpline 	(numKnots 	tracee 	idSpline)
			knt_2 = getKnotPoint 	tracee 	idSpline 	1
			local nvlFace = creerFaceVerticale 	_nodeBat	knt_1		knt_2 	altitude 	hauteur
			if nvlFace != undefined do
				appendIfUnique listeDeFacesDunContour	nvlFace
			
			listeDeFacesDunContour
		),
		
		
		
		
		
		fn creerPlan 	_pt1 		_pt2 	_pt3 =(
			
			local plan = str_equationPlan ()
			local vec_1 = _pt2 - _pt1
			local vec_2 = _pt3 - _pt1
		
			plan.creerFrom_2vecs_et_1Point		vec_1	vec_2		_pt1
			
			plan
		),
		-------- Generation des facades ------------------------------------------------------
		
	private
		fn creer_facade			_nodeBat	_knt_1		_knt_2 	_altitude 	_hauteur	_styleFacade	=(
			
			---- ANALYSE de la SEQUENCE d'élements de facades ------
			local largeurTotal 			= distance		_knt_1	_knt_2
			local nbrElemExtensibles 	= 0
			local largeurFixMin 			= 0
			local largeurExtensible 		= 0
			local listeDeFacesDuneFacade =#()
			
			local grp_ouvert 			= false
			local grp_extensibles 	= 0
			local grp_largeurMin 	= 0
			
			for idElem in _styleFacade.elements do (
				
				local presetElement			= m_urba.facades.elementsDeFacade.get_parIdUnique	idElem
				
				if grp_ouvert then (	
					
-- 			debug "GRP_OUVERT" 
					case presetElement.type of (
						1: (	----	extensible ----
								grp_extensibles += 1
						)
						2: (	----	largeur fixe ----
								grp_largeurMin += presetElement.largeur
						)
						3: (	----	model ----
								local presetModel	= m_urba.facades.modeles.get_parIdUnique 		presetElement.model
								local ndModel 		= trouver_nodeModel	presetModel
								grp_largeurMin +=	get_largeurNodeModele		ndModel
						)
						/* 
						4: (	----	groupe ouverture ----
								grp_ouvert = true
						) */
						5: (	----	groupe fermeture ----
								grp_ouvert = false
								
						)
					) -- fin case of---------------------------------------
					
					
				) else ( --- pas dans groupe-------------------------
					
-- 			debug "GRP_FERMé" 
					case presetElement.type of (
						1: (	----	extensible ----
								nbrElemExtensibles += 1
						)
						2: (	----	largeur fixe ----
								largeurFixMin += presetElement.largeur
						)
						3: (	----	model ----
								local presetModel	= m_urba.facades.modeles.get_parIdUnique 		presetElement.model
								local ndModel 		= trouver_nodeModel	presetModel
								largeurFixMin +=	get_largeurNodeModele		ndModel
						)
						4: (	----	groupe ouverture ----
								grp_ouvert = true
						)
						/* 5: (	----	groupe fermeture ----
								
						) */
					) --- fin case of -------------------
					
				)
				
			)
		
			debug "CREATION des GEOMETRIES" 
			debug "largeurTotal" var:largeurTotal
			local	nbreRepetitionsGrp = 0
			if grp_largeurMin != 0 then (
				local LargeurRestantAvtGrp 	= 	largeurTotal - largeurFixMin 			
				nbreRepetitionsGrp 				= 	floor ( LargeurRestantAvtGrp / grp_largeurMin )		
				
			debug " ( LargeurRestantAvtGrp / grp_largeurMin )" var: ( LargeurRestantAvtGrp / grp_largeurMin )	
			debug "nbreRepetitionsGrp" var:nbreRepetitionsGrp	
				local	largeurRestant 			= 	LargeurRestantAvtGrp  -  nbreRepetitionsGrp * grp_largeurMin			
				largeurExtensible					=	largeurRestant	/	( grp_extensibles * nbreRepetitionsGrp	+ nbrElemExtensibles )
			) else (
				if nbrElemExtensibles != 0 then
					largeurExtensible				=	(largeurTotal	-  largeurFixMin ) /	 nbrElemExtensibles 
			)	
			
-- 			debug "LargeurRestantAvtGrp" var:LargeurRestantAvtGrp
-- 			debug "largeurRestant" var:largeurRestant
			debug "largeurExtensible" var:largeurExtensible
			
			
			---- CREATION des GEOMETRIES ----------------------
			if largeurTotal > ( largeurFixMin	+ grp_largeurMin	) then (
				
				local pt1 			= 	_knt_1
				local pt2		
				local normDir		=	normalize (_knt_2 - _knt_1)
				local rot 			= get_angle_vecteur		normDir
				local nvxNodes 	= #()
				local idDebutGroupe 	= 0
				local nbrGroupCrees 	= 0
				
				local i =0
				while i <  _styleFacade.elements.count do (
					i += 1
					local idElem = _styleFacade.elements[i]
					
					local presetElement			= m_urba.facades.elementsDeFacade.get_parIdUnique idElem
-- 					
-- 					debug "presetElement"  var:presetElement
					
					case presetElement.type of (
						1: (	----	EXTENSIBLE ----
							
					debug "EXTENSIBLE" 
								pt2		=	pt1 + normDir * largeurExtensible
								local nvlFace = creerFaceVerticale 	_nodeBat	pt1 	pt2 	_altitude 		_hauteur	
								if nvlFace != undefined do
									appendIfUnique listeDeFacesDuneFacade	nvlFace
							)
						2: (	----	largeur FIXE ----
					debug "FIXE" 
								pt2		=	pt1 + normDir * presetElement.largeur
								local nvlFace = creerFaceVerticale 	_nodeBat	pt1 	pt2 	_altitude 		_hauteur	
								if nvlFace != undefined do
									appendIfUnique listeDeFacesDuneFacade	nvlFace
							)
						3: (	----	MODEL ----
					debug "MODEL" 
								
								-- placer le model -----							
								local presetModel	= m_urba.facades.modeles.get_parIdUnique 		presetElement.model
								local modelSource 	= trouver_nodeModel		presetModel
								
								local nv_modele 		= copy modelSource
								append nvxNodes 	nv_modele
								
								rotate nv_modele (angleaxis rot [0,0,1])
								nv_modele.pos 				= pt1
								nv_modele.pos.z 				= _altitude
							
								local facesDuNodeAvant 	= _nodeBat.faces.count
								polyop.attach		_nodeBat	nv_modele
								listeDeFacesDuneFacade += #{(facesDuNodeAvant + 1).._nodeBat.faces.count} as array
							
								-----	facette du dessus -----
								pt2 = pt1 + normDir * (get_largeurNodeModele		modelSource)
								
								local hauteurQuiReste = _hauteur	- ( get_hauteurNodeModele modelSource )
-- 								debug "(pt1.z + ( get_hauteurNodeModele modelSource ) )" var:(pt1.z + ( get_hauteurNodeModele modelSource ) )
-- 								debug "hauteurQuiReste" var:hauteurQuiReste
							
								
								local nvlFace = creerFaceVerticale 	_nodeBat	pt1 	pt2 	(_altitude + ( get_hauteurNodeModele modelSource ) )		hauteurQuiReste	
								
								if nvlFace != undefined do
									appendIfUnique listeDeFacesDuneFacade	nvlFace
							
							)
						4: (
							nbrGroupCrees += 1
							grp_ouvert = true
							idDebutGroupe = i - 1
						)
						5: (
							if nbrGroupCrees < nbreRepetitionsGrp do
								i = idDebutGroupe
							grp_ouvert = false
						)
							
					) -- fin case ---------------------------
					
					pt1 = pt2
				)
				listeDeFacesDuneFacade
				
			) else (
-- 				debug  "		*********************************************************************"	
				#( 	creerFaceVerticale 	_nodeBat	_knt_1 	_knt_2 	_altitude 		_hauteur	)
			)
		),
		fn creer_etage			_nodeBat 	_altitude 	_hauteur	_styleFacade	=(
			
			local param 		= get_paramsBatiment	_nodeBat		
			local tracee 		= param.tracee
			local idSpline		= param.idSpline
			local listeDeFacesDunEtage =#()
			
			for id_pt = 1 to ( numKnots 	tracee 	idSpline )  do	 (
				local j = ( id_pt + 1 )
				if id_pt == ( numKnots 	tracee 	idSpline ) do j = 1
				
				knt_1 = getKnotPoint 	tracee 	idSpline 	id_pt
				knt_2 = getKnotPoint 	tracee 	idSpline 	j
				local nvlsFaces = creer_facade		_nodeBat	knt_1		knt_2 	_altitude 	_hauteur	_styleFacade
				listeDeFacesDunEtage	+= nvlsFaces
			)
			
			listeDeFacesDunEtage
		),
		fn creer_toitPlat 			_nodeBat	&z		=(
			debug "creer_toitPlat"
			local param 		= get_paramsBatiment	_nodeBat		
			local tracee 		= param.tracee
			local idSpline		= param.idSpline
			
			--- plancher ---
			if ep_dalle  != 0 do (
				creerFacesContour	_nodeBat	z 	ep_dalle
				z += ep_dalle
			) 
			
			--- creation de la facette globale-----
			local listeDesPoints = #()
			for i = 1 to numKnots tracee 	idSpline do (
				pt = getKnotPoint tracee 	idSpline 	i 
				pt.z = z
				append listeDesPoints  pt
			)
			local faceDuToit	=	creerFace 	_nodeBat	listeDesPoints
			
		),
		fn creer_toitTerrasse 	_nodeBat	&z		=(
			debug "creer_toitTerrasse"
			local param 		= get_paramsBatiment	_nodeBat		
			local tracee 		= param.tracee
			local idSpline		= param.idSpline
			
			 --- plancher ---
			if ep_dalle  != 0 do (
				creerFacesContour	_nodeBat	z 	ep_dalle
				z += ep_dalle
			) 
			
			--- creation de la facette globale-----
			local listeDesPoints = #()
			for i = 1 to numKnots tracee 	idSpline do (
				pt = getKnotPoint tracee 	idSpline 	i 
				pt.z = z
				append listeDesPoints  pt
			)
			local faceDuToit	=	creerFace 	_nodeBat	listeDesPoints
			local selecBack = selection
			select _nodeBat
			constr.accrotere		_nodeBat	#(faceDuToit)
			select	selecBack
		),
		fn creer_toitPentes 		_nodeBat	&z	pentes	=(
			debug "creer_toitDeuxPentes"
			
			local param 		= get_paramsBatiment	_nodeBat		
			local tracee 		= param.tracee
			local idSpline		= param.idSpline
			
			local	 mtrx_axeP	=	get_axePrincipal	 tracee	idSpline
			local	 BB_axeP	=	get_BB_axePrincipal 	tracee	idSpline
			translate mtrx_axeP	BB_axeP[1]
						
			
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
			local largeur 		=	diag_axeP.x
			local longeur 		= 	diag_axeP.z
			local hauteur 		= 	largeur /2 --* random .3 1.5
			
			local nvlsFaces 	= #()
			case pentes of (
				1: ( ---------- 1 PENTE ----------------------------------------------------------------------------------------------------
						--- gestion de l'angle de la pente .... ----
						hauteur = hauteur/4
						
						local pt_0 = (  [0,0,0]  *  mtrx_axeP )
						local pt_1 = (  [0,0,longeur]  *  mtrx_axeP )
						local pt_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )
						
					
						local vec1 = pt_1 - pt_0
						local vec2 = pt_2 - pt_0
						
						local pt_Origine = pt_0
						pt_Origine.z =  z 
-- 						point pos:pt_Origine	 isSelected:true
					
						local plan_pente = str_equationPlan ()
						plan_pente.creerFrom_2vecs_et_1Point	vec1	vec2		pt_Origine
						
						local pointsPente = #()
						local pointsMurs   =#()
						for i = 1 to numKnots tracee 	idSpline do (
							local pt = getKnotPoint tracee 	idSpline 	i 		
							pt.z =  z 
							append pointsMurs  pt					
							local pt_result = plan_pente.projeter_point_verticalement 	pt
-- 							ptNd = point pos:pt_result
							append pointsPente  pt_result
							
						)
						
						--- creation de la face du dessus ----
						append nvlsFaces ( creerFace  _nodeBat		pointsPente )
						
						---- creation des raccord mur ----------
						for i = 1 to pointsMurs.count - 1 do (
							local ptMur1 		= pointsMurs[i]
							local ptMur2 		= pointsMurs[i+1]
							local ptPente3 	= pointsPente[i+1]
							local ptPente4	= pointsPente[i]
							
							local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
							append nvlsFaces ( creerFace  _nodeBat		pointsRaccord )
						)
						local ptMur1 		= pointsMurs[pointsMurs.count]
						local ptMur2 		= pointsMurs[1]
						local ptPente3 	= pointsPente[1]
						local ptPente4	= pointsPente[pointsMurs.count]
						
						local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
						append nvlsFaces ( creerFace  _nodeBat		pointsRaccord )
						
				)
				2: (---------- 2 PENTES ----------------------------------------------------------------------------------------------------
					
					
						--- Plan de la Pente 1  ----
						local pt_P1_0 = (  [0,0,0]  *  mtrx_axeP )
						local pt_P1_1 = (  [0,0,longeur]  *  mtrx_axeP )
						local pt_P1_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )	
					
						local vecP1_1 = pt_P1_1 - pt_P1_0
						local vecP1_2 = pt_P1_2 - pt_P1_0
						
						local pt_Origine = pt_P1_0
						pt_Origine.z =  z 
						local plan_pente1 = str_equationPlan ()
						plan_pente1.creerFrom_2vecs_et_1Point	vecP1_1		vecP1_2		pt_Origine
					
					
					
						--- Plan de la Pente 1  ----
						local pt_P2_0 = (  [largeur,0,longeur]  *  mtrx_axeP )
						local pt_P2_1 = (  [largeur,0,0]  *  mtrx_axeP )
						local pt_P2_2 = (  [0 ,hauteur,longeur]  *  mtrx_axeP )			
					
						local vecP2_1 = pt_P2_1 - pt_P2_0
						local vecP2_2 = pt_P2_2 - pt_P2_0
						
						local pt_Origine = pt_P2_0
						pt_Origine.z =  z 
						local plan_pente2 = str_equationPlan ()
						plan_pente2.creerFrom_2vecs_et_1Point	vecP2_1		vecP2_2		pt_Origine
					
						--- Plan faitage ------
						local pt_F_0 = (  [largeur /2 ,0,0]  *  mtrx_axeP )
						local pt_F_1 = (  [largeur /2 ,0,longeur]  *  mtrx_axeP )
						local pt_F_2	=	pt_F_0 + [0,0,100]												
						local plan_verticaleFaitage =  creerPlan 	pt_F_0		pt_F_1		pt_F_2
						
						
						
						---- creation des liste des points-----------
						local pointsPente = #()
						local pointsPente1 = #()
						local pointsPente2 = #()
						local pointsMurs   =#()
						for i = 1 to numKnots tracee 	idSpline  do (
							
							local j = i+1
							if j > numKnots tracee 	idSpline do j = 1
							
							
							--- point Mur ----
							local pt 			= 	getKnotPoint tracee 	idSpline 	i 		
							pt.z = z
							append pointsMurs  pt		
							
							--- point pente ----
							local pt_pente1 = plan_pente1.projeter_point_verticalement 	pt
							local pt_pente2 = plan_pente2.projeter_point_verticalement 	pt
							if pt_pente1.z < pt_pente2.z then (
								append pointsPente  	pt_pente1
								append pointsPente1 	pt_pente1
								
							) else  (
								append pointsPente  	pt_pente2
								append pointsPente2  	pt_pente2
							)
							
							--- point mur - faitage ----
							local pt_suivant 	=  getKnotPoint tracee 	idSpline 	j
							pt_suivant.z = z
							local intersect = plan_verticaleFaitage.coupe_segment	pt 	pt_suivant							
							if intersect do (
								local pt_faitage_mur = plan_verticaleFaitage.get_intersection_segment 	pt 	pt_suivant
								append pointsMurs  	pt_faitage_mur
								local pt_faitage_pente = plan_pente1.projeter_point_verticalement 	pt_faitage_mur
								append pointsPente  pt_faitage_pente
								
								
								append pointsPente1 	pt_faitage_pente
								append pointsPente2 	pt_faitage_pente
							)
							
							
							
						)
						
						
						
						
						--------- creation des faces ---------------------
						
		
						
						--- les murs ----
						for i = 1 to pointsMurs.count  do (
							
							local j = i+1
							if j > pointsMurs.count do j = 1
							
							local ptMur1 		= pointsMurs[ i ]
							local ptMur2 		= pointsMurs[ j ]
							local ptPente3 	= pointsPente[ j ]
							local ptPente4	= pointsPente[ i ]
							
							local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
							append nvlsFaces ( creerFace  _nodeBat		pointsRaccord )
						) 
						
						
						--- les pentes -----
						append nvlsFaces ( creerFace  _nodeBat		pointsPente1 )
						append nvlsFaces ( creerFace  _nodeBat		pointsPente2 )
						
						
				)
			4: (
					---- Premier Pan ---
					pt1 = (  [0,0,0]  *  mtrx_axeP )
					pt2 = (  [0,0,longeur]  *  mtrx_axeP )
					pt3 = (  [largeur/2,0,longeur - largeur/2]  *  mtrx_axeP )
					pt4 = (  [largeur /2,0,largeur/2]  *  mtrx_axeP )
					pt1.z = pt2.z = z
					pt3.z = pt4.z =  z + hauteur
					listeDesPoints = #(pt1, pt2, pt3, pt4)
					append nvlsFaces ( creerFace  _nodeBat		listeDesPoints )
					
					---- Second Pan ---
					pt5 = (  [largeur,0,longeur]  *  mtrx_axeP )
					pt6 = (  [largeur ,0,0]  *  mtrx_axeP )
					pt5.z = pt6.z = z 
					listeDesPoints = #(pt4, pt3, pt5, pt6)
					append nvlsFaces ( creerFace  _nodeBat		listeDesPoints )
					
					---- Fronton 1 ---
					listeDesPoints = #(pt1, pt4, pt6 )
					append nvlsFaces ( creerFace  _nodeBat		listeDesPoints )
					
					---- Fronton 2 ---
					listeDesPoints = #(pt2, pt5, pt3 )
					append nvlsFaces ( creerFace  _nodeBat		listeDesPoints )
					
				)
			)
		),
		
		
		-------- Generation des parties des batiments --------------------------------------
	private
		fn creer_RdC 				_nodeBat	&z	_presetBat	=(
-- 			debug "_presetBat" var:_presetBat
			
			/* --- plancher ---
			if ep_dalle  != 0 do (
				creerFacesContour	_nodeBat	z 	ep_dalle
				z += ep_dalle
			) 
			*/
			
			--- un etage ---
			local styleFacade = m_urba.facades.presets.get_parIdUnique 		_presetBat.rdc_facade
			creer_etage	_nodeBat	z 	_presetBat.rdc_hauteur	styleFacade
			z += _presetBat.rdc_hauteur
			
		),
		fn creer_etages 			_nodeBat	&z	_presetBat	=(
			
			local nbrEtages  = 0
			if _presetBat.etages_facade != "" then (
				
				-- le nombre d'étages --
				nbrEtages = random 		_presetBat.etages_min 		_presetBat.etages_max
				local listeDeFacesDunEtage =#()
				if nbrEtages != 0 do (
					
					--- plancher ---
					if ep_dalle  != 0 do (
						local nvlsFaces = creerFacesContour	_nodeBat	z 	ep_dalle
						listeDeFacesDunEtage  += nvlsFaces
						z += ep_dalle
					) 
					
					--- un etage ---
					local styleFacade = m_urba.facades.presets.get_parIdUnique 		_presetBat.etages_facade
					local nvlsFaces = 	creer_etage	_nodeBat	z 	_presetBat.etages_hauteur		styleFacade
					listeDeFacesDunEtage  += nvlsFaces
					z += _presetBat.etages_hauteur
					
					
				
					--- on copie l'etage x fois ----
					for i = 2 to nbrEtages do (
						local vertsfin = _nodeBat.verts.count
						polyop.detachFaces _nodeBat listeDeFacesDunEtage delete:false	
						local vertsABouger = #{(vertsfin+1).._nodeBat.verts.count}
						polyop.moveVert 	_nodeBat 	vertsABouger [0,0, ( _presetBat.etages_hauteur + ep_dalle ) *  (i-1) ]
						z += ep_dalle
						z += _presetBat.etages_hauteur
					)
					
				)
				
			)  
			
			nbrEtages
			
		),
		fn creer_toiture 			_nodeBat	&z	_presetBat	=(
			
			local param 		= get_paramsBatiment	_nodeBat		
			local tracee 		= param.tracee
			local idSpline		= param.idSpline
			
			local typeDeToit =  _presetBat.toiture
			
			case typeDeToit of (
				1:			creer_toitPlat			_nodeBat	&z	
				2:			creer_toitPentes		_nodeBat	&z	1
				3:			creer_toitPentes		_nodeBat	&z	2
				4: 		creer_toitPentes		_nodeBat	&z	4
				5: 		creer_toitTerrasse	_nodeBat	&z	
				default:	creer_toitPlat			_nodeBat	&z	
			)
			
		),
		fn creer_ssBassement  	_nodeBat	&z	=(
			creerFacesContour	 _nodeBat	z 	ep_ssBassement
			z += ep_ssBassement
		),
		
		
		-------- Customs attributs / modifiers------------------------------------------------
	private
		fn ajouterModifier_batiment 	_node	=(
			
			--- le modifier ----
			local tmpMod = emptymodifier ()
			tmpMod.name = "Urba | Bâtiment"
			addModifier _node tmpMod
			
			--- Definition	CA ---------------------
			local batimentCA_def= attributes batimentCA		(
				parameters main rollout:roll_params			(
					
					tracee	type:#maxObjectTab 	tabSize:1 			tabSizeVariable:false
					idSpline	type: #integer 			--ui:ui_largeur 				default:60.
					
					--- param pour preset batiment -----					
					style						type: #string		--- l'idUnique du preset du batiment -----
					
					etages					type: #integer 	ui:spn_etages
					etages_hauteur 		type: #float 		ui:spn_etages_hauteur					
					rdc_hauteur 			type: #float		ui:spn_rdc_hauteur			
					
					mtrxAxePrincipal		type: #matrix3	
					
				)
				
				rollout roll_params "Paramètres" width:162 height:140
				(

					spinner 'spn_etages' "" pos:[43,54] width:110 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
-- 					spinner 'spn_etages_min' "" pos:[43,51] width:110 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
					
-- 					spinner 'spn_etages_max' "" pos:[43,66] width:110 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
						
					spinner 'spn_etages_hauteur' "" pos:[43,72] width:110 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
					label 'lbl18' "  Haut.:" pos:[5,71] width:38 height:15 align:#left
					spinner 'spn_rdc_hauteur' "" pos:[43,112] width:110 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
					label 'lbl19' "  Haut.:" pos:[4,111] width:38 height:15 align:#left
					
					dropdownList 'ddl_style' "" pos:[45,7] width:109 height:21 align:#left
					label 'lbl_style' "Style" pos:[5,11] width:38 height:15 align:#left
					label 'lbl23' "Etages:" pos:[5,35] width:38 height:15 align:#left
					label 'lbl24' "RdC:" pos:[5,96] width:25 height:15 align:#left
					label 'lbl8' "  Nbre.:" pos:[5,53] width:38 height:15 align:#left
					
					
					fn actualiser =(
						
						--- liste des bats -----
						local listTmp =#()
						for bat in urba.batiments.presets.get () do
							append listTmp bat.nom
						ddl_style.items = listTmp
						
						local batTmp  = urba.batiments.presets.get_parIdUnique	style
						ddl_style.selection = urba.batiments.presets.trouver_ID	batTmp
					)
					
					
					on roll_params open do actualiser ()
					on ddl_style 						selected 	val do (
						
						style = (urba.batiments.presets.get_preset	val).idUnique
						urba.regenerer_batiment $
						
					)
					on spn_etages_hauteur 		changed 	val do urba.regenerer_batiment $
					on spn_rdc_hauteur 			changed	 	val do urba.regenerer_batiment $
					on spn_etages 					changed 	val do urba.regenerer_batiment $
				)
			) -- fin CA
			
			---- ajouter le CA
			CustAttributes.add 	tmpMod 	batimentCA_def	--#Unique BaseObject : false
			
		),
		fn ajouterModifier_ville 			_node	=(
			
			--- le modifier ----
			local tmpMod = emptymodifier ()
			tmpMod.name = "Urba | Ville"
			addModifier _node tmpMod
			
			
			--- Definition	CA ---------------------
			villeCA_def= attributes villeCA		(
				parameters main rollout:params			(
				)
				 
				rollout params "Paramètres"
				(
					
				)
			) -- fin CA
			
			
			---- ajouter le CA
			CustAttributes.add 	tmpMod 	villeCA_def	
		),
		
		
	------ preparations ------------------------------------------
	private
		nomModelTemp,
		fn positionnerPivot_modele	 _node =(
			local segmentsOuverts 	= polyop.getOpenEdges _node
			local pointsSegsOuverts 	=#()
			local pointsResult 			=[0,0,0]
			for seg in segmentsOuverts do (
				local ptsDuSegment = polyop.getVertsUsingEdge   _node	seg
				for pt in ptsDuSegment do
					appendIfUnique pointsSegsOuverts	pt
			)
			
			--- on cherche le point  ------
			format "pointsSegsOuverts : %\n" pointsSegsOuverts
			
			for idPt in pointsSegsOuverts do (
				
				if idPt == pointsSegsOuverts[1] then pointsResult = _node.verts[ idPt ].pos
				else (
					local pt =_node.verts[ idPt ].pos
					if pt.x < pointsResult.x do pointsResult = pt
					if pt.y < pointsResult.y do pointsResult = pt
					if pt.z < pointsResult.z do pointsResult = pt
				)
			)
			_node.pivot = pointsResult
			
		),
		fn  creer_nodeBatiment 		_tracee	_idSpline	=(
			
			local nvBatiment 		= creerPolyVide ()		
			nvBatiment.name 		= uniqueName "Urba | Batiment - "
			nvBatiment.parent 		= _tracee
			nvBatiment.wirecolor 	= _tracee.wirecolor
			
			-- centrer le pivot du batiment
			local centre = [0,0,0]
			for id_pt = 1 to ( numKnots 	_tracee 	_idSpline ) do	 (
				centre += ( getKnotPoint 	_tracee 	_idSpline 	id_pt )
			)
			centre = centre / ( numKnots 	_tracee 	_idSpline )
			nvBatiment.pivot = centre
			
			---- on ajoute le modifer --
			ajouterModifier_batiment		nvBatiment
			nvBatiment.modifiers[1].tracee[1] 			= 	( nodeTransformMonitor node:_tracee 	forwardTransformChangeMsgs:false )
			nvBatiment.modifiers[1].idSpline				=	_idSpline
			nvBatiment.modifiers[1].mtrxAxePrincipal	=	get_axePrincipal		_tracee 	_idSpline
			
			nvBatiment
		),
		fn preparer_modelFacade 	_node	_elementFacade	=  (
			
			nomModelTemp = _node.name
			
			---- fenetre pour le nom du model ----------
			rollout roll_getNomModele "" width:269 height:61
			(
				local b_valider = false
				editText 'edt_nom' "" pos:[94,10] width:159 height:16 align:#left
				button 'btn_annuler' "Annuler" pos:[157,35] width:49 height:16 align:#left
				button 'btn_valider' "Valider" pos:[205,35] width:49 height:16 align:#left
				label 'lbl44' "Nom du modèle:" pos:[14,11] width:80 height:18 align:#left
				
				--------------------------------------------------------------------------				
				fn actualiser =(
					btn_valider.enabled = not edt_nom.text == "" 
				)				
				fn initialiser =	(
					edt_nom.text = nomModelTemp
					actualiser ()
					setFocus edt_nom					
				)				
				fn valider =(					
					b_valider = true
					nomModelTemp = edt_nom.text 
					destroyDialog roll_getNomModele
				)
				
				--------------------------------------------------------------------------				
				on roll_getNomModele 	close 			do 	if not b_valider do nomModelTemp = ""
				on roll_getNomModele 	open 				do 	initialiser 	()
				on edt_nom 				changed _txt 	do 	actualiser 	()				
				on edt_nom 				entered 	_txt 	do 	valider 		()				
				on btn_valider 			pressed 			do	valider 		()
				on btn_annuler 			pressed 			do 	destroyDialog roll_getNomModele
				
			) ----------- Fin rollout -----------------------------
			createDialog	roll_getNomModele		 modal:true	 	escapeEnable:false
			
			
			
			
			if nomModelTemp != "" do (	
				
				debug "preparation du model"
				debug "nomModelTemp" var:nomModelTemp
				
				--- preparation du model -------
				local nvModel_node = copy _node 
				convertToPoly 	nvModel_node
				local  BB = nodeGetBoundingBox 	nvModel_node	(matrix3 1)
				positionnerPivot_modele _node
				nvModel_node.rotation = quat 0 0 0 1
				nvModel_node.pos  = [0,0,0]
				
				
				debug "sauvegarde du fichier MAX du model"
				
				--- sauvegarde du fichier MAX ------
				local nomFichier =	dossier_modelesFacades + nomModelTemp + ".max"
				debug "nomFichier" var:nomFichier
				saveNodes 		nvModel_node	 nomFichier	quiet:true
				delete nvModel_node
				
				debug "creation du preset du model"
				
				---- creation du preset Model -----
				local nvModele 		= m_urba.facades.modeles.creer_preset ()
				nvModele.nom 		= nomModelTemp
				nvModele.fichier 		= nomFichier
				
				m_urba.facades.modeles.sauvegarder nvModele
				
				---- maj de l'element de facade -----
				_elementFacade.model = 	nvModele.idUnique
				m_urba.facades.elementsDeFacade.sauvegarder 	_elementFacade
				
				debug "Model créé."
				
				nvModel
				
			)
			
			
		),
	public	
		fn preparerShape 	_shape	=(
			
			local subSplineOuvertes =#()
			local resultTracee	= copy	_shape
			resultTracee.name 	= uniqueName	"Urba | Ville "
			
			convertToSplineShape 	resultTracee
			
			--- on ne garde que les shape fermé et on tounre tout ds le mm sens-----
			for idSpline = 1 to (numSplines resultTracee) do
				if isClosed  resultTracee	idSpline	then	(				
					--- on fait tourner les spline dans le meme sens ----
					if not estPolygone_sensPositif 	resultTracee 	idSpline do
						reverse		resultTracee	idSpline				
				) else (
					insertItem  idSpline	subSplineOuvertes 	1
				)
			
			---- on supprimer les spline ouvertes --
			for id in subSplineOuvertes do
				deleteSpline resultTracee	id
			
			---- on ajoute le custom attribut au tracee--
			ajouterModifier_ville		resultTracee
			
			resultTracee
			
		),
		
		
		
		
	private
		fn construire_batiment		_node	_presetBat =(
			
			--- on recupere les parametre sur le node ---------
			local param 		= get_paramsBatiment	_node		
			local tracee 		= param.tracee
			local idSpline		= param.idSpline
			
			--------- la position d'origine  en Z ---------
			local zCourant 	= 		tracee.pos.z	- ep_ssBassement
			local nbrEtages = 0
			
			--- construction du ploy ------
			creer_ssBassement					_node		&zCourant
			creer_rdc 								_node		&zCourant		_presetBat
			nbrEtages = creer_etages			_node		&zCourant		_presetBat
			creer_toiture							_node		&zCourant		_presetBat
			
			---majDu nbre d'etage -------
			_node.modifiers[1].etages 		= nbrEtages
		),
	
	-------- Génération des batiments ---------------------------
	public		
		
		fn maj_presetBat 		_nodeBat	_presetBat =(
			---- maj des data du node du batiment  --------
			_nodeBat.modifiers[1].style 					= _presetBat.idUnique
			_nodeBat.modifiers[1].etages_hauteur 	= _presetBat.etages_hauteur
			_nodeBat.modifiers[1].rdc_hauteur			= _presetBat.etages_hauteur
		),
		fn appliquer_presetBat 		_nodeBat	_presetBat 		majPreset:true	=(
			
			--- maj des parametres ---
			if majPreset	do	maj_presetBat 		_nodeBat	_presetBat
			
			--- maj du poly -----
			viderPoly 	_nodeBat					
			construire_batiment		_nodeBat	_presetBat
			
		),
		
		fn creer_batiment  	_tracee		_idSpline	_presetBat	 	=(
			local nvBatiment  = creer_nodeBatiment 		_tracee	_idSpline	
			maj_presetBat 			nvBatiment		_presetBat
			construire_batiment		nvBatiment		_presetBat
			nvBatiment
		)
	 
) -- fin struct -------------------------------


















