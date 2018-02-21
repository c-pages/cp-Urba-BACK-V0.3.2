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
include	 "$userScripts\cp-Urba\modules\Batiment\Batiment - Managers.ms"




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
	
		---  Managers des Eléments du batiments -------------------	
		mgr_surface			= str_mgr_surfaces (),
		mgr_facades			= str_mgr_facades (),	
		mgr_toiture			= str_mgr_toiture (),
		
		---- convertisseur Parametres to String  -------------
		mgr_datas 				= str_datasToString 	m_prt:this,
		
		---  Rollouts Facade -------------------
		roll_facades 				= 	filein	 "$userScripts\cp-Urba\modules\Batiment\\rollouts\Batiment - rollout facade.ms",
		roll_facades_pos		= [500,500],
		roll_facades_taille		= [500,300],
		
		--- Sous structures  -------------------
		m_construction		= str_construction 	(),
		
		
	-------- FONCTIONS	--------------------------------------------------------------------------------------------------------
	private
	---- Parametres --------------------
		fn charger =(
			
			debug "charger"
			
			--- les parametres à charger --------
			mgr_facades.charger ()
			mgr_toiture.charger ()
			
		),
		
		
	-------- INTERFACE	--------------------------------------------------------------------------------------------------------
	public	
		
	----- Actualiser  -----------------------
		fn actualiser =(
			
			---- on actualise la surface ----
			mgr_surface.actualiser ()
			
			---- on consrtuit ----
			m_construction.actualiser ()
			
		),		
	----- Initialisation  -----------------------
		fn initialiser 	_plug		= (
			
			debug "initialiser"
			
			m_plug = 	_plug			
			
			---- initialisation des structures -----
			mgr_surface.initialiser			m_plug
			mgr_facades.initialiser			class:str_facade		plug:m_plug
			mgr_toiture.initialiser				m_plug
			m_construction.initialiser		m_plug
			
			--- chargement des parametres ------------------
			charger ()
			
		),
		
		
	----- Accessions -----------------------
	public
		fn get_surface_points		=	mgr_surface.get_points	(),
		
		fn get_facades_noms 		=	mgr_facades.get_noms (),
		fn get_facades					=	mgr_facades.get_items (),
		
		fn get_construction			= m_construction,
		fn get_geo						= m_construction.m_geo,
		
		fn get_toiture_index 			=	mgr_toiture.get_index_courant (),
		fn get_toiture					=	mgr_toiture.get_courant (),
		
		fn get_mgr_surface			= mgr_surface,
		fn get_mgr_composants 	= mgr_facades.get_mgr_composants (),
		fn get_mgr_facades	 		= mgr_facades,
		fn get_mgr_toiture	 		= mgr_toiture,
		fn get_mgrDatas 				= mgr_datas,
			
	---- Mutations	------
	public
		fn set_roll_editeurDeFacade_position	_pos 	=( roll_facades_pos = _pos),
		fn set_roll_editeurDeFacade_taille		_taille 	=( roll_facades_taille = _taille),
		
	----- Editeur de facades -----------------
	public
		fn get_facadeEditeur_rollout = roll_facades,
		fn facadeEditeur_ouvrir 	_index	=(
			debug "ouvrir_facadeEditeur"
			createDialog 	roll_facades	style:				#(#style_resizing) 	\
													pos:					roll_facades_pos		\
													width:				roll_facades_taille.x	\
													height:				roll_facades_taille.y	/* \
													modal:				true \ 
													escapeEnable:	true */
			
			roll_facades.initialiser 		m_plug
			roll_facades.set_facade 	( mgr_facades.get_parIndex	_index )
			
		),
		fn facadeEditeur_fermer 			=(
			destroyDialog 	roll_facades
		),
		
	----- Manipuler les facades et leurs composants	---------------
		fn creer_facade 							=(
			local nv_facade 	= mgr_facades.creer ()
			nv_facade
		),
		fn supprimer_facade		_index =(
			local facadeASupprimer = mgr_facades.get_parIndex		_index
			local confirmation 			= querybox ( "Supprimer "  + facadeASupprimer.nom + " ?" )
			if confirmation do 
				mgr_facades.supprimer		facadeASupprimer.id
			
			m_plug.actualiser_rollouts ()
			
			actualiser ()
		),
		fn creer_composant		_facade		_IDmodelCompo			=(
			local mgr_composants 	= get_mgr_composants ()
			local nv_composant 		= mgr_composants.creer		_IDmodelCompo
			
			_facade.ajouter_composant	nv_composant
			
			--- maj de la longueur de la sequence ---
			_facade.update_sequence_longueur ()
			
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
			
		)
		
		
		
)  ---- fin batiment core -------------------------












