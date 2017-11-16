/*
#######################################################################################################################
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
	
	
	/* --------------------  CLEANAGE --------------------
	
	local geo 			= 	str_geo 				m_this:this
	local construire	=	str_construire		m_this:this		m_geo:geo  					
	local facades		=	str_facades		m_this:this		m_construire:construire
	local trace			=	str_trace 			m_this:this		m_geo:geo
	
	local presets 	= str_presets_batiment 	fichier_dossier:			( getDir #userScripts	 + "\\cp-Urba\\lib\\batiments\\"		)	\
															fichier_categorie:			"Urba - Bâtiment"	\
															fichier_extension:			"btm"	\
															params_aEnregistrer:	params_aEnregistrer

	local nodeScanner = str_enregistreurDeNode ()
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------	
	------------ Affichage - ViewPort ------------------------------------------------
	fn	fn_VP_afficher_axePrincipal		 =(
		
		gw.setTransform (matrix3 1)
		
		
		for o in selection where classof o == urba_batiment  do (
			
			local largeurFleche = 100
			local BB_axeP 	= o.axeP_BB
			local mtrx_axeP	= o.axeP_mtrx 
			local mtrx_axeP2	= o.axeP_mtrx 
				
			translate mtrx_axeP 	BB_axeP[1]
			
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP ) - (BB_axeP[1]  * inverse mtrx_axeP  )
			local largeur 		=	diag_axeP.x
			local longeur 		= 	diag_axeP.z
-- 				
			------ l'AXE----------------
			if o.affiche_axe do (
				---- dessin de l'Axe-----------------
				local ptAxe_1 =  [largeur/2,0,0]  *   mtrx_axeP   * o.transform
				local ptAxe_2 =  [largeur/2,0,longeur - largeurFleche ]  *     mtrx_axeP    * o.transform

				gw.setColor	#line	yellow
				gw.Polyline #( ptAxe_1, ptAxe_2 )	false
				
				---- dessin de la fleche de l'axe -----------------
				local ptFleche_1 = (  [largeur/2,0,longeur + 0 ]  ) *  mtrx_axeP    * o.transform
				local ptFleche_2 = (  [largeur/2,0,longeur + 0 ]   + [largeurFleche/ 3,0,-largeurFleche ]) *  mtrx_axeP    * o.transform
				local ptFleche_3 = (  [largeur/2,0,longeur + 0 ]   + [-largeurFleche/ 3,0,-largeurFleche ]) *  mtrx_axeP    * o.transform
				
				gw.Polyline #( ptFleche_1, ptFleche_2, ptFleche_3 )	true
			)
			
			
			
			--- sous tracés -------------
			if o.affiche_ssTraces do (
				
				
				local rectangles = o.trace.rectangles_traces
				
				for i = 1 to rectangles.count do (
-- 					format "o.sousTraces.count :%\n"	o.sousTraces.count
					local rect = rectangles[i]
					
					local barycentre = [0,0,0]
					for id_pt = 1 to rect.count do (
						local id_ptSuiv = id_pt + 1
						if id_ptSuiv > rect.count do id_ptSuiv = 1
						local id_rect 				= rect[ id_pt ]
						local id_rect_suivant 	= rect[ id_ptSuiv ]
						
						local pt 			= o.trace_courant[ id_rect  ] 				*  o.transform 
						local pt_suivant 	= o.trace_courant[ id_rect_suivant  ]  	*  o.transform 
						gw.setColor	#line	gray
						gw.polyline #( pt, pt_suivant )	false
						barycentre += pt
					)
						
					local pt_0 = o.trace_courant[ rect[ 1 ] ]
					local pt_1 = o.trace_courant[ rect[ 2 ] ]
					local pt_2 = o.trace_courant[ rect[ 4 ] ]
					
					barycentre /= rect.count
					
					local surf = ( distance pt_1 pt_0 ) * ( distance pt_2 pt_0 ) / 10000
					gw.text 		barycentre	( surf as string + " m²" )  	color:gray
				)
				
				
				local sousTraces = o.sousTraces
-- 				local barycentre = [0,0,0]
				for i = 1 to sousTraces.count do (
-- 					format "o.sousTraces.count :%\n"	o.sousTraces.count
					
					local nvSsTrace = str_ssTrace ()
					local sousTrace = o.trace.datasMgr.set_datas_string 		sousTraces[i] 		nvSsTrace 	_this
					
					for id_pt = 1 to sousTrace.trace.count do (
						local id_ptSuiv = id_pt + 1
						if id_ptSuiv > sousTrace.trace.count do id_ptSuiv = 1
						local id_ssTrace 				= sousTrace.trace[ id_pt ]
						local id_ssTrace_suivant 	= sousTrace.trace[ id_ptSuiv ]
						
						local pt 			= o.trace_courant[ id_ssTrace  ] 		*  o.transform 
						local pt_suivant 	= o.trace_courant[ id_ssTrace_suivant  ]  	*  o.transform 
						gw.setColor	#line	yellow
						gw.polyline #( pt, pt_suivant )	false
-- 						barycentre += pt
					)
						
-- 					local pt_0 = o.trace_courant[ sousTrace[ 1 ] ]
-- 					local pt_1 = o.trace_courant[ sousTrace[ 2 ] ]
-- 					local pt_2 = o.trace_courant[ sousTrace[ 4 ] ]
					
-- 					barycentre /= sousTraces.count
					
-- 					local surf = ( distance pt_1 pt_0 ) * ( distance pt_2 pt_0 ) / 10000
-- 					gw.text 		barycentre	( surf as string + " m²" )  	color:gray
				)
				
				
				
				
			)
				
				
	-- 			gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
			
			
			
			for i = 1 to o.trace_courant.count do (
				
					
				local j = i + 1
				if j > o.trace_courant.count do j = 1
				local pt = o.trace_courant[i] *  o.transform 
				local pt_suivant = o.trace_courant[j] *  o.transform 
				
				---- les pignons et gouttereaux -----
				local col = red
				local estPignon = o.trace.est_pignon i 
				if estPignon then (
					if o.affiche_pignons do (
						gw.setColor	#line	blue
						gw.polyline #( pt, pt_suivant )	false
						
						local longueurFacade = ( distance pt pt_suivant ) as string
							gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
						
					)
				)else (
					if o.affiche_gouttereaux do (
						gw.setColor	#line	red
						gw.polyline #( pt,pt_suivant )	false
						
						local longueurFacade = ( distance pt pt_suivant ) as string
							gw.text 		( (pt + pt_suivant) /2 )	longueurFacade  	color:white
						
					)
				)
				---- les points du trace_courant -----
				if o.affiche_trace do (
					gw.text 		(pt + [0,0,10]) 	(i as string )  	color:yellow
-- 					gw.Marker 	pt 	#hollowBox 	color:yellow
				)
			
			)
			
		)
		gw.enlargeUpdateRect #whole  


	)
	fn VP_toggle	=(
		unregisterRedrawViewsCallback 	fn_VP_afficher_axePrincipal
		if 	 this.affiche_axe or  this.affiche_trace or  this.affiche_pignons or  this.affiche_gouttereaux   or  this.affiche_ssTraces do
			registerRedrawViewsCallback 		fn_VP_afficher_axePrincipal 	
	)
	fn actualiser_cacherGeo =(
		if this.cache_geometrie then (
			local faces = #{1..(polyop.getNumFaces delegate)} as array
			polyop.setHiddenFaces 	this.delegate 	faces
		) else
			polyop.unHideAllFaces 	this.delegate
	)
	---- Rollouts------------
	fn actualiser_rollouts =(
		
		roll_presets.actualiser 	()	
		roll_trace.actualiser 	()		
		roll_global.actualiser 	()				
		roll_facades.actualiser 	()
		roll_toiture.actualiser	()
		roll_infos.actualiser 		()
		
	)
	---- Reconstruit le batiment ---
	fn actualiser_geometrie =(
-- 		facades.params_toStructs 	this		
		construire.batiment 	()
	)
	
	fn initialiser =(
		geo.m_this 				= this
		construire.m_this 	= this
		facades.m_this 		= this
		trace.m_this 			= this
	)
	
	
	
	------------  Interface ------------------------------------------------
	---- assigner un tracé -----
	fn assigner_trace 	_nvtrace	_node	=
		if _nvtrace != undefined do (
			trace.definir		_nvtrace	_node
			trace.actualiser		()
			construire.batiment 	()
			
		)
	
	
	*/ --------------------  CLEANAGE --------------------
	
	
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
	
	
	--------------- import des PARAMETRES  et rollouts ----------------------------------------------------------------------------------------------------------------------	
	include "$userScripts\cp-Urba\Urba - modifer plugin - Batiment - rollouts.ms"
	
	
	
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




