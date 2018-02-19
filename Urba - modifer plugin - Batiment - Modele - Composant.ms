	
--- la structure mere	du composant	---------
struct	str_compo_mere (
	
	titre ="",
	toolTip ="",
	type ,
	
	params,
	dialog,
	fnConstruire,
	
	public
		
		fn initialiser 	_nvComposant	=(
			
			_nvComposant.initialiser			type		titre
			
			_nvComposant.set_dialog			dialog
			_nvComposant.set_params	 		( copy params )
			_nvComposant.set_construire 	fnConstruire
			format "PARAMETRE A INITIALISATION : %\n" params
			_nvComposant
			
		)
		
)