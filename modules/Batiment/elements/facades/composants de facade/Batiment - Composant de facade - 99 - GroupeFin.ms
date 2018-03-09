
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
compo_nom 		= "Groupe fin"	
compo_type		=	#GroupeFin
compo_toolTip 	=	"Pour grouper des composant entre eux."


------ la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		= pts_accroches
	
	
--- les rollout du composant	---------
rollout compo_dialog "Groupe - fin" width:180 height:70	(
	local m_rollPrt
	local m_compo
	local m_plug
	
	
	fn actualiser =(
		)
		
		
)



------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:undefined/* (compo_params()) */	dialog:compo_dialog	fnConstruire:compo_fnConstruire		invisible:true

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
	