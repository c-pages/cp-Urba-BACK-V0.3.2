(
	--- la structure mere	du composant	---------
	struct	str_modelBase (
		
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		private
			m_debug = false,
			m_dbgPrefix ="urba | str_modelBase",
			fn debug 	_txt  var:	 param:    =(
				try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
				catch ()
			),
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		
		public
			nom ="",
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
				_nvComposant.initialiser			type		nom
				
				_nvComposant.set_dialog			dialog
				_nvComposant.set_params	 		params
				_nvComposant.set_construire 	fnConstruire
				
				_nvComposant
				
			)
			
	)
	str_modelBase
)