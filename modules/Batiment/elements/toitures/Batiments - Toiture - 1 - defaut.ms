

	
( ----	FileIn ----
	
	




--- parametres de base	-----------------------------
toiture_nom 	= "- Sans -"	
toiture_type	=	#sans

--- les parametres du composant	---------
struct toiture_params	(
	fn VP_afficher 	nd	surface_pts	z	=()
)



--- les rollout du composant	---------
rollout toiture_dialog "Sans" width:180 height:70	(
	local m_plug
	local m_compo
	local m_rollPrt
	
	fn actualiser =(
	)
	
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 		= (
		
		local ptr_geo 				= 	_plug.core.get_geo ()
		local face = ptr_geo.face		pts_accroches						matID:#mur
		ptr_geo.extruder	face	_plug.const_dalle_epaisseur
		
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  	nom:toiture_nom	type:toiture_type	params:(toiture_params() )	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire	

	
	
	
) ----	FileIn ----
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	