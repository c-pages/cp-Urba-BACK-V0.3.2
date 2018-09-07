/*#########################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale

	QUARTIER - le coeur du plug.
	
########################################################################################################################*/


include	"$userScripts\\cp-Urba\\modules\\Commun\\Urba - Geometrie.ms"
include	"$userScripts\\cp-Urba\\modules\\Commun\\Urba - mgr - Datas to string.ms"
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
		m_geo		= 	str_geometrie 	(),
		m_datas		=	str_datasToString (),
	
	
	public
	----- liste des struct de typologies -----------------------
		m_typologies						=	#(),	----	Les models des batiments à utiliser pour construir le quartier.
	
	
	
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
	private
	---- Surbrillance ----------------------
		fn fn_afficher_surbrillance_shape  =(
			if selection.count == 1 and classof $ == Urba_Quartier do (
				if $.p_contours_surbrillance do (
					gw.setTransform (matrix3 1)
					gw.setColor	#line		yellow
					
					
					--- pour chaque contours -------
					for shp in $.p_contours do (
						
						pts_shp	 = for i in 1 to numknots shp collect getknotPoint shp	1	i
						gw.polyline pts_shp	true
						
					)
					
					gw.updateScreen() 
				)
			)
		),
	public		
		fn activer_surbrillance =(
			--- reset --------
			unregisterRedrawViewsCallback 	urba_fn_afficherContours
			
			if m_plug.p_contours_surbrillance do (
				urba_fn_afficherContours = fn_afficher_surbrillance_shape
				registerRedrawViewsCallback 		urba_fn_afficherContours 	
			)
		),
		fn desactiver_surbrillance =(
			unregisterRedrawViewsCallback 	urba_fn_afficherContours
			gw.updateScreen() 
		),
		
		
		
		
	
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	public
		------ global --------------
		fn charger_typologies =(
			m_typologies = #()
			--- on charge les typologies depuis les parametres du plug --------------
			for typo_strg in m_plug.p_typologies do (
				local nvlle_typo	=	str_typologie ()
				m_datas.set_datas_string		typo_strg		nvlle_typo
				append m_typologies	nvlle_typo
			)
		),
		fn initialiser 	_plug	= (
			debug "initialiser"
			m_plug = _plug
			m_geo.initialiser	_plug			

			charger_typologies ()
		),
		fn actualiser	=(
			debug "actualiser"
			m_geo.face		m_logo
			
		),
		
		
		---- Models de quartier ----------------
		fn charger 			_fichierModel	= (),
		fn enregistrer		_fichierModel	= (),
		
		
		
		
		
		------ Contours --------------
		fn	ajouter_contour		_shp		=		appendIfUnique	m_plug.p_contours		_shp,
		fn	ajouter_contours		_shps	=		for shp in _shps do	ajouter_contour		shp,
		fn retirer_contour		_shps	=	(
			for shp in _shps do (
				local id_aSupprimer = findItem m_plug.p_contours 	shp
				if id_aSupprimer != 0 do
					deleteItem id_aSupprimer
			)
		),
		fn retirer_contour_parIds		_ids	=	(
			for i= _ids.count to 1 by -1 do 
				deleteItem m_plug.p_contours 	_ids[i]			
		),
		
	
		fn ouvrir_rollout_liste =(
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
					m_plug.p_contours = for obj in liste_contours collect obj
					m_plug.actualiser_rollouts ()
					destroydialog roll_liste_contours	
				)
			) -- fin 	roll_liste_contours			 ----
			
			
			createdialog	roll_liste_contours	--modal:true
			debug "m_plug" var:m_plug
			roll_liste_contours.m_plug = m_plug
			
		),
		
		
		
		
		----- Typologies -------------------------
		fn creer_typologie	=(
			
			local nvlle_typo = str_typologie ()
			nvlle_typo.initialiser ()
			append m_typologies		nvlle_typo
			nvlle_typo.nom += " " + m_typologies.count as string
			
			local nvlle_typo_asString	=	m_datas.get_datas_string		nvlle_typo			
			append  m_plug.p_typologies		nvlle_typo_asString
			
			nvlle_typo
			
		),
		
		fn	enregistrer_typologie	_typo =(
			local trouve = false
			local i = 1
			while not trouve  do(
				local typo_test	=	str_typologie ()
				m_datas.set_datas_string		m_plug.p_typologies[i]		typo_test
				
				if typo_test.id == _typo.id do (
					trouve =true
					m_plug.p_typologies[i] = m_datas.get_datas_string		_typo
				)
				
				if i >=  m_plug.p_typologies.count do trouve = true
				
				i += 1
			)			
		),
		fn		supprimer_typologie	_typo =(
			debug "supprimer_typologie"
			debug "_typo" var:_typo
			local trouve = false
			local i = 1
			while not trouve  do (
				local typo_test	=	str_typologie ()
				m_datas.set_datas_string		m_plug.p_typologies[i]		typo_test
				
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
		)
	
	
)	--	fin str_quartier_core



























