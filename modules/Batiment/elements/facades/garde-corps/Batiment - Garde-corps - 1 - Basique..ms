
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
gardeCorps_nom 		= "Basique"	
gardeCorps_type		=	#basique
gardeCorps_toolTip 	=	""

struct gardeCorps_params (
	hauteur = 100.
)


------ la fonction de construction	---------
fn gardeCorps_fnConstruire  	_plug		_pts		/* norm_dir:	 */	 this:		onConstruitLaDalle:false	 = (
-- 			format "CONSTRUCTION DU GARDE-CORPS\n"
			
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
		local norm_dir 				= normalize	(_pts[2] - _pts[1] )
	
-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
		local hauteur	 		= this.params.hauteur
		local longueur 			= distance _pts[1] _pts[2]
		
		--- Vecteurs ------------
		local vec_ht 				= [0,0,1] 			* 	hauteur
		local vec_longueur 	= norm_dir 		* 	longueur
	
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
	
		local pts_ids 	= ptr_geo.points 	#( 		_pts[1], _pts[1] + vec_ht,  _pts[1] + vec_ht + vec_longueur, _pts[1] +  vec_longueur )
		local nvlFace 	= ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3], pts_ids[4] )			matID:#vitrage
		
	)
	
	
	
	

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:gardeCorps_tooltip		nom:gardeCorps_nom	type:gardeCorps_type	params:(gardeCorps_params() )	dialog:undefined	fnConstruire:gardeCorps_fnConstruire

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
