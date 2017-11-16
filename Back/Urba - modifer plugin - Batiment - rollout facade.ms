
	
	
	
	
	
	------------------------------------------------------------------------------
	----------	Fenetre								 -------------------------
	------------------------------------------------------------------------------
	rollout roll_urba_editeurFacades "urba_editeurFacades" width:500 height:307
	(
		
		include "$userScripts\cp - GLOBAL\UI.ms"
		include "$userScripts\cp - GLOBAL\DragDialog.ms"
		include "$userScripts\cp - GLOBAL\Mgr - ListView.ms"
		

		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_prt				---- pointeur vers la structure de controle ----
-- 		local m_cible			---  le plugin cilbé
		local m_facade
		local m_composant_courant
		
		---- Structures ----
		local m_drag			---- la structure gerant le drag de la fenetre ----
		
		--- ui  virtuel perso ---
		local m_titre		
		
		-- les fenetre secondaires ---
		local dialog_modele, dialog_longueurFixe
		local largeur_params 		= 235
		
		--- images bouton fermer ---
		local murs_types 	= #("Gouttereaux + Pignons", "Gouttereaux", "Pignons")
		local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" 			-- Pressé ----
										)
		
		
		local note_etagesMinMax = "\n0 : RdC\nValeurs négative pour compter les étages en descendant, à partir du dernier (-1: dernier étage)"
-- 		local note_etagesMinMax = ""
		
		local lv_mgr
		
		------------  UI	----------------------------------------------------------------------------------		
		---- le bouton pour fermer la fenetre ----
		ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left

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
	-- 		dotNetControl 'lbx_sequence'	 "System.Windows.Forms.ListView" pos:[91,109] 	width:490 height:190 
			
		button 'btn_dupliquer_composant' "Dupliquer" pos:[10,216] width:75 height:16 toolTip:"Supprimer le composant" align:#left
			
		label 'lbl23' "Séquence:" pos:[11,105] width:52 height:15 align:#left
			
		button 'btn_enregistrer' "S" pos:[224,24] width:19 height:19 toolTip:"Sauvegarder preset." align:#left
		button 'btn_charger' "O" pos:[206,24] width:19 height:19 toolTip:"Ouvrir preset." align:#left
			
		button 'btn_monter' "/\\" pos:[228,123] width:16 height:25 toolTip:"Monter le composant." align:#left
		button 'btn_descendre' "\/" pos:[228,147] width:16 height:25 toolTip:"Descendre le composant." align:#left
		dropdownList 'ddl_mode' "" pos:[90,103] width:154 height:21 items:#("Répéter", "Etrirer", "Centrer", "Espacer") selection:3 align:#left
		checkbutton 'chk_etages' "" pos:[90,53] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
		
		button 'btn_ajouter_espacement' "Espacement" pos:[10,123] width:75 height:16 toolTip:"Ajouter un espacement. Mur plein de longueur varirable, répartis par facade, entre tous les espacement" align:#left
-- 		button 'btn_ajouter_modele' "Modèle 3D" pos:[10,193] width:75 height:16 toolTip:"Ajouter un modèle 3D." align:#left
		
		button 'btn_annuler' "Annuler" pos:[127,257] width:118 height:21 align:#left
		button 'btn_valider' "Valider" pos:[10,257] width:118 height:21 align:#left
		
		label 'lbl95' "Etages:" pos:[12,54] width:43 height:15 align:#left
		
		button 'btn_ajouter_murPlein' "Mur" pos:[10,138] width:75 height:16 toolTip:"Ajouter un mur plein de longueur fixe." align:#left
		
-- 		button 'btn_ajouter_baie' "Baie simple" pos:[10,156] width:75 height:16 toolTip:"Ajouter une baie." align:#left
		button 'btn_ajouter_balcon' "Balcon" pos:[10,168] width:75 height:16 toolTip:"Ajouter un modèle 3D." align:#left

		subRollout 'subroll_parametres' "Parametres" pos:[267,43] width:210 height:208 align:#left
		
-- 		checkbutton 'btn_parametres' "" pos:[228,215] width:16 height:16 toolTip:"Ouvrir les paramètres du composant." align:#left
		GroupBox 'grp_prop' "Propriétés" pos:[255,25] width:225 height:238 align:#left
		
		button 'btn_ajouter_baieTablette' "Baie" pos:[10,153] width:75 height:16 toolTip:"Ajouter une baie." align:#left
		
		button 'btn_supprimer_composant' "Supprimer" pos:[10,231] width:75 height:16 toolTip:"Supprimer le composant" align:#left
		
		------------  Fonctions	----------------------------------------------------------------------------------
		---- Gere l'état du bouton  -----
		fn etatBtnFermer		_etat =(
			case _etat of (
				#Repos : 	ui_btnFermer.bitmap = icos_fermer[1]	
				#Survol : 	ui_btnFermer.bitmap = icos_fermer[2]	
				#Press : 	ui_btnFermer.bitmap = icos_fermer[3]	
			)
		)
		
		----  FENETRE  ----------
		fn actualiser = (
			
			edt_nom_facade.text 			= m_facade.nom
			
			chk_etages.checked				= m_facade.etages_use_min
			spn_etages.indeterminate 		= not m_facade.etages_use_min	
			spn_etages.enabled 				= m_facade.etages_use_min	
			if not spn_etages.indeterminate do
				spn_etages.value				= m_facade.etages_nbre_min
			
			chk_etagesMax.checked		= m_facade.etages_use_max
			spn_etagesMax.indeterminate = not m_facade.etages_use_max	
			spn_etagesMax.enabled		= m_facade.etages_use_max			
			if not spn_etagesMax.indeterminate do
				spn_etagesMax.value		= m_facade.etages_nbre_max	
			
			
			
			chk_longueur_min.checked				= m_facade.longueur_use_min
			spn_longueur_min.indeterminate 		= not m_facade.longueur_use_min	
			spn_longueur_min.enabled 			= m_facade.longueur_use_min	
			if not spn_longueur_min.indeterminate do
				spn_longueur_min.value				= m_facade.longueur_nbre_min
			
			chk_longueur_max.checked				= m_facade.longueur_use_max
			spn_longueur_max.indeterminate 		= not m_facade.longueur_use_max	
			spn_longueur_max.enabled 				= m_facade.longueur_use_max	
			if not spn_longueur_max.indeterminate do
				spn_longueur_max.value				= m_facade.longueur_nbre_max
			
			
			ddl_murs.selection 				= m_facade.murs
			ddl_mode.selection 				= m_facade.mode
			
			local itemsTmp = #()
			local est_dansBalcon = false
			for comp in m_facade.sequence		do	(
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
		fn redimensionnerFenetre 		_taille 	=(
			local largeur_min_ferme 	= 255
			local largeur_min_ouvert 	= largeur_min_ferme + largeur_params			
			local largeur_min 			= /* if btn_parametres.checked then largeur_min_ouvert else  */	largeur_min_ouvert
			local hauteur_min 			= 255
				
			local largeur_btn 		= 17
			local largeur_bord 		= edt_nom_facade.pos.x
			
			if 	_taille.x < largeur_min do 
				_taille.x =  largeur_min
			if 	_taille.y < 255 do 
				_taille.y =  255
			roll_urba_editeurFacades.width 	= _taille.x
			roll_urba_editeurFacades.height 	= _taille.y
			
			local largeur_fenetre = 	_taille.x - largeur_params	/* if btn_parametres.checked then 
												_taille.x - largeur_params
											else 
												_taille.x  */
			
			
			
			ui_btnFermer.pos.x		= 	_taille.x - 20
			
			edt_nom_facade.width 	= 	largeur_fenetre - ( 2* largeur_bord	+ 2 * largeur_btn   )
			btn_enregistrer.pos.x 	= 	edt_nom_facade.width 	+  edt_nom_facade.pos.x
			btn_charger.pos.x 		= 	largeur_btn 	+  btn_enregistrer.pos.x
			
			ddl_murs.width 			= 	ddl_mode.width  = 	largeur_fenetre  - ( ddl_murs.pos.x + largeur_bord )
			lbx_sequence.width 		= ddl_murs.width 	 - largeur_btn
			
			lbx_sequence.height 	= _taille.y - ( lbx_sequence.pos.y + largeur_btn + 2 * largeur_bord )
			
			
			btn_annuler.pos.x		= largeur_fenetre - (  118 + largeur_bord )
			btn_annuler.pos.y 		= btn_valider.pos.y 	= _taille.y - (  largeur_btn +  largeur_bord )
			
			btn_monter.pos.x			=	btn_descendre .pos.x		=	/* btn_parametres.pos.x 	=  */lbx_sequence.pos.x + lbx_sequence.width
			btn_supprimer_composant.pos.y 	/* =	btn_parametres.pos.y 	 */	= lbx_sequence.pos.y + lbx_sequence.height - 14
			
			grp_prop.pos.x 				= ddl_murs.pos.x + ddl_murs.width + largeur_bord 
			grp_prop.height 				= _taille.y - ( grp_prop.pos.y + largeur_bord )
			subroll_parametres.pos.x 	= grp_prop.pos.x + 8
			subroll_parametres.height 	= grp_prop.height - 23
			
		)
		fn initialiser = (
			
			m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Bâtiment | Façade"
			m_titre.setCouleur (color 255 255 255 )
			
			-- le bouton fermer --
			ui_btnFermer.pos = [roll_urba_editeurFacades.width - 20,0]
			ui_btnFermer.bitmap = icos_fermer[1]	
			
			
			
			-- la fenetre ----
			redimensionnerFenetre  (getDialogSize	roll_urba_editeurFacades)
			actualiser()
		)

		
		
		
		----  interface ----------
		fn ajouter_composant	type		param_type:#sans 	=(
			
			format "rollout ---->ajouter_composant\n"
			m_composant_courant = m_prt.creer_composant		lbx_sequence.selection	 type		 	param_type:param_type
			actualiser()
			
			lbx_sequence.selection	+= 1
		)
		
		
		
		
		
		------------  Evenements	----------------------------------------------------------------------------------	
		---- rollout	--------------------------
		
		
		
		---- btn fermer	--------------------------
		
				
		---- Interface	--------------------------
		
		
		
		
		--- sequence -----------------------
		
		
		
		
		
				
				
		------ COMPOSANTS -------------
-- 		on btn_ajouter_murPlein 	pressed 	do	ajouter_composant	#LongueurFixe	
		
		
		
		
		
		
		---- Validation / Annulation	--------------------------
				
				
						
						
						
						
						
						
		/* on lbx_sequence doubleClicked _sel 	do
		(
							m_composant_courant = m_facade.sequence[_sel]	
							if m_composant_courant.type == #Modele then
								ouvrir_fenetre_modele 	()
							else if m_composant_courant.type ==#LongueurFixe then
								ouvrir_fenetre_longueurFixe()
							actualiser ()
						) */
		
		
		
		
		
						
						
						
			
		on roll_urba_editeurFacades close do	(			
							try destroyDialog  dialog_modele 			catch ()
							try destroyDialog  dialog_longueurFixe 	catch ()
						)
		on roll_urba_editeurFacades resized _taille 	do
			redimensionnerFenetre 	_taille
		on roll_urba_editeurFacades lbuttondown _pos 		do
			m_drag.demarrer ()
		on roll_urba_editeurFacades lbuttonup _pos 		do
			m_drag.arreter ()
		on roll_urba_editeurFacades mouseMove _pos 		do
			m_drag.suivreSouris ()
		
		on ui_btnFermer mouseover do
			etatBtnFermer #Survol
		on ui_btnFermer mouseout do
			etatBtnFermer #Repos
		on ui_btnFermer mouseDown do
			etatBtnFermer #Press
		on ui_btnFermer mouseUp do
			etatBtnFermer #Repos
		on ui_btnFermer click do
			m_prt.fermer 	()
		
		
		
		on edt_nom_facade entered txt 	do
		(
							m_facade.nom 					=	txt		
							actualiser ()
						)
		on spn_etages changed val 	do
		(
							m_facade.etages_nbre_min 	= 	val
							actualiser ()
						)
		on spn_etagesMax changed val 	do
		(
							m_facade.etages_nbre_max 	= 	val
							actualiser ()
						)
		on spn_longueur_min changed val 	do
		(
							m_facade.longueur_nbre_min 	= 	val
							actualiser ()
						)
		on spn_longueur_max changed val 	do
		(
							m_facade.longueur_nbre_max 	= 	val
							actualiser ()
						)
		on chk_longueur_max changed state do
		(
							m_facade.longueur_use_max 	= 	state		
							actualiser ()
						)
		on chk_longueur_min changed state do
		(
							m_facade.longueur_use_min 	= 	state		
							actualiser ()
						)
		on ddl_murs selected sel	 do
		(
							m_facade.murs 	= 	sel
							actualiser ()
						)
		on chk_etagesMax changed state do
		(
							m_facade.etages_use_max 	= 	state		
							actualiser ()
						)
		on lbx_sequence selected _sel 	do
		(
							m_composant_courant = m_facade.sequence[_sel]
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
								local itemTmp = m_facade.sequence[id_orig]
								deleteItem	m_facade.sequence	id_orig
								insertItem	itemTmp		m_facade.sequence	(id_orig-1)
								lbx_sequence.selection	-= 1
							)
							actualiser ()
						)
		on btn_descendre pressed do
		(
							local id_orig = lbx_sequence.selection
							if id_orig < m_facade.sequence.count do (
								local itemTmp = m_facade.sequence[id_orig]
								deleteItem	m_facade.sequence	id_orig
								insertItem	itemTmp		m_facade.sequence	(id_orig+1)
								lbx_sequence.selection	+= 1
							)
							actualiser ()
						)
		on ddl_mode selected sel	 do
		(
							m_facade.mode 	= 	sel
							actualiser ()
						)
		on chk_etages changed state do
		(
							m_facade.etages_use_min 	= 	state		
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
								deleteItem	m_facade.sequence	id					
							actualiser ()
						)
	)
	
	
	
	
	
	
	
	
	
	