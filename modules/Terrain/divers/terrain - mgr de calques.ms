

include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\terrain - mgr de polygones.ms" 


----- un calque -------------------------------------------------------------------------------------------
struct str_calque (
	private
		mgr_polys 		= str_mgr_polygones (),
		
	public					
		polygones		=	#(),
		operation		=	#addition,
		nom				=	"",
		
	---- fonctions	--------------------------------------------------------------
	public
		fn	ajouter_polygone		_polygone_aAjouter	=	(
			
			debug "ajouter_polygone"
			debug "_polygone_aAjouter" var:_polygone_aAjouter.nom
			
			--- on regarde si on peut l'inserer dans un polygone deja present dans le calque ----------------------------
			local a_ete_integre			=	false		
			local i = 1
			while	 i <= polygones.count and not a_ete_integre	do (
				local poly_calque				=	polygones[ i ]
				local integration_reussie	=	mgr_polys.inserer_poly_ds_poly		_polygone_aAjouter		poly_calque
				if integration_reussie do a_ete_integre = true
				i += 1
			)
			
			---- s'il a pas été inserer, on l'ajoute basiquement aux polygones du calque- ---------------------------------
			if not a_ete_integre do
				append 		polygones 		_polygone_aAjouter
			
			debug "a_ete_integre" var:a_ete_integre
			debug "polygones" var:polygones param:#nom
			
			polygones
			
		),
		fn retirer_polygone		_polygone 		=(
			local id_polygone= findItem polygones	_polygone
			if id_polygone != 0 do
				deleteItem polygones id_polygone
		),
		fn get_polygones  =(	--	all:false
			
-- 			local result = #()
-- 			for poly in polygones do
-- 				result += poly.get_descendance ()
-- 			
-- 			result
			for poly in polygones collect poly
		),
		fn get_pts =(
			local pts_result =#()						
			for poly in polygones do 
				pts_result += mgr_polys.creer_pts_pourFace  poly
			
			pts_result
		)
		
) ---- fin struct calque --------------------------------------------------------------------------------------------



struct	str_mgr_calques	(

	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	true,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | calques"	  	var:var	 param:param		catch (),
		
		m_tab_format_poly = "		",
		fn format_polygone 	_poly =(
			local indent_prfix = "|    "
			debug (  m_tab_format_poly +  "+ " + _poly.nom + "" )
			if _poly.enfants.count >0 	do	m_tab_format_poly += indent_prfix
			for enft in _poly.enfants 	do 	format_polygone enft
			if _poly.enfants.count >0 	do	m_tab_format_poly = substring m_tab_format_poly 1 (	m_tab_format_poly.count -	indent_prfix.count )
		),
		fn	debug_poly  _poly = if m_debug do (			 
			format_polygone 	_poly 
		),
		fn debug_calque	_calq	=(
			debug ( "------------- " + _calq.nom	+" ---------------------")
			for _poly in _calq.polygones do
				debug_poly _poly
		),	
		
	public
		fn debug_pile	=	(
			debug "----------------------------------------------------------------------------"
			debug "				PILE des calques"
			local i = -1
			for calque in this.m_pile do (
				
				debug "----------------------------------------------------------------------------"
				debug ("	Calque " + (i+1) as string + " : [ " + calque.nom  + "(#" + calque.operation as name + ") ]" )
				debug "----------------------------------------------------------------------------"
				debug_calque calque
			)
			debug "----------------------------------------------------------------------------"
			
		),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		
		
		
		
		
		
		
		
	
	-----------------	Membres	------------------------------------------------------------------------------------------------------------------------------------------------------
	private	
		m_pile 		=	#(),
		
		---- Managers		----------------------------
		mgr_polys	=	str_mgr_polygones (),
		mgr_shp				=	str_outils_shape (),
		
	
		SEUIL_POINTS_EGAUX  	= .01,
		-- constante pr debug-----------------
		SAUVETAGE_MAX 			= 100,
	
	
	-----------------	Fonctions	internes ------------------------------------------------------------------------------------------------------------------------------------------------------
	private
	
	
		fn operer_calque_poly		_calque_A		_poly_B		 operation:#union =(
			
			local 	polys_A	=	_calque_A.get_polygones ()
			debug"---------------------------"
				debug"	polys_A" var:polys_A
				debug"	_poly_B" var:_poly_B
			
			debug"---------------------------"
			If _poly_B.enfants.count>0 do  (
				for poly_enfant in _poly_B.enfants do
					operer_calque_poly	_calque_A	poly_enfant
			) 
			
			
			--- pour chacun des polys de B ------------
			local est_a_cote			=	true
			local poly_aLinterieur	= 	undefined
			local poly_aLexterieur	= 	undefined
			
			debug"---------------------------"
			
			
			
			for parent_poly_A in polys_A do (
				
				for poly_A in (parent_poly_A.get_descendance())  do (
					debug"	poly_Apoly_Apoly_Apoly_Apoly_Apoly_Apoly_Apoly_Apoly_Apoly_A" var:poly_A
					local ope = mgr_polys.operation_booleene  	poly_A 		_poly_B		operation:operation
					debug"	ope.poly_aLinterieur" var:ope.poly_aLinterieur
					debug"	ope.poly_aLexterieur" var:ope.poly_aLexterieur
					if not ope.a_cote do est_a_cote = false
						
					
					if ope.poly_aLexterieur != undefined and not _poly_B.en_creux  do (
						_calque_A.retirer_polygone	ope.poly_aLexterieur
						ope.poly_aLexterieur.supprimer ()
						ope.poly_aLexterieur= undefined
						)
						
					if ope.poly_aLinterieur != undefined and poly_aLinterieur==undefined do poly_aLinterieur=ope.poly_aLinterieur 
					if ope.poly_aLexterieur != undefined and poly_aLexterieur==undefined do poly_aLexterieur=ope.poly_aLexterieur
					if ope.poly_aLinterieur != undefined and poly_aLinterieur!=undefined do (
						
						debug"OPEEEEEEEE" var:ope
						if ope.poly_aLinterieur.est_un_enfant		poly_aLinterieur do poly_aLinterieur=ope.poly_aLinterieur
						
					)
					if ope.poly_aLexterieur != undefined and poly_aLexterieur!=undefined do 
						if poly_aLexterieur.est_un_enfant			ope.poly_aLexterieur do poly_aLexterieur=ope.poly_aLexterieur

				)
			)
			
			
			
			
			
			
			debug"---------------------------"
			if est_a_cote do _calque_A.ajouter_polygone	_poly_B
				debug"est_a_cote" var:est_a_cote
				debug"poly_aLinterieur" var:poly_aLinterieur
				debug"poly_aLexterieur" var:poly_aLexterieur
			
			
-- 			if poly_aLexterieur!=undefined 
				--- B dans un truc ---------
			if poly_aLinterieur!=undefined and poly_aLexterieur==undefined  and poly_aLinterieur.en_creux do (
				
				poly_aLinterieur.ajouter_enfant		_poly_B
			)
			
			
			
			--- B contient une branche
			if poly_aLinterieur==undefined and poly_aLexterieur!=undefined and _poly_B.en_creux  do  
				_poly_B.ajouter_enfant		poly_aLexterieur	
			if poly_aLinterieur==undefined /* and poly_aLexterieur!=undefined */ and not _poly_B.en_creux  do  (
-- 				_poly_B.ajouter_enfant		poly_aLexterieur
				debug"--------------- ##########################popo-----------------"
				
				_calque_A.ajouter_polygone	_poly_B
				debug_calque _calque_A
			)
			
			
			--- B dans un truc  B contient une branche et b plein ( si b vide rien )
			if poly_aLinterieur!=undefined and poly_aLexterieur!=undefined do  (
				
				if not _poly_B.en_creux do (
					_calque_A.retirer_polygone	poly_aLexterieur
					
					if  not poly_aLinterieur.en_creux   then 	(
						
						_poly_B.supprimer ()
					)
					else 
					(
						poly_aLinterieur.ajouter_enfant		_poly_B					
					
					)
				)
				
			)
			
			
		),
		
		fn operer_calques	_calque_A 		_calque_B		operation:#union 	=(
			
			
			--- On renvois un calque	-------------
			local calque_result = this.creer_calque	nom:"RESULTAT BOOL"
			
			local 	polys_A	=	_calque_A.get_polygones ()
			local 	polys_B	=	_calque_B.get_polygones ()
			
			
			--- pour chacun des polys de B ------------
			for poly_B in polys_B do
				operer_calque_poly		_calque_A		poly_B		operation:operation
				
			debug "---------------------------------------------------------->	_calque_A" var:_calque_A
			
			
			debug_calque		_calque_A		
			
			_calque_A
			
		),
		
		
		
		fn calculer_pile	=(
			debug "calculer_pile ()"
			local result_calque = this.creer_calque ()
			if m_pile.count >0 then (
				--- on renvois un calque -----------
				result_calque = m_pile[1]	--	this.creer_calque ()
				
-- 				debug "----->	result_calque" var:result_calque
				---- pour chaque calque de la pile-------------
				for i = 2 to m_pile.count do (
					local calque = m_pile[i]
					--- on calcule l'operation avec chacun des polygones du calque pile	--------
					result_calque = 		operer_calques		result_calque	calque	operation:calque.operation
				)
				
			) 
			
			
-- 			debug_calque		result_calque		
			
			result_calque
		),
	-----------------	Interface	------------------------------------------------------------------------------------------------------------------------------------------------------
	public
		
	-------------- calques -----------------------------------------
		---- Manipulations -------------
		fn creer_calque		shape_node:	nom:"temporaire"		=(
			
			--- Creation d'un calque vide	---------
			local nv_calque = str_calque 	nom:nom
			
			--- Si on a un shape en entrée, on ajoute les polygones du shape au nv calque ----------
			if shape_node != unsupplied	do (
				
				nv_calque.nom 	= shape_node.name
				--- creation des polys à partir du shape -----
				local polygones 	= mgr_polys.creer_fromShape	shape_node
				
				--- Ajout des polys au nv calque -----
				for poly  in polygones do 
					nv_calque.ajouter_polygone 	poly
				
			)
			
			nv_calque
			
		),
		
	-------------- la pile -----------------------------------------
		---- Accessions -------------
		fn get_pts_resultat	=(
			local result = calculer_pile ()
			result.get_pts ()
		),
		fn get_calques = 	for calque in m_pile collect calque,
		
		---- Manipulations -------------
		fn vider = m_pile =#(),
		fn ajouter_calque		_calque			index:0	=(
			if index != 0 then 
				insertItem		_calque		m_pile	index
			else 
				append 	m_pile 	_calque
		),		
		fn supprimer_calque	_calque	=(
			
		)
		
		
		
		
		

) ---------- FIN structure mgr calques --------------------------------------------------------------






















