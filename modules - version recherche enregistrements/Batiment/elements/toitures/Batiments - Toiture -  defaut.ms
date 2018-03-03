

	
( ----	FileIn ----
	
	




--- parametres de base	-----------------------------
toiture_nom 	= "- Sans -"	
toiture_type	=	#sans

--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 _composant		= (
		
		local ptr_geo 				= 	_plug.core.get_geo ()
		local face = ptr_geo.face		pts_accroches						matID:#mur
		ptr_geo.extruder	face	_plug.const_dalle_epaisseur
	
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  	nom:toiture_nom	type:toiture_type	params:undefined	dialog:undefined	fnConstruire:toiture_fnConstruire

	
	
	
) ----	FileIn ----
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	