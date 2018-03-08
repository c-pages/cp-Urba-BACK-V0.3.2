
	
	
(
	

	rollout roll_urba_editeurFacades "Urba - Batiment - Editeur de facade" width:255 height:500
	(
		
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
			fn debug 	_txt  var:	 param:    =(
				local m_debug = true
				try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:"urba | roll_urba_editeurFacades"
				catch ()
			)
			
			
			
			------------  Membres	----------------------------------------------------------------------------------
			---- Pointeurs ----
			local m_plug						---- pointeur vers le plug ----
			local mgr_facade
			
			local m_changement = false
			
			--- les parametres courants ------------
			local m_facade_courante
			local m_composant_courant
			local m_ssComposant_courant
			
			local m_compoCourant_estDansBalcon = false
			local m_compoCourant_estDansGroupe = false
			
			--- rollout	---------	
			local largeur_params		= 	234
-- 			local largeur_min 			= 	490
			local largeur_base 		= 250
			local groupe_existe = false
			local hauteur_min 		= 	300
			
			--- images bouton fermer ---
			local murs_types 	= #("Gouttereaux + Pignons", "Gouttereaux", "Pignons")
			
			local nrbe_subRoll	=	0
			
			------------  UI	----------------------------------------------------------------------------------		
												
		edittext 'edt_nom_facade' "" pos:[7,10] width:200 height:16 align:#left
				
		spinner 'spn_etages' "" pos:[95,49] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		spinner 'spn_etagesMax' "" pos:[172,49] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left		
		
		
		
		
			
				
				
		spinner 'spn_longueur_min' "" pos:[95,64] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		spinner 'spn_longueur_max' "" pos:[172,64] width:63 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		checkbutton 'chk_longueur_max' "" pos:[159,64] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
		checkbutton 'chk_longueur_min' "" pos:[82,64] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
		label 'lbl_longueur' "Longueur:" pos:[17,65] width:52 height:15 align:#left
					
		dropdownList 'ddl_murs' "" pos:[82,79] width:154 height:21 selection:3 align:#left
		
		
		checkbutton 'ckb_mur_nord' "Nord" pos:[82,98] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
		checkbutton 'ckb_mur_sud' "Sud" pos:[121,98] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
		checkbutton 'ckb_mur_est' "Est" pos:[159,98] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
		checkbutton 'ckb_mur_ouest' "Ouest" pos:[197,98] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
		label 'lbl_appliquerA' "Murs:" pos:[17,83] width:32 height:15 align:#left
					
		checkbutton 'chk_etagesMax' "" pos:[159,49] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
					
		listbox 'lbx_sequence' "" pos:[90,183] width:135 height:10 align:#left
					
		label 'lbl23' "Disposition :" pos:[17,144] width:72 height:15 align:#left
					
		button 'btn_enregistrer' "S" pos:[224,9] width:19 height:19 toolTip:"Sauvegarder preset." align:#left
		button 'btn_charger' "O" pos:[206,9] width:19 height:19 toolTip:"Ouvrir preset." align:#left
					
		button 'btn_monter' "/\\" pos:[226,184] width:16 height:16 toolTip:"Monter le composant." align:#left
		button 'btn_descendre' "\/" pos:[226,199] width:16 height:16 toolTip:"Descendre le composant." align:#left
		dropdownList 'ddl_mode' "" pos:[90,142] width:135 height:21 selection:3 align:#left
		checkbutton 'chk_etages' "" pos:[82,49] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
					
		label 'lbl95' "Etages:" pos:[17,50] width:43 height:15 align:#left
					
		subRollout 'subroll_parametres' "Paramètres" pos:[259,16] width:210 height:287 align:#left
		
		
		button 'btn_dupliquer_composant' "Dup." pos:[89,167] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
		button 'btn_instancier_composant' "Inst." pos:[123,167] width:35 height:16 toolTip:"Créer une instance du composant sélectionné." align:#left
		button 'btn_supprimer_composant' "Sup." pos:[191,167] width:35 height:16 toolTip:"Supprimer" align:#left
					
		button 'btn_ajouter_composant_1' "btn1" pos:[12,182] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_2' "btn2" pos:[12,197] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_3' "btn3" pos:[12,212] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_4' "btn4" pos:[12,227] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_5' "btn5" pos:[12,242] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_6' "btn6" pos:[12,257] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_7' "btn7" pos:[12,272] width:75 height:16 visible:false align:#left
		button 'btn_ajouter_composant_8' "btn8" pos:[12,287] width:75 height:16 visible:false align:#left
					
		button 'btn_valider' "Valider" pos:[5,333] width:105 height:30 toolTip:"Valider la façade" align:#left
		button 'btn_annuler' "Annuler" pos:[605,318] width:105 height:30 toolTip:"Annuler les changements" align:#left
					
			
			
			
			
		GroupBox 'grp_global' "Appliqué à " pos:[7,32] width:238 height:89 align:#left
					
					
					
		GroupBox 'grp_sequence' "Séquence" pos:[7,124] width:238 height:203 align:#left
		subRollout 'subroll_parametres_niv2' "Paramètres" pos:[493,16] width:210 height:287 align:#left
		
		
		
		  
			
		GroupBox 'grp_panneau1' "" pos:[250,2] width:228 height:309 align:#left
		GroupBox 'grp_panneau2' "" pos:[484,2] width:228 height:309 align:#left
		
		
			local		btns_ajouter_composant	=#( btn_ajouter_composant_1, btn_ajouter_composant_2, btn_ajouter_composant_3, btn_ajouter_composant_4, btn_ajouter_composant_5, btn_ajouter_composant_6 , btn_ajouter_composant_7 , btn_ajouter_composant_8)
			local 	btns_ids_constructeurs		=#()
			
			
			
			------------  Fonctions	----------------------------------------------------------------------------------
			
			
			fn on_a_change_un_truc = 	m_changement 				= true
				
			
			fn  remplir_lbx_sequence 	=(
				
				--------- la sequence de composants --------
				local itemsTmp 		= #()
				local est_dansBalcon = false
				local est_dansGroupe = false
				
				m_compoCourant_estDansBalcon = false
				m_compoCourant_estDansGroupe = false
				local tabulation		= "     "
				local i = 1
				for comp in m_facade_courante.params.sequence		do	(
					local affichage 		= "  "
					
					if comp.type == #balcon		do est_dansBalcon = true
					if comp.type == #groupe		do est_dansGroupe = groupe_existe = true
					
					if comp.type == #groupe	 then affichage = "-------- "
					else if est_dansGroupe do affichage +=  tabulation
					
					if comp.type == #balcon	or  comp.type == #balconFin		then affichage += "  --- "
					else if est_dansBalcon do affichage += " |     "
					
					-- le nom ---
					affichage += comp.nom 
					
					
					-- on check si c'est l'instance d'un element deja present -----------
					if param_instance != undefined then 
					
					
					
					if comp.type == #groupe	do (
						if comp.params.repetitions  == 0 then
							affichage += " - x Inf." 
						else
							affichage += " - x " + comp.params.repetitions as string
						affichage += " --------------------"
					)
					if comp.type == #groupeFin		then 
						affichage = "-------------------------------------------"
						
					-- quelques infos -----
					if comp.params != undefined do
						if comp.params.longueur != 0 do
							affichage += " - " + comp.params.longueur as string + " cm." 
					
					
					append itemsTmp affichage
					
					if comp.type == #balconFin 	do est_dansBalcon = false
					if comp.type == #groupeFin 	do est_dansGroupe = false
					
					if i == lbx_sequence.selection do (
						m_compoCourant_estDansBalcon = est_dansBalcon
						m_compoCourant_estDansGroupe = est_dansGroupe
					)
					
					i += 1
				)
				
				lbx_sequence.items =  itemsTmp
				
			)
			
			fn gerer_boutons_enabled 	=(
					
				--- bloquage du bouton Balcon si on est deja dans un balcon -------------------
				local idBalcon = ( m_plug.core.get_mgr_composants() ).get_constructeur_index #Balcon 
				btns_ajouter_composant[idBalcon].enabled = not m_compoCourant_estDansBalcon
				
				
				--- bloquage du bouton loggia si on est deja dans un loggia -------------------			
				local idGroupe = m_plug.core.get_composants_bouton_index 	#groupe 
				
				btns_ajouter_composant[ idGroupe ].enabled = not groupe_existe
				
				btn_supprimer_composant.enabled 	= lbx_sequence.selection != 0 
				btn_instancier_composant.enabled 		= lbx_sequence.selection != 0
				btn_dupliquer_composant.enabled 		= lbx_sequence.selection != 0
				
				-- bouton monter ----
				local btnMonter_enabled 		= lbx_sequence.selection != 1 and  lbx_sequence.selection != 0 and m_composant_courant != undefined
				if btnMonter_enabled do (
					if m_composant_courant.type == #balcon  or m_composant_courant.type == #balconFin do (
						local compo_precedant = m_facade_courante.params.sequence[lbx_sequence.selection - 1] 
						if compo_precedant.type == #balcon or compo_precedant.type == #balconFin  do (
							btnMonter_enabled = false
						)
					)
				)
				btn_monter.enabled 		= btnMonter_enabled
				
				-- bouton descendre ----
				local btnDescendre_enabled = lbx_sequence.selection != lbx_sequence.items.count and  lbx_sequence.selection != 0 and m_composant_courant != undefined
				if btnDescendre_enabled do (
					if m_composant_courant.type == #balcon  or m_composant_courant.type == #balconFin do (
						local compo_suivant = m_facade_courante.params.sequence[lbx_sequence.selection + 1] 
						if compo_suivant.type == #balcon or compo_suivant.type == #balconFin   do (
							btnDescendre_enabled = false
						)
					)
				)
				btn_descendre.enabled 		= btnDescendre_enabled
				
			)
			
			fn actualiser 					sans_subRoll_1:false		sans_subRoll_2:false	=(
				debug "actualiser ()"
				
				
				ddl_mode.items	=	m_facade_courante.params.get_modes_distribution ()
				ddl_murs.items	=	m_facade_courante.params.get_modes_murs ()
				
				edt_nom_facade.text 			= m_facade_courante.nom
				
				chk_etages.checked				= m_facade_courante.params.etagesMin_use
				spn_etages.indeterminate 		= not m_facade_courante.params.etagesMin_use	
				spn_etages.enabled 				= m_facade_courante.params.etagesMin_use	
				if not spn_etages.indeterminate do
					spn_etages.value				= m_facade_courante.params.etagesMin
				
				chk_etagesMax.checked			= m_facade_courante.params.etagesMax_use
				spn_etagesMax.indeterminate = not m_facade_courante.params.etagesMax_use	
				spn_etagesMax.enabled			= m_facade_courante.params.etagesMax_use			
				if not spn_etagesMax.indeterminate do
					spn_etagesMax.value			 = m_facade_courante.params.etagesMax	
				
				chk_longueur_min.checked					= m_facade_courante.params.longueurMin_use
-- 				spn_longueur_min.indeterminate 		= not m_facade_courante.params.longueurMin_use	
				spn_longueur_min.enabled 				= m_facade_courante.params.longueurMin_use	
-- 				if not spn_longueur_min.indeterminate do
				spn_longueur_min.range = [m_facade_courante.params.get_longueur (),1e+13,0] 
				spn_longueur_max.range = [m_facade_courante.params.get_longueur (),1e+13,0] 
				
				if m_facade_courante.params.longueurMin_use	then (
					spn_longueur_min.value				= m_facade_courante.params.longueurMin
				)
				else
					spn_longueur_min.value			= m_facade_courante.params.get_longueur ()
				
				
				chk_longueur_max.checked				= m_facade_courante.params.longueurMax_use
				spn_longueur_max.indeterminate 		= not m_facade_courante.params.longueurMax_use	
				spn_longueur_max.enabled 				= m_facade_courante.params.longueurMax_use	
				if not spn_longueur_max.indeterminate do
					spn_longueur_max.value				= m_facade_courante.params.longueurMax
				

				
				
				ckb_mur_nord.checked				= m_facade_courante.params.murs_nord
				ckb_mur_sud.checked				= m_facade_courante.params.murs_sud
				ckb_mur_est.checked					= m_facade_courante.params.murs_est
				ckb_mur_ouest.checked				= m_facade_courante.params.murs_ouest
				
				
				
				ddl_murs.selection 				= m_facade_courante.params.murs
				ddl_mode.selection 				= m_facade_courante.params.mode
			
				
				remplir_lbx_sequence ()
				gerer_boutons_enabled ()
				
				if not sans_subRoll_1 do (
				--- on retire tout les sous panneaux -------------------
				for rollAVirer in subroll_parametres.rollouts do
					removeSubRollout	subroll_parametres	rollAVirer
				
					--- le subRollout des composants	PANNEAU 1 -------
					if m_composant_courant != undefined do (
						addSubRollout	subroll_parametres ( m_composant_courant.get_dialog () )
						m_composant_courant.initialiser_dialog		m_plug			 	roll_parent:roll_urba_editeurFacades
					)
				)
				
				
				if not sans_subRoll_2 do (
					for rollAVirer in subroll_parametres_niv2.rollouts do
						removeSubRollout	subroll_parametres_niv2	rollAVirer
					
					--- le subRollout des composants	PANNEAU 2 -------
					if m_ssComposant_courant != undefined do (
						addSubRollout	subroll_parametres_niv2 ( m_ssComposant_courant.get_dialog () )
						m_ssComposant_courant.initialiser_dialog		m_plug			 	roll_parent:roll_urba_editeurFacades
					)
				)
				
-- 				mgr_facade.set_dialog_taille			_taille
				
				
				
				
			)
			
			fn redim_pour_parametres =(
				
				--- dimension du rollout ----------------------------
				if subroll_parametres_niv2.rollouts.count > 0 then
					nrbe_subRoll = 2
				else if subroll_parametres.rollouts.count > 0 then
					nrbe_subRoll = 1
				else
					nrbe_subRoll = 0
				local largeur_rollout 		= largeur_base + nrbe_subRoll * largeur_params
				
				
				roll_urba_editeurFacades.width 		= largeur_rollout
			)
			
			
			
			fn set_ssComposant		_composant	 = (
				
				m_ssComposant_courant  = _composant
				
				for rollAVirer in subroll_parametres_niv2.rollouts do
					removeSubRollout	subroll_parametres_niv2	rollAVirer
				
				if m_ssComposant_courant != undefined do (
					local m_dialog_ssCompo = m_ssComposant_courant.get_dialog ()
					addSubRollout	subroll_parametres_niv2 	m_dialog_ssCompo
					m_ssComposant_courant.initialiser_dialog		m_plug			 	roll_parent:roll_urba_editeurFacades
					m_dialog_ssCompo.initialiser			m_plug		
					m_dialog_ssCompo.set_menuiserie		m_ssComposant_courant
					
				)
				redim_pour_parametres ()
			)
			fn redimensionnerFenetre 		_taille 	=(
				
	-- 			local largeur_min_ferme 	= 255
	-- 			local largeur_min_ouvert 	= largeur_min_ferme + largeur_params			
	-- 			local largeur_min 				= 	largeur_min_ouvert
	-- 			local hauteur_min 			= 255
				
				local largeur_btn 		= 17
				local largeur_bord 	= edt_nom_facade.pos.x
				/* 
				
				if subroll_parametres_niv2.rollouts.count > 0 then
					nrbe_subRoll = 2
				else if subroll_parametres.rollouts.count > 0 then
					nrbe_subRoll = 1
				else
					nrbe_subRoll = 0
				local largeur_min 		= largeur_base + nrbe_subRoll * largeur_params
				 */
				
				
-- 				if 	_taille.x < largeur_min do 
-- 					_taille.x =  largeur_min
				if 	_taille.y < hauteur_min do 
					_taille.y =  hauteur_min
				roll_urba_editeurFacades.width 		= _taille.x
				roll_urba_editeurFacades.height 		= _taille.y
				mgr_facade.set_dialog_taille		_taille
				
				lbx_sequence.height 		= _taille.y - ( lbx_sequence.pos.y + largeur_btn + 2 * largeur_bord  + 5)
				grp_sequence.height 		= _taille.y - 150
				
				grp_panneau1.height		= _taille.y - 3 * largeur_bord  	- 9
				grp_panneau2.height		= grp_panneau1.height	
				
				
				subroll_parametres.height			= grp_panneau1.height	  	- 19
				subroll_parametres_niv2.height	= subroll_parametres.height
				
				
				
				
				
-- 				local largeur_panneau1 = _taille.x 	- 	nrbe_subRoll * largeur_params
-- 				
-- 				subroll_parametres.pos.x	=	largeur_panneau1 + 5
-- 				subroll_parametres_niv2.pos.x	=	subroll_parametres.pos.x + largeur_panneau1 + 10
				
-- 				grp_global.width 	= 	largeur_panneau1 - ( 2* largeur_bord	   )
-- 				grp_sequence.width		= 	largeur_panneau1 - ( 2* largeur_bord	   )
				
-- 				edt_nom_facade.width 	= 	largeur_panneau1 - ( 2* largeur_bord	+ 2 * largeur_btn   )
-- 				btn_enregistrer.pos.x 	= 	edt_nom_facade.width 	+  edt_nom_facade.pos.x
-- 				btn_charger.pos.x 			= 	largeur_btn 	+  btn_enregistrer.pos.x
				
-- 				ddl_murs.width 			= 	ddl_mode.width  = 	largeur_panneau1  - ( ddl_murs.pos.x + largeur_bord )
-- 				lbx_sequence.width 		= ddl_murs.width 	 - largeur_btn
				
				
				
-- 				btn_monter.pos.x								=	btn_descendre .pos.x		=	lbx_sequence.pos.x + lbx_sequence.width
-- 				btn_dupliquer_composant.pos.y 			= lbx_sequence.pos.y + lbx_sequence.height - 47
-- 				btn_instancier_composant.pos.y 		= lbx_sequence.pos.y + lbx_sequence.height - 32
-- 				btn_supprimer_composant.pos.y 		= lbx_sequence.pos.y + lbx_sequence.height - 17
				
-- 				grp_prop.pos.x 					= ddl_murs.pos.x + ddl_murs.width + largeur_bord 
-- 				grp_prop.height 				= _taille.y - ( grp_prop.pos.y + largeur_bord )
-- 				subroll_parametres.pos.x 	= grp_prop.pos.x + 8
-- 				subroll_parametres.height 	= grp_prop.height - 23
				
				btn_valider.pos.y 		= _taille.y - 35
				btn_annuler.pos.y 		=  _taille.y - 35
				btn_annuler.pos.x 		=  _taille.x - 110
			)
			fn initialiser 			_plug 		=(
				
				m_plug 			= _plug
				mgr_facade		=	_plug.core.get_mgr_facades ()
				
				-- la fenetre ----
				redimensionnerFenetre  (getDialogSize	roll_urba_editeurFacades)
				
				
				----- gestion des boutons de creation de composant -----------
				local mgr_compos = m_plug.core.get_mgr_composants ()
				local constructeurs_compos = mgr_compos.get_constructeurs ()
				local i =1
				local j = 1
				for  constructeur_compo in  constructeurs_compos	do (
					if  constructeur_compo.est_editable  () do (
						btns_ajouter_composant[i].visible 		= true
						btns_ajouter_composant[i].text 			= constructeur_compo.nom
						btns_ajouter_composant[i].tooltip 		= constructeur_compo.tooltip
						btns_ids_constructeurs[i] = j
						i+=1
					)
					j += 1
				)
				
				m_plug.core.VP_afficher_longueurs ()
				redrawViews ()
			)
			fn set_facade		_facade 	=(
				-- la facade courante	----
				m_facade_courante 	= 	_facade
				
				--- la sequence	----------
				if m_facade_courante.params.sequence.count>0 do (
					lbx_sequence.selection  = 1
					m_composant_courant = m_facade_courante.params.sequence[ 	1 ]
				)
				m_changement = false
				
				--- on passe en proxy ---------------
				m_plug.core.actualiser ()
				
				actualiser ()
			)
			
			
			
			
			
			fn ajouter_composant	_IDconstructeurCompo	=(
				
				local sequence_selectionBack = lbx_sequence.selection 
				m_composant_courant	=	m_plug.core.creer_composant	m_facade_courante		_IDconstructeurCompo		position:(lbx_sequence.selection +1)
				
				remplir_lbx_sequence ()
				
				lbx_sequence.selection = sequence_selectionBack +1
				
				m_ssComposant_courant	= undefined
				actualiser ()
				redim_pour_parametres ()
	
	
			)
			
			fn dupliquer_composant =(
				

				/* 
				local mgr_composants 	= m_plug.core.get_mgr_composants ()
				local composantDuplique =  	mgr_composants.dupliquer 		m_composant_courant
				m_facade_courante.params.ajouter_composant	composantDuplique	position:(lbx_sequence.selection +1)
				*/
				
				m_composant_courant = m_plug.core.dupliquer_composant	m_facade_courante	m_composant_courant
				
				remplir_lbx_sequence ()
				lbx_sequence.selection += 1
				gerer_boutons_enabled ()				
				
				
				m_ssComposant_courant	= undefined
				
				actualiser ()
			)
			fn instancier_composant =(
				
				
				
				m_composant_courant =  	m_facade_courante.params.instancier_composant	lbx_sequence.selection 
				
				m_composant_courant = composantDuplique
				remplir_lbx_sequence ()
				
				lbx_sequence.selection += 1
				gerer_boutons_enabled ()				
				
				
				actualiser ()
			)
			/* fn enregistrer =(
				
				local		mgr_facade		=	m_plug.core.get_mgr_facades ()
				mgr_facade.enregistrer_parametres	m_facade_courante
				m_changement 				= false
				
			) */
			
			
			
			
			
		----------------- Evenements ------------------------------------------------------------------------
							
		
		
-- 		on roll_urba_editeurFacades open do			
				
				
				
				
				
				
						
						
		on roll_urba_editeurFacades close do
		(
			m_plug.core.facadeEditeur_fermer 	()
			m_plug.core.VP_cacher_longueurs ()
			
			
				)
		on roll_urba_editeurFacades resized _taille 				do
			redimensionnerFenetre 	_taille
		on roll_urba_editeurFacades moved _pos do
			m_plug.core.set_facadeEditeur_position   	_pos
		on edt_nom_facade entered txt 	do
		(
					m_facade_courante.nom 	=	txt
					m_changement = true
				)
		on spn_etages changed val 	do
		(
					m_facade_courante.params.etagesMin 	= 	val
			m_changement = true
				)
		on spn_etagesMax changed val 	do
		(
					m_facade_courante.params.etagesMax 	= 	val
			m_changement = true
				)
		on spn_longueur_min changed val 	do
		(
					m_facade_courante.params.longueurMin 	= 	val
			m_changement = true
				)
		on spn_longueur_max changed val 	do
		(
					m_facade_courante.params.longueurMax 	= 	val
			m_changement = true
				)
		on chk_longueur_max changed state do
		(
					m_facade_courante.params.longueurMax_use 	= 	state	
			m_changement = true
					actualiser ()
				)
		on chk_longueur_min changed state do
		(
					m_facade_courante.params.longueurMin_use 	= 	state		
			m_changement = true
					actualiser ()
				)
		on ddl_murs selected sel	 do
		(
					m_facade_courante.params.murs 	= 	sel
			m_changement = true
				)
		on ckb_mur_nord changed state do
		(
					m_facade_courante.params.murs_nord 	= 	state		
			m_changement = true
					actualiser ()
				)
		on ckb_mur_sud changed state do
		(
					m_facade_courante.params.murs_sud 	= 	state		
			m_changement = true
					actualiser ()
				)
		on ckb_mur_est changed state do
		(
					m_facade_courante.params.murs_est 	= 	state		
			m_changement = true
					actualiser ()
				)
		on ckb_mur_ouest changed state do
		(
					m_facade_courante.params.murs_ouest 	= 	state		
			m_changement = true
					actualiser ()
				)
		on chk_etagesMax changed state do
		(
					m_facade_courante.params.etagesMax_use 	= 	state		
			m_changement = true
					actualiser ()
				)
		on lbx_sequence selected arg do
		(
					m_composant_courant 		= m_facade_courante.params.sequence[ 	arg ]
					m_ssComposant_courant	= undefined
		-- 					for rollAVirer in subroll_parametres_niv2.rollouts do
		-- 						removeSubRollout	subroll_parametres	rollAVirer
					
		-- 		m_changement = true
					actualiser ()
				redim_pour_parametres ()
				)
		on btn_monter pressed do
		(
					m_facade_courante.params.composant_monter 	 lbx_sequence.selection
					lbx_sequence.selection -= 1
			m_changement = true
					remplir_lbx_sequence ()
				gerer_boutons_enabled ()				
				)
		on btn_descendre pressed do
		(
					m_facade_courante.params.composant_descendre 	 lbx_sequence.selection
					lbx_sequence.selection += 1
			m_changement = true
					remplir_lbx_sequence ()
				gerer_boutons_enabled ()				
				)
		on ddl_mode selected sel	 do
		(
					m_facade_courante.params.mode 	= 	sel
			m_changement = true
				)
		on chk_etages changed state do
		(
					m_facade_courante.params.etagesMin_use 	= 	state		
					actualiser ()
			m_changement = true
				)
		on btn_dupliquer_composant pressed do
		(
				dupliquer_composant ()
				m_changement = true
				m_ssComposant_courant	= undefined
				actualiser ()
			)
		on btn_instancier_composant pressed do
		(
				instancier_composant ()
				m_changement = true
				m_ssComposant_courant	= undefined
				actualiser ()
			)
		on btn_supprimer_composant pressed do
		(
					if queryBox "Supprimer le composant" do (
						m_plug.core.supprimer_composant 	m_facade_courante		lbx_sequence.selection
						actualiser ()
			m_changement = true
					)
				m_ssComposant_courant	= undefined
				actualiser ()
				redim_pour_parametres ()
				)
		on btn_ajouter_composant_1 pressed do
		(
				ajouter_composant	btns_ids_constructeurs[1]
				m_changement = true
			)
		on btn_ajouter_composant_2 pressed do
		(
				ajouter_composant	btns_ids_constructeurs[2]
				m_changement = true
			)
		on btn_ajouter_composant_3 pressed do
		(
				ajouter_composant	btns_ids_constructeurs[3]
				m_changement = true
			)
		on btn_ajouter_composant_4 pressed do
		(
				ajouter_composant	btns_ids_constructeurs[4]
				m_changement = true
			)
		on btn_ajouter_composant_5 pressed do
		(
				ajouter_composant	btns_ids_constructeurs[5]
				m_changement = true
			)
		on btn_ajouter_composant_6 pressed do
		(
				ajouter_composant	btns_ids_constructeurs[6]
				m_changement = true
			)
		on btn_valider pressed do
		(
			
			m_plug.core.VP_cacher_longueurs 	()
			m_plug.core.enregistrer_element	m_facade_courante
			m_changement = false
			m_plug.actualiser_rollouts ()
			
			m_plug.core.demander_reconstruire 	()
			m_plug.core.facadeEditeur_fermer 		()
			
		)
		on btn_annuler pressed do
		(
			
			m_plug.core.VP_cacher_longueurs 		()
			
			m_plug.core.demander_reconstruire 	()			
			m_changement = false
			m_plug.core.facadeEditeur_fermer 		()
			
		)
	)
		
		
		
	
	roll_urba_editeurFacades
	
	
	
	
	
	
)


































