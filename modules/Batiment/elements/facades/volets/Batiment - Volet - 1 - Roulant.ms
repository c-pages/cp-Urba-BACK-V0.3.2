


	
( ----	FileIn ----
	
	



--- parametres de base	-----------------------------
compo_nom 	= "Volet roulant"	
compo_type	=	#voletRoulant
compo_toolTip =	""

--- les parametres du composant	---------
struct compo_params	(
	longueur 	= 0.,
	etirable		=	true,
	
	private
		emprise_verticale 	= 10,			---  <--- pour garder espace en haut de la menuiserie
	
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
fn compo_fnConstruire  	_plug		pt_haut		norm_dir:		 		dist_hauteur:				onConstruitLaDalle:true		this:	= (
	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
		local ptr_params		  	= 	this.params
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
		
		local norm_prof			= norm_dir 		* rotateZ ( matrix3 1 ) 90		
		local emprise_verticale = ptr_params.get_emprise_verticale() 
		local vec_longueur 		= norm_dir 		* ptr_params.longueur
		local vec_caisse_ep		= [0,0,1] 		* emprise_verticale
		local vec_caisse_prof	= norm_prof 	* emprise_verticale
		local vec_volet_hauteur = [0,0,1] 		* ( dist_hauteur - emprise_verticale )
		
		local vec_rail_lrg 		= norm_dir * 3
	
		local vec_decallage_volet	=	norm_prof * 3
	
	
		
		
		--- gestion du hazard -------
		local test_closVolet = random 0 100 <  _plug.alea_volet_clos_proba
		local vec_clos_volet = [0,0,0] -- *  vec_volet_hauteur
		if  test_closVolet do
			vec_clos_volet = [0,0,1] * vec_volet_hauteur * (random 	_plug.alea_volet_clos_min 		_plug.alea_volet_clos_max) / 100


-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
		----------- la caisse---- --------
		-------	Creation des points 	--------
		local pt_2 		= pt_haut		- 	vec_caisse_prof
		local pt_3 		= pt_2			+	vec_longueur
		local pt_4 		= pt_3			+	vec_caisse_prof
		
		local pt_5 		= pt_2			+	vec_caisse_ep
		local pt_6		= pt_3			+	vec_caisse_ep
		
		--- creation des points --------------
		local pts_caisse_pos 	= #(pt_haut, pt_4, pt_3,  pt_2 )
		local pts_caisse_ids 		= ptr_geo.points 	pts_caisse_pos	
		local pts_caisse_devant	 = ptr_geo.points 	#(pt_5,  pt_6)	
		
		-------	Creation de face 	--------
		ptr_geo.face 		pts_caisse_ids 		matid:#menuiserie 		
		ptr_geo.face 		#( pts_caisse_devant[1] ,  pts_caisse_devant[2]	, pts_caisse_ids[3], pts_caisse_ids[4])	matid:#menuiserie 
		
		
		
		---- le volet  ------------
		local pt_volet_1 = pt_haut 		- vec_decallage_volet
		local pt_volet_2 = pt_volet_1 	+ vec_longueur
		local pt_volet_3 = pt_volet_2	- vec_clos_volet
		local pt_volet_4 = pt_volet_3	- vec_longueur
		
		ptr_geo.face 	#(pt_volet_1, pt_volet_4, pt_volet_3,  pt_volet_2 )			matid:#volet 
		
		
		
		----- les rails ------------
		local pt_railG_1 = pt_haut 		- vec_decallage_volet - vec_decallage_volet/3
		local pt_railG_2 = pt_railG_1 		+ vec_rail_lrg
		local pt_railG_3 = pt_railG_2		- vec_volet_hauteur
		local pt_railG_4 = pt_railG_3		- vec_rail_lrg
		
		local pt_railG2_1 = pt_railG_1 + 2* ( vec_decallage_volet/4 )
		local pt_railG2_2 = pt_railG_2 + 2* ( vec_decallage_volet/4 )
		local pt_railG2_3 = pt_railG_3 + 2* ( vec_decallage_volet/4 )
		local pt_railG2_4 = pt_railG_4 + 2* ( vec_decallage_volet/4 )
		
		ptr_geo.face 	#(pt_railG_1,  pt_railG_2, pt_railG_3, pt_railG_4 )			matid:#menuiserie 
		ptr_geo.face 	#(pt_railG2_1,  pt_railG2_2, pt_railG2_3, pt_railG2_4 )			matid:#menuiserie 
		
		
		local pt_railD_1 = pt_railG_1		+ vec_longueur - vec_rail_lrg
		local pt_railD_2 = pt_railD_1 		+ vec_rail_lrg
		local pt_railD_3 = pt_railD_2		- vec_volet_hauteur
		local pt_railD_4 = pt_railD_3		- vec_rail_lrg
		
		local pt_railD2_1 = pt_railD_1 + 2* ( vec_decallage_volet/4 )
		local pt_railD2_2 = pt_railD_2 + 2* ( vec_decallage_volet/4 )
		local pt_railD2_3 = pt_railD_3 + 2* ( vec_decallage_volet/4 )
		local pt_railD2_4 = pt_railD_4 + 2* ( vec_decallage_volet/4 )
		
		ptr_geo.face 	#(pt_railD_1,  pt_railD_2, pt_railD_3, pt_railD_4 )			matid:#menuiserie 
		ptr_geo.face 	#(pt_railD2_1,  pt_railD2_2, pt_railD2_3, pt_railD2_4 )			matid:#menuiserie 
		
		
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:( compo_params () )	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
	
	
