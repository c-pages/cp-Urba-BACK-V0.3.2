/*
#######################################################################################################################
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



parameters params_global rollout:roll_global			(
	
	------- AXE PRINCIPAL	------------------
	axeP_mtrx				type:#matrix3	
	axeP_BB					type:#point3Tab		tabSize:2			tabSizeVariable:false
	axeP_orientation		type:#float				default:0.			ui:spn_rotation_axeP
	
	
	------- sous tracés	------------------
	sousTraces_use				type:#boolean		default:false		ui:chk_sousTraces
	sousTraces_surf_min		type:#float			default:15.			ui:spn_sousTraces_surf_min
	sousTraces_surf_max		type:#float			default:25.			ui:spn_sousTraces_surf_max
	sousTraces_surf_min_use	type:#boolean		default:true		ui:chk_sousTraces_surf_min
	sousTraces_surf_max_use	type:#boolean		default:true		ui:chk_sousTraces_surf_max
	sousTraces_etages			type:#integer		default:1			ui:spn_sousTraces_etages
	
	sousTraces						type:#stringTab 	tabSize:0 			tabSizeVariable:true
	
	
	niveaux_hauteur		type: #float 			default:250.		ui:spn_hauteur
	niveaux_nbre			type: #integer			default:1			ui:spn_nbres
	ep_dalle					type: #float 			default:20.			--ui:spn_ep_dalle
	
	
)

parameters params_trace rollout:roll_trace			(

	------- tracés			------------------
	a_un_trace				type:#boolean			default:false	
	trace_original			type:#point3Tab 		tabSize:0 			tabSizeVariable:true
	trace_courant			type:#point3Tab 		tabSize:0 			tabSizeVariable:true
	
	
	------- Optimisations		------------------
	trace_optimiser		type:#boolean			default:true		ui:chk_optimiser
	trace_souder			type:#boolean			default:true		ui:chk_souder
	trace_ortho			type:#boolean			default:true		ui:chk_ortho
	trace_aligner			type:#boolean			default:true		ui:chk_aligner
	
	seuil_optimiser			type:#float				default:20.			ui:spn_optimiser
	seuil_souder			type:#float				default:30.			ui:spn_souder
	seuil_ortho				type:#float				default:100.		ui:spn_ortho
	seuil_aligner			type:#float				default:50.			ui:spn_aligner
	
)

parameters params_infos rollout:roll_infos			(
	
	surface					type: #float 			default:0.	
	
	------- AFFICHAGE 		 ------------------
	affiche_axe					type:#boolean			default:false	ui:ckb_axe
	affiche_trace				type:#boolean			default:false	ui:ckb_trace
	affiche_gouttereaux		type:#boolean			default:false	ui:ckb_gouttereaux
	affiche_pignons			type:#boolean			default:false	ui:ckb_pignons
	affiche_ssTraces			type:#boolean			default:false	ui:ckb_ssTraces
	
	cache_geometrie			type:#boolean			default:false	ui:ckb_geometrie
)
parameters params_facades 	rollout:roll_facades			(
	
	facades_items					type:#stringTab 		tabSize:0 			tabSizeVariable:true
	facades_composants		type:#stringTab 		tabSize:0 			tabSizeVariable:true
	facades_modeles				type:#stringTab 		tabSize:0 			tabSizeVariable:true
	facades_parametriques		type:#stringTab 		tabSize:0 			tabSizeVariable:true
	
	materiaux						type:#materialTab	tabSize:0 			tabSizeVariable:true
	
)
parameters params_toiture rollout:roll_toiture			(
	
-- 	toit_nbrePentes	type: #radiobtnIndex 	default:2		ui:rdo_pentes
	toit_pente			type: #float 				default:20		ui:spn_pente
	toit_type			type: #integer 			default:1		ui:ddl_toiture
	toit_hauteur		type: #float 				default:20.		ui:spn_toit_hauteur
	
)


-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- ROLLOUT  ----------------------------------------------------------------------------------------------------------------------	
-------------------------------------------------------------------------------------------------------------------------------------------------

rollout roll_presets "Presets" width:235 height:205	rolledUp:true
(
	
	fn shape_filt 		obj = superclassof obj == shape
	
	button 'btn_enregistrer' "Enregistrer" pos:[88,2] width:85 height:16 align:#left		
		
		
	button 'btn_charger' "Charger" pos:[5,2] width:85 height:16 align:#left
	button 'btn_coller' "Coller" pos:[88,17] width:85 height:16 align:#left
	button 'btn_copier' "Copier" pos:[5,17] width:85 height:16 align:#left
	
	
	fn actualiser =(
		btn_coller.enabled 		= a_un_trace and urba_clipboard_batiment != ""
		btn_copier.enabled 			= a_un_trace
		btn_enregistrer.enabled 		= a_un_trace
		btn_charger.enabled 			= a_un_trace
		
	)
	
	
	
	
	on roll_presets open do actualiser ()

	on btn_enregistrer pressed do
		presets.enregistrer 	this
	on btn_charger pressed do
	(
			presets.charger 					this
-- 			facades.params_toStructs 	this
			facades.actualiser ()
		
			trace.actualiser 	()
			construire.batiment 	()
			actualiser_rollouts()
		)
	on btn_coller pressed do
	(
			presets.coller 	this 
		
			facades.actualiser ()
		
			trace.actualiser ()
			construire.batiment ()
			actualiser_rollouts()
			
		)
	on btn_copier pressed do
	(
			presets.copier 	this 
			actualiser()
		)
)
rollout roll_trace "Tracé" width:182 height:301
(
	
	
	fn shape_filt 		obj = superclassof obj == shape
	
	pickbutton 'btn_pick_trace' "Pick shape" pos:[10,13] width:156 height:21 filter:shape_filt align:#left
	GroupBox 'grp9' "Tracé:" pos:[4,0] width:168 height:40 align:#left
	
	checkbox 'chk_optimiser' "Optimiser" pos:[6,76] width:62 height:13 align:#left
	checkbox 'chk_ortho' "Orthonorm." pos:[6,46] width:76 height:13 align:#left
	spinner 'spn_optimiser' "" pos:[87,75] width:85 height:16 range:[0,40,0] align:#left
	checkbox 'chk_souder' "Souder" pos:[6,61] width:55 height:13 align:#left
	spinner 'spn_souder' "" pos:[87,60] width:85 height:16 range:[0,100,0] type:#worldunits align:#left
	spinner 'spn_ortho' "" pos:[87,45] width:85 height:16 range:[0,100,0] type:#float align:#left
	
	
	
	
	
	
	checkbox 'chk_aligner' "Aligner" pos:[6,91] width:50 height:13 align:#left
	spinner 'spn_aligner' "" pos:[87,90] width:85 height:16 range:[0,100,0] align:#left
-- 	spinner 'spn_decouper' "" pos:[87,93] width:80 height:16 range:[0,40,0] align:#left
	
-- 	button 'btn_MaJ' "Actualiser" pos:[24,155] width:147 height:21 align:#left
-- 	checkButton 'chk_MaJ_auto' "" pos:[4,155] width:21 height:21 align:#left
	
	
	
	
	fn actualiser =(
		
-- 		spn_hauteur.enabled 				= a_un_trace
-- 		lbl_hauteur.enabled 				= a_un_trace		
		chk_optimiser.enabled 			= a_un_trace
		chk_ortho.enabled 				= a_un_trace
		chk_souder.enabled 				= a_un_trace		
-- 		btn_rotation.enabled 				= a_un_trace
-- 		btn_rotation_inv.enabled 		= a_un_trace
-- 		spn_rotation_axeP.enabled 	= a_un_trace
-- 		lbl_axeP.enabled 					= a_un_trace
		
		spn_optimiser.enabled 			= trace_optimiser
		spn_souder.enabled 				= trace_souder
		spn_ortho.enabled 				= trace_ortho
		
	)
	

		
	
	
	
	
	
	on btn_pick_trace picked 		_nvtrace 	do
	(
			trace.definir		_nvtrace	$
		
			this.actualiser_rollouts ()
		
			construire.batiment ()
	)
	
	on chk_optimiser changed state do
	(
		trace.actualiser 	()
		construire.batiment ()
		actualiser ()
	)
	on chk_ortho changed state do
	(		
		trace.actualiser ()
		construire.batiment ()
		actualiser ()
	)
	on spn_optimiser changed val 	do
	(
			trace.actualiser ()
			construire.batiment ()
		)
	on chk_souder changed state do
	(		
		trace.actualiser ()
		construire.batiment ()
		actualiser ()
	)
	on spn_souder changed val 	do
	(
			trace.actualiser ()
			construire.batiment ()
		)
	on spn_ortho changed val 	do
	(
			trace.actualiser ()
			construire.batiment ()
		)
	on chk_aligner changed state do
	(
		trace.actualiser 	()
		construire.batiment ()
		actualiser ()
	)
	on spn_aligner changed val 	do
	(
			trace.actualiser ()
			construire.batiment ()
		)
)
rollout roll_global "Global" width:247 height:375
(
	
-- 	local regle_ssTrace_courant
	
	spinner 'spn_rotation_axeP' "" pos:[87,32] width:85 height:16 range:[-360,360,0] type:#float scale:1 align:#left
	label 'lbl_axeP' "Orientation:" pos:[5,33] width:59 height:15 align:#left
	button 'btn_rotation' "+90°" pos:[89,47] width:42 height:16 align:#left
	button 'btn_rotation_inv' "-90°" pos:[130,47] width:42 height:16 align:#left		
		
	label 'lbl_nbre' "Nbre. d'étages:" pos:[5,3] width:79 height:15 align:#left
	spinner 'spn_nbres' "" pos:[87,2] width:85 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	spinner 'spn_hauteur' "" pos:[87,17] width:85 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_hauteur' "Htr. des étages:" pos:[5,18] width:76 height:15 align:#left
	
	
	GroupBox 'grp_sousTrace' "Division surfaces:" pos:[4,64] width:168 height:86 align:#left
	label 'lbl_division_etages' "Nbre. d'étages:" pos:[13,128] width:75 height:15 align:#left
	spinner 'spn_sousTraces_etages' "" pos:[87,127] width:81 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
	label 'lbl_surfMin' "Surf. min (m²):" pos:[13,95] width:76 height:15 align:#left
	label 'lbl_surfMax' "        max (m²):" pos:[15,110] width:72 height:15 align:#left
-- 	button 'btn_ajouter_division' "+" pos:[134,76] width:16 height:16 enabled:true toolTip:"surface minimum." highlightColor:(color 255 255 0) align:#left
-- 	button 'btn_supprimer_division' "-" pos:[149,76] width:16 height:16 enabled:true toolTip:"surface minimum." highlightColor:(color 255 255 0) align:#left
	
	
	spinner 'spn_sousTraces_surf_min' "" pos:[102,95] width:66 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
	spinner 'spn_sousTraces_surf_max' "" pos:[102,111] width:66 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
	checkbutton 'chk_sousTraces_surf_max' "" pos:[89,111] width:16 height:16 highlightColor:(color 255 255 0) toolTip:"Surface maximum." checked:false align:#left
	checkbutton 'chk_sousTraces_surf_min' "" pos:[89,95] width:16 height:16 enabled:true highlightColor:(color 255 255 0) toolTip:"surface minimum." align:#left
-- 	listbox 'lbx_divisions' "" pos:[12,92] width:153 height:5 align:#left

		
	checkbox 'chk_sousTraces' "Diviser" pos:[13,80] width:107 height:15 align:#left
	
	
	fn actualiser =(
		
-- 		lbx_divisions.items = for ssTrace in trace.regles_ssTrace collect ssTrace.nom
-- 		if lbx_divisions.selection != 0 then
-- 			regle_ssTrace_courant	= trace.regles_ssTrace[lbx_divisions.selection]
-- 		else regle_ssTrace_courant = undefined
		
		spn_hauteur.enabled 			= a_un_trace
		lbl_hauteur.enabled 				= a_un_trace		
		btn_rotation.enabled 			= a_un_trace
		btn_rotation_inv.enabled 		= a_un_trace
		spn_rotation_axeP.enabled 	= a_un_trace
		lbl_axeP.enabled 					= a_un_trace
		
		local enabled =  sousTraces_use
		chk_sousTraces.enabled = false
		
		spn_sousTraces_etages.enabled 	= enabled
		spn_sousTraces_surf_min.enabled 			= enabled
		lbl_surfMin.enabled 						= enabled
		lbl_surfMax.enabled 						= enabled
		chk_sousTraces_surf_max.enabled 	= enabled
		chk_sousTraces_surf_min.enabled 	= enabled
		spn_sousTraces_surf_max.enabled 	= enabled
-- 		btn_supprimer_division.enabled 		= enabled
		
		if enabled then (
			spn_sousTraces_etages.indeterminate  		= false
			spn_sousTraces_surf_min.indeterminate  		= false
			spn_sousTraces_surf_max.indeterminate  	= false
-- 			spn_sousTraces_etages.value  			= .nombre_etages
-- 			spn_sousTraces_surf_min.value  		= regle_ssTrace_courant.surface_min
-- 			spn_sousTraces_surf_max.value  		= regle_ssTrace_courant.surface_max
-- 			chk_sousTraces_surf_max.checked  	= regle_ssTrace_courant.surface_min_use
-- 			chk_sousTraces_surf_min.checked  	= regle_ssTrace_courant.surface_max_use
			
		) else (
			spn_sousTraces_etages.indeterminate  		= true
			spn_sousTraces_surf_min.indeterminate  		= true
			spn_sousTraces_surf_max.indeterminate  	= true
			chk_sousTraces_surf_max.checked  			= false
			chk_sousTraces_surf_min.checked  			= false
			
		)
		
		
	)
	

/* 			.value  			= regle_ssTrace_courant.nombre_etages
			spn_division_surfaceMin.value  		= regle_ssTrace_courant.surface_min
			spn_division_surfaceMax.value  		= regle_ssTrace_courant.surface_max
			chk_division_surfaceMin.checked  	= regle_ssTrace_courant.surface_min_use
			chk_division_surfaceMax.checked  	= regle_ssTrace_courant.surface_max_use
		
		nombre_etages	=	0,
		surface_min		= 20.,
		surface_min_use	= true,
		surface_max		= 50.,
		surface_max_use	= true, */
	
		
		
		
		
		
	
	on roll_global open do
		actualiser ()
	on spn_rotation_axeP changed arg do
	(
			trace.actualiser ()
			construire.batiment 	()
		)
	on btn_rotation pressed do
	(
			axeP_orientation += 90
			trace.actualiser 			()
			construire.batiment 	()
		)
	on btn_rotation_inv pressed do
	(
			axeP_orientation -= 90
			trace.actualiser ()
			
			construire.batiment ()
		)
	on spn_nbres changed arg do
	(
			construire.batiment ()
	)
/* 	on spn_nbres buttondown do
		flagForeground $ 	true
	on spn_nbres buttonup do
		flagForeground $ 	false */
	on spn_hauteur changed arg do
	(
					construire.batiment ()
					
		)
	on spn_hauteur buttondown do
		flagForeground $ 	true
	on spn_hauteur buttonup do
		flagForeground $ 	false
	on spn_sousTraces_etages changed val do
	(
-- 			regle_ssTrace_courant.nombre_etages = val
			actualiser ()
-- 			trace.structs_toParam 	this
			trace.actualiser 	()
			construire.batiment 	()
		)
	on spn_sousTraces_surf_min changed val do
	(
-- 			regle_ssTrace_courant.surface_min = val
			actualiser ()
-- 			trace.structs_toParam 	this
			trace.actualiser 	()
			construire.batiment 	()
		)
	on spn_sousTraces_surf_max changed val do
	(
-- 			regle_ssTrace_courant.surface_max = val
			actualiser ()
-- 			trace.structs_toParam 	this
			trace.actualiser 	()
			construire.batiment 	()
		)
	on chk_sousTraces_surf_max changed state do
	(
-- 			regle_ssTrace_courant.surface_max_use = state
			actualiser ()
-- 			trace.structs_toParam 	this
			trace.actualiser 	()
			construire.batiment 	()
		
		)
	on chk_sousTraces_surf_min changed state do
	(
-- 			regle_ssTrace_courant.surface_min_use = state
			actualiser ()
-- 			trace.structs_toParam 	this
			trace.actualiser 	()
			construire.batiment 	()
		
		)
	on chk_sousTraces changed state do
	(
-- 			regle_ssTrace_courant.surface_max_use = state
			actualiser ()
-- 			trace.structs_toParam 	this
			trace.actualiser 	()
			construire.batiment 	()
		
		)
)
rollout roll_facades "Façades" width:510 height:813
(
		local m_debug = true
	local m_dbgPrefix ="urba | roll_facades"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)
	
	
	
	listbox 'lbx_facades' "" pos:[5,15] width:165 height:9 align:#left 
 
 
 
	button 'btn_ajouterFacade' "+" pos:[141,-1] width:16 height:16 align:#left
	
	button 'btn_supprimerFacade' "-" pos:[156,-1] width:16 height:16 align:#left

	button 'btn_dupliquer' "Dup" pos:[96,0] width:27 height:16 align:#left
	fn actualiser =(
-- 			debug "actualiser"
		
		enabled = a_un_trace
		lbx_facades.enabled 			= enabled
		btn_ajouterFacade.enabled 	= enabled
		btn_supprimerFacade.enabled = enabled		
		
		if a_un_trace do 
			lbx_facades.items =  facades.get_facades_noms ()
		
		
	)
	 
	
		
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
)
rollout roll_toiture "Toiture" width:236 height:418
(
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
	
	
	
	fn actualiser =(
		
-- 		lbl12.enabled 			= a_un_trace
		ddl_toiture.enabled 			= a_un_trace
		lbl_facade.enabled 			= a_un_trace
-- 		rdo_pentes.enabled 			= a_un_trace
		spn_toit_hauteur.enabled 	= a_un_trace
		lbl_hauteur.enabled 			= a_un_trace
		spn_pente.enabled 			= a_un_trace
		lbl_pente.enabled 			= a_un_trace
		lbl_composants.enabled 	= a_un_trace
		
		btn_ajouterFacade.enabled 	= a_un_trace
		btn_supprimerFacade.enabled 	= a_un_trace
-- 		grp_prop.enabled 	= a_un_trace
		lbx_facades.enabled 	= a_un_trace
		
		
		if a_un_trace do (
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
)
rollout roll_infos "Infos" width:191 height:142
(
	label 'lbl16' "Surface:" pos:[5,90] width:43 height:14 align:#left
	label 'lbl_surface' "" pos:[85,90] width:78 height:16 align:#left 
 
 
 

	label 'lbl1_tracePts' "Tracé (origin.):" pos:[5,105] width:70 height:14 align:#left
	label 'lbl_tracePts_val' "" pos:[85,105] width:78 height:16 align:#left 
 
 
 

	label 'lbl1_tracePts_opt' "Tracé (optim.):" pos:[5,120] width:69 height:14 align:#left
	label 'lbl_tracePts_opt_val' "" pos:[85,120] width:78 height:16 align:#left 
 
 
 
	checkbutton 'ckb_axe' "Axe" pos:[10,14] width:75 height:16 align:#left	 --highlightColor:[200,200,100]
	 --highlightColor:[200,200,100]
	 --highlightColor:[200,200,100]
	checkbutton 'ckb_trace' "Points" pos:[84,14] width:75 height:16 align:#left --highlightColor:[170,170,170]
 --highlightColor:[170,170,170]
 --highlightColor:[170,170,170]
	checkbutton 'ckb_pignons' "Pignons" pos:[84,29] width:75 height:16 align:#left		 --highlightColor:[130,130,250]
		 --highlightColor:[130,130,250]
		 --highlightColor:[130,130,250]
	checkbutton 'ckb_gouttereaux' "Gouttereaux" pos:[10,29] width:75 height:16 align:#left --highlightColor:[250,100,100]
 --highlightColor:[250,100,100]
 --highlightColor:[250,100,100]
-- 		checkbutton 'ckb_longueurSegts' "Long. façades" pos:[5,32] width:80 height:16 align:#left --highlightColor:[170,170,170]
	checkbutton 'ckb_geometrie' "Cacher géom." pos:[10,65] width:75 height:16 highlightColor:(color 255 0 0) align:#left
	checkbutton 'ckb_ssTraces' "Sous tracés" pos:[10,44] width:75 height:16 align:#left
	
	
	
	
	
-- 		on ckb_longueurSegts 	changed state 		do	VP_toggle ()
	GroupBox 'grp30' "Viewport:" pos:[5,1] width:158 height:85 align:#left
	
	
	fn actualiser =(
		
		ckb_axe.enabled 					= a_un_trace
		ckb_trace.enabled 				= a_un_trace
		ckb_pignons.enabled 			= a_un_trace
		ckb_gouttereaux.enabled 		= a_un_trace
		ckb_geometrie.enabled 			= a_un_trace
		grp30.enabled 			= a_un_trace
		
		lbl16.enabled 			= a_un_trace
		lbl_surface.enabled 			= a_un_trace
		lbl1_tracePts.enabled 			= a_un_trace
		lbl_tracePts_val.enabled 			= a_un_trace
		lbl1_tracePts_opt.enabled 			= a_un_trace
		lbl_tracePts_opt_val.enabled 			= a_un_trace
		if a_un_trace do (
			lbl_surface.text = ( surface / 10000 ) as string + " m²"
			lbl_tracePts_val.text = trace_original.count as string + " pts."
			lbl_tracePts_opt_val.text = trace_courant.count as string + " pts."
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
	on ckb_trace changed state 		do
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
)
rollout roll_aPropos "A propos" width:162 height:64 	rolledUp:true
(
	label 'lbl_axeP' "Urba | V0.1  |" pos:[5,2]  align:#left
	HyperLink 'hpl1' "Christophe Pagès" pos:[76,2] address:"http://c-pages.fr" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	HyperLink 'hpl2' "GitHub" pos:[127,17] address:"https://github.com/c-pages/cp-Urba" color:(color 200 200 127.5) hovercolor:(color 250 250 150) visitedcolor:(color 200 200 127.5) align:#left
	label 'lbl6' "2017" pos:[5,17] align:#left
)

/* 
parameters params_TEST rollout:roll_TEST			(
	
	------- AFFICHAGE 		 ------------------
	modelesEnregistres		type:#string			default:""	
	
)
rollout roll_TEST "TEST" width:162 height:58
(
	pickbutton 'btn1' "piquer" 
 
	button 'btn2' "recreer" 
 
	on btn1 picked obj do
(
	modelesEnregistres = nodeScanner.get_datas 	obj
	)
	on btn2 pressed  do
(
	nodeScanner.creer_objet 	modelesEnregistres
	)
)

 */
















