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
include "$userScripts\\cp-Urba\\modules\\Batiment\\rollouts\\Batiment - Parametres.ms" 

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
	
) -- fin rllout presets -
rollout roll_global "Global" width:162 height:341
(
	
	
	fn shape_filt 		obj = superclassof obj == shape
	
	--- Surface ------
	pickbutton 'btn_pick_surface' "Pick shape" pos:[10,14] width:150 height:18 filter:shape_filt toolTip:"Le shape à utiliser comme surface de base pour la création du bâtiment." autoDisplay:true align:#left
	GroupBox 'grp_surface' "Surface :" pos:[4,0] width:162 height:38 align:#left

	--- Global ------
	GroupBox 'grp_global' "Etages :" pos:[4,40] width:162 height:51 align:#left
-- 	spinner 'spn_rotation_axeP' "" pos:[88,87] width:48 height:16 range:[-360,360,0] type:#float scale:1 align:#left
-- 	label 'lbl_axeP' "Orientation:" pos:[10,87] width:59 height:15 align:#left
-- 	button 'btn_rotation' "+90" pos:[137,87] width:24 height:16 align:#left
	label 'lbl_nbre' "Nbre. d'étages:" pos:[10,56] width:79 height:15 align:#left
	spinner 'spn_nbres' "" pos:[88,55] width:72 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_hauteur' "" pos:[88,71] width:72 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Htr. des étages:" pos:[10,72] width:76 height:15 align:#left
	
	
	--- Facades -----
	GroupBox 'grp_facades' "Façades :" pos:[4,94] width:162 height:121 align:#left
	listbox 'lbx_facades' "" pos:[10,125] width:150 height:6 align:#left
	button 'btn_dupliquer_facade' "Dup." pos:[40,108] width:28 height:16 align:#left
	button 'btn_ajouterFacade' "+" pos:[10,108] width:16 height:16 align:#left
	button 'btn_supprimerFacade' "-" pos:[25,108] width:16 height:16 align:#left
	checkbutton 'btn_editer_facade' "Edit" pos:[133,108] width:28 height:16 align:#left
	
	--- Toitures -----
	GroupBox 'grp14' "Toiture :" pos:[3,217] width:162 height:40 align:#left
	button 'btn_editer_toiture' "Edit" pos:[133,232] width:28 height:19 align:#left
	dropdownList 'ddl_toiture' "" pos:[10,232] width:123 height:21 align:#left
	
	--- Interieur  -----
	GroupBox 'grp_interieur' "Interieur :" pos:[3,259] width:162 height:40 align:#left enabled:false
	checkbox 'chk_planchers' "Planchers" pos:[10,278] width:60 height:12 align:#left	enabled:false
	
	fn actualiser =(
		/* 
		lbx_facades.items 						=  for facadeNom in fac_noms collect facadeNom
		 
		
		btn_supprimerFacade.enabled	=	 lbx_facades.selection != 0 
		btn_editer_facade.enabled			=	 lbx_facades.selection != 0 
		btn_dupliquer_facade.enabled	=	 lbx_facades.selection != 0
		
		btn_editer_facade.checked			= 	core.facadeEditeur_estOuvert ()
		
-- 		local index_toiture 					= core.get_toiture_index ()
-- 		ddl_toiture.selection 					= 	index_toiture
		
		local mgr_toiture 						= core.get_mgr_toiture ()
		btn_editer_toiture.enabled 		= mgr_toiture.a_desParametres		()
		
-- 		if index_toiture == 1 then
-- 			btn_editer_toiture.enabled = false
-- 		else
-- 			btn_editer_toiture.enabled = true
		
		 */
	)
	
	
	
	fn initialiser =(
		/* 
		local mgr_toiture 			= core.get_mgr_toiture ()
		local models_toiture 		= mgr_toiture.get_constructeurs ()
		ddl_toiture.items 		=  ( for  model in models_toiture collect model.titre )
		 */
	)
	




	on roll_global open do
	(
			initialiser()
			actualiser ()
		)
	on roll_global close do
	(
-- 				core.fermer_toutes_fenetres query:true
			)
	on btn_pick_surface picked _shape do
		core.assigner_surface 		$		_shape
	on spn_nbres changed val do
		core.actualiser ()
	on spn_hauteur changed val do
		core.actualiser ()
	on lbx_facades selected val do	(
			if core.facadeEditeur_estOuvert () do (
-- 				local index_facade_ouverte = ( core.get_mgr_facades () ).get_index_facadeOuverte ()
-- 				if lbx_facades.selection != index_facade_ouverte do
					core.facadeEditeur_ouvrir	 	lbx_facades.selection
			)
			actualiser ()
		)
	on lbx_facades doubleClicked arg do (
			if not core.facadeEditeur_estOuvert () do (
					core.facadeEditeur_ouvrir	 	lbx_facades.selection
			)
		)
	on btn_dupliquer_facade pressed do
	(
			core.dupliquer_facade		lbx_facades.selection 
			actualiser ()
		)
	on btn_ajouterFacade pressed do
	(
				core.creer_facade ()
				actualiser ()
				lbx_facades.selection = lbx_facades.items.count
				
				core.facadeEditeur_ouvrir	 	lbx_facades.selection
			)
	on btn_supprimerFacade pressed do
	(		
			local confirmation 			= querybox ( "Supprimer "  + lbx_facades.items [lbx_facades.selection ] + " ?" )
			if confirmation do (
				core.supprimer_facade		lbx_facades.selection
				lbx_facades.selection  -= 1
				core.facadeEditeur_fermer ()
				actualiser ()
			)
		)
	on btn_editer_facade changed state  do
	(
			case state of (
				true:		core.facadeEditeur_ouvrir	 	lbx_facades.selection
				false:	core.facadeEditeur_fermer ()
			)
			actualiser ()
		)
	on btn_editer_toiture pressed do
	(
			local mgr_toiture = core.get_mgr_toiture()
			local toiture = core.get_toiture ()
			mgr_toiture.ouvrir_dialog		toiture
-- 			dialog.initialiser 	$	toiture 
		)
	on ddl_toiture selected _val do
	(
			local mgr_toiture 			= core.get_mgr_toiture ()
			local toiture = mgr_toiture.creer_toiture 	_val
			mgr_toiture.enregistrer_parametres 	toiture
			core.actualiser ()
			actualiser ()
		)
		
		
	on chk_planchers changed state do 
			core.actualiser ()
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





