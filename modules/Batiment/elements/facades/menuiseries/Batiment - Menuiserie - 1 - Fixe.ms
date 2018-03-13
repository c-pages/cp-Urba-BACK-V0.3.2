
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
menuis_nom 		= "Fixe"	
menuis_type		=	#fixe
menuis_toolTip 	=	""



--- les parametres du composant	---------
struct menuis_params	(
-- 	allege_ht	=	0,
	longueur = 0
)

--- les rollout du composant	---------
rollout menuis_dialog "Menuiserie" width:221 height:119
(
	
	local m_plug		
	local m_compo
	local m_rollPrt		
		
	GroupBox 'grp1' "Global" pos:[6,7] width:187 height:70 align:#left
			
	dropdownList 'ddl_type' "" pos:[67,27] width:111 height:21 align:#left
	label 'lbl51' "Type :" pos:[15,29] width:49 height:15 align:#left
			
		
			---- golbal --------------
	label 'lbl_longueur' "Longueur:" pos:[15,54] width:63 height:13 align:#left
	spinner 'spn_longueur' "" pos:[106,54] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		
		
		fn actualiser =(
			ddl_type.items 	= m_plug.core.get_menuiserie_constructeursNoms ()
			local menuis_types 			= m_plug.core.get_menuiserie_constructeursTypes ()
			ddl_type.selection 				= findItem  menuis_types		m_compo.type  
			
			if m_compo != undefined do
				spn_longueur.value = m_compo.params.longueur
		)

		fn set_menuiserie 	_menuis =(
			m_compo	=	_menuis
			actualiser ()
		)
		
		fn initialiser _plug = (
			m_plug = _plug
			
				
		)

	
	on spn_longueur changed val do(
		m_compo.params.longueur = val
		m_rollPrt.changer_un_truc ()
)
	
		on ddl_type selected _val do		(
			m_plug.core.appliquer_menuiserie_type		m_compo	_val
			actualiser ()
		m_rollPrt.changer_un_truc ()
			m_rollPrt.actualiser ()
		)
)

------ la fonction de construction	---------
fn menuis_fnConstruire  	_plug	_pt_origine		norm_dir:		dist_hauteur:	ptr_baie:		 this:		= (
	
			local ptr_geo = _plug.core.get_geo ()
			
		-------------  constantes 			-----------------------------------------------------------------------------------------------------------------
			local 	norm_dir				=	norm_dir
			local		baie_longueur		=	this.params.longueur
			local		baie_hauteur			=	dist_hauteur
			local		baie_profondeur		=	_plug.const_murExt_epaisseur
			
			local menuis_largeur			=	_plug.const_menuiseries_largeur
			local menuis_epaisseur		=	_plug.const_menuiseries_epaisseur		
			local menuis_nu				=	ptr_baie.params.profondeur		
			local vitrage_epaisseur		=	_plug.const_vitrage_epaisseur
			
-- 			local allege_ht					=	this.params.allege_ht
			
			local traverses					=ptr_baie.params.traverses
			
		-------------  vecteurs directeurs  		-----------------------------------------------------------------------------------------------------------------
			local norm_prof				= norm_dir 		* rotateZ ( matrix3 1 ) 90		
			
			local vec_longueur 		= norm_dir 		*	baie_longueur
			local vec_hauteur	 		= [0,0,1]  		*	baie_hauteur
			
			local vec_men_ep			=	norm_prof		*	menuis_epaisseur
			local vec_men_lrg			=	norm_dir		*	menuis_largeur
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
				local ptTmp				=	_pt_origine + [0,0,1] * trav_ht - vec_men_ht
				ptr_geo.tube		ptTmp		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie 
			)
	
	)

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:menuis_tooltip		nom:menuis_nom	type:menuis_type	params:(menuis_params())		dialog:menuis_dialog	fnConstruire:menuis_fnConstruire

	
) ----	FileIn ----
	
	
	
	
	
	
	
	