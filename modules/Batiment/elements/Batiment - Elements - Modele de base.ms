	
--- la structure mere	du composant	---------
struct	str_modelBase (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_modelBase",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	
	public
		titre ="",
		toolTip ="",
		type ,
		
		params,
		dialog,
		fnConstruire,
		
		invisible = false,
		
	public
		fn est_editable = not invisible and params != undefined ,
		fn initialiser 	_nvComposant	=(
			debug "initialiser"
			debug "type" var:type
			_nvComposant.initialiser			type		titre
			
			_nvComposant.set_dialog			dialog
			_nvComposant.set_params	 		( copy params )
			_nvComposant.set_construire 	fnConstruire
			
			_nvComposant
			
		)
		
)