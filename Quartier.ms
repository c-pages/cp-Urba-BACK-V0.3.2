

--------------- le plug in ---------
plugin geometry 	Urba_quartier
name:"Quartier"
classID:#(643585,464251)
category:"CP | Urba"
extends:Editable_poly 
replaceUI:true 
version:0
-- remap:#(#(#surface_node), #(#surface_node))
(

	
	
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	local m_debug = true
	local m_dbgPrefix ="urba | Quartier Plg"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)

	--------------- IMPORTS  ----------------------------------------------------------------------------------------------------------------------
	include "$userScripts\cp-Urba\Modules\Quartier\Quartier - Core.ms"

	

	--------------- CORE   ----------------------------------------------------------------------------------------------------------------------
	local core = str_quartier_core  	()

	
	
	--------------- PARAMETRES  et ROLLOUTS ----------------------------------------------------------------------------------------------------------------------

	---- on  importe les parametres -----
	include "$userScripts\\cp-Urba\\modules\\Quartier\\Quartier - Parametres.ms"
	
	---- on  importe les rollouts -----
	include	 "$userScripts\\cp-Urba\\modules\\Quartier\\Quartier - rollout.ms" 
	include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - rollout - A propos.ms" 

	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn initialiser 	doLogo:false	=(
		core.initialiser 		this
	)
	fn actualiser 		=(
		core.actualiser ()
	)
	
	
	
	
	--------------- CREATION  ----------------------------------------------------------------------------------------------------------------------
	tool create (
		on mousePoint click do	(
			nodeTM.translation = worldPoint
			core.actualiser ()

			#stop
		)
	) --- fin tool create ------------


	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on load 						do 	(
		debug "load du plugin"
		initialiser ()
	)
	on clone 	_original 	do (
		initialiser ()
	)
	on create do (
		debug "creation du plugin"
		initialiser ()
		actualiser ()
	)
	on update do	(
		debug "update du plugin"
		debug "shape : " var:surface_node
		initialiser ()
-- 		actualiser ()
	)
	
	
	
	
	
	
	
)