


 

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
	public
		---- Base	-----------
		nom 						=	"Façade",
		id							=	"",
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
		fn initialiser 		 		=	(
			if id == "" do (
				id = "Facade_"
				for i= 1 to 10 do id +=  ( random 0 9 ) as string
			)
		),
		
		
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
		
		
		--sequence ----------		
		fn get_sequence_longueur	=(
			local sequence_longueur		=	0
			for compo in sequence do
				sequence_longueur	+=	compo.get_longueur ()
			sequence_longueur
		),
		
	---------- EVENEMENTS	--------------------------------------------------------------------------------------
	public
		on create do initialiser ()
	
) -- fin Facade	------------





