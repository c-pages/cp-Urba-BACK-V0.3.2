
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
menuis_nom 		= "Porte"	
menuis_type		=	#porte
menuis_toolTip 	=	""


	
--- les parametres du composant	---------
struct menuis_params	(
	longueur = 0,
	hauteur					=	210,
	ouverture_sens 		= 1
)

--- les rollout du composant	---------
rollout menuis_dialog "Porte" width:162 height:63
(
	
	local m_plug		
	local m_compo
	local m_rollPrt		
	
	
			---- golbal --------------
	label 'lbl_hauteur' "Hauteur : " pos:[5,5] width:75 height:13 align:#left
	spinner 'spn_hauteur' "" pos:[100,5] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
	label 'lbl_ouverture' "Ouverture :" pos:[6,40] width:58 height:13 align:#left
	dropdownList 'ddl_ouverture' "" pos:[68,38] width:100 height:21 items:#("Auto", "Droite", "Gauche") align:#left
			
	label 'lbl_longueur' "Longueur:" pos:[5,21] width:63 height:13 align:#left
	spinner 'spn_longueur' "" pos:[100,21] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		fn actualiser =(
			spn_hauteur.value 		= m_compo.params.hauteur			
			ddl_ouverture.selection	=	m_compo.params.ouverture_sens
		)
		fn initialiser _plug = m_plug = _plug
		fn set_menuiserie _menuis =(
			m_compo	=	_menuis
			actualiser ()
		)
		
		
		
		
	on spn_hauteur changed val do
	(
				m_compo.params.hauteur		 = val			
				m_rollPrt.on_a_change_un_truc ()
			)
	on ddl_ouverture selected val do
	(
				m_compo.params.ouverture_sens		 = val
				m_rollPrt.on_a_change_un_truc ()
			)
	on spn_longueur changed val do
	(
			m_compo.params.longueur = val
			m_rollPrt.changer_un_truc ()
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
			
-- 			local allege_ht					=	this.params.allege_vitree_ht
			
			local traverses					=ptr_baie.params.traverses
			
			local		baie_hauteur			=	dist_hauteur
			local 	porte_hauteur		=	if this.params.hauteur == 0 then baie_hauteur else this.params.hauteur 
			if porte_hauteur	>baie_hauteur do porte_hauteur = baie_hauteur
			
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
	
	
	
	
	
	
	
