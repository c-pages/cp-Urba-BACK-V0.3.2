/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale
	
##########################################################################################################################
	
	Plugin Batiment - les structures du plug --------------------
	
##########################################################################################################################

	NOTES :
	
##########################################################################################################################
	
	todo:
	- gerer les unité des parametre (pour le calcul ou  l'affichage des longueurpar ex..)
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [23/09/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/







------------------------------------------------------------------------------------------------------------------------------------------------------
--------- STRUCTURES Datas --------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------


struct str_enregistreurDeNode (
	private
	separateur_items 	= ";",
	separateur_tableaux = "§",
	
	public
	fn get_datas 		_node 		=(
		
		local modele_result 	= str_facade_modele ()
		local nodeTemp 		=   _node
-- 		convertToPoly nodeTemp
		
		modele_result.verts 		= for i=1 to (polyop.getNumVerts  	nodeTemp )  	collect ( polyop.getVert  						nodeTemp 	i )		
		modele_result.edges		= for i=1 to (polyop.getNumEdges  	nodeTemp )  	collect ( polyop.getEdgeVerts  				nodeTemp 	i )
		modele_result.faces 		= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceVerts  				nodeTemp 	i )
		modele_result.SMs 		= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceSmoothGroup  	nodeTemp 	i )
		modele_result.matIDs	= for i=1 to (polyop.getNumFaces  	nodeTemp )  	collect ( polyop.getFaceMatID   			nodeTemp 	i )
		
		local  BB = nodeGetBoundingBox 	nodeTemp	(matrix3 1)
		modele_result.longueur 	=  BB[2].x - BB[1].x
		modele_result.hauteur 	=  BB[2].z - BB[1].z
-- 		delete nodeTemp
		
-- 		format "modele_result :%\n" modele_result
		modele_result
	),

	fn creer_objet		_modele		m_this		ndDest:		transf_mtrx:	=(
		
		if ndDest == unsupplied do
			ndDest = m_this.delegate
		
		local verts		
		if transf_mtrx != unsupplied then 
			local verts = for  pt in _modele.verts  collect pt *= transf_mtrx
		else verts = _modele.verts
		
			
		local vrts_avtOp 	= polyop.getNumVerts 		ndDest
		local faces_avtOp 	= polyop.getNumFaces 	ndDest
		
		-- les vertex -- 
		for vert in  verts do 
			polyop.createVert ndDest	vert
			
		-- les edges -- 
		local edges = _modele.edges
		for edge_pts in  edges do 
			polyop.createEdge ndDest		(vrts_avtOp + edge_pts[1] )	( vrts_avtOp + edge_pts[2] )
		
		-- les faces -- 
		local faces = _modele.faces
		for face_pts in  faces do (
			face_pts = for face_pt in face_pts collect ( vrts_avtOp + face_pt )
			polyop.createPolygon	 ndDest		face_pts
		)
		--- les smoothing group ----
		local SGs = _modele.SMs
		for i = 1 to  SGs.count do 
			polyop.setFaceSmoothGroup	 ndDest		( faces_avtOp + i )  SGs[i]
		
		--- les material ID ----
		local matIDs = _modele.matIDs
		for i = 1 to  matIDs.count do 
			polyop.setFaceMatID	 ndDest		( faces_avtOp + i )  matIDs[i]
		
	)
	
) --- fin struct enregistreur de nodes ----------


struct str_datasMgr (
	
		m_prt,
		
		
		
	private
		separateur_params 			="§",
		separateur_mutation 		= "¨",
		separateur_mutationTab 	= "£",
		separateur_items 			= "^",
	public
	
	
		fn get_array_to_string		_tab	=(
			local tabString = ""
			for item in _tab do (
				
				case classof item  of (
					string:	tabString += item 		as string + separateur_items
					Integer:	tabString += item 		as string + separateur_items
					Float:	tabString += item 		as string + separateur_items
					
					Point3:	tabString += item 		as string + separateur_items
					Array:	( 
						tabString += item 		as string + separateur_items
						
					)
					---- les reste doit etre nos struct a nous ... -------
					default:	(
-- 									format "---->Default\n" 
						tabString += item.id 	as string + separateur_items
					)
				)
			)
			tabString
		),
		fn get_string_to_array		_string	=(
			
			local tabResult = #()
			local items 	= filterString 	_string 		separateur_items
			
			
			for item in items do (
										
				local data_exe 	= execute item
				
				if data_exe 		== undefined then (
				--------------- string ---------------
					append tabResult ( item )
				) else	if classof data_exe == Name then (
				
				--------------- un objet ---------------
					local elemTmp =  ( m_prt.get_parametre	  item 	)	
					
					--- un id (name)------
					if elemTmp == undefined do
						elemTmp = item
					
					append tabResult		elemTmp
					
				) else 	(					
				--------------- Nombres ---------------			
					append tabResult 	( data_exe)
				)
			)
			tabResult
		),
		
		fn get_datas_string 		_element	=(
			local txtResult = ""
			local propNames = getPropNames _element
			
			for param in propNames do (
				local prop = ( getProperty  _element 	param )
				local type = classof prop
				
-- format  "get_datas_string	--->	param  :%\n" param
-- format  "get_datas_string	--->	type  :%\n" type
-- format  "get_datas_string	--->	superClassof  :%\n" (superClassof prop )
				
				case type of (
					
					--- les trucs qu'on zappe ------
					MAXScriptFunction:	()
					RolloutClass:()
					
					--- les trucs qu'on prend en compte	------
					/* string:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					) */
					array: (
						local tabString = get_array_to_string		prop
						txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
					)
					Name:		(
						txtResult+=  param as string  + separateur_mutation	+	"#" + prop as string  + separateur_params
					)
					default:						(
					/* 	if superClassof prop == StructDef then
							txtResult+=  param as string  + separateur_mutation 	+	prop.id  + separateur_params
						else */
							txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
				) -- fin scase --
				
			)
			txtResult
			
		),
		fn set_datas_string 		_datas_string 		_element 		=(
			
-- 			stack ()
			
			local datasTab 	= filterString 	_datas_string 		separateur_params
-- 			local propNames 	= getPropNames _element
			
			for datas in datasTab do (
				
				local dataTab		= filterString datas 	separateur_mutation
				local propNom 	= dataTab[1]
				local typeProp 	= classof ( getProperty _element propNom  )
				
-- format  "set_datas_string	--->	propNom :%\n" propNom
				case typeProp of (
					
					--- les trucs qu'on zappe ------
					MAXScriptFunction:	()
					RolloutClass:()
					
					--- les trucs qu'on prend en compte	------
					string:					(
						
-- 							--- on tente le struct ---
-- 							local data =  ( m_prt.get_parametre	  dataTab[2] 	m_this	)	
-- 							
-- 							--- si pas struct ---
-- 							if data == undefined do
							local data =   dataTab[2]
							
							if data   == undefined do data =""
							setProperty _element propNom data
					)
					array: (
--  format  "set_datas_string	--->	ARRAY		propNom :%\n" propNom
						if dataTab.count >1 do (
							local datas_liste  = filterString	dataTab[2] 	separateur_items
							local tabResult =#()
							for data in datas_liste do (
								
								local data_exe 	= execute data
								
								if data_exe 		== undefined then (
								--------------- string ---------------
									append tabResult ( data)
								) else	if classof data_exe == Name then (	
								
								--------------- un objet ---------------
									local elemTmp =  ( m_prt.get_parametre	  data 	)	
									
									--- un id (name)------
									if elemTmp == undefined do
										elemTmp = data
									
-- format  "set_datas_string	--->	elemTmp :%\n" elemTmp
									
									
									append tabResult		elemTmp
									
								) else 	(						
								--------------- Nombres ---------------			
									append tabResult 	( data_exe)
								)
							)
							setProperty _element 	propNom 	tabResult
						)
					)
					default:						(
						if dataTab[2] != undefined do  (
							
							local data = execute dataTab[2]
							
							setProperty _element propNom data
						)
						
					)
				)
			)
			_element
		)
)



------------------------------------------------------------------------------------------------------------------------------------------------------
--------- STRUCTURES Grandes fonctions -----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
struct	str_geo	(
	
		m_plug, 
		
		fn vider 													=(
			if (polyop.getNumFaces m_this.delegate) >0 do (
				local listeDesFaces = #{1..(polyop.getNumFaces m_this.delegate)} as array
				polyop.deleteFaces m_this.delegate	listeDesFaces		delIsoVerts:true
				polyop.deleteIsoVerts m_this.delegate
			)
		),
		
	
	
		
		fn points	_liste_pts_position								=(
			local result = #()
			for pos_pts in _liste_pts_position do 			
				append result ( polyop.createVert 	m_this.delegate		pos_pts )
			result
		),
		fn edges	_liste_pts_id					fermer:false	=(
			local result = #()
			
			for i = 1 to _liste_pts_id.count - 1	 do 	(	
				local pt_id_1 = _liste_pts_id[i]
				local pt_id_2 = _liste_pts_id[i+1]
				append result ( polyop.createEdge 	m_this.delegate	 pt_id_1	 pt_id_2 )
			)
			if fermer do (
				local pt_id_1 = _liste_pts_id[_liste_pts_id.count]
				local pt_id_2 = _liste_pts_id[1]
				append result ( polyop.createEdge 	m_this.delegate	 pt_id_1	 pt_id_2 )
			)
			result
		),
		fn face		_liste_pts_id					matID:			=(
			local result = polyop.createPolygon m_this.delegate  _liste_pts_id
			result
		),
		
		fn pointsEtFaces  _liste_pts_position	=(
			local id_pts 	= points 	_liste_pts_position
			local id_edges	= edges 	id_pts
			local idFace 	= face		id_pts
			idFace
		),
		
		
		fn faceVerticale 	pt1 	pt2 		z 					ht:			=(
		
			local VERSION_BACK = true
			
			if not VERSION_BACK then (
				------------	NOUVELLE VERSION	----------------
				
				
			) else (  
				------------	VERSION BACK 	----------------
				
				local hauteur 
				if ht != unsupplied then	hauteur = ht
					else hauteur 	=	m_this.niveaux_hauteur 
				
				local verts = polyop.getNumVerts m_this.delegate		
				
				polyop.createVert m_this.delegate	[pt2.x, pt2.y, z]	
				polyop.createVert m_this.delegate	[pt1.x, pt1.y, z]
				polyop.createVert m_this.delegate	[pt1.x, pt1.y, z + hauteur]
				polyop.createVert m_this.delegate	[pt2.x, pt2.y, z + hauteur]
				
				polyop.createEdge m_this.delegate (verts+1) (verts+2)
				polyop.createEdge m_this.delegate (verts+2) (verts+3)
				polyop.createEdge m_this.delegate (verts+3) (verts+4)
				polyop.createEdge m_this.delegate (verts+4) (verts+1)
				
				polyop.createPolygon m_this.delegate  #((verts+4),(verts+3),(verts+2),(verts+1))
			)
		),
		fn facesContour	ptsContours	 altitude 		hauteur 			=(
			
			local VERSION_BACK = true
			
			if not VERSION_BACK then (
				------------	NOUVELLE VERSION	----------------
				
				
			) else (  
				------------	VERSION BACK 	----------------
				
				local facesDuContour =#()
				local listePts = #()
				if hauteur <0 then
					listePts = for i = ptsContours.count to 1 by -1 collect ptsContours[i]
				else listePts = ptsContours
				
				for i_pt = 1 to listePts.count do	 (
					local pt_1 = listePts[i_pt]
					local pt_2 
					
					if i_pt == listePts.count then
						pt_2 = listePts[1]
					else pt_2 =  listePts[i_pt + 1 ]
					
					local nvlFace = faceVerticale 		pt_1		pt_2 	altitude 		ht:hauteur
					if nvlFace != undefined do
						appendIfUnique facesDuContour	nvlFace
					
				)
				
				facesDuContour
				
			)
		)
		
-- 	) -- fin creer
	
) --- fin GEo







struct str_constr_outils (
		
	
	
	
	
		---- manipulation de tableaux ----
		fn ComparerTableaux 	first 	second =
		(
			result = true
			if first.count != second.count then
				result = false
			else
				for i = 1 to first.count do
					if first[i] != second[i] do result = false
			result
		),
		fn virerDoublonsDansTableau  _tab = (
			for i = 1 to _tab.count do
			(
				for j = _tab.count to i+1 by -1 do
				(
					test = ( ComparerTableaux  _tab[i] _tab[j] )
					if test do
					(
						deleteItem _tab j
					)
				)--end j loop
			)--end i loop
		),
		
		
		
		
		
		
		---- groupes de selection  ----
		fn grouperFaces 	_node 	_faces 	_nom 	=(
			if _node.faces[_nom] == undefined  
							then		_node.faces[_nom] = 	_faces
							else		(								
								tabFaces = for face in _node.faces[_nom] collect face.index
								tabFaces += _faces
								_node.faces[_nom] = tabFaces
							)
		),
		fn degrouperFaces 	_node 	_facesARetirer 	_nom 	=(
			if _node.faces[_nom] != undefined  do		(								
				tabFaces = for face in _node.faces[_nom] collect 	face.index
					for  _face in _facesARetirer do (
						idItem = findItem tabFaces   _face
						if idItem >0 do deleteItem 	tabFaces  idItem
					)
				_node.faces[_nom] = tabFaces
			)
		),
		
		
		
		---- manipulation des selection  ----
		fn etendreSelecFaces		_node 	_faces	= (
			
			_faces_a_retirer = _faces 		---- ( polyop.getFaceSelection  _node ) as array
			_node.EditablePoly.GrowSelection ()
			_facesExtension	= ( polyop.getFaceSelection  _node ) 
			for face in _faces_a_retirer 	do _facesExtension	[face] 	= false
			polyop.setFaceSelection  _node 	_facesExtension	
			
		),
		
		fn etendreFaces		_node 	_faces	= (
			local selectBack = polyop.getFaceSelection  _node
			polyop.setFaceSelection  _node 	_faces
			_node.EditablePoly.GrowSelection ()
			local facesEtendus	=  polyop.getFaceSelection  _node 
			format "facesEtendus : %\n" facesEtendus
			polyop.setFaceSelection  _node  selectBack
			facesEtendus
		),
		
		fn facesDuDessous		_node	_faces	=	(
			
			local _selectBack 	= 	polyop.getFaceSelection  _node 
			local	_facesDuBas 	= #()
			for _face in _faces do (
				polyop.setFaceSelection  	_node 	#(_face)
				outils.etendreSelecFaces 	_node 	#(_face)
				facesCadre = polyop.getFaceSelection  _node
				local		_faceDuBas
				for _faceCadre in facesCadre do 
					if _faceDuBas == undefined 	
						then _faceDuBas = _faceCadre
					else	if ( outils.centreDeLaFace	_node	_faceCadre ).z  <  (outils.centreDeLaFace	_node	_faceDuBas ).z 	
						then _faceDuBas = _faceCadre
				
				append _facesDuBas _faceDuBas
			)
			
			format "Faces du bas : %\n" _facesDuBas
			polyop.setFaceSelection  _node 	_selectBack
			
			for _face in _facesDuBas do
				format "face : %  centre Z : % \n" 	_face	( outils.centreDeLaFace	_node	_face )
			
			
			_facesDuBas
		),		
		fn BACKfacesDuDessous		_node	_faces	=	(
			
			local	_facesDuBas = #()
			for _face in _faces do (
				polyop.setFaceSelection  _node 	#(_face)
				outils.etendreSelecFaces 		_node 	#(_face)
				facesCadre = polyop.getFaceSelection  _node
				local		_faceDuBas
				for _faceCadre in facesCadre do 
					if _faceDuBas == undefined 	then _faceDuBas = _faceCadre
						else	if ( outils.centreDeLaFace		_node		_faceCadre ).z  <  (outils.centreDeLaFace		_node		_faceDuBas ).z 	then _faceDuBas = _faceCadre
				
				append _facesDuBas _faceDuBas
			)
			
			format "Faces du bas : %\n" _facesDuBas
			_facesDuBas
		),
		
		fn faceLaPlusProche		_node		_faces		_ptReference 	= (							
			local faceLaPlusProche
			local distMin = 1000000000000.0
			for faceTmp in _faces do (
				centreFaceTmp 		= 		outils.centreDeLaFace		_node		faceTmp
				dist = length 	(  	centreFaceTmp - _ptReference )
				if dist < distMin do (
					distMin = dist
					faceLaPlusProche = faceTmp
				)
			)
			faceLaPlusProche
		),
		
		---- selection par taille ----
		fn arreteLaPlusPetite		_node		_listeArretes	= (
			
			local arretePlusPetite,  longMin
			
			for arrete in _listeArretes do (
				listePoints = polyop.getEdgeVerts  	_node	arrete
				pt1 = _node.verts[listePoints[1]]
				pt2 = _node.verts[listePoints[2]]
				longueurArrete =  length ( pt1.position	- pt2.position  )
				
				if longMin == undefined do (
					longMin = longueurArrete					
					arretePlusPetite = arrete
				)
				
				if longueurArrete < longMin do (
					longMin = longueurArrete
					arretePlusPetite = arrete
				)
				
			) -- fin for do --
			
			arretePlusPetite
			
		),
		fn arretesLesPlusPetites		_node		_listeArretes	 nbre: = (
			
			local _arretesPlusPetites,  longMin
			local _nbresArretes = floor ( (_listeArretes as array).count / 2 )
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresArretes	= floor ( (_listeArretes as array).count / 2 )
				else		_nbresArretes	= nbre
				
			while _result.count < _nbresArretes do (
				local _arreteAAJouter = arreteLaPlusPetite		_node		_listeArretes
				
				deleteItem	_listeArretes 	_arreteAAJouter
				append 		_result  		_arreteAAJouter
			)
			
			_result
			
		),		
		fn facesLesPlusPetites	_node	_faces	nbre: =(
			local _nbresFaces 
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresFaces	= floor ( (_faces as array).count / 2 )
				else		_nbresFaces	= nbre
			
			while _result.count != _nbresFaces do (
				local _min = 1000000000000000000000000000.0
				local _faceAAJouter
				for _face in _faces do (
					if polyop.getFaceArea _node _face <= _min  and (findItem _result _face ) == 0 do (
						_faceAAJouter 	= _face
						_min 				= polyop.getFaceArea _node _face 
					)
				)
				append _result 	_faceAAJouter
			)
			_result
		),		
		fn facesLesPlusGrandes	_node	_faces	nbre:  =(
			local _nbresFaces 
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresFaces	= floor ( (_faces as array).count / 2 )
				else		_nbresFaces	= nbre
			
			while _result.count != _nbresFaces do (
				local _min = 0.0
				local _faceAAJouter
				for _face in _faces do (
					if polyop.getFaceArea _node _face >= _min  and (findItem _result _face ) == 0 do (
						_faceAAJouter 	= _face
						_min 				= polyop.getFaceArea _node _face 
					)
				)
				append _result 	_faceAAJouter
			)
			_result
		),
		
		
		---- selection par position ----
		fn faceLaPlusHaute 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute = undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  > ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			faceHaute
		),		
		fn faceLaPlusBasse 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute == undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  < ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			 faceHaute
		),
		
		
		fn get_hauteurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local hauteur = BB[2].z -  BB[1].z 
			hauteur
		),
		fn get_largeurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local largeur = BB[2].x -  BB[1].x 
			largeur
		),
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
		
		---- meusures ----
		fn ZMinFace 	_node  _listeFaces = (
			
			local pointLePlusBas
			
			for face in _listeFaces do (
				listePoints = polyop.getFaceVerts  	_node	face
				for IDpt in listePoints do (
					pt = _node.verts[IDpt]
					if pointLePlusBas == undefined do pointLePlusBas = pt.position.z
					if pointLePlusBas > pt.position.z do pointLePlusBas = pt.position.z
				)
			)			
			 	pointLePlusBas			
		),
		fn largeurFace 	_node _face = (
			local listePoints = polyop.getFaceVerts  	_node	_face
			local result = 0
			for  i=1 to listePoints.count-1 do (
				pt_1 = _node.verts[ listePoints[ i ] ]				
				for  j=i+1 to listePoints.count do (				
					pt_2 	= _node.verts[ listePoints[ j ] ]
					dist 		= length ( pt_2.position - pt_1.position )
					if pt_1.position.z == pt_2.position.z and dist > result
						do result = dist
				)
			)
			 result
		),
		fn hauteurFace 	_node 	_face = (
			local _listePoints = polyop.getFaceVerts  	_node	_face
			local _result = 0, _mini = 10000000000, _maxi = 0
			for  _pt in _listePoints 	do (
				_pt = _node.verts[ _pt ]		
				if _pt.position.z < _mini 	do _mini 	= _pt.position.z
				if _pt.position.z > _maxi 	do _maxi 	= _pt.position.z
			)
			_result = _maxi  - _mini
			_result
		),
		
		
		fn centreDeLaFace	_node	_face = (
			
			local versionMax = true
			local centre = [0,0,0]
			
			---- la version max fait  une position  moyenne de tout les points , => pb si 5points sur  la face par ex ----
			if versionMax then
				centre = polyop.getFaceCenter _node _face
			
			---- debut de version centre perso qui deconne ----
			else (
				
				local listePoints 							= polyop.getFaceVerts  	_node	_face
				local pointsAlignesVerticalement	= #()
				local ptsResult 								= #()
				local coinHtG, coinHtD, coinBsG, coinBsD
				
				---- regrouper les points alignés verticalement	----
				for  i=1 to listePoints.count do (
					
					local	ID_pt_1 	= listePoints[ i ] 
					local	pt_1 		= _node.verts[ ID_pt_1 ]				
					local resultTmp = #( ID_pt_1 )
					
					for  j=1 to listePoints.count do (
						ID_pt_2 = listePoints[ j ] 					
						pt_2 = _node.verts[ ID_pt_2 ]
						
						if floor (  pt_1.position.x * 10 )	== floor ( pt_2.position.x * 10 ) do 
							if floor ( pt_1.position.y * 10 ) == floor ( pt_2.position.y * 10 ) do 
								appendIfUnique resultTmp 		ID_pt_2
						
					)
					sort resultTmp
					
					if resultTmp.count > 1 do 	append 	 	pointsAlignesVerticalement 		resultTmp
					
				)
				
				virerDoublonsDansTableau  pointsAlignesVerticalement 
				
				---- selection dans chaque groupe de points du plus haut et du plus bas	----
				for listPts in pointsAlignesVerticalement do (
					---- min ----
					local minZ, maxZ
					for ptID in listPts do (
						if minZ == undefined do minZ = ptID
						if maxZ == undefined do maxZ = ptID
						
						if _node.verts[ ptID ].position.z > _node.verts[ minZ ].position.z   do minZ =ptID
						if _node.verts[ ptID ].position.z < _node.verts[ maxZ ].position.z  do maxZ =ptID
						
					)
					append ptsResult minZ
					append ptsResult maxZ
				)
				
				sort ptsResult
				
				---- moyenne des points hauts et bas	----
				if ptsResult.count != 0 do (
					for IDpt in ptsResult do  (
						centre += _node.verts[ IDpt ].position
						format "_node.verts[ IDpt ].position : %\n" _node.verts[ IDpt ].position
					)
					centre = centre / ptsResult.count
	-- 				format "	=>	centre : %\n" centre
				)
						format "face : %\n" 	_face
				format "	=>	centre : %\n" centre
				
				centre
			)
		) -- fin else
		
)	-- fin struct outils






















