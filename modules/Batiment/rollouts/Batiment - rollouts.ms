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
/* 
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
 */
rollout roll_global "Global" width:195 height:341
(
	
	
	fn shape_filt 		obj = superclassof obj == shape
	
	
	button 'btn_enregistrer' "Enregistrer" pos:[88,19] width:77 height:20 align:#left		
		
		
		
	button 'btn_charger' "Charger" pos:[13,19] width:76 height:20 enabled:true align:#left
	button 'btn_coller' "Coller" pos:[88,37] width:77 height:20 align:#left
	button 'btn_copier' "Copier" pos:[13,38] width:76 height:20 align:#left
	
	--- Surface ------
	pickbutton 'btn_pick_surface' "Pick shape" pos:[13,78] width:152 height:20 filter:shape_filt toolTip:"Le shape à utiliser comme surface de base pour la création du bâtiment." autoDisplay:true align:#left
	GroupBox 'grp_surface' "Surface :" pos:[8,64] width:162 height:38 align:#left
	
/* 
	--- Global ------
	GroupBox 'grp_global' "Etages :" pos:[4,40] width:162 height:51 align:#left
-- 	spinner 'spn_rotation_axeP' "" pos:[88,87] width:48 height:16 range:[-360,360,0] type:#float scale:1 align:#left
-- 	label 'lbl_axeP' "Orientation:" pos:[10,87] width:59 height:15 align:#left
-- 	button 'btn_rotation' "+90" pos:[137,87] width:24 height:16 align:#left
	label 'lbl_nbre' "Nbre. d'étages:" pos:[10,56] width:79 height:15 align:#left
	spinner 'spn_nbres' "" pos:[88,55] width:72 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_hauteur' "" pos:[88,71] width:72 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Hauteur :" pos:[10,72] width:76 height:15 align:#left
	 */
	
	--- Facades -----
	
	--- Toitures -----
	
	--- Interieur  -----
 	--enabled:false 
 	--enabled:false 
	
-- 	button 'btn_editer_etages' "E." pos:[143,72] width:16 height:16 align:#left
	checkbutton 'ckb_editeur' "Edition" pos:[8,108] width:162 height:30 highlightColor:(color 255 255 0) align:#left 
 
 
	GroupBox 'grp63' "Presets :" pos:[8,1] width:162 height:60 align:#left
 
 
	
	fn actualiser =(
		
		btn_coller.enabled 			= urba_clipboard_batiment != ""
		ckb_editeur.checked 	= core.editeur_estOuvert ()
		/* 
		lbx_facades.items 						=  facades_nom as array
		
		btn_supprimerFacade.enabled	=	lbx_facades.selection != 0 
		btn_editer_facade.enabled			=	lbx_facades.selection != 0 
		btn_dupliquer_facade.enabled	=	lbx_facades.selection != 0
		
		btn_editer_facade.checked			=	core.facadeEditeur_estOuvert ()
		btn_editer_toiture.enabled 		=	toiture_params != ""
		
		ddl_toiture.items						=	core.get_toiture_constructeursNoms ()		
		ddl_toiture.selection 					= 	core.get_toiture_index ()
		 */
	)
	
	
	
	




		
			
			
		
		
	on roll_global open do
		actualiser ()
	on roll_global close do
	(
	-- 				core.fermer_toutes_fenetres query:true
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
	on ckb_editeur changed state do	(
		case state of (
			true:		core.editeur_ouvrir ()
			false:	core.editeur_fermer ()
		)
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

rollout roll_aleatoire "Aléatoire" width:162 height:237
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
	label 'lbl60' "Seed :" pos:[11,7] width:57 height:13 align:#left
	spinner 'spn72' "" pos:[83,7] width:72 height:16 range:[0,100,0] scale:1 align:#left
)

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
rollout roll_aPropos 			"A propos" 	rolledUp:false	(
	label 'lbl_axeP' "Urba | V0.12  |" pos:[5,2]  align:#left
	HyperLink 'hpl1' "Christophe Pagès" pos:[76,2] address:"http://c-pages.fr" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	HyperLink 'hpl2' "GitHub" pos:[127,17] address:"https://github.com/c-pages/cp-Urba-Cleanage" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	label 'lbl6' "2017" pos:[5,17] align:#left
)




























