﻿/*#########################################################################################################################
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



-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- PARAMETRES  ---------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
parameters params_global 						rollout:roll_global		(
	
	------- Surface		------------------
	surface_node					type:#node 								 	ui:btn_pick_surface		animatable:false		invisibleInTV:true
-- 	orientation						type:#float				default:0.		ui:spn_rotation_axeP		animatable:false		invisibleInTV:true
	
	------- Etages			------------------
	etages_hauteur				type: #float 				default:250.		ui:spn_hauteur		animatable:false		invisibleInTV:true
	etages_nbre					type: #integer			default:1			ui:spn_nbres			animatable:false		invisibleInTV:true
	

)
parameters params_constantes 							(
	

	------- Constantes 	-----------------
	const_dalle_epaisseur				type: #float 				default:20.	animatable:false		invisibleInTV:true
	const_murExt_epaisseur				type: #float 				default:30.	animatable:false		invisibleInTV:true
	const_ssBassement_epaisseur	type: #float 				default:100.	animatable:false		invisibleInTV:true
	const_couvertine_epaisseur		type: #float 				default:5.		animatable:false		invisibleInTV:true

)
parameters params_optimSurface				rollout:roll_optimSurface	(
	
	------- Optimisations		------------------
	optim_aplanir					type:#boolean			default:true		ui:chk_aplanir		animatable:false		invisibleInTV:true
	optim_souder					type:#boolean			default:true		ui:chk_souder		animatable:false		invisibleInTV:true
	optim_orthonormer			type:#boolean			default:false		ui:chk_ortho			animatable:false		invisibleInTV:true
	optim_aligner					type:#boolean			default:false		ui:chk_aligner		animatable:false		invisibleInTV:true
	optim_projeter					type:#boolean			default:false		ui:chk_projeter		animatable:false		invisibleInTV:true
	
	------- Seuils		------------------
	optim_aplanir_seuil			type:#float				default:20.			ui:spn_aplanir		animatable:false		invisibleInTV:true
	optim_souder_seuil			type:#float				default:30.			ui:spn_souder		animatable:false		invisibleInTV:true
	optim_ortho_seuil				type:#float				default:100.			ui:spn_ortho			animatable:false		invisibleInTV:true
	optim_aligner_seuil			type:#float				default:50.			ui:spn_aligner		animatable:false		invisibleInTV:true
	
)
parameters params_viewport					rollout:roll_viewport	(
	
	------- AFFICHAGE 		 ------------------
	affiche_axe					type:#boolean			default:false	ui:ckb_axe				animatable:false		invisibleInTV:true
	affiche_surface				type:#boolean			default:false	ui:ckb_surface			animatable:false		invisibleInTV:true
	affiche_gouttereaux		type:#boolean			default:false	ui:ckb_gouttereaux	animatable:false		invisibleInTV:true
	affiche_pignons				type:#boolean			default:false	ui:ckb_pignons			animatable:false		invisibleInTV:true
	affiche_ssSurfaces			type:#boolean			default:false	ui:ckb_ssSurfaces		animatable:false		invisibleInTV:true	
	affiche_geometrie			type:#boolean			default:false	ui:ckb_geometrie		animatable:false		invisibleInTV:true
	
)
parameters params_facades 						rollout:roll_global	(
	
	---- générale -----------
	fac_ids 								type:#stringTab 	tabSize:0  		tabSizeVariable:true
	fac_noms 							type:#stringTab 	tabSize:0  		tabSizeVariable:true		--ui:lbx_facades	
	
	--- Limiteurs - Etages	---
	fac_etagesMin_uses			type:#boolTab		tabSize:0 			tabSizeVariable:true
	fac_etagesMin					type:#intTab			tabSize:0 			tabSizeVariable:true
	fac_etagesMax_uses			type:#boolTab		tabSize:0 			tabSizeVariable:true
	fac_etagesMax					type:#intTab			tabSize:0 			tabSizeVariable:true
	
	--- Limiteurs - longueurs	---
	fac_longueurMin_uses		type:#boolTab		tabSize:0 			tabSizeVariable:true
	fac_longueurMin				type:#floatTab		tabSize:0 			tabSizeVariable:true
	fac_longueurMax_uses		type:#boolTab		tabSize:0 			tabSizeVariable:true
	fac_longueurMax				type:#floatTab		tabSize:0 			tabSizeVariable:true
	
	--- Limiteurs - Murs	---
	fac_murs							type:#intTab			tabSize:0 			tabSizeVariable:true			---- ( 1:les deux	2:gouttereaux	3:pignons )	----
	fac_modes							type:#intTab			tabSize:0 			tabSizeVariable:true			---- ( 1:repeter	2:etrier			3:centrer )	----
	
	--- Sequence	---
	fac_sequences					type:#stringTab 	tabSize:0 			tabSizeVariable:true
	fac_sequence_longueurs		type:#floatTab	 	tabSize:0 			tabSizeVariable:true
	
)
parameters params_facades_composants 		(
	
	---- les composants de facades -----------
	fac_compos_ids 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	fac_compos_noms 			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	fac_compos_types 			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	fac_compos_params			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	
)
parameters params_toiture 							(
	toiture_type						type:#string 		 default:"sans"	 		 	animatable:false		invisibleInTV:true
	toiture_params					type:#string	 				animatable:false		invisibleInTV:true /* tabSize:0  		tabSizeVariable:true */
	
	/* 
	toit_pente			type: #float 				default:20		ui:spn_pente					animatable:false		invisibleInTV:true
	toit_hauteur			type: #float 				default:20.	ui:spn_toit_hauteur		animatable:false		invisibleInTV:true
	toit_orientation		type:#float				default:0.											animatable:false		invisibleInTV:true
	*/
	
)


-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  --------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
rollout roll_presets 			"Presets" 		rolledUp:true		(
	
	fn shape_filt 		obj = superclassof obj == shape
	
	button 'btn_enregistrer' "Enregistrer" pos:[88,2] width:85 height:16 align:#left		
		
		
	button 'btn_charger' 	"Charger" 	pos:[5,2] width:85 height:16 align:#left
	button 'btn_coller' 		"Coller" 		pos:[88,17] width:85 height:16 align:#left
	button 'btn_copier' 		"Copier" 		pos:[5,17] width:85 height:16 align:#left
	
	/* --------------------  CLEANAGE --------------------
	fn actualiser =(
		
		btn_coller.enabled 			= a_un_surface and urba_clipboard_batiment != ""
		btn_copier.enabled 			= a_un_surface
		btn_enregistrer.enabled 	= a_un_surface
		btn_charger.enabled 		= a_un_surface
		 
	)
	
	
	
	
	on roll_presets open do actualiser ()

	on btn_enregistrer pressed do
		presets.enregistrer 	this
	on btn_charger pressed do
	(
			presets.charger 					this
		
			facades.actualiser ()
		
			surface.actualiser 	()
			construire.batiment 	()
			actualiser_rollouts()
		)
	on btn_coller pressed do
	(
			presets.coller 	this 
		
			facades.actualiser ()
		
			surface.actualiser ()
			construire.batiment ()
			actualiser_rollouts()
			
		)
	on btn_copier pressed do
	(
			presets.copier 	this 
			actualiser()
		)
		
	*/ --------------------  CLEANAGE --------------------
)
rollout roll_global 			"Global" 		rolledUp:false 	(
	
	
	fn shape_filt 		obj = superclassof obj == shape
	
	--- Surface ------
	pickbutton 'btn_pick_surface' "Pick shape" pos:[10,14] width:150 height:18 filter:shape_filt toolTip:"Le shape à utiliser comme surface de base pour la création du bâtiment." autoDisplay:true align:#left
	GroupBox 'grp_surface' "Surface:" pos:[4,0] width:162 height:38 align:#left

	--- Global ------
	GroupBox 'grp_global' "Etages:" pos:[4,40] width:162 height:51 align:#left
-- 	spinner 'spn_rotation_axeP' "" pos:[88,87] width:48 height:16 range:[-360,360,0] type:#float scale:1 align:#left
-- 	label 'lbl_axeP' "Orientation:" pos:[10,87] width:59 height:15 align:#left
-- 	button 'btn_rotation' "+90" pos:[137,87] width:24 height:16 align:#left
	label 'lbl_nbre' "Nbre. d'étages:" pos:[10,56] width:79 height:15 align:#left
	spinner 'spn_nbres' "" pos:[88,55] width:72 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_hauteur' "" pos:[88,71] width:72 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Htr. des étages:" pos:[10,72] width:76 height:15 align:#left
	
	
	--- Facades -----
	GroupBox 'grp_facades' "Façades:" pos:[4,94] width:162 height:121 align:#left
	listbox 'lbx_facades' "" pos:[10,125] width:150 height:6 align:#left 
 
 
	button 'btn_editer_facade' "Edit" pos:[133,108] width:28 height:16 align:#left
	button 'btn_ajouterFacade' "+" pos:[10,108] width:16 height:16 align:#left
	button 'btn_supprimerFacade' "-" pos:[25,108] width:16 height:16 align:#left
	
	
	--- Toitures -----
	GroupBox 'grp14' "Toiture :" pos:[3,217] width:162 height:40 align:#left
	button 'btn_editer_toiture' "Edit" pos:[133,232] width:28 height:19 align:#left
	dropdownList 'ddl_toiture' "" pos:[10,232] width:123 height:21 align:#left
	
	
	
	fn actualiser =(
		
		lbx_facades.items 		=  core.get_facades_noms ()
		
-- 		if lbx_facades.selection == 0 then (
			btn_supprimerFacade.enabled	=	 lbx_facades.selection != 0 
			btn_editer_facade.enabled			=	 lbx_facades.selection != 0 
-- 		) else (
			
-- 		)
		local mgr_toiture 		= core.get_mgr_toiture ()
		local index_toiture 	= core.get_toiture_index ()
		ddl_toiture.selection 	= 	index_toiture
		
		btn_editer_toiture.enabled = mgr_toiture.a_desParametres		()
		
		if index_toiture == 1 then
			btn_editer_toiture.enabled = false
		else
			btn_editer_toiture.enabled = true
		
		
	)
	
	
	
	fn initialiser =(
		local mgr_toiture 			= core.get_mgr_toiture ()
		local models_toiture 		= mgr_toiture.get_modeles ()
		ddl_toiture.items 		=  ( for  model in models_toiture collect model.titre )
	)
	
	
	
	on btn_pick_surface	picked 	_shape do
		core.assigner_surface 		$		_shape 		
	
	on ddl_toiture selected 	_val do (
		local mgr_toiture 			= core.get_mgr_toiture ()
		mgr_toiture.assigner 	_val
		core.actualiser ()
		actualiser ()
	)
	
	on roll_global open do
	(
			initialiser()
			actualiser ()
		)
	on spn_nbres changed val do
		core.actualiser ()
	on spn_hauteur changed val do
		core.actualiser ()
	/* 
	on spn_hauteur buttonDown do (

		flagForeground $ true
	)
	on spn_hauteur buttonup  inCancel_arg do (
		flagForeground $ false
	) */
	on lbx_facades doubleClicked arg do
		core.facadeEditeur_ouvrir	 	lbx_facades.selection
	on btn_ajouterFacade pressed do
	(
			core.creer_facade ()
			actualiser ()
			lbx_facades.selection = lbx_facades.items.count
			
			core.facadeEditeur_ouvrir	 	lbx_facades.selection
		)
	on btn_supprimerFacade pressed do
	(
			core.supprimer_facade		lbx_facades.selection 
		)
	on btn_editer_toiture pressed do (
		local toiture = core.get_toiture ()
		local dialog = toiture.get_dialog ()
		createDialog 	dialog
		dialog.initialiser 	$	toiture 
	)
)
rollout roll_optimSurface 	"Surface" 		rolledUp:true		(
	
	checkbox 'chk_aplanir' "Aplanir" pos:[6,34] width:62 height:13 align:#left
	checkbox 'chk_ortho' "Orthonorm." pos:[6,19] width:76 height:13 align:#left
	spinner 'spn_aplanir' "" pos:[87,33] width:80 height:16 range:[0,40,0] align:#left
	checkbox 'chk_souder' "Souder" pos:[6,4] width:55 height:13 align:#left
	spinner 'spn_souder' "" pos:[87,3] width:80 height:16 range:[0,100,0] type:#worldunits align:#left
	spinner 'spn_ortho' "" pos:[87,18] width:80 height:16 range:[0,100,0] type:#float align:#left
	
	checkbox 'chk_aligner' "Aligner" pos:[6,49] width:50 height:13 align:#left
	spinner 'spn_aligner' "" pos:[87,48] width:80 height:16 range:[0,100,0] align:#left
	
	checkbox 'chk_projeter' "Projeter" pos:[6,64] width:75 height:13 align:#left
	
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
	
	on roll_surface 	open 				do	actualiser ()
	
	on chk_aplanir 	changed state  		do	(
		core.actualiser ()
		actualiser ()
	)
	on chk_ortho 		changed state  	do	(
		core.actualiser ()
		actualiser ()
	)
	on chk_souder 	changed state  		do	(
		core.actualiser ()		
		actualiser ()
	)
	on chk_aligner 	changed state  		do	(
		core.actualiser ()
		actualiser ()
	)
	on chk_projeter 	changed state  	do	(
		core.actualiser ()
		actualiser ()
	)
	
	on spn_aplanir 	changed state  		do	core.actualiser ()
	on spn_souder	changed state  		do	core.actualiser ()
	on spn_ortho	 	changed state  		do	core.actualiser ()
	on spn_aligner 	changed state  		do	core.actualiser ()
	
)
rollout roll_viewport 			"Viewport"		rolledUp:true		(
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
	checkbutton 'ckb_geometrie' "Cacher géom." pos:[10,65] width:75 height:16 highlightColor:(color 255 0 0) align:#left
	checkbutton 'ckb_sssurfaces' "Sous tracés" pos:[10,44] width:75 height:16 align:#left
	
	GroupBox 'grp30' "Afficher:" pos:[5,1] width:158 height:85 align:#left
	
	
	
	/* --------------------  CLEANAGE --------------------
	
	fn actualiser =(
		
		ckb_axe.enabled 					= a_un_surface
		ckb_surface.enabled 				= a_un_surface
		ckb_pignons.enabled 			= a_un_surface
		ckb_gouttereaux.enabled 		= a_un_surface
		ckb_geometrie.enabled 			= a_un_surface
		grp30.enabled 			= a_un_surface
		
		lbl16.enabled 			= a_un_surface
		lbl_surface.enabled 			= a_un_surface
		lbl1_surfacePts.enabled 			= a_un_surface
		lbl_surfacePts_val.enabled 			= a_un_surface
		lbl1_surfacePts_opt.enabled 			= a_un_surface
		lbl_surfacePts_opt_val.enabled 			= a_un_surface
		if a_un_surface do (
			lbl_surface.text = ( surface / 10000 ) as string + " m²"
			lbl_surfacePts_val.text = surface_original.count as string + " pts."
			lbl_surfacePts_opt_val.text = surface_courant.count as string + " pts."
		)
	)
	
	
	
	
-- 		on ckb_longueurSegts 	changed state 		do	VP_toggle ()
	
	
	on roll_infos open do
		actualiser ()
	on roll_infos close do
	(
			cache_geometrie = false 
			actualiser_cacherGeo ()
		)
	on ckb_axe changed state 		do
		VP_toggle ()
	on ckb_surface changed state 		do
		VP_toggle ()
	on ckb_pignons changed state 		do
	(
			VP_toggle ()
			actualiser ()
		)
	on ckb_gouttereaux changed state 		do
	(
			VP_toggle ()
			actualiser ()
		)
	on ckb_geometrie changed state 		do
		actualiser_cacherGeo ()
*/ --------------------  CLEANAGE --------------------
)
rollout roll_aPropos 			"A propos" 	rolledUp:false	(
	label 'lbl_axeP' "Urba | V0.1  |" pos:[5,2]  align:#left
	HyperLink 'hpl1' "Christophe Pagès" pos:[76,2] address:"http://c-pages.fr" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	HyperLink 'hpl2' "GitHub" pos:[127,17] address:"https://github.com/c-pages/cp-Urba-Cleanage" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	label 'lbl6' "2017" pos:[5,17] align:#left
)




