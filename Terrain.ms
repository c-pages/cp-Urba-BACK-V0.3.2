/*#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - Terrain

	Générer des terrains à partir d'un relief et de differentes splines

########################################################################################################################*/









--------------- debugger ---------
-- (
-- 	include "$userScripts\cp - GLOBAL\Debuger et ecrire.ms"


	global debug, debuger, ecrire
	global DEBUG_MODE = true

global remplirTexte, debuger, ecrire





	fn remplirTexte  _txt  var:	 param:  prefix: = (

		local result =""
		global dbg_elemTmp
		if prefix != unsupplied and prefix != undefined do (
			result += "<" + prefix + ">	"
	-- 		if prefix.count < 10 do result += "	"
			if prefix.count < 6 do result += "	"
			if prefix.count < 2 do result += "	"
		)
		if var != unsupplied then (

			result += "	- " + _txt +  " : "

			if classof 	var == Array then (

				if param != unsupplied then (
					result += "(" + var.count as string + ")  "
					for i = 1 to var.count do (
						if var[i]	 != undefined then (
						dbg_elemTmp	= var[i]

						result +=  ( execute ("dbg_elemTmp." + param ) ) as string

						if i != var.count	do result += ", "
						) else result += "undefined"
					)
				) else 	result += var as string
			) else
			if param != unsupplied  then (
				if var != undefined then (
					dbg_elemTmp	= var
					result += ( execute ("dbg_elemTmp." + param ) ) as string
				) else 	result += "undefined"
			) else 	result += var as string
		) else 	result += _txt
		result
	)

	fn debuger	_txt  var:	 param:    prefix: = 	(
		if DEBUG_MODE   do (
			local txtFinal = "<DEBUG>	"

			txtFinal += remplirTexte  _txt  var:var	 param:param 	prefix:prefix

			format "%\n"	txtFinal
		)
	)
	----- output ------------------------------
	fn ecrire 		_txt  var:	 param:   script:"URBA|Batiment"	= 	(
	-- 	if not DEBUG_MODE then  (

			local txtFinal = "<" + script + ">	"

			txtFinal += remplirTexte  _txt  var:var	 param:param
			format "%\n"	txtFinal
	-- 	) else debuger 	_txt  	var:var	 param:param
	)






-- )	--------- fin debug --------------



	include	 "$userScripts\\cp-Urba\\modules\\Terrain\\Terrain - node.ms" 



--------------- le plug in ---------
plugin helper 	Urba_terrain_mgr
name:"Terrain mgr"
classID:#(519845,146284)
category:"CP | Urba"
invisible:true
extends:point 
replaceUI:true 
version:0
(

	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	local m_debug = false
	local m_dbgPrefix ="urba | Terrain Plg"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)

	


	--------------- CORE   ----------------------------------------------------------------------------------------------------------------------
	include	 "$userScripts\cp-Urba\Modules\Terrain\Terrain - core.ms" 
	local core = str_urba_terrain_core  	()
	
	

	--------------- INTERFACE  ----------------------------------------------------------------------------------------------------------------------

	include	 "$userScripts\cp-Urba\Modules\Terrain\Terrain - rollouts.ms" 
	include	 "$userScripts\cp-Urba\Modules\Terrain\Terrain - parametres.ms" 
	
	---Initialisations / Actualisations ------
	fn initialiser 	=(
		core.initialiser 	this
	)
	fn actualiser_rollouts =(
		roll_terrain_global.actualiser ()
	)
	fn actualiser 		=(
		core.actualiser ()
-- 		actualiser_rollouts ()
	)


	---- Divers	---------



	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on load 						do 	(
		debug "load du plugin"

		initialiser ()
	)
	on clone 	_original 	do (
-- 		debug "clone du plugin"
		initialiser ()
	)
	on create do (
		
		debug "creation du plugin"
		
		delegate.centermarker 			=	off
		delegate.axistripod				=	off
		delegate.cross						= off
		delegate.Box						=	on 
		delegate.constantscreensize	=	on 
		delegate.size						=	20
		delegate.drawontop				=	off
		
		initialiser ()
	)
	on update do	(
		debug "update du plugin"
	)

) --- fin du plug ---



