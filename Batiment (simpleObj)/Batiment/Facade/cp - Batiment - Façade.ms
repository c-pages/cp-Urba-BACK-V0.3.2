
plugin simpleObject		batiment_composant_facade
name:"Façade"
classID:#(0x52a049eb, 0xc56c437)
category:"CP | Bâtiment	| Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="batiment_composant_facade"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	local roll_parametres_element
	
	---- fonctions	-----------
	local corriger_parametres , 		actualiser_composants 
	local	ajouter_element_facade, 	retirer_element_facade, 	dupliquer_element_facade, instancier_element_facade, rendreUnique_element_facade, monter_element_facade, descendre_element_facade, renommer_element_facade, ouvrir_parametres
	local inserer_element
	local est_instance, est_unBalcon
	
	---- la sequence à construire issue de la sequence	------------------------
	local sequence_aConstruire
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	
	
	
	parameters params_general 		rollout:roll_general		(
		
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 					default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur				default:10.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 					default:0.
		
	)
	parameters params_sequence 		rollout:roll_parametres	(
		
		repartition					type:#integer					ui:ddl_repartition			default:1
		repart_nombre				type:#integer					ui:spn_repetitions		default:1
		repart_decallage			type:#worldUnits				ui:spn_decallage			default:0.
		repart_espacement		type:#worldUnits				ui:spn_espacement		default:0.
		
		sequence					type:#maxObjectTab		tabSizeVariable:true
		
	)
	parameters params_divers 			rollout:roll_divers			(
		
		nom	 							type:#string 			default:"Facade"
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	parameters params_contraintes 	rollout:roll_contraintes	(
		
		etages_min_use		type:#boolean 		ui:chk_etages_min			default:false
		etages_min				type:#integer			ui:spn_etages_min			default:0
		etages_max_use		type:#boolean 		ui:chk_etages_max			default:false
		etages_max				type:#integer			ui:spn_etages_max			default:0
		
		longueur_min_use		type:#boolean 		ui:chk_longueur_min			default:false
		longueur_min			type:#integer			ui:spn_longueur_min			default:0
		longueur_max_use		type:#boolean 		ui:chk_longueur_max			default:false
		longueur_max			type:#integer			ui:spn_longueur_max			default:0
		
		mur_nord			type:#boolean 		ui:ckb_mur_nord			default:false
		mur_sud			type:#boolean 		ui:ckb_mur_sud			default:false
		mur_est			type:#boolean 		ui:ckb_mur_est				default:false
		mur_ouest		type:#boolean 		ui:ckb_mur_ouest			default:false
		
		murs				type:#integer			ui:ddl_murs					default:1
		
	)
	parameters params_hasard 			rollout:roll_hasard		(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	
	
	rollout roll_general 						"Paramètres"	(
		
		spinner spn_longueur 				"longueur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_hauteur 				"Hauteur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_profondeur 			"Profondeur" 			type:#worldunits range:[0,1e20,0]
		
	)
	rollout roll_parametres  				"Façade"		(
	
		------------ TRee view -----------------------------
		local m_dragDropEffect		=dotNetClass "System.Windows.Forms.DragDropEffects"		
		local tv_imageList 			= dotNetObject "System.Windows.Forms.ImageList"
		
		
		
		
		--- UI ----------------------------------------------------------------------------------------------
		group "Répartition" (
			dropDownList	ddl_repartition		""	 items:#(	"Répartir",  /* "Répéter", */	"Centrer",	"Aligner à gauche",	"Aligner à droite"		/*,   "Etirer"  */	)	/* width:95	 */align:#left--	across:2
			
			spinner spn_repetitions 		"Nombre" 		/* width:50	 */		type:#integer 			range:[0,1000,1]			align:#right
			spinner spn_decallage		 	"Décallage" 	/* 	width:80	 */		type:#worldunits 	range:[-1e20,1e20,0]	align:#right
			spinner spn_espacement		"Espacement" 	/* 	width:80	 */		type:#worldunits 	range:[-1e20,1e20,0]	align:#right
			
		)
		group "Séquence" (
			
			button 		btn_ajouter_mur 			"Mur"			width:50		height:17		across:3		align:#left
			button 		btn_ajouter_poteau 		"Poteau"			width:50		height:17		align:#left	enabled:false
			button 		btn_ajouter_chainage 		"Chainage"		width:50	height:17			align:#left		enabled:false
			
-- 			label			lbl_baies	"Baies:"	align:#left
			button 		btn_ajouter_fenetre 		"Fenêtre"		width:50		height:17	align:#left	/* enabled:false */	across:3		
			button 		btn_ajouter_porte 	"Porte"			width:50		height:17		align:#left		/* enabled:false */
			button 		btn_ajouter_ensemble 		"Ens. men."				width:50	height:17			align:#left
			
-- 			label			lbl_divers	"Divers:"	align:#left
			button 		btn_ajouter_balcon 	"Balcon"			width:50		height:17		align:#left		across:3	
			button 		btn_ajouter_corniche 	"Corniche"			width:50	height:17			align:#left		enabled:false
			button 		btn_ajouter_porche 	"Porche"			width:50		height:17		align:#left		enabled:false
			
			button 		btn_ajouter_groupe 	"Groupe"			width:50		height:17		align:#left		across:3	
			button 		btn_ajouter_vide1 	""			width:50	height:17			align:#left		enabled:false
			button 		btn_ajouter_vide2 	""			width:50		height:17		align:#left		enabled:false
			
			dotNetControl tv_sequence	 "treeview" /* width:145 */ height:360 --align:#left
			
			button 		btn_dupliquer	 		"Dup."			width:27	height:17	across:4	align:#center
			button 		btn_instancier	 		"Ins."				width:27	height:17			align:#center
			button 		btn_rendreUnique	 	"Uni."				width:27	height:17			align:#center
			button 		btn_retirer	 			"Sup."			width:27	height:17			align:#center
			
		
		)
		
		
		---------- Treeview -----------------------------------------------------------------------------
		local id_element_enDrag	=	0
		local id_element_destination	=	0		
		local elementParent_enDrag
		local element_enDrag
		local node_enDrag
		
		fn vider_tv = (
			tv_sequence.Nodes.Clear()
		)
		
		
		
		
		
		---------------- Accessions ----------------------------------------------
		
		fn get_element_parent  	_noeud	=(
			
			local element_parent
			if _noeud.level > 0 do (
				local noeud_root		=	_noeud
				local index_noeuds	=	#()
				for i = 0	to _noeud.level - 1	do	(
					insertItem	( noeud_root.index + 1 )	index_noeuds		1			
					noeud_root = noeud_root.parent
				)
				
				
				
				local element_root = sequence[ noeud_root.index + 1 ]
				
				element_parent	=	element_root
				local noeud_courant 	= 	noeud_root
				for i = 1 to index_noeuds.count - 1 do(
					local index_nd = index_noeuds[i]
					element_parent = element_parent.elements[ index_nd ]
				)
				
			)
			
			element_parent
		)
		fn get_element		_noeud 	=(
			
			local element
			
			if _noeud != undefined do (
				if _noeud.level == 0 then
					element = sequence[_noeud.index + 1 ]
				
				else (
					
					local elem_parent = get_element_parent 	_noeud
					element = elem_parent.elements[ _noeud.index + 1 ]
					
				)
			)
			
-- 			debug "element"	var:element
			element
			
		)
		
		
		
		
		
		
		---------------- Tests ----------------------------------------------
		fn a_unParent_balcon		_noeud 	=(
			
			local result = false
			
			
			if _noeud != undefined and _noeud.level > 0 do (
				
				local noeud_root		=	_noeud
				local index_noeuds	=	#()
				for i = 0	to _noeud.level - 1	do	(
					insertItem	( noeud_root.index + 1 )	index_noeuds		1			
					noeud_root = noeud_root.parent
				)
				
				
				
				
				local element_root 		= 	sequence[ noeud_root.index + 1 ]
				local element_parent	=	element_root
				
				local noeud_courant 	= 	noeud_root
				
				for i = 1 to index_noeuds.count - 1 do	(
					local index_nd = index_noeuds[i]
					
					if  est_unBalcon 	element_parent	do
						result = true
					element_parent = element_parent.elements[ index_nd ]
				)
				if est_unBalcon element_parent	then 
					result = true
			
			)
			
			result
			
		)
		fn a_unEnfant_balcon		_noeud 	=(
			
			local result = false
			
			local element =	get_element		_noeud
			if est_unbalcon 	element then 
				result = true			
			else	if hasProperty		element		"elements" do (
				for i = 0 to _noeud.nodes.count - 1  do (
					local nd = _noeud.nodes.item[ i  ]
					if nd.tag		!=		"vide" do
						if a_unEnfant_balcon	nd		do
							result = true
				)
			)
			
			result
			
		)
		
		
		------- drag and drop -------------------------
		fn valider_drop	_node_dest =(
			
			local on_valide = true
			
			if a_unEnfant_balcon	node_enDrag	 and 	a_unParent_balcon	 _node_dest	 do
				on_valide = false
			
			on_valide
			
		)		
		fn drag_checkSurvol	 _arg = (
			
			_arg.Effect=_arg.AllowedEffect			
			
			local posDrag		= tv_sequence.PointToClient 	tv_sequence.MousePosition
			local itemSurvol	= tv_sequence.GetNodeAt (dotNetObject "System.Drawing.Point" posDrag.x 	posDrag.y)
			
			
			if itemSurvol != undefined then	(
				
				
				if valider_drop		itemSurvol	 then
					tv_sequence.SelectedNode = itemSurvol	---		tv_sequence.GetNodeAt(posDrag);
				else
					tv_sequence.SelectedNode = node_enDrag
			
			
			) else 
				tv_sequence.SelectedNode = undefined
			
			
			
		)
		fn drag_demarrer 	_arg =(
			
			if _arg.item != undefined do (
				
				if _arg.item.tag	!=		"vide" do (
				
					
					node_enDrag				=		_arg.item
					id_element_enDrag		=		_arg.item.Index	+	1
					elementParent_enDrag	= 		get_element_parent		_arg.item
					element_enDrag 			=  	get_element		 	_arg.item
					
					tv_sequence.doDragDrop 		_arg.item 		m_dragDropEffect.Move
				)
				
			)
		)
		fn drag_recevoir 	_arg =(
			
			local posDrop		= tv_sequence.PointToClient 	tv_sequence.MousePosition
			local noeudDest 	= tv_sequence.GetNodeAt (dotNetObject "System.Drawing.Point" posDrop.x 	posDrop.y )
			
			if noeudDest != undefined then	(
				
				
				local elementParent_dest 		= get_element_parent	noeudDest
				local element_dest 				= get_element		 	noeudDest
				
				
				if valider_drop	noeudDest do 
					inserer_element		elementParent_enDrag		id_element_enDrag		elementParent_dest		( noeudDest.index + 1 )
				
				
			) else 
				inserer_element		elementParent_enDrag		id_element_enDrag		undefined			( sequence.count +1)			
			
			
			elementParent_enDrag 		= undefined
			element_enDrag 				= undefined
			id_element_enDrag			=	0
			id_element_destination 		= 0
			
			node_enDrag = undefined
			
		)
		
		
		
		------- treeview -------------------------
		fn ajouter_TV_item	_item_aAjouter	_itemParent	=(
			
			---- pour element vide ---------
			struct tv_elem_vide (
				nom ="..."
			)
		
			local nv_node 	=	_itemParent.Nodes.add 		_item_aAjouter.nom
			
			if est_instance 	_item_aAjouter	( nv_node.index + 1 )	(get_element_parent nv_node)	do nv_node.text += " *"
				
			case classof _item_aAjouter of (
				cp_facadeCompo_mur:			nv_node.imageIndex = nv_node.selectedImageIndex	=	1
				cp_facadeCompo_ensemble:	nv_node.imageIndex = nv_node.selectedImageIndex	=	2
				cp_facadeCompo_balcon:		nv_node.imageIndex = nv_node.selectedImageIndex	=	3
				cp_facadeCompo_groupe:		nv_node.imageIndex = nv_node.selectedImageIndex	=	4
				
				default:	nv_node.imageIndex = nv_node.selectedImageIndex	=	0
			)
			
			
			if hasProperty	_item_aAjouter	"elements" do (
				if _item_aAjouter.elements.count == 0 then (
						local elem_vide = ajouter_TV_item	(tv_elem_vide () )	nv_node
						elem_vide.tag	="vide"
				) else (
					for elem in _item_aAjouter.elements	do (
						local elem_enfant = ajouter_TV_item	elem	nv_node
						
					)
				)
			)
			
			nv_node.expand ()
			nv_node
		)
		
		fn initialiser_tv = (
			
			---- TRee view ----
			tv_sequence.borderstyle 			= (dotnetclass "System.Windows.Forms.BorderStyle").None
			tv_sequence.LabelEdit 				= false 
			tv_sequence.allowdrop 				= true
			tv_sequence.HideSelection 		= false
-- 			tv_sequence.ShowRootLines	 	= true
			tv_sequence.ShowLines   			= true
-- 			tv_sequence.HotTracking   		= true
			tv_sequence.BackColor 			= (dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			tv_sequence.ForeColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_sequence.LineColor 				= (dotNetClass "System.Drawing.Color").fromARGB 	255	255	255
			tv_sequence.DrawMode 			= (dotnetclass "TreeViewDrawMode.OwnerDrawText")
			
			tv_sequence.indent				= 24
			
			tv_imageList.imageSize 	= 	dotNetObject "System.Drawing.Size" 32 32
			
			tv_imageList.Images.Clear ()
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile("C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\img\\tv - vide.png"))
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile("C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\img\\tv - mur.png"))
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile("C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\img\\tv - ensemble menuis.png"))
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile("C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\img\\tv - balcon.png"))
			tv_imageList.Images.Add((dotnetclass "System.Drawing.Image" ).FromFile("C:\\Users\\kris\\AppData\\Local\\Autodesk\\3dsMax\\2018 - 64bit\\ENU\\scripts\\cp-Urba\\img\\tv - groupe.png"))
		
			tv_sequence.ImageList =	tv_imageList

			
			
		)
		
		
		

		----- UI	divers ----------------------------------------------------------------------------------------------------
		fn actualiser =(
			
			---- repartition -------
-- 			spn_repetitions.enabled = ddl_repartition.selection == 2
			
			---- tree view --------------------------------------------------
			
			
			
			vider_tv ()
			
			
			
			
			for i = 1 to sequence.count do 				
				ajouter_TV_item	sequence[i]		tv_sequence
			
			
			----- divers -------------------
			local repart_options_enabled 		= ddl_repartition.selection != 1
			spn_repetitions.indeterminate			=	repart_options_enabled
			spn_repetitions.enabled 				=	not	repart_options_enabled 
-- 			spn_decallage.indeterminate		=	repart_options_enabled
-- 			spn_decallage.enabled 				=	not	repart_options_enabled
			spn_espacement.indeterminate		=	repart_options_enabled
			spn_espacement.enabled 				=	not	repart_options_enabled
			
			
			
			
		) --- fin actualiser -----------

		
		---- clavier ----		
		fn key_up				_arg =(
			
			keyCode = _arg.KeyCode
			
			local touches = dotnetclass  "System.Windows.Forms.Keys"
			
-- 			local dossierCourant  = m_edit.getDossier ()			
			
			
			debug "key_up arg" var:_arg
			/* 
			case keyCode of (
				
				-- Tab : focus ----
				( touches.Tab ): 	if _arg.shift		then m_prt.focusPrecedant ()
															else  m_prt.focusSuivant ()
				
		 		-- renommer --
				( touches.F2 ): 		if dossierCourant.estElemUtilisateur () do editerNom	dossierCourant
				
				-- supprimer --
				( touches.Delete ): 	if dossierCourant.estElemUtilisateur ()	do m_edit.supprimer	dossierCourant
			
-- 				-- ouvrir  --	
-- 				( touches.Enter ): 	m_edit.ouvrir		dossierCourant
				
				-- fleches --
				( touches.Left): 		m_edit.ouvrir		dossierCourant
				( touches.Right ): 	m_edit.ouvrir		dossierCourant
				( touches.Up): 		m_edit.ouvrir		dossierCourant
				( touches.Down ): 	m_edit.ouvrir		dossierCourant
				
				-- undo /redo --
				( touches.Z ): 		if _arg.Control do	m_cmd.defaire ()
				( touches.Y ): 		if _arg.Control do	m_cmd.refaire ()
				
				( touches.Escape ): 		m_apercus.annuler ()
				
			)
			 */
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
					roll_parametres.height	=	roll_hauteur_init 	+ 	changement_ht
				)
			)
		)
		
		
		
		
		----- EVENEMENTS ------------------------------------------------------------------------------ -----------------------
		on roll_parametres		open 				do 	(
			initialiser_tv  ()
			actualiser ()
		)
		
		---- repartition ---------
		on ddl_repartition selected  val do actualiser ()
		
		----- Sequence -----------------		
		on btn_ajouter_mur	 			pressed 			do 	ajouter_element_facade 	cp_facadeCompo_mur
		on btn_ajouter_ensemble		pressed 			do 	ajouter_element_facade 	cp_facadeCompo_ensemble
		on btn_ajouter_balcon			pressed 			do 	ajouter_element_facade 	cp_facadeCompo_balcon
		on btn_ajouter_groupe			pressed 			do 	ajouter_element_facade 	cp_facadeCompo_groupe
		
		
		
		--------- le treeView ---------
		on tv_sequence 	mouseDown 				_arg 	do  	(
-- 			clq_down  				_arg
			local noeud_selec 	= tv_sequence.GetNodeAt (dotNetObject "System.Drawing.Point" _arg.x _arg.y )
			local elem_selec 		= get_element	noeud_selec
			
			local subroll_dest	 = roll_parametres_element.subroll_param
			if subroll_dest.rollouts.count > 0 do 
				for subRoll in subroll_dest.rollouts  do
					removeSubRollout subroll_dest	subRoll
				
			if elem_selec != undefined then (
				addSubRollout 	subroll_dest		elem_selec.roll_parametres
				a_unEnfant_balcon  	noeud_selec
				a_unParent_balcon  	noeud_selec
			)
			else
				tv_sequence.SelectedNode = undefined
			
		)
		on tv_sequence 	DragOver 	_sender		_arg	do	drag_checkSurvol  	_arg
		on tv_sequence 	DragDrop 					_arg 	do	drag_recevoir 			_arg
		on tv_sequence 	ItemDrag 	_sender		_arg 	do	drag_demarrer 		_arg
/* 
		on tv_sequence 	AfterLabelEdit				_arg 	do  	(
			
			if _arg.label != undefined do (
				local noeud = _arg.Node
				
				local element
				if noeud.level == 0 then	element = sequence[noeud.index + 1 ]
				else if noeud.level == 1 then	element = sequence[noeud.parent.index + 1 ].elements[ noeud.index  + 1 ]
				else if noeud.level == 2 do 	element = sequence[noeud.parent.parent.index + 1 ].elements[ noeud.parent.index  + 1 ].elements[ noeud.index  + 1 ]
				
				element.nom = _arg.label
				
				actualiser ()
			)
		)
		 */
		
-- 		on tv_sequence 	keyup  						_arg 	do  	key_up					_arg
		
		
		
		--------- Edition ---------
		on btn_dupliquer 			pressed 			do	dupliquer_element_facade 			( get_element_parent	tv_sequence.SelectedNode	)				( tv_sequence.SelectedNode.index + 1 )
		on btn_instancier 		pressed 			do	instancier_element_facade 		( get_element_parent	tv_sequence.SelectedNode	)				( tv_sequence.SelectedNode.index + 1 )
		on btn_rendreUnique	pressed 			do	rendreUnique_element_facade 	( get_element_parent	tv_sequence.SelectedNode	)				( tv_sequence.SelectedNode.index + 1 )
		on btn_retirer 			pressed 			do	retirer_element_facade 			( get_element_parent	tv_sequence.SelectedNode	)				( tv_sequence.SelectedNode.index + 1 )
		
	
	
		
	)
	rollout roll_parametres_element  	"Element"		(
	
		subrollout	subroll_param		""	height:516
		
		
	)
	
	rollout roll_contraintes 	"Contraintes"	(
		group "Etages" (
			checkbox 	chk_etages_min	"Min."   		width:47	height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left		across:2
			spinner 	spn_etages_min	"" 				width:57	height:16 range:[-1e+13,1e+13,0] type:#integer scale:1 align:#right
			checkbox 	chk_etages_max 	"Max."  		width:47	height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left	across:2
			spinner 	spn_etages_max 	""  			width:57 	height:16 range:[0,1e+13,0] type:#integer scale:1 align:#right
		)
		group "Longeur" (		
			checkbox 	chk_longueur_min 	"Min." 	width:47	height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left	across:2
			spinner 	spn_longueur_min 	""  		width:57	height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#right
			checkbox 	chk_longueur_max 	"Max."  	width:47	height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left	across:2
			spinner 	spn_longueur_max		"" 		width:57 	height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#right
		)
		group "Murs" (
			checkbutton ckb_mur_nord 		"N."  		width:27 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left	across:4
			checkbutton ckb_mur_sud 		"S."  		width:27 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			checkbutton ckb_mur_est 		"E." 		width:27 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			checkbutton ckb_mur_ouest 	"O."		width:27 height:16 enabled:true highlightColor:(color 180 180 0) toolTip:"Etage minimum." align:#left
			
			dropdownList ddl_murs ""  height:21 selection:3 align:#left	items:#("Tous", "Pignons", "Gouttereaux" )
		)
		
		fn actualiser= (
			spn_etages_min.indeterminate		=	not etages_min_use
			spn_etages_min.enabled 				=	etages_min_use 
			
			spn_etages_max.indeterminate		=	not etages_max_use
			spn_etages_max.enabled 				=	etages_max_use 
			
			spn_longueur_min.indeterminate		=	not longueur_min_use
			spn_longueur_min.enabled 			=	longueur_min_use 
			
			spn_longueur_max.indeterminate		=	not longueur_max_use
			spn_longueur_max.enabled 			=	longueur_max_use 
			
		)
		on roll_contraintes open do actualiser ()
			
		on chk_etages_min 		changed state do actualiser ()
		on chk_etages_max 	changed state do actualiser ()
		on chk_longueur_min 	changed state do actualiser ()
		on chk_longueur_max	changed state do actualiser ()
			
			
		
	) --- fin roll_contraintes-------------------------
	rollout roll_divers  			"Divers"			(
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 		"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 		"Vitrage" 				type:#integer range:[1,1000,1]
			spinner spn_matId_huisserie 	"Huisserie" 				type:#integer range:[1,1000,1]
			spinner spn_matId_mur 			"Mur" 					type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	rollout roll_hasard  			"Hasard"			(
		
		spinner spn_hasard_seed 			"Seed" 					type:#integer		 range:[0,1e20,0]
		
		group "Fenetres" (
			spinner spn_fen_proba_ouv 		"Proba (%)" 			type:#float			 range:[0,100,0]
			spinner spn_fen_ouvMax 			"Max (°)" 		type:#float			 range:[0,180,0]
		)
	
	)
	
	
	
	------------ FONCTIONS	----------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
-- 		--- rester dans les bonnes limites ------
-- 		if align_prof > profondeur do align_prof = profondeur
		
		/* 
		--- longueur de l'ensemble ----------
		local longueur_est_contrainte = true
		local longueur_contrainte = 0
		for elem_long in sequence_elem_long do
			if elem_long == 0 do longueur_est_contrainte	=	false
		if longueur_est_contrainte and sequence.count > 0  do (
			for elem_long in sequence_elem_long do (
				longueur_contrainte += elem_long
				longueur_contrainte += cadre_largeur
			)
			longueur_contrainte += cadre_largeur
			longueur = longueur_contrainte
		)
		 */
	)
	
	
	--------- tests ------------------
	fn est_unGroupe		_compo	=	classof	_compo	==	cp_facadeCompo_groupe
	fn est_ouvrable		_compo	=	classof	_compo	==	cp_facadeCompo_ensemble --or classof	_compo	==	cp_facadeCompo_ensemble
	
	fn est_unBalcon		_compo	=	classof	_compo	==	cp_facadeCompo_balcon
	
	fn est_porte			_compo	=	classof	_compo	==	cp_menuis_porte
	fn est_fixe				_compo	=	classof	_compo	==	cp_menuis_fixe
	fn est_unPlein			_compo	=	classof	_compo	==	cp_facadeCompo_mur	--	_compo.category	as string ==	"CP | Facade	| Pleins"
	fn est_copiable					=	 roll_parametres.lbx_sequence.selection != 0
	
	
	
	--------- divers ------------------
	fn ouvrir_parametres		_element =(
		createdialog 	_element.roll_parametres	width:250
	)	
	fn actualiser_UI = (
		corriger_parametres ()		
		actualiser_composants()		
-- 		if roll_parametres.open do	roll_parametres.actualiser ()
		if roll_parametres.open do	roll_parametres.actualiser ()		
		redrawViews ()
		
	)
	
	
	---- instances -------------------
	fn est_instance_recurrence		_element	_elements		_id_original		 	_parent_original	=(
		local result =false
		
		for i = 1 to _elements.elements.count do (
			if 	 _elements	!= _parent_original or _elements	== _parent_original and i != _id_original	do (
				if _elements.elements[i] == _element then
					result = true
				else
					if hasProperty _elements.elements[i] "elements" do
						if 	est_instance_recurrence		_element		_elements.elements[i] 		_id_original		_parent_original	do
							result = true
			)
		)
		
		result
	)
	fn est_instance		_element		_id_original		 	_parent_original	=(
		local result =false
		
		for i = 1 to sequence.count do (
			if 	 _parent_original != undefined or _parent_original	==  undefined and i != _id_original	do (
				if sequence[i] == _element then
					result = true
				else
					if hasProperty sequence[i] "elements" do
						if 	est_instance_recurrence		_element		sequence[i] 		_id_original		_parent_original	do
							result = true
			)
		)
		
		
		result
	)
	
	
	---- validation contraints facades ---------------------------------------
	fn est_facadeValide	_pt_1 		_pt_2  			_etage		_etages_nbre	=(
		
		local pt_1 = _pt_1
		local pt_2 = _pt_2
		local result_valid 		= true
		
		
		--- longueur ------------
		local longueur_mur 	= distance		pt_1 	pt_2
		if longueur_min_use and longueur_mur < longueur_min do
			result_valid = false
		if longueur_max_use and longueur_mur > longueur_max do
			result_valid = false
		
		
		---- etages -------------
		if etages_max_use and  _etage > etages_max do
			result_valid = false
		
		local etage_min_tmp	=	etages_min
		if etage_min_tmp < 0 do etage_min_tmp = _etages_nbre + etages_min + 1
		if etages_min_use and  _etage < etage_min_tmp do
			result_valid = false
		
		result_valid
	)
	

	
	
	--------------- sequence ----------------------------------
	fn ajouter_element_facade			_element_plug	 		=(
		
-- 		local	id_elem_select 	= 	roll_parametres.lbx_sequence.selection
-- 		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_element 		= createinstance	_element_plug
-- 		
-- 		if id_elem_select != 0 and id_elem_select	!= sequence.count	then	
-- 			insertItem nvl_element 					sequence 					id_elem_insert
-- 		else		
			append sequence						nvl_element
		
		---- actualisations -----------
		actualiser_UI ()
		
		if roll_parametres.open do	(
-- 			roll_parametres.lbx_sequence.selection = id_elem_insert 
			roll_parametres.actualiser ()	
		)
		
	)
	fn retirer_element_facade				_element_parent		_id		 	=(
		
-- 		deleteItem sequence 				_id
		
		
		----- on retire l'element à deplacer de son origine -------------
		if _element_parent != undefined then 
			deleteItem 	_element_parent.elements 			_id
		else 
			deleteItem 	sequence 			_id
		
		
		
		
		---- actualisations -----------
		actualiser_UI ()
		
		if roll_parametres.open do	(
-- 			roll_parametres.lbx_sequence.selection -= 1 
			roll_parametres.actualiser ()	
		)
		
	)
	/* fn renommer_element_facade			_id	_nv_nom 		=(
		sequence[ _id ].nom = _nv_nom
		if roll_parametres.open do	roll_parametres.actualiser ()
	) */
	fn inserer_element						_elementParent_enDrag		_id_aDeplacer		_elementParent_dest			_id_destination		=(
		
		local elem_aDeplacer
		
		----- on retire l'element à deplacer de son origine -------------
		if _elementParent_enDrag != undefined then (
			elem_aDeplacer	=	 	_elementParent_enDrag.elements 		[_id_aDeplacer]
			deleteItem 	_elementParent_enDrag.elements 			_id_aDeplacer
-- 			_elementParent_enDrag.retirer_element	_id_aDeplacer
		) else (
			elem_aDeplacer	=	 	sequence		[_id_aDeplacer]
-- 			_elementParent_enDrag.retirer_element	_id_aDeplacer
			deleteItem 	sequence 			_id_aDeplacer
		)
		
		
		
		----- on le pose à sa destination -------------
		if _elementParent_dest != undefined then (
			
			if _id_destination > _elementParent_dest.elements.count then (
				append _elementParent_dest.elements		 elem_aDeplacer
-- 				_elementParent_dest.ajouter_element		elem_aDeplacer	
			)else(
				insertItem 	elem_aDeplacer			_elementParent_dest.elements  		_id_destination  
-- 				_elementParent_dest.ajouter_element		elem_aDeplacer	id:_id_destination
			)
		) else (
			
			if _id_destination > sequence.count then 
				append sequence	 elem_aDeplacer
			else
				insertItem 	elem_aDeplacer			sequence  			_id_destination  
		)
		
		
		---- actualisations -----------
		actualiser_UI ()
		
		if roll_parametres.open do	(
-- 			roll_parametres.lbx_sequence.selection -=  1
			roll_parametres.actualiser ()	
		)
	
	)
	fn dupliquer_element_facade 			_element_parent		_id		=(
		
		if _id > 0 do (
			
			local liste_cible
			if _element_parent != undefined then 
				liste_cible = _element_parent.elements
			else
				liste_cible = sequence
			
			local elem_duplique 		= copy	liste_cible[ _id ]
			
			if _id > liste_cible.count then 
				append _liste_cible	 elem_duplique
			else
				insertItem 	elem_duplique			liste_cible  					(	_id  )
			
			
			---- actualisations -----------
			actualiser_UI ()
			
			if roll_parametres.open do	(
-- 				roll_parametres.lbx_sequence.selection = (_id+1) 
				roll_parametres.actualiser ()	
			)
		)
	)
	fn instancier_element_facade 		_element_parent	_id			=(
		if _id > 0 do (
			
			local liste_cible
			if _element_parent != undefined then 
				liste_cible = _element_parent.elements
			else
				liste_cible = sequence
			
			local elem_duplique 		= 	liste_cible[ _id ]
			
			if _id > liste_cible.count then 
				append _liste_cible	 elem_duplique
			else
				insertItem 	elem_duplique			liste_cible  					(	_id  )
			
			
			---- actualisations -----------
			actualiser_UI ()
			
			if roll_parametres.open do	(
-- 				roll_parametres.lbx_sequence.selection = (_id+1) 
				roll_parametres.actualiser ()	
			)
		)
	)
	fn rendreUnique_element_facade	_element_parent	_id			=(
		
			if _element_parent != undefined then 
				_element_parent.elements[ _id ]  = copy		_element_parent.elements[ _id ] 
			else
				sequence[ _id ] = copy sequence[ _id ] 
		
		---- actualisations -----------
		actualiser_UI ()
	)
	
	
	
	
	
	--------------- comopsants ----------------------------------
	fn actualiser_composants	= with redraw off (
		
		
		sequence_aConstruire 				= 	#()
		
		--- Si notre sequence est vide ------------------------------------
		if sequence.count == 0 then (
			
			local compo_temp = createInstance cp_facadeCompo_mur
			
			compo_temp.hauteur			=	hauteur 
			compo_temp.profondeur		=	profondeur
			compo_temp.low_poly			=	low_poly
			compo_temp.longueur			=	longueur
			compo_temp.matId				=	matId_mur
			
			append	sequence_aConstruire  	compo_temp
			
		)  else (	----- on construit la sequence ---------------------------------------
			
			
			
			---- la sequence de base à repeter si besoin --------------------------
			local sequence_aRepeter =#()
			
			---- cleanage de la sequence (on retire les elements qui n'apparetront pas ) -----------------------------------------------------------
-- 			local sequence	=#()
-- 			for i = 1 to sequence.count do 
-- 				if not  est_unGroupe	sequence[i] or   est_unGroupe	sequence[i] and sequence[i].elements.count > 0 do 
-- 					append	sequence	sequence[i]
			
			
			
			---- si repetitions == 0 alors on en met le maximum -------------------
			local nombre_deRepetitions		=	repart_nombre
			local longueur_definies 			=	0
			if repartition == 1 then (
				for i = 1 to sequence.count do 
					longueur_definies	+= sequence[i].get_longueur()
				if repart_nombre == 0 do 
					nombre_deRepetitions = floor ( longueur / longueur_definies )
			) else  nombre_deRepetitions = 1
			
			
			
			
			
			---- la longueur des composants  etirable --------------------------------------------------------------------------------------------------
			local longueur_repartition				=	0
			local longueur_definies_total 			=	0
			local longueurMax_atteinte 			=	false
			local id_dernierComposant				=	sequence.count
			
			
			---- on ajoute les longueurs des composant a longueur définie -----------------
-- 			debug""
-- 			debug "############	longueur_definies_total		##############"	
			for i = 1 to sequence.count do (
-- 				if est_unGroupe sequence[i] then (
-- 					longueur_definies_total+= sequence[i].get_longueur()  *	sequence[i].repetition	* nombre_deRepetitions 
-- 				) else (
				local seq_lg	=	sequence[i].get_longueur()
				longueur_definies_total+=  seq_lg * nombre_deRepetitions
-- 				debug "sequence[i] "	var:sequence[i].nom 
-- 				debug "sequence[i].get_longueur() "	var:seq_lg
-- 				)
			)
-- 			debug "---->	longueur_definies_total"	var:longueur_definies_total
-- 			debug""
			/* 
			---- si on est plus long que la longueur de la facade on réajuste --------------------------
			if longueurMax_atteinte do (
				longueur_definies_total 	=	0
-- 				nbr_elem_definies 			=	0
-- 				nbr_elem_indefinies 			=	0
				for i = 1 to id_dernierComposant 	do (
					if not sequence[i].etirable			then (
						longueur_definies_total+= sequence[i].get_longueur()
						nbr_elem_definies += 1
					)	else nbr_elem_indefinies += 1
				)
			)
			
			 */
			
			
			--- en fonction du mode de répartition ----------------------
			case repartition of (
				
				1: 	(	-----	REPARTIR	 --------------------------------------------------------------------------------------------------------------------------------
					
					
					
					
					---- on a donc notre longueur a repartir -------------------
					longueur_repartition		=  ( longueur - longueur_definies_total  )  	/ (  ( nombre_deRepetitions /* *2 */	*	id_dernierComposant /* - nbr_elem_definies */ ) + 1   )
					
					
					
					
					
					
					
					---- l espacement de la sequence ----------------------
					local espacement_sequence = copy repart_espacement
					if espacement_sequence *   ( nombre_deRepetitions * id_dernierComposant - 1 )  > 2* longueur_repartition do
						espacement_sequence = 2* longueur_repartition  / ( nombre_deRepetitions * id_dernierComposant - 1 ) 
					if espacement_sequence < - longueur_repartition	do
						espacement_sequence =  - longueur_repartition
					
					
					---- le decallage de la sequence ----------------------
					local decallage_espacement	=	espacement_sequence * (  ( nombre_deRepetitions * id_dernierComposant - 1 ) )  / 2					
					local decallage_sequence = copy repart_decallage 
					if decallage_sequence > longueur_repartition - decallage_espacement do
						decallage_sequence = longueur_repartition - decallage_espacement 
					if decallage_sequence < ( - longueur_repartition + decallage_espacement ) do
						decallage_sequence = ( - longueur_repartition + decallage_espacement ) 
					
					
					
					
					--- le mur séparant les composant 	------------------	
					local compo_murRepart				=	createInstance cp_facadeCompo_mur
					compo_murRepart.longueur		=	longueur_repartition + espacement_sequence
					compo_murRepart.hauteur			=	hauteur 
					compo_murRepart.profondeur		=	profondeur
					compo_murRepart.low_poly		=	low_poly
					compo_murRepart.matId			=	matId_mur		
					
					
					
					
					---- le premier mur ---------------
					local compo_murDebut 		= copy compo_murRepart					
					compo_murDebut.longueur		=	longueur_repartition - decallage_espacement + decallage_sequence
					append sequence_aConstruire		compo_murDebut
					
					
					
					--- on creer la sequence à construire --------------------------------------------------------------------------------------------------------------					
					for i = 1 to sequence.count do (
						--- le composant ----------------
						local compo_temp 				= 	copy sequence[i]
						compo_temp.longueur 			= 	compo_temp.get_longueur()
						compo_temp.hauteur			=	hauteur
						compo_temp.low_poly			=	low_poly
						if est_ouvrable	 compo_temp do (		--- hasard ------
							compo_temp.fen_ouvMax		=	fen_ouvMax
							compo_temp.fen_proba_ouv	=	fen_proba_ouv
						)
						
						append sequence_aRepeter		compo_temp
						
						---- le mur separant les composants  -------------------------------------
						if i != sequence.count  do
							append sequence_aRepeter		compo_murRepart
						/* 
						---la repetition si c'est un groupe --------------
						if est_unGroupe		compo_temp do 
							for j=2 to compo_temp.repetition	do  (
								append sequence_aRepeter		compo_temp
								if i != sequence.count and  j	!=	compo_temp.repetition	do
									append sequence_aRepeter		compo_murRepart
							)
							 */
							
					) --- fin for sequence ------------------
					
					
					
					
					--- la repetition de la sequence de base -----------
					for repet = 1 to nombre_deRepetitions do 	(
						sequence_aConstruire += for compo in  sequence_aRepeter collect copy compo
						if repet != nombre_deRepetitions  do	append sequence_aConstruire		compo_murRepart
					)
					
					
					
					---- le mur sdernier mur  -------------------------------------
					local compo_murDeFin 			= copy compo_murRepart					
					compo_murDeFin.longueur		=	longueur_repartition - decallage_espacement - decallage_sequence
					append sequence_aConstruire		compo_murDeFin
					
					
				) -----		fin 	REPARTIR	 -------------------------------------------------------------------------------------------------------------------------------- 
				
				
				
				
				2: 	(	-----	CENTRER		 --------------------------------------------------------------------------------------------------------------------------------
					
					---- on a donc notre longueur a repartir -------------------
					longueur_repartition		=  ( longueur - longueur_definies_total  )  	/  2  
					
					
					---- le decallage de la sequence ----------------------
					local decallage_sequence = copy repart_decallage
					if 	abs decallage_sequence > longueur_repartition do
						if decallage_sequence <0 then decallage_sequence = - longueur_repartition
							else decallage_sequence =  longueur_repartition
					
					
					--- le mur séparant les composant 	------------------	
					local compo_murRepart				=	createInstance cp_facadeCompo_mur
					compo_murRepart.longueur		=	longueur_repartition + decallage_sequence
					compo_murRepart.hauteur			=	hauteur 
					compo_murRepart.profondeur		=	profondeur
					compo_murRepart.low_poly		=	low_poly
					compo_murRepart.matId			=	matId_mur	
					
					---- le premier mur ---------------
					append sequence_aConstruire		compo_murRepart
					
					
					
					
					
					--- on creer la sequence à construire ----------------------					
					for i = 1 to id_dernierComposant do (
						
						--- le composant ----------------
						local compo_temp 				= 	copy sequence[i]			
						compo_temp.longueur			=	hauteur	
						compo_temp.hauteur			=	hauteur
						compo_temp.low_poly			=	low_poly						
						if est_ouvrable	 compo_temp do (	--- hasard ------
							compo_temp.fen_ouvMax		=	fen_ouvMax
							compo_temp.fen_proba_ouv	=	fen_proba_ouv
						)
						append sequence_aConstruire		compo_temp
						
						
						
						/* 
						---la repetition si c'est un groupe --------------
						if est_unGroupe		compo_temp do 
							for j=2 to compo_temp.repetition	do  (
								append sequence_aConstruire		compo_temp
-- 								if i != sequence.count and  j	!=	compo_temp.repetition	do
-- 									append sequence_aRepeter		compo_murRepart
							)
						 */
						
						
					) --- fin for sequence ------------------
					
					
					
					
					---- le dernier mur  -------------------------------------
					local compo_murDeFin 				= copy compo_murRepart					
					compo_murDeFin.longueur			=	longueur_repartition - decallage_sequence
					append sequence_aConstruire		compo_murDeFin
					
					
					
				) -----		fin 	CENTRER	 ------------------------------------------------------------ 
				
				
				
				3: 	(	-----	A GAUCHE		 --------------------------------------------------------------------------------------------------------------------------------
					
					---- on a donc notre longueur a repartir -------------------
					longueur_repartition		=  ( longueur - longueur_definies_total  )  	--/  2  
					
					
					---- le decallage de la sequence ----------------------
					local decallage_sequence = copy repart_decallage
					if 	 decallage_sequence > longueur_repartition do
						decallage_sequence =  longueur_repartition
					if decallage_sequence <0 do
						decallage_sequence = 0
					
					
					
					--- le mur séparant les composant 	------------------	
					local compo_murRepart				=	createInstance cp_facadeCompo_mur
					compo_murRepart.longueur		=	decallage_sequence
					compo_murRepart.hauteur			=	hauteur 
					compo_murRepart.profondeur		=	profondeur
					compo_murRepart.low_poly		=	low_poly
					compo_murRepart.matId			=	matId_mur	
					
					---- le premier mur ---------------
					if decallage_sequence > 0 do
						append sequence_aConstruire		compo_murRepart
					
					
					
					
					--- on creer la sequence à construire ----------------------					
					for i = 1 to id_dernierComposant do (
						
						--- le composant ----------------
						local compo_temp 				= 	copy sequence[i]				
						compo_temp.longueur 			= 	compo_temp.get_longueur()
						compo_temp.hauteur			=	hauteur
						compo_temp.low_poly			=	low_poly						
						if est_ouvrable	 compo_temp do (	--- hasard ------
							compo_temp.fen_ouvMax		=	fen_ouvMax
							compo_temp.fen_proba_ouv	=	fen_proba_ouv
						)
						append sequence_aConstruire		compo_temp
						
						
						
						
						---la repetition si c'est un groupe --------------
						if est_unGroupe		compo_temp do 
							for j=2 to compo_temp.repetition	do  (
								append sequence_aConstruire		compo_temp
-- 								if i != sequence.count and  j	!=	compo_temp.repetition	do
-- 									append sequence_aRepeter		compo_murRepart
							)
						
						
						
					) --- fin for sequence ------------------
					
					
					
					
					---- le dernier mur  -------------------------------------
					local compo_murDeFin 				= copy compo_murRepart					
					compo_murDeFin.longueur			=	longueur_repartition - decallage_sequence
					append sequence_aConstruire		compo_murDeFin
					
					
					
				) -----		fin 	CENTRER	 ------------------------------------------------------------ 
				
				
				
				4: 	(	-----	A DROITE		 --------------------------------------------------------------------------------------------------------------------------------
					
					---- on a donc notre longueur a repartir -------------------
					longueur_repartition		=  ( longueur - longueur_definies_total  )  	--/  2  
					
					
					---- le decallage de la sequence ----------------------
					local decallage_sequence = copy repart_decallage
					if 	 decallage_sequence > longueur_repartition do
						decallage_sequence =  longueur_repartition
					if decallage_sequence <0 do
						decallage_sequence = 0
					
					
					
					--- le mur séparant les composant 	------------------	
					local compo_murRepart				=	createInstance cp_facadeCompo_mur
					compo_murRepart.longueur		=	longueur_repartition - decallage_sequence
					compo_murRepart.hauteur			=	hauteur 
					compo_murRepart.profondeur		=	profondeur
					compo_murRepart.low_poly		=	low_poly
					compo_murRepart.matId			=	matId_mur	
					
					---- le premier mur ---------------
-- 					if decallage_sequence > 0 do
						append sequence_aConstruire		compo_murRepart 
					
					
					
					
					--- on creer la sequence à construire ----------------------					
					for i = 1 to id_dernierComposant do (
						
						--- le composant ----------------
						local compo_temp 				= 	copy sequence[i]				
						compo_temp.hauteur			=	hauteur
						compo_temp.low_poly			=	low_poly						
						if est_ouvrable	 compo_temp do (	--- hasard ------
							compo_temp.fen_ouvMax		=	fen_ouvMax
							compo_temp.fen_proba_ouv	=	fen_proba_ouv
						)
						append sequence_aConstruire		compo_temp
						
						
						
						
						---la repetition si c'est un groupe --------------
						if est_unGroupe		compo_temp do 
							for j=2 to compo_temp.repetition	do  (
								append sequence_aConstruire		compo_temp
-- 								if i != sequence.count and  j	!=	compo_temp.repetition	do
-- 									append sequence_aRepeter		compo_murRepart
							)
						
						
						
					) --- fin for sequence ------------------
					
					
					
					
					---- le dernier mur  -------------------------------------
					if decallage_sequence > 0 do (
						local compo_murDeFin 				= copy compo_murRepart					
						compo_murDeFin.longueur			=	 decallage_sequence
						append sequence_aConstruire		compo_murDeFin
					)
					
					
				) -----		fin 	CENTRER	 ------------------------------------------------------------ 
				
				
				
				
			) ---- fin case repartition -----------------------------------------------------------------------------------------
			
			
			
			
			
			
			---- le hasard -----------------------------------------------------------------------------------------
			--  on rend unique le compo qui a besoin d'etre ouvert, c'est plus rapide que de faire tout les composants uniques -------------
			for i = 1 to sequence_aConstruire.count do (
				if est_ouvrable	 sequence_aConstruire[i] do (
					local est_ouverte =   ( random 0.  100. ) < fen_proba_ouv 
					if est_ouverte 	do
						sequence_aConstruire[i] = copy sequence_aConstruire[i]
				)
			)	-----------------------------------------------------------------------------------------
			
			
		) ---- fin creation de la sequence ---------------------------
		
		
	)  --- fin composants_actualiser  -----------------------------------------------------------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
-- 		local chrono_debut = timestamp ()
		
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		
		
		---- la sequence	-----		
		local depos_composant = [ 0, 0, 0 ]
		for i = 1 to	sequence_aConstruire.count do (
			
			---- le composant -----
			local composant 		= sequence_aConstruire [i]
			local align_y =	0	-- if est_unPlein	composant then 0 else profondeur - composant.profondeur
-- 			debug "----> composant" var:composant
			mgr_mesh.attacher		mesh		composant	transf:( depos_composant + [0,align_y,0] )
			
			depos_composant.x += composant.get_longueur()
			
		)
		
-- 		local chrono_fin = timeStamp()
-- 		debug  "build mesh :" var:( ((chrono_fin - chrono_debut) / 1000.0) as string + "s.")
		
		
	)  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		local pt_epaisseur
		
		on mousePoint click do
			case click of
			(
				1: (	
						pt_debut 		=  gridPoint
						nodeTM.translation = pt_debut
				)
				3: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= 	length 		( gridPoint - pt_debut )
					local norm_dir 		=	normalize 	(gridPoint - pt_debut )
					local angle_pts		=	acos			(dot  [1,0,0]  norm_dir)	
					
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_hauteur	=	gridPoint
					
				)
				3:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
					
				)
			)		
	) --- fin tool create ---------
	
	
) --------- fin plugin --------------


