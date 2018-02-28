/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	MANAGER de PRESETS générique
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
########################################################################################################################*/
-- (
-- 	
-- include "$userScripts\cp - GLOBAL\Debuger et ecrire.ms"


struct str_presets_batiment (
		
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="presetsMGR",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		------------ MEMBRES	----------------------------------------------------------------------------------
	public
		fichier_dossier 			= "",		--- a initialiser a la creation ---------
		fichier_categorie		= "",		--- a initialiser a la creation ---------
		fichier_extension		= "",		--- a initialiser a la creation ---------
		
	private
		fichier_type 					= fichier_categorie + "(*." + fichier_extension + ")|*." + fichier_extension + "|All|*.*|",
		
		---- convertisseur Parametres to String  -------------
		mgr_datas 					= str_datasToString 	m_prt:this,
		
		separateur_params 		="¤",
		separateur_mutation 		= "µ",
		separateur_items 			= "`",
		
		------------ FOPNCTIONS	----------------------------------------------------------------------------------
	public
		
		fn lire_fichier 			_fichier = (
			
			local stream 	= openFile _fichier mode:"r"
			local datas 	= readLine  stream
			
			close  stream
			datas
		),
		fn get_params 			_this =(
			
			local txtResult 					= ""
			local parametres_noms 		=  getpropNames 	_this
			for param in parametres_noms where param  != #Editable_Poly and param != #surface_node		do (
				local prop = ( getProperty  _this 	param )
				local type = classof prop
				
				case type of (
					MAXScriptFunction:	()
					ArrayParameter: (
						local tabString = ""
						for item in prop do
							tabString += item as string + separateur_items
						txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
					
					)
					default:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
				)
				
				
			
			)
			txtResult
		),
		fn set_params 		_this		_datas =(
			
			local params = filterString _datas		separateur_params
			for paramStrg in params do (
				local param = filterString paramStrg		separateur_mutation
				
				local nomProp 	= param[1] as name
				local prop 		= ( getProperty  _this 	nomProp )
				local type 		= classof prop
				
				case type of (
					MAXScriptFunction:	()
					string:						( 
						if param[2] == undefined do param[2]  = ""
						setproperty 	_this 	nomProp	param[2]
					)
					ArrayParameter: (
						if param[2] != undefined then (
							local paramTab = filterString 	param[2]		separateur_items
							if paramTab.count > 0 then (
								
								try ( 
									local param_exe = execute paramTab[1] 
									if param_exe != undefined then
										setproperty 	_this 	nomProp		( for param in  paramTab collect (execute param ) )
									else setproperty 	_this 	nomProp		( paramTab ) 
								) catch setproperty 	_this 	nomProp		( paramTab ) 
								
							)	else 	setproperty 	_this 	nomProp		#()
						) else 
							setproperty 	_this 	nomProp		#()
					)
					default:						(
						setproperty 	_this 	nomProp	(execute param[2])
					)
				)
			)
		),
	public
		fn charger  	_this 	= (
			
			local fichierCible 	=	getopenFileName 		caption:				"Charger" 				\
																			filename:			fichier_dossier 		\
																			types:				fichier_type			\
																			historyCategory:	fichier_categorie
			if fichierCible != undefined do (
				local datas = lire_fichier 	fichierCible
				set_params 	_this 	datas
			)
		),
		fn enregistrer 		_this	=(
			if not doesFileExist fichier_dossier do makeDir  fichier_dossier
			local fichierCible 	=	getSaveFileName 	caption:				"Enregistrer" 			\
																		filename:				fichier_dossier 				\
																		types:					fichier_type					\
																		historyCategory:	fichier_categorie
			
			if fichierCible != undefined do (
				
				---- creation du fichier----------
				local stream	
				if doesFileExist fichierCible do deleteFile  fichierCible
				stream	= createFile fichierCible
				close stream
				
				---- ecriture du fichier-----------
				stream = openFile fichierCible 	mode:"a"		
				local txt = get_params		_this 
				format "%" 	txt 					to:stream
				close stream
			)
		), 
		
		fn copier _this =(
			urba_clipboard_batiment = get_params		_this 
		),
		
		fn coller 	_this =(
				set_params 	_this 	urba_clipboard_batiment
		)
		
)	--- fin struct ------









