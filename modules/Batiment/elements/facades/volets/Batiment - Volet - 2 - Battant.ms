


	
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
fn compo_fnConstruire  	_plug		pts_accroches		norm_dir:		 		dist_hauteur:				onConstruitLaDalle:true		this:	= (
	
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:( compo_params () )	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	
	
	
