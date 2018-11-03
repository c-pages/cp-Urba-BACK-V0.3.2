



include	 "$userScripts\\cp-Urba\\modules\\Commun\\cp - mgr - Shapes.ms" 
	
	
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
	local basculer_editeurFacade, ajouter_facade, retirer_facade, monter_facade, descendre_facade, actualiser_shape
	
	
	
	
	
	
	---- managers ----------
	local mgr_shp 	= str_mgr_shape ()
	local mgr_mesh 	= str_mgr_mesh ()
	
	
	
	
	
	parameters param_etages rollout:roll_etages
	(
		
		------- Etages			------------------
		etages_nbre					type: #integer				default:1			ui:spn_etages_nbres	 		animatable:false		invisibleInTV:true
		etages_hauteur_global		type: #worldUnits 		default:250.	 	ui:spn_etages_hauteur	 	animatable:false		invisibleInTV:true
		
	)
	
	parameters param_surface rollout:roll_surface
	(
		------- Surface		------------------
		surface_node					type:#node 			 	ui:btn_pick_perimetre		animatable:false		invisibleInTV:true
		
	)
	
	
	parameters param_facades rollout:roll_facades
	(
		facades					type:#maxObjectTab	tabSizeVariable:true
		
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
		
		on btn_pick_perimetre picked _node do 	actualiser_shape ()
		
	)	---- fin rollout Surface ---------------------------
	
	
	rollout roll_etages "Etages"
	(
		group "Général" (
			spinner spn_etages_nbres 		"Nombre" 			type:#integer 				range:[0,1000,1]
			spinner spn_etages_hauteur		"Hauteur" 			type:#worldUnits 		range:[0,1e20,0]
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
	
	rollout roll_facades "Facades"
	(
		
		button 		btn_ajouter 		"+"			across:4 --	align:#left
		button 		btn_retirer	 		"-"			
		button 		btn_monter			"/\\"			
		button 		btn_descendre	"\\/"	--align:#right
		
		listBox		lbx_facades		""	height:5
		
-- 		editText 	edTxt_nom		 	"Nom:" 	
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
		
		
		
		fn actualiser =(
			
			
			---- l'affichage des facades -------------------
			local elements_noms 	= #()
			for i = 1 to facades.count do (
				local elem_nom = facades[i].nom
-- 				if est_instance 	id:i 	do elem_nom += " *"
				append elements_noms	( i as string + " |  " + elem_nom )
			)	
			lbx_facades.items 		=  for elem_nom in elements_noms collect elem_nom
			/* 
			--- les parametres de l'element (le subrollout)  ---------------			
			--- on retire les vieux rollouts --------
			if subroll_param.rollouts.count > 0 do 
				for subRoll in subroll_param.rollouts  do
					removeSubRollout subroll_param	subRoll
				 
			---- on ajoute le nouveau -----------------
			if lbx_facades.selection > 0 then (				
				local composant_actif 		=  facades[  lbx_facades.selection ]
				addSubRollout 	subroll_param		composant_actif.roll_parametres
			)
			 */
			---- les boutons ------
			btn_retirer.enabled 				= lbx_facades.selection != 0
			btn_monter.enabled 				= lbx_facades.selection > 1
			btn_descendre.enabled 		= lbx_facades.selection < facades.count and lbx_facades.selection != 0
			
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
	
		
		
		on btn_editer_facade  changed state	do 	basculer_editeurFacade 	state
		
	) --- fin rollout facades-------------------------
	
	
	rollout roll_toiture "Toiture"
	(
		
		
		dropDownList	ddl_toiture		""	 items:#("Sans",  "Terrasse",   "1 pan",   "2 pans",   "x pans" )
		subrollout	subroll_param		""	height:150
		
		dotNetControl btn_resize 	"System.Windows.Forms.Button" 		align:#left /* width:150 */ height:10
		
		fn actualiser = ()
		
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
		
		
	) ----- fin rollout toiture -----------------------
	
	
	
	--- rollout a propos -------------------------
	include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - rollout - A propos.ms" 
	
	
	
	
	
	
	
	
	
	
	
	fn actualiser_shape =(
		if surface_node != undefined do (
			local this_node = (refs.dependents this)[1]
			debug "this_node" var:this_node
			
			this_node.transform	=	surface_node.transform
		)
	)
	
	
	fn actualiser =(
	)
	
	
	
	
	
	--------------- facades ----------------------------------
	fn basculer_editeurFacade 	_etat	=(
		
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
				createDialog		roll_editeur_facade					width:250	height:300	style:#( #style_titlebar , #style_border , #style_sysmenu, #style_resizing) 	lockWidth:true		--facades[ id_facade_select ]
				addSubRollout 	roll_editeur_facade.subroll_param		facades[ id_facade_select ].roll_contraintes
				addSubRollout 	roll_editeur_facade.subroll_param		facades[ id_facade_select ].roll_parametres
			)
			false: destroyDialog  roll_editeur_facade
		)
		
	)
	fn ajouter_facade		 =(
		
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
	fn retirer_facade		_id	 	=(
		
		deleteItem facades 				_id
		
		---- actualisations -----------
		actualiser ()
		
		if roll_facades.open do	(
			roll_facades.lbx_facades.selection -= 1 
			roll_facades.actualiser ()	
		)
		
	)
	fn monter_facade		_id 		=(
		
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
	fn	descendre_facade	_id 		=(
		
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
	
	
	
	
	
	--------------- Passerelle Element Sequence  ----------------------------------
	fn ajouter_element_facade		_element_plug	 =(
		
		local 	id_elem 		= 	roll_facades.lbx_facades.selection
		facades[ id_elem ].ajouter_element_facade		_element_plug	
		
		---- actualisations -----------
		actualiser ()
	)
	fn retirer_element_facade			_id	 			=(
		
		local 	id_elem 		= 	roll_facades.lbx_facades.selection
		facades[ id_elem ].retirer_element_facade		_id
		
		---- actualisations -----------
		actualiser ()

	)
	fn monter_element_facade 		_id 				=(
		
		local 	id_elem 		= 	roll_facades.lbx_facades.selection
		facades[ id_elem ].monter_element_facade		_id
		
		---- actualisations -----------
		actualiser ()

	)
	fn	descendre_element_facade 	_id 				=(
		
		local 	id_elem 		= 	roll_facades.lbx_facades.selection
		facades[ id_elem ].descendre_element_facade		_id
		
		---- actualisations -----------
		actualiser ()

	)
	
	fn renommer_element_facade		_id	_nv_nom =(
		
		local 	id_elem 		= 	roll_facades.lbx_facades.selection
		facades[ id_elem ].renommer_element_facade		_id	_nv_nom
		
		if roll_parametres.open do	roll_parametres.actualiser ()
	)
	
	
	fn dupliquer_element_facade 		id_elem_select:		=(
		
		local 	id_elem		= 	roll_facades.lbx_facades.selection
		facades[ id_elem ].dupliquer_element_facade 	id_elem_select:id_elem_select
		
		---- actualisations -----------
		actualiser ()

	)
	fn instancier_element_facade 	id_elem_select:		=(
		
		local 	id_elem		= 	roll_facades.lbx_facades.selection
		facades[ id_elem ].instancier_element_facade 	id_elem_select:id_elem_select
		
		
		---- actualisations -----------
		actualiser ()

	)
	
	fn rendreUnique_element_facade	 id_elem_select:		=(
		
		local 	id_elem		= 	roll_facades.lbx_facades.selection
		facades[ id_elem ].rendreUnique_element_facade 	id_elem_select:id_elem_select
		
		---- actualisations -----------
		actualiser ()

	)
	
	
	
	
	
	
	
	
	on buildMesh do
	(
		
		--- on vide le mesh ----------
		delete mesh
		
		
		if surface_node != undefined do (
			
			local pts_surface = mgr_shp.scanner_points	surface_node
			
-- 			debug"pts_surface" var:pts_surface
			
			for i = 1 to pts_surface.count do (
				local pt 			= pts_surface[i]
				local pt_suivant 	= if i != pts_surface.count then pts_surface[i + 1] else pts_surface[1] 
				if facades.count >0 then (
					local compo_facade		=	copy	facades[1]
					compo_facade.longueur	=	distance	pt	pt_suivant
					compo_facade.hauteur	=	etages_hauteur_global
					
					local angle_facade 		=	mgr_shp.get_angle_oriente 	(pt_suivant - pt )
					local transf_facade 		= rotateZmatrix	angle_facade	*	transMatrix pt
					
					mgr_mesh.attacher		mesh		compo_facade	transf:transf_facade
					
				) else (
					
					local compo_planV		=	createInstance	cp_prim_planVertical
					compo_planV.longueur	=	distance	pt	pt_suivant
					compo_planV.hauteur	=	etages_hauteur_global
					
					local angle_facade 		=	mgr_shp.get_angle_oriente 	(pt_suivant - pt )
					local transf_facade 		= rotateZmatrix	angle_facade	*	transMatrix pt
					
					mgr_mesh.attacher		mesh		compo_planV	transf:transf_facade
					
				)
			)
			
			
			
		) --- fin if surface ---------------------
		
		
		
	) --------- fin on build mesh --------------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	tool create
	(
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
	
	
	
	on update do (
		
		mgr_shp 	= str_mgr_shape ()
		mgr_mesh 	= str_mgr_mesh ()
	)
	
) --------- fin plugin -------------------------------------------------------------------------------------------


