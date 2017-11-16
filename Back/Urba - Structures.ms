
/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################


##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	*v0.1 - [02/10/2016] -----------------------------------------------------------------------------
	- Mise en place globale ( mise au propre du travail durant l'été)
	- Une interface souple et simple
########################################################################################################################*/







---------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------  Presets				 --------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------

---- ELEMENT De Facade -----------------------------------------------------------------------------------------------------------------------------
struct str_urba_preset_modelFacade (
	idUnique			=	"",
	
	nom				=	""	,		----	
	fichier			= ""			----	
)

---- ELEMENT De Facade -----------------------------------------------------------------------------------------------------------------------------
struct str_urba_preset_elementFacade (
	idUnique			=	"",
	
	type 				= 1,			---- 	les types : 	1=Extensible, 2=largeur fixe, 3=model 3D
	largeur			=	100.,		
	model			=	""	,		----	le model 3D ... (fichier ou struct ? .... )
	repetition		= 1			----	pour les groupes (0: sans limite)
)

---- FACADE -----------------------------------------------------------------------------------------------------------------------------
struct str_urba_preset_facade (
	
	idUnique			=	"",
	
	nom 				= 	"Nouvelle façade",
	elements 		=#()
	
)

---- TOITURES -----------------------------------------------------------------------------------------------------------------------------
struct str_urba_preset_toiture (
	
	idUnique			=	"",
	
	nom 				= 	"Nouvelle toiture"
	
)

---- BATIMENT -----------------------------------------------------------------------------------------------------------------------------
struct str_urba_preset_batiment (
	
	idUnique			=	"",
	
	nom 				= 	"Nouveau bâtiment",
	
	toiture		=	1,
	
	etages_facade	=	"",
	etages_min			= 	1,
	etages_max 		= 	5,
	etages_hauteur 	= 	250,
	
	rdc_facade			=	"",
	rdc_hauteur 		= 	300
	
)

---- VILLE -----------------------------------------------------------------------------------------------------------------------------
struct str_urba_preset_ville (
	
	idUnique		=	"",
	
	nom 			=	"Nouvelle ville",
	
	batiments 			=	#(),
	probabilites 		=	#(),
	surfaces_min		= 	#(),
	surfaces_max 		= 	#()
	
)




/* 

struct	str_urba_datas_ville (
	fichier ="",
	
	ville				=	str_urba_preset_ville (),
	
	batiments 		= str_presetsMGR 	preset_type:	str_urba_preset_batiment	\
													fichier:			fichier	\
													prefixUnique:	"Bat",
	
	toitures 			= str_presetsMGR 	preset_type:	str_urba_preset_toiture	\
													fichier:			fichier	\
													prefixUnique:	"Toit",
	
	facades 			= str_presetsMGR 	preset_type:	str_urba_preset_facade	\
													fichier:			fichier	\
													prefixUnique:	"Fac",	
	
	elemsFacade	= str_presetsMGR 	preset_type:	str_urba_preset_elementFacade	\
													fichier:			fichier	\
													prefixUnique:	"ElemF",
	
	modeles			= str_presetsMGR 	preset_type:	str_urba_preset_modelFacade	\
													fichier:			fichier	\
													prefixUnique:	"Mod"
	
)

 */







