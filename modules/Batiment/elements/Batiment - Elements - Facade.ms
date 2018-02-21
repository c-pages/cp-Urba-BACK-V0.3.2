


 

------------------------------------------------------------------------------------------------------------------------------------
----------------- FACADE --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
struct 	str_facade (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_facade",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
	---------- MEMBRES	--------------------------------------------------------------------------------------
	public
		---- Base	-----------
		nom 							=	"Façade",
		id								=	"#FACAD_",
		mode						=	1,					---- ( 1:repeter	2:etrier			3:centrer )	----
		
		--- Limiteurs - Murs	---
		murs							=	1,					---- ( 1:les deux	2:gouttereaux	3:pignons )	----
		
		--- Limiteurs - Etages	---
		etages_min_use		=	false,
		etages_min				= 	0,
		etages_max_use			=	false,
		etages_max			=	0,
		
		--- Limiteurs - longueurs	---
		longueur_min_use			=	false,
		longueur_min		= 	0,
		longueur_max_use	=	false,
		longueur_max		=	0,
		
		--- Sequence	---
		sequence					=	#(),
		sequence_longueur		=	0,
		
		
	---------- INTERFACE	--------------------------------------------------------------------------------------
	public
		fn initialiser 		 		=	(
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		),
		
		
		---- Composants -----------------
		fn get_composants_noms =(
			for compo in sequence collect compo.nom
		),
	/* 	fn get_composant  _posDansSequence	=(
			local result
			if   _posDansSequence<= sequence.count	do
				result = sequence[_posDansSequence]
			result
		), */
		fn update_sequence_longueur =(
			sequence_longueur		=	0
			for compo in sequence do
				sequence_longueur	+=	compo.get_longueur ()
		),
		fn get_sequence_longueur	=(
			update_sequence_longueur ()
			debug "get_sequence_longueur" var:sequence_longueur
			sequence_longueur
		),
		
		fn ajouter_composant 		_composant 	=(
			append sequence 		_composant
		),
		fn supprimer_composant 	_composant 	=(
			
		),
		fn dupliquer_composant 	_composant 	=(
			
		),
		fn cloner_composant 		_composant 	=(
			
		),
				
		---- Enregistrement / chargement	-----------------
		fn enregistrer 	_plug 	=(
			
			debug "enregistrer"
			local mgr_datas = _plug.core.get_mgrDatas ()
			
			--- on cherche s'il existe deja comme parametre -----
			local index_facade = 0
			for i = 1 to _plug.fac_ids.count do
				if _plug.fac_ids[i] == id  do index_facade = i
			
			
			--- s'il n'existe pas encore, on l'ajoute -----
			if index_facade == 0 then (
				debug "enregistrer nouvelle facade"
				append 	_plug.fac_ids 		id
				append 	_plug.fac_noms  	nom
				append    _plug.fac_modes		mode
				--- Limiteurs - Murs	---
				append 	_plug.fac_murs		murs
				
				--- Limiteurs - Etages	---
				append 	_plug.fac_etagesMin_uses 		 etages_min_use
				append 	_plug.fac_etagesMin  					etages_min
				append 	_plug.fac_etagesMax_uses 		 etages_max_use
				append 	_plug.fac_etagesMax 					etages_max
				
				--- Limiteurs - longueurs	---
				append 	_plug.fac_longueurMin_uses 	 longueur_min_use
				append 	_plug.fac_longueurMin 				longueur_min
				append 	_plug.fac_longueurMax_uses 		longueur_max_use
				append 	_plug.fac_longueurMax 			 longueur_max
				
				--- la sequence de composants	-------
				append 	_plug.fac_sequences 						( mgr_datas.array_to_string		#() )
				append 	_plug.fac_sequence_longueurs 			sequence_longueur
				
			--- s'il existe, on l'actualise -----
			) else (
				
				debug "enregistrer facade existante"
				debug "id"		var:id
				
				_plug.fac_noms[index_facade] 		=	nom				
				_plug.fac_modes[index_facade]		=	mode
				
				--- Limiteurs - Murs	---
				_plug.fac_murs[index_facade]		= murs
				
				--- Limiteurs - Etages	---
				_plug.fac_etagesMin_uses[index_facade] 		= etages_min_use
				_plug.fac_etagesMin[index_facade]  				=	etages_min
				_plug.fac_etagesMax_uses[index_facade] 		= etages_max_use
				_plug.fac_etagesMax[index_facade] 				=	etages_max
				
				--- Limiteurs - longueurs	---
				_plug.fac_longueurMin_uses[index_facade] 	= longueur_min_use
				_plug.fac_longueurMin[index_facade] 			=	longueur_min
				_plug.fac_longueurMax_uses[index_facade] 	=	longueur_max_use
				_plug.fac_longueurMax[index_facade] 			= longueur_max
				
				-- la sequence	-----
				local sequenceIDs = for compo in sequence collect	compo.id
				_plug.fac_sequences[index_facade] 						= mgr_datas.array_to_string		sequenceIDs		
				_plug.fac_sequence_longueurs[index_facade] 			= sequence_longueur		
				
				--- les composants -----
				for compo in sequence do
					compo.enregistrer _plug			
				
			)
			
			
		),
		
		fn charger	 		_plug		  =(
			
			debug "charger"
			debug "id" var:id
			
			local		mgr_composant		=	_plug.core.get_mgr_composants ()
			local 	mgr_datas 			= _plug.core.get_mgrDatas ()
			
			--- on cherche s'il existe deja comme parametre -----
			local index_facade = 0
			for i = 1 to _plug.fac_ids.count do (
				debug "id test" var:_plug.fac_ids[i]
				
				if _plug.fac_ids[i] as string == id as string do (
					index_facade = i
				)
				
			)
			
			--- on charge	------------------------------------
			if index_facade != 0 then (
				
				id 								= _plug.fac_ids[index_facade]
				nom 								= _plug.fac_noms[index_facade]
				
				mode							= _plug.fac_modes[index_facade]
				
				--- Limiteurs - Murs	---
				murs								= _plug.fac_murs[index_facade]
				
				--- Limiteurs - Etages	---
				etages_min_use			= _plug.fac_etagesMin_uses[index_facade] 
				etages_min					= _plug.fac_etagesMin[index_facade] 
				etages_max_use			= _plug.fac_etagesMax_uses[index_facade] 
				etages_max					= _plug.fac_etagesMax[index_facade] 
				
				--- Limiteurs - longueurs	---
				longueur_min_use			= _plug.fac_longueurMin_uses[index_facade] 
				longueur_min				= _plug.fac_longueurMin[index_facade] 
				longueur_max_use			= _plug.fac_longueurMax_uses[index_facade] 
				longueur_max				= _plug.fac_longueurMax[index_facade] 
				
				--- Sequence	---
				sequence_longueur		=	_plug.fac_sequence_longueurs[index_facade]
				
				
				
				sequence						=  #()
				local mgr_composants 	= _plug.core.get_mgr_composants ()
				local sequence_IDs	= mgr_datas.string_to_array		 _plug.fac_sequences[index_facade]
				for compoID in sequence_IDs do (					
					nvComposant = 		mgr_composant.charger  	compoID
					append sequence	nvComposant
				) 
				
				
				
			) else messagebox ("Erreur de chargement de facade : " + _id as string )
			
		),
		fn supprimer 	_plug	=(
			
			--- on cherche s'il existe deja comme parametre -----
			local index_facade = 0
			for i = 1 to _plug.fac_ids.count do (
				debug "id test" var:_plug.fac_ids[i]
				
				if _plug.fac_ids[i] as string == id as string do (
					index_facade = i
				)
				
			)
			
			--- on supprime	------------------------------------
			if index_facade != 0 then (
				deleteItem	_plug.fac_ids						index_facade
				deleteItem	_plug.fac_noms						index_facade    
				
				deleteItem	_plug.fac_modes					index_facade    
				
				--- Limiteurs - Murs	---
				deleteItem	_plug.fac_murs						index_facade    
				
				--- Limiteurs - Etages	---
				deleteItem	_plug.fac_etagesMin_uses		index_facade     
				deleteItem	_plug.fac_etagesMin				index_facade     
				deleteItem	_plug.fac_etagesMax_uses		index_facade     
				deleteItem	_plug.fac_etagesMax				index_facade     
				
				--- Limiteurs - longueurs	---
				deleteItem	_plug.fac_longueurMin_uses	index_facade     
				deleteItem	_plug.fac_longueurMin    		index_facade     
				deleteItem	_plug.fac_longueurMax_uses	index_facade     
				deleteItem	_plug.fac_longueurMax			index_facade     
				
				--- Sequence	---
				deleteItem	_plug.fac_sequence_longueurs	index_facade    
				deleteItem	_plug.fac_sequences					index_facade
				
			)
			
			index_facade
			
		),
	---------- EVENEMENTS	--------------------------------------------------------------------------------------
	public
		on create do initialiser ()
	
) -- fin Facade	------------





