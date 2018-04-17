
include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - outils - shape.ms" 


---- polygone de la hierarchie ----------
struct str_polygone (
	--------- membres ------------------------------------------------------------------
	private
		
		
		
		mgr_shp				=	str_outils_shape (),
		pts 					=	#(),
		
		dist_auParent		=	0,
	public
		nom 					=	"",
		
		en_creux			=	true	,		---- si le polygone est  creux ou  plein
		
		
	public
		parent			=	undefined,
		enfants			=	#(),
		calque			,
		
		
	--------- Fonctions ------------------------------------------------------------------
	public					
		
		
		fn maj_enCreux			=(
			if parent != undefined then
				en_creux = not parent.en_creux
			else en_creux = false
			
			for enfant in enfants do
				enfant.maj_enCreux ()
		),
		
		fn est_enCreux	= en_creux,
		fn inverser_enCreux =	(
			en_creux = not en_creux
			for enfant in enfants do
				enfant.maj_enCreux ()
		),
		fn changer_sens =(
			mgr_shp.debug "changer_sens" var:nom
			pts = mgr_shp.changer_sens pts
			),
		
		fn set_parent			_polygoneParent 	= (
			if parent != undefined and parent  != _polygoneParent do
				parent.retirer_enfant	this
			
			parent  = _polygoneParent
			maj_enCreux ()
		),
		fn ajouter_enfant 	_neudEnfant 	distance_toParent:	= (
			
			--- le placer dans l'ordre du plus proche au plus loin ---------------
			local distTest	=	distance_toParent	--struct_prt.get_distance_shapes 	pts	_neudEnfant.pts
			local trouve = false
			if distTest != unsupplied and distTest != undefined do (
				
				local	dist_au_nvl_enfant	 		= distTest.distance
				
				_neudEnfant.dist_auParent 		= dist_au_nvl_enfant
				
				local id_cible = 0
				local i = 1
				while i <= enfants.count and not trouve do (
					local enfant = enfants[i]
					if dist_au_nvl_enfant <	 enfant.dist_auParent do (
						insertItem	_neudEnfant 	enfants	i
						trouve = true
					)
					i += 1
				)
			)
			if not trouve do
				append enfants  _neudEnfant
			if _neudEnfant.calque != undefined do
				_neudEnfant.calque.retirer_polygone	_neudEnfant
			_neudEnfant.set_parent  	this
		),
		fn retirer_enfant		_enfant 		=(
			local id_enfant = findItem enfants	_enfant
			if id_enfant != 0 do
				deleteItem enfants id_enfant
		),
		fn set_pts  			_pts			= pts =  for pt in _pts collect pt,
		
		
		fn get_pts  			= for pt in pts collect pt,
		fn get_descendance	=(
			local result = #()
			for enfant in enfants do (
				append result enfant
				result		+=	enfant.get_descendance()
			)
			result
		),
		
		fn supprimer			=(
			if parent	!=	undefined do
				parent.retirer_enfant	this
		),
		fn set_calque 		_calque =(
			if calque != undefined and calque  != _calque do
				calque.retirer_polygone	this
			
			calque  = _calque
			maj_enCreux ()
		),
		fn initialiser 	_ptr_shp = mgr_shp = _ptr_shp
		
)--- fin du struct----














struct str_mgr_polygones (
	
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	private
		m_debug	=	true,
		fn debug 	_txt  var:	 param:    =	try if m_debug  do ::debuger 	_txt	prefix:"Terrain | polys"	  	var:var	 param:param		catch (),
	------------ DEBUG	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		mgr_shp	=	str_outils_shape (),
	
	
	
	------------ Fonstions internes 	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	
	/* 
	
	fn inserer_dsHierarchie		_poly_aInserer		_polys_hierarchie	=(
		
			local a_ete_integre			=	false		
			local	enfants_hierarchie 	= 	for poly in _polys_hierarchie.enfants collect poly
			local i = 1
			while	 i <= enfants_ndA.count and not a_ete_integre	do (
				local ndA_enfant	=	enfants_ndA[ i ]
-- 								for nd_calque in noeuds	do (
				local integration_reussie	=	integrer_noeud		ndA_enfant	_poly_aInserer
				if integration_reussie do a_ete_integre = true
				i += 1
			)
			
			if not a_ete_integre do
				_poly_dest.ajouter_enfant 	_poly_aInserer
	), */
	
	------------ Interface	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	public	
		fn inserer_poly_ds_poly		_poly_aInserer		_poly_dest 		=(
			
			local pos_relative = mgr_shp.get_positionRelative_shapes 		(_poly_dest.get_pts ())		(_poly_aInserer.get_pts ())
			case pos_relative[1] of (
				
				#aCoté:	 		result = false
				
				#interieur:		 (
						------ on regarde s'il rentre dans les enfants du poly destination	--------------	
						local a_ete_integre	=	false		
						local	enfants_dest = 	for enfant in _poly_dest.enfants collect enfant
						local i = 1
						while	 i <= enfants_dest.count and not a_ete_integre	do (
							local enfant_dest			=	enfants_dest[ i ]
							local integration_reussie	=	inserer_poly_ds_poly		_poly_aInserer			enfant_dest
							if integration_reussie do a_ete_integre = true
							i += 1
						)
						
						----- sinon on l'ajoute aux enfants du poly dest ----------------
						if not a_ete_integre do
							_poly_dest.ajouter_enfant 		_poly_aInserer
							
						result = true
						
					) ---- fin #interieur	----------
					
					
					
				#exterieur:		(
					
						if _poly_aInserer.parent != undefined then (
							local parent_B = _poly_aInserer.parent 
							_poly_aInserer.ajouter_enfant 	_poly_dest
							append 	_poly_dest.calque.noeuds	_poly_aInserer
-- 							parent_B.ajouter_enfant	_poly_dest
						) else (
							_poly_aInserer.ajouter_enfant 	_poly_dest
							append 	_poly_dest.calque.noeuds	_poly_aInserer
						)
						result = true
						
					) ---- fin #exterieur	----------
				
					
					
				#seCroisent:		(
				
						debug "###########################################################"
						debug "#############################################################"
						debug "#########											#########"
						debug "#########	/!\	hmm! probleme, il ne devrait y 		#########"
						debug "#########	avoir d'intersection de noeuds ici 		#########"
						debug "#########											#########"
						debug "#############################################################"
						result = #PROBLEME
					result = true
					) ---- fin #seCroisent	----------
			)
			
			result
		),
		fn creer_polygone 	pts: 	nom:		=(
			
			----	renvoie un nouveau polygonne	----
			local nv_polygone = str_polygone	()		----	struct_prt:this
			
			nv_polygone.initialiser	this
			if pts != unsupplied and pts != undefined do (
				if not mgr_shp.est_sensPositif 	pts do 
					pts = mgr_shp.changer_sens pts
				
				nv_polygone.set_pts 	pts
			)
			if nom != unsupplied do (
				nv_polygone.nom= nom
				if nom != "root" and nom != "temporaire" do
					nv_polygone.en_creux = false
				
			)
			
			nv_polygone
			
		),
		fn creer_fromShape		_shape_node	=(
			
			debug "creer_fromShape()"
			--- on renvoie une liste de polygones --------
			local result_polys	=	#()
			
			--- on recupere nos tracés à partir des splines du shape_node
			local pts_shps 	= 	mgr_shp.interpoler_shape		_shape_node
			
			
			--- et on créé un polygone par tracé		-------------
			local i = 0
			for pts_shp in pts_shps do (
				--- le nouveau polygone ---
				local nom_poly 	=  _shape_node.name	+ "_" + (  i+=1 ) as string
				local nv_poly 		= creer_polygone		pts:pts_shp	nom:nom_poly
				append result_polys nv_poly
-- 				
-- 				--- on l'ajoute à la hierarchie resultante --------------
-- 				inserer	 result_polys 	nv_poly
			)
			
			result_polys
		),
		fn calculer_booleen		_poly_1		_poly_2	operation:#union	=(
			----	renvoie une liste de polygonnes	----
			
		)
		
		
		

	
) ------ fin struct mgr polys ---------------------------






























