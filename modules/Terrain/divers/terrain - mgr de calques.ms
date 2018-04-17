

include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\terrain - mgr de polygones.ms" 


----- un calque --------------------------------------------------------------------------------------------
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
			
			debug "ajouter_polygone()"
			
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
			
			polygones
			
		),
		fn retirer_polygone		_polygone 		=(
			local id_polygone= findItem polygones	_polygone
			if id_polygone != 0 do
				deleteItem polygones id_polygone
		)/* ,
		fn get_pts =(
			local pts_result =#()						
			for nd in polygones do 
				pts_result += mgr_shape.creer_pts_pourFace  nd
			
			pts_result
		) */
		
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
			
			debug "----------------------------------------------------------------------------"
			debug ("[ " + _calq.nom  + "(#" + _calq.operation as name + ") ]" )
			for _poly in _calq.polygones do
				debug_poly _poly
		),	
		
	public
		fn debug_pile	=	(
			debug "----------------------------------------------------------------------------"
			debug "				PILE des calques"
			for calque in this.m_pile do
				debug_calque calque
			debug "----------------------------------------------------------------------------"
			
		),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		
		
		
		
		
		
		
		
	
	-----------------	Membres	------------------------------------------------------------------------------------------------------------------------------------------------------
	private	
		m_pile 		=	#(),
		
		---- manager de polygones --------------
		mgr_polys	=	str_mgr_polygones (),
		
	-----------------	Fonctions	internes ------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		fn operer	_calque_A	_calque_B	operation:#union	=(
			
			local calque_result		=	this.creer_calque ()
			
			--- au premier tour on opere avec les polygones du calque A
			local polygones_a_operer	=	for li in _calque_A.polygones collect li
			
			--- pour chacune des polygone du calque B --------------
			for polygone_B in _calque_B.polygones do (
				
				local polygones_result =#()
				
				---- a chacune des polygones du calque A ----------
				for polygone_aOperer in polygones_aOperer do (
					
					----- on applique l'operation bool à chacune des polygones -----------------------
					polygones_result +=	mgr_polygones.operation_bool  	polygone_aOperer 		polygone_B	operation:operation
					
				)
				
				--- apres on opere chaque tour avec le resultat precedant et on recommence avec la polygone B suivante ------------
				polygones_a_operer = polygones_result
			)
			
			--- au dernier passage normalement on a tout calculé ---------			
			calque_result.polygones = polygones_a_operer
			
			calque_result
		),
		
	-----------------	Interface	------------------------------------------------------------------------------------------------------------------------------------------------------
	public
		
	-------------- la pile -----------------------------------------
		---- Accessions -------------
		fn get_resultat	=(
			local result_pile
			
			---- pour chaque calque de la pile-------------
			for calque in pile do (
				--- on calcule l'operation avec chacune des polygones du calque pile	--------
				result_pile = 		operer	result_pile	calque	operation:calque.operation
			)
			result_pile
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
			
		),
		
		
		
		
	-------------- calques -----------------------------------------
		---- Manipulations -------------
		fn creer_calque		shape_node:	nom:"temporaire"		=(
			
			debug "creer_calque()"
			
			--- Creation d'un calque vide	---------
			local nv_calque = str_calque 	nom:nom
			
			--- Si on a un shape en entrée, on ajoute les polygones du shape au nv calque ----------
			if shape_node != unsupplied	do (
				
				nv_calque.nom 	= shape_node.name
				--- creation des polys à partir du shape -----
				local polygones 	= mgr_polys.creer_fromShape	shape_node
				
			debug "creer_calque #1"
			debug "polygones"var:polygones
				--- Ajout des polys au nv calque -----
				for poly  in polygones do 
					nv_calque.ajouter_polygone 	poly
				
			)
			
			--- debug ----
			debug_calque	nv_calque
			
			nv_calque
			
		)
		
		

) ---------- FIN structure mgr calques --------------------------------------------------------------






















