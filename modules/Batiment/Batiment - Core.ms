/*#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	URBA - BATIMENT - CORE
	
##########################################################################################################################
	
	Le coeur du plug in.
	
##########################################################################################################################

	NOTES :
	
##########################################################################################################################
	
	todo:
	
##########################################################################################################################
	
	changelog:
	*v0.1 - [23/09/2017] -----------------------------------------------------------------------------
	- Mise en place globale 
	
	*v0.2 - [20/02/2018] -----------------------------------------------------------------------------
	- Reorganisation globale
	
########################################################################################################################*/



--- inculsion des fichiers externes	------------------------------
include	 "$userScripts\cp-Urba\modules\Batiment\divers\Batiment - Divers.ms"
include	 "$userScripts\cp-Urba\modules\Batiment\Batiment - Construction.ms"
-- include	 "$userScripts\cp-Urba\modules\Batiment\Batiment - Managers.ms"
include	 "$userScripts\cp-Urba\modules\Batiment\divers\Batiment - Manager Surface.ms"
include	 "$userScripts\cp-Urba\modules\Batiment\divers\Batiment - Manager Parametres.ms"
include	 "$userScripts\cp-Urba\modules\Batiment\Batiment - presets.ms"




--- la sturucture centrale du plug in ------------------------------------------
struct str_batiment_core (
	
	------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="urba | Batiment CORE",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	
	
	
	-------- MEMBRES	--------------------------------------------------------------------------------------------------------
	public
		version_du_plugin = "V0.11",		
		
	private
	---- pointeur  vers le plugin --------------------
		m_plug,	
		
	--------  managers divers ---------------
		---- convertisseur Parametres to String  -------------
		mgr_datas 				= str_datasToString 	m_prt:this,
		
		---- les presets (chargement et enregistrement des parametres dans un fichier -----------------
		mgr_presets				= str_presets_batiment  fichier_dossier:		"$userScripts\cp-Urba\lib\\" 	\
																			fichier_categorie:	"Urba_batiment"\
																			fichier_extension:	"bati",
		
		--- construction de la geometrie  -------------------
		mgr_construction		= str_construction 	(),
		
	-------- Les managers des differents éléments du batiment ---------------
		---- facades	----------
		mgr_facades 				= str_manager_parametres (),
		mgr_facCompos 		= str_manager_parametres (),
		mgr_facMenuiseries,
		
		---- toiture	----------
		mgr_toiture 				= str_manager_parametres (),
		mgr_toitElements,
		
		--- surface -----
		mgr_surface				= str_mgr_surfaces (),
		
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
-- private
		
		
		
		
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	----- Actualiser  -----------------------
	public
		fn actualiser =(
			
			---- on actualise la surface ----
			mgr_surface.actualiser ()
			
			---- on consrtuit ----
			mgr_construction.actualiser ()
			
		),		
		
	----- Presets -----------------------
	public
		fn preset_enregistrer  =(
			mgr_presets.enregistrer	 m_plug
		),
		fn preset_charger  =(
			mgr_presets.charger	 m_plug
			charger ()
			m_plug.actualiser_rollouts ()
			actualiser ()
		),
		fn preset_copier  =(
			mgr_presets.copier	 m_plug
		),
		fn preset_coller  =(
			mgr_presets.coller	 	m_plug
			charger ()
			m_plug.actualiser_rollouts ()
			actualiser ()
		),
		
		
	----- Accessions ---------------------------------------------------------------------------------------------
		---- managers et autres ----------
	public
		fn get_mgr_surface			= mgr_surface,
		fn get_mgr_composants 	= mgr_facCompos,
		fn get_mgr_facades	 		= mgr_facades,
		fn get_mgr_toiture	 		= mgr_toiture,
		
		fn get_mgrDatas 				= mgr_datas,
		fn get_mgrPresets 			= mgr_presets,
		
		fn get_construction			= mgr_construction,
		fn get_geo						= mgr_construction.m_geo,
		
		
		---- elements de construction	---------------
	public
		fn get_surface_points				=	mgr_surface.get_points	(),
		fn get_facade				_index	=	mgr_facades.get_element_parIndex		_index,
		fn get_facades							=	mgr_facades.get_elements (),
		
		fn get_toiture							=	mgr_toiture.get_elements (),
		fn get_toiture_index 					=	mgr_toiture.get_constructeur_index 	(get_toiture ()).type,
		
		
		
	----- Facades----------------------------------
	public
		fn creer_facade 								= mgr_facades.creer_element enregistrer:true,
		fn supprimer_facade		_index 		=(
			mgr_facades.supprimer_element		_index
			actualiser ()
		),
		fn dupliquer_facade		_index =(
			
			local facadeSource		=	mgr_facades.get_facade_parIndex		_index			
			local facadeDuplique 	=	mgr_facades.dupliquer_facade 	facadeSource 
			m_plug.actualiser_rollouts ()
			
			facadeDuplique
		),
		fn get_murPlein  _longueur 	= (
			local murTemp = mgr_facCompos.creer_element  idConstructeur:#mur
			murTemp.params.longueur 	=	_longueur
			murTemp
		),
		
		
		
	----- Composants----------------------------------
	public
		fn supprimer_composant 	_facade		_index =(
			
			local supprimer_balconFin 		= false
			local supprimer_balconDebut		= false
			if _facade.sequence[_index].type == #balcon  		do supprimer_balconFin 		= true
			if _facade.sequence[_index].type == #balconFin  	do supprimer_balconDebut 	= true
			
			local supprimer_loggiaFin 		= false
			local supprimer_loggiaDebut		= false
			if _facade.sequence[_index].type == #loggia  		do supprimer_loggiaFin 		= true
			if _facade.sequence[_index].type == #loggiaFin  	do supprimer_loggiaDebut 	= true
				
			_facade.supprimer_composant 		_index
			
			
			--- les balcons -----------------
			if supprimer_balconFin do (
				local i = _index  
				while i <= _facade.sequence.count do (
					if _facade.sequence[i].type == #balconFin do (
						_facade.supprimer_composant 		i
						i  = _facade.sequence.count + 1
					)
					i += 1
				)
			)
			if supprimer_balconDebut do (
				local i = _index  - 1
				while i > 0 do (
					if _facade.sequence[i].type == #balcon do (
						_facade.supprimer_composant 		i
						i  = 0
					)
					i -= 1
				)
			)
			
			--- les loggia -----------------
			if supprimer_loggiaFin do (
				local i = _index  
				while i <= _facade.sequence.count do (
					if _facade.sequence[i].type == #loggiaFin do (
						_facade.supprimer_composant 		i
						i  = _facade.sequence.count + 1
					)
					i += 1
				)
			)
			if supprimer_loggiaDebut do (
				local i = _index  - 1
				while i > 0 do (
					if _facade.sequence[i].type == #loggia do (
						_facade.supprimer_composant 		i
						i  = 0
					)
					i -= 1
				)
			)
			
		),
		fn creer_composant		_facade		_IDconstructeurCompo		position:	=(
			
			if position == unsupplied  do position = _facade.sequence.count
			
			local mgr_composants 	= get_mgr_composants ()
			local nv_composant 		= mgr_composants.creer_composant		_IDconstructeurCompo
			
			_facade.ajouter_composant	nv_composant		position:position
			
			--- gestion Bacon ----------
			if nv_composant.type == #balcon do  (
				local id_baclonFin = mgr_composants.get_constructeur_ID	#balconFin
				creer_composant  _facade	 id_baclonFin  position:(position+1)
			)
			
			--- gestion Loggia ----------
			if nv_composant.type == #loggia do  (
				local id_loggiaFin = mgr_composants.get_constructeur_ID	#loggiaFin
				creer_composant  _facade	 id_loggiaFin  position:(position+1)
			)
			
			
			
			nv_composant
		),
		
		
		
	----- Facades----------------------------------
	public
		fn creer_toiture				_indexConstr				= (
			mgr_toiture.creer_element 		idConstructeur:_indexConstr 	enregistrer:true
			actualiser ()
		),
		
		
		
	----- Surface ---------------------
		fn assigner_surface 		_nodeTHIS		_shape 		=(
			
-- 			appliquer_material		_nodeTHIS
			
			_nodeTHIS.transform = _shape.transform
			mgr_surface.assigner		_shape
			
			actualiser ()
			
		),
		
		
		
		
		
	----- rollout	Editeur de  facades -----------------
	public
		fn facadeEditeur_ouvrir 				_index	=	(
			local dialg_facades	=	mgr_facades.ouvrir_dialog 		()
			local facade_aOuvrir 	= get_facade  		_index
			debug "facade_aOuvrir" var:facade_aOuvrir
-- 			dialg_facades.set_facade	(  )
			
		),
		fn facadeEditeur_fermer 						=	mgr_facades.fermer_dialog 	(),		
		fn facadeEditeur_estOuvert 					= mgr_facades.dialog_estOuvert (),
		fn set_facadeEditeur_position		_pos 	= mgr_facades.set_dialog_pos  	_pos,
		
		
		
		
		
		
		
	----- Initialisation  -----------------------
		fn initialiser 		_plug		= (
			
			debug "initialiser"
			
			m_plug = 	_plug
			
			---- initialisation des managers -----
			mgr_surface.initialiser			m_plug
			mgr_construction.initialiser		m_plug			
			
			mgr_facades.initialiser 		plug:m_plug					\
													fichier_classeBase:			( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\Batiment - Elements - Facade.ms" )	\
													fichier_dialog:				( "Batiment - rollout facade.ms" )		\
													prefix_nomParametres:	"facades"
			
			mgr_facCompos.initialiser 	plug:m_plug					\
													fichier_classeBase:			( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\Batiment - Elements - Composant de facade.ms" )	\
													dossier_constructeurs:	( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\composants de facade\\" )					\
													prefix_nomParametres:	"facCompos"
			
			mgr_toiture.initialiser 		plug:m_plug					\
													fichier_classeBase:			( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\Batiment - Elements - Toiture.ms")	\
													dossier_constructeurs:	( getdir #userScripts + "\cp-Urba\\modules\\Batiment\\elements\\toitures\\"  )					\
													fichier_dialog:				( "Batiment - rollout toiture.ms" )		\
													prefix_nomParametres:	"toiture" 
			
			
		)
		
)  ---- fin batiment core -------------------------












