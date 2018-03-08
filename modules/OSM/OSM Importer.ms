

-- (

------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
-- include "$userScripts\cp - GLOBAL\UI.ms"
-- include "$userScripts\cp - GLOBAL\DragDialog.ms"



------------------------------------------------------------------------------
----------	Fenetre	OSM Web				 -------------------------
------------------------------------------------------------------------------
rollout roll_OSMWeb "Urba | OSM Importer | Open Street Map" width:800 height:600	(
	
	local		m_prt	
	
	local 	tooltip_osm = "1. Entrer un lieu à rechercher ou déplacer la carte.\n2. Cadrer la zone désirée.\n3. Exporter le fichier *.osm (bouton 'exporter' de la page internet).\n4. Enregistrer le fichier sur DD (de manière à pouvoir le charger depuis l'Importer OSM.)"
		
		edittext edt_Lieu "Lieu:" 	text:"Rouen"	tooltip:tooltip_osm		pos:[8,5] 
		dotNetControl wb "System.Windows.forms.WebBrowser" pos:[10,22] width:780 height:570		tooltip:tooltip_osm
		
		fn formaterTexte 	_texte =(
			substituteString 	_texte " " "%20"
		)
			
		fn openOSM_lieu	 _lieu	 = (
			
			local urlString		=	"https://www.openstreetmap.org/search?query="	
			local urlRecherche 	= urlString + formaterTexte  	_lieu	
			wb.url 		= dotNetObject "System.Uri" urlRecherche 
		
		)
		fn recadrer =(
			taille = GetDialogSize 	roll_OSMWeb
-- 			format "recadrer :%\n" taille
			
			--- taille minimum pour afficher l'interface de la page web comme il faut -----------
			local min_larg = 645
			local min_hauteur = 380
			if taille.x <  min_larg do (
				taille.x = min_larg
				roll_OSMWeb.width = taille.x
			)
			if taille.y < min_hauteur do (
				taille.y = min_hauteur
				roll_OSMWeb.height = taille.y
			)
				
			edt_Lieu.width 	= taille.x - 45
			wb.width 			= taille.x - 20
			wb.height 			= taille.y - 30
		)
		
		on edt_Lieu	entered txt 	do openOSM_lieu txt
		on roll_OSMWeb close 	do m_prt.fermer_OSMWeb ()
		
		on roll_OSMWeb open 	do (
			recadrer ()
			openOSM_lieu edt_Lieu.text
		)
		
		on roll_OSMWeb resized taille do 
			recadrer	()
		
	)

------------------------------------------------------------------------------
----------	Fenetre	Importer				 -------------------------
------------------------------------------------------------------------------
rollout roll_OSM_importer "Urba | OSM Importer" width:200 height:117
(
	
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	

	------------  UI	----------------------------------------------------------------------------------
	checkButton 'chkBtn_webOSM' "OSM.org" pos:[8,6] width:64 height:18 toolTip:"Ouvre un navigateur web sur le site Open Street Map pour y télécharger un fichier OSM (*.osm)." align:#left
	
	checkbox 'chk_batiments' "Batiments" pos:[20,40] width:84 height:18 checked:true align:#left
	checkbox 'chk_voiries' "Voiries" pos:[20,59] width:61 height:18 checked:true align:#left
	checkbox 'chk_divers' "Divers" pos:[105,41] width:61 height:18 checked:true align:#left
	label 'lbl_echelle' "Echelle :" pos:[20,81] width:49 height:13 align:#left
	spinner 'spn_echelle' "" pos:[74,82] width:107 height:16 range:[0,1e+06,1] align:#left
	GroupBox 'grp_options' "Options" pos:[8,25] width:185 height:80 align:#left
	button 'btn_importer' "Importer" pos:[73,6] width:119 height:18 toolTip:"Charger un fichier OSM (*.osm)." align:#left
	
	
	------------  Fonctions	----------------------------------------------------------------------------------
	fn actualiser = (
		chkBtn_webOSM.checked =  m_prt.m_dialog_OSMWeb_estOuvert 
		/* 
		local parsingOK = m_prt.get_parsingOK ()
		
		btn_importer.enabled 	= parsingOK
-- 		grp_infos.enabled 			= parsingOK 
-- 		lbl_infos.enabled 			= parsingOK 
		
		grp_options.enabled 		= parsingOK 
		
		chk_batiments.enabled 	= parsingOK 
		chk_voiries.enabled = parsingOK 
-- 		chk_divers.enabled = parsingOK 
		
		lbl_echelle.enabled 		= parsingOK 
		spn_echelle.enabled 		= parsingOK 		
		
		if parsingOK then (
			local info_txt = ""
			info_txt		+=  m_prt.get_nomDuFichier () + "\n"
			info_txt		+= "\n"
			info_txt		+= "Points : " + m_prt.get_nbr_points () as string + "\n"
			info_txt		+= "Batiments : " + m_prt.get_nbr_batiments () as string + "\n"
			info_txt		+= "Voiries : " + m_prt.get_nbr_voiries () as string + "\n"
			lbl_infos.text = info_txt
		) else lbl_infos.text = "Aucun fichier chargé."
		 */
	)
	
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------

	--- interface	---------
	on chkBtn_webOSM changed state	  do	(
		case state of (
			true:		m_prt.ouvrir_OSMWeb ()
			false:	m_prt.fermer_OSMWeb ()
		)
	)
	
	on btn_importer pressed  do	(
		
		local fichier = getOpenFileName 	caption:"Fichier OSM à importer"\
															types:"OSM(*.osm)|*.osm|All|*.*|" \
															historyCategory:"OSM_fichiers"
		if fichier != undefined do	(
			m_prt.importer	fichier	batiments:chk_batiments.checked 		voiries:chk_voiries.checked 	divers:chk_divers.checked 	  echelle:spn_echelle.value
			
			actualiser ()
		)
	)

	
		
		
)


------------------------------------------------------------------------------
----------	Structures secondaires				 -------------------------
------------------------------------------------------------------------------ 
struct str_posGPS (
	x 	= 0 as double,
	y	= 0 as double
)	------- FIN str_posGPS	-------------

struct	str_OSM_object (	
	nom="",
	points = #()	
)	------- FIN OSM Batiment	-------------

struct	str_OSM_point	(
	ref,
	pos =[0,0,0]
)	------- FIN OSM Point	-------------








------------------------------------------------------------------------------
----------	convertisseur donnés GPS en metres	 -------------------------
------------------------------------------------------------------------------
 struct str_conv_GPStoMeter_mercator (
	private
		rayonMax = 6378137.0	as double,
		rayonMin = 6356752.3142	as double,
		
		coef_correction_echelle = 1.271505947323704,
	
	private
		fn mercX	_longitude =(
			( degToRad  _longitude ) * rayonMax	*coef_correction_echelle
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
			result *= 	coef_correction_echelle
			result
			
		),
		
		
	public
		fn gpsToMeters		_long	_lat	=			
			str_posGPS 	x:(mercX _long)	y:(mercY	_lat)
		
)

 
 
------------------------------------------------------------------------------
----------	le parser de XML					 -------------------------
------------------------------------------------------------------------------
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
		),
		
		
	----	Evenements	-------------------------------------------------
		on create do initialiser ()
		
)	----- FIN 	str_xmlParser	-----------







------------------------------------------------------------------------------
----------	Structure PRINCIPALE				 -------------------------
------------------------------------------------------------------------------
struct str_OSM_importer	(
	
	----	Membres	-------------------------------------------------
	private
		m_boundsMin	=	str_posGPS (),		
	
	--- les elements XML	----
		m_elems_Nodes 		= #(),
		m_elems_voiries		= #(),
		m_elems_batiment	= #(),
		m_elems_divers			=#(),
		
	--- les objets divers 		-----	
		m_points	=#(),
	
	--- les shapes ---------
		m_shps_batiments 	=#(),
		m_shps_voiries 			=#(),
		m_shps_reste			=#(),
		m_shps_divers			=#(),
	
	--- helper d'importation	---
		m_helper,	
		m_helper_batiments,	
		m_helper_voiries,		
		m_helper_divers,		
		
		m_helper_minX,
		m_helper_minY ,
		m_helper_maxX ,
		m_helper_maxY,
	
		---- constante------
		m_const_coefEchelle_metre = 55.51729,
		
	private
		m_xmlParser 		= str_xmlParser (),
		converterGPS = str_conv_GPStoMeter_mercator (),
		
	--- pour l'annulation ----
		m_annuleOp = false,
		
		------------  Rollout ---------------
	public
		---- pointeurs ----
		m_dialog					= roll_OSM_importer ,		---- le rollout ----
		m_dialogPos 				= [100,100],
		m_ouvert					=	false,
		
		m_dialog_OSMWeb	= roll_OSMWeb ,				---- le rollout OSM web ----
		m_dialog_OSMWeb_estOuvert = false,
		
		------------  Fonctions	----------------------------------------------------------------------------------
	public
		
		---- fenetre -----
		fn ouvrir =(			
			---- creation de la fenetre ----
			createDialog m_dialog 	pos:					m_dialogPos	
			
			m_ouvert = true
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
			
		),
		fn fermer  =(	
			m_ouvert = false
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		),
		fn toggle_ouverture	=(
			if m_ouvert 	then fermer ()
								else ouvrir ()
		),
		fn estOuvert	=m_ouvert,
	
		fn fermer_OSMWeb =(
			try	destroyDialog	m_dialog_OSMWeb	catch ()
			
			m_dialog_OSMWeb_estOuvert = false
			m_dialog.actualiser ()
		),
		fn ouvrir_OSMWeb =(
		
			createdialog m_dialog_OSMWeb		style: #( #style_resizing ,#style_titlebar , #style_border , #style_sysmenu)		--	parent:roll_OSM_importer		--		lockHeight:false		lockWidht:false		--bgcolor:[68,68,68 ]
			m_dialog_OSMWeb.m_prt			=	this 
			m_dialog_OSMWeb_estOuvert 	= true
		),
		
	----- Accession	---------
	private
		fn get_point		_id =(
			
			local result 
			
			--- on collecte les IDs des nodes composant le batiment	------
			local i = 0
			local trouve = false
			
			while i < m_points.count and not trouve do (
				
				i +=	1
				local pt = m_points[i]
				
				if pt.ref	 == _id do (
					result	=	pt.pos
					trouve = true
				)
			)
			result
		),
		fn get_element_points		_elemBat		=(
			
			local result =#()
			
			--- on cherche tout les noeuds "nd" du batiment	----
			local	elementsNodes_DuBat 	= m_xmlParser.get_elements	"nd"	element:_elemBat
			
			--- on collecte les IDs des nodes composant le batiment	------
			for elementNode in elementsNodes_DuBat do (
				local attribID =	elementNode.attributes.getNamedItem "ref"
				local pnt = ( get_point	attribID.value )
				if  pnt  != undefined do
					append result	( get_point	attribID.value )
				
			)
			
			-- si le dernier point est le meme que le premier on supprime le dernier ---
			if result.count > 1 do
				if result[1] == result[result.count]	do
					deleteItem result		result.count
				
			
			result
		),
		
		
	----- Creation des shapes	---------
	private	
		fn initialiser_creation_global =(
			m_points = m_points
			m_shps_batiments		= #()
			m_shps_voiries				= #()
			m_helper						= undefined
			m_helper_batiments		= undefined
			m_helper_voiries			= undefined
		),
		
		fn creer_helper nom:"DIVERS"=(
			
			--- les min et max pour placer dummy	-------
			m_helper 		= dummy name:( uniqueName( "OSM - " + nom) )
			
			local helper_maxi 	= 100000000000			
			m_helper_minX 	=	helper_maxi
			m_helper_minY 	=	helper_maxi
			m_helper_maxX 	=	-helper_maxi
			m_helper_maxY 	=	-helper_maxi
			
			m_helper
			
		),
			
		fn recadrer_helper 	=(
			
			local dum_echelle 	= [m_helper_maxX - m_helper_minX, m_helper_maxY - m_helper_minY, 10 ]
			local dum_pos 			= [m_helper_minX + dum_echelle.x / 2 , m_helper_minY + dum_echelle.y / 2, 0 ]
			m_helper.pos 	= dum_pos
			m_helper.scale	=	dum_echelle / 10	*	1.1
			selectMore m_helper
			
		),
		
		
		
		fn construire_shape		_objetAConstruire	echelle:1	type:"Divers"		fermerShape:false		wireCol:[200, 200, 255]		=(
			
				--- on construite le shape ------------------
				local nvShape	 = line pos:( _objetAConstruire.points[1] * echelle * m_const_coefEchelle_metre )	name:( uniqueName( "OSM - " + type + " - " ) )	wirecolor:wireCol
				addNewSpline nvShape
				for pt in _objetAConstruire.points do (
					
					local point_echelle = pt * echelle * m_const_coefEchelle_metre
					--- creation du point	----
					addKnot nvShape 1 #corner #line  	point_echelle
					
					-- on check les min et max globaux	----
					if m_helper_minX 	> point_echelle.x 	do 	m_helper_minX 	= point_echelle.x 
					if m_helper_minY 	> point_echelle.y 	do 	m_helper_minY 	= point_echelle.y 
					if m_helper_maxX < point_echelle.x 	do 	m_helper_maxX 	= point_echelle.x 
					if m_helper_maxY < point_echelle.y 	do 	m_helper_maxY 	= point_echelle.y 
				)
				
				if fermerShape do
					close nvShape 1
				
				updateshape nvShape
				convertToSplineshape nvShape
				
				nvShape
		),
		
		fn creer_elements		_elements		echelle:1.		type:"Divers"		wireCol:[200, 200, 255]		fermerShape:false	=(
			
			local typeAffiche = type
			if typeAffiche[typeAffiche.count] != "s" do  typeAffiche += "s"
				
			progressStart ( "OSM - Création des " + typeAffiche	+ " ..." )
			
			local chrono_debut	=	timestamp ()
			local nvxShapes 		= #()
			
			creer_helper nom:(toUpper  type )
			
			local i=0
			--- on collect les voiries et leurs points -----------------
			while i < _elements.count and not m_annuleOp do (
				
				local elemOSM	= _elements[i+1]
				
				local pourCent = (i as float) / _elements.count * 100
				progressUpdate pourCent
				
				local nvObjetOSM 			= str_OSM_object ()
				
				--- et on collecte les points du batiment	----------
				nvObjetOSM.points 			= get_element_points		elemOSM	
				if nvObjetOSM.points.count > 0 do (
					local nvShape = construire_shape		nvObjetOSM	echelle:echelle	type:type		wireCol:wireCol	fermerShape:fermerShape
					
					append nvxShapes		nvShape
				)
				
				--- on gere l'annulation -------
				if keyboard.escPressed or ( getProgressCancel() )  do
					m_annuleOp = true
				
				i += 1
				
			)
			
			
			--- le helper--------
			recadrer_helper ()
			for shp in nvxShapes do
				shp.parent = m_helper
			
-- 			
-- 			progressEnd() 			
			if not m_annuleOp  then (
				local chrono_result	=	.001 * ( timestamp ()	- chrono_debut )
				format "CP | OSM Importer |	Importation %   : %s.\n"	typeAffiche	chrono_result		
				format "CP | OSM Importer |		% % importés.\n"	nvxShapes.count		typeAffiche
			)
			nvxShapes
		),
		
	---- Chargement	------------------------------------------------
		fn parser 	=(
			
			
			local chrono_debut	=	timestamp ()
			
			progressStart "OSM - Analyse XML du fichier ...."
			
			--- on vide tout -----			
			m_points 					=	#()	
			m_shps_batiments 	=	#()
			m_shps_voiries 			=	#()
			
			---- la limite min du doc OSM --------------
			m_boundsMin			= [0,0]
			
			---	on remlpis nos elements	-------------
			local result 	=#()
			local root 		= m_xmlParser.get_root ()
			
			---- On collecte les nodes	----
			local i = 0
			
			while i < root.childNodes.count and not m_annuleOp do (
				
				local pourCent = (i as float) / root.childNodes.count * 100
				progressUpdate pourCent
				
				---- les WAY	(batiments et routes) ----
				if  root.ChildNodes.itemOf[i].name == "way" then (
					
					local elem_way = root.ChildNodes.itemOf[i]
					
					-- on cycle dans les attributs ---------------
					local j = 0
					local trouve = false
					local type_element = #voirie
					while j < elem_way.childNodes.count and not trouve do (
						
						---- on cherche dans les 'tag' -------------
						if  elem_way.ChildNodes.itemOf[j].name == "tag" do (
							local	valeur_de_K =	elem_way.ChildNodes.itemOf[j].attributes.itemOf[0].value
							
							-- on a un "building"	------
							if valeur_de_K == "building" then (
-- 								appendIfUnique m_elems_batiment	elem_way
								type_element = #building
								trouve = true
							)
							 -- on a une "route"	------
							else  if valeur_de_K == "highway" then (
								type_element = #route
								trouve = true
							) 
							/* -- le reste	------
							else  (
								appendIfUnique 	m_elems_divers		elem_way
								trouve = true
							) */
-- 							else format "tag : %\n"		valeur_de_K
							
						)
						j += 1
					)
				
					
					if type_element == #building	then
							appendIfUnique 	m_elems_batiment		elem_way
					else if type_element == #route then
							appendIfUnique 	m_elems_voiries			elem_way
					else 
							appendIfUnique 	m_elems_divers			elem_way
					
				------ les BOUNDS du document---------------
				) else	if  root.ChildNodes.itemOf[i].name == "bounds" then (
					
					local	elem_bounds = root.ChildNodes.itemOf[i]
					---- la limite min du doc OSM --------------
					local longitudeMin 	= elem_bounds.attributes.getNamedItem "minlon"
					local latitudeMin 		= elem_bounds.attributes.getNamedItem "minlat"
					m_boundsMin	 		= converterGPS.gpsToMeters   ( longitudeMin.value as double )  ( latitudeMin.value as double )
					
				------ les NODES (les differents point)---------------
				) else if  root.ChildNodes.itemOf[i].name == "node" then (
					local	elem_node = root.ChildNodes.itemOf[i]
-- 					appendIfUnique	m_elems_Nodes	elem_node
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
				
				--- on gere l'annulation -------
				if keyboard.escPressed or ( getProgressCancel() )  do
					m_annuleOp = true
				
				i+=1
				
			)	---- fin collecte les nodes	---------------
			
			m_points = m_points
			
-- 			progressEnd() 
			
			
			local chrono_result	=	.001 * ( timestamp ()	- chrono_debut )
			if not m_annuleOp  then (
				format "CP | OSM Importer |	Analyse XML : %s.\n"		chrono_result
				m_parsingOK = true
			)
			
		),
			
	-- Chargement du fichier *.osm	---------
		fn charger  _fichier =(
			
			if doesFileExist _fichier then	(
				
				format "CP | OSM Importer |	Importation de  : \"%\"\n"		_fichier
				
				m_nomDuFichier = _fichier
				
				local nomFichier 		= getFilenameFile		_fichier
				local fichier_temp 	= ("$userScripts\cp-Urba\\" + nomFichier + ".osm")
				copyFile 	_fichier		fichier_temp
				
				--- le fichier xml temporaire -----
				local fichierXmlTemp = getdir #userScripts + "\cp-Urba\\temp.xml"
				renameFile 	fichier_temp		fichierXmlTemp
				
				--- on charge le XML ------
				m_xmlParser.charger		fichierXmlTemp
				
				--- on supprime le fichier xml temporaire -----
				deleteFile fichierXmlTemp
				
				
			) else 
				format "--	OsM Importer --	 ERREUR : \"%\" n'existe pas !!\n"	_fichier
			
		),
		
		
	---- Interface	-----------------------------------------------------
	public
		
	---- Importation	dans la scene		------------------------------------------------
		fn importer	_fichier		batiments:true		voiries:true	divers:true		 echelle:1.0	=(
			
			if _fichier != undefined do with  redraw off (
				
				m_annuleOp 	= false
				
				local chrono_debut	=	timestamp ()	
				
				charger  _fichier
				
				parser ()
				
				local selectBack = selection as array
				
				
				if not m_annuleOp do	
					clearSelection ()
				
				initialiser_creation_global ()
			
				---- Creation du reste	-------
				if not m_annuleOp and divers do  (
					creer_elements		m_elems_divers			echelle:echelle			type:"Divers"			wireCol:[155, 155, 50]	fermerShape:true
					m_helper_divers  = m_helper
				)
				
				---- Creation des voiries	-------
				if not m_annuleOp and voiries do (
					m_shps_batiments = creer_elements		m_elems_voiries		echelle:echelle			type:"Voirie"			wireCol:[255, 255, 150]
					m_helper_voiries  = m_helper
				)
				
				---- Creation des batiments	-------
				if not m_annuleOp and batiments do (
					m_shps_voiries = creer_elements		m_elems_batiment		echelle:echelle		type:"Bâtiment"		wireCol:[200, 200, 255]		fermerShape:true
					m_helper_batiments  = m_helper
				)
				
				
				local chrono_result	=	.001 * ( timestamp ()	- chrono_debut )
				
				if m_annuleOp  then (
					-- on annule tout ----------------
					try delete m_shps_batiments		catch ()
					try delete m_shps_voiries			catch ()
					try delete m_shps_divers			catch ()
					try delete m_helper					catch ()
					try delete m_helper_batiments	catch ()
					try delete m_helper_voiries		catch ()
					try delete m_helper_divers			catch ()
					
					select	selectBack
					
					format "CP | OSM Importer |	 Opération annulée par l'utilisateur : %s.\n"		chrono_result
					
				) else 
					format "CP | OSM Importer |	Opération réussie : %s.\n"		chrono_result
				
			)
			progressEnd() 
			redrawviews ()
			
			ouvrir ()
		)
	
	
)	------- FIN OSM Importer	-------------




---- DECLARATION global de l'importer	---------
GLOBAL 	OSMImporter = str_OSM_importer ()


-- OSMImporter.ouvrir ()



















