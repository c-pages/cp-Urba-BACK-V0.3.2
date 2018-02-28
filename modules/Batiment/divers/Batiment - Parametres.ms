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
	const_menuiseries_epaisseur		type: #float 				default:4.		animatable:false		invisibleInTV:true
	const_menuiseries_largeur			type: #float 				default:5.		animatable:false		invisibleInTV:true
	const_menuiseries_allege_ht		type: #float 				default:5.		animatable:false		invisibleInTV:true
	const_menuiseries_trav_ht			type: #float 				default:5.		animatable:false		invisibleInTV:true
	
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
	affiche_ssSurfaces		type:#boolean			default:false	ui:ckb_ssSurfaces		animatable:false		invisibleInTV:true	
	affiche_geometrie			type:#boolean			default:false	ui:ckb_geometrie		animatable:false		invisibleInTV:true
	
)
parameters params_facades 						rollout:roll_global	(
	
	---- générale -----------
	facades_id 							type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facades_nom 						type:#stringTab 	tabSize:0  		tabSizeVariable:true		--ui:lbx_facades	
	
	--- Limiteurs - Etages	---
	facades_etagesMin_use			type:#boolTab		tabSize:0 			tabSizeVariable:true
	facades_etagesMin					type:#intTab			tabSize:0 			tabSizeVariable:true
	facades_etagesMax_use			type:#boolTab		tabSize:0 			tabSizeVariable:true
	facades_etagesMax				type:#intTab			tabSize:0 			tabSizeVariable:true
	
	--- Limiteurs - longueurs	---
	facades_longueurMin_use		type:#boolTab		tabSize:0 			tabSizeVariable:true
	facades_longueurMin				type:#floatTab		tabSize:0 			tabSizeVariable:true
	facades_longueurMax_use		type:#boolTab		tabSize:0 			tabSizeVariable:true
	facades_longueurMax				type:#floatTab		tabSize:0 			tabSizeVariable:true
	
	--- Limiteurs - Murs	---
	facades_murs						type:#intTab			tabSize:0 			tabSizeVariable:true			---- ( 1:les deux	2:gouttereaux	3:pignons )	----
	facades_mode						type:#intTab			tabSize:0 			tabSizeVariable:true			---- ( 1:repeter	2:etrier			3:centrer )	----
	
	--- Sequence	---
	facades_sequence					type:#stringTab 	tabSize:0 			tabSizeVariable:true
	
)
parameters params_facades_composants 		(
	
	---- les composants de facades -----------
	facCompos_id 				type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facCompos_nom 			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facCompos_type 			type:#stringTab 	tabSize:0  		tabSizeVariable:true
	facCompos_params		type:#stringTab 	tabSize:0  		tabSizeVariable:true
	
)
parameters params_toiture 							(
	
	toiture_type					type:#string 		default:"sans"		animatable:false		invisibleInTV:true
	toiture_params				type:#string		default:""				animatable:false		invisibleInTV:true /* tabSize:0  		tabSizeVariable:true */
	
)

parameters params_interieur				rollout:roll_global					(
	interieur_planchers		type:#boolean			default:false	ui:chk_planchers		animatable:false		invisibleInTV:true
	
)