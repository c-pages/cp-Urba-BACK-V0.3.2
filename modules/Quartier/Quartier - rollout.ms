/*#########################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale

	QUARTIER - les rolllouts du plug
	
########################################################################################################################*/


-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  --------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------


/* 
rollout roll_presets "Presets" width:195 height:410
(

	button 'btn_enregistrer' "Enregistrer" pos:[87,6] width:82 height:16 toolTip:"Enregistrer comme preset de quartier." align:#left
	button 'btn_charger' "Charger" pos:[7,6] width:81 height:16 enabled:true toolTip:"Charger un preset de quartier." align:#left

)-- fin rollout ------------------------ */

rollout roll_contours "Contours" width:195 height:410
(
	
	
	fn shape_filt 		obj = superclassof obj == shape  and findItem p_contours	obj == 0
	
	
	--- Surface ------
	checkbutton 'chkbtn_ajouter_contour' "+" pos:[6,6] width:16 height:16 toolTip:"Ajouter des contours au quartier depuis le viewport. (Clique droit pour options)" align:#left
	button 'btn_retirer_contour' "-" pos:[52,6] width:16 height:16 toolTip:"Retirer le contour séléctionné du quartier." align:#left
	button 'btn_liste' "Liste" pos:[21,6] width:32 height:16 toolTip:"Ajouter des contours au quartier depuis une liste." align:#left
	multiListBox 'lbx_contours' "" pos:[6,23] width:168 height:16 align:#left
	button 'btn_select' "Select" pos:[135,6] width:40 height:16 toolTip:"Selectionne les shapes des contours." align:#left
	
	GroupBox 'grp_infos' "Infos   " pos:[6,238] width:168 height:62 align:#left
	
	label 'lbl_info' "Surface : Largeur : Longueur :" pos:[14,254] width:52 height:40 align:#left	
	
	
	
	label 'lbl_infos_valeurs' "...m²\n...m\n...m" pos:[68,254] width:98 height:40 align:#left
	
	
	button 'btn_generer' "Générer le quartier" pos:[6,303] width:168 height:32 align:#left
	
	
	fn afficher_infos	_valeurs	=(
		lbl_infos_valeurs.text	=		( _valeurs[1] / 10000 )	as string + " m²\n"
		lbl_infos_valeurs.text	+=	( _valeurs[2] / 100 )		as string + " m\n"
		lbl_infos_valeurs.text	+=	( _valeurs[3] / 100 )		as string + " m"
	)
	
	
	fn vider_infos =(
		
		lbl_infos_valeurs.text	=	"...m²\n...m\n...m"
		
	)
	
	
	
	fn afficher_contours =(
	
		local noms_contours = for contour in p_contours collect contour.name
		lbx_contours.items = noms_contours
	)

	fn actualiser_infos =(
		
		local sel = ( lbx_contours.selection as array)
		local enable_infos 	=  sel.count != 0
		grp_infos.enabled 			=	enable_infos
		lbl_info.enabled 				=	enable_infos
		lbl_infos_valeurs.enabled	=	enable_infos
		
		if sel.count == 1 then (
			local contour_data = core.analyser_contour 	p_contours[ sel[1] ]
			afficher_infos  #( contour_data.surface as integer, contour_data.largeur as integer, contour_data.longueur as integer )
		) else 
			vider_infos ()
	)
	
	fn actualiser =(
		
		afficher_contours ()		
		actualiser_infos ()
	)


	
	
	
	
	
	
	
	
	
	on roll_contours open do
	(
			core.charger_parametres ()
			actualiser ()
			core.activer_surbrillance ()
		)
	on chkbtn_ajouter_contour changed state do
	(
				if  state do (
					local shps_aAjouter = pickObject filter:shape_filt  count:#multiple  forceListenerFocus:false	rubberBand:$.position 	rubberBandColor:yellow 
					if shps_aAjouter.count > 0 do (
						core.ajouter_contours	shps_aAjouter
						actualiser ()
						lbx_contours.selection = #{lbx_contours.items.count}
						actualiser ()
					)
					chkbtn_ajouter_contour.checked = false
				)
			)
	on btn_retirer_contour pressed do
	(
				core.retirer_contour_parIds	 ( lbx_contours.selection as array)
				actualiser ()
			)
	on btn_liste pressed do
	(
			core.ouvrir_rollout_contours ()
		)
	on lbx_contours selected _id do
	(
			actualiser_infos ()
			redrawviews ()
		)
	on lbx_contours doubleClicked arg do
		select p_contours[arg]
	on btn_select pressed do
	(
				if p_contours.count > 0 do (
					clearSelection ()
					for obj in  p_contours do
						selectMore obj
					redrawViews ()
				)
			)
	on btn_generer pressed do
		core.generer_batiments ()
)

rollout roll_typologies "Typologies" width:195 height:410
(


	button 'btn_enregistrer' "Enregistrer" pos:[90,19] width:79 height:16 toolTip:"Enregistrer comme preset de quartier." align:#left
	button 'btn_charger' "Charger" pos:[12,19] width:79 height:16 enabled:true toolTip:"Charger un preset de quartier." align:#left
	

	--- Surface ------
	button 'btn_creer_typologie' "+" pos:[8,49] width:16 height:16 toolTip:"Créer une nouvelle typologie de batiment." align:#left
	button 'btn_supprimer_typologie' "-" pos:[23,49] width:16 height:16 toolTip:"Supprime la typologie sélectionnée." align:#left
	
	listbox 'lbx_typologies' "" pos:[8,66] width:150 height:16 align:#left
	
	button 'btn_monter' "/\\" pos:[159,65] width:16 height:16 toolTip:"Monter la typologie (pour l'ordre des priorités)." align:#left
	button 'btn_descendre' "\/" pos:[159,81] width:16 height:16 toolTip:"Descendre la typologie (pour l'ordre des priorités)." align:#left
	
	button 'btn_select_bats' "Sel. Batiments" pos:[9,298] width:81 height:16 toolTip:"Selectionne les bâtiments de cette typologie." align:#left
	checkbutton 'chkbtn_surbillance_typo' "" pos:[158,51] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Revele dans le viewport les contours validés pour cette typologie." align:#left
	GroupBox 'grp_presets' "Presets   " pos:[6,4] width:170 height:38 align:#left
	
	button 'btn_generer' "Générer typologie" pos:[8,279] width:162 height:20 toolTip:"Selectionne les shapes des contours." align:#left
	button 'btn_select_contours' "Sel. contours" pos:[89,298] width:81 height:16 toolTip:"Selectionne les contours pris en charge par cette typologie." align:#left
	
	
	fn afficher_typologies =(
		
		local noms_typologies 	= for typo in core.get_typologies () collect typo.nom
		lbx_typologies.items 	= noms_typologies
		
	)

	fn actualiser =(
		
		
		afficher_typologies ()
		
		----- on actualise le rollout des parametre de la typo s'il yen a une de selectionné.---------
		roll_param_typologie.actualiser ()
		
		
		btn_monter.enabled 					= lbx_typologies.selection > 1
		btn_descendre.enabled 			= lbx_typologies.selection != lbx_typologies.items.count		
		btn_supprimer_typologie.enabled	=  lbx_typologies.items.count > 0
		
		btn_generer.enabled 				= lbx_typologies.selection != 0
		btn_select_contours.enabled 		= lbx_typologies.selection != 0
		btn_select_bats.enabled 			= lbx_typologies.selection != 0
		btn_enregistrer.enabled 			= lbx_typologies.selection != 0
	)


	
	
	
	
	
		
	on roll_typologies open do
	(
			core.charger_typologies ()
			actualiser ()
		)
	on btn_enregistrer pressed do
	(
		core.enregistrer_typologies_preset  ()
		)
	on btn_charger pressed do
	(
		format "charger()\n"
			core.charger_typologies_preset  ()
			actualiser ()
		
		)
	on btn_creer_typologie pressed do -- undo "creer_typologie" on
	(
		core.creer_typologie	()
		
		actualiser ()
		lbx_typologies.selection =  lbx_typologies.items.count
		
		actualiser ()
	)
	on btn_supprimer_typologie pressed do -- undo "supprimer_typologie" on
	(
		core.supprimer_typologie	( core.get_typo_active() )
		actualiser ()
		
	)
	on lbx_typologies selected _id do
	(
			actualiser ()
			redrawviews ()
			
		)
	on btn_monter pressed do
	(
		core.monter_typologie	lbx_typologies.selection
		lbx_typologies.selection -= 1 
		actualiser ()
		)
	on btn_descendre pressed do
	(
		core.descendre_typologie	lbx_typologies.selection
		lbx_typologies.selection += 1 
		actualiser ()
		
		)
	on btn_select_bats pressed do
	(
		with redraw off
		(
				clearselection ()
				local typo =  core.get_typo_active () 
				format "typo.batiments_ids	:%\n"	typo.batiments_ids	
				for id_bat in typo.batiments_ids	 do 
					selectmore		p_batiments[ id_bat ]
				
			)
		)
	on chkbtn_surbillance_typo changed state do
	(
-- 		format "STATE : %\n"	state
-- 			case state of (
-- 				true: 	core.activer_surbrillance_typologie ()
-- 				false: 	core.desactiver_surbrillances ()
-- 			)
		)
	on btn_generer pressed do
	(
		core.generer_typologie		( core.get_typo_active () )
		)
	on btn_select_contours pressed do
	(
			with redraw off
			(
					clearselection ()
					local typo =  core.get_typo_active () 
				format "typo.batiments_ids	:%\n"	typo.batiments_ids	
					for id_bat in typo.batiments_ids	 do 
						selectmore		p_batiments[ id_bat ]
					
				)
		)
)


rollout roll_param_typologie "Parametres typologie" width:182 height:447
(

	local		m_typo

	--- Surface ------
	GroupBox 'grp_conditions' "Conditions contours  " pos:[6,95] width:168 height:120 align:#left
	GroupBox 'grp_batiment' "Batiments  " pos:[6,221] width:168 height:155 align:#left
	
	spinner 'spn_surfaceMin' "" pos:[26,126] width:64 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
	spinner 'spn_surfaceMax' "" pos:[103,126] width:63 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
	checkbox 'ckb_surfaceMax_use' "" pos:[90,126] width:15 height:16 highlightColor:(color 255 255 0) toolTip:"Surface maximum." align:#left
	label 'lbl_surface' "Surface (m²):" pos:[14,111] width:75 height:15 align:#left
	checkbox 'ckb_surfaceMin_use' "" pos:[13,126] width:15 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Surface minimum." align:#left
	spinner 'spn_bat_etages_enPlus' "" pos:[101,332] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_largeurMin' "" pos:[26,156] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	spinner 'spn_largeurMax' "" pos:[103,156] width:63 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	checkbox 'ckb_largeurMax_use' "" pos:[90,156] width:15 height:16 highlightColor:(color 255 255 0) toolTip:"Largeur maximum." align:#left
	label 'lbl_largeur' "Largeur :" pos:[14,141] width:52 height:15 align:#left
	checkbox 'ckb_largeurMin_use' "" pos:[13,156] width:15 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Largeur minimum." align:#left
	spinner 'spn_longueurMin' "" pos:[26,186] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	spinner 'spn_longueurMax' "" pos:[103,186] width:63 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	checkbox 'ckb_longueurMax_use' "" pos:[90,186] width:15 height:16 highlightColor:(color 255 255 0) toolTip:"Longueur maximum." align:#left
	label 'lbl_longueur' "Longueur :" pos:[14,171] width:52 height:15 align:#left
	checkbox 'ckb_longueurMin_use' "" pos:[13,186] width:15 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"Longueur minimum." align:#left
	button 'btn_selectionner_batiments' "Select." pos:[123,235] width:42 height:16 align:#left
	label 'lbl_bat_etages_enPlus' "+" pos:[92,332] width:7 height:15 align:#left
	GroupBox 'grp_contours' "Contours sources  " pos:[6,36] width:168 height:55 align:#left
	radiobuttons 'rdo_groupe_use' "" pos:[19,50] width:67 height:32 labels:#("Tous", "Sélection") columns:1 align:#left
	button 'btn_groupe_editer' "Editer" pos:[101,66] width:63 height:16 align:#left
	listbox 'lbx_batiments' "" pos:[16,252] width:149 height:3 align:#left
	spinner 'spn_bat_pourcent' "" pos:[101,299] width:64 height:16 range:[0,100,0] type:#float scale:1 align:#left
	label 'lbl_bat_pourcent' "Pourcentage :" pos:[18,299] width:71 height:15 align:#left
	button 'btn_ajouter_batiment' "+" pos:[17,235] width:16 height:16 align:#left
	button 'btn_retirer_batiment' "-" pos:[32,235] width:16 height:16 align:#left
	edittext 'edt_nom' "" pos:[5,9] width:146 height:16 align:#left
	spinner 'spn_bat_etages' "" pos:[101,317] width:64 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_bat_etages' "Etages :" pos:[18,317] width:47 height:15 align:#left
	colorPicker 'cp_couleur' "" pos:[151,9] width:26 height:17 align:#left
	spinner 'spn_bat_htEtages' "" pos:[101,350] width:64 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_ht_etages' "Ht. étages :" pos:[18,350] width:64 height:15 align:#left
	label 'lbl_plusOuMoins' "+/-" pos:[83,350] width:16 height:15 align:#left
	
	
	
	
	
	local m_btns	=#( 	'grp_conditions', 'grp_batiment',  'spn_surfaceMin' , 'spn_surfaceMax', 'ckb_surfaceMax_use', 'lbl_surface', 'ckb_surfaceMin_use', 'spn_bat_etages_enPlus', 'spn_largeurMin', 'spn_largeurMax', 'ckb_largeurMax_use', \
								'lbl_largeur', 'ckb_largeurMin_use', 'spn_longueurMin', 'spn_longueurMax', 'ckb_longueurMax_use', 'lbl_longueur', 'ckb_longueurMin_use', 'lbl_longueur', 'ckb_longueurMin_use', 'btn_selectionner_batiments', \
								'lbl_bat_etages_enPlus',   'grp_contours', 'rdo_groupe_use', 'btn_groupe_editer', 'lbx_batiments', 'spn_bat_pourcent', 'lbl_bat_pourcent', 'btn_ajouter_batiment', \
								'btn_retirer_batiment', 'edt_nom', 'spn_bat_etages', 'lbl_bat_etages', 'cp_couleur' )
	
	
	local m_btns_batiments = #(	'lbl_plusOuMoins',  'lbl_ht_etages',   'spn_bat_pourcent', 'lbl_bat_pourcent',  'btn_selectionner_batiments', 'lbl_bat_etages_enPlus', 'spn_bat_etages_enPlus',  'btn_retirer_batiment', 'lbl_bat_etages', 'spn_bat_etages' , 'spn_bat_htEtages' )
	
	
	fn actualiser =(
		
-- 		format "ACTUALISER roll_param_typologie() \n"
-- 		format "		m_typo:% \n"	m_typo
		
		---- la typologie selectionnée --------
		local typo_selec = roll_typologies.lbx_typologies.selection 
		if typo_selec == 0 then
			m_typo = undefined
		else (
			m_typo = ( core.get_typologies())[ typo_selec ]
		)
		
		core.set_typo_active 	typo_selec
		
		for btn in m_btns do	(
			btn.enabled =( core.get_typologies ()).count != 0 and m_typo != undefined --	 != undefined
		
-- 		format "			--> btn.enabled  :% \n"	(btn.enabled  )
		)
-- 		format "		core.m_typologies.count != 0 :% \n"	(core.m_typologies.count != 0 )
		
		
		
		
		
		
		if m_typo != undefined then (
			edt_nom.text 						= m_typo.nom			
			cp_couleur.color 					= m_typo.couleur
			
			
			ckb_surfaceMin_use.checked	=	m_typo.conditions_surfMin_use
			spn_surfaceMin.enabled 		= 	m_typo.conditions_surfMin_use
			if m_typo.conditions_surfMin_use then (
				spn_surfaceMin.indeterminate	=	false
				spn_surfaceMin.value = m_typo.conditions_surfMin
			)	else (
				spn_surfaceMin.indeterminate	=	true
			)
			ckb_surfaceMax_use.checked	=	m_typo.conditions_surfMax_use
			spn_surfaceMax.enabled 		= 	m_typo.conditions_surfMax_use
			if m_typo.conditions_surfMax_use then (
				spn_surfaceMax.indeterminate	=	false
				spn_surfaceMax.value = m_typo.conditions_surfMax
			)	else (
				spn_surfaceMax.indeterminate	=	true
			)
			
			
			
			ckb_largeurMin_use.checked	=	m_typo.conditions_largMin_use
			spn_largeurMin.enabled 		= 	m_typo.conditions_largMin_use
			if m_typo.conditions_largMin_use then (
				spn_largeurMin.indeterminate	=	false
				spn_largeurMin.value = m_typo.conditions_largMin
			)	else (
				spn_largeurMin.indeterminate	=	true
			)
			ckb_largeurMax_use.checked	=	m_typo.conditions_largMax_use
			spn_largeurMax.enabled 		= 	m_typo.conditions_largMax_use
			if m_typo.conditions_largMax_use then (
				spn_largeurMax.indeterminate	=	false
				spn_largeurMax.value = m_typo.conditions_largMax
			)	else (
				spn_largeurMax.indeterminate	=	true
			)
			
			
			
			ckb_longueurMin_use.checked	=	m_typo.conditions_longMin_use
			spn_longueurMin.enabled 		= 	m_typo.conditions_longMin_use
			if m_typo.conditions_longMin_use then (
				spn_longueurMin.indeterminate	=	false
				spn_longueurMin.value = m_typo.conditions_longMin
			)	else (
				spn_longueurMin.indeterminate	=	true
			)
			ckb_longueurMax_use.checked	=	m_typo.conditions_longMax_use
			spn_longueurMax.enabled 		= 	m_typo.conditions_longMax_use
			if m_typo.conditions_longMax_use then (
				spn_longueurMax.indeterminate	=	false
				spn_longueurMax.value = m_typo.conditions_longMax
			)	else (
				spn_longueurMax.indeterminate	=	true
			)
			
			
			
			
			local noms_batiments = 	for fichier_bati in m_typo.batiments_models collect ( ( filenameFromPath fichier_bati ) as string )
			lbx_batiments.items = noms_batiments
			
			
			local batiment_actif = lbx_batiments.selection != 0
			for btn in m_btns_batiments do btn.enabled = batiment_actif
			
			if batiment_actif then (
				spn_bat_pourcent.indeterminate			=	false
				spn_bat_etages.indeterminate			=	false
				spn_bat_etages_enPlus.indeterminate	=	false
				spn_bat_htEtages.indeterminate			=	false
				spn_bat_pourcent.value 			= m_typo.batiments_pourcent[ lbx_batiments.selection ]
				spn_bat_etages.value 				= m_typo.batiments_nbr_etages[ lbx_batiments.selection ]
				spn_bat_etages_enPlus.value 	= m_typo.batiments_nbr_etagesPlus[ lbx_batiments.selection ]
				spn_bat_htEtages.value 			= m_typo.batiments_ht_etages[ lbx_batiments.selection ]
				
			) else (
				spn_bat_pourcent.indeterminate			=	true
				spn_bat_etages.indeterminate			=	true
				spn_bat_etages_enPlus.indeterminate	=	true
				spn_bat_htEtages.indeterminate			=	true
			)
			
			
			
			
			
			
			
			
			
			if m_typo.contours_tout then (
				rdo_groupe_use.state = 1 
				btn_groupe_editer.enabled = false
			) else (
				rdo_groupe_use.state = 2
				btn_groupe_editer.enabled = true				
			)
		) else (
			cp_couleur.color = color 10	10	10
		)
		
		
		
	)
	
	
	
	
	
	
	on roll_param_typologie open do
	(
	-- 		format "actualiser OPEN\n"
			actualiser ()
			
		)
	on spn_surfaceMin changed val do
	(
				m_typo.conditions_surfMin = val
				core.analyser_typologies ()
				core.enregistrer_typologie		m_typo
				actualiser ()
		)
	on spn_surfaceMax changed val do
	(
				m_typo.conditions_surfMax = val
				core.analyser_typologies ()
				core.enregistrer_typologie		m_typo
				actualiser ()
		)
	on ckb_surfaceMax_use changed state do
	(
				m_typo.conditions_surfMax_use = state
				core.analyser_typologies ()
				core.enregistrer_typologie		m_typo
				actualiser ()
		
		)
	on ckb_surfaceMin_use changed state do
	(
				m_typo.conditions_surfMin_use =state
				core.analyser_typologies ()
				core.enregistrer_typologie		m_typo
				actualiser ()
		
		)
	on spn_bat_etages_enPlus changed val do
	(
		
		
		
				m_typo.batiments_nbr_etagesPlus[ lbx_batiments.selection ] = val
				core.analyser_typologies ()
					core.enregistrer_typologie		m_typo
					actualiser ()
		
		)
	on spn_largeurMin changed val do
	(
					m_typo.conditions_largMin = val
				core.analyser_typologies ()
					core.enregistrer_typologie		m_typo
					actualiser ()
	)
	on spn_largeurMax changed val do
	(
					m_typo.conditions_largMax = val
				core.analyser_typologies ()
					core.enregistrer_typologie		m_typo
					actualiser ()
	)
	on ckb_largeurMax_use changed state do
	(
				m_typo.conditions_largMax_use =state
				core.enregistrer_typologie		m_typo
				actualiser ()
		
		)
	on ckb_largeurMin_use changed state do
	(
				m_typo.conditions_largMin_use =state
				core.analyser_typologies ()
				core.enregistrer_typologie		m_typo
				actualiser ()
		
		)
	on spn_longueurMin changed val do
	(
					m_typo.conditions_longMin = val
				core.analyser_typologies ()
					core.enregistrer_typologie		m_typo
					actualiser ()
	)
	on spn_longueurMax changed val do
	(
					m_typo.conditions_longMax = val
				core.analyser_typologies ()
					core.enregistrer_typologie		m_typo
					actualiser ()
	)
	on ckb_longueurMax_use changed state do
	(
				m_typo.conditions_longMax_use =state
				core.analyser_typologies ()
				core.enregistrer_typologie		m_typo
				actualiser ()
		
		)
	on ckb_longueurMin_use changed state do
	(
				m_typo.conditions_longMin_use =state
				core.analyser_typologies ()
				core.enregistrer_typologie		m_typo
				actualiser ()
		
		)
	on rdo_groupe_use changed state do
	(
			m_typo.contours_tout = state == 1
				core.analyser_typologies ()
			core.enregistrer_typologie		m_typo
			actualiser ()
		)
	on lbx_batiments selected sel do
	(
		actualiser ()
		)
	on lbx_batiments doubleClicked sel do
	(
		clearselection()
		
	)
	on spn_bat_pourcent changed val do
	(
		m_typo.batiments_pourcent[ lbx_batiments.selection ] = val
		core.analyser_typologies ()
		core.enregistrer_typologie			m_typo
		actualiser ()
	)
	on btn_ajouter_batiment pressed do
	(
			core.ajouter_batiment_aTypo 	m_typo
			core.analyser_typologies ()
			core.enregistrer_typologie			m_typo
			actualiser ()
		)
	on btn_retirer_batiment pressed do
	(
				core.retirer_batiment_aTypo 	m_typo		lbx_batiments.selection
				core.enregistrer_typologie		m_typo
				actualiser ()
		)
	on edt_nom entered text do
	(
			m_typo.nom	=	text
			core.enregistrer_typologie		m_typo
			roll_typologies.actualiser ()
		)
	on spn_bat_etages changed val do
	(
		
			m_typo.batiments_nbr_etages[ lbx_batiments.selection ] = val
			core.analyser_typologies ()
			core.enregistrer_typologie			m_typo
			actualiser ()
		)
	on cp_couleur changed col do
	(
		m_typo.couleur	=	col
		core.enregistrer_typologie		m_typo
	)
	on spn_bat_htEtages changed val do
	(
			m_typo.batiments_ht_etages[ lbx_batiments.selection ] = val
			core.analyser_typologies ()
			core.enregistrer_typologie			m_typo
			actualiser ()
		)
)




rollout roll_affichage "Affichage" width:182 height:60
(
	checkbox 'ckb_majAuto' "Maj. auto" pos:[7,7] width:84 height:16 align:#left
	
	checkbox 'ckb_proxies' "Proxies" pos:[90,7] width:84 height:16 align:#left
	
	fn actualiser =(
		ckb_proxies.enabled = ckb_majAuto.checked 
	)

	on roll_affichage open do
		actualiser ()
	on ckb_majAuto changed state do
		actualiser ()
)







