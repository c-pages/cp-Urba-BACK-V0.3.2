
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
menuis_nom 		= "Fixe"	
menuis_type		=	#fixe
menuis_toolTip 	=	""


	/* 
--- les parametres du composant	---------
struct menuis_params	(
	allege_ht	=	0
)
 */
--- les rollout du composant	---------
rollout menuis_dialog "Paramètres" width:170 height:44
(
	
		local m_plug		
		local m_menuiserie
		
		/* 
			---- golbal --------------
		label 'lblallege' "Allège:" pos:[11,5] width:49 height:13 align:#left
		spinner 'spn_allege' "" 	pos:[87,5] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	
	 */
		fn actualiser =(
-- 			spn_allege.value = m_menuiserie.params.allege_ht
		)

		fn set_menuiserie _menuis =(
			m_menuiserie	=	_menuis
			actualiser ()
		)
		
		fn initialiser _plug = m_plug = _plug

-- 	on spn_allege changed val do m_menuiserie.params.allege_ht = val
	
)


------ la fonction de construction	---------
fn menuis_fnConstruire  	_plug		_ptr_baie		 _pt_origine		_normDir		_dist_hauteur			 _this		= (
	
			local ptr_geo = _plug.core.get_geo ()
			
		-------------  constantes 			-----------------------------------------------------------------------------------------------------------------
			local 	normDir				=	_normDir
			local		baie_longueur		=	_this.longueur
			local		baie_hauteur			=	_dist_hauteur
			local		baie_profondeur		=	_plug.const_murExt_epaisseur
			
			local menuis_largeur			=	_plug.const_menuiseries_largeur
			local menuis_epaisseur		=	_plug.const_menuiseries_epaisseur		
			local menuis_nu				=	_ptr_baie.params.profondeur		
			local vitrage_epaisseur		=	_plug.const_vitrage_epaisseur
			
-- 			local allege_ht					=	_this.params.allege_ht
			
			local traverses					=_ptr_baie.params.traverses
			
		-------------  vecteurs directeurs  		-----------------------------------------------------------------------------------------------------------------
			local norm_prof				= normDir 		* rotateZ ( matrix3 1 ) 90		
			
			local vec_longueur 		= normDir 		*	baie_longueur
			local vec_hauteur	 		= [0,0,1]  		*	baie_hauteur
			
			local vec_men_ep			=	norm_prof		*	menuis_epaisseur
			local vec_men_lrg			=	normDir		*	menuis_largeur
			local vec_men_ht			=	[0,0,1] 			*	menuis_largeur
			local vec_men_nu			=  norm_prof 	*	menuis_nu
			
-- 			local vec_allege_ht		= 	[0,0,1] 			*	allege_ht
			
			local vec_vitrage_ep		=	norm_prof		*	vitrage_epaisseur		
			local vec_murEp			=	norm_prof 	*	_plug.const_murExt_epaisseur
			
			
			
		-------------   menuiserie du bas		-----------------------------------------------------------------------------------------------------------------
			local ptTmp				=	_pt_origine --		+ vec_allege_ht
			ptr_geo.tube		ptTmp		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie 
			
			
		--- vitrage	------------
			local ptTmp					=	_pt_origine + vec_men_ht + vec_men_ep/2 + vec_vitrage_ep/2		--+ vec_allege_ht
			local vecTMP_htVitr		= vec_hauteur 	- 2* 	vec_men_ht	--  vec_allege_ht
			ptr_geo.tube		ptTmp		vecTMP_htVitr		vec_longueur			-vec_vitrage_ep				matID:#vitrage 
			
			
		---- traverses ---
			for trav_ht in traverses do (
				local ptTmp				=	_pt_origine + [0,0,1] * trav_ht
				ptr_geo.tube		ptTmp		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie 
			)
	
	)

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:menuis_tooltip		nom:menuis_nom	type:menuis_type	params:undefined		dialog:menuis_dialog	fnConstruire:menuis_fnConstruire

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
