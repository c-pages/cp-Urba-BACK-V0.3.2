
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
compo_nom 		= "Groupe"	
compo_type		=	#Groupe
compo_toolTip 	=	"Pour grouper des composant entre eux."


------ la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= ()
	
--- les parametres du composant	---------
struct compo_params	(
	longueur = 0.,
	repetitions = 0,
	
	public	
	fn	get_longueur =(
		longueur
	)
	
)

--- les rollout du composant	---------
rollout compo_dialog "Groupe" width:180 height:70	(
	local m_rollPrt
	local m_compo
	local m_plug
	
	
	edittext 'edt_nom' "" pos:[3,3] width:187 height:16 align:#left
	label 'lbl19' "Répétitions:" pos:[15,36] width:49 height:13 align:#left
	spinner 'spn_repetitions' "" pos:[116,36] width:70 height:16 range:[0,100000,0] type:#integer scale:1 align:#left
	
	
	
	fn actualiser =(
			--- global ------
			edt_nom.text 					=	m_compo.nom
			spn_repetitions.value 		= m_compo.params.repetitions
		)
		
		
		
	on edt_nom entered txt 	do
	(
		m_compo.nom = txt
		m_rollPrt.actualiser ()
	)
	on spn_repetitions changed val 	do (
		m_compo.params.repetitions 					= val
		m_rollPrt.actualiser sans_subRoll_1:true
	)
)


------ la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		= pts_accroches
	

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire	--	invisible:true

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
	