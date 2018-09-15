/*#########################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale

##########################################################################################################################

	Plugin Batiment - les rolllouts du plug --------------------

##########################################################################################################################

	NOTES :

##########################################################################################################################

	todo:
	- gerer les unité des parametre (pour le calcul ou  l'affichage des longueurpar ex..)

##########################################################################################################################

	changelog:
	*v0.1 - [23/09/2017] -----------------------------------------------------------------------------
	- Mise en place globale

########################################################################################################################*/

---- on  importe les parametres -----
include "$userScripts\\cp-Urba\\modules\\Batiment\\divers\\Batiment - Parametres.ms"

-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  --------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

rollout roll_presets 			"Presets" 		rolledUp:true		(


	button 'btn_enregistrer' "Enregistrer" pos:[88,2] width:85 height:16 align:#left
	button 'btn_charger' 	"Charger" 		pos:[5,2] width:85 height:16 align:#left
	button 'btn_coller' 		"Coller" 		pos:[88,17] width:85 height:16 align:#left
	button 'btn_copier' 		"Copier" 		pos:[5,17] width:85 height:16 align:#left

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

) -- fin rllout presets -*
/* 
rollout roll_global "Global" width:195 height:341
(


	fn shape_filt 		obj = superclassof obj == shape


	button 'btn_enregistrer' "Enregistrer" pos:[88,19] width:77 height:16 align:#left




	button 'btn_charger' "Charger" pos:[13,19] width:76 height:16 enabled:true align:#left
	button 'btn_coller' "Coller" pos:[88,34] width:77 height:16 align:#left
	button 'btn_copier' "Copier" pos:[13,34] width:76 height:16 align:#left

	--- Surface ------
	pickbutton 'btn_pick_surface' "Pick shape" pos:[13,70] width:152 height:16 filter:shape_filt toolTip:"Le shape à utiliser comme surface de base pour la création du bâtiment." autoDisplay:true align:#left
	GroupBox 'grp_surface' "Surface :" pos:[8,56] width:162 height:35 align:#left

	checkbutton 'ckb_editeur' "Edition" pos:[8,94] width:50 height:50 align:#left -- highlightColor:(color 255 255 0)
 -- highlightColor:(color 255 255 0)



	GroupBox 'grp63' "Presets :" pos:[8,1] width:162 height:54 align:#left
	checkbox 'ckb_proxy' "Affichage simplifié" pos:[10,147] width:161 height:19 align:#left



-- 		
-- 			--- Global ------
-- 			GroupBox 'grp_global' "Etages :" pos:[4,40] width:162 height:51 align:#left
-- 		-- 	spinner 'spn_rotation_axeP' "" pos:[88,87] width:48 height:16 range:[-360,360,0] type:#float scale:1 align:#left
-- 		-- 	label 'lbl_axeP' "Orientation:" pos:[10,87] width:59 height:15 align:#left
-- 		-- 	button 'btn_rotation' "+90" pos:[137,87] width:24 height:16 align:#left
-- 			label 'lbl_nbre' "Nbre. d'étages:" pos:[10,56] width:79 height:15 align:#left
-- 			spinner 'spn_nbres' "" pos:[88,55] width:72 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
-- 			spinner 'spn_hauteur' "" pos:[88,71] width:72 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
-- 			label 'lbl_hauteur' "Hauteur :" pos:[10,72] width:76 height:15 align:#left
-- 			 

	--- Facades -----

	--- Toitures -----

	--- Interieur  -----
 	--enabled:false
 	--enabled:false

-- 	button 'btn_editer_etages' "E." pos:[143,72] width:16 height:16 align:#left
	fn actualiser =(

		btn_coller.enabled 			= urba_clipboard_batiment != ""
		ckb_editeur.checked 	= core.editeur_estOuvert ()
		
-- 		lbx_facades.items 						=  facades_nom as array

-- 		btn_supprimerFacade.enabled	=	lbx_facades.selection != 0
-- 		btn_editer_facade.enabled			=	lbx_facades.selection != 0
-- 		btn_dupliquer_facade.enabled	=	lbx_facades.selection != 0

-- 		btn_editer_facade.checked			=	core.facadeEditeur_estOuvert ()
-- 		btn_editer_toiture.enabled 		=	toiture_params != ""

-- 		ddl_toiture.items						=	core.get_toiture_constructeursNoms ()
-- 		ddl_toiture.selection 					= 	core.get_toiture_index ()
		 
	)














	on roll_global open do
		actualiser ()
	on roll_global close do
	(
	 				core.editeur_demander_fermeture()
			)
	on btn_enregistrer pressed do
		core.preset_enregistrer ()
	on btn_charger pressed do
		core.preset_charger ()
	on btn_coller pressed do
	(
			core.preset_coller ()
				actualiser()
			)
	on btn_copier pressed do
	(
			core.preset_copier ()
				actualiser()
			)
	on btn_pick_surface picked _shape do
		core.assigner_surface 		$		_shape
	on ckb_editeur changed state do
	(
			case state of (
				true:		core.editeur_ouvrir ()
				false:	(core.get_editeur_dialog ()).fermer ()
			)
		)
	on ckb_proxy changed state do
		core.actualiser ()
) */
rollout roll_surface "Surface" width:162 height:210
(


	fn shape_filt 		obj = superclassof obj == shape

	--- Surface ------
	pickbutton 'btn_pick_surface' "Pick shape" pos:[7,5] width:152 height:20 filter:shape_filt toolTip:"Le shape à utiliser comme surface de base pour la création du bâtiment." autoDisplay:true align:#left
	
	checkbox 'chk_aplanir' "Aplanir" pos:[6,61] width:62 height:13 align:#left
	checkbox 'chk_ortho' "Orthonorm." pos:[6,46] width:76 height:13 align:#left
	spinner 'spn_aplanir' "" pos:[87,60] width:80 height:16 range:[0,40,0] align:#left
	checkbox 'chk_souder' "Souder" pos:[6,31] width:55 height:13 align:#left
	spinner 'spn_souder' "" pos:[87,30] width:80 height:16 range:[0,100,0] type:#worldunits align:#left
	spinner 'spn_ortho' "" pos:[87,45] width:80 height:16 range:[0,100,0] type:#float align:#left

	checkbox 'chk_aligner' "Aligner" pos:[6,76] width:50 height:13 align:#left
	spinner 'spn_aligner' "" pos:[87,75] width:80 height:16 range:[0,100,0] align:#left

	checkbox 'chk_projeter' "Projeter" pos:[6,91] width:75 height:13 align:#left

	fn actualiser =(

		spn_souder.enabled 				= chk_souder.checked
		spn_souder.Indeterminate 	= not chk_souder.checked

		spn_ortho.enabled 				= chk_ortho.checked
		spn_ortho.Indeterminate 		= not chk_ortho.checked

		spn_aligner.enabled 				= chk_aligner.checked
		spn_aligner.Indeterminate 		= not chk_aligner.checked

		spn_aplanir.enabled 				= chk_aplanir.checked
		spn_aplanir.Indeterminate 		= not chk_aplanir.checked

	)



	on btn_pick_surface picked _shape do
		core.assigner_surface 		$		_shape

	on chk_aplanir changed state  		do
	(
			core.actualiser ()
			actualiser ()
		)
	on chk_ortho changed state  	do
	(
			core.actualiser ()
			actualiser ()
		)
	on spn_aplanir changed state  		do
		core.actualiser ()
	on chk_souder changed state  		do
	(
			core.actualiser ()
			actualiser ()
		)
	on spn_souder changed state  		do
		core.actualiser ()
	on spn_ortho changed state  		do
		core.actualiser ()
	on chk_aligner changed state  		do
	(
			core.actualiser ()
			actualiser ()
		)
	on spn_aligner changed state  		do
		core.actualiser ()
	on chk_projeter changed state  	do
	(
			core.actualiser ()
			actualiser ()
		)
)
rollout roll_general "Général" width:280 height:556
(
	local m_rolloutP
	local m_plug
	local m_core
	
	local m_bat
	
	--- Global ------
	GroupBox 'grp_etages' "Etages :" pos:[4,-3] width:160 height:190 align:#left	
	
	
	
	
	label 'lbl_nbre' "Nombre:" pos:[17,16] width:53 height:15 align:#left
	spinner 'spn_nbres' "" pos:[86,15] width:72 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_hauteur' "Hauteur :" pos:[17,32] width:76 height:15 align:#left
	spinner 'spn_hauteur' "" pos:[86,30] width:72 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	
	--- etages specifiques -----------
	GroupBox 'grp_etages_specifiques' "Etages spécifiques" pos:[10,49] width:148 height:131 align:#left
	button 'btn_etages_nouveau' "Nouv." pos:[17,65] width:35 height:16 toolTip:"Ajouter	étages spécifiques" align:#left
	button 'btn_etages_supprimer' "Sup." pos:[117,64] width:35 height:16 toolTip:"Supprimer étages spécifiques" align:#left	
	
	
	
	listbox 'lbx_etages_specifiques' "" pos:[17,81] width:135 height:4 align:#left
	
	label 'lbl_etage_specifiques' "Etages :" pos:[17,139] width:45 height:19 align:#left
	spinner 'spn_etageMin_specifiques' "" pos:[63,142] width:40 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_hauteur_specifiques' "Hauteur :" pos:[17,157] width:55 height:22 align:#left
	spinner 'spn_etageMax_specifiques' "" pos:[115,142] width:40 height:16 range:[0,1e+13,0] type:#integer align:#left
	checkbutton 'ckb_etageMax_specifiques' ">" pos:[100,141] width:16 height:16 align:#left
	spinner 'spn_hauteur_specifiques' "" pos:[63,158] width:92 height:16 range:[0,1e+13,0] type:#worldunits align:#left
	
	---- Divers ------
	GroupBox 'grp_divers' "Divers" pos:[4,200] width:160 height:60 align:#left
	label 'lbl_decallageZ' "Décallage (Z):" pos:[17,217] width:92 height:18 align:#left
	spinner 'spn_decallageZ' "" pos:[86,217] width:72 height:16 range:[-1e+13,1e+13,0] type:#worldunits scale:1 align:#left
	checkbox 'chk_interieur' "Cloisons intèrieures" pos:[16,236] width:141 height:16 align:#left
	
	
	checkbox 'ckb_proxy' "Affichage simplifié" pos:[4,262] width:161 height:19 align:#left
	
	
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
		
		
	
	
	
	
	
	
		
		
	on spn_nbres changed val do
	(
			m_bat.etages_nbre		= val
			m_rolloutP.changer_un_truc ()
		)
	on spn_hauteur changed val do
	(
			m_bat.etages_hauteur_global		= val
			m_rolloutP.changer_un_truc ()
		)
	on btn_etages_nouveau pressed do
	(
			m_bat.ajouter_etage ()		
			m_rolloutP.changer_un_truc ()
			lbx_etages_specifiques.selection += 1
			actualiser ()
		)
	on btn_etages_supprimer pressed do
	(
			if lbx_etages_specifiques.selection > 0 do (
				m_bat.supprimer_etage		lbx_etages_specifiques.selection
				m_rolloutP.changer_un_truc ()
				if lbx_etages_specifiques.selection > lbx_etages_specifiques.items.count do
					lbx_etages_specifiques.selection = lbx_etages_specifiques.items.count 
				actualiser ()
			)
		)
	on lbx_etages_specifiques selected val 		do
		actualiser ()
	on spn_etageMin_specifiques changed val 		do
		set_etage ()
	on spn_etageMax_specifiques changed val 		do
		set_etage ()
	on ckb_etageMax_specifiques changed state 	do
		set_etage ()
	on spn_hauteur_specifiques changed val 		do
		set_etage ()
	on spn_decallageZ changed val do
	(
			m_bat.decallage_z = val
			m_rolloutP.changer_un_truc ()		
			)
	on chk_interieur changed state do
	(
			m_bat.interieur_use = state
			m_rolloutP.changer_un_truc ()
			)
)

rollout roll_facades "Façades" width:280 height:556
(
	checkbutton 'ckb_editeur' "Edition" pos:[7,7] width:160 height:30 align:#left -- highlightColor:(color 255 255 0)
 -- highlightColor:(color 255 255 0)
	
)
rollout sub_toiture "Toiture" width:557 height:427
(

	local m_rolloutP
	local m_core
	local m_plug
	local m_bat
	
	label 'lbl_appliquerA' "Type :" pos:[7,6] width:32 height:15 align:#left
	
	dropdownList 'ddl_toiture' "" pos:[43,4] width:120 height:21 selection:3 align:#left
	
	subRollout 'subroll_parametres' "Parametres" pos:[7,27] width:155 height:209 align:#left
	
	
	fn actualiser =(
		
		m_bat			= m_rolloutP.m_batiment
		local index_toiture 	= m_bat.get_toiture_index		m_core	
		ddl_toiture.selection 	= 	index_toiture
		
		local dialog_toiture = m_bat.toiture.get_dialog ()		
		for x in subroll_parametres.rollouts do removeSubRollout subroll_parametres x
		addSubRollout subroll_parametres 	dialog_toiture
		
		dialog_toiture.m_compo		= m_bat.toiture		
		dialog_toiture.m_rolloutP	= m_rolloutP
		dialog_toiture.m_plug		= m_plug
		dialog_toiture.actualiser ()
		
-- 		btn_editer_toiture.enabled = mgr_toiture.a_desParametres		()
		
		
		
	)
	

	fn initialiser  _roll_edit =(
		m_rolloutP 	= _roll_edit
		m_plug			= m_rolloutP.m_plug
		m_core			= m_rolloutP.m_core
		
		local mgr_toiture 			= m_core.get_mgr_toiture ()
		local models_toiture 		= mgr_toiture.get_constructeurs ()
		ddl_toiture.items 		=  ( for  model in models_toiture collect model.nom )
	)
	/* 
	fn changer_taille_rollout 	_taille	=(
		
	) */
	 
	on ddl_toiture selected _val do
	(
			
			
			local nvl_toiture 			=	m_core.creer_toiture		_val
			
			
			m_bat.toiture = nvl_toiture
			
			m_rolloutP.changer_un_truc ()
			
			actualiser ()
		)
)


rollout roll_aleatoire "Hasard" width:162 height:237
(
	GroupBox 'grp_ouvrants' "Ouverture fenetres" pos:[6,28] width:162 height:71 align:#left
	label 'lbl_ouvrt_proba' "Probabilité (%):" pos:[15,45] width:69 height:13 align:#left
	spinner 'spn_ouvrt_proba' "" pos:[88,45] width:72 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_ouvrt_max' "Maximum (%):" pos:[15,75] width:67 height:13 align:#left
	spinner 'spn_ouvrt_max' "" pos:[88,75] width:72 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_ouvrt_min' "Minimum (%):" pos:[15,60] width:65 height:13 align:#left
	spinner 'spn_ouvrt_min' "" pos:[88,60] width:72 height:16 range:[0,100,0] scale:1 align:#left

	GroupBox 'grp_volet' "Fermeture volets" pos:[6,103] width:162 height:71 align:#left
	label 'lbl_volet_proba' "Probabilité (%):" pos:[16,120] width:68 height:13 align:#left
	spinner 'spn_volet_proba' "" pos:[88,120] width:72 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_volet_max' "Maximum (%):" pos:[16,150] width:67 height:13 align:#left
	spinner 'spn_volet_max' "" pos:[88,150] width:72 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_volet_min' "Minimum (%):" pos:[16,135] width:68 height:13 align:#left
	spinner 'spn_volet_min' "" pos:[88,135] width:72 height:16 range:[0,100,0] scale:1 align:#left
	label 'lbl_seed' "Seed :" pos:[11,7] width:57 height:13 align:#left
	spinner 'spn_seed' "" pos:[83,7] width:72 height:16 range:[0,1e+20,0] type:#integer scale:1 align:#left
	on spn_ouvrt_proba changed val do
(
	core.actualiser ()
	)
	on spn_ouvrt_max changed val do
(
	core.actualiser ()
	)
	on spn_ouvrt_min changed val do
(
	core.actualiser ()
	)
	on spn_volet_proba changed val do
(
	core.actualiser ()
	)
	on spn_volet_max changed val do
(
	core.actualiser ()
	)
	on spn_volet_min  changed val  do
(
	core.actualiser ()
	)
	on spn_seed changed val do
(
	core.actualiser ()
	)
)

/* 
rollout roll_quartier "Quartier" width:162 height:70
(
	button 'btn_select' "Selectionner Quartier" pos:[5,5] width:152 height:21 align:#left
	
	fn actualiser =
		btn_select.enabled =  quartier_parent != undefined
	
	
	on	roll_quartier open	do
		actualiser ()
	
	on btn_select pressed  do
	(
		select	quartier_parent.node
	)
)
 */

-- maxObjectTabArray (nodeTransformMonitor node:x forwardTransformChangeMsgs:false)




/*
rollout roll_viewport "Viewport" width:162 height:204
(
	label 'lbl16' "Surface:" pos:[5,90] width:43 height:14 align:#left
	label 'lbl_surface' "" pos:[85,90] width:78 height:16 align:#left

	label 'lbl_surfacePts' "Tracé (origin.):" pos:[5,105] width:70 height:14 align:#left
	label 'lbl_surfacePts_val' "" pos:[85,105] width:78 height:16 align:#left

	label 'lbl1_surfacePts_opt' "Tracé (optim.):" pos:[5,120] width:69 height:14 align:#left
	label 'lbl_surfacePts_opt_val' "" pos:[85,120] width:78 height:16 align:#left


	checkbutton 'ckb_axe' "Axe" pos:[10,14] width:75 height:16 align:#left
	checkbutton 'ckb_surface' "Points" pos:[84,14] width:75 height:16 align:#left

	checkbutton 'ckb_pignons' "Pignons" pos:[84,29] width:75 height:16 align:#left
	checkbutton 'ckb_gouttereaux' "Gouttereaux" pos:[10,29] width:75 height:16 align:#left
	checkbutton 'ckb_geometrie' "Cacher géom." pos:[10,64] width:75 height:16 highlightColor:(color 255 0 0) align:#left
	checkbutton 'ckb_ssSurfaces' "Sous tracés" pos:[10,44] width:75 height:16 align:#left

	GroupBox 'grp30' "Afficher:" pos:[5,1] width:158 height:85 align:#left
	checkbox 'ckb_proxy' "Proxy mode" pos:[12,143] width:134 height:29 align:#left


	on ckb_proxy changed state 		do
		core.actualiser ()


) */
