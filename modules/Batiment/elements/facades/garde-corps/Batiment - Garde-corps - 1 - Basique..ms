
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
gardeCorps_nom 		= "Basique"	
gardeCorps_type		=	#basique
gardeCorps_toolTip 	=	""




------ la fonction de construction	---------
fn gardeCorps_fnConstruire  	_plug		_ptr_baie		 _pt_origine		_normDir		_dist_hauteur			 _this		= (
			format "CONSTRUCTION DU GARDE-CORPS\n"
			
	)
	
	
	
	

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:gardeCorps_tooltip		nom:gardeCorps_nom	type:gardeCorps_type	params:undefined	dialog:undefined	fnConstruire:gardeCorps_fnConstruire

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
