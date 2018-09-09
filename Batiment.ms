/*#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT

	Batiment procédural pour utilisation avec générateur de ville procédurale

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

	*v0.2 - [20/02/2018] -----------------------------------------------------------------------------
	- Reorganisation globale

########################################################################################################################*/








---- le presse papier pour copier coller -----
global urba_clipboard_batiment	=	""



--------------- debugger ---------
-- (
	include "$userScripts\\cp-Urba\\modules\\Commun\\Urba - Debug.ms"

/* 
	global debug, debuger, ecrire
	global DEBUG_MODE = true






	fn remplirTexte  _txt  var:	 param:  prefix: = (

local oldPrintAllElements = options.printAllElements
options.PrintAllElements = true
		
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
		
		
	
options.printAllElements = oldPrintAllElements
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

 */




-- )	--------- fin debug --------------






--------------- le plug in ---------
plugin geometry 	Urba_Batiment
name:"Batiment"
classID:#(685325,452281)
category:"CP | Urba"
extends:Editable_poly replaceUI:true version:0
remap:#(#(#surface_node), #(#surface_node))
(

	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	local m_debug = true
	local m_dbgPrefix ="urba | Batiment Plg"
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	)

	--------------- IMPORTS  ----------------------------------------------------------------------------------------------------------------------
	include "$userScripts\cp-Urba\Modules\Batiment\Batiment - Core.ms"


	--------------- CORE   ----------------------------------------------------------------------------------------------------------------------
	local core = str_batiment_core  	()

	--------------- PARAMETRES  et ROLLOUTS ----------------------------------------------------------------------------------------------------------------------
	local roll_global, roll_toiture, roll_facades 										----, roll_niveaux,  roll_presets,   roll_infos, roll_trace
	include "$userScripts\\cp-Urba\\Modules\\Batiment\\rollouts\\Batiment - rollouts.ms"
	include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - rollout - A propos.ms" 





	--------------- INTERFACE  ----------------------------------------------------------------------------------------------------------------------

	/*
	fn activer_ecouteur_selection	=	(

		debug "activer ecouteur selection"

		when select 	this  changes  id:#Urba_bat_selection  obj  do (
			format "obj.isSelected :%\n"  obj.isSelected
			if not obj.isSelected do
				if obj.core.editeur_estOuvert do m_editeur_dialog.fermer ()

		)
	) */
	
	
	---Initialisations / Actualisations ------
	fn initialiser 	doLogo:false	=(
-- 		activer_ecouteur_selection ()
		core.initialiser 		this
	)
	fn actualiser 		=(
		core.actualiser ()
	)
	fn actualiser_rollouts =(
		roll_global.actualiser ()
	)


	---- Contours	---------
	fn assigner_shape 		_nodeTHIS		_shape 		=	core.assigner_surface 	_nodeTHIS		_shape

	
	---- Accessions --------------
	fn get_facades 							= core.get_facades ()
	fn	get_etage_ht		_etageNum 	= core.get_etage_ht _etageNum
	fn get_toiture 							= core.get_toiture ()
	fn set_etages_nbre	_nbr_etages =(
		etages_nbre			 = _nbr_etages
	
	)
	fn set_etages_ht		_ht_etages =(
		etages_hauteur_global = _ht_etages
	)
	
	---- Affichage --------------
	fn set_proxy_mode 	_state 	=(
		affiche_asProxy = _state
		core.actualiser_geometrie ()
	)
	
	--- Models -------------
	fn charger		_nomDuFichier		val_etages_nbre:		val_etages_ht:	= (
		debug""
				debug "charger" 
				debug "_nomDuFichier" var:_nomDuFichier
		
				debug "val_etages_nbre" var:val_etages_nbre
				debug "val_etages_ht" var:val_etages_ht
		if doesFileExist	_nomDuFichier	then (
			if val_etages_nbre != unsupplied or  val_etages_ht != unsupplied then (
				
				core.preset_charger  	fichier:_nomDuFichier	maj:false
				
				if val_etages_nbre != unsupplied 	do etages_nbre = val_etages_nbre
				if val_etages_ht != unsupplied 	do etages_ht = val_etages_ht
				debug "etages_nbre" var:etages_nbre
				debug "etages_ht" var:etages_ht
				core.actualiser ()
				
			) else
				core.preset_charger  	fichier:_nomDuFichier
		)
		else core.preset_charger()	--format "/!\\ Attention! le fichier (%) n'existe pas, impossible à charger/n"		(_nomDuFichier as string )
	)
	
	--- Quartier parent ----------------
	fn assigner_quartier 	_quartier =(
		quartier_parent = (nodeTransformMonitor node:_quartier forwardTransformChangeMsgs:false)
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
-- 		debug "load du plugin"



		initialiser ()
	)
	on clone 	_original 	do (
-- 		debug "clone du plugin"
		initialiser ()
	)
	on create do (
-- 		debug "creation du plugin"
		initialiser ()
		actualiser ()
	)
	on update do	(
-- 		debug "update du plugin"
-- 		debug "shape : " var:surface_node
		initialiser ()
-- 		actualiser ()
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
