
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
menuis_nom 		= "Porte"	
menuis_type		=	#porte
menuis_toolTip 	=	""


	
--- les parametres du composant	---------
struct menuis_params	(
	hauteur					=	0,
	ouverture_sens 		= 1
)

--- les rollout du composant	---------
rollout menuis_dialog "Espacement" (
	
			local m_plug		
			local m_menuiserie
	
	
			---- golbal --------------
		label 'lbl_hauteur' "Hauteur : " pos:[6,5] width:75 height:13 align:#left
		spinner 'spn_hauteur' "" pos:[99,5] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		label 'lbl_ouverture' "Ouverture :" pos:[6,38] width:67 height:13 align:#left
		dropdownList 'ddl_ouverture' "" pos:[68,36] width:100 height:21 items:#("Auto", "Droite", "Gauche") align:#left
			
		fn actualiser =(
			spn_hauteur.value 		= m_menuiserie.params.hauteur			
			ddl_ouverture.selection	=	m_menuiserie.params.ouverture_sens
		)
		fn initialiser _plug = m_plug = _plug
		fn set_menuiserie _menuis =(
			m_menuiserie	=	_menuis
			actualiser ()
		)
		
		
		on spn_hauteur changed val do	
			m_menuiserie.params.hauteur		 = val
		
		
		on ddl_ouverture selected val do	
			m_menuiserie.params.ouverture_sens		 = val
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
			
-- 			local allege_ht					=	_this.params.allege_vitree_ht
			
			local traverses					=_ptr_baie.params.traverses
			
			local		baie_hauteur			=	_dist_hauteur
			local 	porte_hauteur		=	if _this.params.hauteur == 0 then baie_hauteur else _this.params.hauteur 
			if porte_hauteur	>baie_hauteur do porte_hauteur = baie_hauteur
			
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
			
			local vec_baie_ht	 		=  [0,0,1]  		*	baie_hauteur
			local vec_porte_ht		=	[0,0,1]			*	porte_hauteur
			
			
			
			
			--- Porte	------------
			local vec_espaceSsPorte = [0,0, 2 ]	
			local ptTmp					=	_pt_origine + vec_men_ep		+ 	 vec_espaceSsPorte  -- + vec_men_ep/2 + vec_vitrage_ep/2
			local vecTMP_htPorte		=  (vec_hauteur   - 1*vec_men_ht  - vec_espaceSsPorte) 
			ptr_geo.tube		ptTmp		vecTMP_htPorte		( vec_longueur  )			-5				matID:#menuiserie 
			
			
			
		-------------   Imposte vitrée				-----------------------------------------------------------------------------------------------------------------
			if (	 porte_hauteur < baie_hauteur ) do (
				-----	menuiserie	-------------
				local ptImposte1				=	_pt_origine +  vec_porte_ht - vec_men_ht
				ptr_geo.tube		ptImposte1		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie
				
				--- vitrage	------------
				local ptTmp					=	ptImposte1  + vec_men_ht + vec_men_ep/2 + vec_vitrage_ep/2
				local vecTMP_htVitr		=  vec_baie_ht -  vec_porte_ht - vec_men_ht
				ptr_geo.tube		ptTmp		vecTMP_htVitr		vec_longueur 			-vec_vitrage_ep				matID:#vitrage 
					
			)
			
	)
	
	
	
	

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:menuis_tooltip		nom:menuis_nom	type:menuis_type	params:(menuis_params())	dialog:menuis_dialog	fnConstruire:menuis_fnConstruire

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
	