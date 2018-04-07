

---- ecouteurs terrain ------------------
TERRAIN_ECOUTEUR_topo 		= undefined
TERRAIN_ECOUTEUR_transf 	= undefined
gc light:true
global TERRAIN_ECOUTEUR_topo, TERRAIN_ECOUTEUR_transf
---- ecouteurs terrain ------------------




plugin geometry  Urba_terrain
name:"Terrain"
classID:#(528514,174852)
category:"CP | Urba"
invisible:false
extends:editable_poly 
replaceUI:true 
version:0
(


		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		fn debug 	_txt  var:	 param:    =	
		try if true  do ::debuger 	_txt	prefix:"urba | Urba_terrain"	  	var:var	 param:param	
		catch ()
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------


		--------------- Membres  ----------------------------------------------------------------------------------------------------------------------
		----- la structure centrale du plugin -------------------
		include	 "$userScripts\\cp-Urba\\modules\\Terrain\\Terrain - core.ms" 
		local	core	=	str_terrain_node_core ()
		
		----  Actualisations -----------------
		fn actualiser 	=	core.actualiser ()
		fn initialiser 	=	core.initialiser	this
		
		----  Divers -----------------
		fn aCommeContour	_node 	=	findItem this.contours_nodes	_node != 0
		fn aCommeRelief		_node 	=	findItem this.reliefs_nodes		_node != 0
		fn set_transform 		_mtrx		=	this.transformation = _mtrx
		
		
		
		
		
		----  Mutations -----------------
		fn ajouter_relief			_node 	aActualiser:true	=(
			if appendIfUnique this.reliefs_nodes	 _node and aActualiser do (
				this.rollout_global.actualiser ()
				actualiser ()
			)
		)
		fn ajouter_contour		_node 	aActualiser:true	=(
			if appendIfUnique this.contours_nodes 	_node and aActualiser  do (
				this.rollout_global.actualiser ()
				actualiser ()
			)
		)
		
		
	---------------- Parameters et rollouts -------------------------------------------------------------------------------------------------------------
		include	 "$userScripts\\cp-Urba\\modules\\Terrain\\divers\\Terrain - Parameters et rollouts.ms" 
		include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - rollout - A propos.ms" 
		
		
	--------------- Creation  ----------------------------------------------------------------------------------------------------------------------
	tool create (
		on mousePoint click do	(
			nodeTM.translation =	mondePoint--- [0,0,0] 
			set_transform		nodeTM
			actualiser ()
			initialiser ()
			#stop
		)

	)

		
		
	--------------- Evenements  ----------------------------------------------------------------------------------------------------------------------
	on load 						do 	(
		debug "load du plugin"

		initialiser ()
	)
	on clone 	_original 	do (
		initialiser ()
	)
	on create do (
		
		debug "creation du plugin"
		
		--- on verifie les noueds présent pour adapter la grille monde-----
		local terrains_presents = for nd_terrain in geometry where classof nd_terrain == Urba_terrain collect nd_terrain
		if terrains_presents.count>0 do (
			grille_monde_resolution	=	terrains_presents[1].grille_monde_resolution
			grille_monde_position	=	terrains_presents[1].grille_monde_position
		)
		
		
		initialiser ()
	)
	on update do	(
		debug "update du plugin"
-- 		initialiser ()
	)

)














