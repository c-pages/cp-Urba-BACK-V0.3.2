
	
	
	
	

rollout roll_urba_editeurFacades "urba_editeurFacades" width:500 height:300
(
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =(
			local m_debug = true
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:"urba | roll_urba_editeurFacades"
			catch ()
		)
		
		------- includes ------------------
		include "$userScripts\cp - GLOBAL\UI.ms"
		include "$userScripts\cp - GLOBAL\DragDialog.ms"
		
		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_plug				---- pointeur vers le plug ----
		
		local m_changement = false
		
		--- les parametres courants ------------
		local m_facade_initiale
		local m_facade_courante
		local m_composant_courant
		local m_compoCourant_estDansBalcon = false
		
		--- rollout	---------	
		local largeur_params		= 	235
		local largeur_min 				= 	490
		local hauteur_min 			= 	300
		
		--- images bouton fermer ---
		local murs_types 	= #("Gouttereaux + Pignons", "Gouttereaux", "Pignons")
		local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" )		-- Pressé ----
		
		------------  UI	----------------------------------------------------------------------------------		
		---- Structures perso pour rollout ----
		local m_drag		---- Gere le drag de la fenetre ----
		local m_titre			---- Gere le titre de la fenetre ----
		
		---- le bouton pour fermer la fenetre ----
-- 		ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
		
		ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
		edittext 'edt_nom_facade' "" pos:[7,25] width:200 height:16 align:#left
		
		spinner 'spn_etages' "" pos:[103,53] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		spinner 'spn_etagesMax' "" pos:[180,53] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left		
		
		
		spinner 'spn_longueur_min' "" pos:[103,68] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		spinner 'spn_longueur_max' "" pos:[180,68] width:63 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		checkbutton 'chk_longueur_max' "" pos:[167,68] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
		checkbutton 'chk_longueur_min' "" pos:[90,68] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
		label 'lbl_longueur' "Longueur:" pos:[12,69] width:52 height:15 align:#left
			
		dropdownList 'ddl_murs' "" pos:[90,83] width:154 height:21 items:#("Gouttereaux + Pignons", "Gouttereaux", "Pignons") selection:3 align:#left
		label 'lbl_appliquerA' "Murs:" pos:[12,87] width:32 height:15 align:#left
			
		checkbutton 'chk_etagesMax' "" pos:[167,53] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
			
		listbox 'lbx_sequence' "" pos:[91,124] width:137 height:10 align:#left
			
		label 'lbl23' "Séquence:" pos:[11,105] width:60 height:15 align:#left
			
		button 'btn_enregistrer' "S" pos:[224,24] width:19 height:19 toolTip:"Sauvegarder preset." align:#left
		button 'btn_charger' "O" pos:[206,24] width:19 height:19 toolTip:"Ouvrir preset." align:#left
			
		button 'btn_monter' "/\\" pos:[228,123] width:16 height:19 toolTip:"Monter le composant." align:#left
		button 'btn_descendre' "\/" pos:[228,141] width:16 height:19 toolTip:"Descendre le composant." align:#left
		dropdownList 'ddl_mode' "" pos:[90,103] width:154 height:21 items:#("Répéter", "Etrirer", "Centrer", "Espacer") selection:3 align:#left
		checkbutton 'chk_etages' "" pos:[90,53] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
			
		label 'lbl95' "Etages:" pos:[12,54] width:43 height:15 align:#left
			
		subRollout 'subroll_parametres' "Parametres" pos:[267,43] width:210 height:208 align:#left
			
		GroupBox 'grp_prop' "Propriétés" pos:[255,25] width:225 height:238 align:#left
			
		button 'btn_dupliquer_composant' "Dupliquer" pos:[10,221] width:75 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
		button 'btn_instancier_composant' "Instancier" pos:[10,236] width:75 height:16 toolTip:"Créer une instance du composant sélectionné." align:#left
		button 'btn_supprimer_composant' "Supprimer" pos:[10,251] width:75 height:16 toolTip:"Supprimer le composant sélectionné." align:#left
			
		button 'btn_ajouter_composant_1' "btn1" pos:[10,123] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_2' "btn2" pos:[10,138] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_3' "btn3" pos:[10,153] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_4' "btn4" pos:[10,168] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_5' "btn5" pos:[10,183] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_6' "btn6" pos:[10,197] width:75 height:16 visible:false align:#left
			
		button 'btn_valider' "Valider" pos:[10,271] width:78 height:25 toolTip:"Valider la façade" align:#left
		button 'btn_annuler' "Annuler" pos:[86,271] width:79 height:25 toolTip:"Annuler les changements" align:#left
			
		local		btns_ajouter_composant	=#( btn_ajouter_composant_1, btn_ajouter_composant_2, btn_ajouter_composant_3, btn_ajouter_composant_4, btn_ajouter_composant_5, btn_ajouter_composant_6 )
		local 	btns_ids_models				=#()
		
		------------  Fonctions	----------------------------------------------------------------------------------
		fn  remplir_lbx_sequence =(
			
			--------- la sequence de composants --------
			local itemsTmp 		= #()
			local est_dansBalcon = false
			m_compoCourant_estDansBalcon = false
			local tabulation		= "    "
			local i = 1
			for comp in m_facade_courante.sequence		do	(
				local affichage 		= ""
				
				if comp.type == #balconFin 	do est_dansBalcon = false
					
				if est_dansBalcon do affichage += tabulation
				affichage += comp.nom
				append itemsTmp affichage
				
				if comp.type == #balcon		do est_dansBalcon = true
					
				-- pour la gestion du bouton de creation de balcon --------
				
-- 					debug "m_composant_courant" var:m_composant_courant.nom
-- 					debug "i" var:i
-- 					debug "lbx_sequence.selection " var:lbx_sequence.selection 
					if i == lbx_sequence.selection do (
						m_compoCourant_estDansBalcon = est_dansBalcon
-- 						debug "===========================" var:m_composant_courant.nom
					)
				
				i += 1
			)
			lbx_sequence.items =  itemsTmp
			
		)
		fn actualiser 							=(
			debug "actualiser ()"
			edt_nom_facade.text 			= m_facade_courante.nom
			
			chk_etages.checked				= m_facade_courante.etages_min_use
			spn_etages.indeterminate 		= not m_facade_courante.etages_min_use	
			spn_etages.enabled 				= m_facade_courante.etages_min_use	
			if not spn_etages.indeterminate do
				spn_etages.value				= m_facade_courante.etages_min
			
			chk_etagesMax.checked			= m_facade_courante.etages_max_use
			spn_etagesMax.indeterminate = not m_facade_courante.etages_max_use	
			spn_etagesMax.enabled			= m_facade_courante.etages_max_use			
			if not spn_etagesMax.indeterminate do
				spn_etagesMax.value			 = m_facade_courante.etages_max	
			
			chk_longueur_min.checked					= m_facade_courante.longueur_min_use
			spn_longueur_min.indeterminate 		= not m_facade_courante.longueur_min_use	
			spn_longueur_min.enabled 				= m_facade_courante.longueur_min_use	
			if not spn_longueur_min.indeterminate do
				spn_longueur_min.value				= m_facade_courante.longueur_min
			
			chk_longueur_max.checked				= m_facade_courante.longueur_max_use
			spn_longueur_max.indeterminate 		= not m_facade_courante.longueur_max_use	
			spn_longueur_max.enabled 				= m_facade_courante.longueur_max_use	
			if not spn_longueur_max.indeterminate do
				spn_longueur_max.value				= m_facade_courante.longueur_max
			
			
			ddl_murs.selection 				= m_facade_courante.murs
			ddl_mode.selection 				= m_facade_courante.mode
			
			remplir_lbx_sequence ()
			
			--- bloquage du bouton Balcon si on est deja dans un balcon -------------------
-- 			if m_compoCourant_estDansBalcon do (
			local idBalcon = ( m_plug.core.get_mgr_composants() ).get_model_ID #Balcon 
			btns_ajouter_composant[idBalcon].enabled = not m_compoCourant_estDansBalcon
-- 			)
			
			btn_supprimer_composant.enabled 	= lbx_sequence.selection != 0
			btn_instancier_composant.enabled 		= lbx_sequence.selection != 0
			btn_dupliquer_composant.enabled 		= lbx_sequence.selection != 0
			
			-- bouton monter ----
			local btnMonter_enabled 		= lbx_sequence.selection != 1 and  lbx_sequence.selection != 0 and m_composant_courant != undefined
			if btnMonter_enabled do (
				if m_composant_courant.type == #balcon  or m_composant_courant.type == #balconFin do (
					local compo_precedant = m_facade_courante.sequence[lbx_sequence.selection - 1] 
					if compo_precedant.type == #balcon or compo_precedant.type == #balconFin  do (
						btnMonter_enabled = false
					)
				)
			)
			btn_monter.enabled 		= btnMonter_enabled
			
			-- bouton descendre ----
			local btnDescendre_enabled = lbx_sequence.selection != lbx_sequence.items.count and  lbx_sequence.selection != 0 and m_composant_courant != undefined
			if btnDescendre_enabled do (
				if m_composant_courant.type == #balcon  or m_composant_courant.type == #balconfin do (
					local compo_suivant = m_facade_courante.sequence[lbx_sequence.selection + 1] 
					if compo_suivant.type == #balcon or compo_suivant.type == #balconFin  do (
						btnDescendre_enabled = false
					)
				)
			)
			btn_descendre.enabled 		= btnDescendre_enabled
			
			
			--- le subRollout des composants	-------
			for rollAVirer in subroll_parametres.rollouts do
				removeSubRollout	subroll_parametres	rollAVirer
			if m_composant_courant != undefined do (
				addSubRollout	subroll_parametres ( m_composant_courant.get_dialog () )
				m_composant_courant.initialiser_dialog	 	roll_urba_editeurFacades
			)
		)
		fn redimensionnerFenetre 		_taille 	=(
			
-- 			local largeur_min_ferme 	= 255
-- 			local largeur_min_ouvert 	= largeur_min_ferme + largeur_params			
-- 			local largeur_min 				= 	largeur_min_ouvert
-- 			local hauteur_min 			= 255
			
			local largeur_btn 		= 17
			local largeur_bord 	= edt_nom_facade.pos.x
			
			if 	_taille.x < largeur_min do 
				_taille.x =  largeur_min
			if 	_taille.y < hauteur_min do 
				_taille.y =  hauteur_min
			roll_urba_editeurFacades.width 		= _taille.x
			roll_urba_editeurFacades.height 	= _taille.y
			
			m_plug.core.set_roll_editeurDeFacade_taille	_taille
-- 			debug "_taille" var:_taille
			local largeur_fenetre 	= 	_taille.x -  largeur_params
			
-- 			ui_btnFermer.pos.x		= 	_taille.x - 20
			
			edt_nom_facade.width 	= 	largeur_fenetre - ( 2* largeur_bord	+ 2 * largeur_btn   )
			btn_enregistrer.pos.x 	= 	edt_nom_facade.width 	+  edt_nom_facade.pos.x
			btn_charger.pos.x 			= 	largeur_btn 	+  btn_enregistrer.pos.x
			
			ddl_murs.width 			= 	ddl_mode.width  = 	largeur_fenetre  - ( ddl_murs.pos.x + largeur_bord )
			lbx_sequence.width 		= ddl_murs.width 	 - largeur_btn
			
			lbx_sequence.height 		= _taille.y - ( lbx_sequence.pos.y + largeur_btn + 2 * largeur_bord )
			
			
-- 			btn_annuler.pos.x		= largeur_fenetre - (  118 + largeur_bord )
-- 			btn_annuler.pos.y 		= btn_valider.pos.y 	= _taille.y - (  largeur_btn +  largeur_bord )
			
			btn_monter.pos.x			=	btn_descendre .pos.x		=	lbx_sequence.pos.x + lbx_sequence.width
			btn_dupliquer_composant.pos.y 			= lbx_sequence.pos.y + lbx_sequence.height - 44
			btn_instancier_composant.pos.y 		= lbx_sequence.pos.y + lbx_sequence.height - 29
			btn_supprimer_composant.pos.y 		= lbx_sequence.pos.y + lbx_sequence.height - 14
			
			grp_prop.pos.x 				= ddl_murs.pos.x + ddl_murs.width + largeur_bord 
			grp_prop.height 				= _taille.y - ( grp_prop.pos.y + largeur_bord )
			subroll_parametres.pos.x 	= grp_prop.pos.x + 8
			subroll_parametres.height 	= grp_prop.height - 23
			
			btn_valider.pos.y 			= _taille.y - 35
			btn_annuler.pos.y 		=  _taille.y - 35
		)
		fn initialiser 			_plug 		=(
			
			m_plug 		= _plug
			
			m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Bâtiment | Façade"
			m_titre.setCouleur (color 255 255 255 )
			
			-- le bouton fermer --
-- 			ui_btnFermer.pos = [roll_urba_editeurFacades.width - 20,0]
-- 			ui_btnFermer.bitmap = icos_fermer[1]	
			
			-- la fenetre ----
			redimensionnerFenetre  (getDialogSize	roll_urba_editeurFacades)
			
			
			----- gestion des boutons de creation de composant -----------
			local mgr_compos = m_plug.core.get_mgr_composants ()
			local models_compos = mgr_compos.get_modeles ()
			local i =1
			local j = 1
			for  model_compo in  models_compos	do (
				if  model_compo.est_editable  () do (
					btns_ajouter_composant[i].visible 		= true
					btns_ajouter_composant[i].text 			= model_compo.titre
					btns_ajouter_composant[i].tooltip 		= model_compo.tooltip
					btns_ids_models[i] = j
					i+=1
				)
				j += 1
			)
			
		)
		fn set_facade		_facade 	=(
			local mgr_facades 	= m_plug.core.get_mgr_facades ()
			
			m_facade_initiale 		= 	_facade
			m_facade_courante 	= 	mgr_facades.dupliquer 		m_facade_initiale
			if m_facade_courante.sequence.count>0 do (
				lbx_sequence.selection  = 1
				m_composant_courant = m_facade_courante.sequence[ 	1 ]
			)
			actualiser ()
		)
		
		
		
		
		
		fn ajouter_composant	_IDmodelCompo	=(
			debug "ajouter composant"
-- 			debug "lbx_sequence.selection AVT" var:lbx_sequence.selection 
			local sequence_selectionBack = lbx_sequence.selection 
			m_composant_courant	=	m_plug.core.creer_composant	m_facade_courante		_IDmodelCompo		position:(lbx_sequence.selection +1)
			
-- 			debug "lbx_sequence.selection APRS" var:lbx_sequence.selection 
			remplir_lbx_sequence ()
			
			lbx_sequence.selection = sequence_selectionBack +1
			actualiser ()
		)
		
		fn dupliquer_composant =(
			
			local mgr_composants 	= m_plug.core.get_mgr_composants ()
			
			local composantDuplique =  	mgr_composants.dupliquer 		m_composant_courant
			m_facade_courante.ajouter_composant	composantDuplique	position:(lbx_sequence.selection +1)
			m_composant_courant = composantDuplique
			remplir_lbx_sequence ()
			
			lbx_sequence.selection += 1
			
			
			actualiser ()
		)
		fn instancier_composant =(
			
			
			
			m_composant_courant =  	m_facade_courante.instancier_composant	lbx_sequence.selection 
			
			m_composant_courant = composantDuplique
			remplir_lbx_sequence ()
			
			lbx_sequence.selection += 1
			
			
			actualiser ()
		)
		fn enregistrer =(
			local mgr_facades 	= m_plug.core.get_mgr_facades ()
			
			
			m_facade_initiale = mgr_facades.dupliquer 	 m_facade_courante	cible:m_facade_initiale
			m_facade_initiale.enregistrer 	m_plug
			
		)
		
		
		
		
		
		
	----------------- Evenements ------------------------------------------------------------------------
						
	on roll_urba_editeurFacades resized _taille 				do
		redimensionnerFenetre 	_taille
	on roll_urba_editeurFacades moved dest do
		m_plug.core.set_roll_editeurDeFacade_position	dest
	on roll_urba_editeurFacades lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba_editeurFacades lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba_editeurFacades mouseMove _pos 	do
		m_drag.suivreSouris ()
	
	
	
	on edt_nom_facade entered txt 	do
	(
				m_facade_courante.nom 	=	txt
		m_changement = true
			)
	on spn_etages changed val 	do
	(
				m_facade_courante.etages_min 	= 	val
		m_changement = true
			)
	on spn_etagesMax changed val 	do
	(
				m_facade_courante.etages_max 	= 	val
		m_changement = true
			)
	on spn_longueur_min changed val 	do
	(
				m_facade_courante.longueur_min 	= 	val
		m_changement = true
			)
	on spn_longueur_max changed val 	do
	(
				m_facade_courante.longueur_max 	= 	val
		m_changement = true
			)
	on chk_longueur_max changed state do
	(
				m_facade_courante.longueur_max_use 	= 	state	
		m_changement = true
				actualiser ()
			)
	on chk_longueur_min changed state do
	(
				m_facade_courante.longueur_min_use 	= 	state		
		m_changement = true
				actualiser ()
			)
	on ddl_murs selected sel	 do
	(
				m_facade_courante.murs 	= 	sel
		m_changement = true
			)
	on chk_etagesMax changed state do
	(
				m_facade_courante.etages_max_use 	= 	state		
		m_changement = true
				actualiser ()
			)
	on lbx_sequence selected arg do
	(
				m_composant_courant = m_facade_courante.sequence[ 	arg ]
		m_changement = true
				actualiser ()
			)
	on btn_monter pressed do
	(
				m_facade_courante.composant_monter 	 lbx_sequence.selection
				lbx_sequence.selection -= 1
		m_changement = true
				actualiser ()
			)
	on btn_descendre pressed do
	(
				m_facade_courante.composant_descendre 	 lbx_sequence.selection
				lbx_sequence.selection += 1
		m_changement = true
				actualiser ()
			)
	on ddl_mode selected sel	 do
	(
				m_facade_courante.mode 	= 	sel
		m_changement = true
			)
	on chk_etages changed state do
	(
				m_facade_courante.etages_min_use 	= 	state		
				actualiser ()
		m_changement = true
			)
	on btn_supprimer_composant pressed do
	(
				if queryBox "Supprimer le composant" do (
					m_plug.core.supprimer_composant 	m_facade_courante		lbx_sequence.selection
					actualiser ()
		m_changement = true
				)
			)
	on btn_ajouter_composant_1 pressed do (
		ajouter_composant	btns_ids_models[1]
		m_changement = true
	)
	on btn_ajouter_composant_2 pressed do (
		ajouter_composant	btns_ids_models[2]
		m_changement = true
	)
	on btn_ajouter_composant_3 pressed do (
		ajouter_composant	btns_ids_models[3]
		m_changement = true
	)
	on btn_ajouter_composant_4 pressed do (
		ajouter_composant	btns_ids_models[4]
		m_changement = true
	)
	on btn_ajouter_composant_5 pressed do (
		ajouter_composant	btns_ids_models[5]
		m_changement = true
	)
	on btn_ajouter_composant_6 pressed do (
		ajouter_composant	btns_ids_models[6]
		m_changement = true
	)
	
	  
	on btn_dupliquer_composant pressed do (
		dupliquer_composant ()
		m_changement = true
	)
	on btn_instancier_composant pressed do (
		instancier_composant ()
		m_changement = true
	)
		
	
	on btn_valider pressed do
	(
				enregistrer ()
				m_plug.core.facadeEditeur_fermer 	()
				m_plug.core.actualiser ()
				m_plug.actualiser_rollouts ()
			)
	on btn_annuler pressed do
	(
				m_plug.core.facadeEditeur_fermer 	()			
			)
)
	
	
	
	
	
	
	
	
	
