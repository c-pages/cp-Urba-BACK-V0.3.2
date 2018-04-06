



struct str_datasToString (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = false,
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:"urba | str_datasToString"	catch (),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	public
		m_prt,
	
	private
		separateur_params 			= "§",
		separateur_mutation 			= "¨",
		separateur_mutationTab 	= "£",
		separateur_items 				= "^",
	
	public
		fn toString		_tab	=(
			local tabString = ""
			for item in _tab do (
				debug "toString" var:(classof item)
				case classof item  of (
					
					string:		tabString += item 	as string + separateur_items
					Integer:		tabString += item 	as string + separateur_items
					Float:		tabString += item 	as string + separateur_items
					Point3:		tabString += item 	as string + separateur_items
					Array:		tabString += item 	as string + separateur_items
					
					---- les reste doit etre nos struct a nous ... -------
					default:		tabString += item 	as string + separateur_items
					
				)
			)
			tabString
		),
		fn toArray		_string	=(
			
			local tabResult = #()
			local items 	= filterString 	_string 		separateur_items
			
			for item in items do (
				
				local data_exe 	
				try data_exe = execute item catch ()
				--------------- string ---------------
				if data_exe 		== undefined then 
					append tabResult ( item )
				else 
					append tabResult 	data_exe
				/* --------------- un objet ---------------
				else	if classof data_exe == Name then (
					local elemTmp =  ( m_prt.get_parametre	  item 	)						
					--- un id (name)------
					if elemTmp == undefined do	elemTmp = item
					append tabResult		elemTmp
				--------------- Nombres ---------------		
				) else 	append tabResult 	( data_exe)
				*/
			)
			tabResult
		),
		
	public
		fn get_datas_string 		_element	=(
			
			local txtResult = ""
			
			if _element != undefined do (
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
							local tabString = toString		prop
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
			)
			txtResult
			
		),
		fn set_datas_string 		_datas_string 		_element 		=(
							debug "<<<<<<<<<<<<		set_datas_string	>>>>>>>>>>><>>><"
			if _datas_string != undefined then (
				local datasTab 	= filterString 	_datas_string 		separateur_params
				for datas in datasTab do (
					local dataTab		= filterString datas 	separateur_mutation
					local propNom 	= dataTab[1]
					debug "<<<<<<< propNom >>>>>>>" var:propNom
					local typeProp 	
					if  hasProperty _element propNom do
						typeProp 	= classof ( getProperty _element propNom  )
					debug "<<<<<<< typeProp >>>>>>>" var:typeProp
					case typeProp of (
						--- les trucs qu'on zappe ------
						MAXScriptFunction:	()
						RolloutClass:()
						--- les trucs qu'on prend en compte	------
						string:		(
							debug "string"
								local data =   dataTab[2]
								if data   == undefined do data =""
								setProperty _element propNom data
							debug "data" var:data
						)
						array: (
							debug "array"
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
							debug "data" var:tabResult
							)
						)
						default:						(
							debug "default" 
							/* 
							if dataTab[2] != undefined do  (							
								local data 		
								if execute dataTab[2]	 != undefined then
									data = execute dataTab[2]	
								else if	dataTab[2] == "undefined" then
									data = undefined
								else
									data = dataTab[2]	
								setProperty _element propNom data
								debug "data" var:data 
							*/
							if  hasProperty _element propNom do
								if dataTab[2] != undefined do  (						
									local data 		
									if execute dataTab[2]	 != undefined then
										try data = execute dataTab[2]	catch data = dataTab[2]	
									else
										data = dataTab[2]	
									
									if	data== "undefined" then
										data = undefined
									
									setProperty _element propNom data
									debug "data" var:data
								)						
						) -- fin default 
					) --- fin case ----------
				)
			)
			_element = undefined
		)

)









