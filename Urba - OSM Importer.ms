

-- (

------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
include "$userScripts\cp - GLOBAL\UI.ms"
include "$userScripts\cp - GLOBAL\DragDialog.ms"



------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_OSM_importer "OSM_importer" width:200 height:259
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
	local m_log
	
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[180,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	ImgTag 'ui_log' "" pos:[6,233] width:66 height:18 align:#left

	button 'btn_webOSM' "OSM web site" pos:[8,23] width:90 height:18 toolTip:"Acceder au site Open Street Map pour y télécharger un export '.osm'." align:#left
	button 'btn_charger' "Charger" pos:[100,23] width:92 height:18 toolTip:"Charger un fichier OSM (*.osm)." align:#left
	
	button 'btn_importer' "Importer" pos:[6,208] width:184 height:23 enabled:false toolTip:"Importer." align:#left
	groupBox 'grp_infos' "Infos" pos:[8,40] width:185 height:102 align:#left
	label 'lbl_infos' "" pos:[18,58] width:164 height:78 align:#left
	checkbox 'chk_batiments' "Batiments" pos:[10,145] width:84 height:18 align:#left		checked:true
	

	checkbox 'chk_voiries' "Voiries" pos:[10,164] width:61 height:18  align:#left		checked:true	--	enabled:false
	
	checkbox 'chk_zones' "Zones" pos:[102,146] width:61 height:18 enabled:false align:#left
	
	label 'lbl_echelle' "Echelle :" pos:[10,186] width:49 height:13 align:#left
	spinner 'spn_echelle' "" pos:[71,187] width:118 height:16 range:[0,1e+06,1] align:#left
	
		------------  Fonctions	----------------------------------------------------------------------------------
	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	
	fn actualiser = (
		
		local parsingOK = m_prt.get_parsingOK ()
		
		btn_importer.enabled 	= parsingOK
		grp_infos.enabled 			= parsingOK 
		lbl_infos.enabled 			= parsingOK 
		
		chk_batiments.enabled 	= parsingOK 
		chk_voiries.enabled = parsingOK 
-- 		chk_zones.enabled = parsingOK 
		
		lbl_echelle.enabled 		= parsingOK 
		spn_echelle.enabled 		= parsingOK 		
		
		if parsingOK do (
			local info_txt = ""
			info_txt		+=  m_prt.get_nomDuFichier () + "\n"
			info_txt		+= "\n"
			info_txt		+= "Points : " + m_prt.get_nbr_points () as string + "\n"
			info_txt		+= "Batiments : " + m_prt.get_nbr_batiments () as string + "\n"
			info_txt		+= "Voiries : " + m_prt.get_nbr_voiries () as string + "\n"
			lbl_infos.text = info_txt
		)
		
	)
	
	fn recadrer _taille =(
		
		ui_btnFermer.pos.x = _taille.x - 20
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_OSM_importer		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | OSM Importer"
		m_titre.setPolice (str_policeGrande())
		m_titre.setCouleur (color 5	5	5)
		m_titre.setCouleurFond (color 200 200 200)
		
		m_log 		= str_label 	m_ui:ui_log				m_texte:"."
-- 		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 55	55	55)
		m_log.setCouleurFond (color 200 200 200)
		
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	---- Drag ----
	on roll_OSM_importer lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_OSM_importer lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_OSM_importer mouseMove _pos 	do
		m_drag.suivreSouris ()
	
-- 	--- recadrage ----
-- 	on roll_OSM_importer resized  taille do
-- 		recadrer (taille)
	
	---- Fermer ----
	on ui_btnFermer mouseover do
		etatBtnFermer #Survol
	on ui_btnFermer mouseout do
		etatBtnFermer #Repos
	on ui_btnFermer mouseDown do
		etatBtnFermer #Press
	on ui_btnFermer mouseUp do
		etatBtnFermer #Repos	
	on ui_btnFermer click do
		m_prt.fermer ()
	
	--- interface	---------
	on btn_webOSM pressed  do
	(
		/* 	command = "ShellLaunch \"Chrome.exe\" @\"https://www.openstreetmap.org\""
			execute command
		 */
		rollout webbrowser_rollout "Open Street Map" width:800 height:600
			(
				edittext edt_Lieu "Lieu:" 	text:"Rouen"
				dotNetControl wb "System.Windows.forms.WebBrowser" pos:[10,22] width:780 height:570


				fn formaterTexte 	_texte =(
					substituteString 	_texte " " "%20"
				)
				
				fn openOSM_lieu	 _lieu	 = (
-- 					wb.AllowNavigation  = false
					
					local urlString		=	"https://www.openstreetmap.org/search?query="	
					local urlRecherche 	= urlString + formaterTexte  	_lieu	
					wb.url 		= dotNetObject "System.Uri" urlRecherche 
				
				)
				
				
				on edt_Lieu	entered txt 	do openOSM_lieu txt
				on webbrowser_rollout open 	do openOSM_lieu edt_Lieu.text




			)
			createdialog webbrowser_rollout		--bgcolor:[68,68,68 ]
	)
	on btn_charger pressed  do
	(
		m_log.setTexte "Importation du fichier OSM ..."
		
		local fichier = getOpenFileName 	caption:"Fichier OSM à importer"\
															types:"OSM(*.osm)|*.osm|All|*.*|" \
															historyCategory:"OSM_fichiers"
		if fichier != undefined then (
			
			m_prt.importer  fichier 
			
			m_log.setTexte "Importation reussie."
			 
		) else
			m_log.setTexte ""
		
		
		actualiser ()
	)
	on spn_echelle changed val do
(
	
	)
	
	
	on btn_importer pressed  do (
		
		m_prt.initialiser_creation ()
		
		if chk_batiments.checked do (

			m_log.setTexte "Création des batiments..."
			m_prt.creer_batiments ()
		)
		if chk_voiries.checked do (
			m_log.setTexte "Création des voiries..."
			m_prt.creer_voiries ()
		)
		
		m_prt.finaliser_creation ()
		
		m_log.setTexte ""
	
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
-- 			showmethods m_xmlDoc
			
			OK
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
		m_nomDuFichier ="",
		m_boundsMin	=	str_posGPS (),		
	
	--- les elements XML	----
		m_elems_Nodes 		= #(),
		m_elems_voiries		= #(),
		m_elems_batiment	= #(),
		
	--- les objets divers 		-----	
		m_points 			=#(),
		m_batiments 	= #(),
		m_voiries	 		= #(),
		
		m_parsingOK 	= false,
	
	--- les shapes ---------
		m_shps_batiments =#(),
		m_shps_voiries =#(),
		
	--- helper d'importation	---
		m_helper,	
		m_helper_minX,
		m_helper_minY ,
		m_helper_maxX ,
		m_helper_maxY,
	
	
	private
		m_xmlParser 		= str_xmlParser (),
		converterGPS = str_conv_GPStoMeter_mercator (),
	
		------------  Rollout ---------------
	public
		---- pointeurs ----
		m_dialog				= roll_OSM_importer ,		---- le rollout ----
		m_dialogPos 			= [100,100],
		m_ouvert				=false,
		
-- 		col_fenetreFond		= color 68  68 68, 	----  ----
-- 		col_fenetreTxt		= color 230  230 230, 	----  ----
		col_fenetreFond		= color 200	200	200, 	----  ----
		col_fenetreTxt		= color 5  5 5, 	----  ----
	
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
			createDialog m_dialog 	style:				#(#style_resizing) \
												lockHeight:			true	\
												lockWidth:			true		\
												pos:					m_dialogPos	\
												bgcolor:			col_fenetreFond 	 \
												fgcolor:				col_fenetreTxt 
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
		
	----	Fonctions	----------------------------------------
	public
	
	-- Accession	---------
		fn get_parsingOK 			= m_parsingOK,
			
		fn get_nbr_points 			= m_points.count,
		fn get_nbr_batiments 	= m_elems_batiment.count,
		fn get_nbr_voiries 		= m_elems_voiries.count,
			
		fn get_nomDuFichier 		= filenameFromPath m_nomDuFichier,
		
		
		
		
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
		
		fn get_element_points		_elemBat		=(
			
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
		
		
		
		fn initialiser_creation =(
			
			--- les min et max pour placer dummy	-------
			m_helper 		= dummy name:(uniqueName "OSM - Import " )
			
			local helper_maxi 	= 100000000000			
			m_helper_minX 	=	helper_maxi
			m_helper_minY 	=	helper_maxi
			m_helper_maxX 	=	-helper_maxi
			m_helper_maxY 	=	-helper_maxi
			
		),
			
		fn finaliser_creation =(
			
			local dum_echelle 	= [m_helper_maxX - m_helper_minX, m_helper_maxY - m_helper_minY, 10 ]
			local dum_pos 		= [m_helper_minX + dum_echelle.x / 2 , m_helper_minY + dum_echelle.y / 2, 0 ]
			m_helper.pos 	= dum_pos
			m_helper.scale	=	dum_echelle / 10
			
			for shapeBat in m_shps_batiments do
				shapeBat.parent = m_helper
			
			for shapeVoirie in m_shps_voiries do
				shapeVoirie.parent = m_helper
			
-- 			m_helper.pos = [0,0,0]
			select m_helper
			
		),
		
		fn creer_batiments	=(
			
			format "Analyse des batiments ... "
			local m_batiments	=#()
			
			
			progressStart "OSM - Analyse des batiments	..."
			
			local i = 0
			--- on collect les batiments et leur points -----------------
			for elemBat in m_elems_batiment do (
				
				
				local pourCent = (i as float) / m_elems_batiment.count * 100
				progressUpdate pourCent
				
				local nvBat 			= str_OSM_object ()
				
				--- et on collecte les points du batiment	----------
				nvBat.points 			= get_element_points	elemBat	
				append	m_batiments	nvBat
				
				i+= 1
			)
			progressEnd() 
			
			
			
			local m_shps_batiments =#()
			format "Tracé des batiments	... "
			
			progressStart "OSM  - Tracé des batiments	..."
			local i = 0
			for bat in m_batiments	do	(
				
				local pourCent = (i as float) / m_batiments.count * 100
				progressUpdate pourCent
				
				local shapeBat = line pos:bat.points[1] name:(uniqueName "OSM - Batiment ")	wirecolor:[230, 230, 150 ]
				append m_shps_batiments	shapeBat
			
				addNewSpline shapeBat
				for pt in bat.points do (
					addKnot shapeBat 1 #corner #line  	pt
					if m_helper_minX > pt.x 	do 	m_helper_minX 	= pt.x 
					if m_helper_minY > pt.y 	do 	m_helper_minY 	= pt.y 
					if m_helper_maxX < pt.x 	do 	m_helper_maxX 	= pt.x 
					if m_helper_maxY < pt.y 	do 	m_helper_maxY 	= pt.y 
				)
				close shapeBat 1
				updateshape shapeBat
				
				i+= 1
			)
			
			progressEnd() 
			
			
			
			format "... Creation des batiments   reussi. \n"
			format "	% batiments créés. \n"	m_shps_batiments.count
		),
	
		fn creer_voiries	=(
			
			format "Analyse des voiries ... "
			
			m_shps_voiries=#()
			
			local i=0
			progressStart "OSM - Analyse des voiries	..."
			--- on collect les voiries et leurs points -----------------
			for elemVoirie in m_elems_voiries do (
				
				
				local pourCent = (i as float) / m_elems_voiries.count * 100
				progressUpdate pourCent
				
				local nvVoirie 			= str_OSM_object ()
				
				--- et on collecte les points du batiment	----------
				nvVoirie.points 			= get_element_points	elemVoirie	
				append	m_voiries		nvVoirie
				
				i += 1
				
			)
			format "... Analyse des voiries   reussi. \n"
			
			
			format "Tracé des voiries	... "
			
			progressStart "OSM  - Tracé des voiries	..."
			for voirie in m_voiries	do	(
				
				local pourCent = (i as float) / m_voiries.count * 100
				progressUpdate pourCent
				
				local shapeVoirie = line pos:voirie.points[1] name:(uniqueName "OSM - Voirie ")	wirecolor:[150, 150, 255 ]
				append m_shps_voiries	shapeVoirie
			
				addNewSpline shapeVoirie
				for pt in voirie.points do (
					addKnot shapeVoirie 1 #corner #line  	pt
					if m_helper_minX > pt.x 	do 	m_helper_minX 	= pt.x 
					if m_helper_minY > pt.y 	do 	m_helper_minY 	= pt.y 
					if m_helper_maxX < pt.x 	do 	m_helper_maxX 	= pt.x 
					if m_helper_maxY < pt.y 	do 	m_helper_maxY 	= pt.y 
				)
-- 				close shapeBat 1
				updateshape shapeVoirie
			)
			
			progressEnd() 
			
			
			format "... Creation des voiries   reussi. \n"
			format "	% voiries créés. \n"	m_shps_voiries.count
		),
		
		
		
		---- Import	------------------------------------------------
		fn parser =(
			
			format "Parsing: ... \n"
			
			progressStart "OSM Importer - Parsing ...."
			
			--- on vide tout -----			
-- 			m_elems_Nodes 		= 	#()
			m_elems_voiries		= 	#()
			m_elems_batiment	= 	#()
			
			m_points 					=	#()
			m_batiments 			= 	#()
			
			
			
			---- la limite min du doc OSM --------------
			m_boundsMin			= [0,0]
			
			
			
			---	on remlpis nos elements	-------------
			local result 	=#()
			local root 		= m_xmlParser.get_root ()
			
			---- On collecte les nodes	----
			local i = 0
			local annuleOp = false			
			while i < root.childNodes.count and not annuleOp do (
-- 			for i = 0 to root.childNodes.count-1 do	(
				
-- 			format "	% ... \n"	i
				
				
				local pourCent = (i as float) / root.childNodes.count * 100
				progressUpdate pourCent
				
				
				------ les BOUNDS du document---------------
				if  root.ChildNodes.itemOf[i].name == "bounds" then (
					
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
				
				
				---- les WAY	(batiments et routes) ----
				else if  root.ChildNodes.itemOf[i].name == "way" do (
					
					
					local elem_way = root.ChildNodes.itemOf[i]
					
					-- on cycle dans les attributs ---------------
					local j = 0
					local trouve = false
					while j < elem_way.childNodes.count and not trouve do (
-- 					for j = 0 to elem_way.childNodes.count-1 do	(
						
						---- on cherche dans les 'tag' -------------
						if  elem_way.ChildNodes.itemOf[j].name == "tag" do (
							local	valeur_de_K =	elem_way.ChildNodes.itemOf[j].attributes.itemOf[0].value
							
							-- on a un "building"	------
							if valeur_de_K == "building" do (
								appendIfUnique m_elems_batiment	elem_way
								trouve = true
							)
							-- on a une "route"	------
							if valeur_de_K == "highway" do (
								appendIfUnique m_elems_voiries		elem_way
								trouve = true
							)
							
						)
						j += 1
					)
					
					
					
				)
				
				
				--- on gere l'annulation -------
				if keyboard.escPressed or ( getProgressCancel() )  do
					annuleOp = true
				
				i+=1
				
			)	---- fin collecte les nodes	---------------
			
-- 			progressUpdate 100
			progressEnd() 
			
			if annuleOp  then (
				format "...	parsing annulé par l'utilisateur.\n"
				m_parsingOK = false
			) else (
				format "...	parsing reussi.\n"
				m_parsingOK = true
			)
			
		),
		
	-- Importation	---------
		fn importer  _fichier =(
			
			if doesFileExist _fichier then	(
				
				m_nomDuFichier = _fichier
				
				local nomFichier 		= getFilenameFile		_fichier
				local fichier_temp 	= ("$userScripts\cp-Urba\\" + nomFichier + ".osm")
				copyFile 	_fichier		fichier_temp
				
				--- le fichier xml temporaire -----
				local fichierXmlTemp = getdir #userScripts + "\cp-Urba\\temp.xml"
				renameFile 	fichier_temp		fichierXmlTemp
				
				--- on charge le XML ------
				m_xmlParser.charger		fichierXmlTemp
				
				parser ()
				
-- 				creer_batiments ()
				
				--- on supprime le fichier xml temporaire -----
				deleteFile fichierXmlTemp
				
				
			) else 
				format "--	OsM Importer --	 ERREUR : \"%\" n'existe pas !!\n"	_fichier
		)
		
		
)	------- FIN OSM Importer	-------------




---- DECLARATION global de l'importer	---------
GLOBAL 	OSMImporter = str_OSM_importer ()






















