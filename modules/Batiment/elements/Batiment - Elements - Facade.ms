(


 

------------------------------------------------------------------------------------------------------------------------------------
----------------- FACADE --------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
struct 	str_facade (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_facade",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
	---------- MEMBRES	--------------------------------------------------------------------------------------
		
	private
		mgr,
		
		m_prefix_nomParametres = "facades_",
		
	public
		---- Base	-----------
		id							=	"ID_facade_",
		nom 						=	"Façade",
		mode					=	1,					---- ( 1:repeter	2:etrier			3:centrer )	----
		
		--- Limiteurs - Murs	---
		murs						=	1,					---- ( 1:les deux	2:gouttereaux	3:pignons )	----
		
		--- Limiteurs - Etages	---
		etagesMin_use		=	false,
		etagesMin				= 	0,
		etagesMax_use		=	false,
		etagesMax				=	0,
		
		--- Limiteurs - longueurs	---
		longueurMin_use	=	false,
		longueurMin			= 	0,
		longueurMax_use	=	false,
		longueurMax			=	0,
		
		--- Sequence	---
		sequence				=	#(),
		
		
	---------- INTERFACE	--------------------------------------------------------------------------------------
	public
		fn get_typeClasse		= "facade",
-- 		fn set_manager		_mgr	= ( mgr	= _mgr ),		
-- 		fn get_manager					= mgr,
		
		---- Composants -----------------
		fn get_composant_parIDUnique		_IDUnique	=(
			
			local result = undefined
			for compo in sequence do (
				if compo.id  == _IDUnique  do
					result = compo
			)
			result
		),
		fn get_composants_noms =	for compo in sequence collect compo.nom,
		
		fn ajouter_composant 		_composant 	position:(sequence.count+1)  =(
			if position == 0 do position = sequence.count+1
			insertItem _composant		sequence 				position
		),
		fn supprimer_composant 	_index 	=		deleteItem sequence	_index,
		fn instancier_composant 	_index 	=(
			debug "sequence[_index]" var:sequence[_index]
			local compoInstance =  sequence[_index]
			ajouter_composant  compoInstance 	position:( _index+1)
			debug "compoInstance" var:compoInstance
			debug "sequence" var:sequence
			compoInstance
		),
		
		fn composant_monter 		_index =(
			local compoTemp = sequence[_index]
			deleteItem sequence		_index
			insertItem compoTemp		sequence 				(_index-1)			
		),
		fn composant_descendre 	_index =(
			local compoTemp = sequence[_index]
			deleteItem sequence		_index
			insertItem compoTemp		sequence 				(_index+1)			
		),
		
		/* 
		--- parametres -------------------
		fn enregistrer			= mgr.enregistrer_parametres	this,
		fn charger					= mgr.charger_parametres			this,
			
		*/
		
		
		--sequence ----------		
		fn get_sequence_longueur	=(
			local sequence_longueur		=	0
			for compo in sequence do
				sequence_longueur	+=	compo.get_longueur ()
			sequence_longueur
		),
		
		
		
			
		
		/* 
		
		
		------ parametres -----------
		fn enregistrer 	_plug 	=(
			
			-- on check si l'element est deja present ou a ajouter ------------
			local index_param	= _plug.core.get_element_index_parID 	id
			
			--- on parse tout les parametres à enregistrer	-----------
			for prop_nom in getPropNames	this do (
				
				--- en fonction de la classe, on fait differents trucs --------
				local val
				case prop_nom of (
					#sequence: 	(	
											val =#()
											for elem in sequence do (
												elem.enregistrer ()
												append val elem.id
											)
											val = ( _plug.core.get_mgr_datas () ).array_to_string		val
						)
					default: 		val = getProperty	this  prop_nom					
				) -- fin case
				
				-- on enregistre le parametre sur le plug ----------
				local nom_dans_parametres = m_prefix_nomParametres + prop_nom
				local parametre = getproperty   _plug  	nom_dans_parametres
				if index_param == 0 then 
					append	parametre	val
				else 
					parametre[ index_param ] = 	val
				
			)-- fin for --------
		),
		fn charger 	_plug	=(
			
		),
		
		
		 */
		
		
		
		fn initialiser 		 		=	(
			---- id unique ----
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		),
		
	---------- EVENEMENTS	--------------------------------------------------------------------------------------
	public
		on create do initialiser ()
	
) -- fin Facade	------------



)

