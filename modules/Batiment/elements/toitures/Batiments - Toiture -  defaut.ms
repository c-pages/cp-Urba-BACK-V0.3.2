



--- parametres de base	-----------------------------
toiture_titre 	= "- Sans -"	
toiture_type	=	#sans

--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 _composant		= (
		
		local ptr_geo 				= 	_plug.core.get_geo ()
		ptr_geo.face		pts_accroches						matID:#mur
		
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
str_modelBase 	titre:toiture_titre	type:toiture_type	params:undefined	dialog:undefined	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	