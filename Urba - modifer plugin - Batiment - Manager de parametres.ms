

struct str_datasToString (
	
		m_prt,
		
	private
		separateur_params 			="§",
		separateur_mutation 		= "¨",
		separateur_mutationTab 	= "£",
		separateur_items 			= "^",
	
	
	private
		fn array_to_string		_tab	=(
			local tabString = ""
			for item in _tab do (
				case classof item  of (
					string:	tabString += item 		as string + separateur_items
					Integer:	tabString += item 		as string + separateur_items
					Float:	tabString += item 		as string + separateur_items
					Point3:	tabString += item 		as string + separateur_items
					Array:	tabString += item 		as string + separateur_items
					
					---- les reste doit etre nos struct a nous ... -------
					default:	tabString += item.id 	as string + separateur_items
				)
			)
			tabString
		),
		fn string_to_array		_string	=(
			
			local tabResult = #()
			local items 	= filterString 	_string 		separateur_items
			
			for item in items do (
				local data_exe 	= execute item
				--------------- string ---------------
				if data_exe 		== undefined then 
					append tabResult ( item )
				--------------- un objet ---------------
				else	if classof data_exe == Name then (
					local elemTmp =  ( m_prt.get_parametre	  item 	)						
					--- un id (name)------
					if elemTmp == undefined do	elemTmp = item
					append tabResult		elemTmp
				--------------- Nombres ---------------		
				) else 	append tabResult 	( data_exe)
				
			)
			tabResult
		),
		
	public
		fn get_datas_string 		_element	=(
			local txtResult = ""
			local propNames = getPropNames _element
			for param in propNames do (
				local prop = ( getProperty  _element 	param )
				local type = classof prop
				case type of (
					--- les trucs qu'on zappe ------
					MAXScriptFunction:	()
					RolloutClass:()
					--- les trucs qu'on prend en compte	------
					array: (
						local tabString = array_to_string		prop
						txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
					)
					Name:		(
						txtResult+=  param as string  + separateur_mutation	+	"#" + prop as string  + separateur_params
					)
					default:						(
							txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
				) -- fin scase --
				
			)
			txtResult
			
		),
		fn set_datas_string 		_datas_string 		_element 		=(
			local datasTab 	= filterString 	_datas_string 		separateur_params
			for datas in datasTab do (
				local dataTab		= filterString datas 	separateur_mutation
				local propNom 	= dataTab[1]
				local typeProp 	= classof ( getProperty _element propNom  )
				case typeProp of (
					--- les trucs qu'on zappe ------
					MAXScriptFunction:	()
					RolloutClass:()
					--- les trucs qu'on prend en compte	------
					string:		(
							local data =   dataTab[2]
							if data   == undefined do data =""
							setProperty _element propNom data
					)
					array: (
						if dataTab.count >1 do (
							local datas_liste  = filterString	dataTab[2] 	separateur_items
							local tabResult =#()
							for data in datas_liste do (
								local data_exe 	= execute data
								--------------- string ---------------
								if data_exe 		== undefined then 	append tabResult ( data)
								--------------- un objet ---------------
								else	if classof data_exe == Name then (	
									local elemTmp =  ( m_prt.get_parametre	  data 	)	
									--- un id (name)------
									if elemTmp == undefined do	elemTmp = data
									append tabResult		elemTmp
								--------------- Nombres ---------------	
								) else 	append tabResult 	( data_exe)
							)
							setProperty _element 	propNom 	tabResult
						)
					)
					default:						(
						if dataTab[2] != undefined do  (							
							local data = execute dataTab[2]							
							setProperty _element propNom data
						)						
					)
				)
			)
			_element
		)

)



struct str_mgr_arrayParametres (
	
	---- Membres ----------------------------------------------------------------------------------------------------------------
	public
		m_this,
		
	private
		m_items	=	#(),
		
		
		mgr_datas 				= str_datasToString 	m_prt:this,
	/* 	m_presets 					= str_presets_batiment 	fichier_dossier:			( getDir #userScripts	 + "\\cp-Urba\\lib\\façades\\"		)	\
																			fichier_categorie:			"Urba - Façades"	\
																			fichier_extension:			"fcd"	\
																			params_aEnregistrer:	m_paramsNoms, 		*/
	---- Fonctions ----------------------------------------------------------------------------------------------------------------
	private
		---- Parametres blocks ----
		fn lire_parametres 		=(),
		fn ecrire_parametres 	=(),
		
	---- Creations -------------------------------------------
	public
		---- Creation/Suppression ----
		creer				=	0,	--	str_constructeur_composants 	m_this:m_this,
		fn supprimer 	=	(),
		
		---- Accessions ---
		fn get  _id =(
			
			local result
			for item in m_items do
				if item.id == _id do result = compo
			result
			
		),
		
		---- Parametres Block ----
		fn lire			=	lire_parametres(),
		fn ecrire			=	ecrire_parametres()
		
)	--	fin manager de composants ------

struct str_batiment_core (
	
	private
		facades 		= str_mgr_arrayParametres (),
		composants	= str_mgr_arrayParametres (),
		toitures			= str_mgr_arrayParametres (),
	
	public	
		fn lire 			=(),
		fn ecrire		=()
	
)












