/*#########################################################################################################################
	Christophe Pages (http://www.c-pages.fr)
##########################################################################################################################

	URBA - BATIMENT
	Générateur de batiment procédurale pour utilisation avec générateur de ville procédurale

	QUARTIER - les parametres du plug
	
########################################################################################################################*/





parameters params_contours 						rollout:roll_contours		(
		
		p_contours						type:#nodeTab 			tabSize:0  		tabSizeVariable:true				----	Les shapes des batiments composant le quartier.
		p_contours_surbrillance		type:#boolean			default:false	 	ui:chkbtn_surbillance	 	animatable:false		invisibleInTV:true		
		
		/* 
		p_batiments						type:#stringTab 			tabSize:0  		tabSizeVariable:true				----	Les addresse des fichiers models des batiments à utiliser pour construir le quartier.
		
		p_conditions_surfMin_use		type:#boolTab	 		tabSize:0  		tabSizeVariable:true				----	Utilisation d'une condition de surface minimum pour choisir le contour du batiment.	(tableau de booleans)
		p_conditions_surfMin			type:#floatTab	 		tabSize:0  		tabSizeVariable:true				----	Surface minimum du contour pour être choisi.		(tableau de floats)
		p_conditions_surfMax_use		type:#boolTab	 		tabSize:0  		tabSizeVariable:true				----	Utilisation d'une condition de surface maximum pour choisir le contour du batiment.	(tableau de booleans)
		p_conditions_surfMax			type:#floatTab	 		tabSize:0  		tabSizeVariable:true				----	Surface maximum du contour pour être choisi.		(tableau de floats)
	
		p_conditions_largMin_use		type:#boolTab	 		tabSize:0  		tabSizeVariable:true				----	Utilisation d'une condition de largeur minimum pour choisir le contour du batiment.		(tableau de booleans)
		p_conditions_largMin				type:#floatTab	 		tabSize:0  		tabSizeVariable:true				----	largeur minimum du contour pour être choisi.		(tableau de floats)
		p_conditions_largMax_use		type:#boolTab	 		tabSize:0  		tabSizeVariable:true				----	Utilisation d'une condition de largeur maximum pour choisir le contour du batiment.	(tableau de booleans)
		p_conditions_largMax			type:#floatTab	 		tabSize:0  		tabSizeVariable:true				----	largeur maximum du contour pour être choisi.		(tableau de floats)
	
		p_conditions_longMin_use		type:#boolTab	 		tabSize:0  		tabSizeVariable:true				----	Utilisation d'une condition de longueur minimum pour choisir le contour du batiment.	(tableau de booleans)
		p_conditions_longMin			type:#floatTab	 		tabSize:0  		tabSizeVariable:true				----	longueur minimum du contour pour être choisi.		(tableau de floats)
		p_conditions_longMax_use		type:#boolTab	 		tabSize:0  		tabSizeVariable:true				----	Utilisation d'une condition de longueur maximum pour choisir le contour du batiment.	(tableau de booleans)
		p_conditions_longMax			type:#floatTab	 		tabSize:0  		tabSizeVariable:true				----	longueur maximum du contour pour être choisi.		(tableau de floats)
		
		p_variations_nbrEtages			type:#intTab		 		tabSize:0  		tabSizeVariable:true				----	Nombre d'étages à ajouter ou a soustraire aux nombres d'étages du model				(tableau de integers)
		p_variations_nbrEtagesMin		type:#intTab		 		tabSize:0  		tabSizeVariable:true				----	Nombre d'étages minimum.		(tableau de integers)
		p_variations_nbrEtagesMax	type:#intTab		 		tabSize:0  		tabSizeVariable:true				----	Nombre d'étages maximum.		(tableau de integers)
		*/
)


parameters params_typologies						rollout:roll_typologies		(
		
		p_typologies					type:#stringTab 			tabSize:0  		tabSizeVariable:true				----	Les parametres (sous formes de DATAS (cf. manager Data to string) ) des differentes typologies du quartier.
		
)


parameters params_affichage						rollout:roll_affichage		(
			
	p_majAuto		type:#boolean			default:true	 	ui:ckb_majAuto	 	animatable:false		invisibleInTV:true		
	p_proxies		type:#boolean			default:true	 	ui:ckb_proxies	 	animatable:false		invisibleInTV:true		
		
)
