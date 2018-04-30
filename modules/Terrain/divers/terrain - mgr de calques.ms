

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
			
-- 			debug "ajouter_polygone"
-- 			debug "_polygone_aAjouter" var:_polygone_aAjouter.nom
			
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
			
-- 			debug "a_ete_integre" var:a_ete_integre
-- 			debug "polygones" var:polygones param:#nom
			
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
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | calq."	  	var:var	 param:param		catch (),
		
		m_tab_format_poly = "    ",
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
			debug ( "calque: " + _calq.nom	+" ---------------------")
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
			
			
			If _poly_B.enfants.count>0 do  (
				for poly_enfant in _poly_B.enfants do
					operer_calque_poly	_calque_A	poly_enfant	operation:operation
			) 
			
			
			format "\n\n\n"
			debug"---------------------------"
			debug"operer_calque_poly"
			debug"	_calque_A" var:_calque_A.nom
			debug"	_poly_B" var:_poly_B.nom
			debug"---------------------------"
-- 			debug"_poly_B.enfants" var:_poly_B.enfants param:#nom
			debug_calque _calque_A
			debug"---------------------------"
			
			
			local 	polys_A	=	_calque_A.get_polygones ()
			
			local est_a_cote			=	true
			local est_aLinterieurDe	= 	undefined
			local est_aLexterieurDe	= 	undefined
			
			
			
			
			--- pour chacun des polys du calque A ------------
			for parent_poly_A in polys_A do (				
				for poly_A in (parent_poly_A.get_descendance())  do (
					
					
					format "\n\n"
					debug"----- POLY_A" var:poly_A.nom
					debug"----- POLY_B" var:_poly_B.nom
					local ope = mgr_polys.operation_booleene  	poly_A 		_poly_B		operation:operation
					
					
					debug"	ope.est_aLinterieurDe" var:ope.est_aLinterieurDe
					debug"	ope.est_aLexterieurDe" var:ope.est_aLexterieurDe
						
					
					if ope.est_aLexterieurDe != undefined and not _poly_B.en_creux  do (
						debug"			-----> POLY_B plein et et poly_B est a l'exterieur"
						debug"			-----> on retire est_aLexterieurDe du calque." 
						_calque_A.retirer_polygone	ope.est_aLexterieurDe
						ope.est_aLexterieurDe.supprimer ()
						ope.est_aLexterieurDe= undefined
						)
						
					if not ope.a_cote do est_a_cote = false
					if ope.est_aLinterieurDe != undefined and est_aLinterieurDe==undefined do 
						est_aLinterieurDe=ope.est_aLinterieurDe 
					if ope.est_aLexterieurDe != undefined and est_aLexterieurDe==undefined do 
						est_aLexterieurDe=ope.est_aLexterieurDe
					if ope.est_aLinterieurDe != undefined and est_aLinterieurDe!=undefined do 
						if ope.est_aLinterieurDe.est_un_enfant		est_aLinterieurDe do est_aLinterieurDe=ope.est_aLinterieurDe
					if ope.est_aLexterieurDe != undefined and est_aLexterieurDe!=undefined do 
						if est_aLexterieurDe.est_un_enfant			ope.est_aLexterieurDe do 
							est_aLexterieurDe=ope.est_aLexterieurDe
						
					if ope.polys.count > 0 do (
						debug"			-----> On a un contact."
						
						local parent_A	=	poly_A.parent
						_calque_A.retirer_polygone	poly_A
						poly_A.supprimer ()
						if parent_A	!= undefined then (
							for ope_poly in ope.polys do
								parent_A.ajouter_enfant	ope_poly
						) else (
							for ope_poly in ope.polys do
								_calque_A.ajouter_polygone	ope_poly
						)
						
					)
				)
			)
			
			
			
			
			
			
			format "\n\n"
			debug"-----------  on a fait tout les poly A ----------------"
			debug"est_a_cote" var:est_a_cote
			debug"est_aLinterieurDe" var:est_aLinterieurDe
			debug"est_aLexterieurDe" var:est_aLexterieurDe
			
			if est_a_cote then (
				
					debug"			-----> On a B a coté donc on l'ajoute au calque A."
					_calque_A.ajouter_polygone	_poly_B
				
			) else (
			
			
		-- 			if est_aLexterieurDe!=undefined 
						--- B dans un truc ---------
					if est_aLinterieurDe!=undefined and est_aLexterieurDe==undefined  and est_aLinterieurDe.en_creux do (
						
						
						debug"			-----> On a B à l'interieur d'un poly de A creux "
						debug"			-----> On ajoute B dans le poly EST_ALINTERIEURDE" var:est_aLinterieurDe param:#nom
						est_aLinterieurDe.ajouter_enfant		_poly_B
					)
					
					
					
					--- B contient une branche
					if est_aLinterieurDe==undefined and est_aLexterieurDe!=undefined and _poly_B.en_creux  do   (
						
						
						debug"			-----> On a B creux à l'exterieur d'un poly de A  "
						debug"			-----> On ajoute le poly EST_ALINTERIEURDE dans B" var:est_aLinterieurDe param:#nom
						_poly_B.ajouter_enfant		est_aLexterieurDe	
						
					)
					if est_aLinterieurDe==undefined /* and est_aLexterieurDe!=undefined */ and not _poly_B.en_creux  do  (
		-- 				_poly_B.ajouter_enfant		est_aLexterieurDe
						debug"			-----> On a B à l'interieur d'aucun poly_A et B plein "
						debug"			-----> On  ajoute B 	au calque A."
						
						_calque_A.ajouter_polygone	_poly_B
		-- 				debug_calque _calque_A
					)
					
					
					--- B dans un truc  B contient une branche et b plein ( si b vide rien )
					if est_aLinterieurDe!=undefined and est_aLexterieurDe!=undefined do  (
						
						debug"			-----> On a B à l'interieur et à l'exterieur de polys de A "
						if not _poly_B.en_creux do (
							_calque_A.retirer_polygone	est_aLexterieurDe
							
							debug"				-----> On a B plein."
							if  not est_aLinterieurDe.en_creux   then 	(
								
								debug"					-----> On a EST_ALINTERIEURDE plein."
								
								_poly_B.supprimer ()
							)
							else 
							(
								debug"					-----> On a EST_ALINTERIEURDE creux."
								est_aLinterieurDe.ajouter_enfant		_poly_B					
							
							)
						)
						
					)
					
				)
				
			format "\n\n"
			debug"--------  FIN OPERER_CALQUE_POLY -------------------"
			debug_calque _calque_A
			debug"---------------------------"
			format "\n\n"
		),
		
		fn operer_calques	_calque_A 		_calque_B		operation:#union 	=(
			
			
			--- On renvois un calque	-------------
			local calque_result = this.creer_calque	nom:"RESULTAT BOOL"
			
			local 	polys_B	=	_calque_B.get_polygones ()
			
			
			--- pour chacun des polys de B ------------
			for poly_B in polys_B do
				operer_calque_poly		_calque_A		poly_B		operation:operation
				
			
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






















