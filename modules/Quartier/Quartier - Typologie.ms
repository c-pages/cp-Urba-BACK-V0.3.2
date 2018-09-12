







struct str_typologie (
		
		
		ID									=	"",
		
		nom								=	"Typologie",
		couleur							=	yellow,
		
		
		
		contours_tout							=	true,				----	Si on utilise tout les contours du quartier ou seulement un groupe.
		contours_groupe						=	#(),				----	le groupe des contours du quartier à utiliser pour la typologie.
		contours_index						=	#(),				----	le groupe des contours du quartier à utiliser pour la typologie.
		
		contours_valides						=	#{},				----	
		
		contours_ids_modelBat_choisis	=	#(),				----	le groupe des contours du quartier à utiliser pour la typologie.
		
		
		
		conditions_surfMin_use		=	false,					----	Utilisation d'une condition de surface minimum pour choisir le contour du batiment.	(tableau de booleans)
		conditions_surfMin			=	0,					----	Surface minimum du contour pour être choisi.		(tableau de floats)
		conditions_surfMax_use		=	false,					----	Utilisation d'une condition de surface maximum pour choisir le contour du batiment.	(tableau de booleans)
		conditions_surfMax			=	0,					----	Surface maximum du contour pour être choisi.		(tableau de floats)
		
		conditions_largMin_use		=	false,					----	Utilisation d'une condition de largeur minimum pour choisir le contour du batiment.		(tableau de booleans)
		conditions_largMin			=	0,					----	largeur minimum du contour pour être choisi.		(tableau de floats)
		conditions_largMax_use		=	false,					----	Utilisation d'une condition de largeur maximum pour choisir le contour du batiment.	(tableau de booleans)
		conditions_largMax			=	0,					----	largeur maximum du contour pour être choisi.		(tableau de floats)
		
		conditions_longMin_use		=	false,					----	Utilisation d'une condition de longueur minimum pour choisir le contour du batiment.	(tableau de booleans)
		conditions_longMin			=	0,					----	longueur minimum du contour pour être choisi.		(tableau de floats)
		conditions_longMax_use	=	false,					----	Utilisation d'une condition de longueur maximum pour choisir le contour du batiment.	(tableau de booleans)
		conditions_longMax			=	0,					----	longueur maximum du contour pour être choisi.		(tableau de floats)
		
		
		
		
		
		batiments_models			=	#(),					----	Les fichiers des models des batiments à utiliser pour construir le quartier.
		batiments_ids					=	#(),					----	Les fichiers des models des batiments à utiliser pour construir le quartier.
		batiments_pourcent			=	#(),					----	Liste des pourcentage utilisé pour la création de bâtiment dans cette typologie
		batiments_nbr_etages		=	#(),					----	
		batiments_nbr_etagesPlus	=	#(),					----	
		batiments_ht_etages		=	#(),					----	
		
		variations_nbrEtages		=	#(),					----	Nombre d'étages à ajouter ou a soustraire aux nombres d'étages du model				(tableau de integers)
		variations_nbrEtagesMin	=	#(),					----	Nombre d'étages minimum.		(tableau de integers)
		variations_nbrEtagesMax	=	#(),					----	Nombre d'étages maximum.		(tableau de integers)
		
		
		
		fn initialiser 		=(
			--- generation de l'id unique ------------
			id = "ID_"
			seed ( timeStamp () )
			for i= 1 to 10 do id += ( random 0 9 ) as string	
			
			couleur = color (random 0 255)	(random 0 255)	(random 0 255)	
		)--,
		
		
		
	--	on create do initialiser()
)










