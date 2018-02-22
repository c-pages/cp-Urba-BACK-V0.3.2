
------ parametres de base	-----------------------------
compo_titre 		= "Espacement"	
compo_type		=	#espacement
compo_toolTip 	=	"Ajouter un espacement. Mur plein de longueur varirable, répartis par facade, entre tous les espacement"


------ la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= ()
	
--- les parametres du composant	---------
struct compo_params	(
	longueur = 0.
)

--- les rollout du composant	---------
rollout compo_dialog "Espacement" width:180 height:70	(
	local m_rollPrt
	local m_compo
	fn actualiser =()
)



------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Elements - Modele de base.ms"
--- Creation de la structure mere	-----------------
str_modelBase 	tooltip:compo_tooltip		titre:compo_titre	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	