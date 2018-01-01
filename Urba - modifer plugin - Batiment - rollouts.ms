/*#######################################################################################################################
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



parameters params_global 				rollout:roll_global		(
	
	------- Surface		------------------
	surface_node				type:#node 								 ui:btn_pick_surface
	surface_points_base		type:#point3Tab 		tabSize:0 		tabSizeVariable:true
	surface_points				type:#point3Tab 		tabSize:0 		tabSizeVariable:true
	
	------- Divers			------------------
	niveaux_hauteur		type: #float 			default:250.		ui:spn_hauteur
	niveaux_nbre			type: #integer			default:1			ui:spn_nbres
	ep_dalle					type: #float 			default:20.			--ui:spn_ep_dalle
	
	------- Orientation	------------------
	axe_principal			type:#matrix3	
	orientation				type:#float				default:0.			ui:spn_rotation_axeP
	
)
parameters params_optimSurface		rollout:roll_optimSurface	(
	
	------- Optimisations		------------------
	optim_aplanir					type:#boolean			default:true		ui:chk_aplanir
	optim_souder					type:#boolean			default:true		ui:chk_souder
	optim_orthonormer			type:#boolean			default:true		ui:chk_ortho
	optim_aligner					type:#boolean			default:true		ui:chk_aligner
	optim_projeter				type:#boolean			default:true		ui:chk_projeter
	
	------- Seuils		------------------
	optim_aplanir_seuil			type:#float				default:20.			ui:spn_aplanir
	optim_souder_seuil			type:#float				default:30.			ui:spn_souder
	optim_ortho_seuil			type:#float				default:100.		ui:spn_ortho
	optim_aligner_seuil			type:#float				default:50.			ui:spn_aligner
	
)
parameters params_viewport				rollout:roll_viewport	(
	
	surface					type: #float 			default:0.	
	
	------- AFFICHAGE 		 ------------------
	affiche_axe					type:#boolean			default:false	ui:ckb_axe
	affiche_surface			type:#boolean			default:false	ui:ckb_surface
	affiche_gouttereaux		type:#boolean			default:false	ui:ckb_gouttereaux
	affiche_pignons			type:#boolean			default:false	ui:ckb_pignons
	affiche_sssurfaces		type:#boolean			default:false	ui:ckb_sssurfaces
	
	cache_geometrie			type:#boolean			default:false	ui:ckb_geometrie
	
)
parameters params_facades 				rollout:roll_facades	(
	
	---- générale -----------
	fac_noms 						type:#stringTab 		tabSize:0  			tabSizeVariable:true		--ui:lbx_facades	
	fac_ids 							type:#stringTab 		tabSize:0  			tabSizeVariable:true
	fac_probabilites				type:#floatTab		tabSize:0 			tabSizeVariable:true
	
	--- Limiteurs - Etages	---
	fac_etagesMin_uses			type:#boolTab		tabSize:0 			tabSizeVariable:true
	fac_etagesMins				type:#intTab			tabSize:0 			tabSizeVariable:true
	fac_etagesMax_uses		type:#boolTab		tabSize:0 			tabSizeVariable:true
	fac_etagesMaxs				type:#intTab			tabSize:0 			tabSizeVariable:true
	
	--- Limiteurs - longueurs	---
	fac_longueurMin_uses		type:#boolTab		tabSize:0 			tabSizeVariable:true
	fac_longueurMins				type:#floatTab		tabSize:0 			tabSizeVariable:true
	fac_longueurMax_uses		type:#boolTab		tabSize:0 			tabSizeVariable:true
	fac_longueurMaxs			type:#floatTab		tabSize:0 			tabSizeVariable:true
	
	--- Limiteurs - Murs	---
	fac_murs						type:#intTab			tabSize:0 			tabSizeVariable:true			---- ( 1:les deux	2:gouttereaux	3:pignons )	----
	fac_modes						type:#intTab			tabSize:0 			tabSizeVariable:true			---- ( 1:repeter	2:etrier			3:centrer )	----
	
	--- Sequence	---
	fac_sequences				type:#stringTab 		tabSize:0 			tabSizeVariable:true
	fac_sequence_longueurs	type:#stringTab 		tabSize:0 			tabSizeVariable:true
	
)
parameters params_toiture 				rollout:roll_toiture	(
	
-- 	toit_nbrePentes	type: #radiobtnIndex 	default:2		ui:rdo_pentes
	toit_pente			type: #float 				default:20		ui:spn_pente
	toit_type			type: #integer 			default:1		ui:ddl_toiture
	toit_hauteur		type: #float 				default:20.		ui:spn_toit_hauteur
	
)


-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  ----------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------------------------------------------------

rollout roll_global "Global" width:162 height:93 (
	
	
	fn shape_filt 		obj = superclassof obj == shape
	
	pickbutton 'btn_pick_surface' "Pick shape" pos:[12,14] width:116 height:18 filter:shape_filt autoDisplay:true align:#left
	GroupBox 'grp9' "Surface:" pos:[4,0] width:162 height:38 align:#left

	spinner 'spn_rotation_axeP' "" pos:[87,73] width:54 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	label 'lbl_axeP' "Orientation:" pos:[5,74] width:59 height:15 align:#left
	button 'btn_rotation' "+90°" pos:[138,73] width:30 height:16 align:#left
	
	label 'lbl_nbre' "Nbre. d'étages:" pos:[5,44] width:79 height:15 align:#left
	spinner 'spn_nbres' "" pos:[87,43] width:80 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_hauteur' "" pos:[87,58] width:80 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Htr. des étages:" pos:[5,59] width:76 height:15 align:#left
	
	button 'btn_maj' "MAJ" pos:[127,15] width:30 height:16 align:#left
	
	fn actualiser =(
		btn_maj.enabled = surface_node != undefined
	)
	
	
	
	
	on roll_global open do actualiser ()
	
	on btn_pick_surface picked _shape	 do (
		core.assigner_surface	 	$		_shape
		actualiser ()
	)
	
	on btn_maj 	pressed do
		core.assigner_surface	 	$		$.surface_node
	
	on spn_nbres changed arg do
		core.actualiser ()
	on spn_hauteur changed arg do
		core.actualiser ()
)
rollout roll_optimSurface 		"Optimisation Surface" 		rolledUp:true	(
	
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
	on spn_ortho	 	changed state  	do	core.actualiser ()
	on spn_aligner 	changed state  		do	core.actualiser ()
	
)
rollout roll_facades 		"Façades"		rolledUp:false	(

	listbox 'lbx_facades' "" pos:[5,15] width:165 height:9 align:#left 
	button 'btn_ajouterFacade' "+" pos:[141,-1] width:16 height:16 align:#left
	button 'btn_supprimerFacade' "-" pos:[156,-1] width:16 height:16 align:#left
	button 'btn_dupliquer' "Dup" pos:[96,0] width:27 height:16 align:#left
	
	fn actualiser =(
-- 			debug "actualiser"
		
		/* enabled = a_un_surface
		lbx_facades.enabled 			= enabled
		btn_ajouterFacade.enabled 	= enabled
		btn_supprimerFacade.enabled = enabled		
		 */
		lbx_facades.items =  core.get_facades_noms ()
		
		
	)
	 

	on roll_facades 			open 			do	actualiser()
	on btn_ajouterFacade 	pressed 		do	(
		core.creer_facade ()
		actualiser ()
	)
	on lbx_facades doubleClicked arg do
		core.facadeEditeur_ouvrir	 	lbx_facades.selection 
	
	
	/* --------------------  CLEANAGE --------------------
	
		
	on roll_facades open do	(
		
			facades.actualiser ()
			actualiser()
		)
	on roll_facades close do
	(
			try  destroydialog facades.dialog catch ()			
		)
	on lbx_facades selected arg do
		if  facades.est_ouvert ()  do	facades.ouvrir 	lbx_facades.selection
	on lbx_facades doubleClicked arg do
		facades.ouvrir 	lbx_facades.selection 
	
	on btn_ajouterFacade pressed do
	(
				facades.creer_facade ()
				facades.ouvrir		(facades.get_facades_count ())	
			)
	on btn_supprimerFacade pressed do
		if queryBox "Supprimer la façade ?"	title:"Urba | Bâtiment | Façade" 	do 
			with undo "supprimer" on (
				facades.supprimer_facade  lbx_facades.selection	 
				actualiser()
			)
	on btn_dupliquer pressed do
	(
				facades.dupliquer_facade	 lbx_facades.selection 
		
	 			actualiser() 
			)
			
	*/ --------------------  CLEANAGE --------------------
)
rollout roll_toiture 		"Toiture"		rolledUp:false	(
	dropdownList 'ddl_toiture' "" pos:[88,1] width:85 height:21 items:#("Plate", "Acrotère", "1 pan", "2 pans") align:#left
	label 'lbl_facade' "Toiture:" pos:[5,7] width:38 height:15 align:#left
-- 	radiobuttons 'rdo_pentes' "" pos:[89,52] width:29 height:32 labels:#("1", "2") align:#left
	spinner 'spn_toit_hauteur' "" pos:[87,21] width:85 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Hauteur:" pos:[5,22] width:45 height:15 align:#left
	spinner 'spn_pente' "" pos:[87,36] width:85 height:16 range:[0,80,20] type:#float scale:1 align:#left
	label 'lbl_pente' "Pente(°):" pos:[5,37] width:45 height:15 align:#left
-- 	label 'lbl5' "Pentes:" pos:[5,52] width:45 height:15 align:#left
	
	multiListBox 'lbx_facades' "" pos:[5,67] width:165 height:9 align:#left 
 
 
	button 'btn_ajouterFacade' "+" pos:[141,51] width:16 height:16 align:#left
	
	button 'btn_supprimerFacade' "-" pos:[156,51] width:16 height:16 align:#left
-- 	label 'lbl_facades' "Facades:" pos:[5,2] width:45 height:15 align:#left
	
-- 	GroupBox 'grp_prop' "Propriétés" pos:[5,195] width:165 height:41 align:#left
	label 'lbl_composants' "Composants:" pos:[5,52] width:64 height:15 align:#left
	
	
	fn actualiser =()
	/* --------------------  CLEANAGE --------------------
	
	fn actualiser =(
		
-- 		lbl12.enabled 			= a_un_surface
		ddl_toiture.enabled 			= a_un_surface
		lbl_facade.enabled 			= a_un_surface
-- 		rdo_pentes.enabled 			= a_un_surface
		spn_toit_hauteur.enabled 	= a_un_surface
		lbl_hauteur.enabled 			= a_un_surface
		spn_pente.enabled 			= a_un_surface
		lbl_pente.enabled 			= a_un_surface
		lbl_composants.enabled 	= a_un_surface
		
		btn_ajouterFacade.enabled 	= a_un_surface
		btn_supprimerFacade.enabled 	= a_un_surface
-- 		grp_prop.enabled 	= a_un_surface
		lbx_facades.enabled 	= a_un_surface
		
		
		if a_un_surface do (
-- 			rdo_pentes.enabled 					= ddl_toiture.selection == 3
			spn_pente.enabled 					= ddl_toiture.selection >= 3
			lbl_pente.enabled 					= ddl_toiture.selection >= 3
		)
	)
	
	
	
	on roll_toiture open do 
		actualiser()
	on ddl_toiture selected sel 	do
	(
				actualiser	()
				construire.batiment ()
			)
	on spn_toit_hauteur changed val 	do
		construire.batiment ()
	on spn_pente changed val 	do
		construire.batiment ()
*/ --------------------  CLEANAGE --------------------
)
rollout roll_presets 		"Presets" 		rolledUp:true	(
	
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
rollout roll_viewport 	"Viewport"	rolledUp:false	(
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
rollout roll_aPropos 	"A propos" 	rolledUp:true	(
	label 'lbl_axeP' "Urba | V0.1  |" pos:[5,2]  align:#left
	HyperLink 'hpl1' "Christophe Pagès" pos:[76,2] address:"http://c-pages.fr" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	HyperLink 'hpl2' "GitHub" pos:[127,17] address:"https://github.com/c-pages/cp-Urba" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	label 'lbl6' "2017" pos:[5,17] align:#left
)









