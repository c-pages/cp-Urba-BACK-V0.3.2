

(
	include "$userScripts\cp-Urba\Urba - OSM Importer - rollout.ms"
 
struct str_posGPS (
	x 	= 0 as double,
	y	= 0 as double
)	------- FIN str_posGPS	-------------

struct	str_OSM_batiment (	
	nom="Bat",
	points = #()	
)	------- FIN OSM Batiment	-------------

struct	str_OSM_point	(
	ref,
	pos =[0,0,0]
)	------- FIN OSM Point	-------------








 struct str_conv_GPStoMeter_mercator (
	private
		rayonMax = 6378137.0	as double,
		rayonMin = 6356752.3142	as double,
	
	
	private
		fn mercX	_longitude =(
			( degToRad  _longitude ) * rayonMax
		),
		fn mercY	_latitude	=(
			if _latitude > 89.5 		do	_latitude = 89.5
			if _latitude < -89.5		do	_latitude = -89.5
			
			local 	temp 	= rayonMin / rayonMax
			local 	es 		= 1.0 - (temp * temp)
			local 	eccent 	= sqrt es
			
			local 	phi 		= ( degToRad		_latitude  ) as double
			local 	sinphi 	= sin	phi
			
			local 	con 		= eccent * sinphi
			local 	com 		= .5 * eccent			
			con 		= ( (1.0-con)/(1.0+con) )	^ com
			
			local 	ts = tan (.5 * ( PI * 0.5 - phi))/con
			local 	result = 0 - rayonMax * log ts
			
			result
			
		),
		
		
	public
		fn gpsToMeters		_long	_lat	=			
			str_posGPS 	x:(mercX _long)	y:(mercY	_lat)
		
)

 
 
struct		str_xmlParser (
	
	----	Membres	-------------------------------------------------
	private
		m_xmlDoc	,
		
	
	----	Fonctions	----------------------------------------
	private	
		fn		get_elements_par_nom		_nomElement	_element 	recurcif:false	=(
			local result =#()
			for i = 0 to _element.childNodes.count-1 do	(
				if  _element.ChildNodes.itemOf[i].name == _nomElement do
					append	result	_element.ChildNodes.itemOf[i]
				if recurcif	do
					result +=	get_elements_par_nom		_nomElement		 _element.ChildNodes.itemOf[i]
			)
			result
		),
	
	
	
	public	
	-- Accessions	---------
		fn get_root =m_xmlDoc.documentElement,
		fn get_elements	_nomElement 	element:	=(
			
			-- si l'element de depart n'est pas assigné, on part de la base du XML----
			if element ==	unsupplied	do
				element	=	m_xmlDoc.documentElement
			
			-- on lanse la fct recursive--------
			local result 	= get_elements_par_nom	_nomElement	element
			
			result
		),
	
	
	
		fn initialiser =(
			--- on charge le module XML du DotNet --------
			dotNet.loadAssembly "system.xml"
			
			m_xmlDoc =dotNetObject "system.xml.xmlDocument"
			
		),
		fn charger  _fichier =(
			
			if doesFileExist _fichier then	(
				initialiser ()
				m_xmlDoc.RemoveAll()
				m_xmlDoc.load 	_fichier
			)
-- 			showmethods m_xmlDoc
			
			OK
		),
		
		
	----	Evenements	-------------------------------------------------
		on create do initialiser ()
		
)	----- FIN 	str_xmlParser	-----------







struct str_OSM_importer	(
	
	----	Membres	-------------------------------------------------
	private

		m_boundsMin	=	str_posGPS (),		
	
	--- les elements XML	----
		m_xmlParser = str_xmlParser (),
		m_elems_Nodes = #(),
		m_elems_Way= #(),
		m_elems_batiment= #(),
		
	--- les objets divers 		-----	
		m_points 			=#(),
		m_batiments 	= #(),
		
	private
		converterGPS = str_conv_GPStoMeter_mercator (),
	
		------------  Rollout ---------------
	public
		---- pointeurs ----
		m_dialog				= roll_OSM_importer ,		---- le rollout ----
		m_dialogPos 		= [100,100],
		
		col_fenetreFond	= color 68  68 68, 	----  ----
		col_fenetreTxt		= color 230  230 230, 	----  ----
	
		--- images bouton fermer ---
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer 	= #(	openBitMap ico_btnFermer_R ,		-- Repos ----
										openBitMap ico_btnFermer_S ,		-- Survol ----
										openBitMap ico_btnFermer_P 			-- Pressé ----
										),
				
		------------  Fonctions	----------------------------------------------------------------------------------
	public
		
		---- fenetre -----
		fn ouvrir =(			
			---- creation de la fenetre ----
			createDialog m_dialog 	bgcolor:				col_fenetreFond 	 \
											fgcolor:				col_fenetreTxt 	\
											style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true		\
											pos:					m_dialogPos
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
						
		),
		
		fn fermer  =(	
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		),
		
	----	Fonctions	----------------------------------------
	public
	
	-- Accession	---------		
		fn get_point		_id =(
			
			local result 
			
			--- on collecte les IDs des nodes composant le batiment	------
			local i = 0
			local trouve = false
			
			while i < m_points.count and not trouve do (
				
				i +=1
				local pt = m_points[i]
				if pt.ref	 == _id do (
					result	=	pt.pos
					
					trouve = true
				)
			)
			result
		),
		
		fn get_batiment_points		_elemBat		=(
			
			local result =#()
			
			--- on cherche tout les noeuds "nd" du batiment	----
			local	elementsNodes_DuBat 	= m_xmlParser.get_elements	"nd"	element:_elemBat
			
			--- on collecte les IDs des nodes composant le batiment	------
			for elementNode in elementsNodes_DuBat do (
				local attribID =	elementNode.attributes.getNamedItem "ref"
				append result	( get_point	attribID.value )
				
			)
			
			
			result
		),
		
		
		fn creer_batiments	=(
			
			format "Analyse des batiments ... "
			local m_batiments	=#()
			
			
			--- on cherche dans chaque noeud "way" les noeuds "tag" avec l'attribut "k" contenant "building"	---
			for elemBat in m_elems_batiment do (
				
				local nvBat 			= str_OSM_batiment ()
				
				--- et on collecte les points du batiment	----------
				nvBat.points 			= get_batiment_points	elemBat	
				append	m_batiments	nvBat
				
			)
			format "... analyse des batiments  reussi. \n"
			
			
			--- les min et max pour placer dummy	-------
			local dum = dummy name:(uniqueName "OSM - Batiments " )
			local maxi 	= 100000000000			
			local minX 	=	maxi
			local minY 	=	maxi
			local maxX 	=	-maxi
			local maxY 	=	-maxi
			
			local shps_batiments =#()
			format "Creation des geometries ... "
			
			for bat in m_batiments	do	(
				
				local shapeBat = line pos:bat.points[1] name:(uniqueName "OSM - Batiment ")	wirecolor:[230, 230, 150 ]
				append shps_batiments	shapeBat
			
				addNewSpline shapeBat
				for pt in bat.points do (
					addKnot shapeBat 1 #corner #line  	pt
					if minX > pt.x 	do 	minX 	= pt.x 
					if minY > pt.y 	do 	minY 	= pt.y 
					if maxX < pt.x 	do 	maxX 	= pt.x 
					if maxY < pt.y 	do 	maxY 	= pt.y 
				)
				close shapeBat 1
				updateshape shapeBat
			)
			
			local dum_echelle 	= [maxX - minX, maxY - minY, 10 ]
			local dum_pos 		= [minX + dum_echelle.x / 2 , minY + dum_echelle.y / 2, 0 ]
			dum.pos 	= dum_pos
			dum.scale	=	dum_echelle / 10
			
			for shapeBat in shps_batiments do
				shapeBat.parent = dum
			
			dum.pos = [0,0,0]
			
			select dum
			format "... Creation des geometries   reussi. \n"
			format "	% batiments créés. \n"	shps_batiments.count
		),
	
		---- Import	------------------------------------------------
		fn parser =(
			
			format "Parsing: ... "
			
			
			
			--- on vide tout -----			
			m_elems_Nodes 		= 	#()
			m_elems_Way			= 	#()
			m_elems_batiment	= 	#()
			
			m_points 					=	#()
			m_batiments 			= 	#()
			
			
			---- la limite min du doc OSM --------------
			m_boundsMin			= [0,0]
			
			
			
			---	on remlpis nos elements	-------------
			local result 	=#()
			local root 		= m_xmlParser.get_root ()
			for i = 0 to root.childNodes.count-1 do	(
				
				---- On collecte les nodes	----
				
				if  root.ChildNodes.itemOf[i].name == "bounds" then (
					
					local	elem_bounds = root.ChildNodes.itemOf[i]
					---- la limite min du doc OSM --------------
					local longitudeMin 	= elem_bounds.attributes.getNamedItem "minlon"
					local latitudeMin 		= elem_bounds.attributes.getNamedItem "minlat"
					m_boundsMin	 		= converterGPS.gpsToMeters   ( longitudeMin.value as double )  ( latitudeMin.value as double )
					

					
				) else if  root.ChildNodes.itemOf[i].name == "node" then (
					local	elem_node = root.ChildNodes.itemOf[i]
					appendIfUnique	m_elems_Nodes	elem_node
					local nvPoint = str_OSM_point ()
					
					local id 				=	elem_node.attributes.getNamedItem "id"
					local longitude 		= elem_node.attributes.getNamedItem "lon"
					local latitude 		= elem_node.attributes.getNamedItem "lat"
					local pos_enMetre	=	converterGPS.gpsToMeters   ( longitude.value as double )  ( latitude.value as double )
					
					nvPoint.ref			=	id.value
					nvPoint.pos.x		=	pos_enMetre.x	- m_boundsMin.x
					nvPoint.pos.y		=	pos_enMetre.y	- m_boundsMin.y
					
					append m_points	nvPoint
				)
				---- On collecte les autres	----
				else if  root.ChildNodes.itemOf[i].name == "way" do (
					
					appendIfUnique	m_elems_Way	root.ChildNodes.itemOf[i]
					
					local elem_way = root.ChildNodes.itemOf[i]
					
					-- on cycle dans les attributs ---------------
					for j = 0 to elem_way.childNodes.count-1 do	(
						
						
						if  elem_way.ChildNodes.itemOf[j].name == "tag" do (
							local	valeur_de_K =	elem_way.ChildNodes.itemOf[j].attributes.itemOf[0].value
							
							-- on cherche "building	------
							if valeur_de_K == "building" do (
								appendIfUnique m_elems_batiment	elem_way
							)
						)
					)
					
					
					append	m_elems_Nodes	root.ChildNodes.itemOf[i]
					
				)
			)
			
			format "...	parsing reussi.\n"
		),
		
	-- Importation	---------
		fn importer  _fichier =(
			
			if doesFileExist _fichier then	(
				
				local nomFichier 		= getFilenameFile		_fichier
				local fichier_temp 	= ("$userScripts\cp-Urba\\" + nomFichier + ".osm")
				copyFile 	_fichier		fichier_temp
				
				--- le fichier xml temporaire -----
				local fichierXmlTemp = getdir #userScripts + "\cp-Urba\\temp.xml"
				renameFile 	fichier_temp		fichierXmlTemp
				
				--- on charge le XML ------
				m_xmlParser.charger		fichierXmlTemp
				
				format "--	OsM Importer --	 Importation de \"%\" reussi.\n"	_fichier
				
				parser ()
				
				creer_batiments ()
				
				--- on supprime le fichier xml temporaire -----
				deleteFile fichierXmlTemp
				
				
			) else format "--	OsM Importer --	 ERREUR : \"%\" n'existe pas !!\n"	_fichier
		)
		
		
)	------- FIN OSM Importer	-------------


-- delete objects

OSMImport = str_OSM_importer ()

-- clearListener ()
OSMImport.ouvrir ()
-- importer "C:\\Users\\kris\\Downloads\\map (4).osm"

-- OSMImport.creer_batiments ()

)
	