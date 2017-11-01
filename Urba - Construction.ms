/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA
	Générateur de ville
	
##########################################################################################################################
	
	La structure d'édition de construction architecturale.
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [27/07/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/



---- la structure outils divers	---------------------------------------------------------------------------------------------
struct urba_construction_outils (
	
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
	
	
	---- tester la selection pour la mise a jour du rollout	----
	fn estValide	=	(
		
		if (selection as array).count != 1  				do return false
		_node = ( selection as array )[1]
		if classOf _node != Editable_Poly  				do return false
		if subobjectLevel != 4 								do return false
		_faces = (  polyop.getFaceSelection  _node  ) as array 
		if _faces.count == 0									do return false
		
		return true
		
	),
	
	
	
	
	---- manipulation des faces du node ----
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
	
	
	
	fn etendreSelecFaces		_node 	_faces	= (
		
		_faces_a_retirer = _faces 		---- ( polyop.getFaceSelection  _node ) as array
		_node.EditablePoly.GrowSelection ()
		_facesExtension	= ( polyop.getFaceSelection  _node ) 
		for face in _faces_a_retirer 	do _facesExtension	[face] 	= false
		polyop.setFaceSelection  _node 	_facesExtension	
		
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
		
		return 	arretePlusPetite
		
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
		return faceHaute
	),		
	fn faceLaPlusBasse 	_node 	_faces = (
		local  faceHaute 
		for faceID in _faces do (
			if faceHaute == undefined do faceHaute = faceID
			if  ( polyop.getFaceCenter 	_node 	faceID ).z  < ( polyop.getFaceCenter 	_node	faceHaute ).z do
				 faceHaute = faceID
		)
		return faceHaute
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
		return 	pointLePlusBas			
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
		return result
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

















---- la structure de construction	---------------------------------------------------------------------------------------------
struct str_urba_construction (
	
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba - construction",
	fn debug 	_txt  var:	 param:    =(
		if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	),
	
	
	outils = urba_construction_outils (),
	
	--- DETAILS	----
	fn	tablette		_node	_facesBase = (
		
		---- selection des faces	----
		polyop.setFaceSelection _node	_facesBase		
		
		---- matID  tablette	----
		_node.EditablePoly.setMaterialIndex 		matID.tablette	 	1
		
		---- extrusion  des tablettes	----
		_node.extrusionType 				= 0
		_node.faceExtrudeHeight 		= prefs.ht_tablette
		_node.EditablePoly.buttonOp 	#Extrude
		
		-- listes des trucs a supprimer	(points et arretes en trop )	----
		listeArretesAVirer 	= polyop.getEdgesUsingFace	_node	( ( polyop.getFaceSelection  _node ) as array )
		listePointsAVirer 	= polyop.getVertsUsingFace  	_node	( ( polyop.getFaceSelection  _node ) as array )
		
		---- Extrusion du débord des tablettes 	----
		outils.etendreSelecFaces		_node		( ( polyop.getFaceSelection  _node ) as array )
		_node.faceExtrudeHeight = prefs.ep_tablette
		_node.extrusionType = 1
		_node.EditablePoly.buttonOp #Extrude
		
	),
	fn cadre 	_node	_facesBase = (
		
		---- selection des faces	----
		polyop.setFaceSelection _node	_facesBase		
		
		---- matID  menuiseries	----
		_node.EditablePoly.setMaterialIndex 		matID.menuiseries	 	1
		
		---- Inset de la hauteur des menuiseries	----
		_node.insetType = 1
		_node.insetAmount = prefs.larg_cadreFenetre
		_node.EditablePoly.buttonOp 		#Inset
		
		---- Extusion des menuiserie	----
		_node.extrusionType 				= 0
		_node.faceExtrudeHeight 		= -prefs.ep_cadreFenetre
		_node.EditablePoly.buttonOp	#Extrude 
		
		---- matID  vitrage	----
		_node.EditablePoly.setMaterialIndex 		matID.verre	 	1
		
	),
	
	--- NIVEAUX ----
	fn etage 	_node	_faces	= (
		undo "construction : étage" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
				
				---- extrusion de la hauteur sous plafond----
				_node.extrusionType = 0
				_node.faceExtrudeHeight = prefs.ht_etage
				_node.EditablePoly.buttonOp #Extrude
				
				---- le nom de la selection des "facades"----
				_faceSelectionTmp 	= (  polyop.getFaceSelection  _node  ) as array 
				outils.etendreSelecFaces		_node 	_faceSelectionTmp
				_facesFacades 			= 	(  polyop.getFaceSelection  _node  ) as array 
				outils.grouperFaces 	_node	_facesFacades	"const_facades" 	
				polyop.setFaceSelection  _node _faceSelectionTmp
				
				---- extrusion de l'épaisseur de la dalle----
				_node.faceExtrudeHeight = prefs.ep_dalle
				_node.EditablePoly.buttonOp #Extrude
				
				---- le nom de la selection des "dalles"----
				_faceSelectionTmp 	= (  polyop.getFaceSelection  _node  ) as array 
				outils.etendreSelecFaces		_node 	_faceSelectionTmp
				_facesFacades 			= 	(  polyop.getFaceSelection  _node  ) as array 
				outils.grouperFaces 	_node	_facesFacades	"const_dalles" 	
				polyop.setFaceSelection  _node _faceSelectionTmp
				
			) -- fin redraw off
			redrawViews()
		)	-- fin undo
	),
	fn diviser	_ratio 	_node	_faces	= (			
		undo "construction : Diviser" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
				
				local _facesFinales = #()
				
				--- Decoupage des faces	----
				polyop.setEdgeSelection  _node #()					
				for face in  _faces do (
					
					local centreFace 			= 	outils.centreDeLaFace		_node	face	
					local largeurFace			= outils.largeurFace	_node	face
					local normalFace 			= ( polyop.getFaceNormal _node face ) 
					local normalFaceRotZ	= normalFace * rotateZMatrix 90 
					local origine					= centreFace + normalFaceRotZ * ( -largeurFace/2 )
					local origineSlice 			= origine - _node.pos						
					local translation			= normalFaceRotZ * ( largeurFace / _ratio )
					
					---- Selection des faces (deja selectionnées dans la version de base)	----
					polyop.setFaceSelection  _node 	#(face)
					
					for i = 1 to ( _ratio - 1) do (
						
							---- Slice debut fenetre ----
							_node.slice 	normalFaceRotZ 	( origineSlice + translation )  	flaggedFacesOnly:true
							
							---- le nom de la selection des "facades"----
							_faceSelectionTmp 	= (  polyop.getFaceSelection  _node  ) as array
							outils.grouperFaces 	_node	_faceSelectionTmp	"const_facades"
							for faceFinale in _faceSelectionTmp do
								appendIfUnique _facesFinales faceFinale
							
							---- Actualiser translation	----
							translation += translation
						
					) -- fin for i
				) -- fin for face
				
				---- Selection des faces 	----
				polyop.setFaceSelection  _node 	_facesFinales
				
			) -- fin redraw off
			redrawViews() 
		)	-- fin undo
	),
	
	--- TOITURES ----		
	fn accrotere	_node	_faces	= (
		debug "accrotere"
-- 		undo "construction : accrotere" on (
-- 			with redraw off (
				local ep_mur 			= 20
				local ht_accrotere 	= 70
				local ht_couvertine 	= 5
		
				local cmdPanelMode_back = getCommandPanelTaskMode ()
				setCommandPanelTaskMode #modify
				---- Selection des faces (deja selectionnées dans la version de base)	----
				modPanel.setCurrentObject _node.baseObject
				subobjectLevel = 4
				polyop.setFaceSelection  _node 	_faces
				
-- 				---- MatID mur	----
-- 				_node.EditablePoly.setMaterialIndex 		matID.mur	 	1
				
				---- Inset de l'épaisseur du mur ----
				_node.insetType = 0
				_node.insetAmount = ep_mur
				_node.EditablePoly.buttonOp 		#Inset
				
				---- Extusion de l'accrotere	----
				outils.etendreSelecFaces 		_node 	( ( polyop.getFaceSelection  _node ) as array )
				_node.extrusionType 				= 0
				_node.faceExtrudeHeight 		= ht_accrotere
				_node.EditablePoly.buttonOp	#Extrude
				
				---- Copie des faces pour creer la base de la couvertine 	----
				_facesCouvertine = _node.EditablePoly.getSelection #Face
				_node.EditablePoly.detachToElement 	#Face 		keepOriginal:on
				
-- 				---- MatID couvertine	----
-- 				_node.EditablePoly.setMaterialIndex 		matID.couvertine	 	1
				
				---- Epaisseur de la couvertine 	----
				_node.faceExtrudeHeight = ht_couvertine
				_node.EditablePoly.buttonOp #Extrude
				
				-- listes des trucs a supprimer	(points et arretes en trop )	----
				listeArretesAVirer 	= polyop.getEdgesUsingFace	_node	( ( polyop.getFaceSelection  _node ) as array )
				listePointsAVirer 	= polyop.getVertsUsingFace  	_node	( ( polyop.getFaceSelection  _node ) as array )
				
				---- Extrusion du débord de la couvertine 	----
				outils.etendreSelecFaces		_node		( ( polyop.getFaceSelection  _node ) as array )
				_node.faceExtrudeHeight = ht_couvertine
				_node.extrusionType = 1
				_node.EditablePoly.buttonOp #Extrude
				
				---- Suppression des trucs (points et arretes en trop )	----
				_node.EditablePoly.SetSelection #Edge 		listeArretesAVirer
				_node.EditablePoly.SetSelection #Vertex 	listePointsAVirer
				subobjectLevel = 2
				_node.EditablePoly.Remove ()
				subobjectLevel = 1
				_node.EditablePoly.Remove ()
				
				---- Deselection des faces ----
				subobjectLevel = 4
				_node.EditablePoly.SetSelection #Face #{}				
				subobjectLevel = 0
				modPanel.setCurrentObject $.modifiers[#Urba___Bâtiment]
				
				setCommandPanelTaskMode cmdPanelMode_back
				
-- 			) -- fin redraw off
-- 			redrawViews()
-- 		)	-- fin undo
	),
	fn pansDeux 		_node	_faces	= (
-- 		undo "construction : 2 pans" on (
-- 			with redraw off (
				
				local cmdPanelMode_back = getCommandPanelTaskMode ()
				setCommandPanelTaskMode #modify
				---- Selection des faces (deja selectionnées dans la version de base)	----
				modPanel.setCurrentObject _node.baseObject
				subobjectLevel = 4
		
		
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
				
				---- declarations ----					
				local 	_listeArretes = polyop.getEdgesUsingFace 	_node	( polyop.getFaceSelection  _node ) 
				
				--- si on a un rectangle ----
				if ( _listeArretes as array ).count == 4 do (
					
					---- 	CREATION DU DEBORD	----
					-- Selection des faces à extruder --
					outils.etendreSelecFaces		_node 	_faces
					_facesDalles 			= ( polyop.getFaceSelection  _node ) as array
					_facesPourDebords 	= outils.facesLesPlusGrandes	_node	_facesDalles
					polyop.setFaceSelection  _node	_facesPourDebords
					
					_faceLaPlusPetite 	=	( outils.facesLesPlusPetites 	_node 	_facesDalles)[1]
					_hauteurFaitage 	= ( outils.largeurFace	_node	_faceLaPlusPetite ) / 2
					
					-- Extrusion du debord --					
					_node.extrusionType 				= 1
					_node.faceExtrudeHeight 		= prefs.lrg_debord
					_node.EditablePoly.buttonOp	#Extrude
					
					
					---- CREATION DU FAITAGE ----
					-- selection des faces pour le toit --
					polyop.setFaceSelection  _node	_faces
					
					-- Selection des arretes pour connection --
					subobjectLevel = 2
					_arretesPourConnect	=	outils.arretesLesPlusPetites		_node   _listeArretes
					polyop.setEdgeSelection  _node 	_arretesPourConnect
					
					-- Connection des arretes pour creation faitage	--
					_node.connectEdgeSegments = 1
					_node.connectEdgePinch = 0
					_node.connectEdgeSlide = 0
					_node.EditablePoly.ConnectEdges ()
					
					--- hauteur du faitage --
					_hauteurToiture =  _hauteurFaitage
					move 	_node.selectedEdges [0,0, _hauteurToiture ]
					
					---- CREATION DU TOIT ----
					-- smothing group des faces du toit ---
					_node.EditablePoly.ConvertSelection #Edge #Face
					subobjectLevel = 4
					_node.EditablePoly.autosmooth ()
					
					-- extrusion de la hauteur du toit --
					_node.extrusionType 				= 1
					_node.faceExtrudeHeight 		= prefs.ht_toiture
					_node.EditablePoly.buttonOp #Extrude
					
					-- Selection epaisseur Du toit --
					outils.etendreSelecFaces		_node 	( polyop.getFaceSelection  _node )
					
					-- extrusion de la epaisseur du toit --
					_node.extrusionType 				= 1
					_node.faceExtrudeHeight 		= prefs.ep_toiture
					_node.EditablePoly.buttonOp #Extrude
					
					
				modPanel.setCurrentObject $.modifiers[#Urba___Bâtiment]
				
				setCommandPanelTaskMode cmdPanelMode_back
				
				) ---- fin de si on a un rectangle
				
				
-- 			) -- fin redraw off
-- 			redrawViews()
-- 		)	-- fin undo
	),
	fn pansTrois 	_node	_faces	= (
		format "pansTrois\n"
		undo "construction : 3 pans" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
									
			) -- fin redraw off
			redrawViews()
		)	-- fin undo
		
	),
	fn pansQuatre 	_node	_faces	= (
		format "pansQuatre\n"
		undo "construction : 4 pans" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
				
			) -- fin redraw off
			redrawViews()
		)	-- fin undo
		
	),
	
	---- OUVERTURES ----
	fn baies 	_node	_faces	= (
		
		undo "construction : bais" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
				
				--- declarations	----
				local _facesBais			= #()
				local _facesSelection 	= _faces
				
				---- MatID mur	----
				_node.EditablePoly.setMaterialIndex 		matID.mur	 	1
				
				---- DECOUPES HORIZONTALES	----
				polyop.setEdgeSelection  _node #()					
				for face in  _facesSelection do (
					
					local hauteurFace 		= outils.hauteurFace 	_node	face
					local largeurFace		= outils.largeurFace	_node	face
					local hauteurFaceMin	= prefs.ht_fenetre
					local largeurFaceMin	= prefs.larg_Fenetre + prefs.ep_mur
					local Zmin 				= outils.ZMinFace 		_node 	#(face)						
					local hauteurLinteau 	= if prefs.ht_fenetre > hauteurFace then hauteurFace else prefs.ht_fenetre
					
					-- Selection de la face a tailler --
					polyop.setFaceSelection  	_node 	#(face)
					
					---- Découpe de l'allège	----
					_node.slice [0,0,1] [0,0,Zmin + prefs.ht_allege ] 	flaggedFacesOnly:true
					
					if hauteurLinteau != hauteurFace then (
						---- Découpe du linteau	----
						_node.slice [0,0,1] [0,0,Zmin + hauteurLinteau ] 	flaggedFacesOnly:true
						
						---- DECOUPES VERTICALES	----
						-- Selection de la face à découper --
						facesTmp 		= 	polyop.getEdgeFaces		_node	( _node.GetNumEdges	() )
						nouvelleFace 	=	outils.faceLaPlusBasse 	_node 	facesTmp							
						polyop.setFaceSelection  _node		#( nouvelleFace  )
					) 
					
					local centreFace 		= 		outils.centreDeLaFace		_node	face							
					local normalFace 		= ( polyop.getFaceNormal _node face ) 
					local normalFaceRotZ= normalFace * rotateZMatrix 90 
					local largeurFace 		= outils.largeurFace 		_node 	face
					local origine				= centreFace + normalFaceRotZ * ( -largeurFace/2 + prefs.ep_mur )
					local origineSlice 		= origine - _node.pos
					local transl_fenetre	= normalFaceRotZ * prefs.larg_Fenetre
					local transl_plein		= normalFaceRotZ * prefs.esp_fenetre
					local translation		= [0,0,0]
					local nbr_fenetre 		= 0
					local nbr_fenetreMax	=	if prefs.nbr_fenetre == 0 then 1 else prefs.nbr_fenetre
					local dimensionMin 	= transl_fenetre  + normalFaceRotZ *	prefs.ep_mur
					
					
					while  length ( translation +  dimensionMin ) < largeurFace and nbr_fenetre < nbr_fenetreMax 	do (
						
						---- Slice debut fenetre ----
						_node.slice 	normalFaceRotZ 	( origineSlice + translation )  	flaggedFacesOnly:true
						
						---- Actualiser translation	----
						translation += transl_fenetre	
						
						---- Slice fin fenetre ----
						polyop.setEdgeSelection  _node		#()
						_node.slice 	normalFaceRotZ 	( origineSlice + translation ) 	flaggedFacesOnly:true
						
						----	Ajout de la face de la fenetre dans la liste pour extrusion epaisseur du mur	----
						derniereArrete 	=	(( polyop.getEdgeSelection  	_node ) as array )[1]
						if derniereArrete != undefined do (
							facesTmp 			= 	polyop.getEdgeFaces			_node		derniereArrete
							faceAAjouter 		= outils.faceLaPlusProche		_node 	facesTmp	origine
							append 	_facesBais		faceAAjouter 
						)
						---- Actualiser nombre de fenetre créées	----
						if prefs.nbr_fenetre != 0 do  nbr_fenetre += 1
						
						---- Actualiser translation	----
						translation += transl_plein
						
					)	-- fin du while --	
					
				)	-- fin du for
				
				---- Extrusion epaisseur du mur ----
				polyop.setFaceSelection  _node		_facesBais
				_node.faceExtrudeHeight 	= -prefs.ep_mur
				_node.extrusionType 			= 1
				_node.EditablePoly.buttonOp #Extrude
				
				---- le nom de la selection des faces ----
				outils.grouperFaces	_node		(( polyop.getFaceSelection  _node ) as array) 		"const_baies" 	
				
				---- retirer de groupe "facades"	----
				outils.degrouperFaces 	_node 	_facesSelection 	"const_facades" 
				
				---- MatID verre	----
				_node.EditablePoly.setMaterialIndex 		matID.verre	 	1
				
			) -- fin redraw off
			
			redrawViews() 
			
		)	-- fin undo
		
	),
	fn ventDeux 	_node	_faces	= (
		
		undo "construction : deux ventaux" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
				
				--- declarations	----
				local _facesSelection 	= ( polyop.getFaceSelection  _node )
				
				
				---- creation des tablettes	----
				_facesTablettes 	= outils.facesDuDessous		_node	_faces
				tablette		_node	_facesTablettes					
				
				---- creation du cadre	---
				cadre 	_node	_faces
				_facesTmp = polyop.getFaceSelection  _node 	
				
				---- Correction de la face du cadre pour la faire sortir de la tablette ----
				_facesDuDessous 	= outils.facesDuDessous		_node	_facesTmp
				polyop.setFaceSelection  _node 	_facesDuDessous
				move _node.selectedFaces [0,0, prefs.ep_tablette ]
				
				
				---- Selection des faces pour ouvrants ----
				polyop.setFaceSelection  _node 	_facesTmp
				
				---- Division de la baie en 2	---
				diviser 2 	_node	_faces
				
				---- creation des fenetre	---
				_facesFenetres =  polyop.getFaceSelection  _node 
				cadre 	_node	_facesFenetres 
				
				
				
			) -- fin redraw off				
			redrawViews() 	 				
		)	-- fin undo
		
	),		
	fn ventDeuxAllege 	_node	_faces	= (
		format "ventDeuxAllege\n"
		undo "construction : 2 ventaux + allège" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
									
			) -- fin redraw off
			redrawViews()
		)	-- fin undo
		
	),
	
	---- BALCONS/LOGGIAS -----
	fn balcon 	_node	_faces	= (
		format "balcon\n"
		undo "construction : Balcon" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
									
			) -- fin redraw off
			redrawViews()
		)	-- fin undo
		
	),
	fn loggia 	_node	_faces	= (
		format "loggia\n"
		undo "construction : Loggia" on (
			with redraw off (
				
				---- Selection des faces (deja selectionnées dans la version de base)	----
				polyop.setFaceSelection  _node 	_faces
				
			) -- fin redraw off
			redrawViews()
		)	-- fin undo
		
	)
	
)











