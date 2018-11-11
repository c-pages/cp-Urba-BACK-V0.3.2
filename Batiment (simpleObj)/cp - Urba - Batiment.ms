



	
---- fonction pour affichage viewport -----------
global 	urba_fn_afficheur_longueurs





plugin simpleObject		cp_batiment
name:"Bâtiment"
classID:#(0x3ae67906, 0x740a62d7)
category:"CP | Urba temp"
-- invisible:true
(
	
	
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_batiment"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local basculer_editeurFacade, ajouter_facade, retirer_facade, monter_facade, descendre_facade, renommer_facade, actualiser_shape
	local afficher_longueurs
	
	local definir_toiture
	
	----- les points de la surface------------------------
	local pts_surface
	
	
	---- managers ----------
	local mgr_shp 	= str_mgr_shape ()
	local mgr_mesh 	= str_mgr_mesh ()
	
	
	
	parameters param_etages rollout:roll_etages	(
		
		------- Etages			------------------
		etages_nbre					type: #integer				default:1			ui:spn_etages_nbres	 				animatable:false		invisibleInTV:true
		etages_hauteur_global		type: #worldUnits 		default:250.	 	ui:spn_etages_hauteur	 			animatable:false		invisibleInTV:true
		
		dalle_epaisseur				type: #worldUnits 		default:20.	 		ui:spn_dalle_epaisseur	 			animatable:false		invisibleInTV:true
		soubassement_hauteur		type: #worldUnits 		default:100.	 	ui:spn_soubassement_hauteur	animatable:false		invisibleInTV:true
	)
	
	parameters param_surface rollout:roll_surface	(
		------- Surface		------------------
		surface_node					type:#node 			 	ui:btn_pick_perimetre		animatable:false		invisibleInTV:true
		
		------- Optimisations		------------------
		optim_aplanir					type:#boolean			default:true		ui:chk_aplanir		animatable:false		invisibleInTV:true
		optim_souder					type:#boolean			default:true		ui:chk_souder		animatable:false		invisibleInTV:true
		optim_orthonormer			type:#boolean			default:false		ui:chk_ortho			animatable:false		invisibleInTV:true
		optim_aligner					type:#boolean			default:false		ui:chk_aligner		animatable:false		invisibleInTV:true
		optim_projeter					type:#boolean			default:false		ui:chk_projeter		animatable:false		invisibleInTV:true
		
		------- Seuils		------------------
		optim_aplanir_seuil			type:#float				default:20.			ui:spn_aplanir		animatable:false		invisibleInTV:true
		optim_souder_seuil			type:#float				default:30.			ui:spn_souder		animatable:false		invisibleInTV:true
		optim_ortho_seuil				type:#float				default:100.		ui:spn_ortho		animatable:false		invisibleInTV:true
		optim_aligner_seuil			type:#float				default:50.			ui:spn_aligner		animatable:false		invisibleInTV:true
		
	)
	
	
	parameters param_facades rollout:roll_facades	(
		facades					type:#maxObjectTab	tabSizeVariable:true
		
		affichage_longueurs		type:#boolean 		ui:ckb_afficher_longueur				default:false
	)
	
	parameters params_divers rollout:roll_divers	(
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	
	parameters params_hasard rollout:roll_hasard	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	parameters param_toiture  rollout:roll_toiture (		
		toiture_type				type:#integer 			ui:ddl_toiture_type		default:1
		toiture						type:#maxObject	
		
		on toiture_type set val do definir_toiture		toiture_type
	)
	
	
	
	
	
	
	
	----------------- Rollouts -------------------------------------------------------------------
	rollout roll_presets 			"Presets" 		rolledUp:true		(


		button btn_enregistrer "Enregistrer" pos:[88,2] width:85 height:16 align:#left
		button btn_charger 	"Charger" 		pos:[5,2] width:85 height:16 align:#left
		button btn_coller 		"Coller" 		pos:[88,17] width:85 height:16 align:#left
		button btn_copier 		"Copier" 		pos:[5,17] width:85 height:16 align:#left
/* 
		fn actualiser =(
			btn_coller.enabled 			= urba_clipboard_batiment != ""
		)

		on roll_presets open do actualiser ()
		on btn_copier pressed do	(
			core.preset_copier ()
				actualiser()
			)
		on btn_coller pressed do	(
			core.preset_coller ()
				actualiser()
			)
		on btn_enregistrer pressed do
			core.preset_enregistrer ()
		on btn_charger pressed do
			core.preset_charger ()
 */
	) 	---- fin rollout Presets ---------------------------
	
	rollout roll_surface "Surface" (
		
		fn shape_filt 		obj = superclassof obj == shape
		--- Surface ------
		pickbutton btn_pick_perimetre "Pick shape"  width:160 height:20 filter:shape_filt	autoDisplay:true-- align:#left
		
		group "Optimiser" (
			
			checkbox 	chk_souder 	"Souder" 		across:2
			spinner 	spn_souder 	"" range:[0,10000,0] type:#worldUnits	width:60	align:#right
			
			checkbox 	chk_ortho 		"Orthonorm." 		across:2
			spinner 	spn_ortho 		"" range:[0,100,0] type:#float 	width:60	align:#right
			
			checkbox 	chk_aplanir 	"Aplanir" 	across:2
			spinner 	spn_aplanir 	""  range:[0,40,0] 	width:60	align:#right
			

			checkbox 	chk_aligner 	"Aligner"	across:2
			spinner 	spn_aligner 	""  range:[0,100,0] 	width:60	align:#right

			checkbox 	chk_projeter 	"Projeter"  
		)
		
-- 		on btn_pick_perimetre picked _node do 	actualiser_shape ()
		
	)	---- fin rollout Surface ---------------------------
	
	
	rollout roll_etages "Etages"	(
		group "Général" (
			spinner spn_etages_nbres 		"Nombre" 			type:#integer 				range:[0,1000,1]
			spinner spn_etages_hauteur		"Hauteur" 			type:#worldUnits 		range:[0,1e20,0]
			
			spinner spn_dalle_epaisseur				"Epaisseur dalle" 			type:#worldUnits 		range:[0,1e20,0]
			spinner spn_soubassement_hauteur	"Soubassement" 			type:#worldUnits 		range:[0,1e20,0]
			
	
		)
		group "Etages spécifiques" (	
			
			button 	btn_etages_nouveau "Nouv." width:35 height:16 toolTip:"Ajouter	étages spécifiques" across:2
			button 	btn_etages_supprimer "Sup."  width:35 height:16 toolTip:"Supprimer étages spécifiques"
			listbox	lbx_etages_specifiques ""  height:4
			
			label				lbl_etage_specifiques 		"Etages :"  width:45 height:19  across:4		align:#left
			spinner 		spn_etageMin_specifiques 	""  width:40 height:16 range:[0,1e+13,0] type:#integer scale:1 
			checkbutton 	ckb_etageMax_specifiques ">"  width:16 height:16 
			spinner 		spn_etageMax_specifiques "" width:40 height:16 range:[0,1e+13,0] type:#integer	align:#right
			label				lbl_hauteur_specifiques 	"Hauteur :"  width:55 height:22	across:2	align:#left
			spinner 		spn_hauteur_specifiques "" width:92 height:16 range:[0,1e+13,0] type:#worldunits 	align:#right
			
		)
	)	---- fin rollout etages ---------------------------
	
	rollout roll_facades "Facades"	(
		
		button 		btn_ajouter 		"+"			across:4 --	align:#left
		button 		btn_retirer	 		"-"			
		button 		btn_monter			"/\\"			
		button 		btn_descendre	"\\/"	--align:#right
		
		listBox		lbx_facades		""	height:5
		group "afficher" (
		checkButton	ckb_afficher_longueur	"Longueurs"
		)
		editText 	edTxt_nom		 	"" 	
		
		
		on ckb_afficher_longueur changed state do 
			afficher_longueurs state
		/* 
		group "Contraintes" (
			
			label 		lbl_contrainte_etages 			"Etages :"   height:15 align:#left 
			checkbox 	chk_contrainte_etages 			"Minimum"   			height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left		across:2
			spinner 	spn_contrainte_etages 			"" 				width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#right
			checkbox 	chk_contrainte_etagesMax 	"Maximum"  			height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left	across:2
			spinner 	spn_contrainte_etagesMax 	""  			width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#right
			
			label lbl_vide_1 ""
			
			label 		lbl_contrainte_longueur 			"Longeur:" width:52 height:15 align:#left			
			checkbox 	chk_contrainte_longueur_min 	"Minimum" 				height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left	across:2
			spinner 	spn_contrainte_longueur_min 	""  	width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#right
			checkbox 	chk_contrainte_longueur_max 	"Maximum"  			height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left	across:2
			spinner 	spn_contrainte_longueur_max		"" 	width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#right
			
			label lbl_vide_2 ""
			
			label lbl_contrainte_murs 			"Murs:" 	width:32 height:15 align:#left
			checkbutton ckb_mur_nord 		"Nord"  	width:40 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left	across:4
			checkbutton ckb_mur_sud 		"Sud"  	width:40 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			checkbutton ckb_mur_est 		"Est" 		width:40 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			checkbutton ckb_mur_ouest 	"Ouest"  width:40 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			
			dropdownList ddl_contrainte_murs ""  	height:21 selection:3 align:#left
			
		) */
		
		checkbutton		btn_editer_facade		"Editer"	width:160 height:25
		
		subrollout	subroll_contraintes		""	height:250	
		
		
		fn actualiser =(
			
			
			---- l'affichage des facades -------------------
			local elements_noms 	= #()
			for i = 1 to facades.count do (
				local elem_nom = facades[i].nom
-- 				if est_instance 	id:i 	do elem_nom += " *"
				append elements_noms	( i as string + " |  " + elem_nom )
			)	
			lbx_facades.items 		=  for elem_nom in elements_noms collect elem_nom
				
			
-- 			addSubRollout 	roll_editeur_facade.subroll_contraintes		facades[ id_facade_select ].roll_contraintes
			
			--- les parametres de l'element (le subrollout)  ---------------			
			--- on retire les vieux rollouts --------
			if subroll_contraintes.rollouts.count > 0 do 
				for subRoll in subroll_contraintes.rollouts  do
					removeSubRollout subroll_contraintes	subRoll
				
			local composant_actif 	
			---- on ajoute le nouveau -----------------
			if lbx_facades.selection > 0 then (				
				composant_actif 		=  facades[  lbx_facades.selection ]
				addSubRollout 	subroll_contraintes		composant_actif.roll_contraintes
			)
			
			---- les boutons ------
			btn_retirer.enabled 				= lbx_facades.selection != 0
			btn_monter.enabled 				= lbx_facades.selection > 1
			btn_descendre.enabled 		= lbx_facades.selection < facades.count and lbx_facades.selection != 0
			
			edTxt_nom.enabled 				= lbx_facades.selection != 0
			edTxt_nom.text	 				= if lbx_facades.selection != 0	then	composant_actif.nom	else ""
			
			btn_editer_facade.enabled 	= lbx_facades.selection != 0
			
			
		) --- fin actualiser -----------
		
		
		on roll_facades	open do actualiser ()
		
		
		----- Facades -----------------
		on lbx_facades 		selected sel 	do	actualiser ()		
		on lbx_facades	 rightClick 	_id 	do	(
			lbx_facades.selection = _id
			actualiser ()
-- 			creer_RCM_edition ()
			
		)
		on btn_ajouter 		pressed 			do 	ajouter_facade ()
		on btn_retirer 		pressed 			do	retirer_facade			lbx_facades.selection 
		on btn_monter 		pressed 			do	monter_facade		lbx_facades.selection 
		on btn_descendre 	pressed		 	do	descendre_facade	lbx_facades.selection 
	
		on edTxt_nom entered txt 			do 	renommer_facade		lbx_facades.selection 	txt
		
		on btn_editer_facade  changed state	do 	basculer_editeurFacade 	state
		
	) --- fin rollout facades-------------------------
	
	
	rollout roll_toiture "Toiture"	(
		
		
		dropDownList	ddl_toiture_type		""	 items:#("Sans",  "Terrasse",   "1 pan",   "2 pans",   "n pans" )
		subrollout			subroll_param			""	height:150
		
		dotNetControl 	btn_resize 	"System.Windows.Forms.Button" 		align:#left /* width:150 */ height:10
		
		fn actualiser = (
			
			--- les parametres de l'element (le subrollout)  ---------------			
			--- on retire les vieux rollouts --------
			if subroll_param.rollouts.count > 0 do 
				for subRoll in subroll_param.rollouts  do
					removeSubRollout subroll_param	subRoll
				
			local composant_actif 	
			---- on ajoute le nouveau -----------------
			if ddl_toiture_type.selection > 1 then (
				addSubRollout 	subroll_param		toiture.roll_general
			)
			
			
		)
		
		----- Gestion du resize du subRollout -----------------------
		local resize_enCours 			= false
		local pos_initial					=	[0,0]
		local subRoll_hauteur_init		=	0
		local btnResize_pos_init		=	[0,0]
		local roll_hauteur_init			=	[0,0]
		fn resize_surbRoll =(
			if resize_enCours do (
				local mouse_pos 			= mouse.posUnscaled
				local changement_ht 	= mouse_pos.y - pos_initial.y
				local subRoll_nvl_ht 	= subRoll_hauteur_init 		+ 	changement_ht
				
				if subRoll_nvl_ht >	50 do (
					subroll_param.height		=	subRoll_nvl_ht
					btn_resize.pos.y			=	btnResize_pos_init.y		+	changement_ht
					roll_toiture.height	=	roll_hauteur_init 	+ 	changement_ht
				)
			)
		)
		
		
		
		on roll_toiture		open 				do 	(
			actualiser ()
			
			---- le bouton resize -----------------------
			btn_resize.FlatStyle	=		(dotNetClass "System.Windows.Forms.FlatStyle").flat	
			btn_resize.BackColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			btn_resize.ForeColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
		)
		
		
		
		------------ le bouton resize -----------------------
		on	btn_resize	MouseDown 	do (
			resize_enCours 				= true
			pos_initial						=	mouse.posUnscaled
			subRoll_hauteur_init			= 	subroll_param.height
			btnResize_pos_init			=	btn_resize.pos
			roll_hauteur_init				=	roll_toiture.height
		)
		on	btn_resize	MouseUp 		do	resize_enCours = false		
		on	btn_resize	MouseMove 	do 	resize_surbRoll ()
		on	btn_resize	MouseLeave 	do	resize_enCours = false		
		
		on 	ddl_toiture_type		selected val		do actualiser()
	) ----- fin rollout toiture -----------------------
	
	
	rollout roll_divers  "Divers"	(
		 group "Qualité" (
			checkbox	shk_lowPoly			"Low poly" 		
		) 
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
			spinner spn_matId_huisserie 	"Huisserie" 				type:#integer range:[1,1000,1]
			spinner spn_matId_mur 			"Mur" 					type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	rollout roll_hasard  "Hasard"	(
		
		spinner spn_hasard_seed 			"Seed" 					type:#integer		 range:[0,1e20,0]
		
		group "Fenetres" (
			spinner spn_fen_proba_ouv 		"Proba (%)" 			type:#float			 range:[0,100,0]
			spinner spn_fen_ouvMax 			"Max (°)" 		type:#float			 range:[0,180,0]
		)
	
	)
	
	
	
	--- rollout a propos -------------------------
	include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - rollout - A propos.ms" 
	
	
	
	
	
	
	
	
	
	
	-------------- divers -------------------------
	fn initialiser =(
		mgr_shp 	= str_mgr_shape ()
		mgr_mesh 	= str_mgr_mesh ()
	)
	
	
	fn actualiser_shape =(
		if surface_node != undefined then (
			
			---- on place le batiment sur le shape ----------
			local this_node 		= (refs.dependents this)[1]
-- 			this_node.rotation	=	surface_node.rotation
-- 			this_node.pos			=	surface_node.pos
			
			this_node.transform	=	surface_node.transform
			
			----- on scanne le shape ---------
			pts_surface = mgr_shp.scanner_points	surface_node
			
			
			--- on gere les OPTIMISATIONS  ----
			if optim_souder			do	mgr_shp.souder				&pts_surface		optim_souder_seuil
			if optim_orthonormer	do	mgr_shp.orthonormer		&pts_surface		optim_ortho_seuil
			if optim_aplanir			do	mgr_shp.aplanir				&pts_surface		optim_aplanir_seuil
			if optim_aligner			do	mgr_shp.aligner				&pts_surface		optim_aligner_seuil
			if optim_projeter			do	mgr_shp.projeter				&pts_surface
			
			
			
		) else (
			pts_surface =#()
		)
	)--- fin actualisr shape ---------------

	fn actualiser =(
-- 		corriger_parametres ()		
-- 		actualiser_composants()		
		if roll_facades.open do	roll_facades.actualiser ()		
		redrawViews ()
	)
	
	--------- viewport --------------------------------------------------------------------------	
	fn fn_afficheur_longueurs =(
		
		gw.setTransform (matrix3 1)
		
		if selection.count == 1 and classof $ == cp_batiment do (
			local nd	 = $
			
-- 			local bat 				= nd.core.get_bat_edition ()
-- 			
-- 			if bat != undefined do (
-- 			local fcd				= nd.core.get_facade_enEdition 	()
			
			local surface_pts 	= 	nd.pts_surface
			
				
			local ptID = 0 
			while ptID <  surface_pts.count do (
				ptID += 1
				
				local ptID_suivant = ptID + 1
				if ptID_suivant > surface_pts.count do ptID_suivant = 1
					
				local vec_sousBassmt		=	[0,0,1] * nd.soubassement_hauteur
				local vec_dalle				=	[0,0,1] * nd.dalle_epaisseur
				local vec_decallage			=	[0,0,1] * 50

				local pt 						= surface_pts[ptID] 	*  nd.transform 
				local pt_suivant 			= surface_pts[ptID_suivant] *  nd.transform  
				local longueur_facade 	= ( (floor ( ( distance pt pt_suivant ) * 10 ) ) / 10 )
				local txt_affichage 		= "  " + longueur_facade as string + " cm"
				
				local col_valid 			= yellow
				local col_nonValid 	= [ 100, 100 , 100 ]
				local col_divers 		= white
				
				---- les longueurs------
				local color_affichage 	 = col_divers
				local longueur_valid 	= true
				if fcd != undefined do			(
					
					local lg_min_fcd = amax #(  fcd.params.longueurMin , fcd.params.get_longueur () )
					
					if longueur_facade < lg_min_fcd do
						longueur_valid = false
					
					if fcd.params.longueurMax_use and longueur_facade >  fcd.params.longueurMax do
						longueur_valid = false
				)
				if longueur_valid then (
					color_affichage 	 = col_valid
					gw.setColor	#line		col_valid
				) else (
					color_affichage 	 = col_nonValid
					gw.setColor	#line		col_nonValid
				)
				
				
				local vec_affichage_lgs = 	vec_sousBassmt 	+ vec_dalle + vec_decallage
				local pt_milieu_facade 	= ( (pt + pt_suivant) /2 )  - vec_affichage_lgs
				gw.polyline #( pt - vec_affichage_lgs , pt_suivant - vec_affichage_lgs )	false
-- 						gw.Marker 	( pt - vec_affichage_lgs  )		#xMarker   color:color_affichage
				gw.Marker pt_milieu_facade		#smallCircle   color:color_affichage
				gw.text 	( pt_milieu_facade	 /* - [0,0,100] */ )	txt_affichage  	color:color_affichage
				
			
			)
		
		)
		gw.updateScreen() 
	)
	fn afficher_longueurs 	state	=(
		
-- 		if urba_fn_afficheur_longueurs  == undefined do 	
		
		unregisterRedrawViewsCallback 					urba_fn_afficheur_longueurs
		
			urba_fn_afficheur_longueurs	= fn_afficheur_longueurs
		
		case state of (
			true:		registerRedrawViewsCallback 		urba_fn_afficheur_longueurs 	
			false:	unregisterRedrawViewsCallback 		urba_fn_afficheur_longueurs
		)
		redrawviews ()
	)
	
	
	--------------- facades ----------------------------------
	fn basculer_editeurFacade 	_etat			=(
		
		rollout roll_editeur_facade "Facade" (
			
			subrollout	subroll_param		""	/* width:350 */	height:300	
			
			fn resize_rollout	=(
				subroll_param.height	=	roll_editeur_facade.height - 5
			)
			on roll_editeur_facade	open do resize_rollout  ()
			on roll_editeur_facade	resized val do resize_rollout  ()
		)
		
		
		local	id_facade_select 	= 	roll_facades.lbx_facades.selection
		
		case _etat of (
			true: (
				createDialog		roll_editeur_facade					width:250	height:700	style:#( #style_titlebar , #style_border , #style_sysmenu, #style_resizing) 	lockWidth:true		--facades[ id_facade_select ]
				
				addSubRollout 	roll_editeur_facade.subroll_param		facades[ id_facade_select ].roll_parametres
			)
			false: destroyDialog  roll_editeur_facade
		)
		
	)
	fn ajouter_facade					 			=(
		
		local	id_elem_select 	= 	roll_facades.lbx_facades.selection
		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_facade		= createinstance		batiment_composant_facade
		
		if id_elem_select != 0 and id_elem_select	!= facades.count	then	
			insertItem nvl_facade					facades 					id_elem_insert
		else		
			append facades						nvl_facade
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection = id_elem_insert 
			roll_facades.actualiser ()	
		)
		
	)
	fn retirer_facade			_id	 				=(
		
		deleteItem facades 				_id
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection -= 1 
			roll_facades.actualiser ()	
		)
		
	)
	fn monter_facade		_id 					=(
		
		local elem_temp 		= facades[ _id ]
		deleteItem 	facades 				_id
		insertItem 	elem_temp			facades  					(	_id - 1 )
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection -=  1
			roll_facades.actualiser ()	
		)
	)
	fn	descendre_facade	_id 					=(
		
		local elem_temp 		= facades[ _id ]
		deleteItem 	facades 				_id
		if _id == facades.count then 
			append facades 				elem_temp
		else 
			insertItem 	elem_temp		facades  					(	_id + 1 )
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection +=  1
			roll_facades.actualiser ()	
		)
	)
	fn renommer_facade 	_id 	_nv_nom	=(
		facades[ _id ].nom = _nv_nom
		---- actualisations -----------
		actualiser ()
	)
	
	
	fn definir_toiture		_id_type 	=(
-- 		debug "definir_toiture" var:_id_type
		case _id_type of (
			1:		toiture		=	undefined
			5:		toiture 		= createInstance		batiment_composant_toiture_nPans
		)
-- 		debug "toiture" var:toiture
	)
	
	----- gestion des facades ----------------------------------------------------
	fn get_facades_pourMur		_id_pt	 =(
		
		local result		= #()
		
		local etages_aRemplir	= #{1..etages_nbre + 1}
		
		local pt 			= pts_surface[ _id_pt ]
		local pt_suivant 	= if _id_pt != pts_surface.count then pts_surface[ _id_pt + 1 ] else pts_surface[ 1 ]
		
		---- Pour chaque etages------------------
		for etage_courant = 0 to etages_nbre do (
			local facade_trouve 			= false
			local facade_pasDeResultat	=	facades.count == 0
			local id_facade = 1
			while not facade_trouve	and not facade_pasDeResultat  do (
				
				local facade_aTester = copy facades[ id_facade ]
				
				if facade_aTester.est_valide		pt		pt_suivant		etage_courant 		etages_nbre		then (
				
					facade_aTester.longueur			=	distance	pt	pt_suivant
					facade_aTester.hauteur			=	etages_hauteur_global
					facade_aTester.low_poly			=	low_poly
					facade_aTester.fen_ouvMax		=	fen_ouvMax
					facade_aTester.fen_proba_ouv	=	fen_proba_ouv
					
					facade_aTester.matId_menuis	=	matId_menuis
					facade_aTester.matId_vitrage	=	matId_vitrage
					facade_aTester.matId_huisserie	=	matId_huisserie
					facade_aTester.matId_mur		=	matId_mur
					
					
					append 	result		facade_aTester
					facade_trouve = true
					
				)
				
				id_facade +=1
				if id_facade > facades.count and not facade_trouve  do
					facade_pasDeResultat = true
				
			)
			
			if facade_pasDeResultat do (
				
				local compo_planV		=	createInstance	cp_prim_planVertical
				compo_planV.longueur	=	distance	pt	pt_suivant
				compo_planV.hauteur	=	etages_hauteur_global
				compo_planV.matId		=	matId_mur
				
				append 	result		compo_planV
				
			)
		) 
		
		result
		
	) ---- fin choisir facade ------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	------------  Construction du mesh --------------------------
	on buildMesh do	(
		
-- 		debug "buildMesh"
		
		
		local chrono_debut = timestamp ()
		
		seed	hasard_seed
		
		--- on vide le mesh ----------
		delete mesh
		
		---- si on a une surface ----------------------
		if surface_node != undefined do (
			
			actualiser_shape ()		
			
			
			
			
			
			
			
			
			----- 1 ) les Facades ----------------------------------------------------------------------------------------------------------------------
			---- Pour chaque segment de la surface ----------------------------
			for i = 1 to pts_surface.count do (
				
				local pt 			= pts_surface[i]
				local pt_suivant 	= if i != pts_surface.count then pts_surface[i + 1] else pts_surface[1]
				
				local angle_facade 		=	mgr_shp.get_angle_oriente 	(pt_suivant - pt )
				local transf_facade 		= rotateZmatrix	angle_facade	*	transMatrix pt
				
				
				
				
				---- le soubassement --------
				local compo_planV		=	createInstance	cp_prim_planVertical
				compo_planV.longueur	=	distance	pt	pt_suivant
				compo_planV.hauteur	=	soubassement_hauteur				
				compo_planV.matId		=	matId_mur
				mgr_mesh.attacher		mesh		compo_planV	transf:( transf_facade * transMatrix [0,0, -(soubassement_hauteur + dalle_epaisseur ) ] )
/* 
				---- l'epaisseur de la dalle RdC --------
				local compo_planV		=	createInstance	cp_prim_planVertical
				compo_planV.longueur	=	distance	pt	pt_suivant
				compo_planV.hauteur	=	dalle_epaisseur				
				compo_planV.matId		=	matId_mur
				mgr_mesh.attacher		mesh		compo_planV	transf:( transf_facade * transMatrix [0,0, - dalle_epaisseur  ] )

				 */
				
				
				
				
				----- les facades ---------------------
				local depose_etage 				= 	transf_facade* transMatrix [0,0, -dalle_epaisseur  ]
				local facades_murCourant		=	get_facades_pourMur	i	
				for i = 1 to facades_murCourant.count do (
					
					
					
					---- l'epaisseur de la dalle --------
					local compo_planV		=	createInstance	cp_prim_planVertical
					compo_planV.longueur	=	distance	pt	pt_suivant
					compo_planV.hauteur	=	dalle_epaisseur		
					compo_planV.matId		=	matId_mur		
					mgr_mesh.attacher		mesh		compo_planV	transf:depose_etage
					
					---- maj depose-----
					depose_etage *= transMatrix [0,0,dalle_epaisseur]
					
					
					
					
					---- la facade ----
					local fcd 				= facades_murCourant[i]
					mgr_mesh.attacher		mesh		fcd	transf:depose_etage
					
					---- maj depose-----
					depose_etage 		*=  transMatrix [0,0,  etages_hauteur_global ]
					
					
					
					
				)				
			)
			
			----- 2 ) la toiture ----------------------------------------------------------------------------------------------------------------------
			local pts_toiture 	= deepcopy pts_surface
			pts_toiture.z 		+=  ( etages_nbre	+ 1 ) *	etages_hauteur_global	+ (etages_nbre  ) * dalle_epaisseur	
			
			
			
			case toiture_type of (
				
				1: (	-----Aucune-----------------------------
					
					
					local vert_debut 	=	 getNumVerts mesh + 1
					local vert_fin 		=	getNumVerts mesh  + pts_toiture.count
					
					meshop.setNumVerts  mesh 	vert_fin
					
					for i = 1 to pts_toiture.count do (
						local i_vert = vert_debut - 1 + i
						setVert mesh 	i_vert 		pts_toiture[ i ]
					)
					local verts_toiture = #{vert_debut..vert_fin} as array
					meshop.createPolygon  mesh verts_toiture 	smGroup:1 	matID:matId_mur
					
				)
					
				5:(	---------- n pans ----------------------
				
					local compo_toiture = copy toiture
					compo_toiture.set_points		pts_toiture
					mgr_mesh.attacher		mesh		compo_toiture	
					
				)
				
				
			) ---- fin case toiture_type	-------
			
			
			
			
		) --- fin if surface ---------------------
		
		local chrono_fin = timeStamp()
-- 		debug  "build mesh " var:( ((chrono_fin - chrono_debut) / 1000.0) as string + "s.")
		
	) --------- fin on build mesh --------------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	tool create	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	
						nodeTM.translation = gridPoint
						#stop
				)
			)
		
	) ----- fin tool create -------------
	
	
	on update 	do initialiser ()
	on create  	do initialiser ()
	on load  	do initialiser ()
	
) --------- fin plugin -------------------------------------------------------------------------------------------


