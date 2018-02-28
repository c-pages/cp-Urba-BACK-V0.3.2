nom



--- parametres de base	-----------------------------
compo_nom 	= "Balcon fin"	
compo_type	=	#balconFin
compo_toolTip =	""




--- les rollout du composant	---------
rollout compo_dialog "Balcon fin" width:180 height:70	(
	local m_rollPrt
	local m_compo
	fn actualiser =()
)


--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= ()
	
	
	


------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
str_modelBase 		nom:compo_nom	type:compo_type	params:undefined 	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	