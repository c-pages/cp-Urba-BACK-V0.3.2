


	
( ----	FileIn ----
	
	



--- parametres de base	-----------------------------
compo_nom 	= "Volet battant"	
compo_type	=	#voletBattant
compo_toolTip =	""

--- les parametres du composant	---------
struct compo_params	(
	longueur 	= 0.,
	etirable		=	true,
	
	private
		emprise_verticale 	= 0,		---  <--- pour garder espace en haut de la menuiserie
	
	public
		fn get_emprise_verticale = emprise_verticale
		
		
)

--- les rollout du composant	---------
rollout compo_dialog "Volet roulant" width:180 height:87
(
	local m_rollPrt
	local m_compo
	local m_plug
	
	edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
	GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:56 align:#left
	label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	checkbox 'chk_etirable' "Etirable" pos:[12,54] width:146 height:15 align:#left
	fn actualiser =(
		spn_longueur.value 	= 	m_compo.params.longueur
			chk_etirable.checked		= m_compo.params.etirable
		edt_nom.text 			=	m_compo.nom
	)

	
	on edt_nom entered txt 	do
	(
			m_compo.nom = txt
			m_rollPrt.actualiser 	sans_params_1:true		
			m_rollPrt.changer_un_truc ()
		)
	on spn_longueur changed val do
	(
			m_compo.params.longueur = val
			m_rollPrt.actualiser 	sans_params_1:true
			m_rollPrt.changer_un_truc ()
		)
	on chk_etirable changed state do
(
		m_compo.params.etirable = state
		m_rollPrt.actualiser 	sans_params_1:true
		m_rollPrt.changer_un_truc ()
	)
)

--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pt_haut		norm_dir:		 		dist_hauteur:				onConstruitLaDalle:true		this:			baie_parent:		= (
	
	
-- 	format "VOLET BATTANT\n"
-- 	format "	baie_parent : %\n"	baie_parent
	
	local ptr_plug				= 	_plug
	local ptr_composant  	= 	this
	local ptr_params		  	= 	this.params
	local ptr_geo 				= 	ptr_plug.core.get_geo ()
	
	local norm_prof				= norm_dir 		* rotateZ ( matrix3 1 ) 90		
	local vec_longueur 			= norm_dir 		* ptr_params.longueur
	
	local vec_hauteur 			= [0,0,1] 		* dist_hauteur
	
	
	--- gestion du hazard -------
	local test_ouvertureVolet = random 0 100 <=  _plug.alea_volet_clos_proba
	local mtrx_rotationHasard_G
	if  test_ouvertureVolet then (
-- 				local sens_ouvertue  	= if not inverse_ouverture then 1 else -1
		local angleMin_G 			=  180. * _plug.alea_volet_clos_min/100
		local angleMax_G 			=  180. * _plug.alea_volet_clos_max/100
		local angleMin_D 			=  180. * _plug.alea_volet_clos_min/100	--	+ 180.
		local angleMax_D 			=  180. * _plug.alea_volet_clos_max/100--	+ 180.
			
		mtrx_rotationHasard_G 	= rotateZMatrix  	( random angleMin_G angleMax_G )
		mtrx_rotationHasard_D 	= rotateZMatrix  (  -1 * 	( random angleMin_D angleMax_D )   )
		
	)	else (
		mtrx_rotationHasard_G = matrix3 1
		mtrx_rotationHasard_D = matrix3 1
	)

	
	
	format "	_plug.alea_volet_clos_proba : %\n"	_plug.alea_volet_clos_proba
	format "	test_ouvertureVolet : %\n"	test_ouvertureVolet
	format "	mtrx_rotationHasard_G : %\n"	mtrx_rotationHasard_G
	
	
	local decallage_volet		 	= 1
	local profondeur_baie			=	baie_parent.params.profondeur
	local vec_volet_decall_prof 	= -1 * norm_prof * (  decallage_volet + profondeur_baie )
	
	local decall_volet_ht			=	1
	local decall_volet_lg				=	1
	
	local vec_volet_decall_ht 		= [0,0,1] * decall_volet_ht
	local vec_volet_decall_lg 		= norm_dir 		* decall_volet_lg
	local vec_volet_ht 				= vec_hauteur		-	2* vec_volet_decall_ht
	local vec_voletG_lg 				= ( vec_longueur	/	2	-	1* vec_volet_decall_lg	)	* 	mtrx_rotationHasard_G
	local vec_voletD_lg 				= -( vec_longueur	/	2	-	1* vec_volet_decall_lg	)	* 	mtrx_rotationHasard_D
	
	local norm_dir_volet_G 		= norm_dir 		* mtrx_rotationHasard_G
	local norm_prof_volet_G 		= norm_prof 	* mtrx_rotationHasard_G
	
	local norm_dir_volet_D 		= -norm_dir 		* mtrx_rotationHasard_D
	local norm_prof_volet_D 		= norm_prof 	* mtrx_rotationHasard_D
	
	
	local volet_G_origine			=	pt_haut 	+ [0,0,-1] 	* dist_hauteur		+	vec_volet_decall_prof	+		vec_volet_decall_ht
	local volet_D_origine			=	volet_G_origine 		+ vec_longueur	
	local volet_ep						=	5
	
	local montant_horiz_larg		=	5
	local montant_horiz_ht			=	10
	
	local montant_vert_larg		=	montant_horiz_ht
	local montant_vert_ht			=	montant_horiz_larg
	
	local remplissage_ht				=	dist_hauteur	-	2 * montant_horiz_ht
	
	local vec_remplissage_lrg_G	=	( 	vec_voletG_lg	- 2 * ( 	norm_dir_volet_G * montant_vert_larg ) 	 )
	local vec_remplissage_lrg_D	=	( 	vec_voletD_lg	- 2 * ( 	norm_dir_volet_D * montant_vert_larg ) 	 )
	
	local vec_volet_G_prof			=	( -1 *  norm_prof_volet_G * volet_ep ) 
	local vec_volet_D_prof			=	( -1 *  norm_prof_volet_D * volet_ep ) 
	
	
	------------ VOLET GAUCHE	--------------------------------------------------------------------------------------------
	----	le cadre  Gauche	------------------------
	---- verticaux	-----------------
	local pt1	=	volet_G_origine	+  -1 *	norm_dir_volet_G * montant_vert_larg  + vec_volet_decall_lg
	ptr_geo.boite 		pt1		vec_volet_ht		( 	norm_dir_volet_G * montant_vert_larg ) 			vec_volet_G_prof 		matID:#volet
	local pt2	=	pt1	-	vec_voletG_lg				+ 1 * ( 	norm_dir_volet_G * montant_vert_larg ) 
	ptr_geo.boite 		pt2		vec_volet_ht		( 	norm_dir_volet_G * montant_vert_larg ) 			vec_volet_G_prof 		matID:#volet
	
	---- horizontaux	-----------------
	local pt3	=	pt2  + ( 	norm_dir_volet_G * montant_vert_larg ) 
	ptr_geo.boite 		pt3		( [0,0,1] * montant_horiz_ht )		vec_remplissage_lrg_G 			vec_volet_G_prof 		matID:#volet
	
	local pt4	=	pt3  + ( [0,0,1] * vec_volet_ht / 2  ) 
	ptr_geo.boite 		pt4		( [0,0,1] * montant_horiz_ht )		vec_remplissage_lrg_G 			vec_volet_G_prof 		matID:#volet
	
	local pt5	=	pt3  + vec_volet_ht	-	( [0,0,1] * montant_horiz_ht ) 
	ptr_geo.boite 		pt5		( [0,0,1] * montant_horiz_ht )		vec_remplissage_lrg_G 			vec_volet_G_prof 		matID:#volet
	
	
	
	----	remplissage  Gauche	------------------------
	local ailette_ht					=	8.
	local	ailette_ep					=	3
	local ailette_enfoncement	=	.5
	local nbre_ailettes				=	floor	( remplissage_ht / ailette_ht )
	ailette_ht							=	remplissage_ht / nbre_ailettes
	local ailette_decallage_ht		=	ailette_ht - ailette_ep
	
	
	
	
	local pt_depose_aliette		=	pt1 + [0,0,1] * montant_horiz_ht
	for i = 1 to nbre_ailettes do (
		
		local pt1	=	pt_depose_aliette -	vec_remplissage_lrg_G		-	1 * ailette_enfoncement * norm_prof_volet_G
		local pt2	=	pt1	+	[0,0,1] *  ailette_ep 
		local pt3	=	pt2	+	vec_remplissage_lrg_G
		local pt4	=	pt3	-	[0,0,1] *  ailette_ep 
		
		local pt5	=	pt1 	+ vec_volet_G_prof	+		[0,0,1] *  ailette_decallage_ht 	+	2 * ailette_enfoncement * norm_prof_volet_G
		local pt6	=	pt5	+	[0,0,1] *  ailette_ep 
		local pt7	=	pt6	+	vec_remplissage_lrg_G
		local pt8	=	pt7	-	[0,0,1] *  ailette_ep 
		
		local pts_ailette		=	ptr_geo.points		#( pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8 )
		
		ptr_geo.face	#(pts_ailette[1], pts_ailette[2], pts_ailette[3], pts_ailette[4] ) 		matID:#volet
		ptr_geo.face	#(pts_ailette[2], pts_ailette[6], pts_ailette[7], pts_ailette[3] ) 		matID:#volet
		ptr_geo.face	#(pts_ailette[8], pts_ailette[7], pts_ailette[6], pts_ailette[5] ) 		matID:#volet
		ptr_geo.face	#(pts_ailette[5], pts_ailette[8], pts_ailette[4], pts_ailette[1] ) 		matID:#volet
		
		pt_depose_aliette += [0,0,1] * ailette_ht
	)
	
	
	
	
	------------ VOLET DROIT	--------------------------------------------------------------------------------------------
	----	le cadre  Droit	------------------------
	---- verticaux	-----------------
	local pt1	=	volet_D_origine	+  -1 *	norm_dir_volet_D * montant_vert_larg   - vec_volet_decall_lg
	local pt2	=	pt1	-	vec_voletD_lg				+ 1 * ( 	norm_dir_volet_D * montant_vert_larg ) 
	ptr_geo.boite 		pt1		vec_volet_ht		( 	norm_dir_volet_D * montant_vert_larg ) 			vec_volet_D_prof 		matID:#volet
	ptr_geo.boite 		pt2		vec_volet_ht		( 	norm_dir_volet_D * montant_vert_larg ) 			vec_volet_D_prof 		matID:#volet
	
	---- horizontaux	-----------------
	local pt3	=	pt2  + ( 	norm_dir_volet_D * montant_vert_larg ) 
	ptr_geo.boite 		pt3		( [0,0,1] * montant_horiz_ht )		vec_remplissage_lrg_D 			vec_volet_D_prof 		matID:#volet
	
	local pt4	=	pt3  + ( [0,0,1] * vec_volet_ht / 2  ) 
	ptr_geo.boite 		pt4		( [0,0,1] * montant_horiz_ht )		vec_remplissage_lrg_D 			vec_volet_D_prof 		matID:#volet
	
	local pt5	=	pt3  + vec_volet_ht	-	( [0,0,1] * montant_horiz_ht ) 
	ptr_geo.boite 		pt5		( [0,0,1] * montant_horiz_ht )		vec_remplissage_lrg_D			vec_volet_D_prof			matID:#volet
	
	
	----	remplissage  Droit	------------------------
	
	
	local pt_depose_aliette		=	pt1 + [0,0,1] * montant_horiz_ht
	for i = 1 to nbre_ailettes do (
		
		local pt1	=	pt_depose_aliette -	vec_remplissage_lrg_D		-	1 * ailette_enfoncement * norm_prof_volet_D
		local pt2	=	pt1	+	[0,0,1] *  ailette_ep 
		local pt3	=	pt2	+	vec_remplissage_lrg_D
		local pt4	=	pt3	-	[0,0,1] *  ailette_ep 
		
		local pt5	=	pt1 	+ vec_volet_D_prof	+		[0,0,1] *  ailette_decallage_ht 	+	2 * ailette_enfoncement * norm_prof_volet_D
		local pt6	=	pt5	+	[0,0,1] *  ailette_ep 
		local pt7	=	pt6	+	vec_remplissage_lrg_D
		local pt8	=	pt7	-	[0,0,1] *  ailette_ep 
		
		local pts_ailette		=	ptr_geo.points		#( pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8 )
		
		ptr_geo.face	#(pts_ailette[1], pts_ailette[2], pts_ailette[3], pts_ailette[4] ) 		matID:#volet
		ptr_geo.face	#(pts_ailette[2], pts_ailette[6], pts_ailette[7], pts_ailette[3] ) 		matID:#volet
		ptr_geo.face	#(pts_ailette[8], pts_ailette[7], pts_ailette[6], pts_ailette[5] ) 		matID:#volet
		ptr_geo.face	#(pts_ailette[5], pts_ailette[8], pts_ailette[4], pts_ailette[1] ) 		matID:#volet
		
		pt_depose_aliette += [0,0,1] * ailette_ht
	)
	
	
	
)	---	 fin contruire	----------
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:( compo_params () )	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
	
	
