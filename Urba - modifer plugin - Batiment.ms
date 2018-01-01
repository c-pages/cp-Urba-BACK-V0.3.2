/*#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale
	
##########################################################################################################################
	
	Plugin Batiment
	
##########################################################################################################################

	NOTES :
	
##########################################################################################################################
	
	todo:
	- gerer les unités des parametres (pour le calcul ou  l'affichage des longueurpar ex..)
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [23/09/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
########################################################################################################################*/





-- try unregisterRedrawViewsCallback 		$.fn_VP_afficher_axePrincipal 	
-- catch ()

clearlistener ()
deleteAllChangeHandlers ()




(
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	include "$userScripts\cp - GLOBAL\Debuger et ecrire.ms"
)	






---------------presse papier ---------
global urba_clipboard_batiment = ""


(
-- include	 "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures secondaires.ms"
)

	
plugin geometry 	Urba_Batiment
name:"Batiment"
classID:#(685325,452281)
category:"CP | Urba"
extends:Editable_poly replaceUI:true version:0
(
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	local m_debug = true
	local m_dbgPrefix ="urba | Batiment Plg"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)
	
	--------------- IMPORTS  ----------------------------------------------------------------------------------------------------------------------
	
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Core.ms"
	
	
	
	/* 
	include "$userScripts\cp - GLOBAL\Enregistreur De Node.ms"	

	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - presets.ms"
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - structures.ms"
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Facades.ms"
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - tracé.ms"
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - Construire.ms"
	 */
	
	--------------- PRé-DéCLARATIONS  ----------------------------------------------------------------------------------------------------------------------
	----  rollouts ------------------
	local roll_global, roll_niveaux,  roll_presets,   roll_toiture, roll_infos , roll_facades , roll_trace
	
	----  structures ------------------
-- 	local geo,  trace,  construire
	
	--------------- MEMBRES  ----------------------------------------------------------------------------------------------------------------------

	local murs_types = #("Gouttereaux", "Pignons", "Gouttereaux + Pignons")
	
	
	
-- 	local params_aEnregistrer = 	#(		/*----	Global  	----*/			#niveaux_hauteur, 			#niveaux_nbre, 	#axeP_orientation,
-- 													/*----	Toiture 	----*/		#toit_pente, 					#toit_type, 		#toit_hauteur ,
-- 													/*----	Tracé  	----*/		#trace_optimiser, 			#trace_souder, 	#trace_ortho, 		#seuil_optimiser, 				#seuil_souder, 	#seuil_ortho , 	#trace_aligner, 	#seuil_aligner ,	-- #trace_decouper, 
-- 													/*----	 Facades  	----*/		#facades_composants , 		#facades_items, 	#facades_modeles, 	#facades_parametriques
-- 											)
 
	
	
	

	
	---------------STRUCTURES  ----------------------------------------------------------------------------------------------------------------------
	local core = str_batiment_core  	()
	
	
	--------------- import des PARAMETRES  et rollouts ----------------------------------------------------------------------------------------------------------------------	
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollouts.ms"
	
	
	--------------- INTERFACE  ----------------------------------------------------------------------------------------------------------------------	
	
	fn actualiser 		=(		
		core.actualiser ()		
	)
	
	fn actualiser_rollouts =(
		roll_global.actualiser ()
		roll_facades.actualiser ()
		roll_toiture.actualiser ()
	)
	
	
	fn initialiser 	doLogo:false	=(
		
		core.initialiser 		this		
		
	)
	
	
	--------------- CREATION  ----------------------------------------------------------------------------------------------------------------------	
	tool create (	
		on mousePoint click do	(	
			nodeTM.translation = worldPoint
			
			core.actualiser ()
			
			#stop	
		)
	)
	
	
	
	
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------	
	on load 						do 	(
		debug "load du plugin" 
		initialiser ()
	)
	on clone 	_original 	do (
		debug "clone du plugin" 
		
		initialiser ()
		
	)
	on create do (
		debug "creation du plugin"		
		
		initialiser ()
	)
	
	on update do	(
		debug "update du plugin"	
		
		initialiser () 
		
	)
	
) --- fin du plug ---




 



/* 




-- try delete $ catch ()

-- debug_mode =false
debug_mode =true

-- 

for obj in objects do if superclassof obj == GeometryClass and obj != $'Rectangle001'  and obj != $'Porte002'  and obj != $'Porte003' do delete obj
bat1 = urba_batiment ()
clearlistener ()
for obj in helpers do delete obj

bat1.assigner_trace 	$'Rectangle001'	bat1
-- bat1.assigner_trace 	$Shape009	bat1

-- bat1.facades.creer_facade 	bat1


select bat1






select $popo

bat1.pos = [0,0,0]
bat1.trace.rectangles_traces
bat1.sousTraces

try unregisterRedrawViewsCallback 		bat1.fn_VP_afficher_axePrincipal 	
catch ()








$.VP_toggle ()



ray <pos_point3> <dir_point3>
intersectRay 



plugin folder





$.facades.facade_courante.sequence

$.construire.batiment $




$.facades.modeles_total
$.facades_modeles[1]
$.facades.composants_total


$.facades.get_composants $

$.facades.composants_total


$.facades_parametriques[1]
for obj in objects  do WITH REDRAW OFF try obj.actualiser_geometrie () catch ()
$.actualiser_geometrie ()



--- Pente aléatoire ---
for obj in selection  do try (
	local angle = random 15. 35.
	obj.toit_pente = angle 
	obj.actualiser_geometrie () 
) catch ()








 */




