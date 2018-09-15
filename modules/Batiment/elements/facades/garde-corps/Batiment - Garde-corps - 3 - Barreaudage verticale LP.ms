
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
gardeCorps_nom 		= "Barreaudage vertical LP"	
gardeCorps_type		=	#barreaudageVert_LP
gardeCorps_toolTip 	=	""

struct gardeCorps_params (
	hauteur = 100./* ,
	
	barreaux_ecart 	= 11,
	barreaux_ep 		= 1,
	barreaux_prof	= 5 */
	
)


------ la fonction de construction	---------
fn gardeCorps_fnConstruire  	_plug		_pts		/* norm_dir:		 */ this:		onConstruitLaDalle:false	 = (
	
			
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
		
-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
		local norm_dir 				= normalize	(_pts[2] - _pts[1] )
		local hauteur	 		= this.params.hauteur
		local longueur 			= distance _pts[1] _pts[2]
	
		local barreaux_ecart 	= 11
		local barreaux_ep 		= 5
		local barreaux_prof		= 5
		
		local norm_prof			= norm_dir 		*	rotateZ ( matrix3 1 ) 90
	
		--- Vecteurs ------------
		local vec_ht 				= [0,0,1] 			* 	hauteur
		local vec_longueur 	= norm_dir 		* 	longueur
	
		local vec_barreaux_ecart 		= -norm_dir 		* 	barreaux_ecart
		local vec_barreaux_epVert		= norm_dir 		* 	barreaux_ep
		local vec_barreaux_epHoriz	= [0,0,1] 		 	* 	barreaux_ep
		local vec_barreaux_prof			= norm_prof  	* 	barreaux_prof
	
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
	/* 	----	 barreau  Bas	-----
		local ptTmp					=	_pts[1]		--+ vec_allege_ht
		ptr_geo.tube		ptTmp		vec_longueur		vec_barreaux_epHoriz			vec_barreaux_prof				matID:#menuiserie 
		 */
		----	 barreau  Haut	-----
		local ptTmp					=	_pts[1]		+ vec_ht
		ptr_geo.tube		ptTmp		vec_longueur		vec_barreaux_epHoriz			vec_barreaux_prof				matID:#menuiserie 
		
		
		----	Barreau Verticaux ------
		local nombre_barreaux 	= floor (longueur / ( barreaux_ecart+ barreaux_ep) ) + 1
		local longueur_reste 		= longueur	-	nombre_barreaux * ( barreaux_ecart+ barreaux_ep)		----(longueur / ( barreaux_ecart+ barreaux_ep) ) - nombre_barreaux


		local pt_barreauVert 		= _pts[2] /* + vec_barreaux_epHoriz  */ +  norm_dir * longueur_reste/2	-	vec_barreaux_epVert/2
		for i = 2 to nombre_barreaux do (
			local pt2 = pt_barreauVert + vec_barreaux_epVert
			local pt3 = pt2 + vec_ht
			local pt4 = pt_barreauVert + vec_ht
-- 			ptr_geo.tube		pt_barreauVert		(vec_ht -	vec_barreaux_epHoriz )   	vec_barreaux_epVert			vec_barreaux_prof				matID:#menuiserie 
			
			ptr_geo.face	#(pt_barreauVert, pt2, pt3, pt4 ) 		matID:#menuiserie
			
			
			pt_barreauVert += -norm_dir * ( barreaux_ecart + barreaux_ep )
		)
		/* 
		----	Barreau Verticaux ------
		local nombre_barreaux 	= floor (longueur / ( barreaux_ecart+ barreaux_ep) ) + 1
		local longueur_reste 		= longueur	-	nombre_barreaux * ( barreaux_ecart+ barreaux_ep)		----(longueur / ( barreaux_ecart+ barreaux_ep) ) - nombre_barreaux


		local pt_barreauVert 		= _pts[2] + vec_barreaux_epHoriz  +  norm_dir * longueur_reste/2	-	vec_barreaux_epVert/2
		for i = 2 to nombre_barreaux do (
			ptr_geo.tube		pt_barreauVert		(vec_ht -	vec_barreaux_epHoriz )   	vec_barreaux_epVert			vec_barreaux_prof				matID:#menuiserie 
			pt_barreauVert += -norm_dir * ( barreaux_ecart + barreaux_ep )
		)
		
		 */
	)
	
	
	
	

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:gardeCorps_tooltip		nom:gardeCorps_nom	type:gardeCorps_type	params:(gardeCorps_params() )	dialog:undefined	fnConstruire:gardeCorps_fnConstruire

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
