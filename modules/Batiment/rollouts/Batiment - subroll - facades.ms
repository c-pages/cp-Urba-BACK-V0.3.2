
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
	local m_sequence_a_un_Groupe = false
	
	
	button 'btn_facade_monter' "/\\" pos:[229,18] width:16 height:16 toolTip:"Monter le composant." align:#left
	button 'btn_facade_descendre' "\/" pos:[229,33] width:16 height:16 toolTip:"Descendre le composant." align:#left
	button 'btn_facade_dupliquer' "Dup." pos:[44,-1] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
	button 'btn_facade_supprimer' "Sup." pos:[193,-1] width:35 height:16 toolTip:"Supprimer" align:#left
	listbox 'lbx_facades' "" pos:[10,16] width:218 height:7 align:#left
	button 'btn_facade_nouveau' "Nouv." pos:[10,-1] width:35 height:16 toolTip:"Dupliquer le composant sélectionné." align:#left
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
	
	local btns_parametres_facade = #(	grp_constraintes,	edt_facade_nom,	btn_facades_presets,	spn_contrainte_longueur_min,	spn_contrainte_longueur_max,	lbl_contrainte_longueur,
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
		m_sequence_a_un_Groupe = false
		local tabulation		= "     "
		local i = 1
		
		if m_facade_courante != undefined do
			for comp in m_facade_courante.params.sequence		do	(
				local affichage 		= "  "
				
				if comp.type == #balcon		do est_dansBalcon = true
				if comp.type == #groupe		do est_dansGroupe = groupe_existe = true
				
				if comp.type == #groupe	 or comp.type == #groupeFin	then (
					affichage = "------------- "
					m_sequence_a_un_Groupe = true
				) else if est_dansGroupe do affichage +=  tabulation
				
				if comp.type == #balcon	or  comp.type == #balconFin		then affichage += "  --- "
				else if est_dansBalcon and not comp.type == #groupe	and not comp.type == #groupeFin	  do affichage += " |     "
				
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
					affichage += " groupe fin -------------------------------------------"
					
				-- quelques infos -----
				if comp.params != undefined do
					if comp.params.longueur != 0 do
						affichage += " - " + comp.params.longueur as string + " cm." 
				
				
				append itemsTmp affichage
				
				if comp.type == #balconFin 	do est_dansBalcon = false
				if comp.type == #groupeFin 	do est_dansGroupe = false
				
	-- 			if i == lbx_sequence.selection do (
				if comp == m_composant_courant do (
					m_compoCourant_estDansBalcon = est_dansBalcon
					m_compoCourant_estDansGroupe = est_dansGroupe
				)
				
				i += 1
			)
		lbx_sequence.items =  itemsTmp
		
		
		
	)
	
	fn remplir_lbx_facades =(
		
		lbx_facades.items = #()
		facade_affiche  = #()
		local i = 1
		for fcd in m_bat.facades do (
			append facade_affiche ( "(" + i as string + ")  " + fcd.nom)
			i += 1
		)
		lbx_facades.items = facade_affiche
	)
	
	fn gerer_boutons_enabled 	=(
		
		btn_facade_dupliquer.enabled 	= lbx_facades.selection != 0
		btn_facade_supprimer.enabled 	= lbx_facades.selection != 0
		btn_facade_monter.enabled 	 	= lbx_facades.selection > 1
		btn_facade_descendre.enabled 	= lbx_facades.selection != 0 and lbx_facades.selection != lbx_facades.items.count
		
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
			
			if m_composant_courant.type == #groupe  or m_composant_courant.type == #groupefin do (
				local compo_precedant = m_facade_courante.params.sequence[lbx_sequence.selection - 1] 
				if compo_precedant.type == #groupe or compo_precedant.type == #groupeFin  do (
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
			if m_composant_courant.type == #groupe  or m_composant_courant.type == #groupeFin do (
				local compo_suivant = m_facade_courante.params.sequence[lbx_sequence.selection + 1] 
				if compo_suivant.type == #groupe or compo_suivant.type == #groupeFin   do (
					btnDescendre_enabled = false
				)
			)
		)
		btn_compo_descendre.enabled 		= btnDescendre_enabled
		
		
		
		
		--- les boutons des menus ----------
		m_core.set_menu_enabled 	#facCompos   #balcon   ( not m_compoCourant_estDansBalcon )
		m_core.set_menu_enabled 	#facCompos   #groupe   ( not m_sequence_a_un_Groupe/*  and not m_compoCourant_estDansBalcon */ )
		
-- 		format "( not m_compoCourant_estDansBalcon  : %\n" ( not m_compoCourant_estDansBalcon )
-- 		format "( not m_sequence_a_un_Groupe ) : %\n" ( not m_sequence_a_un_Groupe )
		
	)
	
	fn actualiser 					sans_params_1:false		sans_params_2:false	=(
		
		
		
		
		m_bat							= m_rolloutP.m_batiment


		remplir_lbx_facades ()

		
		
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
			
			
		)
		
-- 		if m_facade_courante != undefined do
		remplir_lbx_sequence ()
		
		if m_facade_courante != undefined and m_facade_courante.params.sequence.count > 0 do (
			local index_selec = lbx_sequence.selection
			if  index_selec  == 0 do  index_selec  = 1
			m_composant_courant	= m_facade_courante.params.sequence [ index_selec ]
		)
-- 			format "m_composant_courant :%\n" m_composant_courant
	
		--- les panneaux parametres ----------
		if not sans_params_1 do (
			
			--- on remplie les sous panneaux -------------------
			if  m_composant_courant != undefined  then
				m_rolloutP.set_param_1  	( m_composant_courant )
			else
				m_rolloutP.set_param_1   undefined
		)
		
		
		
		
		gerer_boutons_enabled ()
		
	

	)
	
	
	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
	)
	
	
	--- outils divers --------------------
	fn chercher_id_suivant  		_i_depart		_type	_tab		=(
		local i = _i_depart --   + 1 
		local trouve = false
		local id_compo_result = 0
		while i <= _tab.count and not trouve do (
			if _tab[ i ].type == _type do (
				id_compo_result = i
				trouve = true
			)
			i += 1
		)
		id_compo_result
	)
	
	fn chercher_id_precedant  		_i_depart		_type	_tab		=(
		local i = _i_depart -- - 2 
		local trouve = false
		local id_compo_result = 0
		while i >= 1 and not trouve do (
			if _tab[ i ].type == _type do (
				id_compo_result = i
				trouve = true
			)
			i -= 1
		)
		id_compo_result
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	on lbx_facades selected val do 
		actualiser ()
	on lbx_sequence  selected val do 
		actualiser ()
	
	on btn_compo_nouveau pressed do (
		m_core.get_menu_contructeur	#facCompos
	)
	
	
	
	
	
	
	on btn_compo_dupliquer pressed do (
		
		m_composant_courant = m_core.dupliquer_composant	m_facade_courante	m_composant_courant
		
		remplir_lbx_sequence	()
		lbx_sequence.selection 	+=	1
		gerer_boutons_enabled	()
		
		m_ssComposant_courant	= undefined

		m_rolloutP.changer_un_truc	()
		actualiser ()
		
	)
	
	
	
	
	on btn_compo_instancier pressed do (
		
		m_composant_courant =  	m_facade_courante.params.instancier_composant	lbx_sequence.selection 
		
		remplir_lbx_sequence ()
		
		lbx_sequence.selection += 1
		gerer_boutons_enabled ()				
		
		m_ssComposant_courant	= undefined
		
		m_rolloutP.changer_un_truc 		()
		actualiser ()
		
	)
	
	
	on btn_compo_supprimer pressed do (
			format "btn_compo_supprimer ---> lbx_sequence.selection :%\n" lbx_sequence.selection
			if queryBox ( "Supprimer le composant: " + m_composant_courant.nom ) do (
				m_plug.core.supprimer_composant 	m_facade_courante		lbx_sequence.selection
				m_ssComposant_courant	= undefined
				lbx_sequence.selection -= 1
				actualiser ()
				m_rolloutP.changer_un_truc 		()
			)
			
		)
		
		
	on btn_compo_monter pressed do	(
		
			if lbx_sequence.items.count > 0 and lbx_sequence.selection == 0 do
				lbx_sequence.selection = 1
			
			if lbx_sequence.selection > 1 do (
				local sequenceTmp =m_facade_courante.params.sequence
				
				local index 			= lbx_sequence.selection
				local compoTemp 	= copy sequenceTmp[ index ]
				local bouge_index	 = index - 1
				local compo_precedant = sequenceTmp[ index - 1 ]
				
				---- si on bouge  un  GROUPE ou une FIN DE GROUPE --------
				if compoTemp.type == #groupe or compoTemp.type == #groupeFin do (
					
					
					---- si on tape dans une fin balcon, on saute le balcon --------
					if compo_precedant.type == #balconFin do 			
						bouge_index = chercher_id_precedant 		index  #balcon   sequenceTmp
					
					---- si on tape dans un balcon, on sort le groupe et le groupe fin --------
					if compo_precedant.type == #balcon do (
						
						-- on cherche le groupe fin a sortir -----						
						local id_grpFin 	= 	chercher_id_suivant 		index  #groupeFin   sequenceTmp
						local grp_fin 	= sequenceTmp [ id_grpFin ]
						
						-- on cherche le balcon fin a sauter -----
						local id_dest_grp_fin = chercher_id_suivant 		index  #balconFin   sequenceTmp
						
						-- on bouge le groupe fin --------
						deleteItem 	sequenceTmp		id_grpFin
						insertItem 	grp_fin				sequenceTmp		id_dest_grp_fin
						
					)
					
				)
				
				---- si on bouge  un  BALCON ou une FIN DE BALCON --------
				if compoTemp.type == #balcon or compoTemp.type == #balconFin do (
					
					---- si on tape dans une fin groupe, on saute le groupe --------					
					if compo_precedant.type == #groupeFin do 
						bouge_index = chercher_id_precedant 		index  #groupe   sequenceTmp
					
					---- si on tape dans un groupe, on sort le balcon et le balcon fin --------
					if compo_precedant.type == #groupe do (
						
						-- on cherche le balcon fin a sortir -----
						local id_balconFin = chercher_id_suivant 		index  #balconFin   sequenceTmp
						local balcon_fin = sequenceTmp [ id_balconFin ]
						
						-- on cherche le groupe fin  a sauter-----
						local id_dest_balcon_fin = chercher_id_suivant 		index  #groupeFin   sequenceTmp
						
						-- on bouge le groupe fin --------
						deleteItem 	sequenceTmp		id_balconFin
						insertItem 	balcon_fin				sequenceTmp		id_dest_balcon_fin
						
					)
					
				)
				
				
				--- on bouge le compo -----------
				deleteItem 	sequenceTmp		index
				insertItem 	compoTemp			sequenceTmp		bouge_index
				
				lbx_sequence.selection = bouge_index
				
			)
		
			m_rolloutP.changer_un_truc 		()
			remplir_lbx_sequence ()
			gerer_boutons_enabled ()				
		)
	on btn_compo_descendre pressed do
	(
			if lbx_sequence.items.count > 0 and lbx_sequence.selection == 0 do
				lbx_sequence.selection = 1
			
			if lbx_sequence.selection < lbx_sequence.items.count do (
				local sequenceTmp =m_facade_courante.params.sequence
				
				local index 			= lbx_sequence.selection
				local compoTemp 	= copy sequenceTmp[ index ]
				local bouge_index	 = index +1
				
				local compo_suivant = sequenceTmp[ index + 1 ]
				
				if compoTemp.type == #groupe or compoTemp.type == #groupeFin do (
					
					---- si on tape dans un balcon, on saute le balcon --------
					if compo_suivant.type == #balcon do 			
						bouge_index = chercher_id_suivant 		index  #balconFin   sequenceTmp
					
					---- si on tape dans une fin de Balcon, on sort le groupe et le groupe fin --------
					if compo_suivant.type == #balconFin do (
						
						-- on cherche le groupe  a sortir -----
						local id_groupe_dbt = chercher_id_precedant 		index  #groupe   sequenceTmp
						local grp_debt 	= sequenceTmp [ id_groupe_dbt ]
						
						-- on cherche le balcon debut  a sauter-----
						local id_dest_grp_dbt = chercher_id_precedant 		index  #balcon   sequenceTmp
						
						-- on bouge le groupe fin --------
						deleteItem 	sequenceTmp		id_groupe_dbt
						insertItem 	grp_debt				sequenceTmp		id_dest_grp_dbt
						
					)
					
				)
				
				
				
				
				if compoTemp.type == #balcon or compoTemp.type == #balconFin do (
					
					
					---- si on tape dans un groupe, on saute le groupe --------
					if compo_suivant.type == #groupe do 			
						bouge_index = chercher_id_suivant 		index  #groupeFin   sequenceTmp
					
					---- si on tape dans une fin de groupe, on sort le balocn et le balcon fin --------
					if compo_suivant.type == #groupeFin do (
						
						-- on cherche le balcon  a sortir -----
						local id_balcon_dbt 	= chercher_id_precedant 		index  #balcon   sequenceTmp
						local balcon_debt 		= sequenceTmp [ id_balcon_dbt ]
						
						-- on cherche le groupe debut  a sauter-----
						local id_dest_balcon_dbt = chercher_id_precedant 		index  #groupe   sequenceTmp
						
						-- on bouge le groupe fin --------
						deleteItem 	sequenceTmp		id_balcon_dbt
						insertItem 	balcon_debt				sequenceTmp		id_dest_balcon_dbt
						
					)
				)
				
				
				deleteItem 	sequenceTmp		index
				insertItem 	compoTemp			sequenceTmp		bouge_index
				
				lbx_sequence.selection = bouge_index
				
			)
		
			m_rolloutP.changer_un_truc 		()
			remplir_lbx_sequence ()
			gerer_boutons_enabled ()				
		)

	
	
	
		
	on btn_facade_monter pressed do
	(
		
		if lbx_facades.items.count > 0 and lbx_facades.selection == 0 do
			lbx_facades.selection = 1
		if lbx_facades.selection > 1 do (
			local index 		= lbx_facades.selection
			local fcdTemp 	= copy m_bat.facades[ index ]
			
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
			local id_selec_back = lbx_facades.selection
			local nvlle_fcd = m_core.dupliquer_facade		m_facade_courante
			insertItem  	nvlle_fcd	m_bat.facades		lbx_facades.selection
			m_facade_courante = nvlle_fcd
			m_rolloutP.changer_un_truc 		()
			
			remplir_lbx_facades ()
			
			lbx_facades.selection = id_selec_back + 1
			actualiser ()
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
	on btn_facade_nouveau 	pressed do
	(
		local selec = 	lbx_facades.selection 
		local nvlFacade = m_core.creer_facade 				enregistrer:false
		append m_bat.facades	nvlFacade
		nvlFacade.nom += " " + m_bat.facades.count as string
		m_facade_courante = nvlFacade
		actualiser ()
		lbx_facades.selection = selec + 1
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
		
		
		
		
	on ddl_contrainte_mode 	selected	val do(
	
		m_facade_courante.params.mode 	= 	val
		actualiser ()
		m_rolloutP.changer_un_truc 		()
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