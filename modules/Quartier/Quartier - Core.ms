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
		m_typologies			=	#(),			----	Les models des batiments à utiliser pour construir le quartier.
		m_typo_active		=	0,
		
		m_contours_aUtiliser	=	#{},			----
		
		m_nbr_bats_aConstruire = 0,
		m_nbr_bats_construits = 0,
		
	
	
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
	private
	---- Surbrillance --------------------------------------------------------------
		----- la fonction propre ---------------
		fn fn_afficher_surbrillance_contours  =(
			if selection.count == 1 and classof $ == Urba_Quartier do (
			
					gw.setTransform (matrix3 1)
					
					
					local couleur =  white
					if  $.p_typologies_surbrillance and $.p_typologies.count >0 then (
						--- pour chaque typologie -------
						local coutours_gris 	= true
						local typo_active 	= $.core.get_typo_active ()
						local typos 			= $.core.get_typologies ()
						for typo in  typos  do (
							
							-- la couleur ----------					
							if typo == typo_active or typos.count == 1 do (
								coutours_gris = false
							)
							
							---- les contours --------
							
							local contours_ids 	=	#()
							if typo.contours_tout then contours_ids = typo.contours_index
									else	contours_ids = typo.contours_groupe
							
							
							for i = 1 to contours_ids.count /* where typo.contours_valides[i] */	do (
								local id_contour = contours_ids[i]
								local shp =  $.p_contours[ id_contour ]
								
								
								
								couleur =  if coutours_gris then gray else white		
								if typo == typo_active and typo.contours_valides[ id_contour ] do
									couleur = yellow
								
								gw.setColor	#line		couleur
								
								local pts_shp	 = for i in 1 to numknots shp collect getknotPoint shp	1	i
								gw.polyline pts_shp	true
								
							)
						)
					
					)  else (
						for i = 1 to $.p_contours.count do (
							
							local couleur =  white
							local shp =  $.p_contours[i]
							if $.roll_contours.lbx_contours.selection[ i ] then couleur = yellow
							
							gw.setColor	#line		couleur
							pts_shp	 = for i in 1 to numknots shp collect getknotPoint shp	1	i
							gw.polyline pts_shp	true
						)
					)
					
					gw.updateScreen() 
				
			)
		),
	public			
		fn activer_surbrillance =(
			debug "activer_surbrillance"
			--- reset --------
			unregisterRedrawViewsCallback 	urba_fn_afficherContours
			
			urba_fn_afficherContours = fn_afficher_surbrillance_contours
			registerRedrawViewsCallback 		urba_fn_afficherContours 
			redrawviews ()
		),
		
		fn desactiver_surbrillance =(
			debug "desactiver_surbrillance"
			
			unregisterRedrawViewsCallback 	urba_fn_afficherTypologie
			gw.updateScreen() 
			redrawviews ()
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
			
			this.enregistrer_typologies ()
		),
		fn enregistrer_typologies_preset 			= mgr_presets.enregistrer 	m_plug ,
		
		
		
		
		
		
		
		------ Contours --------------
		
		fn analyser_contour		_shp		= if _shp != undefined do (
			
			
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
			include	"$userScripts\\cp-Urba\\modules\\Quartier\\Quartier - rollout - selection Contours.ms"
			
			createdialog	roll_liste_contours	style:#(#style_titlebar , #style_border ,  #style_sysmenu ,#style_resizing)	--#(#style_titlebar , #style_border ,  #style_sysmenu )
			
			
			
			roll_liste_contours.m_plug = m_plug
			
		),
		
		
		
		
		
		
		
		
		
		----- Typologies -------------------------
	private
		fn	analyser_typologie   _typo 	contours_aUtiliser:	=(
			
-- 			debug "analyser_typologie"
-- 			debug "_typo" var:_typo
			
			local contours =#()			
			contours = for contour in m_plug.p_contours collect contour
			
			
			
			_typo.contours_index 						=	#()
			_typo.contours_ids_modelBat_choisis	=	#()
			
			_typo.contours_valides						=	#{}
			
			
			--- on choisi les CONTOURS ------------
			for i = 1 to contours.count where 	m_contours_aUtiliser[i]	do (
				
				--- unité affichag en metre² -----
				local facteur_unite_m2 	= 10000.
				local facteur_unite_m	 	= 100.
				
				
				local contour 			= contours[i]
				local dt_contour 		= analyser_contour		contour
				local valide 			= true
				
				
				
				
				
				
-- 				if  _typo.contours_tout or  	not _typo.contours_tout and  ( _typo.contours_groupe as bitarray )[i] do	
				append 	_typo.contours_index 	i
				
				
				
				
				if not _typo.contours_tout and not ( _typo.contours_groupe as bitarray )[i] do	valide = false
				
				--- condition de surface ------
				if _typo.conditions_surfMin_use do
					if dt_contour.surface < _typo.conditions_surfMin * facteur_unite_m2	do	valide = false
				if _typo.conditions_surfMax_use do
					if dt_contour.surface > _typo.conditions_surfMax *facteur_unite_m2   	do	valide = false
				
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
-- 					append 	_typo.contours_valides 	i
					_typo.contours_valides[i] 	= true
					m_contours_aUtiliser[i]			= false
				)
			)
			
			
			
			--- on choisi les BATIMENTS pour chaque contour ------------	
			if _typo.batiments_models.count == 1 then (
				
				for id_contour in _typo.contours_index do
					append _typo.contours_ids_modelBat_choisis 1
				
			) else if _typo.batiments_models.count > 1 then (
				for i = 1 to _typo.contours_index.count where _typo.contours_valides[i]  do (
					
					local id_contour = _typo.contours_index[i]
					
					local pourcentTotal = 0
					for pourcent in _typo.batiments_pourcent do pourcentTotal += pourcent				
					local tirage = random 0. pourcentTotal
					 
					/*debug	""
					debug "	--->	tirage" var:tirage
					debug "	--->	typo.batiments_pourcent" var:_typo.batiments_models
					debug "	--->	typo.batiments_pourcent" var:_typo.batiments_pourcent
					debug "	--->	pourcentTotal" var:pourcentTotal */
					
					local j				= 1
					local bat_choisi 	= 0
					local trouve 		= false
					local fin 			= false
					local val_min 		= 0
					local val_max 		= _typo.batiments_pourcent[ 1 ]
					while not trouve and not fin do (
						if tirage > val_min and tirage <= val_max then (
							trouve = true
							bat_choisi = j
						) 
						
						j +=1
						
						if j > _typo.batiments_pourcent.count then fin = true
							else (								
								val_min = val_max
								val_max += _typo.batiments_pourcent[j]
							)
					)
					
					if trouve do 
						_typo.contours_ids_modelBat_choisis[i] = bat_choisi
-- 					debug "	--------->	bat_choisi" var:bat_choisi
					
					
				)
				
			) else for id_contour in _typo.contours_index do
				append _typo.contours_ids_modelBat_choisis 0
			
-- 			debug "	---->	_typo.contours_index" var:_typo.contours_index
			
			this.enregistrer_typologie		_typo
			
			/* 
			contours_ids_modelBat_choisis
			
			local model_choisi				
			if _typo.batiments_models.count ==0 then
				model_choisi = _typo.batiments_models[1]
			else 		
			if _typo.batiments_models.count ==1 then
				model_choisi = _typo.batiments_models[1]
			else (
				local pourcentTotal = 0
				for pourcent in _typo.batiments_pourcent do pourcentTotal += pourcent
				
				local tirage = random 0. pourcentTotal
				debug "tirage"
			) */
			
			
			
-- 			this.enregistrer_typologie 	_typo
			
-- 			debug "		--->	contours_index  APRES" var:_typo.contours_index
		),
		
		
	public
		fn analyser_typologies =(
-- 			debug ""
-- 			debug "<<< analyser_typologies >>>"
			
			if m_plug.p_contours.count != 0 do 
				m_contours_aUtiliser	 = #{1..m_plug.p_contours.count}
			
			for typo in m_typologies do (
				analyser_typologie  typo
-- 				debug "m_contours_aUtiliser" var:m_contours_aUtiliser
			)
			
		),
		
		
		
		fn get_typo_vide =(
			include	"$userScripts\\cp-Urba\\modules\\Quartier\\Quartier - typologie.ms"
			str_typologie ()
		),
		
		
		fn	set_typo_active	_id	=	m_typo_active = _id,
		fn	get_typo_active			=	if m_typo_active != 0 then  m_typologies[ m_typo_active] else undefined,
		fn get_typologies				=	for typo in m_typologies collect typo,
		fn charger_typologies =(
			m_typologies = #()
			--- on charge les typologies depuis les parametres du plug --------------
			for typo_strg in m_plug.p_typologies do (
				local nvlle_typo	=	get_typo_vide ()
				
-- 				debug " |||||||||||||||||||||||||| 		A		 ||||||||||||||||||||||||||"
-- 				debug " typo_strg" var:typo_strg
				
				mgr_datas.set_datas_string		typo_strg		nvlle_typo
				
				
-- 				debug " |||||||||||||||||||||||||| 		A	2	 ||||||||||||||||||||||||||"
				
				append m_typologies	nvlle_typo
			)
			
			analyser_typologies ()
			
		),
		fn	enregistrer_typologie	_typo =(
			local trouve = false
			local i = 1
			while not trouve  do (
				local typo_test	=	get_typo_vide()
				mgr_datas.set_datas_string		m_plug.p_typologies[i]		typo_test
				
				if typo_test.id == _typo.id do (
					trouve =true
-- 					analyser_typologie  _typo
					m_plug.p_typologies[i] = mgr_datas.get_datas_string		_typo
				)
				
				if i >=  m_plug.p_typologies.count do trouve = true
				
				i += 1
			)			
		),
		fn enregistrer_typologies	=(
			
			m_plug.p_typologies  =	#()
			
			for i = 1 to m_typologies.count do (
				m_plug.p_typologies[i] = mgr_datas.get_datas_string		m_typologies[i]
				
			)
		),
		
		
		
		
		fn creer_typologie	=(
			
			local nvlle_typo = get_typo_vide ()
			nvlle_typo.initialiser ()
			append m_typologies		nvlle_typo
			nvlle_typo.nom += " " + m_typologies.count as string
			
			local nvlle_typo_asString	=	mgr_datas.get_datas_string		nvlle_typo			
			append  m_plug.p_typologies		nvlle_typo_asString
			
			set_typo_active	m_plug.p_typologies[m_plug.p_typologies.count]
			
			analyser_typologies ()
			
			nvlle_typo
			
		),		
		fn	supprimer_typologie	_typo =(
			debug "supprimer_typologie"
			debug "_typo" var:_typo
			local trouve = false
			local i = 1
			while not trouve  do (
				local typo_test	=	get_typo_vide ()
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
			
			
			analyser_typologies ()
			
		),
		fn monter_typologie			_id_typo		=(
			
			local typo_abouger				=	m_typologies[ _id_typo ]
			deleteItem	m_typologies				_id_typo
			insertItem	typo_abouger		m_typologies		(_id_typo - 1) 
			
			local typo_abouger_param	=	m_plug.p_typologies[ _id_typo ]			
			deleteItem	m_plug.p_typologies		_id_typo			
			insertItem	typo_abouger_param		m_plug.p_typologies		(_id_typo - 1) 
			
			analyser_typologies ()
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
			
			analyser_typologies ()
		),
		
		
		fn ouvrir_rollout_typo_selection =(
			
			debug	"ouvrir_rollout_typo_selection"
			include	"$userScripts\\cp-Urba\\modules\\Quartier\\Quartier - rollout - selection Typologie.ms"
			
			createdialog	roll_liste_contours_typo	style:#(#style_titlebar , #style_border ,  #style_sysmenu ,#style_resizing)	--#(#style_titlebar , #style_border ,  #style_sysmenu )
			
			roll_liste_contours_typo.m_plug = m_plug
			roll_liste_contours_typo.m_typo = get_typo_active()
			
			roll_liste_contours_typo.initialiser_listes ()
			roll_liste_contours_typo.actualiser ()
			
		),
		
		
		
		
		
		
		
		
		
		
		
		fn ajouter_batiment_aTypo  		_typo =(
			
			local fichierCible 	=	getopenFileName 		caption:				"Charger" 				\
																	filename:			"$userScripts\cp-Urba\lib\Batiments\\" 		\
																	types:				"Urba_batiment"			\
																	historyCategory:	"bati"
			if findItem _typo.batiments_models	fichierCible	== 0 do
					if fichierCible != undefined do (
						
						---- lecture de donnés dnas le fichier model de batiment ----------
						local stream 	= openFile fichierCible mode:"r"
						local datas 	= readLine  stream			
						close  stream				
						
						local separateur_params 			="¤"
						local separateur_mutation 		= "µ"
						local separateur_items 			= "`"
						
						local params 			= filterString 	datas		separateur_params
						local nbr_etages 	= 0
						local ht_etages 		= 0
						for i = 1 to params.count do (
							local paramStrg = params[i]
							local param 	= filterString paramStrg		separateur_mutation
							if param[1] as string == "etages_nbre" do 
								nbr_etages 		= param[2] as integer
							if param[1] as string == "etages_hauteur_global" do 
								ht_etages 			= param[2] as float
							
						)
						
-- 						local nbr_etages 	= params[ id_param ]
-- 						local array_param 	= filterString data_param		separateur_mutation
						
-- 						debug "nombred'etages" var:nbr_etages
-- 						debug "datas" var:datas
-- 						debug "params" var:params
-- 						for paramStrg in params do (
-- 							local param = filterString paramStrg		separateur_mutation
-- 							debug ">	param" var:param
-- 						)
-- 						debug "param" var:param
						
						
						append _typo.batiments_models					fichierCible
						append _typo.batiments_pourcent				100
						append _typo.batiments_nbr_etages			nbr_etages
						append _typo.batiments_ht_etages				ht_etages
						append _typo.batiments_nbr_etagesPlus		0
				
					)
			
			analyser_typologies ()
			
			
			m_plug.actualiser_rollouts()
			
		),
		
		fn retirer_batiment_aTypo 	_typo		_id_bat	=(
			deleteItem 	_typo.batiments_models		_id_bat
			deleteItem 	_typo.batiments_pourcent		_id_bat
		),
		
		
		
		
		
		
		
		
		fn initialiser_compteur		_typo 		=(
			
			m_nbr_bats_aConstruire = 0.
			m_nbr_bats_construits = 0.
			
			local contours_ids 	=	#()
			if _typo.contours_tout then contours_ids = _typo.contours_index
					else	contours_ids = _typo.contours_groupe
			m_nbr_bats_aConstruire += contours_ids.count
			
		),
		
		fn initialiser_compteur_global 		=(
			
			m_nbr_bats_aConstruire = 0.
			m_nbr_bats_construits = 0.
			
			for typo in m_typologies do (
				local contours_ids 	=	#()
				if typo.contours_tout then contours_ids = typo.contours_index
						else	contours_ids = typo.contours_groupe
				m_nbr_bats_aConstruire += contours_ids.count
			)
			
		),
		
		fn generer_batiment		_id_contour	_typo 	_id_model		=(
			
			local bat 
			
			
			---- si on n'a pas encore de batiment, ou s'il a été supprimer on le créer-------------
			if m_plug.p_batiments[ _id_contour ]  == undefined or isdeleted m_plug.p_batiments[ _id_contour ] 	do (
				
				--- creation du batiment -------------					
				local nv_bat = Urba_Batiment	affiche_asProxy:m_plug.affiche_asProxy	wirecolor:_typo.couleur					
				nv_bat.assigner_shape 		nv_bat		m_plug.p_contours[ _id_contour ]
				m_plug.p_batiments[ _id_contour ] = nv_bat
				append	_typo.batiments_ids		_id_contour
				
				--- gestion du material -------------
				if batiment_mat	==	undefined then (
					batiment_mat = nv_bat.material			
					batiment_mat.name = _typo.nom
				) else 
					nv_bat.material = batiment_mat
				
				enregistrer_typologie		_typo
			)
			
			--- On met a jour le model et les parametre du batiment  -------------
			if _typo.batiments_models.count >= 1 do (
				
				----- choix du model ----------
-- 				local id_model_choisi = _typo.contours_ids_modelBat_choisis[i]
				if _id_model != 0 do (
					local model_choisi = _typo.batiments_models[ _id_model ]
					
					bat 							= 	m_plug.p_batiments[ _id_contour ]					
					bat.affiche_asProxy 		= 	m_plug.affiche_asProxy
					local nbr_etages 		= 	( _typo.batiments_nbr_etages[ _id_model ]	 + random 0 ( _typo.batiments_nbr_etagesPlus[ _id_model ] ) )
-- 						bat.set_etages_nbre	nbr_etages
-- 						bat.etages_nbre 			= 		nbr_etages
-- 						bat.set_etages_ht		_typo.batiments_ht_etages[ id_model_choisi ]
					
					debug "nbr_etages" var:nbr_etages
					
					bat.charger		model_choisi	val_etages_nbre:nbr_etages	 \
															val_etages_ht:(_typo.batiments_ht_etages[ _id_model ])
					
					debug "	bat.etages_nbre" var:	bat.etages_nbre
				)
			)
		
			m_nbr_bats_construits += 1
			
			local pourCent = m_nbr_bats_construits / m_nbr_bats_aConstruire * 100
			progressUpdate pourCent
			
			bat 
			
		),
		
		
		
		m_batiments_mats	=	#(),

		-------- generation des batiments ----------
		fn generer_typologie		_typo 		solo:false	=		with redraw off 		(
			
			m_batiments_mats	=	#()
			
			local chrono_debut 	=	timestamp ()
			if solo do (
				progressStart ( "Création des batiments ..." )
				progressUpdate 0
				initialiser_compteur 	_typo
			)
			
			
			
			
			
			local contours_ids 	=		if _typo.contours_tout 		then 	_typo.contours_index
																					else		_typo.contours_groupe
			for i = 1 to	contours_ids.count/*  where _typo.contours_valides[i]	 */do (		
				
				local id_contour = contours_ids[i]	
				if  _typo.contours_valides[ id_contour ]	do (
					
					local id_model_choisi = _typo.contours_ids_modelBat_choisis[i]					
					local bat = generer_batiment		id_contour		_typo 		id_model_choisi
					
					
					if m_batiments_mats[ id_model_choisi ] == undefined then
						m_batiments_mats[ id_model_choisi ] = bat.material
					else
						bat.material = m_batiments_mats[ id_model_choisi ] 
				)					
			)
			
			if solo do progressEnd() 
			
			
			format "	Typologie '%' généré en % s.\n" 	_typo.nom		( ( timestamp ()	 - chrono_debut ) /1000 )
		),
		
		
		
		
		fn generer_batiments	= with redraw off (
			
			debug "generer_batiments--------" 
			local chrono_debut = timestamp ()
			
			progressStart ( "Création des batiments ..." )
			progressUpdate 0
			
			initialiser_compteur_global ()
			
			for typo in m_typologies do 
				generer_typologie		typo    
				
			local chrono_fin = timestamp ()
			progressEnd() 
			format "Quartier généré en % s.\n" ( ( chrono_fin - chrono_debut ) /1000 )
			
		)
	
	
)	--	fin str_quartier_core



























