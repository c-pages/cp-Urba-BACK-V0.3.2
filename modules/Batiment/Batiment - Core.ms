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
include	 "$userScripts\cp-Urba\modules\Batiment\divers\Batiment - Manager Generale.ms"
include	 "$userScripts\cp-Urba\modules\Batiment\Batiment - Managers.ms"
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
		
		mgr_facades_test = str_manager_parametres_univ(),
		
		
	private
	---- pointeur  vers le plugin --------------------
		m_plug,	
		
		
		---  Managers des Eléments du batiments -------------------	
		mgr_surface			= str_mgr_surfaces (),
		mgr_facades			= str_mgr_facades (),	
		mgr_toiture			= str_mgr_toiture (),
		
		---- convertisseur Parametres to String  -------------
		mgr_datas 			= str_datasToString 	m_prt:this,
		
		---- les presets (chargement et enregistrement des parametres dans un fichier -----------------
		mgr_presets			= str_presets_batiment  fichier_dossier:		"$userScripts\cp-Urba\lib\\" 	\
																		fichier_categorie:	"Urba_batiment"\
																		fichier_extension:	"bati",
		/* 
		---  Rollouts Facade -------------------
		roll_facades 				= 	filein	 "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - rollout facade.ms",
		roll_facades_estOuvert = false,
		roll_facades_pos		= [700,200],
		roll_facades_taille		= [500,500],
		 */
		--- construction de la geometrie  -------------------
		m_construction			= str_construction 	(),
		
		
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
/* 	private
	---- Parametres --------------------
		fn charger =(
			
			debug "charger"
			
			--- les parametres à charger --------
			mgr_facades.charger ()
			mgr_toiture.charger ()
			
		),
		 */
		
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	public	
		
	----- Actualiser  -----------------------
		fn actualiser =(
			/* 
			---- on actualise la surface ----
			mgr_surface.actualiser ()
			
			---- on consrtuit ----
			m_construction.actualiser ()
			 */
		),		
		
	----- Presets -----------------------
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
		
		
	----- Accessions -----------------------
	public
		---- managers et autres ----------
		fn get_mgr_surface			= mgr_surface,
		fn get_mgr_composants 	= mgr_facades.get_mgr_composants (),
		fn get_mgr_facades	 		= mgr_facades,
		fn get_mgr_toiture	 		= mgr_toiture,
		
		fn get_mgrDatas 				= mgr_datas,
		fn get_mgrPresets 			= mgr_presets,
		
		fn get_construction			= m_construction,
		fn get_geo						= m_construction.m_geo,
		
		
	public
		---- elements de construction	---------------
		fn get_surface_points				=	mgr_surface.get_points	(),
		fn get_facade				_index	=	mgr_facades.get_facade		_index,
		fn get_facades							=	mgr_facades.get_facades (),
		
		fn get_toiture_index 		=	mgr_toiture.get_index_courant (),
		fn get_toiture				=	mgr_toiture.get_toiture (),
		
		
		
		
	----- Editeur de facades -----------------
	public
		fn facadeEditeur_ouvrir 				_index	=	mgr_facades.ouvrir_dialog 		_index,		
		fn facadeEditeur_fermer 						=	mgr_facades.fermer_dialog 	(),		
		fn facadeEditeur_estOuvert 					= mgr_facades.dialog_estOuvert (),
		fn set_facadeEditeur_position		_pos 	= mgr_facades.set_dialog_pos  	_pos,
		
		
		
		
		
	----- Facades----------------------------------
		fn creer_facade 			=(
			local nv_facade 	= mgr_facades.creer_facade ()
			nv_facade
		),
		fn supprimer_facade		_index =(
			mgr_facades.supprimer_facade		_index
			actualiser ()
		),
		fn dupliquer_facade		_index =(
			
			local facadeSource		=	mgr_facades.get_facade_parIndex		_index			
			local facadeDuplique 	=	mgr_facades.dupliquer_facade 	facadeSource 
			m_plug.actualiser_rollouts ()
			
			facadeDuplique
		),
		
	----- Composants----------------------------------
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
		
		
		
	----- material ---------------------
	private
		fn creer_material =(
			local matID 				= fileIn "$userScripts\cp-Urba\Modules\Batiment\Batiment - material IDs.ms"
			local matIDs_noms	= getPropNames  	matID
			local ids 					= for   matID_nom in matIDs_noms collect ( 	getproperty matID	matID_nom )
			local materials 			= #()
			for   i = 1 to matIDs_noms.count	 do(
				local matID_nom	=	matIDs_noms[i]
				local val_color 		= 30*i + 30
				local variante 		= 40
				append materials    ( CoronaMtl nom:matID_nom  colorDiffuse:[ val_color + random -variante variante  ,  val_color + random -variante variante , val_color   + random -variante variante  ] )				
			)
			
			local nvMat 					= multimaterial  	numsubs:0 --matIDs_noms.count
			nvMat.names 				= matIDs_noms
			nvMat.materialIDList		= ids
			nvMat.materialList			= materials
			
			nvMat
		),
	public 
		fn appliquer_material 	_this		=(
			local nvMat = creer_material ()
			_this.material = nvMat
			nvMat
		),
		
		
	----- Surface ---------------------
		fn assigner_surface 		_nodeTHIS		_shape 		=(
			
			appliquer_material		_nodeTHIS
			
			_nodeTHIS.transform = _shape.transform
			mgr_surface.assigner		_shape
			
			actualiser ()
			
		),
		
		
	----- Initialisation  -----------------------
		fn initialiser 		_plug		= (
			
			debug "initialiser"
			
			m_plug = 	_plug			
			/* 
			---- initialisation des structures -----
			mgr_surface.initialiser			m_plug
			mgr_facades.initialiser			m_plug
			mgr_toiture.initialiser				m_plug
			m_construction.initialiser		m_plug
			*/
			
			/* 
			mgr_facades_test.initialiser 	plug:m_plug					\
														fichier_classeBase:			( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\Batiment - Elements - Facade.ms" )	\
														dossier_constructeurs:		""				\
														dialog:							( filein	 "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - rollout facade.ms" )		\
														prefix_nomParametres:	"facades"
			*/
			mgr_facades_test.initialiser 	plug:m_plug					\
														fichier_classeBase:			( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\Batiment - Elements - Composant de facade.ms" )	\
														dossier_constructeurs:	( getdir #userScripts + "\cp-Urba\modules\Batiment\elements\composants de facade\\" )					\
														dialog:							""				\
														prefix_nomParametres:	"facCompos"
			
		)
		
)  ---- fin batiment core -------------------------












