
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
menuis_nom 		= "Fenêtre"	
menuis_type			=	#fenetre
menuis_toolTip 		=	""


	
--- les parametres du composant	---------
struct menuis_params	(	
	hauteur					=	0,
	allege_vitree_ht		=	0,
	ouverture_sens 		= 1
)

--- les rollout du composant	---------
rollout menuis_dialog "Paramètres" width:180 height:130
(
	
		local m_plug		
		local m_menuiserie
	
			---- golbal --------------
	label 'lbl_hauteur' "Hauteur : " pos:[6,5] width:75 height:13 align:#left
	spinner 'spn_hauteur' "" pos:[99,5] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl_ouverture' "Ouverture :" pos:[6,38] width:67 height:13 align:#left
	dropdownList 'ddl_ouverture' "" pos:[68,36] width:100 height:21 items:#("Auto", "Droite", "Gauche") align:#left
		
	label 'lbl3' "Allège vitrée" pos:[6,20] width:75 height:13 align:#left
	spinner 'spn_allege_vitree' "" pos:[99,20] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		
		fn actualiser =(
			spn_hauteur.value 		= m_menuiserie.params.hauteur			
			spn_allege_vitree.value 	= m_menuiserie.params.allege_vitree_ht
			ddl_ouverture.selection	=	m_menuiserie.params.ouverture_sens
		)
		fn initialiser _plug = m_plug = _plug
		fn set_menuiserie _menuis =(
			m_menuiserie	=	_menuis
			actualiser ()
		)
		
		
		on spn_hauteur changed val do	
			m_menuiserie.params.hauteur		 = val
		
		on spn_allege_vitree changed val do	
			m_menuiserie.params.allege_vitree_ht		 = val
		
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
			
			local allege_ht					=	_this.params.allege_vitree_ht
			
			local traverses					=_ptr_baie.params.traverses
			
			
			
		-------------  vecteurs directeurs  		-----------------------------------------------------------------------------------------------------------------
			local norm_prof				= normDir 		* rotateZ ( matrix3 1 ) 90		
			
			local vec_longueur 		= normDir 		*	baie_longueur
			local vec_hauteur	 		= [0,0,1]  		*	baie_hauteur
			
			local vec_men_ep			=	norm_prof		*	menuis_epaisseur
			local vec_men_lrg			=	normDir		*	menuis_largeur
			local vec_men_ht			=	[0,0,1] 			*	menuis_largeur
			local vec_men_nu			=  norm_prof 	*	menuis_nu
			
			local vec_allege_ht		= 	[0,0,1] 			*	allege_ht
			
			local vec_vitrage_ep		=	norm_prof		*	vitrage_epaisseur		
			local vec_murEp			=	norm_prof 	*	_plug.const_murExt_epaisseur
			
			
			
			
			-------------   menuiserie du bas		-----------------------------------------------------------------------------------------------------------------
			local ptTmp				=	_pt_origine 	--	+ vec_allege_ht
			ptr_geo.tube		ptTmp		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie 
			
			
			
			
			-------------   allege	vitrée 		-----------------------------------------------------------------------------------------------------------------
			if allege_ht != 0 do (
				
				--- vitrage	------------
				local ptTmp					=	_pt_origine + vec_men_ht + vec_men_ep/2 + vec_vitrage_ep/2		--+ vec_allege_ht
				local vecTMP_htVitr		=  vec_allege_ht - vec_men_ht
				ptr_geo.tube		ptTmp		vecTMP_htVitr		vec_longueur			-vec_vitrage_ep				matID:#vitrage 
				
				-------------   menuiserie allege		-----------------------------------------------------------------------------------------------------------------
				local ptTmp				=	_pt_origine + vec_allege_ht
				ptr_geo.tube		ptTmp		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie 
				
			)
			
			
			
			
			-------------   FENETRE				-----------------------------------------------------------------------------------------------------------------
			-------------   menuiserie bas		-----------------------------------
			local ptFen1				=	_pt_origine + vec_allege_ht +  vec_men_ht + vec_men_ep/2
			ptr_geo.tube		ptFen1		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie

			-------------   menuiserie haut		-----------------------------------
			local ptFen2				=	_pt_origine + vec_hauteur -  2 * vec_men_ht + vec_men_ep/2
			ptr_geo.tube		ptFen2		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie
			
			-------------   menuiserie gauche		-----------------------------------
			local ptFen3				=	ptFen1 + vec_men_ht
			ptr_geo.tube		ptFen3		(vec_hauteur - vec_allege_ht  - 4*vec_men_ht ) 		vec_men_lrg      vec_men_ep		matID:#menuiserie
			
			-------------   menuiserie droite		-----------------------------------
			local ptFen4				=	ptFen3 + vec_longueur -  vec_men_lrg
			local vec_fen_ht		=	(vec_hauteur - vec_allege_ht  - 4*vec_men_ht ) 
			ptr_geo.tube		ptFen4			vec_fen_ht	vec_men_lrg      vec_men_ep		matID:#menuiserie
			
			
			
			--- vitrage	------------
			local ptTmp					=	ptFen1 + vec_men_lrg + vec_men_ht + vec_men_ep/2 + vec_vitrage_ep/2
			local vecTMP_htVitr		=  vec_fen_ht
			ptr_geo.tube		ptTmp		vecTMP_htVitr		( vec_longueur - 2*vec_men_lrg )			-vec_vitrage_ep				matID:#vitrage 
			
			
			
			
	)

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:menuis_tooltip		nom:menuis_nom	type:menuis_type	params:(menuis_params())	dialog:menuis_dialog	fnConstruire:menuis_fnConstruire

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
