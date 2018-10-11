

include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\recherche - simpleObject - mgr - Construction base.ms"

include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Fix.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Ouvrant.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Porte.ms"


struct str_contruction_menuiseries	(
		
		mgr_contr_base	=	str_contruction_base (),
		
		
		
		fn transform_vertex		_mesh	id_debut:			id_fin:		transf:	= mgr_contr_base.transform_vertex		_mesh	id_debut:id_debut			id_fin:id_fin		transf:transf,
		
		
		
		fn creer_menuiserie 		_type		long:		ht:		prof:		 epais:		matId_menuis:		matId_vitrage:	=(
			
			---- on creer le sous objet model ---------------------
			local nvl_menuiserie
			case _type of (
				#fix:				nvl_menuiserie = createInstance  urba_menuis_fixe
				#ouvrant:		nvl_menuiserie = createInstance  urba_menuis_ouvrant
				#porte:			nvl_menuiserie = createInstance  urba_menuis_porte
			)
			nvl_menuiserie.m_parent = this
			
			
			---- on rempli les params----------------
			if long 				!= unsupplied do		nvl_menuiserie.longueur 			= long
			if ht 					!= unsupplied do		nvl_menuiserie.hauteur 				= ht
			if prof 				!= unsupplied do		nvl_menuiserie.profondeur 			= prof
			if epais				!= unsupplied do		nvl_menuiserie.menuis_epaisseur 			= epais
			if matId_menuis	!= unsupplied do		nvl_menuiserie.matId_menuis 		= matId_menuis
			if matId_vitrage	!= unsupplied do		nvl_menuiserie.matId_vitrage 	= matId_vitrage
			
			nvl_menuiserie
			
		),	
		
		fn ajouter_menuiserie 		_mesh	_type		long:		ht:		prof:	 epais:		transf:		matId_menuis:		matId_vitrage:	=(
			
			---- on creer le sous objet model ---------------------			
			local nvl_menuiserie	=	creer_menuiserie 		_type		long:long		ht:ht		prof:prof	 epais:epais		matId_menuis:matId_menuis		matId_vitrage:matId_vitrage
			
			--- on stock l'id du vertex pour pouvoir deplacer les point si besoin ----------------
			local id_vertex_debut = ( meshop.getNumVerts _mesh + 1 )
			
			--- on l'ajoute a notre _mesh ----------
			meshop.attach	_mesh		nvl_menuiserie.mesh
			
			----- et on place la menuiserie si besoin ---------------
			if transf		!= unsupplied do	
				transform_vertex		_mesh		id_debut:	id_vertex_debut	\
															id_fin:		(meshop.getNumVerts _mesh)	\
															transf:		transf
			
			nvl_menuiserie
			
		)
	
	
	
)




