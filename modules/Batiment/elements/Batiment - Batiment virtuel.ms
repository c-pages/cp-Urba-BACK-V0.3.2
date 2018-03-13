


struct str_batVirt (
	
	---- Membres	---------------------------------
	public
	--- etages ---
		etages_nbre					= 1,
		etages_hauteur_global	= 250,
		
		etages_min					=#(),
		etages_max_use			=#(),
		etages_max					=#(),
		etages_hauteurs			=#(),
		
	--- facades ---
		facades							=#(),
	
	--- toiture ---
		toiture							= undefined,
	
	--- divers ---------
		decallage_z 					= 0,
		interieur_use					= false,
	
	
		
	---- Fonctions -----------------------------------
	---- etages -------
		fn ajouter_etage =(
			append 	etages_min			0
			append 	etages_max_use	false
			append 	etages_max			1
			append 	etages_hauteurs	250.
-- 			format "***  ajouter_etage  **************** \n"
-- 			format "***  etages_min : %\n" etages_min
-- 			format "***  etages_max_use : %\n" etages_max_use
-- 			format "***  etages_max : %\n" etages_max
-- 			format "***  etages_hauteurs : %\n" etages_hauteurs
		),
		fn supprimer_etage 		_index	=(
			deleteItem 	etages_min			_index
			deleteItem 	etages_max_use	_index
			deleteItem 	etages_max			_index
			deleteItem 	etages_hauteurs	_index
		),
		fn set_etage 	_index		_etages_min			_etages_max_use		_etages_max		_etages_hauteurs = (
			etages_min[ _index ]			=	_etages_min
			etages_max_use[ _index ]	=	_etages_max_use
			etages_max[ _index ]		=	_etages_max
			etages_hauteurs[ _index ]	=	_etages_hauteurs
-- 			format "***  set_etage  **************** \n"
-- 			format "***  etages_min : %\n" etages_min
-- 			format "***  etages_max_use : %\n" etages_max_use
-- 			format "***  etages_max : %\n" etages_max
-- 			format "***  etages_hauteurs : %\n" etages_hauteurs
		),
		
		fn get_etage_ht 	_num_etage =(
			local result	=	etages_hauteur_global
			local i =1
			local trouve = false
			while i <= etages_min.count and not trouve	do (
				if _num_etage == etages_min[i] then (
					result		= etages_hauteurs[ i ]	
					trouve		= true
				) else 	if _num_etage > etages_min[i] and etages_max_use[i] do (
					
					if   _num_etage <= etages_max[i] do (
						result = etages_hauteurs[ i ]	
						trouve = true
					)
					
				)
				i+= 1
			)
			result
		),
		fn get_toiture = toiture,
		fn get_facades = facades,
		
	---- données -------
	public
		fn charger		_node 	=(
			
			etages_nbre					=	copy	_node.etages_nbre
			etages_hauteur_global	=	copy	_node.etages_hauteur_global
			
			etages_min					=	for val in _node.etages_min	collect copy val	
			etages_max_use			=	for val in _node.etages_max_use	collect copy val		
			etages_max					=	for val in _node.etages_max	collect copy val		
			etages_hauteurs			=	for val in _node.etages_hauteurs	collect copy val	
			
			facades							=	_node.core.get_facades ()
			
			toiture 							= _node.core.get_toiture ()
			
			decallage_z 					= copy	_node.decallage_z
			interieur_use					= copy	_node.interieur_use
			
		),
		fn enregistrer 	_node	=(
			
-- 			format "-----  enregistrer -------\n"
-- 			format "-----  etages_min : %\n" etages_min
-- 			format "-----  etages_max_use : %\n" etages_max_use
-- 			format "-----  etages_max : %\n" etages_max
-- 			format "-----  etages_hauteurs : %\n" etages_hauteurs
			
			_node.etages_nbre					=	etages_nbre
			_node.etages_hauteur_global		= etages_hauteur_global
			
			_node.etages_min 					= for val in etages_min	collect val
			_node.etages_max_use				= etages_max_use
			_node.etages_max						= etages_max
			_node.etages_hauteurs				= etages_hauteurs
			
			for fcd in facades do _node.core.enregistrer_element	fcd
			
			_node.core.enregistrer_element	toiture			
			
			_node.decallage_z 		=	decallage_z 
			_node.interieur_use		=	interieur_use
			
		)
	
)




/* 
bat1 = str_batVirt ()

bat1.charger_from $

 */





