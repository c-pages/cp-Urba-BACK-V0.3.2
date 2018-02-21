



--- parametres de base	-----------------------------
toiture_titre 	= "Terrasse"	
toiture_type	=	#terrasse
toiture_toolTip =	"..."

--- les parametres du composant	---------
struct toiture_params	(
	longueur = 100.
)
--- les rollout du composant	---------
rollout toiture_dialog "Toiture plate" width:180 height:70	(
	local m_rollPrt
	local m_compo
	
	edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
	GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
	label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
	spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	fn actualiser =(
		spn_longueur.value 	= 	m_compo.params.longueur
		edt_nom.text 			=	m_compo.nom
	)

	on spn_longueur changed val do (
		m_compo.params.longueur = val
		m_rollPrt.actualiser ()
	)
	on edt_nom	 entered txt 	do	(
		m_compo.nom = txt
		m_rollPrt.actualiser ()
	)
	
)
--- la fonction de construction	---------
fn toiture_fnConstruire  	_plug		pts_accroches		 _composant		= (
				
	)
	





------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
parametresTMP = toiture_params () 
str_modelBase		tooltip:toiture_tooltip		titre:toiture_titre	type:toiture_type	params:(parametresTMP)	dialog:toiture_dialog	fnConstruire:toiture_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	