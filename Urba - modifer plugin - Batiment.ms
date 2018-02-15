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

----- DEBUG-------------------------
global bat
try delete bat catch ()
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
	
	
	--------------- CORE   ----------------------------------------------------------------------------------------------------------------------
	local core = str_batiment_core  	()
		
	--------------- PARAMETRES  et ROLLOUTS ----------------------------------------------------------------------------------------------------------------------	
	local roll_global, roll_toiture, roll_facades 										----, roll_niveaux,  roll_presets,   roll_infos, roll_trace 
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollouts.ms"
	
	
	
	
	
	--------------- INTERFACE  ----------------------------------------------------------------------------------------------------------------------	
	---Initialisations / Actualisations ------
	fn initialiser 	doLogo:false	=(		
		core.initialiser 		this
	)
	fn actualiser 		=(		
		core.actualiser ()		
	)
	fn actualiser_rollouts =(
		roll_global.actualiser ()
		roll_facades.actualiser ()
		roll_toiture.actualiser ()
	)
	
	
	---- Divers	---------
	fn assigner_shape 		_nodeTHIS		_shape 		=(
		core.assigner_surface 	_nodeTHIS		_shape 		
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
-- 		initialiser ()		
	)
	
) --- fin du plug ---


 
/* 

----- DEBUG-------------------------
if creerBat != undefined do (
	bat = Urba_Batiment ()
	bat.assigner_shape  bat	$Shape007
	select bat
)
creerBat = true

 */


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




