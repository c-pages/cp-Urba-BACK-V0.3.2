

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
			
			--- on regarde si on peut l'inserer dans un polygone deja present dans le calque ----------------------------
			local a_ete_integre			=	false		
			local i = 1
			while	 i <= polygones.count and not a_ete_integre	do (
				local poly_calque				=	polygones[ i ]
				local integration_reussie	=	mgr_polys.inserer_poly_ds_poly		_polygone_aAjouter		poly_calque
				if integration_reussie do a_ete_integre = true
				i += 1
			)
			
			---- s'il a pas �t� inserer, on l'ajoute basiquement aux polygones du calque- ---------------------------------
			if not a_ete_integre do
				append 		polygones 		_polygone_aAjouter
			
			polygones
			
		),
		fn retirer_polygone		_polygone 		=(
			local id_polygone= findItem polygones	_polygone
			if id_polygone != 0 do
				deleteItem polygones id_polygone
		),
		fn get_polygones 	all:true =(
			local result = #()
			for poly in polygones do (
				append result		poly
				if all do result	+=	poly.get_descendance ()
			)
			result
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
		
		---- manager de polygones --------------
		mgr_polys	=	str_mgr_polygones (),
		
	-----------------	Fonctions	internes ------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		fn operer	_calque_A	_calque_B	operation:#union	=(
			debug "-------------operer ()-----------------"
			
			debug "	_calque_A" var:_calque_A
			debug "	_calque_B" var:_calque_B
			local calque_result		=	this.creer_calque ()
			
			--- au premier tour on opere avec les polygones du calque A ------------
			local polygones_aOperer	=	_calque_A.get_polygones ()
				
			--- si le calque � operer est vide, on ajoute tout B ----------
			if polygones_aOperer.count == 0 then (
				debug "-------------> polygones_aOperer.count == 0  !"
				polygones_aOperer = _calque_B.get_polygones ()
				debug "-------------> POLYGONES_AOPERER  ??????????? " var:polygones_aOperer param:#nom
			
			) else (
				debug "------- pour chacun des polygone du calque B ... --------------"
				--- pour chacun des polygone du calque B ... --------------
				for polygone_operant in _calque_B.polygones do (
					
				format "\n"
					debug "		---->	polygone_operant -B- " var:polygone_operant param:#nom
					
					
					---- On vide les enfants ----------
					polygone_operant.enfants = #()
					
					local polygones_result =#()
					local a_ete_integrer = false
					
					---- sinon, � chacune des polygones du calque A  ... ----------
					for polygone_aOperer in polygones_aOperer do (
						debug "			---->	polygone_aOperer -A-" var:polygone_aOperer param:#nom
						
						---- On vide les enfants ----------
						polygone_aOperer.enfants = #()
						
						-----  ... on applique l'operation booleenne.  -----------------------
						local ope_bool = mgr_polys.operation_booleene  	 polygone_aOperer		polygone_operant		operation:operation
						
						polygones_result +=	ope_bool[2]
						if ope_bool[1]  do
							a_ete_integrer = true
						
						debug "			---->	polygones_result" var:polygones_result param:#nom
						
					)
					
					if not a_ete_integrer do
						append polygones_result 	polygone_operant
					
					--- apres on op�re chaque tour avec le resultat precedant et on recommence avec le polygone operant suivante ------------
					polygones_aOperer = polygones_result
					
				)
			)
			
			debug "-------------> POLYGONES_AOPERER" var:polygones_aOperer param:#nom
			--- au dernier passage normalement on a tout calcul� ---------
			for poly in polygones_aOperer do
				calque_result.ajouter_polygone	poly
			
-- 			calque_result.polygones = polygones_aOperer
			
			calque_result
			
		),
		
		fn calculer_pile	=(
			debug "calculer_pile ()"
			local result_calque
			if m_pile.count >0 then (
				--- on renvois un calque -----------
				result_calque = m_pile[1]	--	this.creer_calque ()
				
				debug "----->	result_calque" var:result_calque
				---- pour chaque calque de la pile-------------
				for i = 2 to m_pile.count do (
					local calque = m_pile[i]
					--- on calcule l'operation avec chacun des polygones du calque pile	--------
					result_calque = 		operer	result_calque	calque	operation:calque.operation
				)
				
			) else 
				result_calque = this.creer_calque ()
			

			debug_calque		result_calque		
			
			result_calque
		),
	-----------------	Interface	------------------------------------------------------------------------------------------------------------------------------------------------------
	public
		
	-------------- calques -----------------------------------------
		---- Manipulations -------------
		fn creer_calque		shape_node:	nom:"temporaire"		=(
			
			--- Creation d'un calque vide	---------
			local nv_calque = str_calque 	nom:nom
			
			--- Si on a un shape en entr�e, on ajoute les polygones du shape au nv calque ----------
			if shape_node != unsupplied	do (
				
				nv_calque.nom 	= shape_node.name
				--- creation des polys � partir du shape -----
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





















