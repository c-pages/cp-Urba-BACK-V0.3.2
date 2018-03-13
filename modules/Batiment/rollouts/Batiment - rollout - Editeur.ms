--Destroy the dialog if it is already open 
-- try(destroyDialog rollout_Urb_Bat_editeur)catch()

(  --- fin FileIn ----------


	
rollout sub_general "" width:255 height:556
(
	local m_rolloutP
	local m_plug
	local m_core
	
	local m_bat
	
	--- Global ------
	GroupBox 'grp_etages' "Etages :" pos:[10,-4] width:235 height:199 align:#left	
	
	
	label 'lbl_nbre' "Nbre. d'étages:" pos:[27,15] width:92 height:15 align:#left
	spinner 'spn_nbres' "" pos:[160,14] width:72 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_hauteur' "Hauteur :" pos:[27,31] width:76 height:15 align:#left
	spinner 'spn_hauteur' "" pos:[160,29] width:72 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	
	--- etages specifiques -----------
	GroupBox 'grp_etages_specifiques' "Etages spécifiques" pos:[20,48] width:215 height:135 align:#left
	button 'btn_etages_nouveau' "Nouv." pos:[30,64] width:35 height:16 toolTip:"Ajouter	étages spécifiques" align:#left
	button 'btn_etages_supprimer' "Sup." pos:[171,63] width:35 height:16 toolTip:"Supprimer étages spécifiques" align:#left	
	
	listbox 'lbx_etages_specifiques' "" pos:[30,80] width:177 height:4 align:#left
	
	label 'lbl_etage_specifiques' "Etages :" pos:[35,138] width:50 height:19 align:#left
	spinner 'spn_etageMin_specifiques' "" pos:[117,141] width:40 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_hauteur_specifiques' "Hauteur :" pos:[35,156] width:55 height:22 align:#left
	spinner 'spn_etageMax_specifiques' "" pos:[169,141] width:40 height:16 range:[0,1e+13,0] type:#integer align:#left
	checkbutton 'ckb_etageMax_specifiques' ">" pos:[156,141] width:16 height:16 align:#left
	spinner 'spn_hauteur_specifiques' "" pos:[117,157] width:92 height:16 range:[0,1e+13,0] type:#worldunits align:#left
	
	---- Divers ------
	GroupBox 'grp_divers' "Divers" pos:[10,199] width:235 height:60 align:#left
	label 'lbl_decallageZ' "Décallage (Z):" pos:[27,216] width:92 height:18 align:#left
	spinner 'spn_decallageZ' "" pos:[160,216] width:72 height:16 range:[-1e+13,1e+13,0] type:#worldunits scale:1 align:#left
	checkbox 'chk_interieur' "Cloisons intèrieures" pos:[26,235] width:141 height:16 align:#left
	
	
	
	
	--- rollout------------------
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
		-------- global ------------------------
		spn_nbres.value		=	m_bat.etages_nbre		
		spn_hauteur.value		=	m_bat.etages_hauteur_global
		
		
		-------- etages spécifiques --------------
		--- affichage dans la liste-
		local liste_affichage = #()
		for i = 1 to m_bat.etages_min.count do (
			local affichage = ""
			affichage+= m_bat.etages_min[i] as string  
			if m_bat.etages_max_use[i] do 
				affichage+= " ---> " + m_bat.etages_max[i] as string 				
			affichage+= " : " + m_bat.etages_hauteurs[i] as string  + "cm."			
			append liste_affichage affichage
		)
		lbx_etages_specifiques.items = liste_affichage
		
		--- les boutons ------------
		local enable_prop =  lbx_etages_specifiques.selection != 0
		btn_etages_supprimer.enabled 	= enable_prop
		
		spn_etageMin_specifiques.enabled 	= enable_prop
		lbl_etage_specifiques.enabled 		= enable_prop
		spn_etageMax_specifiques.enabled	= enable_prop
		lbl_hauteur_specifiques.enabled		= enable_prop
		ckb_etageMax_specifiques.enabled	= enable_prop
		spn_hauteur_specifiques.enabled 	= enable_prop
		
		if enable_prop do (
			local index = lbx_etages_specifiques.selection 
			spn_etageMin_specifiques.value					=	m_bat.etages_min[ index ] 
			ckb_etageMax_specifiques.checked 			= m_bat.etages_max_use[ index ] 
			spn_etageMax_specifiques.indeterminate	=	not ckb_etageMax_specifiques.checked
			spn_etageMax_specifiques.enabled				=	ckb_etageMax_specifiques.checked
			if  ckb_etageMax_specifiques.checked do 
				spn_etageMax_specifiques.value				=	m_bat.etages_max[ index ] 
			
			spn_hauteur_specifiques.value					=	m_bat.etages_hauteurs[ index ] 
			
			spn_etageMax_specifiques.range.x = spn_etageMin_specifiques.value		
		)
		
		
	)
	
	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
		
		spn_etageMax_specifiques.range.x = 0
	)
		
		
		
		
	---- donnees -----------------	
	fn set_etage = (
		m_bat.set_etage		lbx_etages_specifiques.selection 		\
										spn_etageMin_specifiques.value			\
										ckb_etageMax_specifiques.checked		\
										spn_etageMax_specifiques.value			\
										spn_hauteur_specifiques.value
		m_rolloutP.changer_un_truc ()
		actualiser ()
	)
		
		
	
	
	
	
	
	on spn_nbres changed val do (
		m_bat.etages_nbre		= val
		m_rolloutP.changer_un_truc ()
	)
	on spn_hauteur changed val do (
		m_bat.etages_hauteur_global		= val
		m_rolloutP.changer_un_truc ()
	)
	on btn_etages_nouveau pressed do	(
		m_bat.ajouter_etage ()		
		m_rolloutP.changer_un_truc ()
		lbx_etages_specifiques.selection += 1
		actualiser ()
	)
	on btn_etages_supprimer pressed do (
		if lbx_etages_specifiques.selection > 0 do (
			m_bat.supprimer_etage		lbx_etages_specifiques.selection
			m_rolloutP.changer_un_truc ()
			if lbx_etages_specifiques.selection > lbx_etages_specifiques.items.count do
				lbx_etages_specifiques.selection = lbx_etages_specifiques.items.count 
			actualiser ()
		)
	)
	on lbx_etages_specifiques 			selected 	val 		do	actualiser ()
	
	on spn_etageMin_specifiques 	changed 	val 		do 	set_etage ()
	on spn_etageMax_specifiques 	changed 	val 		do	set_etage ()
	on ckb_etageMax_specifiques 	changed 	state 	do	set_etage ()
	on spn_hauteur_specifiques 		changed 	val 		do 	set_etage ()
		
	on spn_decallageZ changed val do	(
		m_bat.decallage_z = val
		m_rolloutP.changer_un_truc ()		
		)
	on chk_interieur changed state do	(
		m_bat.interieur_use = state
		m_rolloutP.changer_un_truc ()
		)
		
) ---- fin rollout general ------

rollout sub_facades "" width:594 height:789
(


	local m_rolloutP
	local m_core
	local m_plug

	--- les parametres courants ------------
	local m_bat
	local m_facade_courante
	local m_composant_courant
	local m_ssComposant_courant
	
	local m_compoCourant_estDansBalcon = false
	local m_compoCourant_estDansGroupe = false
	
	
	button 'btn_facade_monter' "/\\" pos:[229,18] width:16 height:16 toolTip:"Monter le composant." align:#left
	button 'btn_facade_descendre' "\/" pos:[229,33] width:16 height:16 toolTip:"Descendre le composant." align:#left
	button 'btn_facade_dupliquer' "Dup." pos:[44,-1] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	button 'btn_facade_supprimer' "Sup." pos:[193,-1] width:35 height:16 toolTip:"Supprimer" align:#left
	listbox 'lbx_facades' "" pos:[10,16] width:218 height:7 align:#left
	button 'btn_facade' "Nouv." pos:[10,-1] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	checkbutton 'ckb_facades_details' "D" pos:[229,95] width:16 height:16 highlightColor:(color 255 255 0) align:#left
	
	
	
	edittext 'edt_facade_nom' "" pos:[13,132] width:207 height:16 align:#left
	button 'btn_facades_presets' "" pos:[222,132] width:16 height:16 align:#left
	
	spinner 'spn_contrainte_etages' "" pos:[86,166] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_contrainte_etagesMax' "" pos:[163,166] width:63 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	
	GroupBox 'grp_constraintes' "Contraintes" pos:[14,149] width:222 height:89 align:#left
	
	spinner 'spn_contrainte_longueur_min' "" pos:[86,181] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	spinner 'spn_contrainte_longueur_max' "" pos:[163,181] width:63 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	checkbutton 'chk_contrainte_longueur_max' "" pos:[150,181] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	checkbutton 'chk_contrainte_longueur_min' "" pos:[73,181] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl_contrainte_longueur' "Long.:" pos:[22,182] width:52 height:15 align:#left


	
	checkbutton 'ckb_mur_nord' "Nord" pos:[73,215] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_sud' "Sud" pos:[112,214] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_est' "Est" pos:[150,215] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	checkbutton 'ckb_mur_ouest' "Ouest" pos:[188,215] width:40 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	label 'lbl_contrainte_murs' "Murs:" pos:[22,198] width:32 height:15 align:#left
	
	dropdownList 'ddl_contrainte_murs' "" pos:[73,196] width:154 height:21 selection:3 align:#left
	
	checkbutton 'chk_contrainte_etagesMax' "" pos:[150,166] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Etage maximum." align:#left
	label 'lbl_contrainte_etages' "Etages :" pos:[22,166] width:52 height:15 align:#left
	
	checkbutton 'chk_contrainte_etages' "" pos:[73,166] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Etage minimum." align:#left
	
	
	--- parametre facade	------
	GroupBox 'grp_sequence' "Séquence" pos:[14,239] width:222 height:237 align:#left
	
	button 'btn_compo_monter' "/\\" pos:[213,294] width:16 height:16 toolTip:"Monter le composant." align:#left
	button 'btn_compo_descendre' "\/" pos:[213,309] width:16 height:16 toolTip:"Descendre le composant." align:#left
		
		
		
	button 'btn_compo_dupliquer' "Dup." pos:[58,278] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	button 'btn_compo_instancier' "Inst." pos:[92,278] width:35 height:16 toolTip:"Créer une instance du composant sélectionné." align:#left
	button 'btn_compo_supprimer' "Sup." pos:[173,278] width:35 height:16 toolTip:"Supprimer" align:#left
		
		
	listbox 'lbx_sequence' "" pos:[24,294] width:187 height:13 align:#left
		
		
	label 'lbl_contraintes_mode' "Mode :" pos:[22,258] width:32 height:15 align:#left
	dropdownList 'ddl_contrainte_mode' "" pos:[73,256] width:154 height:21 selection:3 align:#left
		
	
	button 'btn_compo_nouveau' "Nouv." pos:[24,278] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	GroupBox 'grp_parametres' "Paramètres" pos:[8,114] width:235 height:370 align:#left
	
	local btns_parametres_facade = #(grp_constraintes,	edt_facade_nom,	btn_facades_presets,	spn_contrainte_longueur_min,	spn_contrainte_longueur_max,	lbl_contrainte_longueur,
	ckb_mur_nord,	ckb_mur_sud,	ckb_mur_est,	ckb_mur_ouest,	spn_contrainte_etages, spn_contrainte_etagesMax , lbl_contrainte_murs,	ddl_contrainte_murs,	chk_contrainte_etagesMax,	lbl_contrainte_etages,
	chk_contrainte_etages,	grp_sequence,	btn_compo_monter,	btn_compo_descendre,	btn_compo_dupliquer,	btn_compo_instancier,	btn_compo_supprimer, lbl_contraintes_mode , ddl_contrainte_mode ,
	lbx_sequence,	btn_compo_nouveau,	grp_parametres )
	
	fn  remplir_lbx_sequence 	=(
		
		--------- la sequence de composants --------
		local itemsTmp 		= #()
		local est_dansBalcon = false
		local est_dansGroupe = false
		lbx_sequence.items  = #()
		
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
		
		
		
		
		
		btn_facade_dupliquer.enabled 	= lbx_facades.selection != 0
		btn_facade_supprimer.enabled 	= lbx_facades.selection != 0
		btn_facade_monter.enabled 	 	= lbx_facades.selection > 1
		btn_facade_descendre.enabled 	= lbx_facades.selection != 0 and lbx_facades.selection != lbx_facades.items.count
		
-- 		--- bloquage du bouton Balcon si on est deja dans un balcon -------------------
-- 		local idBalcon = ( m_plug.core.get_mgr_composants() ).get_constructeur_index #Balcon 
-- 		btns_ajouter_composant[idBalcon].enabled = not m_compoCourant_estDansBalcon
		
		
-- 		--- bloquage du bouton loggia si on est deja dans un loggia -------------------			
-- 		local idGroupe = m_plug.core.get_composants_bouton_index 	#groupe 
-- 		
-- 		btns_ajouter_composant[ idGroupe ].enabled = not groupe_existe
		
		btn_compo_dupliquer.enabled 	= lbx_sequence.selection != 0 
		btn_compo_instancier.enabled 	= lbx_sequence.selection != 0
		btn_compo_supprimer.enabled 	= lbx_sequence.selection != 0
		
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
		btn_compo_monter.enabled 		= btnMonter_enabled
		
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
		btn_compo_descendre.enabled 		= btnDescendre_enabled
		
	)
	
	fn actualiser 					sans_params_1:false		sans_params_2:false	=(
		
		
		
		
		m_bat							= m_rolloutP.m_batiment




		lbx_facades.items = #()
		facade_affiche  = #()
		local i = 1
		for fcd in m_bat.facades do (
			append facade_affiche ( "(" + i as string + ")  " + fcd.nom)
			i += 1
		)
		lbx_facades.items = facade_affiche
		
		
		m_facade_courante 		= undefined
		m_composant_courant	= undefined
		if m_bat.facades.count > 0 then (
			if lbx_facades.selection == 0 do lbx_facades.selection = 1
			m_facade_courante  		= m_bat.facades[ lbx_facades.selection ]
		) 
		
		
		local edit_facade_actif	= m_facade_courante != undefined 
		
		
		btns_parametres_facade.enabled = edit_facade_actif
		
		


		
		if edit_facade_actif then (
			
			edt_facade_nom.text 			= m_facade_courante.nom
			ddl_contrainte_murs.items		=	m_facade_courante.params.get_modes_murs ()
			ddl_contrainte_mode.items	=	m_facade_courante.params.get_modes_distribution ()
			
			chk_contrainte_etages.checked				= m_facade_courante.params.etagesMin_use
			spn_contrainte_etages.indeterminate 		= not m_facade_courante.params.etagesMin_use	
			spn_contrainte_etages.enabled 				= m_facade_courante.params.etagesMin_use	
			if not spn_contrainte_etages.indeterminate do
				spn_contrainte_etages.value				= m_facade_courante.params.etagesMin
			
			chk_contrainte_etagesMax.checked			= m_facade_courante.params.etagesMax_use
			spn_contrainte_etagesMax.indeterminate = not m_facade_courante.params.etagesMax_use	
			spn_contrainte_etagesMax.enabled			= m_facade_courante.params.etagesMax_use			
			if not spn_contrainte_etagesMax.indeterminate do
				spn_contrainte_etagesMax.value			 = m_facade_courante.params.etagesMax	
			
			chk_contrainte_longueur_min.checked					= m_facade_courante.params.longueurMin_use
-- 				spn_longueur_min.indeterminate 		= not m_facade_courante.params.longueurMin_use	
			spn_contrainte_longueur_min.enabled 				= m_facade_courante.params.longueurMin_use	
-- 				if not spn_longueur_min.indeterminate do
			spn_contrainte_longueur_min.range = [m_facade_courante.params.get_longueur (),1e+13,0] 
			spn_contrainte_longueur_max.range = [m_facade_courante.params.get_longueur (),1e+13,0] 
			
			if m_facade_courante.params.longueurMin_use	then 
				spn_contrainte_longueur_min.value				= m_facade_courante.params.longueurMin
			else
				spn_contrainte_longueur_min.value			= m_facade_courante.params.get_longueur ()
			
			
			chk_contrainte_longueur_max.checked				= m_facade_courante.params.longueurMax_use
			spn_contrainte_longueur_max.indeterminate 		= not m_facade_courante.params.longueurMax_use	
			spn_contrainte_longueur_max.enabled 				= m_facade_courante.params.longueurMax_use	
			if not spn_contrainte_longueur_max.indeterminate do
				spn_contrainte_longueur_max.value				= m_facade_courante.params.longueurMax
			

			
			
			ckb_mur_nord.checked				= m_facade_courante.params.murs_nord
			ckb_mur_sud.checked				= m_facade_courante.params.murs_sud
			ckb_mur_est.checked					= m_facade_courante.params.murs_est
			ckb_mur_ouest.checked				= m_facade_courante.params.murs_ouest
			
			
			
			ddl_contrainte_murs.selection 				= m_facade_courante.params.murs
			ddl_contrainte_mode.selection 				= m_facade_courante.params.mode
			
			
			
			if m_facade_courante != undefined do
				remplir_lbx_sequence ()
			
			
			
			
			if not sans_params_1 do (
				
				--- les panneaux parametres ----------
				if m_facade_courante != undefined and m_facade_courante.params.sequence.count > 0 do (
					if  lbx_sequence.selection  == 0 do  lbx_sequence.selection  = 1
					m_composant_courant	= m_facade_courante.params.sequence [ lbx_sequence.selection ]
				)
				
				--- on remplie les sous panneaux -------------------
				if  m_composant_courant != undefined  then
					m_rolloutP.set_param_1  	( m_composant_courant )
				else
					m_rolloutP.set_param_1   undefined
			)
			
			
		)
		
		gerer_boutons_enabled ()
		
	

	)
	
	
	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	on lbx_facades selected val do 
		actualiser ()
	
	
	on btn_compo_nouveau pressed do (
		m_core.get_menu_contructeur	#facCompos
		m_rolloutP.changer_un_truc 		()
	)
		
	on btn_facade_monter pressed do
	(
		
		if lbx_facades.items.count > 0 and lbx_facades.selection == 0 do
			lbx_facades.selection = 1
		if lbx_facades.selection > 1 do (
			local index = lbx_facades.selection
			local fcdTemp = copy m_bat.facades[ index ]
			
			deleteItem 	m_bat.facades		index
			insertItem 	fcdTemp		m_bat.facades 				(index - 1)		
			
			lbx_facades.selection -= 1
			actualiser ()
			m_rolloutP.changer_un_truc 		()
		)
	)
	on btn_facade_descendre pressed do
	(
		
		if lbx_facades.items.count > 0 and lbx_facades.selection == 0 do
			lbx_facades.selection = 1
		if lbx_facades.selection != 0 do (
			local index = lbx_facades.selection
			local fcdTemp = copy m_bat.facades[ index ]
			
			deleteItem m_bat.facades		index
			insertItem fcdTemp		m_bat.facades 				(index+1)		
			
			lbx_facades.selection += 1
			actualiser ()
-- 		gerer_boutons_enabled ()
			m_rolloutP.changer_un_truc 		()
		)
	)
	on btn_facade_dupliquer pressed do	(
		
		if lbx_facades.items.count > 0 and lbx_facades.selection == 0 do
			lbx_facades.selection = 1
		if lbx_facades.selection != 0 do (
			local nvlle_fcd = m_core.dupliquer_facade		m_facade_courante
			insertItem  	nvlle_fcd	m_bat.facades		lbx_facades.selection
			
			m_rolloutP.changer_un_truc 		()
			actualiser ()
			lbx_facades.selection += 1
		)
	)
	on btn_facade_supprimer pressed do
	(	
		if lbx_facades.items.count > 0 and lbx_facades.selection == 0 do
			lbx_facades.selection = 1
		if lbx_facades.selection != 0 do (
			local confirmation 			= querybox ( "Supprimer "  + lbx_facades.items [lbx_facades.selection ] + " ?" )
				if confirmation do (
					local index = lbx_facades.selection
					if index != 0 do (
						deleteItem m_bat.facades	index
						lbx_facades.selection  -= 1
					)
				)
			actualiser ()
			m_rolloutP.changer_un_truc 		()
		)
	)
	on btn_facade pressed do
	(
		local nvlFacade = m_core.creer_facade 				enregistrer:false
		append m_bat.facades	nvlFacade
		nvlFacade.nom += " " + m_bat.facades.count as string
		m_facade_courante = nvlFacade
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on edt_facade_nom entered text do
	(
			m_facade_courante.nom = text
			actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on btn_facades_presets pressed do
	(
		
		)
	on spn_contrainte_etages changed val do
	(
		m_facade_courante.params.etagesMin = val
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on spn_contrainte_etagesMax changed val do
	(
		m_facade_courante.params.etagesMax = val
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on spn_contrainte_longueur_min changed val do
	(
		m_facade_courante.params.longueurMin = val
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on spn_contrainte_longueur_max changed val do
	(
		m_facade_courante.params.longueurMax = val
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on chk_contrainte_longueur_max changed state do
	(
		
		m_facade_courante.params.longueurMax_use = state
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on chk_contrainte_longueur_min changed state do
	(
		m_facade_courante.params.longueurMin_use = state
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on ckb_mur_nord changed state do
	(
		m_facade_courante.params.murs_nord = state
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on ckb_mur_sud changed state do
	(
		m_facade_courante.params.murs_sud = state
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on ckb_mur_est changed state do
	(
		m_facade_courante.params.murs_est = state
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on ckb_mur_ouest changed state do
	(
		m_facade_courante.params.murs_ouest = state
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on ddl_contrainte_murs selected sel do
	(
		
		m_facade_courante.params.murs = sel
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on chk_contrainte_etagesMax changed state do
	(
		m_facade_courante.params.etagesMax_use = state
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
	on chk_contrainte_etages changed state do
	(
		m_facade_courante.params.etagesMin_use = state
		actualiser ()
		m_rolloutP.changer_un_truc 		()
	)
)
rollout sub_toiture "" width:557 height:427
(

	local m_rolloutP
	local m_core
	local m_plug
	local 	m_bat
	
	edittext 'edt1' "" pos:[5,-1] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,-1] width:18 height:18 align:#left
	label 'lbl_appliquerA' "Type :" pos:[10,20] width:32 height:15 align:#left
					
	dropdownList 'ddl_murs' "" pos:[75,18] width:170 height:21 selection:3 align:#left
	
	subRollout 'subroll_parametres' "Parametres" pos:[20,62] width:205 height:209 align:#left
	GroupBox 'grp_prop' "Propriétés" pos:[10,44] width:235 height:238 align:#left
	
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
	)
	

	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	/* 
	fn changer_taille_rollout 	_taille	=(
		
	) */
	 
		
)
rollout sub_materiaux "" width:255 height:427
(


	local m_rolloutP
	local m_core
	local m_plug
	
	edittext 'edt1' "" pos:[5,0] width:222 height:16 align:#left
	button 'btn9' "+" pos:[227,0] width:18 height:18 align:#left
	
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		
	)
	
	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	
	--- Global ------
-- 	GroupBox 'grp_global' "Murs :" pos:[10,56] width:235 height:245 align:#left
	
	/* 
	
	fn changer_taille_rollout 	_taille	=(
		
	)
	  */

)










--Create a rollout
rollout rollout_Urb_Bat_editeur "Urb - Bat - Editeur" width:290	 height:600
(
	--- parametres generaux -----
	local m_plug
	local m_core
	local sub				------ le sous_rollout du tab actif
	
	--- les element manipulés ----------------
	local m_batiment
	local m_facade_courante
	local m_facCompo_courant
	local m_toiture
	
	--- parametres fenetre ---------
	local largeur_base 		= 290
	local largeur_panneau 	= 215
	local nbr_panneau 		= 0
	
	--- pour changement efectués ou non ----
	local m_changement = false
	
	local 	mgr_VP 					= fileIn	 "$userScripts\cp-Urba\modules\Batiment\divers\Batiment - Viewport.ms"
	
	dotNetControl 'tabs' "system.windows.forms.tabControl" pos:[10,22] width:270 height:25 align:#left
	button 'btn_valider' "Valider" pos:[10,483] width:96 height:35 align:#left	
	
	
	
	button 'btn_annuler' "Annuler" pos:[187,483] width:96 height:35 align:#left
	button 'btn_maj' "Maj" pos:[10,3] width:28 height:18 enabled:true align:#left
	
	checkbutton 'ckb_proxy' "Prxy" pos:[64,3] width:28 height:18 enabled:true highlightColor:(color 255 255 0) align:#left
	checkbutton 'ckb_maj_auto' "Auto" pos:[37,3] width:28 height:18 highlightColor:(color 255 255 0) align:#left
	
	checkbutton 'ckb_dist' "Dist" pos:[253,3] width:28 height:18 highlightColor:(color 255 255 0) toolitip:"Affiche les longueur des murs." align:#left
	checkbutton 'ckb_facades' "Fcd." pos:[226,3] width:28 height:18 highlightColor:(color 255 255 0) toolitip:"Affiche les étages." align:#left
	checkbutton 'ckb_etages' "Etg." pos:[199,3] width:28 height:18 highlightColor:(color 255 255 0) toolitip:"Affiche les façades." align:#left
-- 	progressBar 'pb_construction' "ProgressBar" pos:[10,24] width:270 height:6 align:#left
	
	
	subRollout 'subRoll' "Sub" pos:[10,46] width:270 height:407 align:#left
	
	subRollout 'subroll_Params_1' "Paramètres" pos:[289,46] width:210 height:407 align:#left
	subRollout 'subroll_Params_2' "Paramètres" pos:[508,46] width:210 height:407 align:#left
	
	--- viewport ---
	/* 
	fn vp_desactiver				=(
	)
	fn vp_activer 		=(
		
	) */
		
	-- actualisations ------
	fn actualiser 	sans_params_1:false		=(
		if sub != undefined do 
			sub.actualiser sans_params_1:sans_params_1
	)
	fn actualiser_nrbre_panneaux 	=(
		if nbr_panneau > 2 do nbr_panneau = 2
		if nbr_panneau < 0 do nbr_panneau = 0
		rollout_Urb_Bat_editeur.width = largeur_base + nbr_panneau * largeur_panneau
	)
	fn actualiser_taille_rollout 	taille:( getdialogSize rollout_Urb_Bat_editeur )  =(
		
		actualiser_nrbre_panneaux ()
		
		btn_valider.pos.y 		= taille.y - 45
		btn_annuler.pos.y 		= taille.y - 45
		btn_annuler.pos.y 		= taille.y - 45
		subRoll.height 			= taille.y - subRoll.pos.y - 55
		subroll_Params_1.height	= subRoll.height 
		subroll_Params_2.height	= subRoll.height 
		
		if m_core != undefined do
			m_core.editeur_set_taille		taille
-- 		subRoll.rollouts[1].changer_taille_rollout 	_taille 
		
	)
	fn actualiser_VP =(
		
		mgr_VP.longueurs		ckb_dist.checked
		mgr_VP.facades			ckb_facades.checked
		mgr_VP.etages			ckb_etages.checked
		
		m_core.m_edit_affiche_dist 		= ckb_dist.checked
		m_core.m_edit_affiche_fcd 		= ckb_facades.checked
		m_core.m_edit_affiche_etages	= ckb_etages.checked
		
		
	)	
	fn actualiser_geo =(
		
		m_core.actualiser 						bat_edition:m_batiment		proxy:ckb_proxy.checked 
		
		m_core.m_edit_maj_auto 			= ckb_maj_auto.checked
		m_core.m_edit_proxy				=	ckb_proxy.checked	
		
	)
	
	---- accessiosn----------
	fn get_facade_courante =  sub_facades.m_facade_courante
	
	---- changements ----------
	fn changer_un_truc 		=  (
		m_changement = true
		if ckb_maj_auto.checked do 
			actualiser_geo()
	)
	fn onA_changer_unTruc =	m_changement
	fn reset_changement 	=	m_changement = false

	--Add rollouts to the subRollout based on which tab is currently selected. 
	fn ouvrir_tab index	=	(
		--Remove any existing rollouts first. 
 		for x in subRoll.rollouts do removeSubRollout subRoll x
		
		sub=case index of
		(
			default:	sub_general
			1:			sub_facades
			2:			sub_toiture
			3:			sub_materiaux
		)
		addSubRollout subRoll sub
		sub.initialiser  rollout_Urb_Bat_editeur
		sub.actualiser ()
		
		tabs.SelectedIndex = index
		m_core.m_edit_tab = index
	)
	
	--Tab initilization function.
	fn initTabs tab labels:#() =
	(
		
		tab.tabPages.clear()		
		tab.sizeMode=tab.sizeMode.fixed		
		tab.itemSize=dotnetObject "System.Drawing.Size" ((tab.width/( labels.count /* - 1 */ ) ) - 5)   23
		
 		for x in labels do tab.tabPages.add x
	)
	
	fn set_batiment 	_bat = (
		m_batiment = _bat
		actualiser_geo ()
		actualiser_VP ()
	)
	
	fn set_param_1  	_composant =(
		
		for rollAVirer in subroll_Params_1.rollouts do
			removeSubRollout	subroll_Params_1	rollAVirer
	
		--- le subRollout des composants	PANNEAU 1 -------
		if _composant != undefined then (
			addSubRollout	subroll_Params_1		 ( _composant.get_dialog () )
			_composant.initialiser_dialog		m_plug			 	roll_parent:rollout_Urb_Bat_editeur		  ptr_this:_composant
			nbr_panneau = 1
		) else
			nbr_panneau = 0
		actualiser_nrbre_panneaux ()
	)
	fn get_compos_pos = sub_facades.lbx_sequence.selection
	
	
	
	
	
	fn initialiser _plug 		=(
		
		---- pointeurs -------
		m_plug = _plug
		m_core = _plug.core
		
		--- rollout ----------
		actualiser_nrbre_panneaux ()		
		initTabs tabs labels:#("Général", "Façades", "Toiture", "Materiaux")
		
		ckb_dist.checked	 		= m_core.m_edit_affiche_dist
		ckb_facades.checked	 	= m_core.m_edit_affiche_fcd
		ckb_etages.checked	 	= m_core.m_edit_affiche_etages
		
		ckb_maj_auto.checked	= m_core.m_edit_maj_auto
		ckb_proxy.checked	 		= m_core.m_edit_proxy
		
		
	)
	
	
	fn fermer = (
		
		
		local confirmation_fermer = true
		if m_changement do
			confirmation_fermer = queryBox  "Quitter sans enregistrer les modifications ?"
		if confirmation_fermer do (
			
			mgr_VP.desactiver_tout ()
			m_core.editeur_fermer ()
			reset_changement ()
			
			m_core.actualiser ()
			
		)
	)
	fn valider =(
		
		mgr_VP.desactiver_tout ()
		
		m_core.vider_parametres ()
		m_batiment.enregistrer  m_plug
		m_core.editeur_fermer ()
		
		m_core.actualiser ()
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		
	
	
	
	
	
	on rollout_Urb_Bat_editeur open do
		actualiser_taille_rollout ()
	on rollout_Urb_Bat_editeur resized _taille do
		actualiser_taille_rollout  taille:_taille
	on rollout_Urb_Bat_editeur moved _pos do
		m_core.editeur_set_pos		_pos
	on tabs mouseUp senderArg arg do
		ouvrir_tab 	senderArg.SelectedIndex
	on btn_valider pressed do
		valider ()
	on btn_annuler pressed do
		fermer ()
	on btn_maj pressed do
		actualiser_geo ()
	on ckb_proxy changed state do
		actualiser_geo ()
	on ckb_maj_auto changed state do
		actualiser_geo ()
	on ckb_dist changed state do
		actualiser_VP ()
	on ckb_facades changed state do
		actualiser_VP ()
	on ckb_etages changed state do
		actualiser_VP ()
)
rollout_Urb_Bat_editeur

) --- fin 