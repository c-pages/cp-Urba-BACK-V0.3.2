
/*
#######################################################################################################################

	2017 Christophe Pages (http://www.c-pages.fr) 	

##########################################################################################################################
	
	Construction: Outils de modélisation d'éléments architecturaux sur un editable poly 
	
##########################################################################################################################

	todo:	
	
##########################################################################################################################

	changelog:
	*v0.0 - [2016/08] -----------------------------------------------------------------------------
	- Mise en place globale 
	
######################################################################################################################## 
*/




	
------------------------------------------------------------------------------------------------------------------------
---- Rollout	--------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
rollout rollConstruction "Construction" 	width:817 	height:80
(
	
	------------------------------------------------------------
	---- Membres --------------------------------------------
	------------------------------------------------------------
	
	---- Les structures ----
	local const, outils, matID, prefs
	
	---- L'interface ----
	local boutons
	
	---- Ecouteurs ----
	local	ecouteurChangeEtat
	
	------------------------------------------------------------
	---- Structures ------------------------------------------
	------------------------------------------------------------
	---- la structure des Materiaux ID ---------------------------------------------------------------------------------------------
	struct matIDStruct (
		
		mur 				= 1,
		menuiseries 	= 2,
		tablette			= 2,
		couvertine		= 3,
		verre  			= 4
		
	)
	
	---- la structure outils divers	---------------------------------------------------------------------------------------------
	struct outilsStruct (
		
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

	
	---- la structure des preferences	---------------------------------------------------------------------------------------------
	struct prefsStruct (
		
		---- le fichier des preferences	----
		fichier 					= "$userScripts\construction.ini",		
		
		---- les preferences	----
		ep_mur					=	30,	---- Epaisseur du mur.
		
		ht_etage 				= 255, 	---- Hauteur d'un étage.
		ep_dalle				=	25,	---- Epaisseur des dalles.
		
		ht_accrotere 			= 50, 	---- Hauteur de l'accrotere.
		ep_couvertine		=	5,		---- Epaisseur de la couvertine.
		ht_couvertine		=	5,		---- Hauteur de la couvertine.
		
		lrg_debord			=	50,	---- Largeur du débord de toit pour toiture ferme
		ht_toiture				=	30,	---- Hauteur de la toiture ( en debord )
		ep_toiture				=	7,		----  Epaisseur de la toiture
		
		ht_tablette			=	5,		----  Hauteur de la tablette des baies
		ep_tablette			=	5,		----  Epaisseur de la tablette des baies
		
		ht_allege				= 90,	---- Hauteur de l'allège
		
		nbr_fenetre			= 0,		---- Nombre de fenetre à creer ( 0: remplis la face fenetres )
		ht_fenetre				= 210,	---- Hauteur de la fenetre
		larg_fenetre			= 100,	---- Largeur de la fenetre
		esp_fenetre			= 150,	---- Largeur du plein entre 2 fenetres
		align_fenetre			= 1,		---- L'alignement des fenetre dans la face
		decal_fenetre			= 50,	---- Le décalage de la premiere fenetre pa rapport au bord de la face.
		
		ep_cadreFenetre	= 3,		---- L'epaisseur du cadre des menuiseries
		larg_cadreFenetre	= 5,		---- La largeur du cadre des menuiseries
		
		
		--- Fontions ----
		fn sauvegarder 	= (
			
			setINISetting   fichier		"prefs"   "ep_mur"  				( ep_mur as string )
			
			setINISetting   fichier		"prefs"   "ht_etage"  				( ht_etage as string )
			setINISetting   fichier		"prefs"   "ep_dalle"  				( ep_dalle as string )
			
			setINISetting   fichier		"prefs"   "ht_accrotere"  			( ht_accrotere as string )
			setINISetting   fichier		"prefs"   "ep_couvertine"		( ep_couvertine as string )
			setINISetting   fichier		"prefs"   "ht_couvertine"  		( ht_couvertine as string )
			
			setINISetting   fichier		"prefs"   "lrg_debord"  			( lrg_debord as string )
			setINISetting   fichier		"prefs"   "ht_toiture"  			( ht_toiture as string )
			setINISetting   fichier		"prefs"   "ep_toiture"  			( ep_toiture as string )
			
			setINISetting   fichier		"prefs"   "ht_tablette"  			( ht_tablette as string )
			setINISetting   fichier		"prefs"   "ep_tablette"  			( ep_tablette as string )
			
			setINISetting   fichier		"prefs"   "ht_allege"  				( ht_allege as string )
			setINISetting   fichier		"prefs"   "nbr_fenetre"  			( nbr_fenetre as string )
			setINISetting   fichier		"prefs"   "ht_fenetre"  			( ht_fenetre as string )
			setINISetting   fichier		"prefs"   "larg_fenetre"  			( larg_fenetre as string )
			setINISetting   fichier		"prefs"   "esp_fenetre"			( esp_fenetre as string )
			setINISetting   fichier		"prefs"   "align_fenetre"			( align_fenetre as string )
			setINISetting   fichier		"prefs"   "decal_fenetre"			( decal_fenetre as string )
			
			setINISetting   fichier		"prefs"   "ep_cadreFenetre"		( ep_cadreFenetre as string )
			setINISetting   fichier		"prefs"   "larg_cadreFenetre"	( larg_cadreFenetre as string )
			
		),
		
		fn charger 	= (
			
			ep_mur 				= 	( getINISetting   fichier		"prefs"   "ep_mur"  			as float )		
			
			ht_etage				= 	( getINISetting   fichier	"prefs"   "ht_etage"  				as float )
			ep_dalle				= 	( getINISetting   fichier	"prefs"   "ep_dalle"  				as float )
			
			ht_accrotere 			=	( getINISetting   fichier	"prefs"   "ht_accrotere"  			as float )
			ep_couvertine		=	( getINISetting   fichier	"prefs"   "ep_couvertine"		as float )
			ht_couvertine		=	( getINISetting   fichier	"prefs"   "ht_couvertine"  		as float )
			
			lrg_debord			= 	( getINISetting   fichier	"prefs"   "lrg_debord"  			as float )
			ht_toiture				= 	( getINISetting   fichier	"prefs"   "ht_toiture"  			as float )
			ep_toiture				= 	( getINISetting   fichier	"prefs"   "ep_toiture"  			as float )
			
			ht_tablette			= 	( getINISetting   fichier	"prefs"   "ht_tablette"  			as float )
			ep_tablette			= 	( getINISetting   fichier	"prefs"   "ep_tablette"  			as float )
			
			ht_allege				= 	( getINISetting   fichier	"prefs"   "ht_allege"  				as float )
			nbr_fenetre			= 	( getINISetting   fichier	"prefs"   "nbr_fenetre"  			as float )
			ht_fenetre				= 	( getINISetting   fichier	"prefs"   "ht_fenetre"  			as float )
			larg_fenetre			=	( getINISetting   fichier	"prefs"   "larg_fenetre"  			as float )
			esp_fenetre			=	( getINISetting   fichier	"prefs"   "esp_fenetre"			as float )
			align_fenetre			=	( getINISetting   fichier	"prefs"   "align_fenetre"			as integer )
			decal_fenetre			=	( getINISetting   fichier	"prefs"   "decal_fenetre"			as float )
			
			ep_cadreFenetre	=	( getINISetting   fichier	"prefs"   "ep_cadreFenetre"		as float )
			larg_cadreFenetre	=	( getINISetting   fichier	"prefs"   "larg_cadreFenetre"	as float )
			
		),
		
		fn resetFichier = (
			deleteFile  fichier
		),
		
		---- evenements ----
		on create do (
			if not doesFileExist fichier
					then	sauvegarder ()
					else 	charger ()
		)
		
	)	-- fin struct prefs	---
	
	
	
	---- la structure de construction	---------------------------------------------------------------------------------------------
	struct constructionStruct (
		
	---- Les fonctions privées	----
	private
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
		
	---- Les fonctions publics	----
	public
		
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
			undo "construction : accrotere" on (
				with redraw off (
					
					---- Selection des faces (deja selectionnées dans la version de base)	----
					polyop.setFaceSelection  _node 	_faces
					
					---- MatID mur	----
					_node.EditablePoly.setMaterialIndex 		matID.mur	 	1
					
					---- Inset de l'épaisseur du mur ----
					_node.insetType = 0
					_node.insetAmount = prefs.ep_mur
					_node.EditablePoly.buttonOp 		#Inset
					
					---- Extusion de l'accrotere	----
					outils.etendreSelecFaces 		_node 	( ( polyop.getFaceSelection  _node ) as array )
					_node.extrusionType 				= 0
					_node.faceExtrudeHeight 		= prefs.ht_accrotere
					_node.EditablePoly.buttonOp	#Extrude
					
					---- Copie des faces pour creer la base de la couvertine 	----
					_facesCouvertine = _node.EditablePoly.getSelection #Face
					_node.EditablePoly.detachToElement 	#Face 		keepOriginal:on
					
					---- MatID couvertine	----
					_node.EditablePoly.setMaterialIndex 		matID.couvertine	 	1
					
					---- Epaisseur de la couvertine 	----
					_node.faceExtrudeHeight = prefs.ht_couvertine
					_node.EditablePoly.buttonOp #Extrude
					
					-- listes des trucs a supprimer	(points et arretes en trop )	----
					listeArretesAVirer 	= polyop.getEdgesUsingFace	_node	( ( polyop.getFaceSelection  _node ) as array )
					listePointsAVirer 	= polyop.getVertsUsingFace  	_node	( ( polyop.getFaceSelection  _node ) as array )
					
					---- Extrusion du débord de la couvertine 	----
					outils.etendreSelecFaces		_node		( ( polyop.getFaceSelection  _node ) as array )
					_node.faceExtrudeHeight = prefs.ht_couvertine
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
					
					
				) -- fin redraw off
				redrawViews()
			)	-- fin undo
		),
		fn pansDeux 		_node	_faces	= (
			undo "construction : 2 pans" on (
				with redraw off (
					
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
						_facesPourDebords = outils.facesLesPlusGrandes	_node	_facesDalles
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
						
					) ---- fin de si on a un rectangle
					
					
				) -- fin redraw off
				redrawViews()
			)	-- fin undo
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
	
	
	
	------------------------------------------------------------
	---- UI ---------------------------------------------------
	------------------------------------------------------------
	GroupBox 'grp_etage' "Etage" pos:[11,6] width:108 height:67 align:#left
	GroupBox 'grp_toiture' "Toiture" pos:[127,6] width:269 height:67 align:#left
	GroupBox 'grp_baies' "Baies" pos:[404,6] width:213 height:67 align:#left
	GroupBox 'grp_bacons' "Balcons" pos:[628,6] width:146 height:67 align:#left
	
	button 'btn_etage' "Etage" pos:[21,25] width:40 height:40 align:#left
	button 'btn_divParDeux' "Div. /2" pos:[67,25] width:40 height:18 align:#left
	button 'btn_divParTrois' "Div. /3" pos:[67,46] width:40 height:18 align:#left
	button 'btn_accrotere' "Accrotère" pos:[134,26] width:60 height:40 align:#left
	button 'btn_pansDeux' "2 pans" pos:[199,26] width:60 height:40 align:#left
	button 'btn_pansTrois' "3 pans" pos:[264,26] width:60 height:40 align:#left
	button 'btn_pansQuatre' "4 pans" pos:[329,26] width:60 height:40 align:#left
	button 'btn_baies' "Bais" pos:[413,26] width:60 height:40 align:#left
	button 'btn_ventDeux' "2 venteaux" pos:[479,26] width:60 height:40 align:#left
	button 'btn_ventDeuxAllege' "2 vent. + allège" pos:[549,26] width:60 height:40 align:#left
	button 'btn_balcon' "Balcon" pos:[636,26] width:60 height:40 align:#left
	button 'btn_loggia' "Loggia" pos:[706,26] width:60 height:40 align:#left
	
	GroupBox 'grp_params' "Paramêtres " pos:[11,82] width:791 height:283 align:#left
	checkbutton 'btn_details' "+" pos:[780,55] width:17 height:17 align:#left	
	
	subRollout 'sousRoll' "Paramêtres" pos:[24,102] width:760 height:234 align:#left
	button 'btn_defauts' "Défauts" pos:[23,340] width:86 height:18 align:#left

	button 'btn_tests' "tst" pos:[780,35] width:17 height:17 align:#left	
	

	
	
	
	
	------------------------------------------------------------
	---- Rollout secondaires ------------------------------------------
	------------------------------------------------------------
	
	---- Rollout de Etage ---------------------------------------------------------------------------------------------
	rollout rollEtage "Etage" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin rollout etage --
	
	---- Rollout de Accrotère ---------------------------------------------------------------------------------------------
	rollout rollAccrotere "Accrotère" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_ep_mur' 				"Epaisseur mur :" 			pos:[8,9] 			width:100 height:19 align:#left
		spinner 	'spn_ep_mur' 			"" 								pos:[114,9] 		width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_ht_accrotere' 		"Hauteur accrotère :" 	pos:[264,9] 		width:60 	height:19 align:#left
		spinner	'spn_ht_accrotere' 	"" 								pos:[324,9] 		width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		label 		'lbl_ep_couvertine' 	"Epaisseur couvertine :"	pos:[8,29] 		width:100 height:19 align:#left
		spinner 	'spn_ep_couvertine' 	"" 								pos:[114,29] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_ht_couvertine' 	"Hauteur couvertine :" 	pos:[264,29] 	width:60 	height:19 align:#left
		spinner	'spn_ht_couvertine' 	"" 								pos:[324,29] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		
		---- fonctions ----
		fn actualiser = (
			spn_ep_mur.value 			= prefs.ep_mur
			spn_ht_accrotere.value 		= prefs.ht_accrotere		
			spn_ep_couvertine.value 	= prefs.ep_couvertine
			spn_ht_couvertine.value 	= prefs.ht_couvertine		
		)
		
		---- evenements ----
		on rollAccrotere open do actualiser ()
		
		on  spn_ep_mur			changed	val 	do (	
			prefs.ep_mur	=	val
			prefs.sauvegarder()		
		)
		on  spn_ht_accrotere			changed	val 	do (	
			prefs.ht_accrotere	=	val
			prefs.sauvegarder()		
		)
		on  spn_ep_couvertine			changed	val 	do (	
			prefs.ep_couvertine	=	val
			prefs.sauvegarder()		
		)
		on  spn_ht_couvertine			changed	val 	do (	
			prefs.ht_couvertine	=	val
			prefs.sauvegarder()		
		)
		
	)	-- fin rollout Accrotère --
	
	---- Rollout deux pans  ---------------------------------------------------------------------------------------------
	rollout rollDeuxPans "2 pans" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin Rollout deux pans   --
	
	---- Rollout trois pans  ---------------------------------------------------------------------------------------------
	rollout rollTroisPans "3 pans" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin Rollout trois pans   --
	
	---- Rollout 4 pans  ---------------------------------------------------------------------------------------------
	rollout rollQuatrePans "4 pans" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin Rollout 4 pans   --
		
	---- Rollout de Baies ---------------------------------------------------------------------------------------------
	rollout rollBaies "Baies" width:743 height:99 	(
-- 		button 'btn_appliquer' "Appliquer" pos:[624,9] width:108 height:82 align:#left
		
		label 				'lbl_allege' 				"Allège :" 		pos:[8,7] 			width:100 height:19 align:#left
		spinner 			'spn_ht_allege' 			"" 				pos:[114,9] 		width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		
		label 				'lbl_larg_fenetre' 		"Largeur :" 	pos:[264,29] 	width:60 height:19 align:#left
		spinner 			'spn_larg_fenetre' 		"" 				pos:[324,31] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		label				'lbl_ht_fenetre' 			"Hauteur :" 	pos:[449,29] 	width:60 height:19 align:#left
		spinner			'spn_ht_fenetre' 		"" 				pos:[509,31] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		label 				'lbl_nbr_fenetre' 		"Fenetres :" 	pos:[9,29] 		width:100 height:19 align:#left
		spinner 			'spn_nbr_fenetre' 		"" 				pos:[114,30] 	width:100 height:16 range:[0,10000,0] type:#integer scale:1 align:#left
		radiobuttons 	'rdo_align_fenetre'		"Alignement" pos:[9,56] 		width:235 height:30 labels:#("Gauche", "Centre", "Droite") default:1 columns:3 align:#left
		label 				'lbl_esp_fenetre' 		"Espacmt. :" 	pos:[449,70] 	width:60 height:19 align:#left
		spinner 			'spn_esp_fenetre'		"" 				pos:[509,71] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		label 				'lbl_decal_fenetre' 		"Décalage :" 	pos:[264,70] 	width:60 height:19 align:#left
		spinner 			'spn_decal_fenetre' 	"" 				pos:[324,71] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
	
		
		---- fonctions ----
		fn actualiser = (
			spn_ht_allege.value 				= prefs.ht_allege
			spn_larg_fenetre.value 			= prefs.larg_fenetre
			spn_ht_fenetre.value 			= prefs.ht_fenetre
			spn_nbr_fenetre.value 			= prefs.nbr_fenetre
			rdo_align_fenetre.state 			= prefs.align_fenetre
			spn_esp_fenetre.value 			= prefs.esp_fenetre
			spn_decal_fenetre.value 		= prefs.decal_fenetre
			
			---- on gere les activité des boutons	----
			lbl_decal_fenetre.enabled 		= ( rdo_align_fenetre.state != 2 )
			spn_decal_fenetre.enabled 	= ( rdo_align_fenetre.state != 2 )
			
		)
		
		
		---- evenements ----
		on rollBaies open do actualiser ()
		
		on  spn_ht_allege			changed	val 	do (	
			prefs.ht_allege	=	val
			prefs.sauvegarder()		
		)
		on  spn_larg_fenetre			changed	val 	do (	
			prefs.larg_fenetre	=	val
			prefs.sauvegarder()		
		)
		on  spn_ht_fenetre			changed	val 	do (	
			prefs.ht_fenetre	=	val
			prefs.sauvegarder()		
		)
		on  spn_nbr_fenetre			changed	val 	do (	
			prefs.nbr_fenetre	=	val
			prefs.sauvegarder()		
		)
		on  rdo_align_fenetre			changed		arg 	do (	
			
			--- on gere les preferences -----
			prefs.align_fenetre	=	arg
			prefs.sauvegarder()
			actualiser ()
			
		)
		on  spn_esp_fenetre			changed	val 	do (	
			prefs.esp_fenetre	=	val
			prefs.sauvegarder()		
		)
		on  spn_decal_fenetre			changed	val 	do (	
			prefs.decal_fenetre	=	val
			prefs.sauvegarder()		
		)
		
		
		
	)	-- fin rollout Baies --

	---- Rollout 2 ventaux  ---------------------------------------------------------------------------------------------
	rollout rollDeuxVentaux "2 ventaux" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin Rollout 2 ventaux   --
	
	---- Rollout 2 ventaux allege ---------------------------------------------------------------------------------------------
	rollout rollDeuxVentauxAllege "2 ventaux avec allège" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin  rollDeuxVentauxAllege   --
	
	---- Rollout Balcon ---------------------------------------------------------------------------------------------
	rollout rollBalcons "Balcons" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin  Balcon   --
	
	---- Rollout loggia ---------------------------------------------------------------------------------------------
	rollout rollLoggias "loggias" width:743 height:99 	(
		
		---- UI ----
		label 		'lbl_htSsPlaf' 	"Hauteur sous plaf. :" 	pos:[8,9] 		width:100 height:19 align:#left
		spinner 	'spn_htSsPlaf' 	"" 								pos:[114,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left		
		label 		'lbl_epDalle' 		"Ep. dalle :" 					pos:[264,9] 	width:60 	height:19 align:#left
		spinner	'spn_epDalle' 	"" 								pos:[324,9] 	width:100 height:16 range:[0,10000,0] type:#worldunits align:#left
		
		---- fonctions ----
		fn actualiser = (
			spn_htSsPlaf.value 	= prefs.ht_etage
			spn_epDalle.value 		= prefs.ep_dalle			
		)
		
		---- evenements ----
		on rollEtage open do actualiser ()
		on spn_htSsPlaf changed val do (
			prefs.ht_etage	=	val
			prefs.sauvegarder()
		)
		on spn_epDalle changed val do (
			prefs.ep_dalle	=	val
			prefs.sauvegarder()
		)
		
	)	-- fin  loggia   --
	
	------------------------------------------------------------
	---- Fonctions	----------------------------------------
	------------------------------------------------------------
		
	
	---- Pour fonctionnement du rollout	----
	fn actualiserUI = (
		
		---- mise à jour des boutons ----
		b_actif = outils.estValide ()
		for bouton in boutons do 
			bouton.enabled = b_actif
		
	)
	fn actualiserSousRollout = (
		rollEtage.actualiser ()
		rollAccrotere.actualiser ()
		rollDeuxPans.actualiser ()
		rollTroisPans.actualiser ()
		rollQuatrePans.actualiser ()
		rollBaies.actualiser ()
		rollDeuxVentaux.actualiser ()
		rollDeuxVentauxAllege.actualiser ()
		rollBalcons.actualiser ()
		rollLoggias.actualiser ()
	)
	fn fermerSsRollouts = (
		rollEtage.open						=false
		rollAccrotere.open					=false
		rollDeuxPans.open					=false
		rollTroisPans.open					=false
		rollQuatrePans.open				=false
		rollBaies.open						=false
		rollDeuxVentaux.open			=false
		rollDeuxVentauxAllege.open	=false
		rollBalcons.open						=false
		rollLoggias.open						=false
	)
	fn initialiser = (
		
		---- creation des structures ----
		const 	= constructionStruct ()
		outils 	= outilsStruct ()
		matID 	= matIDStruct ()
		prefs		= prefsStruct ()
		
		---- le tableau des boutons de l'interface ----
		boutons = #( btn_etage, btn_accrotere, btn_pansDeux, btn_pansTrois, btn_pansQuatre, btn_baies, btn_ventDeux, btn_ventDeuxAllege, btn_balcon, btn_loggia )
		
		---- actualiser l'interface ----
		actualiserUI ()
		
		---- les ecouteurs ----
		fn ecouterChangeEtat		ev nd = 	actualiserUI ()		
		ecouteurChangeEtat = NodeEventCallback 	mouseUp:true 	delay:1000	selectionChanged:ecouterChangeEtat 		subobjectSelectionChanged:ecouterChangeEtat
		callbacks.addScript #sceneRedo "rollConstruction.actualiserUI()" id:#Perso_construction
		callbacks.addScript #sceneUndo "rollConstruction.actualiserUI()" id:#Perso_construction
		
		---- les rollout dans le sousRoll -----
		AddSubRollout sousRoll	 rollEtage 
		AddSubRollout sousRoll	 rollAccrotere 
		AddSubRollout sousRoll	 rollDeuxPans 
		AddSubRollout sousRoll	 rollTroisPans 
		AddSubRollout sousRoll	 rollQuatrePans 
		AddSubRollout sousRoll	 rollBaies 
		AddSubRollout sousRoll	 rollDeuxVentaux 
		AddSubRollout sousRoll	 rollDeuxVentauxAllege 
		AddSubRollout sousRoll	 rollBalcons 
		AddSubRollout sousRoll	 rollLoggias 
		
		fermerSsRollouts ()
		
	)
	fn fermer = (
		
		--- vider ecouteur	 ---
		ecouteurChangeEtat = undefined
		callbacks.removeScripts #sceneRedo id:#Perso_construction
		callbacks.removeScripts #sceneUndo id:#Perso_construction
		gc light:true
		
		---- update le bouton macro	----
		estOuvert = false
		updateToolbarButtons()
		
	)
	fn togglerDetails _state = (
		case _state of (
			true:		(
				btn_details.text = "-"
				rollConstruction.height = 375
			)
			false:	(
				btn_details.text = "+"
				rollConstruction.height = 78
			)
		)
	)
	
	------------------------------------------------------------
	---- Evenements -----------------------------------------
	------------------------------------------------------------
	---- rollout	----
	on rollConstruction open  			do 	initialiser ()
	on rollConstruction close  			do	fermer ()
	
	
	---- cliques gauche	----
	on btn_etage 				pressed	do 	const.etage 				$	( polyop.getFaceSelection $ ) 
	on btn_divParDeux		pressed	do 	const.diviser 		2		$	( polyop.getFaceSelection $ ) 
	on btn_divParTrois			pressed	do 	const.diviser 		3		$	( polyop.getFaceSelection $ ) 
	
	on btn_accrotere 			pressed	do 	const.accrotere 			$	( polyop.getFaceSelection $ ) 
	on btn_pansDeux 			pressed do 	const.pansDeux 		$	( polyop.getFaceSelection $ ) 
	on btn_pansTrois 			pressed do 	const.pansTrois  		$	( polyop.getFaceSelection $ ) 
	on btn_pansQuatre 		pressed do 	const.pansQuatre 		$	( polyop.getFaceSelection $ ) 
	on btn_baies			 		pressed do 	const.baies 			 	$	( polyop.getFaceSelection $ ) 
	on btn_ventDeux 			pressed do 	const.ventDeux 			$	( polyop.getFaceSelection $ ) 
	on btn_ventDeuxAllege 	pressed do 	const.ventDeuxAllege	$	( polyop.getFaceSelection $ ) 
	on btn_balcon 				pressed do 	const.balcon 				$	( polyop.getFaceSelection $ ) 
	on btn_loggia 				pressed do 	const.loggia 				$	( polyop.getFaceSelection $ ) 
	
	on btn_tests 				pressed do 	(
		
	)
	
	---- cliques droit	----
	on btn_etage 				rightclick 	do 	(
		fermerSsRollouts ()
		rollEtage.open		=	true		
	)
	on btn_accrotere 				rightclick 	do 	(
		fermerSsRollouts ()
		rollAccrotere.open		=	true		
	)
	on btn_pansDeux 				rightclick 	do 	(
		fermerSsRollouts ()
		rollDeuxPans.open		=	true		
	)
	on btn_pansTrois 				rightclick 	do 	(
		fermerSsRollouts ()
		rollTroisPans.open		=	true		
	)
	on btn_pansQuatre 			rightclick 	do 	(
		fermerSsRollouts ()
		rollQuatrePans.open		=	true		
	)
	on btn_baies 				rightclick 	do 	(
		fermerSsRollouts ()
		rollBaies.open		=	true		
	)
	on btn_ventDeux 				rightclick 	do 	(
		fermerSsRollouts ()
		rollDeuxVentaux.open		=	true		
	)
	on btn_ventDeuxAllege 				rightclick 	do 	(
		fermerSsRollouts ()
		rollDeuxVentauxAllege.open		=	true		
	)
	on btn_balcon 				rightclick 	do 	(
		fermerSsRollouts ()
		rollBalcons.open		=	true		
	)
	on btn_loggia 				rightclick 	do 	(
		fermerSsRollouts ()
		rollLoggias.open		=	true		
	)
	
	
	
	---- UI ----
	on btn_details 				changed _state 	do togglerDetails _state	
	on btn_defauts 				pressed 			do ( 
		prefs.resetFichier ()
		prefs = prefsStruct ()
		actualiserSousRollout  ()
	)
	
)	-- fin rollout

rollConstruction






