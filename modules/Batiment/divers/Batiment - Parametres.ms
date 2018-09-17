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

-------------------------------------------------------------------------------------------------------------------------------------------------
--------------- PARAMETRES  ---------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
parameters params_general 						rollout:roll_general		(
	
	------- Etages			------------------
	etages_nbre					type: #integer			default:1			 ui:spn_nbres	 		animatable:false		invisibleInTV:true
	etages_hauteur_global	type: #float 				default:250.		 ui:spn_hauteur	 	animatable:false		invisibleInTV:true
	
	---- les etages spécifiques -----------
	etages_min					type:#intTab 				tabSize:0  		tabSizeVariable:true
	etages_max_use			type:#boolTab	 		tabSize:0  		tabSizeVariable:true
	etages_max				type:#intTab		 		tabSize:0  		tabSizeVariable:true
	etages_hauteurs			type:#floatTab	 		tabSize:0  		tabSizeVariable:true
	
	---- Divers --------
	decallage_z					type:#float	 			default:0.		ui:spn_decallageZ	animatable:false		invisibleInTV:true
	
	
	interieur_use			type:#boolean			default:false	 	ui:chk_interieur	 	animatable:false		invisibleInTV:true
)

parameters params_facades 						rollout:roll_facades	(
	
	---- générale -----------
	facades_id 						type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facades_nom 					type:#stringTab 	tabSize:0  		tabSizeVariable:true		--ui:lbx_facades	
	facades_type 					type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facades_params					type:#stringTab 	tabSize:0  		tabSizeVariable:true

)

parameters params_facades_composants 		(
	
	---- les composants de facades -----------
	facCompos_id 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facCompos_nom 			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facCompos_type 			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facCompos_params		type:#stringTab 	tabSize:0  		tabSizeVariable:true
	
	---- Volets  -----------------------------------
	facVolets_id 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facVolets_nom 			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facVolets_type 			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facVolets_params			type:#stringTab	tabSize:0 		tabSizeVariable:true	
)

parameters params_facades_menuiseries 		(
	
	---- Parametres -----------------------------------
	facMenuis_id 					type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facMenuis_nom 					type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facMenuis_type 					type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facMenuis_params				type:#stringTab		tabSize:0 			tabSizeVariable:true	
	
)

parameters params_gardeCorps 		(
	
	---- Parametres -----------------------------------
	gardeCorps_id 					type:#stringTab 	tabSize:0  		tabSizeVariable:true
	gardeCorps_nom 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	gardeCorps_type 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	gardeCorps_params			type:#stringTab		tabSize:0 			tabSizeVariable:true	
	
)

parameters params_toitElements		(
	
	---- Parametres -----------------------------------
	toitElements_id 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	toitElements_nom 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	toitElements_type 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	toitElements_params			type:#stringTab		tabSize:0 			tabSizeVariable:true	
	
)

parameters params_toiture 							(
	
	toiture_type					type:#string 		default:"sans"		animatable:false		invisibleInTV:true
	toiture_params				type:#string		default:""				animatable:false		invisibleInTV:true /* tabSize:0  		tabSizeVariable:true */
	
)
/* 
parameters params_interieur				rollout:roll_general					(
	
)
 */
 
 
 
 
parameters params_constantes 							(
	
	------- Constantes 	-----------------
	const_batiment_decallage			type: #float 				default:5.		animatable:false		invisibleInTV:true
	
	const_dalle_epaisseur				type: #float 				default:20.	animatable:false		invisibleInTV:true
	const_murExt_epaisseur				type: #float 				default:30.	animatable:false		invisibleInTV:true
	
	const_ssBassement_epaisseur	type: #float 				default:100.	animatable:false		invisibleInTV:true
	
	const_couvertine_epaisseur		type: #float 				default:5.		animatable:false		invisibleInTV:true
	
	const_menuiseries_epaisseur		type: #float 				default:5.		animatable:false		invisibleInTV:true
	const_menuiseries_largeur			type: #float 				default:7.		animatable:false		invisibleInTV:true
	const_menuiseries_allege_ht		type: #float 				default:15.		animatable:false		invisibleInTV:true
	const_menuiseries_trav_ht			type: #float 				default:7.		animatable:false		invisibleInTV:true
	
	const_vitrage_epaisseur				type: #float 				default:1.		animatable:false		invisibleInTV:true
	
	
)
parameters params_surface				rollout:roll_surface	(
	
	------- Surface		------------------
	surface_node					type:#node 								 	ui:btn_pick_surface		animatable:false		invisibleInTV:true
	
	------- Optimisations		------------------
	optim_aplanir					type:#boolean			default:true		ui:chk_aplanir		animatable:false		invisibleInTV:true
	optim_souder					type:#boolean			default:true		ui:chk_souder		animatable:false		invisibleInTV:true
	optim_orthonormer			type:#boolean			default:false		ui:chk_ortho			animatable:false		invisibleInTV:true
	optim_aligner					type:#boolean			default:false		ui:chk_aligner		animatable:false		invisibleInTV:true
	optim_projeter					type:#boolean			default:false		ui:chk_projeter		animatable:false		invisibleInTV:true
	
	------- Seuils		------------------
	optim_aplanir_seuil			type:#float				default:20.			ui:spn_aplanir		animatable:false		invisibleInTV:true
	optim_souder_seuil			type:#float				default:30.			ui:spn_souder		animatable:false		invisibleInTV:true
	optim_ortho_seuil				type:#float				default:100.		ui:spn_ortho		animatable:false		invisibleInTV:true
	optim_aligner_seuil			type:#float				default:50.			ui:spn_aligner		animatable:false		invisibleInTV:true
	
)
parameters params_viewport				rollout:roll_general	(
	--- proxy_mode	-----
	affiche_asProxy				type:#boolean			default:false	 ui:ckb_proxy	 	animatable:false		invisibleInTV:true
	
	------- AFFICHAGE 		 ------------------
	affiche_axe					type:#boolean			default:false	/* ui:ckb_axe */				animatable:false		invisibleInTV:true
	affiche_surface				type:#boolean			default:false	/* ui:ckb_surface	 */		animatable:false		invisibleInTV:true
	affiche_gouttereaux		type:#boolean			default:false	/* ui:ckb_gouttereaux */	animatable:false		invisibleInTV:true
	affiche_pignons				type:#boolean			default:false	/* ui:ckb_pignons		 */	animatable:false		invisibleInTV:true
	affiche_ssSurfaces			type:#boolean			default:false	/* ui:ckb_ssSurfaces */		animatable:false		invisibleInTV:true	
	affiche_geometrie			type:#boolean			default:false	/* ui:ckb_geometrie	 */	animatable:false		invisibleInTV:true
	
)

parameters params_aleatoire				rollout:roll_aleatoire					(
	
	alea_seed								type:#integer				default:12345			ui:spn_seed	animatable:false		invisibleInTV:true
	
	alea_ouvrant_ouvert_proba	type:#float				default:0.			ui:spn_ouvrt_proba	animatable:false		invisibleInTV:true
	alea_ouvrant_ouvert_min		type:#float				default:0.			ui:spn_ouvrt_min		animatable:false		invisibleInTV:true
	alea_ouvrant_ouvert_max		type:#float				default:0.			ui:spn_ouvrt_max		animatable:false		invisibleInTV:true
	
	alea_volet_clos_proba			type:#float				default:0.			ui:spn_volet_proba	animatable:false		invisibleInTV:true
	alea_volet_clos_min				type:#float				default:0.			ui:spn_volet_min		animatable:false		invisibleInTV:true
	alea_volet_clos_max				type:#float				default:100.		ui:spn_volet_max		animatable:false		invisibleInTV:true
	
)



