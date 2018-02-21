
	
	
	
	

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
		
		--- les parametres courants ------------
		local m_facade_initiale
		local m_facade_courante
		local m_composant_courant
		
		--- rollout	---------
		local largeur_params 		= 235
		
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
		
		listbox 'lbx_sequence' "" pos:[91,124] width:137 height:9 align:#left
		
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
		
		button 'btn_dupliquer_composant' "Dupliquer" pos:[10,216] width:75 height:16 toolTip:"Supprimer le composant" align:#left
		button 'btn_supprimer_composant' "Supprimer" pos:[10,231] width:75 height:16 toolTip:"Supprimer le composant" align:#left
		
		button 'btn_ajouter_composant_1' "btn1" pos:[10,123] width:75 height:16  	align:#left		visible:false
		button 'btn_ajouter_composant_2' "btn2" pos:[10,138] width:75 height:16  	align:#left		visible:false
		button 'btn_ajouter_composant_3' "btn3" pos:[10,153] width:75 height:16 	align:#left		visible:false
		button 'btn_ajouter_composant_4' "btn4" pos:[10,168] width:75 height:16  	align:#left		visible:false
		button 'btn_ajouter_composant_5' "btn5" pos:[10,183] width:75 height:16 	align:#left		visible:false
		button 'btn_ajouter_composant_6' "btn6" pos:[10,197] width:75 height:16  	align:#left		visible:false
		
		button 'btn_valider' "Valider" pos:[11,271] width:75 height:21 toolTip:"Valider la façade" align:#left
		button 'btn_annuler' "Annuler" pos:[91,271] width:75 height:21 toolTip:"Annuler les changements" align:#left
		
		local		btns_ajouter_composant	=#( btn_ajouter_composant_1, btn_ajouter_composant_2, btn_ajouter_composant_3, btn_ajouter_composant_4, btn_ajouter_composant_5, btn_ajouter_composant_6 )
		
		------------  Fonctions	----------------------------------------------------------------------------------
		fn actualiser 							=(
			
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
			
			lbx_sequence.items				=	m_facade_courante.get_composants_noms ()
			
			--- le subRollout des composants	-------
			for rollAVirer in subroll_parametres.rollouts do
				removeSubRollout	subroll_parametres	rollAVirer
			if m_composant_courant != undefined do (
				addSubRollout	subroll_parametres ( m_composant_courant.get_dialog () )
				m_composant_courant.initialiser_dialog	 	roll_urba_editeurFacades
			)
		)
		fn redimensionnerFenetre 		_taille 	=(
			
			local largeur_min_ferme 	= 255
			local largeur_min_ouvert 	= largeur_min_ferme + largeur_params			
			local largeur_min 				= 	largeur_min_ouvert
			local hauteur_min 			= 255
				
			local largeur_btn 		= 17
			local largeur_bord 		= edt_nom_facade.pos.x
			
			if 	_taille.x < largeur_min do 
				_taille.x =  largeur_min
			if 	_taille.y < 300 do 
				_taille.y =  300
			roll_urba_editeurFacades.width 	= _taille.x
			roll_urba_editeurFacades.height 	= _taille.y
			
			m_plug.core.set_roll_editeurDeFacade_taille	_taille
			
			local largeur_fenetre 	= 	_taille.x - largeur_params
			
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
			btn_dupliquer_composant.pos.y 			= lbx_sequence.pos.y + lbx_sequence.height - 29
			btn_supprimer_composant.pos.y 		= lbx_sequence.pos.y + lbx_sequence.height - 14
			
			grp_prop.pos.x 				= ddl_murs.pos.x + ddl_murs.width + largeur_bord 
			grp_prop.height 				= _taille.y - ( grp_prop.pos.y + largeur_bord )
			subroll_parametres.pos.x 	= grp_prop.pos.x + 8
			subroll_parametres.height 	= grp_prop.height - 23
			
			btn_valider.pos.y 			= _taille.y - 25
			btn_annuler.pos.y 		=  _taille.y - 25
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
			for  i = 1 to models_compos.count	do (
				local  model_compo = models_compos[i]
				btns_ajouter_composant[i].visible 		= true
				btns_ajouter_composant[i].text 			= model_compo.titre
				btns_ajouter_composant[i].tooltip 		= model_compo.tooltip
				
			)
			
		)
		
		
		
		
		fn set_facade		_facade 	=(
			local mgr_facades 	= m_plug.core.get_mgr_facades ()
			
			m_facade_initiale 		= 	_facade
			m_facade_courante 	= 	mgr_facades.dupliquer 		m_facade_initiale
			
			debug "ajouter set_facade"
			debug "m_facade_initiale" 		var:m_facade_initiale
			debug "m_facade_courante" 	var:m_facade_courante
			
			actualiser ()
		)
		fn ajouter_composant	_IDmodelCompo	=(
			debug "ajouter composant"
			m_composant_courant	=	m_plug.core.creer_composant	m_facade_courante		_IDmodelCompo		position:lbx_sequence.selection
			
			debug "m_facade_initiale.sequence" 		var:m_facade_initiale.sequence
			debug "m_facade_courante.sequence" 	var:m_facade_courante.sequence
			
			actualiser ()
		)
		
/* 		
		---- Gere l'état du bouton  -----
		fn etatBtnFermer		_etat 	=(
			case _etat of (
				#Repos : 	ui_btnFermer.bitmap = icos_fermer[1]	
				#Survol : 	ui_btnFermer.bitmap = icos_fermer[2]	
				#Press : 	ui_btnFermer.bitmap = icos_fermer[3]	
			)
		)
		 */
		
		
		
		
		--------- EVENEMENTS	----------------------------------------------------------------------------------------------
		on btn_valider	 pressed do (
			
			local mgr_facades 	= m_plug.core.get_mgr_facades ()
			
			
			m_facade_initiale = mgr_facades.dupliquer 	 m_facade_courante	cible:m_facade_initiale
			m_facade_initiale.enregistrer 	m_plug
			m_plug.core.facadeEditeur_fermer 	()
			m_plug.core.actualiser ()
			m_plug.actualiser_rollouts ()
		)
		on btn_annuler	 pressed do (
			m_plug.core.facadeEditeur_fermer 	()			
		)
		
		on btn_ajouter_composant_1 pressed do	ajouter_composant	1
		on btn_ajouter_composant_2 pressed do	ajouter_composant	2
		on btn_ajouter_composant_3 pressed do	ajouter_composant	3
		on btn_ajouter_composant_4 pressed do	ajouter_composant	4
		on btn_ajouter_composant_5 pressed do	ajouter_composant	5
		on btn_ajouter_composant_6 pressed do	ajouter_composant	6
		
		--------------- EVENEMENTS ------------------
		----- Fenetre ---------------------------------
		on roll_urba_editeurFacades resized _taille 				do
			redimensionnerFenetre 	_taille
		on roll_urba_editeurFacades lbuttondown 	_pos 	do
			m_drag.demarrer ()
		on roll_urba_editeurFacades lbuttonup 		_pos 	do
			m_drag.arreter ()
		on roll_urba_editeurFacades mouseMove 	_pos 	do
			m_drag.suivreSouris ()
		
-- 		on roll_urba_editeurFacades close do
-- 			m_plug.core.actualiser ()
		
		on roll_urba_editeurFacades moved 	dest do
			m_plug.core.set_roll_editeurDeFacade_position	dest
		
		on lbx_sequence selected arg do (
			m_composant_courant = m_facade_courante.sequence[ 	arg ]
			actualiser ()
		)
		/* 
		on ui_btnFermer mouseover do
			etatBtnFermer #Survol
		on ui_btnFermer mouseout do
			etatBtnFermer #Repos
		on ui_btnFermer mouseDown do
			etatBtnFermer #Press
		on ui_btnFermer mouseUp do
			etatBtnFermer #Repos
		on ui_btnFermer click do
			m_plug.core.facadeEditeur_fermer 	()
		
		
		 */
		
		--- parametres ---------------------
		on edt_nom_facade entered txt 	do (
			m_facade_courante.nom 	=	txt
		)
		on ddl_mode selected sel	 do		(
			m_facade_courante.mode 	= 	sel
		)
		
		on ddl_murs selected sel	 do		(
			m_facade_courante.murs 	= 	sel
		)
		
		
		on chk_etages changed state do		(
			m_facade_courante.etages_min_use 	= 	state		
			actualiser ()
		)
		on spn_etages	 changed val 	do		(
			m_facade_courante.etages_min 	= 	val
		)
		on chk_etagesMax changed state do		(
			m_facade_courante.etages_max_use 	= 	state		
			actualiser ()
		)
		on spn_etagesMax	 changed val 	do		(
			m_facade_courante.etages_max 	= 	val
		)
		
		
		on spn_longueur_min changed val 	do		(
			m_facade_courante.longueur_min 	= 	val
		)
		on spn_longueur_max changed val 	do		(
			m_facade_courante.longueur_max 	= 	val
		)
		on chk_longueur_max changed state do		(
			m_facade_courante.longueur_max_use 	= 	state	
			actualiser ()
		)
		on chk_longueur_min changed state do		(
			m_facade_courante.longueur_min_use 	= 	state		
			actualiser ()
		)
		
		/* 
		on btn_ajouter_espacement pressed do
			ajouter_composant	#Espacement
		
		on btn_ajouter_murPlein pressed do
			ajouter_composant	#MurPlein */
		/* 
		--- Sequence	---
		sequence					=	#(),
		sequence_longueur		=	0,
		 */
		
		/* 
		on lbx_sequence selected _sel 	do
		(
							m_composant_courant = m_facade_courante.sequence[_sel]
							afficher_proprietes ()
							--actualiser ()
						)
		on btn_dupliquer_composant pressed do
		(
			format "rollout ---->ajouter_composant\n"
			m_composant_courant = m_prt.dupliquer_composant		lbx_sequence.selection	 	 
			actualiser()
			
			lbx_sequence.selection	+= 1			
							actualiser ()
						)
		on btn_monter pressed do
		(
							local id_orig = lbx_sequence.selection
							if id_orig >1 do (
								local itemTmp = m_facade_courante.sequence[id_orig]
								deleteItem	m_facade_courante.sequence	id_orig
								insertItem	itemTmp		m_facade_courante.sequence	(id_orig-1)
								lbx_sequence.selection	-= 1
							)
							actualiser ()
						)
		on btn_descendre pressed do
		(
							local id_orig = lbx_sequence.selection
							if id_orig < m_facade_courante.sequence.count do (
								local itemTmp = m_facade_courante.sequence[id_orig]
								deleteItem	m_facade_courante.sequence	id_orig
								insertItem	itemTmp		m_facade_courante.sequence	(id_orig+1)
								lbx_sequence.selection	+= 1
							)
							actualiser ()
						)
		
		on btn_ajouter_espacement pressed do
			ajouter_composant	#Parametrique		param_type:#Espacement
		 */
		/*
		----  FENETRE  ----------
		fn actualiser = (
			
			edt_nom_facade.text 			= m_facade_courante.nom
			
			chk_etages.checked				= m_facade_courante.etages_use_min
			spn_etages.indeterminate 		= not m_facade_courante.etages_use_min	
			spn_etages.enabled 				= m_facade_courante.etages_use_min	
			if not spn_etages.indeterminate do
				spn_etages.value				= m_facade_courante.etages_nbre_min
			
			chk_etagesMax.checked		= m_facade_courante.etages_use_max
			spn_etagesMax.indeterminate = not m_facade_courante.etages_use_max	
			spn_etagesMax.enabled		= m_facade_courante.etages_use_max			
			if not spn_etagesMax.indeterminate do
				spn_etagesMax.value		= m_facade_courante.etages_nbre_max	
			
			
			
			chk_longueur_min.checked				= m_facade_courante.longueur_use_min
			spn_longueur_min.indeterminate 		= not m_facade_courante.longueur_use_min	
			spn_longueur_min.enabled 			= m_facade_courante.longueur_use_min	
			if not spn_longueur_min.indeterminate do
				spn_longueur_min.value				= m_facade_courante.longueur_nbre_min
			
			chk_longueur_max.checked				= m_facade_courante.longueur_use_max
			spn_longueur_max.indeterminate 		= not m_facade_courante.longueur_use_max	
			spn_longueur_max.enabled 				= m_facade_courante.longueur_use_max	
			if not spn_longueur_max.indeterminate do
				spn_longueur_max.value				= m_facade_courante.longueur_nbre_max
			
			
			ddl_murs.selection 				= m_facade_courante.murs
			ddl_mode.selection 				= m_facade_courante.mode
			
			local itemsTmp = #()
			local est_dansBalcon = false
			for comp in m_facade_courante.sequence		do	(
				local affichage = ""
				local suffix		= ""
				
-- 				format "comp.type : %\n" comp.type
				
				if comp.type == #Parametrique do (
					
					
				if classof comp.param[1] == str_facadeParam_balconFin do est_dansBalcon = false
					
-- 				format "classof comp.param[1] : %\n" ( classof comp.param[1] )
					case classof comp.param[1] of (
						str_facadeParam_balcon:			suffix = "|-----   Balcon  " + comp.param[1].largeur as string  + " cm"
						str_facadeParam_balconFin:		suffix = "|-----   Balcon"
						str_facadeParam_espacement:	suffix = "<--->"
						str_facadeParam_murPlein:		suffix = "|-----|  " + comp.longueur as string  + " cm"
						str_facadeParam_baie:				suffix = "|  #  |  Baie  " + comp.longueur as string  + " cm"
					)
				)
				if est_dansBalcon do affichage += "           "
				affichage += suffix --comp.nom
				append itemsTmp affichage
				
				if classof comp.param[1] == str_facadeParam_balcon do est_dansBalcon = true
					
				
			)
			lbx_sequence.items =  itemsTmp
			
			btn_supprimer_composant.enabled = lbx_sequence.selection != 0
			
			try dialog_modele.actualiser () 			catch ()
			try dialog_longueurFixe.actualiser () 	catch ()
			
			
			
			
			
		)
		fn afficher_proprietes 	=(
			if m_composant_courant != undefined do 
				if m_composant_courant.type == #parametrique do (
					if subroll_parametres.rollouts.count	>0 do
						removeSubRollout 	subroll_parametres	subroll_parametres.rollouts[1]
					AddSubRollout 		subroll_parametres	( m_composant_courant.param[1].dialog )
					m_composant_courant.param[1].initialiser_dialog 	roll_urba_editeurFacades
				)
			)
		

		
		
		
		----  interface ----------
		fn ajouter_composant	type		param_type:#sans 	=(
			
			format "rollout ---->ajouter_composant\n"
			m_composant_courant = m_prt.creer_composant		lbx_sequence.selection	 type		 	param_type:param_type
			actualiser()
			
			lbx_sequence.selection	+= 1
		)
		
		
						
			
		on roll_urba_editeurFacades close do	(			
							try destroyDialog  dialog_modele 			catch ()
							try destroyDialog  dialog_longueurFixe 	catch ()
						)
		
		
		on edt_nom_facade entered txt 	do
		(
							m_facade_courante.nom 					=	txt		
							actualiser ()
						)
		on spn_etages 	changed val 	do
		(
							m_facade_courante.etages_nbre_min 	= 	val
							actualiser ()
						)
		on spn_etagesMax changed val 	do
		(
							m_facade_courante.etages_nbre_max 	= 	val
							actualiser ()
						)
		on spn_longueur_min changed val 	do
		(
							m_facade_courante.longueur_nbre_min 	= 	val
							actualiser ()
						)
		on spn_longueur_max changed val 	do
		(
							m_facade_courante.longueur_nbre_max 	= 	val
							actualiser ()
						)
		on chk_longueur_max changed state do
		(
							m_facade_courante.longueur_use_max 	= 	state		
							actualiser ()
						)
		on chk_longueur_min changed state do
		(
							m_facade_courante.longueur_use_min 	= 	state		
							actualiser ()
						)
		on ddl_murs selected sel	 do
		(
							m_facade_courante.murs 	= 	sel
							actualiser ()
						)
		on chk_etagesMax changed state do
		(
							m_facade_courante.etages_use_max 	= 	state		
							actualiser ()
						)
		on lbx_sequence selected _sel 	do
		(
							m_composant_courant = m_facade_courante.sequence[_sel]
							afficher_proprietes ()
							--actualiser ()
						)
		on btn_dupliquer_composant pressed do
		(
			format "rollout ---->ajouter_composant\n"
			m_composant_courant = m_prt.dupliquer_composant		lbx_sequence.selection	 	 
			actualiser()
			
			lbx_sequence.selection	+= 1			
							actualiser ()
						)
		on btn_monter pressed do
		(
							local id_orig = lbx_sequence.selection
							if id_orig >1 do (
								local itemTmp = m_facade_courante.sequence[id_orig]
								deleteItem	m_facade_courante.sequence	id_orig
								insertItem	itemTmp		m_facade_courante.sequence	(id_orig-1)
								lbx_sequence.selection	-= 1
							)
							actualiser ()
						)
		on btn_descendre pressed do
		(
							local id_orig = lbx_sequence.selection
							if id_orig < m_facade_courante.sequence.count do (
								local itemTmp = m_facade_courante.sequence[id_orig]
								deleteItem	m_facade_courante.sequence	id_orig
								insertItem	itemTmp		m_facade_courante.sequence	(id_orig+1)
								lbx_sequence.selection	+= 1
							)
							actualiser ()
						)
		on ddl_mode selected sel	 do
		(
							m_facade_courante.mode 	= 	sel
							actualiser ()
						)
		on chk_etages changed state do
		(
							m_facade_courante.etages_use_min 	= 	state		
							actualiser ()
						)
		on btn_ajouter_espacement pressed do
			ajouter_composant	#Parametrique		param_type:#Espacement
		on btn_annuler pressed do
		(
					m_prt.fermer ()
				)
		on btn_valider pressed do
		(
					m_prt.valider_modifs 	()
					m_prt.fermer  	quiet:true
				)
		on btn_ajouter_murPlein pressed do
			ajouter_composant	#Parametrique		param_type:#MurPlein
		on btn_ajouter_balcon pressed do
			ajouter_composant	#Parametrique		param_type:#Balcon
		on btn_ajouter_baieTablette pressed do
			ajouter_composant	#Parametrique		param_type:#BaieTablette
		on btn_supprimer_composant pressed do
		(
							local id = lbx_sequence.selection
							if id != 0 do
								deleteItem	m_facade_courante.sequence	id					
							actualiser ()
						)
						
						
						*/
						
						
						
) ------- fin rollout -------------------
	
	
	
	
	
	
	
	
	
	