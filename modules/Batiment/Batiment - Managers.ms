
	
--- le manager pour passer des parametre du plug au struct es manipulations des elemenst ------------------------
include	 "$userScripts\cp-Urba\modules\Batiment\divers\Batiment - Manager Parametres.ms"

struct str_mgr_elements (
	
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	private
		m_debug = true,
		m_dbgPrefix ="urba | str_mgr_elements",
		fn debug 	_txt  var:	 param:    =	try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix	catch (),
	------------ DEBUG		-------------------------------------------------------------------------------------------------------------------------
	
	
	
	
	
	------------ MEMBRES	-------------------------------------------------------------------------------------------------------------------------
	private
		m_plug,
		
	-------- Les managers des differents éléments du batiment ---------------
		---- facades	----------
		mgr_facades 			= str_manager_parametres (),
		mgr_facCompos 	= str_manager_parametres (),
		mgr_facMenuiseries,
		
		---- toiture	----------
		mgr_toiture 			= str_manager_parametres (),
		mgr_toitElements,
		
		
		
		
	------------ FONCTIONS	-------------------------------------------------------------------------------------------------------------------------
-- 	private
	
	
	
	------------ INTERFACE	-------------------------------------------------------------------------------------------------------------------------
	public	
		---- facades	----------
		fn get_facades						=	mgr_facades.get_elements (),
		fn ajouter_facade					=	mgr_facades.creer_element			enregistrer:true,
		fn supprimer_facade	_fcd		=	mgr_facades.supprimer_element	_fcd,
		
		---- toiture	----------
		fn get_toiture	=	mgr_facades.get_elements (),
		
		---- initialiser	 avant utilisation----------
		fn initialiser _plug =(
			
			m_plug = _plug
			format "\n"
			mgr_facades.initialiser 		plug:m_plug					\
													fichier_classeBase:			( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\Batiment - Elements - Facade.ms" )	\
													fichier_dialog:				( "Batiment - rollout facade.ms" )		\
													prefix_nomParametres:	"facades"
			format "\n"
			mgr_facCompos.initialiser 	plug:m_plug					\
													fichier_classeBase:			( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\Batiment - Elements - Composant de facade.ms" )	\
													dossier_constructeurs:	( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\composants de facade\\" )					\
													prefix_nomParametres:	"facCompos"
			format "\n"
			mgr_toiture.initialiser 		plug:m_plug					\
													fichier_classeBase:			( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\Batiment - Elements - Toiture.ms")	\
													dossier_constructeurs:	( getdir #userScripts + "\cp-Urba\\modules\\Batiment\\elements\\toitures\\"  )					\
													fichier_dialog:				( "Batiment - rollout toiture.ms" )		\
													prefix_nomParametres:	"toiture" 
			format "\n"
		)

)--- fin struct 	str_mgr_elements 	----------
	
	
	
	
	











