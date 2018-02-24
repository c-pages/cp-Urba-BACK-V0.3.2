	
--- la structure mere	du composant	---------
struct	str_modelBase (
	
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
			
			_nvComposant.initialiser			type		titre
			
			_nvComposant.set_dialog			dialog
			_nvComposant.set_params	 		( copy params )
			_nvComposant.set_construire 	fnConstruire
			
			_nvComposant
			
		)
		
)