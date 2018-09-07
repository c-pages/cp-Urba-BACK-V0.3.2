/*#########################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale

	QUARTIER - le coeur du plug.
	
########################################################################################################################*/


include	"$userScripts\\cp-Urba\\modules\\Commun\\Urba - Geometrie.ms"
include	"$userScripts\\cp-Urba\\modules\\Commun\\Urba - Shapes.ms" 
include	"$userScripts\\cp-Urba\\modules\\Commun\\Urba - Presets.ms" 
-- include	"$userScripts\\cp-Urba\\modules\\Quartier\\Quartier - Presets.ms"
include	"$userScripts\\cp-Urba\\modules\\Quartier\\Quartier - typologie.ms"





--- la sturucture centrale du plug in ------------------------------------------
struct str_quartier_core (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba | Quartier CORE",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	
	
	-------- MEMBRES	--------------------------------------------------------------------------------------------------------
	
	private
	---- tracé Logo  -------------------
		m_logo = #([-1900,-100,0], [1900,-100,0], [1900,3.05176e-05,0], [1500,3.05176e-05,0], [1500,100,0], [1400,200,0], [1300,100,0], [1300,3.05176e-05,0], [1100,3.05176e-05,0], \
						[1100,600,0], [800,600,0], [800,300,0], [600,300,0], [600,500,0], [400,700,0], [400,100,0], [300,200,0], [200,100,0], [200,300,0], [-100,300,0], [-100,200,0], [-300,400,0], \
						[-300,700,0], [-500,700,0], [-500,400,0], [-600,500,0], [-700,400,0], [-700,100,0], [-800,200,0], [-900,100,0], [-1000,3.05176e-05,0], [-1200,3.05176e-05,0], [-1200,100,0], \
						[-1300,200,0], [-1400,100,0], [-1400,3.05176e-05,0], [-1900,3.05176e-05,0]),

	---- pointeur  vers le plugin --------------------
		m_plug,
	
	---- managers --------------
		mgr_geo			= 	str_geometrie 	(),
		mgr_shapes	=	str_outils_shape (),
		mgr_datas		=	str_datasToString (),
		mgr_presets	=	str_mgr_presets 		fichier_dossier:		"$userScripts\cp-Urba\lib\Typologies\\" 	\
															fichier_categorie:		"Urba_Typologie"\
															fichier_extension:		"typo",
	
	
	
	private
	----- liste des struct de typologies -----------------------
		m_typologies			=	#(),	----	Les models des batiments à utiliser pour construir le quartier.
		m_typo_active			=	0,
-- 		m_contours_datas	=	#(),	----	les datas des contours 
	
	
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
	private
	---- Surbrillance ----------------------
		----- la fonction propre ---------------
		fn fn_afficher_surbrillance_typologie  =(
			if selection.count == 1 and classof $ == Urba_Quartier do (
				
				local typo = $.core.get_typo_active ()
				if typo != undefined and $.p_typologies_surbrillance do (
					gw.setTransform (matrix3 1)
					
					--- pour chaque contours -------
					gw.setColor	#line		typo.couleur
					for id_contour in typo.contours_index do (
						
						local shp = $.p_contours[ id_contour ]
						pts_shp	 = for i in 1 to numknots shp collect getknotPoint shp	1	i
						gw.polyline pts_shp	true
-- 						for pt in pts_shp	do							
-- 							gw.Marker pt		#smallDiamond    color:typo.couleur--yellow
					)
					
					gw.updateScreen() 
				)
			)
		),
		fn fn_afficher_surbrillance_contours  =(
			if selection.count == 1 and classof $ == Urba_Quartier do (
				if $.p_contours_surbrillance do (
					gw.setTransform (matrix3 1)
					gw.setColor	#line		white
					
					--- pour chaque contours -------
					for shp in $.p_contours do (
						
						pts_shp	 = for i in 1 to numknots shp collect getknotPoint shp	1	i
						gw.polyline pts_shp	true
-- 						for pt in pts_shp	do							
-- 							gw.Marker pt		#smallCircle   color:white
					)
					
					gw.updateScreen() 
				)
			)
		),
	public		
		fn activer_surbrillance_contours =(
			debug "activer_surbrillance_contours"
			--- reset --------
			unregisterRedrawViewsCallback 	urba_fn_afficherContours
			
			if m_plug.p_contours_surbrillance do (
				urba_fn_afficherContours = fn_afficher_surbrillance_contours
				registerRedrawViewsCallback 		urba_fn_afficherContours 	
			)
		),
		fn activer_surbrillance_typologie =(
			debug "activer_surbrillance_typologie"
			--- reset --------
			unregisterRedrawViewsCallback 	urba_fn_afficherTypologie
			
			if m_plug.p_typologies_surbrillance do (
				urba_fn_afficherTypologie = fn_afficher_surbrillance_typologie
				registerRedrawViewsCallback 		urba_fn_afficherTypologie 	
			)
		),
		fn desactiver_surbrillances =(
			debug "desactiver_surbrillances"
			unregisterRedrawViewsCallback 	urba_fn_afficherContours
			unregisterRedrawViewsCallback 	urba_fn_afficherTypologie
			gw.updateScreen() 
		),
		
		
		
		
	
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	public
		------ global --------------
		fn charger_parametres	=	(
			this.charger_typologies ()
-- 			this.charger_contours ()			
		),
		fn initialiser 	_plug	= (
			debug "initialiser"
			m_plug = _plug
			mgr_geo.initialiser	_plug			
			
			charger_parametres ()
		),
		fn actualiser	=(
			debug "actualiser"
			mgr_geo.face		m_logo
		),
		
		---- Models de typologies ----------------
		fn charger_typologies_preset 				= (
			mgr_presets.charger 			m_plug
			charger_parametres()
			
			this.analyser_typologies ()
			
				
		),
		fn enregistrer_typologies_preset 			= mgr_presets.enregistrer 	m_plug ,
		
		
		
		
		
		
		
		------ Contours --------------
		
		fn analyser_contour		_shp		=(
			
			
			------- structures de datas -----------------
			struct str_contour_data (
				
			-- 	shp		=	undefined,
				
				contour_index	=	0,
				pts				=	#(),
				bat_index		=	0,
				
				surface			=	0,
				largeur			=	0,
				longueur			=	0
				
			)
			
			
			
			
			
			----  ( cf. analyse de la creation de batioment !!! ...  ) ----------------------------------------------------------------------------------
			local	contourDatas = str_contour_data ()
			
			---------------    Prepartion du shape -------------------------------------------------------------------------------------------
			contourDatas.pts		=	#()
			---- On chope les points de la surface a scanner -----------
			
			for id_pt = 1 to ( numKnots 	 _shp	1 ) do	(
				local pt_shape 	= getKnotPoint 	_shp 	1 	id_pt
				local pt_surface 	= pt_shape * inverse  _shp.transform
				append contourDatas.pts 	 pt_surface
			)
			
			--- on fait tourner les spline dans le meme sens ----
			if not mgr_shapes.est_sensPositif 	contourDatas.pts 	 do
				contourDatas.pts = mgr_shapes.changer_sens		contourDatas.pts
			
			
			
			
			---------------    Analyses   -------------------------------------------------------------------------------------------
			---- la surface -----------
			contourDatas.surface	=	   mgr_shapes.get_aire_shape	contourDatas.pts 
				
			
			
			
			--- largeur et longueur ---------------
			local axe_principal_mtrx 	= 	mgr_shapes.get_axePrincipal_mtrx  	contourDatas.pts
			local axe_principal_BB 		=	mgr_shapes.get_axePrincipal_BB		contourDatas.pts		axe_principal_mtrx
			
			local longueur_X				= abs ( axe_principal_BB[2].x		-		axe_principal_BB[1].x ) 
			local longueur_Y				= abs ( axe_principal_BB[2].y	-		axe_principal_BB[1].y ) 
			
			if longueur_X < longueur_Y then (
				contourDatas.largeur 	= longueur_X
				contourDatas.longueur 	= longueur_Y
			) else (
				contourDatas.largeur 	= longueur_Y
				contourDatas.longueur 	= longueur_X
			)
			
			
			contourDatas
			
		),
		
		
		fn	ajouter_contour		_shp		=	(
			
			
-- 			debug "ajouter_contour"
-- 			debug "		_shp" var:_shp
			
			
			appendIfUnique m_plug.p_contours		_shp
			/* 
			--- datas -------
			local nv_contour	=	creer_contour_data () 		
			nv_contour.contour_index	=	 m_plug.p_contours.count 
			analyser_contour		&nv_contour
			
-- 			appendIfUnique	m_plug.p_contours_datas   (  mgr_datas.get_datas_string		nv_contour )
			appendIfUnique	m_contours_datas		nv_contour
			appendIfUnique	m_plug.p_contours		_shp
			 */
			
		),
		
		
		
		
		fn	ajouter_contours		_shps	=		(
			for shp in _shps do	ajouter_contour		shp
			this.analyser_typologies	()
		),
		fn retirer_contour		_shps	=	(
			for shp in _shps do (
				local id_aSupprimer = findItem m_plug.p_contours 	shp
				if id_aSupprimer != 0 do
					deleteItem 	m_plug.p_contours	id_aSupprimer
			)
		),
		fn retirer_contour_parIds		_ids	=	(
			for i= _ids.count to 1 by -1 do 
				deleteItem m_plug.p_contours 	_ids[i]			
		),
		fn ouvrir_rollout_contours =(
			debug	"ouvrir_rollout_liste"
			rollout roll_liste_contours "Contours" width:375 height:262				(
				
				local	m_plug
				
				local liste_contours =#()
				local liste_scene =#()
				
				multiListBox 'lbx_scene' "Scène" pos:[5,6] width:173 height:16 align:#left
				button 'btn_ajouter' ">" pos:[179,25] width:16 height:16 align:#left
				
				button 'btn_retirer' "<" pos:[179,40] width:16 height:16 align:#left
				multiListBox 'lbx_quartier' "Quartier" pos:[196,6] width:173 height:16 align:#left
				button 'btn_annuler' "Annuler" pos:[309,238] width:60 height:20 align:#left
				button 'btn_valider' "Valider" pos:[250,238] width:60 height:20 align:#left
				
				fn actualiser =(
					
					local noms_shapes_scene = for obj in liste_scene	collect  obj.name
					lbx_scene.items = noms_shapes_scene
					
					local noms_shapes_quartier	= for obj in liste_contours	collect  obj.name
					lbx_quartier.items = noms_shapes_quartier
				)
				
				on roll_liste_contours open do
				(
					liste_contours	= 	for obj in $.p_contours 	collect  obj
					liste_scene		=	for obj in shapes where findItem	liste_contours 	obj	==0	collect  obj
					actualiser ()
				)
				on btn_ajouter pressed  do		(
					
					local ids_aAjouter	=	 lbx_scene.selection as array
					
					-- on les ajoute au quartier -------
					for id_scene in ids_aAjouter do
						append	liste_contours	liste_scene[ id_scene ]
					--- on les retire de la scene ----------
					for i = ids_aAjouter.count to 1 by -1 do 
						deleteItem	liste_scene		ids_aAjouter[i]
					
					actualiser ()
				)
				on btn_retirer pressed  do				(
					
					local ids_aRetirer	=	 lbx_quartier.selection as array
					
					-- on les retire du quartier -------
					for i = ids_aRetirer.count to 1 by -1 do
						deleteItem	liste_contours	ids_aRetirer[ i ]
					
					--- on actualise la liste de la scene ----------
					liste_scene		=	for obj in shapes where findItem	liste_contours 	obj	==0	collect  obj
					
					actualiser ()
				)
				on btn_annuler pressed  do	
					destroydialog roll_liste_contours
				
				on btn_valider pressed  do
				(
					m_plug.p_contours = #()
					m_plug.core.ajouter_contours 	liste_contours
					
					
					m_plug.actualiser_rollouts ()
					destroydialog roll_liste_contours	
				)
			) -- fin 	roll_liste_contours			 ----
			
			
			createdialog	roll_liste_contours	
			roll_liste_contours.m_plug = m_plug
			
		),
		
		
		
		
		
		
		
		
		
		----- Typologies -------------------------
		fn generer_typologie		_typo =		with redraw off 		(
			
			for id_contours in _typo.contours_index do(
				if m_plug.p_batiments[ id_contours ]  == undefined do (
					local nv_bat = Urba_Batiment	affiche_asProxy:true	wirecolor:_typo.couleur
					nv_bat.assigner_shape 		nv_bat		m_plug.p_contours[ id_contours ]
					m_plug.p_batiments[ id_contours ] = nv_bat
				)
				if _typo.batiments.count > 0 do (
					nv_bat.charger	_typo.batiments[1]
				)
			)
		),
		
		fn	analyser_typologie   _typo 	contours_aUtiliser:	=(
			
-- 			debug "analyser typo"
			local contours =#()
			if contours_aUtiliser == unsupplied then
				contours = m_plug.p_contours
			else
				contours = contours_aUtiliser
			
			--- on valide les contours ------------
			_typo.contours_index =#()
			for i = 1 to contours.count do (
				local contour = contours[i]
				local dt_contour = analyser_contour		contour
				local valide = true
				
				--- unité affichag en metre² -----
				local facteur_unite_m2 	= 10000.
				local facteur_unite_m	 	= 100.
				
				--- condition de surface ------
				if _typo.conditions_surfMin_use do
					if dt_contour.surface < _typo.conditions_surfMin * facteur_unite_m2	do	valide = false
				if _typo.conditions_surfMax_use do
					if dt_contour.surface > _typo.conditions_surfMax *facteur_unite_m2   do	valide = false
				
				--- condition de largeur ------
				if _typo.conditions_largMin_use do
					if dt_contour.largeur < _typo.conditions_largMin 	do	valide = false
				if _typo.conditions_largMax_use do
					if dt_contour.largeur > _typo.conditions_largMax    do	valide = false
				
				--- condition de longueur ------
				if _typo.conditions_longMin_use do
					if dt_contour.longueur < _typo.conditions_longMin 	do	valide = false
				if _typo.conditions_longMax_use do
					if dt_contour.longueur > _typo.conditions_longMax    do	valide = false
				
				
				--- on valide ou pas -----
				if valide do (
					append 	_typo.contours_index 	i
				)
			)
-- 			debug "_typo.contours_index" var:_typo.contours_index
		),
		
		
		
		fn analyser_typologies =(
-- 			debug "<<< analyser_typologies >>>"
-- 			local ids_contours_aUtiliser = #{1,m_plug.p_contours.count}
			local contours_aUtiliser = for contour in m_plug.p_contours collect contour
			
			for typo in m_typologies do (
				analyser_typologie  typo 	contours_aUtiliser:contours_aUtiliser
-- 				ids_contours_aUtiliser - = typo.contours_index  as bitarray
				for i = typo.contours_index.count to 1 by -1 do
					deleteItem contours_aUtiliser		typo.contours_index[ i ]
			)
			
			
		),
		
		
		
		
		
		
		fn	set_typo_active	_id	=	m_typo_active = _id,
		fn	get_typo_active			=	if m_typo_active != 0 then  m_typologies[ m_typo_active] else undefined,
		fn get_typologies				=	for typo in m_typologies collect typo,
		fn charger_typologies =(
			m_typologies = #()
			--- on charge les typologies depuis les parametres du plug --------------
			for typo_strg in m_plug.p_typologies do (
				local nvlle_typo	=	str_typologie ()
				mgr_datas.set_datas_string		typo_strg		nvlle_typo
				append m_typologies	nvlle_typo
			)
			analyser_typologies ()
		),
		fn	enregistrer_typologie	_typo =(
			local trouve = false
			local i = 1
			while not trouve  do(
				local typo_test	=	str_typologie ()
				mgr_datas.set_datas_string		m_plug.p_typologies[i]		typo_test
				
				if typo_test.id == _typo.id do (
					trouve =true
					analyser_typologie  _typo
					m_plug.p_typologies[i] = mgr_datas.get_datas_string		_typo
				)
				
				if i >=  m_plug.p_typologies.count do trouve = true
				
				i += 1
			)			
		),
		fn creer_typologie	=(
			
			local nvlle_typo = str_typologie ()
			nvlle_typo.initialiser ()
			append m_typologies		nvlle_typo
			nvlle_typo.nom += " " + m_typologies.count as string
			
			local nvlle_typo_asString	=	mgr_datas.get_datas_string		nvlle_typo			
			append  m_plug.p_typologies		nvlle_typo_asString
			analyser_typologies ()
			
			nvlle_typo
			
		),		
		fn	supprimer_typologie	_typo =(
			debug "supprimer_typologie"
			debug "_typo" var:_typo
			local trouve = false
			local i = 1
			while not trouve  do (
				local typo_test	=	str_typologie ()
				mgr_datas.set_datas_string		m_plug.p_typologies[i]		typo_test
				
				debug "typo_test" var:typo_test
				if typo_test.id == _typo.id do (
					trouve =true
					deleteItem	m_plug.p_typologies		i
					deleteItem	m_typologies		i
				)
				
				if i >=  m_plug.p_typologies.count do trouve = true
				
				i += 1
			)			
		),
		fn monter_typologie			_id_typo		=(
			
			local typo_abouger				=	m_typologies[ _id_typo ]
			deleteItem	m_typologies				_id_typo
			insertItem	typo_abouger		m_typologies		(_id_typo - 1) 
			
			local typo_abouger_param	=	m_plug.p_typologies[ _id_typo ]			
			deleteItem	m_plug.p_typologies		_id_typo			
			insertItem	typo_abouger_param		m_plug.p_typologies		(_id_typo - 1) 
			
		),
		fn descendre_typologie		_id_typo		=(
			
			local typo_abouger				=	m_typologies[ _id_typo ]
			deleteItem	m_typologies				_id_typo
			insertItem	typo_abouger		m_typologies		(_id_typo + 1) 
			
			local typo_abouger_param	=	m_plug.p_typologies[ _id_typo ]			
			deleteItem	m_plug.p_typologies		_id_typo	
			if _id_typo < m_plug.p_typologies.count then
				insertItem	typo_abouger_param		m_plug.p_typologies		(_id_typo + 1) 
			else
				append		m_plug.p_typologies		typo_abouger_param
		),
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		fn ajouter_batiment_aTypo  		_typo =(
			
			local fichierCible 	=	getopenFileName 		caption:				"Charger" 				\
																	filename:			"$userScripts\cp-Urba\lib\Batiments\\" 		\
																	types:				"Urba_batiment"			\
																	historyCategory:	"bati"
			if findItem _typo.batiments	fichierCible	== 0 do
					if fichierCible != undefined do (
						append _typo.batiments				fichierCible
						append _typo.batiments_pourcent	100
					)
			
			m_plug.actualiser_rollouts()
			
		),
		
		fn retirer_batiment_aTypo 	_typo		_id_bat	=(
			deleteItem 	_typo.batiments					_id_bat
			deleteItem 	_typo.batiments_pourcent		_id_bat
		),
		
		
		-------- generation des batiments ----------
		fn generer_batiments	= with redraw off (
			
			debug "generer_batiments--------" 
			debug "m_contours_datas" var:m_contours_datas
			/* 
			for contour_data in m_contours_datas do (
				
				
				if  contour_data.bat_index == 0 do (
					local nv_bat = Urba_Batiment()
					nv_bat.assigner_shape 		nv_bat		m_plug.p_contours[ contour_data.contour_index ]
					append	m_plug.p_batiments 		nv_bat
					contour_data.bat_index		=	m_plug.p_batiments.count
					enregistrer_contour	contour_data
				)
				
			) */
			local contours_aUtiliser			=	#{0,m_plug.p_contours.count}
			for typo in m_typologies do (
				
				
			)
			
		)
	
	
)	--	fin str_quartier_core



























